/* spc_diag.c: NAT detection, DNS resolve, OPTIONS ping. */
#include "spc_internal.h"

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

typedef struct { volatile int done; pj_status_t status; pj_dns_srv_record rec; } srv_wait;
static void srv_cb(void* user, pj_status_t status, const pj_dns_srv_record* rec)
{
    srv_wait* w = (srv_wait*)user;
    w->status = status;
    if (status == PJ_SUCCESS && rec) w->rec = *rec;
    w->done = 1;
}

static int h_resolve(cJSON* p, cJSON** res)
{
    const char* host = spc_jstr(p, "host");
    const char* tr = spc_jstr(p, "transport");
    int srv = spc_jbool(p, "srv", 0);
    cJSON *addrs, *srvs;
    pj_addrinfo ai[16];
    unsigned cnt = 16, i;
    pj_str_t h;
    pj_status_t st;
    if (!host || !host[0] || strlen(host) > 250) return spc_err(SPC_E_INVALID_PARAM, 0, "'host' required");
    *res = cJSON_CreateObject();
    addrs = cJSON_AddArrayToObject(*res, "addresses");
    srvs = cJSON_AddArrayToObject(*res, "srv");
    h = spc_pjs(host);
    st = pj_getaddrinfo(pj_AF_UNSPEC(), &h, &cnt, ai);
    if (st == PJ_SUCCESS) {
        for (i = 0; i < cnt; i++) {
            char b[PJ_INET6_ADDRSTRLEN + 4];
            pj_sockaddr_print(&ai[i].ai_addr, b, sizeof(b), 0);
            cJSON_AddItemToArray(addrs, cJSON_CreateString(b));
        }
    }
    if (srv) {
        pj_dns_resolver* r = pjsip_endpt_get_resolver(pjsua_get_pjsip_endpt());
        char rn[40];
        srv_wait w;
        pj_str_t rname;
        pj_pool_t* pool;
        int64_t t0;
        if (!r) {
            cJSON_Delete(*res); *res = NULL;
            return spc_err(SPC_E_UNSUPPORTED, 0, "no DNS resolver configured (SRV needs nameservers)");
        }
        memset(&w, 0, sizeof(w));
        snprintf(rn, sizeof(rn), "_sip._%s", tr && tr[0] ? tr : "udp");
        {
            size_t k;
            for (k = 0; rn[k]; k++) if (rn[k] >= 'A' && rn[k] <= 'Z') rn[k] = (char)(rn[k] + 32);
        }
        rname = spc_pjs(rn);
        pool = pjsua_pool_create("spcsrv", 1024, 1024);
        st = pj_dns_srv_resolve(&h, &rname, 5060, pool, r, PJ_DNS_SRV_FALLBACK_A, &w, &srv_cb, NULL);
        if (st == PJ_SUCCESS) {
            t0 = spc_mono_ms();
            while (!w.done && spc_mono_ms() - t0 < 5000) spc_sleep_ms(10);
            if (w.done && w.status == PJ_SUCCESS) {
                for (i = 0; i < w.rec.count; i++) {
                    cJSON* e = cJSON_CreateObject();
                    spc_jadd_pjstr(e, "target", &w.rec.entry[i].server.name);
                    cJSON_AddNumberToObject(e, "port", w.rec.entry[i].port);
                    cJSON_AddNumberToObject(e, "priority", w.rec.entry[i].priority);
                    cJSON_AddNumberToObject(e, "weight", w.rec.entry[i].weight);
                    cJSON_AddItemToArray(srvs, e);
                }
            }
        }
        pj_pool_release(pool);
    }
    return SPC_OK;
}

typedef struct { int acc; char uid[96]; int64_t t0; } opt_tok;
static void opt_cb(void* token, pjsip_event* e)
{
    opt_tok* t = (opt_tok*)token;
    pjsip_transaction* tsx = e->body.tsx_state.tsx;
    cJSON* f;
    if (tsx->state != PJSIP_TSX_STATE_COMPLETED && tsx->state != PJSIP_TSX_STATE_TERMINATED) return;
    if (tsx->state == PJSIP_TSX_STATE_TERMINATED && tsx->status_code == 0) return;
    f = cJSON_CreateObject();
    cJSON_AddNumberToObject(f, "acc", t->acc);
    cJSON_AddStringToObject(f, "uid", t->uid);
    cJSON_AddNumberToObject(f, "code", tsx->status_code);
    spc_jadd_pjstr(f, "reason", &tsx->status_text);
    cJSON_AddNumberToObject(f, "rttMs", (double)(spc_mono_ms() - t->t0));
    spc_emit("diag.options", f);
    free(t);
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
    m = spc_acc_from_id(acc);
    if (target && target[0]) {
        if (spc_uri_normalize(acc, target, dest, sizeof(dest)) != 0) return spc_err(SPC_E_INVALID_PARAM, 0, "invalid target");
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
    tok = (opt_tok*)calloc(1, sizeof(*tok));
    tok->acc = acc;
    spc_strlcpy(tok->uid, m ? m->uid : "", sizeof(tok->uid));
    tok->t0 = spc_mono_ms();
    st = pjsip_endpt_send_request(pjsua_get_pjsip_endpt(), tdata, 10, tok, &opt_cb);
    if (st != PJ_SUCCESS) { free(tok); return spc_pjerr(st, "send OPTIONS"); }
    return SPC_OK;
}

const spc_method spc_methods_diag[] = {
    { "diag.natType", h_nat_type, 0 }, { "diag.resolve", h_resolve, 0 }, { "diag.optionsPing", h_options_ping, 0 },
    { NULL, NULL, 0 }
};
