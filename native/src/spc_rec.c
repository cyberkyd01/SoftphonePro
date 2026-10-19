/* spc_rec.c: recorders.
 *
 * A recorder owns one or two conference-bridge sink ports. put_frame (conference clock thread) only copies the
 * frame into a ring under a short mutex; a writer thread does all file I/O, Opus encoding and resampling.
 * Silence is inserted by wall clock when a side gets no frames (the bridge does not always deliver frames for
 * idle sources), so a recording is always as long as the wall-clock interval and, for wavStereo, both channels
 * stay frame aligned.
 * Lock order: g_rec_mtx -> conference mutex; the per-recorder mutex is a leaf. */
#include "spc_internal.h"
#include "spc_player.h"
#include "spc_rec.h"

#if defined(__has_include)
#  if __has_include(<opus/opus.h>)
#    include <opus/opus.h>
#    define SPC_HAVE_OPUS 1
#  endif
#endif

#define RING_SECONDS 8
#define PAD_MARGIN_FRAMES 5      /* only insert silence once a side is this many frames behind the wall clock */
#define OGG_MAX_SEG 255
#define OGG_FLUSH_PACKETS 50

struct spc_rec;
typedef struct rec_side {
    pjmedia_port port;            /* first: the pjmedia port IS the side */
    struct spc_rec* r;
    int slot;
    int16_t* ring;
    size_t cap, head, len;        /* samples */
    uint64_t pushed;              /* frames pushed (real + silence) */
    uint64_t dropped;
} rec_side;

typedef struct spc_rec {
    struct spc_rec* next;
    int id, fmt, is_mic, mix;
    uint64_t cid;
    char file[600];
    int rate, spf, nsides;
    rec_side side[2];
    spc_mutex_t mtx;
    spc_cond_t cv;
    volatile int stopping;
    int64_t t0;
    FILE* f;
    spc_thread_t th;
    int th_started;
    int refs;                     /* sides not yet destroyed; the recorder is freed with the last one */
    uint64_t frames_out;          /* per channel at `rate` (wav) */
    int io_err;
    /* opus */
#ifdef SPC_HAVE_OPUS
    OpusEncoder* enc;
#endif
    spc_rs* rs;
    int16_t acc[960];
    int nacc;
    uint64_t in48;                /* samples fed to the encoder (before the final padding) */
    uint64_t enc48;               /* samples encoded (multiple of 960) */
    int pre_skip;
    uint32_t serial, pageseq;
    uint8_t lace[OGG_MAX_SEG];
    int nseg, npk;
    uint8_t* pgdata;
    size_t pglen;
    int64_t pending_gp;
} spc_rec;

static spc_mutex_t g_rec_mtx;
static volatile long g_rec_once;
static spc_rec* g_recs;
static int g_rec_next = 1;
static uint32_t g_crc[256];
static volatile long g_crc_once;

static void rec_init_once(void) { spc_mutex_init(&g_rec_mtx); }
static void crc_init_once(void)
{
    uint32_t i, j;
    for (i = 0; i < 256; i++) {
        uint32_t r = i << 24;
        for (j = 0; j < 8; j++) r = (r & 0x80000000u) ? (r << 1) ^ 0x04C11DB7u : (r << 1);
        g_crc[i] = r;
    }
}
static void rec_ensure(void) { spc_once(&g_rec_once, rec_init_once); spc_once(&g_crc_once, crc_init_once); }

int spc_rec_opus_available(void)
{
#ifdef SPC_HAVE_OPUS
    return 1;
#else
    return 0;
#endif
}

/* ---- helpers ---- */
static void put32(uint8_t* b, uint32_t v) { b[0] = (uint8_t)v; b[1] = (uint8_t)(v >> 8); b[2] = (uint8_t)(v >> 16); b[3] = (uint8_t)(v >> 24); }
static void put16(uint8_t* b, unsigned v) { b[0] = (uint8_t)v; b[1] = (uint8_t)(v >> 8); }

