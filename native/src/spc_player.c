/* spc_player.c: media file player (WAV PCM16/µ-law/A-law/PCM8/24/32/float, MP3 via minimp3), music on hold,
 * and the streaming resampler shared with the recorder.
 *
 * Design: a play = a pjmedia port registered in the conference bridge. A helper thread decodes the file
 * (downmix to mono, resample to the bridge rate) into a chunked in-memory store; the port's get_frame (conference
 * clock thread) only copies from the store under a tiny mutex and never does file I/O or allocation.
 * A play is owned by exactly one party: whoever removes it from the table (spc_player_stop*, EOF timer, shutdown)
 * destroys it. Lock order: g_pl_mtx -> conference mutex; per-play mutex is a leaf. */
#include "spc_internal.h"
#include "spc_player.h"
#include "spc_mp3.h"
#include <math.h>
#ifndef M_PI
#define M_PI 3.14159265358979323846   /* MSVC: M_PI needs _USE_MATH_DEFINES */
#endif

#define CHUNK 8192                     /* samples per store chunk */
#define MAX_PLAYS_PER_CALL 16

/* ------------------------------------------------------------------ */
/* resampler                                                           */
/* ------------------------------------------------------------------ */
#define RS_ZC 8
#define RS_TBL 2048

struct spc_rs {
    double step, pos, W;
    int64_t base;
    float* buf;
    size_t len, cap;
    float* tbl;
};

spc_rs* spc_rs_new(int in_rate, int out_rate)
{
    spc_rs* r;
    double fc;
    int i;
    if (in_rate <= 0 || out_rate <= 0) return NULL;
    r = (spc_rs*)calloc(1, sizeof(*r));
    if (!r) return NULL;
    r->step = (double)in_rate / (double)out_rate;
    fc = r->step > 1.0 ? 1.0 / r->step : 1.0;
    r->W = RS_ZC / fc;
    r->tbl = (float*)malloc(sizeof(float) * (RS_TBL + 2));
    if (!r->tbl) { free(r); return NULL; }
    for (i = 0; i <= RS_TBL + 1; i++) {
        double u = (double)i / RS_TBL, d = u * r->W, x = fc * d, s;
        double w = 0.42 + 0.5 * cos(M_PI * u) + 0.08 * cos(2.0 * M_PI * u);
        s = x < 1e-9 ? 1.0 : sin(M_PI * x) / (M_PI * x);
        r->tbl[i] = (float)(fc * s * (u <= 1.0 ? w : 0.0));
    }
    return r;
}

void spc_rs_free(spc_rs* r)
{
    if (!r) return;
    free(r->buf); free(r->tbl); free(r);
}

static void rs_process(spc_rs* r, int flushing, spc_rs_sink sink, void* ctx)
{
    int16_t ob[512];
    size_t no = 0;
    for (;;) {
        int64_t lo = (int64_t)ceil(r->pos - r->W), hi = (int64_t)floor(r->pos + r->W), j;
        double sum = 0.0, invW = 1.0 / r->W;
        int64_t end = r->base + (int64_t)r->len;
        int v;
        if (!flushing && hi >= end) break;
        if (flushing && r->pos >= (double)end) break;
        for (j = lo; j <= hi; j++) {
            double u, idx, fr;
            int ii;
            float x;
            if (j < r->base || j >= end) continue;     /* zeros outside the signal */
            x = r->buf[j - r->base];
            u = fabs((double)j - r->pos) * invW;
            idx = u * RS_TBL;
            ii = (int)idx;
            fr = idx - ii;
            sum += (double)x * ((double)r->tbl[ii] + ((double)r->tbl[ii + 1] - (double)r->tbl[ii]) * fr);
        }
        v = (int)lrint(sum);
        ob[no++] = (int16_t)(v > 32767 ? 32767 : v < -32768 ? -32768 : v);
        if (no == sizeof(ob) / sizeof(ob[0])) { sink(ctx, ob, no); no = 0; }
        r->pos += r->step;
    }
    if (no) sink(ctx, ob, no);
    {
        int64_t keep = (int64_t)floor(r->pos - r->W) - 1;
        if (keep > r->base) {
            size_t drop = (size_t)(keep - r->base);
            if (drop > r->len) drop = r->len;
            memmove(r->buf, r->buf + drop, (r->len - drop) * sizeof(float));
            r->len -= drop;
            r->base += (int64_t)drop;
        }
    }
}

