"""Live metering, echo test and local playback (ENGINE_API.md 11): media.monitor, media.audioState, media.loopback
(timeout / BUSY / events), media.playLocal / media.playStop and the `chime` tone.

Run via run_tests.py (auto-loaded). These tests use the null sound device (`noAudioDevice`, the harness default), so
they need no microphone or speaker: what is checked is the contract (results, events, state), not live audio levels.
The live-device checks (levels from a real capture device, EC bypass) are in the manual procedure of
docs/ENGINE_API.md 11.
"""
import os
import time

from run_tests import Base, RpcError, TMP, make_tone_wav

LEVEL_KEYS = ("mic", "speaker", "musicbed", "send", "calls")


class TestAudioMonitor(Base):
    def one(self, **kw):
        a = self.cli("A")
        a.start_core(**kw)
        return a

    def test_monitor_state_and_event(self):
        a = self.one()
        r = a.req("media.monitor", {"enabled": True})
        # the null device is not a real microphone: not "active", source tells why
        self.assertEqual((r["active"], r["source"]), (False, "null"))
        self.assertEqual(set(r), {"active", "source", "capture", "playback"})
        st = a.req("media.audioState")
        self.assertTrue(st["monitor"])
        self.assertEqual(st["source"], "null")
        self.assertIsNone(st["capture"])
        self.assertIsNone(st["playback"])
        self.assertEqual(st["sndClockRate"], 0)
        self.assertEqual(set(st["ec"]), {"tailMs", "options", "bypassed"})
        self.assertFalse(st["ec"]["bypassed"])
        self.assertFalse(st["loopback"])
        lv = a.req("media.levels")
        for k in LEVEL_KEYS:
            self.assertIn(k, lv)
        self.assertEqual(lv["send"], 0)
        # idempotent; turning it off keeps working
        self.assertEqual(a.req("media.monitor", {"enabled": True})["source"], "null")
        self.assertFalse(a.req("media.monitor", {"enabled": False})["active"])
        self.assertFalse(a.req("media.audioState")["monitor"])
        # no change of (active, source) after the null device was attached: at most the first state event, none after
        n = len(a.events("media.monitor"))
        a.req("media.monitor", {"enabled": True})
        a.req("media.monitor", {"enabled": False})
        self.assertEqual(len(a.events("media.monitor")), n)
        for bad in ({}, {"enabled": 1}, {"enabled": "yes"}):
            with self.assertRaises(RpcError) as cm:
                a.req("media.monitor", bad)
            self.assertEqual(cm.exception.code, "INVALID_PARAM")

    def test_loopback_events_timeout_and_params(self):
        a = self.one()
        for bad in ({"enabled": True, "timeoutMs": -1}, {"enabled": True, "timeoutMs": 600001}, {"enabled": True, "timeoutMs": "x"}):
            with self.assertRaises(RpcError) as cm:
                a.req("media.loopback", bad)
            self.assertEqual(cm.exception.code, "INVALID_PARAM")
        # stop without start: no event
        m = a.mark()
        a.req("media.loopback", {"enabled": False})
        a.sleep(300)
        self.assertEqual(a.events("media.loopback"), [])
        # explicit stop
        a.req("media.loopback", {"enabled": True})
        st = a.req("media.audioState")
        self.assertTrue(st["loopback"])
        self.assertTrue(st["ec"]["bypassed"])
        a.req("media.loopback", {"enabled": False})
        ev = a.wait_event("media.loopback", 3, m, enabled=False)
        self.assertEqual(ev["reason"], "stopped")
        self.assertFalse(a.req("media.audioState")["ec"]["bypassed"])
        # timeout
        m = a.mark()
        t0 = time.time()
        a.req("media.loopback", {"enabled": True, "timeoutMs": 1200})
        ev = a.wait_event("media.loopback", 4, m, enabled=False)
        self.assertIsNotNone(ev)
        self.assertEqual(ev["reason"], "timeout")
        self.assertTrue(1.0 <= time.time() - t0 < 3.0)
        st = a.req("media.audioState")
        self.assertFalse(st["loopback"])
        self.assertFalse(st["ec"]["bypassed"])
        # a stopped test's timer does not end the next one
        a.req("media.loopback", {"enabled": True, "timeoutMs": 800})
        a.req("media.loopback", {"enabled": False})
        m = a.mark()
        a.req("media.loopback", {"enabled": True})
        a.sleep(1500)
        self.assertTrue(a.req("media.audioState")["loopback"])
        self.assertIsNone(a.wait_event("media.loopback", 0.1, m, enabled=False))
        a.req("media.loopback", {"enabled": False})

    def test_set_ec_while_bypassed(self):
        a = self.one()
        a.req("media.loopback", {"enabled": True})
        a.req("media.setEc", {"algo": "speex", "tailMs": 100})
        st = a.req("media.audioState")
        self.assertTrue(st["ec"]["bypassed"])
        self.assertEqual(st["ec"]["tailMs"], 100)       # the setting that applies when the echo test ends
        a.req("media.loopback", {"enabled": False})
        st = a.req("media.audioState")
        self.assertFalse(st["ec"]["bypassed"])
        self.assertEqual(st["ec"]["tailMs"], 100)

    def test_loopback_busy_and_ends_with_a_call(self):
        a, b = self.cli("A"), self.cli("B")
        a.start_core()
        rb = b.start_core()
        port = [t for t in rb["transports"] if t["type"] == "udp"][0]["local"].split(":")[1]
        a.req("media.loopback", {"enabled": True})
        m, mb = a.mark(), b.mark()
        cid = a.req("call.make", {"acc": -1, "uri": "sip:127.0.0.1:%s" % port})["cid"]
        ev = a.wait_event("media.loopback", 3, m, enabled=False)
        self.assertIsNotNone(ev, "the echo test did not end when the call started")
        self.assertEqual(ev["reason"], "call")
        self.assertFalse(a.req("media.audioState")["ec"]["bypassed"])
        with self.assertRaises(RpcError) as cm:
            a.req("media.loopback", {"enabled": True})
        self.assertEqual(cm.exception.code, "BUSY")
        inc = b.wait_event("call.incoming", 10, mb)
        self.assertIsNotNone(inc)
        a.req("call.hangup", {"cid": cid})
        self.assertIsNotNone(a.wait_event("call.state", 10, m, cid=cid, state="disconnected"))
        # after the call it is available again
        a.req("media.loopback", {"enabled": True})
        a.req("media.loopback", {"enabled": False})

    def test_play_local(self):
        a = self.one()
        wav = make_tone_wav(os.path.join(TMP, "pl_local.wav"), 0.6, 8000, 440.0, 0.5)
        m = a.mark()
        p = a.req("media.playLocal", {"file": wav})
        self.assertIsInstance(p["playId"], int)
        ev = a.wait_event("media.playDone", 5, m, playId=p["playId"])
        self.assertIsNotNone(ev)
        self.assertEqual(ev["reason"], "eof")
        self.assertEqual(ev["file"], wav)
        self.assertNotIn("cid", ev)                      # a local play belongs to no call
        self.assertEqual(a.events("call.playDone"), [])
        # stop by id, stop all, nothing to stop
        long_wav = make_tone_wav(os.path.join(TMP, "pl_local_long.wav"), 5.0, 8000, 440.0, 0.5)
        p1 = a.req("media.playLocal", {"file": long_wav, "volume": 0.5})["playId"]
        p2 = a.req("media.playLocal", {"file": long_wav})["playId"]
        self.assertNotEqual(p1, p2)
        m = a.mark()
        self.assertEqual(a.req("media.playStop", {"playId": p1}), {"stopped": 1})
        self.assertEqual(a.wait_event("media.playDone", 3, m, playId=p1)["reason"], "stopped")
        self.assertEqual(a.req("media.playStop", {"playId": p1}), {"stopped": 0})
        self.assertEqual(a.req("media.playStop", {}), {"stopped": 1})
        self.assertEqual(a.wait_event("media.playDone", 3, m, playId=p2)["reason"], "stopped")
        # parameters
        for bad in ({}, {"file": ""}, {"file": wav, "volume": 4.5}, {"file": wav, "volume": -1},
                    {"file": os.path.join(TMP, "does_not_exist.wav")}):
            with self.assertRaises(RpcError) as cm:
                a.req("media.playLocal", bad)
            self.assertEqual(cm.exception.code, "INVALID_PARAM")
        with self.assertRaises(RpcError) as cm:
            a.req("media.playStop", {"playId": -1})
        self.assertEqual(cm.exception.code, "INVALID_PARAM")

    def test_chime_tone(self):
        a = self.one()
        a.req("media.tone", {"kind": "chime"})
        a.sleep(200)
        a.req("media.toneStop")
        a.req("media.tone", {"kind": "chime", "loop": False})
        with self.assertRaises(RpcError):
            a.req("media.tone", {"kind": "nonsense"})
        a.req("media.toneStop")

    def test_refresh_devices_and_set_devices_keep_monitor(self):
        a = self.one()
        a.req("media.monitor", {"enabled": True})
        a.req("media.refreshDevices")
        a.req("media.setDevices", {"capture": "null", "playback": "null"})
        st = a.req("media.audioState")
        self.assertTrue(st["monitor"])
        self.assertEqual(st["source"], "null")
        with self.assertRaises(RpcError) as cm:
            a.req("media.setDevices", {"capture": "no such device"})
        self.assertEqual(cm.exception.code, "NOT_FOUND")
        self.assertEqual(a.events("media.error"), [])
        a.req("media.monitor", {"enabled": False})
