/* spc_call.c: call registry (cid), pjsua call callbacks, topology, info/stats JSON. */
#include "spc_internal.h"
#include <pjsua-lib/pjsua_internal.h>
#include <math.h>
#include <ctype.h>

static spc_call* g_calls;
static spc_call* g_slot[PJSUA_MAX_CALLS];

/* ------------------------------------------------------------------ */
/* registry                                                            */
/* ------------------------------------------------------------------ */
spc_call* spc_call_find_locked(uint64_t cid)
{
    spc_call* c;
    for (c = g_calls; c; c = c->next) if (c->cid == cid) return c;
    return NULL;
}
spc_call* spc_call_lock_find(uint64_t cid)
{
    spc_call* c;
    spc_registry_lock();
    c = spc_call_find_locked(cid);
    if (!c) spc_registry_unlock();
    return c;
}
int spc_call_alive(uint64_t cid)
{
    int r;
    spc_registry_lock();
    r = spc_call_find_locked(cid) != NULL;
    spc_registry_unlock();
    return r;
}
int spc_call_cid_to_slot(uint64_t cid, int* slot, int* acc)
{
    spc_call* c = spc_call_lock_find(cid);
    if (!c) return -1;
    if (slot) *slot = c->slot;
    if (acc) *acc = c->acc;
    spc_registry_unlock();
    return 0;
}
int spc_calls_active(void)
{
    int n = 0;
    spc_call* c;
    spc_registry_lock();
    for (c = g_calls; c; c = c->next) n++;
    spc_registry_unlock();
    return n;
}
void spc_call_wait_gone(uint64_t cid, int ms)
{
    int64_t t0 = spc_mono_ms();
    while (spc_call_alive(cid) && spc_mono_ms() - t0 < ms) spc_sleep_ms(5);
}

/* Copies the identity of the call in a pjsua slot under the registry lock. The spc_call* itself must never be
 * dereferenced outside the lock: the terminal call.state callback frees it. Returns the cid (0 if none). */
static uint64_t slot_snapshot(int slot, int* acc)
{
    uint64_t cid = 0;
    if (slot < 0 || slot >= PJSUA_MAX_CALLS) return 0;
    spc_registry_lock();
    if (g_slot[slot]) { cid = g_slot[slot]->cid; if (acc) *acc = g_slot[slot]->acc; }
    spc_registry_unlock();
    return cid;
}

void spc_call_get_tags(int slot, char* l, size_t ln, char* r, size_t rn)
{
    pjsua_call* call = NULL;
    pjsip_dialog* dlg = NULL;
    if (l && ln) l[0] = 0;
    if (r && rn) r[0] = 0;
    if (acquire_call("spc_tags", slot, &call, &dlg) == PJ_SUCCESS) {
        if (dlg) {
            if (l && dlg->local.info) spc_pjcopy(l, ln, &dlg->local.info->tag);
            if (r && dlg->remote.info) spc_pjcopy(r, rn, &dlg->remote.info->tag);
            pjsip_dlg_dec_lock(dlg);
        }
    }
}

static int dlg_secure(int slot)
{
    pjsua_call* call = NULL;
    pjsip_dialog* dlg = NULL;
    int s = 0;
    if (acquire_call("spc_sec", slot, &call, &dlg) == PJ_SUCCESS) {
        if (dlg) { s = dlg->secure ? 1 : 0; pjsip_dlg_dec_lock(dlg); }
    }
    return s;
}

/* creates (registry unlocked on entry and exit); returns NULL if not creatable */
static spc_call* call_create(int slot, const pjsua_call_info* ci, int* created, int force)
{
    spc_call* c;
    void* ud;
    uint64_t parent = 0;
    spc_acc* ma;
    *created = 0;
    if (slot < 0 || slot >= PJSUA_MAX_CALLS) return NULL;
    spc_registry_lock();
    c = g_slot[slot];
    spc_registry_unlock();
    if (c) return c;      /* only called from callbacks that own the call's dialog lock: the entry cannot be freed concurrently */
    if (!force && ci->state == PJSIP_INV_STATE_DISCONNECTED) return NULL;
    ud = pjsua_call_get_user_data(slot);
    if (ud && ci->role == PJSIP_ROLE_UAC) parent = (uint64_t)(uintptr_t)ud;
    ma = spc_acc_from_id(ci->acc_id);
    c = (spc_call*)calloc(1, sizeof(*c));
    if (!c) return NULL;
    spc_registry_lock();
    if (g_slot[slot]) { spc_registry_unlock(); free(c); return g_slot[slot]; }
    c->cid = (uint64_t)(++G.cid_counter);
    c->slot = slot;
    c->acc = ci->acc_id;
    if (ma) { spc_strlcpy(c->uid, ma->uid, sizeof(c->uid)); spc_strlcpy(c->dtmf_method, ma->dtmf_method, sizeof(c->dtmf_method)); }
    else spc_strlcpy(c->dtmf_method, "rfc2833", sizeof(c->dtmf_method));
    c->role = ci->role == PJSIP_ROLE_UAC ? 0 : 1;
    spc_pjcopy(c->call_id, sizeof(c->call_id), &ci->call_id);
    c->rec_id = -1; c->player_id = -1; c->tg_slot = -1;
    c->created_ms = spc_mono_ms();
    spc_strlcpy(c->last_media, "none", sizeof(c->last_media));
    if (parent && spc_call_find_locked(parent)) c->parent_cid = parent;
    c->next = g_calls;
    g_calls = c;
    g_slot[slot] = c;
    spc_registry_unlock();
    pjsua_call_set_user_data(slot, (void*)(uintptr_t)c->cid);
    {
        char lt[64], rt[64];
        spc_call_get_tags(slot, lt, sizeof(lt), rt, sizeof(rt));
        spc_registry_lock();
        spc_strlcpy(c->local_tag, lt, sizeof(c->local_tag));
        spc_strlcpy(c->remote_tag, rt, sizeof(c->remote_tag));
        spc_registry_unlock();
    }
    *created = 1;
    return c;
}

/* Registry entry for a pjsua slot that was just created by pjsua_call_make_call(). With asynchronous media
 * initialisation (ICE/TURN) pjsua returns before on_call_state(CALLING) has fired, so create it here
 * (race-safe: call_create re-checks the slot under the lock). Returns 0 if the call is already gone. */
uint64_t spc_call_ensure_slot(int slot)
{
    pjsua_call_info ci;
    uint64_t cid = slot_snapshot(slot, NULL);
    int created;
    spc_call* c;
    if (cid) return cid;
    if (pjsua_call_get_info(slot, &ci) != PJ_SUCCESS || ci.state == PJSIP_INV_STATE_DISCONNECTED) return 0;
    c = call_create(slot, &ci, &created, 0);
    (void)c;
    return slot_snapshot(slot, NULL);
}

