# SoftphonePro — Feature List and Status

Status as of v1.0.0 (2026-10-19). Every status below is backed by the evidence in the last column. A claim that has no test is not marked ✅.

## Summary

| Status | Meaning | Rows |
|---|---|---|
| ✅ | Implemented and covered by an automated test (named in the Evidence column) | **69** |
| ◐ | Implemented, but only checked by hand or on a device, or only partly tested (the Evidence column says what is missing) | **34** |
| ☐ | Not implemented, or deferred | **8** |
| | Total rows | **111** |

Not implemented: video calls (M8), ZRTP (S6) and localisation (U5), plus the items in the last table (push notifications, CardDAV/LDAP, visual voicemail, LAN group chat, a Linux desktop app).

How to read this list:

* **Priority:** P0 is parity with free and basic softphones. P1 is parity with premium products (Zoiper Premium, Bria, Groundwire). P2 covers features that competitors don't offer, or charge extra for.
* **Layer:** C = spcore (the C call engine), D = Dart app, P = platform code (Kotlin/Swift/C++/JS).
* **Evidence prefixes** (paths are relative to the repository root):
  * `N:` engine tests in `native/tests/`. They run the real engine (`spcore_cli`) against the Asterisk test PBX in `tests/sipserver` (see BUILDING.md).
  * `A:` app tests in `app/test/` (`flutter test`). They drive the real UI and controllers with the simulated engine (`FakeSipEngine`), so they prove app behaviour, not audio.
  * `S:` `packages/spcore_dart/test/`: the Dart engine API, its simulator, and (in `integration/`) the real engine against the test PBX.
  * `L:` `packages/lan_link/test/`: the LAN Link protocol.
  * `E:` `extensions/browser/test/`: the browser extension.
  * `QA_ANDROID` / `QA_MACOS`: the manual device runs in [QA_ANDROID.md](QA_ANDROID.md) and [QA_MACOS.md](QA_MACOS.md). Windows and iOS builds are produced by CI but have no device QA report yet.

## Accounts and registration
| ID | Feature | Pri | Layer | Status | Evidence |
|---|---|---|---|---|---|
| A1 | Unlimited* SIP accounts registered **simultaneously** (*64 compiled limit) | P0 | C/D | ✅ | N: `run_tests.py` `test_five_accounts_one_process`; S: `integration/pbx_test.dart` "multiple accounts registered in one engine". The 64 limit is a compile-time constant that no test exercises. |
| A2 | Per-account enable/disable, register/unregister, status chip with code and reason | P0 | D | ✅ | N: `run_tests.py` `TestRegistration` (register, unregister, wrong password); A: `flows_test.dart` "onboarding -> add account -> registered chip", `polish_a1_test.dart` "401/403/404 stop auto retries until the user taps register". |
| A3 | Auth user, outbound proxy (several), registrar override, realm, display name, caller-ID | P0 | C | ◐ | Fields round-trip (S: `models_test.dart` "AccountConfig round trip with non-default values"; A: `provisioning_test.dart` parses `proxies`) and `displayName` is changed live (N: `test_modify`). Missing: no test registers through an outbound proxy or a custom realm against a server. |
| A4 | Registration expiry, retry/backoff, keep-alive, contact/Via rewrite (NAT), rport | P0 | C | ◐ | Retry and backoff: A: `polish_a1_test.dart` "transient failures (408) keep retrying with backoff"; expiry change: N: `test_modify`. Missing: keep-alive, contact rewrite and rport are configured but nothing asserts them on the wire. |
| A5 | Default account for outgoing calls, plus choosing the account per call | P0 | D | ✅ | A: `a2_polish_test.dart` "explicit Direct selector entry routes any target directly", "an account chosen on purpose is respected for IP targets". |
| A6 | Account templates for popular providers and PBXs (Asterisk, FreePBX, 3CX, FreeSWITCH, Kamailio, Twilio, Telnyx, VoIP.ms, Vonage, WebRTC gateway, IAX2, generic) | P1 | D | ✅ | A: `accounts/accounts_ui_test.dart` "every template has sane defaults", "iax2 template builds an IAX2 profile", "webrtc template is prefilled". |
| A7 | Registration health monitor and automatic failover to a backup server | P2 | D | ✅ | A: `polish_a1_test.dart` "failover to the backup registrar after 3 failures and back to the primary". |
| A8 | IAX2 accounts (Zoiper USP): register, calls, DTMF, hold, recording, conference, blind transfer | P1 | C | ✅ | N: `test_iax2.py` (42 tests against Asterisk and a fake server, incl. fuzzing); A: `accounts_ui_test.dart` "add IAX2 account via the protocol picker registers with the engine". Limits are in ENGINE_API §7 (IPv4 only, no MWI, no encryption). |
| A9 | Account import/export (JSON, QR) and remote provisioning (HTTPS URL, `${VARS}`, `softphonepro://provision` links, `--provision` on the desktop command line) | P1 | D | ✅ | A: `provisioning_test.dart` (variable substitution, round trip, fetch from URL), `polish_a1_test.dart` ("provision link: confirm, import, onboarding completes", "provision links need https", "--provision <file> imports without a prompt"), `qr_scanner_test.dart` (payload parsing). QR camera scanning is covered under U8. |
| A10 | Dedicated local port per account (needed by some providers) | P1 | C | ✅ | N: `test_polish_d.py` `test_dscp_sip_shared_and_own_transport` starts an account with `localPort` and its own transport. |

