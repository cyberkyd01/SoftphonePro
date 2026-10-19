#!/usr/bin/env bash
# Build PJSIP 2.17 + OpenSSL + Opus + bcg729 static libs for Linux (host architecture).
#   build_deps_linux.sh [--clean] [-j N] [--no-docker] [--smoke]
# Default: builds the Docker image native/scripts/docker/Dockerfile.linux-build (ubuntu:24.04)
# and runs this same script inside it with the repo mounted at /work.
# Output: native/out/linux-x86_64/ or native/out/linux-arm64/ (matches the Docker/host arch).
#   --no-docker  build directly on the current (Linux) machine
#   --smoke      after building, also run native/scripts/smoke inside the container
# Env: SPC_LINUX_ALSA=1 enables the ALSA audio backend (needs libasound2-dev; default: off,
#      null/no-device is enough for CI tests); SPC_LINUX_UUID=1 links libuuid (default: pjlib's own GUID).
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO="$(cd "$HERE/../.." && pwd)"
IMAGE="${SPC_LINUX_IMAGE:-spc-linux-build:ubuntu24.04}"

USE_DOCKER=1; SMOKE=0; PASS=()
for a in "$@"; do
  case "$a" in
    --no-docker) USE_DOCKER=0 ;;
    --in-container) USE_DOCKER=0 ;;
    --smoke) SMOKE=1 ;;
    *) PASS+=("$a") ;;
  esac
done

if [ "$USE_DOCKER" = 1 ]; then
  command -v docker >/dev/null || { echo "docker not found (use --no-docker on a Linux host)" >&2; exit 1; }
  docker build -t "$IMAGE" -f "$HERE/docker/Dockerfile.linux-build" "$HERE/docker"
  ENVS=(-e SPC_LINUX_ALSA="${SPC_LINUX_ALSA:-0}" -e SPC_LINUX_UUID="${SPC_LINUX_UUID:-0}")
  [ -n "${SPC_JOBS:-}" ] && ENVS+=(-e SPC_JOBS="$SPC_JOBS")
  # Linux build artefacts (native/build, native/out, native/deps) live on the mounted repo.
  exec docker run --rm --user "$(id -u):$(id -g)" "${ENVS[@]}" \
    -v "$REPO":/work -w /work "$IMAGE" \
    bash native/scripts/build_deps_linux.sh --in-container $([ "$SMOKE" = 1 ] && echo --smoke) ${PASS[@]+"${PASS[@]}"}
fi

[ "$(uname -s)" = Linux ] || { echo "build_deps_linux.sh must run on Linux (use Docker mode)" >&2; exit 1; }
. "$HERE/common.sh"

case "$(uname -m)" in
  x86_64)        ARCH=x86_64; OSSL=linux-x86_64 ;;
  aarch64|arm64) ARCH=arm64;  OSSL=linux-aarch64 ;;
  *) die "unsupported host arch $(uname -m)" ;;
esac
spc_init "linux-$ARCH" ${PASS[@]+"${PASS[@]}"}

SPC_CMAKE_PLATFORM_ARGS=()
SPC_WEBRTC_DEFS=(-DWEBRTC_LINUX=1)
[ "$ARCH" = arm64 ] && SPC_WEBRTC_DEFS+=(-DWEBRTC_ARCH_ARM64=1 -DWEBRTC_HAS_NEON=1)
SPC_OPENSSL_TARGET="$OSSL"
SPC_OPENSSL_ARGS=(-fPIC)
SPC_PJ_CMAKE_ARGS=(-DPJLIB_WITH_IOQUEUE=epoll)
SYS="pthread m dl stdc++"
if [ "${SPC_LINUX_ALSA:-0}" = 1 ]; then
  SYS="$SYS asound"
else
  SPC_PJ_CMAKE_ARGS+=(-DPJMEDIA_WITH_AUDIODEV_ALSA=OFF)
fi
if [ "${SPC_LINUX_UUID:-0}" = 1 ]; then SYS="$SYS uuid"; else SPC_PJ_CMAKE_ARGS+=(-DPJLIB_WITH_LIBUUID=OFF); fi
# Bundled WebRTC AEC + AEC3 are enabled by pjproject's CMake on non-Apple platforms.
SPC_SYSTEM_LIBS="$SYS"
SPC_LINK_GROUP=1
spc_build_all

if [ "$SMOKE" = 1 ]; then
  "$HERE/smoke/run_smoke.sh" "linux-$ARCH"
fi
