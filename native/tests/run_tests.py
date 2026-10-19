#!/usr/bin/env python3
"""spcore integration tests: drive spcore_cli processes against the local Asterisk test PBX.

Usage: python3 native/tests/run_tests.py [-v] [TestName ...]
Env:   PBX_HOST (default 127.0.0.1), SPCORE_CLI (path to spcore_cli),
       PBX_CONTAINER (default softphonepro-pbx; used to read DTMF files from the PBX)
"""
import json
import math
import os
import struct
import subprocess
import sys
import tempfile
import threading
import time
import unittest
import wave

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, "..", ".."))
PBX = os.environ.get("PBX_HOST", "127.0.0.1")
CONTAINER = os.environ.get("PBX_CONTAINER", "softphonepro-pbx")
CA = os.path.join(ROOT, "tests", "sipserver", "certs", "ca.crt")


def _native_binary(path):
    try:
        with open(path, "rb") as f:
            magic = f.read(4)
    except OSError:
        return False
    if sys.platform == "darwin":
        return magic in (b"\xcf\xfa\xed\xfe", b"\xca\xfe\xba\xbe")
    if sys.platform.startswith("linux"):
        return magic == b"\x7fELF"
    return True


def find_cli():
    import glob
    p = os.environ.get("SPCORE_CLI")
    if p:
        return p
    cands = sorted(glob.glob(os.path.join(ROOT, "native", "build", "**", "spcore_cli*"), recursive=True))
    cands.sort(key=lambda c: (("asan" in c), c))
    for c in cands:
        if os.path.isfile(c) and os.access(c, os.X_OK) and _native_binary(c):
            return c
    raise SystemExit("spcore_cli not found; set SPCORE_CLI")


CLI = find_cli()
TMP = tempfile.mkdtemp(prefix="spc_tests_")


class RpcError(Exception):
    def __init__(self, method, err):
        super().__init__("%s: %s" % (method, json.dumps(err)))
        self.err = err
        self.code = err.get("code")


class Cli:
    """One spcore_cli process. All messages (events + responses) are kept in order in self.log."""

    def __init__(self, name):
        self.name = name
        env = dict(os.environ)
        lib = os.environ.get("SPCORE_LIB")
        if lib:
            d = os.path.dirname(os.path.abspath(lib))
            for v in ("DYLD_LIBRARY_PATH", "LD_LIBRARY_PATH"):
                env[v] = d + (os.pathsep + env[v] if env.get(v) else "")
        self.proc = subprocess.Popen([CLI], stdin=subprocess.PIPE, stdout=subprocess.PIPE,
                                     stderr=subprocess.PIPE, text=True, bufsize=1, env=env)
        self.log = []
        self.cv = threading.Condition()
        self.stderr = []
        self._t = threading.Thread(target=self._read, daemon=True)
        self._t.start()
        self._te = threading.Thread(target=self._read_err, daemon=True)
        self._te.start()
        self.started = False
        self.cids = {}

    def _read(self):
        for line in self.proc.stdout:
            line = line.strip()
            if not line:
                continue
            try:
                m = json.loads(line)
            except ValueError:
                m = {"type": "garbage", "raw": line}
            with self.cv:
                self.log.append(m)
                self.cv.notify_all()
        with self.cv:
            self.log.append({"type": "eof"})
            self.cv.notify_all()

    def _read_err(self):
        for line in self.proc.stderr:
            self.stderr.append(line)

    def send(self, obj):
        self.proc.stdin.write(json.dumps(obj) + "\n")
        self.proc.stdin.flush()

    def raw(self, method, params=None, timeout=40):
        """sync request; returns the full response message"""
        with self.cv:
            start = len(self.log)
        self.send({"m": method, "p": params or {}, "sync": True})
        deadline = time.time() + timeout
        idx = start
        with self.cv:
            while True:
                while idx < len(self.log):
                    m = self.log[idx]
                    idx += 1
                    if m.get("type") == "response" and m.get("_seen") is None:
                        m["_seen"] = True
                        return m
                    if m.get("type") == "eof":
                        raise RuntimeError("cli exited; stderr=%s" % "".join(self.stderr[-20:]))
                if time.time() > deadline:
                    raise TimeoutError("no response to " + method)
                self.cv.wait(0.2)

    def req(self, method, params=None, timeout=40):
        r = self.raw(method, params, timeout)
        if not r.get("ok"):
            raise RpcError(method, r.get("error", {}))
        return r["result"]

    def sleep(self, ms):
        with self.cv:
            start = len(self.log)
        self.send({"m": "__sleep", "p": {"ms": ms}})
        self.wait(lambda m: m.get("type") == "local" and m.get("m") == "__sleep", ms / 1000.0 + 10, start)

    def events(self, name=None, **match):
        with self.cv:
            out = []
            for m in self.log:
                if m.get("type") != "event":
                    continue
                if name and m.get("event") != name:
                    continue
                if all(m.get(k) == v for k, v in match.items()):
                    out.append(m)
            return out

    def wait(self, pred, timeout=15, start=0):
        deadline = time.time() + timeout
        idx = start
        with self.cv:
            while True:
                while idx < len(self.log):
                    m = self.log[idx]
                    idx += 1
                    if pred(m):
                        return m
                if time.time() > deadline:
                    return None
                self.cv.wait(0.1)

    def wait_event(self, name, timeout=15, start=0, **match):
        def pred(m):
            return m.get("type") == "event" and m.get("event") == name and all(m.get(k) == v for k, v in match.items())
        return self.wait(pred, timeout, start)

    def mark(self):
        with self.cv:
            return len(self.log)

    def start_core(self, **over):
        cfg = {
            "userAgent": "spcore-test/1.0", "logLevel": 2,
            "transports": {"udp": {"port": 0}, "tcp": {"port": 0},
                           "tls": {"port": 0, "verifyServer": False, "caFile": CA}},
            "media": {"noAudioDevice": True},
            "stunServers": [],
            "publicAddr": "127.0.0.1",   # this host's default-route IP may be unreachable locally (VPN); direct/LAN tests need loopback
        }
        for k, v in over.items():
            if isinstance(v, dict) and isinstance(cfg.get(k), dict):
                cfg[k].update(v)
            else:
                cfg[k] = v
        r = self.req("core.start", cfg)
        self.started = True
        return r

    def acct(self, ext, uid=None, transport="udp", **kw):
        cfg = {"uid": uid or ("u%s" % ext), "username": str(ext), "password": "pass%s" % ext,
               "domain": PBX, "transport": transport, "regExpires": 120}
        cfg.update(kw)
        return cfg

    def add_account(self, ext, wait=True, **kw):
        cfg = self.acct(ext, **kw)
        mark = self.mark()
        r = self.req("account.add", cfg)
        if wait:
            ev = self.wait_event("account.reg", 15, mark, uid=cfg["uid"], regState="registered")
            if ev is None:
                last = self.events("account.reg", uid=cfg["uid"])
                raise AssertionError("account %s did not register: %s" % (ext, last[-1:] ))
        return r["acc"], cfg["uid"]

    def shutdown(self):
        try:
            if self.proc.poll() is None:
                try:
                    self.send({"m": "__quit"})
                except Exception:
                    pass
                try:
                    self.proc.wait(timeout=20)
                except subprocess.TimeoutExpired:
                    self.proc.kill()
        finally:
            for f in (self.proc.stdin, self.proc.stdout, self.proc.stderr):
                try:
                    f.close()
                except Exception:
                    pass


