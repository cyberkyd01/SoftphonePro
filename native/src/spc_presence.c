/* spc_presence.c: buddies (presence + BLF via dialog-info), MWI, incoming SUBSCRIBE policy, IM, typing. */
#include "spc_internal.h"
#include <ctype.h>

#define MAX_DLGS 8

typedef struct {
    char id[64], state[16], direction[16], call_id[128], local_tag[64], remote_tag[64];
    char remote[200], local[200];
    int duration;
} dlg_t;

typedef struct spc_buddy {
    int used;
    int id;                 /* primary pjsua id: reported as "buddy" */
    int pj_pres, pj_blf;    /* pjsua buddy ids or -1 */
    int acc;
    char uid[96];
    char uri[256];
    char user[100], host[160];
    int want_pres, want_blf;
    char pres_status[12], pres_note[160], pres_sub[24];
    char blf_state[12], blf_sub[24];
    int ndlg;
    dlg_t dlg[MAX_DLGS];
    int64_t blf_ts;
} spc_buddy;

static spc_buddy g_b[PJSUA_MAX_BUDDIES];

static spc_buddy* by_pj(int pj)
{
    int i;
    for (i = 0; i < PJSUA_MAX_BUDDIES; i++)
        if (g_b[i].used && (g_b[i].pj_pres == pj || g_b[i].pj_blf == pj)) return &g_b[i];
    return NULL;
}
static spc_buddy* by_id(int id)
{
    int i;
    for (i = 0; i < PJSUA_MAX_BUDDIES; i++) if (g_b[i].used && g_b[i].id == id) return &g_b[i];
    return NULL;
}

/* registry lock held */
static cJSON* buddy_json_locked(spc_buddy* b)
{
    cJSON *o = cJSON_CreateObject(), *p, *l, *arr;
    int i;
    cJSON_AddNumberToObject(o, "buddy", b->id);
    cJSON_AddNumberToObject(o, "acc", b->acc);
    cJSON_AddStringToObject(o, "uid", b->uid);
    cJSON_AddStringToObject(o, "uri", b->uri);
    p = cJSON_AddObjectToObject(o, "presence");
    cJSON_AddStringToObject(p, "status", b->pres_status);
    cJSON_AddStringToObject(p, "note", b->pres_note);
    cJSON_AddStringToObject(p, "subState", b->pres_sub);
    l = cJSON_AddObjectToObject(o, "blf");
    cJSON_AddStringToObject(l, "state", b->blf_state);
    cJSON_AddStringToObject(l, "subState", b->blf_sub);
    arr = cJSON_AddArrayToObject(l, "dialogs");
    for (i = 0; i < b->ndlg; i++) {
        cJSON* d = cJSON_CreateObject();
        cJSON_AddStringToObject(d, "id", b->dlg[i].id);
        cJSON_AddStringToObject(d, "state", b->dlg[i].state);
        cJSON_AddStringToObject(d, "direction", b->dlg[i].direction);
        cJSON_AddStringToObject(d, "callId", b->dlg[i].call_id);
        cJSON_AddStringToObject(d, "localTag", b->dlg[i].local_tag);
        cJSON_AddStringToObject(d, "remoteTag", b->dlg[i].remote_tag);
        cJSON_AddStringToObject(d, "remote", b->dlg[i].remote);
        cJSON_AddStringToObject(d, "local", b->dlg[i].local);
        cJSON_AddNumberToObject(d, "durationSec", b->dlg[i].duration);
        cJSON_AddItemToArray(arr, d);
    }
    return o;
}

cJSON* spc_buddy_list_json(void)
{
    cJSON* arr = cJSON_CreateArray();
    int i;
    spc_registry_lock();
    for (i = 0; i < PJSUA_MAX_BUDDIES; i++) if (g_b[i].used) cJSON_AddItemToArray(arr, buddy_json_locked(&g_b[i]));
    spc_registry_unlock();
    return arr;
}

static void emit_buddy(spc_buddy* b)
{
    spc_registry_lock();
    if (b->used) spc_emit("buddy.state", buddy_json_locked(b));
    spc_registry_unlock();
}

void spc_presence_cleanup(void)
{
    spc_registry_lock();
    memset(g_b, 0, sizeof(g_b));
    spc_registry_unlock();
}

