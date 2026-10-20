# Shared helpers for build_linux.sh / make_deb.sh / make_tarball.sh (sourced, not executed).
PKG_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_DIR="$(cd "$PKG_DIR/../.." && pwd)"
REPO_DIR="$(cd "$APP_DIR/.." && pwd)"
APP_ID=com.softphonepro.softphonepro
ICON_SIZES="16 32 48 64 128 256 512"
MAINTAINER='SoftphonePro <111638597+cyberkyd01@users.noreply.github.com>'

log() { printf '\033[1;34m[linux]\033[0m %s\n' "$*"; }
die() { printf '\033[1;31m[linux] ERROR:\033[0m %s\n' "$*" >&2; exit 1; }

# App version from app/pubspec.yaml without the +build suffix (1.1.0+3 -> 1.1.0).
app_version() { sed -n 's/^version:[[:space:]]*\([0-9][0-9.]*\).*/\1/p' "$APP_DIR/pubspec.yaml" | head -1; }

# Debian architecture of the machine we run on (the app is built natively, never cross-compiled).
host_deb_arch() {
  case "$(uname -m)" in
    x86_64) echo amd64 ;; aarch64|arm64) echo arm64 ;;
    *) die "unsupported host architecture $(uname -m) (Flutter Linux builds: x86_64 and arm64)" ;;
  esac
}
# Flutter's directory name for an architecture (build/linux/<x64|arm64>/release/bundle).
flutter_arch() { [ "$1" = amd64 ] && echo x64 || echo "$1"; }

# gen_icons <dest-hicolor-dir>: <N>x<N>/apps/com.softphonepro.softphonepro.png from the master icon.
gen_icons() {
  local dest="$1" master="$APP_DIR/assets/branding/icon_1024.png" conv n
  [ -f "$master" ] || die "missing $master"
  if command -v magick >/dev/null 2>&1; then conv="magick"; elif command -v convert >/dev/null 2>&1; then conv="convert"
  else die "ImageMagick (convert) is needed to generate icons"; fi
  for n in $ICON_SIZES; do
    mkdir -p "$dest/${n}x${n}/apps"
    $conv "$master" -filter Lanczos -resize "${n}x${n}" -strip "PNG32:$dest/${n}x${n}/apps/$APP_ID.png"
  done
}

# finalize_bundle <dir>: normalise a copy of the Flutter release bundle for shipping.
#  - plugin/engine libraries get RUNPATH $ORIGIN (the Flutter build leaves the build machine's
#    .../linux/flutter/ephemeral path in them),
#  - ELF files are stripped (not libapp.so: it is the Dart AOT snapshot),
#  - permissions: dirs 755, files 644, the launcher 755.
finalize_bundle() {
  local d="$1" f
  command -v patchelf >/dev/null || die "patchelf is needed"
  find "$d" -type d -exec chmod 755 {} +
  find "$d" -type f -exec chmod 644 {} +
  for f in "$d"/lib/*.so; do
    [ "$(basename "$f")" = libapp.so ] && continue
    patchelf --set-rpath '$ORIGIN' "$f"
  done
  for f in "$d/softphonepro" "$d"/lib/*.so; do
    [ "$(basename "$f")" = libapp.so ] && continue
    strip --strip-unneeded "$f"
  done
  chmod 755 "$d/softphonepro"
}
