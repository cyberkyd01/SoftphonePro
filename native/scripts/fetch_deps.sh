#!/usr/bin/env bash
# Download the pinned third-party sources into native/deps/src (idempotent).
# Every archive is verified against the SHA-256 recorded below. A cached file
# whose hash does not match is deleted and downloaded again; a fresh download
# that does not match aborts the script.
#
# build_deps_windows.ps1 parses the DEP| lines below, so keep the format:
#   DEP|<name>|<version>|<file name>|<sha256>|<url>
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NATIVE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
DEPS_SRC="${SPC_DEPS_SRC:-$NATIVE_DIR/deps/src}"

dep_table() {
cat <<'TABLE'
DEP|pjproject|2.17|pjproject-2.17.tar.gz|065fe06c06788d97c35f563796d59f00ce52fe9558a52d7b490a042a966facce|https://github.com/pjsip/pjproject/archive/refs/tags/2.17.tar.gz
DEP|openssl|3.5.9|openssl-3.5.9.tar.gz|603f5602e2eef00d77fbd429d34dcd5822bb301757a1bc9cdb24c670f1eb859a|https://github.com/openssl/openssl/releases/download/openssl-3.5.9/openssl-3.5.9.tar.gz
DEP|opus|1.6.1|opus-1.6.1.tar.gz|6ffcb593207be92584df15b32466ed64bbec99109f007c82205f0194572411a1|https://downloads.xiph.org/releases/opus/opus-1.6.1.tar.gz
DEP|bcg729|1.1.2|bcg729-1.1.2.tar.gz|9c22d98c2debc1e37163b8a703f05278ad5d9c03f1c6b373629d8a072092184a|https://github.com/BelledonneCommunications/bcg729/archive/refs/tags/1.1.2.tar.gz
DEP|oboe|1.11.0|oboe-1.11.0.tar.gz|0ccf2110640a2b4489f1c93a404f2978656b434d8c5dc9cb6258f9cc95c79b15|https://github.com/google/oboe/archive/refs/tags/1.11.0.tar.gz
TABLE
}

sha256_of() {
  if command -v sha256sum >/dev/null 2>&1; then sha256sum "$1" | cut -d' ' -f1
  else shasum -a 256 "$1" | cut -d' ' -f1; fi
}

fetch_one() {
  local name="$1" ver="$2" file="$3" sha="$4" url="$5" dest="$DEPS_SRC/$3"
  if [ -f "$dest" ]; then
    if [ "$(sha256_of "$dest")" = "$sha" ]; then
      echo "[fetch] ok      $file"
      return 0
    fi
    echo "[fetch] hash mismatch for cached $file; re-downloading" >&2
    rm -f "$dest"
  fi
  echo "[fetch] get     $file  <- $url"
  mkdir -p "$DEPS_SRC"
  curl -fL --retry 4 --retry-delay 2 --connect-timeout 30 -o "$dest.part" "$url"
  local got; got="$(sha256_of "$dest.part")"
  if [ "$got" != "$sha" ]; then
    rm -f "$dest.part"
    echo "[fetch] SHA-256 MISMATCH for $file" >&2
    echo "        expected $sha" >&2
    echo "        got      $got" >&2
    exit 1
  fi
  mv "$dest.part" "$dest"
  echo "[fetch] verified $file"
}

main() {
  local only=("$@")
  mkdir -p "$DEPS_SRC"
  while IFS='|' read -r tag name ver file sha url; do
    [ "$tag" = "DEP" ] || continue
    if [ "${#only[@]}" -gt 0 ]; then
      local want=0 o
      for o in "${only[@]}"; do [ "$o" = "$name" ] && want=1; done
      [ "$want" = 1 ] || continue
    fi
    fetch_one "$name" "$ver" "$file" "$sha" "$url"
  done < <(dep_table)
  echo "[fetch] done -> $DEPS_SRC"
}

# `fetch_deps.sh [name ...]` (names: pjproject openssl opus bcg729 oboe)
# When sourced (common.sh) only the functions are defined.
if [ "${BASH_SOURCE[0]}" = "$0" ]; then main "$@"; fi
