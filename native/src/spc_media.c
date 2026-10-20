/* spc_media.c: devices, sound modes, codecs, EC, levels, tones, ringer, loopback. */
#include "spc_internal.h"
#include "spc_player.h"
#include "spc_rec.h"
#include <pjmedia/tonegen.h>
#include <pjmedia/wav_port.h>
#include <pjmedia/null_port.h>
#include <pjmedia/master_port.h>
#include <pjmedia/sound_port.h>
#if defined(PJMEDIA_HAS_OPUS_CODEC) && PJMEDIA_HAS_OPUS_CODEC
#  include <pjmedia-codec/opus.h>
#endif

#define SPC_MAX_AUDDEVS 64
pj_pool_t* spc_media_pool;

static char g_cur_cap[160] = "default", g_cur_play[160] = "default", g_cur_ring[160] = "default";
static int g_null_attached;        /* null device currently attached by us */
static int g_real_open_manual;     /* manual mode: Dart opened a real device */
static int g_loopback;
static int g_mic_rec;            /* spc_rec id of the microphone recorder, 0 = none */

/* tone */
static pj_pool_t* g_tone_pool;
static pjmedia_port* g_tone_port;
static int g_tone_slot = -1;
/* ringer */
static pj_pool_t* g_ring_pool;
static pjmedia_port* g_ring_port;
static pjmedia_snd_port* g_ring_snd;
static pjmedia_master_port* g_ring_master;
static pjmedia_port* g_ring_null;

int spc_media_bridge_rate(void)
{
    pjsua_conf_port_info pi;
    if (pjsua_conf_get_port_info(0, &pi) == PJ_SUCCESS) return (int)pi.clock_rate;
    return G.clock_rate > 0 ? G.clock_rate : 16000;
}

/* ---- echo canceller options ---- */
unsigned spc_ec_options(const char* algo, int ns, int agc, int* tail_zero)
{
    unsigned o = PJMEDIA_ECHO_DEFAULT;
    *tail_zero = 0;
    if (!algo || spc_strieq(algo, "auto")) {
#if defined(PJMEDIA_HAS_WEBRTC_AEC3) && PJMEDIA_HAS_WEBRTC_AEC3 && !defined(__APPLE__)
        o = PJMEDIA_ECHO_WEBRTC_AEC3;
#else
        o = PJMEDIA_ECHO_SPEEX;
#endif
    }
    else if (spc_strieq(algo, "aec3")) {
#if defined(PJMEDIA_HAS_WEBRTC_AEC3) && PJMEDIA_HAS_WEBRTC_AEC3
        o = PJMEDIA_ECHO_WEBRTC_AEC3;
#else
        o = PJMEDIA_ECHO_SPEEX;
#endif
    }
    else if (spc_strieq(algo, "webrtc")) o = PJMEDIA_ECHO_WEBRTC;
    else if (spc_strieq(algo, "speex")) o = PJMEDIA_ECHO_SPEEX;
    else if (spc_strieq(algo, "simple")) o = PJMEDIA_ECHO_SIMPLE;
    else if (spc_strieq(algo, "platform")) o = PJMEDIA_ECHO_DEFAULT;
    else if (spc_strieq(algo, "none")) { *tail_zero = 1; o = PJMEDIA_ECHO_DEFAULT; }
    else return 0xFFFFFFFFu;
    if (ns) o |= PJMEDIA_ECHO_USE_NOISE_SUPPRESSOR;
    if (agc) o |= PJMEDIA_ECHO_USE_GAIN_CONTROLLER;
    return o;
}

/* ---- sound device helpers ---- */
pj_status_t spc_media_set_null_snd(void)
{
    pj_status_t st = PJ_SUCCESS;
    if (!g_null_attached) {
        st = pjsua_set_null_snd_dev();
        if (st == PJ_SUCCESS) g_null_attached = 1;
    }
    return st;
}

int spc_media_snd_open(void) { return pjsua_snd_is_active() ? 1 : 0; }

const char* spc_media_snd_current(char* cap, size_t n, char* play, size_t m)
{
    spc_strlcpy(cap, g_cur_cap, n);
    spc_strlcpy(play, g_cur_play, m);
    return cap;
}

static void emit_media_error(const char* op, pj_status_t st, const char* fallback)
{
    cJSON* f = cJSON_CreateObject();
    char em[160];
    pj_strerror(st, em, sizeof(em));
    cJSON_AddStringToObject(f, "op", op);
    cJSON_AddNumberToObject(f, "status", st);
    cJSON_AddStringToObject(f, "message", em);
    spc_jadd_str(f, "fallback", fallback);
    spc_emit("media.error", f);
}

/* called when connecting to port 0 failed (device open failed). Returns 1 if a retry makes sense. */
int spc_media_on_connect_error(pj_status_t st)
{
    if (g_null_attached) return 0;
    if (spc_media_set_null_snd() == PJ_SUCCESS) {
        emit_media_error("openDevice", st, "null");
        return 1;
    }
    return 0;
}

void spc_media_on_call_media(int slot, int active)
{
    (void)slot;
    if (!active) return;
    if ((G.snd_manual && !g_real_open_manual) || G.no_audio_device) {
        if (!pjsua_snd_is_active() || !g_null_attached) {
            if (!G.no_audio_device || !g_null_attached) spc_media_set_null_snd();
        }
    }
}

static int resolve_dev(const char* id, int capture, int* idx, int* special);

