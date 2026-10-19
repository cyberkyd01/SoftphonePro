/* spc_account.c: account.* requests, registration state, URI normalisation, per-account codec filter. */
#include "spc_internal.h"
#include "spc_ws_transport.h"
#include <ctype.h>
#include <math.h>

static spc_acc* g_acc[PJSUA_MAX_ACC];
static spc_acc* g_all;               /* every meta ever allocated this session */

/* ------------------------------------------------------------------ */
/* meta lookup                                                         */
/* ------------------------------------------------------------------ */
spc_acc* spc_acc_from_id(int acc)
{
    spc_acc* a = NULL;
    if (acc < 0 || acc >= PJSUA_MAX_ACC) return NULL;
    spc_registry_lock();
    a = g_acc[acc];
    spc_registry_unlock();
    if (!a && pjsua_acc_is_valid(acc)) a = (spc_acc*)pjsua_acc_get_user_data(acc);
    return a;
}

static spc_acc* meta_alloc(void)
{
    spc_acc* a = (spc_acc*)calloc(1, sizeof(*a));
    if (!a) return NULL;
    a->acc = -1;
    a->own_tp = -1;
    spc_strlcpy(a->reg_state, "none", sizeof(a->reg_state));
    spc_strlcpy(a->presence, "online", sizeof(a->presence));
    spc_strlcpy(a->transport, "udp", sizeof(a->transport));
    spc_strlcpy(a->dtmf_method, "rfc2833", sizeof(a->dtmf_method));
    spc_registry_lock();
    a->next = g_all;
    g_all = a;
    spc_registry_unlock();
    return a;
}

int spc_acc_resolve(const cJSON* p, int* out)
{
    const char* uid = spc_jstr(p, "uid");
    cJSON* ac = cJSON_GetObjectItemCaseSensitive((cJSON*)p, "acc");
    int i;
    if (ac && cJSON_IsNumber(ac)) {
        int id;
        if (!(ac->valuedouble >= -1.0 && ac->valuedouble <= 1048576.0) || ac->valuedouble != floor(ac->valuedouble))
            return spc_err(SPC_E_INVALID_PARAM, 0, "'acc' must be an integer");
        id = (int)ac->valuedouble;
        if (id == -1) {
            if (G.direct_acc < 0) return spc_err(SPC_E_NOT_FOUND, 0, "no direct account");
            *out = G.direct_acc;
            return SPC_OK;
        }
        if (id >= SPC_ID_IAX_BASE) {
            if (!spc_iax2_acc_valid(id)) return spc_err(SPC_E_NOT_FOUND, 0, "account %d not found", id);
            *out = id;
            return SPC_OK;
        }
        if (id < 0 || id >= PJSUA_MAX_ACC || !pjsua_acc_is_valid(id) || !spc_acc_from_id(id))
            return spc_err(SPC_E_NOT_FOUND, 0, "account %d not found", id);
        *out = id;
        return SPC_OK;
    }
    if (uid && uid[0]) {
        if (spc_iax2_acc_find_uid(uid, out) == 0) return SPC_OK;
        spc_registry_lock();
        for (i = 0; i < PJSUA_MAX_ACC; i++) {
            if (g_acc[i] && g_acc[i]->used && strcmp(g_acc[i]->uid, uid) == 0) {
                *out = i;
                spc_registry_unlock();
                return SPC_OK;
            }
        }
        spc_registry_unlock();
        return spc_err(SPC_E_NOT_FOUND, 0, "account uid '%s' not found", uid);
    }
    return spc_err(SPC_E_INVALID_PARAM, 0, "'acc' or 'uid' required");
}

/* ------------------------------------------------------------------ */
/* AccountInfo                                                         */
/* ------------------------------------------------------------------ */
cJSON* spc_acc_info_json(int acc)
{
    pjsua_acc_info ai;
    spc_acc* m = spc_acc_from_id(acc);
    cJSON* o;
    char state[16], reason[96], lerr[200], pres[12], tr[8], uid[96];
    int code, proto, lan, direct;
    if (acc >= SPC_ID_IAX_BASE) return spc_iax2_acc_info_json(acc);
    if (!m || pjsua_acc_get_info(acc, &ai) != PJ_SUCCESS) return NULL;
    spc_registry_lock();
    spc_strlcpy(state, m->reg_state, sizeof(state));
    spc_strlcpy(reason, m->reg_reason, sizeof(reason));
    spc_strlcpy(lerr, m->last_error, sizeof(lerr));
    spc_strlcpy(pres, m->presence, sizeof(pres));
    spc_strlcpy(tr, m->transport, sizeof(tr));
    spc_strlcpy(uid, m->uid, sizeof(uid));
    code = m->reg_code;
    proto = m->proto;
    lan = m->is_lan;
    direct = m->is_direct;
    spc_registry_unlock();
    o = cJSON_CreateObject();
    cJSON_AddNumberToObject(o, "acc", acc);
    cJSON_AddStringToObject(o, "uid", uid);
    cJSON_AddStringToObject(o, "proto", proto ? "iax2" : "sip");
    spc_jadd_pjstr(o, "uri", &ai.acc_uri);
    cJSON_AddStringToObject(o, "regState", state);
    cJSON_AddNumberToObject(o, "regCode", code);
    cJSON_AddStringToObject(o, "regReason", reason);
    cJSON_AddNumberToObject(o, "status", (double)ai.status);
    spc_jadd_pjstr(o, "statusText", &ai.status_text);
    spc_jadd_str(o, "lastError", lerr[0] ? lerr : NULL);
    cJSON_AddNumberToObject(o, "expires", (ai.has_registration && strcmp(state, "registered") == 0) ? (double)ai.expires : 0);
    cJSON_AddBoolToObject(o, "online", strcmp(pres, "offline") != 0);
    cJSON_AddBoolToObject(o, "isUnreg", strcmp(state, "unregistered") == 0);
    if (strcmp(state, "registered") == 0 && !lan && !direct) {
        pj_pool_t* pool = pjsua_pool_create("spcct", 512, 512);
        pj_str_t contact;
        pj_str_t reg;
        pj_str_t uri = ai.acc_uri;
        (void)reg;
        if (pool) {
            /* contact as the registrar sees it */
            if (pjsua_acc_create_uac_contact(pool, &contact, acc, &uri) == PJ_SUCCESS) {
                char tmp[256];
                snprintf(tmp, sizeof(tmp), "%.*s", (int)contact.slen, contact.ptr);
                cJSON_AddStringToObject(o, "contact", tmp);
            } else {
                cJSON_AddNullToObject(o, "contact");
            }
            pj_pool_release(pool);
        } else {
            cJSON_AddNullToObject(o, "contact");
        }
    } else {
        cJSON_AddNullToObject(o, "contact");
    }
    cJSON_AddStringToObject(o, "transport", tr);
    cJSON_AddStringToObject(o, "presence", pres);
    cJSON_AddBoolToObject(o, "isLan", lan);
    cJSON_AddBoolToObject(o, "isDirect", direct);
    return o;
}

int spc_acc_list_json(cJSON* arr)
{
    int i, n = 0;
    for (i = 0; i < PJSUA_MAX_ACC; i++) {
        cJSON* o;
        if (!pjsua_acc_is_valid(i)) continue;
        o = spc_acc_info_json(i);
        if (o) { cJSON_AddItemToArray(arr, o); n++; }
    }
    spc_iax2_acc_list_json(arr);
    return n;
}

static void emit_acc_reg(int acc)
{
    cJSON* o = spc_acc_info_json(acc);
    if (o) spc_emit("account.reg", o);
}

