/* spc_callreq.c: call.* request handlers. */
#include "spc_internal.h"
#include "spc_player.h"
#include "spc_rec.h"
#include <ctype.h>

#define NEED_CID(var) \
    uint64_t var = spc_ju64(p, "cid"); \
    if (!var) return spc_err(SPC_E_INVALID_PARAM, 0, "'cid' required")

static int map_pj(pj_status_t st, const char* what)
{
    if (st == PJ_ETOOMANY) return spc_err(SPC_E_BUSY, st, "%s: too many calls", what);
    if (st == PJSIP_ESESSIONSTATE || st == PJ_EINVALIDOP) return spc_err(SPC_E_BUSY, st, "%s: invalid call state", what);
    return spc_pjerr(st, what);
}

/* resolves a cid to slot; error NOT_FOUND */
static int need_call(uint64_t cid, int* slot, int* acc)
{
    if (spc_call_cid_to_slot(cid, slot, acc) != 0)
        return spc_err(SPC_E_NOT_FOUND, 0, "call %llu not found", (unsigned long long)cid);
    return SPC_OK;
}

static void set_flag(uint64_t cid, int off, int v)
{
    spc_call* c = spc_call_lock_find(cid);
    if (!c) return;
    switch (off) {
    case 0: c->responded = v; break;
    case 1: c->ring_sent = v; break;
    case 2: c->muted = v; break;
    case 3: c->held = v; break;
    case 4: c->detached = v; break;
    default: break;
    }
    spc_registry_unlock();
}

/* ---- make ---- */
static int do_make(cJSON* p, const char* extra_name, const char* extra_val, cJSON** res)
{
    int acc, rc, slot = -1;
    const char* uri = spc_jstr(p, "uri");
    const char* dn = spc_jstr(p, "displayName");
    int anon = spc_jbool(p, "anonymous", 0);
    char dest[512];
    pjsua_msg_data md;
    pj_pool_t* pool;
    pjsua_acc_info ai;
    spc_acc* m;
    pj_status_t st;
    pj_str_t d;
    char local[600];
    cJSON* hdrs;
    cJSON* e;
    cJSON* ah;
    char herr[120];

    if (!uri || !uri[0]) return spc_err(SPC_E_INVALID_PARAM, 0, "'uri' required");
    if (!spc_validate_headers(spc_jobj(p, "headers"), herr, sizeof(herr))) return spc_err(SPC_E_INVALID_PARAM, 0, "%s", herr);
    if (!spc_str_clean(uri) || !spc_str_clean(dn)) return spc_err(SPC_E_INVALID_PARAM, 0, "control characters are not allowed");
    rc = spc_acc_resolve(p, &acc);
    if (rc) return rc;
    if (acc >= SPC_ID_IAX_BASE) return spc_iax2_call_make(acc, p, res);
    rc = spc_uri_normalize(acc, uri, dest, sizeof(dest));
    if (rc == -2) return SPC_E_INVALID_PARAM;      /* sips: on a non-TLS account; message already recorded */
    if (rc != 0) return spc_err(SPC_E_INVALID_PARAM, 0, "invalid uri");
    d = spc_pjs(dest);
    if (pjsua_verify_url(dest) != PJ_SUCCESS && !spc_strnieq(dest, "tel:", 4))
        return spc_err(SPC_E_INVALID_PARAM, 0, "invalid uri '%s'", dest);
    m = spc_acc_from_id(acc);
    pool = pjsua_pool_create("spcmk", 2048, 2048);
    if (!pool) return spc_err(SPC_E_INTERNAL, 0, "out of memory");
    spc_fill_msg_data(pool, &md, spc_jobj(p, "headers"));
    local[0] = 0;
    /* account-wide extra headers */
    if (m && m->cfg) {
        ah = spc_jobj(m->cfg, "headers");
        if (ah) cJSON_ArrayForEach(e, ah) {
            if (e->string && cJSON_IsString(e)) {
                pj_str_t n, v;
                pjsip_generic_string_hdr* gh;
                pj_strdup2_with_null(pool, &n, e->string);
                pj_strdup2_with_null(pool, &v, e->valuestring);
                gh = pjsip_generic_string_hdr_create(pool, &n, &v);
                if (gh) pj_list_push_back(&md.hdr_list, (pjsip_hdr*)gh);
            }
        }
    }
    hdrs = NULL; (void)hdrs;
    {
        const char* ua = (m && m->user_agent[0]) ? m->user_agent : G.user_agent;
        if (ua[0]) {
            pj_str_t n, v;
            pjsip_generic_string_hdr* gh;
            pj_strdup2_with_null(pool, &n, "User-Agent");
            pj_strdup2_with_null(pool, &v, ua);
            gh = pjsip_generic_string_hdr_create(pool, &n, &v);
            if (gh) pj_list_push_back(&md.hdr_list, (pjsip_hdr*)gh);
        }
    }
    if (extra_name) {
        pj_str_t n, v;
        pjsip_generic_string_hdr* gh;
        pj_strdup2_with_null(pool, &n, extra_name);
        pj_strdup2_with_null(pool, &v, extra_val);
        gh = pjsip_generic_string_hdr_create(pool, &n, &v);
        if (gh) pj_list_push_back(&md.hdr_list, (pjsip_hdr*)gh);
    }
    if (pjsua_acc_get_info(acc, &ai) == PJ_SUCCESS && m && !m->is_direct && !m->is_lan) {
        char cur[300], user[100], host[200];
        spc_pjcopy(cur, sizeof(cur), &ai.acc_uri);
        spc_parse_nameaddr(cur, NULL, 0, host, sizeof(host), user, sizeof(user));
        if (anon || m->privacy) {
            snprintf(local, sizeof(local), "\"Anonymous\" <sip:anonymous@anonymous.invalid>");
            {
                pj_str_t n, v;
                pjsip_generic_string_hdr* gh;
                pj_strdup2_with_null(pool, &n, "Privacy");
                pj_strdup2_with_null(pool, &v, "id");
                gh = pjsip_generic_string_hdr_create(pool, &n, &v);
                if (gh) pj_list_push_back(&md.hdr_list, (pjsip_hdr*)gh);
            }
        } else if ((dn && dn[0]) || m->caller_id[0]) {
            const char* at = strchr(host, '@');
            const char* dom = at ? at + 1 : host;
            const char* usr = m->caller_id[0] ? m->caller_id : user;
            const char* disp = (dn && dn[0]) ? dn : m->display_name;
            if (disp[0]) snprintf(local, sizeof(local), "\"%s\" <sip:%s@%s>", disp, usr, dom);
            else snprintf(local, sizeof(local), "<sip:%s@%s>", usr, dom);
        }
        if (local[0]) pj_strdup2_with_null(pool, &md.local_uri, local);
    }
    {
        int tries;
        for (tries = 0; tries < 40; tries++) {
            st = pjsua_call_make_call(acc, &d, NULL, NULL, &md, &slot);
            if ((st == PJMEDIA_EAUD_NODEFDEV || st == PJMEDIA_EAUD_NODEV) && spc_media_on_connect_error(st))
                continue;          /* no audio device at all (headless server, VM, CI): place the call on the null device */
            if (st != PJ_ETOOMANY) break;
            spc_sleep_ms(25);      /* a just-finished call may still hold its pjsua slot */
        }
    }
    pj_pool_release(pool);
    if (st != PJ_SUCCESS) return map_pj(st, "pjsua_call_make_call");
    {
        uint64_t cid = spc_call_ensure_slot(slot);
        if (!cid) {
            /* the call is already gone (e.g. failed synchronously); never answer ok with cid 0 */
            return spc_err(SPC_E_PJ_ERROR, 0, "call terminated during setup");
        }
        *res = cJSON_CreateObject();
        cJSON_AddNumberToObject(*res, "cid", (double)cid);
        cJSON_AddNumberToObject(*res, "call", slot);
    }
    return SPC_OK;
}