## Transports and network
| ID | Feature | Pri | Layer | Status | Evidence |
|---|---|---|---|---|---|
| N1 | SIP over UDP, TCP, TLS (1.2/1.3), with server certificate verification option | P0 | C | ✅ | N: `run_tests.py` `test_udp`, `test_tcp`, `test_tls`, `test_tls_verification_and_pins`, `test_tls_verified_with_ca`. |
| N2 | SIP over WebSocket (WS/WSS, RFC 7118) for WebRTC-style servers | P1 | C | ✅ | N: `test_ws.py` (27 tests: register, calls, DTLS/ICE/rtcp-mux, reconnect, hostile frames). |
| N3 | IPv6 and dual stack | P1 | C | ◐ | Implemented in the engine (`ipv6` setting, IPv6 DNS servers); N: `test_review_fixes.py` `test_ipv6_and_explicit_nameservers` only checks IPv6 nameserver handling. Missing: no IPv6 registration or call test. |
| N4 | STUN, ICE, TURN (UDP/TCP/TLS) | P0 | C | ◐ | ICE call set-up: N: `test_review_fixes.py` `test_make_with_ice_returns_cid_and_hangup_works`; NAT-type wizard logic: A: `diagnostics/diagnostics_ui_test.dart` (fake STUN results). Missing: the test PBX has no STUN or TURN server, so no real STUN binding or TURN relay is tested; the Android emulator STUN check did not answer (QA_ANDROID I). |
| N5 | Network change handling (Wi-Fi ↔ cellular, VPN): re-register and re-INVITE | P0 | C/D | ◐ | Engine: N: `test_n3.py` `test_handle_ip_change_reresolves_and_modify`. Device: QA_ANDROID K (airplane mode on/off re-registers in 7 s). Missing: the app's connectivity listener is stubbed out in every widget test. |
| N6 | QoS DSCP marking (SIP CS3, RTP EF) | P1 | C | ◐ | SIP DSCP, shared and per-account transport: N: `test_polish_d.py` `test_dscp_sip_shared_and_own_transport`, `test_dscp_validation_and_qos_off`. Missing: RTP marking is not asserted on the wire. |
| N7 | DNS SRV, custom DNS servers (NAPTR is not implemented) | P1 | C | ◐ | SRV: N: `test_n3.py` (`test_priority_and_weight`, `test_tcp_beats_udp`, `test_dead_dns_does_not_block`); custom servers: `test_review_fixes.py` `test_srv_blackholed_nameserver_times_out_and_engine_survives`. NAPTR: no code (grep of `native/src`). |
| N8 | SIP Outbound (RFC 5626), session timers (RFC 4028), 100rel (RFC 3262) | P1 | C | ◐ | Settings exist in the account editor (Advanced) and engine config (`spc_account.c`). Missing: no automated test covers any of the three. |
| N9 | Mutual TLS: client certificate, key and key password per account (file pickers; key password in secure storage) | P1 | C/D | ✅ | N: `test_n3.py` `test_mtls_register_with_cert`, `test_mtls_without_cert_fails_clearly`, `test_mtls_encrypted_key_and_modify_cleanup`, `test_wss_presents_client_cert`; A: `recordings/account_connection_test.dart` "client certificate: files + key password reach the engine; password lives in the secrets store only". |
| N10 | Automatic transport: DNS SRV (`_sips._tcp`, `_sip._tcp`, `_sip._udp`) with the resolved server shown in the account sheet | P1 | C/D | ✅ | N: `test_n3.py` `test_sips_srv_selects_tls` and the SRV tests above; A: `recordings/account_connection_test.dart` "account status sheet shows the server DNS resolved for transport auto". |

## Security
| ID | Feature | Pri | Layer | Status | Evidence |
|---|---|---|---|---|---|
| S1 | SRTP SDES (AES-CM, AES-GCM), optional or mandatory | P0 | C | ✅ | N: `run_tests.py` `test_srtp_mandatory_1011`, `test_ws.py` `test_call_wss_sdes`. GCM is built in (CI fails Windows builds without it) but no test selects a GCM suite. |
| S2 | DTLS-SRTP | P1 | C | ✅ | N: `test_ws.py` `test_call_wss_webrtc_dtls_ice_rtcpmux`. |
| S3 | Per-call security indicator (signalling TLS plus media SRTP) | P1 | D | ◐ | Engine flag: N: `test_polish_d.py` `test_udp_false`, `test_tls_true_without_srtp`, `test_wss_true`. Missing: the padlock widget itself has no test. |
| S4 | Passwords in the OS keystore (Keychain/Keystore/DPAPI) | P0 | D | ◐ | Passwords go through a `SecretsStore` (A: `recordings/account_connection_test.dart` checks the password is not in the account record). Missing: tests use an in-memory store; the OS keystore backends and the encrypted-file fallback are not exercised in CI. |
| S5 | App lock (PIN/biometric), privacy mode with no telemetry | P2 | D | ✅ | A: `app_lock_test.dart` (salted hash, backoff, lock-after-background, incoming call over the lock screen); QA_ANDROID H (device). Biometric prompt is not covered by tests. There is no telemetry code. |
| S6 | ZRTP with SAS verification | P2 | C | ☐ | Not implemented (no ZRTP code in `native/` or `app/lib`). Deferred. |
| S7 | Server certificate pinning and "trust this certificate" from the network wizard | P1 | C/D | ✅ | N: `run_tests.py` `test_tls_verification_and_pins`, `test_review_fixes.py` `test_pin_validation`; A: `diagnostics/diagnostics_ui_test.dart` "untrusted TLS certificate can be trusted and pinned". |
| S8 | Bundled Mozilla CA list used as the TLS trust store (user CA file overrides it) | P0 | D | ✅ | A: `polish_a1_test.dart` "the bundled asset is a real PEM bundle", "CA bundle is copied only when changed", "the engine gets the CA file and log file". |
| S9 | Encrypted local data (opt-in): call history, contacts, messages and settings encrypted with AES-256-GCM | P2 | D | ✅ | A: `storage/encrypted_db_test.dart` (codec round trip, per-record nonces, tamper and wrong-key detection, plain to encrypted to plain migration with record counts and plaintext absent from the file, failure after copy leaves the original, swap rollback, missing key and wrong key give the recovery path, start fresh). Key: 32 random bytes in the secrets store. Applied at the next start; the old file is kept as a backup until the start after. Recordings and exported files are not encrypted. The recovery screen (`ui/pages/db_recovery.dart`) is not covered by a widget test. |

