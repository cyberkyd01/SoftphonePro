#!/usr/bin/env bash
# Build SoftphonePro-<ver>-linux-<arch>.deb from a Flutter Linux release bundle.
#   make_deb.sh --bundle DIR --arch amd64|arm64 --version X.Y.Z --out DIR
# Needs dpkg-dev (dpkg-deb, dpkg-shlibdeps), ImageMagick, and optionally lintian/desktop-file-validate.
# Layout: /opt/softphonepro (the bundle), /usr/bin/softphonepro symlink, desktop file, hicolor icons,
# AppStream metainfo, copyright. Depends are computed with dpkg-shlibdeps over the bundle's ELF files.
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
[ -n "$ARCH" ] && [ -n "$VERSION" ] && [ -n "$OUT" ] || die "usage: make_deb.sh --bundle DIR --arch ARCH --version V --out DIR"
mkdir -p "$OUT"; OUT="$(cd "$OUT" && pwd)"
DEB="$OUT/SoftphonePro-$VERSION-linux-$ARCH.deb"
# Debian pre-release ordering: 1.2.0-dev.5 sorts after 1.2.0 unless written 1.2.0~dev.5.
TILDE='~'
DEB_VERSION="${VERSION/-/$TILDE}"

WORK="$(mktemp -d)"; trap 'rm -rf "$WORK"' EXIT
ROOT="$WORK/root"
install -d -m 755 "$ROOT/opt" "$ROOT/usr/bin" "$ROOT/usr/share/applications" "$ROOT/usr/share/metainfo" \
  "$ROOT/usr/share/doc/softphonepro" "$ROOT/DEBIAN"

log "staging the bundle in /opt/softphonepro"
cp -a "$BUNDLE" "$ROOT/opt/softphonepro"
finalize_bundle "$ROOT/opt/softphonepro"
ln -s /opt/softphonepro/softphonepro "$ROOT/usr/bin/softphonepro"

install -m 644 "$PKG_DIR/$APP_ID.desktop" "$ROOT/usr/share/applications/$APP_ID.desktop"
install -m 644 "$PKG_DIR/$APP_ID.metainfo.xml" "$ROOT/usr/share/metainfo/$APP_ID.metainfo.xml"
gen_icons "$ROOT/usr/share/icons/hicolor"
find "$ROOT/usr/share/icons" -type d -exec chmod 755 {} +
find "$ROOT/usr/share/icons" -type f -exec chmod 644 {} +

# Documentation: copyright (DEP-5), third-party notices, a minimal Debian changelog.
DOC="$ROOT/usr/share/doc/softphonepro"
cat > "$DOC/copyright" <<EOC
Format: https://www.debian.org/doc/packaging-manuals/copyright-format/1.0/
Upstream-Name: SoftphonePro
Upstream-Contact: https://github.com/cyberkyd01/SoftphonePro
Source: https://github.com/cyberkyd01/SoftphonePro

Files: *
Copyright: 2025-2026 SoftphonePro contributors
License: GPL-3+

License: GPL-3+
 SoftphonePro is free software: you can redistribute it and/or modify it under the terms of
 the GNU General Public License as published by the Free Software Foundation, either version 3
 of the License, or (at your option) any later version.
 .
 SoftphonePro is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
 without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 See the GNU General Public License for more details.
 .
 On Debian systems, the complete text of the GNU General Public License version 3 can be found
 in /usr/share/common-licenses/GPL-3.
 .
 The packaged binaries also contain or link third-party components (PJSIP, OpenSSL, Opus,
 bcg729, RNNoise, minimp3, cJSON, Flutter and Dart packages) under their own licences; they
 are listed in /usr/share/doc/softphonepro/THIRD_PARTY_NOTICES.md.gz and, for the Dart
 packages, in the app under Settings > About. The complete corresponding source is the
 repository at the release tag.
