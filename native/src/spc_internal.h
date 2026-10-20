/* spcore internals shared by all modules. */
#ifndef SPC_INTERNAL_H
#define SPC_INTERNAL_H

#include <stdint.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>

#include <pjsua-lib/pjsua.h>
#include "cJSON.h"
#include "spcore.h"
#include "spc_port.h"

#define SPC_VERSION "1.0.0"
#define SPC_EVENT_RING_MAX 2000
#define SPC_MAX_CODECS 24
#define SPC_MAX_PEERS 32
#define SPC_ID_IAX_BASE 1000

/* ---- errors ---- */
enum {
    SPC_OK = 0,
    SPC_E_INVALID_PARAM,
    SPC_E_NOT_FOUND,
    SPC_E_NOT_STARTED,
    SPC_E_ALREADY,
    SPC_E_PJ_ERROR,
    SPC_E_TIMEOUT,
    SPC_E_UNSUPPORTED,
    SPC_E_BUSY,
    SPC_E_INTERNAL
};
const char* spc_err_name(int code);
/* Records an error for the current request (worker thread) and returns code. */
int spc_err(int code, pj_status_t status, const char* fmt, ...);
int spc_pjerr(pj_status_t status, const char* what);
pj_sock_t spc_udp_transport_socket(int id);
void spc_udp_set_dscp(int id, int dscp);

typedef int (*spc_handler)(cJSON* p, cJSON** res);
/* Defer the current request's response (handler returns SPC_OK with no result); complete it later from any thread. */
int64_t spc_defer_response(void);       /* returns the request id, 0 if it cannot be deferred */
void    spc_respond_deferred(int64_t id, int code, pj_status_t status, const char* msg, cJSON* result);
typedef struct { const char* name; spc_handler fn; int flags; } spc_method;
#define SPC_M_PRESTART 1

/* ---- json helpers (spc_json.c) ---- */
const char* spc_jstr(const cJSON* o, const char* k);
int         spc_jint(const cJSON* o, const char* k, int def);
double      spc_jnum(const cJSON* o, const char* k, double def);
int         spc_jbool(const cJSON* o, const char* k, int def);
int         spc_jhas(const cJSON* o, const char* k);
cJSON*      spc_jobj(const cJSON* o, const char* k);
cJSON*      spc_jarr(const cJSON* o, const char* k);
uint64_t    spc_ju64(const cJSON* o, const char* k);   /* 0 if missing */
void        spc_jadd_str(cJSON* o, const char* k, const char* s);   /* NULL -> null */
void        spc_jadd_pjstr(cJSON* o, const char* k, const pj_str_t* s);
void        spc_jadd_u64(cJSON* o, const char* k, uint64_t v);
cJSON*      spc_jpjstr(const pj_str_t* s);
char*       spc_json_print(const cJSON* o);          /* malloc'd, free with free() */
pj_str_t    spc_pjs(const char* s);                   /* no copy */
void        spc_pjcopy(char* dst, size_t n, const pj_str_t* s);
char*       spc_strdup(const char* s);
void        spc_strlcpy(char* dst, const char* src, size_t n);
int         spc_strieq(const char* a, const char* b);
int         spc_strnieq(const char* a, const char* b, size_t n);
/* parse: "Disp" <sip:user@host>;tag -> display, uri, user */
void        spc_parse_nameaddr(const char* s, char* disp, size_t dn, char* uri, size_t un, char* user, size_t usn);
cJSON*      spc_sockaddr_json_str(const pj_sockaddr* a);
/* msg_data from {"headers":{k:v}} into msg_data using pool */
void        spc_fill_msg_data(pj_pool_t* pool, pjsua_msg_data* md, const cJSON* headers);
cJSON*      spc_headers_from_rdata(pjsip_rx_data* rdata);
int         spc_hdr_name_ok(const char* n);      /* token chars only and not a core header (Via, From, ...) */
int         spc_hdr_value_ok(const char* v);     /* no CR/LF/NUL, <= 4 KB */
int         spc_str_clean(const char* s);        /* no control characters */
int         spc_validate_headers(const cJSON* headers, char* err, size_t en);   /* 1 ok */
uint64_t    spc_jnum_to_id(const cJSON* e);      /* positive integer < 2^53 or 0 */
int         spc_jint_range(const cJSON* o, const char* k, int def, int lo, int hi, int* out);   /* 0 if present but invalid */
int         spc_jbool_strict(const cJSON* o, const char* k, int* out);                        /* 0 if absent or not a bool */

