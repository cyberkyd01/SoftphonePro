#!/usr/bin/env python3
"""D-section: CPU of the softphonepro process (all threads, % of one core) over 20 s in several UI states.
States: keypad+mixer idle (no call) | Recents page idle (baseline, no mixer) | keypad+mixer in call (meters animating, A+B tone feeds + bed) | phone width in call.
Prereq: boot_pair.py + musicbed chosen. Window is set to 1200x780 for desktop states."""
import sys, json
import os as _os; REPO = _os.path.abspath(_os.path.join(_os.path.dirname(_os.path.abspath(__file__)), '..', '..', '..'))
sys.path.insert(0, REPO + '/tests/linux_e2e/audio')
from lib_qa import *
A, B = 'qa-audio-a', 'qa-audio-b'
def cpu(n, secs=20):
    code = ("import os,time\n"
            "pid=int(os.popen('pgrep -xo softphonepro').read().split()[0]) if False else int(os.popen('pgrep -x softphonepro').read().split()[0])\n"
            "def t():\n"
            "  s=0\n"
            "  for d in os.listdir(f'/proc/{pid}/task'):\n"
            "    try:\n"
            "      p=open(f'/proc/{pid}/task/{d}/stat').read().rsplit(')',1)[1].split(); s+=int(p[11])+int(p[12])\n"
            "    except Exception: pass\n"
            "  return s\n"
            f"a=t();t0=time.time();time.sleep({secs});b=t();print(round((b-a)/os.sysconf('SC_CLK_TCK')/(time.time()-t0)*100,1))\n")
    return float(dx(n, "python3 - <<'PYEOF'\n" + code + "PYEOF"))
res = {}
W = '$(xdotool search --onlyvisible --name "^SoftphonePro$" | head -1)'
def size(w, h): dx(A, f'W={W}; xdotool windowsize $W {w} {h}; xdotool windowmove $W 20 10'); time.sleep(2)
api(A, 'POST', '/v1/audio', {"musicbedEnabled": True, "musicbedVolume": 0.5})
size(1200, 780)
api(A, 'POST', '/v1/ui/show', {"route": "/recents"}); time.sleep(3); res['desktop_recents_idle_nocall (baseline, no mixer)'] = cpu(A)
api(A, 'POST', '/v1/ui/show', {"route": "/keypad"}); time.sleep(3); res['desktop_keypad_mixer_idle_nocall'] = cpu(A)
dx(A, 'sox -n -r 48000 -c 1 -b 16 /tmp/trem1k.wav synth 120 sine 1000 tremolo 2 90 vol 0.5; true'); dx(B, 'sox -n -r 48000 -c 1 -b 16 /tmp/trem880.wav synth 120 sine 880 tremolo 1.5 90 vol 0.5; true')
r = api(A, 'POST', '/v1/calls', {"to": "1002", "waitSeconds": 10}); ca = r['cid']
wait(lambda: api(B, 'GET', '/v1/calls').get('calls'), 10); cb = api(B, 'GET', '/v1/calls')['calls'][0]['cid']; api(B, 'POST', f'/v1/calls/{cb}/answer'); time.sleep(3)
dx(A, 'nohup paplay --device=micfeed /tmp/trem1k.wav >/dev/null 2>&1 &'); dx(B, 'nohup paplay --device=micfeed /tmp/trem880.wav >/dev/null 2>&1 &'); time.sleep(3)
res['desktop_keypad_mixer_in_call_meters_animating'] = cpu(A)
api(A, 'POST', '/v1/ui/show', {"route": "/recents"}); time.sleep(3)
res['desktop_recents_in_call_no_mixer_visible'] = cpu(A)
api(A, 'POST', '/v1/ui/show', {"route": "/keypad"}); size(400, 820); time.sleep(2)
res['phone_width_in_call_strip_collapsed_meters_animating'] = cpu(A)
size(1200, 780); api(A, 'POST', '/v1/ui/show', {"route": "/keypad"}); time.sleep(2)
api(A, 'POST', '/v1/audio', {"musicbedEnabled": False}); time.sleep(1)
res['desktop_keypad_mixer_in_call_bed_off (mic+speaker meters only)'] = cpu(A)
api(A, 'POST', '/v1/audio', {"musicbedEnabled": True}); time.sleep(1)
dx(A, f'W={W}; xdotool windowminimize $W'); time.sleep(2)
res['in_call_window_minimised (engine mostly)'] = cpu(A)
dx(A, f'W=$(xdotool search --name "^SoftphonePro$" | head -1); xdotool windowmap $W; xdotool windowactivate $W; true'); time.sleep(2)
api(A, 'POST', f'/v1/calls/{ca}/hangup'); dx(A, 'pkill paplay'); dx(B, 'pkill paplay'); time.sleep(3)
res['phone_width_idle_strip_collapsed_no_call'] = cpu(A)
size(1200, 780)
print(json.dumps(res, indent=1)); json.dump(res, open(REPO + '/tests/linux_e2e/audio/out/perf.json', 'w'), indent=1)