/* ------------------------------------------------------------------ */
/* JSON                                                                */
/* ------------------------------------------------------------------ */
static const char* state_name(pjsip_inv_state s, int role)
{
    switch (s) {
    case PJSIP_INV_STATE_NULL:
    case PJSIP_INV_STATE_CALLING: return "calling";
    case PJSIP_INV_STATE_INCOMING: return "incoming";
    case PJSIP_INV_STATE_EARLY: (void)role; return "early";
    case PJSIP_INV_STATE_CONNECTING: return "connecting";
    case PJSIP_INV_STATE_CONFIRMED: return "confirmed";
    case PJSIP_INV_STATE_DISCONNECTED: return "disconnected";
    default: return "calling";
    }
}
static const char* media_name(pjsua_call_media_status s)
{
    switch (s) {
    case PJSUA_CALL_MEDIA_ACTIVE: return "active";
    case PJSUA_CALL_MEDIA_LOCAL_HOLD: return "localHold";
    case PJSUA_CALL_MEDIA_REMOTE_HOLD: return "remoteHold";
    case PJSUA_CALL_MEDIA_ERROR: return "error";
    default: return "none";
    }
}

int spc_call_media_audio_idx(const pjsua_call_info* ci)
{
    unsigned i;
    for (i = 0; i < ci->media_cnt; i++)
        if (ci->media[i].type == PJMEDIA_TYPE_AUDIO && ci->media[i].status != PJSUA_CALL_MEDIA_NONE) return (int)i;
    for (i = 0; i < ci->media_cnt; i++)
        if (ci->media[i].type == PJMEDIA_TYPE_AUDIO) return (int)i;
    return -1;
}

static void codec_string(int slot, const pjsua_call_info* ci, char* out, size_t n)
{
    pjsua_stream_info psi;
    int idx = spc_call_media_audio_idx(ci);
    out[0] = 0;
    if (idx < 0 || ci->media[idx].status == PJSUA_CALL_MEDIA_NONE) return;
    if (pjsua_call_get_stream_info(slot, (unsigned)idx, &psi) != PJ_SUCCESS) return;
    if (psi.type != PJMEDIA_TYPE_AUDIO) return;
    snprintf(out, n, "%.*s/%u/%u", (int)psi.info.aud.fmt.encoding_name.slen, psi.info.aud.fmt.encoding_name.ptr,
             psi.info.aud.fmt.clock_rate, psi.info.aud.fmt.channel_cnt);
}

/* srtp/ice details from the media transport */
static void transport_details(int slot, const pjsua_call_info* ci, int* srtp, char* crypto, size_t cn, char* ice_state, size_t in_, char* lt, char* rt, size_t tn)
{
    pjmedia_transport_info ti;
    int idx = spc_call_media_audio_idx(ci);
    unsigned i;
    *srtp = 0; crypto[0] = 0;
    spc_strlcpy(ice_state, "none", in_); lt[0] = rt[0] = 0;
    if (idx < 0) return;
    pjmedia_transport_info_init(&ti);
    if (pjsua_call_get_med_transport_info(slot, (unsigned)idx, &ti) != PJ_SUCCESS) return;
    for (i = 0; i < ti.specific_info_cnt; i++) {
        if (ti.spc_info[i].type == PJMEDIA_TRANSPORT_TYPE_SRTP) {
            pjmedia_srtp_info* si = (pjmedia_srtp_info*)ti.spc_info[i].buffer;
            if (si->active) { *srtp = 1; spc_pjcopy(crypto, cn, &si->tx_policy.name); }
        } else if (ti.spc_info[i].type == PJMEDIA_TRANSPORT_TYPE_ICE) {
            pjmedia_ice_transport_info* ii = (pjmedia_ice_transport_info*)ti.spc_info[i].buffer;
            if (ii->sess_state == PJ_ICE_STRANS_STATE_RUNNING || ii->sess_state == PJ_ICE_STRANS_STATE_READY) {
                spc_strlcpy(ice_state, ii->sess_state == PJ_ICE_STRANS_STATE_READY ? "completed" : "none", in_);
            } else if (ii->sess_state == PJ_ICE_STRANS_STATE_FAILED) spc_strlcpy(ice_state, "failed", in_);
            if (ii->comp_cnt > 0) {
                spc_strlcpy(lt, pj_ice_get_cand_type_name(ii->comp[0].lcand_type), tn);
                spc_strlcpy(rt, pj_ice_get_cand_type_name(ii->comp[0].rcand_type), tn);
            }
        }
    }
}

/* registry lock must be held */
static cJSON* info_locked(spc_call* c, const pjsua_call_info* ci)
{
    cJSON* o = cJSON_CreateObject();
    char disp[128], uri[256], user[128], luri[256];
    char tmp[512];
    int i;
    cJSON_AddNumberToObject(o, "cid", (double)c->cid);
    cJSON_AddNumberToObject(o, "call", c->slot);
    cJSON_AddNumberToObject(o, "acc", c->acc);
    cJSON_AddStringToObject(o, "uid", c->uid);
    cJSON_AddStringToObject(o, "proto", "sip");
    cJSON_AddStringToObject(o, "role", c->role ? "callee" : "caller");
    cJSON_AddStringToObject(o, "state", state_name(ci->state, c->role));
    cJSON_AddNumberToObject(o, "stateCode", ci->last_status);
    spc_jadd_pjstr(o, "stateReason", &ci->last_status_text);
    cJSON_AddNumberToObject(o, "lastCode", ci->last_status);
    spc_pjcopy(tmp, sizeof(tmp), &ci->remote_info);
    spc_parse_nameaddr(tmp, disp, sizeof(disp), uri, sizeof(uri), user, sizeof(user));
    cJSON_AddStringToObject(o, "remoteUri", uri);
    spc_jadd_pjstr(o, "remoteContact", &ci->remote_contact);
    cJSON_AddStringToObject(o, "remoteDisplay", disp);
    cJSON_AddStringToObject(o, "remoteUser", user);
    spc_pjcopy(tmp, sizeof(tmp), &ci->local_info);
    spc_parse_nameaddr(tmp, NULL, 0, luri, sizeof(luri), NULL, 0);
    cJSON_AddStringToObject(o, "localUri", luri);
    cJSON_AddStringToObject(o, "callId", c->call_id);
    cJSON_AddStringToObject(o, "localTag", c->local_tag);
    cJSON_AddStringToObject(o, "remoteTag", c->remote_tag);
    cJSON_AddStringToObject(o, "media", c->last_media);
    cJSON_AddStringToObject(o, "codec", c->last_codec);
    cJSON_AddBoolToObject(o, "srtp", c->last_srtp);
    cJSON_AddBoolToObject(o, "secureSignaling", c->last_srtp >= 2);
    cJSON_AddBoolToObject(o, "muted", c->muted);
    cJSON_AddBoolToObject(o, "recording", c->recording);
    cJSON_AddBoolToObject(o, "detached", c->detached);
    cJSON_AddBoolToObject(o, "held", c->held);
    {
        cJSON* a = cJSON_AddArrayToObject(o, "conferenceWith");
        for (i = 0; i < c->nconf; i++) cJSON_AddItemToArray(a, cJSON_CreateNumber((double)c->conf[i]));
        a = cJSON_AddArrayToObject(o, "bridgedWith");
        for (i = 0; i < c->nbr; i++) cJSON_AddItemToArray(a, cJSON_CreateNumber((double)c->bridged[i]));
    }
    cJSON_AddNumberToObject(o, "connectMs", (double)(ci->connect_duration.sec * 1000 + ci->connect_duration.msec));
    cJSON_AddNumberToObject(o, "totalMs", (double)(ci->total_duration.sec * 1000 + ci->total_duration.msec));
    if (c->parent_cid) cJSON_AddNumberToObject(o, "transferFrom", (double)c->parent_cid);
    return o;
}

