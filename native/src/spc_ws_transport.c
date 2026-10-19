/* spc_ws_transport.c: SIP over WebSocket (RFC 7118, "ws" / "wss") as a PJSIP transport factory.
 *
 * Client only: a connection-oriented transport (like TCP/TLS) whose connection is an RFC 6455 WebSocket
 * with sub-protocol "sip". WSS runs the WebSocket over pj_ssl_sock, WS over pj_activesock. The transport is
 * registered with the transport manager keyed by (type, remote address), so requests the server sends on
 * the connection are answered over it, and in-dialog requests towards the same server reuse it.
 *
 * Own minimal RFC 6455 client (pjlib-util websock.c is experimental, hides the TLS socket info we need for
 * the certificate policy of spc_tls.c, and has no per-message size policy tuned for SIP).
 * Hostile input: all frame lengths are validated before any copy, messages are capped at PJSIP_MAX_PKT_LEN,
 * server frames must be unmasked, RSV bits must be 0, control frames <= 125 bytes and unfragmented,
 * the HTTP upgrade response is capped at 4 KiB and verified (101, Upgrade, Connection, Accept, protocol).
 */
#include "spc_internal.h"
#include "spc_ws_transport.h"

#include <pjsip/sip_transport.h>
#include <pjsip/sip_transport_tls.h>
#include <pjsip/sip_endpoint.h>
#include <pjsip/sip_errno.h>
#include <pjsip/sip_msg.h>
#include <pj/activesock.h>
#include <pj/ssl_sock.h>
#include <pj/addr_resolv.h>
#include <pj/compat/socket.h>
#include <pj/lock.h>
#include <pj/log.h>
#include <pj/os.h>
#include <pj/pool.h>
#include <pj/rand.h>
#include <pjlib-util/sha1.h>
#include <pjlib-util/base64.h>
#include <ctype.h>

#if defined(__has_include)
#  if __has_include(<openssl/rand.h>)
#    include <openssl/rand.h>
#    define SPC_WS_HAVE_RAND_BYTES 1
#  endif
#endif

#define THIS_FILE "spc_ws"

#define WS_MAX_MSG          PJSIP_MAX_PKT_LEN          /* largest SIP message (reassembled) we accept */
#define WS_RXBUF            (WS_MAX_MSG + 32)          /* one full frame: header(<=14) + payload(<=WS_MAX_MSG) */
#define WS_MAX_HTTP_HDR     4096
/* WebSocket ping interval; the connection is dropped after 2.5 intervals without any received data.
 * SPC_WS_KA_SEC (environment, read at core.start) overrides the 30 s default - used by the tests. */
static int g_ka_sec = 30;
#define WS_KA_INTERVAL_SEC  g_ka_sec
#define WS_DEAD_SEC         ((g_ka_sec * 5) / 2)
#define WS_NCTL             4
#define WS_CTL_BUF          144
#define WS_DEFAULT_PATH     "/ws"

enum { OP_CONT = 0, OP_TEXT = 1, OP_BIN = 2, OP_CLOSE = 8, OP_PING = 9, OP_PONG = 10 };
enum { ST_CONNECTING = 0, ST_UPGRADE, ST_OPEN };

typedef struct ws_ctl {
    pj_ioqueue_op_key_t key;
    unsigned char buf[WS_CTL_BUF];
    volatile int busy;
} ws_ctl;

typedef struct ws_factory {
    pjsip_tpfactory factory;
    pjsip_endpoint* endpt;
    pjsip_tpmgr* tpmgr;
    int is_wss;
    int is_v6;
    pj_bool_t is_registered;
    pj_grp_lock_t* grp_lock;
    pj_ssl_cert_t* cert;
    pjsip_tls_setting tls;
    char invalid_host[40];
} ws_factory;

struct delayed_tdata {
    PJ_DECL_LIST_MEMBER(struct delayed_tdata);
    pjsip_tx_data_op_key* tdata_op_key;
    pj_time_val timeout;
};

typedef struct ws_tp {
    pjsip_transport base;
    pj_bool_t is_registered;
    pj_bool_t is_closing;
    pj_status_t close_reason;
    int is_wss;
    int state;
    pj_bool_t has_pending_connect;          /* true until the WebSocket is open */
    pj_sock_t sock;
    pj_activesock_t* asock;
    pj_ssl_sock_t* ssock;
    pj_grp_lock_t* grp_lock;
    struct delayed_tdata delayed_list;
    pj_str_t remote_host;                    /* name for SNI / Host / certificate identity */
    char host_hdr[160];
    char path[132];
    char key_b64[32];
    char accept_exp[32];
    unsigned char* rxbuf;
    int frag_op;                             /* opcode of the message being reassembled, 0 = none */
    size_t msglen;
    int close_sent;
    int upgrade_sent;
    pj_timer_entry ka_timer;
    pj_time_val last_rx;
    pjsip_rx_data rdata;
    ws_ctl ctl[WS_NCTL];
    ws_ctl ctl_close;
    ws_ctl ctl_upgrade;
    char upgrade_req[640];
    struct ws_tp* next_open;                 /* list of open connections (alias lookup) */
    int in_open_list;
} ws_tp;

static int g_types[2][2];                    /* [wss][v6] pjsip transport type ids */
static int g_types_registered;

/* ------------------------------------------------------------------ */
/* helpers                                                             */
/* ------------------------------------------------------------------ */
static void ws_random(void* buf, size_t n)
{
    unsigned char* p = (unsigned char*)buf;
    size_t i;
#ifdef SPC_WS_HAVE_RAND_BYTES
    if (RAND_bytes(p, (int)n) == 1) return;
#endif
    for (i = 0; i < n; i++) p[i] = (unsigned char)(pj_rand() >> 3);
}

void spc_ws_random_invalid_host(char* out, size_t outsz)
{
    static const char al[] = "abcdefghijklmnopqrstuvwxyz0123456789";
    unsigned char r[10];
    size_t i;
    if (outsz < 20) { if (outsz) out[0] = 0; return; }
    ws_random(r, sizeof(r));
    for (i = 0; i < sizeof(r); i++) out[i] = al[r[i] % (sizeof(al) - 1)];
    memcpy(out + sizeof(r), ".invalid", 9);
}

int spc_ws_type_is_wss(int tp_type)
{
    return g_types_registered && (tp_type & ~PJSIP_TRANSPORT_IPV6) == (g_types[1][0] & ~PJSIP_TRANSPORT_IPV6);
}

void spc_ws_ensure_port(const char* hp, int wss, char* out, size_t outsz)
{
    const char* colon;
    int has_port = 0;
    if (!hp) hp = "";
    if (hp[0] == '[') {
        const char* rb = strchr(hp, ']');
        has_port = rb && rb[1] == ':';
    } else {
        colon = strchr(hp, ':');
        has_port = colon != NULL && strchr(colon + 1, ':') == NULL;     /* bare IPv6 has several colons */
    }
    if (has_port) snprintf(out, outsz, "%s", hp);
    else if (hp[0] != '[' && strchr(hp, ':')) snprintf(out, outsz, "[%s]:%d", hp, wss ? 443 : 80);
    else snprintf(out, outsz, "%s:%d", hp, wss ? 443 : 80);
}

/* ---- route (path) registry ---- */
typedef struct { char host[128]; int port; int wss; char path[128]; } ws_route;
static ws_route g_routes[32];
static int g_nroutes;
static spc_mutex_t g_route_mtx;
static int g_route_mtx_init;

static void lower(char* s) { for (; *s; s++) *s = (char)tolower((unsigned char)*s); }

void spc_ws_route_set(const char* host, int port, int wss, const char* path)
{
    char h[128];
    int i;
    if (!host || !host[0]) return;
    if (!g_route_mtx_init) { spc_mutex_init(&g_route_mtx); g_route_mtx_init = 1; }
    spc_strlcpy(h, host, sizeof(h));
    lower(h);
    if (port <= 0) port = wss ? 443 : 80;
    spc_mutex_lock(&g_route_mtx);
    for (i = 0; i < g_nroutes; i++)
        if (g_routes[i].port == port && g_routes[i].wss == wss && strcmp(g_routes[i].host, h) == 0) break;
    if (i == g_nroutes && g_nroutes < (int)(sizeof(g_routes) / sizeof(g_routes[0]))) g_nroutes++;
    if (i < g_nroutes) {
        spc_strlcpy(g_routes[i].host, h, sizeof(g_routes[i].host));
        g_routes[i].port = port;
        g_routes[i].wss = wss;
        spc_strlcpy(g_routes[i].path, (path && path[0]) ? path : WS_DEFAULT_PATH, sizeof(g_routes[i].path));
    }
    spc_mutex_unlock(&g_route_mtx);
}

