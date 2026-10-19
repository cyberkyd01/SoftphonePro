/* spc_denoise.c: RNNoise voice isolation.
 *
 * A "processor" is a pjmedia_port registered in the conference bridge. The bridge feeds it with put_frame()
 * (mix of everything connected to it) and reads the result back with get_frame() on the next clock tick, so a
 * processor adds one bridge frame (20 ms) plus RNNoise's own 10 ms look-ahead and the resampler delay.
 *
 * Pipeline (bridge rate R, frame S samples): resample to 48 kHz -> FIFO -> RNNoise on 480 sample frames
 * (VAD probability per frame) -> wet/dry blend + non-speech attenuation with smoothing -> FIFO -> resample to R.
 *
 * Threads: put_frame/get_frame run on the conference clock thread only. strength/enable are atomic scalars
 * set by API threads; no lock is held across any pjsua call.
 */
#include "spc_internal.h"
#include "spc_denoise.h"
#include "rnnoise.h"
#include <math.h>
#include <pjmedia/resample.h>

#define DN_FRAME 480            /* RNNoise frame: 10 ms at 48 kHz */
#define DN_OUT_FRAMES 4         /* output FIFO depth in bridge frames */
#define DN_MAX_ATT_DB 30.0f

enum { DN_MIC = 0, DN_IN = 1 };

typedef struct spc_dn {
    pjmedia_port base;
    pj_pool_t* pool;
    DenoiseState* st;
    int kind;
    int fixed_str;                       /* >= 0: per mille override (offline harness), else global setting */
    unsigned rate, S, U;                 /* bridge rate, bridge frame, same duration at 48 kHz */
    pjmedia_resample *up, *down;
    int16_t *tmp48, *tmpS;
    float* upq;  unsigned upn;
    float* dnq;  unsigned dnn;
    int16_t* outq; unsigned outn, outcap;
    float dry[DN_FRAME];                 /* previous input frame: RNNoise output lags its input by one frame */
    float gain;
    int hang;
    /* stats for the harness */
    double vad_sum; unsigned long vad_n;
    pj_uint64_t cpu_ticks;
} spc_dn;

/* ---- global configuration: lock-free scalars in static storage, so a port that outlives core.stop by a clock
 * tick (the bridge removes ports asynchronously) can still read them safely ---- */
#if defined(_MSC_VER)
#include <windows.h>
static long a_get(volatile long* p) { return InterlockedCompareExchange(p, 0, 0); }
static void a_set(volatile long* p, long v) { InterlockedExchange(p, v); }
#else
static long a_get(volatile long* p) { return __sync_fetch_and_add(p, 0); }
static void a_set(volatile long* p, long v) { __sync_lock_test_and_set(p, v); __sync_synchronize(); }
#endif
static volatile long g_en[2];            /* 0/1 */
static volatile long g_str[2] = {1000, 1000};   /* per mille */
static volatile long g_vad;              /* per mille, latest mic VAD */

static spc_mutex_t g_mtx;                /* guards g_mic_* publication only */
static volatile long g_mtx_once;
static spc_dn* g_mic_dn;
static int g_mic_slot = -1;
static volatile long g_warm_once;
static volatile int g_started;
static volatile long g_stopping;         /* 1 between spc_denoise_shutdown and the next spc_denoise_start: no new processors */

static void mtx_init_once(void) { spc_mutex_init(&g_mtx); }

static void warm_fn(void)
{
    /* RNNoise lazily fills global tables on its first frame; do it once, single-threaded. */
    float in[DN_FRAME], out[DN_FRAME];
    DenoiseState* st = rnnoise_create(NULL);
    memset(in, 0, sizeof(in));
    if (st) { rnnoise_process_frame(st, out, in); rnnoise_destroy(st); }
}

/* ---- processing ---- */
static float clampf(float v, float lo, float hi) { return v < lo ? lo : (v > hi ? hi : v); }