cJSON* spc_call_info_json(uint64_t cid)
{
    int slot, acc;
    pjsua_call_info ci;
    spc_call* c;
    cJSON* o;
    if (spc_call_cid_to_slot(cid, &slot, &acc) != 0) return NULL;
    if (slot >= SPC_ID_IAX_BASE) return spc_iax2_call_info_json(cid);
    if (pjsua_call_get_info(slot, &ci) != PJ_SUCCESS) return NULL;
    c = spc_call_lock_find(cid);
    if (!c) return NULL;
    o = info_locked(c, &ci);
    spc_registry_unlock();
    return o;
}

void spc_calls_list_json(cJSON* arr)
{
    uint64_t ids[PJSUA_MAX_CALLS];
    int n = 0, i;
    spc_call* c;
    spc_registry_lock();
    for (c = g_calls; c && n < PJSUA_MAX_CALLS; c = c->next) ids[n++] = c->cid;
    spc_registry_unlock();
    for (i = n - 1; i >= 0; i--) {
        cJSON* o = spc_call_info_json(ids[i]);
        if (o) cJSON_AddItemToArray(arr, o);
    }
}

void spc_call_emit(uint64_t cid, const char* ev, cJSON* f)
{
    spc_registry_lock();
    if (spc_call_find_locked(cid)) spc_emit(ev, f);
    else if (f) cJSON_Delete(f);
    spc_registry_unlock();
}

/* ------------------------------------------------------------------ */
/* auto-answer hints                                                   */
/* ------------------------------------------------------------------ */
static cJSON* autoanswer_hint(const cJSON* h)
{
    const char* v;
    cJSON* o = NULL;
    int after = -1, require = 0;
    const char* source = NULL;
    if ((v = spc_jstr(h, "Call-Info")) != NULL) {
        const char* p = v;
        while ((p = strstr(p, "answer-after")) != NULL) {
            p += 12;
            while (*p == ' ') p++;
            if (*p == '=') { after = atoi(p + 1); source = "callInfo"; break; }
        }
    }
    if (!source && (v = spc_jstr(h, "Alert-Info")) != NULL) {
        char low[300];
        size_t i;
        for (i = 0; v[i] && i < sizeof(low) - 1; i++) low[i] = (char)tolower((unsigned char)v[i]);
        low[i] = 0;
        if (strstr(low, "info=alert-autoanswer") || strstr(low, "info=auto answer")) {
            const char* d = strstr(low, "delay=");
            after = d ? atoi(d + 6) : 0;
            source = "alertInfo";
        } else if (strstr(low, "auto answer") || strstr(low, "ring answer") || strstr(low, "intercom")) {
            after = 0; source = "alertInfo";
        }
    }
    if (!source && (v = spc_jstr(h, "Answer-Mode")) != NULL) {
        if (spc_strnieq(v, "auto", 4)) {
            after = 0; source = "answerMode";
            if (strstr(v, "require") || strstr(v, "Require")) require = 1;
        }
    }
    if (source) {
        o = cJSON_CreateObject();
        cJSON_AddNumberToObject(o, "afterSec", after < 0 ? 0 : after);
        cJSON_AddStringToObject(o, "source", source);
        cJSON_AddBoolToObject(o, "require", require);
    }
    return o;
}

/* ------------------------------------------------------------------ */
/* timers                                                              */
/* ------------------------------------------------------------------ */
void spc_call_schedule_timer(void (*cb)(void*), uint64_t cid, unsigned ms)
{
    pjsua_schedule_timer2(cb, (void*)(uintptr_t)cid, ms);
}

static void timer_auto180(void* ud)
{
    uint64_t cid = (uint64_t)(uintptr_t)ud;
    spc_call* c;
    int slot, send = 0;
    pjsua_call_info ci;
    c = spc_call_lock_find(cid);
    if (!c) return;
    slot = c->slot;
    if (!c->responded && !c->ring_sent) { c->ring_sent = 1; send = 1; }
    spc_registry_unlock();
    if (!send) return;
    if (pjsua_call_get_info(slot, &ci) != PJ_SUCCESS || ci.state != PJSIP_INV_STATE_INCOMING) return;
    pjsua_call_answer(slot, 180, NULL, NULL);
}

static void timer_unattended(void* ud)
{
    uint64_t cid = (uint64_t)(uintptr_t)ud;
    spc_call* c;
    int slot, ok = 0;
    pjsua_call_info ci;
    c = spc_call_lock_find(cid);
    if (!c) return;
    slot = c->slot;
    ok = !c->responded;
    spc_registry_unlock();
    if (!ok || spc_sink_attached()) return;
    if (pjsua_call_get_info(slot, &ci) != PJ_SUCCESS ||
        (ci.state != PJSIP_INV_STATE_INCOMING && ci.state != PJSIP_INV_STATE_EARLY)) return;
    pjsua_call_answer(slot, 480, NULL, NULL);
}

/* ------------------------------------------------------------------ */
/* topology                                                            */
/* ------------------------------------------------------------------ */
typedef struct {
    uint64_t cid;
    int slot, cslot, active;
    int muted, held, detached;
    int nconf, nbr;
    uint64_t conf[SPC_MAX_PEERS], bridged[SPC_MAX_PEERS];
    int rec_id, rec_mix, player_id, tg_slot;
} topo_ent;

