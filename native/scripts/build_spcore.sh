#!/usr/bin/env bash
# Build the spcore engine (native/CMakeLists.txt) against the prebuilt dependency prefixes in
# native/out/<target> (see README.md) and copy the results into packages/spcore_flutter.
#
#   build_spcore.sh <macos|ios|android|linux|all> [--clean] [-j N]
#
#   macos   arm64 + x86_64 -> lipo -> universal spcore.framework -> spcore.xcframework
#           => packages/spcore_flutter/macos/Frameworks/spcore.xcframework
#   ios     device arm64 + simulator arm64/x86_64 (needs full Xcode)
#           => packages/spcore_flutter/ios/Frameworks/spcore.xcframework
#   android arm64-v8a armeabi-v7a x86_64 (NDK 27, android-24, c++_static, 16 KB pages, stripped)
#           => packages/spcore_flutter/android/src/main/jniLibs/<abi>/libspcore.so
#   linux   host arch => native/build/linux/libspcore.so (+ spcore_cli). On non-Linux hosts runs in
#           the Docker image used by build_deps_linux.sh.
#   all     every target the current host can build (linux only on Linux/Docker; ios only with Xcode)
#
# Prerequisite: the dependency prefixes: build_deps_<platform>.sh. (Windows: build_spcore_windows.ps1.)
# Env: SPC_NDK / ANDROID_HOME, SPC_ANDROID_API (24), SPC_IOS_MIN (13.0), MACOSX_DEPLOYMENT_TARGET (11.0),
#      SPC_VERSION (framework version string, default 1.0.0), SPC_BUILD_TYPE (Release).
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NATIVE="$(cd "$HERE/.." && pwd)"
REPO="$(cd "$NATIVE/.." && pwd)"
PLUGIN="$REPO/packages/spcore_flutter"
PKG="$HERE/package"

log()  { printf '\033[1;34m[spcore]\033[0m %s\n' "$*"; }
die()  { printf '\033[1;31m[spcore] ERROR:\033[0m %s\n' "$*" >&2; exit 1; }

: "${SPC_VERSION:=1.0.0}"
: "${SPC_BUILD_TYPE:=Release}"
: "${SPC_JOBS:=$( (sysctl -n hw.ncpu 2>/dev/null || nproc 2>/dev/null || echo 4) | head -1)}"
MACOS_MIN="${MACOSX_DEPLOYMENT_TARGET:-11.0}"
IOS_MIN="${SPC_IOS_MIN:-13.0}"
ANDROID_API="${SPC_ANDROID_API:-24}"

TARGETS=(); CLEAN=0; PASS=()
while [ $# -gt 0 ]; do
  case "$1" in
    macos|ios|android|linux) TARGETS+=("$1") ;;
    all) TARGETS+=(all) ;;
    --clean) CLEAN=1 ;;
    -j|--jobs) shift; SPC_JOBS="$1" ;;
    -h|--help) sed -n '2,22p' "$0"; exit 0 ;;
    *) die "unknown argument '$1' (see --help)" ;;
  esac
  shift
done
[ "${#TARGETS[@]}" -gt 0 ] || die "usage: build_spcore.sh <macos|ios|android|linux|all> [--clean] [-j N]"

SRC="${SPC_CMAKE_SOURCE:-$NATIVE}"   # override only for testing with a stub project
[ -f "$SRC/CMakeLists.txt" ] || die "native/CMakeLists.txt not found (spcore sources missing)"

need_prefix() { [ -f "$NATIVE/out/$1/spc_deps.cmake" ] || die "dependency prefix native/out/$1 missing - run native/scripts/build_deps_$2.sh first"; }

# cmake_build <build-dir> <extra cmake args...>   (configure + build target spcore [+ spcore_cli])
cmake_build() {
  local bld="$1"; shift
  [ "$CLEAN" = 1 ] && rm -rf "$bld"
  cmake -S "$SRC" -B "$bld" -G Ninja -DCMAKE_BUILD_TYPE="$SPC_BUILD_TYPE" "$@"
  cmake --build "$bld" --parallel "$SPC_JOBS" --target spcore
}

# find_one <dir> <find args...> : first match or die
find_one() {
  local dir="$1"; shift
  local r; r="$(find "$dir" "$@" 2>/dev/null | head -1)"
  [ -n "$r" ] || die "build output not found in $dir ($*)"
  printf '%s' "$r"
}

# Binary of an Apple build: framework executable if SPC_APPLE_FRAMEWORK produced one, else libspcore.dylib.
apple_binary() {
  local bld="$1" fw
  fw="$(find "$bld" -type d -name spcore.framework 2>/dev/null | head -1 || true)"
  if [ -n "$fw" ]; then
    # resolve the real file (macOS frameworks use symlinks)
    if [ -f "$fw/Versions/A/spcore" ]; then printf '%s' "$fw/Versions/A/spcore"; else printf '%s' "$fw/spcore"; fi
  else
    find_one "$bld" -name 'libspcore*.dylib' -type f
  fi
}

