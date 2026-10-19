# SoftphonePro v1.0.0

Release date: 2026-10-19.

SoftphonePro is a free, open-source softphone for Windows, macOS, Android and iOS. It has no ads, no tracking and no subscription. This is the first public release.

This page says what is in the release, how to install it, what is not finished and how it was tested. Every feature has a row in [FEATURES.md](FEATURES.md) with the test that backs it. Where a feature was only checked by hand, or only in part, the row says so.

## Highlights

**Accounts and networks**
* Up to 64 SIP and IAX2 accounts registered at the same time.
* SIP over UDP, TCP, TLS and WebSocket (WS/WSS, for WebRTC gateways), and IAX2 for Asterisk.
* *Automatic (DNS SRV)* transport: the app asks DNS which transport the server offers and shows the server it chose.
* Mutual TLS (a client certificate per account), certificate pinning, and a bundled Mozilla CA list.
* SRTP and DTLS-SRTP; a padlock shows whether each call is encrypted.
* Provider templates, plus setup from a link, QR code, file or URL. Administrators can use variables such as `${USER}` in the file.

**Calls and audio**
* Opus, G.722, G.711, G.729, GSM, iLBC, Speex, G.722.1 and L16.
* **Voice isolation:** on-device AI noise cancellation (RNNoise) for your microphone and, separately, for incoming audio, with adjustable strength.
* **Hold music**, **announcements** (when a call connects, before recording, before a transfer) and an **audio library** to import or record the files.
* Blind and attended transfer, conferences, call waiting, call park and pickup, BLF, DND, forwarding, auto-answer and intercom, speed dial, dial rules.
* **Caller identity:** the name and number the network asserts, plus "Forwarded from" and "Transferred by".
* **Recordings:** WAV, stereo WAV or compressed Ogg Opus; automatic rules per account and per contact; recording continues through transfers; a Recordings page with search, playback, export and auto-delete.

**Unique features**
* **LAN Link:** devices on your network find each other, pair with a 6-digit code over an encrypted channel, and chat, send files, call each other as an intercom, hand a call over, or pull a call.
* **Diagnostics:** live call quality, a SIP trace viewer with ladder diagram and `.pcap` export, and a network wizard.

**For administrators and integrators**
* **Local automation API** on `127.0.0.1` (desktop, off by default): [AUTOMATION_API.md](AUTOMATION_API.md).
* **Browser extension** (Chrome, Edge, Brave, Firefox) that turns phone numbers into click-to-dial links.
* `sip:`, `tel:`, `callto:` and `softphonepro:` links, "make default" on Windows and macOS, and `--dial`, `--provision` and `--minimized` on the command line.

**Platform integration**
* Windows and macOS: tray or menu-bar icon, notifications with Answer and Decline, global hotkeys, start at login.
* Android: foreground service, full-screen incoming calls, Telecom integration, Bluetooth and wired-headset routing.
* iOS: CallKit.
* App lock with a PIN or biometrics. Incoming calls still ring while the app is locked.

## Downloads and install notes

