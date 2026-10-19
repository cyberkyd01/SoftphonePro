/* spc_tls.c: TLS transport settings, certificate verification policy with pins, transport.state events, sha256. */
#include "spc_internal.h"
#include "spc_ws_transport.h"
#include <time.h>
#include <ctype.h>
#if defined(__APPLE__)
#  include <TargetConditionals.h>
#endif

/* ---- sha256 ---- */
typedef struct { uint32_t h[8]; uint64_t len; unsigned char buf[64]; size_t n; } sha_ctx;
static const uint32_t K[64] = {
0x428a2f98,0x71374491,0xb5c0fbcf,0xe9b5dba5,0x3956c25b,0x59f111f1,0x923f82a4,0xab1c5ed5,0xd807aa98,0x12835b01,0x243185be,0x550c7dc3,0x72be5d74,0x80deb1fe,0x9bdc06a7,0xc19bf174,
0xe49b69c1,0xefbe4786,0x0fc19dc6,0x240ca1cc,0x2de92c6f,0x4a7484aa,0x5cb0a9dc,0x76f988da,0x983e5152,0xa831c66d,0xb00327c8,0xbf597fc7,0xc6e00bf3,0xd5a79147,0x06ca6351,0x14292967,
0x27b70a85,0x2e1b2138,0x4d2c6dfc,0x53380d13,0x650a7354,0x766a0abb,0x81c2c92e,0x92722c85,0xa2bfe8a1,0xa81a664b,0xc24b8b70,0xc76c51a3,0xd192e819,0xd6990624,0xf40e3585,0x106aa070,
0x19a4c116,0x1e376c08,0x2748774c,0x34b0bcb5,0x391c0cb3,0x4ed8aa4a,0x5b9cca4f,0x682e6ff3,0x748f82ee,0x78a5636f,0x84c87814,0x8cc70208,0x90befffa,0xa4506ceb,0xbef9a3f7,0xc67178f2 };
#define ROR(x,n) (((x) >> (n)) | ((x) << (32 - (n))))
static void sha_block(sha_ctx* c, const unsigned char* p)
{
    uint32_t w[64], a, b, cc, d, e, f, g, h, t1, t2;
    int i;
    for (i = 0; i < 16; i++) w[i] = ((uint32_t)p[i*4] << 24) | ((uint32_t)p[i*4+1] << 16) | ((uint32_t)p[i*4+2] << 8) | p[i*4+3];
    for (i = 16; i < 64; i++) {
        uint32_t s0 = ROR(w[i-15], 7) ^ ROR(w[i-15], 18) ^ (w[i-15] >> 3);
        uint32_t s1 = ROR(w[i-2], 17) ^ ROR(w[i-2], 19) ^ (w[i-2] >> 10);
        w[i] = w[i-16] + s0 + w[i-7] + s1;
    }
    a = c->h[0]; b = c->h[1]; cc = c->h[2]; d = c->h[3]; e = c->h[4]; f = c->h[5]; g = c->h[6]; h = c->h[7];
    for (i = 0; i < 64; i++) {
        t1 = h + (ROR(e, 6) ^ ROR(e, 11) ^ ROR(e, 25)) + ((e & f) ^ (~e & g)) + K[i] + w[i];
        t2 = (ROR(a, 2) ^ ROR(a, 13) ^ ROR(a, 22)) + ((a & b) ^ (a & cc) ^ (b & cc));
        h = g; g = f; f = e; e = d + t1; d = cc; cc = b; b = a; a = t1 + t2;
    }
    c->h[0] += a; c->h[1] += b; c->h[2] += cc; c->h[3] += d; c->h[4] += e; c->h[5] += f; c->h[6] += g; c->h[7] += h;
}
void spc_sha256_hex(const unsigned char* data, size_t len, char out[65])
{
    sha_ctx c;
    size_t i;
    unsigned char pad[128];
    size_t padlen;
    uint64_t bits = (uint64_t)len * 8;
    static const char hx[] = "0123456789abcdef";
    c.h[0]=0x6a09e667; c.h[1]=0xbb67ae85; c.h[2]=0x3c6ef372; c.h[3]=0xa54ff53a; c.h[4]=0x510e527f; c.h[5]=0x9b05688c; c.h[6]=0x1f83d9ab; c.h[7]=0x5be0cd19;
    for (i = 0; i + 64 <= len; i += 64) sha_block(&c, data + i);
    c.n = len - i;
    memset(pad, 0, sizeof(pad));
    if (c.n) memcpy(pad, data + i, c.n);
    pad[c.n] = 0x80;
    padlen = (c.n < 56) ? 64 : 128;
    for (i = 0; i < 8; i++) pad[padlen - 1 - i] = (unsigned char)(bits >> (8 * i));
    sha_block(&c, pad);
    if (padlen == 128) sha_block(&c, pad + 64);
    for (i = 0; i < 8; i++) {
        int j;
        for (j = 0; j < 4; j++) {
            unsigned char b = (unsigned char)(c.h[i] >> (24 - 8 * j));
            out[(i*4+j)*2] = hx[b >> 4];
            out[(i*4+j)*2+1] = hx[b & 15];
        }
    }
    out[64] = 0;
}

