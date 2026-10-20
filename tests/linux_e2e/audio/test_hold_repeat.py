#!/usr/bin/env python3
"""Repeat the hold check N times, with the bed enabled (vol 1.0) and disabled, to see whether any 440 Hz leaks to B during hold.
Prints the 440 Hz level and the top spectral peaks of B's right channel during hold (2.5 s after hold, 4 s window)."""
import sys, json
import os as _os; REPO = _os.path.abspath(_os.path.join(_os.path.dirname(_os.path.abspath(__file__)), '..', '..', '..'))
sys.path.insert(0, REPO + '/tests/linux_e2e/audio')
from lib_qa import *
A, B = 'qa-audio-a', 'qa-audio-b'
def one(bed):
    dx(B, 'rm -rf ~/Documents/Recordings/*')
    api(A, 'POST', '/v1/audio', {"musicbedEnabled": bed, "musicbedVolume": 1.0, "musicbedPaused": False}); time.sleep(1)
    r = api(A, 'POST', '/v1/calls', {"to": "1002", "waitSeconds": 10}); ca = r['cid']
    wait(lambda: api(B, 'GET', '/v1/calls').get('calls'), 10); cb = api(B, 'GET', '/v1/calls')['calls'][0]['cid']; api(B, 'POST', f'/v1/calls/{cb}/answer'); time.sleep(4)
    api(A, 'POST', f'/v1/calls/{ca}/hold'); th = time.time(); time.sleep(9)
    api(A, 'POST', f'/v1/calls/{ca}/unhold'); tu = time.time(); time.sleep(3)
    api(A, 'POST', f'/v1/calls/{ca}/hangup'); te = time.time(); time.sleep(3)
    wb = dx(B, 'ls -t ~/Documents/Recordings/*.wav | head -1')
    dur = json.loads(dx(B, f'python3 /e2e/tone.py {wb} -1 -1 1 440'))['dur']
    a, b = dur - (te - th) + 2.5, dur - (te - tu) - 0.5
    return json.loads(dx(B, f'python3 /e2e/tone.py {wb} {a} {b} 1 440 peaks'))
for bed in (False, False, False, True):
    r = one(bed); print('bed', bed, '440Hz', r['440'], 'total', r['total'], 'peaks', r.get('peaks'), flush=True)
api(A, 'POST', '/v1/audio', {"musicbedEnabled": False})
