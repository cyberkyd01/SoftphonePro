#!/usr/bin/env bash
# Configure, build and (when possible) run the smoke test against a prefix.
#   run_smoke.sh <target> [--no-run] [-- extra cmake args]
# Host-runnable targets are executed; others only link.
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NATIVE="$(cd "$HERE/../.." && pwd)"
TARGET="$1"; shift
RUN=1; EXTRA=()
while [ $# -gt 0 ]; do case "$1" in --no-run) RUN=0;; --) shift; EXTRA=("$@"); break;; esac; shift; done
PREFIX="$NATIVE/out/$TARGET"
BLD="$NATIVE/build/smoke-$TARGET"
rm -rf "$BLD"
cmake -S "$HERE" -B "$BLD" -G Ninja -DCMAKE_BUILD_TYPE=Release -DSPC_PREFIX="$PREFIX" ${EXTRA[@]+"${EXTRA[@]}"}
cmake --build "$BLD"
if [ "$RUN" = 1 ]; then
  SMOKE_EXPECT="${SMOKE_EXPECT:-opus,G722,PCMU,PCMA,GSM,iLBC,speex,G729,L16}" "$BLD/smoke"
else
  echo "linked $BLD/smoke (not executed)"; file "$BLD/smoke" 2>/dev/null || true
fi
