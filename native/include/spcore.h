/*
 * spcore - SoftphonePro C engine, public C ABI.
 * Contract: docs/ENGINE_API.md (revision 2).
 */
#ifndef SPCORE_H
#define SPCORE_H

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

#if defined(_WIN32)
#  if defined(SPC_BUILDING)
#    define SPC_API __declspec(dllexport)
#  else
#    define SPC_API __declspec(dllimport)
#  endif
#elif defined(__GNUC__) || defined(__clang__)
#  define SPC_API __attribute__((visibility("default")))
#else
#  define SPC_API
#endif

#define SPC_API_VERSION 1

SPC_API int32_t     spc_api_version(void);
SPC_API const char* spc_version_string(void);
SPC_API intptr_t    spc_init_dart_api(void* data);
SPC_API int32_t     spc_init(int64_t dart_port);
SPC_API int32_t     spc_set_event_port(int64_t dart_port);
SPC_API int32_t     spc_set_event_callback(void (*cb)(const char* json, void* user), void* user);
SPC_API int64_t     spc_request(const char* method, const char* params_json);
SPC_API char*       spc_request_sync(const char* method, const char* params_json, int32_t timeout_ms);
SPC_API void        spc_free(char* p);
SPC_API void        spc_shutdown(void);

#ifdef __cplusplus
}
#endif
#endif /* SPCORE_H */