void spc_rs_push(spc_rs* r, const int16_t* in, size_t n, spc_rs_sink sink, void* ctx)
{
    size_t i;
    if (!r || !n) return;
    if (r->len + n > r->cap) {
        size_t nc = (r->len + n) * 2 + 1024;
        float* nb = (float*)realloc(r->buf, nc * sizeof(float));
        if (!nb) return;
        r->buf = nb; r->cap = nc;
    }
    for (i = 0; i < n; i++) r->buf[r->len + i] = (float)in[i];
    r->len += n;
    rs_process(r, 0, sink, ctx);
}

void spc_rs_flush(spc_rs* r, spc_rs_sink sink, void* ctx)
{
    if (r) rs_process(r, 1, sink, ctx);
}

/* ------------------------------------------------------------------ */
/* sources                                                             */
/* ------------------------------------------------------------------ */
typedef struct {
    int kind;                    /* 1 wav, 2 mp3 */
    int rate, ch;
    int64_t frames;              /* per channel */
    /* wav */
    FILE* f;
    int tag, bits, block;
    int64_t remain;              /* data bytes left */
    /* mp3 */
    uint8_t* mp3buf;
    spc_mp3* mp3;
} spc_src;

static void src_close(spc_src* s)
{
    if (s->f) fclose(s->f);
    if (s->mp3) spc_mp3_close(s->mp3);
    free(s->mp3buf);
    memset(s, 0, sizeof(*s));
}

static uint32_t rd32(const uint8_t* b) { return (uint32_t)b[0] | (uint32_t)b[1] << 8 | (uint32_t)b[2] << 16 | (uint32_t)b[3] << 24; }
static uint16_t rd16(const uint8_t* b) { return (uint16_t)(b[0] | b[1] << 8); }

static int16_t ulaw2lin(uint8_t b)
{
    int u = ~b, t = ((u & 0x0F) << 3) + 0x84;
    t <<= (u & 0x70) >> 4;
    return (int16_t)((u & 0x80) ? (0x84 - t) : (t - 0x84));
}

static int16_t alaw2lin(uint8_t b)
{
    int a = b ^ 0x55, t = (a & 0x0F) << 4, seg = (a & 0x70) >> 4;
    if (seg == 0) t += 8;
    else { t += 0x108; if (seg > 1) t <<= (seg - 1); }
    return (int16_t)((a & 0x80) ? t : -t);
}

#if defined(_MSC_VER) || defined(_WIN32)
#define SPC_FSEEK64(f, o, w) _fseeki64((f), (__int64)(o), (w))
#define SPC_FTELL64(f) ((int64_t)_ftelli64(f))
#else
#define SPC_FSEEK64(f, o, w) fseeko((f), (off_t)(o), (w))
#define SPC_FTELL64(f) ((int64_t)ftello(f))
#endif
#define WAV_MAX_CHUNKS 1000