static void wav_header(uint8_t* h, int rate, int ch, uint64_t data_bytes)
{
    uint64_t d = data_bytes > 0xFFFFFFF0u - 36 ? 0xFFFFFFF0u - 36 : data_bytes;
    memcpy(h, "RIFF", 4); put32(h + 4, (uint32_t)(36 + d)); memcpy(h + 8, "WAVEfmt ", 8);
    put32(h + 16, 16); put16(h + 20, 1); put16(h + 22, (unsigned)ch); put32(h + 24, (uint32_t)rate);
    put32(h + 28, (uint32_t)(rate * ch * 2)); put16(h + 32, (unsigned)(ch * 2)); put16(h + 34, 16);
    memcpy(h + 36, "data", 4); put32(h + 40, (uint32_t)d);
}

int64_t spc_file_size(const char* path)
{
    FILE* f = fopen(path, "rb");
    long n;
    if (!f) return -1;
    fseek(f, 0, SEEK_END); n = ftell(f); fclose(f);
    return n;
}

int spc_wav_duration_ms(const char* path)
{
    uint8_t h[44];
    FILE* f = fopen(path, "rb");
    uint32_t rate, ba, ds;
    if (!f) return -1;
    if (fread(h, 1, 44, f) != 44 || memcmp(h, "RIFF", 4) || memcmp(h + 8, "WAVEfmt ", 8) || memcmp(h + 36, "data", 4)) { fclose(f); return -1; }
    fclose(f);
    rate = (uint32_t)h[24] | (uint32_t)h[25] << 8 | (uint32_t)h[26] << 16 | (uint32_t)h[27] << 24;
    ba = (uint32_t)h[32] | (uint32_t)h[33] << 8;
    ds = (uint32_t)h[40] | (uint32_t)h[41] << 8 | (uint32_t)h[42] << 16 | (uint32_t)h[43] << 24;
    if (!rate || !ba) return -1;
    return (int)((uint64_t)ds / ba * 1000 / rate);
}

/* ---- sides ---- */
static void side_push(rec_side* s, const int16_t* pcm, int spf)
{
    spc_rec* r = s->r;
    int i;
    spc_mutex_lock(&r->mtx);
    if (s->cap - s->len >= (size_t)spf) {
        size_t w = (s->head + s->len) % s->cap;
        for (i = 0; i < spf; i++) { s->ring[w] = pcm ? pcm[i] : 0; w++; if (w == s->cap) w = 0; }
        s->len += (size_t)spf;
    } else s->dropped++;
    s->pushed++;
    spc_mutex_unlock(&r->mtx);
}

static pj_status_t side_put_frame(pjmedia_port* port, pjmedia_frame* frame)
{
    rec_side* s = (rec_side*)port;
    int spf = s->r->spf;
    if (frame->type == PJMEDIA_FRAME_TYPE_AUDIO && frame->buf && frame->size >= (pj_size_t)spf * 2)
        side_push(s, (const int16_t*)frame->buf, spf);
    else
        side_push(s, NULL, spf);
    return PJ_SUCCESS;
}
static void rec_release(spc_rec* r);
/* Conference ports are removed asynchronously and may still receive put_frame after pjsua_conf_remove_port returns, so
 * the rings and the mutex live until every side has been destroyed (our reference + the conference's are gone). */
static pj_status_t side_on_destroy(pjmedia_port* port) { rec_release(((rec_side*)port)->r); return PJ_SUCCESS; }