## Codecs and audio
| ID | Feature | Pri | Layer | Status | Evidence |
|---|---|---|---|---|---|
| M1 | Opus (wideband/fullband), G.722, G.711 µ/A, GSM, iLBC, Speex NB/WB/UWB, G.729 (bcg729), G.722.1, L16 | P0 | C | ◐ | All of these appear in `media.codecs` of the macOS engine build (checked by hand; CI fails builds without Opus or G.729). Call media is tested with PCMU and PCMA (N: `test_codec_selection_per_account`) and GSM (IAX2); Opus is covered by recording tests. Missing: no automated call per remaining codec. |
| M2 | Codec enable and priority, globally and per account | P0 | C/D | ✅ | N: `run_tests.py` `test_02_media_misc`, `test_codec_selection_per_account`; A: `codec_order_test.dart`. |
| M3 | Echo cancellation (WebRTC AEC3 / speex), noise suppression, AGC | P0 | C | ◐ | Settings accepted by the engine (N: `test_02_media_misc` `media.setEc`). Missing: no test measures echo or noise reduction of the classic processors (voice isolation, M9, is measured). |
| M4 | Choice of mic, speaker and **separate ringer device**; hot-plug refresh | P1 | C/D | ✅ | N: `test_02_media_misc` (`media.setDevices`, `media.devicesChanged`); A: `polish_a1_test.dart` "MediaDevicesChangedEvent refreshes the device provider revision", `audio/audio_ui_test.dart` "desktop device sheet lists microphones and speakers with the default marked". |
| M5 | Mic/speaker volume, live VU meters, mic test loopback | P1 | C/D | ✅ | N: `test_02_media_misc` (`media.setMicLevel`, `media.loopback`); A: `diagnostics/diagnostics_ui_test.dart` "echo test toggles loopback; tones play", `audio/audio_ui_test.dart` "shows device names, the OS default and a speaker test". |
| M6 | Jitter buffer and VAD/CNG tuning, ptime | P1 | C | ✅ | N: `test_02_media_misc` (`setCodecParam` ptime/vad); A: `polish_a1_test.dart` "buildCoreConfig sets CA file, custom CA override, jitter buffer, ptime, log file". |
| M7 | Android audio routes (earpiece/speaker/Bluetooth/wired), proximity sensor | P0 | P | ◐ | Device run only: QA_ANDROID (speaker route on the emulator; the emulator reports no earpiece). Dart side: A: `a2_polish_test.dart` "proximity / keep-screen / tray are only invoked on change". Missing: Bluetooth and wired routes and the real proximity sensor were not tested. |
| M8 | Video calls (H.264/VP8) | P1 | C/P | ☐ | Not implemented (PJSIP is built with `PJMEDIA_WITH_VIDEO=OFF`). Deferred. |
| M9 | Voice isolation: AI noise cancellation (RNNoise) for mic and incoming audio, strength, live speech meter, in-call toggle | P1 | C/D | ✅ | N: `test_voice_isolation.py` (12 tests: noise reduction, speech preserved, strength scaling, no clicks, live toggle, conference); A: `audio/voice_isolation_test.dart`, `audio/audio_golden_test.dart`. |
| M10 | Audio library: import WAV/MP3, record your own, preview, rename, delete | P1 | D | ✅ | N: `test_media_files.py` (file info, formats, mic recorder); A: `audio/audio_library_test.dart`, `audio/audio_ui_test.dart`, `audio/mic_recorder_test.dart`. |

