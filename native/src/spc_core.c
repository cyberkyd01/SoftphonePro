/* spc_core.c: public C ABI, worker thread, event delivery, core.* requests. */
#include "spc_internal.h"
#include "dart_api_dl.h"
#include <errno.h>
#include <time.h>

#if defined(_MSC_VER)
#  define SPC_TLS __declspec(thread)
#else
#  define SPC_TLS __thread
#endif

spc_global G;
static void pj_log_early(int level, const char* data, int len) { (void)level; (void)data; (void)len; }

static int g_locks_ready = 0;

/* ------------------------------------------------------------------ */
/* errors                                                              */
/* ------------------------------------------------------------------ */
static struct { int code; pj_status_t status; char msg[300]; } g_err;

const char* spc_err_name(int c)
{
    switch (c) {
    case SPC_E_INVALID_PARAM: return "INVALID_PARAM";
    case SPC_E_NOT_FOUND: return "NOT_FOUND";
    case SPC_E_NOT_STARTED: return "NOT_STARTED";
    case SPC_E_ALREADY: return "ALREADY";
    case SPC_E_PJ_ERROR: return "PJ_ERROR";
    case SPC_E_TIMEOUT: return "TIMEOUT";
    case SPC_E_UNSUPPORTED: return "UNSUPPORTED";
    case SPC_E_BUSY: return "BUSY";
    default: return "INTERNAL";
    }
}
int spc_err(int code, pj_status_t status, const char* fmt, ...)
{
    va_list ap;
    g_err.code = code;
    g_err.status = status;
    va_start(ap, fmt);
    vsnprintf(g_err.msg, sizeof(g_err.msg), fmt, ap);
    va_end(ap);
    return code;
}
int spc_pjerr(pj_status_t status, const char* what)
{
    char em[160];
    pj_strerror(status, em, sizeof(em));
    return spc_err(SPC_E_PJ_ERROR, status, "%s: %s", what, em);
}

/* ------------------------------------------------------------------ */
/* locks                                                               */
/* ------------------------------------------------------------------ */
static void ensure_locks(void)
{
    if (g_locks_ready) return;
    spc_mutex_init(&G.emit_mtx);
    spc_mutex_init(&G.reg_mtx);
    spc_mutex_init(&G.q_mtx);
    spc_cond_init(&G.q_cv);
    G.next_req_id = 1;
    G.cid_counter = 0;
    g_locks_ready = 1;
}
void spc_registry_lock(void) { spc_mutex_lock(&G.reg_mtx); }
void spc_registry_unlock(void) { spc_mutex_unlock(&G.reg_mtx); }

void spc_ensure_pj_thread(const char* name)
{
    static SPC_TLS pj_thread_desc desc;
    static SPC_TLS pj_thread_t* th;
    if (!pj_thread_is_registered()) {
        th = NULL;
        pj_bzero(desc, sizeof(desc));
        pj_thread_register(name ? name : "spc-ext", desc, &th);
    }
}

/* ------------------------------------------------------------------ */
/* event delivery                                                      */
/* ------------------------------------------------------------------ */
static void deliver_locked(const char* s)
{
    int delivered = 0;
    if (G.cb) { G.cb(s, G.cb_user); delivered = 1; }
    if (G.dart_port && G.dart_ok && Dart_PostCObject_DL) {
        Dart_CObject o;
        o.type = Dart_CObject_kString;
        o.value.as_string = (char*)s;
        Dart_PostCObject_DL((Dart_Port_DL)G.dart_port, &o);
        delivered = 1;
    }
    if (!delivered) {
        int idx;
        if (G.ring_count == SPC_EVENT_RING_MAX) {
            free(G.ring[G.ring_head]);
            G.ring[G.ring_head] = NULL;
            G.ring_head = (G.ring_head + 1) % SPC_EVENT_RING_MAX;
            G.ring_count--;
        }
        idx = (G.ring_head + G.ring_count) % SPC_EVENT_RING_MAX;
        G.ring[idx] = spc_strdup(s);
        G.ring_count++;
    }
}

int spc_sink_attached(void)
{
    int r;
    spc_mutex_lock(&G.emit_mtx);
    r = (G.cb != NULL) || (G.dart_port != 0 && G.dart_ok);
    spc_mutex_unlock(&G.emit_mtx);
    return r;
}

void spc_emit(const char* event, cJSON* fields)
{
    char* body;
    char* out;
    size_t n;
    if (!g_locks_ready) { if (fields) cJSON_Delete(fields); return; }
    body = fields ? cJSON_PrintUnformatted(fields) : NULL;
    if (fields) cJSON_Delete(fields);
    n = (body ? strlen(body) : 2) + strlen(event) + 128;
    out = (char*)malloc(n);
    if (!out) { free(body); return; }
    spc_mutex_lock(&G.emit_mtx);
    G.seq++;
    if (body && strlen(body) > 2)
        snprintf(out, n, "{\"type\":\"event\",\"event\":\"%s\",\"ts\":%lld,\"seq\":%lld,%s",
                 event, (long long)spc_now_ms(), (long long)G.seq, body + 1);
    else
        snprintf(out, n, "{\"type\":\"event\",\"event\":\"%s\",\"ts\":%lld,\"seq\":%lld}",
                 event, (long long)spc_now_ms(), (long long)G.seq);
    deliver_locked(out);
    spc_mutex_unlock(&G.emit_mtx);
    free(body);
    free(out);
}

/* responses go only to attached sinks (never buffered) */
static void post_response(const char* s)
{
    spc_mutex_lock(&G.emit_mtx);
    if (G.cb) G.cb(s, G.cb_user);
    if (G.dart_port && G.dart_ok && Dart_PostCObject_DL) {
        Dart_CObject o;
        o.type = Dart_CObject_kString;
        o.value.as_string = (char*)s;
        Dart_PostCObject_DL((Dart_Port_DL)G.dart_port, &o);
    }
    spc_mutex_unlock(&G.emit_mtx);
}