/* ---- events / core (spc_core.c) ---- */
typedef struct spc_global {
    int inited;         /* spc_init called */
    int started;        /* core.start done */
    int shutting;
    /* sinks */
    spc_mutex_t emit_mtx;
    int64_t dart_port;
    void (*cb)(const char*, void*);
    void* cb_user;
    int dart_ok;
    char* ring[SPC_EVENT_RING_MAX];
    int ring_head, ring_count;
    int64_t seq;
    /* registry mutex: protects calls/accounts/buddies tables */
    spc_mutex_t reg_mtx;
    spc_mutex_t tg_mtx;            /* serialises inband-DTMF tonegen use vs destruction */
    /* queue */
    spc_mutex_t q_mtx;
    spc_cond_t q_cv;
    void* q_head; void* q_tail;
    int64_t next_req_id;
    int worker_quit;
    spc_thread_t worker;
    int worker_running;
    pj_pool_t* pool;               /* pjsua pool for engine lifetime */
    /* config */
    char user_agent[128];
    int  incoming_auto_ring_ms;
    int  incoming_unattended_ms;
    int  stats_interval_ms;
    int  max_calls;
    int  snd_manual;               /* sndMode manual */
    int  no_audio_device;
    int  log_forward;
    int  sip_trace;
    int  tls_verify;
    int  qos;
    int  sip_dscp;                 /* shared-transport SIP DSCP (transports.dscpSip) */
    int  rtp_port, rtp_port_range;
    int  ec_tail_ms;
    int  clock_rate;
    int  udp_tp, tcp_tp, tls_tp, udp6_tp, tcp6_tp, tls6_tp, lan_tp;
    int  direct_acc, lan_acc;
    int  ipv6;
    char nat_type_desc[64];
    char nat_type[24];
    char stun_server[128];
    char public_addr[64];         /* optional override for advertised SIP/RTP address (tests, split-horizon) */
    int64_t cid_counter;           /* never reset */
} spc_global;
extern spc_global G;

void   spc_emit(const char* event, cJSON* fields);     /* takes ownership of fields */
int    spc_sink_attached(void);
void   spc_registry_lock(void);
void   spc_registry_unlock(void);
void   spc_ensure_pj_thread(const char* name);

/* module method tables */
extern const spc_method spc_methods_core[];
extern const spc_method spc_methods_account[];
extern const spc_method spc_methods_call[];
extern const spc_method spc_methods_media[];
extern const spc_method spc_methods_presence[];
extern const spc_method spc_methods_diag[];
extern const spc_method spc_methods_denoise[];

/* ---- accounts (spc_account.c) ---- */
typedef struct spc_acc {
    struct spc_acc* next;          /* all-allocated list (freed at core.stop) */
    int acc;
    int proto;                     /* 0 sip, 1 iax2 */
    int used;
    char uid[96];
    int is_lan, is_direct;
    char reg_state[16];
    int reg_code;
    char reg_reason[96];
    char last_error[200];
    char presence[12];
    char presence_note[128];
    char transport[8];
    char domain[128];
    char dtmf_method[12];
    char user_agent[128];
    char caller_id[64];
    char display_name[64];
    int redirect;                  /* 0 auto 1 ask 2 reject */
    int refer_reject, watcher_reject;
    int srtp;
    int mwi;
    int privacy;
    int ncodecs;
    char codecs[SPC_MAX_CODECS][40];
    int own_tp;
    int expires_cfg;
    int tls_verify_failed;         /* last registration failed due to TLS cert */
    int auto_tr;                   /* configured transport is "auto" (SRV-selected) */
    unsigned auto_gen;             /* bumped on modify/remove/new resolution: invalidates in-flight SRV lookups */
    int auto_initial;              /* first resolution still pending: the resolver starts the registration */
    int auto_reg;                  /* registration was requested at add time */
    char resolved[160];            /* "host:port" of the chosen SRV target (auto transport), else "" */
    unsigned long own_sig;         /* signature of the dedicated transport's configuration (port, type, client cert) */
    cJSON* cfg;
} spc_acc;

