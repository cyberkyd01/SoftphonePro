# SoftphonePro — Architecture

SoftphonePro is a free, open-source (GPL-3.0-or-later) SIP/IAX2 softphone for
Windows, macOS, Android and iOS. One Flutter UI codebase is compiled to native
machine code on every platform. All signalling and media run in one C core,
`spcore`, built on PJSIP 2.17. Platform-specific behaviour such as background
service, CallKit, ConnectionService, tray and URL handlers lives in thin
native layers written in Kotlin, Swift and C++.

```
┌──────────────────────────────── Flutter app (app/) ────────────────────────────────┐
│  UI (Material 3, adaptive desktop/mobile)                                          │
│  Controllers (Riverpod): Accounts · Calls · History · Contacts · Messages ·        │
│  Presence/BLF · Settings · DialRules · Provisioning · Diagnostics · LAN Link       │
│  Persistence: sembast (history, contacts, messages, settings) + secure storage     │
│  Platform services (MethodChannel): Android FG service / ConnectionService /       │
│  audio routing · iOS CallKit · desktop tray, hotkeys, URL scheme, notifications    │
├──────────────────────── packages/spcore_dart (pure Dart) ──────────────────────────┤
│  SipEngine (abstract)  ←  FfiSipEngine (dart:ffi)   |   FakeSipEngine (tests/UI)    │
│  Typed models + JSON codec of the Engine API (docs/ENGINE_API.md)                   │
├──────────────────────── packages/spcore_flutter (FFI plugin) ──────────────────────┤
│  Bundles prebuilt libspcore for android/ios/macos/windows                           │
├──────────────────────────────── native/ (C, spcore) ────────────────────────────────┤
│  spc_request(method,json) → worker thread queue → pjsua API                          │
│  events → Dart_PostCObject_DL(port, json string)                                     │
│  modules: core · account · call · media · presence/BLF/MWI · IM · SIP trace ·         │
│           ringer · diagnostics · IAX2 client · SIP-over-WebSocket transport           │
│  PJSIP 2.17 (pjsua C API) + OpenSSL 3 + Opus + bcg729(G.729) + WebRTC AEC3/platform AEC│
└──────────────────────────────────────────────────────────────────────────────────────┘
```

## 1. Key decisions

| Topic | Decision | Why |
|---|---|---|
| UI | Flutter 3.32 (Dart 3.8), Material 3 | One codebase compiled AOT to native ARM/x64 for all 4 OSes; professional UI with no per-platform duplication. |
| SIP/media | PJSIP 2.17 `pjsua` C API | Mature (used by MicroSIP, Telephone, CSipSimple). Covers multi-account, UDP/TCP/TLS, IPv6, SRTP/DTLS, ICE/STUN/TURN, BLF (2.16+), MWI, presence, IM, REFER/Replaces, conference bridge, recording, AEC3, Opus and G.729. GPLv2+. |
| Native↔Dart | One JSON request entry point plus an async event stream (`Dart_PostCObject_DL`) | Tiny, stable FFI surface. Dart never blocks: requests run on a dedicated native worker thread. Events are copied into Dart, so ownership is simple and nothing leaks. |
| TLS/DTLS | OpenSSL 3.x on every platform | DTLS-SRTP and SHA-256 digest need OpenSSL. One backend means the same behaviour everywhere. |
| Build | CMake for spcore. pjproject uses its CMake build where it works (macOS, Linux, Android, iOS); Windows tries CMake first and falls back to the MSVC .sln. | Reproducible scripts under `native/scripts/`, also run in CI. |
| Packaging | Classic Flutter FFI plugin (`spcore_flutter`) with prebuilt binaries | Native-assets hooks are not stable in Flutter 3.32. |
| Persistence | `sembast` (pure Dart) + `flutter_secure_storage` (with an encrypted-file fallback) | No native DB libraries to ship. Works on all 4 OSes. |
| State | `flutter_riverpod` | Testable controllers; UI tests drive them with `FakeSipEngine`. |
| LAN features | Pure Dart (`dart:io`): mDNS (bonsoir) + UDP multicast fallback, encrypted WebSocket link (X25519 + AES-GCM), and direct SIP via a pjsua local account | Cross-platform with no server. |

## 2. Repository layout

```
native/                 C core
  include/spcore.h      public C API (FFI)
  src/                  spc_*.c modules
  third_party/          cJSON, dart_api_dl
  config/config_site.h  PJSIP compile-time config
  scripts/              fetch_deps.sh, build_{macos,ios,android,linux}.sh, build_windows.ps1
  tools/spcore_cli.c    JSON-lines CLI harness (manual + scripted testing)
packages/spcore_dart/   pure Dart engine API + FFI implementation + fake + tests
packages/spcore_flutter/ FFI plugin that bundles libspcore per platform
app/                    Flutter application
tests/sipserver/        Asterisk 20 test PBX (Docker): SIP UDP/TCP/TLS/WS(S), IAX2, VM/MWI, BLF, park, pickup, confbridge
.github/workflows/      CI: native builds, tests, app builds, release artifacts (EXE, DMG, APK, IPA)
docs/                   ARCHITECTURE.md, ENGINE_API.md, FEATURES.md, research/
```