/* ------------------------------------------------------------------ */
/* presence callbacks                                                  */
/* ------------------------------------------------------------------ */
static void cb_buddy_state(pjsua_buddy_id pj)
{
    pjsua_buddy_info bi;
    spc_buddy* b = by_pj(pj);
    const char* st = "unknown";
    char note[160];
    if (!b || pjsua_buddy_get_info(pj, &bi) != PJ_SUCCESS) return;
    spc_pjcopy(note, sizeof(note), &bi.status_text);
    if (bi.status == PJSUA_BUDDY_STATUS_ONLINE) {
        st = "online";
        if (bi.rpid.activity == PJRPID_ACTIVITY_AWAY) st = "away";
        else if (bi.rpid.activity == PJRPID_ACTIVITY_BUSY) {
            st = "busy";
            if (strstr(note, "phone") || strstr(note, "Phone") || strstr(note, "call")) st = "onthephone";
        }
    } else if (bi.status == PJSUA_BUDDY_STATUS_OFFLINE) st = "offline";
    spc_registry_lock();
    if (b->pj_pres == pj) {
        spc_strlcpy(b->pres_status, st, sizeof(b->pres_status));
        spc_strlcpy(b->pres_note, note, sizeof(b->pres_note));
        spc_strlcpy(b->pres_sub, bi.sub_state_name ? bi.sub_state_name : "", sizeof(b->pres_sub));
    }
    spc_registry_unlock();
    emit_buddy(b);
}

static void cb_buddy_dlg_state(pjsua_buddy_id pj)
{
    pjsua_buddy_dlg_event_info di;
    spc_buddy* b = by_pj(pj);
    if (!b || pjsua_buddy_get_dlg_event_info(pj, &di) != PJ_SUCCESS) return;
    spc_registry_lock();
    if (b->pj_blf == pj) spc_strlcpy(b->blf_sub, di.sub_state_name ? di.sub_state_name : "", sizeof(b->blf_sub));
    spc_registry_unlock();
    emit_buddy(b);
}

/* ---- dialog-info XML (bounded: the body is not NUL terminated; namespace prefixes such as <dm:dialog> accepted) ---- */
static int is_delim(char c) { return c == '>' || c == ' ' || c == '/' || c == '\r' || c == '\n' || c == '\t'; }

/* p points at '<' (or "</"); returns the start of the local name (after an optional "prefix:") or NULL */
static const char* local_name(const char* p, const char* e, int closing)
{
    const char* q = p + 1 + (closing ? 1 : 0);
    const char* r = q;
    int n = 0;
    if (q >= e) return NULL;
    while (r < e && !is_delim(*r) && n < 32) { if (*r == ':') return r + 1; r++; n++; }
    return q;
}
static int name_is(const char* ln, const char* e, const char* tag)
{
    size_t tl = strlen(tag);
    return (size_t)(e - ln) > tl && strncmp(ln, tag, tl) == 0 && is_delim(ln[tl]);
}
static const char* xml_find_tag(const char* s, const char* e, const char* tag, const char** tag_end)
{
    const char* p = s;
    while (p < e && (p = (const char*)memchr(p, '<', (size_t)(e - p))) != NULL) {
        if (p + 1 < e && p[1] != '/' && p[1] != '?' && p[1] != '!') {
            const char* ln = local_name(p, e, 0);
            if (ln && name_is(ln, e, tag)) {
                const char* gt = (const char*)memchr(p, '>', (size_t)(e - p));
                if (!gt) return NULL;
                if (tag_end) *tag_end = gt;
                return p;
            }
        }
        p++;
    }
    return NULL;
}
/* position of the "</[prefix:]tag>" at or after s */
static const char* xml_find_close(const char* s, const char* e, const char* tag)
{
    const char* p = s;
    while (p < e && (p = (const char*)memchr(p, '<', (size_t)(e - p))) != NULL) {
        if (p + 1 < e && p[1] == '/') {
            const char* ln = local_name(p, e, 1);
            if (ln && name_is(ln, e, tag)) return p;
        }
        p++;
    }
    return NULL;
}
static int xml_attr(const char* tagstart, const char* tagend, const char* name, char* out, size_t n)
{
    const char* p = tagstart;
    size_t nl = strlen(name);
    out[0] = 0;
    while (p < tagend) {
        const char* f = (const char*)memchr(p, name[0], (size_t)(tagend - p));
        char q;
        const char* v;
        size_t l;
        if (!f) return 0;
        if ((size_t)(tagend - f) < nl + 2 || strncmp(f, name, nl) != 0 || f[nl] != '=' || !isspace((unsigned char)f[-1])) { p = f + 1; continue; }
        q = f[nl + 1];
        if (q != '"' && q != '\'') return 0;
        v = f + nl + 2;
        l = 0;
        while (v + l < tagend && v[l] != q) l++;
        if (l >= n) l = n - 1;
        memcpy(out, v, l);
        out[l] = 0;
        return 1;
    }
    return 0;
}
static int xml_text(const char* s, const char* e, const char* tag, char* out, size_t n)
{
    const char* te;
    const char* t = xml_find_tag(s, e, tag, &te);
    const char* c;
    size_t l;
    out[0] = 0;
    if (!t || te[-1] == '/') return 0;
    c = xml_find_close(te, e, tag);
    if (!c) return 0;
    l = (size_t)(c - te - 1);
    if (l >= n) l = n - 1;
    memcpy(out, te + 1, l);
    out[l] = 0;
    return 1;
}

