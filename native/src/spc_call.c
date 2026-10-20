/* spc_call.c: call registry (cid), pjsua call callbacks, topology, info/stats JSON. */
#include "spc_internal.h"
#include <pjsua-lib/pjsua_internal.h>
#include "spc_ws_transport.h"
#include "spc_denoise.h"
#include "spc_player.h"
#include "spc_rec.h"
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

static int tp_type_secure(pjsip_transport* tp)
{
    int t;
    if (!tp) return 0;
    t = (int)tp->key.type & ~PJSIP_TRANSPORT_IPV6;
    return t == (int)PJSIP_TRANSPORT_TLS || spc_ws_type_is_wss((int)tp->key.type);
}

/* Signalling security of the call's dialog: TLS or WSS transport actually used by the INVITE (or pinned on
 * the dialog), or a sips: target. Independent of SRTP. */
static int dlg_secure(int slot)
{
    pjsua_call* call = NULL;
    pjsip_dialog* dlg = NULL;
    int s = 0;
    if (acquire_call("spc_sec", slot, &call, &dlg) == PJ_SUCCESS) {
        if (dlg) {
            if (dlg->secure) s = 1;
            else if (call && call->inv && call->inv->invite_tsx && tp_type_secure(call->inv->invite_tsx->transport)) s = 1;
            else if (dlg->tp_sel.type == PJSIP_TPSELECTOR_TRANSPORT && tp_type_secure(dlg->tp_sel.u.transport)) s = 1;
            pjsip_dlg_dec_lock(dlg);
        }
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
    c->rec_id = -1; c->player_id = -1; c->tg_slot = -1; c->dn_in_slot = -1;
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
/* caller identity: P-Asserted-Identity, Remote-Party-ID, Diversion,   */
/* History-Info, Referred-By (docs/ENGINE_API.md 9.5)                  */
/* ------------------------------------------------------------------ */
#define ID_MAX_HDRS 64          /* header scan bound */
#define ID_MAX_VALUE 1024       /* bytes of one header value that are looked at */
#define ID_MAX_ENTRIES 24       /* values examined per header kind */

/* Next comma separated element of a header value, honouring "quotes" and <angle brackets>. 0 at the end. */
static int id_next_value(const char** pp, char* out, size_t n)
{
    const char* p = *pp;
    size_t l = 0;
    int q = 0, ang = 0;
    while (*p == ' ' || *p == ',' || *p == '\t') p++;
    if (!*p) { *pp = p; return 0; }
    while (*p) {
        if (*p == '\\' && q && p[1]) { if (l + 2 < n) { out[l++] = p[0]; out[l++] = p[1]; } p += 2; continue; }
        if (*p == '"') q = !q;
        else if (!q && *p == '<') ang = 1;
        else if (!q && *p == '>') ang = 0;
        else if (!q && !ang && *p == ',') break;
        if (l + 1 < n) out[l++] = *p;
        p++;
    }
    out[l] = 0;
    *pp = p;
    return 1;
}

/* parameter after the address ("name=value" or bare flag); value copied without quotes. Returns 1 if present. */
static int id_param(const char* v, const char* name, char* out, size_t n)
{
    const char* p = strchr(v, '>');
    size_t nl = strlen(name);
    int q = 0;
    if (out && n) out[0] = 0;
    if (!p) { p = strchr(v, ';'); if (!p) return 0; } else p++;
    for (; *p; p++) {
        if (*p == '"') { q = !q; continue; }
        if (q || *p != ';') continue;
        {
            const char* s = p + 1;
            while (*s == ' ') s++;
            if (spc_strnieq(s, name, nl) && (s[nl] == '=' || s[nl] == ';' || s[nl] == ',' || s[nl] == ' ' || s[nl] == 0)) {
                s += nl;
                while (*s == ' ') s++;
                if (*s == '=') {
                    size_t l = 0;
                    s++;
                    while (*s == ' ') s++;
                    if (*s == '"') s++;
                    while (*s && *s != '"' && *s != ';' && *s != ',' && *s != ' ' && l + 1 < n) out[l++] = *s++;
                    if (out && n) out[l] = 0;
                }
                return 1;
            }
        }
    }
    return 0;
}

/* Collects the (truncated) values of all headers called `name` (or compact `alt`), in message order. Returns count. */
static int id_headers(const pjsip_msg* msg, const char* name, const char* alt, char vals[][ID_MAX_VALUE], int maxv)
{
    const pjsip_hdr* h;
    int n = 0, scanned = 0;
    for (h = msg->hdr.next; h != &msg->hdr && n < maxv && scanned < ID_MAX_HDRS; h = h->next, scanned++) {
        char hn[32];
        if (h->type != PJSIP_H_OTHER) continue;
        if (h->name.slen <= 0 || h->name.slen >= (pj_ssize_t)sizeof(hn)) continue;
        spc_pjcopy(hn, sizeof(hn), &h->name);
        if (!spc_strieq(hn, name) && !(alt && spc_strieq(hn, alt))) continue;
        spc_pjcopy(vals[n++], ID_MAX_VALUE, &((const pjsip_generic_string_hdr*)h)->hvalue);
    }
    return n;
}

static int id_is_sip(const char* uri) { return spc_strnieq(uri, "sip:", 4) || spc_strnieq(uri, "sips:", 5); }

static void id_clean(char* s)       /* strip control characters (values end up in JSON / UI) */
{
    char* d = s;
    for (; *s; s++) if ((unsigned char)*s >= 0x20 && *s != 0x7f) *d++ = *s;
    *d = 0;
}

static const char* id_reason_from_cause(int cause, char* buf, size_t n)
{
    switch (cause) {
    case 301: case 302: return "unconditional";
    case 486: case 600: case 603: return "user-busy";
    case 408: case 480: return "no-answer";
    case 404: case 410: case 503: return "unavailable";
    case 487: return "deflection";
    default: snprintf(buf, n, "%d", cause); return buf;
    }
}

/* History-Info index "1.2.3" -> comparable key (dotted numeric compare) */
static int id_index_cmp(const char* a, const char* b)
{
    int guard = 0;
    while ((*a || *b) && guard++ < 64) {
        char *ea, *eb;
        long x = strtol(a, &ea, 10), y = strtol(b, &eb, 10);
        /* no progress and not at a separator: malformed -> never loop, fall back to plain string compare */
        if ((ea == a && *a && *a != '.') || (eb == b && *b && *b != '.')) {
            int r = strcmp(a, b);
            return r < 0 ? -1 : (r > 0 ? 1 : 0);
        }
        a = ea; b = eb;
        if (x != y) return x < y ? -1 : 1;
        if (*a == '.') a++;
        if (*b == '.') b++;
        if (!*a && !*b) break;
        if (!*a) return -1;
        if (!*b) return 1;
    }
    return 0;
}

/* History-Info index must be [0-9.]+ ; anything else is treated as "no index" */
static void id_sanitize_index(char* s)
{
    char* p;
    for (p = s; *p; p++) if (!((*p >= '0' && *p <= '9') || *p == '.')) { s[0] = 0; return; }
}

typedef struct { char idx[32]; spc_div d; char cause[16]; } id_he;

static void id_fill_div_uri(spc_div* d, const char* v)
{
    char disp[8], uri[200], user[96];
    spc_parse_nameaddr(v, disp, sizeof(disp), uri, sizeof(uri), user, sizeof(user));
    {   char* q = strchr(uri, '?'); if (q) *q = 0; }          /* History-Info URIs carry ?Reason=... headers */
    spc_strlcpy(d->uri, uri, sizeof(d->uri));
    spc_strlcpy(d->user, user, sizeof(d->user));
    id_clean(d->uri); id_clean(d->user);
}

/* Parses the identity headers of a SIP message. Requests: everything. Responses (18x/2xx of an outgoing call):
 * only the asserted identity. Never writes outside *out; bounded in headers, header length and entries. */
static void id_parse(const pjsip_msg* msg, int is_request, spc_ident* out)
{
    static char vals[ID_MAX_ENTRIES][ID_MAX_VALUE];      /* guarded: only called with g_id_mtx held */
    int n, i, k;
    char tmp[ID_MAX_VALUE], disp[96], user[96], uri[200], privbuf[128];
    memset(out, 0, sizeof(*out));
    if (!msg) return;
    /* --- asserted identity --- */
    privbuf[0] = 0;
    {
        char pv[4][ID_MAX_VALUE];
        int np = id_headers(msg, "Privacy", NULL, pv, 4), j;
        for (j = 0; j < np; j++) { size_t l = strlen(privbuf); if (l + strlen(pv[j]) + 2 < sizeof(privbuf)) snprintf(privbuf + l, sizeof(privbuf) - l, "%s;", pv[j]); }
    }
    n = id_headers(msg, "P-Asserted-Identity", NULL, vals, 4);
    {
        int best = -1, bestk = -1;         /* prefer a sip(s): value, else the first tel: value */
        const char* p;
        char val[ID_MAX_VALUE];
        for (i = 0; i < n; i++) {
            p = vals[i];
            for (k = 0; k < 4 && id_next_value(&p, val, sizeof(val)); k++) {
                spc_parse_nameaddr(val, disp, sizeof(disp), uri, sizeof(uri), user, sizeof(user));
                if (!uri[0]) continue;
                if (id_is_sip(uri)) { best = i; bestk = k; goto found_pai; }
                if (best < 0) { best = i; bestk = k; }
            }
        }
found_pai:
        if (best >= 0) {
            p = vals[best];
            for (k = 0; k <= bestk && id_next_value(&p, val, sizeof(val)); k++) {}
            spc_parse_nameaddr(val, out->disp, sizeof(out->disp), out->uri, sizeof(out->uri), out->user, sizeof(out->user));
            out->pai_set = 1;
        }
    }
    if (!out->pai_set) {
        n = id_headers(msg, "Remote-Party-ID", NULL, vals, 2);
        if (n > 0) {
            const char* p = vals[0];
            if (id_next_value(&p, tmp, sizeof(tmp))) {
                char pr[24];
                spc_parse_nameaddr(tmp, out->disp, sizeof(out->disp), out->uri, sizeof(out->uri), out->user, sizeof(out->user));
                if (out->uri[0]) out->pai_set = 1;
                if (id_param(tmp, "privacy", pr, sizeof(pr))) {
                    if (spc_strieq(pr, "full")) out->withheld = 1;
                    else if (spc_strieq(pr, "name")) out->disp[0] = 0;
                    else if (spc_strieq(pr, "uri")) { out->uri[0] = 0; out->user[0] = 0; }
                }
            }
        }
    } else {
        /* RFC 3325: "Privacy: id" asks the UA not to reveal the asserted identity */
        if (strstr(privbuf, "id") != NULL) {
            const char* s = privbuf;
            while ((s = strstr(s, "id")) != NULL) {
                int pre_ok = (s == privbuf || s[-1] == ';' || s[-1] == ',' || s[-1] == ' ');
                int post_ok = (s[2] == 0 || s[2] == ';' || s[2] == ',' || s[2] == ' ');
                if (pre_ok && post_ok) { out->withheld = 1; break; }
                s += 2;
            }
        }
    }
    if (out->withheld) { out->disp[0] = out->uri[0] = out->user[0] = 0; out->pai_set = 0; }
    id_clean(out->disp); id_clean(out->uri); id_clean(out->user);
    if (!is_request) return;
    /* --- Referred-By --- */
    n = id_headers(msg, "Referred-By", "b", vals, 1);
    if (n > 0) {
        const char* p = vals[0];
        if (id_next_value(&p, tmp, sizeof(tmp))) {
            spc_parse_nameaddr(tmp, disp, sizeof(disp), uri, sizeof(uri), user, sizeof(user));
            spc_strlcpy(out->ref_by, uri, sizeof(out->ref_by));
            id_clean(out->ref_by);
        }
    }
    /* --- Diversion: the topmost header is the most recent diversion; reported earliest first --- */
    n = id_headers(msg, "Diversion", NULL, vals, ID_MAX_ENTRIES);
    if (n > 0) {
        spc_div all[ID_MAX_ENTRIES];
        int na = 0;
        for (i = 0; i < n; i++) {
            const char* p = vals[i];
            char val[ID_MAX_VALUE];
            for (k = 0; k < 8 && na < ID_MAX_ENTRIES && id_next_value(&p, val, sizeof(val)); k++) {
                char c[16];
                spc_div* d = &all[na];
                memset(d, 0, sizeof(*d));
                id_fill_div_uri(d, val);
                if (!d->uri[0]) continue;
                if (id_param(val, "reason", d->reason, sizeof(d->reason))) id_clean(d->reason);
                d->counter = 1;
                if (id_param(val, "counter", c, sizeof(c))) { int v = atoi(c); d->counter = v < 1 ? 1 : (v > 999 ? 999 : v); }
                na++;
            }
        }
        /* header order is most recent first (each diverting proxy adds its header on top): reverse */
        for (i = na - 1; i >= 0 && out->ndiv < SPC_MAX_DIV; i--) out->div[out->ndiv++] = all[i];
    } else {
        /* History-Info (RFC 7044): entry i-1 diverted to entry i; the reason is the Reason of entry i */
        id_he he[ID_MAX_ENTRIES];
        int nh = 0;
        n = id_headers(msg, "History-Info", NULL, vals, ID_MAX_ENTRIES);
        for (i = 0; i < n; i++) {
            const char* p = vals[i];
            char val[ID_MAX_VALUE];
            for (k = 0; k < 8 && nh < ID_MAX_ENTRIES && id_next_value(&p, val, sizeof(val)); k++) {
                char* r;
                memset(&he[nh], 0, sizeof(he[nh]));
                id_fill_div_uri(&he[nh].d, val);
                if (!he[nh].d.uri[0]) continue;
                if (!id_param(val, "index", he[nh].idx, sizeof(he[nh].idx))) he[nh].idx[0] = 0;
                id_sanitize_index(he[nh].idx);
                /* embedded Reason: sip:u@h?Reason=SIP%3Bcause%3D486 */
                r = strstr(val, "cause%3D");
                if (!r) r = strstr(val, "cause%3d");
                if (!r) r = strstr(val, "cause=");
                if (r) { r += (r[5] == '=') ? 6 : 8; { int l = 0; while (isdigit((unsigned char)r[l]) && l < 4) { he[nh].cause[l] = r[l]; l++; } he[nh].cause[l] = 0; } }
                nh++;
            }
        }
        /* sort by index (insertion sort; entries without index keep arrival order after the indexed ones) */
        for (i = 1; i < nh; i++) {
            int j = i;
            while (j > 0 && he[j - 1].idx[0] && he[j].idx[0] && id_index_cmp(he[j - 1].idx, he[j].idx) > 0) {
                id_he t = he[j]; he[j] = he[j - 1]; he[j - 1] = t; j--;
            }
        }
        for (i = 0; i + 1 < nh && out->ndiv < SPC_MAX_DIV; i++) {
            spc_div* d = &out->div[out->ndiv];
            int c = 1, j;
            *d = he[i].d;
            if (he[i + 1].cause[0]) { char rb[16]; spc_strlcpy(d->reason, id_reason_from_cause(atoi(he[i + 1].cause), rb, sizeof(rb)), sizeof(d->reason)); }
            for (j = 0; j < i; j++) if (strcmp(he[j].d.uri, d->uri) == 0) c++;
            d->counter = c;
            out->ndiv++;
        }
    }
}

static spc_mutex_t g_id_mtx;
static volatile long g_id_once;
static void id_mtx_init(void) { spc_mutex_init(&g_id_mtx); }

/* Parses and stores the identity of a message into the call. `is_request`: INVITE of an incoming call. */
static void id_store(uint64_t cid, const pjsip_msg* msg, int is_request)
{
    spc_call* c;
    spc_ident* id = (spc_ident*)malloc(sizeof(*id));
    if (!id) return;
    spc_once(&g_id_once, id_mtx_init);
    spc_mutex_lock(&g_id_mtx);
    id_parse(msg, is_request, id);
    spc_mutex_unlock(&g_id_mtx);
    spc_registry_lock();
    c = spc_call_find_locked(cid);
    if (!c) { /* call gone */ }
    else if (is_request) c->ident = *id;
    else if (id->pai_set || id->withheld) {
        c->ident.pai_set = id->pai_set; c->ident.withheld = id->withheld;
        memcpy(c->ident.disp, id->disp, sizeof(id->disp));
        memcpy(c->ident.user, id->user, sizeof(id->user));
        memcpy(c->ident.uri, id->uri, sizeof(id->uri));
    }
    spc_registry_unlock();
    free(id);
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
    cJSON_AddBoolToObject(o, "secureSignaling", c->last_secsig);
    cJSON_AddBoolToObject(o, "muted", c->muted);
    cJSON_AddBoolToObject(o, "announcementMuted", c->ann_mute);
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
    if (c->ident.pai_set) {
        cJSON* ai = cJSON_AddObjectToObject(o, "assertedIdentity");
        cJSON_AddStringToObject(ai, "display", c->ident.disp);
        cJSON_AddStringToObject(ai, "user", c->ident.user);
        cJSON_AddStringToObject(ai, "uri", c->ident.uri);
    } else cJSON_AddNullToObject(o, "assertedIdentity");
    cJSON_AddBoolToObject(o, "identityWithheld", c->ident.withheld);
    {
        cJSON* da = cJSON_AddArrayToObject(o, "diversion");
        for (i = 0; i < c->ident.ndiv; i++) {
            cJSON* d = cJSON_CreateObject();
            cJSON_AddStringToObject(d, "uri", c->ident.div[i].uri);
            cJSON_AddStringToObject(d, "user", c->ident.div[i].user);
            cJSON_AddStringToObject(d, "reason", c->ident.div[i].reason);
            cJSON_AddNumberToObject(d, "counter", c->ident.div[i].counter);
            cJSON_AddItemToArray(da, d);
        }
    }
    if (c->ident.ref_by[0]) cJSON_AddStringToObject(o, "referredBy", c->ident.ref_by);
    else cJSON_AddNullToObject(o, "referredBy");
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
    int rec2_id, ann_mute, lhold;     /* lhold: locally held with a valid conf slot (music on hold plays then) */
    int dn_slot; void* dn_h;          /* incoming voice-isolation processor of this call */
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

/* The "mic source" of every mic -> call/recorder connection: slot 0, or the voice-isolation processor (msrc >= 0)
 * which is fed from slot 0. dnm is the processor slot if it exists (so a stale path can be removed after a live
 * toggle). The new path is connected before the old one is removed, so audio never drops. */
static void conn_mic(int dst, int want, int msrc, int dnm)
{
    if (want) {
        if (msrc >= 0) { conn(msrc, dst, 1); conn(0, dst, 0); }
        else { conn(0, dst, 1); if (dnm >= 0) conn(dnm, dst, 0); }
    } else {
        conn(0, dst, 0);
        if (dnm >= 0) conn(dnm, dst, 0);
    }
}

int spc_call_mic_source(void)
{
    int s = spc_denoise_mic_wanted() ? spc_denoise_mic_slot_peek() : -1;
    return s >= 0 ? s : 0;
}

/* Incoming isolation: the call's slot feeds a per-call processor which feeds the speaker (slot 0). */
static void ensure_in_processor(topo_ent* t)
{
    int sl = -1;
    void* h;
    spc_call* c;
    if (t->dn_slot >= 0) return;
    h = spc_denoise_in_create(&sl);
    if (!h) return;
    spc_registry_lock();
    c = spc_call_find_locked(t->cid);
    if (c && !c->dn_closed && c->dn_in_slot < 0) { c->dn_in = h; c->dn_in_slot = sl; t->dn_h = h; t->dn_slot = sl; h = NULL; }
    else if (c && !c->dn_closed) { t->dn_h = c->dn_in; t->dn_slot = c->dn_in_slot; }
    spc_registry_unlock();
    if (h) spc_denoise_in_destroy(h, sl);
}

static void conn_speaker(topo_ent* t, int want, int in_want)
{
    if (want && in_want && t->dn_slot >= 0) {
        conn(t->cslot, t->dn_slot, 1);
        conn(t->dn_slot, 0, 1);
        conn(t->cslot, 0, 0);
    } else {
        conn(t->cslot, 0, want);
        if (t->dn_slot >= 0) { conn(t->cslot, t->dn_slot, 0); conn(t->dn_slot, 0, 0); }
    }
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
        t->rec2_id = c->rec2_id; t->ann_mute = c->ann_mute;
        t->dn_slot = c->dn_in_slot; t->dn_h = c->dn_in;
    }
    spc_registry_unlock();
    for (i = 0; i < n; i++) {
        pjsua_call_info ci;
        e[i].cslot = -1; e[i].active = 0; e[i].lhold = 0;
        if (e[i].slot >= SPC_ID_IAX_BASE) {
            int act = 0, cs = -1;
            if (spc_iax2_call_conf(e[i].cid, &cs, &act) == 0) { e[i].cslot = cs; e[i].active = (act && cs >= 0); }
            continue;
        }
        if (pjsua_call_get_info(e[i].slot, &ci) != PJ_SUCCESS) continue;
        e[i].cslot = ci.conf_slot;
        /* a call the remote party holds still delivers audio (e.g. the holder's music on hold), so it counts as active */
        e[i].active = ((ci.media_status == PJSUA_CALL_MEDIA_ACTIVE || ci.media_status == PJSUA_CALL_MEDIA_REMOTE_HOLD) && ci.conf_slot >= 0);
        e[i].lhold = (ci.media_status == PJSUA_CALL_MEDIA_LOCAL_HOLD && ci.conf_slot >= 0);
    }
    {
        int in_want = spc_denoise_in_wanted();
        int msrc = (n > 0 && spc_denoise_mic_wanted()) ? spc_denoise_mic_slot() : -1;
        int dnm = spc_denoise_mic_slot_peek();
        if (dnm >= 0) conn(0, dnm, msrc >= 0);       /* processor input: only while it is the active mic source */
        spc_musicbed_apply_begin();
        for (i = 0; i < n; i++) {
        topo_ent* t = &e[i];
        int local_ok;
        if (t->cslot < 0) continue;
        local_ok = t->active && !t->detached && !t->held;
        if (in_want && local_ok) ensure_in_processor(t);
        conn_mic(t->cslot, local_ok && !t->muted && !t->ann_mute, msrc, dnm);
        conn_speaker(t, local_ok, in_want);
        if (t->rec_id >= 0) {
            int rp = pjsua_recorder_get_conf_port(t->rec_id);
            if (rp >= 0) {
                conn(t->cslot, rp, t->active && (t->rec_mix == 0 || t->rec_mix == 1));
                conn_mic(rp, (t->rec_mix == 0 || t->rec_mix == 2) && !t->muted && !t->detached, msrc, dnm);
            }
        }
        spc_rec_apply_call(t->rec2_id, t->cslot, t->active, t->muted, t->detached, msrc, dnm);
        spc_player_apply_call(t->cid, t->cslot, t->active, t->lhold, t->held);     /* media files + music on hold (spc_player.c) */
        {   /* musicbed: wherever the microphone would go, regardless of call.mute / announcement mute */
            int rs1 = -1, rs2 = -1;
            if (t->rec_id >= 0 && (t->rec_mix == 0 || t->rec_mix == 2)) rs1 = pjsua_recorder_get_conf_port(t->rec_id);
            rs2 = spc_rec_local_sink(t->rec2_id);
            spc_musicbed_apply_call(t->cid, t->cslot, local_ok, rs1, rs2);
        }
        if (t->tg_slot >= 0) conn(t->tg_slot, t->cslot, t->active);
        for (k = 0; k < t->nconf + t->nbr; k++) {
            uint64_t peer = k < t->nconf ? t->conf[k] : t->bridged[k - t->nconf];
            j = ent_find(e, n, peer);
            if (j < 0 || e[j].cslot < 0) continue;
            conn(t->cslot, e[j].cslot, t->active && e[j].active && !t->held && !e[j].held);
        }
        }
        spc_musicbed_apply_end();
        spc_rec_apply_global(msrc, dnm);        /* microphone recorder (media.recordMicStart), independent of calls */
    }
}

/* media.levels "calls": conference slot levels of every call with active media */
cJSON* spc_call_levels_json(void)
{
    uint64_t cid[PJSUA_MAX_CALLS];
    int slot[PJSUA_MAX_CALLS];
    int n = 0, i;
    spc_call* c;
    cJSON* arr = cJSON_CreateArray();
    spc_registry_lock();
    for (c = g_calls; c && n < PJSUA_MAX_CALLS; c = c->next) { cid[n] = c->cid; slot[n] = c->slot; n++; }
    spc_registry_unlock();
    for (i = 0; i < n; i++) {
        int cs = -1, act = 0;
        unsigned tx = 0, rx = 0;
        cJSON* o;
        if (slot[i] >= SPC_ID_IAX_BASE) {
            if (spc_iax2_call_conf(cid[i], &cs, &act) != 0 || !act) continue;
        } else {
            pjsua_call_info ci;
            if (pjsua_call_get_info(slot[i], &ci) != PJ_SUCCESS) continue;
            if (!(ci.media_status == PJSUA_CALL_MEDIA_ACTIVE || ci.media_status == PJSUA_CALL_MEDIA_REMOTE_HOLD)) continue;
            cs = ci.conf_slot;
        }
        if (cs < 0 || pjsua_conf_get_signal_level(cs, &tx, &rx) != PJ_SUCCESS) continue;
        o = cJSON_CreateObject();
        cJSON_AddNumberToObject(o, "cid", (double)cid[i]);
        cJSON_AddNumberToObject(o, "rx", rx);
        cJSON_AddNumberToObject(o, "tx", tx);
        cJSON_AddItemToArray(arr, o);
    }
    return arr;
}

void spc_call_apply_media_all(void) { spc_call_apply_topology(); }

/* ------------------------------------------------------------------ */
/* media resources cleanup                                             */
/* ------------------------------------------------------------------ */
void spc_call_cleanup_media(spc_call* c)
{
    int rec = -1, pl = -1, tgs = -1, was_rec = 0, dns = -1, rec2 = 0;
    void* dnh = NULL;
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
    dnh = c->dn_in; dns = c->dn_in_slot; c->dn_in = NULL; c->dn_in_slot = -1; c->dn_closed = 1;
    spc_strlcpy(file, c->rec_file, sizeof(file));
    rec2 = c->rec2_id; c->rec2_id = 0;
    spc_registry_unlock();
    spc_player_stop_call(c->cid, "hangup");        /* playDone(hangup) for every file + pending music on hold */
    if (rec >= 0) pjsua_recorder_destroy(rec);
    if (rec2 > 0) spc_rec_stop(rec2, NULL);
    if (was_rec) {
        cJSON* f = cJSON_CreateObject();
        cJSON_AddNumberToObject(f, "cid", (double)c->cid);
        cJSON_AddBoolToObject(f, "recording", 0);
        cJSON_AddStringToObject(f, "file", file);
        spc_call_emit(c->cid, "call.recording", f);
    }
    if (pl >= 0) pjsua_player_destroy(pl);
    if (dnh) spc_denoise_in_destroy(dnh, dns);
    if (tgs >= 0) pjsua_conf_remove_port(tgs);
    if (tg) {
        spc_mutex_lock(&G.tg_mtx);          /* serialises with inband DTMF playing on the same port */
        spc_port_destroy_release(tg, tgp);     /* the pool is freed when the bridge drops its last reference */
        spc_mutex_unlock(&G.tg_mtx);
    } else if (tgp) pj_pool_release(tgp);
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
    if (rdata && rdata->msg_info.msg) id_store(c->cid, rdata->msg_info.msg, 1);
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
    if (pjsua_call_get_info(call_id, &ci) != PJ_SUCCESS) return;
    c = call_create(call_id, &ci, &created, 0);
    if (!c) return;
    if (created && c->role == 1 && !c->incoming_emitted) emit_incoming(c, &ci, NULL);
    if (c->role == 0 && e && e->type == PJSIP_EVENT_TSX_STATE && e->body.tsx_state.type == PJSIP_EVENT_RX_MSG) {
        pjsip_rx_data* rd = e->body.tsx_state.src.rdata;     /* identity of the answering party in 18x/2xx */
        if (rd && rd->msg_info.msg && rd->msg_info.msg->type == PJSIP_RESPONSE_MSG &&
            rd->msg_info.msg->line.status.code >= 180 && rd->msg_info.msg->line.status.code < 300)
            id_store(c->cid, rd->msg_info.msg, 0);
    }
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
    else if (dlg_secure(call_id)) { spc_registry_lock(); c->last_secsig = 1; spc_registry_unlock(); }
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
    spc_moh_on_media(cid, (int)ci.media_status);      /* client-side music on hold starts once the hold is acknowledged */
    pjsua_schedule_timer2(&timer_topology, NULL, 0);     /* full re-apply happens off the dialog lock (m7) */
    spc_registry_lock();
    c = spc_call_find_locked(cid);
    if (!c || c->ended) { spc_registry_unlock(); return; }
    {
        int ns = srtp ? 1 : 0;
        if (secure) c->last_secsig = 1;
        secure = c->last_secsig;
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
        cJSON_AddBoolToObject(f, "secureSignaling", secure);
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
    if (tsx->role == PJSIP_ROLE_UAC && tsx->method.id == PJSIP_INVITE_METHOD) {
        /* outgoing call: P-Asserted-Identity of the answering party from 18x/2xx responses */
        rd = e->body.tsx_state.src.rdata;
        if (rd && rd->msg_info.msg && rd->msg_info.msg->type == PJSIP_RESPONSE_MSG &&
            rd->msg_info.msg->line.status.code >= 180 && rd->msg_info.msg->line.status.code < 300) {
            uint64_t icid = slot_snapshot(call_id, NULL);
            if (icid) id_store(icid, rd->msg_info.msg, 0);
        }
        return;
    }
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
    c->rec_id = -1; c->player_id = -1; c->tg_slot = -1; c->dn_in_slot = -1;
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
