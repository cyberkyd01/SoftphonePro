#!/usr/bin/env bash
# Build PJSIP 2.17 + OpenSSL + Opus + bcg729 static libs for iOS (min iOS 13.0).
#   build_deps_ios.sh [ios-arm64|ios-sim-arm64|ios-sim-x86_64|all]... [--clean] [-j N]
# Output: native/out/<target>/   (static, PIC; to be linked into the dynamic spcore.framework)
#
# Needs a full Xcode (iPhoneOS / iPhoneSimulator SDKs). It CANNOT run on a machine with only the
# Command Line Tools; it is meant for GitHub Actions macos-14 / macos-15 runners:
#   sudo xcode-select -s /Applications/Xcode.app && native/scripts/build_deps_ios.sh all
#
# Notes
#  * CMake `CMAKE_SYSTEM_NAME=iOS`, Ninja generator, compiler/SDK picked through xcrun.
#  * Audio: CoreAudio backend (VoiceProcessingIO = platform AEC). Bundled WebRTC AEC is not offered
#    by pjproject's CMake on Apple; Speex AEC is enabled through the SpeexDSP shim.
#  * TLS: OpenSSL (DTLS-SRTP). pjproject's FindCoreAudio insists on AppKit, which does not exist on
#    iOS -> COREAUDIO_LIBRARY_APPKIT is pre-seeded with UIKit.
#  * No bitcode (removed in Xcode 14), -fPIC everywhere.
set -euo pipefail
. "$(dirname "${BASH_SOURCE[0]}")/common.sh"

MIN_IOS="${SPC_IOS_MIN:-13.0}"
TARGETS=(); ARGS=()
for a in "$@"; do
  case "$a" in ios-arm64|ios-sim-arm64|ios-sim-x86_64) TARGETS+=("$a") ;; all) TARGETS=(ios-arm64 ios-sim-arm64 ios-sim-x86_64) ;; *) ARGS+=("$a") ;; esac
done
[ "${#TARGETS[@]}" -gt 0 ] || TARGETS=(ios-arm64 ios-sim-arm64 ios-sim-x86_64)

[ "$(uname -s)" = Darwin ] || die "iOS builds need macOS"
xcrun --sdk iphoneos --show-sdk-path >/dev/null 2>&1 || die "iPhoneOS SDK not found: full Xcode is required (xcode-select -s /Applications/Xcode.app)"
xcrun --sdk iphonesimulator --show-sdk-path >/dev/null 2>&1 || die "iPhoneSimulator SDK not found"

build_one() {
  local target="$1"; shift
  local sdk arch ossl minflag
  case "$target" in
    ios-arm64)       sdk=iphoneos;        arch=arm64;  ossl=ios64-xcrun;        minflag="-miphoneos-version-min=$MIN_IOS" ;;
    ios-sim-arm64)   sdk=iphonesimulator; arch=arm64;  ossl=iossimulator-arm64-xcrun; minflag="-mios-simulator-version-min=$MIN_IOS" ;;
    ios-sim-x86_64)  sdk=iphonesimulator; arch=x86_64; ossl=iossimulator-x86_64-xcrun; minflag="-mios-simulator-version-min=$MIN_IOS" ;;
  esac
  local sdkpath; sdkpath="$(xcrun --sdk "$sdk" --show-sdk-path)"
  spc_init "$target" "$@"
  SPC_OPENSSL_TARGET="$ossl"
  # The *-xcrun Configure targets already add "-arch <arch>"; a separate
  # "-arch" "<arch>" pair would be parsed by Configure as a second target.
  SPC_OPENSSL_ARGS=("$minflag" -fPIC)
  SPC_CMAKE_PLATFORM_ARGS=(
    -DCMAKE_SYSTEM_NAME=iOS
    -DCMAKE_OSX_SYSROOT="$sdk"
    -DCMAKE_OSX_ARCHITECTURES="$arch"
    -DCMAKE_OSX_DEPLOYMENT_TARGET="$MIN_IOS"
    -DCMAKE_SYSTEM_PROCESSOR="$arch"
    -DCMAKE_TRY_COMPILE_TARGET_TYPE=STATIC_LIBRARY     # no signing / linking of probe executables
    -DCMAKE_MACOSX_BUNDLE=OFF
    -DCMAKE_XCODE_ATTRIBUTE_CODE_SIGNING_ALLOWED=NO
  )
  SPC_WEBRTC_AEC=0
  SPC_SPEEX_AEC_SHIM=1
  # Opus: leave OPUS_MAY_HAVE_NEON at its default (ON). On iOS opus presumes NEON (OPUS_PRESUME_NEON, arm64
  # only) and its CMake message "Runtime cpu capability detection needed for MAY_HAVE_NEON" is a plain
  # message(), not an error: MAY_HAVE_NEON must stay defined or celt_neon_intr.c fails to compile
  # (celt_inner_prod_neon undeclared). Result: NEON code is compiled in and used unconditionally.
  # CMAKE_SYSTEM_NAME=iOS restricts find_package/find_path/find_library to the SDK sysroot, so our
  # prefix (OpenSSL!) is invisible unless it is added to CMAKE_FIND_ROOT_PATH and the find modes are
  # relaxed. OpenSSL is also passed explicitly (hard-fails in common.sh if pjproject still does not use it).
  SPC_CMAKE_PLATFORM_ARGS+=(
    "-DCMAKE_FIND_ROOT_PATH=$SPC_OUT"
    -DCMAKE_FIND_ROOT_PATH_MODE_PACKAGE=BOTH
    -DCMAKE_FIND_ROOT_PATH_MODE_INCLUDE=BOTH
    -DCMAKE_FIND_ROOT_PATH_MODE_LIBRARY=BOTH
    -DCMAKE_FIND_ROOT_PATH_MODE_PROGRAM=NEVER
  )
  # select() ioqueue (pjproject's own default on iOS): ioqueue_common_abs.c calls replace_udp_sock()
  # for PJ_IPHONE_OS_HAS_MULTITASKING_SUPPORT, which only exists in ioqueue_select.c (kqueue fails to build).
  SPC_PJ_CMAKE_ARGS=(
    -DPJLIB_WITH_IOQUEUE=select
    # pjproject always builds its pjsua/sample executables; coreaudio_dev.m needs AVFoundation to link them.
    "-DCMAKE_EXE_LINKER_FLAGS=-framework AVFoundation -framework AudioToolbox -framework CoreAudio -framework CoreFoundation -framework Foundation -framework UIKit"
    "-DOPENSSL_INCLUDE_DIR=$SPC_OUT/include"
    "-DOPENSSL_SSL_LIBRARY=$SPC_OUT/lib/libssl.a"
    "-DOPENSSL_CRYPTO_LIBRARY=$SPC_OUT/lib/libcrypto.a"
    -DCOREAUDIO_LIBRARY_APPKIT="$sdkpath/System/Library/Frameworks/UIKit.framework"
  )
  SPC_SYSTEM_LIBS='"-framework CoreAudio" "-framework AudioToolbox" "-framework CoreFoundation" "-framework Foundation" "-framework Security" "-framework Network" "-framework AVFoundation" "-framework CFNetwork" "-framework UIKit" c++ objc'
  SPC_LINK_GROUP=0
  spc_build_all
}

for t in "${TARGETS[@]}"; do build_one "$t" ${ARGS[@]+"${ARGS[@]}"}; done