static int state_rank(const char* s)
{
    if (strcmp(s, "confirmed") == 0) return 3;
    if (strcmp(s, "early") == 0) return 2;
    if (strcmp(s, "terminated") == 0) return 1;
    return 0;
}

static void parse_dialog_info(spc_buddy* b, const char* xml, size_t len)
{
    const char* e = xml + len;
    const char* p = xml;
    dlg_t nd[MAX_DLGS];
    int n = 0, i, best = -1;
    const char* best_s = "idle";
    memset(nd, 0, sizeof(nd));
    while (p < e) {
        const char* te;
        const char* d = xml_find_tag(p, e, "dialog", &te);
        const char* dend;
        char st[24];
        if (!d) break;
        /* tag "dialog" must not be "dialog-info" (xml_find_tag requires delimiter after name) */
        if (te[-1] == '/') { dend = te; }
        else {
            dend = xml_find_close(te, e, "dialog");
            if (!dend) dend = e;
        }
        if (n < MAX_DLGS) {
            dlg_t* x = &nd[n];
            const char* sec;
            const char* sece;
            xml_attr(d, te, "id", x->id, sizeof(x->id));
            xml_attr(d, te, "call-id", x->call_id, sizeof(x->call_id));
            xml_attr(d, te, "local-tag", x->local_tag, sizeof(x->local_tag));
            xml_attr(d, te, "remote-tag", x->remote_tag, sizeof(x->remote_tag));
            xml_attr(d, te, "direction", x->direction, sizeof(x->direction));
            st[0] = 0;
            xml_text(te, dend, "state", st, sizeof(st));
            if (strcmp(st, "trying") == 0 || strcmp(st, "proceeding") == 0 || strcmp(st, "early") == 0) spc_strlcpy(x->state, "early", sizeof(x->state));
            else if (strcmp(st, "confirmed") == 0) spc_strlcpy(x->state, "confirmed", sizeof(x->state));
            else if (strcmp(st, "terminated") == 0) spc_strlcpy(x->state, "terminated", sizeof(x->state));
            else spc_strlcpy(x->state, "idle", sizeof(x->state));
            {
                char dur[16];
                if (xml_text(te, dend, "duration", dur, sizeof(dur))) x->duration = atoi(dur);
            }
            sec = xml_find_tag(te, dend, "local", &sece);
            if (sec) { char idv[200]; if (xml_text(sece, dend, "identity", idv, sizeof(idv))) spc_strlcpy(x->local, idv, sizeof(x->local)); }
            sec = xml_find_tag(te, dend, "remote", &sece);
            if (sec) { char idv[200]; if (xml_text(sece, dend, "identity", idv, sizeof(idv))) spc_strlcpy(x->remote, idv, sizeof(x->remote)); }
            n++;
        }
        p = dend + 1;
        if (p <= d) break;
    }
    for (i = 0; i < n; i++) {
        int r = state_rank(nd[i].state);
        if (r > best) { best = r; best_s = nd[i].state; }
    }
    spc_registry_lock();
    b->ndlg = n;
    memcpy(b->dlg, nd, sizeof(nd));
    spc_strlcpy(b->blf_state, n == 0 ? "idle" : best_s, sizeof(b->blf_state));
    spc_registry_unlock();
}

