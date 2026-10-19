<div align="center">

<img src="app/assets/branding/icon_1024.png" width="112" alt="SoftphonePro logo">

# SoftphonePro

**A free, open-source softphone for Windows, macOS, Android and iOS, with the features of paid apps like Zoiper Premium and Bria.**

Run as many SIP/IAX2 accounts as you need at the same time · Encrypted calls · Hand calls to other devices on your network · No ads, no tracking, no subscription

[![CI](https://github.com/cyberkyd01/SoftphonePro/actions/workflows/ci.yml/badge.svg)](https://github.com/cyberkyd01/SoftphonePro/actions/workflows/ci.yml)
[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](LICENSE)
[![Release](https://img.shields.io/github/v/release/cyberkyd01/SoftphonePro?include_prereleases)](https://github.com/cyberkyd01/SoftphonePro/releases)

[**Download**](#download) · [Features](#features) · [Screenshots](#screenshots) · [Getting started](#getting-started) · [Build from source](docs/BUILDING.md)

</div>

---

<p align="center">
  <img src="docs/screenshots/macos-in-call.png" width="760" alt="SoftphonePro on macOS during a call">
</p>

## Download

Get the latest builds from the [**Releases page**](https://github.com/cyberkyd01/SoftphonePro/releases/latest).

| Platform | File | Notes |
|---|---|---|
| **Windows** 10/11 (x64) | `SoftphonePro-Setup-<ver>-x64.exe` (installer) or `SoftphonePro-<ver>-windows-x64.zip` (portable) | The installer registers `sip:`, `sips:`, `tel:`, `callto:` and `softphonepro:` links. The build isn't code-signed yet, so if SmartScreen appears choose **More info → Run anyway**. |
| **macOS** 11+ (Apple Silicon and Intel) | `SoftphonePro-<ver>-macOS.dmg` | Drag the app to Applications. The build isn't notarised, so open it the first time with **right-click → Open**, or run `xattr -dr com.apple.quarantine /Applications/SoftphonePro.app`. |
| **Android** 7+ | `app-release.apk` (universal) or the per-ABI APKs | Allow "Install unknown apps" for your browser or file manager. |
| **iOS** 15.5+ | `SoftphonePro-<ver>-unsigned.ipa` | Install it with AltStore or Sideloadly. The App Store doesn't allow GPL apps. |
| **Browser** (Chrome, Edge, Brave, Firefox) | `SoftphonePro-ClickToDial-*.zip` | Click any phone number on a web page to call it with SoftphonePro. See [extensions/browser](extensions/browser/README.md). |

## Features

**Accounts**
* Up to **64 accounts registered at once**.
* SIP over **UDP, TCP, TLS 1.2/1.3 and WebSocket (WS/WSS)**, plus **IAX2**.
* Each account has its own codecs, transport, NAT options, DTMF mode, caller ID and ringtone.
* Ready-made templates for Asterisk/FreePBX, 3CX, FreeSWITCH, Kamailio, Twilio, Telnyx, VoIP.ms, WebRTC gateways and IAX2.
* Automatic failover to a backup server.
* Retries back off sensibly. Registration stops after a wrong password, so your provider won't lock you out.
* Set accounts up from a link (`softphonepro://provision?url=…`), a QR code or a file, or by entering details manually.

**Calls**
* HD audio: Opus, G.722, G.711, G.729, GSM, iLBC, Speex, G.722.1 and L16.
* Echo cancellation (WebRTC AEC3 or the platform's own), noise suppression and a jitter buffer you can tune.
* Hold, mute, call waiting and swap.
* **Blind and attended transfer**, and a **local N-way conference** with per-person volume.
* DTMF as RFC 2833, SIP INFO or in-band.
* Call recording, automatic or per account, with an optional beep.
* Auto-answer and intercom (`Call-Info`, `Alert-Info` and `Answer-Mode` headers).
* Do-not-disturb and call forwarding: always, when busy, or when unanswered. These can also be synced to the PBX through feature codes.
* Call park and retrieve, and group/directed pickup, including BLF pickup with Replaces.
* Speed dial, dial plans and E.164 number rewriting, anonymous-call rejection and a blocklist.
* Direct IP calls without any server.

**Security**
* TLS with certificate verification, using a bundled Mozilla CA list. You can trust a server's certificate by pinning it, with no extra setup.
* **SRTP** (SDES, AES-CM/GCM) and **DTLS-SRTP**.
* A padlock on every call shows whether the call is encrypted.
* Passwords live in the OS keystore.
* App lock with a PIN or biometrics. Incoming calls still ring while the app is locked.

**Messaging, presence and BLF**
* SIP instant messages with delivery receipts and typing indicators.
* Presence, a **Busy Lamp Field** board, and voicemail (MWI) badges with one-tap voicemail.

**LAN Link: features other apps don't have.** SoftphonePro devices on the same network can:
* **Find each other automatically** (mDNS/Bonjour).
* **Pair securely** after you compare a 6-digit code on both screens. The link is end-to-end encrypted (X25519 + AES-256-GCM).
* **Hand off any external call to another device**, blind or after talking first. If the other device can be reached through your PBX, a SIP REFER is used. Otherwise the call is relayed through the device that holds it.
* **Pull a call** that's active on another device to your own.
* Make **direct LAN calls and intercom** with no server needed.
* **Chat and drop files** between devices. Each file needs your OK before it's received, and its integrity is checked with SHA-256.

**Diagnostics**
* A live call-quality panel showing MOS, jitter, packet loss and round-trip time, with charts. The quality summary is saved for every call.
* A built-in **SIP trace viewer** with a ladder diagram and raw messages. Traces export as `.log` or `.pcap`, with passwords removed.
* A **network diagnostics wizard**: NAT type, DNS/SRV lookups, SIP OPTIONS ping, TLS certificate check and SIP-ALG detection.
* Audio tests, a log viewer, and a support bundle you can export.

**Platform integration**
* **Windows/macOS:**
  * a tray or menu-bar icon;
  * notifications with Answer/Decline;
  * global hotkeys;
  * start at login;
  * one running instance;
  * the option to make SoftphonePro your default app for `sip:`/`tel:` links;
  * a **local automation API** for CRM and helpdesk integrations (similar to Bria's paid Desktop API).
* **Android:**
  * a foreground service keeps your accounts registered;
  * full-screen incoming calls;
  * system call integration through Telecom;
  * Bluetooth, wired-headset and earpiece routing;
  * proximity sensor.
* **iOS:** CallKit integration.
* **Every platform:**
  * import contacts from the device;
  * T9 search in the dialer;
  * QR scanning;
  * light and dark themes with an adaptive layout for phones, tablets and desktops.

The full list of about 90 features, each with its status, is in [docs/FEATURES.md](docs/FEATURES.md).

## Screenshots

| macOS | Android |
|---|---|
| <img src="docs/screenshots/macos-keypad.png" width="480"> | <img src="docs/screenshots/android-in-call.png" width="220"> |
| <img src="docs/screenshots/macos-incoming.png" width="480"> | <img src="docs/screenshots/android-incoming.png" width="220"> |
| <img src="docs/screenshots/macos-diagnostics.png" width="480"> | <img src="docs/screenshots/android-lan.png" width="220"> |
| <img src="docs/screenshots/macos-lan.png" width="480"> | <img src="docs/screenshots/android-pairing.png" width="220"> |

## Getting started

1. **Install** the app for your platform (see [Download](#download)).
2. **Add an account.** Open the app and choose **Get started → Add account**. Pick your provider's template, or choose *Generic SIP* and enter your username, password and domain. Your administrator can also send you a provisioning link or QR code that sets everything up in one tap.
3. **Make a call** from the keypad, recent calls, contacts, or any `sip:`/`tel:` link.

**More guides:**
* [User guide](docs/USER_GUIDE.md): provisioning format, LAN Link, transfers, recording and troubleshooting.
* [Automation API](docs/AUTOMATION_API.md): control SoftphonePro from your CRM or scripts.

## How it's built

* **One UI for all four platforms**, written in Flutter and compiled to native code.
* **One calling engine** written in C (`spcore`, built on [PJSIP 2.17](https://www.pjsip.org/)). Flutter talks to it through a small JSON API (FFI).
* **Thin native layers** for the rest: Kotlin for Android (foreground service, Telecom), Swift for iOS (CallKit) and macOS, and C++ for Windows.

Details are in [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) and the engine contract is in [docs/ENGINE_API.md](docs/ENGINE_API.md).

```
app/                    Flutter application (UI, controllers, platform layers)
native/                 C engine "spcore" + dependency build scripts + engine tests
packages/spcore_dart    Dart API for the engine (FFI) + simulator
packages/spcore_flutter Flutter plugin that bundles the native engine
packages/lan_link       LAN discovery, pairing, encrypted link, chat, files, handoff
extensions/browser      Click-to-dial browser extension
tests/sipserver         Asterisk test PBX (Docker) used by the integration tests
```

## Quality and testing

Every push goes through CI on GitHub Actions:
* builds for Windows, macOS, iOS, Android and Linux;
* the engine test suite against a real Asterisk PBX (SIP, IAX2, WS/WSS, SRTP, transfers, conferences, BLF, MWI, recording and more), also run under ASan/UBSan;
* Dart integration tests of the engine;
* the LAN Link protocol tests, including fuzzing and stress tests;
* about 250 Flutter unit and widget tests;
* the browser extension tests.

Release builds are also tested end to end on devices: the macOS app (with [docs/QA_MACOS.md](docs/QA_MACOS.md)) and the Android emulator (with [docs/QA_ANDROID.md](docs/QA_ANDROID.md)). Independent reviews of the engine and of the features are in [docs/reviews](docs/reviews).

## Known limitations

* **iOS background calls:** iOS only gets incoming calls while the app is running. Background calls would need VoIP push notifications (PushKit) plus a push server, and the PBX has to support it. Android keeps accounts registered in the background with a foreground service instead.
* **Not yet supported:** video calls and ZRTP. These are planned for a later version.
* **Unsigned builds:** builds aren't code-signed or notarised yet, so expect a one-time security prompt on Windows and macOS.
* **English only:** the interface is in English for now. Localisation support is planned.

## Contributing

Bug reports and pull requests are welcome.
* Read [docs/BUILDING.md](docs/BUILDING.md) first.
* Run the tests: `flutter test` in `app/`, and `python3 native/tests/run_tests.py` with the test PBX from [tests/sipserver](tests/sipserver/README.md).
* Keep the engine contract ([docs/ENGINE_API.md](docs/ENGINE_API.md)) up to date when you change it.

## License

SoftphonePro is free software under the **GNU General Public License v3.0 or later**. See [LICENSE](LICENSE).

It's built on these open-source components:

| Component | License |
|---|---|
| PJSIP | GPLv2+ |
| OpenSSL | Apache-2.0 |
| Opus | BSD |
| bcg729 | GPLv3 |
| Flutter | BSD |
| Inter font | OFL |
| Mozilla CA bundle | MPL-2.0 |
| Other Dart packages | Their own licenses |

The in-app **Settings → About** page lists every license.