spc_acc* spc_acc_from_id(int acc);              /* takes no lock; returns meta pointer or NULL (valid until core.stop) */
int      spc_acc_resolve(const cJSON* p, int* acc);   /* acc or uid -> pjsua id; handles -1 = direct */
cJSON*   spc_acc_info_json(int acc);
void     spc_account_install_callbacks(pjsua_callback* cb);
int      spc_account_init_special(int direct_tp, int lan_tp);
void     spc_account_cleanup(void);
void     spc_account_graceful_unregister(int max_ms);
int      spc_uri_normalize(int acc, const char* in, char* out, size_t outsz);
int      spc_acc_list_json(cJSON* arr);
void     spc_account_on_ip_change(void);

/* ---- calls (spc_call.c) ---- */
#define SPC_MAX_DIV 8
typedef struct { char uri[200], user[96], reason[40]; int counter; } spc_div;
typedef struct {                   /* caller identity from signalling headers (docs/ENGINE_API.md 9.5) */
    int pai_set, withheld;         /* asserted identity present / withheld by Privacy (not exposed) */
    char disp[96], user[96], uri[200];
    int ndiv; spc_div div[SPC_MAX_DIV];
    char ref_by[200];              /* Referred-By URI of the INVITE */
} spc_ident;
typedef struct spc_call {
    struct spc_call* next;
    uint64_t cid;
    int slot;
    int acc;
    char uid[96];
    int proto;
    int role;                      /* 0 caller, 1 callee */
    int ended;
    int responded;                 /* app answered/rang/rejected */
    int ring_sent;
    int incoming_emitted;
    uint64_t parent_cid;           /* spawned by REFER */
    char call_id[128];
    char referred_by[256];
    spc_ident ident;
    char local_tag[64], remote_tag[64];
    char last_media[12];
    char last_codec[48];
    int last_srtp;
    int last_secsig;               /* signalling over TLS/WSS/sips (sticky) */
    int muted, held, detached;
    int redirect_pending;
    int nconf; uint64_t conf[SPC_MAX_PEERS];
    int nbr;   uint64_t bridged[SPC_MAX_PEERS];
    int recording; int rec_id; int rec_mix; char rec_file[600]; int64_t rec_start_ms;
    int player_id;                 /* unused (players live in spc_player.c, keyed by cid) */
    int rec2_id, rec_fmt;          /* spc_rec.c recorder (wavStereo/opus), 0 = none; rec_fmt: 0 wav, 1 wavStereo, 2 opus */
    int ann_mute;                  /* announcement mute: a playing file asked to mute the mic towards this call (independent of `muted`) */
    int tg_slot; pjmedia_port* tg_port; pj_pool_t* tg_pool;
    void* dn_in; int dn_in_slot; int dn_closed;   /* incoming voice-isolation processor (spc_denoise.c); dn_closed: media cleaned up */
    void* iax;                     /* proto==1: unused by the registry (state lives in spc_iax2.c, keyed by cid) */
    int rx_set; float rx_level, tx_level;
    int64_t created_ms;
    int64_t next_stats_ms;
    char dtmf_method[12];
} spc_call;

