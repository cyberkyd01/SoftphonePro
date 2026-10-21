/* spc_media.c: devices, sound modes, codecs, EC, levels, tones, ringer, live metering (monitor), loopback, local play. */
#include "spc_internal.h"
#include "spc_player.h"
#include "spc_rec.h"
#include <pjsua-lib/pjsua_internal.h>
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
static int g_real_open_manual;     /* manual mode: Dart opened a real device */
static int g_loopback;
/* live metering (media.monitor): port 0 -> a null sink keeps the device open and makes the bridge measure the mic */
static int g_monitor;              /* desired (the app owns the decision) */
static pj_pool_t* g_mon_pool;
static pjmedia_port* g_mon_port;
static int g_mon_slot = -1;
static int g_mon_conn;             /* port 0 -> sink connected */
static int g_mon_last_active, g_mon_last_src;   /* last media.monitor event: active, source (0 device, 1 null, 2 none) */
/* echo test: EC/NS would cancel the mic against itself, so the tail is zeroed while it runs */
static int g_ec_bypass;
static unsigned g_ec_tail_cfg, g_ec_opts_cfg;   /* the user's EC (core.start / media.setEc): what calls must get */
static unsigned g_lb_gen;
/* The echo-test state (g_loopback, g_lb_gen, g_ec_bypass, g_ec_*_cfg) is touched by the worker, pjsua's timer thread,
 * the pjsua thread (call creation) and the IAX2 thread. g_lb_mtx is a leaf: held only around those variables, never
 * across a pjsua call. */
static spc_mutex_t g_lb_mtx;
static volatile long g_lb_once;
static void lb_init_once(void) { spc_mutex_init(&g_lb_mtx); }
static void lb_lock(void) { spc_once(&g_lb_once, lb_init_once); spc_mutex_lock(&g_lb_mtx); }
static void lb_unlock(void) { spc_mutex_unlock(&g_lb_mtx); }
/* device-open errors: one media.error per failure episode; the last one is kept for media.audioState */
static int g_err_latched;
static struct { int set; char op[24]; pj_status_t status; char message[160]; } g_last_err;
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

/* the null device is attached when pjsua holds a null master port (the auto-close timer drops it by itself) */
static int null_attached(void) { return pjsua_var.null_snd != NULL; }

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
    if (!null_attached()) st = pjsua_set_null_snd_dev();
    return st;
}

int spc_media_snd_open(void) { return pjsua_snd_is_active() ? 1 : 0; }

const char* spc_media_snd_current(char* cap, size_t n, char* play, size_t m)
{
    spc_strlcpy(cap, g_cur_cap, n);
    spc_strlcpy(play, g_cur_play, m);
    return cap;
}

/* force=0: an "openDevice" failure is reported once until a real device is seen open again (every retry would repeat
 * it); the latch is reset when a real device opens (ensure_clock, setDevices) and when emit_monitor_state sees one */
static void emit_media_error(const char* op, pj_status_t st, const char* fallback, int force)
{
    cJSON* f;
    char em[160];
    pj_strerror(st, em, sizeof(em));
    g_last_err.set = 1;
    g_last_err.status = st;
    spc_strlcpy(g_last_err.op, op, sizeof(g_last_err.op));
    spc_strlcpy(g_last_err.message, em, sizeof(g_last_err.message));
    if (!force && spc_strieq(op, "openDevice") && g_err_latched) return;
    if (spc_strieq(op, "openDevice")) g_err_latched = 1;
    f = cJSON_CreateObject();
    cJSON_AddStringToObject(f, "op", op);
    cJSON_AddNumberToObject(f, "status", st);
    cJSON_AddStringToObject(f, "message", em);
    spc_jadd_str(f, "fallback", fallback);
    spc_emit("media.error", f);
}

