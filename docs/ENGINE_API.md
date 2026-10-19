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
                                         // [] = OS resolver only (getaddrinfo, no SRV); ["8.8.8.8",…] = explicit
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
 "transport":"udp","presence":"online","isLan":false,"isDirect":false}
```
* `account.add` with `register:true` does not emit a separate `account.reg`.
  The first one is pjsua's own `registering` event.
* `regState` is one of `none` · `registering` · `registered` ·
  `unregistering` · `unregistered` · `failed`.
* `lastError` is a human-readable reason, for example "Wrong
  username/password (403)", "Timeout (408)", "TLS certificate not
  trusted", or "DNS lookup failed".

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
| `call.hold` | `{cid}` | `{}`; disconnects both bridge directions, then re-INVITEs using the account's holdType |
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
| `call.recordStart` | `{cid, file:s, mix?:"both\|remote\|local"="both"}` | `{file}` WAV PCM16 at the bridge clock rate |
| `call.recordStop` | `{cid}` | `{file, durationMs}`; returns only after the WAV file is finalised |
| `call.update` | `{cid, useUpdate?:b=false}` | `{}` (re-INVITE/UPDATE: refreshes media/contact) |
| `call.sendRequest` | `{cid, method:s, headers?:{}, body?:s, contentType?:s}` | `{}`; in-dialog request. Only `INFO`, `MESSAGE`, `NOTIFY` and `OPTIONS` are allowed; anything that changes the dialog or INVITE session (`BYE`, `INVITE`, `ACK`, `CANCEL`, `PRACK`, `UPDATE`, `REFER`, ...) is `INVALID_PARAM` - use the dedicated `call.*` methods. |
| `call.info` | `{cid}` | `CallInfo` |
| `call.stats` | `{cid}` | `CallStats` |
| `call.list` | `{}` | `{calls:[CallInfo]}` |
| `call.playFile` | `{cid, file:s, loop?:b}` | `{}`; plays a WAV into the call (the remote party hears it) |
| `call.stopFile` | `{cid}` | `{}` |

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
 "srtp":false,"secureSignaling":false,"muted":false,"recording":false,"detached":false,
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
| `call.recording` | `{cid, recording:b, file}` |
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
Noise suppression uses RNNoise (BSD-3), bundled in spcore.
* **Microphone path:** a processing port is inserted between the sound-device
  port (slot 0) and every call. The topology code uses a "mic source" slot
  that is either slot 0 or the denoise port.
* **Incoming path:** an optional processing port per call, placed between
  the call's port and the speaker.
* **Format:** RNNoise works on 48 kHz, 10 ms frames. Resampling to and from
  the bridge rate is internal.

`strength` (0.0–1.0) blends the original and denoised signal, and also
attenuates non-speech frames by up to `30 dB × strength`, using RNNoise's
voice-activity probability.

| method | params | result |
|---|---|---|
| `media.setVoiceIsolation` | `{mic?:{enabled:b, strength:f}, incoming?:{enabled:b, strength:f}}` | `{available:b, engine:"rnnoise"}`. Takes effect live, for current and future calls. Omitted parts are unchanged. |
| `media.voiceIsolationStatus` | `{}` | `{mic:{enabled, strength, vad:f}, incoming:{enabled, strength}}`; `vad` is the latest speech probability (0–1), for UI meters |

`core.start` media accepts `voiceIsolation` with the same shape. The default
is off.

### 9.2 Media files and playback
`call.playFile` and music on hold accept these formats:
* WAV: PCM16, µ-law or A-law, mono or stereo, any rate;
* MP3, decoded with minimp3 (CC0).

| method | params | result |
|---|---|---|
| `call.playFile` | `{cid, file:s, loop?:b=false, volume?:f=1.0, localMonitor?:b=false, muteMic?:b=false}` | `{playId:i}`. `localMonitor` also plays the file to the local speaker. `muteMic` mutes the mic towards this call while the file plays and restores it afterwards. |
| `call.stopFile` | `{cid, playId?:i}` | `{}`; with no playId, stops all playback on the call |
| `media.fileInfo` | `{file:s}` | `{format:"wav\|mp3", durationMs, sampleRate, channels}`, or `INVALID_PARAM` if the file is unreadable or unsupported |
| `media.recordMicStart` | `{file:s}` | `{file}`. Records only the microphone to WAV, for example a user-recorded announcement. Works with no call (opens the sound device). |
| `media.recordMicStop` | `{}` | `{file, durationMs}` |

New event: `call.playDone {cid, playId, file, reason:"eof|stopped|hangup|error"}`.

### 9.3 Music on hold (client side)
`call.hold {cid, music?:{file:s, loop?:b=true, volume?:f=1.0}}`.
* The hold re-INVITE uses `sendonly`, so we still transmit. After the hold
  is acknowledged, the core connects a looping player to the held call.
* Music stops on unhold, hangup or conference merge.
* With no `music`, the call holds normally, and the PBX can play its own
  hold music.

### 9.4 Recording formats
`call.recordStart` adds a format: `{cid, file, mix?, format?:"wav"|"wavStereo"|"opus"}`.

| format | content |
|---|---|
| `wav` (default) | Mono PCM16 at the bridge rate. `mix` applies. |
| `wavStereo` | Left channel = local microphone, right channel = remote party. `mix` is ignored. |
| `opus` | Ogg Opus, mono, about 24 kbps, 48 kHz granule, with `mix` semantics. The file extension should be `.ogg` or `.opus`. |

`call.recordStop` returns `{file, durationMs, format, bytes}`.

### 9.5 Caller identity (CallInfo additions)
* **`assertedIdentity`:** `{display, user, uri}` or null. It comes from
  `P-Asserted-Identity`, or from `Remote-Party-ID` (privacy honoured).
* **`diversion`:** `[{uri, user, reason, counter}]`, taken from `Diversion`
  or `History-Info`. Earliest diversion first.
* **`referredBy`:** the `Referred-By` URI, for calls that result from a
  transfer.

### 9.6 Accounts: TLS client certificates and automatic transport
AccountConfig additions:

| field | meaning |
|---|---|
| `tlsClientCert: {certFile:s, keyFile:s, password?:s}` | Mutual TLS. The account gets a dedicated TLS transport that presents this certificate. Also used for wss. |
| `transport: "auto"` | The core picks the transport from DNS. It tries the SRV records `_sips._tcp` (tls), then `_sip._tcp` (tcp), then `_sip._udp` (udp), in order of preference, and falls back to udp/5060. The result appears in `AccountInfo.transport` and `AccountInfo.resolvedServer`. |
