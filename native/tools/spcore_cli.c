/* spcore_cli: test harness. Reads JSON lines on stdin, prints every response/event as one JSON line.
 *   {"m":"core.start","p":{...}}            async: response is printed when it arrives
 *   {"m":"core.start","p":{...},"sync":true} sync: response printed after the call returns
 *   {"m":"__sleep","p":{"ms":N}}  {"m":"__quit"}  {"m":"__detach"}  {"m":"__attach"}
 */
#include "spcore.h"
#include "cJSON.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#if defined(_WIN32)
#  include <windows.h>
static CRITICAL_SECTION g_mtx;
static void lock_init(void) { InitializeCriticalSection(&g_mtx); }
static void lock(void) { EnterCriticalSection(&g_mtx); }
static void unlock(void) { LeaveCriticalSection(&g_mtx); }
static void msleep(int ms) { Sleep((DWORD)ms); }
#else
#  include <pthread.h>
#  include <time.h>
static pthread_mutex_t g_mtx = PTHREAD_MUTEX_INITIALIZER;
static void lock_init(void) {}
static void lock(void) { pthread_mutex_lock(&g_mtx); }
static void unlock(void) { pthread_mutex_unlock(&g_mtx); }
static void msleep(int ms) { struct timespec ts; ts.tv_sec = ms / 1000; ts.tv_nsec = (long)(ms % 1000) * 1000000L; nanosleep(&ts, NULL); }
#endif

static void put_line(const char* s)
{
    lock();
    fputs(s, stdout);
    fputc('\n', stdout);
    fflush(stdout);
    unlock();
}

static void on_event(const char* json, void* user)
{
    (void)user;
    put_line(json);
}

static char* read_line(void)
{
    size_t cap = 4096, len = 0;
    char* buf = (char*)malloc(cap);
    int c;
    if (!buf) return NULL;
    while ((c = fgetc(stdin)) != EOF) {
        if (c == '\n') break;
        if (len + 2 > cap) {
            char* nb;
            cap *= 2;
            nb = (char*)realloc(buf, cap);
            if (!nb) { free(buf); return NULL; }
            buf = nb;
        }
        buf[len++] = (char)c;
    }
    if (c == EOF && len == 0) { free(buf); return NULL; }
    buf[len] = 0;
    return buf;
}

static void local_reply(const char* m, const char* extra)
{
    char buf[256];
    snprintf(buf, sizeof(buf), "{\"type\":\"local\",\"m\":\"%s\"%s%s}", m, extra ? "," : "", extra ? extra : "");
    put_line(buf);
}

int main(void)
{
    char* line;
    lock_init();
    setvbuf(stdout, NULL, _IOLBF, 0);
    spc_set_event_callback(on_event, NULL);
    if (spc_init(0) < 0) { fprintf(stderr, "spc_init failed\n"); return 2; }
    while ((line = read_line()) != NULL) {
        cJSON* req;
        const char* m;
        cJSON* p;
        if (line[0] == 0) { free(line); continue; }
        req = cJSON_Parse(line);
        free(line);
        if (!req || !cJSON_IsObject(req) || !cJSON_IsString(cJSON_GetObjectItem(req, "m"))) {
            put_line("{\"type\":\"local\",\"m\":\"?\",\"ok\":false,\"error\":\"bad input line\"}");
            cJSON_Delete(req);
            continue;
        }
        m = cJSON_GetObjectItem(req, "m")->valuestring;
        p = cJSON_GetObjectItem(req, "p");
        if (strcmp(m, "__quit") == 0) {
            cJSON_Delete(req);
            break;
        } else if (strcmp(m, "__sleep") == 0) {
            cJSON* ms = p ? cJSON_GetObjectItem(p, "ms") : NULL;
            msleep(ms && cJSON_IsNumber(ms) ? (int)ms->valuedouble : 0);
            local_reply("__sleep", "\"ok\":true");
        } else if (strcmp(m, "__detach") == 0) {
            spc_set_event_callback(NULL, NULL);
            local_reply("__detach", "\"ok\":true");
        } else if (strcmp(m, "__attach") == 0) {
            char ex[64];
            int n = spc_set_event_callback(on_event, NULL);
            snprintf(ex, sizeof(ex), "\"ok\":true,\"replayed\":%d", n);
            local_reply("__attach", ex);
        } else {
            char* params = p ? cJSON_PrintUnformatted(p) : NULL;
            cJSON* sync = cJSON_GetObjectItem(req, "sync");
            if (sync && cJSON_IsTrue(sync)) {
                char* r = spc_request_sync(m, params, 60000);
                if (r) { put_line(r); spc_free(r); }
            } else {
                int64_t id = spc_request(m, params);
                char buf[160];
                snprintf(buf, sizeof(buf), "{\"type\":\"sent\",\"id\":%lld,\"m\":\"%s\"}", (long long)id, m);
                put_line(buf);
            }
            free(params);
        }
        cJSON_Delete(req);
    }
    spc_shutdown();
    return 0;
}