## Call handling
| ID | Feature | Pri | Layer | Status | Evidence |
|---|---|---|---|---|---|
| C1 | Outgoing and incoming calls, early media, ringback, busy/congestion tones | P0 | C | ✅ | N: `run_tests.py` `test_basic_call_media_hold_mute`, `test_reject_and_busy`; A: `a2_polish_test.dart` "ringback while calling/early with no media", "busy tone for ~3 s on 486 then stops", "busy tone also for 603; congestion for 503 and 408". |
| C2 | Answer, reject (busy/decline), hang up, multiple simultaneous calls (call waiting with tone) | P0 | C/D | ✅ | A: `flows_test.dart` "incoming call -> answer", "call waiting: second incoming call holds the first on answer", "missed incoming call is recorded as missed"; N: `test_reject_and_busy`, `test_cid_uniqueness_max_calls`. |
| C3 | Hold/resume, mute, swap between calls | P0 | C/D | ✅ | A: `flows_test.dart` "dial -> in call -> mute/hold -> hang up -> history"; N: `test_basic_call_media_hold_mute`; macOS device run (QA_MACOS 5). |
| C4 | DTMF: RFC 2833/4733, SIP INFO, in-band, and auto; in-call keypad | P0 | C | ◐ | RFC 2833 is verified at the PBX: N: `run_tests.py` `test_dtmf_rfc2833_to_602`; Android direct call with RFC 2833 digits seen at the far end (QA_ANDROID D); macOS (QA_MACOS 7). SIP INFO and in-band are only checked not to fail (`test_dtmf_inband_and_info_do_not_fail`). Missing: no far-end check for INFO or in-band; the in-call keypad widget has no dedicated test. |
| C5 | Blind transfer (REFER) | P0 | C | ✅ | N: `run_tests.py` `test_blind_transfer`; A: `flows_test.dart` "transfer sheet: blind transfer"; macOS device run (QA_MACOS 9). Android through the PBX is not confirmed (QA_ANDROID F, blocked by the test PBX setup). |
| C6 | Attended transfer (REFER with Replaces) | P0 | C | ✅ | N: `run_tests.py` `test_attended_transfer`; A: `flows_test.dart` "transfer sheet: attended transfer (consult then complete)". |
| C7 | Handling of incoming REFER and Replaces (be transferred, call pickup) | P0 | C | ✅ | N: `run_tests.py` `test_incoming_refer_1999`, `test_redirect_via_direct`, `test_redirect_through_pbx`; A: `a2_polish_test.dart` "ask: prompts, Follow accepts". |
| C8 | Local N-way conference (merge calls, split, per-party mute/volume) | P1 | C/D | ◐ | N: `run_tests.py` `test_conference_three_way`, `test_iax2.py` `test_conference_iax_and_sip`; A: `a2_polish_test.dart` "sliders call setCallLevels for the party". Missing: conferences larger than three parties and the Split button have no test. |
| C9 | Call recording manager: Recordings page (desktop rail, phone More) with list by day, name/number/direction/account/duration/size/format badge, search and filters, in-app player, rename, delete and bulk delete, export, storage summary, open folder, auto-delete after N days, two-way links between history and recordings; auto-record rules (off, all, incoming, outgoing; per account; per contact) | P1 | C/D | ✅ | A: `recordings/recordings_page_test.dart` (10 widget tests), `recordings/recording_rules_test.dart`, `recordings/recording_flow_test.dart` (incl. "retention deletes recordings older than N days and clears history links"), `recordings/recording_settings_test.dart`; N: `run_tests.py` `test_recording`. Recording beep: `a2_polish_test.dart` "recordBeep plays the beep file every 15 s while recording". Missing: share sheet on phones and "Show in folder" are not exercised. |
| C10 | Auto-answer: global, per account, or by header (Call-Info answer-after, Alert-Info auto-answer, Answer-Mode) — intercom | P1 | C/D | ◐ | Header parsing: N: `run_tests.py` `test_autoanswer_hint`; LAN intercom auto-answer: A: `lan/lan_handoff_test.dart` "intercom: paired, allowed peer is auto-answered". Missing: the global and per-account auto-answer settings have no app test. |
| C11 | DND (global or per account), with reject code choice | P0 | D | ✅ | A: `flows_test.dart` "incoming call while DND is auto-rejected and logged", `automation/automation_test.dart` "DND on rejects incoming calls; off accepts them again", `polish_a1_test.dart` "DND toggle dials *78 / *79 silently when enabled"; QA_ANDROID G (rejects with 486). |
| C12 | Call forwarding: always, busy, or no answer after N seconds (client-side 302 redirect) | P1 | D | ◐ | A: `flows_test.dart` "call forwarding always redirects", `polish_a1_test.dart` "forwarding toggle dials forwardOn with the target". Missing: the busy and no-answer modes have no test. |
| C13 | Call park and retrieve, call pickup (group/directed) through feature codes and BLF | P1 | D | ✅ | A: `a2_polish_test.dart` "retrieveParked dials prefix + slot", "BLF pickup uses INVITE with Replaces when an early dialog is known", "BLF pickup without dialog info falls back to the feature code". Park itself relies on the PBX feature code. |
| C14 | Speed dial and favourites (slots 1-9, long-press on the keypad) | P0 | D | ✅ | A: `a2_polish_test.dart` "long-press digit dials the assigned slot", "long-press on an empty slot opens the assignment dialog and saves", "speed dial settings parse slots 1-9 only". |
| C15 | Dial plan rules (regex rewrite, prefix strip/add, per-account routing, E.164) | P1 | D | ✅ | A: `dial_rules_test.dart` (14 tests), `polish_a1_test.dart` "strip prefix, plus replacement and default country prefix"; QA_ANDROID G (live rule test). |
| C16 | Redial, call back from history, click-to-call URL handlers (sip:, sips:, tel:, callto:) | P0 | D/P | ✅ | A: `link_dial_test.dart`, `polish_a1_test.dart` ("tel: link shows the dialer prefilled even from another page", "sip link fills the dialer; with 'call links immediately' it dials"), `desktop_platform_test.dart` (link parsing); device: QA_ANDROID J, QA_MACOS 14-15. |
| C17 | Direct IP calls without an account (sip:user@ip) | P1 | C | ✅ | N: `run_tests.py` `test_direct_ip_call`; A: `a2_polish_test.dart` "IP-literal target with a different account domain goes out directly". |
| C18 | Anonymous call rejection, blocklist | P1 | D | ◐ | A: `a2_polish_test.dart` "blocklist matches the exact number only". Missing: "Reject anonymous calls" has no test. |
| C19 | Per-account and per-contact ringtones | P2 | D | ✅ | A: `a2_polish_test.dart` "resolution order: contact > account > global", "the engine ringer gets the resolved file", "bundled ringtones exist as assets". |
| C20 | Music on hold: built-in or own file, volume, per-account override; plain hold if the engine refuses | P1 | D | ✅ | N: `test_media_files.py` `test_moh_plays_during_hold_and_stops_on_unhold`, `test_plain_hold_without_music`, `test_moh_mp3`; A: `audio/hold_music_test.dart` (6 tests), `audio/audio_ui_test.dart` "hold music and announcement overrides". Through Asterisk the PBX plays its own music (ENGINE_API §9.3). |
| C21 | Opening announcement when a call connects (incoming/outgoing/both, mute mic, local monitor, skip) | P2 | D | ✅ | A: `audio/announcement_test.dart` (14 tests incl. direction, once per call, per-account override, Skip); N: `test_media_files.py` `test_mute_mic_is_separate_from_user_mute`, `test_local_monitor_accepted`. |
| C22 | Transfer announcement: play a notice to the caller before blind, attended and LAN hand-off transfers | P2 | D | ✅ | A: `audio/transfer_announcement_test.dart` (7 tests: blind, attended, Skip, 15 s timeout, unplayable notice). LAN hand-off uses the same path but has no separate test. |
| C23 | Recording formats: Standard WAV, Stereo WAV (you left, caller right) and Compressed Opus (Ogg); Opus playback on Android/Linux, Open with / export elsewhere | P1 | C/D | ✅ | N: `test_media_files.py` `test_wav_stereo_channel_separation`, `test_opus_recording_valid_and_decodable`, `test_opus_recording_both_and_hangup_finalise`; A: `recordings/recording_flow_test.dart` (stereo and opus), `recordings/recordings_page_test.dart` "Opus on a platform without an Ogg Opus decoder offers 'Open with...'". |
| C24 | Recording continuity across transfers: the consultation call of an attended transfer and a REFER/relay-spawned call keep recording and are linked in history and the Recordings page | P2 | D | ✅ | A: `recordings/recording_flow_test.dart` "attended transfer: the consultation call is recorded too and linked", "a call spawned by an incoming REFER keeps recording the relay", "'continue recording through transfers' off". |
| C25 | Blind-transfer feedback: "Transferring..." then "Transfer not confirmed by the server" with Keep call and Retry after 10 s | P1 | D | ✅ | A: `recordings/qa_leftovers_test.dart` "after 10 s: 'Transfer not confirmed by the server' with keep / retry". |
| C26 | Interrupted-call journal: a call cut short by a crash or force-stop becomes an "Interrupted" history entry at the next start | P1 | D | ✅ | A: `recordings/qa_leftovers_test.dart` "a call interrupted by a force-stop becomes an 'interrupted' history entry", "calls are journaled while active and removed when they end normally". The Android force-stop itself was run before the journal was added (QA_ANDROID K); the journal was not re-checked on a device. |

