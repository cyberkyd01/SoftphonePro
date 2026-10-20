#!/usr/bin/env bash
# Build the SoftphonePro Linux packages: SoftphonePro-<ver>-linux-<arch>.deb and .tar.gz.
#
#   build_linux.sh [--docker] [--arch arm64|amd64] [--out DIR] [--version V] [--build-number N] [-j N]
#
#   (default)   native build on this Linux machine (CI: ubuntu-22.04 / ubuntu-22.04-arm runners).
#               Needs the packages of native/scripts/docker/Dockerfile.linux-app, CMake >= 3.28,
#               Flutter 3.32.1 on PATH. --arch must match the host (the app is never cross-built).
#   --docker    build inside the ubuntu:22.04 image native/scripts/docker/Dockerfile.linux-app
#               (any host with Docker; uses whatever DOCKER_HOST/context is active). Sources are
#               copied into the container, so nothing in the checkout is rewritten. Native deps and
#               the pub cache live in named volumes per architecture (spc-linux-{build,cache}-<arch>).
#               --arch defaults to the host's; the other one runs under emulation (slow).
#   --out DIR   where the artifacts go (default: <repo>/dist/linux)
#   --version V package version, e.g. 1.2.0 or 1.2.0-dev.57 (default: app/pubspec.yaml). The part before the
#               first '-' is the Flutter build-name (what the app reports); the .deb Version uses '~' for '-'.
#   --build-number N  Flutter build number (default: from pubspec)
#
# Steps: native deps (PJSIP/OpenSSL/Opus/bcg729, ALSA on) -> libspcore.so (release, no test hooks)
#        -> flutter build linux --release -> .deb (make_deb.sh) + tarball (make_tarball.sh).
# ubuntu:22.04 (glibc 2.35) is the baseline so the result runs on Ubuntu 22.04/24.04, Debian 12/13
# and Raspberry Pi OS Bookworm (64-bit).
set -euo pipefail
. "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

DOCKER=0; ARCH=""; OUT="$REPO_DIR/dist/linux"; JOBS="${SPC_JOBS:-}"; PKG_VERSION=""; BUILD_NUMBER=""
while [ $# -gt 0 ]; do
  case "$1" in
    --docker) DOCKER=1 ;;
    --native) DOCKER=0 ;;
    --arch) ARCH="$2"; shift ;;
    --out) OUT="$2"; shift ;;
    --version) PKG_VERSION="$2"; shift ;;
    --build-number) BUILD_NUMBER="$2"; shift ;;
    -j|--jobs) JOBS="$2"; shift ;;
    -h|--help) sed -n '2,24p' "$0"; exit 0 ;;
    *) die "unknown argument '$1' (see --help)" ;;
  esac; shift
done
case "$ARCH" in ""|amd64|arm64) ;; x86_64) ARCH=amd64 ;; aarch64) ARCH=arm64 ;; *) die "--arch must be arm64 or amd64" ;; esac
mkdir -p "$OUT"; OUT="$(cd "$OUT" && pwd)"