Get the files from the [Releases page](https://github.com/cyberkyd01/SoftphonePro/releases/tag/v1.0.0). **None of the builds are code-signed or notarised yet**, so your system will warn you the first time.

| Platform | File | Install |
|---|---|---|
| Windows 10/11 (x64) | `SoftphonePro-Setup-1.0.0-x64.exe` (installer) or `SoftphonePro-1.0.0-windows-x64-portable.zip` | Run the installer. If SmartScreen says "Windows protected your PC", choose **More info → Run anyway**. The installer registers the `sip:`, `tel:`, `callto:` (optional) and `softphonepro:` links and can start the app at login. |
| macOS 11+ (Apple Silicon and Intel) | `SoftphonePro-1.0.0-macOS.dmg` | Drag the app to Applications. The first time, **right-click → Open**, or run `xattr -dr com.apple.quarantine /Applications/SoftphonePro.app`. The build is ad-hoc signed, not notarised, so Gatekeeper blocks a plain double-click. |
| Android 7+ | `SoftphonePro-1.0.0-android-universal.apk` (or a per-ABI APK) | Allow "Install unknown apps" for your browser or file manager, then open the APK. Release APKs are signed with the debug key unless the maintainers set a release key, so they can't be updated from a store build. After installing, open **Settings → Notifications and ringtones → Background reliability** and allow background running so calls arrive with the screen off. |
| iOS 15.5+ | `SoftphonePro-1.0.0-unsigned.ipa` | The IPA is unsigned. Install it with AltStore or Sideloadly, which sign it with your Apple ID. Free Apple IDs expire after 7 days and the app must be re-signed. The App Store does not accept GPL apps, so there is no store build. |
| Browser extension | `SoftphonePro-ClickToDial-chrome-1.0.0.zip`, `SoftphonePro-ClickToDial-firefox-1.0.0.zip` | Not on the browser stores yet. Unzip and load it as an unpacked extension (Chrome, Edge, Brave) or as a temporary add-on (Firefox). Steps are in [extensions/browser/README.md](../extensions/browser/README.md). |

Before the first call, add an account: **Get started → Add account** and choose a template, or import a provisioning link or QR code from your administrator. The [user guide](USER_GUIDE.md) covers the rest.

## Known limitations

* **iOS background calls.** iOS delivers incoming calls only while the app is running. Calls in the background need VoIP push (PushKit), a push server and PBX support, which this release does not have. Android avoids the problem with a foreground service.
* **No video and no ZRTP.** Both are planned for a later version (rows M8 and S6 in FEATURES.md).
* **English only.** There is no localisation framework yet (row U5).
* **Hold music through Asterisk.** When the PBX answers a hold request itself, the caller hears the PBX's own music, not yours. Your music plays on direct calls and on PBXs that relay the held party's audio.
* **Ogg Opus recordings** play inside the app on Android and Linux only. On iPhone, Mac and Windows, use *Open with…* or export the file; WAV plays everywhere.
* **IAX2** is IPv4 only, with no MWI, trunking or encryption (see ENGINE_API.md §7). SIP over IPv6 has not been tested against a server.
* **Device testing is uneven.** The macOS app was driven end to end through its automation API (17 checks pass), and the Android app was exercised on an emulator. **Windows and iOS builds have not been run on a device or simulator yet**, and neither has CallKit, the Android Telecom integration with a real Bluetooth or car system, camera QR scanning, device contacts import, or setting the default `sip:`/`tel:` handler.
* **Android emulator checks that were blocked:** blind transfer and DTMF through the PBX could not be confirmed end to end because of the test PBX's network setup; both work in direct-call and macOS tests ([QA_ANDROID.md](QA_ANDROID.md)).
* **STUN and TURN** are configurable and the network wizard checks them, but the automated tests have no STUN or TURN server, so they are untested against real ones. NAPTR lookups, SIP Outbound, session timers and 100rel have no automated tests either.
* **Not implemented:** push notifications, CardDAV/LDAP contacts, encrypted-at-rest history and recordings, visual voicemail, LAN group chat, an update checker, and headset media-button handling of our own. The full list is at the end of [FEATURES.md](FEATURES.md).
* **Privacy note:** on Android and iOS the QR scanner uses Google ML Kit (a proprietary component bundled in the app, see [THIRD_PARTY_NOTICES.md](../THIRD_PARTY_NOTICES.md)). The app has no analytics or telemetry code of its own.

## Testing summary

* **Engine:** over 200 automated tests (`native/tests/`) run the real engine against an Asterisk PBX in CI: registration over every transport, calls, SRTP, DTLS, transfers, conferences, BLF, MWI, recording, IAX2, WebSocket, voice isolation, media files, caller identity, mutual TLS and DNS SRV. An independent code review found 4 critical, 10 major and 20 minor issues; all were fixed, each with a regression test, and the suite was re-run under ASan/UBSan locally with no reports ([reviews/2026-10-19-spcore-review.md](reviews/2026-10-19-spcore-review.md)).
* **App:** over 360 Flutter unit and widget tests, including golden images and the local automation API against a real HTTP server.
* **Packages:** over 60 tests of the Dart engine API and over 50 of the LAN Link protocol, including fuzzing and teardown stress tests.
* **Browser extension:** 65 tests (`node --test`) in CI, plus a puppeteer end-to-end script run by hand in Chrome.
* **Devices:** macOS end to end ([QA_MACOS.md](QA_MACOS.md)) and Android emulator ([QA_ANDROID.md](QA_ANDROID.md)).
* **Feature audit:** an independent audit before release ([reviews/2026-10-19-feature-audit.md](reviews/2026-10-19-feature-audit.md)) found gaps; the closing work is in the changelog.

Found a bug? Please [open an issue](https://github.com/cyberkyd01/SoftphonePro/issues) with the app version, platform, and, if it is about a call, a SIP trace exported from **Settings → Diagnostics** (passwords are removed by default).

## Credits and licence

SoftphonePro is free software under the **GNU General Public License v3.0 or later** ([LICENSE](../LICENSE)). It is built on PJSIP, OpenSSL, Opus, bcg729, RNNoise, minimp3, cJSON, Flutter and many Dart packages; the full list with versions and licences is in [THIRD_PARTY_NOTICES.md](../THIRD_PARTY_NOTICES.md). Thanks to the authors of all of them, and to the Asterisk project for the test PBX image.

The source for this release is the repository at the `v1.0.0` tag: https://github.com/cyberkyd01/SoftphonePro. See [BUILDING.md](BUILDING.md) to build it yourself and [CHANGELOG.md](../CHANGELOG.md) for the list of changes.