static int h_make(cJSON* p, cJSON** res) { return do_make(p, NULL, NULL, res); }

static int h_pickup(cJSON* p, cJSON** res)
{
    cJSON* r = spc_jobj(p, "replaces");
    const char* cid_ = spc_jstr(r, "callId");
    const char* tt = spc_jstr(r, "toTag");
    const char* ft = spc_jstr(r, "fromTag");
    char v[400];
    if (!cid_ || !tt || !ft) return spc_err(SPC_E_INVALID_PARAM, 0, "replaces needs callId, toTag, fromTag");
    snprintf(v, sizeof(v), "%s;to-tag=%s;from-tag=%s", cid_, tt, ft);
    return do_make(p, "Replaces", v, res);
}

/* ---- incoming responses ---- */
static int h_answer(cJSON* p, cJSON** res)
{
    NEED_CID(cid);
    int slot, acc, rc, code = spc_jint(p, "code", 200);
    pjsua_msg_data md;
    pj_pool_t* pool;
    pj_status_t st;
    (void)res;
    char herr[120];
    if (code < 101 || code > 699 || (code >= 300 && code < 400)) return spc_err(SPC_E_INVALID_PARAM, 0, "invalid answer code %d", code);
    if (!spc_validate_headers(spc_jobj(p, "headers"), herr, sizeof(herr))) return spc_err(SPC_E_INVALID_PARAM, 0, "%s", herr);
    if ((rc = need_call(cid, &slot, &acc))) return rc;
    if (spc_call_is_iax(cid)) return spc_iax2_call_op(SPC_IAXOP_ANSWER, cid, p, res);
    pool = pjsua_pool_create("spcans", 1024, 1024);
    spc_fill_msg_data(pool, &md, spc_jobj(p, "headers"));
    st = pjsua_call_answer(slot, (unsigned)code, NULL, &md);
    pj_pool_release(pool);
    if (st != PJ_SUCCESS) return map_pj(st, "pjsua_call_answer");
    set_flag(cid, 0, 1);
    if (code == 180 || code == 183 || code == 181) set_flag(cid, 1, 1);
    return SPC_OK;
}

static int h_ring(cJSON* p, cJSON** res)
{
    NEED_CID(cid);
    int slot, acc, rc, need = 0;
    spc_call* c;
    pj_status_t st = PJ_SUCCESS;
    (void)res;
    if ((rc = need_call(cid, &slot, &acc))) return rc;
    if (spc_call_is_iax(cid)) return spc_iax2_call_op(SPC_IAXOP_RING, cid, p, res);
    c = spc_call_lock_find(cid);
    if (c) { c->responded = 1; need = !c->ring_sent; c->ring_sent = 1; spc_registry_unlock(); }
    if (need) st = pjsua_call_answer(slot, 180, NULL, NULL);
    if (st != PJ_SUCCESS && st != PJSIP_ESESSIONSTATE) return map_pj(st, "ring");
    return SPC_OK;
}

static int h_reject(cJSON* p, cJSON** res)
{
    NEED_CID(cid);
    int slot, acc, rc, code = spc_jint(p, "code", 486);
    const char* reason = spc_jstr(p, "reason");
    pjsua_msg_data md;
    pj_pool_t* pool;
    pj_status_t st;
    pj_str_t rs;
    pjsua_call_info ci;
    (void)res;
    char herr[120];
    if (code < 300 || code > 699) return spc_err(SPC_E_INVALID_PARAM, 0, "reject code must be 300..699");
    if (reason && (!spc_str_clean(reason) || strlen(reason) > 120)) return spc_err(SPC_E_INVALID_PARAM, 0, "invalid reason");
    if (!spc_validate_headers(spc_jobj(p, "headers"), herr, sizeof(herr))) return spc_err(SPC_E_INVALID_PARAM, 0, "%s", herr);
    if ((rc = need_call(cid, &slot, &acc))) return rc;
    if (spc_call_is_iax(cid)) {
        rc = spc_iax2_call_op(SPC_IAXOP_REJECT, cid, p, res);
        if (rc == SPC_OK) spc_call_wait_gone(cid, 2000);
        return rc;
    }
    pool = pjsua_pool_create("spcrej", 1024, 1024);
    spc_fill_msg_data(pool, &md, spc_jobj(p, "headers"));
    set_flag(cid, 0, 1);
    if (pjsua_call_get_info(slot, &ci) == PJ_SUCCESS && ci.state == PJSIP_INV_STATE_INCOMING) {
        rs = reason ? spc_pjs(reason) : spc_pjs("");
        st = pjsua_call_answer(slot, (unsigned)code, reason ? &rs : NULL, &md);
    } else {
        st = pjsua_call_hangup(slot, (unsigned)code, NULL, &md);
    }
    pj_pool_release(pool);
    if (st != PJ_SUCCESS) return map_pj(st, "reject");
    spc_call_wait_gone(cid, 2000);
    return SPC_OK;
}