/* ---- Ogg ---- */
static void ogg_flush(spc_rec* r, int type, int64_t gp)
{
    uint8_t hdr[27 + OGG_MAX_SEG];
    uint32_t crc = 0;
    size_t i, hl = 27 + (size_t)r->nseg;
    memcpy(hdr, "OggS", 4);
    hdr[4] = 0; hdr[5] = (uint8_t)type;
    for (i = 0; i < 8; i++) hdr[6 + i] = (uint8_t)((uint64_t)gp >> (8 * i));
    put32(hdr + 14, r->serial);
    put32(hdr + 18, r->pageseq++);
    put32(hdr + 22, 0);
    hdr[26] = (uint8_t)r->nseg;
    memcpy(hdr + 27, r->lace, (size_t)r->nseg);
    for (i = 0; i < hl; i++) crc = (crc << 8) ^ g_crc[((crc >> 24) & 0xFF) ^ hdr[i]];
    for (i = 0; i < r->pglen; i++) crc = (crc << 8) ^ g_crc[((crc >> 24) & 0xFF) ^ r->pgdata[i]];
    put32(hdr + 22, crc);
    if (fwrite(hdr, 1, hl, r->f) != hl || (r->pglen && fwrite(r->pgdata, 1, r->pglen, r->f) != r->pglen)) r->io_err = 1;
    r->nseg = 0; r->pglen = 0; r->npk = 0;
}

/* appends one packet (< 64 KB) to the current page; flushes first if the page is full, so the final page (EOS) always
 * carries at least one packet */
static void ogg_packet(spc_rec* r, const uint8_t* d, size_t n, int64_t gp)
{
    size_t need = n / 255 + 1;
    if (r->npk >= OGG_FLUSH_PACKETS || r->nseg + (int)need > OGG_MAX_SEG || r->pglen + n > 60000) ogg_flush(r, 0, r->pending_gp);
    {
        size_t k = n;
        while (k >= 255) { r->lace[r->nseg++] = 255; k -= 255; }
        r->lace[r->nseg++] = (uint8_t)k;
    }
    memcpy(r->pgdata + r->pglen, d, n);
    r->pglen += n;
    r->npk++;
    r->pending_gp = gp;
}

#ifdef SPC_HAVE_OPUS
static void opus_encode_acc(spc_rec* r, int64_t final_gp)
{
    uint8_t out[1500];
    int n = opus_encode(r->enc, r->acc, 960, out, sizeof(out));
    if (n < 0) { r->io_err = 1; r->nacc = 0; return; }
    r->enc48 += 960;
    r->nacc = 0;
    ogg_packet(r, out, (size_t)n, final_gp >= 0 ? final_gp : (int64_t)r->pre_skip + (int64_t)r->enc48);
}

static void opus_sink(void* ctx, const int16_t* pcm, size_t n)
{
    spc_rec* r = (spc_rec*)ctx;
    size_t i = 0;
    r->in48 += n;
    while (i < n) {
        size_t take = 960 - (size_t)r->nacc;
        if (take > n - i) take = n - i;
        memcpy(r->acc + r->nacc, pcm + i, take * sizeof(int16_t));
        r->nacc += (int)take; i += take;
        if (r->nacc == 960) opus_encode_acc(r, -1);
    }
}

static void opus_headers(spc_rec* r)
{
    uint8_t head[19];
    uint8_t tags[64];
    const char* vendor = "SoftphonePro spcore";
    size_t vl = strlen(vendor);
    memcpy(head, "OpusHead", 8);
    head[8] = 1; head[9] = 1;
    put16(head + 10, (unsigned)r->pre_skip);
    put32(head + 12, (uint32_t)r->rate);
    put16(head + 16, 0);
    head[18] = 0;
    memcpy(r->pgdata, head, 19);
    r->pglen = 19; r->lace[0] = 19; r->nseg = 1;
    ogg_flush(r, 0x02, 0);                         /* BOS: OpusHead alone on the first page */
    memcpy(tags, "OpusTags", 8);
    put32(tags + 8, (uint32_t)vl);
    memcpy(tags + 12, vendor, vl);
    put32(tags + 12 + vl, 0);                      /* no user comments */
    memcpy(r->pgdata, tags, 16 + vl);
    r->pglen = 16 + vl; r->lace[0] = (uint8_t)(16 + vl); r->nseg = 1;
    ogg_flush(r, 0, 0);
}
#endif

