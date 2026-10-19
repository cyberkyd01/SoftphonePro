# spcore Engine API (contract v1)

This is the single source of truth shared by `native/` (C), `packages/spcore_dart`
(Dart) and its tests. Any change must be made here first.
Revision 2 applies the architecture review: stable call ids, event-port
re-attach, manual sound mode for iOS, DNS handling, and extra fields and
methods for premium-feature parity.

## 1. C ABI (`native/include/spcore.h`)

```c
#define SPC_API_VERSION 1
SPC_API int32_t     spc_api_version(void);                 // returns SPC_API_VERSION
SPC_API const char* spc_version_string(void);              // static string, e.g. "1.0.0 (pjsip 2.17)"
SPC_API intptr_t    spc_init_dart_api(void* data);         // = Dart_InitializeApiDL(data); 0 on success
SPC_API int32_t     spc_init(int64_t dart_port);           // idempotent: 0 = started now, 1 = was already running
                                                           // (then behaves like spc_set_event_port(dart_port));
                                                           // <0 on error (-EINVAL if port!=0 and the Dart API wasn't initialised)
SPC_API int32_t     spc_set_event_port(int64_t dart_port); // attach a new isolate's port (0 = detach). Events produced
                                                           // while detached go into a bounded ring (2000) and are
                                                           // replayed in order on attach. Returns the number replayed.
SPC_API int32_t     spc_set_event_callback(void (*cb)(const char* json, void* user), void* user);
                                                           // alternative sink for C tools/tests; NULL to clear
SPC_API int64_t     spc_request(const char* method, const char* params_json);
                                                           // async; returns request id (>0) or <0 on error
SPC_API char*       spc_request_sync(const char* method, const char* params_json, int32_t timeout_ms);
                                                           // blocks; returns malloc'd response JSON (same shape as below)
SPC_API void        spc_free(char* p);
SPC_API void        spc_shutdown(void);                    // destroys pjsua, joins worker; safe to call twice
```

### Threading and lifetime rules (normative)
1. **pj initialisation.** `spc_init` calls `pj_init()` and keeps that
   reference until `spc_shutdown`.
2. **The worker thread.** The worker is a plain OS thread
   (pthread/Win32), registered with `pj_thread_register` and a static
   `pj_thread_desc`. It is never created from a pjsua pool. Requests run on
   it in FIFO order. `spc_request*` may be called from any thread.
3. **Callbacks only post.** pjsua callbacks run on pjsip threads, often with
   `PJSUA_LOCK` and the dialog lock held. They only build JSON, post it, and
   do the small native mechanics listed below. The event path must never
   take a lock that the worker holds while calling into pjsua.
   * `spc_request_sync` and `spc_shutdown` must never be called from the
     event callback or a pjsua callback. Called from the worker or from inside
     an event callback anyway, `spc_request_sync` returns a `BUSY` response
     immediately and `spc_shutdown` returns without doing anything (instead of
     deadlocking or joining itself).
4. **Event ordering.** Events produced synchronously by a request are
   delivered *before* that request's response. For example, the terminal
   `call.state` caused by `call.hangup` arrives before the hangup's
   response.
5. **Dart detach.** The Dart side calls `spc_set_event_port(0)` on
   `AppLifecycleState.detached` and before isolate shutdown. Posting to a
   dead port is harmless, but posting during VM teardown is not.
6. **Message format.** Every message posted to the Dart port is a JSON
   string (`Dart_CObject_kString`).
7. **Start order.** `params_json` may be `NULL` or `""`, meaning `{}`.
   `core.start` must be the first request; anything else fails with
   `NOT_STARTED`. `core.stop` followed by `core.start` must work any number
   of times.

### Identity
* **`cid` (u64)** is a monotonic engine-wide call identity that is never
  reused, even across `core.stop`/`core.start`. Every call event carries
  `cid`. `call` (the pjsua slot, 0..31; IAX2 1000+) is informational only.
  **Every `call.*` request identifies the call by `cid`.** If a request
  names a cid that is unknown or already ended, it fails with `NOT_FOUND`.
* **Hangup responses:** `call.hangup`, `call.reject` and `call.redirect` wait
  up to 2 s for the terminal `call.state`, so the terminal event is always
  delivered before the response.
* **Accounts:** `acc` is the pjsua account id (IAX2: 1000+). Every
  `account.*` request accepts either `acc` or `uid`. Dart's stable `uid`
  is echoed in every account and call event.

### Response message
```json
{"type":"response","id":17,"ok":true,"result":{...}}
{"type":"response","id":17,"ok":false,"error":{"code":"INVALID_PARAM","status":70004,"message":"..."}}
```
Unknown method names fail with `UNSUPPORTED` (so a newer Dart package can probe
for a feature on an older engine). Numeric parameters are range-checked and
must be integral where an integer is documented (ids, ports, timers); a value
outside its range, `NaN`-like or non-integral, fails with `INVALID_PARAM`. Flags
documented as required (`mute`, `detached`, `register`, `enabled`, `typing`,
`bridge`) must be JSON booleans.

Error codes: `INVALID_PARAM`, `NOT_FOUND`, `NOT_STARTED`, `ALREADY`, `PJ_ERROR`
(with `status` = pj_status_t and `message` = pj_strerror), `TIMEOUT`,
`UNSUPPORTED`, `BUSY`, `INTERNAL`.

### Event message
```json
{"type":"event","event":"call.state","ts":1729312345123,"seq":991, ...fields}
```
* Event payloads must not use the keys `type`, `event`, `ts` or `seq`.
* `ts` is Unix time in milliseconds.
* `seq` is a monotonic event counter. Dart uses it to detect gaps after a
  ring overflow and then calls `core.snapshot`.

## 2. Requests

Field types: `s`=string, `i`=int, `u64`=64-bit int, `b`=bool, `f`=float,
`[]`=array, `{}`=object. `?` marks an optional field; its default is shown
after `=`.

### core.*
| method | params | result |
|---|---|---|
| `core.start` | see below | `{version, pjsip, transports:[{id,type,local:"ip:port",ipv6:b}], lan?:{acc,port,transport}, direct:{acc}}` |
| `core.stop` | `{graceful?:b=true}` | `{}`; graceful unregisters accounts first, waiting at most 4 s; `pjsua_destroy2` |
| `core.info` | `{}` | `{version, pjsip, started:b, accounts:i, calls:i, natType?:s, sndMode, soundDevice:{capture,playback,open:b}}` |
| `core.snapshot` | `{}` | `{accounts:[AccountInfo], calls:[CallInfo], buddies:[BuddyInfo], devices:{...media.devices}, seq}`; resync after attach |
| `core.ping` | `{}` | `{}`; worker liveness check. Dart restarts the engine if it times out (5 s). |
| `core.setLogLevel` | `{level:i(0-6), forward?:b}` | `{}`; when `forward` is set, log lines go out as `log` events, rate-limited to 200/s; omitting `forward` keeps the current setting. `log` and `sip.trace` events are never buffered while no event sink is attached. |
| `core.setSipTrace` | `{enabled:b}` | `{}` |
| `core.handleIpChange` | `{}` | `{}`; re-detects (or re-applies) the nameservers, then `pjsua_handle_ip_change`; progress is reported through `core.ipChangeProgress` events |
| `core.setNameservers` | `{servers:[s]}` | `{}`; empty = keep the current list. Uses `pj_dns_resolver_set_ns`, creating the resolver if needed. |
| `core.getSipTos` | `{}` | `{transports:[{id, type, port, tos, dscp}]}`: diagnostic. IP_TOS / IPV6_TCLASS read back from each UDP SIP socket (`tos` = dscp<<2); `-1` for TCP/TLS (their sockets are per connection and cannot be inspected) and on Windows. |
| `core.setTlsPins` | `{pins:[{host:s, sha256:s}]}` | `{}`; a certificate whose SHA-256 matches a pin is accepted even when verification fails (self-signed PBX). `sha256` must be exactly 64 hex digits and `host` non-empty, otherwise `INVALID_PARAM` (nothing is applied). |
| `core.setUserAgent` | `{userAgent:s}` | `{}` |

