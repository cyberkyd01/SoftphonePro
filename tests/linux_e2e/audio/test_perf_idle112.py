#!/usr/bin/env python3
"""v1.1.2 CPU: idle keypad desktop 1280x800 (meters live, silence and with tremolo tone on the mic), 20 s each; minimised; Settings>Audio page.
Needs QA_A container with the app running, window mapped."""
import sys, json
import os as _os; REPO = _os.path.abspath(_os.path.join(_os.path.dirname(_os.path.abspath(__file__)), '..', '..', '..'))
sys.path.insert(0, REPO + '/tests/linux_e2e/audio')
from lib_qa import *
A = _os.environ.get('QA_A', 'qa112-a')
def cpu(n, secs=20):
    code = ("import os,time\n"
            "pid=int(os.popen('pgrep -x softphonepro').read().split()[0])\n"
            "def t():\n  s=0\n  for d in os.listdir(f'/proc/{pid}/task'):\n    try:\n"
            "      p=open(f'/proc/{pid}/task/{d}/stat').read().rsplit(')',1)[1].split(); s+=int(p[11])+int(p[12])\n    except Exception: pass\n  return s\n"
            f"a=t();t0=time.time();time.sleep({secs});b=t();print(round((b-a)/os.sysconf('SC_CLK_TCK')/(time.time()-t0)*100,1))\n")
    return float(dx(n, "python3 - <<'PYEOF'\n" + code + "PYEOF"))
res = {}
dx(A, 'pkill paplay; sox -n -r 48000 -c 1 -b 16 /tmp/trem1k.wav synth 900 sine 1000 tremolo 2 90 vol 0.5; true')
for k in ('pgrep -a softphonepro | head -1',): print(dx(A, k))
W = '$(xdotool search --onlyvisible --name "^SoftphonePro$" | head -1)'   # the mapped toplevel (NOT the first --name hit, that minimises a hidden helper window)
dx(A, f'xdotool windowsize {W} 1280 800; xdotool windowmove {W} 0 0')
time.sleep(1); api(A, 'POST', '/v1/ui/show', {"route": "/keypad"}); time.sleep(8)
res['keypad_silent_20s'] = cpu(A); print(res, flush=True)
dx(A, 'nohup paplay --device=micfeed /tmp/trem1k.wav >/dev/null 2>&1 &'); time.sleep(5)
res['keypad_tone_20s'] = cpu(A); res['levels_tone'] = api(A, 'GET', '/v1/audio')['levels']; print(res, flush=True)
dx(A, 'pkill paplay'); time.sleep(3)
api(A, 'POST', '/v1/ui/show', {"route": "/recents"}); time.sleep(5); res['recents_20s'] = cpu(A); print(res, flush=True)
api(A, 'POST', '/v1/ui/show', {"route": "/keypad"}); time.sleep(3)
dx(A, f'echo {W} > /tmp/w; xdotool windowminimize {W}'); time.sleep(8); res['minimised_20s'] = cpu(A)
res['minimised_source_outputs'] = dx(A, 'pactl list source-outputs | grep -c "Source Output"'); print(res, flush=True)
dx(A, 'xdotool windowmap $(cat /tmp/w); xdotool windowactivate $(cat /tmp/w)'); time.sleep(3)
json.dump(res, open(HOSTDIR + '/out/perf_idle112.json', 'w'), indent=1)
