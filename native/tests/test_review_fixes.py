"""Regression tests for the 2026-10-19 spcore review (docs/reviews/2026-10-19-spcore-review.md).

Loaded by run_tests.py (which auto-loads native/tests/test_*.py). Meant to also run under ASan/UBSan: the shared
Base.tearDown fails a test if the sanitizers printed anything.
"""
import json
import os
import random
import socket
import time
import unittest

from run_tests import Base, Cli, RpcError, PBX, TONE, TMP, pbx_cat


def async_req(c, method, params=None):
    """send a non-sync request; returns its request id"""
    mark = c.mark()
    c.send({"m": method, "p": params or {}})
    m = c.wait(lambda x: x.get("type") == "sent" and x.get("m") == method, 10, mark)
    assert m is not None, "request not accepted"
    return m["id"]


def wait_response(c, rid, timeout=30):
    return c.wait(lambda x: x.get("type") == "response" and x.get("id") == rid, timeout)


def direct_pair(test, **core):
    a, b = test.cli("A"), test.cli("B")
    a.start_core(**core)
    rb = b.start_core(**core)
    port = [t for t in rb["transports"] if t["type"] == "udp"][0]["local"].split(":")[1]
    return a, b, port


def direct_call(test, a, b, port):
    mb = b.mark()
    cid_a = a.req("call.make", {"acc": -1, "uri": "sip:127.0.0.1:%s" % port})["cid"]
    inc = b.wait_event("call.incoming", 10, mb)
    test.assertIsNotNone(inc)
    b.req("call.answer", {"cid": inc["cid"]})
    test.assertIsNotNone(a.wait_event("call.state", 10, 0, cid=cid_a, state="confirmed"))
    return cid_a, inc["cid"]


class TestC1ResolveTimeout(Base):
    def test_srv_blackholed_nameserver_times_out_and_engine_survives(self):
        """C1: the SRV query must be cancelled before its pool is released; the result is TIMEOUT, not ok+empty."""
        c = self.cli()
        c.start_core(nameservers=["10.255.255.1"])
        t0 = time.time()
        rid = async_req(c, "diag.resolve", {"host": "example.invalid", "srv": True})
        # the worker must stay responsive while the lookup is pending
        t1 = time.time()
        c.req("core.ping")
        self.assertLess(time.time() - t1, 1.0, "worker blocked by diag.resolve")
        r = wait_response(c, rid, 30)
        self.assertIsNotNone(r)
        self.assertFalse(r["ok"], r)
        self.assertEqual(r["error"]["code"], "TIMEOUT")
        self.assertGreater(time.time() - t0, 3.0)
        # keep the process alive well past the timeout: a late DNS callback / helper thread must not crash it
        c.sleep(15000)
        c.req("core.ping")
        # a plain address lookup works and never blocks the worker either
        r = c.req("diag.resolve", {"host": "localhost"})
        self.assertTrue(r["addresses"])

    def test_resolve_survives_core_stop_while_pending(self):
        c = self.cli()
        c.start_core(nameservers=["10.255.255.1"])
        rid = async_req(c, "diag.resolve", {"host": "example.invalid", "srv": True})
        c.sleep(300)
        c.req("core.stop", {"graceful": False})
        c.sleep(6000)          # the timeout timer / helper thread fire into a stopped engine
        c.start_core()
        c.req("core.ping")