static int wav_open(spc_src* s, FILE* f, char* err, size_t en)
{
    uint8_t h[12], ck[8], fmt[40];
    int have_fmt = 0, nchunks = 0;
    int64_t data_off = -1, fsize, pos, avail;
    uint32_t dsize = 0;
    if (fread(h, 1, 12, f) != 12 || (memcmp(h, "RIFF", 4) && memcmp(h, "RF64", 4)) || memcmp(h + 8, "WAVE", 4)) {
        snprintf(err, en, "not a WAV file");
        return -1;
    }
    if (SPC_FSEEK64(f, 0, SEEK_END) != 0) { snprintf(err, en, "cannot read file"); return -1; }
    fsize = SPC_FTELL64(f);
    if (fsize < 12 || SPC_FSEEK64(f, 12, SEEK_SET) != 0) { snprintf(err, en, "not a WAV file"); return -1; }
    pos = 12;
    while (nchunks++ < WAV_MAX_CHUNKS) {
        uint32_t sz;
        int64_t body, next;
        if (pos + 8 > fsize || fread(ck, 1, 8, f) != 8) break;
        sz = rd32(ck + 4);
        body = pos + 8;
        next = body + (int64_t)sz + (int64_t)(sz & 1);          /* chunks are word aligned */
        if (!memcmp(ck, "data", 4)) {
            data_off = body; dsize = sz;
            break;
        }
        if (!memcmp(ck, "fmt ", 4)) {
            size_t n = sz < sizeof(fmt) ? sz : sizeof(fmt);
            if (body + (int64_t)n > fsize) { snprintf(err, en, "bad WAV fmt chunk"); return -1; }
            memset(fmt, 0, sizeof(fmt));
            if (n < 16 || fread(fmt, 1, n, f) != n) { snprintf(err, en, "bad WAV fmt chunk"); return -1; }
            have_fmt = 1;
        }
        if (next <= pos || next > fsize) break;                  /* chunk claims to extend past the file */
        if (SPC_FSEEK64(f, next, SEEK_SET) != 0) break;
        pos = next;
    }
    if (!have_fmt || data_off < 0) { snprintf(err, en, "WAV has no fmt/data chunk"); return -1; }
    s->tag = rd16(fmt);
    s->ch = rd16(fmt + 2);
    s->rate = (int)rd32(fmt + 4);
    s->bits = rd16(fmt + 14);
    if (s->tag == 0xFFFE) s->tag = rd16(fmt + 24);          /* WAVE_FORMAT_EXTENSIBLE: sub-format GUID */
    if (s->ch < 1 || s->ch > 8 || s->rate < 1000 || s->rate > 384000) { snprintf(err, en, "unsupported WAV channels/rate (%d ch, %d Hz)", s->ch, s->rate); return -1; }
    if (s->tag == 1 && (s->bits == 8 || s->bits == 16 || s->bits == 24 || s->bits == 32)) {}
    else if (s->tag == 3 && s->bits == 32) {}
    else if ((s->tag == 6 || s->tag == 7) && s->bits == 8) {}
    else { snprintf(err, en, "unsupported WAV encoding (tag %d, %d bits); need PCM, float, mu-law or A-law", s->tag, s->bits); return -1; }
    s->block = s->ch * (s->bits / 8);
    avail = fsize - data_off;
    if (avail < 0) avail = 0;
    if (avail > 0xFFFFFFFFLL) avail = 0xFFFFFFFFLL;
    if (dsize == 0 || dsize > (uint32_t)avail || dsize == 0xFFFFFFFFu) dsize = (uint32_t)avail;
    s->remain = dsize;
    s->frames = dsize / s->block;
    s->kind = 1;
    s->f = f;
    return 0;
}

static int src_open(spc_src* s, const char* path, char* err, size_t en)
{
    FILE* f;
    uint8_t magic[4];
    size_t n;
    memset(s, 0, sizeof(*s));
    f = fopen(path, "rb");
    if (!f) { snprintf(err, en, "cannot open file '%s'", path); return -1; }
    n = fread(magic, 1, 4, f);
    rewind(f);
    if (n == 4 && (!memcmp(magic, "RIFF", 4) || !memcmp(magic, "RF64", 4))) {
        if (wav_open(s, f, err, en) != 0) { fclose(f); memset(s, 0, sizeof(*s)); return -1; }
        return 0;
    }
    {   /* MP3: read the (small) file into memory; minimp3 scans it for the duration */
        int64_t sz;
        uint64_t total = 0;
        if (SPC_FSEEK64(f, 0, SEEK_END) != 0) { fclose(f); snprintf(err, en, "cannot read file"); return -1; }
        sz = SPC_FTELL64(f);
        SPC_FSEEK64(f, 0, SEEK_SET);
        if (sz <= 0) { fclose(f); snprintf(err, en, "file is empty"); return -1; }
        if ((uint64_t)sz > SPC_PLAY_MAX_MP3_BYTES) { fclose(f); snprintf(err, en, "file too large (max 64 MB for MP3)"); return -1; }
        s->mp3buf = (uint8_t*)malloc((size_t)sz);
        if (!s->mp3buf || fread(s->mp3buf, 1, (size_t)sz, f) != (size_t)sz) {
            fclose(f); free(s->mp3buf); memset(s, 0, sizeof(*s));
            snprintf(err, en, "cannot read file");
            return -1;
        }
        fclose(f);
        s->mp3 = spc_mp3_open(s->mp3buf, (size_t)sz, &s->rate, &s->ch, &total);
        if (!s->mp3) { free(s->mp3buf); memset(s, 0, sizeof(*s)); snprintf(err, en, "unsupported or corrupt audio file (need WAV or MP3)"); return -1; }
        s->frames = (int64_t)(total / (uint64_t)s->ch);
        s->kind = 2;
        return 0;
    }
}