int spc_media_ensure_clock(void)
{
    if (pjsua_snd_is_active()) return 0;
    if (G.no_audio_device || (G.snd_manual && !g_real_open_manual)) {
        g_null_attached = 0;
        return spc_media_set_null_snd() == PJ_SUCCESS ? 0 : -1;
    }
    {
        pjsua_snd_dev_param prm;
        pj_status_t st;
        int ci = PJMEDIA_AUD_DEFAULT_CAPTURE_DEV, pi = PJMEDIA_AUD_DEFAULT_PLAYBACK_DEV, cs = 1, ps = 1;
        pjsua_snd_dev_param_default(&prm);
        /* honour the user's selection (media.setDevices), falling back to the OS defaults */
        if (resolve_dev(g_cur_cap, 1, &ci, &cs) != 0 || cs >= 2) ci = PJMEDIA_AUD_DEFAULT_CAPTURE_DEV;
        if (resolve_dev(g_cur_play, 0, &pi, &ps) != 0 || ps >= 2) pi = PJMEDIA_AUD_DEFAULT_PLAYBACK_DEV;
        prm.capture_dev = ci;
        prm.playback_dev = pi;
        st = pjsua_set_snd_dev2(&prm);
        if (st != PJ_SUCCESS) {
            g_null_attached = 0;
            emit_media_error("openDevice", st, "null");
            return spc_media_set_null_snd() == PJ_SUCCESS ? 0 : -1;
        }
        g_null_attached = 0;
    }
    return 0;
}

int spc_media_init(void)
{
    pj_status_t st = PJ_SUCCESS;
    g_null_attached = 0;
    g_real_open_manual = 0;
    g_loopback = 0;
    g_mic_rec = 0;
    spc_strlcpy(g_cur_cap, "default", sizeof(g_cur_cap));
    spc_strlcpy(g_cur_play, "default", sizeof(g_cur_play));
    spc_strlcpy(g_cur_ring, "default", sizeof(g_cur_ring));
    spc_media_pool = pjsua_pool_create("spcmedia", 2048, 2048);
    if (G.no_audio_device) {
        st = spc_media_set_null_snd();
        if (st != PJ_SUCCESS) {
            spc_strlcpy(g_cur_cap, "null", sizeof(g_cur_cap));
        }
        spc_strlcpy(g_cur_cap, "null", sizeof(g_cur_cap));
        spc_strlcpy(g_cur_play, "null", sizeof(g_cur_play));
    } else if (G.snd_manual) {
        st = pjsua_set_no_snd_dev() == NULL ? PJ_SUCCESS : PJ_SUCCESS;
        spc_strlcpy(g_cur_cap, "none", sizeof(g_cur_cap));
        spc_strlcpy(g_cur_play, "none", sizeof(g_cur_play));
    }
    return PJ_SUCCESS;
}

void spc_media_started(void) {}

/* The bridge removes ports asynchronously and keeps a reference on the port's group lock until its next clock tick, so
 * memory a port lives in (its pool) must not be freed before the port's on_destroy runs. spc_port_destroy_release()
 * drops the owner's reference and releases `pool` from the port's on_destroy (chained after the port's own one), i.e.
 * only when the last reference (ours or the bridge's) is gone. Call it AFTER pjsua_conf_remove_port(). */
typedef struct pool_guard { struct pool_guard* next; pjmedia_port* port; pj_pool_t* pool; pj_status_t (*orig)(pjmedia_port*); } pool_guard;
static pool_guard* g_guards;
static pj_status_t guarded_on_destroy(pjmedia_port* port)
{
    pool_guard *g, **pp;
    pj_status_t st = PJ_SUCCESS;
    pj_pool_t* pool = NULL;
    spc_mutex_lock(&G.tg_mtx);
    for (pp = &g_guards; (g = *pp) != NULL; pp = &g->next)
        if (g->port == port) { *pp = g->next; break; }
    spc_mutex_unlock(&G.tg_mtx);
    if (!g) return PJ_SUCCESS;
    if (g->orig) st = g->orig(port);
    pool = g->pool;
    free(g);
    if (pool) pj_pool_release(pool);
    return st;
}

void spc_port_destroy_release(pjmedia_port* port, pj_pool_t* pool)
{
    pool_guard* g;
    if (!port) { if (pool) pj_pool_release(pool); return; }
    if (!pool) { pjmedia_port_destroy(port); return; }
    g = (pool_guard*)calloc(1, sizeof(*g));
    if (!g) { pjmedia_port_destroy(port); return; }   /* out of memory: leak the pool rather than free memory the bridge may read */
    g->port = port; g->pool = pool; g->orig = port->on_destroy;
    spc_mutex_lock(&G.tg_mtx);
    g->next = g_guards; g_guards = g;
    spc_mutex_unlock(&G.tg_mtx);
    port->on_destroy = guarded_on_destroy;
    pjmedia_port_destroy(port);        /* the pool goes with the last reference */
}

static void tone_stop(void)
{
    pjmedia_port* port = g_tone_port;
    pj_pool_t* pool = g_tone_pool;
    if (g_tone_slot >= 0) { pjsua_conf_disconnect(g_tone_slot, 0); pjsua_conf_remove_port(g_tone_slot); g_tone_slot = -1; }
    g_tone_port = NULL; g_tone_pool = NULL;
    spc_port_destroy_release(port, pool);
}

static void ring_stop(void)
{
    if (g_ring_master) { pjmedia_master_port_stop(g_ring_master); pjmedia_master_port_destroy(g_ring_master, PJ_FALSE); g_ring_master = NULL; }
    if (g_ring_snd) { pjmedia_snd_port_disconnect(g_ring_snd); pjmedia_snd_port_destroy(g_ring_snd); g_ring_snd = NULL; }
    if (g_ring_null) { pjmedia_port_destroy(g_ring_null); g_ring_null = NULL; }
    if (g_ring_port) { pjmedia_port_destroy(g_ring_port); g_ring_port = NULL; }
    if (g_ring_pool) { pj_pool_release(g_ring_pool); g_ring_pool = NULL; }
}

void spc_media_shutdown(void)
{
    spc_player_shutdown();
    spc_rec_shutdown();
    if (g_loopback) { pjsua_conf_disconnect(0, 0); g_loopback = 0; }
    tone_stop();
    ring_stop();
    if (spc_media_pool) { pj_pool_release(spc_media_pool); spc_media_pool = NULL; }
}