static int route_lookup(const char* host, int port, int wss, char* path, size_t n)
{
    char h[128];
    int i, found = 0;
    spc_strlcpy(path, WS_DEFAULT_PATH, n);
    if (!g_route_mtx_init || !host) return 0;
    spc_strlcpy(h, host, sizeof(h));
    lower(h);
    spc_mutex_lock(&g_route_mtx);
    for (i = 0; i < g_nroutes; i++)
        if (g_routes[i].port == port && g_routes[i].wss == wss && strcmp(g_routes[i].host, h) == 0) {
            spc_strlcpy(path, g_routes[i].path, n);
            found = 1;
            break;
        }
    spc_mutex_unlock(&g_route_mtx);
    return found;
}

/* ---- open connections (for connection aliasing, see lis_create_transport) ---- */
static struct ws_tp* g_open_list;

static void open_list_add(ws_tp* ws)
{
    if (!g_route_mtx_init) { spc_mutex_init(&g_route_mtx); g_route_mtx_init = 1; }
    spc_mutex_lock(&g_route_mtx);
    if (!ws->in_open_list) {
        ws->next_open = g_open_list;
        g_open_list = ws;
        ws->in_open_list = 1;
    }
    spc_mutex_unlock(&g_route_mtx);
}

static void open_list_remove(ws_tp* ws)
{
    ws_tp** pp;
    if (!g_route_mtx_init) return;
    spc_mutex_lock(&g_route_mtx);
    if (ws->in_open_list) {
        for (pp = &g_open_list; *pp; pp = &(*pp)->next_open)
            if (*pp == ws) { *pp = ws->next_open; break; }
        ws->in_open_list = 0;
    }
    spc_mutex_unlock(&g_route_mtx);
}

/* newest usable open connection of this transport type, or NULL. Caller holds the transport manager lock
 * (create_transport2 is called with it), so the transport cannot be destroyed concurrently. */
static ws_tp* open_find(int type, const char* name, int port)
{
    ws_tp* r = NULL;
    ws_tp* t;
    if (!g_route_mtx_init) return NULL;
    spc_mutex_lock(&g_route_mtx);
    for (t = g_open_list; t; t = t->next_open) {      /* newest first */
        if (t->base.key.type != type || t->state != ST_OPEN || t->base.is_shutdown || t->base.is_destroying) continue;
        if (name && !(t->remote_host.slen == (pj_ssize_t)strlen(name) && spc_strnieq(t->remote_host.ptr, name, strlen(name)) &&
                      (int)t->base.remote_name.port == port)) continue;
        r = t;
        break;
    }
    spc_mutex_unlock(&g_route_mtx);
    return r;
}

static void sockaddr_to_host_port(pj_pool_t* pool, pjsip_host_port* hp, const pj_sockaddr* addr)
{
    hp->host.ptr = (char*)pj_pool_alloc(pool, PJ_INET6_ADDRSTRLEN + 4);
    pj_sockaddr_print(addr, hp->host.ptr, PJ_INET6_ADDRSTRLEN + 4, 0);
    hp->host.slen = (pj_ssize_t)strlen(hp->host.ptr);
    hp->port = pj_sockaddr_get_port(addr);
}

/* RFC 6455 frame, client side: FIN set, masked. out needs len + 14 bytes. Returns frame size. */
static size_t ws_build_frame(unsigned char* out, int opcode, const void* payload, size_t len)
{
    size_t h = 0, i;
    unsigned char mask[4];
    out[h++] = (unsigned char)(0x80 | (opcode & 0x0f));
    if (len < 126) out[h++] = (unsigned char)(0x80 | len);
    else if (len < 65536) { out[h++] = 0x80 | 126; out[h++] = (unsigned char)(len >> 8); out[h++] = (unsigned char)len; }
    else {
        out[h++] = 0x80 | 127;
        for (i = 0; i < 8; i++) out[h++] = (unsigned char)(((uint64_t)len) >> (56 - 8 * i));
    }
    ws_random(mask, 4);
    memcpy(out + h, mask, 4);
    h += 4;
    for (i = 0; i < len; i++) out[h + i] = (unsigned char)(((const unsigned char*)payload)[i] ^ mask[i & 3]);
    return h + len;
}

/* ------------------------------------------------------------------ */
/* low level socket ops                                                */
/* ------------------------------------------------------------------ */
static pj_status_t raw_send(ws_tp* ws, pj_ioqueue_op_key_t* key, const void* buf, pj_ssize_t* len)
{
    if (ws->is_wss) {
        if (!ws->ssock) return PJ_EINVALIDOP;
        return pj_ssl_sock_send(ws->ssock, key, buf, len, 0);
    }
    if (!ws->asock) return PJ_EINVALIDOP;
    return pj_activesock_send(ws->asock, key, buf, len, 0);
}

static pj_bool_t ws_on_sent(ws_tp* ws, pj_ioqueue_op_key_t* op_key, pj_ssize_t bytes_sent);
static void ws_init_shutdown(ws_tp* ws, pj_status_t status);
static void cancel_delayed(ws_tp* ws, pj_status_t status);
static void ws_on_destroy(void* arg);
static pj_status_t ws_destroy(pjsip_transport* transport, pj_status_t reason);

static int ctl_owned(ws_tp* ws, pj_ioqueue_op_key_t* k)
{
    int i;
    for (i = 0; i < WS_NCTL; i++) if (k == &ws->ctl[i].key) return 1;
    return k == &ws->ctl_close.key || k == &ws->ctl_upgrade.key;
}

static void ctl_release(ws_tp* ws, pj_ioqueue_op_key_t* k)
{
    int i;
    for (i = 0; i < WS_NCTL; i++) if (k == &ws->ctl[i].key) ws->ctl[i].busy = 0;
    if (k == &ws->ctl_close.key) ws->ctl_close.busy = 0;
    if (k == &ws->ctl_upgrade.key) ws->ctl_upgrade.busy = 0;
}

/* Send a control frame (ping/pong/close). Best effort; never fails the transport by itself. */
static void send_ctl(ws_tp* ws, int opcode, const void* payload, size_t len)
{
    ws_ctl* c = NULL;
    pj_ssize_t sz;
    pj_status_t st;
    int i;
    if (len > 125) len = 125;
    if (opcode == OP_CLOSE) {
        if (ws->close_sent) return;
        ws->close_sent = 1;
        c = &ws->ctl_close;
    } else {
        for (i = 0; i < WS_NCTL; i++) if (!ws->ctl[i].busy) { c = &ws->ctl[i]; break; }
    }
    if (!c || c->busy) return;                       /* pong/ping flood: drop */
    c->busy = 1;
    pj_ioqueue_op_key_init(&c->key, sizeof(c->key));
    sz = (pj_ssize_t)ws_build_frame(c->buf, opcode, payload, len);
    st = raw_send(ws, &c->key, c->buf, &sz);
    if (st != PJ_EPENDING) c->busy = 0;
}

static void send_close(ws_tp* ws, unsigned code, const char* reason)
{
    unsigned char p[2 + 64];
    size_t n = 2;
    p[0] = (unsigned char)(code >> 8);
    p[1] = (unsigned char)code;
    if (reason) {
        size_t rl = strlen(reason);
        if (rl > 60) rl = 60;
        memcpy(p + 2, reason, rl);
        n += rl;
    }
    send_ctl(ws, OP_CLOSE, p, n);
}

/* ------------------------------------------------------------------ */
/* transport lifecycle                                                 */
/* ------------------------------------------------------------------ */
static void ws_init_shutdown(ws_tp* ws, pj_status_t status)
{
    pjsip_tp_state_callback state_cb;

    if (ws->close_reason == PJ_SUCCESS) ws->close_reason = status;
    if (ws->base.is_shutdown || ws->base.is_destroying) return;

    pjsip_transport_add_ref(&ws->base);
    /* requests queued while connecting hold transport references: fail them now */
    if (ws->has_pending_connect) cancel_delayed(ws, status ? status : PJ_ECANCELLED);
    state_cb = pjsip_tpmgr_get_state_cb(ws->base.tpmgr);
    if (state_cb) {
        pjsip_transport_state_info si;
        pj_bzero(&si, sizeof(si));
        si.status = ws->close_reason;
        (*state_cb)(&ws->base, PJSIP_TP_STATE_DISCONNECTED, &si);
    }
    if (ws->base.is_shutdown || ws->base.is_destroying) {
        pjsip_transport_dec_ref(&ws->base);
        return;
    }
    pjsip_transport_shutdown(&ws->base);
    pjsip_transport_dec_ref(&ws->base);
}

