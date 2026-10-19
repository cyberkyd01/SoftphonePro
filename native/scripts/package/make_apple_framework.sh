#!/usr/bin/env bash
# Wrap a dylib/framework binary into a dynamic spcore.framework.
#   make_apple_framework.sh <macos|ios> <input-binary> <out-dir> [version]
# macOS: versioned bundle (Versions/A, install name @rpath/spcore.framework/Versions/A/spcore).
# iOS  : flat bundle     (install name @rpath/spcore.framework/spcore).
# The result is ad-hoc signed. Works with Command Line Tools only (no Xcode needed).
set -euo pipefail
KIND="$1"; IN="$2"; OUT="$3"; VER="${4:-1.0.0}"
BUNDLE_ID="${SPC_FRAMEWORK_ID:-com.softphonepro.spcore}"
FW="$OUT/spcore.framework"
rm -rf "$FW"
plist() { # $1 = path ; $2 = extra keys
  cat > "$1" <<PL
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
  <key>CFBundleDevelopmentRegion</key><string>en</string>
  <key>CFBundleExecutable</key><string>spcore</string>
  <key>CFBundleIdentifier</key><string>$BUNDLE_ID</string>
  <key>CFBundleInfoDictionaryVersion</key><string>6.0</string>
  <key>CFBundleName</key><string>spcore</string>
  <key>CFBundlePackageType</key><string>FMWK</string>
  <key>CFBundleShortVersionString</key><string>$VER</string>
  <key>CFBundleVersion</key><string>1</string>
  $2
</dict></plist>
PL
}
case "$KIND" in
  macos)
    mkdir -p "$FW/Versions/A/Resources"
    cp "$IN" "$FW/Versions/A/spcore"
    install_name_tool -id "@rpath/spcore.framework/Versions/A/spcore" "$FW/Versions/A/spcore"
    plist "$FW/Versions/A/Resources/Info.plist" '<key>CFBundleSupportedPlatforms</key><array><string>MacOSX</string></array><key>LSMinimumSystemVersion</key><string>11.0</string>'
    ln -s A "$FW/Versions/Current"
    ln -s Versions/Current/spcore "$FW/spcore"
    ln -s Versions/Current/Resources "$FW/Resources"
    ;;
  ios)
    mkdir -p "$FW"
    cp "$IN" "$FW/spcore"
    install_name_tool -id "@rpath/spcore.framework/spcore" "$FW/spcore"
    plist "$FW/Info.plist" '<key>CFBundleSupportedPlatforms</key><array><string>iPhoneOS</string></array><key>MinimumOSVersion</key><string>13.0</string>'
    ;;
  *) echo "kind must be macos|ios" >&2; exit 1 ;;
esac
codesign --force -s - "$FW" >/dev/null
echo "framework: $FW"