/* called when connecting to port 0 failed (device open failed). Returns 1 if a retry makes sense. */
int spc_media_on_connect_error(pj_status_t st)
{
    if (null_attached()) return 0;
    if (spc_media_set_null_snd() == PJ_SUCCESS) {
        emit_media_error("openDevice", st, "null", 0);
        return 1;
    }
    return 0;
}

static void ec_bypass(int on);
static void loopback_stop(const char* reason);

/* A call is starting to use the microphone: the echo test ends and the echo canceller is back before the mic reaches it */
void spc_media_calls_begin(void)
{
    loopback_stop("call");
    ec_bypass(0);
}

void spc_media_on_call_media(int slot, int active)
{
    (void)slot;
    if (!active) return;
    spc_media_calls_begin();
    if ((G.snd_manual && !g_real_open_manual) || G.no_audio_device) {
        if (!null_attached()) spc_media_set_null_snd();
    }
}

static int resolve_dev(const char* id, int capture, int* idx, int* special);

int spc_media_ensure_clock(void)
{
    if (pjsua_snd_is_active()) return 0;
    if (G.no_audio_device || (G.snd_manual && !g_real_open_manual))
        return spc_media_set_null_snd() == PJ_SUCCESS ? 0 : -1;
    {
        pjsua_snd_dev_param prm;
        pj_status_t st;
        int ci = PJMEDIA_AUD_DEFAULT_CAPTURE_DEV, pi = PJMEDIA_AUD_DEFAULT_PLAYBACK_DEV, cs = 1, ps = 1;
        pjsua_snd_dev_param_default(&prm);
        /* honour the user's selection (media.setDevices), falling back to the OS defaults */
        if (resolve_dev(g_cur_cap, 1, &ci, &cs) != 0) { ci = PJMEDIA_AUD_DEFAULT_CAPTURE_DEV; cs = 1; }
        if (resolve_dev(g_cur_play, 0, &pi, &ps) != 0) { pi = PJMEDIA_AUD_DEFAULT_PLAYBACK_DEV; ps = 1; }
        if (cs >= 2 || ps >= 2) return spc_media_set_null_snd() == PJ_SUCCESS ? 0 : -1;   /* the user chose null/none: never a real device */
        prm.capture_dev = ci;
        prm.playback_dev = pi;
        st = pjsua_set_snd_dev2(&prm);
        if (st != PJ_SUCCESS) {
            emit_media_error("openDevice", st, "null", 0);
            return spc_media_set_null_snd() == PJ_SUCCESS ? 0 : -1;
        }
        g_err_latched = 0;
    }
    return 0;
}

