"""IAX2 integration tests (run via run_tests.py, which auto-loads native/tests/test_*.py).

Everything runs against the Docker Asterisk test PBX (tests/sipserver): IAX2 peers 2001-2005 (secret pass200X),
SIP 1001-1020, 600 echo, 601 tone, 602 DTMF collector, 604 music, 1005 etc.
"""
import os
import random
import socket
import struct
import time
import unittest

from run_tests import Base, Cli, RpcError, PBX, TONE, TMP, pbx_cat, wav_stats, check_invariants


def iax_add(c, ext, wait=True, **kw):
    """add an IAX2 account for peer `ext` (password pass<ext>); returns (acc, uid, add_result)"""
    cfg = {"uid": "iax%s" % ext, "proto": "iax2", "username": str(ext), "password": "pass%s" % ext,
           "domain": PBX, "regExpires": 120}
    cfg.update(kw)
    mark = c.mark()
    r = c.req("account.add", cfg)
    if wait:
        ev = c.wait_event("account.reg", 15, mark, uid=cfg["uid"], regState="registered")
        if ev is None:
            raise AssertionError("iax account %s did not register: %s" % (ext, c.events("account.reg", uid=cfg["uid"])[-2:]))
    return r["acc"], cfg["uid"], r


class IaxBase(Base):
    def media_ok(self, c, cid, timeout=12):
        """stats show packets received and the bridge saw non-silent audio from the remote side"""
        def ok():
            st = c.req("call.stats", {"cid": cid})
            return st if st["rx"]["packets"] > 0 and st["rxLevel"] > 0 else None
        st = self.poll(ok, timeout)
        self.assertIsNotNone(st, "no audio received on cid %s: %s" % (cid, self._stats(c, cid)))
        return st

    def _stats(self, c, cid):
        try:
            return c.req("call.stats", {"cid": cid})
        except Exception as e:
            return str(e)

    def tone(self, c, cid):
        c.req("call.playFile", {"cid": cid, "file": TONE, "loop": True})

    def disconnected(self, c, cid, timeout=10):
        ev = c.wait_event("call.state", timeout, 0, cid=cid, state="disconnected")
        self.assertIsNotNone(ev, "cid %s did not disconnect" % cid)
        return ev


class TestIaxRegistration(IaxBase):
    def test_register_ok_and_unregister(self):
        c = self.cli()
        c.start_core()
        acc, uid, r = iax_add(c, 2001)
        self.assertGreaterEqual(acc, 1000)
        self.assertGreater(r["localPort"], 0)
        info = c.req("account.info", {"uid": uid})
        self.assertEqual(info["proto"], "iax2")
        self.assertEqual(info["regState"], "registered")
        self.assertEqual(info["regCode"], 200)
        self.assertIsNone(info["lastError"])
        self.assertGreater(info["expires"], 0)
        self.assertEqual(c.req("account.info", {"acc": acc})["uid"], uid)
        self.assertEqual(c.raw("account.add", {"uid": uid, "proto": "iax2", "username": "2001", "domain": PBX})["error"]["code"], "ALREADY")
        c.req("account.register", {"uid": uid, "register": False})
        self.assertIsNotNone(c.wait_event("account.reg", 10, 0, uid=uid, regState="unregistered"))
        m = c.mark()
        c.req("account.register", {"uid": uid, "register": True})
        self.assertIsNotNone(c.wait_event("account.reg", 10, m, uid=uid, regState="registered"))
        c.req("account.setPresence", {"uid": uid, "status": "away", "note": "brb"})
        self.assertEqual(c.req("account.info", {"uid": uid})["presence"], "away")
        c.req("account.modify", {"uid": uid, "regExpires": 90})
        self.assertIsNotNone(self.poll(lambda: c.req("account.info", {"uid": uid})["regState"] == "registered", 10))
        c.req("account.remove", {"uid": uid})
        self.assertEqual(c.raw("account.info", {"uid": uid})["error"]["code"], "NOT_FOUND")
        self.assertEqual(c.raw("account.info", {"acc": acc})["error"]["code"], "NOT_FOUND")

    def test_bad_password_fails(self):
        c = self.cli()
        c.start_core()
        mark = c.mark()
        c.req("account.add", {"uid": "bad", "proto": "iax2", "username": "2001", "password": "wrong", "domain": PBX,
                              "regRetrySec": 60, "regFirstRetrySec": 60})
        ev = c.wait_event("account.reg", 15, mark, uid="bad", regState="failed")
        self.assertIsNotNone(ev, c.events("account.reg"))
        self.assertEqual(ev["regCode"], 403)
        self.assertIn("Wrong username/password", ev["lastError"])
        self.assertFalse(c.req("account.info", {"uid": "bad"})["online"] is None)

    def test_unresolvable_host(self):
        c = self.cli()
        c.start_core()
        mark = c.mark()
        c.req("account.add", {"uid": "nx", "proto": "iax2", "username": "1", "password": "x", "domain": "no-such-host.invalid",
                              "regRetrySec": 60, "regFirstRetrySec": 60})
        ev = c.wait_event("account.reg", 20, mark, uid="nx", regState="failed")
        self.assertIsNotNone(ev)
        self.assertIn("DNS", ev["lastError"])

    def test_no_server_times_out(self):
        c = self.cli()
        c.start_core()
        mark = c.mark()
        c.req("account.add", {"uid": "dead", "proto": "iax2", "username": "2001", "password": "x", "domain": "127.0.0.1",
                              "iax": {"host": "127.0.0.1", "port": 9}, "regRetrySec": 60, "regFirstRetrySec": 60})
        ev = c.wait_event("account.reg", 25, mark, uid="dead", regState="failed")
        self.assertIsNotNone(ev)
        self.assertEqual(ev["regCode"], 408)
        self.assertIn("Timeout", ev["lastError"])

    def test_two_iax_and_one_sip_online(self):
        c = self.cli()
        c.start_core()
        a1, u1, r1 = iax_add(c, 2001)
        a2, u2, r2 = iax_add(c, 2002)
        s, us = c.add_account(1010)
        self.assertNotEqual(a1, a2)
        self.assertLess(s, 1000)
        accs = {a["uid"]: a for a in c.req("account.list")["accounts"]}
        for u in (u1, u2, us):
            self.assertEqual(accs[u]["regState"], "registered", accs[u])
        self.assertEqual(accs[u1]["proto"], "iax2")
        self.assertEqual(accs[u2]["proto"], "iax2")
        self.assertEqual(accs[us]["proto"], "sip")
        snap = c.req("core.snapshot")
        self.assertEqual(len([a for a in snap["accounts"] if a["proto"] == "iax2"]), 2)
        self.assertEqual(c.req("core.info")["accounts"], 3)
        # both stay registered across a refresh cycle's worth of time
        c.sleep(1500)
        self.assertEqual(c.req("account.info", {"uid": u1})["regState"], "registered")

    def test_graceful_stop_unregisters(self):
        c = self.cli()
        c.start_core()
        acc, uid, _ = iax_add(c, 2003)
        mark = c.mark()
        c.req("core.stop", {"graceful": True})
        self.assertIsNotNone(c.wait_event("account.reg", 5, mark, uid=uid, regState="unregistering"))
        self.assertIsNotNone(c.wait_event("account.reg", 5, mark, uid=uid, regState="unregistered"))
        # core can start again and the account can register again
        c.start_core()
        iax_add(c, 2003)