## Messaging and presence
| ID | Feature | Pri | Layer | Status | Evidence |
|---|---|---|---|---|---|
| P1 | SIP MESSAGE instant messaging with threads, delivery status, typing indicator | P0 | C/D | ✅ | N: `run_tests.py` `test_im`, `test_ws.py` `test_message_and_dtmf_over_ws`; S: `integration/pbx_test.dart` "IM A -> B delivered"; A: `automation/automation_test.dart` "send a message; delivery events; unreachable peer gives 502", `desktop_layout_test.dart` (messages master-detail); macOS (QA_MACOS 11). |
| P2 | Presence (SUBSCRIBE/NOTIFY PIDF) and publish of own status | P1 | C | ✅ | N: `run_tests.py` `test_presence_buddy`, `TestRegistration` (`account.setPresence`); A: `a2_polish_test.dart` "contact presenceAccountId picks the subscribing account". |
| P3 | BLF (dialog-info, RFC 4235) busy lamp field with one-tap call, pickup or transfer | P1 | C/D | ✅ | N: `run_tests.py` `test_blf`; S: `integration/pbx_test.dart` "BLF of 1002 reflects a call"; A: `a2_polish_test.dart` BLF pickup tests. Missing: the Presence board's tap and long-press actions have no widget test. |
| P4 | MWI voicemail indicator (RFC 3842), count badge and one-tap voicemail dial | P0 | C/D | ◐ | Engine and event: N: `run_tests.py` `test_mwi`; A: `automation/automation_test.dart` "events stream: hello snapshot, account, mwi and heartbeat". Missing: the top-bar badge and the voicemail dial have no widget test. |
| P5 | Caller identity: P-Asserted-Identity / Remote-Party-ID name and number, "Forwarded from" (Diversion / History-Info) and "Transferred by" (Referred-By) on incoming, in-call, desktop card and history | P1 | C/D | ✅ | N: `test_caller_identity.py` (15 tests); A: `recordings/caller_identity_test.dart` (6 tests: incoming page, in-call page, history detail, desktop banner and card). |

## Contacts and history
| ID | Feature | Pri | Layer | Status | Evidence |
|---|---|---|---|---|---|
| H1 | Call history (all, missed, in, out) with search, filter, per-account view, export CSV | P0 | D | ◐ | History records are written and read back: A: `flows_test.dart` (history rows for dialled, missed, DND), `diagnostics/diagnostics_ui_test.dart` "history model is backwards compatible"; automation `/v1/history`. Missing: search, filters and CSV export have no test. |
| H2 | Built-in contacts (several numbers or SIP URIs, favourites, notes, ringtone, BLF flag, always-record flag) | P0 | D | ◐ | A: `a2_polish_test.dart` "Contact.presenceAccountId ... round-trip", `recordings/recording_settings_test.dart` "contact editor: 'Always record calls with this contact'", `desktop_layout_test.dart` (master-detail). Missing: no test for adding or editing a plain contact. |
| H3 | Device contacts integration (Android/iOS/macOS) | P1 | P | ◐ | Merge and dedupe logic and the iOS/macOS method channels: A: `device_contacts_test.dart`. Missing: no run on a real device or simulator; the Android reader is untested. |
| H4 | vCard / CSV import and export | P1 | D | ✅ | A: `provisioning_test.dart` "vCard round trip", "CSV round trip with quotes". |
| H5 | T9 or smart search from the dialer | P1 | D | ✅ | A: `a2_polish_test.dart` "tall phones show top suggestions above the keypad". |