static int replay_ring_locked(void)
{
    int n = 0;
    while (G.ring_count > 0) {
        char* s = G.ring[G.ring_head];
        G.ring[G.ring_head] = NULL;
        G.ring_head = (G.ring_head + 1) % SPC_EVENT_RING_MAX;
        G.ring_count--;
        if (s) {
            if (G.cb) G.cb(s, G.cb_user);
            if (G.dart_port && G.dart_ok && Dart_PostCObject_DL) {
                Dart_CObject o;
                o.type = Dart_CObject_kString;
                o.value.as_string = s;
                Dart_PostCObject_DL((Dart_Port_DL)G.dart_port, &o);
            }
            free(s);
            n++;
        }
    }
    G.ring_head = 0;
    return n;
}

SPC_API int32_t spc_api_version(void) { return SPC_API_VERSION; }
SPC_API const char* spc_version_string(void)
{
    static char buf[64];
    snprintf(buf, sizeof(buf), "%s (pjsip %s)", SPC_VERSION, PJ_VERSION);
    return buf;
}
SPC_API intptr_t spc_init_dart_api(void* data)
{
    intptr_t r = Dart_InitializeApiDL(data);
    if (r == 0) {
        ensure_locks();
        spc_mutex_lock(&G.emit_mtx);
        G.dart_ok = 1;
        spc_mutex_unlock(&G.emit_mtx);
    }
    return r;
}

SPC_API int32_t spc_set_event_port(int64_t port)
{
    int n = 0;
    ensure_locks();
    spc_mutex_lock(&G.emit_mtx);
    G.dart_port = port;
    if (port && G.dart_ok) n = replay_ring_locked();
    spc_mutex_unlock(&G.emit_mtx);
    return n;
}
SPC_API int32_t spc_set_event_callback(void (*cb)(const char*, void*), void* user)
{
    int n = 0;
    ensure_locks();
    spc_mutex_lock(&G.emit_mtx);
    G.cb = cb;
    G.cb_user = user;
    if (cb) n = replay_ring_locked();
    spc_mutex_unlock(&G.emit_mtx);
    return n;
}

/* ------------------------------------------------------------------ */
/* request queue + worker                                              */
/* ------------------------------------------------------------------ */
typedef struct spc_waiter {
    spc_cond_t cv;
    int done;
    int abandoned;
    char* resp;
} spc_waiter;

typedef struct spc_req {
    struct spc_req* next;
    int64_t id;
    char* method;
    char* params;
    spc_waiter* waiter;
} spc_req;

static const spc_method* g_tables[8];

static const spc_method* find_method(const char* name)
{
    int t;
    for (t = 0; g_tables[t]; t++) {
        const spc_method* m;
        for (m = g_tables[t]; m->name; m++)
            if (strcmp(m->name, name) == 0) return m;
    }
    return NULL;
}

static char* build_response(int64_t id, int ok, cJSON* result, int code)
{
    cJSON* r = cJSON_CreateObject();
    char* s;
    cJSON_AddStringToObject(r, "type", "response");
    cJSON_AddNumberToObject(r, "id", (double)id);
    cJSON_AddBoolToObject(r, "ok", ok);
    if (ok) {
        cJSON_AddItemToObject(r, "result", result ? result : cJSON_CreateObject());
    } else {
        cJSON* e = cJSON_AddObjectToObject(r, "error");
        cJSON_AddStringToObject(e, "code", spc_err_name(code));
        cJSON_AddNumberToObject(e, "status", (double)g_err.status);
        cJSON_AddStringToObject(e, "message", g_err.msg);
        if (result) cJSON_Delete(result);
    }
    s = cJSON_PrintUnformatted(r);
    cJSON_Delete(r);
    return s;
}

static void process_request(spc_req* rq)
{
    cJSON* params = NULL;
    cJSON* res = NULL;
    const spc_method* m;
    int code = SPC_OK;
    char* resp;

    g_err.code = 0; g_err.status = 0; g_err.msg[0] = 0;
    m = find_method(rq->method);
    if (!m) {
        code = spc_err(SPC_E_INVALID_PARAM, 0, "unknown method '%s'", rq->method);
    } else {
        if (rq->params && rq->params[0]) {
            params = cJSON_Parse(rq->params);
            if (!params || !cJSON_IsObject(params)) {
                code = spc_err(SPC_E_INVALID_PARAM, 0, "params is not a JSON object");
            }
        } else {
            params = cJSON_CreateObject();
        }
        if (code == SPC_OK && !G.started && !(m->flags & SPC_M_PRESTART))
            code = spc_err(SPC_E_NOT_STARTED, 0, "core.start has not been called");
        if (code == SPC_OK) code = m->fn(params, &res);
    }
    if (params) cJSON_Delete(params);
    resp = build_response(rq->id, code == SPC_OK, res, code);
    if (!resp) resp = spc_strdup("{\"type\":\"response\",\"ok\":false}");
    if (rq->waiter) {
        spc_mutex_lock(&G.q_mtx);
        if (rq->waiter->abandoned) {
            spc_cond_destroy(&rq->waiter->cv);
            free(rq->waiter);
            free(resp);
        } else {
            rq->waiter->resp = resp;
            rq->waiter->done = 1;
            spc_cond_broadcast(&rq->waiter->cv);
        }
        spc_mutex_unlock(&G.q_mtx);
    } else {
        post_response(resp);
        free(resp);
    }
}

static void worker_main(void* arg)
{
    pj_thread_desc desc;
    pj_thread_t* th = NULL;
    (void)arg;
    pj_bzero(desc, sizeof(desc));
    pj_thread_register("spc-worker", desc, &th);
    for (;;) {
        spc_req* rq;
        spc_mutex_lock(&G.q_mtx);
        while (!G.q_head && !G.worker_quit) spc_cond_wait(&G.q_cv, &G.q_mtx);
        if (!G.q_head && G.worker_quit) { spc_mutex_unlock(&G.q_mtx); break; }
        rq = (spc_req*)G.q_head;
        G.q_head = rq->next;
        if (!G.q_head) G.q_tail = NULL;
        spc_mutex_unlock(&G.q_mtx);
        process_request(rq);
        free(rq->method);
        free(rq->params);
        free(rq);
    }
}