size_t spc_pem_to_der(const char* pem, size_t pemlen, unsigned char* out, size_t outmax)
{
    size_t i, n = 0;
    uint32_t acc = 0;
    int bits = 0, in_body = 0;
    const char* line;
    (void)line;
    for (i = 0; i < pemlen; i++) {
        char ch = pem[i];
        if (ch == '-') {
            /* header/footer line */
            while (i < pemlen && pem[i] != '\n') i++;
            if (in_body) break;
            in_body = 1;
            continue;
        }
        if (!in_body) continue;
        {
            int v;
            if (ch >= 'A' && ch <= 'Z') v = ch - 'A';
            else if (ch >= 'a' && ch <= 'z') v = ch - 'a' + 26;
            else if (ch >= '0' && ch <= '9') v = ch - '0' + 52;
            else if (ch == '+') v = 62;
            else if (ch == '/') v = 63;
            else continue;
            acc = (acc << 6) | (uint32_t)v;
            bits += 6;
            if (bits >= 8) {
                bits -= 8;
                if (n < outmax) out[n++] = (unsigned char)((acc >> bits) & 0xFF);
            }
        }
    }
    return n;
}

/* ---- settings / pins ---- */
typedef struct { char host[128]; char sha[65]; } pin_t;
static pin_t g_pins[32];
static int g_npins;
static struct { char host[96]; int64_t t; } g_fail[8];
static int g_fail_pos;
static char s_ca[512], s_cert[512], s_key[512], s_min[16];
static int s_verify;

void spc_tls_flag_failure(const char* host)
{
    spc_registry_lock();
    spc_strlcpy(g_fail[g_fail_pos].host, host ? host : "", sizeof(g_fail[0].host));
    g_fail[g_fail_pos].t = spc_mono_ms();
    g_fail_pos = (g_fail_pos + 1) % 8;
    spc_registry_unlock();
}
/* host: the account's registrar host if known. An IP-literal host is matched exactly; a name falls back to
 * "any TLS verification failure in the last 8 s" because the transport only knows the resolved address. */
int spc_tls_recent_failure(const char* host)
{
    int i, r = 0, literal = 0;
    int64_t now = spc_mono_ms();
    if (host) {
        pj_sockaddr tmp;
        pj_str_t hs = spc_pjs(host);
        literal = pj_sockaddr_parse(pj_AF_UNSPEC(), 0, &hs, &tmp) == PJ_SUCCESS;
    }
    spc_registry_lock();
    for (i = 0; i < 8; i++) {
        if (!g_fail[i].t || now - g_fail[i].t > 8000) continue;
        if (!literal || strcmp(g_fail[i].host, host) == 0) r = 1;
    }
    spc_registry_unlock();
    return r;
}