/* ------------------------------------------------------------------ */
/* pjsua callbacks                                                     */
/* ------------------------------------------------------------------ */
static void cb_reg_started2(pjsua_acc_id acc, pjsua_reg_info* info)
{
    spc_acc* m = spc_acc_from_id(acc);
    if (!m || !info) return;
    spc_registry_lock();
    spc_strlcpy(m->reg_state, info->renew ? "registering" : "unregistering", sizeof(m->reg_state));
    spc_registry_unlock();
    emit_acc_reg(acc);
}

static void cb_reg_state2(pjsua_acc_id acc, pjsua_reg_info* info)
{
    spc_acc* m = spc_acc_from_id(acc);
    struct pjsip_regc_cbparam* cp;
    char reason[96];
    char err[200];
    const char* state;
    int code;
    if (!m || !info || !info->cbparam) return;
    cp = info->cbparam;
    spc_pjcopy(reason, sizeof(reason), &cp->reason);
    code = cp->code;
    err[0] = 0;
    if (code / 100 == 2 && cp->status == PJ_SUCCESS) {
        state = cp->expiration > 0 ? "registered" : "unregistered";
    } else {
        char em[160];
        char host_only[128];
        state = "failed";
        spc_strlcpy(host_only, m->domain, sizeof(host_only));
        if (host_only[0] != '[') { char* cc = strchr(host_only, ':'); if (cc && strchr(cc + 1, ':') == NULL) *cc = 0; }
        pj_strerror(cp->status, em, sizeof(em));
        if (code == 401 || code == 403 || code == 407)
            snprintf(err, sizeof(err), "Wrong username/password (%d)", code);
        else if (code == 408)
            snprintf(err, sizeof(err), "Timeout (408)");
        else if (spc_tls_recent_failure(host_only) && (strcmp(m->transport, "tls") == 0 || strcmp(m->transport, "wss") == 0))
            snprintf(err, sizeof(err), "TLS certificate not trusted");
        else if (cp->status == PJ_ERESOLVE || strstr(em, "DNS") || strstr(em, "resolve") || strstr(em, "Resolve"))
            snprintf(err, sizeof(err), "DNS lookup failed");
        else if (cp->status != PJ_SUCCESS)
            snprintf(err, sizeof(err), "%s (%d)", em, code);
        else
            snprintf(err, sizeof(err), "%s (%d)", reason[0] ? reason : "Registration failed", code);
    }
    spc_registry_lock();
    spc_strlcpy(m->reg_state, state, sizeof(m->reg_state));
    m->reg_code = code;
    spc_strlcpy(m->reg_reason, reason, sizeof(m->reg_reason));
    spc_strlcpy(m->last_error, err, sizeof(m->last_error));
    spc_registry_unlock();
    emit_acc_reg(acc);
}

void spc_account_install_callbacks(pjsua_callback* cb)
{
    cb->on_reg_started2 = &cb_reg_started2;
    cb->on_reg_state2 = &cb_reg_state2;
}

/* ------------------------------------------------------------------ */
/* URI normalisation                                                   */
/* ------------------------------------------------------------------ */
int spc_uri_normalize(int acc, const char* in, char* out, size_t outsz)
{
    spc_acc* m = spc_acc_from_id(acc);
    char buf[512];
    char transport[8] = "udp";
    char domain[128] = "";
    int direct = 0;
    if (!in || !in[0] || strlen(in) > 400) return -1;
    if (m) {
        spc_registry_lock();
        spc_strlcpy(transport, m->transport, sizeof(transport));
        spc_strlcpy(domain, m->domain, sizeof(domain));
        direct = m->is_direct || m->is_lan;
        spc_registry_unlock();
    }
    if (spc_strnieq(in, "sip:", 4) || spc_strnieq(in, "sips:", 5) || spc_strnieq(in, "tel:", 4)) {
        spc_strlcpy(buf, in, sizeof(buf));
    } else if (strchr(in, '@')) {
        snprintf(buf, sizeof(buf), "sip:%s", in);
    } else if (direct || !domain[0]) {
        snprintf(buf, sizeof(buf), "sip:%s", in);
    } else {
        snprintf(buf, sizeof(buf), "sip:%s@%s", in, domain);
    }
    if (!spc_strnieq(buf, "tel:", 4) && !strstr(buf, "transport=") && !strstr(buf, "TRANSPORT=")) {
        if (strcmp(transport, "tcp") == 0 || strcmp(transport, "tls") == 0 ||
            strcmp(transport, "ws") == 0 || strcmp(transport, "wss") == 0) {
            if (strlen(buf) + 16 < sizeof(buf)) strcat(buf, ";transport="), strcat(buf, transport);
        }
    }
    spc_strlcpy(out, buf, outsz);
    return 0;
}

/* ------------------------------------------------------------------ */
/* config building                                                     */
/* ------------------------------------------------------------------ */
static int map_ipv6(const char* s)
{
    if (!s) return PJSUA_IPV6_DISABLED;
    if (spc_strieq(s, "enabled")) return PJSUA_IPV6_ENABLED;
    if (spc_strieq(s, "preferIpv4")) return PJSUA_IPV6_ENABLED_PREFER_IPV4;
    if (spc_strieq(s, "preferIpv6")) return PJSUA_IPV6_ENABLED_PREFER_IPV6;
    return PJSUA_IPV6_DISABLED;
}

static void add_hdr(pj_pool_t* pool, pjsip_hdr* list, const char* name, const char* val)
{
    pj_str_t n, v;
    pjsip_generic_string_hdr* h;
    pj_strdup2_with_null(pool, &n, name);
    pj_strdup2_with_null(pool, &v, val);
    h = pjsip_generic_string_hdr_create(pool, &n, &v);
    if (h) pj_list_push_back(list, (pjsip_hdr*)h);
}

/* dscp.sip of an account JSON (default 24), -1 if out of range */
static int acc_sip_dscp(const cJSON* c)
{
    int v = 24;
    cJSON* obj = spc_jobj(c, "dscp");
    if (obj && !spc_jint_range(obj, "sip", 24, 0, 63, &v)) return -1;
    return v;
}

/* Per-account SIP DSCP: an account with its own transport (localPort > 0) owns that socket outright. Accounts on
 * the shared UDP transport re-mark it (last add/modify wins); shared TCP/TLS/WS use transports.dscpSip. */
static void apply_sip_dscp(spc_acc* m, const cJSON* c, int tp_id)
{
    int d = acc_sip_dscp(c);
    const char* tr = spc_jstr(c, "transport");
    if (d < 0 || !G.qos) return;
    if (tp_id >= 0) { spc_udp_set_dscp(tp_id, d); return; }
    (void)m;
    if (!tr || spc_strieq(tr, "udp")) spc_udp_set_dscp(G.udp_tp, d);
}

static int ensure_own_tp(spc_acc* m, const cJSON* c, int* tp_id, char* err, size_t errn)
{
    int port = 0;
    const char* tr = spc_jstr(c, "transport");
    pjsua_transport_config tc;
    pjsip_transport_type_e type = PJSIP_TRANSPORT_UDP;
    pjsua_transport_id id;
    pjsua_transport_info ti;
    if (!spc_jint_range(c, "localPort", 0, 0, 65535, &port)) { snprintf(err, errn, "'localPort' must be an integer in 0..65535"); return -1; }
    if (port <= 0 || (tr && (spc_strieq(tr, "ws") || spc_strieq(tr, "wss")))) {   /* ws/wss: outgoing connections only */
        if (m->own_tp >= 0) { pjsua_transport_close(m->own_tp, PJ_FALSE); m->own_tp = -1; }
        *tp_id = PJSUA_INVALID_ID;
        return 0;
    }
    if (port > 65535) { snprintf(err, errn, "invalid localPort"); return -1; }
    if (m->own_tp >= 0 && pjsua_transport_get_info(m->own_tp, &ti) == PJ_SUCCESS && (int)ti.local_name.port == port) {
        *tp_id = m->own_tp;
        return 0;
    }
    if (m->own_tp >= 0) { pjsua_transport_close(m->own_tp, PJ_FALSE); m->own_tp = -1; }
    pjsua_transport_config_default(&tc);
    tc.port = (unsigned)port;
    if (G.qos) {
        int d = acc_sip_dscp(c);
        tc.qos_type = PJ_QOS_TYPE_CONTROL;
        tc.qos_params.flags = PJ_QOS_PARAM_HAS_DSCP;
        tc.qos_params.dscp_val = (pj_uint8_t)((d < 0 ? 24 : d) & 0x3f);
    }
    if (tr && spc_strieq(tr, "tcp")) type = PJSIP_TRANSPORT_TCP;
    else if (tr && spc_strieq(tr, "tls")) {
        type = PJSIP_TRANSPORT_TLS;
        spc_tls_cfg(&tc.tls_setting, G.tls_verify, NULL, NULL, NULL, NULL);
    }
    if (pjsua_transport_create(type, &tc, &id) != PJ_SUCCESS) {
        snprintf(err, errn, "cannot bind local port %d", port);
        return -1;
    }
    m->own_tp = id;
    spc_udp_set_dscp(id, acc_sip_dscp(c) < 0 ? 24 : acc_sip_dscp(c));
    *tp_id = id;
    return 0;
}