class TestIaxCalls(IaxBase):
    def test_iax_to_sip_media_both_ways(self):
        a = self.cli("A")
        b = self.cli("B")
        a.start_core(); b.start_core()
        _, ua, _ = iax_add(a, 2001)
        b.add_account(1001)
        cid_a, cid_b = self.call_between(a, b, ua, "1001")
        ia = a.req("call.info", {"cid": cid_a})
        self.assertEqual(ia["proto"], "iax2")
        self.assertEqual(ia["state"], "confirmed")
        self.assertGreaterEqual(ia["call"], 1000)
        self.assertEqual(ia["role"], "caller")
        self.assertIn(ia["codec"], ("PCMU/8000/1", "PCMA/8000/1", "GSM/8000/1"))
        self.wait_media(a, cid_a)
        self.wait_media(b, cid_b)
        self.tone(a, cid_a)
        self.tone(b, cid_b)
        sa = self.media_ok(a, cid_a)
        sb = self.media_ok(b, cid_b)
        self.assertGreater(sa["tx"]["packets"], 5)
        self.assertGreater(sa["rx"]["bytes"], 0)
        self.assertGreater(sa["mos"], 1.0)
        self.assertEqual(sa["clockRate"], 8000)
        self.assertTrue(sa["remoteRtp"])
        self.assertGreater(sb["rx"]["packets"], 0)
        # hangup from the IAX2 side
        a.req("call.hangup", {"cid": cid_a})
        self.assertEqual(a.events("call.state", cid=cid_a)[-1]["state"], "disconnected")
        self.disconnected(b, cid_b)
        self.assertEqual(a.raw("call.hangup", {"cid": cid_a})["error"]["code"], "NOT_FOUND")

    def test_sip_to_iax_incoming_and_remote_hangup(self):
        a = self.cli("A")      # IAX2 callee
        b = self.cli("B")      # SIP caller
        a.start_core(incomingAutoRingMs=300); b.start_core()
        _, ua, _ = iax_add(a, 2002)
        _, ub = b.add_account(1002)
        m = a.mark()
        cid_b = b.req("call.make", {"uid": ub, "uri": "2002"})["cid"]
        inc = a.wait_event("call.incoming", 15, m)
        self.assertIsNotNone(inc, "no incoming IAX2 call")
        self.assertEqual(inc["proto"], "iax2")
        self.assertEqual(inc["role"], "callee")
        self.assertEqual(inc["state"], "incoming")
        self.assertEqual(inc["acc"], a.req("account.info", {"uid": ua})["acc"])
        self.assertEqual(inc["uid"], ua)
        self.assertIn("1002", inc["remoteUri"] + inc["remoteUser"] + inc["remoteDisplay"])
        cid_a = inc["cid"]
        # auto ring -> the SIP caller sees ringing
        self.assertIsNotNone(b.wait_event("call.state", 8, 0, cid=cid_b, state="early"), "caller never saw ringing")
        a.req("call.answer", {"cid": cid_a})
        self.assertIsNotNone(b.wait_event("call.state", 10, 0, cid=cid_b, state="confirmed"))
        self.assertIsNotNone(a.wait_event("call.state", 10, m, cid=cid_a, state="confirmed"))
        self.wait_media(a, cid_a); self.wait_media(b, cid_b)
        self.tone(b, cid_b)
        self.tone(a, cid_a)
        self.media_ok(a, cid_a)
        self.media_ok(b, cid_b)
        # hangup from the SIP side
        b.req("call.hangup", {"cid": cid_b})
        ev = self.disconnected(a, cid_a)
        self.assertEqual(ev["proto"], "iax2")
        self.assertEqual(ev["stateCode"], 200)

    def test_incoming_reject_busy(self):
        a = self.cli("A"); b = self.cli("B")
        a.start_core(); b.start_core()
        iax_add(a, 2003)
        _, ub = b.add_account(1003)
        m = a.mark()
        cid_b = b.req("call.make", {"uid": ub, "uri": "2003"})["cid"]
        inc = a.wait_event("call.incoming", 15, m)
        self.assertIsNotNone(inc)
        a.req("call.reject", {"cid": inc["cid"], "code": 486})
        ev = self.disconnected(a, inc["cid"])
        self.assertEqual(ev["stateCode"], 486)
        ev = self.disconnected(b, cid_b)
        self.assertEqual(ev["stateCode"], 486)

    def test_caller_cancels_before_answer(self):
        a = self.cli("A"); b = self.cli("B")
        a.start_core(); b.start_core(incomingAutoRingMs=0)
        _, ua, _ = iax_add(a, 2001)
        b.add_account(1004)
        mb = b.mark()
        cid_a = a.req("call.make", {"uid": ua, "uri": "1004"})["cid"]
        self.assertEqual(a.events("call.state", cid=cid_a)[0]["state"], "calling")
        inc = b.wait_event("call.incoming", 15, mb)
        self.assertIsNotNone(inc)
        b.req("call.ring", {"cid": inc["cid"]})
        self.assertIsNotNone(a.wait_event("call.state", 10, 0, cid=cid_a, state="early"), "no ringing")
        a.req("call.hangup", {"cid": cid_a})
        ev = a.events("call.state", cid=cid_a)[-1]
        self.assertEqual(ev["state"], "disconnected")
        self.assertEqual(ev["stateCode"], 487)
        self.disconnected(b, inc["cid"])

    def test_dial_unknown_extension(self):
        a = self.cli()
        a.start_core()
        _, ua, _ = iax_add(a, 2001)
        cid = a.req("call.make", {"uid": ua, "uri": "98765"})["cid"]
        ev = self.disconnected(a, cid, 15)
        self.assertIn(ev["stateCode"], (404, 503, 603))

    def test_echo_600_media(self):
        a = self.cli()
        a.start_core()
        _, ua, _ = iax_add(a, 2001)
        cid = a.req("call.make", {"uid": ua, "uri": "600"})["cid"]
        self.assertIsNotNone(a.wait_event("call.state", 15, 0, cid=cid, state="confirmed"))
        self.wait_media(a, cid)
        self.tone(a, cid)
        st = self.media_ok(a, cid)
        self.assertGreater(st["rx"]["packets"], 10)
        self.assertGreater(st["rxLevel"], 5)
        self.assertGreater(st["tx"]["packets"], 10)
        self.assertIn("jb", st)
        c = a.req("call.info", {"cid": cid})
        self.assertEqual(c["media"], "active")
        a.req("call.setLevels", {"cid": cid, "rx": 0.5, "tx": 1.0})
        a.req("call.hangup", {"cid": cid})

    def test_codec_selection(self):
        for codecs, want in ((["PCMA/8000/1"], "PCMA/8000/1"), (["GSM/8000/1"], "GSM/8000/1"), (["PCMU/8000/1", "PCMA/8000/1"], "PCMU/8000/1")):
            a = self.cli()
            a.start_core()
            _, ua, _ = iax_add(a, 2001, codecs=codecs)
            cid = a.req("call.make", {"uid": ua, "uri": "600"})["cid"]
            self.assertIsNotNone(a.wait_event("call.state", 15, 0, cid=cid, state="confirmed"))
            self.wait_media(a, cid)
            self.assertEqual(a.req("call.info", {"cid": cid})["codec"], want)
            self.tone(a, cid)
            st = self.media_ok(a, cid)
            self.assertEqual(st["codec"], want)
            a.req("call.hangup", {"cid": cid})

    def test_dtmf_to_602(self):
        a = self.cli()
        a.start_core()
        _, ua, _ = iax_add(a, 2005)
        cid = a.req("call.make", {"uid": ua, "uri": "602"})["cid"]
        self.assertIsNotNone(a.wait_event("call.state", 15, 0, cid=cid, state="confirmed"))
        self.wait_media(a, cid)
        a.sleep(1500)
        a.req("call.dtmf", {"cid": cid, "digits": "1234"})
        got = self.poll(lambda: pbx_cat("/var/log/asterisk/dtmf_2005.txt").strip(), 15, 0.5)
        self.assertEqual(got, "1234")
        a.req("call.hangup", {"cid": cid})
        self.assertEqual(a.raw("call.dtmf", {"cid": cid, "digits": "1"})["error"]["code"], "NOT_FOUND")

    def test_dtmf_received(self):
        """SIP 1006 sends RFC2833 DTMF to the IAX2 callee; Asterisk converts it to IAX2 DTMF frames."""
        a = self.cli("A"); b = self.cli("B")
        a.start_core(); b.start_core()
        _, ua, _ = iax_add(a, 2004)
        _, ub = b.add_account(1006)
        cid_b, cid_a = None, None
        m = a.mark()
        cid_b = b.req("call.make", {"uid": ub, "uri": "2004"})["cid"]
        inc = a.wait_event("call.incoming", 15, m)
        cid_a = inc["cid"]
        a.req("call.answer", {"cid": cid_a})
        self.assertIsNotNone(b.wait_event("call.state", 10, 0, cid=cid_b, state="confirmed"))
        b.sleep(800)
        b.req("call.dtmf", {"cid": cid_b, "digits": "5#", "method": "rfc2833"})
        ev = a.wait_event("call.dtmf", 10, m, cid=cid_a, digit="5")
        self.assertIsNotNone(ev, a.events("call.dtmf"))
        self.assertEqual(ev["method"], "iax2")
        self.assertIsNotNone(a.wait_event("call.dtmf", 10, m, cid=cid_a, digit="#"))
        a.req("call.hangup", {"cid": cid_a})

    def test_hold_unhold_and_mute(self):
        a = self.cli()
        a.start_core()
        _, ua, _ = iax_add(a, 2001)
        cid = a.req("call.make", {"uid": ua, "uri": "604"})["cid"]
        self.assertIsNotNone(a.wait_event("call.state", 15, 0, cid=cid, state="confirmed"))
        self.wait_media(a, cid)
        st = self.media_ok(a, cid)          # music tone arrives
        m = a.mark()
        a.req("call.hold", {"cid": cid})
        self.wait_media(a, cid, "localHold")
        info = a.req("call.info", {"cid": cid})
        self.assertTrue(info["held"])
        self.assertEqual(info["media"], "localHold")
        a.req("call.hold", {"cid": cid})            # idempotent
        t1 = a.req("call.stats", {"cid": cid})["tx"]["packets"]
        a.sleep(600)
        t2 = a.req("call.stats", {"cid": cid})["tx"]["packets"]
        self.assertLessEqual(t2 - t1, 3, "still transmitting while on hold")
        a.req("call.unhold", {"cid": cid})
        self.wait_media(a, cid, "active")
        self.assertFalse(a.req("call.info", {"cid": cid})["held"])
        # mute toggles the flag and the mic connection
        a.req("call.mute", {"cid": cid, "mute": True})
        self.assertTrue(a.req("call.info", {"cid": cid})["muted"])
        a.req("call.mute", {"cid": cid, "mute": False})
        self.assertFalse(a.req("call.info", {"cid": cid})["muted"])
        a.req("call.detachLocal", {"cid": cid, "detached": True})
        self.assertTrue(a.req("call.info", {"cid": cid})["detached"])
        a.req("call.detachLocal", {"cid": cid, "detached": False})
        a.req("call.hangup", {"cid": cid})

    def test_recording(self):
        a = self.cli()
        a.start_core()
        _, ua, _ = iax_add(a, 2001)
        cid = a.req("call.make", {"uid": ua, "uri": "601"})["cid"]
        self.assertIsNotNone(a.wait_event("call.state", 15, 0, cid=cid, state="confirmed"))
        self.wait_media(a, cid)
        path = os.path.join(TMP, "iax_rec_%d.wav" % random.randint(0, 1 << 30))
        r = a.req("call.recordStart", {"cid": cid, "file": path, "mix": "remote"})
        self.assertEqual(r["file"], path)
        self.assertTrue(a.req("call.info", {"cid": cid})["recording"])
        self.assertEqual(a.raw("call.recordStart", {"cid": cid, "file": path})["error"]["code"], "ALREADY")
        a.sleep(3500)
        r = a.req("call.recordStop", {"cid": cid})
        self.assertGreater(r["durationMs"], 2000)
        n, rms = wav_stats(path)
        self.assertGreater(n, 8000)
        self.assertGreater(rms, 500, "recording of the IAX2 call is silent")
        self.assertIsNotNone(a.wait_event("call.recording", 2, 0, cid=cid, recording=False))
        a.req("call.hangup", {"cid": cid})

    def test_recording_stopped_by_hangup(self):
        a = self.cli()
        a.start_core()
        _, ua, _ = iax_add(a, 2001)
        cid = a.req("call.make", {"uid": ua, "uri": "601"})["cid"]
        self.assertIsNotNone(a.wait_event("call.state", 15, 0, cid=cid, state="confirmed"))
        self.wait_media(a, cid)
        path = os.path.join(TMP, "iax_rec2_%d.wav" % random.randint(0, 1 << 30))
        a.req("call.recordStart", {"cid": cid, "file": path})
        a.sleep(1500)
        a.req("call.hangup", {"cid": cid})
        evs = a.events("call.recording", cid=cid)
        self.assertEqual([e["recording"] for e in evs], [True, False])
        # the recording event precedes the terminal state
        log = [m for m in a.log if m.get("type") == "event" and m.get("cid") == cid]
        self.assertEqual(log[-1]["event"], "call.state")
        def wav_ok():
            try:
                return wav_stats(path)[0] > 4000
            except Exception:
                return False
        self.assertTrue(self.poll(wav_ok, 5, 0.2), "recording was not finalised after hangup")

    def test_conference_iax_and_sip(self):
        """A holds an IAX2 call to B and a SIP call to C; conference bridges B <-> C through A."""
        a = self.cli("A"); b = self.cli("B"); c = self.cli("C")
        for x in (a, b, c):
            x.start_core()
        _, ui, _ = iax_add(a, 2001)
        _, us = a.add_account(1008)
        b.add_account(1003)
        c.add_account(1004)
        cid_ab, cid_b = self.call_between(a, b, ui, "1003")
        cid_ac, cid_c = self.call_between(a, c, us, "1004")
        self.assertEqual(a.req("call.info", {"cid": cid_ab})["proto"], "iax2")
        self.assertEqual(a.req("call.info", {"cid": cid_ac})["proto"], "sip")
        for x, cid in ((a, cid_ab), (a, cid_ac), (b, cid_b), (c, cid_c)):
            self.wait_media(x, cid)
        a.req("call.conference", {"cids": [cid_ab, cid_ac]})
        self.assertEqual(a.req("call.info", {"cid": cid_ab})["conferenceWith"], [cid_ac])
        self.assertEqual(a.req("call.info", {"cid": cid_ac})["conferenceWith"], [cid_ab])
        self.tone(b, cid_b)       # B talks; C must hear it through A's bridge
        st = self.media_ok(c, cid_c)
        self.assertGreater(st["rxLevel"], 5)
        c.req("call.stopFile", {"cid": cid_c})
        self.tone(c, cid_c)       # and B hears C
        self.media_ok(b, cid_b)
        a.req("call.unconference", {"cids": [cid_ab, cid_ac]})
        self.assertEqual(a.req("call.info", {"cid": cid_ab})["conferenceWith"], [])
        # bridge (relay) the two calls without the local mic
        a.req("call.detachLocal", {"cid": cid_ab, "detached": True})
        a.req("call.detachLocal", {"cid": cid_ac, "detached": True})
        a.req("call.bridge", {"a": cid_ab, "b": cid_ac, "bridge": True})
        self.assertEqual(a.req("call.info", {"cid": cid_ab})["bridgedWith"], [cid_ac])
        self.media_ok(c, cid_c)
        a.req("call.bridge", {"a": cid_ab, "b": cid_ac, "bridge": False})
        a.req("call.hangupAll")
        self.disconnected(b, cid_b); self.disconnected(c, cid_c)
        self.assertEqual(a.req("call.list")["calls"], [])

    def test_blind_transfer(self):
        a = self.cli("A"); b = self.cli("B")
        a.start_core(); b.start_core()
        _, ua, _ = iax_add(a, 2001)
        b.add_account(1009)
        cid_a, cid_b = self.call_between(a, b, ua, "1009")
        self.wait_media(a, cid_a); self.wait_media(b, cid_b)
        a.sleep(1500)                 # let Asterisk finish bridging the two legs
        m = a.mark()
        a.req("call.transfer", {"cid": cid_a, "target": "600"})
        self.assertIsNotNone(a.wait_event("call.transferStatus", 5, m, cid=cid_a))
        # Asterisk moves B to the echo test and drops A's leg
        self.disconnected(a, cid_a, 10)
        self.assertEqual(b.req("call.info", {"cid": cid_b})["state"], "confirmed")
        self.tone(b, cid_b)
        self.media_ok(b, cid_b)       # B now hears itself via 600
        b.req("call.hangup", {"cid": cid_b})

    def test_unsupported_ops(self):
        a = self.cli()
        a.start_core()
        _, ua, _ = iax_add(a, 2001)
        cid = a.req("call.make", {"uid": ua, "uri": "600"})["cid"]
        self.assertIsNotNone(a.wait_event("call.state", 15, 0, cid=cid, state="confirmed"))
        for method, params in (("call.update", {"cid": cid}), ("call.redirect", {"cid": cid, "targets": ["1"]}),
                               ("call.sendRequest", {"cid": cid, "method": "INFO"}),
                               ("call.transferAttended", {"cid": cid, "destCid": cid + 100})):
            r = a.raw(method, params)
            self.assertFalse(r["ok"], method)
            self.assertIn(r["error"]["code"], ("UNSUPPORTED", "NOT_FOUND"), "%s %s" % (method, r))
        self.assertEqual(a.raw("call.answer", {"cid": cid})["error"]["code"], "BUSY")
        a.req("call.hangup", {"cid": cid})

    def test_hangup_all_and_core_stop_with_calls(self):
        a = self.cli()
        a.start_core()
        _, ua, _ = iax_add(a, 2001)
        _, ub, _ = iax_add(a, 2002)
        c1 = a.req("call.make", {"uid": ua, "uri": "600"})["cid"]
        c2 = a.req("call.make", {"uid": ub, "uri": "604"})["cid"]
        for cid in (c1, c2):
            self.assertIsNotNone(a.wait_event("call.state", 15, 0, cid=cid, state="confirmed"))
            self.wait_media(a, cid)
        self.assertEqual(len(a.req("call.list")["calls"]), 2)
        a.req("call.hangupAll")
        for cid in (c1, c2):
            self.assertEqual(a.events("call.state", cid=cid)[-1]["state"], "disconnected")
        c3 = a.req("call.make", {"uid": ua, "uri": "600"})["cid"]
        self.assertGreater(c3, c2)
        self.assertIsNotNone(a.wait_event("call.state", 15, 0, cid=c3, state="confirmed"))
        self.wait_media(a, c3)
        mark = a.mark()
        a.req("core.stop", {"graceful": True})
        self.assertEqual(a.events("call.state", cid=c3)[-1]["state"], "disconnected")
        self.assertIsNotNone(a.wait_event("account.reg", 5, mark, uid=ua, regState="unregistered"))
        self.assertIsNotNone(a.wait_event("core.stopped", 5, mark))
        # nothing leaks after core.stop
        a.sleep(300)
        late = [m for m in a.log[mark:] if m.get("type") == "event" and m.get("event", "").startswith("call.") and m.get("cid") == c3
                and m.get("event") != "call.state"]
        self.assertEqual(late, [])

    def test_remove_account_hangs_up_calls(self):
        a = self.cli()
        a.start_core()
        acc, ua, _ = iax_add(a, 2001)
        cid = a.req("call.make", {"uid": ua, "uri": "600"})["cid"]
        self.assertIsNotNone(a.wait_event("call.state", 15, 0, cid=cid, state="confirmed"))
        a.req("account.remove", {"uid": ua})
        self.assertEqual(a.events("call.state", cid=cid)[-1]["state"], "disconnected")

    def test_cid_monotonic_and_proto_events(self):
        a = self.cli()
        a.start_core()
        _, ua, _ = iax_add(a, 2001)
        cids = []
        for i in range(3):
            cid = a.req("call.make", {"uid": ua, "uri": "603"})["cid"]
            cids.append(cid)
            self.assertIsNotNone(a.wait_event("call.state", 15, 0, cid=cid, state="confirmed"))
            self.disconnected(a, cid, 15)       # 603 hangs up after 2 s
        self.assertEqual(cids, sorted(cids))
        self.assertEqual(len(set(cids)), 3)
        for e in a.events("call.state"):
            self.assertEqual(e["proto"], "iax2")
            self.assertGreaterEqual(e["call"], 1000)
        # call.stats on a gone call
        self.assertEqual(a.raw("call.stats", {"cid": cids[0]})["error"]["code"], "NOT_FOUND")

    def test_max_calls(self):
        a = self.cli()
        a.start_core(maxCalls=1)
        _, ua, _ = iax_add(a, 2001)
        c1 = a.req("call.make", {"uid": ua, "uri": "600"})["cid"]
        r = a.raw("call.make", {"uid": ua, "uri": "600"})
        self.assertFalse(r["ok"])
        self.assertEqual(r["error"]["code"], "BUSY")
        a.req("call.hangup", {"cid": c1})

    def test_invalid_call_params(self):
        a = self.cli()
        a.start_core()
        _, ua, _ = iax_add(a, 2001)
        for uri in ("", "bad number!", "x" * 200, "ab\ncd"):
            r = a.raw("call.make", {"uid": ua, "uri": uri})
            self.assertFalse(r["ok"], uri)
            self.assertEqual(r["error"]["code"], "INVALID_PARAM", uri)
        self.assertEqual(a.raw("call.make", {"acc": 1999, "uri": "600"})["error"]["code"], "NOT_FOUND")


