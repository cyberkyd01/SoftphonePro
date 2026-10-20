#!/usr/bin/env bash
# Runs INSIDE a clean distro container (debian:12, ubuntu:22.04, ubuntu:24.04, debian:13, ...):
# installs the .deb with apt (lean: no Recommends) and checks the package.
#   docker run --rm -v "$PWD/dist/linux:/dist:ro" -v "$PWD/tests/smoke:/smoke:ro" debian:12 bash /smoke/linux_install_check.sh
# The .deb is /dist/SoftphonePro-*-linux-*.deb (exactly one). Exit code != 0 on any hard failure;
# lintian is informational only.
set -uo pipefail
export DEBIAN_FRONTEND=noninteractive
fail=0
bad() { echo "FAIL: $*"; fail=1; }
ok() { echo "PASS: $*"; }

. /etc/os-release; echo "== $PRETTY_NAME ($(uname -m))"
debs=(/dist/SoftphonePro-*-linux-*.deb)
[ "${#debs[@]}" = 1 ] && [ -f "${debs[0]}" ] || { echo "FAIL: expected exactly one .deb in /dist, got: ${debs[*]}"; exit 1; }
apt-get update -qq >/dev/null || { echo "FAIL: apt-get update"; exit 1; }
# desktop-file-utils / appstream(-cli) for the validators; file for the ELF test below.
apt-get install -y -qq --no-install-recommends desktop-file-utils appstream file ca-certificates >/dev/null 2>&1 || bad "validator tools did not install"
if apt-get install -y --no-install-recommends "${debs[0]}" >/tmp/apt-install.log 2>&1; then ok "apt-get install ${debs[0]##*/} (no recommends)"; else cat /tmp/apt-install.log | tail -30; bad "apt-get install failed"; exit 1; fi

# ldd: no unresolved library for the launcher and every bundled .so (libapp.so is the Dart AOT snapshot).
n=0
while IFS= read -r f; do
  file -b "$f" | grep -q '^ELF' || continue
  n=$((n + 1))
  out="$(ldd "$f" 2>&1)"
  if echo "$out" | grep -q 'not found'; then echo "$out" | grep 'not found'; bad "ldd $f has unresolved libraries"; fi
done < <(find /opt/softphonepro -type f \( -name softphonepro -o -name '*.so' -o -name '*.so.*' \) ! -name libapp.so)
[ "$n" -ge 3 ] && ok "ldd: no 'not found' in $n ELF files" || bad "expected >= 3 ELF files, saw $n"
[ -x /usr/bin/softphonepro ] && ok "/usr/bin/softphonepro launcher" || bad "/usr/bin/softphonepro missing"

D=/usr/share/applications/com.softphonepro.softphonepro.desktop
M=/usr/share/metainfo/com.softphonepro.softphonepro.metainfo.xml
desktop-file-validate "$D" && ok "desktop-file-validate" || bad "desktop-file-validate"
appstreamcli validate --no-net "$M" && ok "appstreamcli validate --no-net" || bad "appstreamcli validate"
for s in 16 32 48 64 128 256 512; do
  [ -f "/usr/share/icons/hicolor/${s}x${s}/apps/com.softphonepro.softphonepro.png" ] || bad "icon ${s}x${s} missing"
done
dpkg -s softphonepro | grep -E '^(Version|Architecture|Depends):' | cut -c1-200

# lintian: informational only.
if apt-get install -y -qq --no-install-recommends lintian >/dev/null 2>&1; then
  echo "== lintian (informational)"; lintian --no-tag-display-limit "${debs[0]}" || true
else echo "lintian not available on $PRETTY_NAME"; fi

[ "$fail" = 0 ] && echo "INSTALL CHECK OK on $PRETTY_NAME" || { echo "INSTALL CHECK FAILED on $PRETTY_NAME"; exit 1; }