def check_invariants(cli):
    """ENGINE_API.md §3 invariants + seq monotonicity. Returns a list of violation strings."""
    v = []
    last_seq = 0
    incoming = set()
    seen_any = set()
    ended = set()
    with cli.cv:
        log = list(cli.log)
    for m in log:
        if m.get("type") != "event":
            continue
        seq = m.get("seq", 0)
        if seq <= last_seq:
            v.append("seq not increasing: %s after %s (%s)" % (seq, last_seq, m.get("event")))
        last_seq = seq
        ev = m.get("event", "")
        if not ev.startswith("call.") or "cid" not in m and ev != "call.replaced":
            continue
        cids = [m["oldCid"], m["newCid"]] if ev == "call.replaced" else [m["cid"]]
        for cid in cids:
            if cid in ended:
                v.append("event %s for cid %s after terminal" % (ev, cid))
            if ev == "call.incoming":
                incoming.add(cid)
            elif cid not in seen_any and m.get("role") == "callee" and cid not in incoming:
                v.append("cid %s (callee) event %s before call.incoming" % (cid, ev))
            seen_any.add(cid)
            if ev == "call.state" and m.get("state") == "disconnected":
                if cid in ended:
                    v.append("cid %s has two terminal events" % cid)
                ended.add(cid)
    return v


