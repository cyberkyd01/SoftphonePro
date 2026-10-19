# SoftphonePro — Feature List and Status

How to read this list:
* **Priority:** P0 is parity with free and basic softphones. P1 is parity
  with premium products (Zoiper Premium, Bria, Groundwire). P2 covers
  features that competitors don't offer, or charge extra for.
* **Status:** ☐ planned · ◐ implemented · ✅ implemented and covered by
  automated tests.
* **Layer:** C = spcore, D = Dart app, P = platform code.
  (Kotlin/Swift/C++)

## Accounts and registration
| ID | Feature | Pri | Layer | Status |
|---|---|---|---|---|
| A1 | Unlimited* SIP accounts registered **simultaneously** (*64 compiled limit) | P0 | C/D | ☐ |
| A2 | Per-account enable/disable, register/unregister, status chip with code and reason | P0 | D | ☐ |
| A3 | Auth user, outbound proxy (several), registrar override, realm, display name, caller-ID | P0 | C | ☐ |
| A4 | Registration expiry, retry/backoff, keep-alive, contact/Via rewrite (NAT), rport | P0 | C | ☐ |
| A5 | Default account for outgoing calls, plus choosing the account per call | P0 | D | ☐ |
| A6 | Account templates for popular providers and PBXs (Asterisk, FreePBX, 3CX, FreeSWITCH, Twilio, Telnyx, VoIP.ms, generic) | P1 | D | ☐ |
| A7 | Registration health monitor and automatic failover to a backup server | P2 | D | ✅ |
| A8 | IAX2 accounts (Zoiper USP) | P1 | C | ✅ |
| A9 | Account import/export (JSON, QR) and remote provisioning (HTTPS URL, `${VARS}`) | P1 | D | ☐ |
| A10 | Dedicated local port per account (needed by some providers) | P1 | C | ☐ |

## Transports and network
| ID | Feature | Pri | Layer | Status |
|---|---|---|---|---|
| N1 | SIP over UDP, TCP, TLS (1.2/1.3), with server certificate verification option | P0 | C | ☐ |
| N2 | SIP over WebSocket (WS/WSS, RFC 7118) for WebRTC-style servers | P1 | C | ✅ |
| N3 | IPv6 and dual stack | P1 | C | ☐ |
| N4 | STUN, ICE, TURN (UDP/TCP/TLS) | P0 | C | ☐ |
| N5 | Network change handling (Wi-Fi ↔ cellular, VPN): re-register and re-INVITE | P0 | C/D | ☐ |
| N6 | QoS DSCP marking (SIP CS3, RTP EF) | P1 | C | ☐ |
| N7 | DNS SRV/NAPTR, custom DNS servers | P1 | C | ☐ |
| N8 | SIP Outbound (RFC 5626), session timers (RFC 4028), 100rel (RFC 3262) | P1 | C | ☐ |
| N9 | Mutual TLS: client certificate, key and key password per account (file pickers; key password in secure storage) | P1 | C/D | ✅ |
| N10 | Automatic transport: DNS SRV (`_sips._tcp`, `_sip._tcp`, `_sip._udp`) with the resolved server shown in the account sheet | P1 | C/D | ✅ |

## Security
| ID | Feature | Pri | Layer | Status |
|---|---|---|---|---|
| S1 | SRTP SDES (AES-CM, AES-GCM), optional or mandatory | P0 | C | ☐ |
| S2 | DTLS-SRTP | P1 | C | ☐ |
| S3 | Per-call security indicator (signalling TLS plus media SRTP) | P1 | D | ☐ |
| S4 | Passwords in the OS keystore (Keychain/Keystore/DPAPI) | P0 | D | ☐ |
| S5 | App lock (PIN/biometric), privacy mode with no telemetry | P2 | D | ✅ |
| S6 | ZRTP with SAS verification | P2 | C | ☐ (phase 2) |

