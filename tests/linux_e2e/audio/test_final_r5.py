#!/usr/bin/env python3
"""Final retest R5: manual Record button on a system whose ~/Documents does not exist (container qa-audio-x, acct 1005; optional arg 'nobin' means xdg-user-dirs was removed by the caller)."""
import sys, json, shutil
import os as _os; REPO = _os.path.abspath(_os.path.join(_os.path.dirname(_os.path.abspath(__file__)), '..', '..', '..'))
sys.path.insert(0, REPO + '/tests/linux_e2e/audio')
from lib_qa import *
X, B = 'qa-audio-x', 'qa-audio-b'
tag = sys.argv[1] if len(sys.argv) > 1 else 'nodocs'
OUT = REPO + '/docs/qa-screenshots/v110_linux_final_'
print(dx(X, 'which xdg-user-dir; ls -a ~ | tr "\n" " "; echo; xdg-user-dir DOCUMENTS'))
dx(X, 'rm -f /e2e/out/qa-audio-x/app.err; true')
st = boot(X, provision(X, '1005', 'pass1005', {"recordRule": "manual", "autoRecord": False}))
wait(lambda: registered(X), 30); time.sleep(3)
W = '$(xdotool search --onlyvisible --name "^SoftphonePro$" | head -1)'
dx(X, f'W={W}; xdotool windowsize $W 1280 800; xdotool windowmove $W 0 0'); time.sleep(2)
api(X, 'POST', '/v1/ui/show', {"route": "/keypad"})
r = api(X, 'POST', '/v1/calls', {"to": "1002", "waitSeconds": 10}); c1 = r['cid']
wait(lambda: api(B, 'GET', '/v1/calls').get('calls'), 10); c2 = api(B, 'GET', '/v1/calls')['calls'][0]['cid']; api(B, 'POST', f'/v1/calls/{c2}/answer'); time.sleep(4)
print('before click recording flag:', api(X, 'GET', f'/v1/calls/{c1}')['call']['recording'])
shutil.copy(shot(X, 'tmp.png'), OUT + f'r5_{tag}_before.png')
dx(X, 'xdotool mousemove 1179 264 click 1'); time.sleep(3)
print('after 1st click recording flag:', api(X, 'GET', f'/v1/calls/{c1}')['call']['recording'])
shutil.copy(shot(X, 'tmp.png'), OUT + f'r5_{tag}_recording.png')
dx(X, 'xdotool mousemove 1179 264 click 1'); time.sleep(2)
print('after 2nd click (stop) flag:', api(X, 'GET', f'/v1/calls/{c1}')['call']['recording'])
shutil.copy(shot(X, 'tmp.png'), OUT + f'r5_{tag}_stopped.png')
api(X, 'POST', f'/v1/calls/{c1}/hangup'); time.sleep(2)
print(dx(X, 'find ~ -name "*.wav" -newer /etc/hostname -path "*ecord*" -exec ls -l {} \; ; find ~ -iname "rec_*" | head'))
print('stderr:', dx(X, 'grep -c -i "unhandled\\|exception" /e2e/out/qa-audio-x/app.err; grep -i -B1 -A4 "unhandled\\|exception" /e2e/out/qa-audio-x/app.err | cut -c1-220 | head -20'))
