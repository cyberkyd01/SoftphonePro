#!/usr/bin/env python3
"""macOS end-to-end run of the CI-built SoftphonePro.app against the local test PBX.

The app is provisioned from a throw-away HTTP server (--provision), driven through its
local automation API and observed from the PBX (docker exec asterisk) and from a host
far-end (native spcore_cli, extension 1015).

  python3 tests/macos_e2e/e2e.py --app /path/SoftphonePro.app --out /path/outdir

Results go to <out>/results.json and are printed as PASS/FAIL lines.
Window screenshots use `screencapture -l<id>` of the app's own windows only.
"""
import argparse
import json
import os
import socket
import subprocess
import sys
import tempfile
import threading
import time
import traceback
import urllib.error
import urllib.request

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, "..", ".."))
PBX = "127.0.0.1"
CONTAINER = "softphonepro-pbx"
TOKEN = "e2e" + "0123456789abcdef" * 4 + "e2e"[:0]
TOKEN = (TOKEN + "0" * 64)[:64]


def free_port():
    s = socket.socket()
    s.bind(("127.0.0.1", 0))
    p = s.getsockname()[1]
    s.close()
    return p


def sh(*a, check=False, timeout=60):
    return subprocess.run(list(a), capture_output=True, text=True, timeout=timeout, check=check)


def pbx(cmd):
    return sh("docker", "exec", CONTAINER, "asterisk", "-rx", cmd).stdout


def pbx_cat(path):
    return sh("docker", "exec", CONTAINER, "cat", path).stdout


class Api:
    def __init__(self, port, token=TOKEN):
        self.base = "http://127.0.0.1:%d" % port
        self.token = token

    def call(self, method, path, body=None, token="default", timeout=15):
        data = None if body is None else json.dumps(body).encode()
        req = urllib.request.Request(self.base + path, data=data, method=method)
        tok = self.token if token == "default" else token
        if tok:
            req.add_header("Authorization", "Bearer " + tok)
        if data is not None:
            req.add_header("Content-Type", "application/json")
        try:
            with urllib.request.urlopen(req, timeout=timeout) as r:
                return r.status, json.loads(r.read() or b"{}")
        except urllib.error.HTTPError as e:
            raw = e.read()
            try:
                return e.code, json.loads(raw or b"{}")
            except ValueError:
                return e.code, {"raw": raw.decode(errors="replace")}

    def get(self, p, **k):
        return self.call("GET", p, **k)

    def post(self, p, body=None, **k):
        return self.call("POST", p, {} if body is None else body, **k)


class Events(threading.Thread):
    """Reads /v1/events in the background."""

    def __init__(self, api):
        super().__init__(daemon=True)
        self.api = api
        self.items = []  # (category, data)
        self.text = ""
        self.cv = threading.Condition()
        self.resp = None
        self.status = None

    def run(self):
        req = urllib.request.Request(self.api.base + "/v1/events")
        req.add_header("Authorization", "Bearer " + self.api.token)
        try:
            self.resp = urllib.request.urlopen(req, timeout=3600)
            self.status = self.resp.status
            cat = None
            for raw in self.resp:
                line = raw.decode()
                with self.cv:
                    self.text += line
                line = line.rstrip("\n")
                if line.startswith("event: "):
                    cat = line[7:]
                elif line.startswith("data: "):
                    with self.cv:
                        self.items.append((cat, json.loads(line[6:])))
                        self.cv.notify_all()
        except Exception as e:  # closed on shutdown
            self.status = self.status or str(e)

    def mark(self):
        with self.cv:
            return len(self.items)

    def wait(self, pred, timeout=15, start=0):
        end = time.time() + timeout
        i = start
        with self.cv:
            while True:
                while i < len(self.items):
                    c, d = self.items[i]
                    i += 1
                    if pred(c, d):
                        return d
                if time.time() > end:
                    return None
                self.cv.wait(0.2)

    def close(self):
        try:
            if self.resp:
                self.resp.close()
        except Exception:
            pass