# ---------------------------------------------------------------------------------------------
build_macos() {
  local stage="$NATIVE/build/spcore-macos-stage"; local arch bins=()
  for arch in arm64 x86_64; do
    need_prefix "macos-$arch" macos
    local bld="$NATIVE/build/spcore-macos-$arch"
    log "macOS $arch"
    cmake_build "$bld" -DSPC_DEPS_PREFIX="$NATIVE/out/macos-$arch" -DSPC_APPLE_FRAMEWORK=ON \
      -DCMAKE_OSX_ARCHITECTURES="$arch" -DCMAKE_OSX_DEPLOYMENT_TARGET="$MACOS_MIN"
    bins+=("$(apple_binary "$bld")")
  done
  rm -rf "$stage"; mkdir -p "$stage"
  lipo -create "${bins[@]}" -output "$stage/spcore"
  lipo -info "$stage/spcore"
  "$PKG/make_apple_framework.sh" macos "$stage/spcore" "$stage" "$SPC_VERSION"
  "$PKG/verify_symbols.sh" "$stage/spcore.framework/Versions/A/spcore"
  local dest="$PLUGIN/macos/Frameworks"; mkdir -p "$dest"
  make_xcfw "$dest/spcore.xcframework" "macos-arm64_x86_64:$stage/spcore.framework:arm64,x86_64:macos"
  # Also keep the plain universal framework (used by the unit/packaging checks).
  rm -rf "$NATIVE/build/macos"; mkdir -p "$NATIVE/build/macos"; cp -R "$stage/spcore.framework" "$NATIVE/build/macos/"
  log "macOS done: $dest/spcore.xcframework"
}

make_xcfw() { # <out> <slice specs...>
  local out="$1"; shift
  python3 "$PKG/make_xcframework.py" "$out" "$@"
}

# ---------------------------------------------------------------------------------------------
build_ios() {
  [ "$(uname -s)" = Darwin ] || die "iOS builds need macOS"
  xcrun --sdk iphoneos --show-sdk-path >/dev/null 2>&1 || die "iPhoneOS SDK not found: full Xcode required"
  local stage="$NATIVE/build/spcore-ios-stage"; rm -rf "$stage"; mkdir -p "$stage/device" "$stage/sim"
  local t sdk arch bins=()
  for t in ios-arm64 ios-sim-arm64 ios-sim-x86_64; do
    need_prefix "$t" ios
    case "$t" in
      ios-arm64)      sdk=iphoneos;        arch=arm64 ;;
      ios-sim-arm64)  sdk=iphonesimulator; arch=arm64 ;;
      ios-sim-x86_64) sdk=iphonesimulator; arch=x86_64 ;;
    esac
    local bld="$NATIVE/build/spcore-$t"
    log "iOS $t"
    cmake_build "$bld" -DSPC_DEPS_PREFIX="$NATIVE/out/$t" -DSPC_APPLE_FRAMEWORK=ON \
      -DCMAKE_SYSTEM_NAME=iOS -DCMAKE_OSX_SYSROOT="$sdk" -DCMAKE_OSX_ARCHITECTURES="$arch" \
      -DCMAKE_OSX_DEPLOYMENT_TARGET="$IOS_MIN" -DCMAKE_SYSTEM_PROCESSOR="$arch" \
      -DCMAKE_XCODE_ATTRIBUTE_CODE_SIGNING_ALLOWED=NO
    if [ "$t" = ios-arm64 ]; then cp "$(apple_binary "$bld")" "$stage/device/spcore"
    else cp "$(apple_binary "$bld")" "$stage/sim/spcore-$arch"; fi
  done
  lipo -create "$stage"/sim/spcore-* -output "$stage/sim/spcore"
  "$PKG/make_apple_framework.sh" ios "$stage/device/spcore" "$stage/device" "$SPC_VERSION"
  "$PKG/make_apple_framework.sh" ios "$stage/sim/spcore" "$stage/sim" "$SPC_VERSION"
  "$PKG/verify_symbols.sh" "$stage/device/spcore.framework/spcore"
  local dest="$PLUGIN/ios/Frameworks"; mkdir -p "$dest"
  make_xcfw "$dest/spcore.xcframework" \
    "ios-arm64:$stage/device/spcore.framework:arm64:ios" \
    "ios-arm64_x86_64-simulator:$stage/sim/spcore.framework:arm64,x86_64:ios:simulator"
  log "iOS done: $dest/spcore.xcframework"
}

