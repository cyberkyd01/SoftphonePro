/* spc_dns.c: native nameserver detection. */
#include "spc_internal.h"
#if defined(_WIN32)
#  include <winsock2.h>
#  include <ws2tcpip.h>
#else
#  include <sys/types.h>
#  include <sys/socket.h>
#  include <netdb.h>
#  include <netinet/in.h>
#endif

/* Bounded name -> IPv4 lookup. getaddrinfo() can block for 20-30 s on a dead resolver, which would freeze the
 * worker (and trip the host's liveness watchdog), so it runs on a helper thread that we stop waiting for after
 * timeout_ms. The job is reference counted: whichever side finishes last frees it. */
typedef struct {
    spc_mutex_t mtx;
    spc_cond_t cv;
    int refs, done, ok;
    uint32_t addr;       /* network order */
    char host[256];
} ip4_job;

static void ip4_unref(ip4_job* j)
{
    int r;
    spc_mutex_lock(&j->mtx);
    r = --j->refs;
    spc_mutex_unlock(&j->mtx);
    if (r > 0) return;
    spc_cond_destroy(&j->cv);
    spc_mutex_destroy(&j->mtx);
    free(j);
}

static void ip4_thread(void* arg)
{
    ip4_job* j = (ip4_job*)arg;
    struct addrinfo hints, *res = NULL;
    memset(&hints, 0, sizeof(hints));
    hints.ai_family = AF_INET;
    hints.ai_socktype = SOCK_DGRAM;
    if (getaddrinfo(j->host, NULL, &hints, &res) == 0 && res) {
        j->addr = ((struct sockaddr_in*)res->ai_addr)->sin_addr.s_addr;
        j->ok = 1;
    }
    if (res) freeaddrinfo(res);
    spc_mutex_lock(&j->mtx);
    j->done = 1;
    spc_cond_broadcast(&j->cv);
    spc_mutex_unlock(&j->mtx);
    ip4_unref(j);
}

int spc_resolve_ipv4(const char* host, uint32_t* addr_be, int timeout_ms)
{
    ip4_job* j;
    spc_thread_t th;
    int ok = 0;
    int64_t t0;
    if (!host || !host[0] || strlen(host) >= sizeof(j->host)) return -1;
    j = (ip4_job*)calloc(1, sizeof(*j));
    if (!j) return -1;
    spc_mutex_init(&j->mtx);
    spc_cond_init(&j->cv);
    j->refs = 2;
    spc_strlcpy(j->host, host, sizeof(j->host));
    if (spc_thread_create(&th, ip4_thread, j) != 0) { j->refs = 1; ip4_unref(j); return -1; }
    spc_thread_detach(&th);
    t0 = spc_mono_ms();
    spc_mutex_lock(&j->mtx);
    while (!j->done && spc_mono_ms() - t0 < timeout_ms) spc_cond_timedwait(&j->cv, &j->mtx, timeout_ms - (int)(spc_mono_ms() - t0));
    if (j->done && j->ok) { *addr_be = j->addr; ok = 1; }
    spc_mutex_unlock(&j->mtx);
    ip4_unref(j);
    return ok ? 0 : -1;
}

#if defined(_WIN32)
#  include <winsock2.h>
#  include <iphlpapi.h>
int spc_dns_detect(char servers[][64], int max)
{
    ULONG len = 0;
    FIXED_INFO* fi;
    int n = 0;
    IP_ADDR_STRING* a;
    GetNetworkParams(NULL, &len);
    if (!len) return 0;
    fi = (FIXED_INFO*)malloc(len);
    if (!fi) return 0;
    if (GetNetworkParams(fi, &len) == NO_ERROR) {
        for (a = &fi->DnsServerList; a && n < max; a = a->Next) {
            if (a->IpAddress.String[0] && strcmp(a->IpAddress.String, "0.0.0.0") != 0) {
                spc_strlcpy(servers[n++], a->IpAddress.String, 64);
            }
        }
    }
    free(fi);
    return n;
}
#elif defined(__ANDROID__)
int spc_dns_detect(char servers[][64], int max) { (void)servers; (void)max; return 0; }
#else
#  include <sys/types.h>
#  include <sys/socket.h>
#  include <netinet/in.h>
#  include <arpa/inet.h>
#  include <arpa/nameser.h>
#  include <resolv.h>
int spc_dns_detect(char servers[][64], int max)
{
    struct __res_state st;
    int n = 0, i;
    memset(&st, 0, sizeof(st));
    if (res_ninit(&st) != 0) return 0;
#if defined(__APPLE__)
    {
        union res_sockaddr_union u[MAXNS];
        int cnt = res_getservers(&st, u, MAXNS);
        for (i = 0; i < cnt && n < max; i++) {
            char buf[64];
            if (u[i].sin.sin_family == AF_INET) {
                if (!inet_ntop(AF_INET, &u[i].sin.sin_addr, buf, sizeof(buf)) || strcmp(buf, "0.0.0.0") == 0) continue;
            } else if (u[i].sin6.sin6_family == AF_INET6) {
                if (!inet_ntop(AF_INET6, &u[i].sin6.sin6_addr, buf, sizeof(buf)) || strcmp(buf, "::") == 0) continue;
            } else continue;
            spc_strlcpy(servers[n++], buf, 64);
        }
    }
    res_ndestroy(&st);
#else
    for (i = 0; i < MAXNS && n < max; i++) {
        char buf[64];
        const struct sockaddr_in6* s6 = st._u._ext.nsaddrs[i];
        if (st._u._ext.nsmap[i] == MAXNS + 1 && s6 && s6->sin6_family == AF_INET6) {
            if (!inet_ntop(AF_INET6, &s6->sin6_addr, buf, sizeof(buf)) || strcmp(buf, "::") == 0) continue;
        } else if (i < st.nscount && st.nsaddr_list[i].sin_family == AF_INET) {
            if (!inet_ntop(AF_INET, &st.nsaddr_list[i].sin_addr, buf, sizeof(buf)) || strcmp(buf, "0.0.0.0") == 0) continue;
        } else continue;
        spc_strlcpy(servers[n++], buf, 64);
    }
    res_nclose(&st);
#endif
    return n;
}
#endif