/* ---- device enumeration ---- */
static int enum_devs(pjmedia_aud_dev_info* info, unsigned* count)
{
    *count = SPC_MAX_AUDDEVS;
    return pjsua_enum_aud_devs(info, count) == PJ_SUCCESS ? 0 : -1;
}

static void dev_id(const pjmedia_aud_dev_info* d, char* out, size_t n)
{
    snprintf(out, n, "%s:%s", d->driver, d->name);
}

cJSON* spc_media_devices_json(void)
{
    pjmedia_aud_dev_info info[SPC_MAX_AUDDEVS];
    unsigned count, i;
    cJSON *o = cJSON_CreateObject(), *cap = cJSON_CreateArray(), *play = cJSON_CreateArray(), *cur;
    int cap_def = -1, play_def = -1;
    if (enum_devs(info, &count) == 0) {
        {   /* OS default devices: ask pjmedia what "default" resolves to */
            pjmedia_aud_param dp;
            if (pjmedia_aud_dev_default_param(PJMEDIA_AUD_DEFAULT_CAPTURE_DEV, &dp) == PJ_SUCCESS && dp.rec_id >= 0 && (unsigned)dp.rec_id < count) cap_def = dp.rec_id;
            if (pjmedia_aud_dev_default_param(PJMEDIA_AUD_DEFAULT_PLAYBACK_DEV, &dp) == PJ_SUCCESS && dp.play_id >= 0 && (unsigned)dp.play_id < count) play_def = dp.play_id;
            if (cap_def < 0 || play_def < 0) {          /* fall back to the first device that can do the job */
                for (i = 0; i < count; i++) {
                    if (cap_def < 0 && info[i].input_count > 0) cap_def = (int)i;
                    if (play_def < 0 && info[i].output_count > 0) play_def = (int)i;
                }
            }
        }
        for (i = 0; i < count; i++) {
            char id[200];
            dev_id(&info[i], id, sizeof(id));
            if (info[i].input_count > 0) {
                cJSON* d = cJSON_CreateObject();
                cJSON_AddStringToObject(d, "devId", id);
                cJSON_AddStringToObject(d, "name", info[i].name);
                cJSON_AddStringToObject(d, "driver", info[i].driver);
                cJSON_AddNumberToObject(d, "inputs", info[i].input_count);
                cJSON_AddNumberToObject(d, "outputs", info[i].output_count);
                cJSON_AddBoolToObject(d, "isDefault", (int)i == cap_def);
                cJSON_AddItemToArray(cap, d);
            }
            if (info[i].output_count > 0) {
                cJSON* d = cJSON_CreateObject();
                cJSON_AddStringToObject(d, "devId", id);
                cJSON_AddStringToObject(d, "name", info[i].name);
                cJSON_AddStringToObject(d, "driver", info[i].driver);
                cJSON_AddNumberToObject(d, "inputs", info[i].input_count);
                cJSON_AddNumberToObject(d, "outputs", info[i].output_count);
                cJSON_AddBoolToObject(d, "isDefault", (int)i == play_def);
                cJSON_AddItemToArray(play, d);
            }
        }
    }
    cJSON_AddItemToObject(o, "capture", cap);
    cJSON_AddItemToObject(o, "playback", play);
    cur = cJSON_AddObjectToObject(o, "current");
    cJSON_AddStringToObject(cur, "capture", g_cur_cap);
    cJSON_AddStringToObject(cur, "playback", g_cur_play);
    cJSON_AddStringToObject(cur, "ringer", g_cur_ring);
    return o;
}

/* devId -> index; special values returned in *special: 0 none, 1 default, 2 null, 3 none */
static int resolve_dev(const char* id, int capture, int* idx, int* special)
{
    pjmedia_aud_dev_info info[SPC_MAX_AUDDEVS];
    unsigned count, i;
    *special = 0;
    if (spc_strieq(id, "default")) { *special = 1; *idx = capture ? PJMEDIA_AUD_DEFAULT_CAPTURE_DEV : PJMEDIA_AUD_DEFAULT_PLAYBACK_DEV; return 0; }
    if (spc_strieq(id, "null")) { *special = 2; *idx = PJSUA_SND_NULL_DEV; return 0; }
    if (spc_strieq(id, "none")) { *special = 3; *idx = PJSUA_SND_NO_DEV; return 0; }
    if (enum_devs(info, &count) != 0) return -1;
    for (i = 0; i < count; i++) {
        char d[200];
        dev_id(&info[i], d, sizeof(d));
        if (strcmp(d, id) == 0 && (capture ? info[i].input_count : info[i].output_count) > 0) { *idx = (int)i; return 0; }
    }
    return -1;
}

static int h_devices(cJSON* p, cJSON** res) { (void)p; *res = spc_media_devices_json(); return SPC_OK; }

