#!/usr/bin/env python3
"""final2: restart A with musicbed file, in a call: thread names, phone-fit screenshots at 400x820 and 360x740 (musicbed on, strip collapsed)."""
import sys, shutil
import os as _os; REPO = _os.path.abspath(_os.path.join(_os.path.dirname(_os.path.abspath(__file__)), '..', '..', '..'))
sys.path.insert(0, REPO + '/tests/linux_e2e/audio')
from lib_qa import *
A, B = 'qa-audio-a', 'qa-audio-b'
OUT = REPO + '/docs/qa-screenshots/'
W = '$(xdotool search --onlyvisible --name "^SoftphonePro$" | head -1)'
def size(w, h): dx(A, f'W={W}; xdotool windowsize $W {w} {h}; xdotool windowmove $W 0 0'); time.sleep(2)
def grab(name): shutil.copy(shot(A, 'tmp.png'), OUT + f'v110_linux_final2_{name}.png')
print(api(A, 'GET', '/v1/audio')['musicbed'])
r = api(A, 'POST', '/v1/calls', {"to": "1002", "waitSeconds": 10}); ca = r['cid']
wait(lambda: api(B, 'GET', '/v1/calls').get('calls'), 10); cb = api(B, 'GET', '/v1/calls')['calls'][0]['cid']; api(B, 'POST', f'/v1/calls/{cb}/answer'); time.sleep(3)
dx(A, 'nohup paplay --device=micfeed /tmp/trem1k.wav >/dev/null 2>&1 &')
print(dx(A, 'pid=$(pgrep -x softphonepro|head -1); for t in /proc/$pid/task/*/comm; do cat $t; done | sort | uniq -c'))
for w, h in [(400, 820), (360, 740)]:
    size(w, h); api(A, 'POST', '/v1/ui/show', {"route": "/keypad"}); time.sleep(1); dx(A, f'xdotool mousemove {w//2} {h-69} click 1'); time.sleep(2); grab(f'phone_{w}x{h}_incall')
print(api(A, 'GET', '/v1/audio')['levels'])
api(A, 'POST', f'/v1/calls/{ca}/hangup'); dx(A, 'pkill paplay'); size(1280, 800)
