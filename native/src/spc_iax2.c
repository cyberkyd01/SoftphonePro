/* spc_iax2.c: IAX2 (RFC 5456) client for spcore.
 *
 * Design
 *  - One UDP socket and one worker thread ("spc-iax2") for all IAX2 accounts/calls. The thread does select(),
 *    frame parsing, retransmission/registration/call timers and ALL media setup/teardown and terminal events.
 *  - One recursive mutex (g_mtx) protects accounts, sessions and call state. Lock order is
 *        g_mtx  ->  registry lock (G.reg_mtx)  ->  emit mutex.
 *    pjsua/conference-bridge APIs are NEVER called with g_mtx held (the bridge clock thread calls into
 *    port_put_frame(), which takes g_mtx, so conf lock -> g_mtx is the only legal order).
 *  - A call is an spc_call in the shared registry (proto = 1, slot = SPC_ID_IAX_BASE + n), so cid, flags,
 *    conference lists, bridge lists, recording and playback behave exactly like SIP calls. The audio side is a
 *    custom pjmedia_port (8 kHz, mono, 20 ms) added with pjsua_conf_add_port().
 *  - Sessions are freed only by the IAX thread, and never while their media port is still in the bridge.
 */
#include "spc_internal.h"
#include "spc_iax2_proto.h"
#include <pjmedia/jbuf.h>
#include <pjmedia/alaw_ulaw.h>
#include <pjmedia/codec.h>
#include <pjmedia/endpoint.h>
#include <pjmedia/port.h>
#include <ctype.h>
#include <math.h>

#define IAX_DEFAULT_PORT 4569
#define IAX_MAX_SESS 256
#define IAX_MAXQ 64
#define IAX_MAX_TRIES 6
#define IAX_PORT_SIG PJMEDIA_SIG_CLASS_PORT_AUD('I', 'X')
#define IAX_FRAME_SAMPLES 160
#define IAX_FRAME_BYTES (IAX_FRAME_SAMPLES * 2)

enum { SK_CALL = 1, SK_REG = 2 };
enum { CS_CALLING = 0, CS_INCOMING, CS_EARLY, CS_CONFIRMED, CS_DISC };
enum { A_REG = 1, A_MEDIA, A_FINISH };

typedef struct iax_pkt {
    struct iax_pkt* next;
    uint8_t oseq, type, sub;
    uint32_t ts;
    uint8_t* ies;
    size_t ielen;
    int tries;
    int64_t due;
    int final;                      /* HANGUP/REJECT/ACK-like: failure is silent */
} iax_pkt;

typedef struct iax_acct {
    struct iax_acct* next;
    int acc;
    char uid[96], user[64], pass[128], host[128], context[64], display[64], caller_id[64];
    int port;
    int regexpires, retry_sec, first_retry_sec;
    int want_reg;
    pj_sockaddr_in addr;
    int addr_ok;
    char reg_state[16];
    int reg_code;
    char reg_reason[96], last_error[200];
    int granted;                    /* seconds granted by the server */
    int64_t reg_ok_ms;              /* when the current registration was confirmed */
    int64_t next_reg_ms;            /* 0 = nothing scheduled */
    uint16_t reg_call;              /* lcall of the in-flight registration transaction, 0 = none */
    int reg_busy;                   /* resolve phase in progress */
    int fails;
    int ever_registered;
    char presence[12], presence_note[128];
    char dtmf_method[12];
    int ncodecs;
    char codecs[SPC_MAX_CODECS][40];
    cJSON* cfg;
} iax_acct;

typedef struct iax_codec {
    pjmedia_codec* enc;
    pjmedia_codec* dec;
} iax_codec;

typedef struct iax_sess {
    struct iax_sess* next;
    int kind;
    int acc;
    uint16_t lcall, rcall;
    pj_sockaddr_in peer;
    uint8_t oseq, iseq;
    int64_t t0;
    int64_t last_rx_ms;
    iax_pkt* q;
    int zombie;                     /* no spc_call any more: only acks/retransmits */
    int64_t kill_at;
    int64_t last_vnak_ms;
    int64_t t_ping;
    uint32_t rx_hi_ts;              /* newest full-frame timestamp seen (for mini-frame ts reconstruction) */
    int have_hi_ts;
    /* credentials copied for REG sessions (account may disappear) */
    char user[64], pass[128];
    int unreg, reg_req_refresh;
    int auth_tries;
    /* call */
    uint64_t cid;
    int role;                       /* 0 caller, 1 callee */
    int state, scode;
    char sreason[64];
    int slot;
    char called[64], remote_num[64], remote_name[64], remote_user[64];
    char host[128];
    char local_user[64];
    uint32_t cap_ours, tx_fmt, rx_fmt;
    int accepted;
    int term_req, finished, term_code;
    char term_text[64];
    int want_media;
    int media_state;                /* 0 none, 3 starting, 1 active, 2 torn down */
    int conf_slot;
    pj_pool_t* pool;
    pjmedia_port* port;
    pjmedia_jbuf* jb;
    spc_mutex_t jbm;
    int jbm_init;
    iax_codec codec;
    int have_gsm;
    int held, rhold, quelch;
    int64_t t_created, t_answer;
    int64_t auto_ring_at, unattended_at;
    int64_t t_term;
    /* tx voice */
    int tx_full_sent;
    uint32_t tx_last_full_ts, vts_next;
    int vts_init;
    /* rx voice */
    int rx_seq_init;
    int rx_seq_last;
    uint32_t rx_ref_ts;
    int rx_ref_seq;
    int64_t jit_prev_arr;
    uint32_t jit_prev_ts;
    int jit_init;
    double jitter_ms, jitter_max_ms;
    /* stats */
    unsigned tx_pkts, rx_pkts, rx_dup, rx_reorder;
    unsigned long long tx_bytes, rx_bytes;
    double rtt_last, rtt_min, rtt_max, rtt_sum;
    unsigned rtt_n;
    /* dtmf out */
    char dtmf_q[40];
    int dtmf_n, dtmf_pos, dtmf_dur;
    int dtmf_state;                 /* 0 idle, 1 begun (waiting for end), 2 gap */
    int64_t dtmf_next;
    int64_t dtmf_rx_begin_ms;
    char last_media[12];
    int calltoken_sent;
} iax_sess;

typedef struct { int type; int id; iax_sess* s; } iax_action;

/* ------------------------------------------------------------------ */
/* globals                                                             */
/* ------------------------------------------------------------------ */
static spc_mutex_t g_mtx;
static volatile int g_ready;
static volatile int g_up;
static volatile int g_quit;
static pj_sock_t g_sock = PJ_INVALID_SOCKET;
static int g_port;
static spc_thread_t g_thr;
static iax_acct* g_accts;
static iax_sess* g_sessions;
static int g_acc_counter = SPC_ID_IAX_BASE - 1;
static unsigned g_callno_ctr;
static int g_cfg_port = IAX_DEFAULT_PORT;
static int g_cfg_enabled = 1;
static int64_t g_inval_win;
static int g_inval_cnt;
static int g_have_gsm = -1;

#define LK() spc_mutex_lock(&g_mtx)
#define UK() spc_mutex_unlock(&g_mtx)
#define NOW() spc_mono_ms()

static void ensure_ready(void)
{
    if (!g_ready) { spc_mutex_init(&g_mtx); g_ready = 1; }
}

/* ------------------------------------------------------------------ */
/* small helpers                                                       */
/* ------------------------------------------------------------------ */
static int addr_eq(const pj_sockaddr_in* a, const pj_sockaddr_in* b)
{
    return a->sin_addr.s_addr == b->sin_addr.s_addr && a->sin_port == b->sin_port;
}
static int ip_eq(const pj_sockaddr_in* a, const pj_sockaddr_in* b)
{
    return a->sin_addr.s_addr == b->sin_addr.s_addr;
}
static void addr_str(const pj_sockaddr_in* a, char* out, size_t n)
{
    char ip[32];
    pj_in_addr ia = a->sin_addr;
    snprintf(ip, sizeof(ip), "%s", pj_inet_ntoa(ia));
    snprintf(out, n, "%s:%d", ip, (int)pj_ntohs(a->sin_port));
}

static iax_acct* acct_find(int acc)
{
    iax_acct* a;
    for (a = g_accts; a; a = a->next) if (a->acc == acc) return a;
    return NULL;
}
static iax_sess* sess_by_lcall(uint16_t n)
{
    iax_sess* s;
    for (s = g_sessions; s; s = s->next) if (s->lcall == n) return s;
    return NULL;
}
static iax_sess* sess_by_cid(uint64_t cid)
{
    iax_sess* s;
    if (!cid) return NULL;
    for (s = g_sessions; s; s = s->next) if (s->cid == cid && !s->zombie) return s;
    return NULL;
}
static int sess_count(void)
{
    int n = 0;
    iax_sess* s;
    for (s = g_sessions; s; s = s->next) n++;
    return n;
}

static void raw_send(const uint8_t* b, size_t n, const pj_sockaddr_in* to)
{
    pj_ssize_t len = (pj_ssize_t)n;
    if (g_sock == PJ_INVALID_SOCKET) return;
    pj_sock_sendto(g_sock, b, &len, 0, to, sizeof(*to));
}

static uint32_t sess_ts(iax_sess* s)
{
    int64_t d = NOW() - s->t0;
    if (d < 1) d = 1;
    return (uint32_t)d;
}

static void tx_full(iax_sess* s, uint8_t type, uint8_t sub, uint32_t ts, const uint8_t* ies, size_t ielen,
                    uint8_t oseq, int retrans)
{
    uint8_t buf[IAX_MAX_PKT];
    if (ielen > sizeof(buf) - IAX_FULL_HDR) return;
    iax_put_full_hdr(buf, s->lcall, s->rcall, retrans, ts, oseq, s->iseq, type, sub);
    if (ielen) memcpy(buf + IAX_FULL_HDR, ies, ielen);
    raw_send(buf, IAX_FULL_HDR + ielen, &s->peer);
}

static unsigned rto_ms(int tries)
{
    static const unsigned t[] = { 500, 1000, 1000, 2000, 2000, 2000, 2000 };
    return t[tries < 0 ? 0 : (tries > 6 ? 6 : tries)];
}

/* reliable full frame: queued until acked. ts_override 0 = use the session clock. */
static int send_rel(iax_sess* s, uint8_t type, uint8_t sub, const uint8_t* ies, size_t ielen, int final, uint32_t ts_override)
{
    iax_pkt *p, **pp;
    int n = 0;
    for (pp = &s->q; *pp; pp = &(*pp)->next) n++;
    if (n >= IAX_MAXQ) return -1;
    p = (iax_pkt*)calloc(1, sizeof(*p));
    if (!p) return -1;
    p->ies = (uint8_t*)malloc(ielen ? ielen : 1);
    if (!p->ies) { free(p); return -1; }
    if (ielen) memcpy(p->ies, ies, ielen);
    p->ielen = ielen;
    p->oseq = s->oseq++;
    p->type = type;
    p->sub = sub;
    p->ts = ts_override ? ts_override : sess_ts(s);
    p->due = NOW() + (int64_t)rto_ms(0);
    p->final = final;
    *pp = p;
    tx_full(s, type, sub, p->ts, ies, ielen, p->oseq, 0);
    return 0;
}

static void send_ack(iax_sess* s, uint32_t ts)
{
    tx_full(s, IAXF_IAX, IAXC_ACK, ts, NULL, 0, s->oseq, 0);
}

static void send_apathetic(const pj_sockaddr_in* to, uint16_t scall_field, uint16_t dcall, uint8_t iseq, uint8_t sub,
                           uint32_t ts, const uint8_t* ies, size_t ielen)
{
    uint8_t buf[IAX_MAX_PKT];
    if (ielen > sizeof(buf) - IAX_FULL_HDR) return;
    iax_put_full_hdr(buf, scall_field, dcall, 0, ts, 0, iseq, IAXF_IAX, sub);
    if (ielen) memcpy(buf + IAX_FULL_HDR, ies, ielen);
    raw_send(buf, IAX_FULL_HDR + ielen, to);
}

static void pkts_free(iax_sess* s)
{
    while (s->q) { iax_pkt* n = s->q->next; free(s->q->ies); free(s->q); s->q = n; }
}

static iax_sess* sess_new(int kind, int acc, const pj_sockaddr_in* peer)
{
    iax_sess* s;
    int tries;
    if (sess_count() >= IAX_MAX_SESS) return NULL;
    s = (iax_sess*)calloc(1, sizeof(*s));
    if (!s) return NULL;
    s->kind = kind;
    s->acc = acc;
    s->peer = *peer;
    s->t0 = NOW();
    s->last_rx_ms = s->t0;
    s->t_created = s->t0;
    s->conf_slot = -1;
    s->slot = -1;
    s->rtt_min = 1e9;
    spc_strlcpy(s->last_media, "none", sizeof(s->last_media));
    if (!g_callno_ctr) g_callno_ctr = (unsigned)(s->t0 & 0x3fff) + 1;
    for (tries = 0; tries < 40000; tries++) {
        g_callno_ctr = (g_callno_ctr % 32767) + 1;
        if (!sess_by_lcall((uint16_t)g_callno_ctr)) break;
    }
    if (tries >= 40000) { free(s); return NULL; }
    s->lcall = (uint16_t)g_callno_ctr;
    s->next = g_sessions;
    g_sessions = s;
    return s;
}

static void sess_destroy(iax_sess* s)
{
    iax_sess** pp;
    for (pp = &g_sessions; *pp; pp = &(*pp)->next) if (*pp == s) { *pp = s->next; break; }
    pkts_free(s);
    if (s->jbm_init) spc_mutex_destroy(&s->jbm);
    free(s);
}

/* ------------------------------------------------------------------ */
/* codecs                                                              */
/* ------------------------------------------------------------------ */
static int gsm_available(void)
{
    if (g_have_gsm < 0) {
        pjmedia_codec_mgr* mgr = pjmedia_endpt_get_codec_mgr(pjsua_get_pjmedia_endpt());
        pj_str_t id = pj_str((char*)"gsm/8000/1");
        unsigned cnt = 1;
        const pjmedia_codec_info* ci[1];
        g_have_gsm = (mgr && pjmedia_codec_mgr_find_codecs_by_id(mgr, &id, &cnt, ci, NULL) == PJ_SUCCESS && cnt > 0) ? 1 : 0;
    }
    return g_have_gsm;
}

static const char* fmt_name(uint32_t f)
{
    switch (f) {
    case IAXFMT_ULAW: return "PCMU/8000/1";
    case IAXFMT_ALAW: return "PCMA/8000/1";
    case IAXFMT_GSM: return "GSM/8000/1";
    default: return "";
    }
}