/* protocol violation / limit: send Close, then tear down */
static pj_bool_t ws_fail(ws_tp* ws, unsigned code, const char* why, pj_status_t status)
{
    PJ_LOG(3, (ws->base.obj_name, "WebSocket failure (%u): %s", code, why));
    if (ws->state == ST_OPEN) send_close(ws, code, why);
    ws_init_shutdown(ws, status);
    return PJ_FALSE;
}

static void cancel_delayed(ws_tp* ws, pj_status_t status)
{
    while (!pj_list_empty(&ws->delayed_list)) {
        struct delayed_tdata* d = ws->delayed_list.next;
        pj_list_erase(d);
        ws_on_sent(ws, (pj_ioqueue_op_key_t*)d->tdata_op_key, -status);
    }
}

static pj_status_t ws_destroy(pjsip_transport* transport, pj_status_t reason)
{
    ws_tp* ws = (ws_tp*)transport;

    if (ws->close_reason == 0) ws->close_reason = reason;
    if (ws->is_registered) {
        ws->is_registered = PJ_FALSE;
        pjsip_transport_destroy(transport);      /* recursively calls us again */
        return PJ_SUCCESS;
    }
    ws->is_closing = PJ_TRUE;
    open_list_remove(ws);
    if (ws->ka_timer.id) {
        pjsip_endpt_cancel_timer(ws->base.endpt, &ws->ka_timer);
        ws->ka_timer.id = PJ_FALSE;
    }
    cancel_delayed(ws, reason ? reason : PJ_ECANCELLED);
    if (ws->ssock) {
        pj_ssl_sock_close(ws->ssock);
        ws->ssock = NULL;
        ws->sock = PJ_INVALID_SOCKET;
    } else if (ws->asock) {
        pj_activesock_close(ws->asock);
        ws->asock = NULL;
        ws->sock = PJ_INVALID_SOCKET;
    } else if (ws->sock != PJ_INVALID_SOCKET) {
        pj_sock_close(ws->sock);
        ws->sock = PJ_INVALID_SOCKET;
    }
    if (ws->grp_lock) {
        pj_grp_lock_t* gl = ws->grp_lock;
        ws->grp_lock = NULL;
        pj_grp_lock_dec_ref(gl);                 /* transport may be freed here */
    }
    return PJ_SUCCESS;
}

static pj_status_t ws_destroy_transport(pjsip_transport* transport)
{
    ws_tp* ws = (ws_tp*)transport;
    ws->is_registered = PJ_FALSE;
    return ws_destroy(transport, ws->close_reason);
}

static void ws_on_destroy(void* arg)
{
    ws_tp* ws = (ws_tp*)arg;
    if (ws->base.lock) { pj_lock_destroy(ws->base.lock); ws->base.lock = NULL; }
    if (ws->base.ref_cnt) { pj_atomic_destroy(ws->base.ref_cnt); ws->base.ref_cnt = NULL; }
    if (ws->rdata.tp_info.pool) { pj_pool_release(ws->rdata.tp_info.pool); ws->rdata.tp_info.pool = NULL; }
    if (ws->base.pool) {
        pj_pool_t* pool = ws->base.pool;
        PJ_LOG(4, (ws->base.obj_name, "%s transport destroyed (reason %d)", ws->is_wss ? "WSS" : "WS", ws->close_reason));
        ws->base.pool = NULL;
        pj_pool_release(pool);
    }
}

static pj_status_t ws_shutdown(pjsip_transport* transport)
{
    ws_tp* ws = (ws_tp*)transport;
    if (ws->ka_timer.id) {
        pjsip_endpt_cancel_timer(ws->base.endpt, &ws->ka_timer);
        ws->ka_timer.id = PJ_FALSE;
    }
    if (ws->state == ST_OPEN) send_close(ws, 1000, NULL);       /* graceful close handshake (best effort) */
    return PJ_SUCCESS;
}

/* ------------------------------------------------------------------ */
/* sending SIP messages                                                */
/* ------------------------------------------------------------------ */
static pj_status_t send_tdata(ws_tp* ws, pjsip_tx_data* tdata, pj_ssize_t* psize)
{
    size_t plen = (size_t)(tdata->buf.cur - tdata->buf.start);
    unsigned char* frame = (unsigned char*)pj_pool_alloc(tdata->pool, plen + 14);
    pj_ssize_t size;
    if (!frame) { *psize = -PJ_ENOMEM; return PJ_ENOMEM; }
    size = (pj_ssize_t)ws_build_frame(frame, OP_TEXT, tdata->buf.start, plen);
    {
        pj_status_t st = raw_send(ws, &tdata->op_key.key, frame, &size);
        *psize = size;
        return st;
    }
}

static pj_bool_t ws_on_sent(ws_tp* ws, pj_ioqueue_op_key_t* op_key, pj_ssize_t bytes_sent)
{
    pjsip_tx_data_op_key* tk;
    if (ctl_owned(ws, op_key)) {
        ctl_release(ws, op_key);
        if (bytes_sent <= 0) {
            ws_init_shutdown(ws, bytes_sent == 0 ? PJ_RETURN_OS_ERROR(OSERR_ENOTCONN) : (pj_status_t)-bytes_sent);
            return PJ_FALSE;
        }
        return PJ_TRUE;
    }
    tk = (pjsip_tx_data_op_key*)op_key;
    tk->tdata = NULL;
    if (tk->callback) {
        if (bytes_sent == 0) bytes_sent = -PJ_RETURN_OS_ERROR(OSERR_ENOTCONN);
        tk->callback(&ws->base, tk->token, bytes_sent);
    }
    if (bytes_sent <= 0) {
        PJ_LOG(5, (ws->base.obj_name, "WS send() error, sent=%ld", (long)bytes_sent));
        ws_init_shutdown(ws, bytes_sent == 0 ? PJ_RETURN_OS_ERROR(OSERR_ENOTCONN) : (pj_status_t)-bytes_sent);
        return PJ_FALSE;
    }
    return PJ_TRUE;
}

static pj_status_t ws_send_msg(pjsip_transport* transport, pjsip_tx_data* tdata, const pj_sockaddr_t* rem_addr,
                               int addr_len, void* token, pjsip_transport_callback callback)
{
    ws_tp* ws = (ws_tp*)transport;
    pj_ssize_t size = 0;
    pj_bool_t delayed = PJ_FALSE;
    pj_status_t status = PJ_SUCCESS;

    PJ_ASSERT_RETURN(transport && tdata, PJ_EINVAL);
    PJ_ASSERT_RETURN(tdata->op_key.tdata == NULL, PJSIP_EPENDINGTX);
    PJ_ASSERT_RETURN(rem_addr && (addr_len == sizeof(pj_sockaddr_in) || addr_len == sizeof(pj_sockaddr_in6)), PJ_EINVAL);

    tdata->op_key.tdata = tdata;
    tdata->op_key.token = token;
    tdata->op_key.callback = callback;

    if (ws->has_pending_connect) {
        pj_lock_acquire(ws->base.lock);
        if (ws->has_pending_connect) {
            struct delayed_tdata* d = PJ_POOL_ZALLOC_T(tdata->pool, struct delayed_tdata);
            d->tdata_op_key = &tdata->op_key;
            if (tdata->msg && tdata->msg->type == PJSIP_REQUEST_MSG) {
                pj_gettickcount(&d->timeout);
                d->timeout.msec += pjsip_cfg()->tsx.td;
                pj_time_val_normalize(&d->timeout);
            }
            pj_list_push_back(&ws->delayed_list, d);
            status = PJ_EPENDING;
            delayed = PJ_TRUE;
        }
        pj_lock_release(ws->base.lock);
    }
    if (!delayed) {
        status = send_tdata(ws, tdata, &size);
        if (status != PJ_EPENDING) {
            tdata->op_key.tdata = NULL;
            if (size <= 0) {
                if (status == PJ_SUCCESS) status = PJ_RETURN_OS_ERROR(OSERR_ENOTCONN);
                ws_init_shutdown(ws, status);
            }
        }
    }
    return status;
}

static void flush_pending(ws_tp* ws)
{
    pj_time_val now;
    pj_gettickcount(&now);
    pj_lock_acquire(ws->base.lock);
    while (!pj_list_empty(&ws->delayed_list)) {
        struct delayed_tdata* d = ws->delayed_list.next;
        pjsip_tx_data* tdata;
        pj_ioqueue_op_key_t* op_key;
        pj_ssize_t size = 0;
        pj_status_t st;

        pj_list_erase(d);
        tdata = d->tdata_op_key->tdata;
        op_key = (pj_ioqueue_op_key_t*)d->tdata_op_key;
        if (d->timeout.sec > 0 && PJ_TIME_VAL_GT(now, d->timeout)) {
            pj_lock_release(ws->base.lock);
            ws_on_sent(ws, op_key, -PJ_ETIMEDOUT);
            pj_lock_acquire(ws->base.lock);
            continue;
        }
        st = send_tdata(ws, tdata, &size);
        if (st != PJ_EPENDING) {
            pj_lock_release(ws->base.lock);
            ws_on_sent(ws, op_key, size > 0 ? size : (st != PJ_SUCCESS ? -st : -PJ_EUNKNOWN));
            pj_lock_acquire(ws->base.lock);
        }
    }
    pj_lock_release(ws->base.lock);
}

