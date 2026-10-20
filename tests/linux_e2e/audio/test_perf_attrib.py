#!/usr/bin/env python3
"""D-section attribution: in-call CPU of the UI with static (all-zero) meters vs animating meters, desktop 1200x780, keypad page.
Scenarios: (1) call, no feeds, bed off (meters flat at 0); (2) + bed on (musicbed meter steady); (3) + 1 kHz tremolo mic feed (mic meter moving)."""
import sys, json, re
import os as _os; REPO = _os.path.abspath(_os.path.join(_os.path.dirname(_os.path.abspath(__file__)), '..', '..', '..'))
sys.path.insert(0, REPO + '/tests/linux_e2e/audio')
src = open(REPO + '/tests/linux_e2e/audio/test_perf.py').read()
from lib_qa import *
exec(src[src.index('def cpu'):src.index('res = {}')])
A, B = 'qa-audio-a', 'qa-audio-b'
res = {}
W = '$(xdotool search --onlyvisible --name "^SoftphonePro$" | head -1)'
dx(A, f'W={W}; xdotool windowsize $W 1200 780; xdotool windowmove $W 20 10'); time.sleep(2)
api(A, 'POST', '/v1/audio', {"musicbedEnabled": False}); api(A, 'POST', '/v1/ui/show', {"route": "/keypad"}); time.sleep(2)
r = api(A, 'POST', '/v1/calls', {"to": "1002", "waitSeconds": 10}); ca = r['cid']
wait(lambda: api(B, 'GET', '/v1/calls').get('calls'), 10); cb = api(B, 'GET', '/v1/calls')['calls'][0]['cid']; api(B, 'POST', f'/v1/calls/{cb}/answer'); time.sleep(4)
res['in_call_static_meters (no bed, no feeds)'] = cpu(A); res['levels1'] = api(A, 'GET', '/v1/audio')['levels']
api(A, 'POST', '/v1/audio', {"musicbedEnabled": True}); time.sleep(2)
res['in_call_bed_only (musicbed meter steady)'] = cpu(A); res['levels2'] = api(A, 'GET', '/v1/audio')['levels']
dx(A, 'nohup paplay --device=micfeed /tmp/trem1k.wav >/dev/null 2>&1 &'); dx(B, 'nohup paplay --device=micfeed /tmp/trem880.wav >/dev/null 2>&1 &'); time.sleep(3)
res['in_call_bed_plus_moving_mic_and_speaker'] = cpu(A)
dx(A, f'W={W}; xdotool windowminimize $W'); time.sleep(2); res['in_call_minimised'] = cpu(A)
dx(A, 'W=$(xdotool search --name "^SoftphonePro$" | head -1); xdotool windowmap $W; true')
api(A, 'POST', f'/v1/calls/{ca}/hangup'); dx(A, 'pkill paplay'); dx(B, 'pkill paplay')
print(json.dumps(res, indent=1)); json.dump(res, open(REPO + '/tests/linux_e2e/audio/out/perf_attrib.json', 'w'), indent=1)