static int dn_strength(spc_dn* d)
{
    int v = d->fixed_str;
    if (v < 0) v = (int)a_get(&g_str[d->kind]);
    return v < 0 ? 0 : (v > 1000 ? 1000 : v);
}

/* one 480-sample frame at 48 kHz: in upq[0..480) -> appended to dnq */
static void dn_frame(spc_dn* d, const float* in)
{
    float wet[DN_FRAME], vad, s, w, tdb, tg, g0, g1, step, g;
    int i;
    vad = rnnoise_process_frame(d->st, wet, in);
    s = (float)dn_strength(d) / 1000.0f;
    d->vad_sum += vad; d->vad_n++;
    if (d->kind == DN_MIC) a_set(&g_vad, (long)(vad * 1000.0f));
    /* speech weight with a 120 ms hangover so word endings are not chopped */
    w = clampf((vad - 0.25f) / 0.5f, 0.0f, 1.0f);
    if (vad > 0.5f) d->hang = 12;
    else if (d->hang > 0) { d->hang--; w = 1.0f; }
    tdb = -DN_MAX_ATT_DB * s * (1.0f - w);
    tg = powf(10.0f, tdb / 20.0f);
    g0 = d->gain;
    g1 = tg > g0 ? g0 + (tg - g0) * 0.6f : g0 + (tg - g0) * 0.12f;   /* fast open, slow close */
    d->gain = g1;
    step = (g1 - g0) / (float)DN_FRAME;
    g = g0;
    for (i = 0; i < DN_FRAME; i++) {
        float y = (d->dry[i] * (1.0f - s) + wet[i] * s) * g;
        g += step;
        if (d->dnn < d->U + 2 * DN_FRAME) d->dnq[d->dnn++] = y;
    }
    memcpy(d->dry, in, sizeof(d->dry));
}

static void dn_feed(spc_dn* d, const int16_t* in)
{
    unsigned i;
    const int16_t* src48 = in;
    pj_timestamp t0, t1;
    pj_get_timestamp(&t0);
    if (d->up) { pjmedia_resample_run(d->up, in, d->tmp48); src48 = d->tmp48; }
    for (i = 0; i < d->U && d->upn < d->U + 2 * DN_FRAME; i++) d->upq[d->upn++] = (float)src48[i];
    while (d->upn >= DN_FRAME) {
        dn_frame(d, d->upq);
        d->upn -= DN_FRAME;
        memmove(d->upq, d->upq + DN_FRAME, d->upn * sizeof(float));
    }
    while (d->dnn >= d->U) {
        int16_t* dst;
        for (i = 0; i < d->U; i++) {
            float y = d->dnq[i];
            d->tmp48[i] = (int16_t)(y > 32767.0f ? 32767 : (y < -32768.0f ? -32768 : (int)lrintf(y)));
        }
        d->dnn -= d->U;
        memmove(d->dnq, d->dnq + d->U, d->dnn * sizeof(float));
        if (d->outn + d->S > d->outcap) {            /* overflow: drop the oldest frame */
            memmove(d->outq, d->outq + d->S, (d->outn - d->S) * sizeof(int16_t));
            d->outn -= d->S;
        }
        dst = d->outq + d->outn;
        if (d->down) pjmedia_resample_run(d->down, d->tmp48, dst);
        else memcpy(dst, d->tmp48, d->S * sizeof(int16_t));
        d->outn += d->S;
    }
    pj_get_timestamp(&t1);
    d->cpu_ticks += pj_elapsed_cycle(&t0, &t1);
}

static pj_status_t dn_put_frame(pjmedia_port* port, pjmedia_frame* frame)
{
    spc_dn* d = (spc_dn*)port;
    if (frame->type == PJMEDIA_FRAME_TYPE_AUDIO && frame->buf && frame->size >= d->S * sizeof(int16_t)) {
        dn_feed(d, (const int16_t*)frame->buf);
    } else {
        memset(d->tmpS, 0, d->S * sizeof(int16_t));    /* silent tick: keep the pipeline moving */
        dn_feed(d, d->tmpS);
    }
    return PJ_SUCCESS;
}