/* ordered list of formats for the account; returns the count (always >= 1) */
static int acct_formats(const iax_acct* a, uint32_t* out)
{
    int n = 0, i;
    if (a && a->ncodecs > 0) {
        for (i = 0; i < a->ncodecs && n < 3; i++) {
            uint32_t f = 0;
            const char* c = a->codecs[i];
            if (spc_strnieq(c, "PCMU", 4) || spc_strnieq(c, "ulaw", 4)) f = IAXFMT_ULAW;
            else if (spc_strnieq(c, "PCMA", 4) || spc_strnieq(c, "alaw", 4)) f = IAXFMT_ALAW;
            else if (spc_strnieq(c, "GSM", 3)) f = IAXFMT_GSM;
            if (f == IAXFMT_GSM && !gsm_available()) f = 0;
            if (f) { int dup = 0, j; for (j = 0; j < n; j++) if (out[j] == f) dup = 1; if (!dup) out[n++] = f; }
        }
    }
    if (n == 0) {
        out[n++] = IAXFMT_ULAW;
        out[n++] = IAXFMT_ALAW;
        if (gsm_available()) out[n++] = IAXFMT_GSM;
    }
    return n;
}

static uint32_t fmts_mask(const uint32_t* f, int n)
{
    uint32_t m = 0;
    int i;
    for (i = 0; i < n; i++) m |= f[i];
    return m;
}

/* ------------------------------------------------------------------ */
/* JSON builders (g_mtx held)                                          */
/* ------------------------------------------------------------------ */
static const char* cstate_name(int st)
{
    switch (st) {
    case CS_CALLING: return "calling";
    case CS_INCOMING: return "incoming";
    case CS_EARLY: return "early";
    case CS_CONFIRMED: return "confirmed";
    default: return "disconnected";
    }
}

static const char* media_str(const iax_sess* s)
{
    if (s->media_state != 1) return "none";
    if (s->held) return "localHold";
    if (s->rhold) return "remoteHold";
    return "active";
}

/* g_mtx and registry lock held; c may be NULL for a gone call */
static cJSON* call_info_locked(iax_sess* s, spc_call* c)
{
    cJSON* o = cJSON_CreateObject();
    char uri[200], luri[200], tag[16];
    int i;
    int64_t now = NOW();
    cJSON_AddNumberToObject(o, "cid", (double)s->cid);
    cJSON_AddNumberToObject(o, "call", s->slot);
    cJSON_AddNumberToObject(o, "acc", s->acc);
    cJSON_AddStringToObject(o, "uid", c ? c->uid : "");
    cJSON_AddStringToObject(o, "proto", "iax2");
    cJSON_AddStringToObject(o, "role", s->role ? "callee" : "caller");
    cJSON_AddStringToObject(o, "state", cstate_name(s->state));
    cJSON_AddNumberToObject(o, "stateCode", s->scode);
    cJSON_AddStringToObject(o, "stateReason", s->sreason);
    cJSON_AddNumberToObject(o, "lastCode", s->scode);
    snprintf(uri, sizeof(uri), "iax2:%s@%s", s->remote_user[0] ? s->remote_user : "unknown", s->host);
    snprintf(luri, sizeof(luri), "iax2:%s@%s", s->local_user, s->host);
    cJSON_AddStringToObject(o, "remoteUri", uri);
    cJSON_AddStringToObject(o, "remoteContact", "");
    cJSON_AddStringToObject(o, "remoteDisplay", s->remote_name);
    cJSON_AddStringToObject(o, "remoteUser", s->remote_user);
    cJSON_AddStringToObject(o, "localUri", luri);
    snprintf(uri, sizeof(uri), "iax2-%u-%u", (unsigned)s->lcall, (unsigned)s->rcall);
    cJSON_AddStringToObject(o, "callId", uri);
    snprintf(tag, sizeof(tag), "%u", (unsigned)s->lcall);
    cJSON_AddStringToObject(o, "localTag", tag);
    snprintf(tag, sizeof(tag), "%u", (unsigned)s->rcall);
    cJSON_AddStringToObject(o, "remoteTag", tag);
    cJSON_AddStringToObject(o, "media", media_str(s));
    cJSON_AddStringToObject(o, "codec", s->media_state == 1 || s->state >= CS_EARLY ? fmt_name(s->tx_fmt) : "");
    cJSON_AddBoolToObject(o, "srtp", 0);
    cJSON_AddBoolToObject(o, "secureSignaling", 0);
    cJSON_AddBoolToObject(o, "muted", c ? c->muted : 0);
    cJSON_AddBoolToObject(o, "recording", c ? c->recording : 0);
    cJSON_AddBoolToObject(o, "detached", c ? c->detached : 0);
    cJSON_AddBoolToObject(o, "held", c ? c->held : 0);
    {
        cJSON* a = cJSON_AddArrayToObject(o, "conferenceWith");
        if (c) for (i = 0; i < c->nconf; i++) cJSON_AddItemToArray(a, cJSON_CreateNumber((double)c->conf[i]));
        a = cJSON_AddArrayToObject(o, "bridgedWith");
        if (c) for (i = 0; i < c->nbr; i++) cJSON_AddItemToArray(a, cJSON_CreateNumber((double)c->bridged[i]));
    }
    cJSON_AddNumberToObject(o, "connectMs", s->t_answer ? (double)((s->state == CS_DISC && s->t_term ? s->t_term : now) - s->t_answer) : 0);
    cJSON_AddNumberToObject(o, "totalMs", (double)((s->state == CS_DISC && s->t_term ? s->t_term : now) - s->t_created));
    return o;
}

/* emit call.state for the current state (g_mtx held) */
static void emit_state(iax_sess* s)
{
    spc_call* c;
    cJSON* o;
    if (!s->cid || s->finished) return;
    spc_registry_lock();
    c = spc_call_find_locked(s->cid);
    if (c) {
        o = call_info_locked(s, c);
        spc_emit("call.state", o);
    }
    spc_registry_unlock();
}

static void set_state(iax_sess* s, int st, int code, const char* reason)
{
    int changed = (s->state != st || s->scode != code);
    s->state = st;
    s->scode = code;
    spc_strlcpy(s->sreason, reason, sizeof(s->sreason));
    if (changed) emit_state(s);
}

/* call.media on change (g_mtx held) */
static void emit_media(iax_sess* s)
{
    spc_call* c;
    const char* m = media_str(s);
    if (!s->cid || s->finished) return;
    spc_registry_lock();
    c = spc_call_find_locked(s->cid);
    if (c && strcmp(c->last_media, m) != 0) {
        cJSON* f = cJSON_CreateObject();
        cJSON* ice;
        spc_strlcpy(c->last_media, m, sizeof(c->last_media));
        spc_strlcpy(c->last_codec, fmt_name(s->tx_fmt), sizeof(c->last_codec));
        cJSON_AddNumberToObject(f, "cid", (double)c->cid);
        cJSON_AddStringToObject(f, "media", m);
        cJSON_AddStringToObject(f, "codec", fmt_name(s->tx_fmt));
        cJSON_AddBoolToObject(f, "srtp", 0);
        cJSON_AddNullToObject(f, "crypto");
        cJSON_AddBoolToObject(f, "secureSignaling", 0);
        ice = cJSON_AddObjectToObject(f, "ice");
        cJSON_AddStringToObject(ice, "state", "none");
        cJSON_AddStringToObject(ice, "localType", "");
        cJSON_AddStringToObject(ice, "remoteType", "");
        spc_emit("call.media", f);
    }
    spc_registry_unlock();
}

/* ------------------------------------------------------------------ */
/* accounts: JSON, registration                                        */
/* ------------------------------------------------------------------ */
static cJSON* acct_info_locked(iax_acct* a)
{
    cJSON* o = cJSON_CreateObject();
    char uri[300];
    int64_t now = NOW();
    int registered = strcmp(a->reg_state, "registered") == 0;
    double exp = 0;
    if (registered && a->granted > 0) {
        exp = (double)a->granted - (double)(now - a->reg_ok_ms) / 1000.0;
        if (exp < 0) exp = 0;
        exp = floor(exp);
    }
    snprintf(uri, sizeof(uri), "iax2:%s@%s", a->user, a->host);
    cJSON_AddNumberToObject(o, "acc", a->acc);
    cJSON_AddStringToObject(o, "uid", a->uid);
    cJSON_AddStringToObject(o, "proto", "iax2");
    cJSON_AddStringToObject(o, "uri", uri);
    cJSON_AddStringToObject(o, "regState", a->reg_state);
    cJSON_AddNumberToObject(o, "regCode", a->reg_code);
    cJSON_AddStringToObject(o, "regReason", a->reg_reason);
    cJSON_AddNumberToObject(o, "status", 0);
    cJSON_AddStringToObject(o, "statusText", a->reg_reason[0] ? a->reg_reason : "Success");
    spc_jadd_str(o, "lastError", a->last_error[0] ? a->last_error : NULL);
    cJSON_AddNumberToObject(o, "expires", exp);
    cJSON_AddBoolToObject(o, "online", strcmp(a->presence, "offline") != 0);
    cJSON_AddBoolToObject(o, "isUnreg", strcmp(a->reg_state, "unregistered") == 0);
    cJSON_AddNullToObject(o, "contact");
    cJSON_AddStringToObject(o, "transport", "udp");
    cJSON_AddStringToObject(o, "presence", a->presence);
    cJSON_AddBoolToObject(o, "isLan", 0);
    cJSON_AddBoolToObject(o, "isDirect", 0);
    return o;
}

static void emit_acc(iax_acct* a)
{
    cJSON* o = acct_info_locked(a);
    spc_emit("account.reg", o);
}

static void acct_set_state(iax_acct* a, const char* st, int code, const char* reason, const char* lasterr)
{
    spc_strlcpy(a->reg_state, st, sizeof(a->reg_state));
    a->reg_code = code;
    spc_strlcpy(a->reg_reason, reason ? reason : "", sizeof(a->reg_reason));
    spc_strlcpy(a->last_error, lasterr ? lasterr : "", sizeof(a->last_error));
    emit_acc(a);
}

static int resolve_host(const char* host, pj_sockaddr_in* out)
{
    pj_str_t h = pj_str((char*)host);
    pj_in_addr ia;
    if (!host[0]) return -1;
    if (pj_inet_aton(&h, &ia) > 0) {
        pj_bzero(out, sizeof(*out));
        out->sin_family = pj_AF_INET();
        out->sin_addr = ia;
        return 0;
    }
    {
        uint32_t a4 = 0;
        if (spc_resolve_ipv4(host, &a4, 3000) != 0) return -1;      /* bounded: the worker must stay responsive */
        pj_bzero(out, sizeof(*out));
        out->sin_family = pj_AF_INET();
        out->sin_addr.s_addr = a4;
        return 0;
    }
}

static void sched_retry(iax_acct* a)
{
    int sec = a->fails <= 1 ? a->first_retry_sec : a->retry_sec;
    if (sec < 1) sec = 1;
    a->next_reg_ms = NOW() + (int64_t)sec * 1000;
}

static void reg_failed(iax_acct* a, int code, const char* reason, const char* lasterr)
{
    a->fails++;
    a->granted = 0;
    acct_set_state(a, "failed", code, reason, lasterr);
    if (a->want_reg) sched_retry(a); else a->next_reg_ms = 0;
}

static void reg_succeeded(iax_acct* a, int granted)
{
    int delay;
    if (granted <= 0) granted = a->regexpires > 0 ? a->regexpires : 60;
    a->granted = granted;
    a->reg_ok_ms = NOW();
    a->fails = 0;
    a->ever_registered = 1;
    delay = granted - (granted / 4 > 5 ? granted / 4 : 5);
    if (delay < 1) delay = 1;
    a->next_reg_ms = NOW() + (int64_t)delay * 1000;
    acct_set_state(a, "registered", 200, "OK", "");
}

/* g_mtx held. Starts a REGREQ/REGREL transaction (address already resolved). */
static void reg_begin_locked(iax_acct* a, int unreg)
{
    iax_sess* s;
    uint8_t ie[256];
    size_t o = 0;
    if (!g_up) return;
    if (!a->addr_ok) { reg_failed(a, 502, "Bad Gateway", "DNS lookup failed"); return; }
    s = sess_new(SK_REG, a->acc, &a->addr);
    if (!s) { reg_failed(a, 500, "Internal Error", "Registration failed (resources)"); return; }
    s->unreg = unreg;
    s->reg_req_refresh = a->regexpires > 0 ? a->regexpires : 60;
    spc_strlcpy(s->user, a->user, sizeof(s->user));
    spc_strlcpy(s->pass, a->pass, sizeof(s->pass));
    a->reg_call = s->lcall;
    a->next_reg_ms = 0;
    acct_set_state(a, unreg ? "unregistering" : "registering", 0, "", "");
    o = iax_put_str(ie, 0, sizeof(ie), IAXIE_USERNAME, s->user);
    if (o) o = iax_put_u16(ie, o, sizeof(ie), IAXIE_REFRESH, (uint16_t)s->reg_req_refresh);
    if (!o) return;
    send_rel(s, IAXF_IAX, unreg ? IAXC_REGREL : IAXC_REGREQ, ie, o, 0, 0);
}

/* Cancels an in-flight registration transaction (g_mtx held). */
static void reg_cancel_locked(iax_acct* a)
{
    if (a->reg_call) {
        iax_sess* s = sess_by_lcall(a->reg_call);
        if (s) { s->zombie = 1; s->kill_at = NOW() + 200; pkts_free(s); }
        a->reg_call = 0;
    }
}

/* Worker/IAX-thread entry (g_mtx NOT held): (re)register or unregister, resolving DNS without the lock. */
static void acct_do_reg(int acc, int unreg)
{
    iax_acct* a;
    char host[128];
    int need = 0;
    pj_sockaddr_in addr;
    LK();
    a = acct_find(acc);
    if (!a || a->reg_busy) { UK(); return; }
    if (!a->addr_ok && !unreg) { need = 1; a->reg_busy = 1; spc_strlcpy(host, a->host, sizeof(host)); }
    UK();
    if (need) {
        int ok = resolve_host(host, &addr) == 0;
        LK();
        a = acct_find(acc);
        if (!a) { UK(); return; }
        a->reg_busy = 0;
        if (ok && strcmp(host, a->host) == 0) {
            a->addr = addr;
            a->addr.sin_port = pj_htons((pj_uint16_t)a->port);
            a->addr_ok = 1;
        }
        UK();
    }
    LK();
    a = acct_find(acc);
    if (!a) { UK(); return; }
    if (unreg) {
        int was = strcmp(a->reg_state, "registered") == 0 || strcmp(a->reg_state, "registering") == 0;
        a->want_reg = 0;
        a->next_reg_ms = 0;
        reg_cancel_locked(a);
        if (was && a->addr_ok && g_up) reg_begin_locked(a, 1);
        else acct_set_state(a, "unregistered", 200, "OK", "");
    } else {
        a->want_reg = 1;
        reg_cancel_locked(a);
        reg_begin_locked(a, 0);
    }
    UK();
}