static int ent_find(topo_ent* e, int n, uint64_t cid)
{
    int i;
    for (i = 0; i < n; i++) if (e[i].cid == cid) return i;
    return -1;
}

static void conn(int src, int dst, int want)
{
    if (src < 0 || dst < 0) return;
    if (want) {
        pj_status_t st = pjsua_conf_connect(src, dst);
        if (st != PJ_SUCCESS && (src == 0 || dst == 0) && spc_media_on_connect_error(st))
            pjsua_conf_connect(src, dst);
    } else pjsua_conf_disconnect(src, dst);
}

void spc_call_apply_topology(void)
{
    topo_ent e[PJSUA_MAX_CALLS];
    int n = 0, i, j, k;
    spc_call* c;
    spc_registry_lock();
    for (c = g_calls; c && n < PJSUA_MAX_CALLS; c = c->next) {
        topo_ent* t = &e[n++];
        t->cid = c->cid; t->slot = c->slot; t->muted = c->muted; t->held = c->held; t->detached = c->detached;
        t->nconf = c->nconf; memcpy(t->conf, c->conf, sizeof(t->conf));
        t->nbr = c->nbr; memcpy(t->bridged, c->bridged, sizeof(t->bridged));
        t->rec_id = c->rec_id; t->rec_mix = c->rec_mix; t->player_id = c->player_id; t->tg_slot = c->tg_slot;
    }
    spc_registry_unlock();
    for (i = 0; i < n; i++) {
        pjsua_call_info ci;
        e[i].cslot = -1; e[i].active = 0;
        if (e[i].slot >= SPC_ID_IAX_BASE) {
            int act = 0, cs = -1;
            if (spc_iax2_call_conf(e[i].cid, &cs, &act) == 0) { e[i].cslot = cs; e[i].active = (act && cs >= 0); }
            continue;
        }
        if (pjsua_call_get_info(e[i].slot, &ci) != PJ_SUCCESS) continue;
        e[i].cslot = ci.conf_slot;
        e[i].active = (ci.media_status == PJSUA_CALL_MEDIA_ACTIVE && ci.conf_slot >= 0);
    }
    for (i = 0; i < n; i++) {
        topo_ent* t = &e[i];
        int local_ok;
        if (t->cslot < 0) continue;
        local_ok = t->active && !t->detached && !t->held;
        conn(0, t->cslot, local_ok && !t->muted);
        conn(t->cslot, 0, local_ok);
        if (t->rec_id >= 0) {
            int rp = pjsua_recorder_get_conf_port(t->rec_id);
            if (rp >= 0) {
                conn(t->cslot, rp, t->active && (t->rec_mix == 0 || t->rec_mix == 1));
                conn(0, rp, (t->rec_mix == 0 || t->rec_mix == 2) && !t->muted && !t->detached);
            }
        }
        if (t->player_id >= 0) {
            int pp = pjsua_player_get_conf_port(t->player_id);
            if (pp >= 0) conn(pp, t->cslot, t->active && !t->held);
        }
        if (t->tg_slot >= 0) conn(t->tg_slot, t->cslot, t->active);
        for (k = 0; k < t->nconf + t->nbr; k++) {
            uint64_t peer = k < t->nconf ? t->conf[k] : t->bridged[k - t->nconf];
            j = ent_find(e, n, peer);
            if (j < 0 || e[j].cslot < 0) continue;
            conn(t->cslot, e[j].cslot, t->active && e[j].active && !t->held && !e[j].held);
        }
    }
}

void spc_call_apply_media_all(void) { spc_call_apply_topology(); }

/* ------------------------------------------------------------------ */
/* media resources cleanup                                             */
/* ------------------------------------------------------------------ */
void spc_call_cleanup_media(spc_call* c)
{
    int rec = -1, pl = -1, tgs = -1, was_rec = 0;
    pjmedia_port* tg = NULL;
    pj_pool_t* tgp = NULL;
    char file[600];
    spc_registry_lock();
    rec = c->rec_id; c->rec_id = -1;
    was_rec = c->recording; c->recording = 0;
    pl = c->player_id; c->player_id = -1;
    tgs = c->tg_slot; c->tg_slot = -1;
    tg = c->tg_port; c->tg_port = NULL;
    tgp = c->tg_pool; c->tg_pool = NULL;
    spc_strlcpy(file, c->rec_file, sizeof(file));
    spc_registry_unlock();
    if (rec >= 0) pjsua_recorder_destroy(rec);
    if (was_rec) {
        cJSON* f = cJSON_CreateObject();
        cJSON_AddNumberToObject(f, "cid", (double)c->cid);
        cJSON_AddBoolToObject(f, "recording", 0);
        cJSON_AddStringToObject(f, "file", file);
        spc_call_emit(c->cid, "call.recording", f);
    }
    if (pl >= 0) pjsua_player_destroy(pl);
    if (tgs >= 0) pjsua_conf_remove_port(tgs);
    if (tg) {
        spc_mutex_lock(&G.tg_mtx);          /* serialises with inband DTMF playing on the same port */
        pjmedia_port_destroy(tg);
        spc_mutex_unlock(&G.tg_mtx);
    }
    if (tgp) pj_pool_release(tgp);
}

/* ------------------------------------------------------------------ */
/* pjsua callbacks                                                     */
/* ------------------------------------------------------------------ */
static void emit_incoming(spc_call* c, const pjsua_call_info* ci, pjsip_rx_data* rdata)
{
    cJSON* o;
    cJSON* hdr = rdata ? spc_headers_from_rdata(rdata) : cJSON_CreateObject();
    cJSON* hint = autoanswer_hint(hdr);
    uint64_t repl = 0;
    spc_registry_lock();
    c->incoming_emitted = 1;
    if (rdata && rdata->msg_info.msg) {
        const char* rv = spc_jstr(hdr, "Replaces");
        if (rv) {
            char cid_[128];
            size_t l = strcspn(rv, ";");
            spc_call* o2;
            if (l >= sizeof(cid_)) l = sizeof(cid_) - 1;
            memcpy(cid_, rv, l); cid_[l] = 0;
            for (o2 = g_calls; o2; o2 = o2->next)
                if (o2 != c && strcmp(o2->call_id, cid_) == 0) { repl = o2->cid; break; }
        }
    }
    o = info_locked(c, ci);
    cJSON_AddItemToObject(o, "headers", hdr);
    if (repl) cJSON_AddNumberToObject(o, "replacesCid", (double)repl);
    if (hint) cJSON_AddItemToObject(o, "autoAnswerHint", hint);
    spc_emit("call.incoming", o);
    spc_registry_unlock();
}

