#!/usr/bin/env python3
"""Runtime smoke test of an installed SoftphonePro on Linux: launch with --provision, drive the local API.

Run it inside a graphical + D-Bus session, e.g. (CI, local container):

  xvfb-run -a dbus-run-session -- python3 tests/smoke/linux_smoke.py --out smoke-logs/linux --version 1.2.0

What it checks
  * the automation API answers within 45 s of launch (no keyring / Secret Service / NetworkManager needed),
  * app name, version, engine running, no unhandled Dart exception in the logs,
  * with the Asterisk test PBX (tests/sipserver, host mode: 127.0.0.1): registration, an outgoing call to
    ext 602 that reaches confirmed/active, DTMF (read back from the PBX when docker is reachable), hang-up,
  * single instance: a second `softphonepro sip:600@...` exits quickly and the running app handles the link,
  * screenshots (ImageMagick `import -window root`) and the app's stdout/stderr in --out.

Without a PBX (--no-pbx, e.g. no Docker on the runner) the PBX part is skipped and says so loudly; the link
is then only checked to reach the running instance (a call attempt / history entry appears).
"""
import argparse
import json
import os
import secrets
import shutil
import signal
import socket
import subprocess
import sys
import time
import urllib.error
import urllib.request


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


def wait_for(fn, timeout, interval=0.5):
    end = time.time() + timeout
    last = None
    while time.time() < end:
        try:
            last = fn()
            if last:
                return last
        except Exception as e:  # noqa: BLE001 - polling helper
            last = None
            _ = e
        time.sleep(interval)
    return last


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--bin", default="softphonepro", help="path or name of the softphonepro launcher")
    ap.add_argument("--out", required=True)
    ap.add_argument("--version", default="", help="expected app version (build name, e.g. 1.2.0)")
    ap.add_argument("--no-pbx", action="store_true", help="skip everything that needs the Asterisk test PBX")
    ap.add_argument("--pbx-host", default="127.0.0.1")
    ap.add_argument("--pbx-container", default="softphonepro-pbx", help="docker container used to read back DTMF")
    a = ap.parse_args()
    os.makedirs(a.out, exist_ok=True)
    out = os.path.abspath(a.out)
    exe = shutil.which(a.bin) or a.bin
    check(shutil.which(a.bin) or os.access(a.bin, os.X_OK), "launcher %s is executable" % a.bin)
    check(bool(os.environ.get("DISPLAY")), "DISPLAY is set (run under xvfb-run)")
    check(bool(os.environ.get("DBUS_SESSION_BUS_ADDRESS")), "a D-Bus session bus exists (run under dbus-run-session)")

    port, token = free_port(), secrets.token_hex(32)
    use_pbx = not a.no_pbx
    if use_pbx:
        account = {"username": "1001", "password": "pass1001", "domain": a.pbx_host, "transport": "udp", "label": "smoke"}
    else:
        print("*** SKIPPING THE PBX PART: --no-pbx (Docker / Asterisk not available on this runner) ***", flush=True)
        account = {"username": "smoke1", "password": "smoke-pass", "domain": "127.0.0.1:5999", "transport": "udp", "label": "smoke"}
    cfg = {
        "accounts": [account],
        "settings": {"automationEnabled": True, "automationPort": port, "automationToken": token,
                     "stunServers": [], "dnd": False, "callLinksImmediately": True},
    }
    cfg_path = os.path.join(out, "provision.json")
    with open(cfg_path, "w") as f:
        json.dump(cfg, f)

    def api(method, path, body=None):
        req = urllib.request.Request("http://127.0.0.1:%d%s" % (port, path), method=method,
                                     data=json.dumps(body).encode() if body is not None else None,
                                     headers={"Authorization": "Bearer " + token, "Content-Type": "application/json"})
        try:
            with urllib.request.urlopen(req, timeout=5) as r:
                return json.loads(r.read() or b"{}")
        except urllib.error.HTTPError as e:
            raise RuntimeError("%s %s -> HTTP %d %s" % (method, path, e.code, e.read()[:300])) from e

    def shot(name):
        r = subprocess.run(["import", "-window", "root", os.path.join(out, name + ".png")],
                           capture_output=True, text=True)
        print("screenshot %s rc=%d %s" % (name, r.returncode, r.stderr.strip()[:120]), flush=True)

    def pids():
        r = subprocess.run(["pgrep", "-x", "softphonepro"], capture_output=True, text=True)
        return [int(x) for x in r.stdout.split()]

    def cpu_ticks(pid):
        with open("/proc/%d/stat" % pid) as f:
            parts = f.read().rsplit(")", 1)[1].split()
        return int(parts[11]) + int(parts[12])  # utime + stime

    out_log, err_log = os.path.join(out, "stdout.log"), os.path.join(out, "stderr.log")
    env = dict(os.environ, SOFTPHONEPRO_DEBUG_DESKTOP="1")
    start = time.time()
    proc = subprocess.Popen([exe, "--provision", cfg_path], stdout=open(out_log, "w"), stderr=open(err_log, "w"), env=env)
    try:
        st = None
        end = time.time() + 90
        while time.time() < end:
            if proc.poll() is not None:
                raise SystemExit("ASSERT FAILED: app exited early with code %s" % proc.returncode)
            try:
                st = api("GET", "/v1/status")
                break
            except Exception:  # noqa: BLE001
                time.sleep(0.5)
        took = time.time() - start
        check(st is not None, "automation API answered /v1/status (%.1f s after launch)" % took)
        check(took <= 45, "automation API up within 45 s (took %.1f s)" % took)
        json.dump(st, open(os.path.join(out, "status.json"), "w"), indent=1)
        check(st["app"] == "SoftphonePro", "app name is SoftphonePro")
        if a.version:
            want = a.version.split("-")[0].split("+")[0]
            check(str(st["version"]).startswith(want), "version %r matches %s" % (st["version"], want))
        else:
            check(bool(st["version"]), "version reported: %s" % st["version"])
        st = wait_for(lambda: (lambda s: s if s["engine"]["state"] == "running" else None)(api("GET", "/v1/status")), 30) or st
        check(st["engine"]["state"] == "running", "engine state is running (%s)" % st["engine"])
        accs = [x for x in st["accounts"] if x.get("username") == account["username"]]
        check(len(accs) >= 1, "provisioned account %s listed" % account["username"])
        acc_id = accs[0]["id"]
        shot("01-started")

        if use_pbx:
            def reg():
                s = api("GET", "/v1/status")
                x = [y for y in s["accounts"] if y["id"] == acc_id][0]
                return x if x["regState"] == "registered" else None
            x = wait_for(reg, 30)
            check(x is not None, "account 1001 registered at the PBX (last: %s)" %
                  [y["regState"] for y in api("GET", "/v1/accounts")["accounts"]] if x is None else "account 1001 registered at the PBX")
            shot("02-registered")

            # Idle CPU while registered (informational: software GL under Xvfb is the worst case).
            main_pid = pids()[0]
            time.sleep(5)
            t0, c0 = time.time(), cpu_ticks(main_pid)
            time.sleep(10)
            pct = (cpu_ticks(main_pid) - c0) / os.sysconf("SC_CLK_TCK") / (time.time() - t0) * 100
            print("idle CPU while registered: %.0f%% of one core (informational)" % pct, flush=True)

            # Outgoing call to ext 602 (answers, collects 4 DTMF digits).
            dtmf_file = "/var/log/asterisk/dtmf_1001.txt"
            docker = shutil.which("docker")
            if docker:
                subprocess.run([docker, "exec", a.pbx_container, "rm", "-f", dtmf_file], capture_output=True)
            r = api("POST", "/v1/calls", {"to": "602", "accountId": acc_id, "waitSeconds": 10})
            cid = r["cid"]
            print("call placed: cid=%s" % cid, flush=True)

            def active():
                c = api("GET", "/v1/calls/%s" % cid)["call"]
                return c if c["state"] == "active" or c.get("engineState") == "confirmed" else None
            c = wait_for(active, 20)
            check(c is not None, "call to 602 reached confirmed/active (last: %s)" % api("GET", "/v1/calls/%s" % cid)["call"] if c is None
                  else "call to 602 reached confirmed/active (%s / %s)" % (c["state"], c.get("engineState")))
            shot("03-in-call")
            time.sleep(1.0)  # beep played by the PBX before it reads digits
            api("POST", "/v1/calls/%s/dtmf" % cid, {"digits": "1234"})
            print("DTMF 1234 sent", flush=True)
            if docker:
                def read_dtmf():
                    r2 = subprocess.run([docker, "exec", a.pbx_container, "cat", dtmf_file], capture_output=True, text=True)
                    return r2.stdout.strip() if r2.returncode == 0 else None
                got = wait_for(read_dtmf, 10)
                check(got == "1234", "PBX received DTMF 1234 (got %r)" % got)
            else:
                print("NOTE: docker not reachable from the smoke script: DTMF read-back skipped", flush=True)
                time.sleep(2.5)  # let the four digits go out before hanging up
            try:
                api("POST", "/v1/calls/%s/hangup" % cid)
            except RuntimeError as e:  # the PBX hangs up after reading the digits; both orders are fine
                print("hangup:", e, flush=True)

            def ended():
                try:
                    return api("GET", "/v1/calls/%s" % cid)["call"]["state"] == "ended"
                except RuntimeError as e:
                    return "call_not_found" in str(e)  # already forgotten = ended
            check(wait_for(ended, 15) is not None, "call ended after hang-up")
            shot("04-after-call")

        # Single instance: a second launch hands its argument to the running app and exits quickly.
        before = pids()
        link = "sip:600@%s" % (a.pbx_host if use_pbx else "127.0.0.1:5999")
        t0 = time.time()
        second = subprocess.run([exe, link], capture_output=True, text=True, timeout=20, env=env)
        dt = time.time() - t0
        print("second instance rc=%d after %.1f s %s" % (second.returncode, dt, second.stderr.strip()[:200]), flush=True)
        check(second.returncode == 0 and dt < 10, "second launch exited quickly (%.1f s)" % dt)
        check(sorted(pids()) == sorted(before), "no extra softphonepro process remains (pids %s)" % pids())

        def link_handled():
            calls = api("GET", "/v1/calls").get("calls", [])
            hist = api("GET", "/v1/history?limit=10")
            hist = hist.get("history", hist.get("items", [])) if isinstance(hist, dict) else hist
            hit = [c for c in calls if "600" in str(c.get("number", "")) or "600" in str(c.get("remoteUri", ""))]
            hit += [h for h in hist if "600" in str(h.get("number", ""))]
            return hit
        hit = wait_for(link_handled, 20)
        check(bool(hit), "the running instance handled %s (call/history entry for 600)" % link)
        shot("05-after-link")
        for c in api("GET", "/v1/calls").get("calls", []):
            try:
                api("POST", "/v1/calls/%s/hangup" % c["cid"])
            except RuntimeError:
                pass

        check(proc.poll() is None and len(pids()) >= 1, "process still running after the API exercise")
        api("POST", "/v1/dnd", {"enabled": True})
        check(api("GET", "/v1/status")["dnd"] is True, "POST /v1/dnd -> status.dnd true")
        api("POST", "/v1/dnd", {"enabled": False})
        check(api("GET", "/v1/status")["dnd"] is False, "DND off again")
    finally:
        for p in pids():
            try:
                os.kill(p, signal.SIGKILL)
            except OSError:
                pass
        try:
            proc.wait(timeout=10)
        except Exception:  # noqa: BLE001
            pass
    logs = ""
    for fn in (out_log, err_log):
        with open(fn, errors="replace") as f:
            logs += f.read()
    bad = [ln for ln in logs.splitlines() if "Unhandled Exception" in ln or "Segmentation fault" in ln]
    check(not bad, "no unhandled Dart exceptions / crashes in the app log %s" % bad[:3])
    print("SMOKE OK" + ("" if use_pbx else " (PBX part skipped)"))


if __name__ == "__main__":
    sys.exit(main())
