# Building SoftphonePro

Everything here is also what CI does (`.github/workflows/ci.yml`, `release.yml`). Flutter is pinned to **3.32.1**
(Dart 3.8.1) in CI; use the same locally.

Pipeline for every platform: (1) native dependencies (`build_deps_*`) -> `native/out/<target>`;
(2) the C engine `spcore` (`build_spcore*`) -> copied into `packages/spcore_flutter`; (3) `flutter build`;
(4) installer/package step.

| Platform | Needs | Local build possible on |
|---|---|---|
| Android | JDK 17+, Android SDK, NDK 27.0.12077973, cmake, ninja, perl | macOS, Linux |
| Linux (engine tests) | cmake, ninja, perl, python3 (or Docker) | Linux, macOS via Docker |
| Linux (desktop app: .deb + tarball) | Docker, or an Ubuntu 22.04-class Linux host with the packages of `native/scripts/docker/Dockerfile.linux-app`, CMake >= 3.28, Flutter | Linux (native), macOS/Linux via Docker |
| macOS | **Xcode**, CocoaPods, cmake, ninja | macOS (engine part works with Command Line Tools only) |
| iOS | **Xcode**, CocoaPods | macOS with Xcode |
| Windows | Visual Studio 2022 (C++), cmake, ninja, perl, nasm (auto-installed), Inno Setup 6 | Windows |

## Android
```bash
export ANDROID_HOME=$HOME/Library/Android/sdk          # NDK 27.0.12077973 must be installed
native/scripts/build_deps_android.sh all               # once (cached per script/config change)
native/scripts/build_spcore.sh android                 # -> packages/spcore_flutter/android/src/main/jniLibs/<abi>/libspcore.so
cd app && flutter build apk --release --split-per-abi  # or without --split-per-abi for the universal APK
```
Output: `app/build/app/outputs/flutter-apk/*.apk`. The script verifies exported symbols and 16 KB LOAD alignment; check an APK with
`zipalign -c -P 16 -v 4 app-release.apk` and `unzip -l app-release.apk | grep libspcore`.
Note: if `~/.gradle/gradle.properties` pins `org.gradle.java.home` to a JDK that is too new for Gradle 8.12 (e.g. 24+),
override it: `GRADLE_OPTS="-Dorg.gradle.java.home=<path without spaces to a JDK 17/21>"`.

**Signing.** Without a keystore the release APKs use the debug key (installable, not upgradeable from a store build).
For a real key copy `app/android/key.properties.example` to `app/android/key.properties` (gitignored). CI writes that file from the secrets
`ANDROID_KEYSTORE_BASE64`, `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_ALIAS`, `ANDROID_KEY_PASSWORD` when present
(create the base64 with `base64 -i release.jks | pbcopy`).

## macOS
```bash
native/scripts/build_deps_macos.sh all                 # arm64 + x86_64
native/scripts/build_spcore.sh macos                   # universal spcore.framework -> packages/spcore_flutter/macos/Frameworks/spcore.xcframework
cd app && flutter build macos --release
app/macos/packaging/make_dmg.sh 1.0.0                  # -> app/build/macos/dist/SoftphonePro-1.0.0-macOS.dmg
```
`build_spcore.sh macos` works with Command Line Tools only (the xcframework is assembled by `native/scripts/package/make_xcframework.py`);
`flutter build macos` needs full Xcode. The DMG is ad-hoc signed (`codesign --force --deep -s -`).
**Unsigned/ad-hoc DMG on a user's Mac:** drag to Applications, then right-click -> Open (once), or
`xattr -dr com.apple.quarantine /Applications/SoftphonePro.app`.

*Developer ID + notarization (optional)*: set secrets `APPLE_CERT_BASE64` (.p12), `APPLE_CERT_PASSWORD`, `APPLE_SIGN_IDENTITY`
(`Developer ID Application: Name (TEAMID)`); add `APPLE_ID`, `APPLE_TEAM_ID`, `APPLE_APP_PASSWORD` (app-specific password) to notarize and staple.
`make_dmg.sh` then signs nested frameworks + app with the hardened runtime and the app's `Release.entitlements`.

## iOS
```bash
sudo xcode-select -s /Applications/Xcode.app
native/scripts/build_deps_ios.sh all
native/scripts/build_spcore.sh ios                     # -> packages/spcore_flutter/ios/Frameworks/spcore.xcframework
cd app && flutter build ios --release --no-codesign
```
CI zips `build/ios/iphoneos/Runner.app` into `Payload/` -> `SoftphonePro-<ver>-unsigned.ipa`. It cannot be installed directly: sideload it
with **AltStore** or **Sideloadly** (they re-sign with your Apple ID; free accounts expire after 7 days). Real distribution needs a paid
Apple Developer account (not wired into CI). iOS was not built locally (needs Xcode).

## Windows
```powershell
pwsh native\scripts\build_deps_windows.ps1
pwsh native\scripts\build_spcore_windows.ps1           # -> packages\spcore_flutter\windows\prebuilt\spcore.dll
cd app; flutter build windows --release
iscc /DAppVersion=1.0.0 app\windows\installer\softphonepro.iss   # -> app\build\windows\installer\SoftphonePro-Setup-1.0.0-x64.exe
```
The portable build is simply the zipped `app\build\windows\x64\runner\Release\` folder (CI: `SoftphonePro-<ver>-windows-x64-portable.zip`).
The installer registers `sip:`, `sips:`, `tel:`, `callto:` (optional task) and `softphonepro:` under HKCU\Software\Classes, can add a Start-with-Windows entry
(`--minimized`), and removes everything on uninstall. It is unsigned: SmartScreen shows "Windows protected your PC" -> **More info -> Run anyway**.

## Linux desktop app (.deb + tarball)
amd64 and arm64, built natively on each architecture (the app is never cross-compiled). The build baseline is **Ubuntu 22.04 / glibc 2.35**, so
the packages run on Ubuntu 22.04/24.04, Debian 12/13 and Raspberry Pi OS Bookworm (64-bit).
```bash
# Local build in Docker (any host with Docker; image = native/scripts/docker/Dockerfile.linux-app, ubuntu:22.04 + Flutter 3.32.1).
# The default arch is the host's; the other one runs under emulation (slow). Native deps and the pub cache live in the named
# volumes spc-linux-{build,cache}-<arch>, so rebuilds are incremental.
app/linux/packaging/build_linux.sh --docker [--arch arm64|amd64] [--out dist/linux]