/* ------------------------------------------------------------------ */
/* keep-alive: WebSocket ping every WS_KA_INTERVAL_SEC, dead after WS_DEAD_SEC without any rx */
/* ------------------------------------------------------------------ */
static void ws_ka_timer(pj_timer_heap_t* th, pj_timer_entry* e)
{
    ws_tp* ws = (ws_tp*)e->user_data;
    pj_time_val now, delay;
    PJ_UNUSED_ARG(th);
    ws->ka_timer.id = PJ_TRUE;
    if (ws->state != ST_OPEN || ws->base.is_shutdown) return;
    pj_gettickcount(&now);
    PJ_TIME_VAL_SUB(now, ws->last_rx);
    if (now.sec >= WS_DEAD_SEC) {
        PJ_LOG(3, (ws->base.obj_name, "WebSocket idle for %ld s, closing", (long)now.sec));
        ws_init_shutdown(ws, PJ_ETIMEDOUT);
        return;
    }
    send_ctl(ws, OP_PING, "spc", 3);
    delay.sec = WS_KA_INTERVAL_SEC;
    delay.msec = 0;
    pjsip_endpt_schedule_timer_w_grp_lock(ws->base.endpt, &ws->ka_timer, &delay, PJ_TRUE, ws->grp_lock);
}

/* ------------------------------------------------------------------ */
/* WebSocket open: notify pjsip / app, flush queue                      */
/* ------------------------------------------------------------------ */
static void fill_ssl_info(ws_tp* ws, pj_ssl_sock_info* si, pj_status_t* st)
{
    *st = pj_ssl_sock_get_info(ws->ssock, si);
    if (*st != PJ_SUCCESS) return;
    /* server identity (same rules as sip_transport_tls.c) */
    if (si->remote_cert_info && si->remote_cert_info->version) {
        pj_ssl_cert_info* sc = si->remote_cert_info;
        const pj_str_t* rn = ws->remote_host.slen ? &ws->remote_host : &ws->base.remote_name.host;
        pj_bool_t matched = PJ_FALSE;
        unsigned i;
        for (i = 0; i < sc->subj_alt_name.cnt && !matched; ++i) {
            pj_str_t* cn = &sc->subj_alt_name.entry[i].name;
            if (sc->subj_alt_name.entry[i].type == PJ_SSL_CERT_NAME_DNS || sc->subj_alt_name.entry[i].type == PJ_SSL_CERT_NAME_IP)
                matched = !pj_stricmp(rn, cn);
        }
        if (!matched) matched = !pj_stricmp(rn, &sc->subject.cn);
        if (!matched) si->verify_status |= PJ_SSL_CERT_EIDENTITY_NOT_MATCH;
    }
}

static pj_bool_t ws_opened(ws_tp* ws)
{
    pjsip_tp_state_callback state_cb;
    pj_bool_t shut;
    pj_ssl_sock_info ssl_info;
    pjsip_tls_state_info tls_info;
    pj_status_t st = PJ_SUCCESS;

    pj_lock_acquire(ws->base.lock);
    ws->state = ST_OPEN;
    pj_lock_release(ws->base.lock);
    pj_gettickcount(&ws->last_rx);

    pjsip_transport_add_ref(&ws->base);
    state_cb = pjsip_tpmgr_get_state_cb(ws->base.tpmgr);
    if (state_cb) {
        pjsip_transport_state_info si;
        pj_bzero(&si, sizeof(si));
        if (ws->is_wss) {
            pj_bzero(&tls_info, sizeof(tls_info));
            fill_ssl_info(ws, &ssl_info, &st);
            if (st == PJ_SUCCESS) {
                tls_info.ssl_sock_info = &ssl_info;
                si.ext_info = &tls_info;
            }
        }
        (*state_cb)(&ws->base, PJSIP_TP_STATE_CONNECTED, &si);
    }
    shut = ws->base.is_shutdown;
    pjsip_transport_dec_ref(&ws->base);
    if (shut) {
        /* e.g. rejected by the certificate policy (spc_tls.c shut the transport down) */
        pj_status_t why = ws->close_reason ? ws->close_reason : PJSIP_TLS_ECERTVERIF;
        cancel_delayed(ws, why);
        return PJ_FALSE;
    }
    pj_lock_acquire(ws->base.lock);
    ws->has_pending_connect = PJ_FALSE;
    pj_lock_release(ws->base.lock);
    open_list_add(ws);
    PJ_LOG(4, (ws->base.obj_name, "%s transport to %s is open", ws->is_wss ? "WSS" : "WS", ws->host_hdr));
    flush_pending(ws);
    {
        pj_time_val delay;
        delay.sec = WS_KA_INTERVAL_SEC;
        delay.msec = 0;
        pjsip_endpt_schedule_timer_w_grp_lock(ws->base.endpt, &ws->ka_timer, &delay, PJ_TRUE, ws->grp_lock);
    }
    return PJ_TRUE;
}

/* ------------------------------------------------------------------ */
/* HTTP upgrade                                                        */
/* ------------------------------------------------------------------ */
static const char WS_GUID[] = "258EAFA5-E914-47DA-95CA-C5AB0DC85B11";

static void compute_accept(const char* key_b64, char out[32])
{
    pj_sha1_context c;
    pj_uint8_t d[PJ_SHA1_DIGEST_SIZE];
    int ol = 32;
    pj_sha1_init(&c);
    pj_sha1_update(&c, (const pj_uint8_t*)key_b64, (pj_size_t)strlen(key_b64));
    pj_sha1_update(&c, (const pj_uint8_t*)WS_GUID, (pj_size_t)strlen(WS_GUID));
    pj_sha1_final(&c, d);
    pj_base64_encode(d, PJ_SHA1_DIGEST_SIZE, out, &ol);
    out[ol] = 0;
}

static pj_status_t send_upgrade(ws_tp* ws)
{
    unsigned char k[16];
    int kl = 32, n;
    pj_ssize_t sz;
    pj_status_t st;
    ws_random(k, 16);
    pj_base64_encode(k, 16, ws->key_b64, &kl);
    ws->key_b64[kl] = 0;
    compute_accept(ws->key_b64, ws->accept_exp);
    n = snprintf(ws->upgrade_req, sizeof(ws->upgrade_req),
                 "GET %s HTTP/1.1\r\n"
                 "Host: %s\r\n"
                 "Upgrade: websocket\r\n"
                 "Connection: Upgrade\r\n"
                 "Sec-WebSocket-Key: %s\r\n"
                 "Sec-WebSocket-Version: 13\r\n"
                 "Sec-WebSocket-Protocol: sip\r\n"
                 "\r\n",
                 ws->path, ws->host_hdr, ws->key_b64);
    if (n <= 0 || n >= (int)sizeof(ws->upgrade_req)) return PJ_ETOOBIG;
    ws->state = ST_UPGRADE;
    ws->ctl_upgrade.busy = 1;
    pj_ioqueue_op_key_init(&ws->ctl_upgrade.key, sizeof(ws->ctl_upgrade.key));
    sz = n;
    st = raw_send(ws, &ws->ctl_upgrade.key, ws->upgrade_req, &sz);
    if (st == PJ_SUCCESS || st == PJ_EPENDING) return PJ_SUCCESS;
    ws->ctl_upgrade.busy = 0;
    return st;
}

/* case-insensitive: does the comma separated list contain token? */
static int has_token(const char* list, const char* token)
{
    size_t tl = strlen(token);
    const char* p = list;
    while (*p) {
        const char* e;
        while (*p == ' ' || *p == '\t' || *p == ',') p++;
        e = p;
        while (*e && *e != ',') e++;
        {
            const char* q = e;
            while (q > p && (q[-1] == ' ' || q[-1] == '\t')) q--;
            if ((size_t)(q - p) == tl && spc_strnieq(p, token, tl)) return 1;
        }
        p = e;
    }
    return 0;
}

