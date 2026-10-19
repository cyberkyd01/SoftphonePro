# Third-party notices

SoftphonePro is released under the GNU General Public License v3.0 or later (see [LICENSE](LICENSE)). It contains or links the components below. Versions are the ones pinned in the repository (`native/scripts/fetch_deps.sh`, `native/third_party/*`, `app/pubspec.lock`). The app shows the same notices under **Settings → About**, and Flutter's licence page there lists every Dart package.

The full licence texts are in each upstream project (links below) and in the downloaded source archives that `native/scripts/fetch_deps.sh` verifies by SHA-256. The vendored components keep their licence files next to the code.

## Native call engine (`spcore`)

| Component | Version | Licence | Used for | Source |
|---|---|---|---|---|
| PJSIP (pjproject) | 2.17 | GPL-2.0-or-later | SIP, SDP, media, NAT traversal | https://github.com/pjsip/pjproject |
| OpenSSL | 3.5.9 | Apache-2.0 | TLS, SRTP and DTLS cryptography | https://www.openssl.org/ |
| Opus | 1.6.1 | BSD-3-Clause (plus royalty-free patent licences) | Opus codec and Ogg Opus recordings | https://opus-codec.org/ |
| bcg729 | 1.1.2 | GPL-3.0-or-later | G.729 codec | https://github.com/BelledonneCommunications/bcg729 |
| RNNoise | 0.1.1 (commit `6cbfd53`) | BSD-3-Clause | Voice isolation (AI noise cancellation) | https://github.com/xiph/rnnoise |
| minimp3 | commit `ea99364` | CC0-1.0 | MP3 decoding (hold music, announcements) | https://github.com/lieff/minimp3 |
| cJSON | 1.7.18 | MIT | JSON in the engine's request interface | https://github.com/DaveGamble/cJSON |
| Dart native API (`dart_api_dl`) | from the Dart SDK used for Flutter 3.32.1 | BSD-3-Clause | Posting events from the engine to Dart | https://github.com/dart-lang/sdk |

Vendored copies live in `native/third_party/` (RNNoise with a small portability patch, `spcore-portability.patch`; minimp3 and cJSON unmodified). PJSIP, OpenSSL, Opus and bcg729 are downloaded, checked against a pinned SHA-256 and built statically by the scripts in `native/scripts/`.

SoftphonePro as a whole is GPLv3-or-later. That is compatible with PJSIP (GPLv2-or-later), bcg729 (GPLv3-or-later) and OpenSSL 3 (Apache-2.0). The complete corresponding source for any binary release is this repository at the release tag.

### Libraries bundled inside PJSIP 2.17 (`pjproject/third_party`)

These are built into the engine because PJSIP includes them. Licences are taken from the files in the pjproject 2.17 source archive.

| Library | Version | Licence | Used for |
|---|---|---|---|
| libsrtp | 2.5.0 | BSD-3-Clause (Cisco Systems) | SRTP |
| Speex | SVN r12832 | BSD-3-Clause style (Xiph.Org, Jean-Marc Valin, Analog Devices, CSIRO) | Speex codec, Speex echo canceller (used on Apple platforms) |
| GSM 06.10 | 1.0.12 | Permissive notice (Jutta Degener, Carsten Bormann, TU Berlin, 1992-1994) | GSM codec |
| iLBC | RFC 3951 reference code | Copyright The Internet Society (2004); see the file headers and RFC 3951 | iLBC codec |
| G.722.1 | ITU-T reference code, release 2.1 | Copyright Polycom, Inc. (2004); see the file headers in `third_party/g7221` | G.722.1 codec |
| libresample | about 1.7 | LGPL-2.1-or-later (Julius O. Smith III) | Sample-rate conversion |
| WebRTC audio processing and AEC3 | as bundled by PJSIP | BSD-3-Clause (The WebRTC project authors) | Echo cancellation on Android, Windows and Linux |

PJSIP's `third_party` folder also holds libyuv, a Windows DirectShow helper and others; they are for video or Windows features that are not enabled here (the engine is built with `PJMEDIA_WITH_VIDEO=OFF`).

### Fetched but not used

