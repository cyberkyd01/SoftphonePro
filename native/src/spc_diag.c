/* spc_diag.c: NAT detection, DNS resolve (never blocks the worker), OPTIONS ping. */
#include "spc_internal.h"
#if defined(_WIN32)
#  include <winsock2.h>
#  include <ws2tcpip.h>
#else
#  include <sys/types.h>
#  include <sys/socket.h>
#  include <netdb.h>
#endif

static void cb_nat_detect(const pj_stun_nat_detect_result* r)
{
    cJSON* f = cJSON_CreateObject();
    const char* t = "unknown";
    if (r && r->status == PJ_SUCCESS) {
        switch (r->nat_type) {
        case PJ_STUN_NAT_TYPE_OPEN: t = "open"; break;
        case PJ_STUN_NAT_TYPE_BLOCKED: t = "blocked"; break;
        case PJ_STUN_NAT_TYPE_SYMMETRIC_UDP: t = "symmetricUdp"; break;
        case PJ_STUN_NAT_TYPE_FULL_CONE: t = "fullCone"; break;
        case PJ_STUN_NAT_TYPE_SYMMETRIC: t = "symmetric"; break;
        case PJ_STUN_NAT_TYPE_RESTRICTED: t = "restricted"; break;
        case PJ_STUN_NAT_TYPE_PORT_RESTRICTED: t = "portRestricted"; break;
        default: break;
        }
    }
    spc_strlcpy(G.nat_type, t, sizeof(G.nat_type));
    cJSON_AddStringToObject(f, "natType", t);
    cJSON_AddStringToObject(f, "description", r ? r->nat_type_name : "");
    if (r) spc_jadd_str(f, "stun", r->status == PJ_SUCCESS ? G.stun_server : NULL);
    else spc_jadd_str(f, "stun", NULL);
    spc_emit("diag.natType", f);
}

void spc_diag_install_callbacks(pjsua_callback* cb) { cb->on_nat_detect = &cb_nat_detect; }

static int h_nat_type(cJSON* p, cJSON** res)
{
    pj_status_t st;
    (void)p; (void)res;
    st = pjsua_detect_nat_type();
    if (st != PJ_SUCCESS) return spc_pjerr(st, "detect_nat_type");
    return SPC_OK;
}

/* ------------------------------------------------------------------ */
/* diag.resolve: asynchronous. The request is answered from whichever   */
/* of {address helper thread, SRV callback, timeout timer} finishes     */
/* last. The job is reference counted and heap allocated, so neither a  */
/* late DNS callback nor a late helper thread can touch freed memory.   */
/* ------------------------------------------------------------------ */
#define RESOLVE_TIMEOUT_MS 5000

typedef struct resolve_job {
    spc_mutex_t mtx;
    int refs;
    int finished;
    int64_t req_id;
    int want_srv, addr_done, srv_done;
    int session;                         /* engine session the pool belongs to */
    char host[256];
    cJSON* addrs;
    cJSON* srvs;
    pj_pool_t* pool;
    pj_dns_srv_async_query* q;
    int srv_ref_owned;                   /* reference held on behalf of the SRV query; whoever clears it drops it */
} resolve_job;

static int g_session;                    /* bumped on every core.start by spc_diag_session() */
void spc_diag_new_session(void) { g_session++; }

static void job_unref(resolve_job* j)
{
    int refs;
    spc_mutex_lock(&j->mtx);
    refs = --j->refs;
    spc_mutex_unlock(&j->mtx);
    if (refs > 0) return;
    if (j->pool && j->session == g_session && G.started) pj_pool_release(j->pool);   /* pool is gone with a stopped engine */
    if (j->addrs) cJSON_Delete(j->addrs);
    if (j->srvs) cJSON_Delete(j->srvs);
    spc_mutex_destroy(&j->mtx);
    free(j);
}

/* mtx held; sends the response when everything is in (or on timeout) */
static void job_try_finish(resolve_job* j, int timed_out)
{
    cJSON* r;
    if (j->finished) return;
    if (!timed_out && !(j->addr_done && (!j->want_srv || j->srv_done))) return;
    j->finished = 1;
    if (timed_out) {
        spc_respond_deferred(j->req_id, SPC_E_TIMEOUT, 0, "DNS lookup timed out", NULL);
        return;
    }
    r = cJSON_CreateObject();
    cJSON_AddItemToObject(r, "addresses", j->addrs ? j->addrs : cJSON_CreateArray());
    j->addrs = NULL;
    cJSON_AddItemToObject(r, "srv", j->srvs ? j->srvs : cJSON_CreateArray());
    j->srvs = NULL;
    spc_respond_deferred(j->req_id, SPC_OK, 0, NULL, r);
}

