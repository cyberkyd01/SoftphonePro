#!/usr/bin/env python3
"""A-section on Debian 12 (Raspberry Pi OS base): install already done by the image; boot 1003 (d1) and 1004 (d2), basic call, then musicbed
chosen through the UI on d1, enabled via API, B (d2) records and must hear 440 Hz; mute check too. Containers: qa-audio-d1 / qa-audio-d2."""
import sys, json, shutil
import os as _os; REPO = _os.path.abspath(_os.path.join(_os.path.dirname(_os.path.abspath(__file__)), '..', '..', '..'))
sys.path.insert(0, REPO + '/tests/linux_e2e/audio')
from lib_qa import *
import ui_choose_musicbed as ui
D1, D2 = 'qa-audio-d1', 'qa-audio-d2'
OUT = REPO + '/docs/qa-screenshots/'
R = []
def rec(i, check, ok, ev): R.append(dict(id=i, check=check, result='PASS' if ok else 'FAIL', evidence=ev)); print(R[-1], flush=True)
print(dx(D1, 'cat /etc/os-release | head -2; dpkg -l softphonepro | tail -1; uname -m'))
for n, u in ((D1, '1003'), (D2, '1004')):
    st = boot(n, provision(n, u, 'pass' + u, {"recordRule": "all", "autoRecord": True, "recordFormat": "wavStereo"}))
    print(n, st['version'], wait(lambda: registered(n), 30))
rec('A-deb-reg', 'debian:12 install, launch, API up, 1003+1004 registered', registered(D1) and registered(D2), f'{dx(D1, "grep PRETTY /etc/os-release")}; version reported {api(D1, "GET", "/v1/status")["version"]}')
r = api(D1, 'POST', '/v1/calls', {"to": "1004", "waitSeconds": 10}); c1 = r['cid']
wait(lambda: api(D2, 'GET', '/v1/calls').get('calls'), 10); c2 = api(D2, 'GET', '/v1/calls')['calls'][0]['cid']
ok_ring = api(D2, 'GET', f'/v1/calls/{c2}')['call']['state'] == 'ringing_in'
api(D2, 'POST', f'/v1/calls/{c2}/answer'); act = wait(lambda: api(D1, 'GET', f'/v1/calls/{c1}')['call']['state'] == 'active', 10)
time.sleep(2); api(D1, 'POST', f'/v1/calls/{c1}/hangup'); end = wait(lambda: api(D2, 'GET', f'/v1/calls/{c2}').get('call', {}).get('state') == 'ended' or 'error' in api(D2, 'GET', f'/v1/calls/{c2}'), 10)
rec('A-deb-call', 'debian: call 1003->1004 rings, B answers via API, active, hangup ends both', ok_ring and act and end, f'ringing_in={ok_ring} active={bool(act)} ended={bool(end)}')
# musicbed
dx(D1, 'mkdir -p ~/Music; cd ~/Music; sox -n -r 44100 -c 2 t.wav synth 10 sine 440 vol 0.5 && lame -q 5 --quiet t.wav tone440.mp3 && rm t.wav')
ui.run(D1, '/home/qa/Music/tone440.mp3', 'tone440', shots=lambda n: shutil.copy(shot(D1, 'tmp.png'), OUT + f'v110_linux_audio_deb12_{n}.png'))
dx(D1, 'xdotool mousemove 1050 781 click 1'); time.sleep(1)
m = api(D1, 'GET', '/v1/audio')['musicbed']; rec('B-deb-ui', 'debian: musicbed file chosen via UI (zenity)', m['file'] == 'tone440', json.dumps(m))
api(D1, 'POST', '/v1/audio', {"musicbedEnabled": True, "musicbedVolume": 1.0})
dx(D2, 'rm -rf ~/Documents/Recordings/*')
r = api(D1, 'POST', '/v1/calls', {"to": "1004", "waitSeconds": 10}); c1 = r['cid']
wait(lambda: api(D2, 'GET', '/v1/calls').get('calls'), 10); c2 = api(D2, 'GET', '/v1/calls')['calls'][0]['cid']; api(D2, 'POST', f'/v1/calls/{c2}/answer'); time.sleep(3)
api(D1, 'POST', f'/v1/calls/{c1}/mute'); time.sleep(7); lv = api(D1, 'GET', '/v1/audio')['levels']
api(D1, 'POST', '/v1/audio', {"musicbedVolume": 0.2}); time.sleep(8)
api(D1, 'POST', f'/v1/calls/{c1}/hangup'); time.sleep(3)
wb = dx(D2, 'ls -t ~/Documents/Recordings/*.wav | head -1')
dur = json.loads(dx(D2, f'python3 /e2e/tone.py {wb} -1 -1 1 440'))['dur']
a = json.loads(dx(D2, f'python3 /e2e/tone.py {wb} 4 9 1 440')); b = json.loads(dx(D2, f'python3 /e2e/tone.py {wb} {dur - 6} {dur - 0.8} 1 440'))
rec('B-deb-bed', 'debian: muted A, bed vol 1.0 audible at B, then 0.2 lower', a['440'] > -20 and a['440'] - b['440'] > 8, f'B right 440Hz: {a["440"]} dBFS (vol 1.0) -> {b["440"]} dBFS (vol 0.2); levels.musicbed={lv["musicbed"]}')
json.dump(R, open(REPO + '/tests/linux_e2e/audio/out/debian_checks.json', 'w'), indent=1)
