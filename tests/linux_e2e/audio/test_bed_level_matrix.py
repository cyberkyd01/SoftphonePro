#!/usr/bin/env python3
"""Measures the 440 Hz bed level at B (right channel of B's recording) for combinations of device choice and voice feed.
Needs the app UI/API on A; devices are set via the persisted settings? (here: through the UI pickers is not scriptable, so this script only reads A's current devices.)
Usage: test_bed_level_matrix.py   (run once per device setting; prints a line per variant)"""
import sys, json
import os as _os; REPO = _os.path.abspath(_os.path.join(_os.path.dirname(_os.path.abspath(__file__)), '..', '..', '..'))
sys.path.insert(0, REPO + '/tests/linux_e2e/audio')
from lib_qa import *
A, B = 'qa-audio-a', 'qa-audio-b'
def one(feed, mic=1.0, bedvol=1.0):
    dx(B, 'rm -rf ~/Documents/Recordings/*')
    api(A, 'POST', '/v1/audio', {"micLevel": mic, "musicbedVolume": bedvol, "musicbedEnabled": True})
    r = api(A, 'POST', '/v1/calls', {"to": "1002", "waitSeconds": 10}); ca = r['cid']
    wait(lambda: api(B, 'GET', '/v1/calls').get('calls'), 10); cb = api(B, 'GET', '/v1/calls')['calls'][0]['cid']; api(B, 'POST', f'/v1/calls/{cb}/answer'); time.sleep(2)
    if feed: dx(A, f'nohup paplay --device=micfeed /tmp/{feed} >/dev/null 2>&1 &')
    time.sleep(9)
    lv = api(A, 'GET', '/v1/audio')
    api(A, 'POST', f'/v1/calls/{ca}/hangup'); dx(A, 'pkill paplay'); time.sleep(3)
    wb = dx(B, 'ls -t ~/Documents/Recordings/*.wav | head -1')
    out = json.loads(dx(B, f'python3 /e2e/tone.py {wb} 4 9 1 440 1000'))
    return dict(feed=feed, mic=mic, bedvol=bedvol, devices=lv['devices'], levels=lv['levels'], b440=out['440'], b1k=out['1000'], total=out['total'])
for feed in [None, 'tone1k.wav', 'trem1k.wav']:
    print(json.dumps(one(feed)), flush=True)