static int h_redirect(cJSON* p, cJSON** res)
{
    NEED_CID(cid);
    int slot, acc, rc, code = spc_jint(p, "code", 302);
    cJSON* t = spc_jarr(p, "targets");
    cJSON* e;
    char val[1024];
    pjsua_msg_data md;
    pj_pool_t* pool;
    pj_status_t st;
    pj_str_t n, v;
    pjsip_generic_string_hdr* gh;
    (void)res;
    if (code < 300 || code > 399) return spc_err(SPC_E_INVALID_PARAM, 0, "redirect code must be 3xx");
    if (!t || cJSON_GetArraySize(t) < 1) return spc_err(SPC_E_INVALID_PARAM, 0, "'targets' must be a non-empty array");
    if ((rc = need_call(cid, &slot, &acc))) return rc;
    if (spc_call_is_iax(cid)) return spc_iax2_call_op(SPC_IAXOP_UNSUPPORTED, cid, p, res);
    val[0] = 0;
    cJSON_ArrayForEach(e, t) {
        char norm[300];
        if (!cJSON_IsString(e) || spc_uri_normalize(acc, e->valuestring, norm, sizeof(norm)) != 0)
            return spc_err(SPC_E_INVALID_PARAM, 0, "invalid target");
        if (strlen(val) + strlen(norm) + 6 < sizeof(val)) {
            if (val[0]) strcat(val, ", ");
            strcat(val, "<"); strcat(val, norm); strcat(val, ">");
        }
    }
    pool = pjsua_pool_create("spcred", 1024, 1024);
    pjsua_msg_data_init(&md);
    pj_strdup2_with_null(pool, &n, "Contact");
    pj_strdup2_with_null(pool, &v, val);
    gh = pjsip_generic_string_hdr_create(pool, &n, &v);
    if (gh) pj_list_push_back(&md.hdr_list, (pjsip_hdr*)gh);
    set_flag(cid, 0, 1);
    st = pjsua_call_answer(slot, (unsigned)code, NULL, &md);
    pj_pool_release(pool);
    if (st != PJ_SUCCESS) return map_pj(st, "redirect");
    spc_call_wait_gone(cid, 2000);
    return SPC_OK;
}

static int h_process_redirect(cJSON* p, cJSON** res)
{
    NEED_CID(cid);
    int slot, acc, rc;
    const char* a = spc_jstr(p, "action");
    pjsip_redirect_op op;
    pj_status_t st;
    (void)res;
    if (!a) return spc_err(SPC_E_INVALID_PARAM, 0, "'action' required");
    if (spc_strieq(a, "accept")) op = PJSIP_REDIRECT_ACCEPT;
    else if (spc_strieq(a, "acceptReplace")) op = PJSIP_REDIRECT_ACCEPT_REPLACE;
    else if (spc_strieq(a, "reject")) op = PJSIP_REDIRECT_REJECT;
    else if (spc_strieq(a, "stop")) op = PJSIP_REDIRECT_STOP;
    else return spc_err(SPC_E_INVALID_PARAM, 0, "invalid action '%s'", a);
    if ((rc = need_call(cid, &slot, &acc))) return rc;
    if (spc_call_is_iax(cid)) return spc_iax2_call_op(SPC_IAXOP_UNSUPPORTED, cid, p, res);
    st = pjsua_call_process_redirect(slot, op);
    if (st != PJ_SUCCESS) return map_pj(st, "process_redirect");
    return SPC_OK;
}

/* ---- hangup ---- */
static int h_hangup(cJSON* p, cJSON** res)
{
    NEED_CID(cid);
    int slot, acc, rc, code = spc_jint(p, "code", 0);
    pj_status_t st;
    (void)res;
    if (code != 0 && (code < 200 || code > 699)) return spc_err(SPC_E_INVALID_PARAM, 0, "invalid code");
    if ((rc = need_call(cid, &slot, &acc))) return rc;
    if (spc_call_is_iax(cid)) {
        rc = spc_iax2_call_op(SPC_IAXOP_HANGUP, cid, p, res);
        if (rc == SPC_OK) spc_call_wait_gone(cid, 2000);
        return rc;
    }
    st = pjsua_call_hangup(slot, (unsigned)code, NULL, NULL);
    if (st != PJ_SUCCESS && st != PJSIP_ESESSIONSTATE) return map_pj(st, "pjsua_call_hangup");
    spc_call_wait_gone(cid, 2000);
    return SPC_OK;
}

static int h_hangup_all(cJSON* p, cJSON** res)
{
    (void)p; (void)res;
    spc_call_hangup_all_and_wait(2000);
    return SPC_OK;
}

/* ---- hold / mute ---- */
static int h_hold(cJSON* p, cJSON** res)
{
    NEED_CID(cid);
    int slot, acc, rc, moh = 0, moh_loop = 1;
    float moh_vol = 1.0f;
    const char* moh_file = NULL;
    pj_status_t st;
    cJSON* music = spc_jobj(p, "music");
    (void)res;
    if ((rc = need_call(cid, &slot, &acc))) return rc;
    if (spc_jhas(p, "music") && !cJSON_IsNull(cJSON_GetObjectItem(p, "music"))) {
        spc_fileinfo fi;
        char perr[200];
        double v;
        if (!music) return spc_err(SPC_E_INVALID_PARAM, 0, "'music' must be an object");
        moh_file = spc_jstr(music, "file");
        if (!moh_file || !moh_file[0]) return spc_err(SPC_E_INVALID_PARAM, 0, "music.file required");
        if (spc_jhas(music, "loop") && !spc_jbool_strict(music, "loop", &moh_loop)) return spc_err(SPC_E_INVALID_PARAM, 0, "music.loop must be a bool");
        v = spc_jnum(music, "volume", 1.0);
        if (!(v >= 0.0 && v <= 4.0)) return spc_err(SPC_E_INVALID_PARAM, 0, "music.volume must be 0..4");
        moh_vol = (float)v;
        if (spc_media_file_info(moh_file, &fi, perr, sizeof(perr)) != 0) return spc_err(SPC_E_INVALID_PARAM, 0, "music.file: %s", perr);
        moh = 1;
    }
    if (spc_call_is_iax(cid)) {
        rc = spc_iax2_call_op(SPC_IAXOP_HOLD, cid, p, res);
        spc_call_apply_topology();
        if (rc == SPC_OK && moh && spc_moh_arm(cid, moh_file, moh_loop, moh_vol) == 0) spc_moh_start_now(cid);   /* IAX2: no media-state callback to wait for */
        return rc;
    }
    set_flag(cid, 3, 1);
    spc_call_apply_topology();
    if (moh) spc_moh_arm(cid, moh_file, moh_loop, moh_vol);      /* armed first: the media-state callback may fire before set_hold2 returns */
    st = pjsua_call_set_hold2(slot, 0, NULL);
    if (st != PJ_SUCCESS && st != PJ_EEXISTS) {
        if (moh) spc_moh_disarm(cid);
        set_flag(cid, 3, 0);
        spc_call_apply_topology();
        return map_pj(st, "hold");
    }
    if (st == PJ_EEXISTS && moh) spc_moh_start_now(cid);        /* already held: no new media-state event will come */
    return SPC_OK;
}

