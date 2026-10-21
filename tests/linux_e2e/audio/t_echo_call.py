#!/usr/bin/env python3
"""Echo test on -> start call A->B -> far end (B's speaker sink) hears A's tone at the same level as in a control call (no echo test)."""
import sys, json
import os as _os; REPO = _os.path.abspath(_os.path.join(_os.path.dirname(_os.path.abspath(__file__)), '..', '..', '..'))
sys.path.insert(0, REPO + '/tests/linux_e2e/audio')
from lib_qa import *
A = _os.environ.get('QA_A', 'qa112-a'); B = _os.environ.get('QA_B', 'qa112-b')
def capB(s=4): return json.loads(dx(B, f'python3 /e2e/cap.py out.monitor {s}'))
def call():
    r = api(A, 'POST', '/v1/calls', {"to": "1002", "waitSeconds": 10}); ca = r['cid']
    wait(lambda: api(B, 'GET', '/v1/calls').get('calls'), 10); cb = api(B, 'GET', '/v1/calls')['calls'][0]['cid']; api(B, 'POST', f'/v1/calls/{cb}/answer')
    wait(lambda: api(A, 'GET', f'/v1/calls/{ca}')['call']['state'] == 'active', 10); time.sleep(3); return ca
R = {}
dx(A, 'pkill paplay; nohup paplay --device=micfeed /tmp/trem1k.wav >/dev/null 2>&1 &')
ca = call(); R['control_B_hears_A'] = {k: v for k, v in capB().items() if k in ('rms_dbfs', 'hz1000_db', 'peak_hz')}
api(A, 'POST', f'/v1/calls/{ca}/hangup'); time.sleep(2)
api(A, 'POST', '/v1/ui/show', {"route": "/settings/audio"}); time.sleep(1); dx(A, 'xdotool mousemove 800 210 click 1'); time.sleep(2)
dx(A, 'xdotool mousemove 500 600; xdotool click --repeat 25 5'); time.sleep(1)
dx(A, 'xdotool mousemove 898 299 click 1'); time.sleep(0.8); dx(A, 'xdotool mousemove 787 468 click 1'); time.sleep(2)
R['echo_on_sink'] = json.loads(dx(A, 'python3 /e2e/cap.py out.monitor 2')).get('hz1000_db')
ca = call(); R['after_echo_B_hears_A'] = {k: v for k, v in capB().items() if k in ('rms_dbfs', 'hz1000_db', 'peak_hz')}
R['A_sink_after_call_start_hz1000'] = json.loads(dx(A, 'python3 /e2e/cap.py out.monitor 2')).get('hz1000_db')
api(A, 'POST', f'/v1/calls/{ca}/hangup'); time.sleep(2)
# a second call after the first post-echo call
ca = call(); R['second_call_B_hears_A'] = {k: v for k, v in capB().items() if k in ('rms_dbfs', 'hz1000_db', 'peak_hz')}
api(A, 'POST', f'/v1/calls/{ca}/hangup'); dx(A, 'pkill paplay')
print(json.dumps(R, indent=1))