static void cb_incoming_call(pjsua_acc_id acc, pjsua_call_id call_id, pjsip_rx_data* rdata)
{
    pjsua_call_info ci;
    spc_call* c;
    int created;
    (void)acc;
    if (pjsua_call_get_info(call_id, &ci) != PJ_SUCCESS) return;
    c = call_create(call_id, &ci, &created, 1);
    if (!c) { pjsua_call_hangup(call_id, 503, NULL, NULL); return; }
    if (!created) return;
    emit_incoming(c, &ci, rdata);
    if (G.incoming_auto_ring_ms > 0)
        spc_call_schedule_timer(timer_auto180, c->cid, (unsigned)G.incoming_auto_ring_ms);
    if (G.incoming_unattended_ms > 0 && !spc_sink_attached())
        spc_call_schedule_timer(timer_unattended, c->cid, (unsigned)G.incoming_unattended_ms);
}

static void cb_call_state(pjsua_call_id call_id, pjsip_event* e)
{
    pjsua_call_info ci;
    spc_call* c;
    int created;
    int terminal;
    cJSON* o;
    (void)e;
    if (pjsua_call_get_info(call_id, &ci) != PJ_SUCCESS) return;
    c = call_create(call_id, &ci, &created, 0);
    if (!c) return;
    if (created && c->role == 1 && !c->incoming_emitted) emit_incoming(c, &ci, NULL);
    terminal = (ci.state == PJSIP_INV_STATE_DISCONNECTED);
    if (!created || ci.state != PJSIP_INV_STATE_NULL) {
        int need;
        spc_registry_lock();
        need = c->local_tag[0] == 0 || c->remote_tag[0] == 0;
        spc_registry_unlock();
        if (need) {
            char lt[64], rt[64];
            spc_call_get_tags(call_id, lt, sizeof(lt), rt, sizeof(rt));
            spc_registry_lock();
            spc_strlcpy(c->local_tag, lt, sizeof(c->local_tag));
            spc_strlcpy(c->remote_tag, rt, sizeof(c->remote_tag));
            spc_registry_unlock();
        }
    }
    if (terminal) spc_call_cleanup_media(c);
    spc_registry_lock();
    if (c->ended) { spc_registry_unlock(); return; }
    if (terminal) {
        spc_call* p;
        int i, j;
        c->ended = 1;
        o = info_locked(c, &ci);
        spc_emit("call.state", o);
        /* unlink */
        if (g_calls == c) g_calls = c->next;
        else for (p = g_calls; p; p = p->next) if (p->next == c) { p->next = c->next; break; }
        g_slot[c->slot] = NULL;
        for (p = g_calls; p; p = p->next) {
            for (i = 0; i < p->nconf; i++) if (p->conf[i] == c->cid) { for (j = i; j < p->nconf - 1; j++) p->conf[j] = p->conf[j + 1]; p->nconf--; i--; }
            for (i = 0; i < p->nbr; i++) if (p->bridged[i] == c->cid) { for (j = i; j < p->nbr - 1; j++) p->bridged[j] = p->bridged[j + 1]; p->nbr--; i--; }
        }
        spc_registry_unlock();
        free(c);
        return;
    }
    o = info_locked(c, &ci);
    spc_emit("call.state", o);
    spc_registry_unlock();
}

static void timer_topology(void* ud)
{
    (void)ud;
    if (G.started) spc_call_apply_topology();
}

static void cb_call_media_state(pjsua_call_id call_id)
{
    pjsua_call_info ci;
    uint64_t cid = slot_snapshot(call_id, NULL);
    spc_call* c;
    char codec[48], crypto[48], ice[16], lt[16], rt[16];
    int srtp, secure, changed = 0;
    const char* mname;
    if (!cid) return;
    if (pjsua_call_get_info(call_id, &ci) != PJ_SUCCESS) return;
    mname = media_name(ci.media_status);
    codec_string(call_id, &ci, codec, sizeof(codec));
    transport_details(call_id, &ci, &srtp, crypto, sizeof(crypto), ice, sizeof(ice), lt, rt, sizeof(lt));
    secure = dlg_secure(call_id);
    if (ci.media_status == PJSUA_CALL_MEDIA_ACTIVE) spc_media_on_call_media(call_id, 1);
    pjsua_schedule_timer2(&timer_topology, NULL, 0);     /* full re-apply happens off the dialog lock (m7) */
    spc_registry_lock();
    c = spc_call_find_locked(cid);
    if (!c || c->ended) { spc_registry_unlock(); return; }
    {
        int ns = srtp ? (secure ? 2 : 1) : 0;
        if (strcmp(c->last_media, mname) != 0 || strcmp(c->last_codec, codec) != 0 || c->last_srtp != ns) changed = 1;
        spc_strlcpy(c->last_media, mname, sizeof(c->last_media));
        spc_strlcpy(c->last_codec, codec, sizeof(c->last_codec));
        c->last_srtp = ns;
    }
    if (changed) {
        cJSON* f = cJSON_CreateObject();
        cJSON* icej;
        cJSON_AddNumberToObject(f, "cid", (double)c->cid);
        cJSON_AddStringToObject(f, "media", mname);
        cJSON_AddStringToObject(f, "codec", codec);
        cJSON_AddBoolToObject(f, "srtp", srtp);
        spc_jadd_str(f, "crypto", crypto[0] ? crypto : NULL);
        cJSON_AddBoolToObject(f, "secureSignaling", srtp && secure);
        icej = cJSON_AddObjectToObject(f, "ice");
        cJSON_AddStringToObject(icej, "state", ice);
        cJSON_AddStringToObject(icej, "localType", lt);
        cJSON_AddStringToObject(icej, "remoteType", rt);
        spc_emit("call.media", f);
    }
    spc_registry_unlock();
}

static void cb_sdp_created(pjsua_call_id call_id, pjmedia_sdp_session* sdp, pj_pool_t* pool, const pjmedia_sdp_session* rem)
{
    pjsua_call_info ci;
    (void)pool; (void)rem;
    if (pjsua_call_get_info(call_id, &ci) != PJ_SUCCESS) return;
    spc_account_filter_codecs_for(ci.acc_id, sdp);
}