static pj_status_t dn_get_frame(pjmedia_port* port, pjmedia_frame* frame)
{
    spc_dn* d = (spc_dn*)port;
    if (d->outn >= d->S) {
        memcpy(frame->buf, d->outq, d->S * sizeof(int16_t));
        d->outn -= d->S;
        memmove(d->outq, d->outq + d->S, d->outn * sizeof(int16_t));
        frame->size = d->S * sizeof(int16_t);
        frame->type = PJMEDIA_FRAME_TYPE_AUDIO;
    } else {
        frame->type = PJMEDIA_FRAME_TYPE_NONE;
        frame->size = 0;
    }
    return PJ_SUCCESS;
}

/* Runs when the last reference to the port goes away: the bridge removes ports asynchronously (on its next clock
 * tick) and keeps a reference to the port's group lock until then, so the memory (the port lives in d->pool) must
 * only be released here, never right after pjsua_conf_remove_port(). */
static pj_status_t dn_on_destroy(pjmedia_port* port)
{
    spc_dn* d = (spc_dn*)port;
    pj_pool_t* pool = d->pool;
    if (d->st) { rnnoise_destroy(d->st); d->st = NULL; }
    d->pool = NULL;
    if (pool) pj_pool_release(pool);
    return PJ_SUCCESS;
}

/* drops the owner's reference (the port must already have been removed from the bridge, if it was ever added) */
static void dn_free(spc_dn* d)
{
    if (!d) return;
    pjmedia_port_destroy(&d->base);
}

/* Creates a processor for bridge rate/frame (channel_count must be 1). Pool comes from the pjsua factory. */
static spc_dn* dn_create(int kind, unsigned rate, unsigned S)
{
    pj_pool_t* pool;
    spc_dn* d;
    pj_str_t nm;
    unsigned U;
    pj_status_t st;
    spc_once(&g_warm_once, warm_fn);
    if (rate < 8000 || rate > 48000 || S == 0 || S > 4096) return NULL;
    if (((unsigned long)S * 48000UL) % rate != 0) return NULL;
    U = (unsigned)(((unsigned long)S * 48000UL) / rate);
    if (U > 8192) return NULL;
    pool = pj_pool_create(pjsua_get_pool_factory(), "spcdn", 8192, 8192, NULL);
    if (!pool) return NULL;
    d = PJ_POOL_ZALLOC_T(pool, spc_dn);
    d->pool = pool;
    d->kind = kind; d->fixed_str = -1;
    d->rate = rate; d->S = S; d->U = U;
    d->gain = 1.0f;
    d->st = rnnoise_create(NULL);
    d->tmp48 = (int16_t*)pj_pool_zalloc(pool, (U > S ? U : S) * sizeof(int16_t));
    d->tmpS = (int16_t*)pj_pool_zalloc(pool, S * sizeof(int16_t));
    d->upq = (float*)pj_pool_zalloc(pool, (U + 2 * DN_FRAME) * sizeof(float));
    d->dnq = (float*)pj_pool_zalloc(pool, (U + 2 * DN_FRAME) * sizeof(float));
    d->outcap = S * DN_OUT_FRAMES;
    d->outq = (int16_t*)pj_pool_zalloc(pool, d->outcap * sizeof(int16_t));
    if (!d->st) goto fail;
    if (rate != 48000) {
        if (pjmedia_resample_create(pool, PJ_TRUE, PJ_TRUE, 1, rate, 48000, S, &d->up) != PJ_SUCCESS) goto fail;
        if (pjmedia_resample_create(pool, PJ_TRUE, PJ_TRUE, 1, 48000, rate, U, &d->down) != PJ_SUCCESS) goto fail;
    }
    nm = pj_str(kind == DN_MIC ? "spc-dn-mic" : "spc-dn-in");
    st = pjmedia_port_info_init(&d->base.info, &nm, PJMEDIA_SIG_CLASS_PORT_AUD('D', 'N'), rate, 1, 16, S);
    if (st != PJ_SUCCESS) goto fail;
    d->base.get_frame = &dn_get_frame;
    d->base.put_frame = &dn_put_frame;
    d->base.on_destroy = &dn_on_destroy;
    return d;
fail:
    if (d->st) rnnoise_destroy(d->st);
    pj_pool_release(pool);
    return NULL;
}

