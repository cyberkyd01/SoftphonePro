# Native dependency build scripts

Reproducible builds of the static libraries `spcore` links against, one install prefix per target:

| Component | Version | Source (SHA-256 pinned in `fetch_deps.sh`) |
|---|---|---|
| pjproject | 2.17 | github.com/pjsip/pjproject tag 2.17 |
| OpenSSL | 3.5.9 (3.5 = current 3.x LTS, supported to 2030) | github.com/openssl/openssl release tarball |
| Opus | 1.6.1 | downloads.xiph.org |
| bcg729 | 1.1.2 (latest tag) | github.com/BelledonneCommunications/bcg729 |
| Oboe (Android only) | 1.11.0 | github.com/google/oboe |

## Outputs

```
native/out/<target>/
  include/            pjproject, openssl/, opus/, bcg729/ (and oboe/ on Android) headers, pj/config_site.h
  bin/*.a             pjproject static libs (pjproject's CMake installs ARCHIVEs under bin/ - upstream quirk),
  bin/pjproject/third_party/*.a   srtp resample speex gsm ilbc g7221 [webrtc webrtc_aec3]
  lib/                libopus.a libbcg729.a libssl.a libcrypto.a [liboboe.a libspeexdsp.a(empty shim)]
  lib/cmake/Pj/       pjproject's own CMake package (PjConfig.cmake) - works, but see below
  spc_deps.cmake      <- the entry point
```
Targets: `macos-arm64 macos-x86_64 linux-<arm64|x86_64> android-{arm64-v8a,armeabi-v7a,x86_64}
ios-arm64 ios-sim-arm64 ios-sim-x86_64 windows-x64`. `native/out`, `native/build`, `native/deps` are gitignored.

### Consuming
```cmake
include(${SPC_DEPS_PREFIX}/spc_deps.cmake)        # prefix = native/out/<target>
target_link_libraries(spcore PRIVATE spc::deps)
```
`spc::deps` is an imported INTERFACE target: include dir, the static libs in link order (wrapped in a
rescan group on ELF), compile definitions, and the system libs/frameworks for that platform
(Apple: CoreAudio AudioToolbox AudioUnit CoreFoundation Foundation Security Network AVFoundation CoreServices;
Android: OpenSLES android log m dl c++_static c++abi + `-Wl,-z,max-page-size=16384`;
Linux: pthread m dl stdc++ [asound] [uuid]; Windows: ws2_32 winmm iphlpapi ole32 crypt32 secur32 avrt ksuser uuid ...).
The paths in it are relative to the file, so the prefix may be moved. spcore must be compiled with
`native/config/config_site.h` force-included (`-include`, `/FI`), exactly as in `smoke/CMakeLists.txt`.

## Usage