static pj_bool_t mod_on_rx_request(pjsip_rx_data* rd)
{
    pjsip_msg* msg = rd->msg_info.msg;
    static const pj_str_t NOTIFY = { "NOTIFY", 6 };
    pjsip_generic_string_hdr* ev;
    static const pj_str_t EVN = { "Event", 5 };
    pjsip_sip_uri* from;
    char fuser[100], fhost[160];
    int i;
    if (pjsip_method_cmp(&msg->line.req.method, pjsip_get_notify_method()) != 0) { (void)NOTIFY; return PJ_FALSE; }
    ev = (pjsip_generic_string_hdr*)pjsip_msg_find_hdr_by_name(msg, &EVN, NULL);
    if (!ev || pj_strnicmp2(&ev->hvalue, "dialog", 6) != 0) return PJ_FALSE;
    if (!msg->body || !msg->body->data || msg->body->len == 0) return PJ_FALSE;
    if (!rd->msg_info.from || !rd->msg_info.from->uri) return PJ_FALSE;
    if (!PJSIP_URI_SCHEME_IS_SIP(rd->msg_info.from->uri) && !PJSIP_URI_SCHEME_IS_SIPS(rd->msg_info.from->uri)) return PJ_FALSE;
    /* Only NOTIFYs inside one of our own subscription dialogs count: unknown Call-ID/tags are spoofs. */
    if (!rd->msg_info.cid || !rd->msg_info.to || !rd->msg_info.from) return PJ_FALSE;
    {
        pjsip_dialog* dlg = pjsip_ua_find_dialog(&rd->msg_info.cid->id, &rd->msg_info.to->tag, &rd->msg_info.from->tag, PJ_TRUE);
        if (!dlg) return PJ_FALSE;
        pjsip_dlg_dec_lock(dlg);
    }
    from = (pjsip_sip_uri*)pjsip_uri_get_uri(rd->msg_info.from->uri);
    spc_pjcopy(fuser, sizeof(fuser), &from->user);
    spc_pjcopy(fhost, sizeof(fhost), &from->host);
    for (i = 0; i < PJSUA_MAX_BUDDIES; i++) {
        spc_buddy* b = &g_b[i];
        int match;
        spc_registry_lock();
        match = b->used && b->pj_blf >= 0 && spc_strieq(b->user, fuser) && spc_strieq(b->host, fhost);
        spc_registry_unlock();
        if (match) {
            parse_dialog_info(b, (const char*)msg->body->data, msg->body->len);
            emit_buddy(b);
        }
    }
    return PJ_FALSE;
}

static pjsip_module g_mod = {
    NULL, NULL, { "mod-spc-dlgev", 13 }, -1, PJSIP_MOD_PRIORITY_TRANSPORT_LAYER - 2,
    NULL, NULL, NULL, NULL,
    &mod_on_rx_request, NULL, NULL, NULL, NULL
};

int spc_presence_init_module(void)
{
    g_mod.prev = g_mod.next = NULL;
    g_mod.id = -1;
    return pjsip_endpt_register_module(pjsua_get_pjsip_endpt(), &g_mod) == PJ_SUCCESS ? 0 : -1;
}

