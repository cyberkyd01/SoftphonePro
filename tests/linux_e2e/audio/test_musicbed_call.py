#!/usr/bin/env python3
"""B-section QA: musicbed reaches the far end. One long A->B call with phases, B and A auto-record (stereo WAV:
left = local side, right = remote side). Marks are aligned to the END of the recordings (hangup time).
Prereq: boot_pair.py done; A has musicbed file `tone440` chosen (ui_choose_musicbed.py). Prints a JSON result list.
"""
import sys, json, glob
import os as _os; REPO = _os.path.abspath(_os.path.join(_os.path.dirname(_os.path.abspath(__file__)), '..', '..', '..'))
sys.path.insert(0, REPO + '/tests/linux_e2e/audio')
from lib_qa import *
A, B = 'qa-audio-a', 'qa-audio-b'
R = []
def rec(i, check, ok, ev): R.append(dict(id=i, check=check, result='PASS' if ok else 'FAIL', evidence=ev)); print(R[-1], flush=True)
def cid_of(n): return api(n, 'GET', '/v1/calls')['calls'][0]['cid']
def lv(): return api(A, 'GET', '/v1/audio')
def lvB(): return api(B, 'GET', '/v1/audio')

# tone feeds (sox in each container)
dx(A, 'cd /tmp; sox -n -r 48000 -c 1 -b 16 tone1k.wav synth 90 sine 1000 vol 0.5')
dx(B, 'cd /tmp; sox -n -r 48000 -c 1 -b 16 tone880.wav synth 90 sine 880 vol 0.5')
api(A, 'POST', '/v1/audio', {"musicbedEnabled": True, "musicbedVolume": 1.0, "micLevel": 1.0, "musicbedPaused": False})
dx(A, 'rm -rf ~/Documents/Recordings/*'); dx(B, 'rm -rf ~/Documents/Recordings/*')

r = api(A, 'POST', '/v1/calls', {"to": "1002", "waitSeconds": 10}); ca = r['cid']
wait(lambda: api(B, 'GET', '/v1/calls').get('calls'), 10)
cb = cid_of(B); api(B, 'POST', f'/v1/calls/{cb}/answer')
wait(lambda: api(A, 'GET', f'/v1/calls/{ca}')['call']['state'] == 'active', 10)
t_conn = time.time()
print('call active; recording flags', api(A, 'GET', f'/v1/calls/{ca}')['call']['recording'], api(B, 'GET', f'/v1/calls/{cb}')['call']['recording'])
# feed tones continuously for the whole call
dx(A, 'nohup paplay --device=micfeed /tmp/tone1k.wav >/dev/null 2>&1 &')
dx(B, 'nohup paplay --device=micfeed /tmp/tone880.wav >/dev/null 2>&1 &')
marks = {}
def mark(k): marks[k] = time.time()
levels = {}

# P1: A muted, bed vol 1.0
api(A, 'POST', f'/v1/calls/{ca}/mute'); time.sleep(0.5)
time.sleep(20); mark('p1a'); time.sleep(8); levels['p1'] = lv()['levels']; mark('p1b')
# P2: vol 0.2
api(A, 'POST', '/v1/audio', {"musicbedVolume": 0.2}); time.sleep(1); mark('p2a'); time.sleep(7); levels['p2'] = lv()['levels']; mark('p2b')
# P3: hold from A, vol back to 1.0
api(A, 'POST', '/v1/audio', {"musicbedVolume": 1.0}); time.sleep(0.5)
api(A, 'POST', f'/v1/calls/{ca}/hold'); time.sleep(2); mark('p3a'); time.sleep(7); levels['p3'] = lv()['levels']; mark('p3b')
# P4: unhold
api(A, 'POST', f'/v1/calls/{ca}/unhold'); time.sleep(2); mark('p4a'); time.sleep(7); levels['p4'] = lv()['levels']; mark('p4b')
# P5: bed disabled
api(A, 'POST', '/v1/audio', {"musicbedEnabled": False}); time.sleep(1.5); mark('p5a'); time.sleep(6); levels['p5'] = lv()['levels']; mark('p5b')
# P6: bed on again + paused
api(A, 'POST', '/v1/audio', {"musicbedEnabled": True}); time.sleep(1)
api(A, 'POST', '/v1/audio', {"musicbedPaused": True}); time.sleep(1.5); mark('p6a'); time.sleep(5); levels['p6'] = lv()['levels']; lv6 = lv()['musicbed']; mark('p6b')
# P7: resume + unmute -> voice (1k) + bed (440)
api(A, 'POST', '/v1/audio', {"musicbedPaused": False}); api(A, 'POST', f'/v1/calls/{ca}/unmute'); time.sleep(2); mark('p7a'); time.sleep(8)
levels['p7'] = lv()['levels']; levels['p7B'] = lvB()['levels']; audio7 = lv(); mark('p7b')
api(A, 'POST', f'/v1/calls/{ca}/hangup'); t_end = time.time()
time.sleep(4)
dx(A, 'pkill paplay'); dx(B, 'pkill paplay')
print(json.dumps(levels), lv6)

def newest(n):
    return dx(n, 'ls -t ~/Documents/Recordings/*.wav | head -1')