int spc_media_init(void)
{
    pj_status_t st = PJ_SUCCESS;
    g_real_open_manual = 0;
    g_loopback = 0;
    g_mic_rec = 0;
    g_monitor = 0; g_mon_conn = 0; g_mon_last_active = 0; g_mon_last_src = 2;
    g_ec_bypass = 0;
    g_ec_tail_cfg = pjsua_var.media_cfg.ec_tail_len;     /* pjsua_init has applied core.start's ec config */
    g_ec_opts_cfg = pjsua_var.media_cfg.ec_options;
    g_err_latched = 0;
    memset(&g_last_err, 0, sizeof(g_last_err));
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

/* ---- live metering (media.monitor) ---- */
static void mon_destroy(void)
{
    pjmedia_port* port = g_mon_port;
    pj_pool_t* pool = g_mon_pool;
    if (g_mon_slot >= 0) { pjsua_conf_disconnect(0, g_mon_slot); pjsua_conf_remove_port(g_mon_slot); g_mon_slot = -1; }
    g_mon_conn = 0;
    g_mon_port = NULL; g_mon_pool = NULL;
    spc_port_destroy_release(port, pool);
}

static void mon_create(void)
{
    pjsua_conf_port_info pi;
    pj_status_t st;
    unsigned rate = (unsigned)spc_media_bridge_rate();
    g_mon_pool = pjsua_pool_create("spcmon", 1024, 1024);
    if (!g_mon_pool) return;
    if (pjsua_conf_get_port_info(0, &pi) == PJ_SUCCESS)      /* mirrors port 0 */
        st = pjmedia_null_port_create(g_mon_pool, pi.clock_rate, pi.channel_count, pi.samples_per_frame, pi.bits_per_sample, &g_mon_port);
    else
        st = pjmedia_null_port_create(g_mon_pool, rate, 1, rate / 50, 16, &g_mon_port);
    if (st == PJ_SUCCESS) st = pjsua_conf_add_port(g_mon_pool, g_mon_port, &g_mon_slot);
    if (st != PJ_SUCCESS) { g_mon_slot = -1; mon_destroy(); }
}

int spc_media_monitor_slot(void) { return g_mon_slot; }
int spc_media_monitor_on(void) { return g_mon_slot >= 0 && g_mon_conn; }

/* source of the microphone signal: 0 real device, 1 null device, 2 none (closed) */
static int snd_source(void) { return pjsua_snd_is_active() ? 0 : (null_attached() ? 1 : 2); }
static const char* const g_src_name[3] = { "device", "null", "none" };

static int mon_active(void) { return pjsua_snd_is_active() && g_mon_slot >= 0 && g_mon_conn && g_monitor; }

static cJSON* monitor_json(void)
{
    cJSON* o = cJSON_CreateObject();
    cJSON_AddBoolToObject(o, "active", mon_active());
    cJSON_AddStringToObject(o, "source", g_src_name[snd_source()]);
    cJSON_AddStringToObject(o, "capture", g_cur_cap);
    cJSON_AddStringToObject(o, "playback", g_cur_play);
    return o;
}

/* media.monitor event, only when (active, source) changed since the last one */
static void emit_monitor_state(void)
{
    int act = mon_active() ? 1 : 0, src = snd_source();
    if (src == 0) g_err_latched = 0;      /* a real device is open again: the next open failure is news */
    if (act == g_mon_last_active && src == g_mon_last_src) return;
    g_mon_last_active = act; g_mon_last_src = src;
    spc_emit("media.monitor", monitor_json());
}

/* Reconciles the desired monitor state with the bridge; safe to call from any handler. */
static void monitor_apply(void)
{
    int want = g_monitor && !G.no_audio_device && !(G.snd_manual && !g_real_open_manual);
    if (want) {
        spc_media_ensure_clock();                  /* also retries the real device when the null one is attached */
        if (g_mon_slot < 0) mon_create();
        if (g_mon_slot >= 0) {
            pj_status_t st = pjsua_conf_connect(0, g_mon_slot);
            if (st != PJ_SUCCESS && spc_media_on_connect_error(st)) st = pjsua_conf_connect(0, g_mon_slot);
            g_mon_conn = st == PJ_SUCCESS;
        }
    } else if (g_mon_slot >= 0) {
        pjsua_conf_disconnect(0, g_mon_slot);      /* the auto-close timer takes the device down 1 s later */
        g_mon_conn = 0;
    }
    spc_call_apply_topology();                     /* the musicbed feeds (or leaves) the sink */
    emit_monitor_state();
}

/* ---- echo test: EC bypass ---- */
static void ec_bypass(int on)
{
    unsigned tail = 0, opts = 0;
    int act = 0, again;
    lb_lock();
    if (on && !g_ec_bypass) { g_ec_bypass = 1; act = 1; tail = 0; opts = g_ec_opts_cfg; }
    else if (!on && g_ec_bypass) { g_ec_bypass = 0; act = 1; tail = g_ec_tail_cfg; opts = g_ec_opts_cfg; }
    lb_unlock();
    if (!act) return;
    pjsua_set_ec(tail, opts);                      /* applies to the open port and to every later open */
    /* a concurrent restore (call start / timeout) may have landed before our bypass: re-apply the config */
    lb_lock();
    again = on && !g_ec_bypass; tail = g_ec_tail_cfg; opts = g_ec_opts_cfg;
    lb_unlock();
    if (again) pjsua_set_ec(tail, opts);
}

static void loopback_stop(const char* reason)
{
    cJSON* f;
    lb_lock();
    if (!g_loopback) { lb_unlock(); return; }
    g_loopback = 0;
    g_lb_gen++;
    lb_unlock();
    pjsua_conf_disconnect(0, 0);
    ec_bypass(0);
    f = cJSON_CreateObject();
    cJSON_AddBoolToObject(f, "enabled", 0);
    cJSON_AddStringToObject(f, "reason", reason);
    spc_emit("media.loopback", f);
}

static void loopback_timer_cb(void* ud)
{
    int stale;
    lb_lock();
    stale = (unsigned)(uintptr_t)ud != g_lb_gen || !g_loopback;
    lb_unlock();
    if (!stale) loopback_stop("timeout");
}

void spc_media_shutdown(void)
{
    spc_player_shutdown();
    spc_rec_shutdown();
    loopback_stop("shutdown");
    ec_bypass(0);
    g_monitor = 0;
    mon_destroy();
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

/* Device names as UTF-8. WMME reports them in the ANSI code page ("Intel\xAE" for "Intel®"), and JSON
 * that is not valid UTF-8 is dropped by the Dart VM: the device list would never arrive. */
static void dev_str(const char* s, char* out, size_t n)
{
#if defined(_WIN32)
    wchar_t w[256];
    if (n > 0 && MultiByteToWideChar(CP_ACP, 0, s, -1, w, 256) > 0 &&
        WideCharToMultiByte(CP_UTF8, 0, w, -1, out, (int)n, NULL, NULL) > 0) return;
#endif
    spc_strlcpy(out, s, n);
}

static void dev_id(const pjmedia_aud_dev_info* d, char* out, size_t n)
{
    char drv[96], name[200];
    dev_str(d->driver, drv, sizeof(drv));
    dev_str(d->name, name, sizeof(name));
    snprintf(out, n, "%s:%s", drv, name);
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
            char id[300], name[200], drv[96];
            dev_id(&info[i], id, sizeof(id));
            dev_str(info[i].name, name, sizeof(name));
            dev_str(info[i].driver, drv, sizeof(drv));
            if (info[i].input_count > 0) {
                cJSON* d = cJSON_CreateObject();
                cJSON_AddStringToObject(d, "devId", id);
                cJSON_AddStringToObject(d, "name", name);
                cJSON_AddStringToObject(d, "driver", drv);
                cJSON_AddNumberToObject(d, "inputs", info[i].input_count);
                cJSON_AddNumberToObject(d, "outputs", info[i].output_count);
                cJSON_AddBoolToObject(d, "isDefault", (int)i == cap_def);
                cJSON_AddItemToArray(cap, d);
            }
            if (info[i].output_count > 0) {
                cJSON* d = cJSON_CreateObject();
                cJSON_AddStringToObject(d, "devId", id);
                cJSON_AddStringToObject(d, "name", name);
                cJSON_AddStringToObject(d, "driver", drv);
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
        char d[300];
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
        loopback_stop("stopped");
        if (spc_calls_active() > 0) st = spc_media_set_null_snd();
        else pjsua_set_no_snd_dev();
        monitor_apply();
        return SPC_OK;
    }
    if (cs == 2 || ps == 2) {
        g_real_open_manual = 0;
        loopback_stop("stopped");
        st = spc_media_set_null_snd();
        if (st != PJ_SUCCESS) return spc_pjerr(st, "null device");
        monitor_apply();
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
            emit_media_error("setDevices", st, "null", 1);
            g_real_open_manual = 0;
            spc_media_set_null_snd();
            monitor_apply();
            return SPC_OK;
        }
        g_err_latched = 0;
        g_real_open_manual = 1;
    }
    /* NO_IMMEDIATE_OPEN closes the old device without opening the new one: re-wire the monitor / echo test onto it */
    if (g_loopback) spc_media_ensure_clock();
    monitor_apply();
    return SPC_OK;
}

static int h_refresh_devices(cJSON* p, cJSON** res)
{
    (void)p; (void)res;
    pjmedia_aud_dev_refresh();
    spc_emit("media.devicesChanged", NULL);
    /* a monitor / echo test that fell back to the null device retries the real one */
    if ((g_monitor || g_loopback) && null_attached() && !G.no_audio_device) {
        if (g_loopback) spc_media_ensure_clock();
        monitor_apply();
    }
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
    int tail = spc_jint(p, "tailMs", 200), tz, byp;
    unsigned opts, tail_now;
    pj_status_t st;
    (void)res;
    if (!algo) return spc_err(SPC_E_INVALID_PARAM, 0, "'algo' required");
    if (tail < 0 || tail > 1000) return spc_err(SPC_E_INVALID_PARAM, 0, "tailMs must be 0..1000");
    opts = spc_ec_options(algo, spc_jbool(p, "ns", 1), spc_jbool(p, "agc", 0), &tz);
    if (opts == 0xFFFFFFFFu) return spc_err(SPC_E_INVALID_PARAM, 0, "unknown algo '%s'", algo);
    lb_lock();
    g_ec_tail_cfg = tz ? 0 : (unsigned)tail;
    g_ec_opts_cfg = opts;
    byp = g_ec_bypass;                    /* echo test running: applied when it ends */
    tail_now = g_ec_tail_cfg;
    lb_unlock();
    if (!byp) {
        st = pjsua_set_ec(tail_now, opts);
        if (st != PJ_SUCCESS) return spc_pjerr(st, "pjsua_set_ec");
    }
    return SPC_OK;
}

static int h_levels(cJSON* p, cJSON** res)
{
    unsigned tx = 0, rx = 0, dtx = 0, drx = 0, stx = 0, srx = 0;
    int dn = spc_call_mic_source();
    (void)p;
    pjsua_conf_get_signal_level(0, &tx, &rx);
    /* the microphone as the calls get it: the voice-isolation output while that processor is in the path */
    if (dn > 0 && spc_calls_active() > 0 && pjsua_conf_get_signal_level(dn, &dtx, &drx) == PJ_SUCCESS) rx = drx;
    *res = cJSON_CreateObject();
    cJSON_AddNumberToObject(*res, "mic", rx);
    cJSON_AddNumberToObject(*res, "speaker", tx);
    cJSON_AddNumberToObject(*res, "musicbed", spc_musicbed_level());
    /* what callers would get: the mic and the musicbed as mixed into the monitor sink (0 without monitor) */
    if (g_monitor && spc_media_monitor_on()) pjsua_conf_get_signal_level(g_mon_slot, &stx, &srx);
    cJSON_AddNumberToObject(*res, "send", stx);
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
    pjmedia_tone_desc td[3];
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
    else if (spc_strieq(kind, "chime")) {
        td[0].freq1 = 523; td[0].on_msec = 180; td[0].off_msec = 40;
        td[1].freq1 = 659; td[1].on_msec = 180; td[1].off_msec = 40;
        td[2].freq1 = 784; td[2].on_msec = 260; td[2].off_msec = 0;
        nt = 3; loop = 0;
    }
    else if (spc_strieq(kind, "dtmf")) {
        if (!digits || !digits[0] || strlen(digits) > 32) return spc_err(SPC_E_INVALID_PARAM, 0, "'digits' required for dtmf");
        for (i = 0; digits[i]; i++) {
            if (!strchr("0123456789*#ABCDabcd", digits[i])) return spc_err(SPC_E_INVALID_PARAM, 0, "invalid digit");
            dg[nd].digit = digits[i]; dg[nd].on_msec = 120; dg[nd].off_msec = 60; dg[nd].volume = 0; nd++;
        }
    } else return spc_err(SPC_E_INVALID_PARAM, 0, "unknown tone kind '%s'", kind);
    if (spc_jhas(p, "loop") && !spc_strieq(kind, "chime")) loop = spc_jbool(p, "loop", loop);
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
    if (st != PJ_SUCCESS) { ring_stop(); emit_media_error("ringStart", st, NULL, 1); return spc_pjerr(st, "ringer"); }
    spc_strlcpy(g_cur_ring, dev, sizeof(g_cur_ring));
    return SPC_OK;
}

static int h_ring_stop(cJSON* p, cJSON** res) { (void)p; (void)res; ring_stop(); return SPC_OK; }

static int h_loopback(cJSON* p, cJSON** res)
{
    int en = 0, tmo = 0, was;
    unsigned gen;
    pj_status_t st;
    (void)res;
    if (!spc_jbool_strict(p, "enabled", &en)) return spc_err(SPC_E_INVALID_PARAM, 0, "'enabled' (bool) required");
    if (!spc_jint_range(p, "timeoutMs", 0, 0, 600000, &tmo)) return spc_err(SPC_E_INVALID_PARAM, 0, "'timeoutMs' must be 0..600000");
    if (en) {
        if (spc_calls_active() > 0) return spc_err(SPC_E_BUSY, 0, "echo test is not available during a call");
        lb_lock();
        was = g_loopback;
        if (!was) g_loopback = 1;
        gen = ++g_lb_gen;                               /* a new timeout replaces the previous one */
        lb_unlock();
        if (!was) {
            spc_media_ensure_clock();
            ec_bypass(1);
            st = pjsua_conf_connect(0, 0);
            if (st != PJ_SUCCESS && spc_media_on_connect_error(st)) st = pjsua_conf_connect(0, 0);
            if (st != PJ_SUCCESS) {
                lb_lock(); g_loopback = 0; lb_unlock();
                ec_bypass(0);
                return spc_pjerr(st, "loopback");
            }
        }
        if (tmo > 0) pjsua_schedule_timer2(&loopback_timer_cb, (void*)(uintptr_t)gen, (unsigned)tmo);
    } else loopback_stop("stopped");
    return SPC_OK;
}

/* ---- media.monitor / media.audioState ---- */
static int h_monitor(cJSON* p, cJSON** res)
{
    int en = 0;
    if (!spc_jbool_strict(p, "enabled", &en)) return spc_err(SPC_E_INVALID_PARAM, 0, "'enabled' (bool) required");
    g_monitor = en;
    monitor_apply();
    *res = monitor_json();
    return SPC_OK;
}

/* {devId,name,driver} of an audio device index (default ids resolved), NULL when it is none */
static cJSON* dev_obj(int idx, int capture)
{
    pjmedia_aud_dev_info info;
    pjmedia_aud_param dp;
    char id[300], name[200], drv[96];
    cJSON* o;
    if (idx == PJMEDIA_AUD_DEFAULT_CAPTURE_DEV || idx == PJMEDIA_AUD_DEFAULT_PLAYBACK_DEV) {
        if (pjmedia_aud_dev_default_param(idx, &dp) != PJ_SUCCESS) return NULL;
        idx = capture ? dp.rec_id : dp.play_id;
    }
    if (idx < 0 || pjmedia_aud_dev_get_info(idx, &info) != PJ_SUCCESS) return NULL;
    dev_id(&info, id, sizeof(id));
    dev_str(info.name, name, sizeof(name));
    dev_str(info.driver, drv, sizeof(drv));
    o = cJSON_CreateObject();
    cJSON_AddStringToObject(o, "devId", id);
    cJSON_AddStringToObject(o, "name", name);
    cJSON_AddStringToObject(o, "driver", drv);
    return o;
}

static int h_audio_state(cJSON* p, cJSON** res)
{
    int src, ci = -3, pi = -3, cs = 0, ps = 0, have = 0, byp;
    unsigned snd_rate = 0, tail, opts;
    cJSON *cap = NULL, *play = NULL, *ec, *le;
    (void)p;
    PJSUA_LOCK();
    src = snd_source();
    if (pjsua_var.snd_port) {       /* the open stream: what is really in use */
        pjmedia_aud_stream* strm = pjmedia_snd_port_get_snd_stream(pjsua_var.snd_port);
        pjmedia_aud_param ap;
        if (strm && pjmedia_aud_stream_get_param(strm, &ap) == PJ_SUCCESS) {
            ci = ap.rec_id; pi = ap.play_id; snd_rate = ap.clock_rate; have = 1;
        }
    }
    PJSUA_UNLOCK();
    if (!have && src != 1) {        /* closed: the configured devices */
        if (resolve_dev(g_cur_cap, 1, &ci, &cs) != 0 || cs >= 2) ci = cs >= 2 ? -3 : PJMEDIA_AUD_DEFAULT_CAPTURE_DEV;
        if (resolve_dev(g_cur_play, 0, &pi, &ps) != 0 || ps >= 2) pi = ps >= 2 ? -3 : PJMEDIA_AUD_DEFAULT_PLAYBACK_DEV;
    }
    if (src != 1) { cap = dev_obj(ci, 1); play = dev_obj(pi, 0); }
    lb_lock();
    tail = g_ec_tail_cfg; opts = g_ec_opts_cfg; byp = g_ec_bypass;
    lb_unlock();
    *res = cJSON_CreateObject();
    cJSON_AddStringToObject(*res, "source", g_src_name[src]);
    if (cap) cJSON_AddItemToObject(*res, "capture", cap); else cJSON_AddNullToObject(*res, "capture");
    if (play) cJSON_AddItemToObject(*res, "playback", play); else cJSON_AddNullToObject(*res, "playback");
    cJSON_AddNumberToObject(*res, "clockRate", spc_media_bridge_rate());
    cJSON_AddNumberToObject(*res, "sndClockRate", snd_rate);
    ec = cJSON_AddObjectToObject(*res, "ec");
    cJSON_AddNumberToObject(ec, "tailMs", tail);
    cJSON_AddNumberToObject(ec, "options", opts);
    cJSON_AddBoolToObject(ec, "bypassed", byp);
    cJSON_AddBoolToObject(*res, "loopback", g_loopback);
    cJSON_AddBoolToObject(*res, "monitor", g_monitor);
    if (g_last_err.set) {
        le = cJSON_AddObjectToObject(*res, "lastError");
        cJSON_AddStringToObject(le, "op", g_last_err.op);
        cJSON_AddNumberToObject(le, "status", g_last_err.status);
        cJSON_AddStringToObject(le, "message", g_last_err.message);
    } else cJSON_AddNullToObject(*res, "lastError");
    return SPC_OK;
}

/* ---- local playback (media.playLocal / media.playStop): a file to the speaker, no call ---- */
static int h_play_local(cJSON* p, cJSON** res)
{
    const char* file = spc_jstr(p, "file");
    double vol = spc_jnum(p, "volume", 1.0);
    char err[200];
    int id = 0;
    if (!file || !file[0]) return spc_err(SPC_E_INVALID_PARAM, 0, "'file' required");
    if (!(vol >= 0.0 && vol <= 4.0)) return spc_err(SPC_E_INVALID_PARAM, 0, "volume must be 0.0..4.0");
    if (spc_player_start(SPC_LOCAL_CID, file, 0, (float)vol, 1, 0, 0, &id, err, sizeof(err)) != 0)
        return spc_err(SPC_E_INVALID_PARAM, 0, "%s", err);
    *res = cJSON_CreateObject();
    cJSON_AddNumberToObject(*res, "playId", id);
    return SPC_OK;
}

static int h_play_stop(cJSON* p, cJSON** res)
{
    int id = 0;
    if (!spc_jint_range(p, "playId", 0, 0, 0x7FFFFFFF, &id)) return spc_err(SPC_E_INVALID_PARAM, 0, "'playId' must be an integer >= 0");
    *res = cJSON_CreateObject();
    cJSON_AddNumberToObject(*res, "stopped", spc_player_stop(SPC_LOCAL_CID, id, "stopped"));
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
    int mon = 0, rc, pst = 0;
    spc_fileinfo fi;
    char err[200];
    if (!file || !file[0]) return spc_err(SPC_E_INVALID_PARAM, 0, "'file' required");
    if (!vol_param(p, "volume", 0.3, &vol)) return spc_err(SPC_E_INVALID_PARAM, 0, "'volume' must be 0.0..2.0");
    if (!vol_param(p, "monitorVolume", 0.5, &mvol)) return spc_err(SPC_E_INVALID_PARAM, 0, "'monitorVolume' must be 0.0..2.0");
    if (spc_jhas(p, "monitor") && !spc_jbool_strict(p, "monitor", &mon)) return spc_err(SPC_E_INVALID_PARAM, 0, "'monitor' must be a bool");
    /* INVALID_PARAM only for the file itself (the app gives up on that file); NOT_STARTED / INTERNAL / PJ_ERROR when
     * the engine side fails, so that the app may retry */
    if ((rc = spc_musicbed_start(file, vol, mon, mvol, &fi, &pst, err, sizeof(err))) != 0)
        return spc_err(rc, (pj_status_t)pst, "%s", err);
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

#ifdef SPC_TEST_HOOKS
/* __topoDelay {ms:0..200}: widen every topology pass (concurrency tests only) */
static int h_topo_delay(cJSON* p, cJSON** res)
{
    int ms = 0;
    (void)res;
    if (!spc_jint_range(p, "ms", 0, 0, 200, &ms)) return spc_err(SPC_E_INVALID_PARAM, 0, "'ms' must be 0..200");
    spc_call_test_topo_delay(ms);
    return SPC_OK;
}
#endif

const spc_method spc_methods_media[] = {
    { "media.devices", h_devices, 0 }, { "media.setDevices", h_set_devices, 0 },
    { "media.refreshDevices", h_refresh_devices, 0 }, { "media.codecs", h_codecs, 0 },
    { "media.setCodecPriority", h_set_codec_priority, 0 }, { "media.setCodecPriorities", h_set_codec_priorities, 0 },
    { "media.setCodecParam", h_set_codec_param, 0 }, { "media.setEc", h_set_ec, 0 },
    { "media.levels", h_levels, 0 }, { "media.setMicLevel", h_set_mic, 0 }, { "media.setSpeakerLevel", h_set_speaker, 0 },
    { "media.tone", h_tone, 0 }, { "media.toneStop", h_tone_stop, 0 },
    { "media.ringStart", h_ring_start, 0 }, { "media.ringStop", h_ring_stop, 0 },
    { "media.loopback", h_loopback, 0 }, { "media.monitor", h_monitor, 0 }, { "media.audioState", h_audio_state, 0 },
    { "media.playLocal", h_play_local, 0 }, { "media.playStop", h_play_stop, 0 },
    { "media.fileInfo", h_file_info, SPC_M_PRESTART },
    { "media.recordMicStart", h_record_mic_start, 0 }, { "media.recordMicStop", h_record_mic_stop, 0 },
    { "media.musicbedStart", h_musicbed_start, 0 }, { "media.musicbedStop", h_musicbed_stop, 0 },
    { "media.musicbedSet", h_musicbed_set, 0 }, { "media.musicbedState", h_musicbed_state, 0 },
#ifdef SPC_TEST_HOOKS
    { "__topoDelay", h_topo_delay, 0 },
#endif
    { NULL, NULL, 0 }
};