/* ---- MWI ---- */
static void cb_mwi_info(pjsua_acc_id acc, pjsua_mwi_info* mi)
{
    pjsip_rx_data* rd = mi ? mi->rdata : NULL;
    spc_acc* m = spc_acc_from_id(acc);
    char body[1024];
    int waiting = 0, nn = 0, no = 0, un = 0, uo = 0;
    char account[200] = "";
    char* line;
    char* save;
    cJSON* f;
    static const pj_str_t SS = { "Subscription-State", 18 };
    int solicited;
    if (!rd || !rd->msg_info.msg || !rd->msg_info.msg->body || !m) return;
    {
        size_t l = rd->msg_info.msg->body->len;
        if (l >= sizeof(body)) l = sizeof(body) - 1;
        memcpy(body, rd->msg_info.msg->body->data, l);
        body[l] = 0;
    }
    solicited = pjsip_msg_find_hdr_by_name(rd->msg_info.msg, &SS, NULL) != NULL;
    for (line = body; line && *line; line = save) {
        char* nl = strpbrk(line, "\r\n");
        char* val;
        if (nl) { save = nl; while (*save == '\r' || *save == '\n') { *save++ = 0; } } else save = NULL;
        val = strchr(line, ':');
        if (!val) continue;
        *val++ = 0;
        while (*val == ' ') val++;
        if (spc_strieq(line, "Messages-Waiting")) waiting = spc_strnieq(val, "yes", 3);
        else if (spc_strieq(line, "Message-Account")) spc_strlcpy(account, val, sizeof(account));
        else if (spc_strieq(line, "Voice-Message")) {
            int a = 0, b = 0, c = 0, d = 0;
            int k = sscanf(val, "%d/%d (%d/%d)", &a, &b, &c, &d);
            if (k >= 2) { nn = a; no = b; }
            if (k >= 4) { un = c; uo = d; }
        }
    }
    f = cJSON_CreateObject();
    cJSON_AddNumberToObject(f, "acc", acc);
    cJSON_AddStringToObject(f, "uid", m->uid);
    cJSON_AddBoolToObject(f, "waiting", waiting);
    cJSON_AddNumberToObject(f, "newMsgs", nn);
    cJSON_AddNumberToObject(f, "oldMsgs", no);
    cJSON_AddNumberToObject(f, "urgentNew", un);
    cJSON_AddNumberToObject(f, "urgentOld", uo);
    if (account[0]) cJSON_AddStringToObject(f, "account", account);
    cJSON_AddBoolToObject(f, "solicited", solicited);
    spc_emit("account.mwi", f);
}

/* ---- incoming SUBSCRIBE ---- */
static void cb_incoming_subscribe(pjsua_acc_id acc, pjsua_srv_pres* sp, pjsua_buddy_id bid, const pj_str_t* from,
                                  pjsip_rx_data* rd, pjsip_status_code* code, pj_str_t* reason, pjsua_msg_data* md)
{
    spc_acc* m = spc_acc_from_id(acc);
    cJSON* f;
    (void)sp; (void)bid; (void)rd; (void)reason; (void)md;
    if (m && m->watcher_reject) *code = PJSIP_SC_FORBIDDEN;
    if (!m) return;
    f = cJSON_CreateObject();
    cJSON_AddNumberToObject(f, "acc", acc);
    cJSON_AddStringToObject(f, "uid", m->uid);
    spc_jadd_pjstr(f, "from", from);
    cJSON_AddBoolToObject(f, "accepted", *code / 100 == 2);
    spc_emit("account.incomingSubscribe", f);
}

/* ---- IM ---- */
static void cb_pager2(pjsua_call_id call_id, const pj_str_t* from, const pj_str_t* to, const pj_str_t* contact,
                      const pj_str_t* mime, const pj_str_t* body, pjsip_rx_data* rd, pjsua_acc_id acc)
{
    spc_acc* m = spc_acc_from_id(acc);
    cJSON* f;
    char fr[300], disp[128], uri[256], user[100];
    (void)call_id; (void)contact; (void)rd;
    if (!m) return;
    spc_pjcopy(fr, sizeof(fr), from);
    spc_parse_nameaddr(fr, disp, sizeof(disp), uri, sizeof(uri), user, sizeof(user));
    f = cJSON_CreateObject();
    cJSON_AddNumberToObject(f, "acc", acc);
    cJSON_AddStringToObject(f, "uid", m->uid);
    cJSON_AddStringToObject(f, "from", uri);
    cJSON_AddStringToObject(f, "fromDisplay", disp);
    spc_jadd_pjstr(f, "to", to);
    spc_jadd_pjstr(f, "body", body);
    spc_jadd_pjstr(f, "contentType", mime);
    cJSON_AddBoolToObject(f, "isLan", m->is_lan);
    spc_emit("im.incoming", f);
}

