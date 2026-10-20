#!/usr/bin/env python3
"""B5 (monitor / "hear it myself") and B6 (persistence across restart). Prereq: boot_pair.py, tone440 chosen as A's musicbed."""
import sys, json
import os as _os; REPO = _os.path.abspath(_os.path.join(_os.path.dirname(_os.path.abspath(__file__)), '..', '..', '..'))
sys.path.insert(0, REPO + '/tests/linux_e2e/audio')
from lib_qa import *
A, B = 'qa-audio-a', 'qa-audio-b'
R = []
def rec(i, check, ok, ev): R.append(dict(id=i, check=check, result='PASS' if ok else 'FAIL', evidence=ev)); print(R[-1], flush=True)
def cap(n, dev, secs, f):
    dx(n, f'timeout {secs} parec -d {dev} --format=s16le --rate=48000 --channels=1 --file-format=wav {f}; true')
    r = json.loads(dx(n, f'python3 /e2e/tone.py {f} 0.5 -1 -1 440 880 peaks'))
    if 'err' in r:   # idle null sink delivers no samples at all = silence
        r.update({'440': -180.0, '880': -180.0, 'total': -180.0, 'note': 'no samples (sink idle)'})
    return r
api(A, 'POST', '/v1/audio', {"musicbedEnabled": True, "musicbedVolume": 1.0, "musicbedMonitor": False, "musicbedMonitorVolume": 0.5})
time.sleep(1)
off = cap(A, 'out.monitor', 4, '/tmp/mon_off.wav')
api(A, 'POST', '/v1/audio', {"musicbedMonitor": True, "musicbedMonitorVolume": 0.5}); time.sleep(1.5)
a = api(A, 'GET', '/v1/audio'); print(a['musicbed'], a['levels'])
on5 = cap(A, 'out.monitor', 4, '/tmp/mon_05.wav')
api(A, 'POST', '/v1/audio', {"musicbedMonitorVolume": 1.0}); time.sleep(1)
on10 = cap(A, 'out.monitor', 4, '/tmp/mon_10.wav')
rec('M1', 'monitor off, no call: nothing on A output sink', off['440'] < -60, f'out.monitor 440Hz={off["440"]} dBFS')
rec('M2', 'monitor on (no call, preview): bed on A output sink', on5['440'] > -35, f'monitorVolume 0.5: {on5["440"]} dBFS; levels.musicbed={a["levels"]["musicbed"]}')
rec('M3', 'monitor volume scales the monitor (0.5 -> 1.0 = +6 dB)', 4 < on10['440'] - on5['440'] < 8, f'{on5["440"]} -> {on10["440"]} dB')
# during a call: monitor on, check A's output sink and B still gets bed at constant level regardless of monitorVolume
dx(A, 'rm -rf ~/Documents/Recordings/*'); dx(B, 'rm -rf ~/Documents/Recordings/*')
dx(B, 'cd /tmp; sox -n -r 48000 -c 1 -b 16 tone880.wav synth 60 sine 880 vol 0.5')
r = api(A, 'POST', '/v1/calls', {"to": "1002", "waitSeconds": 10}); ca = r['cid']
wait(lambda: api(B, 'GET', '/v1/calls').get('calls'), 10); cb = api(B, 'GET', '/v1/calls')['calls'][0]['cid']; api(B, 'POST', f'/v1/calls/{cb}/answer'); time.sleep(3)
dx(B, 'nohup paplay --device=micfeed /tmp/tone880.wav >/dev/null 2>&1 &')
api(A, 'POST', '/v1/audio', {"musicbedMonitorVolume": 0.5}); time.sleep(2)
t0 = time.time(); c1 = cap(A, 'out.monitor', 5, '/tmp/mon_call.wav'); t1 = time.time()
api(A, 'POST', '/v1/audio', {"musicbedMonitorVolume": 1.0}); time.sleep(2)
c2 = cap(A, 'out.monitor', 5, '/tmp/mon_call2.wav'); t2 = time.time()
api(A, 'POST', f'/v1/calls/{ca}/hangup'); dx(B, 'pkill paplay'); time.sleep(3)
rec('M4', 'monitor in call: A output has bed (440) AND far end (880)', c1['440'] > -35 and c1['880'] > -45, f'440={c1["440"]} 880={c1["880"]}; mon vol 1.0: 440={c2["440"]} 880={c2["880"]}')
wb = dx(B, 'ls -t ~/Documents/Recordings/*.wav | head -1')
dx(B, f'cp {wb} /e2e/out/rec_B_monitor.wav')
dur = json.loads(dx(B, f'python3 /e2e/tone.py {wb} -1 -1 1 440'))['dur']
t_end = time.time() - 3 - 0.2   # approx hangup time
# window ends: hangup ~ (now-3s)
tend = time.time() - 3.3
def b_at(ts, te): return json.loads(dx(B, f'python3 /e2e/tone.py {wb} {dur - (tend - ts) + 0.5} {dur - (tend - te) - 0.5} 1 440'))['440']
b1, b2 = b_at(t0, t1), b_at(t1 + 2, t2)
rec('M5', 'far-end bed level independent of monitor volume (0.5 vs 1.0)', abs(b1 - b2) < 1.5, f'B right 440Hz at monitorVol 0.5 = {b1}, at 1.0 = {b2}')
api(A, 'POST', '/v1/audio', {"musicbedMonitor": False, "musicbedVolume": 0.7})
a = api(A, 'GET', '/v1/audio'); before = a['musicbed']; print('before restart', a)
# ---- persistence ----
restart_app(A, None)
wait(lambda: registered(A), 30)
after = api(A, 'GET', '/v1/audio'); print('after restart', after)
ok = after['musicbed']['enabled'] and after['musicbed']['file'] == 'tone440' and abs(after['musicbed']['volume'] - 0.7) < 1e-6
rec('P1', 'musicbed enabled/file/volume persist across restart', ok, json.dumps(after['musicbed']))
dx(B, 'rm -rf ~/Documents/Recordings/*')
r = api(A, 'POST', '/v1/calls', {"to": "1002", "waitSeconds": 10}); ca = r['cid']
wait(lambda: api(B, 'GET', '/v1/calls').get('calls'), 10); cb = api(B, 'GET', '/v1/calls')['calls'][0]['cid']; api(B, 'POST', f'/v1/calls/{cb}/answer'); time.sleep(8)
lvl = api(A, 'GET', '/v1/audio')
api(A, 'POST', f'/v1/calls/{ca}/hangup'); time.sleep(3)
wb = dx(B, 'ls -t ~/Documents/Recordings/*.wav | head -1')
lvB = json.loads(dx(B, f'python3 /e2e/tone.py {wb} 2 -1 1 440'))
rec('P2', 'after restart the bed plays on the next call (no manual re-enable)', lvB['440'] > -25 and lvl['musicbed']['active'], f'B right 440Hz={lvB["440"]} dBFS (vol 0.7 => ~-13); levels.musicbed={lvl["levels"]["musicbed"]} active={lvl["musicbed"]["active"]}')
json.dump(R, open(REPO + '/tests/linux_e2e/audio/out/monitor_persist_checks.json', 'w'), indent=1)