/* hdr: NUL-terminated response head (without the final blank line). Returns 0 if valid. */
static int check_upgrade_response(ws_tp* ws, char* hdr)
{
    char* line = hdr;
    int first = 1, nlines = 0;
    int got_upgrade = 0, got_conn = 0, got_accept = 0;
    while (line && *line) {
        char* eol = strstr(line, "\r\n");
        char* colon;
        char* name;
        char* val;
        if (eol) *eol = 0;
        if (++nlines > 64) return -1;
        if (first) {
            first = 0;
            if (strncmp(line, "HTTP/1.", 7) != 0 || (line[7] != '0' && line[7] != '1') || line[8] != ' ') return -2;
            if (strncmp(line + 9, "101", 3) != 0 || (line[12] != ' ' && line[12] != 0)) {
                PJ_LOG(3, (ws->base.obj_name, "WebSocket upgrade refused: %.60s", line));
                return -3;
            }
        } else if (line[0]) {
            colon = strchr(line, ':');
            if (!colon) return -4;
            *colon = 0;
            name = line;
            val = colon + 1;
            while (*val == ' ' || *val == '\t') val++;
            {   /* trim trailing blanks of value */
                size_t vl = strlen(val);
                while (vl > 0 && (val[vl - 1] == ' ' || val[vl - 1] == '\t')) val[--vl] = 0;
            }
            if (spc_strieq(name, "upgrade")) {
                if (spc_strieq(val, "websocket")) got_upgrade = 1;
            } else if (spc_strieq(name, "connection")) {
                if (has_token(val, "upgrade")) got_conn = 1;
            } else if (spc_strieq(name, "sec-websocket-accept")) {
                if (strcmp(val, ws->accept_exp) == 0) got_accept = 1;
            } else if (spc_strieq(name, "sec-websocket-protocol")) {
                if (!has_token(val, "sip")) return -5;
            } else if (spc_strieq(name, "sec-websocket-extensions")) {
                return -6;                           /* none requested */
            }
        }
        line = eol ? eol + 2 : NULL;
    }
    return (got_upgrade && got_conn && got_accept) ? 0 : -7;
}

/* ------------------------------------------------------------------ */
/* receive path                                                        */
/* ------------------------------------------------------------------ */
static int only_crlf(const unsigned char* p, size_t n)
{
    size_t i;
    for (i = 0; i < n; i++) if (p[i] != '\r' && p[i] != '\n') return 0;
    return 1;
}

static void deliver_msg(ws_tp* ws)
{
    pjsip_rx_data* rd = &ws->rdata;
    if (ws->msglen == 0 || only_crlf((const unsigned char*)rd->pkt_info.packet, ws->msglen)) return;
    if (ws->msglen < PJSIP_MAX_PKT_LEN) rd->pkt_info.packet[ws->msglen] = 0;
    rd->pkt_info.len = (pj_ssize_t)ws->msglen;
    rd->pkt_info.zero = 0;
    pj_gettimeofday(&rd->pkt_info.timestamp);
    pjsip_tpmgr_receive_packet(ws->base.tpmgr, rd);
    pj_pool_reset(rd->tp_info.pool);
}

static pj_bool_t handle_frame(ws_tp* ws, int fin, int op, const unsigned char* pl, size_t len)
{
    if (op >= OP_CLOSE) {
        if (op == OP_PING) { send_ctl(ws, OP_PONG, pl, len); return PJ_TRUE; }
        if (op == OP_PONG) return PJ_TRUE;
        if (op == OP_CLOSE) {
            unsigned code = len >= 2 ? (unsigned)((pl[0] << 8) | pl[1]) : 1005;
            if (len == 1) return ws_fail(ws, 1002, "bad close payload", PJ_EINVALIDOP);
            PJ_LOG(4, (ws->base.obj_name, "WebSocket closed by peer (%u)", code));
            if (!ws->close_sent) send_close(ws, len >= 2 ? 1000 : 1000, NULL);
            ws_init_shutdown(ws, PJ_EEOF);
            return PJ_FALSE;
        }
        return ws_fail(ws, 1002, "unknown control opcode", PJ_EINVALIDOP);
    }
    if (op == OP_CONT) {
        if (!ws->frag_op) return ws_fail(ws, 1002, "unexpected continuation", PJ_EINVALIDOP);
    } else {
        if (ws->frag_op) return ws_fail(ws, 1002, "new message inside fragmented message", PJ_EINVALIDOP);
        ws->frag_op = op;
        ws->msglen = 0;
    }
    if (len > WS_MAX_MSG - ws->msglen) return ws_fail(ws, 1009, "message too big", PJ_ETOOBIG);
    if (len) memcpy(ws->rdata.pkt_info.packet + ws->msglen, pl, len);
    ws->msglen += len;
    if (fin) {
        deliver_msg(ws);
        ws->frag_op = 0;
        ws->msglen = 0;
        if (ws->base.is_shutdown || ws->base.is_destroying) return PJ_FALSE;
    }
    return PJ_TRUE;
}

/* Returns PJ_FALSE when the transport has been torn down. *remainder = bytes kept at buffer start. */
static pj_bool_t ws_rx(ws_tp* ws, unsigned char* data, size_t size, pj_size_t* remainder)
{
    size_t pos = 0;
    *remainder = 0;
    pj_gettickcount(&ws->last_rx);

    if (ws->state == ST_UPGRADE) {
        size_t i, end = 0;
        char hdr[WS_MAX_HTTP_HDR + 1];
        for (i = 0; i + 3 < size; i++)
            if (data[i] == '\r' && data[i + 1] == '\n' && data[i + 2] == '\r' && data[i + 3] == '\n') { end = i; break; }
        if (!end) {
            if (size >= WS_MAX_HTTP_HDR) return ws_fail(ws, 1002, "upgrade response too large", PJ_ETOOBIG);
            *remainder = size;
            return PJ_TRUE;
        }
        if (end > WS_MAX_HTTP_HDR) return ws_fail(ws, 1002, "upgrade response too large", PJ_ETOOBIG);
        memcpy(hdr, data, end);
        hdr[end] = 0;
        if (check_upgrade_response(ws, hdr) != 0) {
            PJ_LOG(3, (ws->base.obj_name, "WebSocket upgrade response invalid"));
            ws_init_shutdown(ws, PJSIP_ERRNO_FROM_SIP_STATUS(502));
            return PJ_FALSE;
        }
        pos = end + 4;
        if (!ws_opened(ws)) {
            ws_init_shutdown(ws, ws->close_reason ? ws->close_reason : PJSIP_TLS_ECERTVERIF);
            return PJ_FALSE;
        }
    }

    while (size - pos >= 2) {
        const unsigned char* f = data + pos;
        int fin = (f[0] & 0x80) != 0, rsv = f[0] & 0x70, op = f[0] & 0x0f, masked = (f[1] & 0x80) != 0;
        uint64_t len = f[1] & 0x7f;
        size_t hl = 2;
        if (rsv) return ws_fail(ws, 1002, "RSV bits set", PJ_EINVALIDOP);
        if (masked) return ws_fail(ws, 1002, "masked server frame", PJ_EINVALIDOP);
        if (len == 126) {
            if (size - pos < 4) break;
            len = (uint64_t)((f[2] << 8) | f[3]);
            hl = 4;
        } else if (len == 127) {
            int k;
            if (size - pos < 10) break;
            len = 0;
            for (k = 0; k < 8; k++) len = (len << 8) | f[2 + k];
            if (len >> 63) return ws_fail(ws, 1002, "bad length", PJ_EINVALIDOP);
            hl = 10;
        }
        if (op >= 8) {
            if (!fin || len > 125) return ws_fail(ws, 1002, "bad control frame", PJ_EINVALIDOP);
        } else if (op > 2) {
            return ws_fail(ws, 1002, "unknown opcode", PJ_EINVALIDOP);
        }
        if (len > WS_MAX_MSG) return ws_fail(ws, 1009, "frame too big", PJ_ETOOBIG);
        if (size - pos < hl + (size_t)len) break;                /* wait for the rest */
        if (!handle_frame(ws, fin, op, f + hl, (size_t)len)) return PJ_FALSE;
        pos += hl + (size_t)len;
    }
    if (pos < size) {
        *remainder = size - pos;
        if (pos > 0) memmove(data, data + pos, *remainder);
    }
    return PJ_TRUE;
}

static pj_bool_t ws_read_cb(ws_tp* ws, void* data, pj_size_t size, pj_status_t status, pj_size_t* remainder)
{
    if (ws->is_closing) { ws->is_closing++; return PJ_FALSE; }
    if (status != PJ_SUCCESS) {
        PJ_LOG(4, (ws->base.obj_name, "WebSocket connection closed"));
        ws_init_shutdown(ws, status);
        return PJ_FALSE;
    }
    return ws_rx(ws, (unsigned char*)data, size, remainder);
}

