#!/usr/bin/env bash
# Build PJSIP 2.17 + OpenSSL + Opus + bcg729 + Oboe static libs for Android.
#   build_deps_android.sh [arm64-v8a|armeabi-v7a|x86_64|all]... [--clean] [-j N]
# Output: native/out/android-<abi>/
# Env: ANDROID_HOME / ANDROID_SDK_ROOT (SDK location), SPC_NDK (explicit NDK dir; default
#      $ANDROID_HOME/ndk/27.0.12077973), SPC_ANDROID_API (default 24).
set -euo pipefail
. "$(dirname "${BASH_SOURCE[0]}")/common.sh"

NDK_VERSION="${SPC_NDK_VERSION:-27.0.12077973}"
SDK="${ANDROID_HOME:-${ANDROID_SDK_ROOT:-$HOME/Library/Android/sdk}}"
NDK="${SPC_NDK:-$SDK/ndk/$NDK_VERSION}"
API="${SPC_ANDROID_API:-24}"
[ -f "$NDK/build/cmake/android.toolchain.cmake" ] || die "Android NDK not found at $NDK (set ANDROID_HOME or SPC_NDK)"

ABIS=(); ARGS=()
for a in "$@"; do
  case "$a" in arm64-v8a|armeabi-v7a|x86_64) ABIS+=("$a") ;; all) ABIS=(arm64-v8a armeabi-v7a x86_64) ;; *) ARGS+=("$a") ;; esac
done
[ "${#ABIS[@]}" -gt 0 ] || ABIS=(arm64-v8a armeabi-v7a x86_64)

HOST_TAG=""
for t in darwin-x86_64 linux-x86_64 windows-x86_64; do [ -d "$NDK/toolchains/llvm/prebuilt/$t" ] && HOST_TAG="$t" && break; done
[ -n "$HOST_TAG" ] || die "no prebuilt toolchain in $NDK"
TOOLBIN="$NDK/toolchains/llvm/prebuilt/$HOST_TAG/bin"

build_one() {
  local abi="$1"; shift
  spc_init "android-$abi" "$@"
  local ossl
  case "$abi" in
    arm64-v8a)   ossl=android-arm64 ;;
    armeabi-v7a) ossl=android-arm ;;
    x86_64)      ossl=android-x86_64 ;;
  esac
  # OpenSSL's android-* targets find the compiler through ANDROID_NDK_ROOT + PATH.
  export ANDROID_NDK_ROOT="$NDK" ANDROID_NDK_HOME="$NDK"
  export PATH="$TOOLBIN:$PATH"
  SPC_OPENSSL_TARGET="$ossl"
  SPC_OPENSSL_ARGS=("-D__ANDROID_API__=$API" -fPIC)
  SPC_CMAKE_PLATFORM_ARGS=(
    -DCMAKE_TOOLCHAIN_FILE="$NDK/build/cmake/android.toolchain.cmake"
    -DANDROID_ABI="$abi"
    -DANDROID_PLATFORM="android-$API"
    -DANDROID_STL=c++_static
    -DANDROID_SUPPORT_FLEXIBLE_PAGE_SIZES=ON        # 16 KB page size (NDK r27+)
    "-DCMAKE_SHARED_LINKER_FLAGS=-Wl,-z,max-page-size=16384"
    "-DCMAKE_EXE_LINKER_FLAGS=-Wl,-z,max-page-size=16384"
    -DCMAKE_FIND_ROOT_PATH="$SPC_OUT"
  )
  # Audio backend (SPC_ANDROID_AUDIO=opensl|oboe, default opensl). pjmedia's own JNI backend is always off.
  #  opensl: JNI-free OpenSL ES (VOICE_COMMUNICATION capture preset). Verified to initialise in a plain
  #          native process / dart:ffi. Needs a small patch of the extracted pjmedia/CMakeLists.txt.
  #  oboe  : pjproject's Oboe backend ALSO needs a JavaVM + the Java class org.pjsip.PjAudioDevInfo
  #          (pjmedia/src/pjmedia-audiodev/android/PjAudioDevInfo.java) at pjmedia_endpt_create() time;
  #          without them process start-up crashes in JNIEnv::FindClass.
  # AEC: pjproject's bundled WebRTC AEC (mobile flavour, AECM) + AEC3.
  SPC_ANDROID_AUDIO="${SPC_ANDROID_AUDIO:-opensl}"
  local libs_extra='-lOpenSLES -llog'
  if [ "$SPC_ANDROID_AUDIO" = oboe ]; then SPC_WITH_OBOE=1; libs_extra="\"$SPC_OUT/lib/liboboe.a\" $libs_extra"; else SPC_WITH_OBOE=0; fi
  SPC_WEBRTC_DEFS=(-DWEBRTC_ANDROID=1)
  case "$abi" in
    arm64-v8a)   SPC_WEBRTC_DEFS+=(-DWEBRTC_ARCH_ARM64=1 -DWEBRTC_HAS_NEON=1) ;;
    armeabi-v7a) SPC_WEBRTC_DEFS+=(-DWEBRTC_HAS_NEON=1 -mfpu=neon) ;;
  esac
  # pjproject's CMake also builds its pjsua/aidemo executables, whose link line lacks Oboe/log/OpenSLES
  # (the Oboe backend is not wired into its CMake); append them via CMAKE_CXX_STANDARD_LIBRARIES.
  SPC_PJ_CMAKE_ARGS=(-DPJLIB_WITH_IOQUEUE=epoll -DPJMEDIA_WITH_AUDIODEV_JNI=OFF
    "-DCMAKE_CXX_STANDARD_LIBRARIES=$libs_extra")
  SPC_SYSTEM_LIBS="OpenSLES android log m dl c++_static c++abi"
  SPC_LINK_GROUP=1
  SPC_LINK_OPTIONS='"-Wl,-z,max-page-size=16384"'
  spc_build_all
}

for abi in "${ABIS[@]}"; do
  build_one "$abi" ${ARGS[@]+"${ARGS[@]}"}
done