/* reads up to max mono frames (downmixed); returns frames, 0 at the end, -1 on error */
static int src_read(spc_src* s, int16_t* out, int max)
{
    int i, c;
    if (s->kind == 2) {
        int16_t tmp[4096 * 2];
        int want = max > 4096 ? 4096 : max;
        size_t got;
        if (s->ch > 2) {      /* minimp3 only emits mono/stereo */
            return -1;
        }
        got = spc_mp3_read(s->mp3, tmp, (size_t)want * (size_t)s->ch);
        got /= (size_t)s->ch;
        for (i = 0; i < (int)got; i++)
            out[i] = s->ch == 1 ? tmp[i] : (int16_t)(((int)tmp[2 * i] + (int)tmp[2 * i + 1]) / 2);
        return (int)got;
    } else {
        uint8_t raw[4096 * 8 * 4];
        int want = max;
        size_t nread, nfr;
        if (want > 4096) want = 4096;
        if ((int64_t)want * s->block > s->remain) want = (int)(s->remain / s->block);
        if (want <= 0) return 0;
        nread = fread(raw, 1, (size_t)want * (size_t)s->block, s->f);
        nfr = nread / (size_t)s->block;
        if (nfr == 0) return 0;
        s->remain -= (int64_t)nfr * s->block;
        for (i = 0; i < (int)nfr; i++) {
            int acc = 0;
            const uint8_t* b = raw + (size_t)i * (size_t)s->block;
            for (c = 0; c < s->ch; c++) {
                int v;
                if (s->tag == 7) v = ulaw2lin(b[c]);
                else if (s->tag == 6) v = alaw2lin(b[c]);
                else if (s->tag == 3) { float fv; uint32_t u = rd32(b + 4 * c); memcpy(&fv, &u, 4); v = (int)lrintf(fv * 32767.0f); if (v > 32767) v = 32767; if (v < -32768) v = -32768; }
                else if (s->bits == 8) v = ((int)b[c] - 128) << 8;
                else if (s->bits == 16) v = (int16_t)rd16(b + 2 * c);
                else if (s->bits == 24) v = (int16_t)rd16(b + 3 * c + 1);
                else v = (int16_t)rd16(b + 4 * c + 2);
                acc += v;
            }
            out[i] = (int16_t)(acc / s->ch);
        }
        return (int)nfr;
    }
}

int spc_media_file_info(const char* path, spc_fileinfo* fi, char* err, size_t en)
{
    spc_src s;
    if (!path || !path[0]) { snprintf(err, en, "'file' required"); return -1; }
    if (src_open(&s, path, err, en) != 0) return -1;
    memset(fi, 0, sizeof(*fi));
    spc_strlcpy(fi->format, s.kind == 1 ? "wav" : "mp3", sizeof(fi->format));
    fi->sampleRate = s.rate;
    fi->channels = s.ch;
    fi->durationMs = (int)(s.frames * 1000 / s.rate);
    src_close(&s);
    return 0;
}

/* ------------------------------------------------------------------ */
/* player objects                                                      */
/* ------------------------------------------------------------------ */
typedef struct spc_play {
    pjmedia_port port;           /* must stay first: the pjmedia port IS the object */
    struct spc_play* next;
    int id;
    uint64_t cid;
    char file[600];
    int loop, moh, local_monitor, mute_mic;
    int slot, spf, rate;
    int gain_q10;
    /* store */
    spc_mutex_t mtx;
    int16_t** chunks;
    size_t max_chunks;
    size_t total, pos;
    int decode_done, decode_err, eof_sched;
    /* decoder */
    spc_src src;
    spc_rs* rs;
    spc_thread_t th;
    int th_started;
    volatile int cancel;
} spc_play;

static spc_mutex_t g_pl_mtx;
static volatile long g_pl_once;
static spc_play* g_plays;
static int g_next_id = 1;

typedef struct moh_ent {
    struct moh_ent* next;
    uint64_t cid;
    char file[600];
    int loop;
    float volume;
    int running;
} moh_ent;
static moh_ent* g_moh;

