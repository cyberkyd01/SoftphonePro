#!/usr/bin/env bash
# Build PJSIP 2.17 + OpenSSL + Opus + bcg729 static libs for macOS.
#   build_deps_macos.sh [arm64|x86_64|all] [--clean] [-j N]
# Output: native/out/macos-<arch>/   (works with Command Line Tools only)
set -euo pipefail
. "$(dirname "${BASH_SOURCE[0]}")/common.sh"

ARCHES=()
ARGS=()
for a in "$@"; do
  case "$a" in arm64|x86_64) ARCHES+=("$a") ;; all) ARCHES=(arm64 x86_64) ;; *) ARGS+=("$a") ;; esac
done
[ "${#ARCHES[@]}" -gt 0 ] || ARCHES=(arm64 x86_64)

build_one() {
  local arch="$1"; shift
  export MACOSX_DEPLOYMENT_TARGET="${MACOSX_DEPLOYMENT_TARGET:-11.0}"
  spc_init "macos-$arch" "$@"
  SPC_CMAKE_PLATFORM_ARGS=(
    -DCMAKE_OSX_ARCHITECTURES="$arch"
    -DCMAKE_OSX_DEPLOYMENT_TARGET="$MACOSX_DEPLOYMENT_TARGET"
    -DCMAKE_SYSTEM_PROCESSOR="$arch"
  )
  SPC_OPENSSL_TARGET="darwin64-$([ "$arch" = arm64 ] && echo arm64 || echo x86_64)-cc"
  SPC_OPENSSL_ARGS=("-mmacosx-version-min=$MACOSX_DEPLOYMENT_TARGET")
  # TLS via OpenSSL (DTLS-SRTP); CoreAudio via pjmedia-audiodev. Bundled WebRTC AEC/AEC3
  # are not offered by pjproject's CMake on Apple platforms -> Speex AEC only (see README).
  SPC_PJ_CMAKE_ARGS=(-DPJLIB_WITH_IOQUEUE=kqueue)
  SPC_SYSTEM_LIBS='"-framework CoreAudio" "-framework AudioToolbox" "-framework AudioUnit" "-framework CoreFoundation" "-framework Foundation" "-framework Security" "-framework Network" "-framework AVFoundation" "-framework CoreServices" "-framework AppKit" c++ objc'
  SPC_LINK_GROUP=0
  SPC_WEBRTC_AEC=0
  SPC_SPEEX_AEC_SHIM=1   # CMake offers no WebRTC AEC on Apple; use bundled Speex AEC (+ CoreAudio VPIO at runtime)
  spc_build_all
}

for arch in "${ARCHES[@]}"; do
  build_one "$arch" ${ARGS[@]+"${ARGS[@]}"}
done