static void opus_finish(spc_rec* r)
{
#ifdef SPC_HAVE_OPUS
    int64_t gp;
    if (r->rs) spc_rs_flush(r->rs, opus_sink, r);
    if (r->nacc > 0) {
        memset(r->acc + r->nacc, 0, (size_t)(960 - r->nacc) * sizeof(int16_t));
        gp = (int64_t)r->pre_skip + (int64_t)r->in48;
        opus_encode_acc(r, gp);
        r->pending_gp = gp;
    } else if (r->enc48 == 0) {                    /* nothing recorded: emit one silent packet so the stream has audio */
        memset(r->acc, 0, sizeof(r->acc));
        opus_encode_acc(r, (int64_t)r->pre_skip);
    } else {
        r->pending_gp = (int64_t)r->pre_skip + (int64_t)r->in48;
    }
    ogg_flush(r, 0x04, r->pending_gp);             /* EOS */
#else
    (void)r;
#endif
}

/* ---- writer thread ---- */
#define XFER 4096                                   /* frames per transfer */

static void rec_thread(void* arg)
{
    spc_rec* r = (spc_rec*)arg;
    int16_t* tmp = (int16_t*)malloc(sizeof(int16_t) * XFER * 2);
    int16_t* tmp1 = (int16_t*)malloc(sizeof(int16_t) * XFER);
    int i;
    for (;;) {
        int stopping, got = 0, k;
        int64_t elapsed;
        uint64_t target;
        spc_mutex_lock(&r->mtx);
        if (!r->stopping) spc_cond_timedwait(&r->cv, &r->mtx, 20);
        stopping = r->stopping;
        elapsed = spc_mono_ms() - r->t0;
        target = (uint64_t)(elapsed > 0 ? elapsed : 0) * (uint64_t)r->rate / 1000 / (uint64_t)r->spf;
        for (i = 0; i < r->nsides; i++) {
            rec_side* s = &r->side[i];
            uint64_t want = stopping ? target : (target > PAD_MARGIN_FRAMES ? target - PAD_MARGIN_FRAMES : 0);
            while (s->pushed < want) {
                if (s->cap - s->len < (size_t)r->spf) { s->pushed = want; break; }
                {
                    size_t w = (s->head + s->len) % s->cap;
                    int j;
                    for (j = 0; j < r->spf; j++) { s->ring[w] = 0; w++; if (w == s->cap) w = 0; }
                    s->len += (size_t)r->spf;
                    s->pushed++;
                }
            }
        }
        if (stopping && r->nsides == 2) {                         /* equalise the channels */
            rec_side *a = &r->side[0], *b = &r->side[1], *lag = a->len < b->len ? a : b;
            size_t diff = a->len > b->len ? a->len - b->len : b->len - a->len;
            while (diff && lag->len < lag->cap) {
                size_t w = (lag->head + lag->len) % lag->cap;
                lag->ring[w] = 0; lag->len++; diff--;
            }
        }
        /* extract */
        if (r->nsides == 2) {
            size_t n = r->side[0].len < r->side[1].len ? r->side[0].len : r->side[1].len;
            size_t j;
            if (n > XFER) n = XFER;
            for (j = 0; j < n; j++) {
                for (k = 0; k < 2; k++) {
                    rec_side* s = &r->side[k];
                    tmp[2 * j + (size_t)k] = s->ring[s->head];
                    s->head++; if (s->head == s->cap) s->head = 0;
                }
            }
            r->side[0].len -= n; r->side[1].len -= n;
            got = (int)n;
        } else {
            rec_side* s = &r->side[0];
            size_t n = s->len > XFER ? XFER : s->len, j;
            for (j = 0; j < n; j++) { tmp1[j] = s->ring[s->head]; s->head++; if (s->head == s->cap) s->head = 0; }
            s->len -= n;
            got = (int)n;
        }
        spc_mutex_unlock(&r->mtx);
        if (got > 0) {
            if (r->fmt == SPC_REC_OPUS) {
                if (r->rs) spc_rs_push(r->rs, tmp1, (size_t)got, opus_sink, r);
                else
#ifdef SPC_HAVE_OPUS
                    opus_sink(r, tmp1, (size_t)got);
#else
                    ;
#endif
                r->frames_out += (uint64_t)got;
            } else if (r->fmt == SPC_REC_WAV_STEREO) {
                if (fwrite(tmp, 2, (size_t)got * 2, r->f) != (size_t)got * 2) r->io_err = 1;
                r->frames_out += (uint64_t)got;
            } else {
                if (fwrite(tmp1, 2, (size_t)got, r->f) != (size_t)got) r->io_err = 1;
                r->frames_out += (uint64_t)got;
            }
        }
        if (stopping && got == 0) break;
    }
    free(tmp); free(tmp1);
}