## LAN Link (exceeds competitors)
| ID | Feature | Pri | Layer | Status | Evidence |
|---|---|---|---|---|---|
| L1 | Auto-discovery of SoftphonePro devices on the LAN (mDNS plus multicast fallback) | P2 | D | ◐ | Multicast discovery and merging: L: `discovery_test.dart` (9 tests incl. "two MulticastDiscovery instances find each other"). Missing: the Bonjour/mDNS provider (`bonsoir`) needs real devices and has no automated test; QA_MACOS 16 only looked at the LAN screen. |
| L2 | Secure pairing (verified with a 6-digit code), encrypted link (X25519 / AES-GCM) | P2 | D | ✅ | L: `crypto_test.dart` (MITM, tamper, replay, reflection), `link_test.dart` ("both confirm -> trusted on both sides, SAS equal", rate limiting); A: `lan/lan_ui_test.dart` "LAN page: connect, pair with the 6-digit code on both sides". |
| L3 | LAN chat between devices | P2 | D | ✅ | L: `link_test.dart` "chat round trip with delivered and read acks"; A: `lan/lan_chat_test.dart`, `lan/lan_ui_test.dart`. |
| L4 | File drop with accept/decline, progress, SHA-256 verification | P2 | D | ✅ | L: `link_test.dart` (5 MB file, resume, wrong hash, path traversal, size limit); A: `lan/lan_ui_test.dart` "incoming file offer: dialog with name and size, accept, ...". |
| L5 | Direct LAN calls and intercom without a server | P2 | C/D | ✅ | N: `run_tests.py` `test_lan_call`; A: `lan/lan_handoff_test.dart` (5 intercom tests); L: `link_test.dart` "calls list, pull and intercom". |
| L6 | Transfer or hand off **any external call** to a LAN device (relay bridge, or REFER when possible), blind or attended | P2 | C/D | ✅ | A: `lan/lan_handoff_test.dart` (relay, take back, REFER mode, attended relay, forward a ringing call, failure paths); `lan/lan_ui_test.dart` "hand-off offer dialog, then the transferred call is answered and labelled". Run only with fakes and the engine simulator; not run between two real devices. |
| L7 | Call pull: take over a call that is active on another LAN device | P2 | D | ✅ | A: `lan/lan_handoff_test.dart` "call pull: peer lists active calls and pulls; owner relays automatically", "call pull is ignored unless the owner allowed it". |
| L8 | LAN device presence (available, on a call, DND) | P2 | D | ✅ | L: `link_test.dart` "status update propagates". |

## UI / UX
| ID | Feature | Pri | Layer | Status | Evidence |
|---|---|---|---|---|---|
| U1 | Adaptive layout for desktop and mobile, light/dark/system theme, accent colours | P0 | D | ✅ | A: `desktop_layout_test.dart` (rail, two-pane settings, master-detail), golden images in `test/goldens` and `test/*/goldens`; QA_ANDROID G (themes), QA_MACOS 16. |
| U2 | Full-screen incoming-call UI and notifications with Answer/Decline actions | P0 | D/P | ✅ | A: `flows_test.dart` "incoming call -> answer", `desktop_layout_test.dart` "desktop incoming banner answers via button", `recordings/qa_leftovers_test.dart` (foreground vs background notification); device: QA_ANDROID C (heads-up and screen-off full-screen), QA_MACOS 8 (banner). |
| U3 | Desktop: tray icon, minimise to tray, start at login, global hotkeys | P1 | P | ◐ | Logic only: A: `desktop_platform_test.dart` (hotkey parsing and defaults, window bounds, tray menu structure, link and command-line parsing). Missing: the tray icon, login item and global hotkey registration are not tested; QA_MACOS did not check them. |
| U4 | Keyboard shortcuts, full keyboard navigation, screen-reader labels | P1 | D | ◐ | Implemented (`ui/shortcuts.dart`, `Semantics` labels on the keypad, call, list and settings widgets). Missing: no test and no screen-reader pass. |
| U5 | Localisation framework (English first) with RTL support | P1 | D | ☐ | Not implemented: no `flutter_localizations`, ARB files or locale list in `app/`. The UI is English only. |
| U6 | Onboarding wizard (QR, URL, provider templates, manual) | P1 | D | ✅ | A: `flows_test.dart` "onboarding -> add account -> registered chip", `polish_a1_test.dart` "cold-start provision link during onboarding shows the confirm dialog and finishes onboarding"; QA_ANDROID A. |
| U7 | Browser click-to-dial extension (Chrome, Edge, Brave, Firefox; Manifest V3) | P1 | P | ✅ | E: `phone.test.js` (65 tests with `node --test`: number detection, settings, site lists); `test/e2e/e2e.js` is a puppeteer script run by hand (Chrome only, not in CI). Not tested in Firefox or on the stores. |
| U8 | QR codes: scan provisioning and LAN pairing QR codes; show your own QR | P1 | D/P | ◐ | Payload parsing and the paste fallback: A: `qr_scanner_test.dart` (the camera detection callback is simulated). Missing: no run with a real camera on any platform. |
| U9 | "Make default" setting for sip:, tel: and callto: links (macOS, Windows) | P1 | P | ◐ | A: `link_dial_test.dart` (`DefaultHandlerService` with a mocked channel; "Settings > Calls shows the default-handler tile"). QA_MACOS 17 read the current handlers but did not change them. Missing: setting the handler on a real Mac or Windows PC is untested. |