Oboe 1.11.0 (Apache-2.0, https://github.com/google/oboe) is downloaded by `fetch_deps.sh` and can be selected with `SPC_ANDROID_AUDIO=oboe`. The default, and the build that CI makes, uses OpenSL ES, so Oboe is **not** in the released apps.

## App assets

| Asset | Licence | Source |
|---|---|---|
| Inter typeface (Regular, Medium, SemiBold, Bold) | SIL Open Font License 1.1 | https://github.com/rsms/inter (licence text in `app/assets/fonts/Inter-LICENSE.txt`) |
| Mozilla CA certificate bundle (`app/assets/certs/cacert.pem`, fetched 2026-10-19, SHA-256 in `app/assets/certs/README`) | MPL-2.0 | https://curl.se/docs/caextract.html (https://curl.se/ca/cacert.pem) |
| Ringtones, hold music, chime and record beep | Created for SoftphonePro | Synthesised by `app/tool/gen_ringtones.py` and `app/tool/gen_hold_music.py`; GPL-3.0-or-later like the rest of the project |
| App icons | Created for SoftphonePro | `app/assets/branding/` |

## Flutter and Dart

| Component | Licence |
|---|---|
| Flutter framework and engine (Flutter 3.32.1) | BSD-3-Clause |
| Dart SDK (Dart 3.8.1) | BSD-3-Clause |
| Material Icons and the other fonts and assets shipped by the Flutter SDK | Apache-2.0 and the licences listed on the in-app licence page |

### Dart packages used by the app (`app/pubspec.yaml`)

Licences were read from each package's `LICENSE` file in the pub cache.

| Package | Version | Licence |
|---|---|---|
| audioplayers | 6.6.0 | MIT |
| bonsoir | 2.2.0+1 | MIT |
| collection | 1.19.1 | BSD-3-Clause |
| connectivity_plus | 6.1.5 | BSD-3-Clause |
| cryptography | 2.9.0 | Apache-2.0 |
| cupertino_icons | 1.0.8 | MIT |
| file_picker | 10.2.4 | MIT |
| flutter_riverpod | 3.3.2 | MIT |
| flutter_secure_storage | 10.3.4 | BSD-3-Clause |
| go_router | 17.0.0 | BSD-3-Clause |
| hotkey_manager | 0.2.3 | MIT |
| http | 1.6.0 | BSD-3-Clause |
| intl | 0.20.2 | BSD-3-Clause |
| launch_at_startup | 0.5.1 | MIT |
| local_auth | 2.3.0 | BSD-3-Clause |
| local_notifier | 0.1.6 | MIT |
| mobile_scanner | 6.0.11 | BSD-3-Clause (but see Google ML Kit below) |
| package_info_plus | 9.0.1 | BSD-3-Clause |
| path | 1.9.1 | BSD-3-Clause |
| path_provider | 2.1.5 | BSD-3-Clause |
| qr_flutter | 4.1.0 | BSD-3-Clause |
| screen_retriever | 0.2.2 | MIT |
| sembast | 3.8.5+1 | BSD-3-Clause |
| share_plus | 12.0.2 | BSD-3-Clause |
| tray_manager | 0.5.3 | MIT |
| uuid | 4.6.0 | MIT |
| window_manager | 0.5.2 | MIT |

The workspace packages are part of this project (GPL-3.0-or-later): `lan_link`, `spcore_dart` and `spcore_flutter` in `packages/`. Their own dependencies are `async` 2.13.1, `collection`, `cryptography`, `ffi` 2.2.0, `meta` 1.19.0 and `path` (all BSD-3-Clause apart from `cryptography`, Apache-2.0).

Packages that Flutter pulls in indirectly (for example the platform implementations of the plugins above) are not listed one by one here. Flutter's licence page in the app lists all of them, which is generated from the resolved dependency set.

Development-only tools (`flutter_lints`, `flutter_launcher_icons`) are not part of the shipped apps.

### Patched copy of `bonsoir_android`

`third_party/bonsoir_android/` is a copy of bonsoir_android 2.2.0 (MIT, Copyright (c) 2019 Hugo Delaunay "Skyost") with a fix for the removed Flutter v1 plugin Registrar API. It replaces the pub.dev release through `dependency_overrides` in `app/pubspec.yaml`. Its `LICENSE` file is kept in place.

### Native libraries pulled in by Flutter plugins

* **Android:** AndroidX libraries and CameraX (Apache-2.0), kotlinx-coroutines (Apache-2.0), and **Google ML Kit barcode scanning** (`com.google.mlkit:barcode-scanning` 17.3.0, bundled model) through `mobile_scanner`.
* **iOS:** **GoogleMLKit/BarcodeScanning** (7.0.x) through `mobile_scanner`.
* **macOS:** `mobile_scanner` uses Apple's Vision framework.

Google ML Kit is proprietary software provided under Google's ML Kit and APIs terms (https://developers.google.com/ml-kit/terms), not an open-source licence. It is used only for decoding QR codes on Android and iOS. Anyone who wants a build with no proprietary component can remove `mobile_scanner` and use the paste fallback that the QR sheet already has.

## Browser extension

The extension in `extensions/browser/` has **no third-party dependencies** (no runtime or build packages; `package.json` lists none). It is GPL-3.0-or-later. Its icons are generated from the SoftphonePro app icon.

## Test infrastructure (not shipped)

The test PBX in `tests/sipserver/` uses Asterisk (GPL-2.0) in a Docker image; it is not part of any release.
