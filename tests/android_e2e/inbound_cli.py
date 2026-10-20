#!/usr/bin/env python3
"""Second registration for the Android QA: spcore_cli registers as ext 1002 (host -> PBX on 127.0.0.1) and
calls 1001 (the emulator app). Prints the call events; hangs up after HOLD seconds once confirmed.
Usage: inbound_cli.py [hold_seconds=15]   (PBX must be up; signalling only, no usable media path)
"""
import glob, json, os, subprocess, sys, threading, time
ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
CLI = os.environ.get("SPCORE_CLI", os.path.join(ROOT, "native", "build", "v110-rel", "spcore_cli"))
HOLD = float(sys.argv[1]) if len(sys.argv) > 1 else 15
p = subprocess.Popen([CLI], stdin=subprocess.PIPE, stdout=subprocess.PIPE, text=True, cwd=os.path.dirname(CLI),
                     env=dict(os.environ, DYLD_LIBRARY_PATH=os.path.dirname(CLI)))
ev = []
def rd():
    for l in p.stdout:
        ev.append(l); print(l.strip()[:300], flush=True)
threading.Thread(target=rd, daemon=True).start()
def send(m, pr): p.stdin.write(json.dumps({"m": m, "p": pr}) + "\n"); p.stdin.flush()
def wait(sub, t):
    t0 = time.time()
    while time.time() - t0 < t:
        for l in ev:
            if all(s in l for s in sub): return l
        time.sleep(.2)
send("core.start", {"userAgent": "qa-cli", "logLevel": 2, "transports": {"udp": {"port": 0}}, "media": {"noAudioDevice": True},
                    "stunServers": [], "publicAddr": "127.0.0.1"})
time.sleep(1)
send("account.add", {"uid": "u1002", "username": "1002", "password": "pass1002", "domain": "127.0.0.1", "transport": "udp", "regExpires": 120})
print("registered:", bool(wait(['"registered"'], 15)))
send("call.make", {"uid": "u1002", "uri": "1001"})
cid = None
l = wait(['"call.state"'], 10)
print("call.state seen:", bool(l))
if wait(['"confirmed"'], 40):
    time.sleep(HOLD)
send("call.hangupAll", {}); time.sleep(2); send("__quit", {}); p.wait(5)