static int h_set_devices(cJSON* p, cJSON** res)
{
    const char* cap = spc_jstr(p, "capture");
    const char* play = spc_jstr(p, "playback");
    char ncap[160], nplay[160];
    int ci = PJMEDIA_AUD_DEFAULT_CAPTURE_DEV, pi = PJMEDIA_AUD_DEFAULT_PLAYBACK_DEV, cs = 1, ps = 1;
    pj_status_t st = PJ_SUCCESS;
    (void)res;
    if (!cap && !play) return spc_err(SPC_E_INVALID_PARAM, 0, "'capture' or 'playback' required");
    spc_strlcpy(ncap, cap ? cap : g_cur_cap, sizeof(ncap));
    spc_strlcpy(nplay, play ? play : g_cur_play, sizeof(nplay));
    if (resolve_dev(ncap, 1, &ci, &cs) != 0) return spc_err(SPC_E_NOT_FOUND, 0, "capture device '%s' not found", ncap);
    if (resolve_dev(nplay, 0, &pi, &ps) != 0) return spc_err(SPC_E_NOT_FOUND, 0, "playback device '%s' not found", nplay);
    if ((cs == 3 || ps == 3) && !G.snd_manual) return spc_err(SPC_E_UNSUPPORTED, 0, "\"none\" requires sndMode manual");
    spc_strlcpy(g_cur_cap, ncap, sizeof(g_cur_cap));
    spc_strlcpy(g_cur_play, nplay, sizeof(g_cur_play));
    if (G.no_audio_device) return SPC_OK;    /* null device always */
    if (cs == 3 && ps == 3) {
        g_real_open_manual = 0;
        if (spc_calls_active() > 0) { g_null_attached = 0; st = spc_media_set_null_snd(); }
        else { pjsua_set_no_snd_dev(); g_null_attached = 0; }
        return SPC_OK;
    }
    if (cs == 2 || ps == 2) {
        g_null_attached = 0;
        g_real_open_manual = 0;
        st = spc_media_set_null_snd();
        if (st != PJ_SUCCESS) return spc_pjerr(st, "null device");
        return SPC_OK;
    }
    {
        pjsua_snd_dev_param prm;
        pjsua_snd_dev_param_default(&prm);
        prm.capture_dev = ci;
        prm.playback_dev = pi;
        if (!G.snd_manual && spc_calls_active() == 0) prm.mode |= PJSUA_SND_DEV_NO_IMMEDIATE_OPEN;
        st = pjsua_set_snd_dev2(&prm);
        if (st != PJ_SUCCESS) {
            emit_media_error("setDevices", st, "null");
            g_null_attached = 0;
            g_real_open_manual = 0;
            spc_media_set_null_snd();
            return SPC_OK;
        }
        g_null_attached = 0;
        g_real_open_manual = 1;
    }
    return SPC_OK;
}

static int h_refresh_devices(cJSON* p, cJSON** res)
{
    (void)p; (void)res;
    pjmedia_aud_dev_refresh();
    spc_emit("media.devicesChanged", NULL);
    return SPC_OK;
}

/* ---- codecs ---- */
static void codec_parse(const char* id, char* name, size_t nn, int* rate, int* ch)
{
    char tmp[64];
    char* s1;
    char* s2;
    spc_strlcpy(tmp, id, sizeof(tmp));
    *rate = 0; *ch = 1;
    s1 = strchr(tmp, '/');
    if (s1) { *s1++ = 0; s2 = strchr(s1, '/'); if (s2) { *s2++ = 0; *ch = atoi(s2); } *rate = atoi(s1); }
    spc_strlcpy(name, tmp, nn);
}

static int h_codecs(cJSON* p, cJSON** res)
{
    pjsua_codec_info ci[64];
    unsigned n = 64, i;
    cJSON* arr = cJSON_CreateArray();
    (void)p;
    if (pjsua_enum_codecs(ci, &n) != PJ_SUCCESS) { cJSON_Delete(arr); return spc_err(SPC_E_PJ_ERROR, 0, "enum codecs"); }
    for (i = 0; i < n; i++) {
        char id[64], name[48];
        int rate, ch;
        cJSON* o = cJSON_CreateObject();
        spc_pjcopy(id, sizeof(id), &ci[i].codec_id);
        codec_parse(id, name, sizeof(name), &rate, &ch);
        cJSON_AddStringToObject(o, "id", id);
        cJSON_AddStringToObject(o, "name", name);
        cJSON_AddNumberToObject(o, "clockRate", rate);
        cJSON_AddNumberToObject(o, "channels", ch);
        cJSON_AddNumberToObject(o, "priority", ci[i].priority);
        cJSON_AddBoolToObject(o, "enabled", ci[i].priority > 0);
        cJSON_AddItemToArray(arr, o);
    }
    *res = cJSON_CreateObject();
    cJSON_AddItemToObject(*res, "codecs", arr);
    return SPC_OK;
}

static int set_prio(const char* id, int prio)
{
    pj_str_t s = spc_pjs(id);
    pj_status_t st = pjsua_codec_set_priority(&s, (pj_uint8_t)prio);
    if (st == PJ_ENOTFOUND) return spc_err(SPC_E_NOT_FOUND, st, "codec '%s' not found", id);
    if (st != PJ_SUCCESS) return spc_pjerr(st, "codec_set_priority");
    return SPC_OK;
}

static int h_set_codec_priority(cJSON* p, cJSON** res)
{
    const char* id = spc_jstr(p, "id");
    int prio = spc_jint(p, "priority", -1);
    (void)res;
    if (!id || prio < 0 || prio > 255) return spc_err(SPC_E_INVALID_PARAM, 0, "'id' and 'priority' (0..255) required");
    return set_prio(id, prio);
}

static int h_set_codec_priorities(cJSON* p, cJSON** res)
{
    cJSON* ord = spc_jarr(p, "order");
    cJSON* e;
    int i = 0, rc;
    (void)res;
    if (!ord) return spc_err(SPC_E_INVALID_PARAM, 0, "'order' must be an array");
    cJSON_ArrayForEach(e, ord) if (!cJSON_IsString(e)) return spc_err(SPC_E_INVALID_PARAM, 0, "order entries must be strings");
    if (spc_jbool(p, "disableOthers", 0)) {
        pjsua_codec_info ci[64];
        unsigned n = 64, k;
        pjsua_enum_codecs(ci, &n);
        for (k = 0; k < n; k++) pjsua_codec_set_priority(&ci[k].codec_id, 0);
    }
    cJSON_ArrayForEach(e, ord) {
        rc = set_prio(e->valuestring, 255 - i);
        if (rc) return rc;
        i++;
    }
    return SPC_OK;
}