static int unhold_one(uint64_t cid, int slot)
{
    pjsua_call_setting opt;
    pj_status_t st;
    set_flag(cid, 3, 0);
    spc_moh_disarm(cid);
    pjsua_call_setting_default(&opt);
    opt.flag |= PJSUA_CALL_UNHOLD;
    st = pjsua_call_reinvite2(slot, &opt, NULL);
    spc_call_apply_topology();
    return st;
}

static int h_unhold(cJSON* p, cJSON** res)
{
    NEED_CID(cid);
    int slot, acc, rc;
    pj_status_t st;
    (void)res;
    if ((rc = need_call(cid, &slot, &acc))) return rc;
    if (spc_call_is_iax(cid)) {
        rc = spc_iax2_call_op(SPC_IAXOP_UNHOLD, cid, p, res);
        spc_call_apply_topology();
        return rc;
    }
    st = unhold_one(cid, slot);
    if (st != PJ_SUCCESS && st != PJ_EEXISTS) return map_pj(st, "unhold");
    return SPC_OK;
}

static int h_mute(cJSON* p, cJSON** res)
{
    NEED_CID(cid);
    int slot, acc, rc;
    (void)res;
    int mv;
    if (!spc_jbool_strict(p, "mute", &mv)) return spc_err(SPC_E_INVALID_PARAM, 0, "'mute' (bool) required");
    if ((rc = need_call(cid, &slot, &acc))) return rc;
    set_flag(cid, 2, mv);
    spc_call_apply_topology();
    return SPC_OK;
}

static int h_set_levels(cJSON* p, cJSON** res)
{
    NEED_CID(cid);
    int slot, acc, rc, cslot;
    double rx = spc_jnum(p, "rx", 1.0), tx = spc_jnum(p, "tx", 1.0);
    (void)res;
    if (rx < 0 || rx > 8 || tx < 0 || tx > 8) return spc_err(SPC_E_INVALID_PARAM, 0, "levels must be 0..8");
    if ((rc = need_call(cid, &slot, &acc))) return rc;
    cslot = spc_call_conf_slot(cid, slot);
    if (cslot < 0) return spc_err(SPC_E_BUSY, 0, "no active media");
    pjsua_conf_adjust_rx_level(cslot, (float)rx);
    pjsua_conf_adjust_tx_level(cslot, (float)tx);
    return SPC_OK;
}

/* ---- dtmf ---- */
static int inband_dtmf(uint64_t cid, int slot, const char* digits, int dur)
{
    spc_call* c;
    pjsua_call_info ci;
    pjmedia_tone_digit d[32];
    int n = 0, i;
    pj_status_t st;
    int rate = spc_media_bridge_rate();
    pjmedia_port* port;
    if (pjsua_call_get_info(slot, &ci) != PJ_SUCCESS || ci.conf_slot < 0) return PJ_EINVALIDOP;
    c = spc_call_lock_find(cid);
    if (!c) return PJ_ENOTFOUND;
    port = c->tg_port;
    spc_registry_unlock();
    if (!port) {
        pj_pool_t* pool;
        int cs = -1;
        pool = pjsua_pool_create("spctg", 1024, 1024);
        if (!pool) return PJ_ENOMEM;
        st = pjmedia_tonegen_create(pool, (unsigned)rate, 1, (unsigned)(rate / 50), 16, 0, &port);
        if (st != PJ_SUCCESS) { pj_pool_release(pool); return st; }
        st = pjsua_conf_add_port(pool, port, &cs);
        if (st != PJ_SUCCESS) { pjmedia_port_destroy(port); pj_pool_release(pool); return st; }
        c = spc_call_lock_find(cid);
        if (!c) { pjsua_conf_remove_port(cs); spc_port_destroy_release(port, pool); return PJ_ENOTFOUND; }
        c->tg_port = port; c->tg_slot = cs; c->tg_pool = pool;
        spc_registry_unlock();
    }
    spc_call_apply_topology();
    for (i = 0; digits[i] && n < 32; i++) {
        d[n].digit = digits[i];
        d[n].on_msec = (short)dur;
        d[n].off_msec = 60;
        d[n].volume = 0;
        n++;
    }
    /* The port can be destroyed by the call's terminal cleanup at any moment. Cleanup destroys it under tg_mtx
     * after clearing c->tg_port, so if it is still registered while we hold tg_mtx, it stays valid until we are done. */
    spc_mutex_lock(&G.tg_mtx);
    c = spc_call_lock_find(cid);
    if (!c || c->tg_port != port) {
        if (c) spc_registry_unlock();
        spc_mutex_unlock(&G.tg_mtx);
        return PJ_ENOTFOUND;
    }
    spc_registry_unlock();
    st = pjmedia_tonegen_play_digits(port, (unsigned)n, d, 0);
    spc_mutex_unlock(&G.tg_mtx);
    return st;
}

