#!/usr/bin/env python3
"""Runtime smoke test of a built SoftphonePro.app: launch with --provision, drive the local API.

  python3 tests/smoke/macos_smoke.py --app path/softphonepro.app --out outdir [--version 1.2.3]
"""
import argparse
import json
import os
import secrets
import socket
import subprocess
import sys
import time
import threading
import urllib.request
from functools import partial
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer


def free_port():
    s = socket.socket()
    s.bind(("127.0.0.1", 0))
    p = s.getsockname()[1]
    s.close()
    return p


def check(cond, msg):
    if not cond:
        raise SystemExit("ASSERT FAILED: " + msg)
    print("PASS:", msg, flush=True)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--app", required=True)
    ap.add_argument("--out", required=True)
    ap.add_argument("--version", default="")
    a = ap.parse_args()
    os.makedirs(a.out, exist_ok=True)
    app = os.path.abspath(a.app)
    port, token = free_port(), secrets.token_hex(32)
    cfg = {
        "accounts": [{"username": "smoke1", "password": "smoke-pass", "domain": "127.0.0.1:5999",
                      "transport": "udp", "label": "smoke"}],
        "settings": {"automationEnabled": True, "automationPort": port, "automationToken": token,
                     "stunServers": [], "dnd": False},
    }
    cfg_path = os.path.join(a.out, "provision.json")
    with open(cfg_path, "w") as f:
        json.dump(cfg, f)

    def api(method, path, body=None):
        req = urllib.request.Request("http://127.0.0.1:%d%s" % (port, path), method=method,
                                     data=json.dumps(body).encode() if body is not None else None,
                                     headers={"Authorization": "Bearer " + token, "Content-Type": "application/json"})
        with urllib.request.urlopen(req, timeout=5) as r:
            return json.loads(r.read() or b"{}")

    def pids():
        r = subprocess.run(["pgrep", "-x", "softphonepro"], capture_output=True, text=True)
        return [int(x) for x in r.stdout.split()]

    # The app is sandboxed and cannot read arbitrary paths, so serve the JSON on loopback
    # (http://127.0.0.1 is an allowed --provision source, same as tests/macos_e2e).
    class Quiet(SimpleHTTPRequestHandler):
        def log_message(self, *args):
            pass

    httpd = ThreadingHTTPServer(("127.0.0.1", 0), partial(Quiet, directory=a.out))
    threading.Thread(target=httpd.serve_forever, daemon=True).start()
    prov_url = "http://127.0.0.1:%d/provision.json" % httpd.server_address[1]

    start = time.time()
    r = subprocess.run(["open", "-n", app, "--args", "--provision", prov_url], capture_output=True, text=True)
    print("open rc=%d %s" % (r.returncode, r.stderr.strip()), flush=True)
    check(r.returncode == 0, "open launched the app")
    try:
        st = None
        end = time.time() + 90
        while time.time() < end:
            try:
                st = api("GET", "/v1/status")
                break
            except Exception:
                time.sleep(0.7)
        if st is None:
            print("pids:", pids(), flush=True)
            subprocess.run("ls -la ~/Library/Logs/DiagnosticReports | tail; ps aux | grep -i softphone | head", shell=True)
            with open(os.path.join(a.out, "unified.log"), "w") as f:
                subprocess.run(["log", "show", "--last", "3m", "--style", "compact", "--predicate",
                                'process == "softphonepro" OR eventMessage CONTAINS[c] "softphonepro"'], stdout=f)
        check(st is not None, "automation API answered /v1/status within 90 s")
        json.dump(st, open(os.path.join(a.out, "status.json"), "w"), indent=1)
        check(st["app"] == "SoftphonePro", "app name is SoftphonePro")
        if a.version:
            want = a.version.split("-")[0].split("+")[0]
            check(str(st["version"]).startswith(want), "version %r matches %s" % (st["version"], want))
        end = time.time() + 30
        while st["engine"]["state"] != "running" and time.time() < end:
            time.sleep(0.7)
            st = api("GET", "/v1/status")
        check(st["engine"]["state"] == "running", "engine state is running (%s)" % st["engine"])
        accs = [x for x in st["accounts"] if x.get("username") == "smoke1"]
        check(len(accs) >= 1, "provisioned account smoke1 listed")
        end = time.time() + 30
        while time.time() < end:
            st = api("GET", "/v1/status")
            accs = [x for x in st["accounts"] if x.get("username") == "smoke1"]
            if accs[0]["regState"] in ("failed", "offline"):
                break
            time.sleep(1)
        print("account:", accs[0], flush=True)
        check(accs[0]["regState"] in ("registering", "failed", "offline"), "account not registered (no server), app alive")
        api("POST", "/v1/dnd", {"enabled": True})
        check(api("GET", "/v1/status")["dnd"] is True, "POST /v1/dnd -> status.dnd true")
        api("POST", "/v1/dnd", {"enabled": False})
        check(api("GET", "/v1/status")["dnd"] is False, "DND off again")
        check(len(pids()) >= 1, "process alive")
    finally:
        for p in pids():
            try:
                os.kill(p, 9)
            except OSError:
                pass
    time.sleep(1)
    # crash reports written since launch
    d = os.path.expanduser("~/Library/Logs/DiagnosticReports")
    crashes = []
    if os.path.isdir(d):
        crashes = [f for f in os.listdir(d) if f.lower().startswith("softphonepro")
                   and os.path.getmtime(os.path.join(d, f)) >= start]
    for f in crashes:
        subprocess.run(["cp", os.path.join(d, f), a.out])
    check(not crashes, "no crash reports (%s)" % crashes)
    print("SMOKE OK")


if __name__ == "__main__":
    sys.exit(main())