All scripts: idempotent (per-component stamps; rebuilt only when version/config_site.h/args change),
`set -euo pipefail`, `--clean` (wipe this target's prefix and build dir), `-j N` (default: all cores), print a summary.

```
native/scripts/fetch_deps.sh                       # download + verify (also called automatically)
native/scripts/build_deps_macos.sh [arm64|x86_64|all]
native/scripts/build_deps_linux.sh [--smoke]       # Docker (ubuntu:24.04) - or --no-docker on a Linux host
native/scripts/build_deps_android.sh [arm64-v8a|armeabi-v7a|x86_64|all]   # NDK 27.0.12077973, API 24
native/scripts/build_deps_ios.sh [ios-arm64|ios-sim-arm64|ios-sim-x86_64|all]   # needs full Xcode
pwsh native/scripts/build_deps_windows.ps1 [-Clean] [-OpenSSL source|vcpkg]
native/scripts/smoke/run_smoke.sh <target>         # link + run the smoke test against a prefix
```
`config_site.h` is copied from `native/config/config_site.h` into pjlib before every pjproject build and never edited.
Needed tools: cmake >= 3.28, ninja, perl (OpenSSL), a C/C++ compiler; Docker for Linux; NDK for Android.

### CI commands
```
macos-14/15 :  native/scripts/build_deps_macos.sh all
               sudo xcode-select -s /Applications/Xcode.app && native/scripts/build_deps_ios.sh all
ubuntu      :  native/scripts/build_deps_linux.sh --smoke        (or --no-docker)
android     :  ANDROID_HOME=... native/scripts/build_deps_android.sh all
windows-2022:  pwsh -File native\scripts\build_deps_windows.ps1
```

## Smoke test
`smoke/smoke.c` does `pjsua_create/init` (null sound device) `/start`, prints `pjsua_enum_codecs`, probes
which echo cancellers were compiled in, and `pjsua_destroy`. Set `SMOKE_EXPECT=opus,G722,...` to assert codecs.

## Per-platform notes

* **pjproject CMake build is used on macOS, Linux, Android and iOS.** Upstream gaps worked around by the scripts
  (no source patching):
  1. `PJMEDIA_HAS_WEBRTC_AEC/AEC3`: the CMake build defines `PJMEDIA_HAS_LIBWEBRTC[_AEC3]` but the sources test
     `PJMEDIA_HAS_WEBRTC_AEC[3]` -> WebRTC AEC would silently be compiled out. The scripts pass the right macros
     (plus the `WEBRTC_*` OS/arch defines the CMake only gives to the aec3 library itself) via CFLAGS/CXXFLAGS,
     and `spc::deps` defines `PJMEDIA_HAS_WEBRTC_AEC=1`/`AEC3=1` for consumers. Verified at runtime by the smoke test.
  2. `PJMEDIA_WITH_AUDIODEV_NULL` can never be enabled (typo upstream) - irrelevant: `pjsua_set_null_snd_dev()` works.
  3. Android audio: pjproject's Oboe backend needs a JavaVM *and* the Java class `org.pjsip.PjAudioDevInfo` during
     `pjmedia_endpt_create()` (process crashes in `JNIEnv::FindClass` otherwise - observed on the emulator), and its CMake
     has no OpenSL ES backend. Default is therefore **OpenSL ES** (`SPC_ANDROID_AUDIO=opensl`): the scripts add
     `opensl_dev.c` to the extracted build tree's `pjmedia/CMakeLists.txt`, flip `PJMEDIA_AUDIO_DEV_HAS_OPENSL` to 1 and add the
     missing prototype (patches are applied to the throw-away extracted copy and verified). `SPC_ANDROID_AUDIO=oboe`
     builds Oboe 1.11 (`-DPJMEDIA_AUDIO_DEV_HAS_OBOE=1`) for apps that ship the Java class and set the JVM.
  4. `FindCoreAudio` requires AppKit (absent on iOS): pre-seeded with UIKit.
  5. pkg-config / Homebrew prefixes are hidden from CMake so a host's opus/openssl can never leak in.
  6. The default echo-canceller order is Speex > WebRTC AEC > AEC3 (`PJMEDIA_ECHO_DEFAULT`); **select AEC3 explicitly**
     (`ec_options = PJMEDIA_ECHO_WEBRTC_AEC3`) on Linux/Android/Windows.
* **macOS**: `MACOSX_DEPLOYMENT_TARGET=11.0`, CoreAudio, kqueue. pjproject's CMake offers no WebRTC AEC on Apple,
  so: CoreAudio VoiceProcessingIO (platform AEC, via `PJMEDIA_AUD_DEV_CAP_EC`) + Speex AEC, enabled through an
  empty `libspeexdsp.a` + placeholder header shim (the AEC code is in the bundled libspeex). Works with Command Line Tools only.
* **iOS**: min iOS 13.0, static PIC libs for linking into the dynamic `spcore.framework`; CoreAudio/VPIO + Speex AEC; OpenSSL
  for TLS. Requires Xcode SDKs - **not buildable/tested on a CLT-only machine; written for GitHub Actions macos-14/15.**
* **Linux**: image `docker/Dockerfile.linux-build`; builds as the host uid, repo mounted at `/work`. Output arch = Docker VM arch
  (arm64 on Apple Silicon). ALSA (`SPC_LINUX_ALSA=1`) and libuuid (`SPC_LINUX_UUID=1`) are opt-in; default needs only pthread/m/dl.
  WebRTC AEC + AEC3 enabled.
* **Android**: NDK 27.0.12077973 (`SPC_NDK` / `ANDROID_HOME` to override), `android-24`, `c++_static`,
  16 KB pages (`ANDROID_SUPPORT_FLEXIBLE_PAGE_SIZES`, `-Wl,-z,max-page-size=16384`; also in `spc::deps` link options
  - the final `libspcore.so` link must carry them). Audio: **OpenSL ES** (JNI-free, VOICE_COMMUNICATION capture preset); Oboe opt-in, see above.
  WebRTC AEC (mobile AECM) + AEC3 enabled; select AEC3 explicitly.
* **Windows**: pjproject's CMake is *not* used on MSVC. `pjproject-vs14.sln` projects, `Release-Static|x64` (/MT, v143), OpenSSL built from
  source (perl+nasm+nmake, makefile patched /MD->/MT; `-OpenSSL vcpkg` = `openssl:x64-windows-static`), Opus/bcg729 via CMake with
  `MultiThreaded` runtime. A trailer is appended to the *build-tree copy* of config_site.h (Opus, bcg729, AEC3 macros, WMME on, WASAPI off).
  spcore must use `CMAKE_MSVC_RUNTIME_LIBRARY=MultiThreaded`. **Untested here** (no Windows host); first CI run may need small fixes.