## Codecs and audio
| ID | Feature | Pri | Layer | Status |
|---|---|---|---|---|
| M1 | Opus (wideband/fullband), G.722, G.711 µ/A, GSM, iLBC, Speex NB/WB/UWB, G.729 (bcg729), G.722.1, L16 | P0 | C | ☐ |
| M2 | Codec enable and priority, globally and per account | P0 | C/D | ☐ |
| M3 | Echo cancellation (WebRTC AEC3 / platform VPIO / speex), noise suppression, AGC | P0 | C | ☐ |
| M4 | Choice of mic, speaker and **separate ringer device**; hot-plug refresh | P1 | C/D | ✅ |
| M5 | Mic/speaker volume, live VU meters, mic test loopback | P1 | C/D | ☐ |
| M6 | Jitter buffer and VAD/CNG tuning, ptime | P1 | C | ✅ |
| M7 | Android audio routes (earpiece/speaker/Bluetooth/wired), proximity sensor | P0 | P | ☐ |
| M9 | Voice isolation: AI noise cancellation (RNNoise) for mic and incoming audio, strength, live speech meter, in-call toggle | P1 | C/D | ✅ |
| M10 | Audio library: import WAV/MP3, record your own, preview, rename, delete | P1 | D | ✅ |
| M8 | Video calls (H.264/VP8) | P1 | C/P | ☐ (phase 2) |

## Call handling
| ID | Feature | Pri | Layer | Status |
|---|---|---|---|---|
| C1 | Outgoing and incoming calls, early media, ringback, busy/congestion tones | P0 | C | ✅ |
| C2 | Answer, reject (busy/decline), hang up, multiple simultaneous calls (call waiting with tone) | P0 | C/D | ☐ |
| C3 | Hold/resume, mute, swap between calls | P0 | C/D | ☐ |
| C4 | DTMF: RFC 2833/4733, SIP INFO, in-band, and auto; in-call keypad | P0 | C | ☐ |
| C5 | Blind transfer (REFER) | P0 | C | ☐ |
| C6 | Attended transfer (REFER with Replaces) | P0 | C | ☐ |
| C7 | Handling of incoming REFER and Replaces (be transferred, call pickup) | P0 | C | ☐ |
| C8 | Local N-way conference (merge calls, split, per-party mute/volume) | P1 | C/D | ◐ |
| C9 | Call recording manager: Recordings page (desktop rail, phone More) with list by day, name/number/direction/account/duration/size/format badge, search and account/direction/date filters, in-app player (play, pause, seek), rename, delete with confirmation and bulk delete, export (Save as / Show in folder on desktop, share sheet on phones), storage summary, open recordings folder, auto-delete after N days (startup + daily), two-way links between history and recordings; auto-record rules (off, all, incoming, outgoing; per account; per contact) | P1 | C/D | ✅ |
| C10 | Auto-answer: global, per account, or by header (Call-Info answer-after, Alert-Info auto-answer, Answer-Mode) — intercom | P1 | C/D | ☐ |
| C11 | DND (global or per account), with reject code choice | P0 | D | ☐ |
| C12 | Call forwarding: always, busy, or no answer after N seconds (client-side 302 redirect) | P1 | D | ☐ |
| C13 | Call park and retrieve, call pickup (group/directed) through feature codes and BLF | P1 | D | ✅ |
| C14 | Speed dial and favourites | P0 | D | ✅ |
| C15 | Dial plan rules (regex rewrite, prefix strip/add, per-account routing, E.164) | P1 | D | ☐ |
| C16 | Redial, call back from history, click-to-call URL handlers (sip:, sips:, tel:, callto:) | P0 | D/P | ☐ |
| C17 | Direct IP calls without an account (sip:user@ip) | P1 | C | ✅ |
| C18 | Anonymous call rejection, blocklist | P1 | D | ☐ |
| C19 | Per-account and per-contact ringtones | P2 | D | ✅ |
| C20 | Music on hold: built-in or own file, volume, per-account override; plain hold if the engine refuses | P1 | D | ✅ |
| C21 | Opening announcement when a call connects (incoming/outgoing/both, mute mic, local monitor, skip) | P2 | D | ✅ |
| C22 | Transfer announcement: play a notice to the caller before blind, attended and LAN hand-off transfers | P2 | D | ✅ |
| C23 | Recording formats: Standard WAV, Stereo WAV (you left, caller right) and Compressed Opus (Ogg); Opus playback on Android/Linux, Open with / export elsewhere | P1 | C/D | ✅ |
| C24 | Recording continuity across transfers: the consultation call of an attended transfer and a REFER/relay-spawned call keep recording and are linked in history and the Recordings page | P2 | D | ✅ |

