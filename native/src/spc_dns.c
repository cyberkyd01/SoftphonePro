/* spc_dns.c: native nameserver detection. */
#include "spc_internal.h"

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
    for (i = 0; i < st.nscount && n < max; i++) {
        char buf[64];
        const struct sockaddr_in* sin = &st.nsaddr_list[i];
        if (sin->sin_family != AF_INET) continue;
        if (!inet_ntop(AF_INET, &sin->sin_addr, buf, sizeof(buf))) continue;
        if (strcmp(buf, "0.0.0.0") == 0) continue;
        spc_strlcpy(servers[n++], buf, 64);
    }
#if defined(__APPLE__)
    res_ndestroy(&st);
#else
    res_nclose(&st);
#endif
    return n;
}
#endif