/* ------------------------------------------------------------------ */
/* causes                                                              */
/* ------------------------------------------------------------------ */
static void map_cause(int causecode, int has, int confirmed, int is_reject, int* code, const char** reason)
{
    if (!has || causecode == 0 || causecode == 16 || causecode == 31) {
        if (is_reject) { *code = 603; *reason = "Decline"; }
        else if (confirmed) { *code = 200; *reason = "Normal call clearing"; }
        else { *code = 487; *reason = "Request Terminated"; }
        return;
    }
    switch (causecode) {
    case 17: *code = 486; *reason = "Busy Here"; break;
    case 21: *code = 603; *reason = "Decline"; break;
    case 19: case 20: *code = 480; *reason = "Temporarily Unavailable"; break;
    case 18: *code = 408; *reason = "Request Timeout"; break;
    case 1: case 3: *code = 404; *reason = "Not Found"; break;
    case 28: *code = 484; *reason = "Address Incomplete"; break;
    case 22: *code = 410; *reason = "Gone"; break;
    case 58: case 65: case 79: *code = 488; *reason = "Not Acceptable Here"; break;
    case 127: *code = 500; *reason = "Server Internal Error"; break;
    default:
        if (confirmed && causecode < 32) { *code = 200; *reason = "Normal call clearing"; }
        else { *code = 503; *reason = "Service Unavailable"; }
        break;
    }
}

static int status_to_cause(int sip, const char** text)
{
    switch (sip) {
    case 486: case 600: *text = "User busy"; return 17;
    case 480: case 408: *text = "No answer"; return 19;
    case 404: *text = "Unallocated number"; return 1;
    case 503: case 500: *text = "Congestion"; return 34;
    case 488: case 606: *text = "Incompatible destination"; return 88;
    case 603: case 403: case 401: default: *text = "Call rejected"; return 21;
    }
}

/* ------------------------------------------------------------------ */
/* call lifecycle (g_mtx held unless noted)                            */
/* ------------------------------------------------------------------ */
static void request_term(iax_sess* s, int code, const char* reason)
{
    if (s->term_req || s->finished || s->zombie) return;
    s->term_req = 1;
    s->term_code = code;
    spc_strlcpy(s->term_text, reason, sizeof(s->term_text));
    s->t_term = NOW();
}

static void send_hangup_frame(iax_sess* s, int causecode, const char* text, int reject)
{
    uint8_t ie[200];
    size_t o = iax_put_str(ie, 0, sizeof(ie), IAXIE_CAUSE, text);
    if (o) o = iax_put_u8(ie, o, sizeof(ie), IAXIE_CAUSECODE, (uint8_t)causecode);
    if (o) send_rel(s, IAXF_IAX, reject ? IAXC_REJECT : IAXC_HANGUP, ie, o, 1, 0);
}

/* Builds NEW/ACCEPT style session for an outgoing call or an incoming one. Returns the session or NULL. */
static iax_sess* call_session_create(iax_acct* a, const pj_sockaddr_in* peer, int role)
{
    iax_sess* s = sess_new(SK_CALL, a->acc, peer);
    spc_call* c;
    int idx, used;
    iax_sess* o;
    if (!s) return NULL;
    s->role = role;
    for (idx = 0; idx < 512; idx++) {
        used = 0;
        for (o = g_sessions; o; o = o->next) if (o != s && o->slot == SPC_ID_IAX_BASE + idx && o->cid) used = 1;
        if (!used) break;
    }
    s->slot = SPC_ID_IAX_BASE + idx;
    c = spc_call_iax_new(s->slot, a->acc, a->uid, role);
    if (!c) { s->zombie = 1; s->kill_at = 0; return NULL; }
    s->cid = c->cid;
    spc_strlcpy(s->host, a->host, sizeof(s->host));
    spc_strlcpy(s->local_user, a->user, sizeof(s->local_user));
    spc_strlcpy(c->dtmf_method, "iax2", sizeof(c->dtmf_method));
    s->state = role ? CS_INCOMING : CS_CALLING;
    s->scode = role ? 0 : 100;
    spc_strlcpy(s->sreason, role ? "" : "Trying", sizeof(s->sreason));
    s->t_ping = NOW() + 5000;
    return s;
}

static void call_incoming_emit(iax_sess* s, const iax_ies* ies)
{
    spc_call* c;
    cJSON *o, *hdr;
    spc_registry_lock();
    c = spc_call_find_locked(s->cid);
    if (c) {
        c->incoming_emitted = 1;
        o = call_info_locked(s, c);
        hdr = cJSON_CreateObject();
        if (ies->called_number[0]) cJSON_AddStringToObject(hdr, "X-IAX-Called-Number", ies->called_number);
        if (ies->called_context[0]) cJSON_AddStringToObject(hdr, "X-IAX-Context", ies->called_context);
        if (ies->username[0]) cJSON_AddStringToObject(hdr, "X-IAX-Username", ies->username);
        cJSON_AddItemToObject(o, "headers", hdr);
        spc_emit("call.incoming", o);
    }
    spc_registry_unlock();
}

/* ------------------------------------------------------------------ */
/* media: port, codecs (IAX thread, g_mtx NOT held except in callbacks) */
/* ------------------------------------------------------------------ */
static pj_status_t codec_open(pjmedia_codec** out, pj_pool_t* pool)
{
    pjmedia_codec_mgr* mgr = pjmedia_endpt_get_codec_mgr(pjsua_get_pjmedia_endpt());
    pj_str_t id = pj_str((char*)"gsm/8000/1");
    unsigned cnt = 1;
    const pjmedia_codec_info* ci[1];
    pjmedia_codec_param prm;
    pjmedia_codec* codec = NULL;
    pj_status_t st;
    *out = NULL;
    if (!mgr) return PJ_ENOTFOUND;
    st = pjmedia_codec_mgr_find_codecs_by_id(mgr, &id, &cnt, ci, NULL);
    if (st != PJ_SUCCESS || cnt == 0) return PJ_ENOTFOUND;
    st = pjmedia_codec_mgr_get_default_param(mgr, ci[0], &prm);
    if (st != PJ_SUCCESS) return st;
    prm.setting.vad = 0;
    prm.setting.frm_per_pkt = 1;
    st = pjmedia_codec_mgr_alloc_codec(mgr, ci[0], &codec);
    if (st != PJ_SUCCESS) return st;
    st = codec->op->init(codec, pool);
    if (st == PJ_SUCCESS) st = codec->op->open(codec, &prm);
    if (st != PJ_SUCCESS) { pjmedia_codec_mgr_dealloc_codec(mgr, codec); return st; }
    *out = codec;
    return PJ_SUCCESS;
}

static void codec_close(pjmedia_codec* c)
{
    pjmedia_codec_mgr* mgr;
    if (!c) return;
    mgr = pjmedia_endpt_get_codec_mgr(pjsua_get_pjmedia_endpt());
    c->op->close(c);
    if (mgr) pjmedia_codec_mgr_dealloc_codec(mgr, c);
}

/* decode a payload chunk to PCM16 (up to 320 bytes). returns samples or 0 */
static unsigned decode_chunk(iax_sess* s, uint32_t fmt, const uint8_t* d, size_t n, int16_t* pcm)
{
    if (fmt == IAXFMT_ULAW) { if (n > IAX_FRAME_SAMPLES) n = IAX_FRAME_SAMPLES; pjmedia_ulaw_decode(pcm, d, n); return (unsigned)n; }
    if (fmt == IAXFMT_ALAW) { if (n > IAX_FRAME_SAMPLES) n = IAX_FRAME_SAMPLES; pjmedia_alaw_decode(pcm, d, n); return (unsigned)n; }
    if (fmt == IAXFMT_GSM && s->codec.dec && n >= 33) {
        pjmedia_frame in, out;
        pj_bzero(&in, sizeof(in)); pj_bzero(&out, sizeof(out));
        in.type = PJMEDIA_FRAME_TYPE_AUDIO; in.buf = (void*)d; in.size = 33;
        out.buf = pcm; out.size = IAX_FRAME_BYTES;
        if (s->codec.dec->op->decode(s->codec.dec, &in, IAX_FRAME_BYTES, &out) == PJ_SUCCESS && out.size >= IAX_FRAME_BYTES)
            return IAX_FRAME_SAMPLES;
    }
    return 0;
}

static size_t chunk_bytes(uint32_t fmt)
{
    return fmt == IAXFMT_GSM ? 33 : IAX_FRAME_SAMPLES;
}

static pj_status_t port_get_frame(pjmedia_port* p, pjmedia_frame* f)
{
    iax_sess* s = (iax_sess*)p->port_data.pdata;
    char ft = 0;
    if (!s || !s->jb) { f->type = PJMEDIA_FRAME_TYPE_NONE; f->size = 0; return PJ_SUCCESS; }
    spc_mutex_lock(&s->jbm);
    pjmedia_jbuf_get_frame(s->jb, f->buf, &ft);
    spc_mutex_unlock(&s->jbm);
    if (ft == PJMEDIA_JB_NORMAL_FRAME) {
        f->type = PJMEDIA_FRAME_TYPE_AUDIO;
        f->size = IAX_FRAME_BYTES;
    } else {
        f->type = PJMEDIA_FRAME_TYPE_NONE;
        f->size = 0;
    }
    return PJ_SUCCESS;
}

static void send_voice_locked(iax_sess* s, const uint8_t* data, size_t n)
{
    uint8_t buf[IAX_MAX_PKT];
    int64_t el = (int64_t)sess_ts(s);
    uint32_t ts;
    if (!s->vts_init || (el - (int64_t)s->vts_next) > 80 || ((int64_t)s->vts_next - el) > 80) { s->vts_next = (uint32_t)el; s->vts_init = 1; }
    ts = s->vts_next;
    s->vts_next += 20;
    if (!s->tx_full_sent || (ts >> 16) != (s->tx_last_full_ts >> 16)) {
        if (send_rel(s, IAXF_VOICE, iax_fmt_to_sub(s->tx_fmt), data, n, 0, ts) == 0) {
            s->tx_full_sent = 1;
            s->tx_last_full_ts = ts;
        } else return;
    } else {
        buf[0] = (uint8_t)((s->lcall >> 8) & 0x7f);
        buf[1] = (uint8_t)s->lcall;
        buf[2] = (uint8_t)(ts >> 8);
        buf[3] = (uint8_t)ts;
        if (n > sizeof(buf) - 4) return;
        memcpy(buf + 4, data, n);
        raw_send(buf, 4 + n, &s->peer);
    }
    s->tx_pkts++;
    s->tx_bytes += n;
}

static pj_status_t port_put_frame(pjmedia_port* p, pjmedia_frame* f)
{
    iax_sess* s = (iax_sess*)p->port_data.pdata;
    uint8_t enc[IAX_FRAME_SAMPLES + 8];
    size_t n = 0;
    uint32_t fmt;
    if (!s || f->type != PJMEDIA_FRAME_TYPE_AUDIO || f->size < IAX_FRAME_BYTES || s->media_state != 1) return PJ_SUCCESS;
    fmt = s->tx_fmt;
    if (fmt == IAXFMT_ULAW) { pjmedia_ulaw_encode(enc, (const pj_int16_t*)f->buf, IAX_FRAME_SAMPLES); n = IAX_FRAME_SAMPLES; }
    else if (fmt == IAXFMT_ALAW) { pjmedia_alaw_encode(enc, (const pj_int16_t*)f->buf, IAX_FRAME_SAMPLES); n = IAX_FRAME_SAMPLES; }
    else if (fmt == IAXFMT_GSM && s->codec.enc) {
        pjmedia_frame in, out;
        pj_bzero(&in, sizeof(in)); pj_bzero(&out, sizeof(out));
        in.type = PJMEDIA_FRAME_TYPE_AUDIO; in.buf = f->buf; in.size = IAX_FRAME_BYTES;
        out.buf = enc; out.size = sizeof(enc);
        if (s->codec.enc->op->encode(s->codec.enc, &in, sizeof(enc), &out) != PJ_SUCCESS || out.size != 33) return PJ_SUCCESS;
        n = 33;
    }
    if (!n) return PJ_SUCCESS;
    LK();
    if (s->media_state == 1 && !s->finished && !s->term_req && !s->zombie && !s->held && !s->rhold && !s->quelch &&
        s->state >= CS_EARLY)
        send_voice_locked(s, enc, n);
    UK();
    return PJ_SUCCESS;
}

static pj_status_t port_on_destroy(pjmedia_port* p) { (void)p; return PJ_SUCCESS; }

/* IAX thread, g_mtx not held */
static void media_start(iax_sess* s)
{
    pj_pool_t* pool;
    pjmedia_port* port;
    pjmedia_jbuf* jb = NULL;
    pj_str_t nm;
    int slot = -1;
    pj_status_t st;
    iax_codec cod;
    int need_gsm;
    pj_bzero(&cod, sizeof(cod));
    LK();
    need_gsm = (s->tx_fmt == IAXFMT_GSM) || (s->cap_ours & IAXFMT_GSM);
    UK();
    pool = pjsua_pool_create("iaxmed", 2048, 2048);
    if (!pool) goto fail;
    port = (pjmedia_port*)pj_pool_zalloc(pool, sizeof(*port));
    nm = pj_str((char*)"iax2");
    if (pjmedia_port_info_init(&port->info, &nm, IAX_PORT_SIG, 8000, 1, 16, IAX_FRAME_SAMPLES) != PJ_SUCCESS) goto fail_pool;
    port->get_frame = &port_get_frame;
    port->put_frame = &port_put_frame;
    port->on_destroy = &port_on_destroy;
    port->port_data.pdata = s;
    if (pjmedia_jbuf_create(pool, &nm, IAX_FRAME_BYTES, 20, 50, &jb) != PJ_SUCCESS) goto fail_pool;
    pjmedia_jbuf_set_adaptive(jb, 2, 1, 15);
    if (need_gsm && gsm_available()) {
        codec_open(&cod.enc, pool);
        codec_open(&cod.dec, pool);
    }
    LK();
    if (!s->jbm_init) { spc_mutex_init(&s->jbm); s->jbm_init = 1; }
    s->pool = pool;
    s->port = port;
    s->jb = jb;
    s->codec = cod;
    UK();
    st = pjsua_conf_add_port(pool, port, &slot);
    if (st != PJ_SUCCESS) {
        LK(); s->pool = NULL; s->port = NULL; s->jb = NULL; s->media_state = 0; s->want_media = 0; UK();
        codec_close(cod.enc); codec_close(cod.dec);
        pj_pool_release(pool);
        return;
    }
    LK();
    s->conf_slot = slot;
    s->media_state = 1;
    s->state = s->state;     /* unchanged */
    if (!s->finished) emit_media(s);
    UK();
    spc_media_on_call_media(s->slot, 1);
    spc_call_apply_topology();
    return;
fail_pool:
    pj_pool_release(pool);
fail:
    LK(); s->media_state = 0; s->want_media = 0; UK();
}