## 3. Native core (spcore)

* **Threads.** `spc_init()` creates pjsua and starts one worker thread (a pj
  thread). Every `spc_request` is pushed to a mutex+condvar queue and executed
  on that worker in FIFO order. pjsua callbacks run on pjsip's own threads
  (`thread_cnt=1`, media `thread_cnt=1`). They only build event JSON, post
  it, and apply native-side mechanics such as auto-180. Any non-pj thread that
  touches pj APIs calls `pj_thread_register` first; this is done once, in a
  thread-local guard helper.
* **Policy lives in Dart, mechanism in C.** Examples: DND, forwarding rules,
  auto-answer, dial rules, per-contact ringtones, LAN handoff orchestration.
  Native time-critical defaults:
  * When an INVITE arrives, the core emits `call.incoming` and waits for Dart
    to choose ring, answer, reject or redirect. If Dart hasn't answered
    within `incomingAutoRingMs` (default 1500 ms), the core sends `180 Ringing`
    itself.
  * Incoming REFER is accepted automatically, and the core reports it with
    `call.transferRequest`.
* **Per-account codecs.** pjsua codec priorities are global. The account's
  codec list is applied in `on_call_sdp_created`, which filters and reorders
  `m=audio` formats for that account's calls. `telephone-event` is always kept.
* **Limits** (in config_site.h): `PJSUA_MAX_ACC=64`, `PJSUA_MAX_CALLS=32`,
  `PJSUA_MAX_BUDDIES=512`, conference ports 254.
* **IDs.**
  * SIP accounts and calls use pjsua ids (`acc` 0–63, `call` 0–31).
  * IAX2 accounts use 1000+n and IAX2 calls use 1000+n. Every account and
    call event carries `"proto":"sip"|"iax2"`.
  * Dart passes a stable `uid` for each account, and the core echoes it in
    every account event.
* **SIP trace.** A pjsip module at priority `PJSIP_MOD_PRIORITY_TRANSPORT_LAYER-1`
  captures raw rx/tx packets when tracing is on, and emits them as `sip.trace`
  events. The Dart side keeps a ring buffer, renders a ladder view, and
  exports with redaction.
* **Ringer.** On desktop, a separate `pjmedia_snd_port` plays a WAV on a
  selectable ringer device, independent of the call device. Mobile
  platforms ring through the OS (Android RingtoneManager, iOS CallKit).
* **IAX2.** `spc_iax2*.c` implements an RFC 5456 client:
  * Messages: REGREQ/REGAUTH/REGACK/REGREJ, NEW/AUTHREQ/AUTHREP/ACCEPT/RINGING/ANSWER/HANGUP/REJECT, PING/PONG/LAGRQ/LAGRP, ACK and retransmits, DTMF, HOLD/UNHOLD, QUELCH/UNQUELCH.
  * Codecs: µ-law, A-law, GSM, plus mini frames.
  * Media: a custom `pjmedia_port` joins the pjsua conference bridge, so
    IAX2 calls get mixing, recording, conferencing and LAN relay for free.
* **SIP over WebSocket (RFC 7118).** A custom pjsip transport factory
  (`ws`/`wss`) is built on pjlib-util `websock` plus pj_ssl_sock. It lets
  accounts register to WebRTC-style SIP servers (Asterisk WSS, FreeSWITCH,
  Kamailio). Used together with ICE, DTLS-SRTP and rtcp-mux.

## 4. Dart engine (packages/spcore_dart)

* `SipEngine`: an abstract async API, one method per Engine API method, with
  a `Stream<EngineEvent>` of typed events.
* `FfiSipEngine`:
  1. Loads the library: `SPCORE_LIB` env override, else per-platform
     defaults.
  2. Calls `Dart_InitializeApiDL`.
  3. Creates a `ReceivePort` and passes its native port to `spc_init`.
  4. Maps `response` events to request `Completer`s, with a timeout per
     request.
* `FakeSipEngine`: deterministic simulation, used by widget tests and demo
  mode.
* Pure Dart, with no Flutter imports, so `dart test` can run real-network
  integration tests on a desktop host against the Docker PBX. Each test
  peer is a separate OS process, because pjsua allows one instance per
  process.

## 5. App (app/)

* Layout:
  * **Adaptive shell.** Below 840 dp, a bottom navigation bar with full-screen
    in-call UI. Wider, a navigation rail plus content, with a right-hand
    call panel.
  * **Tabs:** Dialer · Calls (history) · Contacts · Messages · LAN · Settings.
  * **Always visible** across tabs: the active-call bar, an account status
    chip strip, and the MWI badge.
