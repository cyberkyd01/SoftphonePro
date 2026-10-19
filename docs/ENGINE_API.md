# spcore Engine API (contract v1)

This is the single source of truth shared by `native/` (C), `packages/spcore_dart`
(Dart) and its tests. Any change must be made here first.

## 1. C ABI (`native/include/spcore.h`)

```c
#define SPC_API_VERSION 1
SPC_API int32_t     spc_api_version(void);                 // returns SPC_API_VERSION
SPC_API const char* spc_version_string(void);              // static string, e.g. "1.0.0 (pjsip 2.17)"
SPC_API intptr_t    spc_init_dart_api(void* data);         // = Dart_InitializeApiDL(data); 0 on success
SPC_API int32_t     spc_init(int64_t dart_port);           // start worker; events go to this port; 0 ok
SPC_API int32_t     spc_set_event_callback(void (*cb)(const char* json, void* user), void* user);
                                                           // alternative sink for C tools; NULL to clear
SPC_API int64_t     spc_request(const char* method, const char* params_json);
                                                           // async; returns request id (>0) or <0 on error
SPC_API char*       spc_request_sync(const char* method, const char* params_json, int32_t timeout_ms);
                                                           // blocks; returns malloc'd response JSON (same shape as below)
SPC_API void        spc_free(char* p);
SPC_API void        spc_shutdown(void);                    // destroys pjsua, joins worker; safe to call twice
```

* Every message sent to the Dart port is a **JSON string** (`Dart_CObject_kString`).
* `params_json` may be `NULL` or `""`, meaning `{}`.
* Requests execute in FIFO order on the worker thread. You may call
  `spc_request*` from any thread.
* Calling `spc_init` a second time without `spc_shutdown` returns
  `-EALREADY` (-114) and does nothing. `core.start` must be the first
  request; every other request before it fails with `NOT_STARTED`.

### Response message
```json
{"type":"response","id":17,"ok":true,"result":{...}}
{"type":"response","id":17,"ok":false,"error":{"code":"INVALID_PARAM","status":70004,"message":"..."}}
```
Error codes: `INVALID_PARAM`, `NOT_FOUND`, `NOT_STARTED`, `ALREADY`, `PJ_ERROR`
(with `status`, the pj_status_t), `TIMEOUT`, `UNSUPPORTED`, `INTERNAL`.

### Event message
```json
{"type":"event","event":"call.state","ts":1729312345123, ...fields}
```
`ts` is Unix time in milliseconds.

## 2. Requests

Field types: `s`=string, `i`=int, `b`=bool, `f`=float, `[]`=array, `{}`=object.
`?` marks an optional field; its default is shown after `=`.

### core.*
| method | params | result |
|---|---|---|
| `core.start` | see below | `{version, pjsip, transports:[{id,type,local:"ip:port",ipv6:b}], lan:{transportUdp,transportTcp,acc,port}?}` |
| `core.stop` | `{}` | `{}` (equivalent to destroy, keeps worker; core.start may be called again) |
| `core.info` | `{}` | `{version, pjsip, started:b, accounts:i, calls:i, natType?:s}` |
| `core.setLogLevel` | `{level:i(0-6), forward:b}` | `{}`; when `forward` is set, log lines are sent as `log` events |
| `core.setSipTrace` | `{enabled:b}` | `{}` |
| `core.handleIpChange` | `{}` | `{}`; calls `pjsua_handle_ip_change` (restarts transports, re-registers, updates contacts, re-INVITEs calls) |
| `core.setUserAgent` | `{userAgent:s}` | `{}` |

`core.start` params:
```json
{
  "userAgent": "SoftphonePro/1.0",
  "logLevel": 3, "logForward": false, "sipTrace": false,
  "logFile": null,
  "nameservers": ["8.8.8.8"],            // optional; empty = OS resolver (sync, via getaddrinfo)
  "stunServers": ["stun.l.google.com:19302"],
  "stunIgnoreFailure": true,
  "maxCalls": 16,
  "incomingAutoRingMs": 1500,            // 0 = never auto-ring
  "transports": {
    "udp": {"port": 5060, "enabled": true},     // port 0 = random; if busy, falls back to random
    "tcp": {"port": 5060, "enabled": true},
    "tls": {"port": 5061, "enabled": true, "verifyServer": false, "caFile": null,
            "certFile": null, "keyFile": null, "method": "tlsv1_2+"},
    "ipv6": false,
    "qos": true                                 // DSCP: SIP=CS3/signalling, RTP=EF/voice
  },
  "lan": {"enabled": true, "port": 0, "deviceId": "ab12cd34"},  // creates local account + UDP/TCP transports
  "media": {
    "clockRate": 0, "sndClockRate": 0,         // 0 = auto (16000 conf bridge)
    "channelCount": 1,
    "ec": {"algo": "auto", "tailMs": 200, "ns": true, "agc": false},
          // algo: auto|aec3|webrtc|speex|simple|platform|none
          // auto = platform on iOS/macOS/Android if available, else aec3, else speex, else simple
    "vad": false, "quality": 8, "ptime": 20,
    "jb": {"initMs": -1, "minPreMs": -1, "maxPreMs": -1, "maxMs": -1},
    "rtpPort": 4000, "rtpPortRange": 0,
    "noAudioDevice": false                      // true = null device (tests/headless)
  }
}
```