/* IAX thread, g_mtx not held: remove the port from the bridge and release media resources */
static void media_stop(iax_sess* s)
{
    int slot;
    pj_pool_t* pool;
    pjmedia_port* port;
    iax_codec cod;
    LK();
    if (s->media_state != 1) { UK(); return; }
    s->media_state = 2;
    slot = s->conf_slot;
    s->conf_slot = -1;
    UK();
    if (slot >= 0) pjsua_conf_remove_port(slot);     /* blocks until the clock thread is out of our callbacks */
    LK();
    pool = s->pool; port = s->port; cod = s->codec;
    s->pool = NULL; s->port = NULL; s->jb = NULL;
    pj_bzero(&s->codec, sizeof(s->codec));
    UK();
    codec_close(cod.enc);
    codec_close(cod.dec);
    /* the bridge drops ports asynchronously and may still call get_frame: the port (and jitter buffer) live in the pool,
     * which is released only when the bridge's last reference is gone */
    if (port) port->port_data.pdata = NULL;
    spc_port_destroy_release(port, pool);
}

/* terminal sequence for a call (IAX thread, g_mtx not held) */
static void finish_call(iax_sess* s)
{
    uint64_t cid;
    spc_call* c;
    cJSON* o;
    LK();
    if (s->finished || !s->cid) { UK(); return; }
    s->finished = 1;
    cid = s->cid;
    UK();
    media_stop(s);
    c = spc_call_lock_find(cid);
    if (c) { spc_registry_unlock(); spc_call_cleanup_media(c); }
    LK();
    s->state = CS_DISC;
    s->scode = s->term_code ? s->term_code : 487;
    spc_strlcpy(s->sreason, s->term_text[0] ? s->term_text : "Request Terminated", sizeof(s->sreason));
    if (!s->t_term) s->t_term = NOW();
    spc_registry_lock();
    c = spc_call_find_locked(cid);
    o = c ? call_info_locked(s, c) : NULL;
    spc_registry_unlock();
    if (c) spc_call_iax_finish(c, o);
    s->cid = 0;
    s->zombie = 1;
    s->kill_at = NOW() + 3000;
    if (!s->q) s->kill_at = NOW() + 1500;       /* linger to re-ack retransmissions */
    UK();
}

/* ------------------------------------------------------------------ */
/* receive path                                                        */
/* ------------------------------------------------------------------ */
static void rx_voice(iax_sess* s, uint32_t fmt, uint32_t ts, const uint8_t* d, size_t n, int64_t now)
{
    size_t cb, off = 0;
    if (s->media_state != 1 || s->finished || !s->jb) return;
    if (fmt != IAXFMT_ULAW && fmt != IAXFMT_ALAW && fmt != IAXFMT_GSM) return;
    if (fmt == IAXFMT_GSM && !s->codec.dec) return;
    s->rx_fmt = fmt;
    cb = chunk_bytes(fmt);
    s->rx_pkts++;
    s->rx_bytes += n;
    /* RFC 3550 style interarrival jitter on (arrival - timestamp) */
    if (s->jit_init) {
        double d_ = (double)(now - s->jit_prev_arr) - (double)(int32_t)(ts - s->jit_prev_ts);
        if (d_ < 0) d_ = -d_;
        s->jitter_ms += (d_ - s->jitter_ms) / 16.0;
        if (s->jitter_ms > s->jitter_max_ms) s->jitter_max_ms = s->jitter_ms;
    }
    s->jit_init = 1; s->jit_prev_arr = now; s->jit_prev_ts = ts;
    while (off < n) {
        int16_t pcm[IAX_FRAME_SAMPLES];
        size_t take = n - off < cb ? n - off : cb;
        unsigned samples;
        uint8_t tmp[IAX_FRAME_SAMPLES];
        int seq;
        uint32_t cts = ts + (uint32_t)(20 * (off / cb));
        if (take < cb) {
            if (fmt == IAXFMT_GSM || take < cb / 2) break;
            memset(tmp, fmt == IAXFMT_ULAW ? 0xff : 0xd5, sizeof(tmp));
            memcpy(tmp, d + off, take);
            samples = decode_chunk(s, fmt, tmp, cb, pcm);
        } else samples = decode_chunk(s, fmt, d + off, take, pcm);
        off += take;
        if (samples != IAX_FRAME_SAMPLES) {
            if (samples == 0) continue;
            memset(pcm + samples, 0, (IAX_FRAME_SAMPLES - samples) * 2);
        }
        if (!s->rx_seq_init) {
            s->rx_seq_init = 1; s->rx_ref_ts = cts; s->rx_ref_seq = 1000; s->rx_seq_last = 999;
        }
        {
            int32_t dlt = (int32_t)(cts - s->rx_ref_ts);
            int frames = (dlt + (dlt >= 0 ? 10 : -10)) / 20;
            seq = s->rx_ref_seq + frames;
            if (seq < s->rx_seq_last - 100 || seq > s->rx_seq_last + 150) {
                s->rx_ref_ts = cts;
                s->rx_ref_seq = s->rx_seq_last + 1;
                seq = s->rx_ref_seq;
                spc_mutex_lock(&s->jbm);
                pjmedia_jbuf_reset(s->jb);
                spc_mutex_unlock(&s->jbm);
            }
        }
        if (seq == s->rx_seq_last) s->rx_dup++;
        else if (seq < s->rx_seq_last) s->rx_reorder++;
        else s->rx_seq_last = seq;
        spc_mutex_lock(&s->jbm);
        pjmedia_jbuf_put_frame(s->jb, pcm, IAX_FRAME_BYTES, seq);
        spc_mutex_unlock(&s->jbm);
    }
}

static uint32_t extend_ts16(iax_sess* s, uint16_t ts16)
{
    uint32_t base = s->have_hi_ts ? s->rx_hi_ts : 0;
    uint32_t cand = (base & 0xffff0000u) | ts16;
    if ((int32_t)(cand - base) > 0x8000) cand -= 0x10000;
    else if ((int32_t)(base - cand) > 0x8000) cand += 0x10000;
    return cand;
}

static void rx_mini(const uint8_t* b, size_t len, const pj_sockaddr_in* from, iax_hdr* h)
{
    iax_sess* s;
    (void)b; (void)len;
    for (s = g_sessions; s; s = s->next) {
        if (s->kind == SK_CALL && !s->zombie && s->rcall == h->scall && addr_eq(&s->peer, from)) break;
    }
    if (!s || s->media_state != 1 || s->rx_fmt == 0) return;
    s->last_rx_ms = NOW();
    rx_voice(s, s->rx_fmt, extend_ts16(s, (uint16_t)h->ts), h->payload, h->plen, NOW());
}

static void do_ack_queue(iax_sess* s, uint8_t iseq)
{
    iax_pkt **pp = &s->q;
    while (*pp) {
        iax_pkt* p = *pp;
        if ((int8_t)(uint8_t)(p->oseq - iseq) < 0) { *pp = p->next; free(p->ies); free(p); }
        else pp = &p->next;
    }
}

static void retransmit_all(iax_sess* s)
{
    iax_pkt* p;
    for (p = s->q; p; p = p->next) tx_full(s, p->type, p->sub, p->ts, p->ies, p->ielen, p->oseq, 1);
}

static void send_auth_reply(iax_sess* s, const iax_ies* ies, int is_reg)
{
    uint8_t ie[300];
    size_t o = 0;
    char md5[33];
    if (s->auth_tries >= 2) return;
    s->auth_tries++;
    if (!(ies->has & IAXH_AUTHM)) { return; }
    if ((ies->authmethods & IAX_AUTH_MD5) && (ies->has & IAXH_CHALLENGE)) {
        iax_md5_hex(ies->challenge, s->pass, md5);
        o = iax_put_str(ie, 0, sizeof(ie), IAXIE_USERNAME, s->user);
        if (o) o = iax_put_str(ie, o, sizeof(ie), IAXIE_MD5_RESULT, md5);
    } else if (ies->authmethods & IAX_AUTH_PLAINTEXT) {
        o = iax_put_str(ie, 0, sizeof(ie), IAXIE_USERNAME, s->user);
        if (o) o = iax_put_str(ie, o, sizeof(ie), IAXIE_PASSWORD, s->pass);
    } else return;
    if (!o) return;
    if (is_reg) {
        if (o) o = iax_put_u16(ie, o, sizeof(ie), IAXIE_REFRESH, (uint16_t)s->reg_req_refresh);
        if (o) send_rel(s, IAXF_IAX, s->unreg ? IAXC_REGREL : IAXC_REGREQ, ie, o, 0, 0);
    } else {
        if (o) send_rel(s, IAXF_IAX, IAXC_AUTHREP, ie, o, 0, 0);
    }
}

/* CALLTOKEN challenge: rebuild the head packet (still unacked) with the token IE appended */
static void handle_calltoken(iax_sess* s, const iax_ies* ies)
{
    iax_pkt* p = s->q;
    uint8_t* n;
    size_t nl;
    if (!p || p->oseq != 0 || s->calltoken_sent || !(ies->has & IAXH_CALLTOKEN)) return;
    nl = p->ielen + 2 + ies->calltoken_len;
    if (nl > IAX_MAX_PKT - IAX_FULL_HDR || ies->calltoken_len > 253) return;
    n = (uint8_t*)malloc(nl);
    if (!n) return;
    memcpy(n, p->ies, p->ielen);
    nl = iax_put_raw(n, p->ielen, nl, IAXIE_CALLTOKEN, ies->calltoken, ies->calltoken_len);
    if (!nl) { free(n); return; }
    free(p->ies);
    p->ies = n;
    p->ielen = nl;
    p->tries = 0;
    p->due = NOW() + (int64_t)rto_ms(0);
    s->calltoken_sent = 1;
    tx_full(s, p->type, p->sub, p->ts, p->ies, p->ielen, p->oseq, 0);
}

static void reg_session_done(iax_sess* s)
{
    s->zombie = 1;
    s->kill_at = NOW() + 1500;
    pkts_free(s);
}

static void handle_reg_frame(iax_sess* s, const iax_hdr* h, const iax_ies* ies)
{
    iax_acct* a = acct_find(s->acc);
    if (h->type != IAXF_IAX) return;
    if (!a || a->reg_call != s->lcall) { reg_session_done(s); return; }
    switch (h->sub) {
    case IAXC_REGAUTH:
        send_auth_reply(s, ies, 1);
        break;
    case IAXC_REGACK:
        a->reg_call = 0;
        reg_session_done(s);
        if (s->unreg) {
            a->granted = 0; a->next_reg_ms = 0;
            acct_set_state(a, "unregistered", 200, "OK", "");
        } else {
            reg_succeeded(a, (ies->has & IAXH_REFRESH) ? ies->refresh : s->reg_req_refresh);
        }
        break;
    case IAXC_REGREJ: {
        const char* why = ies->cause[0] ? ies->cause : "Registration Rejected";
        char err[200];
        a->reg_call = 0;
        reg_session_done(s);
        if (s->unreg) { acct_set_state(a, "unregistered", 200, "OK", ""); break; }
        if (strstr(why, "efused") || strstr(why, "uth") || strstr(why, "assword") || strstr(why, "ejected") || !ies->cause[0])
            snprintf(err, sizeof(err), "Wrong username/password (403)");
        else snprintf(err, sizeof(err), "%.150s (403)", why);
        reg_failed(a, 403, why, err);
        break;
    }
    case IAXC_REJECT:
    case IAXC_HANGUP:
        a->reg_call = 0;
        reg_session_done(s);
        if (!s->unreg) reg_failed(a, 403, "Rejected", "Registration rejected (403)");
        else acct_set_state(a, "unregistered", 200, "OK", "");
        break;
    default: break;
    }
}

static void handle_call_term(iax_sess* s, const iax_hdr* h, const iax_ies* ies, int is_reject)
{
    int code; const char* reason;
    map_cause(ies->causecode, (ies->has & IAXH_CAUSECODE) != 0, s->state == CS_CONFIRMED, is_reject, &code, &reason);
    (void)h;
    request_term(s, code, reason);
}

static void call_confirm(iax_sess* s)
{
    if (s->state == CS_CONFIRMED) return;
    s->t_answer = NOW();
    s->state = CS_CONFIRMED;
    s->scode = 200;
    spc_strlcpy(s->sreason, "OK", sizeof(s->sreason));
    s->want_media = s->media_state == 0;
    emit_state(s);
}

static void handle_call_iax(iax_sess* s, const iax_hdr* h, const iax_ies* ies)
{
    switch (h->sub) {
    case IAXC_ACCEPT:
        if (s->role == 0 && !s->accepted) {
            uint32_t ours[3];
            int n = 0, i, ok = 0;
            iax_acct* a = acct_find(s->acc);
            n = acct_formats(a, ours);
            if (ies->has & IAXH_FORMAT) {
                for (i = 0; i < n; i++) if ((ies->format & ours[i]) == ours[i] && ours[i] == (uint32_t)ies->format) { s->tx_fmt = ours[i]; ok = 1; }
                if (!ok) for (i = 0; i < n; i++) if (ies->format & ours[i]) { s->tx_fmt = ours[i]; ok = 1; break; }
            } else { s->tx_fmt = ours[0]; ok = 1; }
            s->accepted = 1;
            if (!ok) {
                send_hangup_frame(s, 58, "Bearer capability not available", 0);
                request_term(s, 488, "Not Acceptable Here");
            } else {
                s->rx_fmt = s->tx_fmt;
            }
        }
        break;
    case IAXC_AUTHREQ:
        if (s->role == 0) {
            iax_acct* a = acct_find(s->acc);
            if (a) { spc_strlcpy(s->user, a->user, sizeof(s->user)); spc_strlcpy(s->pass, a->pass, sizeof(s->pass)); }
            send_auth_reply(s, ies, 0);
        }
        break;
    case IAXC_HANGUP: handle_call_term(s, h, ies, 0); break;
    case IAXC_REJECT: handle_call_term(s, h, ies, 1); break;
    case IAXC_PING:
        send_rel(s, IAXF_IAX, IAXC_PONG, NULL, 0, 0, h->ts);
        break;
    case IAXC_LAGRQ:
        send_rel(s, IAXF_IAX, IAXC_LAGRP, NULL, 0, 0, h->ts);
        break;
    case IAXC_PONG:
    case IAXC_LAGRP: {
        double rtt = (double)((int64_t)sess_ts(s) - (int64_t)h->ts);
        if (rtt >= 0 && rtt < 20000) {
            s->rtt_last = rtt;
            if (rtt < s->rtt_min) s->rtt_min = rtt;
            if (rtt > s->rtt_max) s->rtt_max = rtt;
            s->rtt_sum += rtt; s->rtt_n++;
        }
        break;
    }
    case IAXC_QUELCH: s->quelch = 1; break;
    case IAXC_UNQUELCH: s->quelch = 0; break;
    case IAXC_TXREQ: {
        uint8_t ie[16];
        size_t o = 0;
        if (ies->has & IAXH_TRANSFER) o = iax_put_u32(ie, 0, sizeof(ie), IAXIE_TRANSFERID, ies->transferid);
        send_rel(s, IAXF_IAX, IAXC_TXREJ, ie, o, 0, 0);       /* media always stays through the PBX */
        break;
    }
    case IAXC_INVAL:
        request_term(s, 481, "Call/Transaction Does Not Exist");
        break;
    default: break;
    }
}

