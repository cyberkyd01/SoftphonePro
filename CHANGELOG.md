# Changelog

All notable changes to SoftphonePro are listed here. The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and the project uses [Semantic Versioning](https://semver.org/).

## [Unreleased]

### Added
* Localisation: the whole interface (screens, dialogs, notices, notifications, SIP error explanations) in 13 languages - English, Spanish, French, German, Brazilian Portuguese, Italian, Dutch, Russian, Turkish, Hindi, Arabic, Simplified Chinese and Japanese - with full right-to-left layout for Arabic. New Settings > Appearance > Language picker (default: follow the system). Android declares RTL support; iOS and macOS declare their languages and localise the permission prompts.
* Optional encryption of the local database (call history, contacts, messages, settings) with AES-256-GCM; key in the OS keystore. Safe migration both ways with a verified copy, a backup until the next start, and a recovery screen if the key is missing.
* Desktop update checker: weekly check of the latest GitHub release, banner with release notes / download / skip, opt-out and Check now in Settings > About.
* Desktop headset / media play-pause button answers and hangs up (or mutes), claimed only while a call rings or is active (macOS and Windows).

### Changed
* The recording-notice setting points to Settings > Calls > Announcements, with a button to open it.
* The welcome text no longer compares the app with premium apps.
* Native licences are registered once at startup instead of when the About page is built.

## [1.0.0] - 2026-10-19

First public release. Windows, macOS, Android and iOS builds, plus a browser extension. See [docs/RELEASE_NOTES_v1.0.0.md](docs/RELEASE_NOTES_v1.0.0.md) for downloads, install notes and known limitations, and [docs/FEATURES.md](docs/FEATURES.md) for the status of every feature and the test behind it.

### Added

**Call engine (`spcore`, built on PJSIP 2.17)**
* SIP over UDP, TCP, TLS 1.2/1.3 and WebSocket (WS/WSS, RFC 7118), IAX2 (RFC 5456), IPv4 and IPv6 settings, SRTP (SDES) and DTLS-SRTP, ICE, STUN and TURN settings.
* Several accounts registered at once, with per-account codecs, transport and NAT options.
* Codecs: Opus, G.722, G.711, G.729, GSM, iLBC, Speex, G.722.1 and L16.
* Blind and attended transfer, incoming REFER and Replaces, local conferences, hold and mute, DTMF (RFC 2833, SIP INFO, in-band), direct IP calls.
* Presence, BLF (dialog-info), MWI, SIP MESSAGE.
* TLS certificate verification with a bundled Mozilla CA list, certificate pinning and trust-on-demand.
* Mutual TLS: a client certificate, key and key password per account.
* Automatic transport: DNS SRV (`_sips._tcp`, `_sip._tcp`, `_sip._udp`) picks TLS, TCP or UDP and reports the resolved server.
* DSCP marking for SIP, and a clear failure when a TLS or WebSocket transport cannot start.
* Voice isolation: RNNoise AI noise cancellation for the microphone and, separately, for incoming audio, with adjustable strength and a speech detector.
* Media files: play WAV and MP3 into a call, hold music, announcements, and a microphone recorder.
* Recording as WAV, stereo WAV (you left, caller right) and Ogg Opus.
* Caller identity from `P-Asserted-Identity`, `Remote-Party-ID`, `Diversion`, `History-Info` and `Referred-By`.
* A JSON engine API with a versioned contract: [docs/ENGINE_API.md](docs/ENGINE_API.md).

**App (Flutter, one UI for all platforms)**
* Account setup: provider templates (Asterisk/FreePBX, 3CX, FreeSWITCH, Kamailio, Twilio, Telnyx, VoIP.ms, Vonage, WebRTC gateway, IAX2), onboarding, provisioning from a link, QR code, file or URL with variables, and export.
* Registration safeguards: backoff, no endless retries after 401/403/404, failover to a backup registrar.
* Calls: keypad with T9 suggestions, speed dial (slots 1-9), call waiting, call progress tones, per-account and per-contact ringtones, DND, forwarding, auto-answer and intercom, blocklist and anonymous-call rejection, call park and pickup (including BLF pickup with Replaces), dial plan rules and E.164 rewriting, redial and call back.
* Hold music (built in or your own), opening announcements, notices before recording and before transfers, an audio library with import and in-app recording.
* Recordings manager: list by day, search and filters, player, rename, delete, export, auto-delete, automatic recording rules (global, per account, per contact), recording through transfers.
* Caller identity shown on incoming, in-call, desktop and history screens.
* Contacts with vCard and CSV import and export, and import from the device on phones and Mac.
* Messages, Presence and BLF board, voicemail indicator.
* LAN Link: discovery, 6-digit-code pairing with an encrypted channel, chat, file drop, direct calls and intercom, and call hand-off and pull.
* Diagnostics: call quality charts, SIP trace with ladder diagram and `.pcap` export, network wizard, audio tests, logs.
* App lock with a PIN and biometrics.
* Interrupted-call journal: a call cut short by a crash shows up as "Interrupted" in the history.
* Adaptive layout for phones, tablets and desktops, light and dark themes, accent colours.
* Desktop (Windows and macOS): tray or menu-bar icon, notifications with Answer and Decline, global hotkeys, start at login, single instance, `sip:`/`tel:`/`callto:` handling with a "make default" setting, `--dial`, `--provision` and `--minimized`.
* Local automation API on `127.0.0.1` (desktop, off by default): [docs/AUTOMATION_API.md](docs/AUTOMATION_API.md).
* Android: foreground service, full-screen incoming calls, Telecom ConnectionService, audio routing, boot start.
* iOS: CallKit and audio session handling.
* Third-party notices on the About page and in [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).

**Browser extension (Chrome, Edge, Brave, Firefox)**
* Turns phone numbers on web pages into click-to-dial links, with a context-menu entry, a quick-dial popup and options. No dependencies, no network access.

**Project**
* CI for engine tests against an Asterisk test PBX, Dart and Flutter tests, and builds for Windows, macOS, iOS and Android; release workflow that publishes the installers.
* Documentation: user guide, architecture, engine and automation API references, build guide, QA reports for Android and macOS, and two independent review reports.

### Fixed

Found by the independent reviews and the device runs before release:
* Engine review (34 findings): crashes and races on shutdown and during DTMF floods, DNS timeouts, header injection through `call.sendRequest`, number-range checks, a wrong call-security flag for TLS calls, and silently ignored TLS transport failures. Each has a regression test.
* Android: deep links in cold and warm starts, duplicate codecs in the codec list, the transfer sheet hidden by the keyboard, `tel:` and `sip:` links not opening the keypad.
* macOS: URL handling when the app is already running, the first `--dial` call before the account registers.
* Registration retried endlessly after a wrong password; an engine restart could race with account synchronisation.
* Per-contact and per-account ringtones, the recording beep, the blocklist (it matched number fragments) and emergency dialling without accounts.
* TLS verification was on by default but no CA list shipped, so the engine could not start on Windows and iOS; the app now ships the Mozilla CA bundle and no longer falls back silently to the simulator when the engine fails to start.

### Known limitations

* iOS cannot receive calls in the background (no PushKit/push server).
* Video calls and ZRTP are not implemented.
* The interface is English only.
* Windows and iOS builds have not been run on a device or simulator. macOS and Android were tested as described in [docs/QA_MACOS.md](docs/QA_MACOS.md) and [docs/QA_ANDROID.md](docs/QA_ANDROID.md).
* Builds are not code-signed or notarised.
* Hold music through Asterisk is the PBX's own; Ogg Opus recordings play in the app on Android and Linux only.

[Unreleased]: https://github.com/cyberkyd01/SoftphonePro/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/cyberkyd01/SoftphonePro/releases/tag/v1.0.0