/* SIP over WebSocket (RFC 7118): registrar URI with explicit port, "<token>.invalid" Contact, no NAT rewriting
 * (the server routes back over the WebSocket connection), no UDP keep-alive (the transport pings). */
static int apply_ws(pjsua_acc_config* cfg, pj_pool_t* pool, const cJSON* c, const char* user, const char* domain,
                    const char* registrar, int wss, char* err, size_t errn)
{
    const char* path = spc_jstr(c, "wsPath");
    char reg[400], hp[200], host[160], contact[300], rest[200];
    const char* p;
    const char* semi;
    char* colon;
    int port, n;
    if (!path || !path[0]) path = "/ws";
    if (path[0] != '/' || strlen(path) > 120) { snprintf(err, errn, "invalid wsPath"); return -1; }
    for (p = path; *p; p++) if ((unsigned char)*p <= ' ' || *p == 0x7f) { snprintf(err, errn, "invalid wsPath"); return -1; }
    if (registrar && registrar[0]) spc_strlcpy(reg, registrar, sizeof(reg));
    else snprintf(reg, sizeof(reg), "sip:%s", domain);
    p = reg;
    if (spc_strnieq(p, "sips:", 5)) p += 5; else if (spc_strnieq(p, "sip:", 4)) p += 4;
    semi = strchr(p, ';');
    n = semi ? (int)(semi - p) : (int)strlen(p);
    if (n <= 0 || n >= (int)sizeof(host)) { snprintf(err, errn, "invalid registrar"); return -1; }
    memcpy(host, p, (size_t)n); host[n] = 0;
    spc_strlcpy(rest, semi ? semi : "", sizeof(rest));
    spc_ws_ensure_port(host, wss, hp, sizeof(hp));
    snprintf(reg, sizeof(reg), "sip:%.199s%.150s", hp, rest);
    if (!strstr(reg, "transport=") && !strstr(reg, "TRANSPORT=")) {
        if (strlen(reg) + 16 < sizeof(reg)) strcat(reg, wss ? ";transport=wss" : ";transport=ws");
    }
    pj_strdup2_with_null(pool, &cfg->reg_uri, reg);
    /* route registry: path for connections to host:port */
    if (hp[0] == '[') { char* rb = strchr(hp, ']'); n = rb ? (int)(rb - hp) - 1 : 0; memcpy(host, hp + 1, (size_t)n); host[n] = 0; colon = rb ? strchr(rb, ':') : NULL; }
    else { colon = strrchr(hp, ':'); n = colon ? (int)(colon - hp) : (int)strlen(hp); memcpy(host, hp, (size_t)n); host[n] = 0; }
    port = colon ? atoi(colon + 1) : (wss ? 443 : 80);
    spc_ws_route_set(host, port, wss, path);
    {   char inv[40];
        spc_ws_random_invalid_host(inv, sizeof(inv));
        snprintf(contact, sizeof(contact), "<sip:%s@%s;transport=%s>", user, inv, wss ? "wss" : "ws");
        pj_strdup2_with_null(pool, &cfg->force_contact, contact);
    }
    /* all requests of the account go to the server over the WebSocket: loose-route through the server URI
     * (explicit port, so no SRV lookup for a transport that has no SRV convention here) */
    if (cfg->proxy_cnt == 0) {
        char px[240];
        snprintf(px, sizeof(px), "<sip:%s;transport=%s;lr>", hp, wss ? "wss" : "ws");
        pj_strdup2_with_null(pool, &cfg->proxy[cfg->proxy_cnt++], px);
    }
    if (!spc_jhas(c, "regUseProxy")) cfg->reg_use_proxy = 0;
    cfg->allow_contact_rewrite = PJ_FALSE;
    cfg->allow_via_rewrite = PJ_FALSE;
    cfg->use_rfc5626 = 0;
    cfg->ka_interval = 0;
    return 0;
}

