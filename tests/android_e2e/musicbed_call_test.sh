#!/usr/bin/env bash
# Musicbed call scenario on the emulator (emulator-5554, app already registered, musicbed enabled with bed440 at 100%).
# Timeline (t = seconds after the Record button): 0-12 bed 100% | 12 set slider to ~20% | 24 Hold | 36 Resume | 46 Stop.
# NOTE: the final results were gathered with the same steps run by hand (the in-call mixer must be expanded and
# scrolled into view before the slider tap; this script's find/swipe timing is flaky). Writes the event timeline to $1 (default /tmp/timeline.txt). Coordinates are for a 1080x2400 screen.
set -u
U="python3 $(dirname "$0")/ui.py"; OUT=${1:-/tmp/timeline.txt}; : > "$OUT"
ev(){ echo "$(date +%s.%N | cut -c1-14) $*" >> "$OUT"; echo "$*"; }
adb shell input keyevent KEYCODE_HOME >/dev/null; adb shell am start -n com.softphonepro.softphonepro/.MainActivity >/dev/null; sleep 2
$U tap Keypad >/dev/null; sleep 1
for d in 6 0 0; do $U tap "$d, Long" >/dev/null; done
$U tapxy 540 2032; ev dial; sleep 5
$U tapxy 235 1055; ev mute; sleep 1
$U tapxy 235 1654; ev record_start; sleep 4
$U tapxy 975 1885; sleep 2; $U swipe 540 1500 540 500 500; sleep 2; ev mixer_expanded
$U shot D_incall_mixer_100
sleep 2; Y=$($U find "Musicbed volume" | python3 -c "import sys,ast;b=ast.literal_eval(sys.stdin.readline())[2];print((b[1]+b[3])//2)"); echo "slider y=$Y"; $U tapxy 288 "$Y"; ev vol20; $U shot D_incall_mixer_20
sleep 12
$U tap Hold >/dev/null; ev hold; sleep 1; $U shot D_hold; sleep 11
($U tap Resume || $U tap Hold) >/dev/null; ev resume; sleep 11
$U tap Stop >/dev/null; ev record_stop; sleep 2
$U tap "End call" >/dev/null; ev hangup
