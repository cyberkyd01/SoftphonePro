#!/usr/bin/env python3
"""v1.1.2: test sound, echo test (tone on the virtual mic -> speaker sink), auto-stop at 60 s, call preempts echo test, call audio after.
Drives the Audio test page by xdotool (window 1280x800 at 0,0). Output printed as JSON."""
import sys, json, shutil
import os as _os; REPO = _os.path.abspath(_os.path.join(_os.path.dirname(_os.path.abspath(__file__)), '..', '..', '..'))
sys.path.insert(0, REPO + '/tests/linux_e2e/audio')
from lib_qa import *
A = _os.environ.get('QA_A', 'qa112-a'); B = _os.environ.get('QA_B', 'qa112-b'); OUT = REPO + '/dist/qa112/'
R = {}
def cap(src='out.monitor', s=4): return json.loads(dx(A, f'python3 /e2e/cap.py {src} {s}'))
def sh(n): shutil.copy(shot(A, 'tmp_e.png'), OUT + n + '.png')
def so(): return dx(A, 'echo src=$(pactl list source-outputs | grep -c "Source Output") snk=$(pactl list sink-inputs | grep -c "Sink Input")')
dx(A, 'pkill paplay; sox -n -r 48000 -c 1 -b 16 /tmp/trem1k.wav synth 900 sine 1000 tremolo 2 90 vol 0.5; true')
W = '$(xdotool search --onlyvisible --name "^SoftphonePro$" | head -1)'
dx(A, f'W={W}; xdotool windowsize $W 1280 800; xdotool windowmove $W 0 0'); time.sleep(1)
api(A, 'POST', '/v1/ui/show', {"route": "/settings/audio"}); time.sleep(1.5)
dx(A, 'xdotool mousemove 800 210 click 1'); time.sleep(2.5)        # Audio test page
R['baseline_idle_sink_silence_no_feed'] = cap()

def hy():
    # "Hear yourself" switch (page scrolled to the bottom); a confirm dialog ("Use headphones") follows when switching on
    dx(A, 'xdotool mousemove 898 299 click 1'); time.sleep(0.8)
    px = dx(A, 'import -window root -crop 1x1+787+468 txt:- | tail -1')
    if '#3' in px.upper() or '#2' in px.upper() or 'srgb(5' in px:
        dx(A, 'xdotool mousemove 787 468 click 1'); time.sleep(0.5)
def bottom(): dx(A, 'xdotool mousemove 500 600; xdotool click --repeat 25 5'); time.sleep(1)
import threading
res = {}
t = threading.Thread(target=lambda: res.update(c=cap('out.monitor', 5))); t.start(); time.sleep(0.8)
dx(A, 'xdotool mousemove 127 608 click 1'); t.join(); R['test_sound'] = res['c']
sh('audiotest_after_test_sound'); time.sleep(2)
dx(A, 'pkill paplay; nohup paplay --device=micfeed /tmp/trem1k.wav >/dev/null 2>&1 &'); time.sleep(1)
bottom(); R['tone_on_mic_no_echo_test_sink'] = cap('out.monitor', 3)
hy(); time.sleep(2); sh('audiotest_echo_on')
R['echo_start_sink'] = cap('out.monitor', 4); R['echo_pulse_state'] = so()
hy(); time.sleep(1.5); R['after_stop_sink'] = cap('out.monitor', 3); sh('audiotest_echo_off'); R['stop_pulse_state'] = so()
# auto stop
hy(); t0 = time.time(); time.sleep(1.5)
R['echo2_running_sink'] = cap('out.monitor', 2)
stop_at = None
while time.time() - t0 < 100:
    c = cap('out.monitor', 1.5)
    if c.get('rms_dbfs', 0) < -70 and time.time() - t0 > 10: stop_at = round(time.time() - t0 - 1.5, 1); break
R['echo_autostop_after_s'] = stop_at; sh('audiotest_echo_autostopped'); R['autostop_pulse_state'] = so()
# call during echo test
hy(); time.sleep(2)
R['echo3_running_sink'] = cap('out.monitor', 2)
r = api(A, 'POST', '/v1/calls', {"to": "1002", "waitSeconds": 10}); ca = r.get('cid'); R['call_during_echo_state'] = r.get('call', {}).get('state')
wait(lambda: api(B, 'GET', '/v1/calls').get('calls'), 10); cb = api(B, 'GET', '/v1/calls')['calls'][0]['cid']; api(B, 'POST', f'/v1/calls/{cb}/answer')
wait(lambda: api(A, 'GET', f'/v1/calls/{ca}')['call']['state'] == 'active', 10); time.sleep(1)
R['sink_after_call_connected_1s'] = cap('out.monitor', 3)
api(A, 'POST', '/v1/ui/show', {"route": "/settings/audio"}); time.sleep(1); dx(A, 'xdotool mousemove 800 210 click 1'); time.sleep(2); bottom(); sh('audiotest_in_call_after_echo')
R['call_audio_note'] = 'A sends tremolo 1k on mic; B feed 880 started below'
dx(B, 'sox -n -r 48000 -c 1 -b 16 /tmp/trem880.wav synth 120 sine 880 tremolo 1.5 90 vol 0.5; nohup paplay --device=micfeed /tmp/trem880.wav >/dev/null 2>&1 &'); time.sleep(4)
R['sink_in_call_A_hears'] = cap('out.monitor', 4)
dx(A, 'pkill paplay'); api(A, 'POST', f'/v1/calls/{ca}/hangup'); dx(B, 'pkill paplay')
json.dump(R, open(HOSTDIR + '/out/echo_result.json', 'w'), indent=1); print(json.dumps(R, indent=1))