static int64_t enqueue(const char* method, const char* params, spc_waiter* w, int64_t* idout)
{
    spc_req* rq;
    int64_t id;
    if (!g_locks_ready || !G.inited || !method || !method[0]) return -1;
    rq = (spc_req*)calloc(1, sizeof(*rq));
    if (!rq) return -2;
    rq->method = spc_strdup(method);
    rq->params = params ? spc_strdup(params) : NULL;
    rq->waiter = w;
    spc_mutex_lock(&G.q_mtx);
    if (G.worker_quit) { spc_mutex_unlock(&G.q_mtx); free(rq->method); free(rq->params); free(rq); return -3; }
    id = G.next_req_id++;
    rq->id = id;
    if (idout) *idout = id;
    if (G.q_tail) ((spc_req*)G.q_tail)->next = rq; else G.q_head = rq;
    G.q_tail = rq;
    spc_cond_signal(&G.q_cv);
    spc_mutex_unlock(&G.q_mtx);
    return id;
}

SPC_API int64_t spc_request(const char* method, const char* params_json)
{
    return enqueue(method, params_json, NULL, NULL);
}

SPC_API char* spc_request_sync(const char* method, const char* params_json, int32_t timeout_ms)
{
    spc_waiter* w;
    int64_t id = -1;
    char* out = NULL;
    int64_t r;
    int rem;
    if (!g_locks_ready || !G.inited) {
        return spc_strdup("{\"type\":\"response\",\"id\":0,\"ok\":false,\"error\":{\"code\":\"NOT_STARTED\",\"status\":0,\"message\":\"spc_init has not been called\"}}");
    }
    w = (spc_waiter*)calloc(1, sizeof(*w));
    if (!w) return NULL;
    spc_cond_init(&w->cv);
    r = enqueue(method, params_json, w, &id);
    if (r < 0) {
        spc_cond_destroy(&w->cv);
        free(w);
        return spc_strdup("{\"type\":\"response\",\"id\":0,\"ok\":false,\"error\":{\"code\":\"INTERNAL\",\"status\":0,\"message\":\"cannot enqueue request\"}}");
    }
    if (timeout_ms <= 0) timeout_ms = 30000;
    rem = timeout_ms;
    spc_mutex_lock(&G.q_mtx);
    while (!w->done && rem > 0) {
        int64_t t0 = spc_mono_ms();
        spc_cond_timedwait(&w->cv, &G.q_mtx, rem);
        rem -= (int)(spc_mono_ms() - t0);
    }
    if (w->done) {
        out = w->resp;
        spc_cond_destroy(&w->cv);
        free(w);
    } else {
        w->abandoned = 1;
        {
            char tmp[200];
            snprintf(tmp, sizeof(tmp),
                     "{\"type\":\"response\",\"id\":%lld,\"ok\":false,\"error\":{\"code\":\"TIMEOUT\",\"status\":0,\"message\":\"request timed out\"}}",
                     (long long)id);
            out = spc_strdup(tmp);
        }
    }
    spc_mutex_unlock(&G.q_mtx);
    return out;
}

SPC_API void spc_free(char* p) { free(p); }

/* ------------------------------------------------------------------ */
/* init / shutdown                                                     */
/* ------------------------------------------------------------------ */
extern void spc_core_force_stop(void);

SPC_API int32_t spc_init(int64_t port)
{
    pj_status_t st;
    ensure_locks();
    if (G.inited) {
        if (port && !G.dart_ok) return -EINVAL;
        spc_set_event_port(port);
        return 1;
    }
    if (port != 0 && !G.dart_ok) return -EINVAL;
    pj_log_set_log_func(&pj_log_early);
    st = pj_init();
    if (st != PJ_SUCCESS) return -EIO;
    g_tables[0] = spc_methods_core;
    g_tables[1] = spc_methods_account;
    g_tables[2] = spc_methods_call;
    g_tables[3] = spc_methods_media;
    g_tables[4] = spc_methods_presence;
    g_tables[5] = spc_methods_diag;
    g_tables[6] = NULL;
    G.worker_quit = 0;
    G.q_head = G.q_tail = NULL;
    if (spc_thread_create(&G.worker, worker_main, NULL) != 0) {
        pj_shutdown();
        return -EAGAIN;
    }
    G.worker_running = 1;
    G.inited = 1;
    if (port) spc_set_event_port(port);
    return 0;
}

SPC_API void spc_shutdown(void)
{
    int i;
    if (!g_locks_ready || !G.inited) return;
    G.shutting = 1;
    spc_ensure_pj_thread("spc-shutdown");
    /* run a non-graceful stop on the worker, then quit it */
    {
        char* r = spc_request_sync("core.stop", "{\"graceful\":false}", 15000);
        spc_free(r);
    }
    spc_mutex_lock(&G.q_mtx);
    G.worker_quit = 1;
    spc_cond_broadcast(&G.q_cv);
    spc_mutex_unlock(&G.q_mtx);
    if (G.worker_running) spc_thread_join(&G.worker);
    G.worker_running = 0;
    /* drain anything left in the queue */
    spc_mutex_lock(&G.q_mtx);
    while (G.q_head) {
        spc_req* rq = (spc_req*)G.q_head;
        G.q_head = rq->next;
        if (rq->waiter) {
            rq->waiter->resp = spc_strdup("{\"type\":\"response\",\"ok\":false,\"error\":{\"code\":\"NOT_STARTED\",\"status\":0,\"message\":\"shutdown\"}}");
            rq->waiter->done = 1;
            spc_cond_broadcast(&rq->waiter->cv);
        }
        free(rq->method); free(rq->params); free(rq);
    }
    G.q_tail = NULL;
    spc_mutex_unlock(&G.q_mtx);
    spc_mutex_lock(&G.emit_mtx);
    for (i = 0; i < SPC_EVENT_RING_MAX; i++) { free(G.ring[i]); G.ring[i] = NULL; }
    G.ring_head = G.ring_count = 0;
    G.dart_port = 0;
    spc_mutex_unlock(&G.emit_mtx);
    G.inited = 0;
    G.shutting = 0;
    pj_shutdown();
}