static int h_set_codec_param(cJSON* p, cJSON** res)
{
    const char* id = spc_jstr(p, "id");
    pj_str_t sid;
    pjmedia_codec_param prm;
    pj_status_t st;
    cJSON* fm;
    cJSON* op;
    (void)res;
    if (!id) return spc_err(SPC_E_INVALID_PARAM, 0, "'id' required");
    sid = spc_pjs(id);
    st = pjsua_codec_get_param(&sid, &prm);
    if (st == PJ_ENOTFOUND) return spc_err(SPC_E_NOT_FOUND, st, "codec '%s' not found", id);
    if (st != PJ_SUCCESS) return spc_pjerr(st, "codec_get_param");
    if (spc_jhas(p, "ptime")) {
        int pt = spc_jint(p, "ptime", 20);
        if (pt < 10 || pt > 200) return spc_err(SPC_E_INVALID_PARAM, 0, "ptime must be 10..200");
        if (prm.info.frm_ptime > 0) {
            int fpp = pt / (int)prm.info.frm_ptime;
            if (fpp < 1) fpp = 1;
            if (fpp > 16) fpp = 16;
            prm.setting.frm_per_pkt = (pj_uint8_t)fpp;
        }
    }
    if (spc_jhas(p, "vad")) prm.setting.vad = spc_jbool(p, "vad", 0);
    fm = spc_jobj(p, "fmtp");
    if (fm) {
        cJSON* e;
        static char names[PJMEDIA_CODEC_MAX_FMTP_CNT][32], vals[PJMEDIA_CODEC_MAX_FMTP_CNT][64];
        unsigned n = 0;
        cJSON_ArrayForEach(e, fm) {
            if (!e->string || n >= PJMEDIA_CODEC_MAX_FMTP_CNT) continue;
            spc_strlcpy(names[n], e->string, sizeof(names[n]));
            if (cJSON_IsString(e)) spc_strlcpy(vals[n], e->valuestring, sizeof(vals[n]));
            else if (cJSON_IsNumber(e) && e->valuedouble > -1e9 && e->valuedouble < 1e9) snprintf(vals[n], sizeof(vals[n]), "%d", (int)e->valuedouble);
            else continue;
            prm.setting.dec_fmtp.param[n].name = spc_pjs(names[n]);
            prm.setting.dec_fmtp.param[n].val = spc_pjs(vals[n]);
            n++;
        }
        prm.setting.dec_fmtp.cnt = (pj_uint8_t)n;
    }
    op = spc_jobj(p, "opus");
    if (op) {
#if defined(PJMEDIA_HAS_OPUS_CODEC) && PJMEDIA_HAS_OPUS_CODEC
        pjmedia_codec_opus_config oc;
        pjmedia_codec_opus_get_config(&oc);
        if (spc_jhas(op, "bitrate")) oc.bit_rate = (unsigned)spc_jint(op, "bitrate", 24000);
        if (spc_jhas(op, "fec")) oc.packet_loss = spc_jbool(op, "fec", 0) ? 20 : 0;
        if (spc_jhas(op, "cbr")) oc.cbr = spc_jbool(op, "cbr", 0);
        if (spc_jhas(op, "complexity")) oc.complexity = (unsigned)spc_jint(op, "complexity", 5);
        if (spc_jhas(op, "maxPlaybackRate")) oc.sample_rate = (unsigned)spc_jint(op, "maxPlaybackRate", 48000);
        if (spc_jhas(op, "dtx")) prm.setting.vad = spc_jbool(op, "dtx", 0);
        if (oc.complexity > 10) return spc_err(SPC_E_INVALID_PARAM, 0, "complexity must be 0..10");
        st = pjmedia_codec_opus_set_default_param(&oc, &prm);
        if (st != PJ_SUCCESS) return spc_pjerr(st, "opus set config");
#else
        return spc_err(SPC_E_UNSUPPORTED, 0, "opus not built in");
#endif
    }
    st = pjsua_codec_set_param(&sid, &prm);
    if (st != PJ_SUCCESS) return spc_pjerr(st, "codec_set_param");
    return SPC_OK;
}

/* ---- EC / levels ---- */
static int h_set_ec(cJSON* p, cJSON** res)
{
    const char* algo = spc_jstr(p, "algo");
    int tail = spc_jint(p, "tailMs", 200), tz;
    unsigned opts;
    pj_status_t st;
    (void)res;
    if (!algo) return spc_err(SPC_E_INVALID_PARAM, 0, "'algo' required");
    if (tail < 0 || tail > 1000) return spc_err(SPC_E_INVALID_PARAM, 0, "tailMs must be 0..1000");
    opts = spc_ec_options(algo, spc_jbool(p, "ns", 1), spc_jbool(p, "agc", 0), &tz);
    if (opts == 0xFFFFFFFFu) return spc_err(SPC_E_INVALID_PARAM, 0, "unknown algo '%s'", algo);
    st = pjsua_set_ec(tz ? 0 : (unsigned)tail, opts);
    if (st != PJ_SUCCESS) return spc_pjerr(st, "pjsua_set_ec");
    return SPC_OK;
}

static int h_levels(cJSON* p, cJSON** res)
{
    unsigned tx = 0, rx = 0, dtx = 0, drx = 0;
    int dn = spc_call_mic_source();
    (void)p;
    pjsua_conf_get_signal_level(0, &tx, &rx);
    /* the microphone as the calls get it: the voice-isolation output while that processor is in the path */
    if (dn > 0 && spc_calls_active() > 0 && pjsua_conf_get_signal_level(dn, &dtx, &drx) == PJ_SUCCESS) rx = drx;
    *res = cJSON_CreateObject();
    cJSON_AddNumberToObject(*res, "mic", rx);
    cJSON_AddNumberToObject(*res, "speaker", tx);
    cJSON_AddNumberToObject(*res, "musicbed", spc_musicbed_level());
    cJSON_AddItemToObject(*res, "calls", spc_call_levels_json());
    return SPC_OK;
}