static int h_dtmf(cJSON* p, cJSON** res)
{
    NEED_CID(cid);
    const char* digits = spc_jstr(p, "digits");
    const char* method = spc_jstr(p, "method");
    int dur = spc_jint(p, "durationMs", 160);
    int slot, acc, rc, i;
    char meth[12];
    pj_status_t st;
    pjsua_call_send_dtmf_param prm;
    spc_call* c;
    (void)res;
    if (!digits || !digits[0] || strlen(digits) > 32) return spc_err(SPC_E_INVALID_PARAM, 0, "'digits' required (1..32 chars)");
    for (i = 0; digits[i]; i++)
        if (!strchr("0123456789*#ABCDabcd", digits[i])) return spc_err(SPC_E_INVALID_PARAM, 0, "invalid DTMF digit '%c'", digits[i]);
    if (dur < 40 || dur > 5000) return spc_err(SPC_E_INVALID_PARAM, 0, "durationMs must be 40..5000");
    if ((rc = need_call(cid, &slot, &acc))) return rc;
    if (method) spc_strlcpy(meth, method, sizeof(meth));
    else {
        c = spc_call_lock_find(cid);
        spc_strlcpy(meth, c ? c->dtmf_method : "rfc2833", sizeof(meth));
        if (c) spc_registry_unlock();
    }
    if (!(spc_strieq(meth, "rfc2833") || spc_strieq(meth, "info") || spc_strieq(meth, "inband") || spc_strieq(meth, "auto") || spc_strieq(meth, "iax2")))
        return spc_err(SPC_E_INVALID_PARAM, 0, "invalid DTMF method '%s'", meth);
    if (!spc_strieq(meth, "inband") && spc_call_is_iax(cid)) return spc_iax2_call_op(SPC_IAXOP_DTMF, cid, p, res);
    if (spc_strieq(meth, "inband")) {
        st = inband_dtmf(cid, slot, digits, dur);
        if (st != PJ_SUCCESS) return map_pj(st, "inband dtmf");
        return SPC_OK;
    }
    pjsua_call_send_dtmf_param_default(&prm);
    prm.digits = spc_pjs(digits);
    prm.duration = (unsigned)dur;
    prm.method = spc_strieq(meth, "info") ? PJSUA_DTMF_METHOD_SIP_INFO : PJSUA_DTMF_METHOD_RFC2833;
    st = pjsua_call_send_dtmf(slot, &prm);
    if (st != PJ_SUCCESS && spc_strieq(meth, "auto")) {
        prm.method = PJSUA_DTMF_METHOD_SIP_INFO;
        st = pjsua_call_send_dtmf(slot, &prm);
    }
    if (st != PJ_SUCCESS) return map_pj(st, "send_dtmf");
    return SPC_OK;
}

/* ---- transfer ---- */
static int h_transfer(cJSON* p, cJSON** res)
{
    NEED_CID(cid);
    const char* target = spc_jstr(p, "target");
    int slot, acc, rc;
    char dest[512];
    pj_str_t d;
    pj_status_t st;
    (void)res;
    if (!target || !target[0]) return spc_err(SPC_E_INVALID_PARAM, 0, "'target' required");
    if ((rc = need_call(cid, &slot, &acc))) return rc;
    if (spc_call_is_iax(cid)) return spc_iax2_call_op(SPC_IAXOP_TRANSFER, cid, p, res);
    if (spc_uri_normalize(acc, target, dest, sizeof(dest)) != 0) return spc_err(SPC_E_INVALID_PARAM, 0, "invalid target");
    d = spc_pjs(dest);
    st = pjsua_call_xfer(slot, &d, NULL);
    if (st != PJ_SUCCESS) return map_pj(st, "xfer");
    return SPC_OK;
}

static int h_transfer_attended(cJSON* p, cJSON** res)
{
    NEED_CID(cid);
    uint64_t dest = spc_ju64(p, "destCid");
    int slot, acc, dslot, dacc, rc;
    pj_status_t st;
    (void)res;
    if (!dest) return spc_err(SPC_E_INVALID_PARAM, 0, "'destCid' required");
    if (dest == cid) return spc_err(SPC_E_INVALID_PARAM, 0, "destCid must differ from cid");
    if ((rc = need_call(cid, &slot, &acc))) return rc;
    if ((rc = need_call(dest, &dslot, &dacc))) return rc;
    if (spc_call_is_iax(cid) || spc_call_is_iax(dest)) return spc_err(SPC_E_UNSUPPORTED, 0, "attended transfer is not supported for IAX2 calls");
    st = pjsua_call_xfer_replaces(slot, dslot, spc_jbool(p, "requireReplaces", 1) ? 0 : PJSUA_XFER_NO_REQUIRE_REPLACES, NULL);
    if (st != PJ_SUCCESS) return map_pj(st, "xfer_replaces");
    return SPC_OK;
}

/* ---- topology ---- */
static int add_peer(uint64_t* list, int* n, uint64_t v)
{
    int i;
    for (i = 0; i < *n; i++) if (list[i] == v) return 0;
    if (*n >= SPC_MAX_PEERS) return -1;
    list[(*n)++] = v;
    return 0;
}
static void del_peer(uint64_t* list, int* n, uint64_t v)
{
    int i, j;
    for (i = 0; i < *n; i++) if (list[i] == v) { for (j = i; j < *n - 1; j++) list[j] = list[j + 1]; (*n)--; return; }
}

static void disconnect_pair(uint64_t a, uint64_t b)
{
    int sa, sb, x, ca, cb;
    if (spc_call_cid_to_slot(a, &sa, &x) != 0 || spc_call_cid_to_slot(b, &sb, &x) != 0) return;
    ca = spc_call_conf_slot(a, sa);
    cb = spc_call_conf_slot(b, sb);
    if (ca < 0 || cb < 0) return;
    pjsua_conf_disconnect(ca, cb);
    pjsua_conf_disconnect(cb, ca);
}