/* ------------------------------------------------------------------ */
/* logging                                                             */
/* ------------------------------------------------------------------ */
static int64_t g_log_win_start;
static int g_log_win_count;

void spc_log_cb(int level, const char* data, int len)
{
    cJSON* f;
    char* tmp;
    int64_t now;
    if (!G.log_forward || !G.inited) return;
    now = spc_mono_ms();
    if (now - g_log_win_start >= 1000) { g_log_win_start = now; g_log_win_count = 0; }
    if (g_log_win_count >= 200) return;
    g_log_win_count++;
    if (len < 0) len = 0;
    while (len > 0 && (data[len - 1] == '\n' || data[len - 1] == '\r')) len--;
    tmp = (char*)malloc((size_t)len + 1);
    if (!tmp) return;
    memcpy(tmp, data, (size_t)len);
    tmp[len] = 0;
    f = cJSON_CreateObject();
    cJSON_AddNumberToObject(f, "level", level);
    cJSON_AddStringToObject(f, "msg", tmp);
    free(tmp);
    spc_emit("log", f);
}

static void pj_log_bridge(int level, const char* data, int len) { spc_log_cb(level, data, len); }

/* ------------------------------------------------------------------ */
/* transports                                                          */
/* ------------------------------------------------------------------ */
typedef struct { int id; int type; int ipv6; } tp_rec;
static tp_rec g_tps[12];
static int g_ntps;

static void pj_cb_ip_change(pjsua_ip_change_op op, pj_status_t status, const pjsua_ip_change_op_info* info)
{
    cJSON* f = cJSON_CreateObject();
    const char* n = "done";
    switch (op) {
    case PJSUA_IP_CHANGE_OP_RESTART_LIS: n = "restartListener"; break;
    case PJSUA_IP_CHANGE_OP_ACC_SHUTDOWN_TP: n = "shutdownTransport"; break;
    case PJSUA_IP_CHANGE_OP_ACC_UPDATE_CONTACT: n = "reregister"; break;
    case PJSUA_IP_CHANGE_OP_ACC_HANGUP_CALLS: n = "reinvite"; break;
    case PJSUA_IP_CHANGE_OP_ACC_REINVITE_CALLS: n = "reinvite"; break;
    case PJSUA_IP_CHANGE_OP_COMPLETED: n = "done"; break;
    default: break;
    }
    cJSON_AddStringToObject(f, "op", n);
    cJSON_AddNumberToObject(f, "status", status);
    if (info) {
        if (op == PJSUA_IP_CHANGE_OP_ACC_SHUTDOWN_TP || op == PJSUA_IP_CHANGE_OP_ACC_UPDATE_CONTACT)
            cJSON_AddNumberToObject(f, "acc", info->acc_shutdown_tp.acc_id);
        else if (op == PJSUA_IP_CHANGE_OP_ACC_HANGUP_CALLS || op == PJSUA_IP_CHANGE_OP_ACC_REINVITE_CALLS) {
            cJSON_AddNumberToObject(f, "acc", info->acc_reinvite_calls.acc_id);
        }
    }
    spc_emit("core.ipChangeProgress", f);
}

static int create_tp(pjsip_transport_type_e type, const pjsua_transport_config* cfg, int ipv6, int* idout)
{
    pjsua_transport_config c = *cfg;
    pjsua_transport_id id = -1;
    pj_status_t st = pjsua_transport_create(type, &c, &id);
    if (st != PJ_SUCCESS && c.port != 0) {
        c.port = 0;
        st = pjsua_transport_create(type, &c, &id);
    }
    if (st != PJ_SUCCESS) return -1;
    if (g_ntps < (int)(sizeof(g_tps) / sizeof(g_tps[0]))) {
        g_tps[g_ntps].id = id;
        g_tps[g_ntps].type = (int)type;
        g_tps[g_ntps].ipv6 = ipv6;
        g_ntps++;
    }
    if (idout) *idout = id;
    return 0;
}

/* ------------------------------------------------------------------ */
/* DNS                                                                 */
/* ------------------------------------------------------------------ */
static int apply_nameservers(char servers[][64], int n)
{
    pjsip_endpoint* ep = pjsua_get_pjsip_endpt();
    pj_dns_resolver* res = pjsip_endpt_get_resolver(ep);
    pj_str_t ns[PJ_DNS_RESOLVER_MAX_NS];
    int i, cnt = 0;
    pj_status_t st;
    for (i = 0; i < n && cnt < PJ_DNS_RESOLVER_MAX_NS; i++) {
        if (!servers[i][0]) continue;
        ns[cnt++] = spc_pjs(servers[i]);
    }
    if (!cnt) return 0;
    if (!res) {
        st = pjsip_endpt_create_resolver(ep, &res);
        if (st != PJ_SUCCESS) return st;
        st = pjsip_endpt_set_resolver(ep, res);
        if (st != PJ_SUCCESS) return st;
    }
    st = pj_dns_resolver_set_ns(res, (unsigned)cnt, ns, NULL);
    return st;
}

/* ------------------------------------------------------------------ */
/* core.start                                                          */
/* ------------------------------------------------------------------ */
static void install_callbacks(pjsua_callback* cb)
{
    spc_account_install_callbacks(cb);
    spc_call_install_callbacks(cb);
    spc_presence_install_callbacks(cb);
    spc_diag_install_callbacks(cb);
    cb->on_transport_state = &spc_tls_on_transport_state;
    cb->on_ip_change_progress = &pj_cb_ip_change;
    cb->on_acc_find_for_incoming = &spc_lan_on_find;
}

static unsigned g_stats_gen;
static void stats_timer_cb(void* ud)
{
    unsigned gen = (unsigned)(uintptr_t)ud;
    if (gen != g_stats_gen || !G.started || G.stats_interval_ms <= 0) return;
    spc_call_stats_tick(spc_mono_ms());
    pjsua_schedule_timer2(&stats_timer_cb, ud, (unsigned)G.stats_interval_ms);
}