## Platform integration
| ID | Feature | Pri | Layer | Status | Evidence |
|---|---|---|---|---|---|
| X1 | Android foreground service that keeps accounts registered in the background, start on boot | P0 | P | ◐ | Kotlin only (`SipService.kt`, `BootReceiver.kt`). Device run: QA_ANDROID C and K (screen-off incoming, force-stop recovery). Missing: no automated test; boot start was not tested. |
| X2 | Android ConnectionService (self-managed): system call integration, Bluetooth and car controls | P1 | P | ◐ | Implemented (`SpConnectionService.kt`). Missing: no test and no mention in QA_ANDROID; Bluetooth and car controls were not tested. |
| X3 | iOS CallKit integration (native call UI and audio session) | P1 | P | ◐ | Implemented (`CallKitManager.swift`). A: `ios_platform_services_test.dart` (method channel encoding), `a2_polish_test.dart` "systemDtmf digits are sent on the matching call". Missing: never run on an iOS device or simulator (CI builds an unsigned IPA only). |
| X4 | Battery optimisation guidance, Wi-Fi lock and wake locks during calls | P1 | P | ◐ | Implemented ("Background reliability" checklist in Settings, `Locks.kt`). Missing: no test. |
| X5 | Headset / media play-pause button answers and hangs up (desktop) | P1 | P | ◐ | Desktop: A: `media_keys_test.dart` (policy: ringing answers, active hangs up or mutes, keys claimed only while a call rings or is active, repeat-press debounce, channel round trip). Native side is not run in CI: macOS `MPRemoteCommandCenter` in `MainFlutterWindow.swift` (needs a manual check on a Mac), Windows `VK_MEDIA_PLAY_PAUSE` via hotkey_manager (manual check on Windows). Android/iOS: not handled by the app itself; Android Telecom or iOS CallKit may route headset buttons for system-registered calls (not verified). |
| X6 | Desktop command line: `--dial <target>`, `--provision <file\|url>`, `--minimized`; single running instance | P1 | P | ✅ | A: `polish_a1_test.dart` "--dial places the call even with the setting off", "--provision <file> imports without a prompt", "CLI flags become local intents; links cannot forge them"; `link_dial_test.dart` "--dial at launch waits for the account to register"; `desktop_platform_test.dart` (forwarded command lines); macOS: QA_MACOS 1, 14, 15. The Windows single-instance code (`single_instance.cpp`) is not tested. |
| X7 | Blocking engine-error screen with Retry / network settings / explicit "Use simulator" (no silent demo fallback) | P0 | D | ✅ | A: `polish_a1_test.dart` "blocking error with Retry / network settings / simulator", "Retry starts the engine again", "a library that cannot load still falls back to the demo engine". |
| X8 | Update checker (desktop): weekly check of the GitHub latest release, banner with Release notes / Download / Skip this version, opt-out and Check now in Settings > About | P2 | D | ✅ | A: `update_checker_test.dart` (semver and pre-release ordering, rate limit, 404, timeout, junk replies, weekly schedule, opt-out, skip version, banner opens the release page, hidden on mobile) with a mocked HTTP client. Nothing is downloaded or installed. |

## Automation and integrations
| ID | Feature | Pri | Layer | Status | Evidence |
|---|---|---|---|---|---|
| D6 | Local automation API (HTTP/JSON + SSE on 127.0.0.1, token auth; dial, answer, hold, transfer, DND, messages, history, events) | P2 | D | ✅ | A: `automation/automation_test.dart` (26 tests against a real `HttpServer` with the fake engine: auth, DNS-rebinding guard, CORS, limits, calls, transfers, events); macOS end to end: `tests/macos_e2e/e2e.py`, results in QA_MACOS (17 cases pass). Desktop only; off by default. Reference: AUTOMATION_API.md. |

## Diagnostics (exceeds competitors)
| ID | Feature | Pri | Layer | Status | Evidence |
|---|---|---|---|---|---|
| D1 | Live call quality panel: MOS, jitter, loss, RTT, codec, bitrate sparkline | P2 | C/D | ✅ | A: `diagnostics/diagnostics_ui_test.dart` "quality panel renders gauge and charts"; N: `run_tests.py` (`call.stats` in the call tests); QA_ANDROID B (quality 4.4 shown). |
| D2 | Built-in SIP trace viewer (ladder and raw), filtering, export with password redaction | P2 | C/D | ✅ | A: `diagnostics/sip_parser_test.dart` (redaction, pcap, grouping), `diagnostics/diagnostics_ui_test.dart` "list, filters, raw viewer, redaction, ladder, export, clear"; N: `test_04_sip_trace_and_log`; QA_ANDROID I. |
| D3 | Network diagnostics wizard: NAT type (STUN), DNS/SRV resolution, OPTIONS ping, TLS check | P2 | C/D | ✅ | A: `diagnostics/diagnostics_ui_test.dart` "healthy setup passes every step", "symmetric NAT and no network produce actionable advice"; N: `test_05_diag`. The STUN step has no real STUN server in tests (see N4). |
| D4 | Log export, debug log levels | P1 | D | ◐ | Log viewer and search: A: `diagnostics/diagnostics_ui_test.dart` "... logs are listed and searchable"; log rotation: `polish_a1_test.dart`. Missing: the support-bundle export is untested. |
| D5 | Per-call quality history saved in call history | P2 | D | ◐ | A: `diagnostics/diagnostics_ui_test.dart` "history model is backwards compatible"; QA_ANDROID B shows the quality value for a call. Missing: no test that the summary is saved when a call ends. |