static int h_bridge(cJSON* p, cJSON** res)
{
    uint64_t a = spc_ju64(p, "a"), b = spc_ju64(p, "b");
    int on = 1, sa, sb, x, rc;
    spc_call *ca, *cb;
    (void)res;
    if (!a || !b || a == b) return spc_err(SPC_E_INVALID_PARAM, 0, "'a' and 'b' must be distinct calls");
    if (!spc_jbool_strict(p, "bridge", &on)) return spc_err(SPC_E_INVALID_PARAM, 0, "'bridge' (bool) required");
    if ((rc = need_call(a, &sa, &x)) || (rc = need_call(b, &sb, &x))) return rc;
    spc_registry_lock();
    ca = spc_call_find_locked(a); cb = spc_call_find_locked(b);
    if (!ca || !cb) { spc_registry_unlock(); return spc_err(SPC_E_NOT_FOUND, 0, "call not found"); }
    if (on) {
        if (add_peer(ca->bridged, &ca->nbr, b) || add_peer(cb->bridged, &cb->nbr, a)) {
            spc_registry_unlock();
            return spc_err(SPC_E_BUSY, 0, "too many bridges");
        }
    } else {
        del_peer(ca->bridged, &ca->nbr, b);
        del_peer(cb->bridged, &cb->nbr, a);
    }
    spc_registry_unlock();
    if (!on) disconnect_pair(a, b);
    spc_call_apply_topology();
    return SPC_OK;
}

static int h_detach_local(cJSON* p, cJSON** res)
{
    NEED_CID(cid);
    int slot, acc, rc;
    (void)res;
    int dv;
    if (!spc_jbool_strict(p, "detached", &dv)) return spc_err(SPC_E_INVALID_PARAM, 0, "'detached' (bool) required");
    if ((rc = need_call(cid, &slot, &acc))) return rc;
    set_flag(cid, 4, dv);
    spc_call_apply_topology();
    return SPC_OK;
}

static int read_cids(cJSON* p, uint64_t* out, int* n, int minn)
{
    cJSON* arr = spc_jarr(p, "cids");
    cJSON* e;
    int slot, acc;
    *n = 0;
    if (!arr) return spc_err(SPC_E_INVALID_PARAM, 0, "'cids' must be an array");
    cJSON_ArrayForEach(e, arr) {
        uint64_t v;
        int i, dup = 0;
        v = spc_jnum_to_id(e);
        if (!v) return spc_err(SPC_E_INVALID_PARAM, 0, "cids must be positive integers");
        for (i = 0; i < *n; i++) if (out[i] == v) dup = 1;
        if (dup) continue;
        if (*n >= SPC_MAX_PEERS) return spc_err(SPC_E_INVALID_PARAM, 0, "too many cids");
        if (spc_call_cid_to_slot(v, &slot, &acc) != 0) return spc_err(SPC_E_NOT_FOUND, 0, "call %llu not found", (unsigned long long)v);
        out[(*n)++] = v;
    }
    if (*n < minn) return spc_err(SPC_E_INVALID_PARAM, 0, "need at least %d distinct cids", minn);
    return SPC_OK;
}

static int h_conference(cJSON* p, cJSON** res)
{
    uint64_t ids[SPC_MAX_PEERS];
    int n, i, j, rc;
    (void)res;
    if ((rc = read_cids(p, ids, &n, 2))) return rc;
    for (i = 0; i < n; i++) {
        spc_call* c = spc_call_lock_find(ids[i]);
        int slot, held;
        if (!c) continue;
        slot = c->slot; held = c->held;
        c->detached = 0;
        spc_registry_unlock();
        spc_moh_disarm(ids[i]);
        c = spc_call_lock_find(ids[i]);
        if (!c) continue;
        for (j = 0; j < n; j++) if (j != i) add_peer(c->conf, &c->nconf, ids[j]);
        spc_registry_unlock();
        if (held) unhold_one(ids[i], slot);
    }
    spc_call_apply_topology();
    return SPC_OK;
}

static int h_unconference(cJSON* p, cJSON** res)
{
    uint64_t ids[SPC_MAX_PEERS];
    int n, i, j, rc;
    (void)res;
    if ((rc = read_cids(p, ids, &n, 1))) return rc;
    for (i = 0; i < n; i++) {
        spc_call* c = spc_call_lock_find(ids[i]);
        if (!c) continue;
        for (j = 0; j < n; j++) if (j != i) del_peer(c->conf, &c->nconf, ids[j]);
        spc_registry_unlock();
    }
    for (i = 0; i < n; i++) for (j = i + 1; j < n; j++) disconnect_pair(ids[i], ids[j]);
    spc_call_apply_topology();
    return SPC_OK;
}

/* ---- recording / playback ---- */
static int h_record_start(cJSON* p, cJSON** res)
{
    NEED_CID(cid);
    const char* file = spc_jstr(p, "file");
    const char* mix = spc_jstr(p, "mix");
    const char* fmts = spc_jstr(p, "format");
    int slot, acc, rc, mixv = 0, id = -1, fmt = SPC_REC_WAV_MONO, id2 = 0;
    spc_call* c;
    pj_str_t f;
    pj_status_t st;
    char err[200];
    if (!file || !file[0] || strlen(file) > 590) return spc_err(SPC_E_INVALID_PARAM, 0, "'file' required");
    if (mix) {
        if (spc_strieq(mix, "both")) mixv = 0;
        else if (spc_strieq(mix, "remote")) mixv = 1;
        else if (spc_strieq(mix, "local")) mixv = 2;
        else return spc_err(SPC_E_INVALID_PARAM, 0, "mix must be both|remote|local");
    }
    if (spc_jhas(p, "format") && !fmts) return spc_err(SPC_E_INVALID_PARAM, 0, "format must be wav|wavStereo|opus");
    if (fmts) {
        if (spc_strieq(fmts, "wav")) fmt = SPC_REC_WAV_MONO;
        else if (spc_strieq(fmts, "wavStereo")) fmt = SPC_REC_WAV_STEREO;
        else if (spc_strieq(fmts, "opus")) fmt = SPC_REC_OPUS;
        else return spc_err(SPC_E_INVALID_PARAM, 0, "format must be wav|wavStereo|opus");
    }
    if ((rc = need_call(cid, &slot, &acc))) return rc;
    c = spc_call_lock_find(cid);
    if (!c) return spc_err(SPC_E_NOT_FOUND, 0, "call gone");
    if (c->recording) { spc_registry_unlock(); return spc_err(SPC_E_ALREADY, 0, "already recording"); }
    spc_registry_unlock();
    if (fmt == SPC_REC_WAV_MONO) {
        f = spc_pjs(file);
        st = pjsua_recorder_create(&f, 0, NULL, 0, 0, &id);
        if (st != PJ_SUCCESS) return spc_pjerr(st, "pjsua_recorder_create");
    } else {
        int r2 = spc_rec_start(fmt, cid, mixv, file, &id2, err, sizeof(err));
        if (r2 != 0) return spc_err(r2 == -2 ? SPC_E_UNSUPPORTED : SPC_E_INVALID_PARAM, 0, "%s", err);
    }
    c = spc_call_lock_find(cid);
    if (!c) {
        if (id >= 0) pjsua_recorder_destroy(id);
        if (id2 > 0) spc_rec_stop(id2, NULL);
        return spc_err(SPC_E_NOT_FOUND, 0, "call gone");
    }
    c->rec_id = id; c->rec2_id = id2; c->rec_fmt = fmt; c->rec_mix = mixv; c->recording = 1;
    spc_strlcpy(c->rec_file, file, sizeof(c->rec_file));
    c->rec_start_ms = spc_mono_ms();
    spc_registry_unlock();
    spc_call_apply_topology();
    {
        cJSON* f2 = cJSON_CreateObject();
        cJSON_AddNumberToObject(f2, "cid", (double)cid);
        cJSON_AddBoolToObject(f2, "recording", 1);
        cJSON_AddStringToObject(f2, "file", file);
        cJSON_AddStringToObject(f2, "format", fmt == SPC_REC_OPUS ? "opus" : fmt == SPC_REC_WAV_STEREO ? "wavStereo" : "wav");
        spc_call_emit(cid, "call.recording", f2);
    }
    *res = cJSON_CreateObject();
    cJSON_AddStringToObject(*res, "file", file);
    return SPC_OK;
}

