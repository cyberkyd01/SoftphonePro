#!/usr/bin/env python3
"""Final retest R1: CPU in a call with meters animating, desktop keypad 1280x800 and phone width 400x820 (10 s warm-up, 20 s sample),
plus two screenshots 1 s apart per state. Output out/perf_112_call.json and docs/qa-screenshots/v112_linux_*.png"""
import sys, json, shutil
import os as _os; REPO = _os.path.abspath(_os.path.join(_os.path.dirname(_os.path.abspath(__file__)), '..', '..', '..'))
sys.path.insert(0, REPO + '/tests/linux_e2e/audio')
from lib_qa import *
A, B = _os.environ.get('QA_A','qa-audio-a'), _os.environ.get('QA_B','qa-audio-b')
OUT = REPO + '/dist/qa112/'
def cpu(n, secs=20):
    code = ("import os,time\n"
            "pid=int(os.popen('pgrep -x softphonepro').read().split()[0])\n"
            "def t():\n  s=0\n  for d in os.listdir(f'/proc/{pid}/task'):\n    try:\n"
            "      p=open(f'/proc/{pid}/task/{d}/stat').read().rsplit(')',1)[1].split(); s+=int(p[11])+int(p[12])\n    except Exception: pass\n  return s\n"
            f"a=t();t0=time.time();time.sleep({secs});b=t();print(round((b-a)/os.sysconf('SC_CLK_TCK')/(time.time()-t0)*100,1))\n")
    return float(dx(n, "python3 - <<'PYEOF'\n" + code + "PYEOF"))
W = '$(xdotool search --onlyvisible --name "^SoftphonePro$" | head -1)'
def size(w, h): dx(A, f'W={W}; xdotool windowsize $W {w} {h}; xdotool windowmove $W 0 0'); time.sleep(2)
def grab(name): shutil.copy(shot(A, 'tmp.png'), OUT + f'v112_linux_{name}.png')
res = {}
api(A, 'POST', '/v1/audio', {"musicbedEnabled": True, "musicbedVolume": 0.5, "musicbedMonitor": False, "musicbedPaused": False})
dx(A, 'sox -n -r 48000 -c 1 -b 16 /tmp/trem1k.wav synth 150 sine 1000 tremolo 2 90 vol 0.5; true'); dx(B, 'sox -n -r 48000 -c 1 -b 16 /tmp/trem880.wav synth 150 sine 880 tremolo 1.5 90 vol 0.5; true')
size(1280, 800); api(A, 'POST', '/v1/ui/show', {"route": "/keypad"})
r = api(A, 'POST', '/v1/calls', {"to": "1002", "waitSeconds": 10}); ca = r['cid']
wait(lambda: api(B, 'GET', '/v1/calls').get('calls'), 10); cb = api(B, 'GET', '/v1/calls')['calls'][0]['cid']; api(B, 'POST', f'/v1/calls/{cb}/answer'); time.sleep(3)
dx(A, 'nohup paplay --device=micfeed /tmp/trem1k.wav >/dev/null 2>&1 &'); dx(B, 'nohup paplay --device=micfeed /tmp/trem880.wav >/dev/null 2>&1 &')
def phase(tag):
    time.sleep(10)
    grab(f'{tag}_meters_1'); lv1 = api(A, 'GET', '/v1/audio')['levels']; time.sleep(1); grab(f'{tag}_meters_2'); lv2 = api(A, 'GET', '/v1/audio')['levels']
    c = cpu(A); res[tag] = dict(cpu_pct=c, levels_t1=lv1, levels_t2=lv2); print(tag, res[tag], flush=True)
phase('desktop_1280x800')
size(400, 820); api(A, 'POST', '/v1/ui/show', {"route": "/keypad"})
phase('phone_400x820')
size(1280, 800)
api(A, 'POST', f'/v1/calls/{ca}/hangup'); dx(A, 'pkill paplay'); dx(B, 'pkill paplay')
json.dump(res, open(HOSTDIR + '/out/perf_112_call.json', 'w'), indent=1)