static pjsua_logging_config g_lcfg;

static int h_core_start(cJSON* p, cJSON** res)
{
    pjsua_config ucfg;
    pjsua_logging_config lcfg;
    pjsua_media_config mcfg;
    pj_status_t st;
    cJSON *tr, *tcp, *udp, *tls, *media, *ec, *jb, *lan;
    const char* s;
    char ns_auto[PJ_DNS_RESOLVER_MAX_NS][64];
    int ns_auto_n = 0;
    int ns_mode = 0; /* 0 auto, 1 none, 2 explicit */
    cJSON* ns_list = NULL;
    int log_level, i;
    static char logfile[512];
    int udp_en = 1, tcp_en = 1, tls_en = 1;
    int udp_port = 5060, tcp_port = 5061 - 1, tls_port = 5061;
    pjsua_transport_config tcfg;
    cJSON* arr;
    cJSON* r;
    cJSON* tparr;
    int ec_algo = 0;
    const char* ec_name = "auto";

    if (G.started) return spc_err(SPC_E_ALREADY, 0, "core already started");
    tcp_port = 5060;
    memset(&g_tps, 0, sizeof(g_tps));
    g_ntps = 0;
    G.udp_tp = G.tcp_tp = G.tls_tp = G.udp6_tp = G.tcp6_tp = G.tls6_tp = G.lan_tp = -1;
    G.direct_acc = G.lan_acc = -1;
    G.nat_type[0] = 0; G.nat_type_desc[0] = 0;

    s = spc_jstr(p, "publicAddr");
    spc_strlcpy(G.public_addr, s ? s : "", sizeof(G.public_addr));
    s = spc_jstr(p, "userAgent");
    spc_strlcpy(G.user_agent, s ? s : "SoftphonePro/1.0", sizeof(G.user_agent));
    log_level = spc_jint(p, "logLevel", 3);
    if (log_level < 0) log_level = 0;
    if (log_level > 6) log_level = 6;
    G.log_forward = spc_jbool(p, "logForward", 0);
    G.sip_trace = spc_jbool(p, "sipTrace", 0);
    s = spc_jstr(p, "logFile");
    spc_strlcpy(logfile, s ? s : "", sizeof(logfile));
    G.max_calls = spc_jint(p, "maxCalls", 16);
    if (G.max_calls < 1 || G.max_calls > PJSUA_MAX_CALLS) G.max_calls = G.max_calls < 1 ? 1 : PJSUA_MAX_CALLS;
    G.incoming_auto_ring_ms = spc_jint(p, "incomingAutoRingMs", 1500);
    G.incoming_unattended_ms = spc_jint(p, "incomingUnattendedMs", 30000);
    G.stats_interval_ms = spc_jint(p, "statsIntervalMs", 0);
    if (G.stats_interval_ms > 0 && G.stats_interval_ms < 200) G.stats_interval_ms = 200;

    /* nameservers */
    {
        cJSON* n = cJSON_GetObjectItemCaseSensitive(p, "nameservers");
        if (n && cJSON_IsArray(n)) {
            ns_mode = cJSON_GetArraySize(n) == 0 ? 1 : 2;
            ns_list = n;
        } else if (n && cJSON_IsString(n) && !spc_strieq(n->valuestring, "auto")) {
            return spc_err(SPC_E_INVALID_PARAM, 0, "nameservers must be \"auto\" or an array");
        }
    }

    media = spc_jobj(p, "media");
    G.snd_manual = 0;
    G.no_audio_device = 0;
    if (media) {
        s = spc_jstr(media, "sndMode");
        if (s) {
            if (spc_strieq(s, "manual")) G.snd_manual = 1;
            else if (!spc_strieq(s, "auto")) return spc_err(SPC_E_INVALID_PARAM, 0, "media.sndMode must be auto|manual");
        }
        G.no_audio_device = spc_jbool(media, "noAudioDevice", 0);
    }

    tr = spc_jobj(p, "transports");
    udp = spc_jobj(tr, "udp");
    tcp = spc_jobj(tr, "tcp");
    tls = spc_jobj(tr, "tls");
    if (udp) { udp_en = spc_jbool(udp, "enabled", 1); udp_port = spc_jint(udp, "port", 5060); }
    if (tcp) { tcp_en = spc_jbool(tcp, "enabled", 1); tcp_port = spc_jint(tcp, "port", 5060); }
    if (tls) { tls_en = spc_jbool(tls, "enabled", 1); tls_port = spc_jint(tls, "port", 5061); }
    if (udp_port < 0 || udp_port > 65535 || tcp_port < 0 || tcp_port > 65535 || tls_port < 0 || tls_port > 65535)
        return spc_err(SPC_E_INVALID_PARAM, 0, "invalid transport port");
    G.ipv6 = spc_jbool(tr, "ipv6", 0);
    G.qos = spc_jbool(tr, "qos", 1);

    st = pjsua_create();
    if (st != PJ_SUCCESS) return spc_pjerr(st, "pjsua_create");

    pjsua_config_default(&ucfg);
    ucfg.max_calls = (unsigned)G.max_calls;
    install_callbacks(&ucfg.cb);
    ucfg.user_agent = spc_pjs("");         /* per-request UA is added by the core */
    ucfg.enable_unsolicited_mwi = PJ_TRUE;
    ucfg.hangup_forked_call = PJ_TRUE;
    if (ns_mode == 0) {
        ns_auto_n = spc_dns_detect(ns_auto, PJ_DNS_RESOLVER_MAX_NS);
    }
    {
        cJSON* stun = spc_jarr(p, "stunServers");
        int k = 0;
        if (stun) {
            cJSON* e;
            static char stunbuf[8][128];
            cJSON_ArrayForEach(e, stun) {
                if (cJSON_IsString(e) && e->valuestring[0] && k < 8) {
                    spc_strlcpy(stunbuf[k], e->valuestring, sizeof(stunbuf[k]));
                    ucfg.stun_srv[k] = spc_pjs(stunbuf[k]);
                    k++;
                }
            }
            ucfg.stun_srv_cnt = (unsigned)k;
            if (k) spc_strlcpy(G.stun_server, stunbuf[0], sizeof(G.stun_server));
        }
        ucfg.stun_ignore_failure = spc_jbool(p, "stunIgnoreFailure", 1);
    }

    pjsua_logging_config_default(&lcfg);
    lcfg.msg_logging = PJ_FALSE;
    lcfg.level = (unsigned)log_level;
    lcfg.console_level = (unsigned)log_level;
    lcfg.cb = &pj_log_bridge;
    lcfg.decor = PJ_LOG_HAS_SENDER | PJ_LOG_HAS_TIME | PJ_LOG_HAS_MICRO_SEC | PJ_LOG_HAS_NEWLINE;
    if (logfile[0]) lcfg.log_filename = spc_pjs(logfile);
    g_lcfg = lcfg;

    pjsua_media_config_default(&mcfg);
    mcfg.thread_cnt = 1;
    mcfg.snd_auto_close_time = (G.snd_manual || G.no_audio_device) ? -1 : 1;
    if (media) {
        int v;
        v = spc_jint(media, "clockRate", 0); if (v > 0) mcfg.clock_rate = (unsigned)v;
        v = spc_jint(media, "sndClockRate", 0); if (v > 0) mcfg.snd_clock_rate = (unsigned)v;
        v = spc_jint(media, "channelCount", 1); if (v == 1 || v == 2) mcfg.channel_count = (unsigned)v;
        v = spc_jint(media, "quality", 8); if (v >= 0 && v <= 10) mcfg.quality = (unsigned)v;
        v = spc_jint(media, "ptime", 20); if (v >= 10 && v <= 200) { mcfg.ptime = (unsigned)v; }
        mcfg.no_vad = spc_jbool(media, "vad", 0) ? PJ_FALSE : PJ_TRUE;
        jb = spc_jobj(media, "jb");
        if (jb) {
            mcfg.jb_init = spc_jint(jb, "initMs", -1);
            mcfg.jb_min_pre = spc_jint(jb, "minPreMs", -1);
            mcfg.jb_max_pre = spc_jint(jb, "maxPreMs", -1);
            mcfg.jb_max = spc_jint(jb, "maxMs", -1);
        }
        G.rtp_port = spc_jint(media, "rtpPort", 4000);
        G.rtp_port_range = spc_jint(media, "rtpPortRange", 0);
        ec = spc_jobj(media, "ec");
        if (ec) {
            int tail = spc_jint(ec, "tailMs", 200);
            s = spc_jstr(ec, "algo");
            ec_name = s ? s : "auto";
            {
                int tz = 0;
                unsigned o = spc_ec_options(ec_name, spc_jbool(ec, "ns", 1), spc_jbool(ec, "agc", 0), &tz);
                if (o == 0xFFFFFFFFu) { pjsua_destroy(); return spc_err(SPC_E_INVALID_PARAM, 0, "unknown ec.algo '%s'", ec_name); }
                ec_algo = (int)o;
                if (tail < 0) tail = 0;
                if (tail > 1000) tail = 1000;
                mcfg.ec_tail_len = tz ? 0 : (unsigned)tail;
                G.ec_tail_ms = (int)mcfg.ec_tail_len;
            }
            mcfg.ec_options = (unsigned)ec_algo;
        }
    } else {
        G.rtp_port = 4000;
        G.rtp_port_range = 0;
    }
    if (G.rtp_port < 0 || G.rtp_port > 65535) G.rtp_port = 4000;

    st = pjsua_init(&ucfg, &lcfg, &mcfg);
    if (st != PJ_SUCCESS) { pjsua_destroy(); return spc_pjerr(st, "pjsua_init"); }
    G.clock_rate = (int)mcfg.clock_rate;

    spc_trace_init();
    spc_trace_set(G.sip_trace);
    spc_presence_init_module();

    /* nameservers */
    if (ns_mode == 2) {
        cJSON* e;
        char ns[PJ_DNS_RESOLVER_MAX_NS][64];
        int n = 0;
        cJSON_ArrayForEach(e, ns_list) {
            if (cJSON_IsString(e) && n < PJ_DNS_RESOLVER_MAX_NS) spc_strlcpy(ns[n++], e->valuestring, 64);
        }
        apply_nameservers(ns, n);
    } else if (ns_mode == 0 && ns_auto_n > 0) {
        apply_nameservers(ns_auto, ns_auto_n);
    }

    /* transports */
    tparr = cJSON_CreateArray();
    pjsua_transport_config_default(&tcfg);
    if (G.public_addr[0]) tcfg.public_addr = spc_pjs(G.public_addr);
    if (G.qos) {
        tcfg.qos_type = PJ_QOS_TYPE_CONTROL;
    }
    if (udp_en) {
        tcfg.port = (unsigned)udp_port;
        if (create_tp(PJSIP_TRANSPORT_UDP, &tcfg, 0, &G.udp_tp) != 0) {
            cJSON_Delete(tparr); pjsua_destroy();
            return spc_err(SPC_E_PJ_ERROR, 0, "cannot create UDP transport");
        }
        if (G.ipv6) create_tp(PJSIP_TRANSPORT_UDP6, &tcfg, 1, &G.udp6_tp);
    }
    if (tcp_en) {
        tcfg.port = (unsigned)tcp_port;
        create_tp(PJSIP_TRANSPORT_TCP, &tcfg, 0, &G.tcp_tp);
        if (G.ipv6) create_tp(PJSIP_TRANSPORT_TCP6, &tcfg, 1, &G.tcp6_tp);
    }
    if (tls_en) {
        pjsua_transport_config tl = tcfg;
        const char* ca = spc_jstr(tls, "caFile");
        const char* cert = spc_jstr(tls, "certFile");
        const char* key = spc_jstr(tls, "keyFile");
        const char* mp = spc_jstr(tls, "minProto");
        static char s_ca[512], s_cert[512], s_key[512];
        G.tls_verify = spc_jbool(tls, "verifyServer", 0);
        spc_strlcpy(s_ca, ca ? ca : "", sizeof(s_ca));
        spc_strlcpy(s_cert, cert ? cert : "", sizeof(s_cert));
        spc_strlcpy(s_key, key ? key : "", sizeof(s_key));
        spc_tls_cfg(&tl.tls_setting, G.tls_verify, s_ca, s_cert, s_key, mp);
        tl.port = (unsigned)tls_port;
        create_tp(PJSIP_TRANSPORT_TLS, &tl, 0, &G.tls_tp);
        if (G.ipv6) create_tp(PJSIP_TRANSPORT_TLS6, &tl, 1, &G.tls6_tp);
    }
    if (G.udp_tp < 0 && G.tcp_tp < 0 && G.tls_tp < 0) {
        cJSON_Delete(tparr); pjsua_destroy();
        return spc_err(SPC_E_INVALID_PARAM, 0, "no transport enabled");
    }

    /* sound mode */
    st = spc_media_init();
    if (st != PJ_SUCCESS) { cJSON_Delete(tparr); pjsua_destroy(); return spc_pjerr(st, "media init"); }

    st = pjsua_start();
    if (st != PJ_SUCCESS) { cJSON_Delete(tparr); spc_media_shutdown(); pjsua_destroy(); return spc_pjerr(st, "pjsua_start"); }

    /* direct + lan accounts */
    G.started = 1;
    if (spc_account_init_special(G.udp_tp >= 0 ? G.udp_tp : (G.tcp_tp >= 0 ? G.tcp_tp : G.tls_tp), -1) != 0) {
        G.started = 0;
        cJSON_Delete(tparr); spc_media_shutdown(); pjsua_destroy();
        return spc_err(SPC_E_PJ_ERROR, 0, "cannot create direct account");
    }
    spc_media_started();

    r = cJSON_CreateObject();
    cJSON_AddStringToObject(r, "version", SPC_VERSION);
    cJSON_AddStringToObject(r, "pjsip", PJ_VERSION);
    for (i = 0; i < g_ntps; i++) {
        pjsua_transport_info ti;
        cJSON* t;
        char la[PJ_INET6_ADDRSTRLEN + 16];
        if (pjsua_transport_get_info(g_tps[i].id, &ti) != PJ_SUCCESS) continue;
        t = cJSON_CreateObject();
        cJSON_AddNumberToObject(t, "id", g_tps[i].id);
        {
            char tn[16];
            const char* lower;
            spc_pjcopy(tn, sizeof(tn), &ti.type_name);
            lower = tn;
            { char* c; for (c = tn; *c; c++) *c = (char)((*c >= 'A' && *c <= 'Z') ? *c + 32 : *c); }
            cJSON_AddStringToObject(t, "type", lower);
        }
        snprintf(la, sizeof(la), "%.*s:%d", (int)ti.local_name.host.slen, ti.local_name.host.ptr, (int)ti.local_name.port);
        cJSON_AddStringToObject(t, "local", la);
        cJSON_AddBoolToObject(t, "ipv6", g_tps[i].ipv6);
        cJSON_AddItemToArray(tparr, t);
    }
    cJSON_AddItemToObject(r, "transports", tparr);
    lan = spc_jobj(p, "lan");
    if (lan && spc_jbool(lan, "enabled", 0)) {
        cJSON* lr = cJSON_CreateObject();
        if (spc_lan_start(spc_jint(lan, "port", 0), lr) == 0) cJSON_AddItemToObject(r, "lan", lr);
        else cJSON_Delete(lr);
    }
    {
        cJSON* d = cJSON_AddObjectToObject(r, "direct");
        cJSON_AddNumberToObject(d, "acc", G.direct_acc);
    }
    (void)arr;
    if (G.stats_interval_ms > 0) {
        g_stats_gen++;
        pjsua_schedule_timer2(&stats_timer_cb, (void*)(uintptr_t)g_stats_gen, (unsigned)G.stats_interval_ms);
    }
    {
        cJSON* ev = cJSON_CreateObject();
        cJSON_AddStringToObject(ev, "version", SPC_VERSION);
        spc_emit("core.started", ev);
    }
    *res = r;
    return SPC_OK;
}