/* ---- lifecycle ---- */
static void rec_release(spc_rec* r)
{
    int i, left;
    spc_mutex_lock(&r->mtx);
    left = --r->refs;
    spc_mutex_unlock(&r->mtx);
    if (left > 0) return;
    for (i = 0; i < r->nsides; i++) free(r->side[i].ring);
    spc_mutex_destroy(&r->mtx);
    spc_cond_destroy(&r->cv);
    free(r);
}

/* writer thread must be stopped before; the file/encoder are released here, the object when the ports are gone */
static void rec_free(spc_rec* r)
{
    int i, n;
    if (r->f) { fclose(r->f); r->f = NULL; }
#ifdef SPC_HAVE_OPUS
    if (r->enc) { opus_encoder_destroy(r->enc); r->enc = NULL; }
#endif
    spc_rs_free(r->rs); r->rs = NULL;
    free(r->pgdata); r->pgdata = NULL;
    for (i = 0; i < r->nsides; i++)
        if (r->side[i].slot >= 0) { pjsua_conf_remove_port(r->side[i].slot); r->side[i].slot = -1; }
    n = r->nsides;
    for (i = 0; i < n; i++) pjmedia_port_destroy(&r->side[i].port);    /* r may be gone after the last one: do not touch it again */
}

int spc_rec_start(int fmt, uint64_t cid, int mix, const char* file, int* id, char* err, size_t en)
{
    spc_rec* r;
    pjsua_conf_port_info pi;
    pj_str_t nm;
    int i, rate, spf;
    rec_ensure();
    if (fmt == SPC_REC_OPUS && !spc_rec_opus_available()) { snprintf(err, en, "this build has no Opus encoder"); return -2; }
    if (pjsua_conf_get_port_info(0, &pi) != PJ_SUCCESS) { snprintf(err, en, "audio engine not ready"); return -1; }
    rate = (int)pi.clock_rate; spf = (int)pi.samples_per_frame;
    r = (spc_rec*)calloc(1, sizeof(*r));
    if (!r) { snprintf(err, en, "out of memory"); return -1; }
    r->fmt = fmt; r->cid = cid; r->is_mic = (cid == 0); r->mix = mix;
    r->rate = rate; r->spf = spf;
    r->nsides = fmt == SPC_REC_WAV_STEREO ? 2 : 1;
    r->refs = r->nsides;
    spc_strlcpy(r->file, file, sizeof(r->file));
    spc_mutex_init(&r->mtx);
    spc_cond_init(&r->cv);
    for (i = 0; i < 2; i++) r->side[i].slot = -1;
    for (i = 0; i < r->nsides; i++) { r->side[i].r = r; r->side[i].port.on_destroy = side_on_destroy; }
    r->f = fopen(file, "wb");
    if (!r->f) { snprintf(err, en, "cannot create file '%s'", file); rec_free(r); return -1; }
    for (i = 0; i < r->nsides; i++) {
        rec_side* s = &r->side[i];
        s->cap = (size_t)rate * RING_SECONDS;
        s->ring = (int16_t*)calloc(s->cap, sizeof(int16_t));
        if (!s->ring) { snprintf(err, en, "out of memory"); rec_free(r); return -1; }
    }
    if (fmt == SPC_REC_OPUS) {
#ifdef SPC_HAVE_OPUS
        int oerr = 0, la = 0, k;
        uint8_t rnd[4];
        r->enc = opus_encoder_create(48000, 1, OPUS_APPLICATION_VOIP, &oerr);
        if (!r->enc || oerr != OPUS_OK) { snprintf(err, en, "opus_encoder_create failed (%d)", oerr); rec_free(r); return -1; }
        opus_encoder_ctl(r->enc, OPUS_SET_BITRATE(24000));
        opus_encoder_ctl(r->enc, OPUS_SET_SIGNAL(OPUS_SIGNAL_VOICE));
        opus_encoder_ctl(r->enc, OPUS_SET_COMPLEXITY(6));
        opus_encoder_ctl(r->enc, OPUS_GET_LOOKAHEAD(&la));
        r->pre_skip = la;
        r->pgdata = (uint8_t*)malloc(64 * 1024);
        if (!r->pgdata) { snprintf(err, en, "out of memory"); rec_free(r); return -1; }
        if (rate != 48000) {
            r->rs = spc_rs_new(rate, 48000);
            if (!r->rs) { snprintf(err, en, "out of memory"); rec_free(r); return -1; }
        }
        {
            int64_t t = spc_now_ms() ^ ((int64_t)cid << 20) ^ (int64_t)(uintptr_t)r;
            for (k = 0; k < 4; k++) rnd[k] = (uint8_t)(t >> (8 * k) ^ t >> (8 * k + 17));
            r->serial = (uint32_t)rnd[0] | (uint32_t)rnd[1] << 8 | (uint32_t)rnd[2] << 16 | (uint32_t)rnd[3] << 24;
        }
        opus_headers(r);
        if (r->io_err) { snprintf(err, en, "cannot write file '%s'", file); rec_free(r); return -1; }
#endif
    } else {
        uint8_t h[44];
        wav_header(h, rate, r->nsides, 0);
        if (fwrite(h, 1, 44, r->f) != 44) { snprintf(err, en, "cannot write file '%s'", file); rec_free(r); return -1; }
    }
    nm = spc_pjs("spcrec");
    for (i = 0; i < r->nsides; i++) {
        rec_side* s = &r->side[i];
        pj_status_t st;
        pjmedia_port_info_init(&s->port.info, &nm, PJMEDIA_SIG_CLASS_PORT_AUD('S', 'R'), (unsigned)rate, 1, 16, (unsigned)spf);
        s->port.put_frame = side_put_frame;
        st = pjsua_conf_add_port(spc_media_pool, &s->port, &s->slot);
        if (st != PJ_SUCCESS) { s->slot = -1; snprintf(err, en, "conference port: pj status %d", (int)st); rec_free(r); return -1; }
    }
    r->t0 = spc_mono_ms();
    if (spc_thread_create(&r->th, rec_thread, r) != 0) { snprintf(err, en, "cannot start writer thread"); rec_free(r); return -1; }
    r->th_started = 1;
    spc_mutex_lock(&g_rec_mtx);
    r->id = g_rec_next++;
    r->next = g_recs; g_recs = r;
    spc_mutex_unlock(&g_rec_mtx);
    *id = r->id;
    return 0;
}