## Messaging and presence
| ID | Feature | Pri | Layer | Status |
|---|---|---|---|---|
| P1 | SIP MESSAGE instant messaging with threads, delivery status, typing indicator | P0 | C/D | ☐ |
| P2 | Presence (SUBSCRIBE/NOTIFY PIDF) and publish of own status | P1 | C | ☐ |
| P3 | BLF (dialog-info, RFC 4235) busy lamp field with one-tap call, pickup or transfer | P1 | C/D | ◐ |
| P4 | MWI voicemail indicator (RFC 3842), count badge and one-tap voicemail dial | P0 | C/D | ☐ |
| P5 | Caller identity: P-Asserted-Identity / Remote-Party-ID name and number, "Forwarded from" (Diversion / History-Info) and "Transferred by" (Referred-By) on incoming, in-call, desktop card and history | P1 | C/D | ✅ |

## Contacts and history
| ID | Feature | Pri | Layer | Status |
|---|---|---|---|---|
| H1 | Call history (all, missed, in, out) with search, filter, per-account view, export CSV | P0 | D | ☐ |
| H2 | Built-in contacts (several numbers or SIP URIs, favourites, notes, ringtone) | P0 | D | ☐ |
| H3 | Device contacts integration (Android/iOS/macOS) | P1 | P | ◐ |
| H4 | vCard / CSV import and export | P1 | D | ☐ |
| H5 | T9 or smart search from the dialer | P1 | D | ☐ |

## LAN Link (exceeds competitors)
| ID | Feature | Pri | Layer | Status |
|---|---|---|---|---|
| L1 | Auto-discovery of SoftphonePro devices on the LAN (mDNS plus multicast fallback) | P2 | D | ☐ |
| L2 | Secure pairing (verified with a 6-digit code), encrypted link (X25519 / AES-GCM) | P2 | D | ☐ |
| L3 | LAN chat between devices | P2 | D | ☐ |
| L4 | File drop with accept/decline, progress, SHA-256 verification | P2 | D | ☐ |
| L5 | Direct LAN calls and intercom without a server | P2 | C/D | ☐ |
| L6 | Transfer or hand off **any external call** to a LAN device (relay bridge, or REFER when possible), blind or attended | P2 | C/D | ☐ |
| L7 | Call pull: take over a call that is active on another LAN device | P2 | D | ☐ |
| L8 | LAN device presence (available, on a call, DND) | P2 | D | ☐ |

## UI / UX
| ID | Feature | Pri | Layer | Status |
|---|---|---|---|---|
| U1 | Adaptive layout for desktop and mobile, light/dark/system theme, accent colours | P0 | D | ☐ |
| U2 | Full-screen incoming-call UI and notifications with Answer/Decline actions | P0 | D/P | ☐ |
| U3 | Desktop: tray icon, minimise to tray, start at login, global hotkeys | P1 | P | ☐ |
| U4 | Keyboard shortcuts, full keyboard navigation, screen-reader labels | P1 | D | ☐ |
| U5 | Localisation framework (English first) with RTL support | P1 | D | ☐ |
| U6 | Onboarding wizard (QR, URL, provider templates, manual) | P1 | D | ☐ |

## Platform integration
| ID | Feature | Pri | Layer | Status |
|---|---|---|---|---|
| X1 | Android foreground service that keeps accounts registered in the background, start on boot | P0 | P | ☐ |
| X2 | Android ConnectionService (self-managed): system call integration, Bluetooth and car controls | P1 | P | ☐ |
| X3 | iOS CallKit integration (native call UI and audio session) | P1 | P | ☐ |
| X4 | Battery optimisation guidance, Wi-Fi lock and wake locks during calls | P1 | P | ☐ |
| X5 | Headset media-button answer/hang-up | P1 | P | ☐ |

## Diagnostics (exceeds competitors)
| ID | Feature | Pri | Layer | Status |
|---|---|---|---|---|
| D1 | Live call quality panel: MOS, jitter, loss, RTT, codec, bitrate sparkline | P2 | C/D | ☐ |
| D2 | Built-in SIP trace viewer (ladder and raw), filtering, export with password redaction | P2 | C/D | ☐ |
| D3 | Network diagnostics wizard: NAT type (STUN), DNS/SRV resolution, OPTIONS ping, TLS check | P2 | C/D | ☐ |
| D4 | Log export, debug log levels | P1 | D | ☐ |
| D5 | Per-call quality history saved in call history | P2 | D | ☐ |