class TestC2C4Dtmf(Base):
    def test_rfc2833_dtmf_flood_during_hangup(self):
        """C2: RFC 2833 events are delivered on the media thread without the dialog lock while hangup frees the call."""
        a, b, port = direct_pair(self)
        for i in range(50):
            cid_a, cid_b = direct_call(self, a, b, port)
            self.wait_media(a, cid_a)
            self.wait_media(b, cid_b)
            b.req("call.dtmf", {"cid": cid_b, "digits": "1234567890*#ABCD", "method": "rfc2833", "durationMs": 40})
            time.sleep(random.uniform(0.0, 0.25))
            a.req("call.hangup", {"cid": cid_a})
            self.assertIsNotNone(b.wait_event("call.state", 10, 0, cid=cid_b, state="disconnected"))
        a.req("core.ping")
        b.req("core.ping")
        self.assertGreater(len(a.events("call.dtmf")), 0)

    def test_inband_dtmf_while_remote_hangs_up(self):
        """C4: the tone generator port must not be destroyed under the playing thread."""
        a, b, port = direct_pair(self)
        for i in range(25):
            cid_a, cid_b = direct_call(self, a, b, port)
            self.wait_media(a, cid_a)
            a.req("call.dtmf", {"cid": cid_a, "digits": "123456789#", "method": "inband", "durationMs": 300})
            time.sleep(random.uniform(0.0, 0.15))
            b.send({"m": "call.hangup", "p": {"cid": cid_b}})
            a.wait_event("call.state", 10, 0, cid=cid_a, state="disconnected")
            # a second burst racing with the terminal cleanup may fail with NOT_FOUND/BUSY but must not crash
            a.raw("call.dtmf", {"cid": cid_a, "digits": "1", "method": "inband"})
        a.req("core.ping")


class TestC3IceMake(Base):
    def test_make_with_ice_returns_cid_and_hangup_works(self):
        c = self.cli()
        c.start_core(stunServers=[])
        _, ua = c.add_account(1001, ice=True)
        for _ in range(3):
            r = c.req("call.make", {"uid": ua, "uri": "600"})
            self.assertGreater(r["cid"], 0, r)
            self.assertGreaterEqual(r["call"], 0)
            c.req("call.hangup", {"cid": r["cid"]})
            self.assertEqual(len(c.events("call.state", cid=r["cid"], state="disconnected")), 1)
        # and one that really connects
        r = c.req("call.make", {"uid": ua, "uri": "600"})
        self.assertIsNotNone(c.wait_event("call.state", 15, 0, cid=r["cid"], state="confirmed"))
        c.req("call.hangup", {"cid": r["cid"]})

    def test_make_failure_never_returns_cid_zero(self):
        c = self.cli()
        c.start_core()
        for uri in ("sip:", "sip:@", "sips:127.0.0.1:1;transport=bogus", "sip:x@[::1"):
            r = c.raw("call.make", {"acc": -1, "uri": uri})
            if r["ok"]:
                self.assertGreater(r["result"]["cid"], 0, r)
            else:
                self.assertIn(r["error"]["code"], ("INVALID_PARAM", "PJ_ERROR"), r)


class TestM1OptionsPing(Base):
    def test_unanswered_ping_reports_408_after_about_five_seconds(self):
        c = self.cli()
        c.start_core()
        _, ua = c.add_account(1010)
        m = c.mark()
        t0 = time.time()
        c.req("diag.optionsPing", {"uid": ua, "target": "sip:10.255.255.1:5060"})
        ev = c.wait_event("diag.options", 15, m)
        self.assertIsNotNone(ev)
        dt = time.time() - t0
        self.assertEqual(ev["code"], 408)
        self.assertGreater(dt, 3.5, "ping gave up after %.2fs: timeout parameter is in ms" % dt)
        self.assertLess(dt, 10.0)
        # a reachable target is answered normally
        m = c.mark()
        c.req("diag.optionsPing", {"uid": ua})
        ev = c.wait_event("diag.options", 10, m)
        self.assertIsNotNone(ev)
        self.assertNotEqual(ev["code"], 408)


class TestM2TlsPolicy(Base):
    def test_pin_validation(self):
        c = self.cli()
        c.start_core()
        good = "ab" * 32
        c.req("core.setTlsPins", {"pins": [{"host": "x", "sha256": good}]})
        c.req("core.setTlsPins", {"pins": []})
        for bad in ("", "ab" * 31, "ab" * 33, "zz" * 32, ("ab" * 31) + "a:", good[:-1] + " "):
            r = c.raw("core.setTlsPins", {"pins": [{"host": "x", "sha256": bad}]})
            self.assertFalse(r["ok"], bad)
            self.assertEqual(r["error"]["code"], "INVALID_PARAM")
        self.assertEqual(c.raw("core.setTlsPins", {"pins": [{"host": "", "sha256": good}]})["error"]["code"], "INVALID_PARAM")
        self.assertEqual(c.raw("core.setTlsPins", {"pins": [{"sha256": good}]})["error"]["code"], "INVALID_PARAM")

    def test_verify_requires_a_readable_ca(self):
        c = self.cli()
        r = c.raw("core.start", {"transports": {"tls": {"port": 0, "verifyServer": True, "caFile": os.path.join(TMP, "missing.pem")}},
                                 "media": {"noAudioDevice": True}})
        self.assertFalse(r["ok"])
        self.assertEqual(r["error"]["code"], "INVALID_PARAM")
        self.assertIn("caFile", r["error"]["message"])
        self.assertFalse(c.req("core.info")["started"])


