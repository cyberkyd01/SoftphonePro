#!/usr/bin/env bash
# Boots an iPhone simulator, installs + launches the simulator build of the app, verifies it is still
# alive after ~25 s, takes a screenshot and captures the device log.
#   tests/smoke/ios_sim_smoke.sh <Runner.app> <outdir>
set -euo pipefail
APP="${1:?Runner.app}"; OUT="${2:?outdir}"
mkdir -p "$OUT"
BUNDLE_ID="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' "$APP/Info.plist")"
echo "bundle id: $BUNDLE_ID"

UDID="$(xcrun simctl list devices available -j | python3 -c '
import json,sys
d=json.load(sys.stdin)["devices"]
c=[]
for rt,devs in d.items():
    if "iOS" not in rt: continue
    ver=tuple(int(x) for x in rt.split("iOS-")[-1].split("-") if x.isdigit())
    for x in devs:
        if x["name"].startswith("iPhone") and x.get("isAvailable",True): c.append((ver,x["name"],x["udid"]))
c.sort()
print(c[-1][2] if c else "")
')"
[ -n "$UDID" ] || { echo "no available iPhone simulator"; xcrun simctl list devices available; exit 1; }
echo "using simulator $UDID"
xcrun simctl boot "$UDID" || true
xcrun simctl bootstatus "$UDID" -b
xcrun simctl install "$UDID" "$APP"

# stream the log of the app process while it runs
xcrun simctl spawn "$UDID" log stream --style compact --level debug --predicate 'process == "Runner"' > "$OUT/device.log" 2>&1 &
LOGPID=$!
sleep 2
xcrun simctl launch --console-pty "$UDID" "$BUNDLE_ID" > "$OUT/console.log" 2>&1 &
sleep 5
PID="$(xcrun simctl spawn "$UDID" launchctl list | awk -v b="UIKitApplication:$BUNDLE_ID" 'index($0,b){print $1; exit}')"
echo "app pid after 5 s: ${PID:-none}"
sleep 20
PID2="$(xcrun simctl spawn "$UDID" launchctl list | awk -v b="UIKitApplication:$BUNDLE_ID" 'index($0,b){print $1; exit}')"
echo "app pid after 25 s: ${PID2:-none}"
xcrun simctl io "$UDID" screenshot "$OUT/ios-simulator.png"
sleep 1
kill "$LOGPID" 2>/dev/null || true

echo "--- console tail"; tail -n 30 "$OUT/console.log" || true
echo "--- engine-related log lines"; grep -i -E 'spcore|engine' "$OUT/device.log" "$OUT/console.log" | head -20 || true

FAIL=0
if [ -z "${PID2:-}" ] || [ "$PID2" = "-" ]; then echo "FAIL: app is not running after 25 s"; FAIL=1; fi
if [ -n "${PID:-}" ] && [ -n "${PID2:-}" ] && [ "$PID" != "$PID2" ]; then echo "FAIL: app pid changed ($PID -> $PID2): it crashed/restarted"; FAIL=1; fi
if ls ~/Library/Logs/DiagnosticReports/Runner* >/dev/null 2>&1; then echo "FAIL: crash report found"; cp ~/Library/Logs/DiagnosticReports/Runner* "$OUT/" ; FAIL=1; fi
[ -s "$OUT/ios-simulator.png" ] || { echo "FAIL: no screenshot"; FAIL=1; }
xcrun simctl terminate "$UDID" "$BUNDLE_ID" || true
xcrun simctl shutdown "$UDID" || true
[ "$FAIL" = 0 ] && echo "IOS SMOKE OK"
exit "$FAIL"