static void cb_dtmf_event(pjsua_call_id call_id, const pjsua_dtmf_event* ev)
{
    uint64_t cid = slot_snapshot(call_id, NULL);
    cJSON* f;
    char d[2];
    if (!cid || !ev) return;
    d[0] = (char)ev->digit; d[1] = 0;
    f = cJSON_CreateObject();
    cJSON_AddNumberToObject(f, "cid", (double)cid);
    cJSON_AddStringToObject(f, "digit", d);
    cJSON_AddStringToObject(f, "method", ev->method == PJSUA_DTMF_METHOD_SIP_INFO ? "info" : "rfc2833");
    cJSON_AddNumberToObject(f, "durationMs", ev->duration == PJSUA_UNKNOWN_DTMF_DURATION ? 0 : (double)ev->duration);
    spc_call_emit(cid, "call.dtmf", f);
}

static void cb_transfer_request2(pjsua_call_id call_id, const pj_str_t* dst, pjsip_status_code* code, pjsua_call_setting* opt)
{
    int acc = -1;
    uint64_t cid = slot_snapshot(call_id, &acc);
    spc_acc* ma;
    cJSON* f;
    char rb[256];
    spc_call* c;
    (void)opt;
    if (!cid) return;
    ma = spc_acc_from_id(acc);
    if (ma && ma->refer_reject) *code = PJSIP_SC_DECLINE;
    rb[0] = 0;
    c = spc_call_lock_find(cid);
    if (c) { spc_strlcpy(rb, c->referred_by, sizeof(rb)); c->referred_by[0] = 0; spc_registry_unlock(); }
    f = cJSON_CreateObject();
    cJSON_AddNumberToObject(f, "cid", (double)cid);
    spc_jadd_pjstr(f, "target", dst);
    cJSON_AddStringToObject(f, "referredBy", rb);
    cJSON_AddBoolToObject(f, "accepted", *code / 100 == 2);
    spc_call_emit(cid, "call.transferRequest", f);
}

static void cb_transfer_status(pjsua_call_id call_id, int st_code, const pj_str_t* st_text, pj_bool_t final, pj_bool_t* cont)
{
    uint64_t cid = slot_snapshot(call_id, NULL);
    cJSON* f;
    (void)cont;
    if (!cid) return;
    f = cJSON_CreateObject();
    cJSON_AddNumberToObject(f, "cid", (double)cid);
    cJSON_AddNumberToObject(f, "code", st_code);
    spc_jadd_pjstr(f, "reason", st_text);
    cJSON_AddBoolToObject(f, "final", final ? 1 : 0);
    spc_call_emit(cid, "call.transferStatus", f);
}

static void cb_call_replaced(pjsua_call_id old_id, pjsua_call_id new_id)
{
    pjsua_call_info ci;
    uint64_t ocid = slot_snapshot(old_id, NULL), ncid = slot_snapshot(new_id, NULL);
    cJSON* f;
    int created;
    if (!ncid && pjsua_call_get_info(new_id, &ci) == PJ_SUCCESS) {
        spc_call* n = call_create(new_id, &ci, &created, 1);
        if (n && created && n->role == 1 && !n->incoming_emitted) emit_incoming(n, &ci, NULL);
        ncid = slot_snapshot(new_id, NULL);
    }
    if (!ocid || !ncid) return;
    f = cJSON_CreateObject();
    cJSON_AddNumberToObject(f, "oldCid", (double)ocid);
    cJSON_AddNumberToObject(f, "newCid", (double)ncid);
    spc_registry_lock();
    spc_emit("call.replaced", f);
    spc_registry_unlock();
}

static void cb_call_tsx_state(pjsua_call_id call_id, pjsip_transaction* tsx, pjsip_event* e)
{
    static const pj_str_t RB = { "Referred-By", 11 };
    static const pj_str_t RBS = { "b", 1 };
    uint64_t cid;
    pjsip_rx_data* rd;
    pjsip_generic_string_hdr* h;
    spc_call* c;
    if (!tsx || !e || e->type != PJSIP_EVENT_TSX_STATE || e->body.tsx_state.type != PJSIP_EVENT_RX_MSG) return;
    if (tsx->role != PJSIP_ROLE_UAS || pjsip_method_cmp(&tsx->method, pjsip_get_refer_method()) != 0) return;
    rd = e->body.tsx_state.src.rdata;
    if (!rd || !rd->msg_info.msg) return;
    h = (pjsip_generic_string_hdr*)pjsip_msg_find_hdr_by_name(rd->msg_info.msg, &RB, NULL);
    if (!h) h = (pjsip_generic_string_hdr*)pjsip_msg_find_hdr_by_name(rd->msg_info.msg, &RBS, NULL);
    cid = slot_snapshot(call_id, NULL);
    if (!cid) return;
    c = spc_call_lock_find(cid);
    if (!c) return;
    if (h) spc_pjcopy(c->referred_by, sizeof(c->referred_by), &h->hvalue);
    else c->referred_by[0] = 0;
    spc_registry_unlock();
}

static pjsip_redirect_op cb_redirected(pjsua_call_id call_id, const pjsip_uri* target, const pjsip_event* e)
{
    int acc = -1;
    uint64_t cid = slot_snapshot(call_id, &acc);
    spc_call* c;
    spc_acc* ma;
    int mode = 0;
    char buf[512];
    int code = 302;
    cJSON* f;
    if (!cid) return PJSIP_REDIRECT_REJECT;
    ma = spc_acc_from_id(acc);
    if (ma) mode = ma->redirect;
    if (mode == 2) return PJSIP_REDIRECT_REJECT;
    if (mode == 0) return PJSIP_REDIRECT_ACCEPT_REPLACE;
    buf[0] = 0;
    {
        int n = pjsip_uri_print(PJSIP_URI_IN_REQ_URI, target, buf, sizeof(buf) - 1);
        if (n < 0) n = 0;
        buf[n] = 0;
    }
    if (e && e->type == PJSIP_EVENT_TSX_STATE && e->body.tsx_state.type == PJSIP_EVENT_RX_MSG) {
        pjsip_rx_data* rd = e->body.tsx_state.src.rdata;
        if (rd && rd->msg_info.msg && rd->msg_info.msg->type == PJSIP_RESPONSE_MSG) code = rd->msg_info.msg->line.status.code;
    }
    spc_registry_lock();
    c = spc_call_find_locked(cid);
    if (!c) { spc_registry_unlock(); return PJSIP_REDIRECT_REJECT; }
    c->redirect_pending = 1;
    f = cJSON_CreateObject();
    cJSON_AddNumberToObject(f, "cid", (double)cid);
    cJSON_AddStringToObject(f, "target", buf);
    cJSON_AddNumberToObject(f, "code", code);
    spc_emit("call.redirected", f);
    spc_registry_unlock();
    return PJSIP_REDIRECT_PENDING;
}