static void pl_init_once(void) { spc_mutex_init(&g_pl_mtx); }
static void pl_ensure(void) { spc_once(&g_pl_once, pl_init_once); }

/* decoder -> store */
static void store_append(spc_play* p, const int16_t* pcm, size_t n)
{
    spc_mutex_lock(&p->mtx);
    while (n) {
        size_t ci = p->total / CHUNK, off = p->total % CHUNK, take = CHUNK - off;
        if (take > n) take = n;
        if (ci >= p->max_chunks) { p->decode_err = 1; break; }
        if (!p->chunks[ci]) {
            p->chunks[ci] = (int16_t*)malloc(CHUNK * sizeof(int16_t));
            if (!p->chunks[ci]) { p->decode_err = 1; break; }
        }
        memcpy(p->chunks[ci] + off, pcm, take * sizeof(int16_t));
        p->total += take;
        pcm += take; n -= take;
    }
    spc_mutex_unlock(&p->mtx);
}

static void rs_sink(void* ctx, const int16_t* pcm, size_t n) { store_append((spc_play*)ctx, pcm, n); }

static void dec_thread(void* arg)
{
    spc_play* p = (spc_play*)arg;
    int16_t in[4096];
    while (!p->cancel) {
        int n = src_read(&p->src, in, 4096);
        if (n < 0) { spc_mutex_lock(&p->mtx); p->decode_err = 1; spc_mutex_unlock(&p->mtx); break; }
        if (n == 0) { if (p->rs) spc_rs_flush(p->rs, rs_sink, p); break; }
        if (p->rs) spc_rs_push(p->rs, in, (size_t)n, rs_sink, p);
        else store_append(p, in, (size_t)n);
        if (p->decode_err) break;
    }
    spc_mutex_lock(&p->mtx);
    p->decode_done = 1;
    spc_mutex_unlock(&p->mtx);
}

static void play_done_timer(void* ud);

static pj_status_t pl_get_frame(pjmedia_port* port, pjmedia_frame* frame)
{
    spc_play* p = (spc_play*)port;
    int16_t* out = (int16_t*)frame->buf;
    unsigned n = 0, spf = (unsigned)p->spf, i;
    int eof = 0, sched = 0;
    spc_mutex_lock(&p->mtx);
    while (n < spf) {
        if (p->pos < p->total) {
            size_t ci = p->pos / CHUNK, off = p->pos % CHUNK, take = CHUNK - off, avail = p->total - p->pos;
            if (take > avail) take = avail;
            if (take > spf - n) take = spf - n;
            memcpy(out + n, p->chunks[ci] + off, take * sizeof(int16_t));
            n += (unsigned)take; p->pos += take;
        } else if (p->decode_done) {
            if (p->loop && p->total > 0 && !p->decode_err) { p->pos = 0; continue; }
            eof = 1;
            break;
        } else break;        /* decoder is behind: play silence for now */
    }
    if (eof && !p->eof_sched) { p->eof_sched = 1; sched = 1; }
    spc_mutex_unlock(&p->mtx);
    if (p->gain_q10 != 1024)
        for (i = 0; i < n; i++) {
            int v = (out[i] * p->gain_q10) >> 10;
            out[i] = (int16_t)(v > 32767 ? 32767 : v < -32768 ? -32768 : v);
        }
    if (n < spf) memset(out + n, 0, (spf - n) * sizeof(int16_t));
    frame->size = spf * sizeof(int16_t);
    frame->type = (n == 0 && eof) ? PJMEDIA_FRAME_TYPE_NONE : PJMEDIA_FRAME_TYPE_AUDIO;
    frame->timestamp.u64 = 0;
    if (sched) spc_call_schedule_timer(play_done_timer, (uint64_t)p->id, 0);
    return PJ_SUCCESS;
}

static pj_status_t pl_put_frame(pjmedia_port* port, pjmedia_frame* frame) { (void)port; (void)frame; return PJ_SUCCESS; }
/* The conference removes ports asynchronously (ops run at the start of the next clock tick) and holds a reference on
 * the port's group lock until then. The object may therefore still be read by get_frame after pjsua_conf_remove_port
 * returns: it is freed only here, when the last reference (ours from play_destroy, the conference's) is gone. */