## Not implemented or deferred
| ID | Feature | Pri | Layer | Status | Evidence |
|---|---|---|---|---|---|
| Z1 | Push notifications for incoming calls (needs a push server and PBX support) | P2 | P | ☐ | Not implemented. iOS receives calls only while the app runs; Android uses a foreground service instead. |
| Z2 | CardDAV / LDAP / Outlook contacts | P1 | D | ☐ | Not implemented (no code in `app/lib`). |
| Z4 | Visual voicemail | P2 | D | ☐ | Not implemented; only the MWI indicator and voicemail dial exist (P4). |
| Z5 | Group chat on LAN Link | P2 | D | ☐ | Not implemented; LAN chat is one to one (L3). |
| Z7 | Linux desktop app | P2 | P | ☐ | Not a target: there is no `app/linux` runner. Linux is built only to run the engine tests in CI. |

## Compared with Zoiper Premium, Bria, Groundwire, MicroSIP and Linphone

This comparison uses only the claims in [research/COMPETITOR_FEATURES.md](research/COMPETITOR_FEATURES.md) (vendor pages fetched on 2026-10-19). **Y** = yes, **N** = no, **P** = partial or depends. A cell with **?** or **Y?** comes from general knowledge in that document, not from a fetched vendor page, and is **unverified**. "Bria" covers Solo, Teams and Enterprise. The SoftphonePro column repeats the status of the row named in brackets. Competitor products change, so check the vendor before relying on a cell.

| Feature | SoftphonePro | Zoiper Premium | Bria | Groundwire | MicroSIP | Linphone |
|---|---|---|---|---|---|---|
| Several accounts at once | ✅ (A1) | Y | P (5 on Solo) | Y | Y | Y |
| IAX2 | ✅ (A8) | Y | N | N | N | N |
| UDP / TCP / TLS | ✅ (N1) | Y | Y | Y | Y | Y |
| TLS client certificate | ✅ (N9) | ? | ? | ? | P | Y |
| STUN / ICE / TURN | ◐ (N4) | Y | Y | Y | Y | Y |
| IPv6 | ◐ (N3) | ? | ? | ? | P | Y |
| SRTP (SDES) | ✅ (S1) | Y | Y | Y | Y | Y |
| DTLS-SRTP | ✅ (S2) | ? | ? | ? | Y | Y |
| ZRTP | ☐ (S6) | Y (mobile Premium) | ? | Y (optional) | N? | Y |
| Video | ☐ (M8) | Y | Y | Y? | Y | Y |
| G.729 | ◐ (M1) | Y | Y? | ? | Y | Y |
| Echo cancellation / noise suppression | ◐ (M3) | Y | Y | Y | Y (WebRTC AEC) | Y |
| Blind and attended transfer | ✅ (C5, C6) | Y | Y | Y | Y | Y |
| Call recording | ✅ (C9) | ? | Y? | Y | Y? | Y |
| Auto-answer / intercom | ◐ (C10) | Y? | Y? | ? | Y | Y |
| Call park / pickup | ✅ (C13) | ? | ? | ? | N | N |
| Local 3-way conference | ◐ (C8) | Y | Y | Y | Y | Y |
| SIP MESSAGE instant messages | ✅ (P1) | Y (mobile) | Y | ? | Y | Y |
| Presence (SIMPLE) | ✅ (P2) | Y | Y | ? | Y | P |
| BLF (RFC 4235) | ✅ (P3) | ? | Y? | ? | P | N |
| Voicemail indicator (MWI) | ◐ (P4) | Y | Y | Y | Y | Y |
| System contacts | ◐ (H3) | Y | Y | Y | N (local) | Y |
| LDAP / Outlook contacts | ☐ (Z2) | Y | Y | N? | N | Y (LDAP, CardDAV) |
| Speed dial | ✅ (C14) | Y | Y | Y? | Y | N |
| `sip:` / `tel:` URL handlers | ✅ (C16) | Y | Y | Y | Y | Y |
| Browser click-to-call | ✅ (U7) | Y | ? | N | N | N |
| Auto-provisioning from a URL | ✅ (A9) | Y | Y (Stretto) | Y? | P (INI file) | Y |
| QR provisioning | ◐ (U8) | ? | ? | Y? | N | Y |
| Desktop API for other programs | ✅ (D6) | not covered | Y, paid ("Bria Desktop API") | not covered | not covered | not covered |
| Call statistics (MOS, jitter, loss) | ✅ (D1) | Y? | Y | P | P | Y |
| SIP log viewer | ✅ (D2) | P | P | P | P (log file) | P |
| Push notifications (needs a server) | ☐ (Z1) | Y (Zoiper proxy) | Y (CounterPath/Stretto) | Y (Acrobits cloud) | N/A | Y (Linphone accounts) |
| Screen reader | ◐ (U4) | ? | ? | iOS VoiceOver ? | Y (NVDA) | ? |
| Right-to-left languages | ☐ (U5) | ? | ? | ? | Y | ? |

Not covered by the research document, so no comparison is made: voice isolation (M9), the audio library and announcements (C20-C22), recording formats (C23), caller identity display (P5), and LAN Link (L1-L8). The document lists RNNoise-style local noise suppression as an idea for differentiation, not as a competitor feature.