wa, wb = newest(A), newest(B)
print('recordings', wa, wb)
dx(A, f'cp {wa} /e2e/out/rec_A_last.wav'); dx(B, f'cp {wb} /e2e/out/rec_B_last.wav')
def seg(n, wav, chan, k0, k1, freqs=(440, 880, 1000, 'peaks')):
    dur = json.loads(dx(n, f'python3 /e2e/tone.py {wav} -1 -1 -1 440'))['dur']
    off = dur - (t_end - marks[k0]); end = dur - (t_end - marks[k1])
    return tone_levels(n, wav, freqs, off + 0.7, end - 0.7, chan)
S = {}
for k in ['p1', 'p2', 'p3', 'p4', 'p5', 'p6', 'p7']:
    S[k] = seg(B, wb, 1, k + 'a', k + 'b')
    print('B right', k, S[k])
json.dump(dict(B_right=S, levels=levels, p6_musicbed=lv6, audio_p7=audio7, rec_a=wa, rec_b=wb), open(REPO + '/tests/linux_e2e/audio/out/call_result.json', 'w'), indent=1)
f = lambda k, hz: S[k].get(str(hz))
# A's own recording (left = local)
SA = {k: seg(A, wa, 0, k + 'a', k + 'b') for k in ['p1', 'p5', 'p6', 'p7']}
SAr = {k: seg(A, wa, 1, k + 'a', k + 'b') for k in ['p1', 'p7']}
print('A left', SA); print('A right', SAr)
json.dump(dict(A_left=SA, A_right=SAr, B_right=S), open(REPO + '/tests/linux_e2e/audio/out/call_result2.json', 'w'), indent=1)

# Evaluate
p1 = f('p1', 440); p2 = f('p2', 440)
rec('B1', 'bed 440 Hz audible at B while A mic muted', p1 is not None and p1 > -40, f'B right p1 440Hz={p1} dBFS, 1kHz={f("p1",1000)} (muted voice)')
ratio = p1 - p2 if p1 is not None and p2 is not None else None
rec('B2', 'live volume 1.0 -> 0.2 drops level ~14 dB', ratio is not None and 10 < ratio < 18, f'440Hz {p1} -> {p2} dBFS, drop {ratio} dB (ideal 13.98)')
rec('B3', 'bed not sent to held call (>=20 dB below unheld; Asterisk MOH may add music ~-34 dBFS near 430-450 Hz, see test_hold_repeat.py which shows the same with bed off)', f('p3', 440) is not None and f('p3', 440) < p1 - 20, f'p3 440Hz={f("p3",440)} peaks={S["p3"].get("peaks")} vs unheld {p1}')
rec('B4', '440 Hz back after unhold', f('p4', 440) is not None and f('p4', 440) > p1 - 6, f'p4 440Hz={f("p4",440)}')
rec('B5', 'no 440 Hz when musicbed disabled', f('p5', 440) < p1 - 40, f'p5 440Hz={f("p5",440)}')
rec('B6', 'paused bed: no 440 Hz at B', f('p6', 440) < p1 - 40, f'p6 440Hz={f("p6",440)}')
rec('B7', 'A unmuted with 1 kHz mic: B hears 1 kHz and 440 Hz', f('p7', 1000) > -50 and f('p7', 440) > p1 - 6, f'p7 1kHz={f("p7",1000)} 440Hz={f("p7",440)} 880(A hears B? n/a)')
rec('B8', 'mute really mutes 1 kHz voice (p1)', f('p1', 1000) < f('p7', 1000) - 30, f'p1 1kHz={f("p1",1000)} p7 1kHz={f("p7",1000)}')
rec('B9', "A's own recording has bed on local (left) side", SA['p1']['440'] > -40 and SA['p5']['440'] < -60, f'A left p1 440={SA["p1"]["440"]}, p5(off) 440={SA["p5"]["440"]}, p6(paused) 440={SA["p6"]["440"]}, p7 1k={SA["p7"]["1000"]}')
rec('B9b', "A's recording left has voice 1 kHz when unmuted only", SA['p7']['1000'] > -50 and SA['p1']['1000'] < -60, f'p7={SA["p7"]["1000"]} p1(muted)={SA["p1"]["1000"]}')
rec('B10', "A's recording right (remote=B) has B's 880 Hz tone", SAr['p1']['880'] > -50, f'{SAr["p1"]["880"]}')
rec('L1', 'levels.musicbed >0 while bed plays; 0 when off/paused', levels['p1']['musicbed'] > 0 and levels['p5']['musicbed'] == 0 and levels['p6']['musicbed'] == 0, json.dumps({k: v['musicbed'] for k, v in levels.items()}))
rec('L2', 'levels.mic >0 when unmuted and fed (and what it is when muted)', levels['p7']['mic'] > 0, f'mic levels per phase: {json.dumps({k: v["mic"] for k, v in levels.items()})}')
rec('L3', 'levels.speaker >0 when B sends audio', levels['p1']['speaker'] > 0, f'speaker levels per phase: {json.dumps({k: v["speaker"] for k, v in levels.items()})}')
env_out = dx(B, f'python3 /e2e/envelope.py {wb} 1 20')
print(env_out)
dips = json.loads(env_out.splitlines()[1].split('dips(-3dB):')[1].strip().replace('(', '[').replace(')', ']'))
early = [d for d in dips if d[0] < 25]
rec('B11', 'bed loops seamlessly (no >3 dB dip in 20 ms envelope over first ~27 s = 2+ loop seams of the 10 s file)', not early, f'dips before 25 s: {early}')
json.dump(R, open(REPO + '/tests/linux_e2e/audio/out/call_checks.json', 'w'), indent=1)