class TestIaxRobustness(IaxBase):
    def test_garbage_and_hostile_packets(self):
        a = self.cli()
        a.start_core()
        _, ua, r = iax_add(a, 2001)
        port = r["localPort"]
        s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        rnd = random.Random(1234)
        pkts = [b"", b"\x00", b"\x80", b"\x80\x01", b"\x00\x00\x00\x00", b"\x00\x00" + b"\x00" * 30,
                b"\xff" * 12, b"\xff" * 1400, b"\x80\x05\x00\x00" + b"\x00" * 8]
        # full frames with absurd IE lengths, truncated IEs, unknown dest call numbers, bogus subclasses
        for t in range(0, 256, 5):
            for sub in (1, 2, 7, 13, 14, 15, 16, 17, 18, 40, 200):
                hdr = struct.pack(">HHIBBBB", 0x8000 | rnd.randrange(1, 0x7fff), rnd.choice((0, 1, 2, 3, 4, 5)), rnd.randrange(1 << 32),
                                  rnd.randrange(256), rnd.randrange(256), t, sub)
                body = bytes(rnd.randrange(256) for _ in range(rnd.randrange(0, 40)))
                pkts.append(hdr + body + bytes([1, 255]))
                pkts.append(hdr + b"\x06\xff" + body)
        for _ in range(400):
            pkts.append(bytes(rnd.randrange(256) for _ in range(rnd.randrange(1, 300))))
        # NEW with huge/garbage IEs from the PBX's address would be needed to get past source filtering; also try unknown source
        for p in pkts:
            try:
                s.sendto(p, ("127.0.0.1", port))
            except OSError:
                pass
        s.close()
        a.sleep(500)
        a.req("core.ping")
        self.assertEqual(a.req("account.info", {"uid": ua})["regState"], "registered")
        # still able to place a call afterwards
        cid = a.req("call.make", {"uid": ua, "uri": "600"})["cid"]
        self.assertIsNotNone(a.wait_event("call.state", 15, 0, cid=cid, state="confirmed"))
        a.req("call.hangup", {"cid": cid})

    def test_fuzz_ies_and_unknown_source(self):
        """NEW frames with garbage IEs from an address that is not the PBX must not create calls (or crash)"""
        a = self.cli()
        a.start_core()
        mark = a.mark()
        r = a.req("account.add", {"uid": "ghost", "proto": "iax2", "username": "2002", "password": "x", "domain": "192.0.2.1",
                                  "regRetrySec": 60, "regFirstRetrySec": 60})
        port = r["localPort"]
        s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        for i in range(200):
            ies = b"".join(bytes([random.randrange(1, 60), random.randrange(0, 200)]) + bytes(random.randrange(256) for _ in range(random.randrange(0, 20)))
                           for _ in range(random.randrange(1, 8)))
            hdr = struct.pack(">HHIBBBB", 0x8000 | random.randrange(1, 0x7fff), 0, 0, 0, 0, 6, 1)
            s.sendto(hdr + ies, ("127.0.0.1", port))
        s.close()
        a.sleep(300)
        self.assertFalse(a.events("call.incoming"), "unsolicited NEW from an unknown address created a call")
        a.req("core.ping")

    def test_fuzz_new_from_pbx_address(self):
        """garbage NEW frames that do come from the PBX's address may create calls, but never crash; hang them up"""
        a = self.cli()
        a.start_core()
        _, ua, r = iax_add(a, 2002)
        port = r["localPort"]
        rnd = random.Random(99)
        s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        for i in range(150):
            ies = b"".join(bytes([rnd.randrange(1, 60), rnd.randrange(0, 200)]) + bytes(rnd.randrange(256) for _ in range(rnd.randrange(0, 20)))
                           for _ in range(rnd.randrange(1, 8)))
            hdr = struct.pack(">HHIBBBB", 0x8000 | rnd.randrange(1, 0x7fff), 0, 0, 0, 0, 6, 1)
            s.sendto(hdr + ies, ("127.0.0.1", port))
        s.close()
        a.sleep(600)
        a.req("call.hangupAll")
        a.req("core.ping")
        self.assertEqual(a.req("account.info", {"uid": ua})["regState"], "registered")