static void handle_call_control(iax_sess* s, const iax_hdr* h)
{
    switch (h->sub) {
    case IAXCTL_RINGING:
        if (s->role == 0 && (s->state == CS_CALLING || s->state == CS_EARLY)) set_state(s, CS_EARLY, 180, "Ringing");
        break;
    case IAXCTL_PROGRESS:
        if (s->role == 0 && s->state < CS_CONFIRMED) {
            set_state(s, CS_EARLY, 183, "Session Progress");
            s->want_media = s->media_state == 0;
        }
        break;
    case IAXCTL_PROCEEDING:
        if (s->role == 0 && s->state == CS_CALLING) set_state(s, CS_CALLING, 100, "Proceeding");
        break;
    case IAXCTL_ANSWER:
        if (s->role == 0 && s->state < CS_CONFIRMED) call_confirm(s);
        break;
    case IAXCTL_BUSY:
        if (s->role == 0) { send_hangup_frame(s, 17, "User busy", 0); request_term(s, 486, "Busy Here"); }
        break;
    case IAXCTL_CONGESTION:
        if (s->role == 0) { send_hangup_frame(s, 34, "Congestion", 0); request_term(s, 503, "Service Unavailable"); }
        break;
    case IAXCTL_HANGUP:
        request_term(s, s->state == CS_CONFIRMED ? 200 : 487, s->state == CS_CONFIRMED ? "Normal call clearing" : "Request Terminated");
        break;
    case IAXCTL_HOLD:
        if (!s->rhold) { s->rhold = 1; emit_media(s); }
        break;
    case IAXCTL_UNHOLD:
        if (s->rhold) { s->rhold = 0; emit_media(s); }
        break;
    default: break;
    }
}

static void emit_dtmf(iax_sess* s, int digit, int dur)
{
    cJSON* f;
    char d[2];
    if (!s->cid || s->finished) return;
    d[0] = (char)digit; d[1] = 0;
    f = cJSON_CreateObject();
    cJSON_AddNumberToObject(f, "cid", (double)s->cid);
    cJSON_AddStringToObject(f, "digit", d);
    cJSON_AddStringToObject(f, "method", "iax2");
    cJSON_AddNumberToObject(f, "durationMs", dur);
    spc_call_emit(s->cid, "call.dtmf", f);
}

static void handle_frame(iax_sess* s, const iax_hdr* h, const uint8_t* raw_unused)
{
    iax_ies ies;
    (void)raw_unused;
    if (s->kind == SK_REG) {
        if (h->type == IAXF_IAX) {
            if (h->sub == IAXC_PING) { send_rel(s, IAXF_IAX, IAXC_PONG, NULL, 0, 0, h->ts); return; }
            iax_parse_ies(h->payload, h->plen, &ies);
            handle_reg_frame(s, h, &ies);
        }
        return;
    }
    if (s->zombie || s->finished || s->term_req) return;
    switch (h->type) {
    case IAXF_IAX:
        iax_parse_ies(h->payload, h->plen, &ies);
        handle_call_iax(s, h, &ies);
        break;
    case IAXF_CONTROL:
        handle_call_control(s, h);
        break;
    case IAXF_VOICE:
        if (h->sub == IAXFMT_ULAW || h->sub == IAXFMT_ALAW || h->sub == IAXFMT_GSM) {
            s->rx_fmt = h->sub;
            if (!s->have_hi_ts || (int32_t)(h->ts - s->rx_hi_ts) > 0) { s->rx_hi_ts = h->ts; s->have_hi_ts = 1; }
            rx_voice(s, h->sub, h->ts, h->payload, h->plen, NOW());
        }
        break;
    case IAXF_DTMF_BEGIN:
        if (h->sub > 0 && h->sub < 128) s->dtmf_rx_begin_ms = NOW();
        break;
    case IAXF_DTMF_END:
        if (h->sub > 0 && h->sub < 128) {
            int dur = s->dtmf_rx_begin_ms ? (int)(NOW() - s->dtmf_rx_begin_ms) : 0;
            s->dtmf_rx_begin_ms = 0;
            emit_dtmf(s, (int)h->sub, dur);
        }
        break;
    default: break;
    }
}

static iax_acct* pick_acct_for_incoming(const pj_sockaddr_in* from, const iax_ies* ies)
{
    iax_acct *a, *first = NULL, *best = NULL;
    int ncand = 0;
    for (a = g_accts; a; a = a->next) {
        if (!a->addr_ok || !ip_eq(&a->addr, from)) continue;
        ncand++;
        if (!first) first = a;
        if (ies->username[0] && strcmp(ies->username, a->user) == 0) best = a;
        else if (!best && ies->called_number[0] && strcmp(ies->called_number, a->user) == 0) best = a;
        else if (!best && ies->dnid[0] && strcmp(ies->dnid, a->user) == 0) best = a;
    }
    if (best) return best;
    if (ncand >= 1) {
        /* several accounts on one PBX and no hint: prefer a registered one */
        for (a = g_accts; a; a = a->next)
            if (a->addr_ok && ip_eq(&a->addr, from) && strcmp(a->reg_state, "registered") == 0) return a;
        return first;
    }
    return NULL;
}

static void handle_new(const pj_sockaddr_in* from, const iax_hdr* h)
{
    iax_ies ies;
    iax_acct* a;
    iax_sess* s;
    uint32_t ours[3];
    int n, i;
    uint32_t pick = 0;
    uint64_t theirs;
    uint8_t ie[64];
    size_t o;
    if (!g_up) return;
    iax_parse_ies(h->payload, h->plen, &ies);
    a = pick_acct_for_incoming(from, &ies);
    if (!a) {
        const char* t = "No such peer";
        uint8_t r[80];
        size_t ro = iax_put_str(r, 0, sizeof(r), IAXIE_CAUSE, t);
        if (ro) ro = iax_put_u8(r, ro, sizeof(r), IAXIE_CAUSECODE, 1);
        send_apathetic(from, 0, h->scall, (uint8_t)(h->oseq + 1), IAXC_REJECT, h->ts, r, ro);
        return;
    }
    {   /* one call per incoming NEW; limit concurrent calls */
        int calls = 0;
        iax_sess* x;
        for (x = g_sessions; x; x = x->next) if (x->kind == SK_CALL && x->cid) calls++;
        if (G.max_calls > 0 && calls >= G.max_calls) {
            uint8_t r[64];
            size_t ro = iax_put_str(r, 0, sizeof(r), IAXIE_CAUSE, "Busy");
            if (ro) ro = iax_put_u8(r, ro, sizeof(r), IAXIE_CAUSECODE, 17);
            send_apathetic(from, 0, h->scall, (uint8_t)(h->oseq + 1), IAXC_REJECT, h->ts, r, ro);
            return;
        }
    }
    n = acct_formats(a, ours);
    theirs = (ies.has & IAXH_CAP) ? ies.capability : ((ies.has & IAXH_FORMAT) ? ies.format : 0);
    if (ies.has & IAXH_FORMAT) for (i = 0; i < n; i++) if (ours[i] == ies.format) pick = ours[i];
    if (!pick) for (i = 0; i < n; i++) if (theirs & ours[i]) { pick = ours[i]; break; }
    if (!pick) {
        uint8_t r[80];
        size_t ro = iax_put_str(r, 0, sizeof(r), IAXIE_CAUSE, "Unable to negotiate codec");
        if (ro) ro = iax_put_u8(r, ro, sizeof(r), IAXIE_CAUSECODE, 58);
        send_apathetic(from, 0, h->scall, (uint8_t)(h->oseq + 1), IAXC_REJECT, h->ts, r, ro);
        return;
    }
    s = call_session_create(a, from, 1);
    if (!s) {
        uint8_t r[64];
        size_t ro = iax_put_str(r, 0, sizeof(r), IAXIE_CAUSE, "Congestion");
        if (ro) ro = iax_put_u8(r, ro, sizeof(r), IAXIE_CAUSECODE, 34);
        send_apathetic(from, 0, h->scall, (uint8_t)(h->oseq + 1), IAXC_REJECT, h->ts, r, ro);
        return;
    }
    s->rcall = h->scall;
    s->iseq = (uint8_t)(h->oseq + 1);
    s->have_hi_ts = 1; s->rx_hi_ts = h->ts;
    s->cap_ours = fmts_mask(ours, n);
    s->tx_fmt = pick; s->rx_fmt = pick;
    spc_strlcpy(s->called, ies.called_number, sizeof(s->called));
    spc_strlcpy(s->remote_user, ies.calling_number[0] ? ies.calling_number : (ies.username[0] ? ies.username : ""), sizeof(s->remote_user));
    spc_strlcpy(s->remote_name, ies.calling_name, sizeof(s->remote_name));
    s->accepted = 1;
    call_incoming_emit(s, &ies);
    /* ACCEPT carries the chosen format; it also acknowledges the NEW through its iseq */
    o = iax_put_u32(ie, 0, sizeof(ie), IAXIE_FORMAT, pick);
    if (o) send_rel(s, IAXF_IAX, IAXC_ACCEPT, ie, o, 0, 0);
    if (G.incoming_auto_ring_ms > 0) s->auto_ring_at = NOW() + G.incoming_auto_ring_ms;
    if (G.incoming_unattended_ms > 0 && !spc_sink_attached()) s->unattended_at = NOW() + G.incoming_unattended_ms;
}

static int inval_ok(void)
{
    int64_t now = NOW();
    if (now - g_inval_win > 1000) { g_inval_win = now; g_inval_cnt = 0; }
    return ++g_inval_cnt <= 20;
}

static void rx_packet(const uint8_t* b, size_t len, const pj_sockaddr_in* from)
{
    iax_hdr h;
    iax_sess* s = NULL;
    if (iax_parse_hdr(b, len, &h) != 0) return;
    if (!h.full) { rx_mini(b, len, from, &h); return; }
    if (h.dcall) {
        s = sess_by_lcall(h.dcall);
        if (!s || !addr_eq(&s->peer, from)) {
            if (!(h.type == IAXF_IAX && (h.sub == IAXC_ACK || h.sub == IAXC_INVAL || h.sub == IAXC_TXCNT || h.sub == IAXC_TXACC)) && inval_ok())
                send_apathetic(from, h.dcall, h.scall, (uint8_t)(h.oseq + 1), IAXC_INVAL, h.ts, NULL, 0);
            return;
        }
        if (h.type == IAXF_IAX && h.sub == IAXC_CALLTOKEN) {
            iax_ies ies;
            iax_parse_ies(h.payload, h.plen, &ies);
            handle_calltoken(s, &ies);
            return;
        }
        if (h.scall) {
            if (!s->rcall) s->rcall = h.scall;
            else if (s->rcall != h.scall) return;
        }
    } else {
        if (h.type != IAXF_IAX) return;
        if (h.sub == IAXC_NEW) {
            iax_sess* x;
            for (x = g_sessions; x; x = x->next)
                if (x->kind == SK_CALL && x->rcall == h.scall && addr_eq(&x->peer, from) && x->role == 1) { s = x; break; }
            if (!s) { handle_new(from, &h); return; }
        } else if (h.sub == IAXC_POKE) {
            send_apathetic(from, 0, h.scall, (uint8_t)(h.oseq + 1), IAXC_PONG, h.ts, NULL, 0);
            return;
        } else return;
    }
    s->last_rx_ms = NOW();
    do_ack_queue(s, h.iseq);
    if (h.type == IAXF_IAX) {
        switch (h.sub) {
        case IAXC_ACK: return;
        case IAXC_INVAL:
            if (s->kind == SK_CALL) request_term(s, 481, "Call/Transaction Does Not Exist");
            else { iax_acct* a = acct_find(s->acc); if (a && a->reg_call == s->lcall) { a->reg_call = 0; reg_failed(a, 408, "Request Timeout", "Timeout (408)"); } reg_session_done(s); }
            return;
        case IAXC_TXCNT: case IAXC_TXACC: return;
        case IAXC_VNAK: {
            int64_t now = NOW();
            if (now - s->last_vnak_ms > 100) { s->last_vnak_ms = now; retransmit_all(s); }
            return;
        }
        default: break;
        }
    }
    if (h.oseq == s->iseq) {
        s->iseq++;
        send_ack(s, h.ts);
        if (h.ts && (!s->have_hi_ts || (int32_t)(h.ts - s->rx_hi_ts) > 0)) { s->rx_hi_ts = h.ts; s->have_hi_ts = 1; }
        handle_frame(s, &h, b);
    } else if ((int8_t)(uint8_t)(h.oseq - s->iseq) < 0) {
        send_ack(s, h.ts);                       /* duplicate: re-ack, do not process */
        s->rx_dup++;
    } else {
        int64_t now = NOW();                      /* gap: ask for a resend */
        if (now - s->last_vnak_ms > 200) {
            s->last_vnak_ms = now;
            tx_full(s, IAXF_IAX, IAXC_VNAK, 0, NULL, 0, s->oseq, 0);
        }
    }
}

/* ------------------------------------------------------------------ */
/* timers (g_mtx held)                                                 */
/* ------------------------------------------------------------------ */
static void sess_send_timeout(iax_sess* s)
{
    if (s->kind == SK_REG) {
        iax_acct* a = acct_find(s->acc);
        if (a && a->reg_call == s->lcall) {
            a->reg_call = 0;
            if (s->unreg) acct_set_state(a, "unregistered", 408, "Request Timeout", "");
            else reg_failed(a, 408, "Request Timeout", "Timeout (408)");
        }
        reg_session_done(s);
        return;
    }
    pkts_free(s);
    if (!s->zombie && !s->finished && !s->term_req) {
        send_hangup_frame(s, 18, "Timeout", 0);       /* best effort, sent once */
        request_term(s, 408, "Request Timeout");
        pkts_free(s);
    } else {
        s->zombie = 1;
        s->kill_at = NOW() + 500;
    }
}