static pj_bool_t on_data_read(pj_activesock_t* a, void* data, pj_size_t size, pj_status_t status, pj_size_t* rem)
{
    return ws_read_cb((ws_tp*)pj_activesock_get_user_data(a), data, size, status, rem);
}
static pj_bool_t on_data_sent(pj_activesock_t* a, pj_ioqueue_op_key_t* k, pj_ssize_t sent)
{
    return ws_on_sent((ws_tp*)pj_activesock_get_user_data(a), k, sent);
}
static pj_bool_t ssl_on_data_read(pj_ssl_sock_t* s, void* data, pj_size_t size, pj_status_t status, pj_size_t* rem)
{
    return ws_read_cb((ws_tp*)pj_ssl_sock_get_user_data(s), data, size, status, rem);
}
static pj_bool_t ssl_on_data_sent(pj_ssl_sock_t* s, pj_ioqueue_op_key_t* k, pj_ssize_t sent)
{
    return ws_on_sent((ws_tp*)pj_ssl_sock_get_user_data(s), k, sent);
}

static void init_rdata(ws_tp* ws)
{
    pj_pool_t* pool = pjsip_endpt_create_pool(ws->base.endpt, "rtd%p", PJSIP_POOL_RDATA_LEN, PJSIP_POOL_RDATA_INC);
    pj_sockaddr* ra = &ws->base.key.rem_addr;
    ws->rdata.tp_info.pool = pool;
    ws->rdata.tp_info.transport = &ws->base;
    ws->rdata.tp_info.tp_data = ws;
    ws->rdata.tp_info.op_key.rdata = &ws->rdata;
    pj_ioqueue_op_key_init(&ws->rdata.tp_info.op_key.op_key, sizeof(pj_ioqueue_op_key_t));
    ws->rdata.pkt_info.src_addr = *ra;
    ws->rdata.pkt_info.src_addr_len = sizeof(ws->rdata.pkt_info.src_addr);
    pj_sockaddr_print(ra, ws->rdata.pkt_info.src_name, sizeof(ws->rdata.pkt_info.src_name), 0);
    ws->rdata.pkt_info.src_port = pj_sockaddr_get_port(ra);
}

static pj_status_t start_read(ws_tp* ws)
{
    pj_status_t st;
    if (!ws->rdata.tp_info.pool) {
        init_rdata(ws);
        if (!ws->rdata.tp_info.pool) return PJ_ENOMEM;
    }
    if (ws->is_wss) {
        st = pj_ssl_sock_start_read(ws->ssock, ws->base.pool, WS_RXBUF, 0);
    } else {
        void* rb[1];
        ws->rxbuf = (unsigned char*)pj_pool_alloc(ws->base.pool, WS_RXBUF);
        rb[0] = ws->rxbuf;
        st = pj_activesock_start_read2(ws->asock, ws->base.pool, WS_RXBUF, rb, 0);
    }
    return (st == PJ_SUCCESS || st == PJ_EPENDING) ? PJ_SUCCESS : st;
}

/* TCP (ws) or TCP+TLS (wss) established: begin the HTTP upgrade */
static pj_bool_t connected_common(ws_tp* ws, pj_status_t status)
{
    if (status == PJ_SUCCESS && (ws->base.is_shutdown || ws->base.is_destroying)) status = PJ_ECANCELLED;
    if (status != PJ_SUCCESS) {
        PJ_PERROR(4, (ws->base.obj_name, status, "%s connect() error", ws->is_wss ? "WSS" : "WS"));
        cancel_delayed(ws, status);
        ws_init_shutdown(ws, status);
        return PJ_FALSE;
    }
    if (!ws->is_wss) {
        pj_sockaddr a;
        int al = sizeof(a);
        if (pj_sock_getsockname(ws->sock, &a, &al) == PJ_SUCCESS && pj_sockaddr_has_addr(&a))
            pj_sockaddr_cp(&ws->base.local_addr, &a);
    }
    status = start_read(ws);
    if (status == PJ_SUCCESS) status = send_upgrade(ws);
    if (status != PJ_SUCCESS) {
        cancel_delayed(ws, status);
        ws_init_shutdown(ws, status);
        return PJ_FALSE;
    }
    return PJ_TRUE;
}

static pj_bool_t on_connect_complete(pj_activesock_t* a, pj_status_t status)
{
    return connected_common((ws_tp*)pj_activesock_get_user_data(a), status);
}
static pj_bool_t ssl_on_connect_complete(pj_ssl_sock_t* s, pj_status_t status)
{
    return connected_common((ws_tp*)pj_ssl_sock_get_user_data(s), status);
}

/* ------------------------------------------------------------------ */
/* transport creation                                                  */
/* ------------------------------------------------------------------ */
static pj_status_t ws_create(ws_factory* lf, pj_pool_t* pool, const pj_sockaddr* local, const pj_sockaddr* remote,
                             const pj_str_t* remote_name, pj_grp_lock_t* glock, ws_tp** p_ws, pj_sock_t sock)
{
    ws_tp* ws;
    pj_status_t status;
    char pa[PJ_INET6_ADDRSTRLEN + 10];
    int port = pj_sockaddr_get_port(remote);
    char hostbuf[128];
    int def_port = lf->is_wss ? 443 : 80;

    ws = PJ_POOL_ZALLOC_T(pool, ws_tp);
    ws->is_wss = lf->is_wss;
    ws->sock = sock;
    pj_list_init(&ws->delayed_list);
    ws->base.pool = pool;
    pj_ansi_snprintf(ws->base.obj_name, PJ_MAX_OBJ_NAME, lf->is_wss ? "wssc%p" : "wsc%p", ws);

    status = pj_atomic_create(pool, 0, &ws->base.ref_cnt);
    if (status != PJ_SUCCESS) goto on_error;
    status = pj_lock_create_recursive_mutex(pool, "ws", &ws->base.lock);
    if (status != PJ_SUCCESS) goto on_error;

    ws->base.key.type = lf->factory.type;
    pj_sockaddr_cp(&ws->base.key.rem_addr, remote);
    ws->base.type_name = (char*)pjsip_transport_get_type_name((pjsip_transport_type_e)ws->base.key.type);
    ws->base.flag = pjsip_transport_get_flag_from_type((pjsip_transport_type_e)ws->base.key.type);
    ws->base.info = (char*)pj_pool_alloc(pool, 64);
    pj_ansi_snprintf(ws->base.info, 64, "%s to %s", ws->base.type_name, pj_sockaddr_print(remote, pa, sizeof(pa), 3));
    ws->base.addr_len = pj_sockaddr_get_len(remote);
    pj_sockaddr_cp(&ws->base.local_addr, local);
    /* RFC 7118 5: the Via sent-by / Contact host is a random ".invalid" name */
    ws->base.has_addr_name = PJ_TRUE;
    ws->base.local_name = lf->factory.addr_name;
    ws->base.dir = PJSIP_TP_DIR_OUTGOING;

    /* remote_name: hostname from the SIP URI when known, else the IP */
    if (remote_name && remote_name->slen > 0 && remote_name->slen < (pj_ssize_t)sizeof(hostbuf)) {
        memcpy(hostbuf, remote_name->ptr, (size_t)remote_name->slen);
        hostbuf[remote_name->slen] = 0;
        pj_strdup2_with_null(pool, &ws->remote_host, hostbuf);
        ws->base.remote_name.host = ws->remote_host;
        ws->base.remote_name.port = (unsigned)port;
    } else {
        sockaddr_to_host_port(pool, &ws->base.remote_name, remote);
        pj_strdup_with_null(pool, &ws->remote_host, &ws->base.remote_name.host);
        pj_sockaddr_print(remote, hostbuf, sizeof(hostbuf), 2);
    }
    {   /* Host header; IPv6 literals need brackets */
        const char* hn = hostbuf;
        char tmp[140];
        if (remote_name && remote_name->slen > 0 && strchr(hostbuf, ':') && hostbuf[0] != '[') {
            snprintf(tmp, sizeof(tmp), "[%s]", hostbuf);
            hn = tmp;
        }
        if (port == def_port) snprintf(ws->host_hdr, sizeof(ws->host_hdr), "%s", hn);
        else snprintf(ws->host_hdr, sizeof(ws->host_hdr), "%s:%d", hn, port);
    }
    route_lookup(hostbuf, port, lf->is_wss, ws->path, sizeof(ws->path));

    ws->base.endpt = lf->endpt;
    ws->base.tpmgr = lf->tpmgr;
    ws->base.send_msg = &ws_send_msg;
    ws->base.do_shutdown = &ws_shutdown;
    ws->base.destroy = &ws_destroy_transport;
    ws->base.factory = &lf->factory;

    if (glock) {
        ws->grp_lock = glock;
        pj_grp_lock_add_ref(glock);
        pj_grp_lock_add_handler(glock, pool, ws, &ws_on_destroy);
    } else {
        status = pj_grp_lock_create_w_handler(pool, NULL, ws, &ws_on_destroy, &ws->grp_lock);
        if (status != PJ_SUCCESS) goto on_error;
        pj_grp_lock_add_ref(ws->grp_lock);
    }
    ws->base.grp_lock = ws->grp_lock;

    ws->ka_timer.user_data = ws;
    ws->ka_timer.cb = &ws_ka_timer;
    ws->has_pending_connect = PJ_TRUE;
    ws->state = ST_CONNECTING;

    *p_ws = ws;
    return PJ_SUCCESS;

on_error:
    if (ws->grp_lock && pj_grp_lock_get_ref(ws->grp_lock)) ws_destroy(&ws->base, status);
    else ws_on_destroy(ws);
    return status;
}