/* ------------------------------------------------------------------ */
/* core.stop                                                           */
/* ------------------------------------------------------------------ */
static void do_stop(int graceful)
{
    if (!G.started) return;
    g_stats_gen++;
    if (graceful) spc_account_graceful_unregister(4000);
    spc_call_hangup_all_and_wait(1500);
    spc_media_shutdown();
    spc_trace_set(0);
    spc_lan_stop();
    pjsua_destroy2(0);
    G.started = 0;
    spc_call_cleanup_all();
    spc_presence_cleanup();
    spc_account_cleanup();
    spc_tls_cleanup();
    spc_trace_shutdown();
    g_ntps = 0;
    pj_log_set_log_func(&pj_log_early);
    spc_emit("core.stopped", NULL);
}

static int h_core_stop(cJSON* p, cJSON** res)
{
    (void)res;
    if (!G.started) return SPC_OK;
    do_stop(spc_jbool(p, "graceful", 1));
    return SPC_OK;
}

static int h_core_ping(cJSON* p, cJSON** res) { (void)p; (void)res; return SPC_OK; }

static int h_core_info(cJSON* p, cJSON** res)
{
    cJSON* r = cJSON_CreateObject();
    cJSON* sd;
    char cap[160] = "", play[160] = "";
    (void)p;
    cJSON_AddStringToObject(r, "version", SPC_VERSION);
    cJSON_AddStringToObject(r, "pjsip", PJ_VERSION);
    cJSON_AddBoolToObject(r, "started", G.started);
    if (G.started) {
        cJSON* arr = cJSON_CreateArray();
        int n = 0, i;
        cJSON_AddNumberToObject(r, "calls", spc_calls_active());
        spc_acc_list_json(arr);
        for (i = 0; i < cJSON_GetArraySize(arr); i++) {
            cJSON* a = cJSON_GetArrayItem(arr, i);
            if (!spc_jbool(a, "isLan", 0) && !spc_jbool(a, "isDirect", 0)) n++;
        }
        cJSON_Delete(arr);
        cJSON_AddNumberToObject(r, "accounts", n);
        if (G.nat_type[0]) cJSON_AddStringToObject(r, "natType", G.nat_type);
        cJSON_AddStringToObject(r, "sndMode", G.snd_manual ? "manual" : "auto");
        spc_media_snd_current(cap, sizeof(cap), play, sizeof(play));
        sd = cJSON_AddObjectToObject(r, "soundDevice");
        cJSON_AddStringToObject(sd, "capture", cap);
        cJSON_AddStringToObject(sd, "playback", play);
        cJSON_AddBoolToObject(sd, "open", spc_media_snd_open());
    } else {
        cJSON_AddNumberToObject(r, "calls", 0);
        cJSON_AddNumberToObject(r, "accounts", 0);
        cJSON_AddStringToObject(r, "sndMode", "auto");
        sd = cJSON_AddObjectToObject(r, "soundDevice");
        cJSON_AddStringToObject(sd, "capture", "");
        cJSON_AddStringToObject(sd, "playback", "");
        cJSON_AddBoolToObject(sd, "open", 0);
    }
    *res = r;
    return SPC_OK;
}