static pj_status_t pl_on_destroy(pjmedia_port* port)
{
    spc_play* p = (spc_play*)port;
    size_t i;
    for (i = 0; i < p->max_chunks; i++) free(p->chunks[i]);
    free(p->chunks);
    spc_rs_free(p->rs);
    src_close(&p->src);
    spc_mutex_destroy(&p->mtx);
    free(p);
    return PJ_SUCCESS;
}

static void play_destroy(spc_play* p)
{
    p->cancel = 1;
    if (p->th_started) { spc_thread_join(&p->th); p->th_started = 0; }
    if (p->slot >= 0) pjsua_conf_remove_port(p->slot);
    pjmedia_port_destroy(&p->port);          /* drops our reference; p may be gone on return */
}

/* mode: 0 = non-MOH plays of cid, 1 = any play of cid, 2 = MOH play of cid; id > 0 matches that id */
static spc_play* take_match(uint64_t cid, int id, int mode)
{
    spc_play *p, *prev = NULL;
    pl_ensure();
    spc_mutex_lock(&g_pl_mtx);
    for (p = g_plays; p; prev = p, p = p->next) {
        int m = (id > 0) ? (p->id == id && (cid == 0 || p->cid == cid))
                         : (p->cid == cid && (mode == 1 || (mode == 2) == (p->moh != 0)));
        if (m) {
            if (prev) prev->next = p->next; else g_plays = p->next;
            p->next = NULL;
            spc_mutex_unlock(&g_pl_mtx);
            return p;
        }
    }
    spc_mutex_unlock(&g_pl_mtx);
    return NULL;
}

int spc_player_ann_mute(uint64_t cid)
{
    spc_play* p;
    int n = 0;
    pl_ensure();
    spc_mutex_lock(&g_pl_mtx);
    for (p = g_plays; p; p = p->next) if (p->cid == cid && p->mute_mic) n++;
    spc_mutex_unlock(&g_pl_mtx);
    return n;
}

static void ann_refresh(uint64_t cid)
{
    int n = spc_player_ann_mute(cid);
    spc_call* c = spc_call_lock_find(cid);
    if (c) { c->ann_mute = n > 0; spc_registry_unlock(); }
    spc_call_apply_topology();
}

static void moh_remove(uint64_t cid);

static void finish_play(spc_play* p, const char* reason, int emit)
{
    uint64_t cid = p->cid;
    int id = p->id, moh = p->moh, had_mute = p->mute_mic;
    char file[600];
    spc_strlcpy(file, p->file, sizeof(file));
    play_destroy(p);
    if (moh) moh_remove(cid);
    if (emit) {
        cJSON* f = cJSON_CreateObject();
        cJSON_AddNumberToObject(f, "cid", (double)cid);
        cJSON_AddNumberToObject(f, "playId", id);
        cJSON_AddStringToObject(f, "file", file);
        cJSON_AddStringToObject(f, "reason", reason);
        if (moh) cJSON_AddBoolToObject(f, "moh", 1);
        spc_call_emit(cid, "call.playDone", f);
    }
    if (had_mute) ann_refresh(cid);
}

static void play_done_timer(void* ud)
{
    int id = (int)(uintptr_t)ud;
    spc_play* p = take_match(0, id, 1);
    int err;
    if (!p) return;
    spc_mutex_lock(&p->mtx);
    err = p->decode_err;
    spc_mutex_unlock(&p->mtx);
    finish_play(p, err ? "error" : "eof", 1);
}

int spc_player_stop(uint64_t cid, int id, const char* reason)
{
    int n = 0;
    spc_play* p;
    while ((p = take_match(cid, id, 0)) != NULL) {
        finish_play(p, reason, 1);
        n++;
        if (id > 0) break;
    }
    if (id > 0 && n == 0) return 0;
    return n;
}

static void moh_remove(uint64_t cid)
{
    moh_ent *e, *prev = NULL;
    pl_ensure();
    spc_mutex_lock(&g_pl_mtx);
    for (e = g_moh; e; prev = e, e = e->next)
        if (e->cid == cid) {
            if (prev) prev->next = e->next; else g_moh = e->next;
            free(e);
            break;
        }
    spc_mutex_unlock(&g_pl_mtx);
}

void spc_player_stop_call(uint64_t cid, const char* reason)
{
    spc_play* p;
    moh_remove(cid);
    while ((p = take_match(cid, 0, 1)) != NULL) finish_play(p, reason, 1);
}