spc_call* spc_call_find_locked(uint64_t cid);        /* registry lock must be held */
int       spc_call_cid_to_slot(uint64_t cid, int* slot, int* acc);   /* takes lock */
int       spc_call_alive(uint64_t cid);
void      spc_call_install_callbacks(pjsua_callback* cb);
cJSON*    spc_call_info_json(uint64_t cid);                          /* NULL if gone */
void      spc_call_apply_media_all(void);
int       spc_calls_active(void);
void      spc_call_cleanup_all(void);
void      spc_call_hangup_all_and_wait(int ms);
cJSON*    spc_call_stats_json(uint64_t cid, int* err);
void      spc_call_stats_tick(int64_t now_ms);
void      spc_call_emit(uint64_t cid, const char* ev, cJSON* f);     /* dropped if cid is gone */
void      spc_call_wait_gone(uint64_t cid, int ms);
void      spc_calls_list_json(cJSON* arr);
int       spc_account_filter_codecs_for(int acc, pjmedia_sdp_session* sdp);

/* call internals shared with spc_callreq.c */
spc_call* spc_call_lock_find(uint64_t cid);      /* returns with registry lock held if found, else unlocked NULL */
void      spc_call_apply_topology(void);
cJSON*    spc_call_levels_json(void);            /* [{cid, rx, tx}] for calls with active media */
int       spc_call_bed_sinks(int* out, int max); /* live conf slots the musicbed may feed: every call slot + its local-side recorder sinks */
#ifdef SPC_TEST_HOOKS
void      spc_call_test_topo_delay(int ms);      /* __topoDelay */
#endif
int       spc_call_mic_source(void);             /* conf slot every "microphone -> X" connection must use: 0, or the voice-isolation processor */
void      spc_call_cleanup_media(spc_call* c);   /* registry lock NOT held */
int       spc_lan_register_account(int tp, int* acc);
int       spc_call_media_audio_idx(const pjsua_call_info* ci);
void      spc_call_get_tags(int slot, char* l, size_t ln, char* r, size_t rn);
void      spc_call_schedule_timer(void (*cb)(void*), uint64_t cid, unsigned ms);
uint64_t  spc_call_cid_of_slot(int slot);
uint64_t  spc_call_ensure_slot(int slot);

/* ---- IAX2 (spc_iax2.c); acc ids and call slots >= SPC_ID_IAX_BASE ---- */
enum { SPC_IAXOP_ANSWER = 1, SPC_IAXOP_RING, SPC_IAXOP_REJECT, SPC_IAXOP_HANGUP, SPC_IAXOP_HOLD, SPC_IAXOP_UNHOLD,
       SPC_IAXOP_DTMF, SPC_IAXOP_TRANSFER, SPC_IAXOP_UNSUPPORTED };
int    spc_iax2_acc_valid(int acc);
int    spc_iax2_acc_find_uid(const char* uid, int* acc);
int    spc_iax2_account_add(cJSON* p, cJSON** res);
int    spc_iax2_account_modify(int acc, const cJSON* p);
int    spc_iax2_account_remove(int acc);
int    spc_iax2_account_register(int acc, int on);
int    spc_iax2_account_set_presence(int acc, const char* status, const char* note);
cJSON* spc_iax2_acc_info_json(int acc);
void   spc_iax2_acc_list_json(cJSON* arr);
void   spc_iax2_configure(const cJSON* iax);                  /* core.start "iax" object (may be NULL) */
int    spc_iax2_call_make(int acc, const cJSON* p, cJSON** res);
int    spc_iax2_call_op(int op, uint64_t cid, const cJSON* p, cJSON** res);
cJSON* spc_iax2_call_info_json(uint64_t cid);
cJSON* spc_iax2_call_stats_json(uint64_t cid, int* err);
int    spc_iax2_call_conf(uint64_t cid, int* conf_slot, int* active);   /* 0 ok, -1 unknown */
int    spc_call_is_iax(uint64_t cid);
int    spc_call_conf_slot(uint64_t cid, int slot);             /* conference slot of a call (SIP or IAX2), -1 if none */
void   spc_iax2_unregister_all(int max_ms);
void   spc_iax2_hangup_all(void);
void   spc_iax2_shutdown(void);
/* registry helpers for IAX2 calls (spc_call.c) */
spc_call* spc_call_iax_new(int slot, int acc, const char* uid, int role);
void      spc_call_iax_finish(spc_call* c, cJSON* terminal_state);   /* emits call.state, unlinks, frees; registry lock NOT held */

