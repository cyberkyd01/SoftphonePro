#!/usr/bin/env python3
"""v1.1.2 idle live meters + mic-open-at-idle. Usage: QA_A=container t_idle.py"""
import sys, json, shutil
import os as _os; REPO = _os.path.abspath(_os.path.join(_os.path.dirname(_os.path.abspath(__file__)), '..', '..', '..'))
sys.path.insert(0, REPO + '/tests/linux_e2e/audio')
from lib_qa import *
A = _os.environ.get('QA_A', 'qa112-a'); OUT = REPO + '/dist/qa112/'
W = '$(xdotool search --onlyvisible --name "^SoftphonePro$" | head -1)'
res = {}
def srcout(): return dx(A, 'pactl list source-outputs | grep -E "Source Output|application.name|Source:|Corked|media.name" ; echo ---; pactl list sources short')
dx(A, 'sox -n -r 48000 -c 1 -b 16 /tmp/trem1k.wav synth 600 sine 1000 tremolo 2 90 vol 0.5; true')
dx(A, f'W={W}; xdotool windowsize $W 1280 800; xdotool windowmove $W 0 0'); time.sleep(1.5)
api(A, 'POST', '/v1/ui/show', {"route": "/keypad"}); time.sleep(3)
res['idle_no_tone_levels'] = api(A, 'GET', '/v1/audio')['levels']
res['source_outputs_idle_visible'] = srcout()
dx(A, 'nohup paplay --device=micfeed /tmp/trem1k.wav >/dev/null 2>&1 &'); time.sleep(2)
l = []
for i in range(8): l.append(api(A, 'GET', '/v1/audio')['levels']['mic']); time.sleep(0.25)
res['mic_levels_with_tone'] = l
shutil.copy(shot(A, 'tmp_i.png'), OUT + 'idle_meter_1.png'); time.sleep(0.7); shutil.copy(shot(A, 'tmp_i.png'), OUT + 'idle_meter_2.png')
print(json.dumps(res, indent=1))
