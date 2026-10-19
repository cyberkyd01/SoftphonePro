/* spc_ws_transport.h: SIP over WebSocket (RFC 7118) client transport for PJSIP ("WS" / "WSS"). */
#ifndef SPC_WS_TRANSPORT_H
#define SPC_WS_TRANSPORT_H

#include <stddef.h>

/* Registers the WS/WSS transport types (once per process) and creates the transport factories on the
 * current pjsip endpoint. Call after pjsua_init() and after the TLS settings have been captured
 * (spc_tls_cfg). Factories are destroyed together with the endpoint. Returns 0 on success. */
int  spc_ws_start(void);

/* 1 if the pjsip transport type (tp->key.type) is WSS (v4 or v6). */
int  spc_ws_type_is_wss(int tp_type);

/* Remember the HTTP request path for connections to "host:port" (host as it appears in the SIP URI).
 * Default path is "/ws". Thread safe. */
void spc_ws_route_set(const char* host, int port, int wss, const char* path);

/* Per-route TLS client certificate for wss connections to "host:port" (empty cert/key clears it). The route must
 * exist (spc_ws_route_set first). Loaded per connection. */
void spc_ws_route_set_cert(const char* host, int port, int wss, const char* cert, const char* key, const char* pass);

/* out = hostport with the default port (80 ws / 443 wss) appended when it has none. */
void spc_ws_ensure_port(const char* hostport, int wss, char* out, size_t outsz);

/* RFC 7118 5: random "<token>.invalid" host for Contact / Via. out >= 32 bytes. */
void spc_ws_random_invalid_host(char* out, size_t outsz);

#endif