`core.start` params:
```json
{
  "userAgent": "SoftphonePro/1.0",
  "logLevel": 3, "logForward": false, "sipTrace": false, "logFile": null,
  "nameservers": "auto",                 // "auto" = native detection (res_ninit on Apple/Linux, GetNetworkParams
                                         // on Windows; Android has none → Dart must call core.setNameservers);
                                         // [] = OS resolver only (getaddrinfo, no SRV); ["8.8.8.8",…] = explicit;
                                         // entries are "ip", "ipv4:port" or "[ipv6]:port" (default port 53)
  "stunServers": ["stun.l.google.com:19302"], "stunIgnoreFailure": true,
  "maxCalls": 16,
  "incomingAutoRingMs": 1500,            // send 180 if Dart hasn't answered/rung/rejected in time; 0 = never
  "incomingUnattendedMs": 30000,         // if no event port/callback is attached when an INVITE arrives: 480 after this
  "statsIntervalMs": 0,                  // >0: emit call.stats events for confirmed calls at this interval
  "publicAddr": null,                    // optional: overrides the advertised address for SIP transports and RTP
                                         // (testing, split-horizon DNS, multi-homed hosts)
  "transports": {
    "udp": {"port": 5060, "enabled": true},     // port 0 = random; falls back to random if busy
    "tcp": {"port": 5060, "enabled": true},
    "tls": {"port": 5061, "enabled": true, "verifyServer": false, "caFile": null,
            "certFile": null, "keyFile": null, "minProto": "tls1.2", "optional": false},
          // verifyServer:true needs trusted CAs. macOS/Linux fall back to the system bundle (/etc/ssl/cert.pem,
          // /etc/ssl/certs/ca-certificates.crt, ...), Android to /system/etc/security/cacerts. iOS and Windows have
          // no CA path OpenSSL can use: core.start fails with INVALID_PARAM unless caFile points to a readable
          // PEM bundle (the app ships a Mozilla bundle). An unreadable caFile also fails the start. The verdict is
          // applied right after the handshake, before any SIP data is sent; a connection with no certificate, or
          // with a failed verification and no matching pin, is dropped (transport.tlsVerify event).
          // TLS start failures: if the TLS listener cannot be created (unreadable/invalid certFile or keyFile, or
          // other transport error) or the ws/wss transports cannot start, core.start fails with PJ_ERROR and a
          // message naming the port / files, and the engine stays stopped (startable again). `optional:true`
          // restores the lenient behaviour: continue without the failed TLS/WSS transports (check
          // result.transports). A busy port is not an error: the engine falls back to a random port.
          // All TLS settings (verifyServer, caFile, certFile, keyFile, minProto), the TLS pins and the verify
          // flag are reset on every core.start/core.stop: a start without a `tls` object means verifyServer:false.
    "ipv6": false,                              // also create IPv6 UDP/TCP/TLS transports
    "qos": true,                                // DSCP marking: SIP signalling, RTP voice (EF)
    "dscpSip": 24                               // 0..63, DSCP of the SHARED SIP transports (default CS3); see "SIP DSCP" below
  },
  "lan": {"enabled": false, "port": 0},         // UDP transport + local account (uid "__lan__") for LAN calls
  "media": {
    "clockRate": 0, "sndClockRate": 0, "channelCount": 1,
    "ec": {"algo": "auto", "tailMs": 200, "ns": true, "agc": false},
          // algo: auto|aec3|webrtc|speex|simple|platform|none
          // auto = platform (VPIO/VOICE_COMMUNICATION) on iOS/macOS/Android, aec3 on Windows/Linux, else speex
    "vad": false, "quality": 8, "ptime": 20,
    "jb": {"initMs": -1, "minPreMs": -1, "maxPreMs": -1, "maxMs": -1},
    "rtpPort": 4000, "rtpPortRange": 0,
    "sndMode": "auto",                          // auto | manual. manual is mandatory on iOS (CallKit):
                                                // see §5
    "noAudioDevice": false                      // true = null device always (tests/headless)
  }
}
```
`core.start` always creates the **direct account** (uid `"__direct__"`).
This is a userless local account on the main UDP transport, used by
`call.make {acc:-1}` for direct IP calls.

### account.*
| method | params | result |
|---|---|---|
| `account.add` | AccountConfig | `{acc:i}` |
| `account.modify` | `{acc|uid, ...AccountConfig}` | `{}` (pjsua_acc_modify; re-registers) |
| `account.remove` | `{acc|uid}` | `{}` (unregisters, deletes); always ends with an `account.reg` event whose `regState` is `unregistered` |
| `account.register` | `{acc|uid, register:b}` | `{}`; true sends REGISTER/refresh, false unregisters |
| `account.setPresence` | `{acc|uid, status:"online\|away\|busy\|dnd\|onthephone\|offline", note?:s}` | `{}` |
| `account.list` | `{}` | `{accounts:[AccountInfo]}` |
| `account.info` | `{acc|uid}` | `AccountInfo` |

AccountConfig:
```json
{
  "uid": "8c1e…",                    // required, stable app-side id
  "proto": "sip",                    // sip | iax2
  "displayName": "Alice", "username": "1001", "authUser": null, "password": "secret",
  "domain": "pbx.example.com",       // host[:port]
  "registrar": null,                 // override, e.g. "sip:pbx.example.com:5080"; default sip:<domain>
  "proxies": [],                     // outbound proxies, e.g. ["sip:proxy.example.com;lr"]
  "regUseProxy": 3,                  // pjsua reg_use_proxy bitmask (1 outbound, 2 acc proxy)
  "transport": "udp",                // udp | tcp | tls | ws | wss | auto   (ws/wss = SIP over WebSocket, RFC 7118, §8)
  "wsPath": "/ws",                   // ws/wss only: HTTP path of the WebSocket upgrade (starts with "/", <=120 chars)
  "rtcpFb": false,                   // offer RTP/AVPF (SAVPF, UDP/TLS/RTP/SAVPF) + a=rtcp-fb:* nack (WebRTC servers)
  "register": true, "regExpires": 300, "regRetrySec": 30, "regFirstRetrySec": 5,
  "regRetryRandomSec": 10, "regDelayBeforeRefreshSec": 5, "unregTimeoutMs": 4000,
  "dropCallsOnRegFail": false,
  "keepAliveSec": 15,                // UDP keep-alive only (TCP/TLS keep-alive is compile-time 90 s)
  "localPort": 0,                    // >0 = dedicated transport bound to this port for this account
  "contactUseSrcPort": true,
  "publishPresence": false, "mwi": true, "mwiExpires": 3600,
  "watcherPolicy": "accept",         // accept | reject incoming presence SUBSCRIBE
  "referPolicy": "accept",           // accept | reject incoming REFER
  "redirect": "auto",                // auto | ask | reject  (3xx handling; ask → call.redirected event)
  "srtp": "off",                     // off | optional | mandatory
  "srtpSecureSignaling": 0,          // 0 none, 1 TLS hop, 2 TLS end-to-end (sips)
  "srtpKeying": ["sdes"],            // ordered subset of sdes | dtls
  "srtpCryptos": [],                 // empty = all; names as in transport_srtp.c, e.g. "AES_CM_128_HMAC_SHA1_80"
  "ice": false, "rtcpMux": false,
  "turn": {"enabled": false, "server": "", "username": "", "password": "", "transport": "udp"},
  "useStun": true,
  "contactRewrite": true, "viaRewrite": true, "sdpNatRewrite": false,
  "sipOutbound": false,              // RFC 5626
  "sessionTimers": "optional",       // off | optional | required | always
  "timerSe": 1800,
  "use100rel": false,
  "holdType": "rfc3264",             // rfc3264 (a=sendonly) | rfc2543 (c=0.0.0.0)
  "lockCodec": true,                 // re-INVITE to lock a single codec after multi-codec answer
  "streamKeepAlive": true,
  "dtmfMethod": "rfc2833",           // rfc2833 | info | inband | auto
  "codecs": [],                      // ordered codec ids for this account (empty = global order); filtered in on_call_sdp_created
  "callerId": null,                  // From user override
  "privacy": false,                  // anonymous From + Privacy: id header
  "headers": {},                     // extra headers on REGISTER and INVITE
  "userAgent": null,                 // per-account UA (core clears the global UA header and adds it per request)
  "authAlgorithm": "auto",           // auto | md5 | sha256
  "ipv6Sip": "disabled", "ipv6Media": "disabled",   // disabled | enabled | preferIpv4 | preferIpv6
  "ipChange": {"shutdownTransport": true, "hangupCalls": false, "reinvite": true, "useUpdate": false},
  "dscp": {"sip": 24, "rtp": 46},
  "voicemailNumber": null,           // informational; Dart dials it
  "iax": {"host": "", "port": 4569, "context": null}   // proto=iax2 only; uses username/password
}
```
**SIP DSCP (`dscp.sip`, `transports.dscpSip`, applies only when `transports.qos` is true).** PJSIP sockets are
shared between accounts, so the precise behaviour is:

* UDP, account with its own transport (`localPort` > 0): the account owns the socket; `dscp.sip` is applied exactly
  (IP_TOS / IPV6_TCLASS = dscp<<2) on add and on `account.modify`.
* UDP, shared transport (no `localPort`, `transport:"udp"`): the socket starts at `transports.dscpSip` (default
  24); adding or modifying an account re-marks the shared socket with that account's `dscp.sip` (last add/modify
  wins, applies to every account sharing the socket).
* TCP / TLS / WS / WSS shared transports: marked at `core.start` with `transports.dscpSip`; per-account
  `dscp.sip` cannot change a per-connection socket afterwards (own TCP/TLS transports get the account value at creation).
* On Apple platforms the OS maps DSCP to a coarse service class for TCP; exact bits are guaranteed for UDP only.
* `dscp.rtp` is per account and applies to that account's RTP sockets.

Numeric AccountConfig fields are range-checked (`INVALID_PARAM` otherwise):
`regExpires` 10..86400, `regRetrySec` / `regFirstRetrySec` 0..86400,
`regRetryRandomSec` / `regDelayBeforeRefreshSec` / `keepAliveSec` 0..3600 (the
last: 0 = off), `unregTimeoutMs` 0..60000, `mwiExpires` 0..86400,
`srtpSecureSignaling` 0..2, `regUseProxy` 0..3, `timerSe` 90..86400,
`localPort` 0..65535, `dscp.*` 0..63 (`dscp.rtp` default 46, `dscp.sip` default 24). The same ranges apply to IAX2 accounts
(`iax.port` 0..65535). `core.start` validates `media.rtpPort` +
`media.rtpPortRange` <= 65535, `media.jb.*` >= -1, the timers
(`incomingAutoRingMs`, `incomingUnattendedMs`, `statsIntervalMs`) and the
nameserver addresses (IPv4 or IPv6 literals) before anything is created.

AccountInfo, which is also the payload of the `account.reg` event:
```json
{"acc":0,"uid":"…","proto":"sip","uri":"sip:1001@pbx","regState":"registered",
 "regCode":200,"regReason":"OK","status":0,"statusText":"Success","lastError":null,
 "expires":295,"online":true,"isUnreg":false,"contact":"<sip:1001@1.2.3.4:5060;ob>",
 "transport":"udp","resolvedServer":null,"presence":"online","isLan":false,"isDirect":false}
```
* `account.add` with `register:true` does not emit a separate `account.reg`.
  The first one is pjsua's own `registering` event.
* `regState` is one of `none` · `registering` · `registered` ·
  `unregistering` · `unregistered` · `failed`.
* `lastError` is a human-readable reason, for example "Wrong
  username/password (403)", "Timeout (408)", "TLS certificate not
  trusted", "TLS client certificate required by the server (set
  tlsClientCert): …", "Server rejected the TLS client certificate: …", or
  "DNS lookup failed".
* `transport` is the transport in use. For `transport:"auto"` accounts it
  is `"auto"` until the first SRV lookup completes, then `udp`, `tcp` or `tls`.
  `resolvedServer` is `"host:port"` of the chosen SRV target for auto
  accounts (or the registrar host and default port when no SRV lookup was
  needed or possible), and `null` for every other account.

### call.*
Every call request identifies the call by `cid` (u64).