static int build_cfg(spc_acc* m, const cJSON* c, pjsua_acc_config* cfg, pj_pool_t* pool, char* err, size_t errn)
{
    const char* s;
    const char* user = spc_jstr(c, "username");
    const char* domain = spc_jstr(c, "domain");
    const char* disp = spc_jstr(c, "displayName");
    const char* transport = spc_jstr(c, "transport");
    const char* registrar = spc_jstr(c, "registrar");
    const char* pass = spc_jstr(c, "password");
    const char* authu = spc_jstr(c, "authUser");
    char id[600], reg[400];
    char dname[128];
    cJSON *arr, *e, *obj;
    int i, v;
    char ua[160];

    if (!user || !user[0]) { snprintf(err, errn, "'username' required"); return -1; }
    if (!domain || !domain[0]) { snprintf(err, errn, "'domain' required"); return -1; }
    if (strlen(user) > 100 || strlen(domain) > 120) { snprintf(err, errn, "username/domain too long"); return -1; }
    if (!spc_str_clean(user) || !spc_str_clean(domain) || !spc_str_clean(disp) || !spc_str_clean(registrar) ||
        !spc_str_clean(authu) || !spc_str_clean(spc_jstr(c, "callerId")) || strpbrk(user, "@<>;\" ") || strpbrk(domain, "<>;\" @")) {
        snprintf(err, errn, "username, domain, displayName, registrar, authUser or callerId contain invalid characters");
        return -1;
    }
    if (spc_jstr(c, "userAgent") && !spc_hdr_value_ok(spc_jstr(c, "userAgent"))) { snprintf(err, errn, "invalid userAgent"); return -1; }
    if (!transport) transport = "udp";
    if (!(spc_strieq(transport, "udp") || spc_strieq(transport, "tcp") || spc_strieq(transport, "tls") ||
          spc_strieq(transport, "ws") || spc_strieq(transport, "wss") || spc_strieq(transport, "auto"))) {
        snprintf(err, errn, "invalid transport '%s'", transport);
        return -1;
    }
    pjsua_acc_config_default(cfg);
    cfg->user_data = m;

    dname[0] = 0;
    if (disp && disp[0]) {
        size_t k, j = 0;
        for (k = 0; disp[k] && j < sizeof(dname) - 1; k++) dname[j++] = disp[k] == '"' ? '\'' : disp[k];
        dname[j] = 0;
    }
    if (dname[0]) snprintf(id, sizeof(id), "\"%s\" <sip:%s@%s>", dname, user, domain);
    else snprintf(id, sizeof(id), "<sip:%s@%s>", user, domain);
    pj_strdup2_with_null(pool, &cfg->id, id);

    if (registrar && registrar[0]) spc_strlcpy(reg, registrar, sizeof(reg));
    else snprintf(reg, sizeof(reg), "sip:%s", domain);
    if (!strstr(reg, "transport=")) {
        if (spc_strieq(transport, "tcp")) strcat(reg, ";transport=tcp");
        else if (spc_strieq(transport, "tls")) strcat(reg, ";transport=tls");
    }
    pj_strdup2_with_null(pool, &cfg->reg_uri, reg);

    if (pass) {
        cfg->cred_count = 1;
        cfg->cred_info[0].realm = spc_pjs("*");
        cfg->cred_info[0].scheme = spc_pjs("digest");
        pj_strdup2_with_null(pool, &cfg->cred_info[0].username, (authu && authu[0]) ? authu : user);
        cfg->cred_info[0].data_type = PJSIP_CRED_DATA_PLAIN_PASSWD;
        pj_strdup2_with_null(pool, &cfg->cred_info[0].data, pass);
    }
    arr = spc_jarr(c, "proxies");
    if (arr) {
        cJSON_ArrayForEach(e, arr) {
            if (cJSON_IsString(e) && e->valuestring[0] && cfg->proxy_cnt < PJSUA_ACC_MAX_PROXIES)
                pj_strdup2_with_null(pool, &cfg->proxy[cfg->proxy_cnt++], e->valuestring);
        }
    }
#define RNG(k, def, lo, hi, var) do { if (!spc_jint_range(c, k, def, lo, hi, &(var))) { snprintf(err, errn, "'%s' must be an integer in %d..%d", k, lo, hi); return -1; } } while (0)
    {
        int n1, n2, n3, n4, n5, n6;
        RNG("regUseProxy", 3, 0, 3, n1);
        cfg->reg_use_proxy = (unsigned)n1;
        RNG("regExpires", 300, 10, 86400, n2);
        cfg->reg_timeout = (unsigned)n2;
        RNG("regRetrySec", 30, 0, 86400, n3);
        cfg->reg_retry_interval = (unsigned)n3;
        RNG("regFirstRetrySec", 5, 0, 86400, n4);
        cfg->reg_first_retry_interval = (unsigned)n4;
        RNG("regRetryRandomSec", 10, 0, 3600, n5);
        cfg->reg_retry_random_interval = (unsigned)n5;
        RNG("regDelayBeforeRefreshSec", 5, 0, 3600, n6);
        cfg->reg_delay_before_refresh = (unsigned)n6;
        RNG("unregTimeoutMs", 4000, 0, 60000, n1);
        cfg->unreg_timeout = (unsigned)n1;
        RNG("keepAliveSec", 15, 0, 3600, n2);
        cfg->ka_interval = (unsigned)n2;
        RNG("mwiExpires", 3600, 0, 86400, n3);
        cfg->mwi_expires = (unsigned)n3;
        RNG("srtpSecureSignaling", 0, 0, 2, n4);
        cfg->srtp_secure_signaling = n4;
    }
    cfg->register_on_acc_add = spc_jbool(c, "register", 1) ? PJ_TRUE : PJ_FALSE;
    cfg->drop_calls_on_reg_fail = spc_jbool(c, "dropCallsOnRegFail", 0);
    cfg->contact_use_src_port = spc_jbool(c, "contactUseSrcPort", 1);
    cfg->publish_enabled = spc_jbool(c, "publishPresence", 0);
    cfg->mwi_enabled = spc_jbool(c, "mwi", 1);

    s = spc_jstr(c, "srtp");
    cfg->use_srtp = PJMEDIA_SRTP_DISABLED;
    if (s) {
        if (spc_strieq(s, "optional")) cfg->use_srtp = PJMEDIA_SRTP_OPTIONAL;
        else if (spc_strieq(s, "mandatory")) cfg->use_srtp = PJMEDIA_SRTP_MANDATORY;
        else if (!spc_strieq(s, "off")) { snprintf(err, errn, "invalid srtp '%s'", s); return -1; }
    }
    arr = spc_jarr(c, "srtpKeying");
    if (arr) {
        cJSON_ArrayForEach(e, arr) {
            if (!cJSON_IsString(e)) continue;
            if (cfg->srtp_opt.keying_count < PJMEDIA_SRTP_KEYINGS_COUNT) {
                if (spc_strieq(e->valuestring, "sdes")) cfg->srtp_opt.keying[cfg->srtp_opt.keying_count++] = PJMEDIA_SRTP_KEYING_SDES;
                else if (spc_strieq(e->valuestring, "dtls")) cfg->srtp_opt.keying[cfg->srtp_opt.keying_count++] = PJMEDIA_SRTP_KEYING_DTLS_SRTP;
            }
        }
    }
    arr = spc_jarr(c, "srtpCryptos");
    if (arr) {
        cJSON_ArrayForEach(e, arr) {
            if (cJSON_IsString(e) && cfg->srtp_opt.crypto_count < PJMEDIA_SRTP_MAX_CRYPTOS) {
                pj_strdup2_with_null(pool, &cfg->srtp_opt.crypto[cfg->srtp_opt.crypto_count].name, e->valuestring);
                cfg->srtp_opt.crypto_count++;
            }
        }
    }

    /* ICE / TURN / STUN */
    {
        pjsua_media_config mc;
        pjsua_media_config_default(&mc);
        pjsua_ice_config_from_media_config(pool, &cfg->ice_cfg, &mc);
        pjsua_turn_config_from_media_config(pool, &cfg->turn_cfg, &mc);
    }
    cfg->ice_cfg_use = PJSUA_ICE_CONFIG_USE_CUSTOM;
    cfg->ice_cfg.enable_ice = spc_jbool(c, "ice", 0);
    cfg->enable_rtcp_mux = spc_jbool(c, "rtcpMux", 0);
    if (spc_jbool(c, "rtcpFb", 0)) {            /* offer RTP/AVPF (SAVPF/UDP-TLS-RTP-SAVPF) with a=rtcp-fb:* nack, as WebRTC peers expect */
        cfg->rtcp_fb_cfg.dont_use_avpf = PJ_FALSE;
        cfg->rtcp_fb_cfg.cap_count = 1;
        cfg->rtcp_fb_cfg.caps[0].codec_id = pj_str((char*)"*");
        cfg->rtcp_fb_cfg.caps[0].type = PJMEDIA_RTCP_FB_NACK;
    }
    obj = spc_jobj(c, "turn");
    cfg->turn_cfg_use = PJSUA_TURN_CONFIG_USE_CUSTOM;
    cfg->turn_cfg.enable_turn = PJ_FALSE;
    if (obj && spc_jbool(obj, "enabled", 0)) {
        const char* srv = spc_jstr(obj, "server");
        if (srv && srv[0]) {
            const char* tt = spc_jstr(obj, "transport");
            cfg->turn_cfg.enable_turn = PJ_TRUE;
            pj_strdup2_with_null(pool, &cfg->turn_cfg.turn_server, srv);
            cfg->turn_cfg.turn_conn_type = (tt && spc_strieq(tt, "tcp")) ? PJ_TURN_TP_TCP : (tt && spc_strieq(tt, "tls")) ? PJ_TURN_TP_TLS : PJ_TURN_TP_UDP;
            cfg->turn_cfg.turn_auth_cred.type = PJ_STUN_AUTH_CRED_STATIC;
            pj_strdup2_with_null(pool, &cfg->turn_cfg.turn_auth_cred.data.static_cred.realm, "*");
            pj_strdup2_with_null(pool, &cfg->turn_cfg.turn_auth_cred.data.static_cred.username, spc_jstr(obj, "username") ? spc_jstr(obj, "username") : "");
            cfg->turn_cfg.turn_auth_cred.data.static_cred.data_type = PJ_STUN_PASSWD_PLAIN;
            pj_strdup2_with_null(pool, &cfg->turn_cfg.turn_auth_cred.data.static_cred.data, spc_jstr(obj, "password") ? spc_jstr(obj, "password") : "");
        }
    }
    {
        int stun = spc_jbool(c, "useStun", 1);
        cfg->sip_stun_use = stun ? PJSUA_STUN_USE_DEFAULT : PJSUA_STUN_USE_DISABLED;
        cfg->media_stun_use = stun ? PJSUA_STUN_USE_DEFAULT : PJSUA_STUN_USE_DISABLED;
    }
    cfg->allow_contact_rewrite = spc_jbool(c, "contactRewrite", 1);
    cfg->allow_via_rewrite = spc_jbool(c, "viaRewrite", 1);
    cfg->allow_sdp_nat_rewrite = spc_jbool(c, "sdpNatRewrite", 0);
    cfg->use_rfc5626 = spc_jbool(c, "sipOutbound", 0) ? 1 : 0;

    s = spc_jstr(c, "sessionTimers");
    cfg->use_timer = PJSUA_SIP_TIMER_OPTIONAL;
    if (s) {
        if (spc_strieq(s, "off")) cfg->use_timer = PJSUA_SIP_TIMER_INACTIVE;
        else if (spc_strieq(s, "required")) cfg->use_timer = PJSUA_SIP_TIMER_REQUIRED;
        else if (spc_strieq(s, "always")) cfg->use_timer = PJSUA_SIP_TIMER_ALWAYS;
        else if (!spc_strieq(s, "optional")) { snprintf(err, errn, "invalid sessionTimers '%s'", s); return -1; }
    }
    RNG("timerSe", 1800, 90, 86400, v);
    cfg->timer_setting.sess_expires = (unsigned)v;
    cfg->require_100rel = spc_jbool(c, "use100rel", 0) ? PJSUA_100REL_OPTIONAL : PJSUA_100REL_NOT_USED;
    s = spc_jstr(c, "holdType");
    cfg->call_hold_type = (s && spc_strieq(s, "rfc2543")) ? PJSUA_CALL_HOLD_TYPE_RFC2543 : PJSUA_CALL_HOLD_TYPE_RFC3264;
    cfg->lock_codec = spc_jbool(c, "lockCodec", 1) ? 1 : 0;
#if defined(PJMEDIA_STREAM_ENABLE_KA) && (PJMEDIA_STREAM_ENABLE_KA != 0)
    cfg->use_stream_ka = spc_jbool(c, "streamKeepAlive", 1);
#endif
    s = spc_jstr(c, "authAlgorithm");
    if (s && spc_strieq(s, "md5")) cfg->auth_pref.algorithm = spc_pjs("MD5");
    else if (s && spc_strieq(s, "sha256")) cfg->auth_pref.algorithm = spc_pjs("SHA-256");
    cfg->ipv6_sip_use = (pjsua_ipv6_use)map_ipv6(spc_jstr(c, "ipv6Sip"));
    cfg->ipv6_media_use = (pjsua_ipv6_use)map_ipv6(spc_jstr(c, "ipv6Media"));
    obj = spc_jobj(c, "ipChange");
    if (obj) {
        cfg->ip_change_cfg.shutdown_tp = spc_jbool(obj, "shutdownTransport", 1);
        cfg->ip_change_cfg.hangup_calls = spc_jbool(obj, "hangupCalls", 0);
        cfg->ip_change_cfg.reinv_use_update = spc_jbool(obj, "useUpdate", 0);
        cfg->ip_change_cfg.reinvite_flags = spc_jbool(obj, "reinvite", 1) ?
            (PJSUA_CALL_REINIT_MEDIA | PJSUA_CALL_UPDATE_CONTACT | PJSUA_CALL_UPDATE_VIA) : 0;
    }
    if (acc_sip_dscp(c) < 0) { snprintf(err, errn, "dscp.sip must be 0..63"); return -1; }
    /* rtp transport */
    pjsua_transport_config_default(&cfg->rtp_cfg);
    cfg->rtp_cfg.port = (unsigned)G.rtp_port;
    cfg->rtp_cfg.port_range = (unsigned)G.rtp_port_range;
    if (G.public_addr[0]) cfg->rtp_cfg.public_addr = spc_pjs(G.public_addr);
    if (G.qos) {
        int dscp = 46;
        obj = spc_jobj(c, "dscp");
        if (obj && !spc_jint_range(obj, "rtp", 46, 0, 63, &dscp)) { snprintf(err, errn, "dscp.rtp must be 0..63"); return -1; }
        cfg->rtp_cfg.qos_type = PJ_QOS_TYPE_VOICE;
        cfg->rtp_cfg.qos_params.flags = PJ_QOS_PARAM_HAS_DSCP;
        cfg->rtp_cfg.qos_params.dscp_val = (pj_uint8_t)(dscp & 0x3f);
    }

    /* extra headers + UA on REGISTER */
    s = spc_jstr(c, "userAgent");
    snprintf(ua, sizeof(ua), "%s", (s && s[0]) ? s : G.user_agent);
    if (ua[0]) {
        add_hdr(pool, &cfg->reg_hdr_list, "User-Agent", ua);
        add_hdr(pool, &cfg->sub_hdr_list, "User-Agent", ua);
    }
    obj = spc_jobj(c, "headers");
    if (spc_jhas(c, "headers") && !obj) { snprintf(err, errn, "'headers' must be an object"); return -1; }
    if (obj) {
        if (!spc_validate_headers(obj, err, errn)) return -1;
        cJSON_ArrayForEach(e, obj) {
            if (e->string && cJSON_IsString(e)) add_hdr(pool, &cfg->reg_hdr_list, e->string, e->valuestring);
        }
    }
    (void)i;
    if (spc_strieq(transport, "ws") || spc_strieq(transport, "wss"))
        return apply_ws(cfg, pool, c, user, domain, registrar, spc_strieq(transport, "wss"), err, errn);
    return 0;
}