static void dtmf_tick(iax_sess* s, int64_t now)
{
    if (s->dtmf_n == 0 && s->dtmf_state == 0) return;
    if (now < s->dtmf_next) return;
    if (s->state != CS_CONFIRMED) { s->dtmf_n = 0; s->dtmf_pos = 0; s->dtmf_state = 0; return; }
    if (s->dtmf_state == 0) {
        if (s->dtmf_pos >= s->dtmf_n) { s->dtmf_n = 0; s->dtmf_pos = 0; return; }
        send_rel(s, IAXF_DTMF_BEGIN, (uint8_t)s->dtmf_q[s->dtmf_pos], NULL, 0, 0, 0);
        s->dtmf_state = 1;
        s->dtmf_next = now + s->dtmf_dur;
    } else if (s->dtmf_state == 1) {
        send_rel(s, IAXF_DTMF_END, (uint8_t)s->dtmf_q[s->dtmf_pos], NULL, 0, 0, 0);
        s->dtmf_pos++;
        s->dtmf_state = 2;
        s->dtmf_next = now + 60;
    } else {
        s->dtmf_state = 0;
        if (s->dtmf_pos >= s->dtmf_n) { s->dtmf_n = 0; s->dtmf_pos = 0; }
    }
}

static void tick(int64_t now, iax_action* acts, int* nacts, int maxacts)
{
    iax_sess *s, *next;
    iax_acct* a;
    for (a = g_accts; a; a = a->next) {
        if (a->want_reg && !a->reg_call && !a->reg_busy && a->next_reg_ms && now >= a->next_reg_ms && *nacts < maxacts) {
            a->next_reg_ms = 0;
            acts[*nacts].type = A_REG; acts[*nacts].id = a->acc; acts[*nacts].s = NULL; (*nacts)++;
        }
    }
    for (s = g_sessions; s; s = next) {
        iax_pkt* p;
        next = s->next;
        /* retransmissions */
        for (p = s->q; p; p = p->next) {
            if (now >= p->due) {
                if (p->tries + 1 >= IAX_MAX_TRIES) {
                    if (p->final) { pkts_free(s); if (s->zombie) s->kill_at = now; }
                    else sess_send_timeout(s);
                    break;
                }
                p->tries++;
                p->due = now + (int64_t)rto_ms(p->tries);
                tx_full(s, p->type, p->sub, p->ts, p->ies, p->ielen, p->oseq, 1);
            }
        }
        if (s->kind == SK_CALL && !s->zombie && !s->finished) {
            if (s->state == CS_INCOMING) {
                if (s->auto_ring_at && now >= s->auto_ring_at) {
                    s->auto_ring_at = 0;
                    spc_call* c = spc_call_lock_find(s->cid);
                    if (c) {
                        int send = !c->responded && !c->ring_sent;
                        if (send) c->ring_sent = 1;
                        spc_registry_unlock();
                        if (send) send_rel(s, IAXF_CONTROL, IAXCTL_RINGING, NULL, 0, 0, 0);
                    }
                }
                if (s->unattended_at && now >= s->unattended_at) {
                    spc_call* c;
                    int ok;
                    s->unattended_at = 0;
                    c = spc_call_lock_find(s->cid);
                    ok = c && !c->responded;
                    if (c) spc_registry_unlock();
                    if (ok && !spc_sink_attached()) {
                        send_hangup_frame(s, 19, "No answer", 1);
                        request_term(s, 480, "Temporarily Unavailable");
                    }
                }
            }
            if (s->state == CS_CONFIRMED || s->state == CS_EARLY) {
                if (now >= s->t_ping) {
                    s->t_ping = now + 5000;
                    send_rel(s, IAXF_IAX, IAXC_PING, NULL, 0, 0, 0);
                }
            }
            if (now - s->last_rx_ms > 45000 && !s->term_req) {
                send_hangup_frame(s, 18, "Timeout", 0);
                request_term(s, 408, "Request Timeout");
            }
            dtmf_tick(s, now);
            if (s->want_media && s->media_state == 0 && !s->term_req && *nacts < maxacts) {
                s->media_state = 3;
                s->want_media = 0;
                acts[*nacts].type = A_MEDIA; acts[*nacts].id = 0; acts[*nacts].s = s; (*nacts)++;
            }
            if (s->term_req && !s->finished && *nacts < maxacts && s->media_state != 3) {
                acts[*nacts].type = A_FINISH; acts[*nacts].id = 0; acts[*nacts].s = s; (*nacts)++;
            }
        }
        /* reaping: never while the media port is (or may still be) in the bridge */
        if (s->zombie && (s->media_state != 1 && s->media_state != 3)) {
            if (now >= s->kill_at) {
                if (s->kind == SK_REG) {
                    iax_acct* ra = acct_find(s->acc);
                    if (ra && ra->reg_call == s->lcall) ra->reg_call = 0;
                }
                sess_destroy(s);
            }
        }
    }
}

static void thread_main(void* arg)
{
    uint8_t buf[IAX_MAX_PKT];
    (void)arg;
    spc_ensure_pj_thread("spc-iax2");
    while (!g_quit) {
        pj_fd_set_t rf;
        pj_time_val tv;
        iax_action acts[48];
        int nacts = 0, i, npk = 0;
        int n;
        PJ_FD_ZERO(&rf);
        PJ_FD_SET(g_sock, &rf);
        tv.sec = 0; tv.msec = 10;
        n = pj_sock_select((int)g_sock + 1, &rf, NULL, NULL, &tv);
        while (n > 0 && PJ_FD_ISSET(g_sock, &rf) && npk++ < 128) {
            pj_sockaddr_in from;
            int flen = sizeof(from);
            pj_ssize_t len = sizeof(buf);
            pj_fd_set_t r2;
            pj_time_val z;
            if (pj_sock_recvfrom(g_sock, buf, &len, 0, &from, &flen) == PJ_SUCCESS && len > 0 && from.sin_family == pj_AF_INET()) {
                LK();
                rx_packet(buf, (size_t)len, &from);
                UK();
            }
            PJ_FD_ZERO(&r2);
            PJ_FD_SET(g_sock, &r2);
            z.sec = 0; z.msec = 0;
            n = pj_sock_select((int)g_sock + 1, &r2, NULL, NULL, &z);
            rf = r2;
        }
        LK();
        tick(NOW(), acts, &nacts, 48);
        UK();
        for (i = 0; i < nacts; i++) {
            if (acts[i].type == A_REG) acct_do_reg(acts[i].id, 0);
            else if (acts[i].type == A_MEDIA) media_start(acts[i].s);
            else if (acts[i].type == A_FINISH) finish_call(acts[i].s);
        }
    }
}

/* ------------------------------------------------------------------ */
/* engine lifecycle                                                    */
/* ------------------------------------------------------------------ */
void spc_iax2_configure(const cJSON* iax)
{
    ensure_ready();
    LK();
    g_cfg_port = IAX_DEFAULT_PORT;
    g_cfg_enabled = 1;
    if (iax) {
        if (!spc_jint_range(iax, "port", IAX_DEFAULT_PORT, 0, 65535, &g_cfg_port)) g_cfg_port = IAX_DEFAULT_PORT;
        g_cfg_enabled = spc_jbool(iax, "enabled", 1);
    }
    UK();
}

static int engine_up(void)
{
    pj_sock_t s = PJ_INVALID_SOCKET;
    pj_sockaddr_in a;
    int want, tries;
    if (g_up) return 0;
    if (!g_cfg_enabled) return spc_err(SPC_E_UNSUPPORTED, 0, "IAX2 disabled in core.start");
    if (pj_sock_socket(pj_AF_INET(), pj_SOCK_DGRAM(), 0, &s) != PJ_SUCCESS) return spc_err(SPC_E_PJ_ERROR, 0, "IAX2 socket failed");
    {
        int rb = 262144, sb = 262144, tos = G.qos ? 0xB8 : 0;
        pj_sock_setsockopt(s, pj_SOL_SOCKET(), pj_SO_RCVBUF(), &rb, sizeof(rb));
        pj_sock_setsockopt(s, pj_SOL_SOCKET(), pj_SO_SNDBUF(), &sb, sizeof(sb));
        if (tos) pj_sock_setsockopt(s, pj_SOL_IP(), pj_IP_TOS(), &tos, sizeof(tos));
    }
    want = g_cfg_port;
    for (tries = 0; tries < 2; tries++) {
        pj_bzero(&a, sizeof(a));
        a.sin_family = pj_AF_INET();
        a.sin_addr.s_addr = 0;
        a.sin_port = pj_htons((pj_uint16_t)(tries == 0 ? want : 0));
        if (pj_sock_bind(s, &a, sizeof(a)) == PJ_SUCCESS) break;
        if (tries == 1) { pj_sock_close(s); return spc_err(SPC_E_PJ_ERROR, 0, "IAX2 bind failed"); }
    }
    {
        int alen = sizeof(a);
        pj_sockaddr_in bound;
        if (pj_sock_getsockname(s, &bound, &alen) == PJ_SUCCESS) g_port = (int)pj_ntohs(bound.sin_port);
        else g_port = want;
    }
    g_sock = s;
    g_quit = 0;
    if (spc_thread_create(&g_thr, thread_main, NULL) != 0) {
        pj_sock_close(s);
        g_sock = PJ_INVALID_SOCKET;
        return spc_err(SPC_E_INTERNAL, 0, "cannot start IAX2 thread");
    }
    g_up = 1;
    return SPC_OK;
}

static void acct_free(iax_acct* a)
{
    if (a->cfg) cJSON_Delete(a->cfg);
    free(a);
}

/* ------------------------------------------------------------------ */
/* account API                                                         */
/* ------------------------------------------------------------------ */
int spc_iax2_acc_valid(int acc)
{
    int r;
    if (!g_ready || acc < SPC_ID_IAX_BASE) return 0;
    LK();
    r = acct_find(acc) != NULL;
    UK();
    return r;
}

int spc_iax2_acc_find_uid(const char* uid, int* acc)
{
    iax_acct* a;
    int r = -1;
    if (!g_ready || !uid) return -1;
    LK();
    for (a = g_accts; a; a = a->next) if (strcmp(a->uid, uid) == 0) { if (acc) *acc = a->acc; r = 0; break; }
    UK();
    return r;
}

/* fills the account fields from a merged config. Returns 0 or an error code (message via spc_err) */
static int acct_fill(iax_acct* a, const cJSON* c)
{
    const char* s;
    cJSON* iax = spc_jobj(c, "iax");
    const char* host = iax ? spc_jstr(iax, "host") : NULL;
    int port = 0;
    char hbuf[128];
    cJSON* arr;
    cJSON* e;
    if (iax && !spc_jint_range(iax, "port", 0, 0, 65535, &port)) return spc_err(SPC_E_INVALID_PARAM, 0, "'iax.port' must be an integer in 0..65535");
    if (!spc_str_clean(host) || !spc_str_clean(spc_jstr(c, "domain")) || !spc_str_clean(spc_jstr(c, "username")) || !spc_str_clean(spc_jstr(c, "displayName")) || !spc_str_clean(spc_jstr(c, "callerId")))
        return spc_err(SPC_E_INVALID_PARAM, 0, "control characters are not allowed");
    if (!host || !host[0]) host = spc_jstr(c, "domain");
    if (!host || !host[0]) return spc_err(SPC_E_INVALID_PARAM, 0, "iax2 account needs 'iax.host' or 'domain'");
    spc_strlcpy(hbuf, host, sizeof(hbuf));
    {
        char* colon = strchr(hbuf, ':');
        if (colon && strchr(colon + 1, ':') == NULL) {
            *colon = 0;
            if (!port) port = atoi(colon + 1);
        }
    }
    if (!hbuf[0]) return spc_err(SPC_E_INVALID_PARAM, 0, "invalid iax2 host");
    if (port <= 0 || port > 65535) port = 4569;
    s = spc_jstr(c, "username");
    if (!s || !s[0] || strlen(s) >= sizeof(a->user)) return spc_err(SPC_E_INVALID_PARAM, 0, "'username' required (max 63 chars)");
    spc_strlcpy(a->user, s, sizeof(a->user));
    s = spc_jstr(c, "password");
    if (s && strlen(s) >= sizeof(a->pass)) return spc_err(SPC_E_INVALID_PARAM, 0, "'password' too long");
    spc_strlcpy(a->pass, s ? s : "", sizeof(a->pass));
    if (strcmp(hbuf, a->host) != 0 || port != a->port) a->addr_ok = 0;
    spc_strlcpy(a->host, hbuf, sizeof(a->host));
    a->port = port;
    if (a->addr_ok) a->addr.sin_port = pj_htons((pj_uint16_t)port);
    s = iax ? spc_jstr(iax, "context") : NULL;
    spc_strlcpy(a->context, s ? s : "", sizeof(a->context));
    s = spc_jstr(c, "displayName"); spc_strlcpy(a->display, s ? s : "", sizeof(a->display));
    s = spc_jstr(c, "callerId"); spc_strlcpy(a->caller_id, s ? s : "", sizeof(a->caller_id));
    if (!spc_jint_range(c, "regExpires", 300, 10, 86400, &a->regexpires)) return spc_err(SPC_E_INVALID_PARAM, 0, "'regExpires' must be an integer in 10..86400");
    if (a->regexpires > 3600) a->regexpires = 3600;
    if (!spc_jint_range(c, "regRetrySec", 30, 0, 86400, &a->retry_sec)) return spc_err(SPC_E_INVALID_PARAM, 0, "'regRetrySec' must be an integer in 0..86400");
    if (!spc_jint_range(c, "regFirstRetrySec", 5, 0, 86400, &a->first_retry_sec)) return spc_err(SPC_E_INVALID_PARAM, 0, "'regFirstRetrySec' must be an integer in 0..86400");
    if (a->retry_sec < 1) a->retry_sec = 30;
    if (a->first_retry_sec < 1) a->first_retry_sec = 5;
    a->ncodecs = 0;
    arr = spc_jarr(c, "codecs");
    if (arr) cJSON_ArrayForEach(e, arr)
        if (cJSON_IsString(e) && e->valuestring[0] && a->ncodecs < SPC_MAX_CODECS)
            spc_strlcpy(a->codecs[a->ncodecs++], e->valuestring, sizeof(a->codecs[0]));
    s = spc_jstr(c, "uid");
    if (s) spc_strlcpy(a->uid, s, sizeof(a->uid));
    return SPC_OK;
}