static int h_set_mic(cJSON* p, cJSON** res)
{
    double v = spc_jnum(p, "level", -1);
    (void)res;
    if (v < 0 || v > 2) return spc_err(SPC_E_INVALID_PARAM, 0, "level must be 0.0..2.0");
    pjsua_conf_adjust_rx_level(0, (float)v);
    return SPC_OK;
}
static int h_set_speaker(cJSON* p, cJSON** res)
{
    double v = spc_jnum(p, "level", -1);
    (void)res;
    if (v < 0 || v > 2) return spc_err(SPC_E_INVALID_PARAM, 0, "level must be 0.0..2.0");
    pjsua_conf_adjust_tx_level(0, (float)v);
    return SPC_OK;
}

/* ---- tones ---- */
static int h_tone(cJSON* p, cJSON** res)
{
    const char* kind = spc_jstr(p, "kind");
    const char* digits = spc_jstr(p, "digits");
    int loop;
    pjmedia_tone_desc td[2];
    pjmedia_tone_digit dg[32];
    int nt = 0, nd = 0, rate, i;
    pj_status_t st;
    (void)res;
    if (!kind) return spc_err(SPC_E_INVALID_PARAM, 0, "'kind' required");
    memset(td, 0, sizeof(td));
    loop = 0;
    if (spc_strieq(kind, "ringback")) { td[0].freq1 = 440; td[0].freq2 = 480; td[0].on_msec = 2000; td[0].off_msec = 4000; nt = 1; loop = 1; }
    else if (spc_strieq(kind, "busy")) { td[0].freq1 = 480; td[0].freq2 = 620; td[0].on_msec = 500; td[0].off_msec = 500; nt = 1; loop = 1; }
    else if (spc_strieq(kind, "congestion")) { td[0].freq1 = 480; td[0].freq2 = 620; td[0].on_msec = 250; td[0].off_msec = 250; nt = 1; loop = 1; }
    else if (spc_strieq(kind, "dial")) { td[0].freq1 = 350; td[0].freq2 = 440; td[0].on_msec = 1000; td[0].off_msec = 0; nt = 1; loop = 1; }
    else if (spc_strieq(kind, "waiting")) { td[0].freq1 = 440; td[0].freq2 = 0; td[0].on_msec = 300; td[0].off_msec = 9700; nt = 1; loop = 0; }
    else if (spc_strieq(kind, "dtmf")) {
        if (!digits || !digits[0] || strlen(digits) > 32) return spc_err(SPC_E_INVALID_PARAM, 0, "'digits' required for dtmf");
        for (i = 0; digits[i]; i++) {
            if (!strchr("0123456789*#ABCDabcd", digits[i])) return spc_err(SPC_E_INVALID_PARAM, 0, "invalid digit");
            dg[nd].digit = digits[i]; dg[nd].on_msec = 120; dg[nd].off_msec = 60; dg[nd].volume = 0; nd++;
        }
    } else return spc_err(SPC_E_INVALID_PARAM, 0, "unknown tone kind '%s'", kind);
    if (spc_jhas(p, "loop")) loop = spc_jbool(p, "loop", loop);
    spc_media_ensure_clock();
    tone_stop();
    rate = spc_media_bridge_rate();
    g_tone_pool = pjsua_pool_create("spctone", 1024, 1024);
    if (!g_tone_pool) return spc_err(SPC_E_INTERNAL, 0, "out of memory");
    st = pjmedia_tonegen_create(g_tone_pool, (unsigned)rate, 1, (unsigned)(rate / 50), 16, 0, &g_tone_port);
    if (st != PJ_SUCCESS) { tone_stop(); return spc_pjerr(st, "tonegen_create"); }
    st = pjsua_conf_add_port(g_tone_pool, g_tone_port, &g_tone_slot);
    if (st != PJ_SUCCESS) { tone_stop(); return spc_pjerr(st, "conf_add_port"); }
    if (nt) st = pjmedia_tonegen_play(g_tone_port, (unsigned)nt, td, loop ? PJMEDIA_TONEGEN_LOOP : 0);
    else st = pjmedia_tonegen_play_digits(g_tone_port, (unsigned)nd, dg, loop ? PJMEDIA_TONEGEN_LOOP : 0);
    if (st != PJ_SUCCESS) { tone_stop(); return spc_pjerr(st, "tonegen_play"); }
    st = pjsua_conf_connect(g_tone_slot, 0);
    if (st != PJ_SUCCESS) {
        if (spc_media_on_connect_error(st)) st = pjsua_conf_connect(g_tone_slot, 0);
        if (st != PJ_SUCCESS) { tone_stop(); return spc_pjerr(st, "conf_connect"); }
    }
    return SPC_OK;
}

static int h_tone_stop(cJSON* p, cJSON** res) { (void)p; (void)res; tone_stop(); return SPC_OK; }

