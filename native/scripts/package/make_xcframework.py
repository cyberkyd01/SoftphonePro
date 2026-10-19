#!/usr/bin/env python3
"""Create an .xcframework directory by hand (same layout xcodebuild -create-xcframework produces).

Used when full Xcode is unavailable (Command Line Tools only). Usage:
  make_xcframework.py <out.xcframework> <slice-id>:<framework-dir>:<arch,arch>:<platform>[:simulator] ...
e.g. macos-arm64_x86_64:/tmp/fw/spcore.framework:arm64,x86_64:macos
"""
import os, plistlib, shutil, subprocess, sys

out = sys.argv[1]
shutil.rmtree(out, ignore_errors=True)
os.makedirs(out)
libs = []
for spec in sys.argv[2:]:
    parts = spec.split(":")
    ident, fw, archs, plat = parts[:4]
    sim = len(parts) > 4 and parts[4] == "simulator"
    dest = os.path.join(out, ident)
    os.makedirs(dest)
    # cp -R keeps the symlinks inside macOS framework bundles
    subprocess.check_call(["cp", "-R", fw, dest])
    entry = {
        "LibraryIdentifier": ident,
        "LibraryPath": "spcore.framework",
        "SupportedArchitectures": archs.split(","),
        "SupportedPlatform": plat,
    }
    if sim:
        entry["SupportedPlatformVariant"] = "simulator"
    libs.append(entry)
with open(os.path.join(out, "Info.plist"), "wb") as f:
    plistlib.dump({"AvailableLibraries": libs, "CFBundlePackageType": "XFWK",
                   "XCFrameworkFormatVersion": "1.0"}, f)
print("xcframework:", out)