int spc_iax2_account_add(cJSON* p, cJSON** res)
{
    const char* uid = spc_jstr(p, "uid");
    iax_acct* a;
    int rc, reg, acc;
    ensure_ready();
    if (!uid || !uid[0] || strlen(uid) >= sizeof(a->uid)) return spc_err(SPC_E_INVALID_PARAM, 0, "'uid' required");
    LK();
    for (a = g_accts; a; a = a->next)
        if (strcmp(a->uid, uid) == 0) { UK(); return spc_err(SPC_E_ALREADY, 0, "uid '%s' already exists", uid); }
    UK();
    {   /* uid must also be unique among SIP accounts */
        cJSON* arr = cJSON_CreateArray();
        cJSON* e;
        int dup = 0;
        spc_acc_list_json(arr);
        cJSON_ArrayForEach(e, arr) { const char* u = spc_jstr(e, "uid"); if (u && strcmp(u, uid) == 0 && strcmp(spc_jstr(e, "proto") ? spc_jstr(e, "proto") : "", "iax2") != 0) dup = 1; }
        cJSON_Delete(arr);
        if (dup) return spc_err(SPC_E_ALREADY, 0, "uid '%s' already exists", uid);
    }
    a = (iax_acct*)calloc(1, sizeof(*a));
    if (!a) return spc_err(SPC_E_INTERNAL, 0, "out of memory");
    spc_strlcpy(a->reg_state, "none", sizeof(a->reg_state));
    spc_strlcpy(a->presence, "online", sizeof(a->presence));
    spc_strlcpy(a->dtmf_method, "iax2", sizeof(a->dtmf_method));
    rc = acct_fill(a, p);
    if (rc) { free(a); return rc; }
    a->cfg = cJSON_Duplicate(p, 1);
    rc = engine_up();
    if (rc) { acct_free(a); return rc; }
    reg = spc_jbool(p, "register", 1);
    LK();
    a->acc = ++g_acc_counter;
    a->next = g_accts;
    g_accts = a;
    acc = a->acc;
    a->want_reg = reg;
    if (!reg) emit_acc(a);
    UK();
    if (reg) acct_do_reg(acc, 0);
    *res = cJSON_CreateObject();
    cJSON_AddNumberToObject(*res, "acc", acc);
    cJSON_AddNumberToObject(*res, "localPort", g_port);
    return SPC_OK;
}

int spc_iax2_account_modify(int acc, const cJSON* p)
{
    iax_acct* a;
    cJSON* merged;
    cJSON* it;
    iax_acct tmp;
    int rc, reg;
    LK();
    a = acct_find(acc);
    if (!a) { UK(); return spc_err(SPC_E_NOT_FOUND, 0, "account %d not found", acc); }
    merged = cJSON_Duplicate(a->cfg, 1);
    cJSON_ArrayForEach(it, (cJSON*)p) {
        if (!it->string || strcmp(it->string, "acc") == 0 || strcmp(it->string, "uid") == 0 || strcmp(it->string, "proto") == 0) continue;
        if (cJSON_GetObjectItemCaseSensitive(merged, it->string))
            cJSON_ReplaceItemInObjectCaseSensitive(merged, it->string, cJSON_Duplicate(it, 1));
        else cJSON_AddItemToObject(merged, it->string, cJSON_Duplicate(it, 1));
    }
    tmp = *a;
    rc = acct_fill(&tmp, merged);
    if (rc) { cJSON_Delete(merged); UK(); return rc; }
    {
        int cred_changed = strcmp(tmp.user, a->user) || strcmp(tmp.pass, a->pass) || strcmp(tmp.host, a->host) || tmp.port != a->port;
        iax_acct* link = a->next;
        *a = tmp;
        a->next = link;
        cJSON_Delete(a->cfg);
        a->cfg = merged;
        reg = a->want_reg;
        if (cred_changed) { reg_cancel_locked(a); a->granted = 0; }
        if (!reg) emit_acc(a);
    }
    UK();
    if (reg) acct_do_reg(acc, 0);
    return SPC_OK;
}

int spc_iax2_account_remove(int acc)
{
    iax_acct* a;
    iax_sess* s;
    uint64_t cids[32];
    int n = 0, i;
    int64_t t0 = spc_mono_ms();
    LK();
    a = acct_find(acc);
    if (!a) { UK(); return spc_err(SPC_E_NOT_FOUND, 0, "account %d not found", acc); }
    a->want_reg = 0;
    for (s = g_sessions; s; s = s->next)
        if (s->kind == SK_CALL && s->acc == acc && s->cid && !s->zombie && n < 32) {
            cids[n++] = s->cid;
            if (!s->term_req) { send_hangup_frame(s, 16, "Normal Clearing", 0); request_term(s, 487, "Request Terminated"); }
        }
    UK();
    for (i = 0; i < n; i++) spc_call_wait_gone(cids[i], 1500);
    LK();
    a = acct_find(acc);
    if (a) {
        int was = strcmp(a->reg_state, "registered") == 0 && a->addr_ok && g_up;
        iax_acct** pp;
        reg_cancel_locked(a);
        if (was) {   /* fire-and-forget REGREL carrying its own credentials */
            iax_sess* r = sess_new(SK_REG, a->acc, &a->addr);
            if (r) {
                uint8_t ie[256];
                size_t o;
                r->unreg = 1;
                r->reg_req_refresh = 0;
                spc_strlcpy(r->user, a->user, sizeof(r->user));
                spc_strlcpy(r->pass, a->pass, sizeof(r->pass));
                o = iax_put_str(ie, 0, sizeof(ie), IAXIE_USERNAME, r->user);
                if (o) send_rel(r, IAXF_IAX, IAXC_REGREL, ie, o, 0, 0);
                r->kill_at = NOW() + 3000;
                r->acc = -1;                     /* orphan: no account to update */
            }
        }
        for (pp = &g_accts; *pp; pp = &(*pp)->next) if (*pp == a) { *pp = a->next; break; }
        acct_free(a);
    }
    UK();
    (void)t0;
    return SPC_OK;
}

int spc_iax2_account_register(int acc, int on)
{
    iax_acct* a;
    LK();
    a = acct_find(acc);
    UK();
    if (!a) return spc_err(SPC_E_NOT_FOUND, 0, "account %d not found", acc);
    acct_do_reg(acc, on ? 0 : 1);
    return SPC_OK;
}

int spc_iax2_account_set_presence(int acc, const char* status, const char* note)
{
    iax_acct* a;
    LK();
    a = acct_find(acc);
    if (!a) { UK(); return spc_err(SPC_E_NOT_FOUND, 0, "account %d not found", acc); }
    spc_strlcpy(a->presence, status, sizeof(a->presence));
    spc_strlcpy(a->presence_note, note ? note : "", sizeof(a->presence_note));
    UK();
    return SPC_OK;
}

cJSON* spc_iax2_acc_info_json(int acc)
{
    iax_acct* a;
    cJSON* o = NULL;
    if (!g_ready) return NULL;
    LK();
    a = acct_find(acc);
    if (a) o = acct_info_locked(a);
    UK();
    return o;
}

void spc_iax2_acc_list_json(cJSON* arr)
{
    iax_acct* a;
    if (!g_ready) return;
    LK();
    for (a = g_accts; a; a = a->next) cJSON_AddItemToArray(arr, acct_info_locked(a));
    UK();
}

void spc_iax2_unregister_all(int max_ms)
{
    iax_acct* a;
    int ids[64], n = 0, i;
    int64_t t0 = spc_mono_ms();
    if (!g_ready || !g_up) return;
    LK();
    for (a = g_accts; a && n < 64; a = a->next)
        if (strcmp(a->reg_state, "registered") == 0 || strcmp(a->reg_state, "registering") == 0) ids[n++] = a->acc;
    UK();
    for (i = 0; i < n; i++) acct_do_reg(ids[i], 1);
    for (;;) {
        int pending = 0;
        LK();
        for (a = g_accts; a; a = a->next)
            if (strcmp(a->reg_state, "unregistering") == 0) pending++;
        UK();
        if (!pending || spc_mono_ms() - t0 > max_ms) break;
        spc_sleep_ms(20);
    }
}

/* ------------------------------------------------------------------ */
/* call API                                                            */
/* ------------------------------------------------------------------ */
static int clean_number(const char* in, char* out, size_t n)
{
    const char* p = in;
    size_t i = 0;
    char tmp[128];
    if (!in) return -1;
    if (spc_strnieq(p, "iax2:", 5)) p += 5;
    else if (spc_strnieq(p, "iax:", 4)) p += 4;
    else if (spc_strnieq(p, "sip:", 4)) p += 4;
    else if (spc_strnieq(p, "tel:", 4)) p += 4;
    while (*p == '/') p++;
    for (; *p && *p != '@' && *p != ';' && *p != '?' && i < sizeof(tmp) - 1; p++) tmp[i++] = *p;
    tmp[i] = 0;
    if (!i || i >= n) return -1;
    for (i = 0; tmp[i]; i++)
        if (!(isalnum((unsigned char)tmp[i]) || strchr("*#+_.-/", tmp[i]))) return -1;
    spc_strlcpy(out, tmp, n);
    return 0;
}

int spc_iax2_call_make(int acc, const cJSON* p, cJSON** res)
{
    const char* uri = spc_jstr(p, "uri");
    const char* dn = spc_jstr(p, "displayName");
    int anon = spc_jbool(p, "anonymous", 0);
    char num[64];
    iax_acct* a;
    iax_sess* s;
    uint32_t ours[3];
    int n, calls = 0;
    uint8_t ie[600];
    size_t o;
    uint64_t cid;
    int slot;
    pj_sockaddr_in addr;
    char host[128];
    int need;
    if (!uri || clean_number(uri, num, sizeof(num)) != 0) return spc_err(SPC_E_INVALID_PARAM, 0, "invalid iax2 destination");
    if (!g_up) return spc_err(SPC_E_NOT_FOUND, 0, "account %d not found", acc);
    LK();
    a = acct_find(acc);
    if (!a) { UK(); return spc_err(SPC_E_NOT_FOUND, 0, "account %d not found", acc); }
    need = !a->addr_ok;
    spc_strlcpy(host, a->host, sizeof(host));
    UK();
    if (need) {
        pj_sockaddr_in r;
        if (resolve_host(host, &r) != 0) return spc_err(SPC_E_PJ_ERROR, 0, "cannot resolve '%s'", host);
        LK();
        a = acct_find(acc);
        if (a && strcmp(host, a->host) == 0) { a->addr = r; a->addr.sin_port = pj_htons((pj_uint16_t)a->port); a->addr_ok = 1; }
        UK();
    }
    LK();
    a = acct_find(acc);
    if (!a || !a->addr_ok) { UK(); return spc_err(SPC_E_NOT_FOUND, 0, "account %d not found", acc); }
    addr = a->addr;
    for (s = g_sessions; s; s = s->next) if (s->kind == SK_CALL && s->cid) calls++;
    if (G.max_calls > 0 && calls >= G.max_calls) { UK(); return spc_err(SPC_E_BUSY, 0, "too many calls"); }
    s = call_session_create(a, &addr, 0);
    if (!s) { UK(); return spc_err(SPC_E_BUSY, 0, "too many calls"); }
    n = acct_formats(a, ours);
    s->cap_ours = fmts_mask(ours, n);
    s->tx_fmt = ours[0];
    spc_strlcpy(s->called, num, sizeof(s->called));
    spc_strlcpy(s->remote_user, num, sizeof(s->remote_user));
    spc_strlcpy(s->user, a->user, sizeof(s->user));
    spc_strlcpy(s->pass, a->pass, sizeof(s->pass));
    s->t_ping = NOW() + 5000;
    o = iax_put_u16(ie, 0, sizeof(ie), IAXIE_VERSION, 2);
    if (o) o = iax_put_str(ie, o, sizeof(ie), IAXIE_CALLED_NUMBER, num);
    if (o && a->context[0]) o = iax_put_str(ie, o, sizeof(ie), IAXIE_CALLED_CONTEXT, a->context);
    if (!anon) {
        const char* cn = a->caller_id[0] ? a->caller_id : a->user;
        const char* nm = (dn && dn[0]) ? dn : (a->display[0] ? a->display : NULL);
        if (o) o = iax_put_str(ie, o, sizeof(ie), IAXIE_CALLING_NUMBER, cn);
        if (o && nm) o = iax_put_str(ie, o, sizeof(ie), IAXIE_CALLING_NAME, nm);
    } else {
        if (o) o = iax_put_str(ie, o, sizeof(ie), IAXIE_CALLING_NAME, "Anonymous");
        if (o) o = iax_put_u8(ie, o, sizeof(ie), IAXIE_CALLINGPRES, 0x20);
    }
    if (o) o = iax_put_str(ie, o, sizeof(ie), IAXIE_USERNAME, a->user);
    if (o) o = iax_put_u32(ie, o, sizeof(ie), IAXIE_CAPABILITY, s->cap_ours);
    if (o) o = iax_put_u32(ie, o, sizeof(ie), IAXIE_FORMAT, s->tx_fmt);
    if (!o || send_rel(s, IAXF_IAX, IAXC_NEW, ie, o, 0, 0) != 0) {
        uint64_t id = s->cid;
        spc_call* c2;
        s->cid = 0; s->zombie = 1; s->kill_at = 0;
        c2 = spc_call_lock_find(id);
        if (c2) { spc_registry_unlock(); spc_call_iax_finish(c2, NULL); }
        UK();
        return spc_err(SPC_E_INTERNAL, 0, "cannot build NEW");
    }
    cid = s->cid;
    slot = s->slot;
    emit_state(s);
    UK();
    *res = cJSON_CreateObject();
    cJSON_AddNumberToObject(*res, "cid", (double)cid);
    cJSON_AddNumberToObject(*res, "call", slot);
    return SPC_OK;
}

static void set_flag_locked(uint64_t cid, int off, int v)
{
    spc_call* c = spc_call_lock_find(cid);
    if (!c) return;
    switch (off) {
    case 0: c->responded = v; break;
    case 1: c->ring_sent = v; break;
    case 3: c->held = v; break;
    default: break;
    }
    spc_registry_unlock();
}

