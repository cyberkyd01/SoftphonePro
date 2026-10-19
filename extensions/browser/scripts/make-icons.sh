#!/usr/bin/env bash
# Regenerate src/icons/*.png from the app's branding SVG (requires rsvg-convert, e.g. brew install librsvg).
set -euo pipefail
here="$(cd "$(dirname "$0")/.." && pwd)"
svg="$here/../../app/assets/branding/icon.svg"
mkdir -p "$here/src/icons"
for s in 16 32 48 128; do
  rsvg-convert -w "$s" -h "$s" "$svg" -o "$here/src/icons/icon-$s.png"
done
ls -l "$here/src/icons"
