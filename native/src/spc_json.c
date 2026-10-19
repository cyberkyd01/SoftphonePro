#include "spc_internal.h"
#include <ctype.h>

const char* spc_jstr(const cJSON* o, const char* k)
{
    const cJSON* v;
    if (!o || !cJSON_IsObject(o)) return NULL;
    v = cJSON_GetObjectItemCaseSensitive(o, k);
    return (v && cJSON_IsString(v)) ? v->valuestring : NULL;
}
int spc_jhas(const cJSON* o, const char* k)
{
    const cJSON* v;
    if (!o || !cJSON_IsObject(o)) return 0;
    v = cJSON_GetObjectItemCaseSensitive(o, k);
    return v && !cJSON_IsNull(v);
}
double spc_jnum(const cJSON* o, const char* k, double def)
{
    const cJSON* v;
    if (!o || !cJSON_IsObject(o)) return def;
    v = cJSON_GetObjectItemCaseSensitive(o, k);
    if (v && cJSON_IsNumber(v)) return v->valuedouble;
    return def;
}
int spc_jint(const cJSON* o, const char* k, int def)
{
    double d = spc_jnum(o, k, (double)def);
    if (d > 2147483647.0) return 2147483647;
    if (d < -2147483648.0) return (int)-2147483647 - 1;
    return (int)d;
}
uint64_t spc_ju64(const cJSON* o, const char* k)
{
    double d = spc_jnum(o, k, 0);
    return d > 0 ? (uint64_t)d : 0;
}
int spc_jbool(const cJSON* o, const char* k, int def)
{
    const cJSON* v;
    if (!o || !cJSON_IsObject(o)) return def;
    v = cJSON_GetObjectItemCaseSensitive(o, k);
    if (!v) return def;
    if (cJSON_IsBool(v)) return cJSON_IsTrue(v) ? 1 : 0;
    if (cJSON_IsNumber(v)) return v->valuedouble != 0;
    return def;
}
cJSON* spc_jobj(const cJSON* o, const char* k)
{
    cJSON* v;
    if (!o || !cJSON_IsObject(o)) return NULL;
    v = cJSON_GetObjectItemCaseSensitive((cJSON*)o, k);
    return (v && cJSON_IsObject(v)) ? v : NULL;
}
cJSON* spc_jarr(const cJSON* o, const char* k)
{
    cJSON* v;
    if (!o || !cJSON_IsObject(o)) return NULL;
    v = cJSON_GetObjectItemCaseSensitive((cJSON*)o, k);
    return (v && cJSON_IsArray(v)) ? v : NULL;
}
void spc_jadd_str(cJSON* o, const char* k, const char* s)
{
    if (s) cJSON_AddStringToObject(o, k, s);
    else cJSON_AddNullToObject(o, k);
}
void spc_jadd_u64(cJSON* o, const char* k, uint64_t v)
{
    cJSON_AddNumberToObject(o, k, (double)v);
}
cJSON* spc_jpjstr(const pj_str_t* s)
{
    char* tmp;
    cJSON* r;
    if (!s || !s->ptr || s->slen <= 0) return cJSON_CreateString("");
    tmp = (char*)malloc((size_t)s->slen + 1);
    if (!tmp) return cJSON_CreateString("");
    memcpy(tmp, s->ptr, (size_t)s->slen);
    tmp[s->slen] = 0;
    r = cJSON_CreateString(tmp);
    free(tmp);
    return r;
}
void spc_jadd_pjstr(cJSON* o, const char* k, const pj_str_t* s)
{
    cJSON* v = spc_jpjstr(s);
    if (v) cJSON_AddItemToObject(o, k, v);
}
char* spc_json_print(const cJSON* o) { return cJSON_PrintUnformatted(o); }
pj_str_t spc_pjs(const char* s)
{
    pj_str_t r;
    r.ptr = (char*)(s ? s : "");
    r.slen = (pj_ssize_t)strlen(r.ptr);
    return r;
}
void spc_pjcopy(char* dst, size_t n, const pj_str_t* s)
{
    size_t l;
    if (!n) return;
    if (!s || !s->ptr || s->slen <= 0) { dst[0] = 0; return; }
    l = (size_t)s->slen;
    if (l >= n) l = n - 1;
    memcpy(dst, s->ptr, l);
    dst[l] = 0;
}
char* spc_strdup(const char* s)
{
    size_t l;
    char* r;
    if (!s) return NULL;
    l = strlen(s);
    r = (char*)malloc(l + 1);
    if (r) memcpy(r, s, l + 1);
    return r;
}
void spc_strlcpy(char* dst, const char* src, size_t n)
{
    size_t l;
    if (!n) return;
    if (!src) { dst[0] = 0; return; }
    l = strlen(src);
    if (l >= n) l = n - 1;
    memcpy(dst, src, l);
    dst[l] = 0;
}
int spc_strieq(const char* a, const char* b)
{
    if (!a || !b) return a == b;
    while (*a && *b) {
        if (tolower((unsigned char)*a) != tolower((unsigned char)*b)) return 0;
        a++; b++;
    }
    return *a == *b;
}
int spc_strnieq(const char* a, const char* b, size_t n)
{
    size_t i;
    for (i = 0; i < n; i++) {
        if (tolower((unsigned char)a[i]) != tolower((unsigned char)b[i])) return 0;
        if (!a[i]) return 1;
    }
    return 1;
}