| method | params | result |
|---|---|---|
| `call.make` | `{acc|uid, uri:s, headers?:{}, displayName?:s, anonymous?:b}` | `{cid, call}`; `acc:-1` = direct account (IP calls) |
| `call.answer` | `{cid, code?:i=200, headers?:{}}` | `{}`; 183 sends an early-media answer with SDP; 180/181 carry no SDP |
| `call.ring` | `{cid}` | `{}` (sends 180 Ringing; idempotent) |
| `call.reject` | `{cid, code?:i=486, reason?:s, headers?:{}}` | `{}` |
| `call.redirect` | `{cid, targets:[s], code?:i=302}` | `{}` (Contact header with the targets) |
| `call.processRedirect` | `{cid, action:"accept\|acceptReplace\|reject\|stop"}` | `{}` (answer to `call.redirected` when the account's redirect = ask) |
| `call.hangup` | `{cid, code?:i}` | `{}` |
| `call.hangupAll` | `{}` | `{}` |
| `call.hold` | `{cid, music?:{file:s, loop?:b=true, volume?:f=1.0}}` | `{}`; disconnects both bridge directions, then re-INVITEs using the account's holdType. With `music`, plays a file to the held party (section 9.3) |
| `call.unhold` | `{cid}` | `{}` (re-INVITE sendrecv, then reconnects ports as before the hold) |
| `call.mute` | `{cid, mute:b}` | `{}` (disconnects or reconnects mic → call) |
| `call.setLevels` | `{cid, rx?:f=1.0, tx?:f=1.0}` | `{}` |
| `call.dtmf` | `{cid, digits:s, method?:s, durationMs?:i=160}` | `{}`; rfc2833/info through pjsua; inband through a tone generator connected to the call port |
| `call.transfer` | `{cid, target:s}` | `{}` (blind REFER) |
| `call.transferAttended` | `{cid, destCid:u64, requireReplaces?:b=true}` | `{}`; REFERs `cid`'s peer to the party on `destCid` (Replaces) |
| `call.pickup` | `{acc|uid, uri:s, replaces:{callId:s, toTag:s, fromTag:s}, headers?:{}}` | `{cid, call}`; INVITE with Replaces (BLF pickup) |
| `call.bridge` | `{a:u64, b:u64, bridge:b}` | `{}`; connects or disconnects the media of two calls in both directions |
| `call.detachLocal` | `{cid, detached:b}` | `{}`; true disconnects the local mic/speaker from this call (relay handoff) |
| `call.conference` | `{cids:[u64]}` | `{}`; full-mesh connect with the local mic/speaker; unholds held calls |
| `call.unconference` | `{cids:[u64]}` | `{}` |
| `call.recordStart` | `{cid, file:s, mix?:"both\|remote\|local"="both", format?:"wav\|wavStereo\|opus"="wav"}` | `{file}`; see section 9.4 |
| `call.recordStop` | `{cid}` | `{file, durationMs, format, bytes}`; returns only after the file is finalised |
| `call.update` | `{cid, useUpdate?:b=false}` | `{}` (re-INVITE/UPDATE: refreshes media/contact) |
| `call.sendRequest` | `{cid, method:s, headers?:{}, body?:s, contentType?:s}` | `{}`; in-dialog request. Only `INFO`, `MESSAGE`, `NOTIFY` and `OPTIONS` are allowed; anything that changes the dialog or INVITE session (`BYE`, `INVITE`, `ACK`, `CANCEL`, `PRACK`, `UPDATE`, `REFER`, ...) is `INVALID_PARAM` - use the dedicated `call.*` methods. |
| `call.info` | `{cid}` | `CallInfo` |
| `call.stats` | `{cid}` | `CallStats` |
| `call.list` | `{}` | `{calls:[CallInfo]}` |
| `call.playFile` | `{cid, file:s, loop?:b=false, volume?:f=1.0, localMonitor?:b=false, muteMic?:b=false}` | `{playId}`; plays a WAV or MP3 into the call (section 9.2) |
| `call.stopFile` | `{cid, playId?:i}` | `{stopped:i}` (section 9.2) |

**Custom headers** (`headers` on `call.make`, `call.answer`, `call.reject`, `call.pickup`,
`call.sendRequest` and the account-level `headers`): names must be SIP tokens
(letters, digits and `-.!%*_+`'~`), values must not contain CR, LF or NUL and
are limited to 4 KB. The headers the stack owns - `Via`, `CSeq`, `Call-ID`,
`Content-Length`, `Content-Type`, `From`, `To`, `Route`, `Record-Route`,
`Contact`, `Max-Forwards` (and their compact forms) - cannot be set; any
violation fails the request with `INVALID_PARAM`. `userAgent`, `displayName`,
`username`, `domain`, `registrar`, `authUser` and `callerId` must not contain
control characters.

`call.make` and `call.pickup` return only after the call has a `cid`; they never
answer `ok` with `cid: 0` (a call that is already gone fails with `PJ_ERROR`).

CallInfo:
```json
{"cid":42,"call":0,"acc":0,"uid":"…","proto":"sip","role":"caller|callee",
 "state":"calling|incoming|early|connecting|confirmed|disconnected",
 "stateCode":180,"stateReason":"Ringing","lastCode":180,
 "remoteUri":"sip:1002@pbx","remoteContact":"<sip:…>","remoteDisplay":"Bob","remoteUser":"1002",
 "localUri":"sip:1001@pbx","callId":"SIP Call-ID","localTag":"…","remoteTag":"…",
 "media":"none|active|localHold|remoteHold|bothHold|error","codec":"opus/48000/2",   // bothHold reserved (not emitted yet)
 "srtp":false,"secureSignaling":false,"muted":false,"announcementMuted":false,"recording":false,"detached":false,
 "held":false,"conferenceWith":[43],"bridgedWith":[],
 "connectMs":0,"totalMs":0,"headers":{"Call-Info":"…"}}
```

CallStats:
```json
{"cid":42,"codec":"PCMU/8000/1","clockRate":8000,"ptime":20,
 "rx":{"packets":1500,"bytes":240000,"lost":3,"lossPct":0.2,"discard":0,"reorder":0,"dup":0,
       "jitterMs":4.1,"jitterMaxMs":12,"lossPeriodMs":20},
 "tx":{"packets":1500,"bytes":240000,"lost":0,"lossPct":0,"jitterMs":2.0},
 "rtt":{"lastMs":38,"minMs":30,"avgMs":36,"maxMs":51},
 "jb":{"prefetch":3,"size":4,"avgDelayMs":40,"maxDelayMs":80,"burst":2,"empty":0,"discard":0},
 "mos":4.3,"rxLevel":120,"txLevel":90,
 "srtp":false,"crypto":null,"ice":{"state":"none|completed|failed","localType":"host","remoteType":"srflx"},
 "localRtp":"1.2.3.4:4000","remoteRtp":"5.6.7.8:12000"}
```
* `mos` uses the E-model (ITU-T G.107 simplified: Ie per codec, loss,
  jitter-buffer delay and RTT).
* `rxLevel` and `txLevel` range from 0 to 255.

### media.*
Devices are identified by a stable string `devId` = `"<driver>:<name>"`.
Special ids:
* `"default"` = OS default
* `"null"` = null device (clock without hardware)
* `"none"` = release audio (`pjsua_set_no_snd_dev`; manual sndMode only)

| method | params | result |
|---|---|---|
| `media.devices` | `{}` | `{capture:[Dev], playback:[Dev], current:{capture:s, playback:s, ringer:s}}`; Dev = `{devId:s,name:s,driver:s,inputs:i,outputs:i,isDefault:b}` |
| `media.setDevices` | `{capture?:s, playback?:s}` | `{}`; uses `pjsua_set_snd_dev2`, so it doesn't open immediately when there are no calls. If opening fails, falls back to `"null"` and emits `media.error`. |
| `media.refreshDevices` | `{}` | `{}` (pjmedia_aud_dev_refresh, then a `media.devicesChanged` event) |
| `media.codecs` | `{}` | `{codecs:[{id:s,name:s,clockRate:i,channels:i,priority:i,enabled:b}]}` |
| `media.setCodecPriority` | `{id:s, priority:i}` | `{}`; 0 disables; up to 255 |
| `media.setCodecPriorities` | `{order:[s], disableOthers?:b=false}` | `{}` |
| `media.setCodecParam` | `{id:s, ptime?:i, vad?:b, fmtp?:{}, opus?:{bitrate:i, fec:b, dtx:b, cbr:b, complexity:i, maxPlaybackRate:i}}` | `{}` |
| `media.setEc` | `{algo:s, tailMs:i, ns:b, agc:b}` | `{}` |
| `media.levels` | `{}` | `{mic:i, speaker:i}` (0–255) |
| `media.setMicLevel` | `{level:f}` | `{}` (0.0–2.0) |
| `media.setSpeakerLevel` | `{level:f}` | `{}` |
| `media.tone` | `{kind:"ringback\|busy\|congestion\|dial\|waiting\|dtmf", digits?:s, loop?:b}` | `{}`; local tone to the speaker. `waiting` is the call-waiting beep. |
| `media.toneStop` | `{}` | `{}` |
| `media.ringStart` | `{file?:s, devId?:s="default", loop?:b=true, volume?:f=1}` | `{}`; separate ringer sound port (desktop); with no file, a built-in synthesized ring |
| `media.ringStop` | `{}` | `{}` |
| `media.loopback` | `{enabled:b}` | `{}`; mic → speaker echo test |
| `media.fileInfo`, `media.recordMicStart`, `media.recordMicStop` | | see section 9.2 |

### buddy.* (presence and BLF)
| method | params | result |
|---|---|---|
| `buddy.add` | `{acc|uid, uri:s, presence?:b=true, blf?:b=false}` | `{buddy:i}`. pjsua picks the sending account from the buddy URI's domain, so `acc`/`uid` is used only for URI normalisation. |
| `buddy.subscribe` | `{buddy:i, presence?:b, blf?:b}` | `{}` |
| `buddy.remove` | `{buddy:i}` | `{}` |
| `buddy.list` | `{}` | `{buddies:[BuddyInfo]}` |
| `buddy.refresh` | `{buddy:i}` | `{}` |

BuddyInfo:
```json
{"buddy":3,"acc":0,"uid":"…","uri":"sip:1002@pbx",
 "presence":{"status":"unknown|online|offline|away|busy|onthephone","note":"","subState":"active"},
 "blf":{"state":"unknown|idle|early|confirmed|terminated","subState":"active",
        "dialogs":[{"id":"…","state":"early","direction":"initiator|recipient","callId":"…",
                    "localTag":"…","remoteTag":"…","remote":"sip:1003@pbx","local":"sip:1002@pbx",
                    "durationSec":12}]}}
```
* The core parses the dialog-info XML itself, so it handles several
  dialogs per NOTIFY.
* The BLF `state` is the most significant dialog's state, ranked
  confirmed > early > terminated/idle.

### im.*
| method | params | result |
|---|---|---|
| `im.send` | `{acc|uid, to:s, body:s, contentType?:s="text/plain", msgId?:s}` | `{}`; delivery is reported through `im.status` (echoes msgId) |
| `im.typing` | `{acc|uid, to:s, typing:b}` | `{}` |

### diag.*
| method | params | result |
|---|---|---|
| `diag.natType` | `{}` | `{}` → `diag.natType` event |
| `diag.resolve` | `{host:s, srv?:b, transport?:"udp\|tcp\|tls"}` | `{addresses:[s], srv:[{target,port,priority,weight}]}`; never blocks the worker (the response is sent when the lookup completes). If the lookup has not finished after 5 s the request fails with `TIMEOUT`. `srv:true` without a DNS resolver (no nameservers) is `UNSUPPORTED`. |
| `diag.optionsPing` | `{acc|uid, target?:s}` | `{}` → `diag.options` event `{code, reason, rttMs}`; an unanswered ping reports `code:408` after 5 s |

## 3. Events

| event | fields |
|---|---|
| `core.started` | `{version}` |
| `core.stopped` | `{}` |
| `core.ipChangeProgress` | `{op:"restartListener\|shutdownTransport\|reregister\|reinvite\|done", status, acc?, cid?}` |
| `log` | `{level, msg}` |
| `sip.trace` | `{dir:"rx\|tx", transport:"UDP\|TCP\|TLS\|WS\|WSS", local:"ip:port", remote:"ip:port", len, msg}` |
| `transport.state` | `{transport:"udp\|tcp\|tls\|ws\|wss", local, remote, state:"connected\|disconnected\|shutdown", status, tls?:{verifyStatus:[s], cipher, remoteCert:{subject,issuer,notAfter,sha256}}}` |
| `transport.tlsVerify` | `{host, sha256, verifyStatus:[s], subject, issuer}`; a handshake was rejected. The UI may pin the cert (`core.setTlsPins`) and re-register. Pins match on the certificate SHA-256; the pin's `host` field is advisory. |
| `account.reg` | AccountInfo |
| `account.mwi` | `{acc, uid, waiting:b, newMsgs:i, oldMsgs:i, urgentNew:i, urgentOld:i, account?:s, solicited:b}` |
| `account.incomingSubscribe` | `{acc, uid, from, accepted:b}` |
| `call.incoming` | CallInfo + `{headers:{Call-Info, Alert-Info, Answer-Mode, Referred-By, X-*, ...}, replacesCid?:u64, autoAnswerHint?:{afterSec:i, source:"callInfo\|alertInfo\|answerMode", require:b}}` |
| `call.state` | `{cid, call, acc, uid, proto, role, state, stateCode, stateReason, lastCode, remoteUri, remoteDisplay, remoteUser, connectMs, totalMs}` |
| `call.media` | `{cid, media, codec, srtp, crypto, secureSignaling, ice}`; `srtp` = media is SRTP-protected, `secureSignaling` = the call's SIP signalling runs over TLS or WSS (or a `sips:` target). The two are independent (SRTP over UDP: `srtp:true, secureSignaling:false`; TLS without SRTP: the reverse). Same semantics in `call.state`/CallInfo. |
| `call.dtmf` | `{cid, digit, method:"rfc2833\|info", durationMs}` (in-band receive is not supported in v1) |
| `call.transferRequest` | `{cid, target, referredBy, accepted:b}`; incoming REFER. The call created by the REFER announces itself with its own events, and its `call.state` events carry `transferFrom:<cid>`. |
| `call.transferStatus` | `{cid, code, reason, final:b}` |
| `call.replaced` | `{oldCid, newCid}` |
| `call.redirected` | `{cid, target, code}`; only when the account's redirect = ask |
| `call.recording` | `{cid, recording:b, file, format?:s}` (`format` on start) |
| `call.playDone` | `{cid, playId, file, reason:"eof\|stopped\|hangup\|error", moh?:true}`; section 9.2 |
| `call.stats` | CallStats (periodic, when statsIntervalMs > 0) |
| `buddy.state` | BuddyInfo |
| `im.incoming` | `{acc, uid, from, fromDisplay, to, body, contentType, isLan:b}` |
| `im.status` | `{acc, uid, to, msgId, code, reason, ok:b}` |
| `im.typing` | `{acc, uid, from, typing:b}` |
| `media.devicesChanged` | `{}` |
| `media.error` | `{op, status, message, fallback:"null"\|null}` |
| `diag.natType` | `{natType:"unknown\|open\|blocked\|symmetricUdp\|fullCone\|symmetric\|restricted\|portRestricted", description, stun}` |
| `diag.options` | `{acc, uid, code, reason, rttMs}` |

Every call satisfies these invariants (tests assert them):
1. `call.incoming` precedes any other event for an incoming cid.
2. Each cid gets exactly one terminal `call.state` with `disconnected`, and
   no events for that cid follow it.
3. Events caused by a request precede that request's response.

### Auto-answer hint parsing (native)
| header | example | result |
|---|---|---|
| `Call-Info` | `<sip:x>;answer-after=N` | afterSec N |
| `Alert-Info` | `<…>;info=alert-autoanswer[;delay=N]` | afterSec N or 0 |
| `Alert-Info` | `Auto Answer`, `Ring Answer`, `intercom` | 0 |
| `Answer-Mode` | `Auto[;require]` | 0, with require |

The decision to auto-answer is made in Dart policy, not in native code.

## 4. URI normalisation (native)
`call.make` and `im.send` accept these forms:
* a full `sip:`, `sips:` or `tel:` URI;
* `user`, which becomes `sip:user@<acc domain>`;
* `user@host`, which becomes `sip:user@host`;
* an IP literal, which becomes `sip:<ip>` for the direct account.

`;transport=` is appended to match the account transport when the target has
no transport parameter and the account uses TCP, TLS, WS or WSS.
Phone-number cleanup is done by Dart dial rules.

`sips:` targets: they are accepted only on TLS accounts (`transport` `tls`,
or an `auto` account), and on the direct account when the TLS listener is
enabled. On any other account, `call.make` fails with `INVALID_PARAM` ("sips:
URIs need a TLS account …"). No `;transport=` is appended to a `sips:` URI
(sips implies TLS, default port 5061). For a `sips:` request the core also
promotes the `Contact` to `sips:` (RFC 3261 26.2.2), as PBXs such as Asterisk
answer `480 SIPS Required` otherwise. See §9.6.

## 5. Sound device modes
* **auto** (desktop, Android): pjsua opens the sound device when a call's
  media becomes active and auto-closes it about 1 s after the last call
  (`snd_auto_close_time = 1`).
* **manual** (iOS, mandatory with CallKit):
  * The core starts in `pjsua_set_no_snd_dev()` and never opens the device
    by itself.
  * Dart sends `media.setDevices {capture:"default", playback:"default"}`
    from `provider:didActivate:` and `{capture:"none", playback:"none"}`
    from `didDeactivate`.
  * While calls have active media and no device is set, the core attaches
    the **null device**, so the conference bridge keeps its clock. Relay
    handoff and recording keep working.
* **Tests:** `noAudioDevice:true` forces the null device.

## 6. Native-side mechanics allowed in callbacks
* Auto-180 timer: `pjsua_schedule_timer2`. If Dart already responded, it
  ignores `PJSIP_ESESSIONSTATE`.
* Auto-reject 480 when unattended.
* Applying `referPolicy`, `watcherPolicy` and `redirect=auto|reject`.
* Restoring conference/bridge connections after unhold and after a media
  update (`on_call_media_state` re-applies the stored topology).
* Picking the account for incoming calls: `on_acc_find_for_incoming`
  routes by receiving transport for the LAN and direct accounts.

## 7. IAX2 (proto "iax2")
* **Accounts:**
  * `account.add` with `proto:"iax2"` returns `{acc, localPort}`. IAX2
    account ids start at 1000 and share the `account.*` namespace and the
    uid space with SIP.
  * Config fields used: `username`, `password`, `domain` (or `iax.host`),
    `iax.port` (default 4569), `iax.context` (sent as CALLED_CONTEXT),
    `codecs` (subset of `PCMU/8000/1`, `PCMA/8000/1`, `GSM/8000/1`, in
    order), `callerId`, `displayName`, `regExpires`, `regRetrySec`,
    `regFirstRetrySec`, `register`.
  * Registration failures report `regCode` 403 ("Wrong username/password
    (403)"), 408 ("Timeout (408)") or 502 ("DNS lookup failed").
* **Socket:** `core.start` accepts `iax:{port:4569, enabled:true}`. One UDP
  socket is shared by all IAX2 accounts and calls. It is created lazily, and
  falls back to a random port if 4569 is busy.
* **Calls:**
  * IAX2 calls carry `proto:"iax2"`, a `call` slot of 1000 or more, and a
    normal global `cid`.
  * The codec is one of `PCMU/8000/1`, `PCMA/8000/1` or `GSM/8000/1`.
    `srtp` is always false and `remoteContact` is empty.
  * `call.incoming.headers` carries `X-IAX-Called-Number`, `X-IAX-Context`
    and `X-IAX-Username`.
* **Shared requests:** IAX2 calls join the same conference bridge as SIP
  calls. These requests therefore work for both protocols: `call.mute`,
  `hold`, `unhold`, `conference`, `bridge`, `detachLocal`, `recordStart`,
  `recordStop`, `playFile`, `setLevels`, `stats`, `dtmf` and `hangup`.
* **DTMF:** the `call.dtmf` event's `method` can also be `"iax2"`. A
  `call.dtmf` request with any method except `inband` is sent as native
  IAX2 DTMF frames.
* **Transfer and unsupported requests:** `call.transfer` sends an IAX
  TRANSFER and emits `call.transferStatus {code:202, final:false}`. The
  call ends when the PBX drops our leg. `call.transferAttended`,
  `call.update`, `call.redirect`, `call.processRedirect` and
  `call.sendRequest` return `UNSUPPORTED` for IAX2.
* **Stats:** `rtt` comes from PING/PONG, and `jitterMs` is an RFC 3550-style
  estimate. IAX2 has no RTCP, so `tx.lost` is 0 and `rx.lost` is the jitter
  buffer's loss count.
* **Limitations (v1):**
  * IPv4 only.
  * No trunk or meta frames, no RSA auth, no IAX encryption, and no native
    media transfer (TXREQ is refused).
  * No MWI.
  * Remote hold is reported only when the peer sends a HOLD control frame.

## 8. SIP over WebSocket (transport "ws" / "wss")
* **Server and connection:**
  * The server is the registrar host[:port] (else the domain). The default
    port is 80 for ws and 443 for wss, and the HTTP path is `wsPath`.
  * All accounts on the same server host:port share one connection and one
    path.
* **Addressing:**
  * Contact is `<sip:user@<random>.invalid;transport=ws|wss>`.
  * Contact/Via rewriting, `sipOutbound` and UDP `keepAliveSec` don't apply.
  * Requests the server sends are accepted on the same connection. The
    remote-target Contact of dialog-forming messages is re-pointed at that
    connection.
* **TLS:** wss uses `transports.tls` (verifyServer, caFile, certFile/keyFile,
  minProto) and `core.setTlsPins`, even when the TLS listener is disabled.
* **Liveness and limits:**
  * The WebSocket is pinged every 30 s and dropped after 75 s of silence.
  * Messages over 8000 bytes, protocol violations and handshake failures
    close the connection, and pjsua re-registers on a new connection.
* **`transport.state`:**
  * `transport` is `"ws"` or `"wss"`.
  * `connected` is reported after the WebSocket upgrade completes (for wss,
    after TLS and then the upgrade).
  * `disconnected` is reported on handshake failure, a peer Close, a drop, a
    timeout or a protocol violation.
  * `local` is the `.invalid` host with port 0.
* **`sip.trace`:** `transport` is `WS` or `WSS`.
* **WebRTC servers** (Asterisk `webrtc=yes`, FreeSWITCH, Kamailio): set
  `srtp:"mandatory"`, `srtpKeying:["dtls"]`, `ice:true`, `rtcpMux:true` and
  `rtcpFb:true`.
* **Limitation:** `core.start` still needs at least one of udp/tcp/tls
  enabled.

## 9. Voice isolation, media files, announcements, recording formats (contract v1.1)

### 9.1 Voice isolation (AI noise suppression)
Noise suppression uses RNNoise v0.1.1 (BSD-3, compiled-in model), bundled in spcore
(`native/third_party/rnnoise`).

Each processor is a port in the conference bridge. The bridge feeds it with `put_frame`
and reads the result back on the next 20 ms clock tick, so a processor adds one
bridge frame plus about 14 ms of RNNoise look-ahead and resampler delay (about 35 ms
in total). The work runs on the conference clock thread; enable and strength changes
are atomic and never take a lock that is held across a pjsua call.
* **Microphone path:** one processor, fed from the sound-device port (slot 0). The
  topology code uses a "mic source" slot that is either slot 0 or this processor,
  for every mic-to-call and mic-to-recorder connection. Mute, hold, detach, conference,
  bridge and recording semantics are unchanged. The processor is connected only while
  isolation is enabled and at least one call exists. Anything that connects the mic
  to something else must use `spc_call_mic_source()`.
* **Incoming path:** one processor per call, between the call's port and the speaker
  (slot 0). It is created on first use and destroyed with the call.
* **Format:** RNNoise works on 48 kHz, 10 ms frames. The core resamples from the bridge
  rate (any rate where 20 ms maps to a whole number of 48 kHz samples, which covers
  8/16/24/32/44.1/48 kHz) and back, with libresample's large filter (unity gain).
* **Cost:** about 160 us of CPU per 10 ms frame on Apple M2 (about 1.6% of one core)
  per processor, with the mic and each call counted separately.

`strength` (0.0–1.0, default 1.0) blends the original and denoised signal, and also
attenuates non-speech frames by up to `30 dB × strength`, using RNNoise's
voice-activity probability. The attenuation uses a 120 ms hangover so word endings are
kept, a fast open and a slow close, and is applied as a per-sample ramp, so there are
no clicks. At strength 0 the signal passes through the resamplers only, delayed.

| method | params | result |
|---|---|---|
| `media.setVoiceIsolation` | `{mic?:{enabled?:b, strength?:f}, incoming?:{enabled?:b, strength?:f}}` | `{available:b, engine:"rnnoise"}`. Takes effect live, for current and future calls, without dropping audio (the new path is connected before the old one is removed). Omitted parts and omitted fields are unchanged. `INVALID_PARAM` for a non-boolean `enabled`, a `strength` outside 0..1 or non-object parts; nothing is changed in that case. |
| `media.voiceIsolationStatus` | `{}` | `{available, engine, mic:{enabled, strength, vad:f}, incoming:{enabled, strength}}`; `vad` is the latest speech probability (0–1) of the microphone processor, 0 while it is off. For UI meters. |

`core.start` media accepts `voiceIsolation` with the same shape (`INVALID_PARAM` if
malformed). The default is off, and the setting does not survive `core.stop`.

**Limitations**
* Incoming isolation shapes the local speaker path only. The recording, a conference or
  bridge relay to other calls, and the call's own media statistics (`rxLevel`) see the
  unprocessed audio. This is deliberate: recordings stay faithful, and the other party
  of a bridged call is not affected by the local user's preference.
* The mic processor is shared by all calls and recorders, so it is a mono, bridge-rate
  signal; `wavStereo` recordings and other code that taps the mic must go through
  `spc_call_mic_source()` to get the isolated mic.
* RNNoise is trained on speech; music and tones are treated as noise and are
  suppressed at high strength.
* Warm-up: the first ~0.5 s after a processor starts reduces noise less (the model state
  and gain smoothing converge).
* Test builds (`-DSPC_TEST_HOOKS=ON`) add the hidden method
  `__denoise.processFile {in, out, strength}` which runs a processor offline on a mono PCM16 WAV
  (the output is delayed by the processor latency) and returns the CPU cost per 10 ms frame.

### 9.2 Media files and playback
`call.playFile`, music on hold and `media.fileInfo` accept:
* **WAV** (RIFF/RF64 container): PCM 8/16/24/32 bit, IEEE float32, µ-law, A-law
  (also `WAVE_FORMAT_EXTENSIBLE` with these sub-formats), 1 to 8 channels, any
  sample rate from 1 kHz to 384 kHz. A `data` chunk with a wrong or zero size is
  clamped to the file size.
* **MP3** (MPEG-1/2/2.5 Layer III, mono or stereo, CBR or VBR, with or without
  ID3 tags), decoded with minimp3 (CC0, vendored).

Multi-channel audio is down-mixed to mono (average) and resampled to the
conference-bridge rate with a windowed-sinc resampler (8 zero crossings, 
anti-aliased when down-sampling). Decoding runs on a helper thread per play; the
bridge's clock thread only copies decoded samples from memory, so it never
waits for file I/O. If decoding is momentarily behind playback (huge file, slow
disk), silence is played until samples are ready. **Limits:** 30 minutes of
audio and 200 MB (the decoded PCM16 at the bridge rate for all formats; MP3 input files are
additionally capped at 64 MB); longer files are rejected with `INVALID_PARAM`. At most 16 concurrent
plays per call.

| method | params | result |
|---|---|---|
| `call.playFile` | `{cid, file:s, loop?:b=false, volume?:f=1.0, localMonitor?:b=false, muteMic?:b=false}` | `{playId:i}` |
| `call.stopFile` | `{cid, playId?:i}` | `{stopped:i}` |
| `media.fileInfo` | `{file:s}` | `{format:"wav\|mp3", durationMs, sampleRate, channels}`; works before `core.start`; `INVALID_PARAM` if the file is unreadable, unsupported or too long |
| `media.recordMicStart` | `{file:s}` | `{file}` |
| `media.recordMicStop` | `{}` | `{file, durationMs, format:"wav", bytes}` |

**`call.playFile`**
* `playId` is unique per engine run (positive integer, never reused).
  Several plays can run on one call at the same time; they are mixed by the
  bridge. The file is validated when the request is made: an unreadable,
  unsupported, empty or too long file, or a bad parameter, is `INVALID_PARAM`
  (no play is created). `volume` is a linear gain, 0 to 4.
* The audio goes to the call's transmit path (the remote party hears it). It
  is connected while the call media is active and the call is not on hold;
  while the call is on hold the play is silent (it keeps running). Files played
  into a call are not part of `call.recordStart` recordings.
* `localMonitor: true` also plays the file to the speaker (conference slot 0).
* `muteMic: true` removes the microphone from the call while this file plays
  and restores it afterwards. This is an **announcement mute**, separate from
  the user's `call.mute`: the microphone reaches the call only if neither is
  set. `CallInfo.announcementMuted` is true while at least one `muteMic` play is
  running (overlapping plays keep it set until the last one ends). Ending an
  announcement never unmutes a user who muted, and a user's `call.mute` during
  the announcement does not end it.
* When the play ends, the event `call.playDone {cid, playId, file, reason}` is
  emitted exactly once per play:
  `eof` (finished, not looping), `stopped` (`call.stopFile`, music stopped by
  unhold or conference merge), `hangup` (the call ended; emitted before the
  terminal `call.state`), `error` (the decoder failed mid-file). Music on hold
  adds `moh: true`; a music file that cannot be started after the hold was
  acknowledged emits `playDone` with `playId: 0` and `reason: "error"`.

**`call.stopFile`** stops the play `playId`, or every non-music play on the call
when `playId` is omitted. `stopped` is the number of plays stopped (0 is not an
error: the play may have ended on its own). Music on hold is only stopped by
`call.unhold`, hangup or a conference merge, or by `playId` of the music play.

**`media.recordMicStart` / `media.recordMicStop`** record the microphone source
(the raw microphone, or the voice-isolation output while isolation is active
and a call exists) to a mono PCM16 WAV at the bridge rate, for example a user
recorded announcement. They work without a call: the sound device (or the
null device when `noAudioDevice` is set) is opened if needed. Only one
microphone recording can run (`ALREADY`). Silence is inserted by wall clock if
the device delivers no frames, so `durationMs` matches the elapsed time. The
recording is finalised by `core.stop` too. **Limitation:** with no call in
progress the raw microphone (slot 0) is recorded even if voice isolation is on.

### 9.3 Music on hold (client side)
`call.hold {cid, music?:{file:s, loop?:b=true, volume?:f=1.0}}`.
* `music` is validated first (`INVALID_PARAM` leaves the call unheld). The hold
  re-INVITE then goes out as usual (sendonly, or the account's holdType); we
  keep transmitting. When the re-INVITE has been acknowledged (media state
  `localHold`, event `call.media`), the engine starts a player on that call; if
  the hold fails, no music starts. Calling `call.hold` again on a held call
  with `music` starts the music at once.
* Music stops on `call.unhold`, hangup (`playDone` with `reason: "hangup"`) or
  when the call is merged into a conference (`call.conference`). `playDone`
  carries `moh: true`. A non-looping file ends with `reason: "eof"`; the call
  stays on hold.
* With no `music`, the call holds normally and the PBX can play its own
  hold music. Through a PBX that answers a hold request itself (Asterisk), the
  far end hears the PBX music, not ours; client-side music is for direct calls
  and PBXs that relay the held party's audio.
* A call that the remote party holds (media `remoteHold`) still delivers its
  audio to the speaker and recorders, so a SoftphonePro peer hears the holder's
  music. IAX2 calls have no media-state acknowledgement: the music starts as
  soon as the hold request succeeded.

### 9.4 Recording formats
`call.recordStart` adds a format: `{cid, file, mix?, format?:"wav"|"wavStereo"|"opus"}`.
An unknown format is `INVALID_PARAM`; `opus` is `UNSUPPORTED` in a build without
libopus. The file is created when the request is made (unwritable path:
`INVALID_PARAM`). Start and stop emit `call.recording` (it carries `format` on
start). Hangup and `core.stop` finalise the file.

| format | content |
|---|---|
| `wav` (default) | Mono PCM16 at the bridge rate. `mix` applies. Written by pjsua's WAV recorder. |
| `wavStereo` | Stereo PCM16 at the bridge rate. Left = local microphone source (what is sent to the call; silent while `call.mute` is on), right = the remote party. `mix` is ignored. |
| `opus` | Ogg Opus (RFC 7845 / RFC 6716): mono, Opus VOIP application, signal type voice, VBR about 24 kbps, 20 ms packets. Input is resampled to 48 kHz; granule positions are at 48 kHz, so players report the exact duration (the encoder lookahead is in `pre-skip`; the last packet is trimmed by the final granule position). `OpusHead` and `OpusTags` are on their own pages, pages are about 1 s long, the last page has EOS, and every page carries the Ogg CRC32. `mix` applies as for `wav`. The extension should be `.ogg` or `.opus`. |

`wavStereo` and `opus` use sink ports in the conference bridge that feed a
writer thread (the bridge clock thread never touches the file). The writer pads
a side that receives no frames with silence by wall clock (after 100 ms), so
the two channels of a stereo file stay frame aligned and the file duration
matches the recording time.

`call.recordStop` returns `{file, durationMs, format:"wav|wavStereo|opus", bytes}` after the
file is finalised: `durationMs` is the recorded audio length (from the written
samples for `wavStereo`, `opus` and the microphone recorder; read from the WAV
header for `wav`), `bytes` the file size. Playing a file into the call
(`call.playFile`) is not part of any recording.

### 9.5 Caller identity (CallInfo additions)
Present in `call.incoming`, `call.state` and `call.info`:
* **`assertedIdentity`:** `{display, user, uri}` or `null`.
  * `P-Asserted-Identity` (RFC 3325). When there are several values (in one header or in
    several), a `sip:`/`sips:` value is preferred over `tel:`; otherwise the first. For a
    `tel:` URI, `user` is the number without parameters.
  * With no PAI: `Remote-Party-ID` (first value). Its `privacy` parameter is honoured:
    `full` hides the identity, `name` clears `display`, `uri` clears `uri` and `user`.
  * `Privacy: id` (RFC 3325) hides a PAI.
* **`identityWithheld`:** `true` if an identity was present but is hidden by one of the
  privacy rules above (then `assertedIdentity` is `null`). UIs should show "Anonymous".
* **`diversion`:** `[{uri, user, reason, counter}]`, earliest diversion first, at most 8.
  * From `Diversion` headers (RFC 5806). The topmost value is the most recent diversion,
    so the list is reversed. `reason` is the `reason` parameter (`user-busy`, `no-answer`,
    `unconditional`, ...), `""` if absent; `counter` is the `counter` parameter (1..999,
    default 1).
  * With no `Diversion`: `History-Info` (RFC 7044), ordered by `index` (dotted numeric).
    Entry *n* diverted to entry *n+1*, so the final entry (the current target) is not
    listed; `reason` comes from the `cause` of the next entry's embedded `Reason`
    (302 → `unconditional`, 486/600/603 → `user-busy`, 408/480 → `no-answer`,
    404/410/503 → `unavailable`, 487 → `deflection`, otherwise the number); `counter`
    counts earlier entries with the same URI.
  * If both are present, `Diversion` wins.
* **`referredBy`:** the URI of the `Referred-By` header of the incoming INVITE (calls that
  result from a transfer), else `null`. It is separate from the `referredBy` field of the
  `call.transferRequest` event, which comes from the REFER.

Sources: for incoming calls the identity is parsed once from the INVITE. For outgoing
calls, only `assertedIdentity` is taken, from 18x (180 and above) and 2xx responses; the
latest response that carries one wins, and a later response without PAI keeps the value.
Re-INVITE and UPDATE requests are not examined.

Hostile-input handling: at most 64 headers are scanned, 1 KB of each header value and 24
values per header kind are examined, fields are truncated (display 95, user 95, uri 199,
reason 39 bytes) and control characters are stripped. Quoted strings and angle brackets
are respected when splitting comma-separated values. Malformed values are skipped.
The raw headers are also still in `headers` of `call.incoming`.

### 9.6 Accounts: TLS client certificates and automatic transport
AccountConfig additions:

| field | meaning |
|---|---|
| `tlsClientCert: {certFile:s, keyFile:s, password?:s}` | Mutual TLS: the account presents this PEM certificate (chain) and key. `password` decrypts an encrypted key. `null` removes it on `account.modify`. |
| `transport: "auto"` | The core picks the transport from DNS SRV records (below). |

#### tlsClientCert
* **Where it applies:** accounts with `transport` `tls`, `wss` or `auto`
  (for `auto` it is used when TLS is chosen). With `udp`, `tcp` or `ws` the
  request fails (`INVALID_PARAM`: "tlsClientCert needs transport tls, wss or auto").
* **tls:** the account gets a dedicated TLS transport. It binds to `localPort`
  if set, else to a random port. It uses its own certificate, and the same
  CA, protocol minimum, `verifyServer` and `core.setTlsPins` policy as the
  global TLS transport. The account is bound to it, like the transport of an
  account with `localPort`. The transport is closed when the account is
  removed, or modified so that it no longer needs it. It is re-created when the
  certificate files, their modification times, the password or `localPort` change.
* **wss:** the certificate is presented on each WebSocket TLS connection to
  the account's server (`host:port`). It is held per server route, not per account. If
  two wss accounts use the same server `host:port` with different
  certificates, the last one added or modified wins.
* **Validation at `account.add` / `account.modify`:** both files must be
  readable and be PEM. The key must decrypt with `password`; the engine never prompts on a terminal. The key must match
  the certificate. Otherwise the request fails with `INVALID_PARAM` and a
  specific message ("… is not readable", "… is not a valid PEM certificate",
  "… cannot be decrypted (missing or wrong password)", "… does not match
  certFile …"). A failed `account.modify` leaves the account unchanged.
  Later file problems (for example an expired certificate) show up as a
  registration failure.
* **Server refuses the connection:** a server that requires a client
  certificate and gets none (or a rejected one) ends the TLS handshake. The
  account goes to `regState:"failed"` with `lastError` "TLS client
  certificate required by the server (set tlsClientCert): …" or "Server
  rejected the TLS client certificate: …".
* The certificate is not read for the global `transports.tls.certFile`;
  that one still serves the TLS listener and wss accounts without their own.

#### transport: "auto"
The core chooses `tls`, `tcp` or `udp` for the account, then configures it as if the
app had set that transport. Registration starts after the choice.

1. **Lookup name:** the `registrar` host if set, otherwise the `domain`.
2. **No DNS lookup is done** (the choice is made at once, synchronously) when:
   * the registrar has a `transport=` parameter (`udp|tcp|tls`) or a `sips:`
     scheme (that transport / `tls` is used);
   * the host is an IP literal or has an explicit port (RFC 3263 skips SRV);
     transport is `udp`;
   * no DNS resolver is configured (`nameservers: []`): `udp`, port 5060,
     with a log note.
3. **Otherwise** the core queries `_sips._tcp`, `_sip._tcp` and `_sip._udp`
   under the name, in parallel, using the PJSIP resolver (`nameservers`).
   * The most preferred transport that has at least one SRV record wins:
     `tls`, then `tcp`, then `udp`.
   * `resolvedServer` is the SRV record of the winning transport with
     the lowest priority number (highest weight breaks ties) as
     `target:port`.
   * With no SRV record at all: `udp`, `<name>:5060`, with a log note.
   * The lookup is bounded: a transport whose query has not answered after 4 s is
     treated as having no records.
4. **The actual connection** is made by PJSIP's own SRV handling once the transport
   is fixed (`;transport=` on the registrar URI, and on outgoing calls): it follows SRV priority and weight
   among all targets and falls back to the next target.
   `resolvedServer` only reports the primary one.
5. **Never blocks the worker.** `account.add` returns at once. The lookup runs on the
   resolver; the result is applied on a timer thread through an internal
   account modify. Until then `regState` is `registering` (or `none` with
   `register:false`), `transport` is `"auto"`, `resolvedServer` is `null`, and no
   REGISTER is sent. With `register:false` the account is configured but not
   registered; `account.register` registers it later.
6. **Events:** every change is reported as `account.reg` (`transport`,
   `resolvedServer`). `transport.state` shows the real connection.
7. **Re-resolution:** on `core.handleIpChange` (after the nameservers are
   refreshed), and on `account.modify`. The previous result stays visible while
   the new lookup runs. If the result is unchanged nothing else happens. If it
   changed, the account is reconfigured and re-registers. `account.remove` cancels a pending lookup.
8. **tlsClientCert** applies when `tls` is chosen.
9. **Limitations:** the resolver caches answers for their TTL and
   negative answers for 60 s (PJSIP default), so a changed DNS zone may
   take that long to be seen by a re-resolution. `ws`/`wss` are never
   chosen automatically. `account.modify` of any field re-runs the lookup.

#### sips: targets
See §4. `sips:` works for TLS accounts: the INVITE goes over TLS and
`secureSignaling` is `true`. On other accounts it is rejected with a clear
error. Tests: `native/tests/test_n3.py` (`TestSips`).

#### Tests and test PBX
* The Asterisk test PBX has a second TLS listener, port **5062**, that
  requires a client certificate signed by the test CA
  (`tests/sipserver/certs/client.crt`, `client.key`, and `client-enc.key`,
  the same key encrypted with password `secret`). See `tests/sipserver/README.md`.
* `native/tests/dns_stub.py` is a stdlib UDP DNS responder (A, SRV) used by the
  `auto` tests. Start the core with `nameservers:["127.0.0.1:<port>"]`.