static int bridge_fmt(unsigned* rate, unsigned* S)
{
    pjsua_conf_port_info pi;
    if (pjsua_conf_get_port_info(0, &pi) != PJ_SUCCESS) return -1;
    if (pi.channel_count != 1) return -1;
    *rate = pi.clock_rate; *S = pi.samples_per_frame;
    return 0;
}

/* ---- API for the call topology ---- */
int spc_denoise_mic_wanted(void) { return a_get(&g_en[DN_MIC]) != 0; }
int spc_denoise_in_wanted(void) { return a_get(&g_en[DN_IN]) != 0; }

int spc_denoise_mic_slot_peek(void)
{
    int s;
    spc_once(&g_mtx_once, mtx_init_once);
    spc_mutex_lock(&g_mtx);
    s = g_mic_slot;
    spc_mutex_unlock(&g_mtx);
    return s;
}

static int dn_register(spc_dn* d, int* slot)
{
    pj_status_t st = pjsua_conf_add_port(d->pool, &d->base, slot);
    return st == PJ_SUCCESS ? 0 : -1;
}

int spc_denoise_mic_slot(void)
{
    unsigned rate, S;
    spc_dn* d;
    int slot = -1, s;
    if (!spc_denoise_mic_wanted() || a_get(&g_stopping)) return -1;
    if ((s = spc_denoise_mic_slot_peek()) >= 0) return s;
    if (bridge_fmt(&rate, &S) != 0) return -1;
    d = dn_create(DN_MIC, rate, S);
    if (!d) return -1;
    if (dn_register(d, &slot) != 0) { dn_free(d); return -1; }
    spc_mutex_lock(&g_mtx);
    if (g_mic_slot < 0 && !a_get(&g_stopping)) { g_mic_dn = d; g_mic_slot = slot; d = NULL; }
    s = g_mic_slot;
    spc_mutex_unlock(&g_mtx);
    if (d) { pjsua_conf_remove_port(slot); dn_free(d); }      /* lost the creation race (or shutting down) */
    return s;
}

void* spc_denoise_in_create(int* slot)
{
    unsigned rate, S;
    spc_dn* d;
    if (a_get(&g_stopping) || bridge_fmt(&rate, &S) != 0) return NULL;
    d = dn_create(DN_IN, rate, S);
    if (!d) return NULL;
    if (dn_register(d, slot) != 0) { dn_free(d); return NULL; }
    return d;
}

void spc_denoise_in_destroy(void* h, int slot)
{
    if (!h) return;
    if (slot >= 0) pjsua_conf_remove_port(slot);    /* synchronous with the clock thread: the port is idle afterwards */
    dn_free((spc_dn*)h);
}

/* ---- config ---- */
static int parse_side(const cJSON* o, const char* what, int* en, int* str, char* err, size_t en_sz)
{
    const cJSON* v;
    if (!o) return 0;
    if (!cJSON_IsObject(o)) { snprintf(err, en_sz, "%s must be an object", what); return -1; }
    v = cJSON_GetObjectItemCaseSensitive((cJSON*)o, "enabled");
    if (v) {
        if (!cJSON_IsBool(v)) { snprintf(err, en_sz, "%s.enabled must be a boolean", what); return -1; }
        *en = cJSON_IsTrue(v) ? 1 : 0;
    }
    v = cJSON_GetObjectItemCaseSensitive((cJSON*)o, "strength");
    if (v) {
        if (!cJSON_IsNumber(v) || !(v->valuedouble >= 0.0 && v->valuedouble <= 1.0)) {
            snprintf(err, en_sz, "%s.strength must be a number in 0..1", what); return -1;
        }
        *str = (int)lrint(v->valuedouble * 1000.0);
    }
    return 0;
}

