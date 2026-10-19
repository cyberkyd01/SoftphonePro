#!/usr/bin/env bash
# Runs inside an emulator (adb device present): install the x86_64 APK, launch, wait, screenshot,
# assert the process is alive and logcat has no crash for the package.
#   tests/smoke/android_smoke.sh <apk> <outdir>
set -uo pipefail
APK="${1:?apk}"; OUT="${2:?outdir}"; PKG=com.softphonepro.softphonepro
mkdir -p "$OUT"
adb logcat -c
adb install -r -g "$APK" || { echo "FAIL: install"; exit 1; }
adb shell monkey -p "$PKG" -c android.intent.category.LAUNCHER 1 >/dev/null
sleep 25
PID="$(adb shell pidof "$PKG" | tr -d '\r')"
echo "pid: ${PID:-none}"
adb exec-out screencap -p > "$OUT/android-emulator.png"
adb logcat -d -b all > "$OUT/logcat.txt"
FAIL=0
[ -n "$PID" ] || { echo "FAIL: app process not running"; FAIL=1; }
if grep -E "FATAL EXCEPTION|Fatal signal|>>> $PKG <<<" "$OUT/logcat.txt" | grep -v "^$" | head -5 | grep .; then
  echo "FAIL: crash in logcat"; FAIL=1
fi
grep -i -E "spcore|SoftphonePro" "$OUT/logcat.txt" | head -15 || true
[ -s "$OUT/android-emulator.png" ] || { echo "FAIL: no screenshot"; FAIL=1; }
[ "$FAIL" = 0 ] && echo "ANDROID SMOKE OK"
exit "$FAIL"