static void addr_thread(void* arg)
{
    resolve_job* j = (resolve_job*)arg;
    struct addrinfo hints, *res = NULL, *ai;
    cJSON* arr = cJSON_CreateArray();
    int n = 0;
    memset(&hints, 0, sizeof(hints));
    hints.ai_family = AF_UNSPEC;
    hints.ai_socktype = SOCK_DGRAM;
    if (getaddrinfo(j->host, NULL, &hints, &res) == 0) {
        for (ai = res; ai && n < 16; ai = ai->ai_next) {
            char b[128];
            if (getnameinfo(ai->ai_addr, (socklen_t)ai->ai_addrlen, b, sizeof(b), NULL, 0, NI_NUMERICHOST) == 0) {
                cJSON* it;
                int dup = 0;
                cJSON_ArrayForEach(it, arr) if (strcmp(it->valuestring, b) == 0) dup = 1;
                if (!dup) { cJSON_AddItemToArray(arr, cJSON_CreateString(b)); n++; }
            }
        }
        freeaddrinfo(res);
    }
    spc_mutex_lock(&j->mtx);
    if (j->finished) cJSON_Delete(arr);
    else { j->addrs = arr; j->addr_done = 1; job_try_finish(j, 0); }
    spc_mutex_unlock(&j->mtx);
    job_unref(j);
}

static void srv_cb(void* user, pj_status_t status, const pj_dns_srv_record* rec)
{
    resolve_job* j = (resolve_job*)user;
    int own;
    spc_mutex_lock(&j->mtx);
    own = j->srv_ref_owned;
    j->srv_ref_owned = 0;
    if (!j->finished) {
        unsigned i;
        cJSON* arr = cJSON_CreateArray();
        if (status == PJ_SUCCESS && rec) {
            for (i = 0; i < rec->count; i++) {
                cJSON* e = cJSON_CreateObject();
                spc_jadd_pjstr(e, "target", &rec->entry[i].server.name);
                cJSON_AddNumberToObject(e, "port", rec->entry[i].port);
                cJSON_AddNumberToObject(e, "priority", rec->entry[i].priority);
                cJSON_AddNumberToObject(e, "weight", rec->entry[i].weight);
                cJSON_AddItemToArray(arr, e);
            }
        }
        j->srvs = arr;
        j->srv_done = 1;
        job_try_finish(j, 0);
    }
    j->q = NULL;
    spc_mutex_unlock(&j->mtx);
    if (own) job_unref(j);
}

static void job_timeout(void* ud)
{
    resolve_job* j = (resolve_job*)ud;
    pj_dns_srv_async_query* q = NULL;
    int own = 0;
    spc_mutex_lock(&j->mtx);
    if (!j->finished) {
        job_try_finish(j, 1);
        q = j->q;
        j->q = NULL;
        own = j->srv_ref_owned;
        j->srv_ref_owned = 0;
    }
    spc_mutex_unlock(&j->mtx);
    /* cancel outside our lock (the resolver may be calling srv_cb under its own lock) and before the pool is freed;
     * after cancel the callback is not invoked, hence we drop the query's reference ourselves */
    if (q) pj_dns_srv_cancel_query(q, PJ_FALSE);
    if (own) job_unref(j);
    job_unref(j);                      /* the timer's own reference */
}