/* copy mirrored fields into the meta used by callbacks */
static void fill_meta(spc_acc* m, const cJSON* c)
{
    const char* s;
    cJSON* arr;
    cJSON* e;
    spc_registry_lock();
    s = spc_jstr(c, "uid"); if (s) spc_strlcpy(m->uid, s, sizeof(m->uid));
    s = spc_jstr(c, "transport"); spc_strlcpy(m->transport, s ? s : "udp", sizeof(m->transport));
    {   /* normalise to lower case */
        char* p; for (p = m->transport; *p; p++) *p = (char)tolower((unsigned char)*p);
    }
    s = spc_jstr(c, "domain"); spc_strlcpy(m->domain, s ? s : "", sizeof(m->domain));
    s = spc_jstr(c, "dtmfMethod"); spc_strlcpy(m->dtmf_method, s ? s : "rfc2833", sizeof(m->dtmf_method));
    s = spc_jstr(c, "userAgent"); spc_strlcpy(m->user_agent, s ? s : "", sizeof(m->user_agent));
    s = spc_jstr(c, "callerId"); spc_strlcpy(m->caller_id, s ? s : "", sizeof(m->caller_id));
    s = spc_jstr(c, "displayName"); spc_strlcpy(m->display_name, s ? s : "", sizeof(m->display_name));
    s = spc_jstr(c, "redirect");
    m->redirect = (s && spc_strieq(s, "ask")) ? 1 : (s && spc_strieq(s, "reject")) ? 2 : 0;
    s = spc_jstr(c, "referPolicy"); m->refer_reject = (s && spc_strieq(s, "reject")) ? 1 : 0;
    s = spc_jstr(c, "watcherPolicy"); m->watcher_reject = (s && spc_strieq(s, "reject")) ? 1 : 0;
    s = spc_jstr(c, "srtp"); m->srtp = (s && !spc_strieq(s, "off")) ? 1 : 0;
    m->mwi = spc_jbool(c, "mwi", 1);
    m->privacy = spc_jbool(c, "privacy", 0);
    m->ncodecs = 0;
    arr = spc_jarr(c, "codecs");
    if (arr) {
        cJSON_ArrayForEach(e, arr) {
            if (cJSON_IsString(e) && e->valuestring[0] && m->ncodecs < SPC_MAX_CODECS)
                spc_strlcpy(m->codecs[m->ncodecs++], e->valuestring, sizeof(m->codecs[0]));
        }
    }
    spc_registry_unlock();
}