int spc_denoise_validate(const cJSON* vi, char* err, size_t en)
{
    int e[2] = {0, 0}, s[2] = {1000, 1000};
    if (!vi) return 0;
    if (!cJSON_IsObject(vi)) { snprintf(err, en, "media.voiceIsolation must be an object"); return -1; }
    if (parse_side(cJSON_GetObjectItemCaseSensitive((cJSON*)vi, "mic"), "voiceIsolation.mic", &e[0], &s[0], err, en)) return -1;
    if (parse_side(cJSON_GetObjectItemCaseSensitive((cJSON*)vi, "incoming"), "voiceIsolation.incoming", &e[1], &s[1], err, en)) return -1;
    return 0;
}

void spc_denoise_configure(const cJSON* vi)
{
    char err[96];
    int e[2] = {0, 0}, st[2] = {1000, 1000}, k;
    if (vi && spc_denoise_validate(vi, err, sizeof(err)) == 0) {
        parse_side(cJSON_GetObjectItemCaseSensitive((cJSON*)vi, "mic"), "mic", &e[0], &st[0], err, sizeof(err));
        parse_side(cJSON_GetObjectItemCaseSensitive((cJSON*)vi, "incoming"), "incoming", &e[1], &st[1], err, sizeof(err));
    }
    for (k = 0; k < 2; k++) { a_set(&g_str[k], st[k]); a_set(&g_en[k], e[k]); }
    a_set(&g_vad, 0);
}

void spc_denoise_start(void)
{
    spc_once(&g_mtx_once, mtx_init_once);
    spc_once(&g_warm_once, warm_fn);
    spc_mutex_lock(&g_mtx);
    g_mic_dn = NULL; g_mic_slot = -1;            /* nothing survives a core.stop (shutdown destroyed it) */
    spc_mutex_unlock(&g_mtx);
    a_set(&g_stopping, 0);
    g_started = 1;
}

void spc_denoise_shutdown(void)
{
    spc_dn* d;
    int slot;
    spc_once(&g_mtx_once, mtx_init_once);
    a_set(&g_stopping, 1);
    spc_mutex_lock(&g_mtx);
    d = g_mic_dn; slot = g_mic_slot; g_mic_dn = NULL; g_mic_slot = -1;
    spc_mutex_unlock(&g_mtx);
    if (d) spc_denoise_in_destroy(d, slot);      /* per-call incoming ports are destroyed with their calls */
    a_set(&g_en[DN_MIC], 0); a_set(&g_en[DN_IN], 0);
    g_started = 0;
}

/* ---- JSON methods ---- */
static cJSON* side_json(int k, int with_vad)
{
    cJSON* o = cJSON_CreateObject();
    cJSON_AddBoolToObject(o, "enabled", a_get(&g_en[k]) != 0);
    cJSON_AddNumberToObject(o, "strength", (double)a_get(&g_str[k]) / 1000.0);
    if (with_vad) cJSON_AddNumberToObject(o, "vad", a_get(&g_en[k]) ? (double)a_get(&g_vad) / 1000.0 : 0.0);
    return o;
}

static int h_set(cJSON* p, cJSON** res)
{
    char err[128];
    int e[2], s[2], k, changed_en = 0;
    cJSON* sides[2];
    if (!g_started) return spc_err(SPC_E_NOT_STARTED, 0, "voice isolation not initialised");
    for (k = 0; k < 2; k++) { e[k] = (int)a_get(&g_en[k]); s[k] = (int)a_get(&g_str[k]); }
    if (spc_denoise_validate(p, err, sizeof(err)) != 0) return spc_err(SPC_E_INVALID_PARAM, 0, "%s", err);
    sides[0] = spc_jobj(p, "mic");
    sides[1] = spc_jobj(p, "incoming");
    {
        int ne[2] = {e[0], e[1]}, ns[2] = {s[0], s[1]};
        parse_side(sides[0], "mic", &ne[0], &ns[0], err, sizeof(err));
        parse_side(sides[1], "incoming", &ne[1], &ns[1], err, sizeof(err));
        for (k = 0; k < 2; k++) {
            if (ne[k] != e[k]) changed_en = 1;
            a_set(&g_str[k], ns[k]);
            a_set(&g_en[k], ne[k]);
        }
    }
    if (changed_en && G.started) spc_call_apply_topology();
    *res = cJSON_CreateObject();
    cJSON_AddBoolToObject(*res, "available", 1);
    cJSON_AddStringToObject(*res, "engine", "rnnoise");
    return SPC_OK;
}