static int h_resolve(cJSON* p, cJSON** res)
{
    const char* host = spc_jstr(p, "host");
    const char* tr = spc_jstr(p, "transport");
    int srv = spc_jbool(p, "srv", 0);
    resolve_job* j;
    spc_thread_t th;
    char rn[40];
    pj_str_t h, rname;
    pj_dns_resolver* r = NULL;
    (void)res;
    if (!host || !host[0] || strlen(host) > 250 || !spc_str_clean(host)) return spc_err(SPC_E_INVALID_PARAM, 0, "'host' required");
    if (tr && !(spc_strieq(tr, "udp") || spc_strieq(tr, "tcp") || spc_strieq(tr, "tls"))) return spc_err(SPC_E_INVALID_PARAM, 0, "transport must be udp|tcp|tls");
    if (srv) {
        r = pjsip_endpt_get_resolver(pjsua_get_pjsip_endpt());
        if (!r) return spc_err(SPC_E_UNSUPPORTED, 0, "no DNS resolver configured (SRV needs nameservers)");
    }
    j = (resolve_job*)calloc(1, sizeof(*j));
    if (!j) return spc_err(SPC_E_INTERNAL, 0, "out of memory");
    spc_mutex_init(&j->mtx);
    j->refs = 2;                             /* timer + address thread */
    j->session = g_session;
    j->want_srv = srv;
    j->req_id = spc_defer_response();
    if (!j->req_id) { spc_mutex_destroy(&j->mtx); free(j); return spc_err(SPC_E_BUSY, 0, "too many pending lookups"); }
    spc_strlcpy(j->host, host, sizeof(j->host));
    if (srv) {
        pj_status_t st;
        j->pool = pjsua_pool_create("spcsrv", 1024, 1024);
        snprintf(rn, sizeof(rn), "_sip._%s", tr && tr[0] ? tr : "udp");
        {
            size_t k;
            for (k = 0; rn[k]; k++) if (rn[k] >= 'A' && rn[k] <= 'Z') rn[k] = (char)(rn[k] + 32);
        }
        h = spc_pjs(j->host);
        rname = spc_pjs(rn);
        spc_mutex_lock(&j->mtx);
        j->refs++;                           /* owned by the SRV query */
        j->srv_ref_owned = 1;
        st = pj_dns_srv_resolve(&h, &rname, 5060, j->pool, r, PJ_DNS_SRV_FALLBACK_A, j, &srv_cb, &j->q);
        if (st != PJ_SUCCESS) {
            j->q = NULL;
            j->srv_ref_owned = 0;
            j->refs--;
            j->srv_done = 1;                 /* treat as "no SRV records" */
            j->srvs = cJSON_CreateArray();
        } else if (j->srv_done) {
            j->q = NULL;                     /* callback already ran synchronously */
        }
        spc_mutex_unlock(&j->mtx);
    }
    if (spc_thread_create(&th, addr_thread, j) != 0) {
        /* cannot spawn: answer with an empty address list */
        spc_mutex_lock(&j->mtx);
        j->addrs = cJSON_CreateArray();
        j->addr_done = 1;
        j->refs--;
        job_try_finish(j, 0);
        spc_mutex_unlock(&j->mtx);
    } else {
        spc_thread_detach(&th);
    }
    if (pjsua_schedule_timer2(&job_timeout, j, RESOLVE_TIMEOUT_MS) != PJ_SUCCESS) {
        /* no timer: rely on completion only */
        spc_mutex_lock(&j->mtx);
        j->refs--;
        spc_mutex_unlock(&j->mtx);
    }
    return SPC_OK;
}

/* ------------------------------------------------------------------ */
/* diag.optionsPing                                                    */
/* ------------------------------------------------------------------ */
/* pjsip_endpt_send_request() ignores its timeout argument (PJ_UNUSED_ARG in 2.17), so the ping carries its own 5 s
 * timer. The token is shared by the transaction callback and the timer; whichever reports first wins, the last one
 * to finish frees it. */
#define OPTIONS_TIMEOUT_MS 5000
typedef struct { int acc; char uid[96]; int64_t t0; int done; int refs; } opt_tok;
static spc_mutex_t g_opt_mtx;
static volatile long g_opt_once;
static void opt_init(void) { spc_mutex_init(&g_opt_mtx); }

static void opt_report(opt_tok* t, int code, const pj_str_t* reason)
{
    cJSON* f = cJSON_CreateObject();
    cJSON_AddNumberToObject(f, "acc", t->acc);
    cJSON_AddStringToObject(f, "uid", t->uid);
    cJSON_AddNumberToObject(f, "code", code);
    if (reason) spc_jadd_pjstr(f, "reason", reason);
    else cJSON_AddStringToObject(f, "reason", "Request Timeout");
    cJSON_AddNumberToObject(f, "rttMs", (double)(spc_mono_ms() - t->t0));
    spc_emit("diag.options", f);
}
static void opt_unref(opt_tok* t)      /* g_opt_mtx held */
{
    if (--t->refs <= 0) spc_token_free(t);
}
static void opt_cb(void* token, pjsip_event* e)
{
    opt_tok* t = (opt_tok*)token;
    pjsip_transaction* tsx = e->body.tsx_state.tsx;
    spc_once(&g_opt_once, opt_init);
    if (tsx->state != PJSIP_TSX_STATE_COMPLETED && tsx->state != PJSIP_TSX_STATE_TERMINATED) return;
    spc_mutex_lock(&g_opt_mtx);
    if (!t->done && !(tsx->state == PJSIP_TSX_STATE_TERMINATED && tsx->status_code == 0)) {
        t->done = 1;
        opt_report(t, tsx->status_code, &tsx->status_text);
    }
    if (tsx->state == PJSIP_TSX_STATE_TERMINATED) opt_unref(t);        /* last callback of this transaction */
    spc_mutex_unlock(&g_opt_mtx);
}
static void opt_timeout(void* ud)
{
    opt_tok* t = (opt_tok*)ud;
    spc_once(&g_opt_once, opt_init);
    spc_mutex_lock(&g_opt_mtx);
    if (!t->done) { t->done = 1; opt_report(t, 408, NULL); }
    opt_unref(t);
    spc_mutex_unlock(&g_opt_mtx);
}