void spc_call_install_callbacks(pjsua_callback* cb)
{
    cb->on_incoming_call = &cb_incoming_call;
    cb->on_call_state = &cb_call_state;
    cb->on_call_media_state = &cb_call_media_state;
    cb->on_call_sdp_created = &cb_sdp_created;
    cb->on_dtmf_event = &cb_dtmf_event;
    cb->on_call_transfer_request2 = &cb_transfer_request2;
    cb->on_call_transfer_status = &cb_transfer_status;
    cb->on_call_replaced = &cb_call_replaced;
    cb->on_call_redirected = &cb_redirected;
    cb->on_call_tsx_state = &cb_call_tsx_state;
}

/* ------------------------------------------------------------------ */
/* lifecycle                                                           */
/* ------------------------------------------------------------------ */
void spc_call_hangup_all_and_wait(int ms)
{
    int64_t t0 = spc_mono_ms();
    if (spc_calls_active() == 0) return;
    spc_iax2_hangup_all();
    pjsua_call_hangup_all();
    while (spc_calls_active() > 0 && spc_mono_ms() - t0 < ms) spc_sleep_ms(10);
}

void spc_call_cleanup_all(void)
{
    spc_call* c;
    spc_registry_lock();
    c = g_calls;
    g_calls = NULL;
    memset(g_slot, 0, sizeof(g_slot));
    while (c) {
        spc_call* n = c->next;
        cJSON* f = cJSON_CreateObject();
        cJSON_AddNumberToObject(f, "cid", (double)c->cid);
        cJSON_AddNumberToObject(f, "call", c->slot);
        cJSON_AddNumberToObject(f, "acc", c->acc);
        cJSON_AddStringToObject(f, "uid", c->uid);
        cJSON_AddStringToObject(f, "proto", c->proto ? "iax2" : "sip");
        cJSON_AddStringToObject(f, "role", c->role ? "callee" : "caller");
        cJSON_AddStringToObject(f, "state", "disconnected");
        cJSON_AddNumberToObject(f, "stateCode", 487);
        cJSON_AddStringToObject(f, "stateReason", "Engine stopped");
        cJSON_AddNumberToObject(f, "lastCode", 487);
        spc_emit("call.state", f);
        free(c);
        c = n;
    }
    spc_registry_unlock();
}

/* ------------------------------------------------------------------ */
/* stats                                                               */
/* ------------------------------------------------------------------ */
static void ma_add(cJSON* o, const char* k, const pj_math_stat* s, double scale)
{
    (void)o; (void)k; (void)s; (void)scale;
}

cJSON* spc_call_stats_json(uint64_t cid, int* err)
{
    int slot, acc, idx;
    pjsua_call_info ci;
    pjsua_stream_stat st;
    pjsua_stream_info psi;
    cJSON *o, *rx, *tx, *rtt, *jb, *ice;
    int srtp; char crypto[48], icestate[16], lt[16], rt[16];
    unsigned tx_level = 0, rx_level = 0;
    char codec[48] = "";
    double jit_ms, lossPct, rttms, ptime = 20, jbdelay;
    pjmedia_transport_info ti;
    *err = 0;
    if (spc_call_cid_to_slot(cid, &slot, &acc) != 0) { *err = SPC_E_NOT_FOUND; return NULL; }
    if (slot >= SPC_ID_IAX_BASE) return spc_iax2_call_stats_json(cid, err);
    if (pjsua_call_get_info(slot, &ci) != PJ_SUCCESS) { *err = SPC_E_NOT_FOUND; return NULL; }
    idx = spc_call_media_audio_idx(&ci);
    if (idx < 0 || pjsua_call_get_stream_stat(slot, (unsigned)idx, &st) != PJ_SUCCESS) {
        *err = SPC_E_BUSY;
        return NULL;
    }
    (void)ma_add;
    o = cJSON_CreateObject();
    cJSON_AddNumberToObject(o, "cid", (double)cid);
    codec_string(slot, &ci, codec, sizeof(codec));
    cJSON_AddStringToObject(o, "codec", codec);
    memset(&psi, 0, sizeof(psi));
    if (pjsua_call_get_stream_info(slot, (unsigned)idx, &psi) == PJ_SUCCESS && psi.type == PJMEDIA_TYPE_AUDIO) {
        cJSON_AddNumberToObject(o, "clockRate", psi.info.aud.fmt.clock_rate);
        if (psi.info.aud.param) ptime = psi.info.aud.param->info.frm_ptime * psi.info.aud.param->setting.frm_per_pkt;
    } else cJSON_AddNumberToObject(o, "clockRate", 0);
    cJSON_AddNumberToObject(o, "ptime", ptime);
    jit_ms = st.rtcp.rx.jitter.mean / 1000.0;
    {
        double tot = (double)st.rtcp.rx.pkt + (double)st.rtcp.rx.loss;
        lossPct = tot > 0 ? 100.0 * (double)st.rtcp.rx.loss / tot : 0;
    }
    rx = cJSON_AddObjectToObject(o, "rx");
    cJSON_AddNumberToObject(rx, "packets", (double)st.rtcp.rx.pkt);
    cJSON_AddNumberToObject(rx, "bytes", (double)st.rtcp.rx.bytes);
    cJSON_AddNumberToObject(rx, "lost", (double)st.rtcp.rx.loss);
    cJSON_AddNumberToObject(rx, "lossPct", lossPct);
    cJSON_AddNumberToObject(rx, "discard", (double)st.rtcp.rx.discard);
    cJSON_AddNumberToObject(rx, "reorder", (double)st.rtcp.rx.reorder);
    cJSON_AddNumberToObject(rx, "dup", (double)st.rtcp.rx.dup);
    cJSON_AddNumberToObject(rx, "jitterMs", jit_ms);
    cJSON_AddNumberToObject(rx, "jitterMaxMs", st.rtcp.rx.jitter.max / 1000.0);
    cJSON_AddNumberToObject(rx, "lossPeriodMs", st.rtcp.rx.loss_period.mean / 1000.0);
    tx = cJSON_AddObjectToObject(o, "tx");
    cJSON_AddNumberToObject(tx, "packets", (double)st.rtcp.tx.pkt);
    cJSON_AddNumberToObject(tx, "bytes", (double)st.rtcp.tx.bytes);
    cJSON_AddNumberToObject(tx, "lost", (double)st.rtcp.tx.loss);
    {
        double tot = (double)st.rtcp.tx.pkt;
        cJSON_AddNumberToObject(tx, "lossPct", tot > 0 ? 100.0 * (double)st.rtcp.tx.loss / tot : 0);
    }
    cJSON_AddNumberToObject(tx, "jitterMs", st.rtcp.tx.jitter.mean / 1000.0);
    rtt = cJSON_AddObjectToObject(o, "rtt");
    rttms = st.rtcp.rtt.mean / 1000.0;
    cJSON_AddNumberToObject(rtt, "lastMs", st.rtcp.rtt.last / 1000.0);
    cJSON_AddNumberToObject(rtt, "minMs", st.rtcp.rtt.min == 0x7FFFFFFF ? 0 : st.rtcp.rtt.min / 1000.0);
    cJSON_AddNumberToObject(rtt, "avgMs", rttms);
    cJSON_AddNumberToObject(rtt, "maxMs", st.rtcp.rtt.max / 1000.0);
    jb = cJSON_AddObjectToObject(o, "jb");
    cJSON_AddNumberToObject(jb, "prefetch", st.jbuf.prefetch);
    cJSON_AddNumberToObject(jb, "size", st.jbuf.size);
    cJSON_AddNumberToObject(jb, "avgDelayMs", st.jbuf.avg_delay);
    cJSON_AddNumberToObject(jb, "maxDelayMs", st.jbuf.max_delay);
    cJSON_AddNumberToObject(jb, "burst", st.jbuf.burst);
    cJSON_AddNumberToObject(jb, "empty", st.jbuf.empty);
    cJSON_AddNumberToObject(jb, "discard", st.jbuf.discard);
    jbdelay = st.jbuf.avg_delay;
    cJSON_AddNumberToObject(o, "mos", spc_emodel_mos(codec, lossPct, jit_ms, rttms, jbdelay, ptime));
    if (ci.conf_slot >= 0 && pjsua_conf_get_signal_level(ci.conf_slot, &tx_level, &rx_level) == PJ_SUCCESS) {}
    /* level of audio arriving from the remote party = what the bridge transmits out of the call port */
    cJSON_AddNumberToObject(o, "rxLevel", rx_level);
    cJSON_AddNumberToObject(o, "txLevel", tx_level);
    transport_details(slot, &ci, &srtp, crypto, sizeof(crypto), icestate, sizeof(icestate), lt, rt, sizeof(lt));
    cJSON_AddBoolToObject(o, "srtp", srtp);
    spc_jadd_str(o, "crypto", crypto[0] ? crypto : NULL);
    ice = cJSON_AddObjectToObject(o, "ice");
    cJSON_AddStringToObject(ice, "state", icestate);
    cJSON_AddStringToObject(ice, "localType", lt);
    cJSON_AddStringToObject(ice, "remoteType", rt);
    pjmedia_transport_info_init(&ti);
    if (pjsua_call_get_med_transport_info(slot, (unsigned)idx, &ti) == PJ_SUCCESS) {
        char a[PJ_INET6_ADDRSTRLEN + 10];
        pj_sockaddr_print(&ti.sock_info.rtp_addr_name, a, sizeof(a), 3);
        cJSON_AddStringToObject(o, "localRtp", a);
        if (psi.type == PJMEDIA_TYPE_AUDIO) {
            pj_sockaddr_print(&psi.info.aud.rem_addr, a, sizeof(a), 3);
            cJSON_AddStringToObject(o, "remoteRtp", a);
        } else cJSON_AddStringToObject(o, "remoteRtp", "");
    }
    return o;
}