/* each pin: {host, sha256 = exactly 64 hex digits}. Returns 0 on success, -1 if any entry is invalid (nothing applied). */
int spc_tls_set_pins(const cJSON* pins)
{
    const cJSON* e;
    pin_t np[32];
    int n = 0;
    cJSON_ArrayForEach(e, pins) {
        const char* h = spc_jstr(e, "host");
        const char* s = spc_jstr(e, "sha256");
        size_t i, k = 0;
        if (!h || !s || n >= 32 || strlen(s) != 64 || !h[0]) return -1;
        spc_strlcpy(np[n].host, h, sizeof(np[n].host));
        for (i = 0; s[i]; i++) {
            if (!isxdigit((unsigned char)s[i])) return -1;
            np[n].sha[k++] = (char)tolower((unsigned char)s[i]);
        }
        np[n].sha[k] = 0;
        n++;
    }
    spc_registry_lock();
    memcpy(g_pins, np, sizeof(pin_t) * (size_t)n);
    g_npins = n;
    spc_registry_unlock();
    return 0;
}

static int pinned(const char* sha)
{
    int i, r = 0;
    if (!sha || strlen(sha) != 64) return 0;          /* an uncomputable fingerprint never matches */
    spc_registry_lock();
    for (i = 0; i < g_npins; i++) if (strcmp(g_pins[i].sha, sha) == 0) r = 1;
    spc_registry_unlock();
    return r;
}

/* Is a usable CA configured for server verification? Fills `err` and returns 0 if not. */
int spc_tls_check_ca(int verify, const char* ca, char* err, size_t en)
{
    if (!verify) return 1;
    if (ca && ca[0]) {
        FILE* f = fopen(ca, "rb");
        if (!f) { snprintf(err, en, "tls.caFile '%s' is not readable", ca); return 0; }
        fclose(f);
        return 1;
    }
#if defined(__ANDROID__)
    return 1;            /* system store directory is used */
#elif defined(__APPLE__) && TARGET_OS_IPHONE
    snprintf(err, en, "tls.verifyServer requires tls.caFile on iOS (no system CA path is available to OpenSSL)");
    return 0;
#elif defined(_WIN32)
    snprintf(err, en, "tls.verifyServer requires tls.caFile on Windows (no system CA path is available to OpenSSL)");
    return 0;
#else
    {
        static const char* const paths[] = { "/etc/ssl/cert.pem", "/etc/ssl/certs/ca-certificates.crt", "/etc/pki/tls/certs/ca-bundle.crt", NULL };
        int i;
        for (i = 0; paths[i]; i++) {
            FILE* f = fopen(paths[i], "rb");
            if (f) { fclose(f); return 1; }
        }
    }
    snprintf(err, en, "tls.verifyServer needs tls.caFile (no system CA bundle found)");
    return 0;
#endif
}

