#!/usr/bin/env python3
"""C-section screenshots: keypad+mixer idle, in-call (3 shots 1 s apart, meters moving). Output: docs/qa-screenshots/v110_linux_audio_*.png"""
import sys, shutil
import os as _os; REPO = _os.path.abspath(_os.path.join(_os.path.dirname(_os.path.abspath(__file__)), '..', '..', '..'))
sys.path.insert(0, REPO + '/tests/linux_e2e/audio')
from lib_qa import *
A, B = 'qa-audio-a', 'qa-audio-b'
OUT = REPO + '/docs/qa-screenshots/'
def grab(name): shutil.copy(shot(A, 'tmp.png'), OUT + f'v110_linux_audio_{name}.png')
dx(A, 'cd /tmp; sox -n -r 48000 -c 1 -b 16 trem1k.wav synth 90 sine 1000 tremolo 2 90 vol 0.5')
dx(B, 'cd /tmp; sox -n -r 48000 -c 1 -b 16 trem880.wav synth 90 sine 880 tremolo 1.5 90 vol 0.5')
api(A, 'POST', '/v1/ui/show', {"route": "/keypad"}); time.sleep(2)
api(A, 'POST', '/v1/audio', {"musicbedEnabled": True, "musicbedVolume": 0.5, "musicbedMonitor": False}); time.sleep(1)
grab('01_keypad_desktop_idle')
r = api(A, 'POST', '/v1/calls', {"to": "1002", "waitSeconds": 10}); ca = r['cid']
wait(lambda: api(B, 'GET', '/v1/calls').get('calls'), 10); cb = api(B, 'GET', '/v1/calls')['calls'][0]['cid']; api(B, 'POST', f'/v1/calls/{cb}/answer'); time.sleep(3)
dx(A, 'nohup paplay --device=micfeed /tmp/trem1k.wav >/dev/null 2>&1 &'); dx(B, 'nohup paplay --device=micfeed /tmp/trem880.wav >/dev/null 2>&1 &')
time.sleep(2)
for i in range(3):
    grab(f'02_incall_desktop_{i+1}'); print(api(A, 'GET', '/v1/audio')['levels']); time.sleep(1)
print('call', ca)
