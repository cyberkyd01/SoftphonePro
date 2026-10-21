# Changelog

All notable changes to SoftphonePro are listed here. The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and the project uses [Semantic Versioning](https://semver.org/).

## [Unreleased]

## [1.1.3] - 2026-10-21

A bug-fix release. See [docs/RELEASE_NOTES_v1.1.3.md](docs/RELEASE_NOTES_v1.1.3.md). Installs over 1.1.2 and keeps your accounts and settings.

### Fixed
* Turning on LAN Link while the app was running stopped the calling engine ("Couldn't start the calling engine" until Retry; accounts unregistered). Two engine restarts ran at once, the settings change and LAN Link asking for its SIP listener; they now share one restart.
* On computers that draw the screen without a GPU (virtual machines, remote desktops, Linux with Mesa's software renderer), the live level meters on the idle keypad update twice a second instead of five times, cutting their CPU use.
* Linux: file choosers had no title ("Unnamed Window").

## [1.1.2] - 2026-10-21

First public release. Windows, macOS, Linux, Android and iOS builds, plus a browser extension. See [docs/RELEASE_NOTES_v1.1.2.md](docs/RELEASE_NOTES_v1.1.2.md) for downloads, install notes and known limitations, and [docs/FEATURES.md](docs/FEATURES.md) for the status of every feature and the test behind it.

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
* Falls back to a null audio device on computers with no sound card (servers, VMs), and retries the real device when one becomes available; device errors are reported, not silent.
* Windows: audio device names are converted from the ANSI code page to UTF-8, so devices with names such as "Intel® Smart Sound" are listed and can be selected.
* A JSON engine API with a versioned contract (v1.3): [docs/ENGINE_API.md](docs/ENGINE_API.md).

**Audio test, live mixer and musicbed**
* Audio test page (Settings > Audio, Diagnostics > Audio, and the mixer): checks the devices in use, the microphone level (with hints for a silent, quiet or clipping microphone and links to the system sound and privacy settings), the speaker with a test chime, a 5 second record and play back, "hear yourself", and the background music, including a preview of what callers hear. A summary can be copied for support.
* Live audio mixer: level bars and sliders for the microphone (input gain), speaker or headphones (output volume) and the musicbed, with input and output device pickers (the audio route on phones), plus a "sent to callers" level. It is on the keypad screen (a card on desktop and tablets, a collapsible strip on phones), in calls and in Settings > Audio. The meters are live whenever they are on screen on desktop; on phones only on the Audio test and Settings > Audio pages; on iOS only during a call.
* Echo test ("hear yourself") with echo cancellation and noise suppression bypassed while it runs, restored when it ends or a call starts. It stops by itself after 60 seconds.
* Musicbed: pick an MP3 or WAV file from the audio library and it loops under your voice to the people on your calls. Own volume from 0 to 200%, adjustable live; optional "Hear it myself" monitor with its own volume. It keeps playing while you mute your microphone, is not sent to held calls (they get hold music), reaches every member of a local conference, is included in your side of call recordings, and pauses between calls. Settings > Audio > Musicbed, or from the mixer.
* Automation API: `GET /v1/audio` and `POST /v1/audio` read and set the microphone and speaker levels and the musicbed (on/off, volume, monitor, pause; the file is chosen in the app only), and the SSE stream has an `audio` event.

**App (Flutter, one UI for all platforms)**
* Account setup: provider templates (Asterisk/FreePBX, 3CX, FreeSWITCH, Kamailio, Twilio, Telnyx, VoIP.ms, Vonage, WebRTC gateway, IAX2), onboarding, provisioning from a link, QR code, file or URL with variables, and export. Re-provisioning updates matching accounts in place instead of adding duplicates.
* Registration safeguards: backoff, no endless retries after 401/403/404, failover to a backup registrar.
* Calls: keypad with T9 suggestions, speed dial (slots 1-9), call waiting, call progress tones, per-account and per-contact ringtones, DND, forwarding, auto-answer and intercom, blocklist and anonymous-call rejection, call park and pickup (including BLF pickup with Replaces), dial plan rules and E.164 rewriting, redial and call back.
* Hold music (built in or your own), opening announcements, notices before recording and before transfers, an audio library with import and in-app recording.
* Recordings manager: list by day, search and filters, player, rename, delete, export, auto-delete, automatic recording rules (global, per account, per contact), recording through transfers.
* Caller identity shown on incoming, in-call, desktop and history screens.
* Contacts with vCard and CSV import and export, and import from the device on phones and Mac.
* Messages, Presence and BLF board, voicemail indicator.
* LAN Link: discovery, 6-digit-code pairing with an encrypted channel, chat, file drop, direct calls and intercom, and call hand-off and pull.
* Diagnostics: call quality charts, SIP trace with ladder diagram and `.pcap` export, network wizard, audio tests, logs.
* Localisation: the whole interface in 13 languages - English, Spanish, French, German, Brazilian Portuguese, Italian, Dutch, Russian, Turkish, Hindi, Arabic, Simplified Chinese and Japanese - with full right-to-left layout for Arabic and a language picker (default: follow the system, English when the system language is not supported).
* Optional encryption of the local database (call history, contacts, messages, settings) with AES-256-GCM; key in the OS keystore, with safe migration both ways and a recovery screen if the key is missing.
* App lock with a PIN and biometrics.
* Interrupted-call journal: a call cut short by a crash shows up as "Interrupted" in the history.
* Adaptive layout for phones, tablets and desktops, light and dark themes, accent colours.
* Desktop update checker: weekly check of the latest GitHub release, banner with release notes / download / skip, opt-out and Check now in Settings > About.
* Third-party notices on the About page and in [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).

**Platforms**
* Windows and macOS: tray or menu-bar icon, notifications with Answer and Decline, global hotkeys, start at login, single instance, `sip:`/`tel:`/`callto:` handling with a "make default" setting, `--dial`, `--provision` and `--minimized`, and the headset / media play-pause button answers and hangs up (or mutes) while a call rings or is active.
* Linux desktop app (GTK runner and engine plugin) for 64-bit systems: Ubuntu 22.04+, Debian 12+ and Raspberry Pi OS (64-bit) Bookworm, as `.deb` and portable `.tar.gz` for amd64 and arm64. Tray icon where the desktop has a StatusNotifierItem host, notifications with Answer/Decline, `sip:`/`sips:`/`tel:`/`callto:`/`softphonepro:` links with a default-handler setting (`xdg-mime`), single instance, start at login, MPRIS media keys, global shortcuts on X11, passwords in the Secret Service keyring with an encrypted-file fallback, audio through ALSA.
* Local automation API on `127.0.0.1` (desktop, off by default): [docs/AUTOMATION_API.md](docs/AUTOMATION_API.md).
* Android: foreground service, full-screen incoming calls, Telecom ConnectionService, audio routing, boot start.
* iOS: CallKit and audio session handling.

**Browser extension (Chrome, Edge, Brave, Firefox)**
* Turns phone numbers on web pages into click-to-dial links, with a context-menu entry, a quick-dial popup and options. No dependencies, no network access.

**Project**
* CI for engine tests against an Asterisk test PBX, Dart and Flutter tests, and builds for Windows, macOS, Linux (amd64 and arm64), iOS and Android; release workflow that publishes the installers.
* Documentation: user guide, architecture, engine and automation API references, build guide, QA reports for Linux, Android and macOS, and independent review reports.

### Security
Fixed before release, after the final review. Each fix has a regression test; see [docs/reviews/2026-10-19-final-review.md](docs/reviews/2026-10-19-final-review.md).
* A remote engine hang on malformed `History-Info` indexes, and an engine hang on crafted WAV files on Windows.
* Header injection through `call.sendRequest`.
* Android intents that other installed apps could use to place, provision or answer calls.
* The automation token appearing in settings exports, and secrets in the diagnostic bundle's engine log and in exported traces (`a=ice-pwd`, JSON secrets).
* Provisioning imports changing dangerous settings: links, QR codes, pasted text, files and Settings URL fetches share one allowlist-based import with a single confirmation dialog; TLS pins, custom CA, DNS servers, the automation API, the app lock and all file paths cannot be imported, and auto-answer and automatic recording stay off unless ticked (only the local `--provision` command line is trusted).
* macOS URL events being parsed as command-line flags, and LAN pairing prompts built from unescaped peer names.

### Known limitations

* On desktop the microphone is open while the mixer's meters are on screen, so the system shows the microphone-in-use indicator then.
* iOS cannot receive calls in the background (no PushKit/push server).
* Video calls and ZRTP are not implemented.
* Translations are machine-assisted. Recording audio files are not encrypted (the database can be).
* Linux: 64-bit only; no QR camera scanning, biometric unlock, mDNS discovery or system contacts; global shortcuts on X11 only.
* Builds are not code-signed or notarised.
* Hold music through Asterisk is the PBX's own; Ogg Opus recordings play in the app on Android and Linux only.
* Device testing is uneven; see "How it was tested" in [docs/RELEASE_NOTES_v1.1.2.md](docs/RELEASE_NOTES_v1.1.2.md).

[Unreleased]: https://github.com/cyberkyd01/SoftphonePro/compare/v1.1.2...HEAD
[1.1.2]: https://github.com/cyberkyd01/SoftphonePro/releases/tag/v1.1.2