static int h_status(cJSON* p, cJSON** res)
{
    (void)p;
    *res = cJSON_CreateObject();
    cJSON_AddBoolToObject(*res, "available", 1);
    cJSON_AddStringToObject(*res, "engine", "rnnoise");
    cJSON_AddItemToObject(*res, "mic", side_json(DN_MIC, 1));
    cJSON_AddItemToObject(*res, "incoming", side_json(DN_IN, 0));
    return SPC_OK;
}

#ifdef SPC_TEST_HOOKS
/* __denoise.processFile {in, out, strength}: runs the processor offline on a mono PCM16 WAV (rates where a 20 ms
 * frame maps to 48 kHz exactly). Output is the raw processor output (delayed by its latency). */
static int rd_wav(const char* path, int16_t** data, size_t* n, unsigned* rate)
{
    FILE* f = fopen(path, "rb");
    unsigned char h[12], ch[8];
    int ok = 0;
    unsigned fmt_rate = 0, fmt_ch = 0, fmt_bits = 0, fmt_tag = 0;
    *data = NULL; *n = 0;
    if (!f) return -1;
    if (fread(h, 1, 12, f) != 12 || memcmp(h, "RIFF", 4) || memcmp(h + 8, "WAVE", 4)) { fclose(f); return -1; }
    while (fread(ch, 1, 8, f) == 8) {
        unsigned long sz = ch[4] | (ch[5] << 8) | (ch[6] << 16) | ((unsigned long)ch[7] << 24);
        if (!memcmp(ch, "fmt ", 4) && sz >= 16) {
            unsigned char b[16];
            if (fread(b, 1, 16, f) != 16) break;
            fmt_tag = b[0] | (b[1] << 8); fmt_ch = b[2] | (b[3] << 8);
            fmt_rate = b[4] | (b[5] << 8) | (b[6] << 16) | ((unsigned)b[7] << 24);
            fmt_bits = b[14] | (b[15] << 8);
            fseek(f, (long)(sz - 16 + (sz & 1)), SEEK_CUR);
        } else if (!memcmp(ch, "data", 4)) {
            size_t cnt;
            if (fmt_tag != 1 || fmt_ch != 1 || fmt_bits != 16 || sz > 64UL * 1024 * 1024) break;
            cnt = sz / 2;
            *data = (int16_t*)calloc(cnt + 1, 2);
            if (!*data) break;
            *n = fread(*data, 2, cnt, f);
            *rate = fmt_rate;
            ok = 1;
            break;
        } else fseek(f, (long)(sz + (sz & 1)), SEEK_CUR);
    }
    fclose(f);
    if (!ok) { free(*data); *data = NULL; return -1; }
    return 0;
}