class TestM3TraceAfterFailedStart(Base):
    def test_failed_start_then_good_start_traces(self):
        c = self.cli()
        # fails after pjsua_init (no transport): the trace module must not stay marked as installed
        r = c.raw("core.start", {"transports": {"udp": {"enabled": False}, "tcp": {"enabled": False}, "tls": {"enabled": False}},
                                 "media": {"noAudioDevice": True}})
        self.assertFalse(r["ok"], r)
        c.start_core(sipTrace=True)
        c.add_account(1010)
        tr = c.events("sip.trace")
        self.assertTrue(any("REGISTER" in e["msg"] for e in tr), "no trace after a failed start")


class TestM4M5Requests(Base):
    def test_send_request_whitelist_and_header_injection(self):
        a, b, port = direct_pair(self)
        cid_a, cid_b = direct_call(self, a, b, port)
        for m in ("BYE", "INVITE", "ACK", "CANCEL", "PRACK", "UPDATE", "REFER", "SUBSCRIBE", "REGISTER", "bye"):
            r = a.raw("call.sendRequest", {"cid": cid_a, "method": m})
            self.assertFalse(r["ok"], m)
            self.assertEqual(r["error"]["code"], "INVALID_PARAM", m)
        for m in ("INFO", "MESSAGE", "NOTIFY", "OPTIONS"):
            if m == "NOTIFY":
                continue      # needs an Event header; allowed by the whitelist but rejected by the stack
            r = a.raw("call.sendRequest", {"cid": cid_a, "method": m, "headers": {"X-Ok": "1"}, "body": "x", "contentType": "text/plain"})
            self.assertTrue(r["ok"], (m, r))
        self.assertEqual(a.req("call.info", {"cid": cid_a})["state"], "confirmed")
        # header injection
        evil = [{"X-A": "v\r\nVia: SIP/2.0/UDP evil"}, {"X-A": "v\nContact: <sip:evil>"}, {"Via": "x"}, {"cseq": "1"},
                {"Call-ID": "x"}, {"content-length": "0"}, {"Content-Type": "x"}, {"From": "x"}, {"to": "x"}, {"Route": "x"},
                {"Record-Route": "x"}, {"Contact": "x"}, {"Max-Forwards": "1"}, {"X A": "x"}, {"X:A": "x"}, {"": "x"},
                {"X-A\r\nB": "x"}, {"v": "x"}, {"m": "x"}]
        for h in evil:
            for method, params in (("call.sendRequest", {"cid": cid_a, "method": "INFO"}),
                                   ("call.make", {"acc": -1, "uri": "sip:127.0.0.1:%s" % port}),
                                   ("call.answer", {"cid": cid_a}), ("call.reject", {"cid": cid_a})):
                p = dict(params)
                p["headers"] = h
                r = a.raw(method, p)
                self.assertFalse(r["ok"], (method, h))
                self.assertEqual(r["error"]["code"], "INVALID_PARAM", (method, h, r))
        r = a.raw("account.add", {"uid": "h", "username": "1", "domain": "x", "register": False, "headers": {"X-A": "v\r\nVia: evil"}})
        self.assertEqual(r["error"]["code"], "INVALID_PARAM")
        r = a.raw("account.add", {"uid": "h2", "username": "1\r\nVia: x", "domain": "x", "register": False})
        self.assertEqual(r["error"]["code"], "INVALID_PARAM")
        r = a.raw("account.add", {"uid": "h3", "username": "1", "domain": "x", "register": False, "displayName": "a\r\nb"})
        self.assertEqual(r["error"]["code"], "INVALID_PARAM")
        r = a.raw("core.setUserAgent", {"userAgent": "x\r\nVia: evil"})
        self.assertEqual(r["error"]["code"], "INVALID_PARAM")
        # custom, valid headers still go through and are visible to the callee
        mb = b.mark()
        cid2 = a.req("call.make", {"acc": -1, "uri": "sip:127.0.0.1:%s" % port, "headers": {"X-Custom-1": "hello", "P-Foo": "bar"}})["cid"]
        inc = b.wait_event("call.incoming", 10, mb)
        self.assertEqual(inc["headers"].get("X-Custom-1"), "hello")
        a.req("call.hangup", {"cid": cid2})