static spc_rec* rec_take(int id)
{
    spc_rec *r, *prev = NULL;
    rec_ensure();
    spc_mutex_lock(&g_rec_mtx);
    for (r = g_recs; r; prev = r, r = r->next)
        if (r->id == id) {
            if (prev) prev->next = r->next; else g_recs = r->next;
            spc_mutex_unlock(&g_rec_mtx);
            return r;
        }
    spc_mutex_unlock(&g_rec_mtx);
    return NULL;
}

static void rec_finalize(spc_rec* r, spc_rec_result* out)
{
    int i;
    /* the bridge stops delivering frames, the writer pads to the wall clock and drains */
    for (i = 0; i < r->nsides; i++)
        if (r->side[i].slot >= 0) { pjsua_conf_remove_port(r->side[i].slot); r->side[i].slot = -1; }
    spc_mutex_lock(&r->mtx);
    r->stopping = 1;
    spc_cond_signal(&r->cv);
    spc_mutex_unlock(&r->mtx);
    if (r->th_started) spc_thread_join(&r->th);
    r->th_started = 0;
    if (r->fmt == SPC_REC_OPUS) {
        opus_finish(r);
    } else {
        uint8_t h[44];
        wav_header(h, r->rate, r->nsides, r->frames_out * (uint64_t)r->nsides * 2);
        fseek(r->f, 0, SEEK_SET);
        if (fwrite(h, 1, 44, r->f) != 44) r->io_err = 1;
        fseek(r->f, 0, SEEK_END);
    }
    fflush(r->f);
    if (out) {
        long sz = ftell(r->f);
        memset(out, 0, sizeof(*out));
        spc_strlcpy(out->file, r->file, sizeof(out->file));
        out->bytes = sz < 0 ? 0 : sz;
        out->durationMs = r->fmt == SPC_REC_OPUS ? (int)(r->in48 / 48) : (int)(r->frames_out * 1000 / (uint64_t)r->rate);
        spc_strlcpy(out->format, r->fmt == SPC_REC_OPUS ? "opus" : r->fmt == SPC_REC_WAV_STEREO ? "wavStereo" : "wav", sizeof(out->format));
    }
}