### account.*
| method | params | result |
|---|---|---|
| `account.add` | AccountConfig | `{acc:i}` |
| `account.modify` | `{acc:i, ...AccountConfig}` | `{}` (pjsua_acc_modify; re-registers) |
| `account.remove` | `{acc:i}` | `{}` (unregisters, deletes) |
| `account.register` | `{acc:i, register:b}` | `{}`; true sends REGISTER/refresh, false unregisters |
| `account.setPresence` | `{acc:i, status:"online\|away\|busy\|dnd\|onthephone\|offline", note?:s}` | `{}` |
| `account.list` | `{}` | `{accounts:[AccountInfo]}` |
| `account.info` | `{acc:i}` | `AccountInfo` |

AccountConfig:
```json
{
  "uid": "8c1e…",                    // required, stable app-side id, echoed in events
  "proto": "sip",                    // sip | iax2
  "displayName": "Alice", "username": "1001", "authUser": null, "password": "secret",
  "domain": "pbx.example.com",       // SIP domain/realm host[:port]
  "registrar": null,                 // override, e.g. "sip:pbx.example.com:5080"; default sip:<domain>
  "proxies": [],                     // outbound proxies, e.g. ["sip:proxy.example.com;lr"]
  "transport": "udp",                // udp | tcp | tls | ws | wss | auto
  "register": true, "regExpires": 300, "regRetrySec": 30, "regFirstRetrySec": 5,
  "keepAliveSec": 15,                // UDP keep-alive (0 = off)
  "localPort": 0,                    // >0 = dedicated transport bound to this port for this account
  "publishPresence": false, "mwi": true, "mwiExpires": 3600,
  "srtp": "off",                     // off | optional | mandatory
  "srtpSecureSignaling": 0,          // 0 none, 1 TLS hop, 2 TLS end-to-end (sips)
  "dtls": false,                     // use DTLS-SRTP keying (else SDES)
  "ice": false, "rtcpMux": false,
  "turn": {"enabled": false, "server": "", "username": "", "password": "", "tcp": false, "tls": false},
  "useStun": true,
  "contactRewrite": true, "viaRewrite": true, "sdpNatRewrite": false,
  "sipOutbound": false,              // RFC 5626
  "sessionTimers": "optional",       // off | optional | required | always
  "timerSe": 1800,
  "use100rel": false,
  "dtmfMethod": "rfc2833",           // rfc2833 | info | inband | auto
  "codecs": [],                      // ordered codec ids for this account (empty = global order)
  "callerId": null,                  // overrides the From user part (P-Preferred-Identity is not used)
  "headers": {},                     // extra headers added to REGISTER and INVITE
  "userAgent": null,                 // per-account UA override (sent as a custom User-Agent header)
  "ipv6": false,
  "voicemailNumber": null,           // informational; Dart dials it
  "iax": {"host": "", "port": 4569, "context": null}  // proto=iax2 only; uses username/password
}
```
AccountInfo:
```json
{"acc":0,"uid":"…","proto":"sip","uri":"sip:1001@pbx","regState":"registered",
 "regCode":200,"regReason":"OK","expires":295,"online":true,"contact":"<sip:1001@1.2.3.4:5060;ob>",
 "transport":"udp","presence":"online","isLan":false}
```
`regState` is one of: `none` (register=false) · `registering` · `registered` · `unregistering` · `unregistered` · `failed`.

The LAN local account appears with `isLan:true` and `uid:"__lan__"`. It is
not created by `account.add`.

