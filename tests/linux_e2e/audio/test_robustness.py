#!/usr/bin/env python3
"""E-section. E1: musicbed enabled, file removed from the audio library while the app is closed, restart -> notice + setting off.
E2: import a text file renamed .mp3 through the UI (zenity) -> rejected with a message. Screenshots -> docs/qa-screenshots/v110_linux_audio_E*.png"""
import sys, json, shutil, os
import os as _os; REPO = _os.path.abspath(_os.path.join(_os.path.dirname(_os.path.abspath(__file__)), '..', '..', '..'))
sys.path.insert(0, REPO + '/tests/linux_e2e/audio')
from lib_qa import *
A = 'qa-audio-a'
OUT = REPO + '/docs/qa-screenshots/'
R = []
def rec(i, check, ok, ev): R.append(dict(id=i, check=check, result='PASS' if ok else 'FAIL', evidence=ev)); print(R[-1], flush=True)
def grab(n): shutil.copy(shot(A, 'tmp.png'), OUT + f'v110_linux_audio_{n}.png')
W = '$(xdotool search --onlyvisible --name "^SoftphonePro$" | head -1)'
print(dx(A, 'ls -la ~/.local/share/softphonepro/audio/'))
api(A, 'POST', '/v1/audio', {"musicbedEnabled": True}); time.sleep(1)
print(api(A, 'GET', '/v1/audio')['musicbed'])
kill_app(A)
print(dx(A, 'rm -v ~/.local/share/softphonepro/audio/*tone440* ; ls ~/.local/share/softphonepro/audio/'))
dx(A, '/e2e/app_start.sh "" /e2e/out/qa-audio-a C.UTF-8')
t0 = time.time(); seen = []
while time.time() - t0 < 60:
    if api(A, 'GET', '/v1/status').get('app'): break
    time.sleep(0.5)
print('api up after', round(time.time() - t0, 1))
for i in range(10):
    shot(A, 'tmp.png'); shutil.copy(OUT[:-1] + '/../../tests/linux_e2e/audio/out/tmp.png', f'/tmp/e1_{i}.png') if False else None
    m = api(A, 'GET', '/v1/audio')['musicbed']; seen.append((round(time.time() - t0, 1), m['enabled'], m['file'], m['active']))
    if i in (1, 3, 6): grab(f'E1_restart_missing_file_{i}')
    time.sleep(1)
print(seen)
m = api(A, 'GET', '/v1/audio')['musicbed']
rec('E1', 'file removed + restart: musicbed turns itself off', not m['enabled'], json.dumps(m))
print(dx(A, 'tail -5 /e2e/out/qa-audio-a/app.out'))
json.dump(R, open(REPO + '/tests/linux_e2e/audio/out/robust_e1.json', 'w'), indent=1)
