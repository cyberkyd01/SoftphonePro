"""Musicbed (ENGINE_API.md 10): a looping file mixed into the microphone path of every call, independent of call.mute.

Calls are direct IP calls between spcore_cli processes (no PBX) except the IAX2 test. B measures what arrives
(call.stats rxLevel, remote recordings); "bed" tones are 440 Hz, music on hold 900 Hz, so they can be told apart.
"""
import os
import time

from run_tests import Base, RpcError, TMP, make_tone_wav
from test_media_files import MP3, read_wav, goertzel, rms, write_wav, sine

BED_HZ = 440.0
MOH_HZ = 900.0


def bed_file(name="bed.wav", seconds=0.6, rate=8000, freq=BED_HZ, amp=0.6):
    return make_tone_wav(os.path.join(TMP, name), seconds, rate, freq, amp)


class BedBase(Base):
    def pair(self, **kw):
        a, b = self.cli("A"), self.cli("B")
        a.start_core(**kw)
        rb = b.start_core(**kw)
        port = [t for t in rb["transports"] if t["type"] == "udp"][0]["local"].split(":")[1]
        return a, b, port

    def call(self, a, b, port):
        mb = b.mark()
        ma = a.mark()
        cid_a = a.req("call.make", {"acc": -1, "uri": "sip:127.0.0.1:%s" % port})["cid"]
        inc = b.wait_event("call.incoming", 15, mb)
        self.assertIsNotNone(inc, "B got no call")
        cid_b = inc["cid"]
        b.req("call.answer", {"cid": cid_b})
        self.assertIsNotNone(a.wait_event("call.state", 15, ma, cid=cid_a, state="confirmed"))
        self.assertIsNotNone(b.wait_event("call.state", 15, mb, cid=cid_b, state="confirmed"))
        self.wait_media(a, cid_a)
        self.wait_media(b, cid_b)
        return cid_a, cid_b

    def direct_call(self, **kw):
        a, b, port = self.pair(**kw)
        ca, cb = self.call(a, b, port)
        return a, b, ca, cb

    def heard(self, b, cid_b, timeout=10, level=5):
        return self.poll(lambda: (lambda s: s if s["rxLevel"] > level else None)(b.req("call.stats", {"cid": cid_b})), timeout, 0.1)

    def silent(self, b, cid_b, timeout=10):
        def f():
            s = b.req("call.stats", {"cid": cid_b})
            return s if s["rxLevel"] == 0 else None
        return self.poll(f, timeout, 0.1)

    def record_remote(self, b, cid_b, seconds, name, **kw):
        path = os.path.join(TMP, name)
        b.req("call.recordStart", dict({"cid": cid_b, "file": path, "mix": "remote"}, **kw))
        time.sleep(seconds)
        b.req("call.recordStop", {"cid": cid_b})
        ch, rate = read_wav(path)
        x = ch[0]
        return x[len(x) // 4:], rate

    def tone_amp(self, b, cid_b, name, freq=BED_HZ, seconds=1.0):
        x, rate = self.record_remote(b, cid_b, seconds, name)
        return goertzel(x, rate, freq)

    def levels(self, c):
        return c.req("media.levels")

    def bed_events(self, c, mark=0):
        return [m for m in c.log[mark:] if m.get("type") == "event" and m.get("event") == "media.musicbed"]


class TestMusicbedBasics(BedBase):
    def test_start_state_stop_and_events(self):
        a = self.cli("A")
        a.start_core()
        f = bed_file()
        st = a.req("media.musicbedState")
        self.assertFalse(st["active"])
        self.assertEqual((st["volume"], st["monitor"], st["monitorVolume"], st["paused"], st["calls"]), (0.3, False, 0.5, False, []))
        mark = a.mark()
        r = a.req("media.musicbedStart", {"file": f})
        self.assertEqual((r["file"], r["format"]), (f, "wav"))
        self.assertAlmostEqual(r["durationMs"], 600, delta=10)
        ev = self.bed_events(a, mark)
        self.assertEqual([(e["active"], e["reason"], e.get("file")) for e in ev], [(True, "started", f)])
        st = a.req("media.musicbedState")
        self.assertTrue(st["active"])
        self.assertEqual((st["file"], st["format"], st["volume"], st["monitor"], st["monitorVolume"], st["paused"]),
                         (f, "wav", 0.3, False, 0.5, False))
        self.assertEqual(st["durationMs"], r["durationMs"])
        self.assertEqual(st["calls"], [])
        a.req("media.musicbedSet", {"volume": 1.5, "monitorVolume": 0.25})
        st = a.req("media.musicbedState")
        self.assertEqual((st["volume"], st["monitorVolume"]), (1.5, 0.25))
        mark = a.mark()
        self.assertEqual(a.req("media.musicbedStop"), {"stopped": True})
        ev = self.bed_events(a, mark)
        self.assertEqual([(e["active"], e["reason"]) for e in ev], [(False, "stopped")])
        self.assertFalse(a.req("media.musicbedState")["active"])
        self.assertEqual(a.req("media.musicbedStop"), {"stopped": False})     # not an error
        self.assertEqual(self.bed_events(a, mark)[-1]["reason"], "stopped")
        self.assertEqual(len(self.bed_events(a, mark)), 1)
        # MP3
        r = a.req("media.musicbedStart", {"file": MP3, "volume": 0.0})
        self.assertEqual(r["format"], "mp3")
        self.assertAlmostEqual(r["durationMs"], 3000, delta=100)
        self.assertEqual(a.req("media.musicbedState")["volume"], 0.0)

    def test_validation_and_bad_start_leaves_running_bed(self):
        a = self.cli("A")
        a.start_core()
        f = bed_file()
        garbage = os.path.join(TMP, "mb_garbage.wav")
        with open(garbage, "wb") as fh:
            fh.write(b"not audio at all " * 200)
        empty = write_wav(os.path.join(TMP, "mb_empty.wav"), [[]], 8000)
        for p in ({}, {"file": ""}, {"file": os.path.join(TMP, "mb_missing.wav")}, {"file": garbage}, {"file": empty},
                  {"file": TMP}, {"file": f, "volume": 2.5}, {"file": f, "volume": -0.1}, {"file": f, "volume": "x"},
                  {"file": f, "monitorVolume": 3}, {"file": f, "monitor": "yes"}):
            r = a.raw("media.musicbedStart", p)
            self.assertFalse(r["ok"], p)
            self.assertEqual(r["error"]["code"], "INVALID_PARAM", (p, r))
        self.assertFalse(a.req("media.musicbedState")["active"])
        self.assertEqual(self.bed_events(a), [])
        # a bad request does not disturb the running one
        a.req("media.musicbedStart", {"file": f, "volume": 0.7})
        mark = a.mark()
        for p in ({"file": garbage}, {"file": f, "volume": 9}, {"file": os.path.join(TMP, "mb_missing.wav")}):
            self.assertEqual(a.raw("media.musicbedStart", p)["error"]["code"], "INVALID_PARAM")
        st = a.req("media.musicbedState")
        self.assertTrue(st["active"])
        self.assertEqual((st["file"], st["volume"]), (f, 0.7))
        self.assertEqual(self.bed_events(a, mark), [])
        # set
        self.assertEqual(a.raw("media.musicbedSet", {})["error"]["code"], "INVALID_PARAM")
        for p in ({"volume": 2.1}, {"volume": -1}, {"monitorVolume": 5}, {"monitor": 1}, {"paused": "x"}, {"volume": "1"}):
            self.assertEqual(a.raw("media.musicbedSet", p)["error"]["code"], "INVALID_PARAM", p)
        self.assertEqual(a.req("media.musicbedState")["volume"], 0.7)
        a.req("media.musicbedStop")
        self.assertEqual(a.raw("media.musicbedSet", {"volume": 0.5})["error"]["code"], "NOT_FOUND")

    def test_replace_event_order(self):
        a = self.cli("A")
        a.start_core()
        f1, f2 = bed_file("mb_r1.wav"), bed_file("mb_r2.wav", freq=700.0)
        a.req("media.musicbedStart", {"file": f1, "volume": 0.4})
        mark = a.mark()
        a.req("media.musicbedStart", {"file": f2, "volume": 0.8, "monitor": False})
        ev = self.bed_events(a, mark)
        self.assertEqual([(e["active"], e["reason"], e["file"]) for e in ev], [(False, "replaced", f1), (True, "started", f2)])
        st = a.req("media.musicbedState")
        self.assertEqual((st["file"], st["volume"]), (f2, 0.8))

    def test_core_stop_emits_shutdown(self):
        a = self.cli("A")
        a.start_core()
        f = bed_file()
        a.req("media.musicbedStart", {"file": f})
        mark = a.mark()
        a.req("core.stop", {"graceful": True})
        ev = self.bed_events(a, mark)
        self.assertEqual([(e["active"], e["reason"]) for e in ev], [(False, "shutdown")])
        # restart: nothing running
        a.start_core()
        self.assertFalse(a.req("media.musicbedState")["active"])


class TestMusicbedCalls(BedBase):
    def test_far_end_receives_bed_while_muted_and_volume(self):
        a, b, ca, cb = self.direct_call()
        f = bed_file()
        self.assertIsNone(self.heard(b, cb, 1.0), "B hears something before the bed")
        a.req("call.mute", {"cid": ca, "mute": True})
        a.req("media.musicbedStart", {"file": f, "volume": 0.5})
        self.assertIsNotNone(self.heard(b, cb, 8), "B does not receive the bed with the mic muted")
        st = a.req("media.musicbedState")
        self.assertEqual(st["calls"], [ca])
        amp1 = self.tone_amp(b, cb, "mb_v05.wav")
        self.assertGreater(amp1, 1000)                                  # 0.6 * 0.5 * 32767 ~ 9800 nominal
        # live volume change: double
        a.req("media.musicbedSet", {"volume": 1.0})
        time.sleep(0.4)
        amp2 = self.tone_amp(b, cb, "mb_v10.wav")
        self.assertGreater(amp2, 1.6 * amp1, "volume 1.0 not louder than 0.5 (%s vs %s)" % (amp2, amp1))
        self.assertLess(amp2, 2.5 * amp1)
        # volume 0: silence
        a.req("media.musicbedSet", {"volume": 0.0})
        self.assertIsNotNone(self.silent(b, cb, 8), "volume 0 is not silent")
        a.req("media.musicbedSet", {"volume": 0.5})
        self.assertIsNotNone(self.heard(b, cb, 8))
        # the announcement mute (muteMic) does not silence it either
        p = make_tone_wav(os.path.join(TMP, "mb_ann.wav"), 30.0, 8000, 1300.0)
        a.req("call.playFile", {"cid": ca, "file": p, "muteMic": True})
        x, rate = self.record_remote(b, cb, 1.0, "mb_ann_rec.wav")
        self.assertGreater(goertzel(x, rate, BED_HZ), 800, "bed lost during the announcement mute")
        self.assertGreater(goertzel(x, rate, 1300.0), 800, "announcement missing")
        a.req("call.stopFile", {"cid": ca})
        # stop
        a.req("media.musicbedStop")
        self.assertIsNotNone(self.silent(b, cb, 8), "B still hears the bed after stop")

    def test_mp3_bed_arrives(self):
        a, b, ca, cb = self.direct_call()
        a.req("media.musicbedStart", {"file": MP3, "volume": 0.8})
        self.assertIsNotNone(self.heard(b, cb, 8))
        time.sleep(3.5)         # past one loop of the 3 s file: still audible
        self.assertIsNotNone(self.heard(b, cb, 3), "bed stopped after one pass")
        self.assertEqual(self.bed_events(a)[-1]["reason"], "started")

    def test_call_started_after_bed_gets_it(self):
        a, b, port = self.pair()
        a.req("media.musicbedStart", {"file": bed_file(), "volume": 0.6})
        self.assertEqual(a.req("media.musicbedState")["calls"], [])
        ca, cb = self.call(a, b, port)
        self.assertIsNotNone(self.heard(b, cb, 8), "late call does not get the bed")
        self.assertEqual(a.req("media.musicbedState")["calls"], [ca])
        # and the callee side works too: B (callee) starts its own bed
        b.req("media.musicbedStart", {"file": bed_file("mb_b.wav", freq=700.0), "volume": 0.6})
        self.assertIsNotNone(self.heard(a, ca, 8), "callee-side bed not heard")
        a.req("call.hangup", {"cid": ca})
        self.assertIsNotNone(b.wait_event("call.state", 10, 0, cid=cb, state="disconnected"))
        self.poll(lambda: a.req("media.musicbedState")["calls"] == [], 5)
        self.assertEqual(a.req("media.musicbedState")["calls"], [])
        self.assertTrue(a.req("media.musicbedState")["active"])        # the bed outlives the call

    def test_pause_resume_and_position(self):
        a, b, ca, cb = self.direct_call()
        a.req("media.musicbedStart", {"file": bed_file("mb_pos.wav", seconds=10.0), "volume": 0.6})
        self.assertIsNotNone(self.heard(b, cb, 8))
        time.sleep(0.5)
        p1 = a.req("media.musicbedState")["positionMs"]
        self.assertGreater(p1, 100)
        a.req("media.musicbedSet", {"paused": True})
        self.assertTrue(a.req("media.musicbedState")["paused"])
        self.assertIsNotNone(self.silent(b, cb, 8), "paused bed is not silent")
        self.assertEqual(self.levels(a)["musicbed"], 0)
        p2 = a.req("media.musicbedState")["positionMs"]
        time.sleep(0.6)
        p3 = a.req("media.musicbedState")["positionMs"]
        self.assertEqual(p2, p3, "position moved while paused")
        self.assertGreaterEqual(p2, p1)
        a.req("media.musicbedSet", {"paused": False})
        self.assertIsNotNone(self.heard(b, cb, 8), "bed does not resume")
        time.sleep(0.5)
        p4 = a.req("media.musicbedState")["positionMs"]
        self.assertGreater(p4, p3 + 200, "did not resume from the paused position")
        self.assertLess(p4, p3 + 3000)

    def test_hold_disconnects_and_unhold_reconnects_with_moh(self):
        a, b, ca, cb = self.direct_call()
        a.req("media.musicbedStart", {"file": bed_file(), "volume": 0.6})
        self.assertIsNotNone(self.heard(b, cb, 8))
        # hold without music: silence, and the bed is not listed
        mark = a.mark()
        a.req("call.hold", {"cid": ca})
        self.assertIsNotNone(a.wait_event("call.media", 10, mark, cid=ca, media="localHold"))
        self.assertIsNotNone(self.silent(b, cb, 10), "bed leaks through a hold")
        self.assertEqual(a.req("media.musicbedState")["calls"], [])
        mark = a.mark()
        a.req("call.unhold", {"cid": ca})
        self.assertIsNotNone(a.wait_event("call.media", 10, mark, cid=ca, media="active"))
        self.assertIsNotNone(self.heard(b, cb, 10), "bed does not come back after unhold")
        self.assertEqual(a.req("media.musicbedState")["calls"], [ca])
        # hold with music on hold: B hears the MOH tone, not the bed
        moh = make_tone_wav(os.path.join(TMP, "mb_moh.wav"), 1.0, 8000, MOH_HZ, 0.6)
        mark = a.mark()
        a.req("call.hold", {"cid": ca, "music": {"file": moh, "loop": True, "volume": 1.0}})
        self.assertIsNotNone(a.wait_event("call.media", 10, mark, cid=ca, media="localHold"))
        self.assertIsNotNone(self.heard(b, cb, 10), "no music on hold")
        time.sleep(0.5)
        x, rate = self.record_remote(b, cb, 1.0, "mb_moh_rec.wav")
        self.assertGreater(goertzel(x, rate, MOH_HZ), 1500)
        self.assertLess(goertzel(x, rate, BED_HZ), 150, "bed audible during the hold")
        a.req("call.unhold", {"cid": ca})
        self.assertIsNotNone(a.wait_event("call.playDone", 8, mark, cid=ca))
        time.sleep(0.5)
        x, rate = self.record_remote(b, cb, 1.0, "mb_unhold_rec.wav")
        self.assertGreater(goertzel(x, rate, BED_HZ), 800)
        self.assertLess(goertzel(x, rate, MOH_HZ), 150)

    def test_conference_both_receive(self):
        a = self.cli("A")
        b, c = self.cli("B"), self.cli("C")
        a.start_core()
        ports = []
        for x in (b, c):
            r = x.start_core()
            ports.append([t for t in r["transports"] if t["type"] == "udp"][0]["local"].split(":")[1])
        ca1, cb = self.call(a, b, ports[0])
        ca2, cc = self.call(a, c, ports[1])
        a.req("call.conference", {"cids": [ca1, ca2]})
        a.req("call.mute", {"cid": ca1, "mute": True})
        a.req("call.mute", {"cid": ca2, "mute": True})
        a.req("media.musicbedStart", {"file": bed_file(), "volume": 0.6})
        self.assertIsNotNone(self.heard(b, cb, 8), "B (conference member 1) does not hear the bed")
        self.assertIsNotNone(self.heard(c, cc, 8), "C (conference member 2) does not hear the bed")
        self.assertEqual(sorted(a.req("media.musicbedState")["calls"]), sorted([ca1, ca2]))

    def test_levels_and_per_call_levels(self):
        a, b, ca, cb = self.direct_call()
        lv = self.levels(a)
        self.assertEqual(set(lv), {"mic", "speaker", "musicbed", "calls"})
        self.assertEqual(lv["musicbed"], 0)
        self.assertEqual([c["cid"] for c in lv["calls"]], [ca])
        a.req("media.musicbedStart", {"file": bed_file(), "volume": 0.8})
        lv = self.poll(lambda: (lambda l: l if l["musicbed"] > 0 else None)(self.levels(a)), 8, 0.1)
        self.assertIsNotNone(lv, "musicbed level stays 0 while connected")
        for k in ("mic", "speaker", "musicbed"):
            self.assertTrue(0 <= lv[k] <= 255, lv)
        # per-call tx carries the bed
        lv = self.poll(lambda: (lambda l: l if l["calls"] and l["calls"][0]["tx"] > 0 else None)(self.levels(a)), 8, 0.1)
        self.assertIsNotNone(lv, "calls[].tx stays 0 while the bed plays to the call")
        self.assertEqual(lv["calls"][0]["cid"], ca)
        # volume scales the reported level; 0 gives 0
        loud = max(self.levels(a)["musicbed"] for _ in range(10))
        a.req("media.musicbedSet", {"volume": 0.1})
        time.sleep(0.3)
        quiet = max(self.levels(a)["musicbed"] for _ in range(10))
        self.assertLess(quiet, loud)
        a.req("media.musicbedSet", {"volume": 0.0})
        time.sleep(0.3)
        self.assertEqual(self.levels(a)["musicbed"], 0)
        a.req("media.musicbedSet", {"volume": 0.8})
        # rx from the far end shows up in calls[].rx
        b.req("call.playFile", {"cid": cb, "file": bed_file("mb_far.wav", seconds=10.0, freq=1100.0), "loop": True})
        lv = self.poll(lambda: (lambda l: l if l["calls"] and l["calls"][0]["rx"] > 0 else None)(self.levels(a)), 8, 0.1)
        self.assertIsNotNone(lv, "calls[].rx stays 0 with remote audio")
        a.req("media.musicbedStop")
        time.sleep(0.3)
        self.assertEqual(self.levels(a)["musicbed"], 0)

    def test_monitor_on_off(self):
        a = self.cli("A")
        a.start_core()
        a.req("media.musicbedStart", {"file": bed_file(seconds=2.0), "volume": 0.5})
        time.sleep(0.5)
        lv = self.levels(a)
        self.assertEqual((lv["musicbed"], lv["speaker"]), (0, 0), "no call and monitor off: nothing should pull the bed")
        a.req("media.musicbedSet", {"monitor": True, "monitorVolume": 0.8})
        self.assertTrue(a.req("media.musicbedState")["monitor"])
        lv = self.poll(lambda: (lambda l: l if l["musicbed"] > 0 and l["speaker"] > 0 else None)(self.levels(a)), 8, 0.1)
        self.assertIsNotNone(lv, "monitor on: the bed does not reach the speaker")
        pos = a.req("media.musicbedState")["positionMs"]
        time.sleep(0.4)
        self.assertNotEqual(pos, a.req("media.musicbedState")["positionMs"])
        a.req("media.musicbedSet", {"monitor": False})
        lv = self.poll(lambda: (lambda l: l if l["musicbed"] == 0 and l["speaker"] == 0 else None)(self.levels(a)), 8, 0.1)
        self.assertIsNotNone(lv, "monitor off: the bed is still routed to the speaker")
        # with a call: monitor is independent of the call volume
        b = self.cli("B")
        port = [t for t in b.start_core()["transports"] if t["type"] == "udp"][0]["local"].split(":")[1]
        ca, cb = self.call(a, b, port)
        a.req("media.musicbedSet", {"volume": 0.0, "monitor": True, "monitorVolume": 1.0})
        self.assertIsNotNone(self.silent(b, cb, 8), "volume 0 must silence the remote side")
        lv = self.poll(lambda: (lambda l: l if l["speaker"] > 0 and l["musicbed"] > 0 else None)(self.levels(a)), 8, 0.1)
        self.assertIsNotNone(lv, "monitor must not depend on the call volume")

    def test_recording_contains_bed(self):
        a, b, ca, cb = self.direct_call()
        a.req("media.musicbedStart", {"file": bed_file(), "volume": 0.6})
        self.assertIsNotNone(self.heard(b, cb, 8))
        # mono (mix both): the bed is mixed in
        path = os.path.join(TMP, "mb_rec_mono.wav")
        a.req("call.recordStart", {"cid": ca, "file": path})
        time.sleep(1.5)
        a.req("call.recordStop", {"cid": ca})
        ch, rate = read_wav(path)
        x = ch[0][len(ch[0]) // 4:]
        self.assertGreater(goertzel(x, rate, BED_HZ), 800, "mono recording lacks the bed")
        # stereo: the bed is on the local (left) channel, the remote channel is silent
        path = os.path.join(TMP, "mb_rec_st.wav")
        a.req("call.recordStart", {"cid": ca, "file": path, "format": "wavStereo"})
        time.sleep(1.5)
        a.req("call.recordStop", {"cid": ca})
        ch, rate = read_wav(path)
        self.assertEqual(len(ch), 2)
        l, r = [c[len(c) // 4:] for c in ch]
        self.assertGreater(goertzel(l, rate, BED_HZ), 800, "stereo recording lacks the bed on the local channel")
        self.assertLess(rms(r), 50)
        # recording survives a muted call
        a.req("call.mute", {"cid": ca, "mute": True})
        path = os.path.join(TMP, "mb_rec_muted.wav")
        a.req("call.recordStart", {"cid": ca, "file": path})
        time.sleep(1.2)
        a.req("call.recordStop", {"cid": ca})
        ch, rate = read_wav(path)
        self.assertGreater(goertzel(ch[0][len(ch[0]) // 4:], rate, BED_HZ), 800, "recording of a muted call lacks the bed")

    def test_bed_survives_replace_during_call(self):
        a, b, ca, cb = self.direct_call()
        a.req("media.musicbedStart", {"file": bed_file(), "volume": 0.6})
        self.assertIsNotNone(self.heard(b, cb, 8))
        a.req("media.musicbedStart", {"file": bed_file("mb_rep.wav", freq=700.0), "volume": 0.6})
        time.sleep(0.5)
        x, rate = self.record_remote(b, cb, 1.0, "mb_rep_rec.wav")
        self.assertGreater(goertzel(x, rate, 700.0), 800)
        self.assertLess(goertzel(x, rate, BED_HZ), 150)
        self.assertEqual(a.req("media.musicbedState")["calls"], [ca])

    def test_repeated_start_stop_with_calls(self):
        """lifetime stress (meaningful under ASan): start/replace/stop racing against a call and its hangup"""
        a, b, port = self.pair()
        f = bed_file(seconds=0.3)
        for i in range(12):
            ca, cb = self.call(a, b, port)
            for j in range(3):
                a.req("media.musicbedStart", {"file": f, "volume": 0.5, "monitor": bool(j % 2)})
            a.req("media.musicbedSet", {"paused": True})
            a.req("media.musicbedSet", {"paused": False, "volume": 1.0})
            if i % 2:
                a.req("media.musicbedStop")
            a.req("call.hangup", {"cid": ca})
            self.assertIsNotNone(b.wait_event("call.state", 10, 0, cid=cb, state="disconnected"))
        a.req("media.musicbedStop")
        a.req("core.ping")


class TestMusicbedIax2(BedBase):
    def test_iax2_call_receives_bed(self):
        from test_iax2 import iax_add
        a, b = self.cli("A"), self.cli("B")
        a.start_core(); b.start_core()
        _, ua, _ = iax_add(a, 2001)
        b.add_account(1001)
        cid_a, cid_b = self.call_between(a, b, ua, "1001")
        self.assertEqual(a.req("call.info", {"cid": cid_a})["proto"], "iax2")
        self.wait_media(a, cid_a)
        self.wait_media(b, cid_b)
        a.req("call.mute", {"cid": cid_a, "mute": True})
        a.req("media.musicbedStart", {"file": bed_file(), "volume": 0.8})
        self.assertIsNotNone(self.heard(b, cid_b, 12), "far end of the IAX2 call does not hear the bed")
        self.assertEqual(a.req("media.musicbedState")["calls"], [cid_a])
        a.req("media.musicbedStop")
        self.assertIsNotNone(self.silent(b, cid_b, 8))