# Native build on a Linux host (this is what CI runs): needs the Dockerfile's apt packages, CMake >= 3.28
# (`pip3 install 'cmake==3.31.*'` on 22.04) and Flutter 3.32.1 on PATH.
app/linux/packaging/build_linux.sh [--version 1.2.0-dev.7] [--build-number 7]
```
Output: `SoftphonePro-<version>-linux-<arch>.deb` and `.tar.gz` in `--out`. Steps: native dependencies with ALSA on (`build_deps_linux.sh`) ->
`libspcore.so` (release, no test hooks) -> `flutter build linux --release` -> `make_deb.sh` (Depends from `dpkg-shlibdeps`, desktop file, hicolor icons,
AppStream metainfo, man page, lintian overrides; a `-suffix` in the version becomes `~suffix` in the Debian version) and `make_tarball.sh`
(bundle plus `install-desktop-entry.sh` / `uninstall-desktop-entry.sh` for a user-local menu entry). Those two scripts can also be run alone on an existing
`build/linux/<x64|arm64>/release/bundle`.

Installing: `sudo apt install ./SoftphonePro-<ver>-linux-<arch>.deb` (installs to `/opt/softphonepro`, launcher `/usr/bin/softphonepro`); the tarball runs
from any folder (`./softphonepro`). Passwords and the automation token use the Secret Service (GNOME Keyring / KWallet) when one is usable and unlocked,
otherwise an encrypted file in the app's data folder. Network-change detection needs NetworkManager and is skipped quietly without it.

Tests of the packages (CI does both for each architecture, `ci.yml` job `linux`):
```bash
# install the .deb in clean containers: apt install, ldd (no "not found"), desktop-file-validate, appstreamcli, lintian (informational)
for img in debian:12 ubuntu:22.04 ubuntu:24.04 debian:13; do
  docker run --rm -v $PWD/dist/linux:/dist:ro -v $PWD/tests/smoke:/smoke:ro $img bash /smoke/linux_install_check.sh
done
# runtime smoke on a machine with the .deb installed + the test PBX (host mode, 127.0.0.1): register, call 602, DTMF, hang up, single instance
tests/sipserver/scripts/up.sh
xvfb-run -a dbus-run-session -- python3 tests/smoke/linux_smoke.py --out smoke-logs/linux --version 1.0.0    # --no-pbx without Docker
```
The smoke test needs `xvfb`, `dbus-x11` (for `dbus-run-session`), ImageMagick (`import` for screenshots) and Python 3.

## Linux (engine tests / CI)
```bash
native/scripts/build_deps_linux.sh [--no-docker]       # Docker by default; --no-docker on a Linux host
native/scripts/build_spcore.sh linux                   # -> native/build/linux/libspcore.so + spcore_cli (Docker on non-Linux hosts)
tests/sipserver/scripts/up.sh                          # test PBX
python3 native/tests/run_tests.py
cd packages/spcore_dart && SPCORE_LIB=$PWD/../../native/build/linux/libspcore.so PBX_HOST=127.0.0.1 dart test
```

## CI
`ci.yml` (push, PR, manual, reusable): `meta` (version), `native-linux` (engine + Dart tests against the Asterisk PBX), `flutter` (analyze/test),
`android`, `windows`, `macos`, `linux` (matrix amd64 on `ubuntu-22.04`, arm64 on `ubuntu-22.04-arm`: packages, install tests in clean containers, runtime smoke), `ios`. Native dependency prefixes are cached with a key of `hashFiles(native/scripts/**, native/config/**)`
(excluding the `build_spcore*` scripts). Artifacts: `android-apks` (3 split APKs + universal), `windows-artifacts` (installer EXE + portable ZIP),
`macos-dmg`, `ios-ipa`, `linux-packages-<arch>` (.deb + .tar.gz), `linux-smoke-<arch>`, `linux-test-logs`.

Optional repository secrets: `ANDROID_KEYSTORE_BASE64`, `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_ALIAS`, `ANDROID_KEY_PASSWORD`;
`APPLE_CERT_BASE64`, `APPLE_CERT_PASSWORD`, `APPLE_SIGN_IDENTITY`, `APPLE_ID`, `APPLE_TEAM_ID`, `APPLE_APP_PASSWORD`.

## Releasing
1. Set `version:` in `app/pubspec.yaml` (e.g. `1.2.0+1`) and commit.
2. `git tag v1.2.0 && git push origin v1.2.0` (tags with a `-` suffix such as `v1.3.0-beta.1` become pre-releases).
3. `release.yml` runs the full build via `ci.yml`, then publishes a GitHub Release with the EXE, portable ZIP, DMG, the Linux .deb / tarballs (amd64 + arm64), APKs and unsigned IPA plus generated notes.
   Use *Run workflow* with a tag to republish for an existing tag.
Version numbers: the tag (without `v`) names the files; Flutter's build name is the part before any `-`, build number = CI run number.