### call.*
| method | params | result |
|---|---|---|
| `call.make` | `{acc:i, uri:s, headers?:{}, video?:b=false, displayName?:s}` | `{call:i}` |
| `call.answer` | `{call:i, code?:i=200, headers?:{}}` | `{}` (code 180/183 sends a provisional response) |
| `call.ring` | `{call:i}` | `{}` (sends 180 Ringing) |
| `call.reject` | `{call:i, code?:i=486, reason?:s}` | `{}` |
| `call.redirect` | `{call:i, target:s, code?:i=302}` | `{}` (adds a Contact: target) |
| `call.hangup` | `{call:i, code?:i}` | `{}` |
| `call.hangupAll` | `{}` | `{}` |
| `call.hold` | `{call:i}` | `{}` |
| `call.unhold` | `{call:i}` | `{}` (re-INVITE with UPDATE_CONTACT, sendrecv) |
| `call.mute` | `{call:i, mute:b}` | `{}` (disconnects or reconnects mic → call) |
| `call.setLevels` | `{call:i, rx?:f=1.0, tx?:f=1.0}` | `{}` (per-call conference port levels) |
| `call.dtmf` | `{call:i, digits:s, method?:s, durationMs?:i=160}` | `{}`; method defaults to the account dtmfMethod |
| `call.transfer` | `{call:i, target:s}` | `{}` (blind REFER) |
| `call.transferAttended` | `{call:i, dest:i}` | `{}`; REFER `call`'s peer to the party on `dest`, using Replaces |
| `call.bridge` | `{a:i, b:i, bridge:b}` | `{}`; connects or disconnects the media of two calls in both directions |
| `call.detachLocal` | `{call:i, detached:b}` | `{}`; true disconnects local mic/speaker from this call |
| `call.conference` | `{calls:[i]}` | `{}`; full-mesh connect of the calls with the local mic/speaker; unholds as needed |
| `call.unconference` | `{calls:[i]}` | `{}`; removes the mesh (each call only to local) |
| `call.recordStart` | `{call:i, file:s}` | `{file}`: a WAV of the mix (local mic + remote) |
| `call.recordStop` | `{call:i}` | `{file, durationMs}` |
| `call.info` | `{call:i}` | `CallInfo` |
| `call.stats` | `{call:i}` | `CallStats` |
| `call.list` | `{}` | `{calls:[CallInfo]}` |
| `call.sendInfo` | `{call:i, contentType:s, body:s}` | `{}` |
| `call.playFile` | `{call:i, file:s, loop?:b}` | `{}`; plays a WAV into the call |
| `call.stopFile` | `{call:i}` | `{}` |

CallInfo:
```json
{"call":0,"acc":0,"uid":"…","proto":"sip","role":"caller|callee",
 "state":"calling|incoming|early|connecting|confirmed|disconnected",
 "stateCode":180,"stateReason":"Ringing","lastCode":180,
 "remoteUri":"sip:1002@pbx","remoteContact":"<sip:…>","remoteDisplay":"Bob","remoteUser":"1002",
 "localUri":"sip:1001@pbx","callId":"SIP Call-ID",
 "media":"none|active|localHold|remoteHold|bothHold|error","codec":"opus/48000/2",
 "srtp":false,"secure":false,"muted":false,"recording":false,"detached":false,
 "conferenceWith":[1],"bridgedWith":[],
 "connectMs":0,"totalMs":0,"headers":{"Call-Info":"…"}}
```
`connectMs` is the connected duration so far. `totalMs` counts from the first event.

CallStats:
```json
{"call":0,"codec":"PCMU/8000/1","clockRate":8000,"ptime":20,
 "rx":{"packets":1500,"bytes":240000,"lost":3,"lossPct":0.2,"discard":0,"jitterMs":4.1,"jitterMaxMs":12},
 "tx":{"packets":1500,"bytes":240000,"lost":0,"lossPct":0,"jitterMs":2.0},
 "rttMs":38,"mos":4.3,"rxLevel":120,"txLevel":90,"srtp":false,"ice":false,
 "localRtp":"1.2.3.4:4000","remoteRtp":"5.6.7.8:12000"}
```
`mos` is computed with the E-model (ITU-T G.107 simplified, from loss, jitter
and RTT). `rxLevel` and `txLevel` range from 0 to 255.

### media.*
| method | params | result |
|---|---|---|
| `media.devices` | `{}` | `{capture:[Dev], playback:[Dev], current:{capture:i, playback:i}}`; Dev = `{id:i,name:s,driver:s,inputs:i,outputs:i,default:b}` |
| `media.setDevices` | `{capture:i, playback:i}` | `{}`; -1 = OS default, -99 = null device, -98 = no device (release audio, used for iOS CallKit) |
| `media.refreshDevices` | `{}` | `{}` (pjmedia_aud_dev_refresh) |
| `media.codecs` | `{}` | `{codecs:[{id:s,name:s,clockRate:i,channels:i,priority:i,enabled:b}]}` |
| `media.setCodecPriority` | `{id:s, priority:i}` | `{}`; 0 disables; up to 255 |
| `media.setCodecPriorities` | `{order:[s], disableOthers?:b=false}` | `{}`; the first gets 255, each next one less |
| `media.setEc` | `{algo:s, tailMs:i, ns:b, agc:b}` | `{}` |
| `media.levels` | `{}` | `{mic:i, speaker:i}` (0–255, of the main conference port) |
| `media.setMicLevel` | `{level:f}` | `{}` (0.0–2.0) |
| `media.setSpeakerLevel` | `{level:f}` | `{}` |
| `media.tone` | `{kind:"ringback\|busy\|congestion\|dial\|waiting\|dtmf", digits?:s, loop?:b}` | `{}`; local tone generator to the speaker |
| `media.toneStop` | `{}` | `{}` |
| `media.ringStart` | `{file?:s, device?:i=-1, loop?:b=true, volume?:f=1}` | `{}`; separate ringer device; with no file, a built-in synthesized ring |
| `media.ringStop` | `{}` | `{}` |
| `media.loopback` | `{enabled:b}` | `{}`; mic → speaker echo test |