static pj_status_t lis_create_transport(pjsip_tpfactory* factory, pjsip_tpmgr* mgr, pjsip_endpoint* endpt,
                                        const pj_sockaddr* rem_addr, int addr_len, pjsip_tx_data* tdata,
                                        pjsip_transport** p_transport)
{
    ws_factory* lf = (ws_factory*)factory;
    ws_tp* ws = NULL;
    pj_pool_t* pool;
    pj_sockaddr local;
    pj_str_t rname;
    pj_status_t status;

    PJ_ASSERT_RETURN(factory && mgr && endpt && rem_addr && addr_len && p_transport, PJ_EINVAL);
    PJ_ASSERT_RETURN((rem_addr->addr.sa_family == pj_AF_INET() && addr_len == sizeof(pj_sockaddr_in)) ||
                     (rem_addr->addr.sa_family == pj_AF_INET6() && addr_len == sizeof(pj_sockaddr_in6)), PJ_EINVAL);

    if (tdata) rname = tdata->dest_info.name; else pj_bzero(&rname, sizeof(rname));
    {   /* Connection aliasing (RFC 5923 spirit): a WebSocket client talks to its server over the connection it
         * opened. The server's Contact / Record-Route often name an address we never connected to (container,
         * private or load-balancer address). For a destination that is not a server configured on any ws/wss
         * account, reuse the newest open connection of this type instead of dialing a new one. */
        char hk[128], dummy[8];
        ws_tp* ex;
        if (rname.slen > 0 && rname.slen < (pj_ssize_t)sizeof(hk)) { memcpy(hk, rname.ptr, (size_t)rname.slen); hk[rname.slen] = 0; }
        else pj_sockaddr_print(rem_addr, hk, sizeof(hk), 0);
        int port = pj_sockaddr_get_port(rem_addr);
        int known = route_lookup(hk, port, lf->is_wss, dummy, sizeof(dummy));
        /* configured server whose connection is already open (the resolved address is stale): that connection;
         * unknown destination: the newest open connection */
        ex = open_find(lf->factory.type, known ? hk : NULL, port);
        if (ex) {
            PJ_LOG(4, (ex->base.obj_name, "%s destination %s:%d: reusing the open connection to %s",
                       lf->is_wss ? "WSS" : "WS", hk, port, ex->host_hdr));
            *p_transport = &ex->base;
            return PJ_SUCCESS;
        }
    }
    pool = pjsip_endpt_create_pool(endpt, lf->is_wss ? "wss" : "ws", 2048, 2048);
    PJ_ASSERT_RETURN(pool, PJ_ENOMEM);
    pj_sockaddr_init(rem_addr->addr.sa_family, &local, NULL, 0);

    if (!lf->is_wss) {
        pj_sock_t sock;
        pj_activesock_cfg acfg;
        pj_activesock_cb cb;
        pj_grp_lock_t* gl;

        status = pj_sock_socket(rem_addr->addr.sa_family, pj_SOCK_STREAM() | pj_SOCK_CLOEXEC(), 0, &sock);
        if (status != PJ_SUCCESS) { pj_pool_release(pool); return status; }
        status = pj_sock_bind(sock, &local, pj_sockaddr_get_len(&local));
        if (status != PJ_SUCCESS) { pj_sock_close(sock); pj_pool_release(pool); return status; }
        {
            int ll = sizeof(local);
            pj_sockaddr_init(rem_addr->addr.sa_family, &local, NULL, 0);
            pj_sock_getsockname(sock, &local, &ll);
        }
        status = ws_create(lf, pool, &local, rem_addr, &rname, NULL, &ws, sock);
        if (status != PJ_SUCCESS) { pj_sock_close(sock); return status; }
        gl = ws->grp_lock;
        pj_activesock_cfg_default(&acfg);
        acfg.async_cnt = 1;
        acfg.grp_lock = gl;
        pj_bzero(&cb, sizeof(cb));
        cb.on_data_read = &on_data_read;
        cb.on_data_sent = &on_data_sent;
        cb.on_connect_complete = &on_connect_complete;
        status = pj_activesock_create(pool, sock, pj_SOCK_STREAM(), &acfg, pjsip_endpt_get_ioqueue(endpt), &cb, ws, &ws->asock);
        if (status != PJ_SUCCESS) { ws->sock = PJ_INVALID_SOCKET; pj_sock_close(sock); ws_destroy(&ws->base, status); return status; }
        status = pjsip_transport_register(lf->tpmgr, &ws->base);
        if (status != PJ_SUCCESS) { ws_destroy(&ws->base, status); return status; }
        ws->is_registered = PJ_TRUE;
        status = pj_activesock_start_connect(ws->asock, ws->base.pool, rem_addr, addr_len);
        if (status == PJ_SUCCESS) on_connect_complete(ws->asock, PJ_SUCCESS);
        else if (status != PJ_EPENDING) { ws_destroy(&ws->base, status); return status; }
    } else {
        pj_ssl_sock_param sp;
        pj_grp_lock_t* gl;
        pj_ssl_sock_t* ssock;

        status = pj_grp_lock_create(pool, NULL, &gl);
        if (status != PJ_SUCCESS) { pj_pool_release(pool); return status; }
        pj_ssl_sock_param_default(&sp);
        sp.sock_af = rem_addr->addr.sa_family;
        sp.cb.on_connect_complete = &ssl_on_connect_complete;
        sp.cb.on_data_read = &ssl_on_data_read;
        sp.cb.on_data_sent = &ssl_on_data_sent;
        sp.async_cnt = 1;
        sp.ioqueue = pjsip_endpt_get_ioqueue(endpt);
        sp.timer_heap = pjsip_endpt_get_timer_heap(endpt);
        sp.server_name = rname;
        sp.timeout = lf->tls.timeout;
        sp.user_data = NULL;
        sp.verify_peer = PJ_FALSE;          /* policy (verifyServer / pins) is applied by spc_tls.c on the state callback */
        if (sp.send_buffer_size < WS_RXBUF) sp.send_buffer_size = WS_RXBUF;
        if (sp.read_buffer_size < WS_RXBUF) sp.read_buffer_size = WS_RXBUF;
        sp.ciphers_num = lf->tls.ciphers_num;
        sp.ciphers = lf->tls.ciphers;
        sp.curves_num = lf->tls.curves_num;
        sp.curves = lf->tls.curves;
        sp.sigalgs = lf->tls.sigalgs;
        sp.entropy_type = lf->tls.entropy_type;
        sp.entropy_path = lf->tls.entropy_path;
        sp.proto = lf->tls.proto ? lf->tls.proto : (PJ_SSL_SOCK_PROTO_TLS1_2 | PJ_SSL_SOCK_PROTO_TLS1_3);
        sp.grp_lock = gl;
        status = pj_ssl_sock_create(pool, &sp, &ssock);
        if (status != PJ_SUCCESS) { pj_grp_lock_destroy(gl); pj_pool_release(pool); return status; }
        if (lf->cert) {
            status = pj_ssl_sock_set_certificate(ssock, pool, lf->cert);
            if (status != PJ_SUCCESS) { pj_ssl_sock_close(ssock); pj_pool_release(pool); return status; }
        }
        status = ws_create(lf, pool, &local, rem_addr, &rname, gl, &ws, PJ_INVALID_SOCKET);
        if (status != PJ_SUCCESS) { pj_ssl_sock_close(ssock); return status; }
        ws->ssock = ssock;
        pj_ssl_sock_set_user_data(ssock, ws);
        status = pjsip_transport_register(lf->tpmgr, &ws->base);
        if (status != PJ_SUCCESS) { ws_destroy(&ws->base, status); return status; }
        ws->is_registered = PJ_TRUE;
        status = pj_ssl_sock_start_connect(ssock, ws->base.pool, &local, rem_addr, addr_len);
        if (status == PJ_SUCCESS) ssl_on_connect_complete(ssock, PJ_SUCCESS);
        else if (status != PJ_EPENDING) { ws_destroy(&ws->base, status); return status; }
    }

    PJ_LOG(4, (ws->base.obj_name, "%s transport connecting to %s%s", lf->is_wss ? "WSS" : "WS", ws->host_hdr, ws->path));
    *p_transport = &ws->base;
    return PJ_SUCCESS;
}