void spc_player_shutdown(void)
{
    spc_play* p;
    moh_ent* e;
    pl_ensure();
    for (;;) {
        spc_mutex_lock(&g_pl_mtx);
        p = g_plays;
        if (p) g_plays = p->next;
        spc_mutex_unlock(&g_pl_mtx);
        if (!p) break;
        play_destroy(p);
    }
    spc_mutex_lock(&g_pl_mtx);
    while ((e = g_moh) != NULL) { g_moh = e->next; free(e); }
    spc_mutex_unlock(&g_pl_mtx);
}

static void conn(int src, int dst, int want)
{
    if (src < 0 || dst < 0) return;
    if (want) pjsua_conf_connect(src, dst);
    else pjsua_conf_disconnect(src, dst);
}

void spc_player_apply_call(uint64_t cid, int cslot, int active, int lhold, int held)
{
    spc_play* p;
    pl_ensure();
    spc_mutex_lock(&g_pl_mtx);
    for (p = g_plays; p; p = p->next) {
        if (p->cid != cid) continue;
        conn(p->slot, cslot, p->moh ? (active || lhold) : (active && !held));
        if (p->local_monitor) conn(p->slot, 0, 1);
    }
    spc_mutex_unlock(&g_pl_mtx);
}

int spc_player_start(uint64_t cid, const char* file, int loop, float volume, int local_monitor, int mute_mic,
                     int moh, int* id, char* err, size_t en)
{
    spc_play* p;
    spc_play* q;
    spc_src src;
    pj_status_t st;
    pjsua_conf_port_info pi;
    pj_str_t nm;
    int rate, spf, ncall = 0;
    uint64_t maxs;
    char perr[160];
    if (src_open(&src, file, perr, sizeof(perr)) != 0) { snprintf(err, en, "%s", perr); return -1; }
    if (src.frames <= 0) { src_close(&src); snprintf(err, en, "file contains no audio"); return -1; }
    if (src.frames * 1000 / src.rate > SPC_PLAY_MAX_MS) { src_close(&src); snprintf(err, en, "file too long (max 30 minutes)"); return -1; }
    if (pjsua_conf_get_port_info(0, &pi) != PJ_SUCCESS) { src_close(&src); snprintf(err, en, "audio engine not ready"); return -1; }
    rate = (int)pi.clock_rate;
    spf = (int)pi.samples_per_frame;
    maxs = (uint64_t)src.frames * (uint64_t)rate / (uint64_t)src.rate + (uint64_t)rate;
    if (maxs * 2 > SPC_PLAY_MAX_BYTES) { src_close(&src); snprintf(err, en, "decoded audio too large (max 200 MB)"); return -1; }
    pl_ensure();
    spc_mutex_lock(&g_pl_mtx);
    for (q = g_plays; q; q = q->next) if (q->cid == cid) ncall++;
    spc_mutex_unlock(&g_pl_mtx);
    if (ncall >= MAX_PLAYS_PER_CALL) { src_close(&src); snprintf(err, en, "too many concurrent plays on this call"); return -1; }

    p = (spc_play*)calloc(1, sizeof(*p));
    if (!p) { src_close(&src); snprintf(err, en, "out of memory"); return -1; }
    p->src = src;
    p->cid = cid; p->loop = loop; p->moh = moh; p->local_monitor = local_monitor; p->mute_mic = mute_mic;
    p->rate = rate; p->spf = spf; p->slot = -1;
    p->gain_q10 = (int)lrintf(volume * 1024.0f);
    spc_strlcpy(p->file, file, sizeof(p->file));
    spc_mutex_init(&p->mtx);
    p->max_chunks = (size_t)(maxs / CHUNK) + 2;
    p->chunks = (int16_t**)calloc(p->max_chunks, sizeof(int16_t*));
    if (!p->chunks) { spc_mutex_destroy(&p->mtx); src_close(&p->src); free(p); snprintf(err, en, "out of memory"); return -1; }
    if (src.rate != rate) {
        p->rs = spc_rs_new(src.rate, rate);
        if (!p->rs) { free(p->chunks); spc_mutex_destroy(&p->mtx); src_close(&p->src); free(p); snprintf(err, en, "out of memory"); return -1; }
    }
    nm = spc_pjs("spcplay");
    pjmedia_port_info_init(&p->port.info, &nm, PJMEDIA_SIG_CLASS_PORT_AUD('S', 'P'), (unsigned)rate, 1, 16, (unsigned)spf);
    p->port.get_frame = pl_get_frame;
    p->port.put_frame = pl_put_frame;
    p->port.on_destroy = pl_on_destroy;

    spc_media_ensure_clock();
    st = pjsua_conf_add_port(spc_media_pool, &p->port, &p->slot);
    if (st != PJ_SUCCESS) {
        p->slot = -1;
        snprintf(err, en, "conference port: pj status %d", (int)st);
        play_destroy(p);
        return -1;
    }
    spc_mutex_lock(&g_pl_mtx);
    p->id = g_next_id++;
    spc_mutex_unlock(&g_pl_mtx);
    if (spc_thread_create(&p->th, dec_thread, p) != 0) { snprintf(err, en, "cannot start decoder thread"); play_destroy(p); return -1; }
    p->th_started = 1;
    spc_mutex_lock(&g_pl_mtx);
    p->next = g_plays; g_plays = p;
    spc_mutex_unlock(&g_pl_mtx);
    *id = p->id;
    if (local_monitor) conn(p->slot, 0, 1);
    if (mute_mic) ann_refresh(cid); else spc_call_apply_topology();
    return 0;
}