static void cb_pager_status2(pjsua_call_id call_id, const pj_str_t* to, const pj_str_t* body, void* ud,
                             pjsip_status_code status, const pj_str_t* reason, pjsip_tx_data* tdata, pjsip_rx_data* rdata, pjsua_acc_id acc)
{
    spc_acc* m = spc_acc_from_id(acc);
    cJSON* f;
    char* mid = (char*)ud;
    (void)call_id; (void)body; (void)tdata; (void)rdata;
    f = cJSON_CreateObject();
    cJSON_AddNumberToObject(f, "acc", acc);
    cJSON_AddStringToObject(f, "uid", m ? m->uid : "");
    spc_jadd_pjstr(f, "to", to);
    cJSON_AddStringToObject(f, "msgId", mid ? mid : "");
    cJSON_AddNumberToObject(f, "code", status);
    spc_jadd_pjstr(f, "reason", reason);
    cJSON_AddBoolToObject(f, "ok", status / 100 == 2);
    spc_emit("im.status", f);
    spc_token_free(mid);
}

static void cb_typing2(pjsua_call_id call_id, const pj_str_t* from, const pj_str_t* to, const pj_str_t* contact,
                       pj_bool_t is_typing, pjsip_rx_data* rd, pjsua_acc_id acc)
{
    spc_acc* m = spc_acc_from_id(acc);
    cJSON* f;
    char fr[300], uri[256];
    (void)call_id; (void)to; (void)contact; (void)rd;
    if (!m) return;
    spc_pjcopy(fr, sizeof(fr), from);
    spc_parse_nameaddr(fr, NULL, 0, uri, sizeof(uri), NULL, 0);
    f = cJSON_CreateObject();
    cJSON_AddNumberToObject(f, "acc", acc);
    cJSON_AddStringToObject(f, "uid", m->uid);
    cJSON_AddStringToObject(f, "from", uri);
    cJSON_AddBoolToObject(f, "typing", is_typing ? 1 : 0);
    spc_emit("im.typing", f);
}

void spc_presence_install_callbacks(pjsua_callback* cb)
{
    cb->on_buddy_state = &cb_buddy_state;
    cb->on_buddy_dlg_event_state = &cb_buddy_dlg_state;
    cb->on_mwi_info = &cb_mwi_info;
    cb->on_incoming_subscribe = &cb_incoming_subscribe;
    cb->on_pager2 = &cb_pager2;
    cb->on_pager_status2 = &cb_pager_status2;
    cb->on_typing2 = &cb_typing2;
}

/* ------------------------------------------------------------------ */
/* handlers                                                            */
/* ------------------------------------------------------------------ */
static int sub_pres(spc_buddy* b, const char* uri, int on)
{
    pj_status_t st;
    if (b->pj_pres < 0) {
        pjsua_buddy_config bc;
        pjsua_buddy_id id = -1;
        if (!on) return 0;
        pjsua_buddy_config_default(&bc);
        bc.uri = spc_pjs(uri);
        bc.subscribe = PJ_TRUE;
        st = pjsua_buddy_add(&bc, &id);
        if (st != PJ_SUCCESS) return st;
        b->pj_pres = id;
        if (b->id < 0) b->id = id;
    } else {
        st = pjsua_buddy_subscribe_pres(b->pj_pres, on);
        if (st != PJ_SUCCESS) return st;
    }
    b->want_pres = on;
    if (!on) spc_strlcpy(b->pres_sub, "terminated", sizeof(b->pres_sub));
    return 0;
}
static int sub_blf(spc_buddy* b, const char* uri, int on)
{
    pj_status_t st;
    if (b->pj_blf < 0) {
        pjsua_buddy_config bc;
        pjsua_buddy_id id = -1;
        if (!on) return 0;
        pjsua_buddy_config_default(&bc);
        bc.uri = spc_pjs(uri);
        bc.subscribe = PJ_FALSE;
        bc.subscribe_dlg_event = PJ_TRUE;
        st = pjsua_buddy_add(&bc, &id);
        if (st != PJ_SUCCESS) return st;
        b->pj_blf = id;
        if (b->id < 0) b->id = id;
    } else {
        st = pjsua_buddy_subscribe_dlg_event(b->pj_blf, on);
        if (st != PJ_SUCCESS) return st;
    }
    b->want_blf = on;
    return 0;
}

