# Changelog

All notable changes to SoftphonePro are listed here. The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and the project uses [Semantic Versioning](https://semver.org/).

## [Unreleased]

## [1.1.0] - 2026-10-20

Adds a Linux app, a musicbed and a live audio mixer. See [docs/RELEASE_NOTES_v1.1.0.md](docs/RELEASE_NOTES_v1.1.0.md) for downloads, install notes and known limitations. Installs over 1.0.0 and keeps your accounts and settings.

### Added

**Linux**
* Linux desktop app (GTK runner and engine plugin) for 64-bit systems: Ubuntu 22.04+, Debian 12+ and Raspberry Pi OS (64-bit) Bookworm. Built on Ubuntu 22.04 (glibc 2.35). 32-bit Raspberry Pi OS is not supported, because Flutter has no 32-bit ARM Linux build.
* Packages: `.deb` and portable `.tar.gz` for amd64 and arm64 (`SoftphonePro-<ver>-linux-<arch>.deb` / `.tar.gz`). The tarball includes `install-desktop-entry.sh` and `uninstall-desktop-entry.sh` for the menu entry and link handling.
* Desktop integration: tray icon where the desktop has a StatusNotifierItem host (without one, closing the window quits), notifications with Answer/Decline, `sip:`/`sips:`/`tel:`/`callto:`/`softphonepro:` links with a default-handler setting (`xdg-mime`), single instance, start at login, headset and media play-pause through MPRIS, and global shortcuts on X11 sessions (not Wayland).
* Passwords in the Secret Service keyring (GNOME Keyring or KWallet), with an encrypted-file fallback when there is none. Audio through ALSA, which reaches PulseAudio and PipeWire through the `default` device.
* Not on Linux: QR camera scanning, biometric app unlock (PIN only), mDNS discovery (LAN Link uses its multicast discovery, which works with the other platforms) and system contacts.
* Linux builds in CI for amd64 and arm64.

**Musicbed and audio mixer**
* Musicbed: pick an MP3 or WAV file from the audio library and it loops under your voice to the people on your calls. Own volume from 0 to 200%, adjustable live; optional "Hear it myself" monitor with its own volume. It keeps playing while you mute your microphone, is not sent to held calls (they get hold music), reaches every member of a local conference, is included in your side of call recordings, and pauses between calls. Settings > Audio > Musicbed, or from the mixer.
* Engine: `media.musicbedStart`, `media.musicbedStop`, `media.musicbedSet`, `media.musicbedState` and the `media.musicbed` event, and `media.levels` for per-channel levels (contract v1.2, [docs/ENGINE_API.md](docs/ENGINE_API.md) section 10).
* Live audio mixer: level bars and sliders for the microphone (input gain), speaker or headphones (output volume) and the musicbed, with input and output device pickers (the audio route on phones). It is on the keypad screen (a card on desktop and tablets, a collapsible strip on phones), in calls (calls panel on desktop, meters right under the call timer on phones) and in Settings > Audio. The meters update about 15 times a second while audio flows, once a second at idle, and drop to about 5 a second when the screen is drawn without a GPU.
* Automation API: `GET /v1/audio` and `POST /v1/audio` read and set the microphone and speaker levels and the musicbed (on/off, volume, monitor, pause; the file is chosen in the app only), and the SSE stream has an `audio` event.

### Changed
* [docs/FEATURES.md](docs/FEATURES.md): rows added for the musicbed, the mixer and Linux, and the "Linux desktop app" entry (Z7) removed from the not-implemented list. It now has 114 rows.
* The app version is 1.1.0 (build 2), so Android installs it over 1.0.0.

### Fixed
* The app chose Arabic when the system language was not one of the 13 supported ones (for example Swedish). It now falls back to English.
* Text overflows at large text sizes, and in Arabic, on the keypad and in-call screens.
* A flaky FFI plumbing test in `spcore_dart` and a flaky WebSocket close-frame test were made deterministic.
* Calls failed to start on computers with no sound card (servers, VMs); the engine now falls back to its null audio device.
* The status dot of an account that is still registering animated at 60 frames a second; it now steps at 4.
* Found by the 1.1.0 test passes on Linux and Android before release:
  * on Linux without `xdg-user-dirs`, recording did nothing and LAN Link failed to start; Retry after a LAN start failure did not bring back LAN calling;
  * on Linux, Arabic navigation labels and Hindi, Chinese and Japanese text could show empty boxes (no font fallback);
  * a keyring that was locked or not answering froze the Linux app for 25 seconds per request; the app now asks the desktop to unlock it, and keeps passwords in its encrypted file for that session if it stays locked;
  * the missed-call notification's Show action did not open Recents; the tray tooltip raised errors on Linux;
  * on desktop, a call card with a banner could be hidden behind the mixer; on phones the expanded mixer could be cut off; Settings > Audio broke words while a call was active; the musicbed chip claimed the bed was playing to a held call.

## [1.0.0] - 2026-10-19

First public release. Windows, macOS, Android and iOS builds, plus a browser extension. See [docs/RELEASE_NOTES_v1.0.0.md](docs/RELEASE_NOTES_v1.0.0.md) for downloads, install notes and known limitations, and [docs/FEATURES.md](docs/FEATURES.md) for the status of every feature and the test behind it.

### Added

**Languages, privacy and desktop**
* Localisation: the whole interface (screens, dialogs, notices, notifications, SIP error explanations) in 13 languages - English, Spanish, French, German, Brazilian Portuguese, Italian, Dutch, Russian, Turkish, Hindi, Arabic, Simplified Chinese and Japanese - with full right-to-left layout for Arabic. New Settings > Appearance > Language picker (default: follow the system). Android declares RTL support; iOS and macOS declare their languages and localise the permission prompts.
* Optional encryption of the local database (call history, contacts, messages, settings) with AES-256-GCM; key in the OS keystore. Safe migration both ways with a verified copy, a backup until the next start, and a recovery screen if the key is missing.
* Desktop update checker: weekly check of the latest GitHub release, banner with release notes / download / skip, opt-out and Check now in Settings > About.
* Desktop headset / media play-pause button answers and hangs up (or mutes), claimed only while a call rings or is active (macOS and Windows).

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
* Re-provisioning no longer adds duplicate accounts: an imported account that matches an existing one (same protocol, username, domain and registrar, host compared case-insensitively) updates it in place and keeps its id, call history links and, unless the import carries one, its password. The import confirmation says "Update N existing, add M new". Applies to `--provision` and to web link, QR, file and URL imports.
* In-call page in landscape with a large font scale (for example 1.6) showed only the name, timer and End button: it now uses two columns that scroll, so Mute, Hold, Keypad and the other actions stay reachable. The navigation rail, dial pad and call panel of the wide layout no longer overflow at large font scales.
* Right-to-left languages (Arabic) showed SIP addresses and numbers reordered ("127.0.0.1@1016" instead of "1016@127.0.0.1"). Technical strings (SIP URIs, numbers, IP addresses, host:port, codec names) are now isolated left-to-right in account chips and selectors, call screens, recents, contacts, speed dial, diagnostics and the LAN page.
* Recording format setting accepts the aliases `stereo` / `wav-stereo` (WAV stereo) and `ogg` (Opus).
* LAN: the first file offer right after pairing could stay on "Waiting for you" with no accept dialog, and a second offer was then declined as a duplicate. The pairing dialog's automatic close removed the offer dialog instead of itself. Offers now queue until the UI is ready, show one dialog at a time, and a repeated offer of a still-pending transfer re-shows its dialog instead of being declined.

### Changed
* The recording-notice setting points to Settings > Calls > Announcements, with a button to open it.
* The welcome text no longer compares the app with premium apps.
* Native licences are registered once at startup instead of when the About page is built.

### Security
* Fixed before release, after the final review:
  * a remote engine hang on malformed `History-Info` indexes;
  * Android intents that other installed apps could use to place, provision or answer calls;
  * an engine hang on crafted WAV files on Windows;
  * the automation token appearing in settings exports;
  * provisioning imports changing dangerous settings: links, QR codes, pasted text, files and Settings URL fetches now share one allowlist-based import with a single confirmation dialog; TLS pins, custom CA, DNS servers, the automation API, the app lock and all file paths cannot be imported, and auto-answer and automatic recording stay off unless ticked (only the local `--provision` command line is trusted);
  * macOS URL events being parsed as command-line flags, `a=ice-pwd` and JSON secrets in exported traces, and LAN pairing prompts built from unescaped peer names;
  * secrets in the diagnostic bundle's engine log.

  Each fix has a regression test. See [docs/reviews/2026-10-19-final-review.md](docs/reviews/2026-10-19-final-review.md).

### Known limitations

* iOS cannot receive calls in the background (no PushKit/push server).
* Video calls and ZRTP are not implemented.
* Translations are machine-assisted. Recording audio files are not encrypted (the database can be).
* Windows and iOS builds have not been run on a device or simulator. macOS and Android were tested as described in [docs/QA_MACOS.md](docs/QA_MACOS.md) and [docs/QA_ANDROID.md](docs/QA_ANDROID.md).
* Builds are not code-signed or notarised.
* Hold music through Asterisk is the PBX's own; Ogg Opus recordings play in the app on Android and Linux only.

[Unreleased]: https://github.com/cyberkyd01/SoftphonePro/compare/v1.1.0...HEAD
[1.1.0]: https://github.com/cyberkyd01/SoftphonePro/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/cyberkyd01/SoftphonePro/releases/tag/v1.0.0