/* ---- media (spc_media.c) ---- */
int   spc_media_init(void);                 /* after pjsua_init, before start */
void  spc_media_started(void);              /* after pjsua_start */
void  spc_media_shutdown(void);
void  spc_media_on_call_media(int slot, int active);   /* ensure clock etc */
cJSON* spc_media_devices_json(void);
void  spc_media_on_snd_op(int op);
int   spc_media_ensure_clock(void);
pj_status_t spc_media_set_null_snd(void);
extern pj_pool_t* spc_media_pool;
int   spc_media_bridge_rate(void);
void  spc_port_destroy_release(pjmedia_port* port, pj_pool_t* pool);   /* destroy a (already removed) bridge port; pool is freed on its last reference */
const char* spc_media_snd_current(char* cap, size_t n, char* play, size_t m);
int   spc_media_snd_open(void);
int   spc_media_on_connect_error(pj_status_t st);
unsigned spc_ec_options(const char* algo, int ns, int agc, int* tail_zero);

/* ---- stats (spc_stats.c) ---- */
double spc_emodel_mos(const char* codec, double lossPct, double jitterMs, double rttMs, double jbDelayMs, double ptimeMs);

/* ---- presence (spc_presence.c) ---- */
void  spc_presence_install_callbacks(pjsua_callback* cb);
void  spc_presence_cleanup(void);
void  spc_presence_on_mwi(int acc, pjsip_rx_data* rdata);
cJSON* spc_buddy_list_json(void);

/* ---- trace (spc_trace.c) ---- */
int   spc_trace_init(void);
void  spc_trace_set(int enabled);
void  spc_trace_shutdown(void);

/* ---- tls (spc_tls.c) ---- */
void  spc_tls_on_transport_state(pjsip_transport* tp, pjsip_transport_state state, const pjsip_transport_state_info* info);
int   spc_tls_set_pins(const cJSON* pins);          /* 0 ok, -1 invalid entry (needs 64 hex chars) */
int   spc_tls_check_ca(int verify, const char* ca, char* err, size_t en);   /* 1 ok */
void  spc_tls_cfg(pjsip_tls_setting* st, int verify, const char* ca, const char* cert, const char* key, const char* minProto);
void  spc_tls_flag_failure(const char* host);
int   spc_tls_recent_failure(const char* host);
void  spc_tls_cleanup(void);
/* Validates a client certificate: both files readable, key decrypts with `password`, cert and key match.
 * 0 ok, -1 with a message in err. */
int   spc_tls_validate_client_cert(const char* cert, const char* key, const char* password, char* err, size_t en);

/* ---- dns (spc_dns.c) ---- */
int   spc_dns_detect(char servers[][64], int max);
int   spc_resolve_ipv4(const char* host, uint32_t* addr_be, int timeout_ms);   /* 0 ok; bounded, never blocks longer than timeout_ms */

/* ---- lan (spc_lan.c) ---- */
int   spc_lan_start(int port, cJSON* res);
void  spc_lan_stop(void);
void  spc_lan_on_find(const pjsip_rx_data* rdata, pjsua_acc_id* acc_id);
int   spc_presence_init_module(void);

/* ---- diag ---- */
void  spc_diag_install_callbacks(pjsua_callback* cb);
void  spc_diag_new_session(void);
/* heap tokens passed as pjsua user_data; freed by the completion callback, or in bulk at core.stop */
void* spc_token_new(size_t size);
void  spc_token_free(void* t);
void  spc_tokens_free_all(void);

/* sha256 */
void  spc_sha256_hex(const unsigned char* data, size_t len, char out[65]);
size_t spc_pem_to_der(const char* pem, size_t pemlen, unsigned char* out, size_t outmax);

/* log forwarding */
void  spc_log_cb(int level, const char* data, int len);

#endif