/* ---- ringer ---- */
static int h_ring_start(cJSON* p, cJSON** res)
{
    const char* file = spc_jstr(p, "file");
    const char* dev = spc_jstr(p, "devId");
    int loop = spc_jbool(p, "loop", 1);
    double vol = spc_jnum(p, "volume", 1.0);
    int di = PJMEDIA_AUD_DEFAULT_PLAYBACK_DEV, ds = 1;
    pj_status_t st;
    unsigned clock, ch, spf, bits;
    (void)res;
    if (vol < 0 || vol > 1) return spc_err(SPC_E_INVALID_PARAM, 0, "volume must be 0..1");
    if (!dev) dev = "default";
    if (resolve_dev(dev, 0, &di, &ds) != 0) return spc_err(SPC_E_NOT_FOUND, 0, "playback device '%s' not found", dev);
    if (file) {
        FILE* fp = fopen(file, "rb");
        if (!fp) return spc_err(SPC_E_INVALID_PARAM, 0, "cannot open '%s'", file);
        fclose(fp);
    }
    ring_stop();
    g_ring_pool = pjsua_pool_create("spcring", 2048, 2048);
    if (!g_ring_pool) return spc_err(SPC_E_INTERNAL, 0, "out of memory");
    if (file) {
        pj_str_t f = spc_pjs(file);
        st = pjmedia_wav_player_port_create(g_ring_pool, file, 20, loop ? 0 : PJMEDIA_FILE_NO_LOOP, 0, &g_ring_port);
        (void)f;
        if (st != PJ_SUCCESS) { ring_stop(); return spc_pjerr(st, "wav player"); }
    } else {
        pjmedia_tone_desc td[1];
        memset(td, 0, sizeof(td));
        td[0].freq1 = 440; td[0].freq2 = 480; td[0].on_msec = 2000; td[0].off_msec = 4000;
        td[0].volume = (short)(vol * 16000);
        if (td[0].volume < 1) td[0].volume = 1;
        st = pjmedia_tonegen_create(g_ring_pool, 8000, 1, 160, 16, 0, &g_ring_port);
        if (st != PJ_SUCCESS) { ring_stop(); return spc_pjerr(st, "tonegen"); }
        st = pjmedia_tonegen_play(g_ring_port, 1, td, loop ? PJMEDIA_TONEGEN_LOOP : 0);
        if (st != PJ_SUCCESS) { ring_stop(); return spc_pjerr(st, "tonegen_play"); }
    }
    clock = PJMEDIA_PIA_SRATE(&g_ring_port->info);
    ch = PJMEDIA_PIA_CCNT(&g_ring_port->info);
    spf = PJMEDIA_PIA_SPF(&g_ring_port->info);
    bits = PJMEDIA_PIA_BITS(&g_ring_port->info);
    if (G.no_audio_device || ds == 2) {
        st = pjmedia_null_port_create(g_ring_pool, clock, ch, spf, bits, &g_ring_null);
        if (st == PJ_SUCCESS) st = pjmedia_master_port_create(g_ring_pool, g_ring_port, g_ring_null, 0, &g_ring_master);
        if (st == PJ_SUCCESS) st = pjmedia_master_port_start(g_ring_master);
    } else {
        st = pjmedia_snd_port_create_player(g_ring_pool, di, clock, ch, spf, bits, 0, &g_ring_snd);
        if (st == PJ_SUCCESS) st = pjmedia_snd_port_connect(g_ring_snd, g_ring_port);
    }
    if (st != PJ_SUCCESS) { ring_stop(); emit_media_error("ringStart", st, NULL); return spc_pjerr(st, "ringer"); }
    spc_strlcpy(g_cur_ring, dev, sizeof(g_cur_ring));
    return SPC_OK;
}

static int h_ring_stop(cJSON* p, cJSON** res) { (void)p; (void)res; ring_stop(); return SPC_OK; }

static int h_loopback(cJSON* p, cJSON** res)
{
    int en = 0;
    pj_status_t st;
    (void)res;
    if (!spc_jbool_strict(p, "enabled", &en)) return spc_err(SPC_E_INVALID_PARAM, 0, "'enabled' (bool) required");
    if (en && !g_loopback) {
        spc_media_ensure_clock();
        st = pjsua_conf_connect(0, 0);
        if (st != PJ_SUCCESS) return spc_pjerr(st, "loopback");
        g_loopback = 1;
    } else if (!en && g_loopback) {
        pjsua_conf_disconnect(0, 0);
        g_loopback = 0;
    }
    return SPC_OK;
}

/* ---- media files / microphone recorder ---- */
static int h_file_info(cJSON* p, cJSON** res)
{
    const char* file = spc_jstr(p, "file");
    spc_fileinfo fi;
    char err[200];
    if (!file || !file[0]) return spc_err(SPC_E_INVALID_PARAM, 0, "'file' required");
    if (spc_media_file_info(file, &fi, err, sizeof(err)) != 0) return spc_err(SPC_E_INVALID_PARAM, 0, "%s", err);
    *res = cJSON_CreateObject();
    cJSON_AddStringToObject(*res, "format", fi.format);
    cJSON_AddNumberToObject(*res, "durationMs", fi.durationMs);
    cJSON_AddNumberToObject(*res, "sampleRate", fi.sampleRate);
    cJSON_AddNumberToObject(*res, "channels", fi.channels);
    return SPC_OK;
}


static int h_record_mic_start(cJSON* p, cJSON** res)
{
    const char* file = spc_jstr(p, "file");
    char err[200];
    int id = 0;
    if (!file || !file[0] || strlen(file) > 590) return spc_err(SPC_E_INVALID_PARAM, 0, "'file' required");
    if (g_mic_rec && spc_rec_mic_id() == g_mic_rec) return spc_err(SPC_E_ALREADY, 0, "microphone recording already active");
    spc_media_ensure_clock();
    if (spc_rec_start(SPC_REC_WAV_MONO, 0, 0, file, &id, err, sizeof(err)) != 0) return spc_err(SPC_E_INVALID_PARAM, 0, "%s", err);
    g_mic_rec = id;
    spc_call_apply_topology();
    *res = cJSON_CreateObject();
    cJSON_AddStringToObject(*res, "file", file);
    return SPC_OK;
}

static int h_record_mic_stop(cJSON* p, cJSON** res)
{
    spc_rec_result rr;
    (void)p;
    if (!g_mic_rec) return spc_err(SPC_E_INVALID_PARAM, 0, "not recording");
    if (spc_rec_stop(g_mic_rec, &rr) != 0) { g_mic_rec = 0; return spc_err(SPC_E_INVALID_PARAM, 0, "not recording"); }
    g_mic_rec = 0;
    *res = cJSON_CreateObject();
    cJSON_AddStringToObject(*res, "file", rr.file);
    cJSON_AddNumberToObject(*res, "durationMs", rr.durationMs);
    cJSON_AddStringToObject(*res, "format", "wav");
    cJSON_AddNumberToObject(*res, "bytes", (double)rr.bytes);
    return SPC_OK;
}