static int h_options_ping(cJSON* p, cJSON** res)
{
    int acc, rc;
    const char* target = spc_jstr(p, "target");
    char dest[400], from[300];
    pjsua_acc_info ai;
    pj_pool_t* pool;
    pjsip_tx_data* tdata = NULL;
    pj_str_t d, f, contact;
    pj_status_t st;
    opt_tok* tok;
    spc_acc* m;
    (void)res;
    rc = spc_acc_resolve(p, &acc);
    if (rc) return rc;
    if (acc >= SPC_ID_IAX_BASE) return spc_err(SPC_E_UNSUPPORTED, 0, "OPTIONS ping is SIP only");
    m = spc_acc_from_id(acc);
    if (target && target[0]) {
        if (!spc_str_clean(target) || spc_uri_normalize(acc, target, dest, sizeof(dest)) != 0) return spc_err(SPC_E_INVALID_PARAM, 0, "invalid target");
    } else {
        const char* reg = m && m->cfg ? spc_jstr(m->cfg, "registrar") : NULL;
        if (reg && reg[0]) spc_strlcpy(dest, reg, sizeof(dest));
        else if (m && m->domain[0]) snprintf(dest, sizeof(dest), "sip:%s", m->domain);
        else return spc_err(SPC_E_INVALID_PARAM, 0, "no target");
        if (m && (!strstr(dest, "transport=")) && (strcmp(m->transport, "tcp") == 0 || strcmp(m->transport, "tls") == 0)) {
            strncat(dest, ";transport=", sizeof(dest) - strlen(dest) - 1);
            strncat(dest, m->transport, sizeof(dest) - strlen(dest) - 1);
        }
    }
    if (pjsua_verify_url(dest) != PJ_SUCCESS) return spc_err(SPC_E_INVALID_PARAM, 0, "invalid target");
    if (pjsua_acc_get_info(acc, &ai) != PJ_SUCCESS) return spc_err(SPC_E_NOT_FOUND, 0, "account");
    spc_pjcopy(from, sizeof(from), &ai.acc_uri);
    pool = pjsua_pool_create("spcopt", 1024, 1024);
    d = spc_pjs(dest);
    f = spc_pjs(from);
    st = pjsua_acc_create_uac_contact(pool, &contact, acc, &d);
    if (st != PJ_SUCCESS) { pj_pool_release(pool); return spc_pjerr(st, "contact"); }
    st = pjsip_endpt_create_request(pjsua_get_pjsip_endpt(), &pjsip_options_method, &d, &f, &d, &contact, NULL, -1, NULL, &tdata);
    pj_pool_release(pool);
    if (st != PJ_SUCCESS) return spc_pjerr(st, "create OPTIONS");
    tok = (opt_tok*)spc_token_new(sizeof(*tok));
    if (!tok) { pjsip_tx_data_dec_ref(tdata); return spc_err(SPC_E_INTERNAL, 0, "out of memory"); }
    tok->acc = acc;
    spc_strlcpy(tok->uid, m ? m->uid : "", sizeof(tok->uid));
    tok->t0 = spc_mono_ms();
    tok->refs = 2;                              /* transaction callback + timer */
    st = pjsip_endpt_send_request(pjsua_get_pjsip_endpt(), tdata, -1, tok, &opt_cb);
    if (st != PJ_SUCCESS) { spc_token_free(tok); return spc_pjerr(st, "send OPTIONS"); }
    if (pjsua_schedule_timer2(&opt_timeout, tok, OPTIONS_TIMEOUT_MS) != PJ_SUCCESS) {
        spc_once(&g_opt_once, opt_init);
        spc_mutex_lock(&g_opt_mtx);
        tok->refs--;
        spc_mutex_unlock(&g_opt_mtx);
    }
    return SPC_OK;
}

const spc_method spc_methods_diag[] = {
    { "diag.natType", h_nat_type, 0 }, { "diag.resolve", h_resolve, 0 }, { "diag.optionsPing", h_options_ping, 0 },
    { NULL, NULL, 0 }
};