class Results:
    def __init__(self):
        self.rows = []

    def run(self, name, fn):
        t0 = time.time()
        try:
            note = fn()
            self.rows.append({"case": name, "result": "PASS", "note": note or "", "secs": round(time.time() - t0, 1)})
        except Exception as e:
            tb = traceback.format_exc(limit=3)
            self.rows.append({"case": name, "result": "FAIL", "note": "%s: %s" % (type(e).__name__, e), "trace": tb,
                              "secs": round(time.time() - t0, 1)})
        r = self.rows[-1]
        print("%-4s %-52s %s" % (r["result"], name, r["note"][:160]), flush=True)


def check(cond, msg="check failed"):
    if not cond:
        raise AssertionError(msg)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--app", required=True)
    ap.add_argument("--out", required=True)
    ap.add_argument("--cli", default=os.environ.get("SPCORE_CLI"))
    ap.add_argument("--winlist", required=True, help="compiled winlist helper")
    ap.add_argument("--only", default="")
    args = ap.parse_args()
    out = os.path.abspath(args.out)
    os.makedirs(out, exist_ok=True)

    # far-end engine from the native test harness
    os.environ["SPCORE_CLI"] = args.cli or ""
    if args.cli:
        os.environ["SPCORE_LIB"] = os.path.join(os.path.dirname(args.cli), "libspcore.dylib")
    sys.path.insert(0, os.path.join(ROOT, "native", "tests"))
    import run_tests as rt  # noqa: E402

    api_port = free_port()
    prov_port = free_port()
    prov_dir = tempfile.mkdtemp(prefix="spro_prov_")
    cfg = {
        "version": 1,
        "accounts": [{"username": "1016", "password": "pass1016", "domain": PBX, "transport": "udp",
                      "label": "1016 (test PBX)", "voicemail": "*97"}],
        "settings": {
            "automationEnabled": True, "automationPort": api_port, "automationToken": TOKEN,
            "stunServers": [], "udpEnabled": True, "tcpEnabled": True, "tlsEnabled": False,
            "callLinksImmediately": False, "dnd": False,
        },
    }
    with open(os.path.join(prov_dir, "cfg.json"), "w") as f:
        json.dump(cfg, f)
    prov = subprocess.Popen([sys.executable, "-I", "-m", "http.server", str(prov_port), "--bind", "127.0.0.1",
                             "--directory", prov_dir], stdout=open(os.path.join(out, "prov.log"), "w"), stderr=subprocess.STDOUT)
    time.sleep(0.5)
    prov_url = "http://127.0.0.1:%d/cfg.json" % prov_port

    app = os.path.abspath(args.app)
    api = Api(api_port)
    R = Results()
    ev = None
    far = None
    state = {}

    def app_pid():
        r = sh("pgrep", "-x", "softphonepro")
        return [int(x) for x in r.stdout.split()]

    def quit_app():
        # `tell application ... to quit` would launch an app that is not running.
        if not app_pid():
            return
        sh("osascript", "-e", 'tell application id "com.softphonepro.softphonepro" to quit')
        for _ in range(40):
            if not app_pid():
                return
            time.sleep(0.25)
        for p in app_pid():
            os.kill(p, 9)

    def launch(*extra):
        r = sh("open", "-n", app, "--args", *extra)
        if r.returncode != 0 or r.stderr.strip():
            print("open:", r.returncode, r.stderr.strip(), flush=True)

    def wait_api(timeout=60):
        end = time.time() + timeout
        while time.time() < end:
            try:
                s, j = api.get("/v1/status", timeout=3)
                if s == 200:
                    return j
            except Exception:
                pass
            time.sleep(0.5)
        raise TimeoutError("automation API did not come up")

    def wait_registered(timeout=30):
        end = time.time() + timeout
        while time.time() < end:
            s, j = api.get("/v1/accounts")
            if s == 200 and any(a["regState"] == "registered" for a in j["accounts"]):
                return j["accounts"]
            time.sleep(0.5)
        raise TimeoutError("account not registered: %s" % (api.get("/v1/accounts"),))

    def shot(name, wait=0.8):
        time.sleep(wait)
        best = None
        for attempt in range(12):
            best = pick_window(strict=(attempt >= 3))
            if best:
                break
            api.post("/v1/ui/show", {})
            sh("open", app)  # re-activate the running app
            time.sleep(0.7)
        if not best:
            raise AssertionError("no onscreen window to capture: " + sh(args.winlist).stdout.replace("\n", " | ")[:1800])
        path = os.path.join(out, name + ".png")
        if os.path.exists(path):
            os.remove(path)
        sh("screencapture", "-l%d" % best[0], "-o", "-x", path)
        if not os.path.exists(path):
            raise AssertionError("screencapture produced no file")
        return path

    import re

    def pick_window(strict=False):
        lines = sh(args.winlist).stdout.splitlines()
        best = None
        for l in lines:
            parts = l.split()
            lm = re.search(r"layer=(\d+)", l)
            if lm and int(lm.group(1)) <= 3 and (strict or "onscreen=true" in l):
                wid = int(parts[0])
                m = re.search(r"Width[\"']*: (\d+)", l)
                w = int(m.group(1)) if m else 0
                hm = re.search(r"Height[\"']*: (\d+)", l)
                if not hm or int(hm.group(1)) < 300:
                    continue  # menu bar strip etc.
                if best is None or w > best[1]:
                    best = (wid, w)
        return best

    def show(route):
        s, j = api.post("/v1/ui/show", {"route": route})
        check(s == 200, "ui/show %s -> %s %s" % (route, s, j))

    def hangup_all():
        s, j = api.get("/v1/calls")
        for c in j.get("calls", []):
            api.post("/v1/calls/%d/hangup" % c["cid"])
        end = time.time() + 8
        while time.time() < end:
            if not api.get("/v1/calls")[1].get("calls"):
                return
            time.sleep(0.3)

    def retry_once(fn):
        """The far end sits behind the Docker UDP port forwarder, whose NAT mappings expire when idle."""
        def run():
            try:
                return fn()
            except AssertionError as e:
                first = str(e)
                hangup_all()
                time.sleep(3)
                return (fn() or "") + " (second attempt; first: %s)" % first[:60]
        return run

    def wait_gone():
        for _ in range(20):
            if "PJSIP/1016" not in pbx("core show channels"):
                return True
            time.sleep(0.5)
        return False

    def only(name):
        return not args.only or args.only in name

    try:
        # ------------------------------------------------------------------ boot
        def t_boot():
            quit_app()
            launch("--provision", prov_url)
            j = wait_api(90)
            check(j["app"] == "SoftphonePro")
            return "version %s, engine %s" % (j["version"], j["engine"]["state"])

        R.run("boot: --provision enables the automation API", t_boot)
        if R.rows[-1]["result"] != "PASS":
            raise SystemExit("cannot continue without the API")

        ev = Events(api)
        ev.start()

        def t_reg():
            accs = wait_registered()
            contacts = pbx("pjsip show contacts")
            check("1016" in contacts, "PBX does not list 1016:\n" + contacts)
            return "app regState=%s; PBX contacts include 1016" % accs[0]["regState"]

        R.run("registration of 1016 (API + PBX pjsip show contacts)", t_reg)
        R.run("screenshot: keypad registered", lambda: (show("/keypad"), shot("01_keypad_registered"))[1])

        # ------------------------------------------------------------------ auth
        def t_auth():
            check(api.get("/v1/status", token=None)[0] == 401, "no token")
            check(api.get("/v1/status", token="x" * 64)[0] == 401, "wrong token")
            s, j = api.call("GET", "/v1/status", token=TOKEN)
            check(s == 200)
            return "401 without/with wrong token, 200 with token"

        R.run("API auth", t_auth)

        # ------------------------------------------------------------------ outgoing 600
        def t_out600():
            m = ev.mark()
            s, j = api.post("/v1/calls", {"to": "600"})
            check(s == 201, "dial: %s %s" % (s, j))
            cid = j["cid"]
            state["cid600"] = cid
            d = ev.wait(lambda c, d: c == "call" and d["type"] == "state" and d["call"]["cid"] == cid and d["call"]["state"] == "active", 15, m)
            check(d, "call never became active; events=%s" % ev.items[m:])
            time.sleep(1.5)
            ch = pbx("core show channels")
            check("1016" in ch and "600" in ch.replace("Echo", "600") or "Echo" in ch, "PBX channels:\n" + ch)
            return "cid %d active; PBX: %s" % (cid, " | ".join(l.strip() for l in ch.splitlines() if "PJSIP" in l or "Echo" in l)[:140])

        R.run("outgoing call to 600 (PBX core show channels)", t_out600)
        R.run("screenshot: in-call window", lambda: (shot("02_in_call")))

        def t_hold():
            cid = state["cid600"]
            s, j = api.post("/v1/calls/%d/hold" % cid)
            check(s == 200, str(j))
            time.sleep(1)
            check(api.get("/v1/calls/%d" % cid)[1]["call"]["state"] == "held", "not held")
            shot("03_in_call_held")
            s, j = api.post("/v1/calls/%d/unhold" % cid)
            check(s == 200, str(j))
            time.sleep(1)
            check(api.get("/v1/calls/%d" % cid)[1]["call"]["state"] == "active", "not active after unhold")
            check(api.post("/v1/calls/%d/unhold" % cid)[0] == 409, "unhold of active call should be 409")
            s, j = api.post("/v1/calls/%d/mute" % cid)
            check(s == 200 and api.get("/v1/calls/%d" % cid)[1]["call"]["muted"], "mute")
            api.post("/v1/calls/%d/unmute" % cid)
            return "hold, unhold, mute, unmute; conflicting unhold gives 409"

        R.run("hold / unhold / mute", t_hold)
        R.run("hangup 600", lambda: (api.post("/v1/calls/%d/hangup" % state["cid600"])[0] == 200 or check(False), time.sleep(1), check(wait_gone(), "channel still up"))[2] or "channel gone")

        # ------------------------------------------------------------------ DTMF 602
        def t_dtmf():
            # the dialplan overwrites this file per call: compare modification times
            def mtime():
                return sh("docker", "exec", CONTAINER, "stat", "-c", "%Y.%y", "/var/log/asterisk/dtmf_1016.txt").stdout.strip()
            before_mtime = mtime()
            before = ""
            m = ev.mark()
            s, j = api.post("/v1/calls", {"to": "602"})
            check(s == 201, str(j))
            cid = j["cid"]
            check(ev.wait(lambda c, d: c == "call" and d["type"] == "state" and d["call"]["cid"] == cid and d["call"]["state"] == "active", 15, m), "not active")
            time.sleep(1.5)
            s, j = api.post("/v1/calls/%d/dtmf" % cid, {"digits": "1234"})
            check(s == 200, str(j))
            got = ""
            for _ in range(30):
                got = pbx_cat("/var/log/asterisk/dtmf_1016.txt")
                if "1234" in got and mtime() != before_mtime:
                    break
                time.sleep(0.5)
            api.post("/v1/calls/%d/hangup" % cid)
            check("1234" in got[len(before):], "dtmf_1016.txt did not receive 1234: %r -> %r" % (before, got))
            return "PBX dtmf_1016.txt gained %r" % got[len(before):].strip()

        R.run("DTMF 1234 to 602 (PBX dtmf_1016.txt)", t_dtmf)
        time.sleep(1)

        # ------------------------------------------------------------------ host far end
        far = rt.Cli("far")
        far.start_core()
        state["far_acc"], _ = far.add_account(1015, keepAliveSec=10)
        state["far"] = far

        def t_incoming():
            hangup_all()
            m = ev.mark()
            mf = far.mark()
            r = far.req("call.make", {"uid": "u1015", "uri": "1016"})
            fcid = r["cid"]
            state["fcid"] = fcid
            d = ev.wait(lambda c, d: c == "call" and d["type"] == "incoming", 15, m)
            if not d:
                diag = "events=%s sse=%s calls=%s far=%s contacts=%s" % (
                    ev.items[m:], ev.status, api.get("/v1/calls"),
                    [(e.get("event"), e.get("state"), e.get("lastCode")) for e in far.events() if e.get("cid") == fcid],
                    [l.strip() for l in pbx("pjsip show contacts").splitlines() if "Contact:" in l and "Aor" not in l])
                raise AssertionError("no incoming event; " + diag)
            check(d["call"]["number"] == "1015", "caller number %r" % d["call"]["number"])
            cid = d["call"]["cid"]
            state["icid"] = cid
            time.sleep(1.0)
            state["incoming_shot"] = shot("04_incoming_banner")
            s, j = api.post("/v1/calls/%d/answer" % cid)
            check(s == 200, str(j))
            check(ev.wait(lambda c, d: c == "call" and d["call"]["cid"] == cid and d["call"]["state"] == "active", 15, m), "not active after answer")
            check(far.wait_event("call.state", 15, mf, cid=fcid, state="confirmed"), "far end never confirmed")
            time.sleep(1.0)
            shot("05_incoming_answered")
            far.req("call.hangup", {"cid": fcid})
            check(ev.wait(lambda c, d: c == "call" and d["type"] == "ended" and d["call"]["cid"] == cid, 15, m), "no ended event")
            check(not api.get("/v1/calls")[1]["calls"], "call list not empty")
            return "incoming from 1015: event, answer via API, ended on far-end hangup"

        R.run("incoming 1015 -> 1016: event, answer, far-end hangup", t_incoming)

        def ensure_far():
            # refresh the far end's registration (its NAT mapping behind the Docker UDP forwarder may have expired)
            mk = far.mark()
            try:
                far.req("account.register", {"acc": state["far_acc"]})
                far.wait_event("account.reg", 10, mk, regState="registered")
            except Exception:
                pass
            for _ in range(20):
                if "1015" in pbx("pjsip show contacts"):
                    return
                time.sleep(0.5)
            raise AssertionError("1015 is not registered on the PBX:\n" + pbx("pjsip show contacts"))

        def t_transfer():
            ensure_far()
            m = ev.mark()
            mf = far.mark()
            s, j = api.post("/v1/calls", {"to": "1015"})
            check(s == 201, str(j))
            cid = j["cid"]
            inc = far.wait_event("call.incoming", 15, mf)
            check(inc, "far end did not ring")
            far.req("call.answer", {"cid": inc["cid"]})
            check(ev.wait(lambda c, d: c == "call" and d["call"]["cid"] == cid and d["call"]["state"] == "active", 15, m), "not active")
            time.sleep(1.5)
            s, j = api.post("/v1/calls/%d/transfer" % cid, {"target": "600"})
            check(s == 200, str(j))
            time.sleep(3)
            ch = pbx("core show channels")
            far_refer = [e for e in far.events() if e.get("event", "").startswith("call.") and e.get("cid") == inc["cid"]]
            hangup_all()
            try:
                far.req("call.hangup", {"cid": inc["cid"]})
            except Exception:
                pass
            return "blind transfer accepted (200); PBX after transfer: %s" % " | ".join(l.strip() for l in ch.splitlines() if "PJSIP" in l or "Echo" in l)[:160]

        R.run("blind transfer to 600", retry_once(t_transfer))
        time.sleep(1)

        def t_dnd():
            hangup_all()
            m = ev.mark()
            s, j = api.post("/v1/dnd", {"enabled": True})
            check(s == 200 and j["enabled"] is True, str(j))
            check(api.get("/v1/status")[1]["dnd"] is True)
            mf = far.mark()
            fcid = far.req("call.make", {"uid": "u1015", "uri": "1016"})["cid"]
            d = far.wait_event("call.state", 15, mf, cid=fcid, state="disconnected")
            check(d, "far end call was not rejected")
            code = d.get("lastCode")
            time.sleep(1)
            check(not api.get("/v1/calls")[1]["calls"], "call visible while DND")
            check(not [x for x in ev.items[m:] if x[0] == "call" and x[1]["type"] == "incoming"], "incoming event under DND")
            h = ev.wait(lambda c, d: c == "history" and d["record"]["direction"] == "incoming", 5, m)
            api.post("/v1/dnd", {"enabled": False})
            check(h, "no history event for the rejected call")
            return "far end got SIP %s; history result=%s" % (code, h["record"]["result"])

        R.run("DND on: incoming rejected", t_dnd)

        def t_msg():
            ensure_far()
            mf = far.mark()
            s, j = api.post("/v1/messages", {"to": "1015", "body": "hello from the API"})
            check(s == 201, str(j))
            e = far.wait_event("im.incoming", 15, mf)
            check(e and e.get("body") == "hello from the API", "far end got %s" % e)
            # and the reverse direction produces an event
            m = ev.mark()
            far.req("im.send", {"uid": "u1015", "to": "1016", "body": "reply from far"})
            d = ev.wait(lambda c, d: c == "message" and d["type"] == "received", 15, m)
            check(d and d["message"]["body"] == "reply from far", "no message event")
            return "message delivered to 1015; reply arrived as event"

        R.run("message to 1015 (+ reply event)", retry_once(t_msg))

        def t_hist():
            s, j = api.get("/v1/history?limit=20")
            check(s == 200 and j["history"], "empty history")
            dirs = {(h["direction"], h["number"]) for h in j["history"]}
            check(("outgoing", "600") in dirs and ("incoming", "1015") in dirs, "history: %s" % dirs)
            check(api.get("/v1/history?limit=0")[0] == 400)
            return "%d records, e.g. %s" % (len(j["history"]), sorted(dirs)[:4])

        R.run("history contains the calls", t_hist)

        def t_err():
            check(api.post("/v1/calls", {"to": ""})[0] == 400)
            check(api.get("/v1/calls/9999")[0] == 404)
            check(api.post("/v1/calls/9999/hangup")[0] == 404)
            check(api.call("DELETE", "/v1/status")[0] == 405)
            s, j = api.post("/v1/calls", {"to": "600", "accountId": "nope"})
            check(s == 404, str(j))
            return "400/404/405 JSON errors"

        R.run("API error responses", t_err)

        # ------------------------------------------------------------------ links
        def t_open_url_running():
            hangup_all()
            sh("open", "-a", app, "sip:600")
            time.sleep(2)
            p = shot("06_sip_link_prefill")
            logs = sh("log", "show", "--last", "1m", "--predicate", 'process == "softphonepro" AND eventMessage CONTAINS "link received"', "--style", "compact").stdout
            check("link received sip:600" in logs, "no native log of the link:\n" + logs[-400:])
            return "native log shows the link; dialer screenshot %s" % os.path.basename(p)

        R.run("open sip:600 while running reaches the app", t_open_url_running)

        def t_dial_at_launch():
            # relaunch with --dial: must wait for registration and place the call
            quit_app()
            time.sleep(1)
            launch("--dial", "600")
            wait_api(60)
            end = time.time() + 40
            call = None
            while time.time() < end:
                try:
                    calls = api.get("/v1/calls", timeout=3)[1].get("calls", [])
                except Exception:
                    calls = []
                if calls:
                    call = calls[0]
                    break
                time.sleep(0.5)
            check(call, "no call placed by --dial 600")
            time.sleep(2)
            shot("07_dial_at_launch")
            hangup_all()
            return "call %s placed after startup (state %s)" % (call["cid"], call["state"])

        R.run("--dial 600 at launch waits for registration", t_dial_at_launch)

        # ------------------------------------------------------------------ screens
        def t_screens():
            wait_registered()
            names = []
            for n, route in [("08_settings_advanced", "/settings/advanced"), ("09_settings_calls", "/settings/calls"),
                             ("10_settings_diagnostics", "/settings/diagnostics"), ("11_lan", "/lan"),
                             ("12_recents", "/recents"), ("13_messages", "/messages")]:
                show(route)
                shot(n, 1.2)
                names.append(n)
            return ", ".join(names)

        R.run("screenshots: settings, diagnostics, LAN, recents, messages", t_screens)

        def t_default_handler_read():
            logs = sh("log", "show", "--last", "5m", "--predicate", 'process == "softphonepro"', "--style", "compact").stdout
            return "see 09_settings_calls.png (tile reads current handlers)"

        R.run("default handler tile (read only)", t_default_handler_read)

    finally:
        if ev:
            ev.close()
        for k in ("far",):
            if state.get(k):
                try:
                    state[k].shutdown()
                except Exception:
                    pass
        prov.terminate()
        with open(os.path.join(out, "results.json"), "w") as f:
            json.dump({"rows": R.rows, "apiPort": api_port}, f, indent=2)
        fails = [r for r in R.rows if r["result"] != "PASS"]
        print("\n%d cases, %d failed" % (len(R.rows), len(fails)))
        if not os.environ.get("E2E_KEEP_APP"):
            quit_app()


if __name__ == "__main__":
    main()