void spc_call_stats_tick(int64_t now)
{
    uint64_t ids[PJSUA_MAX_CALLS];
    int n = 0, i;
    spc_call* c;
    (void)now;
    spc_registry_lock();
    for (c = g_calls; c && n < PJSUA_MAX_CALLS; c = c->next)
        if (strcmp(c->last_media, "active") == 0) ids[n++] = c->cid;
    spc_registry_unlock();
    for (i = 0; i < n; i++) {
        int err;
        cJSON* s = spc_call_stats_json(ids[i], &err);
        if (s) spc_call_emit(ids[i], "call.stats", s);
    }
}

uint64_t spc_call_cid_of_slot(int slot)
{
    return slot_snapshot(slot, NULL);
}

/* ------------------------------------------------------------------ */
/* IAX2 calls live in the same registry (cid, conference lists, flags)   */
/* ------------------------------------------------------------------ */
int spc_call_is_iax(uint64_t cid)
{
    spc_call* c = spc_call_lock_find(cid);
    int r;
    if (!c) return 0;
    r = c->proto == 1;
    spc_registry_unlock();
    return r;
}

int spc_call_conf_slot(uint64_t cid, int slot)
{
    pjsua_call_info ci;
    if (slot >= SPC_ID_IAX_BASE) {
        int cs = -1, act = 0;
        if (spc_iax2_call_conf(cid, &cs, &act) != 0) return -1;
        return cs;
    }
    if (pjsua_call_get_info(slot, &ci) != PJ_SUCCESS) return -1;
    return ci.conf_slot;
}

spc_call* spc_call_iax_new(int slot, int acc, const char* uid, int role)
{
    spc_call* c = (spc_call*)calloc(1, sizeof(*c));
    if (!c) return NULL;
    spc_registry_lock();
    c->cid = (uint64_t)(++G.cid_counter);
    c->slot = slot;
    c->acc = acc;
    c->proto = 1;
    c->role = role;
    if (uid) spc_strlcpy(c->uid, uid, sizeof(c->uid));
    spc_strlcpy(c->dtmf_method, "iax2", sizeof(c->dtmf_method));
    c->rec_id = -1; c->player_id = -1; c->tg_slot = -1;
    c->created_ms = spc_mono_ms();
    spc_strlcpy(c->last_media, "none", sizeof(c->last_media));
    c->next = g_calls;
    g_calls = c;
    spc_registry_unlock();
    return c;
}

/* emits the (already built) terminal call.state, unlinks and frees the call */
void spc_call_iax_finish(spc_call* c, cJSON* terminal_state)
{
    spc_call* p;
    int i, j;
    spc_registry_lock();
    c->ended = 1;
    if (terminal_state) spc_emit("call.state", terminal_state);
    if (g_calls == c) g_calls = c->next;
    else for (p = g_calls; p; p = p->next) if (p->next == c) { p->next = c->next; break; }
    for (p = g_calls; p; p = p->next) {
        for (i = 0; i < p->nconf; i++) if (p->conf[i] == c->cid) { for (j = i; j < p->nconf - 1; j++) p->conf[j] = p->conf[j + 1]; p->nconf--; i--; }
        for (i = 0; i < p->nbr; i++) if (p->bridged[i] == c->cid) { for (j = i; j < p->nbr - 1; j++) p->bridged[j] = p->bridged[j + 1]; p->nbr--; i--; }
    }
    spc_registry_unlock();
    free(c);
}