static int h_buddy_add(cJSON* p, cJSON** res)
{
    const char* uri = spc_jstr(p, "uri");
    int acc, rc, i, pres = spc_jbool(p, "presence", 1), blf = spc_jbool(p, "blf", 0);
    char norm[300];
    spc_buddy* b = NULL;
    pj_status_t st;
    spc_acc* m;
    if (!uri || !uri[0]) return spc_err(SPC_E_INVALID_PARAM, 0, "'uri' required");
    rc = spc_acc_resolve(p, &acc);
    if (rc) return rc;
    if (spc_uri_normalize(acc, uri, norm, sizeof(norm)) != 0 || pjsua_verify_url(norm) != PJ_SUCCESS)
        return spc_err(SPC_E_INVALID_PARAM, 0, "invalid uri");
    if (!pres && !blf) return spc_err(SPC_E_INVALID_PARAM, 0, "presence or blf must be set");
    spc_registry_lock();
    for (i = 0; i < PJSUA_MAX_BUDDIES; i++) if (!g_b[i].used) { b = &g_b[i]; break; }
    if (b) { memset(b, 0, sizeof(*b)); b->used = 1; b->id = -1; b->pj_pres = b->pj_blf = -1; }
    spc_registry_unlock();
    if (!b) return spc_err(SPC_E_BUSY, 0, "too many buddies");
    m = spc_acc_from_id(acc);
    b->acc = acc;
    spc_strlcpy(b->uid, m ? m->uid : "", sizeof(b->uid));
    spc_strlcpy(b->uri, norm, sizeof(b->uri));
    {
        char u[100], h[160];
        const char* p0 = strchr(norm, ':');
        const char* at;
        p0 = p0 ? p0 + 1 : norm;
        at = strchr(p0, '@');
        if (at) { size_t l = (size_t)(at - p0); if (l >= sizeof(u)) l = sizeof(u) - 1; memcpy(u, p0, l); u[l] = 0; at++; }
        else { u[0] = 0; at = p0; }
        { size_t l = strcspn(at, ":;>"); if (l >= sizeof(h)) l = sizeof(h) - 1; memcpy(h, at, l); h[l] = 0; }
        spc_strlcpy(b->user, u, sizeof(b->user));
        spc_strlcpy(b->host, h, sizeof(b->host));
    }
    spc_strlcpy(b->pres_status, "unknown", sizeof(b->pres_status));
    spc_strlcpy(b->pres_sub, "none", sizeof(b->pres_sub));
    spc_strlcpy(b->blf_state, "unknown", sizeof(b->blf_state));
    spc_strlcpy(b->blf_sub, "none", sizeof(b->blf_sub));
    st = 0;
    if (pres) st = (pj_status_t)sub_pres(b, norm, 1);
    if (!st && blf) st = (pj_status_t)sub_blf(b, norm, 1);
    if (st) {
        if (b->pj_pres >= 0) pjsua_buddy_del(b->pj_pres);
        if (b->pj_blf >= 0) pjsua_buddy_del(b->pj_blf);
        spc_registry_lock(); b->used = 0; spc_registry_unlock();
        return spc_pjerr(st, "buddy_add");
    }
    *res = cJSON_CreateObject();
    cJSON_AddNumberToObject(*res, "buddy", b->id);
    return SPC_OK;
}

static int h_buddy_subscribe(cJSON* p, cJSON** res)
{
    spc_buddy* b = by_id(spc_jint(p, "buddy", -1));
    int st = 0;
    (void)res;
    if (!b) return spc_err(SPC_E_NOT_FOUND, 0, "buddy not found");
    if (spc_jhas(p, "presence")) st = sub_pres(b, b->uri, spc_jbool(p, "presence", 1));
    if (!st && spc_jhas(p, "blf")) st = sub_blf(b, b->uri, spc_jbool(p, "blf", 0));
    if (st) return spc_pjerr(st, "buddy_subscribe");
    return SPC_OK;
}

static int h_buddy_remove(cJSON* p, cJSON** res)
{
    spc_buddy* b = by_id(spc_jint(p, "buddy", -1));
    (void)res;
    if (!b) return spc_err(SPC_E_NOT_FOUND, 0, "buddy not found");
    if (b->pj_pres >= 0) pjsua_buddy_del(b->pj_pres);
    if (b->pj_blf >= 0) pjsua_buddy_del(b->pj_blf);
    spc_registry_lock(); b->used = 0; spc_registry_unlock();
    return SPC_OK;
}