void spc_parse_nameaddr(const char* s, char* disp, size_t dn, char* uri, size_t un, char* user, size_t usn)
{
    const char* lt;
    const char* gt;
    const char* u;
    const char* at;
    char tmp[512];
    if (disp && dn) disp[0] = 0;
    if (uri && un) uri[0] = 0;
    if (user && usn) user[0] = 0;
    if (!s) return;
    while (*s == ' ') s++;
    lt = strchr(s, '<');
    if (lt) {
        gt = strchr(lt, '>');
        if (disp && dn) {
            size_t l = (size_t)(lt - s);
            const char* b = s;
            while (l && b[l - 1] == ' ') l--;
            if (l >= 2 && b[0] == '"' && b[l - 1] == '"') { b++; l -= 2; }
            if (l >= dn) l = dn - 1;
            memcpy(disp, b, l);
            disp[l] = 0;
        }
        {
            size_t l = gt ? (size_t)(gt - lt - 1) : strlen(lt + 1);
            if (l >= sizeof(tmp)) l = sizeof(tmp) - 1;
            memcpy(tmp, lt + 1, l);
            tmp[l] = 0;
        }
    } else {
        size_t l = strcspn(s, ";");
        if (l >= sizeof(tmp)) l = sizeof(tmp) - 1;
        memcpy(tmp, s, l);
        tmp[l] = 0;
    }
    if (uri && un) spc_strlcpy(uri, tmp, un);
    if (user && usn) {
        u = strchr(tmp, ':');
        u = u ? u + 1 : tmp;
        at = strchr(u, '@');
        if (at) {
            size_t l = (size_t)(at - u);
            if (l >= usn) l = usn - 1;
            memcpy(user, u, l);
            user[l] = 0;
            {   /* strip ;params from user part */
                char* sc = strchr(user, ';');
                if (sc) *sc = 0;
            }
        } else {
            /* no user: report host as user so UI still shows something */
            size_t l = strcspn(u, ";:?");
            if (l >= usn) l = usn - 1;
            memcpy(user, u, l);
            user[l] = 0;
        }
    }
}

cJSON* spc_sockaddr_json_str(const pj_sockaddr* a)
{
    char buf[PJ_INET6_ADDRSTRLEN + 10];
    if (!a || !pj_sockaddr_has_addr(a)) return cJSON_CreateString("");
    pj_sockaddr_print(a, buf, sizeof(buf), 3);
    return cJSON_CreateString(buf);
}

void spc_fill_msg_data(pj_pool_t* pool, pjsua_msg_data* md, const cJSON* headers)
{
    const cJSON* h;
    pjsua_msg_data_init(md);
    if (!headers || !cJSON_IsObject(headers)) return;
    cJSON_ArrayForEach(h, headers) {
        pj_str_t name, val;
        pjsip_generic_string_hdr* gh;
        if (!h->string || !cJSON_IsString(h) || !h->valuestring) continue;
        name = spc_pjs(h->string);
        pj_strdup2_with_null(pool, &name, h->string);
        pj_strdup2_with_null(pool, &val, h->valuestring);
        gh = pjsip_generic_string_hdr_create(pool, &name, &val);
        if (gh) pj_list_push_back(&md->hdr_list, (pjsip_hdr*)gh);
    }
}

cJSON* spc_headers_from_rdata(pjsip_rx_data* rdata)
{
    cJSON* o = cJSON_CreateObject();
    pjsip_hdr* h;
    static const char* const keep[] = { "Call-Info", "Alert-Info", "Answer-Mode", "Referred-By", "Replaces",
        "Diversion", "History-Info", "P-Asserted-Identity", "P-Preferred-Identity", "Remote-Party-ID",
        "Privacy", "Subject", "Priority", "Require", "Supported", "Allow-Events", "Session-Expires",
        "Geolocation", "Join", "Refer-To", NULL };
    if (!rdata || !rdata->msg_info.msg) return o;
    for (h = rdata->msg_info.msg->hdr.next; h != (pjsip_hdr*)&rdata->msg_info.msg->hdr; h = h->next) {
        char name[64];
        char buf[1024];
        int n, i, ok = 0;
        const char* val;
        spc_pjcopy(name, sizeof(name), &h->name);
        if (spc_strnieq(name, "X-", 2) && strlen(name) > 2) ok = 1;
        for (i = 0; !ok && keep[i]; i++) if (spc_strieq(name, keep[i])) ok = 1;
        if (!ok) continue;
        n = h->vptr->print_on(h, buf, sizeof(buf) - 1);
        if (n <= 0) continue;
        buf[n] = 0;
        val = strchr(buf, ':');
        val = val ? val + 1 : buf;
        while (*val == ' ') val++;
        if (cJSON_GetObjectItemCaseSensitive(o, name)) {
            /* join duplicates with ", " */
            cJSON* old = cJSON_GetObjectItemCaseSensitive(o, name);
            size_t l = strlen(old->valuestring) + strlen(val) + 3;
            char* j = (char*)malloc(l);
            if (j) {
                snprintf(j, l, "%s, %s", old->valuestring, val);
                cJSON_ReplaceItemInObjectCaseSensitive(o, name, cJSON_CreateString(j));
                free(j);
            }
        } else {
            cJSON_AddStringToObject(o, name, val);
        }
    }
    return o;
}