* In-call:
  * Basic controls: mute, hold, keypad (DTMF), speaker/audio route.
  * Transfer: blind, attended, or to a LAN device.
  * Multi-party: add call, merge into a conference, swap.
  * Record, live call quality (MOS/jitter/loss/RTT sparkline), security
    badge (TLS/SRTP).
* Controllers:
  * AccountsController persists configs and applies them to the engine,
    with a registration health monitor, backoff, network-change handling
    (`core.handleIpChange`) and failover.
  * CallsController handles incoming policy (DND, forwarding, auto-answer,
    intercom header), call waiting, history writing, and recording.
* Provisioning:
  * Import from an HTTPS URL, QR code, file, or a `softphonepro://provision?url=` link.
  * Config is JSON: accounts plus settings, with `${MAC}` and `${USER}`
    variables.
  * Export as JSON or QR.
* Dial rules: ordered regex rewrite rules, each with an optional
  account-routing target and a strip/prepend action.

## 6. LAN Link (no server required)

* **Discovery.**
  * Advertisement: each device advertises `_softphonepro._tcp` via mDNS
    (bonsoir) and sends UDP multicast beacons on 239.255.77.77:47777 as a
    fallback.
  * Beacon contents: deviceId, name, platform, link port, LAN SIP
    port, the device's public identity key fingerprint, and its registered
    AORs (only when the user opts in).
* **Secure link.**
  * Each device has an X25519 + Ed25519 identity.
  * Pairing is one-time: both screens show a 6-digit short authentication
    string, which the user confirms.
  * Paired peers talk over WebSocket with frames encrypted using
    X25519 ECDH → HKDF → AES-256-GCM, with a per-frame nonce counter.
* **Chat and file drop.** Text and file offers travel over the link. The
  receiver accepts or declines each offer. Files are sent in chunks, with
  SHA-256 verification, progress, and resume.
* **Direct LAN calls and intercom.** A pjsua local account on a dedicated UDP+TCP
  transport handles these. Calls go to `sip:<deviceId>@<ip>:<port>`.
  Intercom adds `Call-Info: answer-after=0`, which is honoured only from
  paired devices with intercom allowed.
* **Call handoff (external → LAN peer).**
  1. *Direct REFER:* used if the peer advertises an AOR on the same
     domain/PBX. This is a standard blind or attended transfer through the
     provider.
  2. *Relay (always works):*
     1. The owner calls the peer over LAN with `X-SPP-Handoff` headers
        carrying the original caller name and number.
     2. On answer, `call.bridge` connects the external leg to the LAN leg.
     3. `call.detachLocal` removes the owner's mic and speaker.
     4. The owner's UI shows "Relayed to <peer>", with *Take back* and *End*.
     5. If either leg hangs up, the other is ended.

     Attended mode consults the peer first, then completes. Peers can also
     *pull* a call; the request is sent over the link.

## 7. Testing

1. **spcore integration tests** (`packages/spcore_dart/test/integration`):
   * Setup: run against the Docker Asterisk PBX with the null audio device,
     using two engine processes.
   * Coverage: register over UDP/TCP/TLS/WSS and IAX2, with multiple
     accounts online at once. Basic call, hold/unhold, mute, DTMF
     (RFC 2833 and INFO), blind and attended transfer, conference,
     recording, MWI, BLF, presence, IM, park/pickup, redirect, SRTP, each
     codec, LAN direct call, relay handoff.
   * Media check: assert media flows by checking RTP packet counters and
     the received signal level.
2. **Dart unit tests:** JSON codec, dial rules, provisioning parser, LAN crypto
   and framing.
3. **Flutter widget tests:** main flows against `FakeSipEngine`.
4. **Android emulator:** integration test registers to the PBX at 10.0.2.2
   and calls the echo test.
5. **CI:**
   * Every push: native builds on all 4 OSes plus Linux; Linux integration
     tests with the PBX as a service container; `flutter test`.
   * Tags: app builds for every platform, published to a GitHub Release
     (EXE installer, portable ZIP, DMG, APK, unsigned IPA).

## 8. Known limitations

* **iOS background calls.** Incoming calls in the background need VoIP push
  (PushKit) plus a push gateway, which needs PBX cooperation. Without
  that, iOS receives calls only while the app is in the foreground or
  during an active call.
* **Android background.** A foreground service keeps registration alive
  (the Zoiper/Bria non-push mode). FCM push is not included.
* **Unsigned builds.** The macOS DMG and Windows EXE aren't code-signed, so
  users will see Gatekeeper and SmartScreen prompts. The iOS IPA is
  unsigned and must be sideloaded.
* **Video and ZRTP.** These are a planned phase after audio parity, not in
  the first release.