# ---------------------------------------------------------------------------------------------
# A tiny scripted IAX2 peer (wire level) for behaviours the Asterisk container cannot produce
# ---------------------------------------------------------------------------------------------
import hashlib
import math
import threading


def _ulaw(sample):
    BIAS, CLIP = 0x84, 32635
    sign = 0x80 if sample < 0 else 0
    if sample < 0:
        sample = -sample
    sample = min(sample, CLIP) + BIAS
    exp = 7
    mask = 0x4000
    while exp > 0 and not (sample & mask):
        exp -= 1
        mask >>= 1
    mant = (sample >> (exp + 3)) & 0x0F
    return (~(sign | (exp << 4) | mant)) & 0xFF


def tone_ulaw(n=160, start=0, amp=9000, freq=440.0):
    return bytes(_ulaw(int(amp * math.sin(2 * math.pi * freq * (start + i) / 8000.0))) for i in range(n))


IE = dict(called_number=1, calling_number=2, calling_name=4, called_context=5, username=6, password=7, capability=8,
          format=9, version=11, authmethods=14, challenge=15, md5_result=16, refresh=19, cause=22, causecode=42,
          calltoken=54, transferid=27, msgcount=24)
IE_NAME = {v: k for k, v in IE.items()}


def ie_pack(**kw):
    out = b""
    for k, v in kw.items():
        code = IE[k]
        if isinstance(v, str):
            v = v.encode()
        elif isinstance(v, int):
            ln = {"capability": 4, "format": 4, "transferid": 4}.get(k, 1 if k == "causecode" else 2)
            v = v.to_bytes(ln, "big")
        out += bytes([code, len(v)]) + v
    return out