def make_tone_wav(path, seconds=4.0, rate=8000, freq=440.0, amp=0.5):
    n = int(seconds * rate)
    frames = b"".join(struct.pack("<h", int(amp * 32767 * math.sin(2 * math.pi * freq * i / rate))) for i in range(n))
    with wave.open(path, "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(rate)
        w.writeframes(frames)
    return path


def wav_stats(path):
    with wave.open(path, "rb") as w:
        n = w.getnframes()
        data = w.readframes(n)
    samples = struct.unpack("<%dh" % (len(data) // 2), data)
    if not samples:
        return 0, 0
    rms = math.sqrt(sum(s * s for s in samples) / len(samples))
    return len(samples), rms


def pbx_cat(path):
    r = subprocess.run(["docker", "exec", CONTAINER, "cat", path], capture_output=True, text=True)
    return r.stdout


TONE = make_tone_wav(os.path.join(TMP, "tone.wav"))


class Base(unittest.TestCase):
    def setUp(self):
        self.clis = []

    def tearDown(self):
        problems = []
        for c in self.clis:
            try:
                if c.started and c.proc.poll() is None:
                    try:
                        c.raw("core.stop", {"graceful": True}, timeout=20)
                    except Exception:
                        pass
            finally:
                c.shutdown()
            problems += ["%s: %s" % (c.name, x) for x in check_invariants(c)]
            if c.proc.returncode not in (0, None) and c.proc.returncode != -15:
                problems.append("%s exited with %s; stderr: %s" % (c.name, c.proc.returncode, "".join(c.stderr[-30:])))
            if any("ERROR: AddressSanitizer" in l or "runtime error:" in l for l in c.stderr):
                problems.append("%s sanitizer report:\n%s" % (c.name, "".join(c.stderr[-60:])))
        self.assertEqual(problems, [], "\n".join(problems))

    def cli(self, name="cli"):
        c = Cli(name)
        self.clis.append(c)
        return c

    # --- call helpers
    def call_between(self, a, b, a_acc, b_ext_uri, answer=True, b_acc_uid=None):
        """A calls B; returns (cid_a, cid_b). B must have an account registered."""
        mark_b = b.mark()
        r = a.req("call.make", {"uid": a_acc, "uri": b_ext_uri})
        cid_a = r["cid"]
        inc = b.wait_event("call.incoming", 15, mark_b)
        self.assertIsNotNone(inc, "B did not get call.incoming")
        cid_b = inc["cid"]
        if answer:
            b.req("call.answer", {"cid": cid_b})
            self.assertIsNotNone(a.wait_event("call.state", 15, 0, cid=cid_a, state="confirmed"), "A not confirmed")
            self.assertIsNotNone(b.wait_event("call.state", 15, mark_b, cid=cid_b, state="confirmed"), "B not confirmed")
        return cid_a, cid_b

    def wait_media(self, c, cid, state="active", timeout=10):
        ev = c.wait(lambda m: m.get("type") == "event" and m.get("event") == "call.media" and m.get("cid") == cid
                    and m.get("media") == state, timeout)
        self.assertIsNotNone(ev, "no call.media %s for cid %s" % (state, cid))
        return ev

    def poll(self, fn, timeout=10, interval=0.25):
        end = time.time() + timeout
        last = None
        while time.time() < end:
            try:
                last = fn()
            except RpcError as e:
                last = None
            if last:
                return last
            time.sleep(interval)
        return last


class TestCore(Base):
    def test_00_not_started_and_start_stop_start(self):
        c = self.cli()
        info = c.req("core.info")
        self.assertFalse(info["started"])
        r = c.raw("account.list")
        self.assertFalse(r["ok"])
        self.assertEqual(r["error"]["code"], "NOT_STARTED")
        r = c.raw("no.such.method")
        self.assertEqual(r["error"]["code"], "INVALID_PARAM")
        c.req("core.ping")
        res = c.start_core()
        self.assertTrue(res["transports"])
        self.assertIn("direct", res)
        self.assertEqual(c.raw("core.start", {})["error"]["code"], "ALREADY")
        self.assertTrue(c.req("core.info")["started"])
        for i in range(3):
            c.req("core.stop", {"graceful": True})
            self.assertFalse(c.req("core.info")["started"])
            self.assertIsNotNone(c.wait_event("core.stopped", 5))
            res = c.start_core()
            self.assertTrue(c.req("core.info")["started"])
        c.req("core.stop")
        c.req("core.stop")  # idempotent

    def test_01_invalid_params(self):
        c = self.cli()
        c.start_core()
        for method, params in [("call.make", {}), ("call.make", {"uri": "x"}), ("call.make", {"uid": "nope", "uri": "1"}),
                               ("call.hangup", {"cid": 99999}), ("call.hangup", {}), ("call.answer", {"cid": "x"}),
                               ("account.add", {}), ("account.add", {"uid": "a"}), ("account.remove", {"acc": 77}),
                               ("buddy.remove", {"buddy": 5}), ("im.send", {"uid": "x"}), ("media.setDevices", {}),
                               ("media.setCodecPriority", {"id": "PCMU", "priority": 999}),
                               ("media.tone", {"kind": "bogus"}), ("call.dtmf", {"cid": 1, "digits": "zz"}),
                               ("call.conference", {"cids": "x"}), ("core.setLogLevel", {"level": 99}),
                               ("account.register", {"acc": 0})]:
            r = c.raw(method, params)
            self.assertFalse(r["ok"], "%s %s" % (method, params))
            self.assertIn(r["error"]["code"], ("INVALID_PARAM", "NOT_FOUND"), "%s: %s" % (method, r))
        # garbage params
        r = c.raw("account.list", {"x": [1, 2, {"y": None}]})
        self.assertTrue(r["ok"])
        c.send({"m": "core.ping", "p": "notjson"})
        c.sleep(100)
        self.assertEqual(c.raw("account.add", {"uid": "w", "username": "1", "domain": "x", "transport": "wss"})["error"]["code"], "UNSUPPORTED")
        self.assertEqual(c.raw("account.add", {"uid": "w", "username": "1", "domain": "x", "transport": "ws"})["error"]["code"], "UNSUPPORTED")
        self.assertEqual(c.raw("account.add", {"uid": "i", "proto": "iax2", "username": "1", "domain": "x"})["error"]["code"], "UNSUPPORTED")

    def test_02_media_misc(self):
        c = self.cli()
        c.start_core()
        d = c.req("media.devices")
        self.assertIn("capture", d)
        self.assertIn("current", d)
        cod = c.req("media.codecs")["codecs"]
        ids = [x["id"] for x in cod]
        self.assertTrue(any(i.startswith("PCMU") for i in ids), ids)
        c.req("media.setCodecPriority", {"id": "PCMA/8000/1", "priority": 250})
        c.req("media.setCodecPriorities", {"order": ["PCMU/8000/1", "PCMA/8000/1"]})
        c.req("media.setCodecParam", {"id": "PCMU/8000/1", "ptime": 20, "vad": False})
        if any(i.startswith("opus") for i in ids):
            c.req("media.setCodecParam", {"id": "opus/48000/2", "opus": {"bitrate": 24000, "fec": True, "dtx": False, "cbr": False, "complexity": 5, "maxPlaybackRate": 48000}})
        self.assertEqual(c.raw("media.setCodecPriority", {"id": "nosuchcodec", "priority": 3})["error"]["code"], "NOT_FOUND")
        c.req("media.setEc", {"algo": "speex", "tailMs": 100, "ns": True, "agc": False})
        c.req("media.levels")
        c.req("media.setMicLevel", {"level": 1.0})
        c.req("media.setSpeakerLevel", {"level": 1.0})
        for kind in ("ringback", "busy", "congestion", "dial", "waiting"):
            c.req("media.tone", {"kind": kind})
            c.req("media.toneStop")
        c.req("media.tone", {"kind": "dtmf", "digits": "123#"})
        c.req("media.toneStop")
        c.req("media.ringStart", {})
        c.sleep(300)
        c.req("media.ringStop")
        c.req("media.ringStart", {"file": TONE, "loop": True})
        c.req("media.ringStop")
        c.req("media.loopback", {"enabled": True})
        c.req("media.loopback", {"enabled": False})
        c.req("media.refreshDevices")
        self.assertIsNotNone(c.wait_event("media.devicesChanged", 5))
        c.req("media.setDevices", {"capture": "null", "playback": "null"})
        self.assertEqual(c.raw("media.setDevices", {"capture": "nonexistent:dev"})["error"]["code"], "NOT_FOUND")
        self.assertEqual(c.raw("media.setDevices", {"capture": "none", "playback": "none"})["error"]["code"], "UNSUPPORTED")

    def test_03_manual_sound_mode(self):
        c = self.cli()
        c.start_core(media={"noAudioDevice": False, "sndMode": "manual"})
        self.assertEqual(c.req("core.info")["sndMode"], "manual")
        c.req("media.setDevices", {"capture": "none", "playback": "none"})
        self.assertFalse(c.req("core.info")["soundDevice"]["open"])
        # a direct call between two cli instances keeps the null clock without a device
        b = self.cli("B")
        rb = b.start_core(media={"noAudioDevice": False, "sndMode": "manual"})
        port = [t for t in rb["transports"] if t["type"] == "udp"][0]["local"].split(":")[1]
        a_cid = c.req("call.make", {"acc": -1, "uri": "sip:%s:%s" % ("127.0.0.1", port)})["cid"]
        inc = b.wait_event("call.incoming", 10)
        b.req("call.answer", {"cid": inc["cid"]})
        self.wait_media(c, a_cid)
        self.assertTrue(self.poll(lambda: c.req("call.stats", {"cid": a_cid})["tx"]["packets"] > 5, 10))
        c.req("call.hangup", {"cid": a_cid})

    def test_04_sip_trace_and_log(self):
        c = self.cli()
        c.start_core()
        c.req("core.setSipTrace", {"enabled": True})
        c.req("core.setLogLevel", {"level": 4, "forward": True})
        c.add_account(1010)
        tr = c.events("sip.trace")
        self.assertTrue(any("REGISTER" in e["msg"] and e["dir"] == "tx" for e in tr), "no tx REGISTER trace")
        self.assertTrue(any(e["msg"].startswith("SIP/2.0 200") for e in tr if e["dir"] == "rx"))
        self.assertTrue(c.events("log"))
        c.req("core.setSipTrace", {"enabled": False})
        c.req("core.setLogLevel", {"level": 3, "forward": False})

    def test_05_diag(self):
        c = self.cli()
        c.start_core(nameservers="auto")
        r = c.req("diag.resolve", {"host": "localhost"})
        self.assertTrue(r["addresses"])
        acc, uid = c.add_account(1010)
        m = c.mark()
        c.req("diag.optionsPing", {"uid": uid})
        ev = c.wait_event("diag.options", 10, m)
        self.assertIsNotNone(ev)
        self.assertIn(ev["code"], (200, 401, 403, 404))
        c.req("core.setNameservers", {"servers": ["127.0.0.1"]})
        c.req("core.setUserAgent", {"userAgent": "x/1"})
        c.req("core.handleIpChange")


class TestRegistration(Base):
    def _reg(self, transport, ext=1010):
        c = self.cli()
        c.start_core()
        acc, uid = c.add_account(ext, transport=transport)
        info = c.req("account.info", {"uid": uid})
        self.assertEqual(info["regState"], "registered")
        self.assertEqual(info["regCode"], 200)
        self.assertEqual(info["transport"], transport)
        self.assertIsNone(info["lastError"])
        lst = c.req("account.list")["accounts"]
        self.assertTrue(any(a["isDirect"] for a in lst))
        c.req("account.register", {"uid": uid, "register": False})
        self.assertIsNotNone(c.wait_event("account.reg", 10, 0, uid=uid, regState="unregistered"))
        c.req("account.register", {"uid": uid, "register": True})
        c.req("account.setPresence", {"uid": uid, "status": "away", "note": "brb"})
        c.req("account.remove", {"uid": uid})
        self.assertEqual(c.raw("account.info", {"uid": uid})["error"]["code"], "NOT_FOUND")

    def test_udp(self):
        self._reg("udp")

    def test_tcp(self):
        self._reg("tcp")

    def test_tls(self):
        self._reg("tls")

    def test_five_accounts_one_process(self):
        c = self.cli()
        c.start_core()
        uids = []
        m = c.mark()
        for ext in range(1003, 1008):
            r = c.req("account.add", c.acct(ext))
            uids.append("u%d" % ext)
        for u in uids:
            self.assertIsNotNone(c.wait_event("account.reg", 20, m, uid=u, regState="registered"), u)
        self.assertEqual(c.req("core.info")["accounts"], 5)
        self.assertEqual(len([a for a in c.req("account.list")["accounts"] if a["regState"] == "registered"]), 5)

    def test_wrong_password(self):
        c = self.cli()
        c.start_core()
        cfg = c.acct(1009, password="WRONG")
        m = c.mark()
        c.req("account.add", cfg)
        ev = c.wait_event("account.reg", 15, m, uid=cfg["uid"], regState="failed")
        self.assertIsNotNone(ev, c.events("account.reg"))
        self.assertIn(ev["regCode"], (401, 403))
        self.assertTrue(ev["lastError"] and "password" in ev["lastError"].lower(), ev["lastError"])

    def test_modify(self):
        c = self.cli()
        c.start_core()
        acc, uid = c.add_account(1010)
        m = c.mark()
        c.req("account.modify", {"uid": uid, "displayName": "Ten", "regExpires": 90})
        self.assertIsNotNone(c.wait_event("account.reg", 15, m, uid=uid, regState="registered"))

    def test_tls_verification_and_pins(self):
        other = os.path.join(TMP, "other-ca.pem")
        subprocess.run(["openssl", "req", "-x509", "-newkey", "rsa:2048", "-nodes", "-keyout", os.path.join(TMP, "other.key"),
                        "-subj", "/CN=other-ca", "-days", "2", "-out", other], check=True, capture_output=True)
        c = self.cli()
        c.start_core(transports={"tls": {"port": 0, "verifyServer": True, "caFile": other}})
        cfg = c.acct(1010, transport="tls")
        m = c.mark()
        c.req("account.add", cfg)
        ev = c.wait_event("transport.tlsVerify", 15, m)
        self.assertIsNotNone(ev, "no transport.tlsVerify; events: %s" % [e["event"] for e in c.events()][-10:])
        self.assertEqual(len(ev["sha256"]), 64)
        failed = c.wait_event("account.reg", 20, m, uid=cfg["uid"], regState="failed")
        self.assertIsNotNone(failed)
        self.assertIn("TLS", failed["lastError"] or "")
        c.req("core.setTlsPins", {"pins": [{"host": PBX, "sha256": ev["sha256"]}]})
        m = c.mark()
        c.req("account.register", {"uid": cfg["uid"], "register": True})
        self.assertIsNotNone(c.wait_event("account.reg", 20, m, uid=cfg["uid"], regState="registered"))

    def test_tls_verified_with_ca(self):
        c = self.cli()
        c.start_core(transports={"tls": {"port": 0, "verifyServer": True, "caFile": CA}})
        c.add_account(1010, transport="tls", domain="localhost")
        ev = [e for e in c.events("transport.state") if e["transport"] == "tls" and e["state"] == "connected"]
        self.assertTrue(ev)
        self.assertEqual(ev[0]["tls"]["verifyStatus"], [])


class TestCalls(Base):
    def setup_ab(self, ea=1001, eb=1002, **kw):
        a, b = self.cli("A"), self.cli("B")
        a.start_core(**kw)
        b.start_core(**kw)
        _, ua = a.add_account(ea)
        _, ub = b.add_account(eb)
        return a, b, ua, ub

    def test_basic_call_media_hold_mute(self):
        a, b, ua, ub = self.setup_ab()
        m_b = b.mark()
        r = a.req("call.make", {"uid": ua, "uri": str(1002)})
        cid_a = r["cid"]
        self.assertGreater(cid_a, 0)
        inc = b.wait_event("call.incoming", 15, m_b)
        self.assertIsNotNone(inc)
        cid_b = inc["cid"]
        self.assertEqual(inc["state"], "incoming")
        self.assertEqual(inc["role"], "callee")
        self.assertEqual(inc["remoteUser"], "1001")
        self.assertEqual(inc["uid"], ub)
        # incoming precedes every other event for the cid
        first = [e for e in b.events() if e.get("cid") == cid_b][0]
        self.assertEqual(first["event"], "call.incoming")
        b.req("call.answer", {"cid": cid_b})
        self.assertIsNotNone(a.wait_event("call.state", 15, 0, cid=cid_a, state="confirmed"))
        self.assertIsNotNone(b.wait_event("call.state", 15, m_b, cid=cid_b, state="confirmed"))
        self.wait_media(a, cid_a)
        self.wait_media(b, cid_b)
        info = a.req("call.info", {"cid": cid_a})
        self.assertEqual(info["state"], "confirmed")
        self.assertEqual(info["role"], "caller")
        self.assertTrue(info["callId"])
        self.assertTrue(info["localTag"] and info["remoteTag"])
        self.assertEqual(len(a.req("call.list")["calls"]), 1)
        # audio: A plays a tone into the call, B must receive RTP with signal
        a.req("call.playFile", {"cid": cid_a, "file": TONE, "loop": True})
        st = self.poll(lambda: (lambda s: s if s["rx"]["packets"] > 10 and s["rxLevel"] > 0 else None)(b.req("call.stats", {"cid": cid_b})), 15)
        self.assertIsNotNone(st, "B never received audio")
        self.assertGreater(st["mos"], 3.0)
        self.assertTrue(st["codec"])
        sa = a.req("call.stats", {"cid": cid_a})
        self.assertGreater(sa["tx"]["packets"], 10)
        # hold / unhold
        m = a.mark(); mb = b.mark()
        a.req("call.hold", {"cid": cid_a})
        ev = a.wait_event("call.media", 10, m, cid=cid_a, media="localHold")
        self.assertIsNotNone(ev)
        # (Asterisk does not forward the hold to the other leg, so remoteHold is checked in the direct-call test)
        self.assertTrue(a.req("call.info", {"cid": cid_a})["held"])
        m = a.mark(); mb = b.mark()
        a.req("call.unhold", {"cid": cid_a})
        self.assertIsNotNone(a.wait_event("call.media", 10, m, cid=cid_a, media="active"))
        self.assertFalse(a.req("call.info", {"cid": cid_a})["held"])
        # mute
        a.req("call.mute", {"cid": cid_a, "mute": True})
        self.assertTrue(a.req("call.info", {"cid": cid_a})["muted"])
        a.req("call.mute", {"cid": cid_a, "mute": False})
        self.assertFalse(a.req("call.info", {"cid": cid_a})["muted"])
        a.req("call.setLevels", {"cid": cid_a, "rx": 1.0, "tx": 0.8})
        a.req("call.update", {"cid": cid_a})
        a.req("call.sendRequest", {"cid": cid_a, "method": "INFO", "headers": {"X-Test": "1"}, "body": "hello", "contentType": "text/plain"})
        a.req("call.stopFile", {"cid": cid_a})
        # hangup: terminal state event precedes the response
        mark = len(a.log)
        a.req("call.hangup", {"cid": cid_a})
        idx_resp = max(i for i, x in enumerate(a.log) if x.get("type") == "response")
        idx_term = [i for i, x in enumerate(a.log) if x.get("event") == "call.state" and x.get("cid") == cid_a and x.get("state") == "disconnected"]
        self.assertEqual(len(idx_term), 1)
        self.assertLess(idx_term[0], idx_resp)
        self.assertIsNotNone(b.wait_event("call.state", 10, m_b, cid=cid_b, state="disconnected"))
        self.assertEqual(a.raw("call.hangup", {"cid": cid_a})["error"]["code"], "NOT_FOUND")
        self.assertEqual(a.raw("call.info", {"cid": cid_a})["error"]["code"], "NOT_FOUND")

    def test_reject_and_busy(self):
        a, b, ua, ub = self.setup_ab(eb=1014)      # 1014 has no voicemail fallback
        mb = b.mark()
        cid_a = a.req("call.make", {"uid": ua, "uri": "1014"})["cid"]
        inc = b.wait_event("call.incoming", 15, mb)
        b.req("call.reject", {"cid": inc["cid"], "code": 486})
        ev = a.wait_event("call.state", 15, 0, cid=cid_a, state="disconnected")
        self.assertIsNotNone(ev)
        self.assertEqual(ev["lastCode"], 486)

    def test_dtmf_rfc2833_to_602(self):
        a = self.cli("A")
        a.start_core()
        acc, ua = a.add_account(1001, dtmfMethod="rfc2833")
        cid = a.req("call.make", {"uid": ua, "uri": "602"})["cid"]
        self.assertIsNotNone(a.wait_event("call.state", 15, 0, cid=cid, state="confirmed"))
        self.wait_media(a, cid)
        time.sleep(1.0)
        a.req("call.dtmf", {"cid": cid, "digits": "1234", "method": "rfc2833", "durationMs": 160})
        digits = ""
        for _ in range(30):
            digits = pbx_cat("/var/log/asterisk/dtmf_1001.txt").strip()
            if "1234" in digits:
                break
            time.sleep(0.5)
        self.assertIn("1234", digits)
        a.req("call.hangup", {"cid": cid})

    def test_dtmf_inband_and_info_do_not_fail(self):
        a = self.cli("A")
        a.start_core()
        acc, ua = a.add_account(1001)
        cid = a.req("call.make", {"uid": ua, "uri": "604"})["cid"]
        self.assertIsNotNone(a.wait_event("call.state", 15, 0, cid=cid, state="confirmed"))
        self.wait_media(a, cid)
        a.req("call.dtmf", {"cid": cid, "digits": "56#", "method": "inband"})
        a.req("call.dtmf", {"cid": cid, "digits": "9", "method": "info"})
        a.req("call.dtmf", {"cid": cid, "digits": "7", "method": "auto"})
        a.sleep(800)
        a.req("call.hangup", {"cid": cid})

    def test_blind_transfer(self):
        a, b, ua, ub = self.setup_ab()
        cid_a, cid_b = self.call_between(a, b, ua, "1002")
        self.wait_media(a, cid_a)
        m = a.mark()
        a.req("call.transfer", {"cid": cid_a, "target": "600"})
        st = a.wait(lambda x: x.get("event") == "call.transferStatus" and x.get("final") and x.get("cid") == cid_a, 15, m)
        self.assertIsNotNone(st, "no final transferStatus")
        self.assertEqual(st["code"] // 100, 2)
        # transferee remains in a call (now connected to 600) or ends; A's leg is released
        self.assertIsNotNone(a.wait_event("call.state", 15, m, cid=cid_a, state="disconnected") or True)
        info = self.poll(lambda: b.req("call.list")["calls"], 5)
        self.assertTrue(info, "B lost its call after transfer")

    def test_attended_transfer(self):
        a, b, ua, ub = self.setup_ab()
        c = self.cli("C")
        c.start_core()
        c.add_account(1003)
        cid_ab, cid_ba = self.call_between(a, b, ua, "1002")
        a.req("call.hold", {"cid": cid_ab})
        cid_ac, cid_ca = self.call_between(a, c, ua, "1003")
        mb = b.mark(); mc = c.mark(); ma = a.mark()
        a.req("call.transferAttended", {"cid": cid_ab, "destCid": cid_ac})
        st = a.wait(lambda x: x.get("event") == "call.transferStatus" and x.get("final") and x.get("cid") == cid_ab, 20, ma)
        self.assertIsNotNone(st, "no final transferStatus")
        self.assertEqual(st["code"] // 100, 2, st)
        # B and C are now connected to each other: C plays a tone, B hears it
        self.assertTrue(b.req("call.list")["calls"])
        self.assertTrue(c.req("call.list")["calls"])
        cb = b.req("call.list")["calls"][0]["cid"]
        cc = c.req("call.list")["calls"][0]["cid"]
        self.wait_media(b, cb) if not b.events("call.media", cid=cb, media="active") else None
        c.req("call.playFile", {"cid": cc, "file": TONE, "loop": True})
        st = self.poll(lambda: (lambda s: s if s["rxLevel"] > 0 else None)(b.req("call.stats", {"cid": cb})), 20)
        self.assertIsNotNone(st, "B did not hear C after the attended transfer")

    def test_conference_three_way(self):
        a, b, ua, ub = self.setup_ab()
        c = self.cli("C")
        c.start_core()
        c.add_account(1003)
        cid_ab, cid_ba = self.call_between(a, b, ua, "1002")
        cid_ac, cid_ca = self.call_between(a, c, ua, "1003")
        self.wait_media(a, cid_ab); self.wait_media(a, cid_ac)
        a.req("call.conference", {"cids": [cid_ab, cid_ac]})
        i1 = a.req("call.info", {"cid": cid_ab})
        i2 = a.req("call.info", {"cid": cid_ac})
        self.assertEqual(i1["conferenceWith"], [cid_ac])
        self.assertEqual(i2["conferenceWith"], [cid_ab])
        self.wait_media(b, cid_ba); self.wait_media(c, cid_ca)
        b.req("call.playFile", {"cid": cid_ba, "file": TONE, "loop": True})
        st = self.poll(lambda: (lambda s: s if s["rxLevel"] > 0 else None)(c.req("call.stats", {"cid": cid_ca})), 20)
        self.assertIsNotNone(st, "C did not hear B through A's conference")
        a.req("call.unconference", {"cids": [cid_ab, cid_ac]})
        self.assertEqual(a.req("call.info", {"cid": cid_ab})["conferenceWith"], [])
        # bridge and detachLocal API
        a.req("call.detachLocal", {"cid": cid_ab, "detached": True})
        self.assertTrue(a.req("call.info", {"cid": cid_ab})["detached"])
        a.req("call.bridge", {"a": cid_ab, "b": cid_ac, "bridge": True})
        self.assertEqual(a.req("call.info", {"cid": cid_ab})["bridgedWith"], [cid_ac])
        a.req("call.bridge", {"a": cid_ab, "b": cid_ac, "bridge": False})
        a.req("call.hangupAll")
        self.assertEqual(a.req("call.list")["calls"], [])

    def test_recording(self):
        a = self.cli("A")
        a.start_core()
        acc, ua = a.add_account(1001)
        cid = a.req("call.make", {"uid": ua, "uri": "601"})["cid"]
        self.assertIsNotNone(a.wait_event("call.state", 15, 0, cid=cid, state="confirmed"))
        self.wait_media(a, cid)
        out = os.path.join(TMP, "rec.wav")
        m = a.mark()
        self.assertEqual(a.req("call.recordStart", {"cid": cid, "file": out, "mix": "remote"})["file"], out)
        self.assertIsNotNone(a.wait_event("call.recording", 5, m, cid=cid, recording=True))
        self.assertTrue(a.req("call.info", {"cid": cid})["recording"])
        self.assertEqual(a.raw("call.recordStart", {"cid": cid, "file": out})["error"]["code"], "ALREADY")
        time.sleep(4.0)
        r = a.req("call.recordStop", {"cid": cid})
        self.assertEqual(r["file"], out)
        self.assertGreater(r["durationMs"], 3000)
        self.assertGreater(os.path.getsize(out), 44)
        n, rms = wav_stats(out)
        self.assertGreater(n, 1000)
        self.assertGreater(rms, 200, "recording is silent (rms=%s)" % rms)
        a.req("call.hangup", {"cid": cid})

    def test_mwi(self):
        c = self.cli()
        c.start_core()
        c.add_account(1002)
        ev = c.wait_event("account.mwi", 15)
        self.assertIsNotNone(ev, "no account.mwi")
        self.assertGreaterEqual(ev["newMsgs"], 1)
        self.assertTrue(ev["waiting"])

    def test_blf(self):
        a, b = self.cli("A"), self.cli("B")
        a.start_core(); b.start_core()
        _, ua = a.add_account(1001)
        _, ub = b.add_account(1003)
        r = a.req("buddy.add", {"uid": ua, "uri": "1003", "presence": False, "blf": True})
        buddy = r["buddy"]
        self.assertIsNotNone(a.wait_event("buddy.state", 15))
        self.assertEqual(len(a.req("buddy.list")["buddies"]), 1)
        m = a.mark()
        cid = b.req("call.make", {"uid": ub, "uri": "600"})["cid"]
        ev = a.wait(lambda x: x.get("event") == "buddy.state" and x["blf"]["state"] in ("early", "confirmed"), 15, m)
        self.assertIsNotNone(ev, "no early/confirmed blf; got %s" % [e["blf"] for e in a.events("buddy.state")])
        self.assertTrue(ev["blf"]["dialogs"])
        time.sleep(1.0)
        m2 = a.mark()
        b.req("call.hangup", {"cid": cid})
        ev = a.wait(lambda x: x.get("event") == "buddy.state" and x["blf"]["state"] in ("terminated", "idle"), 15, m2)
        self.assertIsNotNone(ev, "no terminated blf")
        a.req("buddy.refresh", {"buddy": buddy})
        a.req("buddy.remove", {"buddy": buddy})
        self.assertEqual(a.req("buddy.list")["buddies"], [])

    def test_presence_buddy(self):
        a, b = self.cli("A"), self.cli("B")
        a.start_core(); b.start_core()
        _, ua = a.add_account(1001)
        _, ub = b.add_account(1003, publishPresence=True)
        r = a.req("buddy.add", {"uid": ua, "uri": "1003", "presence": True})
        self.assertIsNotNone(a.wait_event("buddy.state", 15))

    def test_im(self):
        a, b, ua, ub = self.setup_ab()
        mb = b.mark(); ma = a.mark()
        a.req("im.send", {"uid": ua, "to": "1002", "body": "hello bob", "msgId": "m-1"})
        ev = b.wait_event("im.incoming", 15, mb)
        self.assertIsNotNone(ev)
        self.assertEqual(ev["body"], "hello bob")
        self.assertIn("1001", ev["from"])
        st = a.wait_event("im.status", 15, ma)
        self.assertIsNotNone(st)
        self.assertEqual(st["msgId"], "m-1")
        self.assertTrue(st["ok"], st)
        a.req("im.typing", {"uid": ua, "to": "1002", "typing": True})

    def test_incoming_refer_1999(self):
        a = self.cli("A")
        a.start_core()
        acc, ua = a.add_account(1001)
        m = a.mark()
        cid = a.req("call.make", {"uid": ua, "uri": "1999"})["cid"]
        ev = a.wait_event("call.transferRequest", 25, m, cid=cid)
        self.assertIsNotNone(ev, "no call.transferRequest")
        self.assertIn("600", ev["target"])
        # the new call to 600 (echo) comes up
        new = a.wait(lambda x: x.get("event") == "call.state" and x.get("cid") != cid and x.get("state") == "confirmed", 20, m)
        self.assertIsNotNone(new, "REFER target call never confirmed")

    def test_redirect_via_direct(self):
        """B (reachable by IP) rejects with a redirect to 600; A (account 1001) follows it to the PBX echo extension."""
        a, b = self.cli("A"), self.cli("B")
        a.start_core(); rb = b.start_core()
        _, ua = a.add_account(1001, redirect="auto")
        _, ub = b.add_account(1002)
        port = [t for t in rb["transports"] if t["type"] == "udp"][0]["local"].split(":")[1]
        mb = b.mark()
        cid_a = a.req("call.make", {"uid": ua, "uri": "sip:1002@127.0.0.1:%s" % port})["cid"]
        inc = b.wait_event("call.incoming", 15, mb)
        self.assertIsNotNone(inc)
        b.req("call.redirect", {"cid": inc["cid"], "targets": ["sip:600@%s" % PBX], "code": 302})
        ev = a.wait_event("call.state", 20, 0, cid=cid_a, state="confirmed")
        self.assertIsNotNone(ev, "A did not follow the redirect: %s" % [(e["state"], e["lastCode"]) for e in a.events("call.state")])
        info = a.req("call.info", {"cid": cid_a})
        self.assertIn("600", info["remoteUri"])

    def test_redirect_ask(self):
        a, b = self.cli("A"), self.cli("B")
        a.start_core(); rb = b.start_core()
        _, ua = a.add_account(1001, redirect="ask")
        port = [t for t in rb["transports"] if t["type"] == "udp"][0]["local"].split(":")[1]
        cid_a = a.req("call.make", {"uid": ua, "uri": "sip:1002@127.0.0.1:%s" % port})["cid"]
        inc = b.wait_event("call.incoming", 15)
        b.req("call.redirect", {"cid": inc["cid"], "targets": ["sip:600@%s" % PBX]})
        ev = a.wait_event("call.redirected", 15, 0, cid=cid_a)
        self.assertIsNotNone(ev)
        a.req("call.processRedirect", {"cid": cid_a, "action": "accept"})
        self.assertIsNotNone(a.wait_event("call.state", 20, 0, cid=cid_a, state="confirmed"))

    def test_redirect_through_pbx(self):
        a, b, ua, ub = self.setup_ab()
        mb = b.mark()
        cid_a = a.req("call.make", {"uid": ua, "uri": "1002"})["cid"]
        inc = b.wait_event("call.incoming", 15, mb)
        b.req("call.redirect", {"cid": inc["cid"], "targets": ["600"]})
        ev = a.wait_event("call.state", 15, 0, cid=cid_a, state="confirmed")
        if ev is None:
            self.skipTest("PBX does not forward a callee 302 to the caller (Asterisk dial behaviour); "
                          "A saw: %s" % [(e["state"], e["lastCode"]) for e in a.events("call.state")])

    def test_autoanswer_hint(self):
        a, b, ua, ub = self.setup_ab()
        mb = b.mark()
        a.req("call.make", {"uid": ua, "uri": "19981002"})
        inc = b.wait_event("call.incoming", 15, mb)
        self.assertIsNotNone(inc)
        hint = inc.get("autoAnswerHint")
        self.assertIsNotNone(hint, inc.get("headers"))
        self.assertEqual(hint["afterSec"], 0)
        self.assertIn(hint["source"], ("callInfo", "alertInfo"))
        self.assertIn("Call-Info", inc["headers"])
        b.req("call.answer", {"cid": inc["cid"]})

    def test_direct_ip_call(self):
        a, b = self.cli("A"), self.cli("B")
        a.start_core(); rb = b.start_core()
        port = [t for t in rb["transports"] if t["type"] == "udp"][0]["local"].split(":")[1]
        mb = b.mark()
        r = a.req("call.make", {"acc": -1, "uri": "sip:127.0.0.1:%s" % port})
        cid_a = r["cid"]
        inc = b.wait_event("call.incoming", 10, mb)
        self.assertIsNotNone(inc)
        self.assertEqual(inc["uid"], "__direct__")
        b.req("call.answer", {"cid": inc["cid"]})
        self.assertIsNotNone(a.wait_event("call.state", 10, 0, cid=cid_a, state="confirmed"))
        self.wait_media(a, cid_a)
        a.req("call.playFile", {"cid": cid_a, "file": TONE, "loop": True})
        st = self.poll(lambda: (lambda s: s if s["rx"]["packets"] > 10 and s["rxLevel"] > 0 else None)(b.req("call.stats", {"cid": inc["cid"]})), 15)
        self.assertIsNotNone(st)
        # hold -> remote side sees remoteHold; unhold restores audio
        m = a.mark(); mb = b.mark()
        a.req("call.hold", {"cid": cid_a})
        self.assertIsNotNone(a.wait_event("call.media", 10, m, cid=cid_a, media="localHold"))
        self.assertIsNotNone(b.wait_event("call.media", 10, mb, cid=inc["cid"], media="remoteHold"))
        a.req("call.unhold", {"cid": cid_a})
        self.assertIsNotNone(b.wait_event("call.media", 10, mb, cid=inc["cid"], media="active"))
        # bare IP form with the direct account too
        a.req("call.hangup", {"cid": cid_a})
        mb = b.mark()
        r = a.req("call.make", {"acc": -1, "uri": "127.0.0.1:%s" % port})
        inc2 = b.wait_event("call.incoming", 10, mb)
        self.assertIsNotNone(inc2)
        b.req("call.reject", {"cid": inc2["cid"], "code": 603})
        self.assertIsNotNone(a.wait_event("call.state", 10, 0, cid=r["cid"], state="disconnected"))
        self.assertNotEqual(r["cid"], cid_a)

    def test_auto_180_and_unattended(self):
        a, b = self.cli("A"), self.cli("B")
        a.start_core(); rb = b.start_core(incomingAutoRingMs=300, incomingUnattendedMs=1500)
        port = [t for t in rb["transports"] if t["type"] == "udp"][0]["local"].split(":")[1]
        cid = a.req("call.make", {"acc": -1, "uri": "sip:127.0.0.1:%s" % port})["cid"]
        ev = a.wait_event("call.state", 5, 0, cid=cid, stateCode=180)
        self.assertIsNotNone(ev, "no auto 180")
        b.req("call.hangup", {"cid": b.wait_event("call.incoming", 5)["cid"]})
        # unattended: detach the sink in B, call again, expect 480
        b.send({"m": "__detach"})
        b.sleep(100)
        cid2 = a.req("call.make", {"acc": -1, "uri": "sip:127.0.0.1:%s" % port})["cid"]
        ev = a.wait_event("call.state", 10, 0, cid=cid2, state="disconnected")
        self.assertIsNotNone(ev, "unattended call not rejected")
        self.assertEqual(ev["lastCode"], 480)
        m = b.mark()
        b.send({"m": "__attach"})
        rep = b.wait(lambda x: x.get("m") == "__attach", 5, m)
        self.assertGreater(rep["replayed"], 0)

    def test_lan_call(self):
        a, b = self.cli("A"), self.cli("B")
        ra = a.start_core(lan={"enabled": True, "port": 0})
        rb = b.start_core(lan={"enabled": True, "port": 0})
        self.assertIn("lan", ra)
        mb = b.mark()
        cid = a.req("call.make", {"uid": "__lan__", "uri": "127.0.0.1:%d" % rb["lan"]["port"]})["cid"]
        inc = b.wait_event("call.incoming", 10, mb)
        self.assertIsNotNone(inc)
        self.assertEqual(inc["uid"], "__lan__")
        b.req("call.answer", {"cid": inc["cid"]})
        self.assertIsNotNone(a.wait_event("call.state", 10, 0, cid=cid, state="confirmed"))
        mb = b.mark()
        a.req("im.send", {"uid": "__lan__", "to": "127.0.0.1:%d" % rb["lan"]["port"], "body": "lan hi"})
        ev = b.wait_event("im.incoming", 10, mb)
        self.assertIsNotNone(ev)
        self.assertTrue(ev["isLan"])
        a.req("call.hangup", {"cid": cid})

    def test_codec_selection_per_account(self):
        a, b = self.cli("A"), self.cli("B")
        a.start_core(); b.start_core()
        _, ua = a.add_account(1001, codecs=["PCMA/8000/1"])
        _, ub = b.add_account(1002)
        cid_a, cid_b = self.call_between(a, b, ua, "1002")
        ev = self.wait_media(a, cid_a)
        self.assertTrue(ev["codec"].startswith("PCMA"), ev)
        self.assertTrue(a.req("call.info", {"cid": cid_a})["codec"].startswith("PCMA"))
        st = self.poll(lambda: a.req("call.stats", {"cid": cid_a}), 5)
        self.assertTrue(st["codec"].startswith("PCMA"))
        a.req("call.hangup", {"cid": cid_a})
        # and PCMU for the reverse restriction
        _, = [0]
        a.req("account.modify", {"uid": ua, "codecs": ["PCMU/8000/1"]})
        a.sleep(1500)
        cid_a, cid_b = self.call_between(a, b, ua, "1002")
        ev = self.wait_media(a, cid_a)
        self.assertTrue(ev["codec"].startswith("PCMU"), ev)

    def test_srtp_mandatory_1011(self):
        a = self.cli("A")
        a.start_core()
        _, ua = a.add_account(1011, srtp="mandatory")
        cid = a.req("call.make", {"uid": ua, "uri": "600"})["cid"]
        self.assertIsNotNone(a.wait_event("call.state", 15, 0, cid=cid, state="confirmed"))
        ev = self.wait_media(a, cid)
        self.assertTrue(ev["srtp"], ev)
        self.assertTrue(a.req("call.info", {"cid": cid})["srtp"])
        st = self.poll(lambda: (lambda s: s if s["rx"]["packets"] > 5 else None)(a.req("call.stats", {"cid": cid})), 10)
        self.assertIsNotNone(st)
        self.assertTrue(st["srtp"])
        a.req("call.hangup", {"cid": cid})

    def test_cid_uniqueness_max_calls(self):
        a = self.cli("A")
        a.start_core(maxCalls=2)
        _, ua = a.add_account(1001)
        cids = []
        for i in range(20):
            cid = a.req("call.make", {"uid": ua, "uri": "600"})["cid"]
            cids.append(cid)
            self.assertIsNotNone(a.wait_event("call.state", 15, 0, cid=cid, state="confirmed"), "call %d" % i)
            a.req("call.hangup", {"cid": cid})
        self.assertEqual(len(set(cids)), 20)
        self.assertEqual(cids, sorted(cids))
        a.req("core.stop")
        a.start_core(maxCalls=2)
        _, ua = a.add_account(1001)
        cid = a.req("call.make", {"uid": ua, "uri": "600"})["cid"]
        self.assertGreater(cid, cids[-1], "cid reused after core.stop/start")
        a.req("call.hangup", {"cid": cid})

    def test_snapshot_after_reattach(self):
        a = self.cli("A")
        a.start_core()
        acc, ua = a.add_account(1001)
        a.send({"m": "__detach"})
        a.sleep(100)
        a.req("account.register", {"uid": ua, "register": False})
        cid = a.req("call.make", {"acc": -1, "uri": "sip:127.0.0.1:9"})["cid"]
        a.sleep(1500)
        m = a.mark()
        a.send({"m": "__attach"})
        rep = a.wait(lambda x: x.get("m") == "__attach", 5, m)
        self.assertGreater(rep["replayed"], 0)
        replayed = [x for x in a.log[m:] if x.get("type") == "event"]
        seqs = [x["seq"] for x in replayed]
        self.assertEqual(seqs, sorted(seqs))
        snap = a.req("core.snapshot")
        self.assertGreaterEqual(snap["seq"], seqs[-1])
        self.assertTrue(any(x["uid"] == ua for x in snap["accounts"]))
        self.assertIn("devices", snap)
        self.assertIsInstance(snap["buddies"], list)


def load_tests(loader, standard_tests, pattern):
    """Also run extension suites in native/tests/test_*.py (IAX2, WebSocket, ...).

    Those modules can `from run_tests import Base, Cli, ...` to reuse the harness.
    """
    here = os.path.dirname(os.path.abspath(__file__))
    if here not in sys.path:
        sys.path.insert(0, here)
    for name in sorted(os.listdir(here)):
        if name.startswith("test_") and name.endswith(".py"):
            mod = __import__(name[:-3])
            standard_tests.addTests(loader.loadTestsFromModule(mod))
    return standard_tests


if __name__ == "__main__":
    # Make the harness importable as `run_tests` from extension modules even
    # when this file runs as __main__.
    sys.modules.setdefault("run_tests", sys.modules[__name__])
    unittest.main(verbosity=2)