class TestM7SpoofedDialogInfo(Base):
    def test_notify_outside_a_subscription_dialog_is_ignored(self):
        a, b = self.cli("A"), self.cli("B")
        ra = a.start_core()
        b.start_core()
        _, ua = a.add_account(1001)
        _, ub = b.add_account(1003)
        a.req("buddy.add", {"uid": ua, "uri": "1003", "presence": False, "blf": True})
        self.assertIsNotNone(a.wait_event("buddy.state", 15))
        port = int([t for t in ra["transports"] if t["type"] == "udp"][0]["local"].split(":")[1])
        body = ('<?xml version="1.0"?><dialog-info xmlns="urn:ietf:params:xml:ns:dialog-info" version="9" state="full" '
                'entity="sip:1003@%s"><dialog id="evil" direction="initiator"><state>confirmed</state></dialog></dialog-info>' % PBX)
        s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        s.settimeout(1)
        m = a.mark()
        for i in range(3):
            pkt = ("NOTIFY sip:1001@127.0.0.1:%d SIP/2.0\r\nVia: SIP/2.0/UDP 127.0.0.1:5999;branch=z9hG4bKspoof%d\r\n"
                   "From: <sip:1003@%s>;tag=sp%d\r\nTo: <sip:1001@%s>;tag=zz%d\r\nCall-ID: spoof-%d@evil\r\nCSeq: 1 NOTIFY\r\n"
                   "Max-Forwards: 70\r\nEvent: dialog\r\nSubscription-State: active;expires=300\r\n"
                   "Content-Type: application/dialog-info+xml\r\nContent-Length: %d\r\n\r\n%s") % (
                port, i, PBX, i, PBX, i, i, len(body), body)
            s.sendto(pkt.encode(), ("127.0.0.1", port))
        time.sleep(1.5)
        spoofed = [e for e in a.events("buddy.state") if e["blf"]["state"] == "confirmed"]
        self.assertEqual(spoofed, [], "spoofed dialog-info changed the BLF state")
        # the genuine path still works: B calls the echo test, A's BLF turns early/confirmed
        m = a.mark()
        cid = b.req("call.make", {"uid": ub, "uri": "600"})["cid"]
        ev = a.wait(lambda x: x.get("event") == "buddy.state" and x["blf"]["state"] in ("early", "confirmed"), 15, m)
        self.assertIsNotNone(ev, "genuine BLF NOTIFY no longer processed")
        b.req("call.hangup", {"cid": cid})