void spc_tls_cfg(pjsip_tls_setting* st, int verify, const char* ca, const char* cert, const char* key, const char* minProto)
{
    pjsip_tls_setting_default(st);
    if (ca || cert || key || minProto) {
        s_verify = verify;
        spc_strlcpy(s_ca, ca ? ca : "", sizeof(s_ca));
        spc_strlcpy(s_cert, cert ? cert : "", sizeof(s_cert));
        spc_strlcpy(s_key, key ? key : "", sizeof(s_key));
        spc_strlcpy(s_min, minProto ? minProto : "tls1.2", sizeof(s_min));
    }
    (void)s_verify;
#if defined(__ANDROID__)
    if (!s_ca[0] && G.tls_verify) st->ca_list_path = spc_pjs("/system/etc/security/cacerts");
#endif
    if (!s_ca[0] && G.tls_verify) {
        static const char* const paths[] = { "/etc/ssl/cert.pem", "/etc/ssl/certs/ca-certificates.crt", "/etc/pki/tls/certs/ca-bundle.crt", NULL };
        int i;
        for (i = 0; paths[i]; i++) {
            FILE* f = fopen(paths[i], "rb");
            if (f) { fclose(f); spc_strlcpy(s_ca, paths[i], sizeof(s_ca)); break; }
        }
    }
    if (s_ca[0]) st->ca_list_file = spc_pjs(s_ca);
    if (s_cert[0]) st->cert_file = spc_pjs(s_cert);
    if (s_key[0]) st->privkey_file = spc_pjs(s_key);
    st->method = PJSIP_SSL_UNSPECIFIED_METHOD;
    if (spc_strieq(s_min, "tls1.3")) st->proto = PJ_SSL_SOCK_PROTO_TLS1_3;
    else if (spc_strieq(s_min, "tls1.0")) st->proto = PJ_SSL_SOCK_PROTO_TLS1 | PJ_SSL_SOCK_PROTO_TLS1_1 | PJ_SSL_SOCK_PROTO_TLS1_2 | PJ_SSL_SOCK_PROTO_TLS1_3;
    else if (spc_strieq(s_min, "tls1.1")) st->proto = PJ_SSL_SOCK_PROTO_TLS1_1 | PJ_SSL_SOCK_PROTO_TLS1_2 | PJ_SSL_SOCK_PROTO_TLS1_3;
    else st->proto = PJ_SSL_SOCK_PROTO_TLS1_2 | PJ_SSL_SOCK_PROTO_TLS1_3;
    st->verify_server = PJ_FALSE;     /* verification policy is applied in spc_tls_on_transport_state */
    st->verify_client = PJ_FALSE;
}

void spc_tls_cleanup(void)
{
    memset(g_fail, 0, sizeof(g_fail));
    memset(g_pins, 0, sizeof(g_pins)); g_npins = 0;
    s_ca[0] = s_cert[0] = s_key[0] = s_min[0] = 0; s_verify = 0;
}

#if defined(__has_include)
#  if __has_include(<openssl/ssl.h>)
#    include <openssl/ssl.h>
#    include <openssl/err.h>
#    include <openssl/pem.h>
#    include <openssl/x509.h>
#    define SPC_HAVE_OSSL 1
#  endif
#endif

#ifdef SPC_HAVE_OSSL
static int pw_cb(char* buf, int size, int rw, void* u)
{
    const char* p = (const char*)u;
    size_t n;
    (void)rw;
    if (!p || !p[0]) return 0;          /* never prompt on a terminal */
    n = strlen(p);
    if (n > (size_t)size) n = (size_t)size;
    memcpy(buf, p, n);
    return (int)n;
}
#endif

int spc_tls_validate_client_cert(const char* cert, const char* key, const char* password, char* err, size_t en)
{
    FILE* f;
    if (!cert || !cert[0]) { snprintf(err, en, "tlsClientCert.certFile required"); return -1; }
    if (!key || !key[0]) { snprintf(err, en, "tlsClientCert.keyFile required"); return -1; }
    f = fopen(cert, "rb");
    if (!f) { snprintf(err, en, "tlsClientCert.certFile '%s' is not readable", cert); return -1; }
    fclose(f);
    f = fopen(key, "rb");
    if (!f) { snprintf(err, en, "tlsClientCert.keyFile '%s' is not readable", key); return -1; }
    fclose(f);
#ifdef SPC_HAVE_OSSL
    {
        SSL_CTX* ctx = SSL_CTX_new(TLS_client_method());
        int rc = -1;
        unsigned long e;
        if (!ctx) { snprintf(err, en, "cannot create a TLS context"); return -1; }
        SSL_CTX_set_default_passwd_cb(ctx, pw_cb);
        SSL_CTX_set_default_passwd_cb_userdata(ctx, (void*)password);
        ERR_clear_error();
        if (SSL_CTX_use_certificate_chain_file(ctx, cert) != 1) {
            snprintf(err, en, "tlsClientCert.certFile '%s' is not a valid PEM certificate", cert);
        } else if (SSL_CTX_use_PrivateKey_file(ctx, key, SSL_FILETYPE_PEM) != 1) {
            int dec = 0, mism = 0;
            while ((e = ERR_get_error()) != 0) {         /* OpenSSL 3 decoders queue several errors: look at all of them */
                char es[160];
                ERR_error_string_n(e, es, sizeof(es));
                if (getenv("SPC_DEBUG_TLS")) fprintf(stderr, "tls key error: %s\n", es);
                if (strstr(es, "ecrypt") || strstr(es, "assword") || strstr(es, "assphrase") ||
                    ERR_GET_REASON(e) == PEM_R_BAD_PASSWORD_READ || ERR_GET_REASON(e) == PEM_R_PROBLEMS_GETTING_PASSWORD) dec = 1;
                if (ERR_GET_REASON(e) == X509_R_KEY_VALUES_MISMATCH) mism = 1;
            }
            if (dec)
                snprintf(err, en, "tlsClientCert.keyFile '%s' cannot be decrypted (missing or wrong password)", key);
            else if (mism)
                snprintf(err, en, "tlsClientCert.keyFile '%s' does not match certFile '%s'", key, cert);
            else
                snprintf(err, en, "tlsClientCert.keyFile '%s' is not a valid PEM private key (or the password is wrong)", key);
        } else if (SSL_CTX_check_private_key(ctx) != 1) {
            snprintf(err, en, "tlsClientCert.keyFile '%s' does not match certFile '%s'", key, cert);
        } else {
            rc = 0;
        }
        SSL_CTX_free(ctx);
        ERR_clear_error();
        return rc;
    }
#else
    (void)password;
    return 0;
#endif
}