/* ---- musicbed ---- */
static int vol_param(cJSON* p, const char* k, double def, double* out)
{
    const cJSON* v;
    *out = def;
    if (!spc_jhas(p, k)) return 1;
    v = cJSON_GetObjectItemCaseSensitive(p, k);
    if (!cJSON_IsNumber(v) || !(v->valuedouble >= 0.0 && v->valuedouble <= 2.0)) return 0;
    *out = v->valuedouble;
    return 1;
}

static int h_musicbed_start(cJSON* p, cJSON** res)
{
    const char* file = spc_jstr(p, "file");
    double vol, mvol;
    int mon = 0;
    spc_fileinfo fi;
    char err[200];
    if (!file || !file[0]) return spc_err(SPC_E_INVALID_PARAM, 0, "'file' required");
    if (!vol_param(p, "volume", 0.3, &vol)) return spc_err(SPC_E_INVALID_PARAM, 0, "'volume' must be 0.0..2.0");
    if (!vol_param(p, "monitorVolume", 0.5, &mvol)) return spc_err(SPC_E_INVALID_PARAM, 0, "'monitorVolume' must be 0.0..2.0");
    if (spc_jhas(p, "monitor") && !spc_jbool_strict(p, "monitor", &mon)) return spc_err(SPC_E_INVALID_PARAM, 0, "'monitor' must be a bool");
    if (spc_musicbed_start(file, vol, mon, mvol, &fi, err, sizeof(err)) != 0) return spc_err(SPC_E_INVALID_PARAM, 0, "%s", err);
    *res = cJSON_CreateObject();
    cJSON_AddStringToObject(*res, "file", file);
    cJSON_AddStringToObject(*res, "format", fi.format);
    cJSON_AddNumberToObject(*res, "durationMs", fi.durationMs);
    return SPC_OK;
}

static int h_musicbed_stop(cJSON* p, cJSON** res)
{
    (void)p;
    *res = cJSON_CreateObject();
    cJSON_AddBoolToObject(*res, "stopped", spc_musicbed_stop("stopped", NULL));
    return SPC_OK;
}

static int h_musicbed_set(cJSON* p, cJSON** res)
{
    double vol, mvol;
    int mon = -1, paused = -1, b;
    (void)res;
    if (!spc_jhas(p, "volume") && !spc_jhas(p, "monitor") && !spc_jhas(p, "monitorVolume") && !spc_jhas(p, "paused"))
        return spc_err(SPC_E_INVALID_PARAM, 0, "at least one of volume, monitor, monitorVolume, paused required");
    if (!vol_param(p, "volume", -1.0, &vol)) return spc_err(SPC_E_INVALID_PARAM, 0, "'volume' must be 0.0..2.0");
    if (!vol_param(p, "monitorVolume", -1.0, &mvol)) return spc_err(SPC_E_INVALID_PARAM, 0, "'monitorVolume' must be 0.0..2.0");
    if (spc_jhas(p, "monitor")) { if (!spc_jbool_strict(p, "monitor", &b)) return spc_err(SPC_E_INVALID_PARAM, 0, "'monitor' must be a bool"); mon = b; }
    if (spc_jhas(p, "paused")) { if (!spc_jbool_strict(p, "paused", &b)) return spc_err(SPC_E_INVALID_PARAM, 0, "'paused' must be a bool"); paused = b; }
    if (spc_musicbed_set(vol, mvol, mon, paused) != 0) return spc_err(SPC_E_NOT_FOUND, 0, "no musicbed running");
    return SPC_OK;
}

static int h_musicbed_state(cJSON* p, cJSON** res)
{
    spc_bed_state st;
    cJSON* arr = cJSON_CreateArray();
    int i;
    (void)p;
    spc_musicbed_state(&st);
    *res = cJSON_CreateObject();
    cJSON_AddBoolToObject(*res, "active", st.active);
    if (st.active) {
        cJSON_AddStringToObject(*res, "file", st.file);
        cJSON_AddStringToObject(*res, "format", st.format);
    }
    cJSON_AddNumberToObject(*res, "volume", st.vol);
    cJSON_AddBoolToObject(*res, "monitor", st.monitor);
    cJSON_AddNumberToObject(*res, "monitorVolume", st.monvol);
    cJSON_AddBoolToObject(*res, "paused", st.paused);
    cJSON_AddNumberToObject(*res, "positionMs", st.positionMs);
    cJSON_AddNumberToObject(*res, "durationMs", st.durationMs);
    for (i = 0; i < st.ncalls; i++) cJSON_AddItemToArray(arr, cJSON_CreateNumber((double)st.calls[i]));
    cJSON_AddItemToObject(*res, "calls", arr);
    return SPC_OK;
}

const spc_method spc_methods_media[] = {
    { "media.devices", h_devices, 0 }, { "media.setDevices", h_set_devices, 0 },
    { "media.refreshDevices", h_refresh_devices, 0 }, { "media.codecs", h_codecs, 0 },
    { "media.setCodecPriority", h_set_codec_priority, 0 }, { "media.setCodecPriorities", h_set_codec_priorities, 0 },
    { "media.setCodecParam", h_set_codec_param, 0 }, { "media.setEc", h_set_ec, 0 },
    { "media.levels", h_levels, 0 }, { "media.setMicLevel", h_set_mic, 0 }, { "media.setSpeakerLevel", h_set_speaker, 0 },
    { "media.tone", h_tone, 0 }, { "media.toneStop", h_tone_stop, 0 },
    { "media.ringStart", h_ring_start, 0 }, { "media.ringStop", h_ring_stop, 0 },
    { "media.loopback", h_loopback, 0 },
    { "media.fileInfo", h_file_info, SPC_M_PRESTART },
    { "media.recordMicStart", h_record_mic_start, 0 }, { "media.recordMicStop", h_record_mic_stop, 0 },
    { "media.musicbedStart", h_musicbed_start, 0 }, { "media.musicbedStop", h_musicbed_stop, 0 },
    { "media.musicbedSet", h_musicbed_set, 0 }, { "media.musicbedState", h_musicbed_state, 0 },
    { NULL, NULL, 0 }
};
