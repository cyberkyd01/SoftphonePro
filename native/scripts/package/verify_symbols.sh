#!/usr/bin/env bash
# Verify that a shared library exports the spcore C ABI.
#   verify_symbols.sh <lib> [nm-tool]
# Works for Mach-O (nm -gU), ELF (nm -D / llvm-nm -D). Windows: see build_spcore_windows.ps1 (dumpbin).
set -euo pipefail
LIB="$1"; NM="${2:-}"
REQUIRED="spc_api_version spc_version_string spc_init_dart_api spc_init spc_set_event_port spc_set_event_callback spc_request spc_request_sync spc_free spc_shutdown"
[ -f "$LIB" ] || { echo "verify_symbols: $LIB not found" >&2; exit 1; }
if [ -z "$NM" ]; then
  if command -v llvm-nm >/dev/null 2>&1; then NM=llvm-nm; else NM=nm; fi
fi
if file "$LIB" | grep -q 'Mach-O'; then
  OUT="$("$NM" -gU "$LIB" 2>&1 || true)"
else
  OUT="$("$NM" -D --defined-only "$LIB" 2>&1 || true)"
fi
missing=0
for s in $REQUIRED; do
  # Mach-O prefixes C symbols with an underscore.
  if ! grep -Eq "[[:space:]]_?${s}\$" <<<"$OUT"; then
    echo "verify_symbols: MISSING export '$s' in $LIB" >&2; missing=1
  fi
done
[ "$missing" = 0 ] || exit 1
echo "verify_symbols: OK ($(echo $REQUIRED | wc -w | tr -d ' ') symbols) $LIB"