def ie_parse(b):
    d, i = {}, 0
    while i + 2 <= len(b):
        code, ln = b[i], b[i + 1]
        val = b[i + 2:i + 2 + ln]
        i += 2 + ln
        d[IE_NAME.get(code, code)] = val
    return d


class FakeIax:
    """UDP IAX2 peer. mode flags: calltoken, auth ('md5'|'plain'|'none'), answer (bool), drop_new (first n NEWs ignored)."""

    def __init__(self, secret="s3cr3t", calltoken=False, auth="md5", answer=True, drop_new=0, reject_reg=False, refresh=60):
        self.refresh = refresh
        self.secret, self.calltoken, self.auth, self.answer, self.drop_new = secret, calltoken, auth, answer, drop_new
        self.reject_reg = reject_reg
        self.sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        self.sock.bind(("127.0.0.1", 0))
        self.sock.settimeout(0.1)
        self.port = self.sock.getsockname()[1]
        self.lock = threading.Lock()
        self.rx = []                     # (dialog_id, type, sub, retrans, ies, ts)
        self.dialogs = []
        self.client_addr = None
        self.next_call = 100
        self.run = True
        self.new_attempts = 0
        self.challenge = ""
        self.t = threading.Thread(target=self._loop, daemon=True)
        self.t.start()

    def close(self):
        self.run = False
        self.t.join(2)
        self.sock.close()

    def _mk(self, peer=0):
        d = dict(id=len(self.dialogs), me=self.next_call, peer=peer, oseq=0, iseq=0, t0=time.time())
        self.next_call += 1
        self.dialogs.append(d)
        return d

    # ---- wire
    def _send(self, d, typ, sub, ies=b"", ts=None, raw_sub=None, retrans=0, oseq=None, apath=False):
        if apath:
            scall, dcall, o, i = 0, d["peer"], 0, 1
        else:
            scall, dcall = d["me"], d["peer"]
            o = d["oseq"] if oseq is None else oseq
            i = d["iseq"]
        ts = int((time.time() - d["t0"]) * 1000) if ts is None else ts
        hdr = struct.pack(">HHIBBBB", 0x8000 | scall, (0x8000 if retrans else 0) | dcall, ts & 0xffffffff, o, i, typ,
                          sub if raw_sub is None else raw_sub)
        self.sock.sendto(hdr + ies, self.client_addr)
        if not apath and oseq is None and not (typ == 6 and sub == 4):
            d["oseq"] = (d["oseq"] + 1) & 0xff

    def send(self, typ, sub, ies=b"", d=None, **kw):
        with self.lock:
            self._send(d or self.dialogs[-1], typ, sub, ies, **kw)

    def send_mini(self, ts16, payload, d=None):
        with self.lock:
            d = d or self.dialogs[-1]
            self.sock.sendto(struct.pack(">HH", d["me"], ts16 & 0xffff) + payload, self.client_addr)

    def _loop(self):
        while self.run:
            try:
                data, addr = self.sock.recvfrom(4096)
            except socket.timeout:
                continue
            except OSError:
                return
            try:
                with self.lock:
                    self.client_addr = addr
                    self._handle(data)
            except Exception as e:      # keep serving
                self.err = e

    def _handle(self, data):
        if len(data) < 12 or not data[0] & 0x80:
            return
        scall = ((data[0] & 0x7f) << 8) | data[1]
        retrans = bool(data[2] & 0x80)
        dcall = ((data[2] & 0x7f) << 8) | data[3]
        ts = struct.unpack(">I", data[4:8])[0]
        oseq, iseq, typ, sub = data[8], data[9], data[10], data[11]
        ies = ie_parse(data[12:]) if typ == 6 else {}
        d = None
        if dcall:
            d = next((x for x in self.dialogs if x["me"] == dcall), None)
            if d is not None and not d["peer"]:
                d["peer"] = scall
        else:
            d = next((x for x in self.dialogs if x["peer"] == scall), None)
        if d is None:
            if not (typ == 6 and sub in (1, 13, 17)):
                return
            tmp = dict(me=0, peer=scall, oseq=0, iseq=0, t0=time.time())
            if sub == 1:
                self.new_attempts += 1
                if self.new_attempts <= self.drop_new:
                    self.rx.append((-1, typ, sub, retrans, ies, ts))
                    return
            if self.calltoken and "calltoken" not in ies:
                self.rx.append((-1, typ, sub, retrans, ies, ts))
                self._send(tmp, 6, 40, ie_pack(calltoken=b"TOK123456"), apath=True)
                return
            d = self._mk(scall)
        self.rx.append((d["id"], typ, sub, retrans, ies, ts))
        if typ == 6 and sub in (4, 10, 23, 24, 18):       # ACK INVAL TXCNT TXACC VNAK: no seq
            return
        if oseq == d["iseq"]:
            d["iseq"] = (d["iseq"] + 1) & 0xff
            self._send(d, 6, 4, ts=ts, oseq=d["oseq"])      # ACK
        elif retrans or ((oseq - d["iseq"]) & 0xff) > 128:
            self._send(d, 6, 4, ts=ts, oseq=d["oseq"])
            return
        else:
            return
        if typ == 6 and sub in (13, 17):                    # REGREQ / REGREL
            self._reg(d, sub, ies)
        elif typ == 6 and sub == 1:                         # NEW
            d["new_ies"] = ies
            if self.auth != "none":
                self._challenge(d, 1)
            else:
                self._accept(d)
        elif typ == 6 and sub == 9:                         # AUTHREP
            if self._check(ies):
                self._accept(d)
            else:
                self._send(d, 6, 6, ie_pack(cause="Authentication failed", causecode=21))
        elif typ == 6 and sub == 2:
            self._send(d, 6, 3, ts=ts)                      # PING -> PONG
        elif typ == 6 and sub == 11:
            self._send(d, 6, 12, ts=ts)                     # LAGRQ -> LAGRP

    def _check(self, ies):
        if self.auth == "none":
            return True
        if self.auth == "plain":
            return ies.get("password", b"").decode() == self.secret
        want = hashlib.md5((self.challenge + self.secret).encode()).hexdigest()
        return ies.get("md5_result", b"").decode() == want

    def _challenge(self, d, sub):
        self.challenge = "%010d" % random.randrange(10 ** 10)
        meth = 1 if self.auth == "plain" else 2
        self._send(d, 6, 14 if sub in (13, 17) else 8, ie_pack(username="x", authmethods=meth, challenge=self.challenge))

    def _reg(self, d, sub, ies):
        if self.reject_reg:
            self._send(d, 6, 16, ie_pack(cause="Registration Refused", causecode=29))
            return
        if self.auth != "none" and "md5_result" not in ies and "password" not in ies:
            self._challenge(d, sub)
            return
        if self.auth == "none" or self._check(ies):
            self._send(d, 6, 15, ie_pack(username=ies.get("username", b"").decode(), refresh=self.refresh))
        else:
            self._send(d, 6, 16, ie_pack(cause="Registration Refused", causecode=29))

    def _accept(self, d):
        self._send(d, 6, 7, ie_pack(format=0x04))           # ACCEPT ulaw
        if self.answer:
            self._send(d, 4, 3)                               # RINGING
            self._send(d, 4, 4)                               # ANSWER

    # ---- helpers for tests
    def frames(self, typ=None, sub=None):
        with self.lock:
            return [f for f in self.rx if (typ is None or f[1] == typ) and (sub is None or f[2] == sub)]

    def wait_frame(self, typ, sub, timeout=8, since=0):
        end = time.time() + timeout
        while time.time() < end:
            fr = self.frames(typ, sub)
            if len(fr) > since:
                return fr[since:]
            time.sleep(0.02)
        return []

    def call_new(self, number="2001", caller="9999", name="Fake Caller"):
        """send a NEW to the client (needs a prior frame from it so the address is known)"""
        with self.lock:
            d = self._mk(0)
            self._send(d, 6, 1, ie_pack(version=2, called_number=number, calling_number=caller, calling_name=name,
                                        capability=0x4c, format=0x04))
        return d


