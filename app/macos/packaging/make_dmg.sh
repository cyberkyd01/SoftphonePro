#!/usr/bin/env bash
# Create SoftphonePro-<ver>-macOS.dmg from the built .app (flutter build macos --release).
#   make_dmg.sh <version> [path/to/softphonepro.app] [output-dir]
# Signing:
#   default                      ad-hoc (codesign --force --deep -s -)  -> users right-click > Open
#   APPLE_CERT_BASE64 + APPLE_CERT_PASSWORD + APPLE_SIGN_IDENTITY set
#                                -> Developer ID signing (hardened runtime) with a temp keychain
#   + APPLE_ID, APPLE_TEAM_ID, APPLE_APP_PASSWORD also set
#                                -> notarize with notarytool and staple
set -euo pipefail
VER="${1:?usage: make_dmg.sh <version> [app] [outdir]}"
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP="${2:-$HERE/../../build/macos/Build/Products/Release/softphonepro.app}"
OUT="${3:-$HERE/../../build/macos/dist}"
VOL="SoftphonePro"
DMG="$OUT/SoftphonePro-$VER-macOS.dmg"
ENT="$HERE/../Runner/Release.entitlements"

[ -d "$APP" ] || { echo "app bundle not found: $APP" >&2; exit 1; }
mkdir -p "$OUT"
STAGE="$(mktemp -d)"; trap 'rm -rf "$STAGE"; [ -n "${KC:-}" ] && security delete-keychain "$KC" 2>/dev/null || true' EXIT
cp -R "$APP" "$STAGE/SoftphonePro.app"
APP2="$STAGE/SoftphonePro.app"

if [ -n "${APPLE_CERT_BASE64:-}" ] && [ -n "${APPLE_SIGN_IDENTITY:-}" ]; then
  echo "Signing with Developer ID: $APPLE_SIGN_IDENTITY"
  KC="$RUNNER_TEMP/spc-signing.keychain-db"; KCPW="$(uuidgen)"
  echo "$APPLE_CERT_BASE64" | base64 --decode > "$STAGE/cert.p12"
  security create-keychain -p "$KCPW" "$KC"; security set-keychain-settings -lut 21600 "$KC"
  security unlock-keychain -p "$KCPW" "$KC"
  security import "$STAGE/cert.p12" -P "${APPLE_CERT_PASSWORD:-}" -A -t cert -f pkcs12 -k "$KC"
  security set-key-partition-list -S apple-tool:,apple: -k "$KCPW" "$KC" >/dev/null
  security list-keychains -d user -s "$KC" login.keychain-db
  rm -f "$STAGE/cert.p12"
  # Sign nested code first, then the app (no --deep for Developer ID).
  find "$APP2/Contents/Frameworks" -maxdepth 1 \( -name '*.framework' -o -name '*.dylib' \) -print0 |
    xargs -0 -I{} codesign --force --options runtime --timestamp -s "$APPLE_SIGN_IDENTITY" "{}"
  codesign --force --options runtime --timestamp --entitlements "$ENT" -s "$APPLE_SIGN_IDENTITY" "$APP2"
  SIGNED=1
else
  echo "Ad-hoc signing (no Developer ID configured)"
  codesign --force --deep -s - "$APP2"
  SIGNED=0
fi
codesign --verify --deep --strict "$APP2"

ln -s /Applications "$STAGE/Applications"
rm -f "$DMG"
hdiutil create -volname "$VOL" -srcfolder "$STAGE" -ov -format UDZO -fs HFS+ "$DMG"

if [ "$SIGNED" = 1 ]; then
  codesign --force --timestamp -s "$APPLE_SIGN_IDENTITY" "$DMG"
  if [ -n "${APPLE_ID:-}" ] && [ -n "${APPLE_TEAM_ID:-}" ] && [ -n "${APPLE_APP_PASSWORD:-}" ]; then
    xcrun notarytool submit "$DMG" --apple-id "$APPLE_ID" --team-id "$APPLE_TEAM_ID" --password "$APPLE_APP_PASSWORD" --wait
    xcrun stapler staple "$DMG"
  else
    echo "Notarization skipped (APPLE_ID / APPLE_TEAM_ID / APPLE_APP_PASSWORD not set)"
  fi
fi
echo "Created $DMG"
