#!/bin/bash
# Host-side driver for the automatable desktop-integration checks of the SoftphonePro Linux .deb (QA 1.1.0).
# Needs: the colima VM env (DOCKER_HOST/DOCKER_CONFIG), image spc-qa-desk:arm64 (see image/Dockerfile),
#        the QA PBX `spc-qa-pbx` on network spc-qa, and this directory bind-mounted at /e2e.
# Usage: DOCKER_HOST=... ./desktop_checks.sh [container=qa-desk-a] [ip=172.30.0.31]
# Prints PASS/FAIL per check: K1 (file backend), K2 (keyring first run), K5 (hanging Secret Service <=4s),
# T1 (no tray: close quits, --minimized iconic), S (autostart file on/off), L (xdg-mime + second-launch).
# Interactive checks (locked keyring prompt K3/K4, tray menu T2, MPRIS M, notifications N, hotkeys H, LAN) were
# driven by hand with lib/*.py helpers; see RESULTS_desktop.md for the exact steps.
C=${1:-qa-desk-a}; IP=${2:-172.30.0.31}; HERE="$(cd "$(dirname "$0")" && pwd)"
docker rm -f "$C" >/dev/null 2>&1
docker run -d --name "$C" --platform linux/arm64 --network spc-qa --ip "$IP" -v "$HERE:/e2e" spc-qa-desk:arm64 sleep infinity >/dev/null
docker exec "$C" rm -f /.dockerenv      # tray_manager treats /.dockerenv as a sandbox and passes a relative icon path
D() { docker exec -u qa "$C" bash -c ". /e2e/lib/h.sh; $*"; }
res() { printf '%-4s %s\n' "$1" "$2"; }
fresh() { docker exec "$C" /e2e/lib/reset.sh "$1" >/dev/null; }

fresh --wm
D '/e2e/lib/start_app.sh 1014 >/dev/null; sleep 1'
[ "$(D 'cat ~/.local/share/softphonepro/secrets/backend')" = file ] && res K1 "PASS marker=file" || res K1 FAIL
D 'pkill -u qa -x softphonepro; sleep 2; (setsid nohup softphonepro >/tmp/a2.out 2>&1 &); sleep 8; api GET /v1/status' | grep -q '"regState":"registered"' && res K1b "PASS registers after restart" || res K1b FAIL

fresh --wm
D 'echo -n qapass | gnome-keyring-daemon --unlock --components=secrets >/dev/null; /e2e/lib/start_app.sh 1014 >/dev/null'
[ "$(D 'cat ~/.local/share/softphonepro/secrets/backend')" = keyring ] && res K2 "PASS marker=keyring" || res K2 FAIL

fresh --wm
t=$(D 'python3 /e2e/lib/fake_secrets_hang.py >/dev/null 2>&1 & sleep 1; prov 1014; s=$(date +%s.%N); (setsid nohup softphonepro --provision /tmp/prov.json >/tmp/a.out 2>&1 &); for i in $(seq 300); do api GET /v1/status 2>/dev/null | grep -q SoftphonePro && break; sleep 0.1; done; python3 -c "import time;print(round(time.time()-$s,1))"')
python3 -c "import sys; sys.exit(0 if float('$t')<=4.5 else 1)" && res K5 "PASS usable after ${t}s" || res K5 "FAIL ${t}s"

fresh --wm
D '/e2e/lib/start_app.sh 1014 >/dev/null; sleep 1; xdotool mousemove 1231 70 click 1; sleep 4'
[ -z "$(D 'ps -eo stat,cmd | grep "[s]oftphonepro" | grep -v "^Z"')" ] && res T1a "PASS close quits without tray" || res T1a FAIL
D '(setsid nohup softphonepro --minimized >/dev/null 2>&1 &); sleep 9'
D 'xprop -id $(xdotool search --name "^SoftphonePro$" | tail -1) WM_STATE' | grep -q Iconic && res T1b "PASS --minimized is iconic" || res T1b FAIL

fresh --wm
D '/e2e/lib/start_app.sh 1014 >/dev/null; sleep 1; api POST /v1/ui/show -d "{\"route\":\"/settings/advanced\"}" >/dev/null; sleep 1.5; xdotool mousemove 1179 564 click 1; sleep 2; cat ~/.config/autostart/SoftphonePro.desktop; desktop-file-validate ~/.config/autostart/SoftphonePro.desktop && echo VALID' | grep -q -e '--minimized' && res S1 "PASS autostart file written, valid" || res S1 FAIL
D 'xdotool mousemove 1179 564 click 1; sleep 2; ls ~/.config/autostart/SoftphonePro.desktop 2>&1' | grep -q "No such" && res S2 "PASS toggle off removes file" || res S2 FAIL

D 'xdg-mime query default x-scheme-handler/sip' | grep -q com.softphonepro.softphonepro.desktop && res L1 "PASS xdg-mime sip handler" || res L1 FAIL
t0=$(date +%s); D 'softphonepro; echo done' >/dev/null; [ $(( $(date +%s) - t0 )) -le 3 ] && res L5 "PASS bare second launch exits fast" || res L5 FAIL