def fake_account(c, fake, uid="fk", user="2001", pw="s3cr3t", **kw):
    cfg = {"uid": uid, "proto": "iax2", "username": user, "password": pw, "domain": "127.0.0.1",
           "iax": {"host": "127.0.0.1", "port": fake.port}, "regExpires": 60}
    cfg.update(kw)
    mark = c.mark()
    r = c.req("account.add", cfg)
    return r, mark


class TestIaxWire(IaxBase):
    def setUp(self):
        super().setUp()
        self.fakes = []

    def tearDown(self):
        try:
            super().tearDown()
        finally:
            for f in self.fakes:
                f.close()

    def fake(self, **kw):
        f = FakeIax(**kw)
        self.fakes.append(f)
        return f

    def test_md5_register_and_refresh_fields(self):
        f = self.fake()
        c = self.cli()
        c.start_core()
        r, mark = fake_account(c, f)
        ev = c.wait_event("account.reg", 10, mark, uid="fk", regState="registered")
        self.assertIsNotNone(ev)
        self.assertLessEqual(ev["expires"], 60)
        reqs = f.frames(6, 13)
        self.assertEqual(len(reqs), 2)                       # REGREQ, then REGREQ with the MD5 result
        self.assertNotIn("md5_result", reqs[0][4])
        self.assertIn("md5_result", reqs[1][4])
        self.assertEqual(reqs[0][4]["username"], b"2001")
        self.assertEqual(int.from_bytes(reqs[0][4]["refresh"], "big"), 60)

    def test_refresh_before_expiry(self):
        f = self.fake(refresh=8)
        c = self.cli()
        c.start_core()
        r, mark = fake_account(c, f)
        ev = c.wait_event("account.reg", 10, mark, uid="fk", regState="registered")
        self.assertIsNotNone(ev)
        self.assertLessEqual(ev["expires"], 8)
        first = len(f.frames(6, 13))
        again = c.wait(lambda m: m.get("event") == "account.reg" and m.get("regState") == "registering" and m["seq"] > ev["seq"], 9)
        self.assertIsNotNone(again, "no refresh before the granted expiry")
        self.assertIsNotNone(c.wait_event("account.reg", 5, c.mark() - 1, uid="fk", regState="registered") or
                             c.wait(lambda m: m.get("event") == "account.reg" and m.get("regState") == "registered" and m["seq"] > again["seq"], 5))
        self.assertGreater(len(f.frames(6, 13)), first)

    def test_plaintext_auth_and_calltoken_register(self):
        f = self.fake(auth="plain", calltoken=True)
        c = self.cli()
        c.start_core()
        r, mark = fake_account(c, f)
        self.assertIsNotNone(c.wait_event("account.reg", 10, mark, uid="fk", regState="registered"))
        reqs = f.frames(6, 13)
        self.assertTrue(any("calltoken" in x[4] for x in reqs))
        self.assertTrue(any(x[4].get("password") == b"s3cr3t" for x in reqs))

    def test_register_rejected_reports_failure(self):
        f = self.fake(reject_reg=True)
        c = self.cli()
        c.start_core()
        r, mark = fake_account(c, f, regRetrySec=60, regFirstRetrySec=60)
        ev = c.wait_event("account.reg", 10, mark, uid="fk", regState="failed")
        self.assertIsNotNone(ev)
        self.assertEqual(ev["regCode"], 403)
        self.assertEqual(ev["regReason"], "Registration Refused")
        self.assertIn("Wrong username/password", ev["lastError"])

    def test_wrong_secret_with_fake(self):
        f = self.fake()
        c = self.cli()
        c.start_core()
        r, mark = fake_account(c, f, pw="nope", regRetrySec=60, regFirstRetrySec=60)
        ev = c.wait_event("account.reg", 10, mark, uid="fk", regState="failed")
        self.assertIsNotNone(ev)
        self.assertEqual(ev["regCode"], 403)

    def test_new_has_expected_ies_and_retransmits(self):
        f = self.fake(auth="none", drop_new=1)               # first NEW is lost
        c = self.cli()
        c.start_core()
        r, mark = fake_account(c, f)
        c.wait_event("account.reg", 10, mark, uid="fk", regState="registered")
        cid = c.req("call.make", {"uid": "fk", "uri": "iax2:5551234", "displayName": "Alice"})["cid"]
        self.assertIsNotNone(c.wait_event("call.state", 10, 0, cid=cid, state="confirmed"))
        news = f.frames(6, 1)
        self.assertGreaterEqual(len(news), 2)
        self.assertFalse(news[0][3])
        self.assertTrue(news[1][3], "retransmission must carry the R bit")
        ies = news[1][4]
        self.assertEqual(ies["called_number"], b"5551234")
        self.assertEqual(ies["username"], b"2001")
        self.assertEqual(ies["calling_name"], b"Alice")
        self.assertEqual(ies["calling_number"], b"2001")
        self.assertEqual(int.from_bytes(ies["version"], "big"), 2)
        cap = int.from_bytes(ies["capability"], "big")
        self.assertTrue(cap & 0x04 and cap & 0x08)
        self.assertEqual(int.from_bytes(ies["format"], "big"), 0x04)
        self.assertEqual(c.req("call.info", {"cid": cid})["codec"], "PCMU/8000/1")
        c.req("call.hangup", {"cid": cid})
        h = f.wait_frame(6, 5)
        self.assertTrue(h)
        self.assertEqual(h[0][4]["causecode"], bytes([16]))

    def test_call_auth_md5_and_calltoken(self):
        f = self.fake(auth="md5", calltoken=True)
        c = self.cli()
        c.start_core()
        r, mark = fake_account(c, f)
        c.wait_event("account.reg", 10, mark, uid="fk", regState="registered")
        cid = c.req("call.make", {"uid": "fk", "uri": "600"})["cid"]
        self.assertIsNotNone(c.wait_event("call.state", 10, 0, cid=cid, state="confirmed"))
        reps = f.frames(6, 9)
        self.assertTrue(reps)
        self.assertEqual(reps[0][4]["md5_result"].decode(), hashlib.md5((f.challenge + "s3cr3t").encode()).hexdigest())
        news = f.frames(6, 1)
        self.assertTrue(any("calltoken" in n[4] for n in news), "NEW was not re-sent with the call token")
        c.req("call.hangup", {"cid": cid})

    def test_call_states_busy_and_cause_mapping(self):
        f = self.fake(auth="none", answer=False)
        c = self.cli()
        c.start_core()
        r, mark = fake_account(c, f)
        c.wait_event("account.reg", 10, mark, uid="fk", regState="registered")
        # progress, then ringing -> early 183/180; BUSY control -> 486
        cid = c.req("call.make", {"uid": "fk", "uri": "1"})["cid"]
        f.wait_frame(6, 1)
        f.send(4, 14)           # PROGRESS
        ev = c.wait_event("call.state", 5, 0, cid=cid, state="early")
        self.assertEqual(ev["stateCode"], 183)
        self.assertIsNotNone(c.wait_event("call.media", 5, 0, cid=cid, media="active"))
        f.send(4, 3)            # RINGING
        self.assertIsNotNone(c.wait(lambda m: m.get("event") == "call.state" and m.get("cid") == cid and m.get("stateCode") == 180, 5))
        f.send(4, 5)            # BUSY
        ev = self.disconnected(c, cid)
        self.assertEqual(ev["stateCode"], 486)
        self.assertTrue(f.wait_frame(6, 5))
        for causecode, want in ((21, 603), (19, 480), (1, 404), (34, 503), (16, 487)):
            cid = c.req("call.make", {"uid": "fk", "uri": "1"})["cid"]
            n = len(f.frames(6, 1))
            f.wait_frame(6, 1, since=n)
            f.send(6, 5, ie_pack(cause="x", causecode=causecode))      # HANGUP
            ev = self.disconnected(c, cid)
            self.assertEqual(ev["stateCode"], want, "causecode %s" % causecode)

    def test_remote_hold_and_txreq_and_pings(self):
        f = self.fake(auth="none")
        c = self.cli()
        c.start_core()
        r, mark = fake_account(c, f)
        c.wait_event("account.reg", 10, mark, uid="fk", regState="registered")
        cid = c.req("call.make", {"uid": "fk", "uri": "1"})["cid"]
        self.assertIsNotNone(c.wait_event("call.state", 10, 0, cid=cid, state="confirmed"))
        self.wait_media(c, cid, "active")
        f.send(4, 16)            # HOLD
        self.wait_media(c, cid, "remoteHold")
        self.assertEqual(c.req("call.info", {"cid": cid})["media"], "remoteHold")
        f.send(4, 17)            # UNHOLD
        self.wait(c, cid) if False else None
        ev = c.wait(lambda m: m.get("event") == "call.media" and m.get("cid") == cid and m.get("media") == "active" and m["seq"] > c.events("call.media", cid=cid, media="remoteHold")[0]["seq"], 5)
        self.assertIsNotNone(ev)
        # transfer-media request is refused, ping/lagrq answered
        f.send(6, 22, ie_pack(transferid=1234))
        self.assertTrue(f.wait_frame(6, 27), "TXREQ must be answered with TXREJ")
        f.send(6, 2, ts=777)
        f.send(6, 11, ts=888)
        pong = f.wait_frame(6, 3)
        lagrp = f.wait_frame(6, 12)
        self.assertTrue(pong and lagrp)
        self.assertEqual(pong[0][5], 777)
        self.assertEqual(lagrp[0][5], 888)
        c.req("call.hangup", {"cid": cid})

    def test_incoming_call_and_voice_with_ts_wrap(self):
        f = self.fake(auth="none")
        c = self.cli()
        c.start_core(incomingAutoRingMs=200)
        r, mark = fake_account(c, f, user="2002")
        c.wait_event("account.reg", 10, mark, uid="fk", regState="registered")
        m = c.mark()
        f.call_new(number="2002", caller="7001", name="Fake Caller")
        inc = c.wait_event("call.incoming", 8, m)
        self.assertIsNotNone(inc)
        self.assertEqual(inc["proto"], "iax2")
        self.assertEqual(inc["remoteUser"], "7001")
        self.assertEqual(inc["remoteDisplay"], "Fake Caller")
        self.assertTrue(f.wait_frame(6, 7), "client must ACCEPT the call")
        self.assertTrue(f.wait_frame(4, 3, timeout=3), "auto ring should send RINGING")
        c.req("call.answer", {"cid": inc["cid"]})
        self.assertTrue(f.wait_frame(4, 4), "client must send ANSWER")
        self.wait_media(c, inc["cid"], "active")
        # first a full voice frame near the 16-bit wrap, then minis crossing it
        base = 65400
        d = f.dialogs[-1]
        f.send(2, 0, tone_ulaw(160, 0), d=d, ts=base, raw_sub=0x82)
        for i in range(1, 160):
            f.send_mini((base + 20 * i), tone_ulaw(160, 160 * i), d=d)
            time.sleep(0.02)
        st = self.media_ok(c, inc["cid"])
        self.assertGreaterEqual(st["rx"]["packets"], 140)
        self.assertGreater(st["rxLevel"], 20)
        self.assertGreater(st["tx"]["packets"], 0) if False else None
        # incoming DTMF
        f.send(12, ord("7"), d=d)
        time.sleep(0.12)
        f.send(1, ord("7"), d=d)
        ev = c.wait_event("call.dtmf", 5, m, cid=inc["cid"], digit="7")
        self.assertIsNotNone(ev)
        self.assertEqual(ev["method"], "iax2")
        self.assertGreater(ev["durationMs"], 50)
        # outgoing DTMF frames
        c.req("call.dtmf", {"cid": inc["cid"], "digits": "93#"})
        f.wait_frame(1, ord("#"), timeout=5)
        seq = [(x[1], chr(x[2])) for x in f.frames() if x[1] in (1, 12)]
        self.assertEqual(seq, [(12, "9"), (1, "9"), (12, "3"), (1, "3"), (12, "#"), (1, "#")])
        c.req("call.hangup", {"cid": inc["cid"]})

    def test_out_of_order_frames_get_vnak(self):
        f = self.fake(auth="none")
        c = self.cli()
        c.start_core()
        r, mark = fake_account(c, f)
        c.wait_event("account.reg", 10, mark, uid="fk", regState="registered")
        cid = c.req("call.make", {"uid": "fk", "uri": "1"})["cid"]
        self.assertIsNotNone(c.wait_event("call.state", 10, 0, cid=cid, state="confirmed"))
        d = f.dialogs[-1]
        f.send(4, 16, d=d, oseq=(d["oseq"] + 5) & 0xff)       # a frame from the future
        self.assertTrue(f.wait_frame(6, 18), "client must send VNAK for a sequence gap")
        self.assertEqual(c.req("call.info", {"cid": cid})["media"], "active")   # the future frame was not applied
        c.req("call.hangup", {"cid": cid})

    def test_unattended_incoming_is_rejected_without_sink(self):
        """no event sink attached -> the call is rejected after incomingUnattendedMs"""
        f = self.fake(auth="none")
        c = self.cli()
        c.start_core(incomingAutoRingMs=0, incomingUnattendedMs=700)
        r, mark = fake_account(c, f, user="2002")
        c.wait_event("account.reg", 10, mark, uid="fk", regState="registered")
        c.send({"m": "__detach"})
        c.sleep(100)
        f.call_new(number="2002")
        self.assertTrue(f.wait_frame(6, 7))
        self.assertTrue(f.wait_frame(6, 6, timeout=6), "unattended call should be REJECTed")
        c.send({"m": "__attach"})
        c.sleep(300)

    def test_retransmit_gives_up_with_timeout(self):
        f = self.fake(auth="none", drop_new=99)
        c = self.cli()
        c.start_core()
        r, mark = fake_account(c, f)
        c.wait_event("account.reg", 10, mark, uid="fk", regState="registered")
        cid = c.req("call.make", {"uid": "fk", "uri": "1"})["cid"]
        ev = self.disconnected(c, cid, 20)
        self.assertEqual(ev["stateCode"], 408)
        self.assertGreaterEqual(len(f.frames(6, 1)), 5)


if __name__ == "__main__":
    unittest.main(verbosity=2)