/* ------------------------------------------------------------------ */
/* handlers                                                            */
/* ------------------------------------------------------------------ */
static int h_account_add(cJSON* p, cJSON** res)
{
    const char* uid = spc_jstr(p, "uid");
    const char* proto = spc_jstr(p, "proto");
    pjsua_acc_config cfg;
    pj_pool_t* pool;
    spc_acc* m;
    char err[200];
    int rc, tp = PJSUA_INVALID_ID, i;
    pjsua_acc_id id = -1;
    pj_status_t st;

    if (!uid || !uid[0] || strlen(uid) >= sizeof(m->uid)) return spc_err(SPC_E_INVALID_PARAM, 0, "'uid' required");
    if (uid[0] == '_' && uid[1] == '_') return spc_err(SPC_E_INVALID_PARAM, 0, "reserved uid");
    if (proto && !spc_strieq(proto, "sip")) {
        if (spc_strieq(proto, "iax2")) return spc_iax2_account_add(p, res);
        return spc_err(SPC_E_INVALID_PARAM, 0, "invalid proto '%s'", proto);
    }
    if (spc_iax2_acc_find_uid(uid, &i) == 0) return spc_err(SPC_E_ALREADY, 0, "uid '%s' already exists", uid);
    spc_registry_lock();
    for (i = 0; i < PJSUA_MAX_ACC; i++)
        if (g_acc[i] && g_acc[i]->used && strcmp(g_acc[i]->uid, uid) == 0) {
            spc_registry_unlock();
            return spc_err(SPC_E_ALREADY, 0, "uid '%s' already exists", uid);
        }
    spc_registry_unlock();

    m = meta_alloc();
    if (!m) return spc_err(SPC_E_INTERNAL, 0, "out of memory");
    m->cfg = cJSON_Duplicate(p, 1);
    fill_meta(m, p);
    pool = pjsua_pool_create("spcacc", 4096, 2048);
    if (!pool) return spc_err(SPC_E_INTERNAL, 0, "out of memory");
    err[0] = 0;
    rc = build_cfg(m, p, &cfg, pool, err, sizeof(err));
    if (rc == 0 && ensure_own_tp(m, p, &tp, err, sizeof(err)) != 0) rc = -1;
    if (rc != 0) {
        pj_pool_release(pool);
        if (m->own_tp >= 0) pjsua_transport_close(m->own_tp, PJ_FALSE);
        m->used = 0;
        return spc_err(rc == -2 ? SPC_E_UNSUPPORTED : SPC_E_INVALID_PARAM, 0, "%s", err);
    }
    cfg.transport_id = tp;
    apply_sip_dscp(m, p, tp);
    spc_registry_lock();
    m->used = 1;
    spc_strlcpy(m->reg_state, cfg.register_on_acc_add ? "registering" : "none", sizeof(m->reg_state));
    spc_registry_unlock();
    st = pjsua_acc_add(&cfg, PJ_FALSE, &id);
    pj_pool_release(pool);
    if (st != PJ_SUCCESS) {
        spc_registry_lock(); m->used = 0; spc_registry_unlock();
        if (m->own_tp >= 0) { pjsua_transport_close(m->own_tp, PJ_FALSE); m->own_tp = -1; }
        return spc_pjerr(st, "pjsua_acc_add");
    }
    spc_registry_lock();
    m->acc = id;
    g_acc[id] = m;
    spc_registry_unlock();
    *res = cJSON_CreateObject();
    cJSON_AddNumberToObject(*res, "acc", id);
    if (!cfg.register_on_acc_add) emit_acc_reg(id);
    return SPC_OK;
}

static int h_account_modify(cJSON* p, cJSON** res)
{
    int acc, rc, tp;
    spc_acc* m;
    cJSON* merged;
    cJSON* it;
    pjsua_acc_config cfg;
    pj_pool_t* pool;
    char err[200];
    pj_status_t st;
    (void)res;
    rc = spc_acc_resolve(p, &acc);
    if (rc) return rc;
    if (acc >= SPC_ID_IAX_BASE) return spc_iax2_account_modify(acc, p);
    m = spc_acc_from_id(acc);
    if (!m || m->is_lan || m->is_direct || !m->cfg) return spc_err(SPC_E_INVALID_PARAM, 0, "cannot modify this account");
    merged = cJSON_Duplicate(m->cfg, 1);
    cJSON_ArrayForEach(it, p) {
        if (!it->string) continue;
        if (strcmp(it->string, "acc") == 0 || strcmp(it->string, "uid") == 0) continue;
        if (cJSON_GetObjectItemCaseSensitive(merged, it->string))
            cJSON_ReplaceItemInObjectCaseSensitive(merged, it->string, cJSON_Duplicate(it, 1));
        else
            cJSON_AddItemToObject(merged, it->string, cJSON_Duplicate(it, 1));
    }
    {
        const char* proto = spc_jstr(merged, "proto");
        if (proto && !spc_strieq(proto, "sip")) { cJSON_Delete(merged); return spc_err(SPC_E_UNSUPPORTED, 0, "proto %s unsupported", proto); }
    }
    pool = pjsua_pool_create("spcmod", 4096, 2048);
    if (!pool) { cJSON_Delete(merged); return spc_err(SPC_E_INTERNAL, 0, "out of memory"); }
    err[0] = 0;
    rc = build_cfg(m, merged, &cfg, pool, err, sizeof(err));
    if (rc == 0 && ensure_own_tp(m, merged, &tp, err, sizeof(err)) != 0) rc = -1;
    if (rc != 0) {
        pj_pool_release(pool);
        cJSON_Delete(merged);
        return spc_err(rc == -2 ? SPC_E_UNSUPPORTED : SPC_E_INVALID_PARAM, 0, "%s", err);
    }
    cfg.transport_id = tp;
    apply_sip_dscp(m, merged, tp);
    st = pjsua_acc_modify(acc, &cfg);
    pj_pool_release(pool);
    if (st != PJ_SUCCESS) { cJSON_Delete(merged); return spc_pjerr(st, "pjsua_acc_modify"); }
    spc_registry_lock();
    cJSON_Delete(m->cfg);
    m->cfg = merged;
    spc_registry_unlock();
    fill_meta(m, merged);
    emit_acc_reg(acc);
    return SPC_OK;
}

static int h_account_remove(cJSON* p, cJSON** res)
{
    int acc, rc;
    spc_acc* m;
    pj_status_t st;
    (void)res;
    rc = spc_acc_resolve(p, &acc);
    if (rc) return rc;
    if (acc >= SPC_ID_IAX_BASE) return spc_iax2_account_remove(acc);
    m = spc_acc_from_id(acc);
    if (!m || m->is_lan || m->is_direct) return spc_err(SPC_E_INVALID_PARAM, 0, "cannot remove this account");
    st = pjsua_acc_del(acc);
    if (st != PJ_SUCCESS) return spc_pjerr(st, "pjsua_acc_del");
    {   /* a removed account always ends with a final "unregistered" account.reg */
        cJSON* fin;
        int need;
        spc_registry_lock();
        need = strcmp(m->reg_state, "unregistered") != 0;
        spc_strlcpy(m->reg_state, "unregistered", sizeof(m->reg_state));
        m->used = 0;
        g_acc[acc] = NULL;
        fin = cJSON_CreateObject();
        cJSON_AddNumberToObject(fin, "acc", acc);
        cJSON_AddStringToObject(fin, "uid", m->uid);
        cJSON_AddStringToObject(fin, "proto", "sip");
        cJSON_AddStringToObject(fin, "uri", "");
        cJSON_AddStringToObject(fin, "regState", "unregistered");
        cJSON_AddNumberToObject(fin, "regCode", m->reg_code);
        cJSON_AddStringToObject(fin, "regReason", m->reg_reason);
        cJSON_AddNumberToObject(fin, "status", 0);
        cJSON_AddStringToObject(fin, "statusText", "removed");
        cJSON_AddNullToObject(fin, "lastError");
        cJSON_AddNumberToObject(fin, "expires", 0);
        cJSON_AddBoolToObject(fin, "online", 0);
        cJSON_AddBoolToObject(fin, "isUnreg", 1);
        cJSON_AddNullToObject(fin, "contact");
        cJSON_AddStringToObject(fin, "transport", m->transport);
        cJSON_AddStringToObject(fin, "presence", m->presence);
        cJSON_AddBoolToObject(fin, "isLan", 0);
        cJSON_AddBoolToObject(fin, "isDirect", 0);
        if (need) spc_emit("account.reg", fin); else cJSON_Delete(fin);
        spc_registry_unlock();
    }
    if (m->own_tp >= 0) { pjsua_transport_close(m->own_tp, PJ_FALSE); m->own_tp = -1; }
    return SPC_OK;
}