/* pjsua removes conference ports asynchronously; wait until the WAV header has been finalised */
static void wait_wav_final(const char* path, int ms)
{
    int64_t t0 = spc_mono_ms();
    for (;;) {
        unsigned char h[8];
        FILE* f = fopen(path, "rb");
        if (f) {
            size_t n = fread(h, 1, 8, f);
            fclose(f);
            if (n == 8 && (h[4] | h[5] | h[6] | h[7]) != 0) return;
        }
        if (spc_mono_ms() - t0 > ms) return;
        spc_sleep_ms(10);
    }
}

static int h_record_stop(cJSON* p, cJSON** res)
{
    NEED_CID(cid);
    spc_call* c;
    int id, id2, fmt, slot, acc, rc;
    char file[600];
    int64_t dur;
    spc_rec_result rr;
    int have_rr = 0;
    if ((rc = need_call(cid, &slot, &acc))) return rc;
    c = spc_call_lock_find(cid);
    if (!c) return spc_err(SPC_E_NOT_FOUND, 0, "call gone");
    if (!c->recording) { spc_registry_unlock(); return spc_err(SPC_E_INVALID_PARAM, 0, "not recording"); }
    id = c->rec_id; c->rec_id = -1; c->recording = 0;
    id2 = c->rec2_id; c->rec2_id = 0; fmt = c->rec_fmt;
    spc_strlcpy(file, c->rec_file, sizeof(file));
    dur = spc_mono_ms() - c->rec_start_ms;
    spc_registry_unlock();
    if (id >= 0) pjsua_recorder_destroy(id);
    if (id2 > 0 && spc_rec_stop(id2, &rr) == 0) have_rr = 1;
    else if (id >= 0) wait_wav_final(file, 1500);
    {
        cJSON* f2 = cJSON_CreateObject();
        cJSON_AddNumberToObject(f2, "cid", (double)cid);
        cJSON_AddBoolToObject(f2, "recording", 0);
        cJSON_AddStringToObject(f2, "file", file);
        spc_call_emit(cid, "call.recording", f2);
    }
    *res = cJSON_CreateObject();
    cJSON_AddStringToObject(*res, "file", file);
    if (have_rr) {
        cJSON_AddNumberToObject(*res, "durationMs", rr.durationMs);
        cJSON_AddStringToObject(*res, "format", rr.format);
        cJSON_AddNumberToObject(*res, "bytes", (double)rr.bytes);
    } else {
        int wd = spc_wav_duration_ms(file);
        int64_t bytes = spc_file_size(file);
        cJSON_AddNumberToObject(*res, "durationMs", wd >= 0 ? (double)wd : (double)dur);
        cJSON_AddStringToObject(*res, "format", fmt == SPC_REC_OPUS ? "opus" : fmt == SPC_REC_WAV_STEREO ? "wavStereo" : "wav");
        cJSON_AddNumberToObject(*res, "bytes", (double)(bytes < 0 ? 0 : bytes));
    }
    return SPC_OK;
}

static int h_play_file(cJSON* p, cJSON** res)
{
    NEED_CID(cid);
    const char* file = spc_jstr(p, "file");
    int slot, acc, rc, id = 0, loop = 0, mon = 0, mute = 0;
    double vol = 1.0;
    char err[200];
    if (!file || !file[0]) return spc_err(SPC_E_INVALID_PARAM, 0, "'file' required");
    if (spc_jhas(p, "loop") && !spc_jbool_strict(p, "loop", &loop)) return spc_err(SPC_E_INVALID_PARAM, 0, "'loop' must be a bool");
    if (spc_jhas(p, "localMonitor") && !spc_jbool_strict(p, "localMonitor", &mon)) return spc_err(SPC_E_INVALID_PARAM, 0, "'localMonitor' must be a bool");
    if (spc_jhas(p, "muteMic") && !spc_jbool_strict(p, "muteMic", &mute)) return spc_err(SPC_E_INVALID_PARAM, 0, "'muteMic' must be a bool");
    if (spc_jhas(p, "volume")) {
        vol = spc_jnum(p, "volume", -1.0);
        if (!(vol >= 0.0 && vol <= 4.0)) return spc_err(SPC_E_INVALID_PARAM, 0, "'volume' must be 0..4");
    }
    if ((rc = need_call(cid, &slot, &acc))) return rc;
    if (spc_player_start(cid, file, loop, (float)vol, mon, mute, 0, &id, err, sizeof(err)) != 0)
        return spc_err(SPC_E_INVALID_PARAM, 0, "%s", err);
    *res = cJSON_CreateObject();
    cJSON_AddNumberToObject(*res, "playId", id);
    return SPC_OK;
}