# ---------------------------------------------------------------------------------------------
build_android() {
  local sdk="${ANDROID_HOME:-${ANDROID_SDK_ROOT:-$HOME/Library/Android/sdk}}"
  local ndk="${SPC_NDK:-$sdk/ndk/${SPC_NDK_VERSION:-27.0.12077973}}"
  [ -f "$ndk/build/cmake/android.toolchain.cmake" ] || die "Android NDK not found at $ndk (set ANDROID_HOME or SPC_NDK)"
  local host tool
  for host in darwin-x86_64 linux-x86_64 windows-x86_64; do [ -d "$ndk/toolchains/llvm/prebuilt/$host" ] && break; done
  tool="$ndk/toolchains/llvm/prebuilt/$host/bin"
  local abi
  for abi in arm64-v8a armeabi-v7a x86_64; do
    need_prefix "android-$abi" android
    local bld="$NATIVE/build/spcore-android-$abi"
    log "Android $abi"
    cmake_build "$bld" -DSPC_DEPS_PREFIX="$NATIVE/out/android-$abi" \
      -DCMAKE_TOOLCHAIN_FILE="$ndk/build/cmake/android.toolchain.cmake" \
      -DANDROID_ABI="$abi" -DANDROID_PLATFORM="android-$ANDROID_API" -DANDROID_STL=c++_static \
      -DANDROID_SUPPORT_FLEXIBLE_PAGE_SIZES=ON \
      "-DCMAKE_SHARED_LINKER_FLAGS=-Wl,-z,max-page-size=16384"
    local so; so="$(find_one "$bld" -name libspcore.so -type f)"
    local dest="$PLUGIN/android/src/main/jniLibs/$abi"; mkdir -p "$dest"
    cp "$so" "$dest/libspcore.so"
    "$tool/llvm-strip" --strip-unneeded "$dest/libspcore.so"
    "$PKG/verify_symbols.sh" "$dest/libspcore.so" "$tool/llvm-nm"
    # 16 KB page-size check: every PT_LOAD segment must have p_align >= 0x4000
    local al
    for al in $("$tool/llvm-readelf" -lW "$dest/libspcore.so" | awk '$1=="LOAD"{print $NF}'); do
      [ $((al)) -ge 16384 ] || die "$abi libspcore.so has LOAD alignment $al (< 16 KB)"
    done
  done
  log "Android done: $PLUGIN/android/src/main/jniLibs"
}

# ---------------------------------------------------------------------------------------------
build_linux() {
  if [ "$(uname -s)" != Linux ]; then
    command -v docker >/dev/null || die "linux target on non-Linux hosts needs Docker"
    local image="${SPC_LINUX_IMAGE:-spc-linux-build:ubuntu24.04}"
    docker image inspect "$image" >/dev/null 2>&1 || docker build -t "$image" -f "$HERE/docker/Dockerfile.linux-build" "$HERE/docker"
    exec docker run --rm --user "$(id -u):$(id -g)" -e SPC_JOBS="$SPC_JOBS" -v "$REPO":/work -w /work "$image" \
      bash native/scripts/build_spcore.sh linux -j "$SPC_JOBS" $([ "$CLEAN" = 1 ] && echo --clean)
  fi
  local arch; case "$(uname -m)" in x86_64) arch=x86_64 ;; aarch64|arm64) arch=arm64 ;; *) die "unsupported arch" ;; esac
  need_prefix "linux-$arch" linux
  local bld="$NATIVE/build/linux"
  log "Linux $arch"
  [ "$CLEAN" = 1 ] && rm -rf "$bld"
  cmake -S "$SRC" -B "$bld" -G Ninja -DCMAKE_BUILD_TYPE="$SPC_BUILD_TYPE" \
    -DSPC_DEPS_PREFIX="$NATIVE/out/linux-$arch"
  cmake --build "$bld" --parallel "$SPC_JOBS"
  local so; so="$(find_one "$bld" -name libspcore.so -type f)"
  [ "$so" = "$bld/libspcore.so" ] || cp "$so" "$bld/libspcore.so"
  local cli; cli="$(find "$bld" -name spcore_cli -type f 2>/dev/null | head -1 || true)"
  [ -z "$cli" ] || [ "$cli" = "$bld/spcore_cli" ] || cp "$cli" "$bld/spcore_cli"
  "$PKG/verify_symbols.sh" "$bld/libspcore.so"
  log "Linux done: $bld/libspcore.so ${cli:+(+ spcore_cli)}"
}

# ---------------------------------------------------------------------------------------------
run_target() {
  case "$1" in
    macos) build_macos ;; ios) build_ios ;; android) build_android ;; linux) build_linux ;;
  esac
}
for t in "${TARGETS[@]}"; do
  if [ "$t" = all ]; then
    if [ "$(uname -s)" = Darwin ]; then
      run_target macos
      if xcrun --sdk iphoneos --show-sdk-path >/dev/null 2>&1; then run_target ios; else log "skipping ios (no Xcode)"; fi
    fi
    run_target android
    if [ "$(uname -s)" = Linux ]; then run_target linux; fi
  else
    run_target "$t"
  fi
done
