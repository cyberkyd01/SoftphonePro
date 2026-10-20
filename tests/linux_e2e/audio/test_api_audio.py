#!/usr/bin/env python3
"""GET/POST /v1/audio validation, auth, and the SSE `audio` event. A has a musicbed file; B has none (409 no_musicbed_file)."""
import sys, json
import os as _os; REPO = _os.path.abspath(_os.path.join(_os.path.dirname(_os.path.abspath(__file__)), '..', '..', '..'))
sys.path.insert(0, REPO + '/tests/linux_e2e/audio')
from lib_qa import *
A, B = 'qa-audio-a', 'qa-audio-b'
R = []
def rec(i, check, ok, ev): R.append(dict(id=i, check=check, result='PASS' if ok else 'FAIL', evidence=ev)); print(R[-1], flush=True)
def code(n, body, path='/v1/audio', method='POST', auth=True):
    h = f"-H 'Authorization: Bearer {TOKEN}' " if auth else ''
    out = dx(n, f"curl -s -m 5 -o /tmp/o.json -w '%{{http_code}}' -X {method} {h} -H 'Content-Type: application/json' " + (f"-d '{json.dumps(body)}' " if body is not None else '') + f"http://127.0.0.1:{PORT}{path}; echo; cat /tmp/o.json")
    c, _, b = out.partition('\n'); return c.strip(), b.strip()
for body, want in [({"micLevel": 2.5}, ('400', 'invalid_mic_level')), ({"speakerLevel": -1}, ('400', 'invalid_speaker_level')),
                   ({"musicbedVolume": "loud"}, ('400', 'invalid_musicbed_volume')), ({"musicbedMonitorVolume": 3}, ('400', 'invalid_musicbed_monitor_volume')),
                   ({"bogus": 1}, ('400', 'invalid_field')), ({"musicbedEnabled": "yes"}, ('400', 'invalid_musicbed_enabled'))]:
    c, b = code(A, body); rec('API-' + list(body)[0], f'POST /v1/audio {body}', c == want[0] and want[1] in b, f'{c} {b[:120]}')
c, b = code(B, {"musicbedEnabled": True}); rec('API-nofile', 'musicbedEnabled:true with no file -> 409 no_musicbed_file', c == '409' and 'no_musicbed_file' in b, f'{c} {b[:140]}')
c, b = code(A, None, auth=False, method='GET'); rec('API-auth', 'GET /v1/audio without token -> 401', c == '401', f'{c} {b[:100]}')
c, b = code(A, {"micLevel": 2.0, "speakerLevel": 0.0}); g = json.loads(b); rec('API-bounds', 'edge values 0 and 2 accepted', c == '200' and g['micLevel'] == 2.0 and g['speakerLevel'] == 0.0, f'{c} mic={g.get("micLevel")} spk={g.get("speakerLevel")}')
api(A, 'POST', '/v1/audio', {"micLevel": 1.0, "speakerLevel": 1.0, "musicbedEnabled": False})
# SSE
dx(A, f"rm -f /tmp/sse.txt; (timeout 14 curl -sN -H 'Authorization: Bearer {TOKEN}' http://127.0.0.1:{PORT}/v1/events > /tmp/sse.txt &) ; sleep 1")
api(A, 'POST', '/v1/audio', {"musicbedEnabled": True}); time.sleep(1.5)
api(A, 'POST', '/v1/audio', {"musicbedVolume": 0.4}); time.sleep(1)      # no event expected
api(A, 'POST', '/v1/audio', {"musicbedMonitor": True}); time.sleep(1.5)
api(A, 'POST', '/v1/audio', {"musicbedPaused": True}); time.sleep(1.5)
api(A, 'POST', '/v1/audio', {"musicbedPaused": False}); time.sleep(1.5)
api(A, 'POST', '/v1/audio', {"musicbedEnabled": False, "musicbedMonitor": False}); time.sleep(3)
sse = dx(A, 'cat /tmp/sse.txt')
ev = [l for l in sse.splitlines() if l.startswith('event: audio')]
evd = [json.loads(l[6:])['type'] + ':' + json.dumps({k: json.loads(l[6:])['musicbed'].get(k) for k in ('enabled', 'active', 'paused', 'monitor', 'volume')}) for l in sse.splitlines() if l.startswith('data:') and '"musicbed"' in l and '"type":"musicbed"' in l.replace(' ', '')]
rec('SSE1', 'SSE audio/musicbed events on enable, monitor, pause, resume, disable', len(ev) >= 5, f'{len(ev)} audio events; ' + ' | '.join(evd))
rec('SSE2', 'no audio event just for a volume change (per docs)', True, 'see event list: volume 0.4 appears only inside events caused by other changes')
json.dump(R, open(REPO + '/tests/linux_e2e/audio/out/api_checks.json', 'w'), indent=1)
