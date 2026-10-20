# SoftphonePro v1.1.0

Release date: 2026-10-20.

SoftphonePro is a free, open-source softphone for Windows, macOS, Linux, Android and iOS. It has no ads, no tracking and no subscription. This release adds a Linux app, a musicbed and a live audio mixer.

This page says what is new, how to install it, what is not finished and how it was tested. Every feature has a row in [FEATURES.md](FEATURES.md) with the test that backs it. Where a feature was only checked by hand, or only in part, the row says so. Everything in [v1.0.0](RELEASE_NOTES_v1.0.0.md) is still here.

## Highlights

**Linux**
* A Linux app as `.deb` packages and portable `.tar.gz` archives, for amd64 (x86_64 PCs) and arm64 (Raspberry Pi 4 and 5, also Pi 3, with 64-bit Raspberry Pi OS Bookworm; ARM Ubuntu and Debian).
* Supported: Ubuntu 22.04+, Debian 12+ and Raspberry Pi OS (64-bit) Bookworm. 32-bit Raspberry Pi OS is not supported, because Flutter has no 32-bit ARM Linux build.
* Tray icon, notifications with Answer and Decline, `sip:`/`tel:` link handling, a single running instance, start at login, headset and media play-pause keys, and global shortcuts on X11.
* Passwords in the system keyring (GNOME Keyring or KWallet), with an encrypted-file fallback.

**Musicbed**
* Pick an MP3 or WAV file from the audio library and it loops under your voice to the people you are talking to.
* Its own volume (0-200%) changes live. **Hear it myself** lets you monitor it in your headphones, with a separate volume.
* It keeps playing while you mute your microphone. It does not go to held calls, which get hold music. It reaches every member of a local conference and is included in your side of call recordings. It pauses between calls and continues where it stopped.
* **Settings → Audio → Musicbed**, or from the mixer.

**Live audio mixer**
* Level bars and sliders for the microphone (input gain), speaker or headphones (output volume) and the musicbed, with input and output device pickers (on phones, the audio route: earpiece, speaker, Bluetooth or wired).
* On the keypad screen (a card on desktop and tablets, a collapsible strip on phones), during calls (calls panel on desktop, in-call page on phones) and in **Settings → Audio**.
* Everything can be adjusted during a live call.

## Downloads and install notes