class TestM8M9Numbers(Base):
    def test_hostile_numbers_are_invalid_params(self):
        c = self.cli()
        c.start_core()
        huge = [1e300, -1e300, 1e19, 9007199254740993.0, 0.5, -1, 0]
        for v in huge:
            for method, params in (("call.hangup", {"cid": v}), ("call.info", {"cid": v}), ("call.dtmf", {"cid": v, "digits": "1"}),
                                   ("call.conference", {"cids": [v, v]}), ("call.bridge", {"a": v, "b": v + 1 if v < 1e18 else 1, "bridge": True}),
                                   ("call.transferAttended", {"cid": v, "destCid": 1}), ("call.mute", {"cid": v, "mute": True})):
                r = c.raw(method, params)
                self.assertFalse(r["ok"], (method, v))
                self.assertIn(r["error"]["code"], ("INVALID_PARAM", "NOT_FOUND"), (method, v, r))
        for v in (1e300, -1e300, 0.5, 1e19, -2):
            r = c.raw("account.info", {"acc": v})
            self.assertFalse(r["ok"], v)
            self.assertIn(r["error"]["code"], ("INVALID_PARAM", "NOT_FOUND"))
        for v in (1e300, -1e300):
            r = c.raw("media.setCodecParam", {"id": "PCMU/8000/1", "fmtp": {"x": v}})
            self.assertTrue(r["ok"] or r["error"]["code"] in ("INVALID_PARAM", "PJ_ERROR"))
            for k in ("priority", "ptime"):
                r = c.raw("media.setCodecPriority", {"id": "PCMU/8000/1", "priority": v})
                self.assertFalse(r["ok"])
        fields = {"regExpires": [-5, 5, 1e300, 0.5, "x"], "keepAliveSec": [-1, 1e300, 99999], "regRetrySec": [-1, 1e300],
                  "regFirstRetrySec": [-1, 1e300], "regRetryRandomSec": [-1, 1e300], "regDelayBeforeRefreshSec": [-1, 1e300],
                  "unregTimeoutMs": [-1, 1e300], "mwiExpires": [-1, 1e300], "srtpSecureSignaling": [-1, 3, 1e300],
                  "regUseProxy": [-1, 4, 1e300], "timerSe": [-1, 10, 1e300], "localPort": [-1, 70000, 1e300]}
        n = 0
        for k, vals in fields.items():
            for v in vals:
                n += 1
                cfg = {"uid": "n%d" % n, "username": "1", "domain": "x", "register": False, k: v}
                r = c.raw("account.add", cfg)
                self.assertFalse(r["ok"], (k, v))
                self.assertEqual(r["error"]["code"], "INVALID_PARAM", (k, v, r))
                cfg["proto"] = "iax2"
                cfg["uid"] = "ni%d" % n
                if k in ("regExpires", "regRetrySec", "regFirstRetrySec"):
                    r = c.raw("account.add", cfg)
                    self.assertFalse(r["ok"], ("iax2", k, v))
                    self.assertEqual(r["error"]["code"], "INVALID_PARAM", ("iax2", k, v, r))
        for bad in ({"media": {"rtpPort": 70000}}, {"media": {"rtpPort": 65000, "rtpPortRange": 2000}}, {"media": {"rtpPort": -1}},
                    {"media": {"jb": {"initMs": -5}}}, {"media": {"jb": {"maxMs": 1e300}}}, {"statsIntervalMs": -1}, {"statsIntervalMs": 1e300},
                    {"incomingAutoRingMs": -1}, {"nameservers": ["not-an-ip"]}, {"nameservers": [1]}, {"nameservers": "bogus"}):
            c2 = self.cli("bad")
            r = c2.raw("core.start", dict({"media": {"noAudioDevice": True}}, **bad) if "media" not in bad else
                       {"media": dict({"noAudioDevice": True}, **bad["media"])})
            self.assertFalse(r["ok"], bad)
            self.assertEqual(r["error"]["code"], "INVALID_PARAM", (bad, r))
            self.assertFalse(c2.req("core.info")["started"])
        # strict booleans
        for method, params in (("call.mute", {"cid": 1, "mute": "yes"}), ("call.detachLocal", {"cid": 1, "detached": 1}),
                               ("account.register", {"acc": 0, "register": "true"}), ("media.loopback", {"enabled": "x"}),
                               ("core.setSipTrace", {"enabled": 5}), ("im.typing", {"acc": -1, "to": "1", "typing": "no"})):
            r = c.raw(method, params)
            self.assertFalse(r["ok"], method)
            self.assertEqual(r["error"]["code"], "INVALID_PARAM", (method, r))


class TestM6Dns(Base):
    def test_ipv6_and_explicit_nameservers(self):
        c = self.cli()
        c.start_core(nameservers=["::1", "127.0.0.1"])
        c.req("core.setNameservers", {"servers": ["127.0.0.1"]})
        self.assertEqual(c.raw("core.setNameservers", {"servers": ["bad address"]})["error"]["code"], "INVALID_PARAM")
        c.req("core.handleIpChange")
        c.req("core.ping")


