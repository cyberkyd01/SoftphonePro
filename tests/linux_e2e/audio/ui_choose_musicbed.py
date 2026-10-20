#!/usr/bin/env python3
"""Choose a musicbed file through the real UI (as a user): Settings > Audio > Audio files > Import a WAV or MP3... (zenity file chooser,
path typed with ctrl+L, Enter) then Settings > Audio > Musicbed > Music file dropdown. Coordinates assume the window at 1200x780 (default size).
Usage: ui_choose_musicbed.py <container> <abs path of mp3 inside the container> <display name (file stem)>"""
import sys
import os as _os; REPO = _os.path.abspath(_os.path.join(_os.path.dirname(_os.path.abspath(__file__)), '..', '..', '..'))
sys.path.insert(0, REPO + '/tests/linux_e2e/audio')
from lib_qa import *
def run(A, path, stem, shots=None):
    W = '$(xdotool search --onlyvisible --name "^SoftphonePro$" | head -1)'
    dx(A, f'W={W}; xdotool windowsize $W 1200 780; xdotool windowmove $W 40 60'); time.sleep(1.5)
    api(A, 'POST', '/v1/ui/show', {"route": "/keypad"}); time.sleep(1)
    api(A, 'POST', '/v1/ui/show', {"route": "/settings/audio"}); time.sleep(2)
    dx(A, 'xdotool mousemove 800 830 click 1'); time.sleep(1.5)            # Audio files
    dx(A, 'xdotool mousemove 400 271 click 1'); time.sleep(3)              # Import a WAV or MP3...
    dx(A, f'xdotool key ctrl+l; sleep .5; xdotool type --delay 30 "{path}"; sleep .7; xdotool key Return'); time.sleep(2)
    if dx(A, 'pgrep zenity'): dx(A, 'xdotool key Return'); time.sleep(3)    # first Enter only navigated/selected
    if shots: shots('import_done')
    dx(A, 'xdotool mousemove 270 171 click 1'); time.sleep(1.5)            # back
    dx(A, 'xdotool mousemove 1100 607 click 1'); time.sleep(1.2)           # Music file dropdown
    if shots: shots('dropdown')
if __name__ == '__main__':
    A, path, stem = sys.argv[1:4]
    run(A, path, stem)
    print('manual pick of the item follows in the caller; musicbed =', api(A, 'GET', '/v1/audio')['musicbed'])