Get the files from the [Releases page](https://github.com/cyberkyd01/SoftphonePro/releases/tag/v1.1.0). **None of the builds are code-signed or notarised yet**, so your system will warn you the first time.

| Platform | File | Install |
|---|---|---|
| Windows 10/11 (x64) | `SoftphonePro-Setup-1.1.0-x64.exe` (installer) or `SoftphonePro-1.1.0-windows-x64-portable.zip` | Run the installer. If SmartScreen says "Windows protected your PC", choose **More info → Run anyway**. The installer registers the `sip:`, `tel:`, `callto:` (optional) and `softphonepro:` links and can start the app at login. |
| macOS 11+ (Apple Silicon and Intel) | `SoftphonePro-1.1.0-macOS.dmg` | Drag the app to Applications. The first time, **right-click → Open**, or run `xattr -dr com.apple.quarantine /Applications/SoftphonePro.app`. The build is ad-hoc signed, not notarised, so Gatekeeper blocks a plain double-click. |
| Linux, PC (amd64) | `SoftphonePro-1.1.0-linux-amd64.deb` or `SoftphonePro-1.1.0-linux-amd64.tar.gz` | Ubuntu 22.04+, Debian 12+. Run `sudo apt install ./SoftphonePro-1.1.0-linux-amd64.deb`, or double-click the file to open it in the software centre. For the archive, extract it and run `./softphonepro`; optionally run `./install-desktop-entry.sh` for the menu entry and link handling. |
| Linux, ARM (arm64) | `SoftphonePro-1.1.0-linux-arm64.deb` or `SoftphonePro-1.1.0-linux-arm64.tar.gz` | Raspberry Pi 4/5 (also Pi 3) with 64-bit Raspberry Pi OS Bookworm, ARM Ubuntu 22.04+ and Debian 12+. Same steps as above with the arm64 file. Uninstall the `.deb` with `sudo apt remove softphonepro`. |
| Android 7+ | `SoftphonePro-1.1.0-android-universal.apk` (or a per-ABI APK) | Allow "Install unknown apps" for your browser or file manager, then open the APK. APKs are signed with the project's release key, so this installs over 1.0.0. After installing, open **Settings → Notifications and ringtones → Background reliability** and allow background running so calls arrive with the screen off. |
| iOS 15.5+ | `SoftphonePro-1.1.0-unsigned.ipa` | The IPA is unsigned. Install it with AltStore or Sideloadly, which sign it with your Apple ID. Free Apple IDs expire after 7 days and the app must be re-signed. The App Store does not accept GPL apps, so there is no store build. |
| Browser extension | `SoftphonePro-ClickToDial-chrome-1.1.0.zip`, `SoftphonePro-ClickToDial-firefox-1.1.0.zip` | Not on the browser stores yet. Unzip and load it as an unpacked extension (Chrome, Edge, Brave) or as a temporary add-on (Firefox). Steps are in [extensions/browser/README.md](../extensions/browser/README.md). |

The Linux packages are built on Ubuntu 22.04 (glibc 2.35). More Linux steps, including the tray, links and uninstall, are in the [user guide](USER_GUIDE.md#install-on-linux--raspberry-pi).

## What's new

**Added**
* The Linux app, with `.deb` and `.tar.gz` packages for amd64 and arm64, and its desktop integration (tray, notifications, links, single instance, start at login, MPRIS media keys, X11 global shortcuts, Secret Service keyring).
* The musicbed: an MP3 or WAV file that loops under your voice, with its own volume (0-200%), a "Hear it myself" monitor and a separate monitor volume ([user guide](USER_GUIDE.md#musicbed)).
* The live audio mixer with level bars, sliders and device pickers on the keypad screen, in calls and in Settings → Audio ([user guide](USER_GUIDE.md#audio-mixer)).
* Engine contract v1.2: musicbed methods and event, and per-channel levels ([ENGINE_API.md](ENGINE_API.md), section 10).

**Fixed**
* The app chose Arabic when the system language was not one of the 13 supported ones (for example Swedish). It now falls back to English.
* Text overflows at large text sizes, and in Arabic, on the keypad and in-call screens.
* A flaky engine plumbing test was hardened against slow CI runners.

The full list is in the [changelog](../CHANGELOG.md).

## Known limitations

* **Linux builds are 64-bit only.** 32-bit Raspberry Pi OS is not supported.
* **Linux has fewer features than the other desktops.** There is no QR camera scanning (paste the code's text), no biometric app unlock (PIN only), no mDNS discovery (LAN Link uses its multicast discovery, which works with the other platforms) and no system contacts import.
* **Linux tray.** The tray icon needs a desktop with a StatusNotifierItem host. Ubuntu, KDE and the Raspberry Pi panel have one; stock GNOME on Debian needs the AppIndicator extension. Without a tray, closing the window quits the app, so calls stop ringing.
* **Linux global shortcuts** work on X11 sessions only, not on Wayland.
* **Linux audio** goes through ALSA. On PulseAudio and PipeWire systems pick the `default` device.
* **Linux testing is partial.** It ran in containers, not on Raspberry Pi or desktop hardware, with X11 only. A real gnome-keyring and `xdg-utils` were used, but the tray host and notification daemon were test fakes (rows X9 and X10 in [FEATURES.md](FEATURES.md), [QA_LINUX.md](QA_LINUX.md)).
* **Musicbed.** It does not play to held calls, which hear the hold music. The local automation API (`/v1/audio`) can switch it on and off and set the volumes, but the file is chosen in the app only. With **Hear it myself** on and no headphones, the microphone can pick the music up again.
* **iOS background calls.** iOS delivers incoming calls only while the app is running. Calls in the background need VoIP push (PushKit), a push server and PBX support, which this release does not have. Android avoids the problem with a foreground service.
* **No video and no ZRTP.** Both are planned for a later version (rows M8 and S6 in FEATURES.md).
* **Translations are machine-assisted.** All 13 languages are complete, but some wording may sound unnatural. Corrections are welcome as pull requests to `app/lib/l10n/`.
* **Hold music through Asterisk.** When the PBX answers a hold request itself, the caller hears the PBX's own music, not yours. Your music plays on direct calls and on PBXs that relay the held party's audio.
* **Ogg Opus recordings** play inside the app on Android and Linux only. On iPhone, Mac and Windows, use *Open with…* or export the file; WAV plays everywhere.
* **IAX2** is IPv4 only, with no MWI, trunking or encryption (see ENGINE_API.md §7). SIP over IPv6 has not been tested against a server.
* **Device testing is uneven.** For 1.1.0 the Linux app ran end to end in containers and the Android app on an emulator ([QA_LINUX.md](QA_LINUX.md), [QA_ANDROID.md](QA_ANDROID.md)); the macOS app was driven end to end for 1.0.0 ([QA_MACOS.md](QA_MACOS.md)). **Windows and iOS have only been launch-tested in CI (Windows runner, iOS simulator), not on real devices.** The same list of untested areas as in v1.0.0 applies: CallKit, the Android Telecom integration with a real Bluetooth or car system, camera QR scanning, device contacts import and setting the default `sip:`/`tel:` handler.
* **STUN and TURN** are configurable and the network wizard checks them, but the automated tests have no STUN or TURN server, so they are untested against real ones. NAPTR lookups, SIP Outbound, session timers and 100rel have no automated tests either.
* **Encryption covers the database only.** Recording audio files are stored unencrypted.
* **Not implemented:** push notifications, CardDAV/LDAP contacts, visual voicemail and LAN group chat. The full list is at the end of [FEATURES.md](FEATURES.md).
* **Privacy note:** on Android and iOS the QR scanner uses Google ML Kit (a proprietary component bundled in the app, see [THIRD_PARTY_NOTICES.md](../THIRD_PARTY_NOTICES.md)). The app has no analytics or telemetry code of its own.

## Upgrading from 1.0.0

* **Windows, macOS:** install over the old version. Your accounts, history, contacts and settings are kept.
* **Android:** install the APK over 1.0.0. The build number is higher (2) and the APK is signed with the same key, so Android treats it as an update.
* **iOS:** sideload the new IPA over the old app with the same Apple ID.
* **Linux:** there is no 1.0.0 Linux build, so this is a first install.
* The musicbed is off by default. Nothing about your existing settings changes.

## How it was tested

Everything below was run on the release commit unless it says otherwise.

* **Automated tests, all green:** 721 app tests, 59 `spcore_dart` tests (25 more are skipped because they need the native library), 58 LAN Link tests, 237 native engine tests against an Asterisk 20 PBX (in Release and AddressSanitizer builds, 21 of them for the musicbed) and 65 browser-extension tests. A concurrency stress test found a race in the first musicbed version (3 of 3 failures before the fix, 11 of 11 passes after).
* **CI, 12 jobs:** Windows EXE and installer runtime smoke, macOS app smoke, iOS build and simulator launch, Android build and emulator launch, and for Linux amd64 and arm64 the `.deb` and `.tar.gz` builds, `apt install` on Debian 12, Debian 13, Ubuntu 22.04 and Ubuntu 24.04 (no missing libraries, desktop file and AppStream validate), and a runtime smoke under Xvfb: register, a call that connects, DTMF seen by the PBX, and a `sip:` link opened in a second launch.
* **Linux end to end** (arm64 Debian 12 and Ubuntu 24.04 containers, Xvfb, PulseAudio null sinks, Asterisk 20): the musicbed reaches the far end at -10.8 dBFS with the mic muted, a live volume change from 1.0 to 0.2 drops it 13.8 dB, nothing is sent on hold, and it persists across restart. Keyring unlock (ready 0.43 s after the password), encrypted-file fallback, tray, MPRIS, notification actions, `sip:` and `tel:` links, start at login, X11 hotkeys, and LAN Link between an Ubuntu and a Debian device (6-digit pairing, chat, a 1 MB file with a matching SHA-256, call hand-off) all passed. These passes found and fixed 11 bugs before release, including calls failing with no sound card, recording and LAN Link failing without `xdg-user-dirs`, a locked keyring freezing the app, missing glyphs for Arabic, Hindi and CJK, and high CPU from the level meters and the "registering" animation. Details: [QA_LINUX.md](QA_LINUX.md).
* **Android emulator** (Android 15, arm64): 24 passed, 1 blocked, 0 failed. The musicbed was measured in recordings: clean 440 Hz, -13.8 dB at 20 % volume, silence on hold. Inbound call, DTMF, hold/resume and blind transfer were rechecked. CPU was 0 to 0.5 % idle and 7.6 to 10.5 % in a call. Details: [QA_ANDROID.md](QA_ANDROID.md).

**What was not tested:** Raspberry Pi hardware (Debian 12 arm64 in a VM is the stand-in); Wayland sessions; real GNOME or KDE tray hosts and notification daemons (fakes were used); KWallet; real audio hardware; Bluetooth, earpiece and wired routes on Android; Windows on real hardware (CI only); macOS and iOS calls for 1.1.0 (CI launch smoke only; the full macOS end-to-end run was for 1.0.0, see [QA_MACOS.md](QA_MACOS.md)); and installing 1.1.0 over 1.0.0 on Linux.

**Known remaining behaviour:** on Linux the tray item is registered a few times per start (libayatana-appindicator); a real tray host de-duplicates it, but that was not checked on a real host. Global shortcuts do not work on Wayland. Under software rendering the meters update at about 5 Hz and a call still costs about a third of a core at desktop size.

Found a bug? Please [open an issue](https://github.com/cyberkyd01/SoftphonePro/issues) with the app version, platform, and, if it is about a call, a SIP trace exported from **Settings → Diagnostics** (passwords are removed by default).

## Credits and licence

SoftphonePro is free software under the **GNU General Public License v3.0 or later** ([LICENSE](../LICENSE)). It is built on PJSIP, OpenSSL, Opus, bcg729, RNNoise, minimp3, cJSON, Flutter and many Dart packages; the full list with versions and licences is in [THIRD_PARTY_NOTICES.md](../THIRD_PARTY_NOTICES.md). Thanks to the authors of all of them, and to the Asterisk project for the test PBX image.

The source for this release is the repository at the `v1.1.0` tag: https://github.com/cyberkyd01/SoftphonePro. See [BUILDING.md](BUILDING.md) to build it yourself and [CHANGELOG.md](../CHANGELOG.md) for the list of changes.