static int h_buddy_list(cJSON* p, cJSON** res)
{
    (void)p;
    *res = cJSON_CreateObject();
    cJSON_AddItemToObject(*res, "buddies", spc_buddy_list_json());
    return SPC_OK;
}

static int h_buddy_refresh(cJSON* p, cJSON** res)
{
    spc_buddy* b = by_id(spc_jint(p, "buddy", -1));
    (void)res;
    if (!b) return spc_err(SPC_E_NOT_FOUND, 0, "buddy not found");
    if (b->pj_pres >= 0 && b->want_pres) pjsua_buddy_update_pres(b->pj_pres);
    if (b->pj_blf >= 0 && b->want_blf) pjsua_buddy_update_dlg_event(b->pj_blf);
    return SPC_OK;
}

static int h_im_send(cJSON* p, cJSON** res)
{
    const char* to = spc_jstr(p, "to");
    const char* body = spc_jstr(p, "body");
    const char* ct = spc_jstr(p, "contentType");
    const char* mid = spc_jstr(p, "msgId");
    int acc, rc;
    char dest[400];
    pj_str_t d, mime, b;
    pjsua_msg_data md;
    pj_pool_t* pool;
    char* ud;
    pj_status_t st;
    spc_acc* m;
    (void)res;
    if (!to || !body) return spc_err(SPC_E_INVALID_PARAM, 0, "'to' and 'body' required");
    rc = spc_acc_resolve(p, &acc);
    if (rc) return rc;
    if (spc_uri_normalize(acc, to, dest, sizeof(dest)) != 0 || pjsua_verify_url(dest) != PJ_SUCCESS)
        return spc_err(SPC_E_INVALID_PARAM, 0, "invalid 'to'");
    pool = pjsua_pool_create("spcim", 1024, 1024);
    pjsua_msg_data_init(&md);
    m = spc_acc_from_id(acc);
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
    d = spc_pjs(dest);
    mime = spc_pjs(ct ? ct : "text/plain");
    b = spc_pjs(body);
    ud = (char*)spc_token_new(strlen(mid ? mid : "") + 1);
    if (!ud) { pj_pool_release(pool); return spc_err(SPC_E_INTERNAL, 0, "out of memory"); }
    strcpy(ud, mid ? mid : "");
    st = pjsua_im_send(acc, &d, &mime, &b, &md, ud);
    pj_pool_release(pool);
    if (st != PJ_SUCCESS) { spc_token_free(ud); return spc_pjerr(st, "pjsua_im_send"); }
    return SPC_OK;
}

static int h_im_typing(cJSON* p, cJSON** res)
{
    const char* to = spc_jstr(p, "to");
    int acc, rc;
    char dest[400];
    pj_str_t d;
    pj_status_t st;
    (void)res;
    int tv;
    if (!to || !spc_jbool_strict(p, "typing", &tv)) return spc_err(SPC_E_INVALID_PARAM, 0, "'to' and 'typing' (bool) required");
    rc = spc_acc_resolve(p, &acc);
    if (rc) return rc;
    if (spc_uri_normalize(acc, to, dest, sizeof(dest)) != 0 || pjsua_verify_url(dest) != PJ_SUCCESS)
        return spc_err(SPC_E_INVALID_PARAM, 0, "invalid 'to'");
    d = spc_pjs(dest);
    st = pjsua_im_typing(acc, &d, tv, NULL);
    if (st != PJ_SUCCESS) return spc_pjerr(st, "pjsua_im_typing");
    return SPC_OK;
}

const spc_method spc_methods_presence[] = {
    { "buddy.add", h_buddy_add, 0 }, { "buddy.subscribe", h_buddy_subscribe, 0 }, { "buddy.remove", h_buddy_remove, 0 },
    { "buddy.list", h_buddy_list, 0 }, { "buddy.refresh", h_buddy_refresh, 0 },
    { "im.send", h_im_send, 0 }, { "im.typing", h_im_typing, 0 },
    { NULL, NULL, 0 }
};