static int h_core_snapshot(cJSON* p, cJSON** res)
{
    cJSON* r = cJSON_CreateObject();
    cJSON* a = cJSON_CreateArray();
    cJSON* c = cJSON_CreateArray();
    (void)p;
    spc_acc_list_json(a);
    spc_calls_list_json(c);
    cJSON_AddItemToObject(r, "accounts", a);
    cJSON_AddItemToObject(r, "calls", c);
    cJSON_AddItemToObject(r, "buddies", spc_buddy_list_json());
    cJSON_AddItemToObject(r, "devices", spc_media_devices_json());
    spc_mutex_lock(&G.emit_mtx);
    cJSON_AddNumberToObject(r, "seq", (double)G.seq);
    spc_mutex_unlock(&G.emit_mtx);
    *res = r;
    return SPC_OK;
}

static int h_core_set_log_level(cJSON* p, cJSON** res)
{
    int lvl = spc_jint(p, "level", 3);
    (void)res;
    if (lvl < 0 || lvl > 6) return spc_err(SPC_E_INVALID_PARAM, 0, "level must be 0..6");
    g_lcfg.level = (unsigned)lvl;
    g_lcfg.console_level = (unsigned)lvl;
    pjsua_reconfigure_logging(&g_lcfg);
    pj_log_set_level(lvl);
    G.log_forward = spc_jbool(p, "forward", 0);
    return SPC_OK;
}