static int wr_wav(const char* path, const int16_t* d, size_t n, unsigned rate)
{
    FILE* f = fopen(path, "wb");
    unsigned char h[44];
    unsigned long db = (unsigned long)n * 2, br = (unsigned long)rate * 2;
    if (!f) return -1;
    memcpy(h, "RIFF", 4); { unsigned long v = 36 + db; h[4] = v; h[5] = v >> 8; h[6] = v >> 16; h[7] = v >> 24; }
    memcpy(h + 8, "WAVEfmt ", 8);
    h[16] = 16; h[17] = h[18] = h[19] = 0; h[20] = 1; h[21] = 0; h[22] = 1; h[23] = 0;
    h[24] = rate; h[25] = rate >> 8; h[26] = rate >> 16; h[27] = rate >> 24;
    h[28] = br; h[29] = br >> 8; h[30] = br >> 16; h[31] = br >> 24;
    h[32] = 2; h[33] = 0; h[34] = 16; h[35] = 0;
    memcpy(h + 36, "data", 4); h[40] = db; h[41] = db >> 8; h[42] = db >> 16; h[43] = db >> 24;
    fwrite(h, 1, 44, f);
    fwrite(d, 2, n, f);
    fclose(f);
    return 0;
}

static int h_process_file(cJSON* p, cJSON** res)
{
    const char* in = spc_jstr(p, "in");
    const char* out = spc_jstr(p, "out");
    double strength = spc_jnum(p, "strength", 1.0);
    int16_t* data; int16_t* outd;
    size_t n, i, outn = 0, total;
    unsigned rate, S;
    spc_dn* d;
    pj_timestamp freq;
    pj_uint64_t ticks;
    if (!in || !out || !(strength >= 0.0 && strength <= 1.0)) return spc_err(SPC_E_INVALID_PARAM, 0, "in, out, strength(0..1) required");
    if (rd_wav(in, &data, &n, &rate) != 0) return spc_err(SPC_E_INVALID_PARAM, 0, "unreadable WAV (mono PCM16 only)");
    S = rate / 50;
    d = dn_create(DN_MIC, rate, S);
    if (!d) { free(data); return spc_err(SPC_E_UNSUPPORTED, 0, "unsupported rate %u", rate); }
    d->fixed_str = (int)lrint(strength * 1000.0);
    total = ((n + S - 1) / S + 2) * S;               /* two extra frames flush the pipeline */
    outd = (int16_t*)calloc(total + S, 2);
    if (!outd) { dn_free(d); free(data); return spc_err(SPC_E_INTERNAL, 0, "oom"); }
    for (i = 0; i < total; i += S) {
        int16_t blk[4096];
        pjmedia_frame fr;
        memset(blk, 0, sizeof(blk));
        if (i < n) memcpy(blk, data + i, (n - i < S ? n - i : S) * 2);
        memset(&fr, 0, sizeof(fr));
        fr.type = PJMEDIA_FRAME_TYPE_AUDIO; fr.buf = blk; fr.size = S * 2;
        dn_put_frame(&d->base, &fr);
        {
            int16_t ob[4096];
            fr.buf = ob; fr.size = 0;
            dn_get_frame(&d->base, &fr);
            if (fr.type == PJMEDIA_FRAME_TYPE_AUDIO) { memcpy(outd + outn, ob, S * 2); outn += S; }
            else { memset(outd + outn, 0, S * 2); outn += S; }
        }
    }
    wr_wav(out, outd, outn, rate);
    pj_get_timestamp_freq(&freq);
    ticks = d->cpu_ticks;
    *res = cJSON_CreateObject();
    cJSON_AddNumberToObject(*res, "rate", rate);
    cJSON_AddNumberToObject(*res, "samples", (double)outn);
    cJSON_AddNumberToObject(*res, "frames10ms", (double)d->vad_n);
    cJSON_AddNumberToObject(*res, "cpuUsPer10ms", d->vad_n ? (double)ticks * 1e6 / (double)freq.u64 / (double)d->vad_n : 0.0);
    cJSON_AddNumberToObject(*res, "meanVad", d->vad_n ? d->vad_sum / (double)d->vad_n : 0.0);
    dn_free(d);
    free(outd); free(data);
    return SPC_OK;
}
#endif

const spc_method spc_methods_denoise[] = {
    { "media.setVoiceIsolation", h_set, 0 },
    { "media.voiceIsolationStatus", h_status, 0 },
#ifdef SPC_TEST_HOOKS
    { "__denoise.processFile", h_process_file, 0 },
#endif
    { NULL, NULL, 0 }
};
