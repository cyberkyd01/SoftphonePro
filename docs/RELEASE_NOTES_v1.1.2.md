# SoftphonePro v1.1.2

Release date: 2026-10-21.

SoftphonePro is a free, open-source softphone for Windows, macOS, Linux, Android and iOS. It has no ads, no tracking and no subscription. This is the first public release.

This page says what is in the release, how to install it, what is not finished and how it was tested. Every feature has a row in [FEATURES.md](FEATURES.md) with the test that backs it. Where a feature was only checked by hand, or only in part, the row says so. The full list of features is in the [README](../README.md#features) and the [changelog](../CHANGELOG.md).

## Highlights

**Calls and accounts**
* Up to 64 SIP and IAX2 accounts at once, over UDP, TCP, TLS 1.2/1.3 and WebSocket, with automatic transport selection (DNS SRV), mutual TLS, SRTP and DTLS-SRTP.
* HD audio (Opus, G.722, G.711, G.729 and more), AI noise cancellation (RNNoise) for your microphone and for noisy callers, echo cancellation (WebRTC AEC3).
* Transfer, local conferences, call park and pickup, BLF, presence, messaging, voicemail indicator, call recording with a Recordings page, auto-answer and intercom.
* LAN Link: pair your own devices on the local network for chat, file drop, direct calls and handing a call from one device to another.

**Audio test and live audio mixer**
* **Audio test page** (Settings → Audio → **Test microphone and speakers**, also from the mixer and Diagnostics):
  1. Devices: pick the microphone and speaker and see which one is actually in use.
  2. Microphone: a live level that moves while you speak, "We hear you" when the signal is good, hints when it is silent, very quiet or clipping, and links to the system sound and privacy settings on Windows and macOS.
  3. Speaker or earphones: plays a short chime, and you confirm that you heard it.
  4. Record and play back: records 5 seconds and plays them back.
  5. Hear yourself: a live echo test with echo cancellation bypassed. It stops by itself after 60 seconds. Use headphones: with loudspeakers you will hear feedback.
  6. Background music: the musicbed with a preview of what callers hear (your voice and the music as they are sent).
  7. Summary: the result of each step and a **Copy diagnostics** button for support.
* **Live audio mixer** on the keypad screen, in calls and in Settings → Audio: level bars and sliders for the microphone, the speaker or headphones and the musicbed, with device pickers. On desktop the meters are live whenever they are on screen; on phones only on the Audio test and Settings → Audio pages; on iPhone only during a call.
* **Musicbed:** an MP3 or WAV file that loops under your voice to the people on your calls, with its own volume (0-200 %) and an optional "Hear it myself" monitor.
* Device problems are never silent: if a device cannot be opened you get a notice, and the mixer says when a silent device is in use.

**Platforms**
* Desktop apps for Windows, macOS and Linux (including Raspberry Pi 4/5 with 64-bit Raspberry Pi OS), with tray icon, notifications with Answer and Decline, `sip:`/`tel:` links, start at login and global shortcuts.
* Android and iOS apps, and a click-to-dial browser extension.
* The interface in 13 languages, with right-to-left layout for Arabic.

## Downloads and install notes

Get the files from the [Releases page](https://github.com/cyberkyd01/SoftphonePro/releases/tag/v1.1.2). **None of the builds are code-signed or notarised yet**, so your system will warn you the first time.

| Platform | File | Install |
|---|---|---|
| Windows 10/11 (x64) | `SoftphonePro-Setup-1.1.2-x64.exe` (installer) or `SoftphonePro-1.1.2-windows-x64-portable.zip` | Run the installer. If SmartScreen says "Windows protected your PC", choose **More info → Run anyway**. The installer registers the `sip:`, `tel:`, `callto:` (optional) and `softphonepro:` links and can start the app at login. |
| macOS 11+ (Apple Silicon and Intel) | `SoftphonePro-1.1.2-macOS.dmg` | Drag the app to Applications. The first time, **right-click → Open**, or run `xattr -dr com.apple.quarantine /Applications/SoftphonePro.app`. The build is ad-hoc signed, not notarised, so Gatekeeper blocks a plain double-click. |
| Linux, PC (amd64) | `SoftphonePro-1.1.2-linux-amd64.deb` or `SoftphonePro-1.1.2-linux-amd64.tar.gz` | Ubuntu 22.04+, Debian 12+. Run `sudo apt install ./SoftphonePro-1.1.2-linux-amd64.deb`, or double-click the file to open it in the software centre. For the archive, extract it and run `./softphonepro`; optionally run `./install-desktop-entry.sh` for the menu entry and link handling. |
| Linux, ARM (arm64) | `SoftphonePro-1.1.2-linux-arm64.deb` or `SoftphonePro-1.1.2-linux-arm64.tar.gz` | Raspberry Pi 4/5 (also Pi 3) with 64-bit Raspberry Pi OS Bookworm, ARM Ubuntu 22.04+ and Debian 12+. Same steps as above with the arm64 file. Uninstall the `.deb` with `sudo apt remove softphonepro`. |
| Android 7+ | `SoftphonePro-1.1.2-android-universal.apk` (or a per-ABI APK) | Allow "Install unknown apps" for your browser or file manager, then open the APK. After installing, open **Settings → Notifications and ringtones → Background reliability** and allow background running so calls arrive with the screen off. |
| iOS 15.5+ | `SoftphonePro-1.1.2-unsigned.ipa` | The IPA is unsigned. Install it with AltStore or Sideloadly, which sign it with your Apple ID. Free Apple IDs expire after 7 days and the app must be re-signed. The App Store does not accept GPL apps, so there is no store build. |
| Browser extension | `SoftphonePro-ClickToDial-chrome-1.1.2.zip`, `SoftphonePro-ClickToDial-firefox-1.1.2.zip` | Not on the browser stores yet. Unzip and load it as an unpacked extension (Chrome, Edge, Brave) or as a temporary add-on (Firefox). Steps are in [extensions/browser/README.md](../extensions/browser/README.md). |

The Linux packages are built on Ubuntu 22.04 (glibc 2.35). More Linux steps, including the tray, links and uninstall, are in the [user guide](USER_GUIDE.md#install-on-linux--raspberry-pi).

**After installing, open Settings → Audio → Test microphone and speakers** to check your microphone, speaker or earphones and background music before your first call.

## Known limitations

* **Microphone indicator on desktop.** The microphone is open while the mixer's meters are on screen (that is what makes them live), so Windows and macOS show the microphone-in-use indicator then.
* **Echo test.** Echo cancellation is bypassed while it runs, so use headphones. It cannot run during a call.
* **Linux builds are 64-bit only.** 32-bit Raspberry Pi OS is not supported.
* **Linux has fewer features than the other desktops.** There is no QR camera scanning (paste the code's text), no biometric app unlock (PIN only), no mDNS discovery (LAN Link uses its multicast discovery, which works with the other platforms) and no system contacts import.
* **Linux tray.** The tray icon needs a desktop with a StatusNotifierItem host. Ubuntu, KDE and the Raspberry Pi panel have one; stock GNOME on Debian needs the AppIndicator extension. Without a tray, closing the window quits the app, so calls stop ringing.
* **Linux global shortcuts** work on X11 sessions only, not on Wayland.
* **Linux audio** goes through ALSA. On PulseAudio and PipeWire systems pick the `default` device.
* **Musicbed.** It does not play to held calls, which hear the hold music. The local automation API (`/v1/audio`) can switch it on and off and set the volumes, but the file is chosen in the app only. With **Hear it myself** on and no headphones, the microphone can pick the music up again.
* **iOS background calls.** iOS delivers incoming calls only while the app is running. Calls in the background need VoIP push (PushKit), a push server and PBX support, which this release does not have. Android avoids the problem with a foreground service.
* **No video and no ZRTP.** Both are planned for a later version (rows M8 and S6 in FEATURES.md).
* **Translations are machine-assisted.** All 13 languages are complete, but some wording may sound unnatural. Corrections are welcome as pull requests to `app/lib/l10n/`.
* **Hold music through Asterisk.** When the PBX answers a hold request itself, the caller hears the PBX's own music, not yours. Your music plays on direct calls and on PBXs that relay the held party's audio.
* **Ogg Opus recordings** play inside the app on Android and Linux only. On iPhone, Mac and Windows, use *Open with…* or export the file; WAV plays everywhere.
* **IAX2** is IPv4 only, with no MWI, trunking or encryption (see ENGINE_API.md §7). SIP over IPv6 has not been tested against a server.
* **STUN and TURN** are configurable and the network wizard checks them, but the automated tests have no STUN or TURN server, so they are untested against real ones. NAPTR lookups, SIP Outbound, session timers and 100rel have no automated tests either.
* **Encryption covers the database only.** Recording audio files are stored unencrypted.
* **Not implemented:** push notifications, CardDAV/LDAP contacts, visual voicemail and LAN group chat. The full list is at the end of [FEATURES.md](FEATURES.md).
* **Privacy note:** on Android and iOS the QR scanner uses Google ML Kit (a proprietary component bundled in the app, see [THIRD_PARTY_NOTICES.md](../THIRD_PARTY_NOTICES.md)). The app has no analytics or telemetry code of its own.

## How it was tested

* **Automated tests:** 735 app tests (including the Audio test page, the live meters on desktop and phones, the echo test and the device-error notice) and 64 `spcore_dart` tests on Windows; native engine tests against an Asterisk 20 PBX in CI; LAN Link and browser-extension tests. All 14 language files are checked for every text.
* **CI:** Windows EXE and installer runtime smoke, macOS app smoke, iOS build and simulator launch, Android build and emulator launch, and for Linux amd64 and arm64 the `.deb` and `.tar.gz` builds, `apt install` on Debian 12, Debian 13, Ubuntu 22.04 and Ubuntu 24.04, and a runtime smoke under Xvfb (register, a call that connects, DTMF, a `sip:` link).
* **Windows audio on real hardware** (Windows 11, Intel Smart Sound microphone, Realtek speaker, VB-Audio virtual cable): with a known tone fed into the engine, the live microphone meter reads a steady level outside calls, the echo test plays the microphone back without dropouts with echo cancellation set to automatic, echo cancellation is restored within milliseconds when a call starts, device switching and recovery work, and the test chime plays to the end. Device names with characters such as `®` are listed and can be selected.
* **Linux end to end** (on the 1.1.0 build, arm64 Debian 12 and Ubuntu 24.04 containers, Xvfb, PulseAudio null sinks, Asterisk 20): musicbed levels measured at the far end, keyring, tray, MPRIS, notifications, links, start at login, X11 hotkeys and LAN Link between two devices. Details: [QA_LINUX.md](QA_LINUX.md).
* **Android emulator** (on the 1.1.0 build, Android 15, arm64): 24 passed, 1 blocked, 0 failed, including the musicbed measured in recordings. Details: [QA_ANDROID.md](QA_ANDROID.md).
* **macOS** was driven end to end on an earlier build ([QA_MACOS.md](QA_MACOS.md)).

**What was not tested:** Raspberry Pi hardware; Wayland sessions; real GNOME or KDE tray hosts and notification daemons; KWallet; Bluetooth, earpiece and wired routes on Android; the Windows app's screens on a device by the developers (the engine's audio was tested on Windows hardware, the screens by automated tests and CI launch); macOS and iOS calls on this build (CI launch smoke only); CallKit, the Android Telecom integration with a real Bluetooth or car system, camera QR scanning, device contacts import and setting the default `sip:`/`tel:` handler.

Found a bug? Please [open an issue](https://github.com/cyberkyd01/SoftphonePro/issues) with the app version, platform and, for audio problems, the text from **Copy diagnostics** on the Audio test page. For call problems, add a SIP trace exported from **Settings → Diagnostics** (passwords are removed by default).

## Credits and licence

SoftphonePro is free software under the **GNU General Public License v3.0 or later** ([LICENSE](../LICENSE)). It is built on PJSIP, OpenSSL, Opus, bcg729, RNNoise, minimp3, cJSON, Flutter and many Dart packages; the full list with versions and licences is in [THIRD_PARTY_NOTICES.md](../THIRD_PARTY_NOTICES.md). Thanks to the authors of all of them, and to the Asterisk project for the test PBX image.

The source for this release is the repository at the `v1.1.2` tag: https://github.com/cyberkyd01/SoftphonePro. See [BUILDING.md](BUILDING.md) to build it yourself and [CHANGELOG.md](../CHANGELOG.md) for the list of changes.