static int h_core_set_sip_trace(cJSON* p, cJSON** res)
{
    (void)res;
    if (!spc_jhas(p, "enabled")) return spc_err(SPC_E_INVALID_PARAM, 0, "missing 'enabled'");
    G.sip_trace = spc_jbool(p, "enabled", 0);
    spc_trace_set(G.sip_trace);
    return SPC_OK;
}

static int h_core_handle_ip_change(cJSON* p, cJSON** res)
{
    pjsua_ip_change_param prm;
    pj_status_t st;
    (void)p; (void)res;
    pjsua_ip_change_param_default(&prm);
    st = pjsua_handle_ip_change(&prm);
    if (st != PJ_SUCCESS) return spc_pjerr(st, "pjsua_handle_ip_change");
    return SPC_OK;
}

static int h_core_set_nameservers(cJSON* p, cJSON** res)
{
    cJSON* arr = spc_jarr(p, "servers");
    cJSON* e;
    char ns[PJ_DNS_RESOLVER_MAX_NS][64];
    int n = 0;
    pj_status_t st;
    (void)res;
    if (!arr) return spc_err(SPC_E_INVALID_PARAM, 0, "'servers' must be an array");
    cJSON_ArrayForEach(e, arr) {
        if (!cJSON_IsString(e) || !e->valuestring[0]) return spc_err(SPC_E_INVALID_PARAM, 0, "servers must be strings");
        if (n < PJ_DNS_RESOLVER_MAX_NS) spc_strlcpy(ns[n++], e->valuestring, 64);
    }
    if (n == 0) return SPC_OK;
    st = apply_nameservers(ns, n);
    if (st != PJ_SUCCESS) return spc_pjerr(st, "set nameservers");
    return SPC_OK;
}

static int h_core_set_tls_pins(cJSON* p, cJSON** res)
{
    cJSON* arr = spc_jarr(p, "pins");
    cJSON* e;
    (void)res;
    if (!arr) return spc_err(SPC_E_INVALID_PARAM, 0, "'pins' must be an array");
    cJSON_ArrayForEach(e, arr) {
        if (!spc_jstr(e, "host") || !spc_jstr(e, "sha256")) return spc_err(SPC_E_INVALID_PARAM, 0, "pin needs host and sha256");
    }
    spc_tls_set_pins(arr);
    return SPC_OK;
}

static int h_core_set_user_agent(cJSON* p, cJSON** res)
{
    const char* ua = spc_jstr(p, "userAgent");
    (void)res;
    if (!ua) return spc_err(SPC_E_INVALID_PARAM, 0, "missing 'userAgent'");
    spc_strlcpy(G.user_agent, ua, sizeof(G.user_agent));
    return SPC_OK;
}

const spc_method spc_methods_core[] = {
    { "core.start", h_core_start, SPC_M_PRESTART },
    { "core.stop", h_core_stop, SPC_M_PRESTART },
    { "core.info", h_core_info, SPC_M_PRESTART },
    { "core.snapshot", h_core_snapshot, 0 },
    { "core.ping", h_core_ping, SPC_M_PRESTART },
    { "core.setLogLevel", h_core_set_log_level, 0 },
    { "core.setSipTrace", h_core_set_sip_trace, 0 },
    { "core.handleIpChange", h_core_handle_ip_change, 0 },
    { "core.setNameservers", h_core_set_nameservers, 0 },
    { "core.setTlsPins", h_core_set_tls_pins, 0 },
    { "core.setUserAgent", h_core_set_user_agent, 0 },
    { NULL, NULL, 0 }
};
