#!/usr/bin/env python3
"""Bug repro: image without xdg-user-dirs (spc-qa-audio-noxdg:arm64, container qa-audio-x on 172.30.0.25, account 1005) -> auto-record and
manual Record fail with an unhandled MissingPlatformDirectoryException. Callee = B (qa-audio-b, 1002). Screenshots: *_noxdg_*.png"""
import sys, json, shutil
import os as _os; REPO = _os.path.abspath(_os.path.join(_os.path.dirname(_os.path.abspath(__file__)), '..', '..', '..'))
sys.path.insert(0, REPO + '/tests/linux_e2e/audio')
from lib_qa import *
X, B = 'qa-audio-x', 'qa-audio-b'
OUT = REPO + '/docs/qa-screenshots/'
print(dx(X, 'which xdg-user-dir; ls ~; echo ---'))
st = boot(X, provision(X, '1005', 'pass1005', {"recordRule": "all", "autoRecord": True}))
wait(lambda: registered(X), 30); time.sleep(3)
r = api(X, 'POST', '/v1/calls', {"to": "1002", "waitSeconds": 10}); c1 = r['cid']
wait(lambda: api(B, 'GET', '/v1/calls').get('calls'), 10); c2 = api(B, 'GET', '/v1/calls')['calls'][0]['cid']; api(B, 'POST', f'/v1/calls/{c2}/answer'); time.sleep(4)
print('auto-record flag:', api(X, 'GET', f'/v1/calls/{c1}')['call']['recording'])
api(X, 'POST', '/v1/ui/show', {"route": "/keypad"}); time.sleep(2)
dx(X, 'xdotool mousemove 1139 324 click 1'); time.sleep(1.5)
shutil.copy(shot(X, 'tmp.png'), OUT + 'v110_linux_audio_noxdg_manual_record_click.png')
print('after manual Record click, recording flag:', api(X, 'GET', f'/v1/calls/{c1}')['call']['recording'])
api(X, 'POST', f'/v1/calls/{c1}/hangup')
print(dx(X, 'grep -h -A3 "Unhandled" /e2e/out/qa-audio-x/app.err | cut -c1-200 | head -12'))
