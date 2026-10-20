#!/usr/bin/env bash
# Build SoftphonePro-<ver>-linux-<arch>.tar.gz from a Flutter Linux release bundle.
#   make_tarball.sh --bundle DIR --arch amd64|arm64 --version X.Y.Z --out DIR
set -euo pipefail
. "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

BUNDLE=""; ARCH=""; VERSION=""; OUT=""
while [ $# -gt 0 ]; do
  case "$1" in
    --bundle) BUNDLE="$2"; shift ;; --arch) ARCH="$2"; shift ;;
    --version) VERSION="$2"; shift ;; --out) OUT="$2"; shift ;;
    *) die "unknown argument $1" ;;
  esac; shift
done
[ -d "$BUNDLE" ] && [ -x "$BUNDLE/softphonepro" ] || die "bundle not found (or no softphonepro binary): $BUNDLE"
[ -n "$ARCH" ] && [ -n "$VERSION" ] && [ -n "$OUT" ] || die "usage: make_tarball.sh --bundle DIR --arch ARCH --version V --out DIR"
mkdir -p "$OUT"; OUT="$(cd "$OUT" && pwd)"
NAME="SoftphonePro-$VERSION-linux-$ARCH"
TAR="$OUT/$NAME.tar.gz"

WORK="$(mktemp -d)"; trap 'rm -rf "$WORK"' EXIT
TOP="$WORK/$NAME"
cp -a "$BUNDLE" "$TOP"
finalize_bundle "$TOP"

install -d -m 755 "$TOP/share/applications"
install -m 644 "$PKG_DIR/$APP_ID.desktop" "$TOP/share/applications/$APP_ID.desktop"
gen_icons "$TOP/share/icons/hicolor"
install -m 755 "$PKG_DIR/install-desktop-entry.sh" "$PKG_DIR/uninstall-desktop-entry.sh" "$TOP/"
install -m 644 "$PKG_DIR/README-linux.txt" "$TOP/README.txt"
install -m 644 "$REPO_DIR/LICENSE" "$TOP/LICENSE"
install -m 644 "$REPO_DIR/THIRD_PARTY_NOTICES.md" "$TOP/THIRD_PARTY_NOTICES.md"
find "$TOP/share" -type d -exec chmod 755 {} +

rm -f "$TAR"
tar --owner=0 --group=0 --numeric-owner --sort=name -C "$WORK" -cf - "$NAME" | gzip -9n > "$TAR"
log "done: $TAR ($(du -h "$TAR" | cut -f1))"