int spc_rec_stop(int id, spc_rec_result* out)
{
    spc_rec* r = rec_take(id);
    if (!r) return -1;
    rec_finalize(r, out);
    rec_free(r);
    return 0;
}

void spc_rec_shutdown(void)
{
    spc_rec* r;
    rec_ensure();
    for (;;) {
        spc_mutex_lock(&g_rec_mtx);
        r = g_recs;
        if (r) g_recs = r->next;
        spc_mutex_unlock(&g_rec_mtx);
        if (!r) break;
        rec_finalize(r, NULL);
        rec_free(r);
    }
}

/* ---- topology ---- */
static void conn(int src, int dst, int want)
{
    if (src < 0 || dst < 0) return;
    if (want) pjsua_conf_connect(src, dst);
    else pjsua_conf_disconnect(src, dst);
}

/* Same semantics as conn_mic() in spc_call.c: msrc >= 0 is the voice-isolation processor feeding the mic path,
 * dnm the processor slot if it exists (so a stale path is removed). */
static void mic_conn(int sink, int want, int msrc, int dnm)
{
    if (want) {
        if (msrc >= 0) { conn(msrc, sink, 1); conn(0, sink, 0); }
        else { conn(0, sink, 1); if (dnm >= 0) conn(dnm, sink, 0); }
    } else {
        conn(0, sink, 0);
        if (dnm >= 0) conn(dnm, sink, 0);
    }
}

int spc_rec_mic_id(void)
{
    spc_rec* r;
    int id = 0;
    rec_ensure();
    spc_mutex_lock(&g_rec_mtx);
    for (r = g_recs; r; r = r->next) if (r->is_mic) { id = r->id; break; }
    spc_mutex_unlock(&g_rec_mtx);
    return id;
}

void spc_rec_apply_call(int id, int cslot, int active, int muted, int detached, int msrc, int dnm)
{
    spc_rec* r;
    if (id <= 0) return;
    rec_ensure();
    spc_mutex_lock(&g_rec_mtx);
    for (r = g_recs; r; r = r->next) {
        if (r->id != id) continue;
        if (r->fmt == SPC_REC_WAV_STEREO) {
            mic_conn(r->side[0].slot, !muted && !detached, msrc, dnm);
            conn(cslot, r->side[1].slot, active);
        } else {
            conn(cslot, r->side[0].slot, active && (r->mix == 0 || r->mix == 1));
            mic_conn(r->side[0].slot, (r->mix == 0 || r->mix == 2) && !muted && !detached, msrc, dnm);
        }
        break;
    }
    spc_mutex_unlock(&g_rec_mtx);
}

void spc_rec_apply_global(int msrc, int dnm)
{
    spc_rec* r;
    rec_ensure();
    spc_mutex_lock(&g_rec_mtx);
    for (r = g_recs; r; r = r->next)
        if (r->is_mic) mic_conn(r->side[0].slot, 1, msrc, dnm);
    spc_mutex_unlock(&g_rec_mtx);
}