# ------------------------------------------------------------------------------------ Docker mode
if [ "$DOCKER" = 1 ]; then
  command -v docker >/dev/null || die "docker not found"
  if [ -z "$ARCH" ]; then
    case "$(uname -m)" in x86_64) ARCH=amd64 ;; *) ARCH=arm64 ;; esac
  fi
  IMAGE="spc-linux-app:$ARCH"
  log "building image $IMAGE (linux/$ARCH)"
  docker build --platform "linux/$ARCH" -t "$IMAGE" -f "$REPO_DIR/native/scripts/docker/Dockerfile.linux-app" \
    "$REPO_DIR/native/scripts/docker"
  # Copy the sources into /build (a persistent per-arch volume, which also keeps the native deps,
  # native/build and app/build between runs). Caches and host-generated state are not copied.
  RSYNC_EXCLUDES=(--exclude .git --exclude .dart_tool --exclude build --exclude dist
    --exclude /native/out --exclude /native/deps --exclude /.pub-cache --exclude ephemeral
    --exclude .symlinks --exclude Pods --exclude .gradle --exclude node_modules
    --exclude /tests/sipserver/data --exclude pubspec_overrides.yaml)
  exec docker run --rm --platform "linux/$ARCH" \
    -v "$REPO_DIR":/src:ro -v "spc-linux-build-$ARCH":/build -v "spc-linux-cache-$ARCH":/cache -v "$OUT":/out \
    -e HOST_UID="$(id -u)" -e HOST_GID="$(id -g)" -e PUB_CACHE=/cache/pub ${JOBS:+-e SPC_JOBS="$JOBS"} \
    ${PKG_VERSION:+-e SPC_PKG_VERSION="$PKG_VERSION"} ${BUILD_NUMBER:+-e SPC_BUILD_NUMBER="$BUILD_NUMBER"} \
    -w /build "$IMAGE" bash -euc '
      mkdir -p /build/native/out /build/native/deps /cache/pub
      # seed the source tarballs of the native deps from the checkout (fetch_deps.sh verifies SHA-256)
      [ -d /src/native/deps ] && rsync -a --ignore-existing /src/native/deps/ /build/native/deps/ || true
      rsync -a --delete "$@" /src/ /build/
      /build/app/linux/packaging/build_linux.sh --native --arch '"$ARCH"' --out /out ${SPC_PKG_VERSION:+--version "$SPC_PKG_VERSION"} ${SPC_BUILD_NUMBER:+--build-number "$SPC_BUILD_NUMBER"}
      chown "$HOST_UID:$HOST_GID" /out/SoftphonePro-* 2>/dev/null || true
    ' bash "${RSYNC_EXCLUDES[@]}"
fi

# ------------------------------------------------------------------------------------ native mode
[ "$(uname -s)" = Linux ] || die "native mode needs Linux; use --docker on this machine"
HOST_ARCH="$(host_deb_arch)"
ARCH="${ARCH:-$HOST_ARCH}"
[ "$ARCH" = "$HOST_ARCH" ] || die "--arch $ARCH does not match this $HOST_ARCH host (use --docker, or a runner of that architecture)"
command -v flutter >/dev/null || die "flutter not found on PATH (Flutter 3.32.1)"
VERSION="${PKG_VERSION:-$(app_version)}"; [ -n "$VERSION" ] || die "cannot read the version from app/pubspec.yaml"
[ -n "$JOBS" ] && export SPC_JOBS="$JOBS"
log "SoftphonePro $VERSION linux-$ARCH -> $OUT"

# 1. Native dependencies, with the ALSA audio backend (PJSIP reaches PulseAudio/PipeWire through ALSA's
#    "default" device). The stamps include the ALSA setting, so a null-audio test build is rebuilt.
log "native dependencies (ALSA on)"
SPC_LINUX_ALSA=1 "$REPO_DIR/native/scripts/build_deps_linux.sh" --no-docker

# 2. The engine: release, never with the CI test hooks.
log "libspcore.so"
SPC_TEST_HOOKS=OFF "$REPO_DIR/native/scripts/build_spcore.sh" linux
SO="$REPO_DIR/native/build/linux/libspcore.so"
[ -f "$SO" ] || die "$SO missing"
readelf -d "$SO" | grep -q 'NEEDED.*libasound' || die "libspcore.so is not linked against ALSA (stale null-audio dependency build?)"

# 3. The app.
log "flutter build linux --release"
cd "$APP_DIR"
flutter pub get
SPCORE_PREBUILT_SO="$SO" flutter build linux --release --build-name "${VERSION%%-*}" ${BUILD_NUMBER:+--build-number "$BUILD_NUMBER"}
BUNDLE="$APP_DIR/build/linux/$(flutter_arch "$ARCH")/release/bundle"
[ -x "$BUNDLE/softphonepro" ] || die "bundle not found: $BUNDLE"
[ -f "$BUNDLE/lib/libspcore.so" ] || die "libspcore.so was not bundled"

# 4. Packages.
"$PKG_DIR/make_deb.sh" --bundle "$BUNDLE" --arch "$ARCH" --version "$VERSION" --out "$OUT"
"$PKG_DIR/make_tarball.sh" --bundle "$BUNDLE" --arch "$ARCH" --version "$VERSION" --out "$OUT"
log "artifacts:"; ls -lh "$OUT"/SoftphonePro-"$VERSION"-linux-"$ARCH".*