### buddy.* (presence and BLF)
| method | params | result |
|---|---|---|
| `buddy.add` | `{acc:i, uri:s, presence?:b=true, blf?:b=false}` | `{buddy:i}` |
| `buddy.remove` | `{buddy:i}` | `{}` |
| `buddy.list` | `{}` | `{buddies:[BuddyInfo]}` |
| `buddy.refresh` | `{buddy:i}` | `{}` |

BuddyInfo:
`{buddy, acc, uri, presence:{status:"unknown|online|offline|away|busy|onthephone", note, subState}, blf:{state:"unknown|idle|early|confirmed|terminated", direction?:"initiator|recipient", remote?:s, subState}}`

### im.*
| method | params | result |
|---|---|---|
| `im.send` | `{acc:i, to:s, body:s, contentType?:s="text/plain", msgId?:s}` | `{}`; delivery is reported with an `im.status` event that echoes `msgId` |
| `im.typing` | `{acc:i, to:s, typing:b}` | `{}` |

### diag.*
| method | params | result |
|---|---|---|
| `diag.natType` | `{}` | `{}`; the result arrives as a `diag.natType` event |
| `diag.resolve` | `{host:s, srv?:b}` | `{addresses:[s], srv:[{target,port,priority,weight}]}` |
| `diag.optionsPing` | `{acc:i, target?:s}` | `{}`; result in a `diag.options` event `{code, reason, rttMs}` |

## 3. Events

| event | fields |
|---|---|
| `core.started` | `{version}` |
| `core.stopped` | `{}` |
| `log` | `{level, msg}` (only when log forwarding is on) |
| `sip.trace` | `{dir:"rx\|tx", transport:"UDP\|TCP\|TLS\|WS\|WSS", local:"ip:port", remote:"ip:port", len, msg}` |
| `account.reg` | `{acc, uid, proto, regState, code, reason, expires, online}` |
| `account.mwi` | `{acc, uid, waiting:b, newMsgs:i, oldMsgs:i, urgentNew:i, urgentOld:i, account?:s}` |
| `account.incomingSubscribe` | `{acc, uid, from}`; auto-accepted (presence watchers) |
| `call.incoming` | CallInfo + `{headers:{all non-standard + Call-Info, Alert-Info, Answer-Mode, X-*}, replacesCall?:i, autoAnswerHint:{afterSec:i}?}` |
| `call.state` | CallInfo (subset: call, acc, uid, proto, role, state, stateCode, stateReason, lastCode, remoteUri, remoteDisplay, remoteUser, connectMs, totalMs) |
| `call.media` | `{call, media, codec, srtp, secure, ice}` |
| `call.dtmf` | `{call, digit, method:"rfc2833\|info\|inband", durationMs}` |
| `call.transferRequest` | `{call, target}` (incoming REFER; already accepted) |
| `call.transferStatus` | `{call, code, reason, final:b}` |
| `call.replaced` | `{oldCall, newCall}` |
| `call.recording` | `{call, recording:b, file}` |
| `buddy.state` | BuddyInfo |
| `im.incoming` | `{acc, uid, from, fromDisplay, to, body, contentType, isLan:b}` |
| `im.status` | `{acc, to, msgId, code, reason, ok:b}` |
| `im.typing` | `{acc, from, typing:b}` |
| `media.devicesChanged` | `{}` |
| `diag.natType` | `{type:"unknown\|open\|blocked\|symmetricUdp\|fullCone\|symmetric\|restricted\|portRestricted", description, stun}` |
| `diag.options` | `{acc, code, reason, rttMs}` |

Two invariants hold for every call:
* Each call emits exactly one terminal `call.state` with
  `state:"disconnected"`, and after that the call id may be reused.
* `call.incoming` is always emitted before any `call.state` for that
  incoming call.

## 4. URI normalisation (native)

`call.make` and `im.send` accept these forms:
* a full `sip:`, `sips:` or `tel:` URI;
* `user`, which becomes `sip:user@<acc domain>`;
* `user@host`, which becomes `sip:user@host`.

`;transport=` is appended to match the account transport when the target has
no transport parameter and the account uses TCP, TLS, WS or WSS.
Phone-number cleanup, such as removing spaces and dashes, is done in Dart by
the dial rules.