static void verify_names(unsigned long vs, cJSON* arr)
{
    static const struct { unsigned long bit; const char* n; } t[] = {
        { PJ_SSL_CERT_EISSUER_NOT_FOUND, "issuerNotFound" }, { PJ_SSL_CERT_EUNTRUSTED, "untrusted" },
        { PJ_SSL_CERT_EVALIDITY_PERIOD, "validityPeriod" }, { PJ_SSL_CERT_EINVALID_FORMAT, "invalidFormat" },
        { PJ_SSL_CERT_EINVALID_PURPOSE, "invalidPurpose" }, { PJ_SSL_CERT_EISSUER_MISMATCH, "issuerMismatch" },
        { PJ_SSL_CERT_ECRL_FAILURE, "crlFailure" }, { PJ_SSL_CERT_EREVOKED, "revoked" },
        { PJ_SSL_CERT_ECHAIN_TOO_LONG, "chainTooLong" }, { PJ_SSL_CERT_EWEAK_SIGNATURE, "weakSignature" },
        { PJ_SSL_CERT_EIDENTITY_NOT_MATCH, "identityNotMatch" }, { 0, NULL } };
    int i;
    for (i = 0; t[i].n; i++) if (vs & t[i].bit) cJSON_AddItemToArray(arr, cJSON_CreateString(t[i].n));
    if ((vs & PJ_SSL_CERT_EUNKNOWN) && 0) cJSON_AddItemToArray(arr, cJSON_CreateString("unknown"));
}

static void cert_sha(const pj_ssl_cert_info* ci, char out[65])
{
    unsigned char der[8192];
    size_t n;
    out[0] = 0;
    if (!ci || !ci->raw.ptr || ci->raw.slen <= 0) return;
    n = spc_pem_to_der(ci->raw.ptr, (size_t)ci->raw.slen, der, sizeof(der));
    if (n) spc_sha256_hex(der, n, out);
}

static void iso_time(const pj_time_val* tv, char* out, size_t n)
{
    time_t t = (time_t)tv->sec;
    struct tm tmv;
#if defined(_WIN32)
    gmtime_s(&tmv, &t);
#else
    gmtime_r(&t, &tmv);
#endif
    strftime(out, n, "%Y-%m-%dT%H:%M:%SZ", &tmv);
}

