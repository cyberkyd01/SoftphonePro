#!/usr/bin/env python3
"""Reset A to English/light via local --provision, re-import + choose tone440 through the UI (restores musicbed after E1), then
E2: import a text file renamed .mp3 through the UI and look for a rejection message (screenshots E2_*)."""
import sys, json, shutil
import os as _os; REPO = _os.path.abspath(_os.path.join(_os.path.dirname(_os.path.abspath(__file__)), '..', '..', '..'))
sys.path.insert(0, REPO + '/tests/linux_e2e/audio')
from lib_qa import *
import ui_choose_musicbed as ui
A = 'qa-audio-a'
OUT = REPO + '/docs/qa-screenshots/'
def grab(n): shutil.copy(shot(A, 'tmp.png'), OUT + f'v110_linux_audio_{n}.png')
pv = provision(A, '1001', 'pass1001', {"recordRule": "all", "autoRecord": True, "recordFormat": "wavStereo", "language": "en", "themeMode": "light"})
restart_app(A, pv); wait(lambda: registered(A), 30); time.sleep(3)
ui.run(A, '/home/qa/Music/tone440.mp3', 'tone440')
# pick the new item (last in list)
shot(A, 'tmp.png')
items = dx(A, 'ls ~/.local/share/softphonepro/audio/')
print(items)
dx(A, 'xdotool mousemove 1050 781 click 1'); time.sleep(1)
print(api(A, 'GET', '/v1/audio')['musicbed'])
# E2
dx(A, "printf 'this is not audio at all\\n' > /home/qa/Music/notaudio.mp3; ls -la /home/qa/Music")
api(A, 'POST', '/v1/ui/show', {"route": "/keypad"}); time.sleep(1)
api(A, 'POST', '/v1/ui/show', {"route": "/settings/audio"}); time.sleep(2)
dx(A, 'xdotool mousemove 800 830 click 1'); time.sleep(1.5)
dx(A, 'xdotool mousemove 400 271 click 1'); time.sleep(3)
dx(A, 'xdotool key ctrl+l; sleep .5; xdotool type --delay 30 "/home/qa/Music/notaudio.mp3"; sleep .7; xdotool key Return'); time.sleep(2)
if dx(A, 'pgrep zenity'): dx(A, 'xdotool key Return')
for i in range(4):
    time.sleep(0.8); grab(f'E2_invalid_mp3_{i}')
print(dx(A, 'ls ~/.local/share/softphonepro/audio/; cat ~/.local/share/softphonepro/audio/index.json'))