static int h_account_register(cJSON* p, cJSON** res)
{
    int acc, rc;
    pj_status_t st;
    (void)res;
    rc = spc_acc_resolve(p, &acc);
    if (rc) return rc;
    int regv;
    if (!spc_jbool_strict(p, "register", &regv)) return spc_err(SPC_E_INVALID_PARAM, 0, "'register' (bool) required");
    if (acc >= SPC_ID_IAX_BASE) return spc_iax2_account_register(acc, regv);
    {
        spc_acc* m = spc_acc_from_id(acc);
        if (!m || m->is_lan || m->is_direct) return spc_err(SPC_E_INVALID_PARAM, 0, "account has no registration");
    }
    st = pjsua_acc_set_registration(acc, regv);
    if (st != PJ_SUCCESS) return spc_pjerr(st, "pjsua_acc_set_registration");
    return SPC_OK;
}

static int h_account_set_presence(cJSON* p, cJSON** res)
{
    int acc, rc;
    const char* st = spc_jstr(p, "status");
    const char* note = spc_jstr(p, "note");
    pjrpid_element rpid;
    pj_bool_t online = PJ_TRUE;
    spc_acc* m;
    (void)res;
    rc = spc_acc_resolve(p, &acc);
    if (rc) return rc;
    if (!st) return spc_err(SPC_E_INVALID_PARAM, 0, "'status' required");
    memset(&rpid, 0, sizeof(rpid));
    rpid.type = PJRPID_ELEMENT_TYPE_PERSON;
    rpid.activity = PJRPID_ACTIVITY_UNKNOWN;
    if (acc >= SPC_ID_IAX_BASE) {
        static const char* ok[] = { "online", "away", "busy", "dnd", "onthephone", "offline", NULL };
        int k, good = 0;
        for (k = 0; ok[k]; k++) if (spc_strieq(st, ok[k])) good = 1;
        if (!good) return spc_err(SPC_E_INVALID_PARAM, 0, "invalid status '%s'", st);
        return spc_iax2_account_set_presence(acc, st, note);
    }
    if (spc_strieq(st, "online")) {}
    else if (spc_strieq(st, "away")) rpid.activity = PJRPID_ACTIVITY_AWAY;
    else if (spc_strieq(st, "busy")) rpid.activity = PJRPID_ACTIVITY_BUSY;
    else if (spc_strieq(st, "dnd")) { rpid.activity = PJRPID_ACTIVITY_BUSY; if (!note) note = "Do not disturb"; }
    else if (spc_strieq(st, "onthephone")) { rpid.activity = PJRPID_ACTIVITY_BUSY; if (!note) note = "On the phone"; }
    else if (spc_strieq(st, "offline")) online = PJ_FALSE;
    else return spc_err(SPC_E_INVALID_PARAM, 0, "invalid status '%s'", st);
    if (note) rpid.note = spc_pjs(note);
    {
        pj_status_t ps = pjsua_acc_set_online_status2(acc, online, &rpid);
        if (ps != PJ_SUCCESS) return spc_pjerr(ps, "set_online_status");
    }
    m = spc_acc_from_id(acc);
    if (m) {
        spc_registry_lock();
        spc_strlcpy(m->presence, st, sizeof(m->presence));
        spc_strlcpy(m->presence_note, note ? note : "", sizeof(m->presence_note));
        spc_registry_unlock();
    }
    return SPC_OK;
}

static int h_account_list(cJSON* p, cJSON** res)
{
    cJSON* arr = cJSON_CreateArray();
    (void)p;
    spc_acc_list_json(arr);
    *res = cJSON_CreateObject();
    cJSON_AddItemToObject(*res, "accounts", arr);
    return SPC_OK;
}

static int h_account_info(cJSON* p, cJSON** res)
{
    int acc, rc;
    rc = spc_acc_resolve(p, &acc);
    if (rc) return rc;
    *res = spc_acc_info_json(acc);
    if (!*res) return spc_err(SPC_E_NOT_FOUND, 0, "account not found");
    return SPC_OK;
}

const spc_method spc_methods_account[] = {
    { "account.add", h_account_add, 0 },
    { "account.modify", h_account_modify, 0 },
    { "account.remove", h_account_remove, 0 },
    { "account.register", h_account_register, 0 },
    { "account.setPresence", h_account_set_presence, 0 },
    { "account.list", h_account_list, 0 },
    { "account.info", h_account_info, 0 },
    { NULL, NULL, 0 }
};

/* ------------------------------------------------------------------ */
/* special accounts, lifecycle                                          */
/* ------------------------------------------------------------------ */
static int add_special(int tp, const char* uid, int lan, int* out)
{
    spc_acc* m = meta_alloc();
    pjsua_acc_id id = -1;
    pj_status_t st;
    if (!m) return -1;
    spc_strlcpy(m->uid, uid, sizeof(m->uid));
    m->is_lan = lan;
    m->is_direct = !lan;
    m->used = 1;
    spc_strlcpy(m->transport, "udp", sizeof(m->transport));
    spc_strlcpy(m->reg_state, "none", sizeof(m->reg_state));
    st = pjsua_acc_add_local(tp, lan ? PJ_FALSE : PJ_TRUE, &id);
    if (st != PJ_SUCCESS) { m->used = 0; return -1; }
    m->acc = id;
    spc_registry_lock();
    g_acc[id] = m;
    spc_registry_unlock();
    {   /* apply the engine's RTP settings to the local account */
        pj_pool_t* pool = pjsua_pool_create("spcloc", 2048, 2048);
        pjsua_acc_config cfg;
        if (pool && pjsua_acc_get_config(id, pool, &cfg) == PJ_SUCCESS) {
            pjsua_transport_config_default(&cfg.rtp_cfg);
            cfg.rtp_cfg.port = (unsigned)G.rtp_port;
            cfg.rtp_cfg.port_range = (unsigned)G.rtp_port_range;
            if (G.public_addr[0]) cfg.rtp_cfg.public_addr = spc_pjs(G.public_addr);
            if (G.qos) {
                cfg.rtp_cfg.qos_type = PJ_QOS_TYPE_VOICE;
                cfg.rtp_cfg.qos_params.flags = PJ_QOS_PARAM_HAS_DSCP;
                cfg.rtp_cfg.qos_params.dscp_val = 46;
            }
            cfg.user_data = m;
            pjsua_acc_modify(id, &cfg);
        }
        if (pool) pj_pool_release(pool);
    }
    *out = id;
    return 0;
}

int spc_account_init_special(int direct_tp, int lan_tp)
{
    (void)lan_tp;
    if (direct_tp < 0) return -1;
    return add_special(direct_tp, "__direct__", 0, &G.direct_acc);
}