static int h_stop_file(cJSON* p, cJSON** res)
{
    NEED_CID(cid);
    int slot, acc, rc, id = 0, n;
    if ((rc = need_call(cid, &slot, &acc))) return rc;
    if (spc_jhas(p, "playId")) {
        if (!spc_jint_range(p, "playId", 0, 1, 0x7fffffff, &id)) return spc_err(SPC_E_INVALID_PARAM, 0, "'playId' must be a positive integer");
    }
    n = spc_player_stop(cid, id, "stopped");
    *res = cJSON_CreateObject();
    cJSON_AddNumberToObject(*res, "stopped", n);
    return SPC_OK;
}

/* ---- misc ---- */
static int h_update(cJSON* p, cJSON** res)
{
    NEED_CID(cid);
    int slot, acc, rc;
    pjsua_call_setting opt;
    pj_status_t st;
    (void)res;
    if ((rc = need_call(cid, &slot, &acc))) return rc;
    if (spc_call_is_iax(cid)) return spc_iax2_call_op(SPC_IAXOP_UNSUPPORTED, cid, p, res);
    pjsua_call_setting_default(&opt);
    opt.flag |= PJSUA_CALL_UPDATE_CONTACT;
    if (spc_jbool(p, "useUpdate", 0)) st = pjsua_call_update2(slot, &opt, NULL);
    else st = pjsua_call_reinvite2(slot, &opt, NULL);
    if (st != PJ_SUCCESS) return map_pj(st, "update");
    return SPC_OK;
}

static int h_send_request(cJSON* p, cJSON** res)
{
    NEED_CID(cid);
    const char* method = spc_jstr(p, "method");
    const char* body = spc_jstr(p, "body");
    const char* ct = spc_jstr(p, "contentType");
    int slot, acc, rc, i;
    pjsua_msg_data md;
    pj_pool_t* pool;
    pj_str_t m;
    pj_status_t st;
    (void)res;
    if (!method || !method[0] || strlen(method) > 20) return spc_err(SPC_E_INVALID_PARAM, 0, "'method' required");
    for (i = 0; method[i]; i++) if (!isupper((unsigned char)method[i]) && !isdigit((unsigned char)method[i]) && method[i] != '-') return spc_err(SPC_E_INVALID_PARAM, 0, "invalid method token");
    /* anything that changes dialog / INVITE-session state is owned by the dedicated call.* methods */
    if (strcmp(method, "INFO") && strcmp(method, "MESSAGE") && strcmp(method, "NOTIFY") && strcmp(method, "OPTIONS"))
        return spc_err(SPC_E_INVALID_PARAM, 0, "method '%s' is not allowed (INFO, MESSAGE, NOTIFY, OPTIONS only)", method);
    {
        char herr[120];
        if (!spc_validate_headers(spc_jobj(p, "headers"), herr, sizeof(herr))) return spc_err(SPC_E_INVALID_PARAM, 0, "%s", herr);
        if (ct && (!spc_str_clean(ct) || strlen(ct) > 100)) return spc_err(SPC_E_INVALID_PARAM, 0, "invalid contentType");
    }
    if ((rc = need_call(cid, &slot, &acc))) return rc;
    if (spc_call_is_iax(cid)) return spc_iax2_call_op(SPC_IAXOP_UNSUPPORTED, cid, p, res);
    pool = pjsua_pool_create("spcsr", 1024, 1024);
    spc_fill_msg_data(pool, &md, spc_jobj(p, "headers"));
    if (body) {
        pj_strdup2_with_null(pool, &md.msg_body, body);
        pj_strdup2_with_null(pool, &md.content_type, ct ? ct : "text/plain");
    }
    pj_strdup2_with_null(pool, &m, method);
    st = pjsua_call_send_request(slot, &m, &md);
    pj_pool_release(pool);
    if (st != PJ_SUCCESS) return map_pj(st, "send_request");
    return SPC_OK;
}

static int h_info(cJSON* p, cJSON** res)
{
    NEED_CID(cid);
    *res = spc_call_info_json(cid);
    if (!*res) return spc_err(SPC_E_NOT_FOUND, 0, "call %llu not found", (unsigned long long)cid);
    return SPC_OK;
}

static int h_stats(cJSON* p, cJSON** res)
{
    NEED_CID(cid);
    int err;
    *res = spc_call_stats_json(cid, &err);
    if (!*res) return err == SPC_E_NOT_FOUND ? spc_err(SPC_E_NOT_FOUND, 0, "call %llu not found", (unsigned long long)cid) : spc_err(SPC_E_BUSY, 0, "no active media stream");
    return SPC_OK;
}

static int h_list(cJSON* p, cJSON** res)
{
    cJSON* arr = cJSON_CreateArray();
    (void)p;
    spc_calls_list_json(arr);
    *res = cJSON_CreateObject();
    cJSON_AddItemToObject(*res, "calls", arr);
    return SPC_OK;
}

const spc_method spc_methods_call[] = {
    { "call.make", h_make, 0 }, { "call.answer", h_answer, 0 }, { "call.ring", h_ring, 0 },
    { "call.reject", h_reject, 0 }, { "call.redirect", h_redirect, 0 }, { "call.processRedirect", h_process_redirect, 0 },
    { "call.hangup", h_hangup, 0 }, { "call.hangupAll", h_hangup_all, 0 },
    { "call.hold", h_hold, 0 }, { "call.unhold", h_unhold, 0 }, { "call.mute", h_mute, 0 },
    { "call.setLevels", h_set_levels, 0 }, { "call.dtmf", h_dtmf, 0 },
    { "call.transfer", h_transfer, 0 }, { "call.transferAttended", h_transfer_attended, 0 },
    { "call.pickup", h_pickup, 0 }, { "call.bridge", h_bridge, 0 }, { "call.detachLocal", h_detach_local, 0 },
    { "call.conference", h_conference, 0 }, { "call.unconference", h_unconference, 0 },
    { "call.recordStart", h_record_start, 0 }, { "call.recordStop", h_record_stop, 0 },
    { "call.update", h_update, 0 }, { "call.sendRequest", h_send_request, 0 },
    { "call.info", h_info, 0 }, { "call.stats", h_stats, 0 }, { "call.list", h_list, 0 },
    { "call.playFile", h_play_file, 0 }, { "call.stopFile", h_stop_file, 0 },
    { NULL, NULL, 0 }
};
