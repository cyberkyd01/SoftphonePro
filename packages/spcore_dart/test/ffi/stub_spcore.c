// Minimal stand-in for libspcore implementing the C ABI with canned
// behaviour, used to test FfiSipEngine plumbing without PJSIP.
#include <pthread.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "dart_api_dl.h"

#if defined(_WIN32)
#define API __declspec(dllexport)
#else
#define API __attribute__((visibility("default")))
#endif

static int64_t g_port = 0;
static int g_inited = 0;
static int g_mute_ping = 0;
static int64_t g_req = 0;
static int64_t g_seq = 0;
static pthread_mutex_t mu = PTHREAD_MUTEX_INITIALIZER;

static void post(const char* s) {
  pthread_mutex_lock(&mu);
  if (g_port) {
    Dart_CObject o;
    o.type = Dart_CObject_kString;
    o.value.as_string = (char*)s;
    Dart_PostCObject_DL(g_port, &o);
  }
  pthread_mutex_unlock(&mu);
}

static void post_event(const char* name, const char* extra, int64_t seq) {
  char buf[512];
  snprintf(buf, sizeof buf, "{\"type\":\"event\",\"event\":\"%s\",\"ts\":1,\"seq\":%lld%s}", name, (long long)seq, extra);
  post(buf);
}

API int32_t spc_api_version(void) { return 1; }
API const char* spc_version_string(void) { return "stub"; }
API intptr_t spc_init_dart_api(void* d) { return Dart_InitializeApiDL(d); }
API int32_t spc_init(int64_t port) {
  int was = g_inited;
  g_inited = 1;
  pthread_mutex_lock(&mu); g_port = port; pthread_mutex_unlock(&mu);
  return was ? 1 : 0;
}
API int32_t spc_set_event_port(int64_t port) {
  pthread_mutex_lock(&mu); g_port = port; pthread_mutex_unlock(&mu);
  if (port == 0) g_inited = 0; /* stub: detaching == fresh process for the next attach */
  return 0;
}
API int32_t spc_set_event_callback(void (*cb)(const char*, void*), void* u) { return 0; }

typedef struct { int64_t id; char method[64]; } Req;

static void* worker(void* p) {
  Req* r = (Req*)p;
  char buf[1024];
  if (strcmp(r->method, "test.never") == 0) { free(r); return NULL; }
  if (strcmp(r->method, "core.ping") == 0 && g_mute_ping) { free(r); return NULL; }
  if (strcmp(r->method, "test.mute") == 0) { g_mute_ping = 1; snprintf(buf, sizeof buf, "{\"type\":\"response\",\"id\":%lld,\"ok\":true,\"result\":{}}", (long long)r->id); }
  else if (strcmp(r->method, "test.unmute") == 0) { g_mute_ping = 0; snprintf(buf, sizeof buf, "{\"type\":\"response\",\"id\":%lld,\"ok\":true,\"result\":{}}", (long long)r->id); }
  else if (strcmp(r->method, "test.event") == 0) {
    post_event("log", ",\"level\":3,\"msg\":\"hi\"", ++g_seq);
    snprintf(buf, sizeof buf, "{\"type\":\"response\",\"id\":%lld,\"ok\":true,\"result\":{}}", (long long)r->id);
  } else if (strcmp(r->method, "test.gap") == 0) {
    post_event("log", ",\"level\":3,\"msg\":\"a\"", ++g_seq);
    g_seq += 5;
    post_event("log", ",\"level\":3,\"msg\":\"b\"", ++g_seq);
    snprintf(buf, sizeof buf, "{\"type\":\"response\",\"id\":%lld,\"ok\":true,\"result\":{}}", (long long)r->id);
  } else if (strcmp(r->method, "core.snapshot") == 0) {
    snprintf(buf, sizeof buf, "{\"type\":\"response\",\"id\":%lld,\"ok\":true,\"result\":{\"accounts\":[],\"calls\":[],\"buddies\":[],\"seq\":%lld}}", (long long)r->id, (long long)g_seq);
  } else if (strcmp(r->method, "test.fail") == 0) {
    snprintf(buf, sizeof buf, "{\"type\":\"response\",\"id\":%lld,\"ok\":false,\"error\":{\"code\":\"PJ_ERROR\",\"status\":70004,\"message\":\"boom\"}}", (long long)r->id);
  } else {
    snprintf(buf, sizeof buf, "{\"type\":\"response\",\"id\":%lld,\"ok\":true,\"result\":{\"echo\":\"%s\"}}", (long long)r->id, r->method);
  }
  post(buf);
  free(r);
  return NULL;
}

API int64_t spc_request(const char* method, const char* params) {
  Req* r = (Req*)calloc(1, sizeof(Req));
  r->id = ++g_req;
  strncpy(r->method, method, 63);
  int64_t id = r->id;
  pthread_t t;
  /* A loaded CI runner can refuse new threads; answer inline then (the
   * response is queued on the port and handled after this returns). */
  if (pthread_create(&t, NULL, worker, r) != 0) worker(r);
  else pthread_detach(t);
  return id;
}
API char* spc_request_sync(const char* m, const char* p, int32_t t) { return strdup("{}"); }
API void spc_free(char* p) { free(p); }
API void spc_shutdown(void) { g_inited = 0; }