EOC
gzip -9n -c "$REPO_DIR/THIRD_PARTY_NOTICES.md" > "$DOC/THIRD_PARTY_NOTICES.md.gz"
{
  echo "softphonepro ($DEB_VERSION) unstable; urgency=medium"
  echo
  echo "  * SoftphonePro $VERSION for Linux."
  echo "  * Release notes: https://github.com/cyberkyd01/SoftphonePro/releases"
  echo "  * Full history: /usr/share/doc/softphonepro/CHANGELOG.md.gz"
  echo
  echo " -- $MAINTAINER  $(LC_ALL=C date -R)"
} | gzip -9n > "$DOC/changelog.gz"
gzip -9n -c "$REPO_DIR/CHANGELOG.md" > "$DOC/CHANGELOG.md.gz"
chmod 644 "$DOC"/*

# Man page and lintian overrides (the app lives in /opt by design, and ships its own libraries).
install -d -m 755 "$ROOT/usr/share/man/man1" "$ROOT/usr/share/lintian/overrides"
cat > "$WORK/softphonepro.1" <<'EOM'
.TH SOFTPHONEPRO 1 "" "SoftphonePro" "User Commands"
.SH NAME
softphonepro \- free, open-source SIP softphone
.SH SYNOPSIS
.B softphonepro
[\fB\-\-minimized\fR] [\fB\-\-provision\fR \fIFILE\fR] [\fIURI\fR]
.SH DESCRIPTION
SoftphonePro makes and receives voice calls over SIP. Only one instance runs per desktop session:
starting it again, or opening a link, hands the request over to the running instance.
.SH OPTIONS
.TP
.B \-\-minimized
Start hidden in the system tray.
.TP
.BI \-\-provision " FILE"
Import accounts and settings from a local JSON file.
.TP
.I URI
A sip:, sips:, tel:, callto: or softphonepro: link to open.
.SH SEE ALSO
https://github.com/cyberkyd01/SoftphonePro
EOM
gzip -9n -c "$WORK/softphonepro.1" > "$ROOT/usr/share/man/man1/softphonepro.1.gz"
chmod 644 "$ROOT/usr/share/man/man1/softphonepro.1.gz"
cat > "$ROOT/usr/share/lintian/overrides/softphonepro" <<'EOM'
# The self-contained Flutter bundle lives in /opt/softphonepro; /usr/bin/softphonepro links to it.
softphonepro: dir-or-file-in-opt opt/softphonepro/*
# Bundled Flutter engine / PJSIP statically contain these; upstream does not support system copies.
softphonepro: embedded-library *
# libapp.so is the Dart AOT snapshot, not a normal shared library.
softphonepro: shared-library-lacks-prerequisites opt/softphonepro/lib/libapp.so
EOM
chmod 644 "$ROOT/usr/share/lintian/overrides/softphonepro"

# Depends: shared-library dependencies of every ELF file in the bundle.
log "computing Depends with dpkg-shlibdeps"
mkdir -p "$WORK/debian"
printf 'Source: softphonepro\n\nPackage: softphonepro\nArchitecture: %s\n' "$ARCH" > "$WORK/debian/control"
ELFS=()
while IFS= read -r f; do
  file -b "$f" | grep -q '^ELF' && ELFS+=("-e$f") || true
done < <(find "$ROOT/opt/softphonepro" -type f \( -name '*.so' -o -name '*.so.*' -o -name softphonepro \) ! -name libapp.so)
# -l: where the bundle's own libraries live (libflutter_linux_gtk.so, libspcore.so, plugins);
# those have no dpkg metadata, so tolerate that. libapp.so (the Dart AOT snapshot) is skipped.
SHLIBS="$(cd "$WORK" && dpkg-shlibdeps -O --ignore-missing-info -l"$ROOT/opt/softphonepro/lib" \
            "${ELFS[@]}" 2>"$WORK/shlibdeps.err" | sed -n 's/^shlibs:Depends=//p')" || true
# dpkg-shlibdeps is very chatty about bundled libraries; show only real problems.
grep -E '^dpkg-shlibdeps: (error|warning: (cannot find|could not find))' "$WORK/shlibdeps.err" | sort -u >&2 || true
[ -n "$SHLIBS" ] || die "dpkg-shlibdeps produced no dependencies"
# Runtime-only: the GStreamer plugins (audioplayers: ringtones, Ogg playback) and EGL/GL, which Flutter's
# GTK embedder loads through libepoxy with dlopen() (no ELF link, so dpkg-shlibdeps cannot see them).
EXTRA_DEPENDS="gstreamer1.0-plugins-base, gstreamer1.0-plugins-good, libegl1, libgl1, xdg-user-dirs"
RECOMMENDS="zenity | kdialog, gnome-keyring | kwalletmanager, xdg-utils, libasound2-plugins | pipewire-alsa, libgl1-mesa-dri"

INSTALLED_KB="$(du -sk --apparent-size "$ROOT" | cut -f1)"
cat > "$ROOT/DEBIAN/control" <<EOC
Package: softphonepro
Version: $DEB_VERSION
Architecture: $ARCH
Maintainer: $MAINTAINER
Installed-Size: $INSTALLED_KB
Depends: $SHLIBS, $EXTRA_DEPENDS
Recommends: $RECOMMENDS
Section: comm
Priority: optional
Homepage: https://github.com/cyberkyd01/SoftphonePro
Description: Free, open-source SIP softphone
 SoftphonePro makes and receives voice calls over SIP (UDP, TCP, TLS and
 WebSocket) with SRTP/DTLS-SRTP, ICE/STUN/TURN and codecs including Opus,
 G.711, G.722 and G.729. It handles several accounts, call history,
 contacts, call recording and sip:/tel: links, and runs on X11 and Wayland.
 .
 The call engine is built on PJSIP. This package is the 64-bit build for
 Ubuntu, Debian and Raspberry Pi OS.
EOC
(cd "$ROOT" && find opt usr -type f -print0 | sort -z | xargs -0 md5sum > DEBIAN/md5sums)
chmod 644 "$ROOT/DEBIAN/md5sums"; chmod 755 "$ROOT/DEBIAN"

log "building $DEB"
rm -f "$DEB"
dpkg-deb --root-owner-group -Zxz -b "$ROOT" "$DEB" >/dev/null

if command -v desktop-file-validate >/dev/null 2>&1; then
  desktop-file-validate "$PKG_DIR/$APP_ID.desktop" && log "desktop-file-validate: ok"
fi
if command -v appstreamcli >/dev/null 2>&1; then
  appstreamcli validate --no-net "$PKG_DIR/$APP_ID.metainfo.xml" || true
fi
if command -v lintian >/dev/null 2>&1; then
  log "lintian (informational):"
  lintian --no-tag-display-limit "$DEB" || true
fi
log "done: $DEB ($(du -h "$DEB" | cut -f1))"