int spc_iax2_call_op(int op, uint64_t cid, const cJSON* p, cJSON** res)
{
    iax_sess* s;
    int rc = SPC_OK;
    (void)res;
    ensure_ready();
    if (op == SPC_IAXOP_UNSUPPORTED) return spc_err(SPC_E_UNSUPPORTED, 0, "not supported for IAX2 calls");
    LK();
    s = sess_by_cid(cid);
    if (!s || s->finished) { UK(); return spc_err(SPC_E_NOT_FOUND, 0, "call %llu not found", (unsigned long long)cid); }
    if (s->term_req && op != SPC_IAXOP_HANGUP && op != SPC_IAXOP_REJECT) { UK(); return spc_err(SPC_E_BUSY, 0, "call is ending"); }
    switch (op) {
    case SPC_IAXOP_ANSWER: {
        int code = spc_jint(p, "code", 200);
        if (code < 101 || code > 699 || (code >= 300 && code < 400)) { rc = spc_err(SPC_E_INVALID_PARAM, 0, "invalid answer code %d", code); break; }
        if (s->role != 1 || s->state == CS_CONFIRMED) { rc = spc_err(SPC_E_BUSY, 0, "invalid call state"); break; }
        if (code >= 400) {
            const char* t;
            int cc = status_to_cause(code, &t);
            send_hangup_frame(s, cc, t, 1);
            request_term(s, code, t);
            set_flag_locked(cid, 0, 1);
            break;
        }
        set_flag_locked(cid, 0, 1);
        if (code == 200) {
            send_rel(s, IAXF_CONTROL, IAXCTL_ANSWER, NULL, 0, 0, 0);
            call_confirm(s);
        } else if (code == 183) {
            send_rel(s, IAXF_CONTROL, IAXCTL_PROGRESS, NULL, 0, 0, 0);
            set_flag_locked(cid, 1, 1);
            s->want_media = s->media_state == 0;
            set_state(s, CS_EARLY, 183, "Session Progress");
        } else {
            send_rel(s, IAXF_CONTROL, IAXCTL_RINGING, NULL, 0, 0, 0);
            set_flag_locked(cid, 1, 1);
            set_state(s, CS_EARLY, 180, "Ringing");
        }
        break;
    }
    case SPC_IAXOP_RING: {
        int need;
        spc_call* c = spc_call_lock_find(cid);
        if (!c) { rc = spc_err(SPC_E_NOT_FOUND, 0, "call gone"); break; }
        c->responded = 1; need = !c->ring_sent; c->ring_sent = 1;
        spc_registry_unlock();
        if (need && s->role == 1 && s->state == CS_INCOMING) {
            send_rel(s, IAXF_CONTROL, IAXCTL_RINGING, NULL, 0, 0, 0);
            set_state(s, CS_EARLY, 180, "Ringing");
        }
        break;
    }
    case SPC_IAXOP_REJECT: {
        int code = spc_jint(p, "code", 486);
        const char* reason = spc_jstr(p, "reason");
        const char* t;
        int cc;
        if (code < 300 || code > 699) { rc = spc_err(SPC_E_INVALID_PARAM, 0, "reject code must be 300..699"); break; }
        set_flag_locked(cid, 0, 1);
        cc = status_to_cause(code, &t);
        send_hangup_frame(s, cc, reason && reason[0] ? reason : t, s->state < CS_CONFIRMED && s->role == 1);
        request_term(s, code, reason && reason[0] ? reason : t);
        break;
    }
    case SPC_IAXOP_HANGUP: {
        int code = spc_jint(p, "code", 0);
        if (code != 0 && (code < 200 || code > 699)) { rc = spc_err(SPC_E_INVALID_PARAM, 0, "invalid code"); break; }
        if (s->state == CS_CONFIRMED) {
            send_hangup_frame(s, 16, "Normal Clearing", 0);
            request_term(s, code ? code : 200, "Normal call clearing");
        } else if (s->role == 1 && s->state == CS_INCOMING) {
            send_hangup_frame(s, 21, "Call rejected", 1);
            request_term(s, code ? code : 603, "Decline");
        } else {
            send_hangup_frame(s, 16, "Normal Clearing", 0);
            request_term(s, code ? code : 487, "Request Terminated");
        }
        break;
    }
    case SPC_IAXOP_HOLD:
        if (s->state != CS_CONFIRMED && s->state != CS_EARLY) { rc = spc_err(SPC_E_BUSY, 0, "invalid call state"); break; }
        if (!s->held) {
            s->held = 1;
            send_rel(s, IAXF_IAX, IAXC_QUELCH, NULL, 0, 0, 0);
            send_rel(s, IAXF_CONTROL, IAXCTL_HOLD, NULL, 0, 0, 0);
            set_flag_locked(cid, 3, 1);
            emit_media(s);
        }
        break;
    case SPC_IAXOP_UNHOLD:
        if (s->held) {
            s->held = 0;
            send_rel(s, IAXF_IAX, IAXC_UNQUELCH, NULL, 0, 0, 0);
            send_rel(s, IAXF_CONTROL, IAXCTL_UNHOLD, NULL, 0, 0, 0);
            set_flag_locked(cid, 3, 0);
            emit_media(s);
        }
        break;
    case SPC_IAXOP_DTMF: {
        const char* digits = spc_jstr(p, "digits");
        int dur = spc_jint(p, "durationMs", 160), i;
        if (s->state != CS_CONFIRMED) { rc = spc_err(SPC_E_BUSY, 0, "invalid call state"); break; }
        if (!digits) { rc = spc_err(SPC_E_INVALID_PARAM, 0, "'digits' required"); break; }
        if (s->dtmf_n + (int)strlen(digits) > (int)sizeof(s->dtmf_q)) { rc = spc_err(SPC_E_BUSY, 0, "DTMF queue full"); break; }
        if (s->dtmf_n == 0) { s->dtmf_pos = 0; s->dtmf_state = 0; s->dtmf_next = 0; }
        s->dtmf_dur = dur;
        for (i = 0; digits[i]; i++) s->dtmf_q[s->dtmf_n++] = (char)toupper((unsigned char)digits[i]);
        break;
    }
    case SPC_IAXOP_TRANSFER: {
        const char* target = spc_jstr(p, "target");
        char num[64];
        uint8_t ie[160];
        size_t o;
        iax_acct* a = acct_find(s->acc);
        if (s->state != CS_CONFIRMED) { rc = spc_err(SPC_E_BUSY, 0, "invalid call state"); break; }
        if (!target || clean_number(target, num, sizeof(num)) != 0) { rc = spc_err(SPC_E_INVALID_PARAM, 0, "invalid transfer target"); break; }
        o = iax_put_str(ie, 0, sizeof(ie), IAXIE_CALLED_NUMBER, num);
        if (o && a && a->context[0]) o = iax_put_str(ie, o, sizeof(ie), IAXIE_CALLED_CONTEXT, a->context);
        if (!o || send_rel(s, IAXF_IAX, IAXC_TRANSFER, ie, o, 0, 0) != 0) { rc = spc_err(SPC_E_INTERNAL, 0, "cannot send TRANSFER"); break; }
        {
            cJSON* f = cJSON_CreateObject();
            cJSON_AddNumberToObject(f, "cid", (double)cid);
            cJSON_AddNumberToObject(f, "code", 202);
            cJSON_AddStringToObject(f, "reason", "Transfer requested");
            cJSON_AddBoolToObject(f, "final", 0);
            spc_call_emit(cid, "call.transferStatus", f);
        }
        break;
    }
    default: rc = spc_err(SPC_E_UNSUPPORTED, 0, "unsupported"); break;
    }
    UK();
    return rc;
}

cJSON* spc_iax2_call_info_json(uint64_t cid)
{
    iax_sess* s;
    cJSON* o = NULL;
    spc_call* c;
    if (!g_ready) return NULL;
    LK();
    s = sess_by_cid(cid);
    if (s) {
        spc_registry_lock();
        c = spc_call_find_locked(cid);
        if (c) o = call_info_locked(s, c);
        spc_registry_unlock();
    }
    UK();
    return o;
}

int spc_iax2_call_conf(uint64_t cid, int* conf_slot, int* active)
{
    iax_sess* s;
    int r = -1;
    if (!g_ready) return -1;
    LK();
    s = sess_by_cid(cid);
    if (s) {
        if (conf_slot) *conf_slot = s->media_state == 1 ? s->conf_slot : -1;
        if (active) *active = (s->media_state == 1 && !s->held && !s->rhold && !s->term_req);
        r = 0;
    }
    UK();
    return r;
}

cJSON* spc_iax2_call_stats_json(uint64_t cid, int* err)
{
    iax_sess* s;
    cJSON *o, *rx, *tx, *rtt, *jb, *ice;
    pjmedia_jb_state js;
    int cslot = -1;
    unsigned txl = 0, rxl = 0;
    char codec[24], a1[40], a2[40];
    double lossPct, rttavg, ptime = 20;
    unsigned lost = 0;
    pj_sockaddr_in peer;
    *err = 0;
    if (!g_ready) { *err = SPC_E_NOT_FOUND; return NULL; }
    pj_bzero(&js, sizeof(js));
    LK();
    s = sess_by_cid(cid);
    if (!s) { UK(); *err = SPC_E_NOT_FOUND; return NULL; }
    if (s->media_state != 1 || !s->jb) { UK(); *err = SPC_E_BUSY; return NULL; }
    spc_strlcpy(codec, fmt_name(s->tx_fmt), sizeof(codec));
    cslot = s->conf_slot;
    peer = s->peer;
    spc_mutex_lock(&s->jbm);
    pjmedia_jbuf_get_state(s->jb, &js);
    spc_mutex_unlock(&s->jbm);
    lost = js.lost;
    o = cJSON_CreateObject();
    cJSON_AddNumberToObject(o, "cid", (double)cid);
    cJSON_AddStringToObject(o, "codec", codec);
    cJSON_AddNumberToObject(o, "clockRate", 8000);
    cJSON_AddNumberToObject(o, "ptime", ptime);
    {
        double tot = (double)s->rx_pkts + (double)lost;
        lossPct = tot > 0 ? 100.0 * (double)lost / tot : 0;
    }
    rx = cJSON_AddObjectToObject(o, "rx");
    cJSON_AddNumberToObject(rx, "packets", (double)s->rx_pkts);
    cJSON_AddNumberToObject(rx, "bytes", (double)s->rx_bytes);
    cJSON_AddNumberToObject(rx, "lost", (double)lost);
    cJSON_AddNumberToObject(rx, "lossPct", lossPct);
    cJSON_AddNumberToObject(rx, "discard", (double)js.discard);
    cJSON_AddNumberToObject(rx, "reorder", (double)s->rx_reorder);
    cJSON_AddNumberToObject(rx, "dup", (double)s->rx_dup);
    cJSON_AddNumberToObject(rx, "jitterMs", s->jitter_ms);
    cJSON_AddNumberToObject(rx, "jitterMaxMs", s->jitter_max_ms);
    cJSON_AddNumberToObject(rx, "lossPeriodMs", 0);
    tx = cJSON_AddObjectToObject(o, "tx");
    cJSON_AddNumberToObject(tx, "packets", (double)s->tx_pkts);
    cJSON_AddNumberToObject(tx, "bytes", (double)s->tx_bytes);
    cJSON_AddNumberToObject(tx, "lost", 0);
    cJSON_AddNumberToObject(tx, "lossPct", 0);
    cJSON_AddNumberToObject(tx, "jitterMs", 0);
    rttavg = s->rtt_n ? s->rtt_sum / s->rtt_n : 0;
    rtt = cJSON_AddObjectToObject(o, "rtt");
    cJSON_AddNumberToObject(rtt, "lastMs", s->rtt_last);
    cJSON_AddNumberToObject(rtt, "minMs", s->rtt_n ? s->rtt_min : 0);
    cJSON_AddNumberToObject(rtt, "avgMs", rttavg);
    cJSON_AddNumberToObject(rtt, "maxMs", s->rtt_max);
    jb = cJSON_AddObjectToObject(o, "jb");
    cJSON_AddNumberToObject(jb, "prefetch", js.prefetch);
    cJSON_AddNumberToObject(jb, "size", js.size);
    cJSON_AddNumberToObject(jb, "avgDelayMs", js.avg_delay);
    cJSON_AddNumberToObject(jb, "maxDelayMs", js.max_delay);
    cJSON_AddNumberToObject(jb, "burst", js.burst);
    cJSON_AddNumberToObject(jb, "empty", js.empty);
    cJSON_AddNumberToObject(jb, "discard", js.discard);
    cJSON_AddNumberToObject(o, "mos", spc_emodel_mos(codec, lossPct, s->jitter_ms, rttavg, js.avg_delay, ptime));
    addr_str(&peer, a2, sizeof(a2));
    snprintf(a1, sizeof(a1), "0.0.0.0:%d", g_port);
    UK();
    if (cslot >= 0) pjsua_conf_get_signal_level(cslot, &txl, &rxl);
    cJSON_AddNumberToObject(o, "rxLevel", rxl);
    cJSON_AddNumberToObject(o, "txLevel", txl);
    cJSON_AddBoolToObject(o, "srtp", 0);
    cJSON_AddNullToObject(o, "crypto");
    ice = cJSON_AddObjectToObject(o, "ice");
    cJSON_AddStringToObject(ice, "state", "none");
    cJSON_AddStringToObject(ice, "localType", "");
    cJSON_AddStringToObject(ice, "remoteType", "");
    cJSON_AddStringToObject(o, "localRtp", a1);
    cJSON_AddStringToObject(o, "remoteRtp", a2);
    return o;
}

/* ------------------------------------------------------------------ */
/* shutdown                                                            */
/* ------------------------------------------------------------------ */
void spc_iax2_hangup_all(void)
{
    iax_sess* s;
    if (!g_ready || !g_up) return;
    LK();
    for (s = g_sessions; s; s = s->next) {
        if (s->kind == SK_CALL && s->cid && !s->zombie && !s->term_req) {
            if (s->state == CS_INCOMING && s->role == 1) { send_hangup_frame(s, 21, "Call rejected", 1); request_term(s, 603, "Decline"); }
            else { send_hangup_frame(s, 16, "Normal Clearing", 0); request_term(s, s->state == CS_CONFIRMED ? 200 : 487, s->state == CS_CONFIRMED ? "Normal call clearing" : "Request Terminated"); }
        }
    }
    UK();
}

void spc_iax2_shutdown(void)
{
    iax_acct* a;
    iax_sess* s;
    int64_t t0 = spc_mono_ms();
    if (!g_ready) return;
    if (g_up) {
        spc_iax2_hangup_all();
        for (;;) {                   /* wait for the IAX thread to finish every call */
            int left = 0;
            LK();
            for (s = g_sessions; s; s = s->next) if (s->kind == SK_CALL && s->cid) left++;
            UK();
            if (!left || spc_mono_ms() - t0 > 2000) break;
            spc_sleep_ms(10);
        }
        /* give pending HANGUP frames a moment to leave */
        spc_sleep_ms(20);
        g_quit = 1;
        spc_thread_join(&g_thr);
        g_up = 0;
        if (g_sock != PJ_INVALID_SOCKET) { pj_sock_close(g_sock); g_sock = PJ_INVALID_SOCKET; }
    }
    for (;;) {                       /* thread is gone: tear down whatever is left, without g_mtx held across pjsua calls */
        uint64_t cid;
        spc_call* c;
        LK();
        for (s = g_sessions; s; s = s->next) if (s->media_state == 1 || s->cid) break;
        UK();
        if (!s) break;
        media_stop(s);
        LK();
        cid = s->cid;
        UK();
        if (cid) {
            c = spc_call_lock_find(cid);
            if (c) {
                cJSON* o;
                spc_registry_unlock();
                spc_call_cleanup_media(c);
                LK();
                s->state = CS_DISC; s->scode = 487; spc_strlcpy(s->sreason, "Engine stopped", sizeof(s->sreason));
                s->t_term = NOW();
                spc_registry_lock();
                o = call_info_locked(s, c);
                spc_registry_unlock();
                spc_call_iax_finish(c, o);
                UK();
            }
            LK(); s->cid = 0; UK();
        }
        LK(); s->media_state = 2; UK();
    }
    LK();
    while (g_sessions) sess_destroy(g_sessions);
    while (g_accts) { a = g_accts; g_accts = a->next; acct_free(a); }
    UK();
}