int spc_lan_register_account(int tp, int* acc)
{
    return add_special(tp, "__lan__", 1, acc);
}

void spc_account_graceful_unregister(int max_ms)
{
    int i;
    int64_t t0 = spc_mono_ms();
    for (i = 0; i < PJSUA_MAX_ACC; i++) {
        spc_acc* m;
        if (!pjsua_acc_is_valid(i)) continue;
        m = spc_acc_from_id(i);
        if (!m || m->is_lan || m->is_direct) continue;
        if (strcmp(m->reg_state, "registered") == 0 || strcmp(m->reg_state, "registering") == 0)
            pjsua_acc_set_registration(i, PJ_FALSE);
    }
    for (;;) {
        int pending = 0;
        spc_registry_lock();
        for (i = 0; i < PJSUA_MAX_ACC; i++) {
            if (g_acc[i] && g_acc[i]->used && !g_acc[i]->is_lan && !g_acc[i]->is_direct) {
                const char* s = g_acc[i]->reg_state;
                if (strcmp(s, "registered") == 0 || strcmp(s, "registering") == 0 || strcmp(s, "unregistering") == 0) pending++;
            }
        }
        spc_registry_unlock();
        if (!pending || spc_mono_ms() - t0 > max_ms) break;
        spc_sleep_ms(20);
    }
}

void spc_account_cleanup(void)
{
    spc_acc* a;
    int i;
    spc_registry_lock();
    for (i = 0; i < PJSUA_MAX_ACC; i++) g_acc[i] = NULL;
    a = g_all;
    g_all = NULL;
    spc_registry_unlock();
    while (a) {
        spc_acc* n = a->next;
        if (a->cfg) cJSON_Delete(a->cfg);
        free(a);
        a = n;
    }
    G.direct_acc = G.lan_acc = -1;
}

/* ------------------------------------------------------------------ */
/* per-account codec filtering of the SDP                              */
/* ------------------------------------------------------------------ */
static int sdp_fmt_info(const pjmedia_sdp_media* m, const pj_str_t* pt, char* name, size_t nn, int* rate, int* ch)
{
    unsigned i;
    name[0] = 0; *rate = 0; *ch = 1;
    for (i = 0; i < m->attr_count; i++) {
        pjmedia_sdp_attr* a = m->attr[i];
        pjmedia_sdp_rtpmap rm;
        if (pj_strcmp2(&a->name, "rtpmap") != 0) continue;
        if (pjmedia_sdp_attr_get_rtpmap(a, &rm) != PJ_SUCCESS) continue;
        if (pj_strcmp(&rm.pt, pt) != 0) continue;
        spc_pjcopy(name, nn, &rm.enc_name);
        *rate = (int)rm.clock_rate;
        if (rm.param.slen > 0) { *ch = atoi(rm.param.ptr); if (*ch < 1) *ch = 1; }
        return 1;
    }
    {   /* static payload types */
        int n = atoi(pt->ptr);
        switch (n) {
        case 0: spc_strlcpy(name, "PCMU", nn); *rate = 8000; return 1;
        case 8: spc_strlcpy(name, "PCMA", nn); *rate = 8000; return 1;
        case 3: spc_strlcpy(name, "GSM", nn); *rate = 8000; return 1;
        case 9: spc_strlcpy(name, "G722", nn); *rate = 8000; return 1;
        case 18: spc_strlcpy(name, "G729", nn); *rate = 8000; return 1;
        default: break;
        }
    }
    return 0;
}

static int codec_matches(const char* entry, const char* name, int rate, int ch)
{
    char e[40];
    char* sl;
    char* sl2;
    int er = 0, ec = 0;
    spc_strlcpy(e, entry, sizeof(e));
    sl = strchr(e, '/');
    if (sl) {
        *sl = 0;
        er = atoi(sl + 1);
        sl2 = strchr(sl + 1, '/');
        if (sl2) ec = atoi(sl2 + 1);
    }
    if (!spc_strieq(e, name)) return 0;
    if (er > 0 && er != rate) {
        if (!(spc_strieq(name, "G722") && (er == 16000 || er == 8000))) return 0;
    }
    if (ec > 0 && ec != ch) return 0;
    return 1;
}

int spc_account_filter_codecs_for(int acc, pjmedia_sdp_session* sdp)
{
    spc_acc* m = spc_acc_from_id(acc);
    char list[SPC_MAX_CODECS][40];
    int n, ci, mi;
    if (!m || !sdp) return 0;
    spc_registry_lock();
    n = m->ncodecs;
    for (ci = 0; ci < n; ci++) spc_strlcpy(list[ci], m->codecs[ci], sizeof(list[0]));
    spc_registry_unlock();
    if (n == 0) return 0;
    for (mi = 0; mi < (int)sdp->media_count; mi++) {
        pjmedia_sdp_media* sm = sdp->media[mi];
        pj_str_t newfmt[PJMEDIA_MAX_SDP_FMT];
        int newcnt = 0, f;
        unsigned k;
        char removed[PJMEDIA_MAX_SDP_FMT][8];
        int nremoved = 0;
        if (pj_strcmp2(&sm->desc.media, "audio") != 0) continue;
        /* codecs in account order */
        for (ci = 0; ci < n; ci++) {
            for (f = 0; f < (int)sm->desc.fmt_count; f++) {
                char name[48]; int rate, ch;
                if (!sdp_fmt_info(sm, &sm->desc.fmt[f], name, sizeof(name), &rate, &ch)) continue;
                if (spc_strieq(name, "telephone-event")) continue;
                if (codec_matches(list[ci], name, rate, ch)) {
                    int dup = 0, q;
                    for (q = 0; q < newcnt; q++) if (pj_strcmp(&newfmt[q], &sm->desc.fmt[f]) == 0) dup = 1;
                    if (!dup && newcnt < PJMEDIA_MAX_SDP_FMT) newfmt[newcnt++] = sm->desc.fmt[f];
                }
            }
        }
        if (newcnt == 0) continue;         /* nothing matches: do not break the call */
        /* keep non-codec payloads (telephone-event, CN) */
        for (f = 0; f < (int)sm->desc.fmt_count; f++) {
            char name[48]; int rate, ch, keep = 0, q, present = 0;
            for (q = 0; q < newcnt; q++) if (pj_strcmp(&newfmt[q], &sm->desc.fmt[f]) == 0) present = 1;
            if (present) continue;
            if (sdp_fmt_info(sm, &sm->desc.fmt[f], name, sizeof(name), &rate, &ch)) {
                if (spc_strieq(name, "telephone-event") || spc_strieq(name, "CN")) keep = 1;
            }
            if (keep) {
                if (newcnt < PJMEDIA_MAX_SDP_FMT) newfmt[newcnt++] = sm->desc.fmt[f];
            } else if (nremoved < PJMEDIA_MAX_SDP_FMT) {
                spc_pjcopy(removed[nremoved], sizeof(removed[0]), &sm->desc.fmt[f]);
                nremoved++;
            }
        }
        for (f = 0; f < newcnt; f++) sm->desc.fmt[f] = newfmt[f];
        sm->desc.fmt_count = (unsigned)newcnt;
        for (k = sm->attr_count; k > 0; k--) {
            pjmedia_sdp_attr* a = sm->attr[k - 1];
            int q;
            if (pj_strcmp2(&a->name, "rtpmap") != 0 && pj_strcmp2(&a->name, "fmtp") != 0) continue;
            for (q = 0; q < nremoved; q++) {
                size_t l = strlen(removed[q]);
                if ((size_t)a->value.slen > l && strncmp(a->value.ptr, removed[q], l) == 0 && a->value.ptr[l] == ' ') {
                    pjmedia_sdp_media_remove_attr(sm, a);
                    break;
                }
            }
        }
    }
    return 1;
}