class TestM4Stop(Base):
    def test_non_graceful_stop_is_fast(self):
        c = self.cli()
        c.start_core()
        for ext in range(1003, 1008):
            c.req("account.add", c.acct(ext))
        for ext in range(1003, 1008):
            self.assertIsNotNone(c.wait_event("account.reg", 20, 0, uid="u%d" % ext, regState="registered"))
        t0 = time.time()
        c.req("core.stop", {"graceful": False})
        dt = time.time() - t0
        self.assertLess(dt, 1.0, "non-graceful stop took %.2fs" % dt)
        c.start_core()
        c.req("core.stop", {"graceful": True})


class TestMinor(Base):
    def test_shutdown_and_sync_request_from_event_callback(self):
        c = self.cli()
        c.start_core()
        m = c.mark()
        c.send({"m": "__shutdown_from_cb"})
        c.wait(lambda x: x.get("m") == "__arm", 5, m)
        c.req("account.add", c.acct(1010, register=False))      # produces an event -> the callback runs the check
        ev = c.wait(lambda x: x.get("m") == "__shutdown_from_cb", 10, m)
        self.assertIsNotNone(ev, "callback never returned from spc_shutdown/spc_request_sync")
        self.assertEqual(ev["code"], "BUSY")
        c.req("core.ping")

    def test_log_forward_flag_is_kept_and_detached_trace_not_buffered(self):
        c = self.cli()
        c.start_core(logForward=True, logLevel=4)
        c.req("core.setLogLevel", {"level": 4})             # no 'forward': keeps forwarding
        m = c.mark()
        c.req("core.ping")
        c.add_account(1010)
        self.assertTrue(c.events("log"))
        c.req("core.setSipTrace", {"enabled": True})
        c.send({"m": "__detach"})
        c.sleep(100)
        c.req("account.register", {"uid": "u1010", "register": False})
        c.sleep(800)
        mk = c.mark()
        c.send({"m": "__attach"})
        rep = c.wait(lambda x: x.get("m") == "__attach", 5, mk)
        replayed = [x for x in c.log[mk:] if x.get("type") == "event"]
        self.assertFalse([x for x in replayed if x["event"] in ("sip.trace", "log")], "firehose events were buffered")
        self.assertTrue([x for x in replayed if x["event"] == "account.reg"])

    def test_remove_account_emits_final_unregistered(self):
        c = self.cli()
        c.start_core()
        acc, uid = c.add_account(1010)
        m = c.mark()
        c.req("account.remove", {"uid": uid})
        regs = [x for x in c.log[m:] if x.get("event") == "account.reg" and x.get("uid") == uid]
        self.assertTrue(regs)
        self.assertEqual(regs[-1]["regState"], "unregistered")

    def test_referred_by_and_unknown_method(self):
        c = self.cli()
        self.assertEqual(c.raw("nope.nope")["error"]["code"], "UNSUPPORTED")
        a = self.cli("A")
        a.start_core()
        _, ua = a.add_account(1001)
        m = a.mark()
        cid = a.req("call.make", {"uid": ua, "uri": "1999"})["cid"]
        ev = a.wait_event("call.transferRequest", 25, m, cid=cid)
        self.assertIsNotNone(ev)
        self.assertIsInstance(ev["referredBy"], str)

    def test_device_default_flag(self):
        c = self.cli()
        c.start_core()
        d = c.req("media.devices")
        for k in ("capture", "playback"):
            if d[k]:
                self.assertEqual(len([x for x in d[k] if x["isDefault"]]), 1)

    def test_muted_mic_not_recorded(self):
        a, b, port = direct_pair(self)
        cid_a, cid_b = direct_call(self, a, b, port)
        self.wait_media(a, cid_a)
        a.req("call.mute", {"cid": cid_a, "mute": True})
        a.req("call.recordStart", {"cid": cid_a, "file": os.path.join(TMP, "muted.wav"), "mix": "both"})
        a.sleep(300)
        a.req("call.recordStop", {"cid": cid_a})


if __name__ == "__main__":
    import sys
    sys.modules.setdefault("run_tests", __import__("run_tests"))
    unittest.main(verbosity=2)