/* ------------------------------------------------------------------ */
/* music on hold                                                       */
/* ------------------------------------------------------------------ */
int spc_moh_arm(uint64_t cid, const char* file, int loop, float volume)
{
    moh_ent* e = (moh_ent*)calloc(1, sizeof(*e));
    if (!e) return -1;
    spc_moh_disarm(cid);
    e->cid = cid; e->loop = loop; e->volume = volume;
    spc_strlcpy(e->file, file, sizeof(e->file));
    spc_mutex_lock(&g_pl_mtx);
    e->next = g_moh; g_moh = e;
    spc_mutex_unlock(&g_pl_mtx);
    return 0;
}

void spc_moh_disarm(uint64_t cid)
{
    spc_play* p;
    moh_remove(cid);
    while ((p = take_match(cid, 0, 2)) != NULL) finish_play(p, "stopped", 1);
}

static void moh_start_timer(void* ud)
{
    uint64_t cid = (uint64_t)(uintptr_t)ud;
    moh_ent* e;
    char file[600];
    int loop = 1, go = 0, id = 0;
    float vol = 1.0f;
    char err[200];
    pl_ensure();
    spc_mutex_lock(&g_pl_mtx);
    for (e = g_moh; e; e = e->next)
        if (e->cid == cid && !e->running) {
            e->running = 1; go = 1; loop = e->loop; vol = e->volume;
            spc_strlcpy(file, e->file, sizeof(file));
            break;
        }
    spc_mutex_unlock(&g_pl_mtx);
    if (!go) return;
    if (spc_player_start(cid, file, loop, vol, 0, 0, 1, &id, err, sizeof(err)) != 0) {
        cJSON* f = cJSON_CreateObject();
        moh_remove(cid);
        cJSON_AddNumberToObject(f, "cid", (double)cid);
        cJSON_AddNumberToObject(f, "playId", 0);
        cJSON_AddStringToObject(f, "file", file);
        cJSON_AddStringToObject(f, "reason", "error");
        cJSON_AddBoolToObject(f, "moh", 1);
        spc_call_emit(cid, "call.playDone", f);
    }
}

static void moh_stop_timer(void* ud) { spc_moh_disarm((uint64_t)(uintptr_t)ud); }

void spc_moh_start_now(uint64_t cid) { moh_start_timer((void*)(uintptr_t)cid); }

void spc_moh_on_media(uint64_t cid, int media_status)
{
    moh_ent* e;
    int armed = 0, running = 0;
    pl_ensure();
    spc_mutex_lock(&g_pl_mtx);
    for (e = g_moh; e; e = e->next) if (e->cid == cid) { armed = !e->running; running = e->running; break; }
    spc_mutex_unlock(&g_pl_mtx);
    if (media_status == PJSUA_CALL_MEDIA_LOCAL_HOLD && armed)
        spc_call_schedule_timer(moh_start_timer, cid, 0);
    else if (media_status == PJSUA_CALL_MEDIA_ACTIVE && running)
        spc_call_schedule_timer(moh_stop_timer, cid, 0);
}