/* ------------------------------------------------------------------ */
/* Remote-target fix-up                                                */
/* ------------------------------------------------------------------ */
/* A WebSocket client can only reach its server over the connection it opened. The Contact the server puts in
 * dialog-forming messages usually names an address that is private, unresolvable or load-balanced. When such a
 * message arrives on a ws/wss connection without Record-Route, point the (remote target) Contact at the
 * connection's peer, so in-dialog requests (ACK, BYE, re-INVITE, ...) go back over the same connection. */
static int method_has_target(const pjsip_method* m)
{
    static const char* const names[] = { "INVITE", "UPDATE", "SUBSCRIBE", "NOTIFY", "REFER", NULL };
    int i;
    for (i = 0; names[i]; i++) if (pj_stricmp2(&m->name, names[i]) == 0) return 1;
    return 0;
}

static pj_bool_t fixup_rx(pjsip_rx_data* rdata)
{
    pjsip_transport* tp = rdata->tp_info.transport;
    pjsip_msg* msg = rdata->msg_info.msg;
    pjsip_contact_hdr* ch;
    pjsip_sip_uri* uri;
    ws_tp* ws;
    if (!tp || !msg || (tp->destroy != &ws_destroy_transport)) return PJ_FALSE;
    ws = (ws_tp*)tp;
    if (msg->type == PJSIP_REQUEST_MSG) {
        if (!method_has_target(&msg->line.req.method)) return PJ_FALSE;
    } else {
        int c = msg->line.status.code;
        if (c < 101 || c > 299 || !rdata->msg_info.cseq || !method_has_target(&rdata->msg_info.cseq->method)) return PJ_FALSE;
    }
    if (pjsip_msg_find_hdr(msg, PJSIP_H_RECORD_ROUTE, NULL)) return PJ_FALSE;
    ch = (pjsip_contact_hdr*)pjsip_msg_find_hdr(msg, PJSIP_H_CONTACT, NULL);
    if (!ch || ch->star || !ch->uri) return PJ_FALSE;
    {
        pjsip_uri* u = (pjsip_uri*)pjsip_uri_get_uri(ch->uri);
        if (!PJSIP_URI_SCHEME_IS_SIP(u) && !PJSIP_URI_SCHEME_IS_SIPS(u)) return PJ_FALSE;
        uri = (pjsip_sip_uri*)u;
    }
    pj_strdup(rdata->tp_info.pool, &uri->host, &ws->base.remote_name.host);
    uri->port = (int)ws->base.remote_name.port;
    /* the peer is only reachable over this very connection type (Asterisk, for one, advertises transport=ws on WSS) */
    pj_strdup2(rdata->tp_info.pool, &uri->transport_param, ws->is_wss ? "wss" : "ws");
    return PJ_FALSE;                          /* keep processing */
}

static pj_bool_t mod_rx_request(pjsip_rx_data* rdata) { return fixup_rx(rdata); }
static pj_bool_t mod_rx_response(pjsip_rx_data* rdata) { return fixup_rx(rdata); }

static pjsip_module g_fixup_mod = {
    NULL, NULL,
    { "mod-spc-ws", 10 }, -1,
    PJSIP_MOD_PRIORITY_TRANSPORT_LAYER + 1,
    NULL, NULL, NULL, NULL,
    &mod_rx_request, &mod_rx_response,
    NULL, NULL, NULL
};

/* ------------------------------------------------------------------ */
/* factories                                                           */
/* ------------------------------------------------------------------ */
static pj_status_t lis_destroy(pjsip_tpfactory* factory)
{
    ws_factory* lf = (ws_factory*)factory;
    if (lf->is_registered) {
        pjsip_tpmgr_unregister_tpfactory(lf->tpmgr, &lf->factory);
        lf->is_registered = PJ_FALSE;
    }
    if (lf->factory.lock) { pj_lock_destroy(lf->factory.lock); lf->factory.lock = NULL; }
    if (lf->factory.pool) {
        pj_pool_t* p = lf->factory.pool;
        lf->factory.pool = NULL;
        pj_pool_release(p);
    }
    return PJ_SUCCESS;
}

static int start_factory(int wss, int v6, const char* invalid_host)
{
    pjsip_endpoint* endpt = pjsua_get_pjsip_endpt();
    pj_pool_t* pool;
    ws_factory* lf;
    pj_status_t st;
    int af = v6 ? pj_AF_INET6() : pj_AF_INET();

    pool = pjsip_endpt_create_pool(endpt, wss ? "wssf" : "wsf", 1024, 1024);
    if (!pool) return -1;
    lf = PJ_POOL_ZALLOC_T(pool, ws_factory);
    lf->factory.pool = pool;
    lf->endpt = endpt;
    lf->tpmgr = pjsip_endpt_get_tpmgr(endpt);
    lf->is_wss = wss;
    lf->is_v6 = v6;
    lf->factory.type = (pjsip_transport_type_e)g_types[wss][v6];
    lf->factory.type_name = (char*)pjsip_transport_get_type_name(lf->factory.type);
    lf->factory.flag = pjsip_transport_get_flag_from_type(lf->factory.type);
    pj_ansi_snprintf(lf->factory.obj_name, sizeof(lf->factory.obj_name), "%s%s", wss ? "wss" : "ws", v6 ? "6" : "");
    st = pj_lock_create_recursive_mutex(pool, lf->factory.obj_name, &lf->factory.lock);
    if (st != PJ_SUCCESS) goto fail;

    pj_sockaddr_init(af, &lf->factory.local_addr, NULL, 0);
    lf->factory.has_addr_name = PJ_TRUE;
    pj_strdup2_with_null(pool, &lf->factory.addr_name.host, invalid_host);
    lf->factory.addr_name.port = 0;
    lf->factory.create_transport2 = &lis_create_transport;
    lf->factory.destroy = &lis_destroy;

    if (wss) {
        spc_tls_cfg(&lf->tls, G.tls_verify, NULL, NULL, NULL, NULL);
        if (lf->tls.cert_file.slen || lf->tls.ca_list_file.slen || lf->tls.ca_list_path.slen || lf->tls.privkey_file.slen) {
            st = pj_ssl_cert_load_from_files2(pool, &lf->tls.ca_list_file, &lf->tls.ca_list_path, &lf->tls.cert_file,
                                              &lf->tls.privkey_file, &lf->tls.password, &lf->cert);
            if (st != PJ_SUCCESS) {
                PJ_PERROR(2, (THIS_FILE, st, "WSS: cannot load TLS credentials"));
                if (lf->tls.cert_file.slen || lf->tls.privkey_file.slen) goto fail;   /* explicit client cert/key: hard error */
            }
        }
    }
    lf->is_registered = PJ_TRUE;
    st = pjsip_tpmgr_register_tpfactory(lf->tpmgr, &lf->factory);
    if (st != PJ_SUCCESS) { lf->is_registered = PJ_FALSE; goto fail; }
    return 0;
fail:
    lis_destroy(&lf->factory);
    return -1;
}

int spc_ws_start(void)
{
    char host[40];
    int ok = 0;
    if (!g_types_registered) {
        int w, v;
        for (w = 0; w < 2; w++) {
            for (v = 0; v < 2; v++) {
                unsigned fl = PJSIP_TRANSPORT_RELIABLE | (w ? PJSIP_TRANSPORT_SECURE : 0) | (v ? PJSIP_TRANSPORT_IPV6 : 0);
                int t = 0;
                if (pjsip_transport_register_type(fl, w ? "WSS" : "WS", w ? 443 : 80, &t) != PJ_SUCCESS) return -1;
                g_types[w][v] = t;
            }
        }
        g_types_registered = 1;
    }
    {
        const char* e = getenv("SPC_WS_KA_SEC");
        g_ka_sec = (e && atoi(e) > 0 && atoi(e) <= 3600) ? atoi(e) : 30;
    }
    spc_ws_random_invalid_host(host, sizeof(host));
    g_fixup_mod.id = -1;                      /* module struct is reused across core.stop / core.start */
    g_fixup_mod.prev = g_fixup_mod.next = NULL;
    if (pjsip_endpt_register_module(pjsua_get_pjsip_endpt(), &g_fixup_mod) != PJ_SUCCESS) return -1;
    ok += start_factory(0, 0, host) == 0;
    ok += start_factory(1, 0, host) == 0;
    ok += start_factory(0, 1, host) == 0;
    ok += start_factory(1, 1, host) == 0;
    return ok == 4 ? 0 : -1;
}