void spc_tls_on_transport_state(pjsip_transport* tp, pjsip_transport_state state, const pjsip_transport_state_info* info)
{
    cJSON* f;
    const char* sn;
    char type[12], local[96], remote[96], host[128];
    int is_tls = (tp->key.type & ~PJSIP_TRANSPORT_IPV6) == PJSIP_TRANSPORT_TLS || spc_ws_type_is_wss(tp->key.type);
    pj_ssl_sock_info* ssi = NULL;
    char sha[65] = "";
    int reject = 0;
    if (state == PJSIP_TP_STATE_DESTROY) return;
    sn = state == PJSIP_TP_STATE_CONNECTED ? "connected" : state == PJSIP_TP_STATE_DISCONNECTED ? "disconnected" : "shutdown";
    {
        size_t i;
        spc_strlcpy(type, tp->type_name, sizeof(type));
        for (i = 0; type[i]; i++) type[i] = (char)tolower((unsigned char)type[i]);
    }
    snprintf(local, sizeof(local), "%.*s:%d", (int)tp->local_name.host.slen, tp->local_name.host.ptr, tp->local_name.port);
    snprintf(remote, sizeof(remote), "%.*s:%d", (int)tp->remote_name.host.slen, tp->remote_name.host.ptr, tp->remote_name.port);
    spc_pjcopy(host, sizeof(host), &tp->remote_name.host);
    if (is_tls && info && info->ext_info) {
        pjsip_tls_state_info* ti = (pjsip_tls_state_info*)info->ext_info;
        ssi = ti->ssl_sock_info;
    }
    if (is_tls && state == PJSIP_TP_STATE_CONNECTED && tp->dir == PJSIP_TP_DIR_OUTGOING) {
        if (ssi && ssi->remote_cert_info) cert_sha(ssi->remote_cert_info, sha);
        if (G.tls_verify) {
            /* no certificate information at all, or a failed verification that is not pinned, is a rejection */
            if (!ssi || !ssi->remote_cert_info || ssi->verify_status != 0) reject = !pinned(sha);
        }
    }
    f = cJSON_CreateObject();
    cJSON_AddStringToObject(f, "transport", type);
    cJSON_AddStringToObject(f, "local", local);
    cJSON_AddStringToObject(f, "remote", remote);
    cJSON_AddStringToObject(f, "state", reject ? "disconnected" : sn);
    cJSON_AddNumberToObject(f, "status", reject ? PJSIP_TLS_ECERTVERIF : (info ? info->status : 0));
    if (ssi && ssi->remote_cert_info && state != PJSIP_TP_STATE_SHUTDOWN) {
        cJSON* t = cJSON_AddObjectToObject(f, "tls");
        cJSON* rc;
        char nb[40];
        verify_names(ssi->verify_status, cJSON_AddArrayToObject(t, "verifyStatus"));
        cJSON_AddStringToObject(t, "cipher", ssi->cipher ? pj_ssl_cipher_name(ssi->cipher) : "");
        rc = cJSON_AddObjectToObject(t, "remoteCert");
        spc_jadd_pjstr(rc, "subject", &ssi->remote_cert_info->subject.info);
        spc_jadd_pjstr(rc, "issuer", &ssi->remote_cert_info->issuer.info);
        iso_time(&ssi->remote_cert_info->validity.end, nb, sizeof(nb));
        cJSON_AddStringToObject(rc, "notAfter", nb);
        cJSON_AddStringToObject(rc, "sha256", sha);
    }
    spc_emit("transport.state", f);
    if (reject) {
        cJSON* v = cJSON_CreateObject();
        cJSON_AddStringToObject(v, "host", host);
        cJSON_AddStringToObject(v, "sha256", sha);
        verify_names(ssi ? ssi->verify_status : 0, cJSON_AddArrayToObject(v, "verifyStatus"));
        if (ssi && ssi->remote_cert_info) {
            spc_jadd_pjstr(v, "subject", &ssi->remote_cert_info->subject.info);
            spc_jadd_pjstr(v, "issuer", &ssi->remote_cert_info->issuer.info);
        }
        spc_emit("transport.tlsVerify", v);
        spc_tls_flag_failure(host);
        pjsip_transport_shutdown(tp);
    }
}
