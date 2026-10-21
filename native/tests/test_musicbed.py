"""Musicbed (ENGINE_API.md 10): a looping file mixed into the microphone path of every call, independent of call.mute.

Calls are direct IP calls between spcore_cli processes (no PBX) except the IAX2 tests. B measures what arrives
(call.stats rxLevel, remote recordings); "bed" tones are 440 Hz, music on hold 900 Hz, far-end tones 1100 Hz, so they
can be told apart. The calls negotiate a speech codec (speex), which smears a pure tone into other bins (a 900 Hz
tone alone shows up to ~250 at 440 Hz), so "tone X is absent" after the codec is checked against X's own level when
present (absent()), not against a small absolute number.
"""
import os
import threading
import time

from run_tests import Base, RpcError, TMP, make_tone_wav
from test_media_files import MP3, read_wav, goertzel, rms, write_wav, sine

BED_HZ = 440.0
MOH_HZ = 900.0


FAR_HZ = 1100.0


def bed_file(name="bed.wav", seconds=0.6, rate=8000, freq=BED_HZ, amp=0.6):
    return make_tone_wav(os.path.join(TMP, name), seconds, rate, freq, amp)


def truncated_mp3(name="mb_truncated.mp3", frames=200):
    """An MP3 that passes validation but has no audio: a single MPEG-2 layer III frame (32 kbit/s, 22.05 kHz, mono,
    104 bytes) carrying only a Xing tag that claims `frames` frames. minimp3 takes the duration from the tag
    (media.fileInfo / musicbedStart succeed), the decoder then finds nothing to decode."""
    b = bytearray(104)
    b[0:4] = bytes([0xFF, 0xF3, 0x40, 0xC4])
    off = 4 + 9                                   # header + MPEG-2 mono side info (all zero)
    b[off:off + 4] = b"Xing"
    b[off + 4:off + 8] = (1).to_bytes(4, "big")   # flags: frame count only
    b[off + 8:off + 12] = frames.to_bytes(4, "big")
    path = os.path.join(TMP, name)
    with open(path, "wb") as fh:
        fh.write(bytes(b))
    return path


def udp_port(start_result):
    return [t for t in start_result["transports"] if t["type"] == "udp"][0]["local"].split(":")[1]


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

    def tone_profile(self, b, cid_b, name, freq=BED_HZ, seconds=1.0):
        """(amplitude over the window, [amplitude per 100 ms]) - the profile makes a failure message readable"""
        x, rate = self.record_remote(b, cid_b, seconds, name)
        n = rate // 10
        return goertzel(x, rate, freq), [int(goertzel(x[i:i + n], rate, freq)) for i in range(0, len(x) - n + 1, n)]

    def levels(self, c):
        return c.req("media.levels")

    def absent(self, amp, present, msg):
        """amp (a tone measured after the call's codec) is at most a tenth of that tone's level when present"""
        self.assertLess(amp, 0.1 * present, "%s (%.0f vs %.0f when present)" % (msg, amp, present))

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
        bed_ref = self.tone_amp(b, cb, "mb_hold_ref.wav")
        self.assertGreater(bed_ref, 800)
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
        moh_amp = goertzel(x, rate, MOH_HZ)
        self.assertGreater(moh_amp, 1500)
        self.absent(goertzel(x, rate, BED_HZ), bed_ref, "bed audible during the hold")
        a.req("call.unhold", {"cid": ca})
        self.assertIsNotNone(a.wait_event("call.playDone", 8, mark, cid=ca))
        time.sleep(0.5)
        x, rate = self.record_remote(b, cb, 1.0, "mb_unhold_rec.wav")
        self.assertGreater(goertzel(x, rate, BED_HZ), 800)
        self.absent(goertzel(x, rate, MOH_HZ), moh_amp, "music on hold still audible after unhold")

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
        self.assertEqual(set(lv), {"mic", "speaker", "musicbed", "send", "calls"})
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

    def rec(self, a, ca, name, seconds=1.2, **kw):
        path = os.path.join(TMP, name)
        a.req("call.recordStart", dict({"cid": ca, "file": path}, **kw))
        time.sleep(seconds)
        a.req("call.recordStop", {"cid": ca})
        ch, rate = read_wav(path)
        return [c[len(c) // 4:] for c in ch], rate

    def test_recording_contains_bed(self):
        a, b, ca, cb = self.direct_call()
        a.req("media.musicbedStart", {"file": bed_file(), "volume": 0.6})
        self.assertIsNotNone(self.heard(b, cb, 8))
        # the far end sends its own tone, so the bed on the local side can be told apart from the call's audio
        b.req("call.playFile", {"cid": cb, "file": bed_file("mb_far_rec.wav", seconds=10.0, freq=FAR_HZ), "loop": True})
        self.assertIsNotNone(self.heard(a, ca, 8))
        time.sleep(0.3)
        # mono, mix both: bed (local side) and far-end tone
        (x,), rate = self.rec(a, ca, "mb_rec_mono.wav")
        self.assertGreater(goertzel(x, rate, BED_HZ), 800, "mono recording lacks the bed")
        self.assertGreater(goertzel(x, rate, FAR_HZ), 800, "mono recording lacks the far end")
        # mix local: the bed, not the far end
        (x,), rate = self.rec(a, ca, "mb_rec_local.wav", mix="local")
        self.assertGreater(goertzel(x, rate, BED_HZ), 800, "mix local lacks the bed")
        self.assertLess(goertzel(x, rate, FAR_HZ), 150, "mix local contains the far end")
        local_bed = goertzel(x, rate, BED_HZ)
        # mix remote: the far end only; the bed is mixed in locally, it does not come back through the call
        (x,), rate = self.rec(a, ca, "mb_rec_remote.wav", mix="remote")
        self.assertGreater(goertzel(x, rate, FAR_HZ), 800, "mix remote lacks the far end")
        self.absent(goertzel(x, rate, BED_HZ), local_bed, "the bed is on the remote side of the recording")
        # stereo: the bed on the local (left) channel, the far end on the right
        ch, rate = self.rec(a, ca, "mb_rec_st.wav", format="wavStereo")
        self.assertEqual(len(ch), 2)
        l, r = ch
        self.assertGreater(goertzel(l, rate, BED_HZ), 800, "stereo recording lacks the bed on the local channel")
        self.assertLess(goertzel(l, rate, FAR_HZ), 150)
        self.assertGreater(goertzel(r, rate, FAR_HZ), 800)
        self.absent(goertzel(r, rate, BED_HZ), goertzel(l, rate, BED_HZ), "the bed leaked into the remote channel")
        b.req("call.stopFile", {"cid": cb})
        # recording survives a muted call
        a.req("call.mute", {"cid": ca, "mute": True})
        path = os.path.join(TMP, "mb_rec_muted.wav")
        a.req("call.recordStart", {"cid": ca, "file": path})
        time.sleep(1.2)
        a.req("call.recordStop", {"cid": ca})
        ch, rate = read_wav(path)
        self.assertGreater(goertzel(ch[0][len(ch[0]) // 4:], rate, BED_HZ), 800, "recording of a muted call lacks the bed")

    def speaker_on(self, a, on, timeout=8):
        return self.poll(lambda: (lambda l: l if (l["speaker"] > 0 and l["musicbed"] > 0) == on and
                                  (on or l["speaker"] == 0) else None)(self.levels(a)), timeout, 0.1)

    def test_bed_survives_replace_during_call(self):
        a, b, ca, cb = self.direct_call()
        a.req("media.musicbedStart", {"file": bed_file(), "volume": 0.6, "monitor": True, "monitorVolume": 0.8})
        self.assertIsNotNone(self.heard(b, cb, 8))
        self.assertIsNotNone(self.speaker_on(a, True), "monitor not on before the replace")
        a.req("media.musicbedStart", {"file": bed_file("mb_rep.wav", freq=700.0), "volume": 0.6, "monitor": True,
                                      "monitorVolume": 0.8})
        time.sleep(0.5)
        x, rate = self.record_remote(b, cb, 1.0, "mb_rep_rec.wav")
        self.assertGreater(goertzel(x, rate, 700.0), 800)
        self.absent(goertzel(x, rate, BED_HZ), goertzel(x, rate, 700.0), "the replaced bed is still audible")
        self.assertEqual(a.req("media.musicbedState")["calls"], [ca])
        # the old bed's port is gone, so a live speaker signal is the new bed on the monitor
        self.assertTrue(a.req("media.musicbedState")["monitor"])
        self.assertIsNotNone(self.speaker_on(a, True), "the monitor is not reconnected to the new bed")
        # replaced without the monitor: the speaker goes quiet, the call keeps the bed
        a.req("media.musicbedStart", {"file": bed_file("mb_rep2.wav", freq=700.0), "volume": 0.6})
        self.assertIsNotNone(self.speaker_on(a, False), "the monitor survived a replace with monitor:false")
        self.assertIsNotNone(self.heard(b, cb, 8))
        a.req("media.musicbedSet", {"monitor": True})
        self.assertIsNotNone(self.speaker_on(a, True), "monitor:true after the replace does not reconnect")

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
        st = a.req("media.musicbedState")
        self.assertEqual((st["active"], st["calls"]), (False, []))
        # one start/replace/stop cycle per transition: started/replaced/stopped counts match what was asked
        ev = [e["reason"] for e in self.bed_events(a)]
        self.assertEqual(ev.count("started"), 36)
        self.assertEqual(ev.count("replaced"), 36 - 6)         # every start but the very first and the 5 after a stop
        self.assertEqual(ev.count("stopped"), 6)               # the final musicbedStop found nothing to stop
        self.assertNotIn("error", ev)
        # and everything still works afterwards: a new call gets a new bed, and stop silences it
        ca, cb = self.call(a, b, port)
        self.assertIsNone(self.heard(b, cb, 1.0), "audio before any bed")
        a.req("media.musicbedStart", {"file": bed_file(), "volume": 0.6})
        self.assertIsNotNone(self.heard(b, cb, 8), "no bed after the stress")
        self.assertEqual(a.req("media.musicbedState")["calls"], [ca])
        x, rate = self.record_remote(b, cb, 1.0, "mb_after_stress.wav")
        self.assertGreater(goertzel(x, rate, BED_HZ), 800)
        a.req("media.musicbedStop")
        self.assertIsNotNone(self.silent(b, cb, 8), "bed still audible after the final stop")


    def test_decoder_error_mid_play(self):
        """a file that passes validation but cannot be decoded: exactly one reason:"error" per bed, after "started" """
        bad = truncated_mp3()
        fi = self.cli("probe").raw("media.fileInfo", {"file": bad})      # works before core.start
        self.assertTrue(fi["ok"], fi)
        self.assertEqual(fi["result"]["format"], "mp3")
        self.assertGreater(fi["result"]["durationMs"], 1000)
        a, b, ca, cb = self.direct_call()
        good = bed_file("mb_good.wav")
        a.req("media.musicbedStart", {"file": good, "volume": 0.6})
        self.assertIsNotNone(self.heard(b, cb, 8))
        # replacing a playing bed with the broken one, during a call
        mark = a.mark()
        r = a.req("media.musicbedStart", {"file": bad, "volume": 0.6})
        self.assertEqual(r["format"], "mp3")
        self.assertIsNotNone(a.wait_event("media.musicbed", 8, mark, reason="error"), "no decoder error event")
        time.sleep(0.5)
        ev = self.bed_events(a, mark)
        self.assertEqual([(e["active"], e["reason"], e["file"]) for e in ev],
                         [(False, "replaced", good), (True, "started", bad), (False, "error", bad)])
        self.assertTrue(ev[-1].get("message"))
        st = a.req("media.musicbedState")
        self.assertEqual((st["active"], st["calls"]), (False, []))
        self.assertEqual(a.raw("media.musicbedSet", {"volume": 0.5})["error"]["code"], "NOT_FOUND")
        self.assertIsNotNone(self.silent(b, cb, 8), "something still plays after the error")
        # without any call: the monitor pulls it, same single error
        a.req("call.hangup", {"cid": ca})
        self.assertIsNotNone(b.wait_event("call.state", 10, 0, cid=cb, state="disconnected"))
        mark = a.mark()
        a.req("media.musicbedStart", {"file": bad, "monitor": True})
        self.assertIsNotNone(a.wait_event("media.musicbed", 8, mark, reason="error"))
        time.sleep(0.5)
        self.assertEqual([(e["active"], e["reason"]) for e in self.bed_events(a, mark)], [(True, "started"), (False, "error")])
        self.assertFalse(a.req("media.musicbedState")["active"])
        # a good file afterwards is fine
        mark = a.mark()
        a.req("media.musicbedStart", {"file": good})
        time.sleep(0.5)
        self.assertTrue(a.req("media.musicbedState")["active"])
        self.assertEqual([e["reason"] for e in self.bed_events(a, mark)], ["started"])

    def test_volume_set_before_call_applies_to_new_call(self):
        a, b, port = self.pair()
        a.req("media.musicbedStart", {"file": bed_file(), "volume": 0.2})
        a.req("media.musicbedSet", {"volume": 1.0})        # no call yet: the next call must still get 1.0
        ca, cb = self.call(a, b, port)
        self.assertIsNotNone(self.heard(b, cb, 8))
        time.sleep(0.3)
        hi = self.tone_amp(b, cb, "mb_pre_hi.wav")
        a.req("media.musicbedSet", {"volume": 0.25})
        time.sleep(0.4)
        lo = self.tone_amp(b, cb, "mb_pre_lo.wav")
        # 0.6 * 1.0 * 32767 ~ 19700 nominal; at the stale 0.2 it would be ~3900, i.e. below the 0.25 measurement
        self.assertGreater(hi, 8000, "the new call did not get the volume set before it")
        self.assertTrue(2.8 < hi / lo < 5.5, "the new call does not follow the volume (%s at 1.0 vs %s at 0.25)" % (hi, lo))
        a.req("media.musicbedSet", {"volume": 0.5})
        time.sleep(0.4)
        mid = self.tone_amp(b, cb, "mb_pre_mid.wav")
        self.assertTrue(1.5 < mid / lo < 2.6, "volume 0.5 vs 0.25: %s vs %s" % (mid, lo))

    def test_conference_member_on_hold(self):
        a = self.cli("A")
        b, c = self.cli("B"), self.cli("C")
        a.start_core()
        ports = [udp_port(x.start_core()) for x in (b, c)]
        ca1, cb = self.call(a, b, ports[0])
        ca2, cc = self.call(a, c, ports[1])
        a.req("call.conference", {"cids": [ca1, ca2]})
        a.req("media.musicbedStart", {"file": bed_file(), "volume": 0.6})
        self.assertIsNotNone(self.heard(b, cb, 8))
        self.assertIsNotNone(self.heard(c, cc, 8))
        # hold member B: B's far end gets nothing (no bed), C keeps the bed
        mark = a.mark()
        a.req("call.hold", {"cid": ca1})
        self.assertIsNotNone(a.wait_event("call.media", 10, mark, cid=ca1, media="localHold"))
        self.assertIsNotNone(self.silent(b, cb, 10), "a held conference member still receives the bed")
        x, rate = self.record_remote(c, cc, 1.0, "mb_confhold_c.wav")
        c_bed = goertzel(x, rate, BED_HZ)
        self.assertGreater(c_bed, 800, "the other member lost the bed")
        self.assertEqual(a.req("media.musicbedState")["calls"], [ca2])
        # unhold: back in the conference with the bed
        mark = a.mark()
        a.req("call.unhold", {"cid": ca1})
        self.assertIsNotNone(a.wait_event("call.media", 10, mark, cid=ca1, media="active"))
        self.assertIsNotNone(self.heard(b, cb, 10), "no bed after unhold")
        x, rate = self.record_remote(b, cb, 1.0, "mb_confunhold_b.wav")
        self.assertGreater(goertzel(x, rate, BED_HZ), 800)
        self.assertEqual(sorted(a.req("media.musicbedState")["calls"]), sorted([ca1, ca2]))
        # hold member C with music on hold: C hears the MOH, not the bed; B keeps the bed
        moh = make_tone_wav(os.path.join(TMP, "mb_conf_moh.wav"), 1.0, 8000, MOH_HZ, 0.6)
        mark = a.mark()
        a.req("call.hold", {"cid": ca2, "music": {"file": moh, "loop": True, "volume": 1.0}})
        self.assertIsNotNone(a.wait_event("call.media", 10, mark, cid=ca2, media="localHold"))
        time.sleep(0.8)
        x, rate = self.record_remote(c, cc, 1.0, "mb_confmoh_c.wav")
        c_moh = goertzel(x, rate, MOH_HZ)
        self.assertGreater(c_moh, 1500, "no music on hold for the held member")
        self.absent(goertzel(x, rate, BED_HZ), c_bed, "the bed reaches a held conference member")
        x, rate = self.record_remote(b, cb, 1.0, "mb_confmoh_b.wav")
        self.assertGreater(goertzel(x, rate, BED_HZ), 800)
        self.absent(goertzel(x, rate, MOH_HZ), c_moh, "music on hold leaks to the other member")
        self.assertEqual(a.req("media.musicbedState")["calls"], [ca1])

    def test_record_stop_then_start_with_bed(self):
        """recordStop does not run a topology pass; a new recording (whose sink may reuse the old slot) gets the bed"""
        a, b, ca, cb = self.direct_call()
        a.req("media.musicbedStart", {"file": bed_file(), "volume": 0.6})
        self.assertIsNotNone(self.heard(b, cb, 8))
        amps = []
        for i, fmt in enumerate(("wav", "wav", "wavStereo", "wav", "wavStereo", "wav")):
            (ch, rate) = self.rec(a, ca, "mb_rr_%d.wav" % i, seconds=1.0, format=fmt)
            amps.append(goertzel(ch[0], rate, BED_HZ))
        self.assertTrue(all(v > 800 for v in amps), "a recording after recordStop lacks the bed: %s" % amps)
        # the recorder sink follows a volume change made while nothing records
        a.req("media.musicbedSet", {"volume": 0.15})
        (ch, rate) = self.rec(a, ca, "mb_rr_low.wav", seconds=1.0)
        low = goertzel(ch[0], rate, BED_HZ)
        self.assertTrue(2.5 < amps[-1] / max(low, 1.0) < 6.5, "recording level does not follow the volume: %s vs %s" % (amps[-1], low))
        # recording while the call is held: the bed is not sent, so it is not recorded either
        mark = a.mark()
        a.req("call.hold", {"cid": ca})
        self.assertIsNotNone(a.wait_event("call.media", 10, mark, cid=ca, media="localHold"))
        (ch, rate) = self.rec(a, ca, "mb_rr_held.wav", seconds=1.0)
        self.assertLess(goertzel(ch[0], rate, BED_HZ), 100, "the bed is recorded while the call is held")


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


class TestMusicbedStress(BedBase):
    def test_concurrent_topology_passes(self):
        """Topology passes on several threads at once while calls B (direct SIP, and IAX2 through the PBX) come and go.

        A hammer thread drives A's worker (musicbedSet volume/monitor, call.mute on the long-lived call, and short
        muteMic announcements, whose end runs a pass on the pjsua thread); B's media start runs passes on the pjsua or
        IAX2 thread. In test builds every pass is also slowed down (__topoDelay), so unserialised passes would
        interleave almost every time; the hammer is paced so that the bridge's operation queue keeps up.
        Checked for every B: musicbedState.calls stays exactly {A, B} while the passes race, B follows the final
        volume, and holding B (while passes still race) takes the bed off B for good. Meaningful under ASan as well
        (plays and passes created and destroyed concurrently)."""
        from test_iax2 import iax_add
        a, x, y = self.cli("A"), self.cli("X"), self.cli("Y")
        a.start_core()
        px, py = udp_port(x.start_core()), udp_port(y.start_core())
        _, ua_iax, _ = iax_add(a, 2001)
        y.add_account(1001)
        ca, cx = self.call(a, x, px)
        a.req("media.musicbedStart", {"file": bed_file("mb_stress.wav", seconds=2.0), "volume": 0.3})
        self.assertIsNotNone(self.heard(x, cx, 8))
        a.raw("__topoDelay", {"ms": 2})          # UNSUPPORTED (ignored) in builds without SPC_TEST_HOOKS
        blip = bed_file("mb_blip.wav", seconds=0.04, freq=1300.0)
        lock = threading.Lock()
        errors = []

        def rq(m, p=None):
            with lock:
                return a.req(m, p)

        def hammer(stop):
            i = 0
            try:
                while not stop.is_set():
                    i += 1
                    p = {"volume": 0.1 + 0.05 * (i % 7)}
                    if i % 5 == 0:
                        p["monitor"] = i % 10 == 0
                    rq("media.musicbedSet", p)
                    if i % 2 == 0:
                        rq("call.mute", {"cid": ca, "mute": i % 4 == 0})
                    if i % 6 == 0:
                        with lock:
                            r = a.raw("call.playFile", {"cid": ca, "file": blip, "muteMic": True})
                        if not r["ok"] and "too many" not in r["error"].get("message", ""):
                            raise RpcError("call.playFile", r["error"])
                    # paced: the bridge applies at most 100 queued operations per 20 ms tick; flooding it would only
                    # delay every connection change by seconds (no real client comes anywhere near this rate)
                    time.sleep(0.004)
            except Exception as e:          # surfaced by the main thread
                errors.append(e)

        class Hammer:
            def __enter__(hs):
                hs.stop = threading.Event()
                hs.th = threading.Thread(target=hammer, args=(hs.stop,), daemon=True)
                hs.th.start()
                return hs

            def __exit__(hs, *exc):
                hs.stop.set()
                hs.th.join(20)
                self.assertFalse(hs.th.is_alive(), "hammer thread stuck")
                self.assertEqual(errors, [])

        for it in range(6):
            iax = it % 3 == 2
            kind = "iax2" if iax else "sip"
            my = y.mark()
            with Hammer():
                if iax:
                    cb = rq("call.make", {"uid": ua_iax, "uri": "1001"})["cid"]
                else:
                    cb = rq("call.make", {"acc": -1, "uri": "sip:127.0.0.1:%s" % py})["cid"]
                inc = y.wait_event("call.incoming", 15, my)
                self.assertIsNotNone(inc, "Y got no call (iteration %d)" % it)
                cy = inc["cid"]
                y.req("call.answer", {"cid": cy})
                self.assertIsNotNone(y.wait_event("call.state", 15, my, cid=cy, state="confirmed"),
                                     "iteration %d (%s): not confirmed; A: %s Y: %s" % (
                                         it, kind, [(e["cid"], e["state"], e.get("lastCode")) for e in a.events("call.state", cid=cb)],
                                         [(e["cid"], e["state"], e.get("lastCode")) for e in y.events("call.state", cid=cy)]))
                self.wait_media(a, cb, timeout=15)
                self.wait_media(y, cy, timeout=15)
                listed = self.poll(lambda: cb in rq("media.musicbedState")["calls"], 5, 0.05)
                self.assertTrue(listed, "iteration %d (%s): B never listed in musicbedState.calls" % (it, kind))
                time.sleep(0.8)              # past any codec-locking re-INVITE; passes keep racing meanwhile
                for k in range(25):
                    calls = rq("media.musicbedState")["calls"]
                    self.assertEqual(sorted(calls), sorted([ca, cb]),
                                     "iteration %d (%s), sample %d: musicbedState.calls lost track" % (it, kind, k))
            # B follows the final volume; volume only, so no topology pass helps it
            a.req("media.musicbedSet", {"volume": 1.0})
            time.sleep(0.3)
            hi, hip = self.tone_profile(y, cy, "mb_st_hi_%d.wav" % it)
            a.req("media.musicbedSet", {"volume": 0.25})
            time.sleep(0.4)
            lo, lop = self.tone_profile(y, cy, "mb_st_lo_%d.wav" % it)
            self.assertGreater(hi, 2000, "iteration %d (%s): B does not get the bed at the final volume (%s)" % (it, kind, hip))
            self.assertTrue(2.5 < hi / max(lo, 1.0) < 6.5, "iteration %d (%s): B does not follow the volume (%.0f %s vs %.0f %s)"
                            % (it, kind, hi, hip, lo, lop))
            # hold B while passes race: the bed leaves B and stays off (SIP: B's far end goes silent; the PBX plays
            # its own music on hold to an IAX2 hold, so there only the call list is checked)
            ma = a.mark()
            with Hammer():
                rq("call.hold", {"cid": cb})
                if not iax:
                    self.assertIsNotNone(a.wait_event("call.media", 10, ma, cid=cb, media="localHold"))
                time.sleep(0.5)
            if not iax:
                self.assertIsNotNone(self.silent(y, cy, 10), "iteration %d: held B still receives the bed" % it)
            self.assertEqual(a.req("media.musicbedState")["calls"], [ca], "iteration %d (%s): held B still listed" % (it, kind))
            if it % 2:
                a.req("call.hangup", {"cid": cb})
            else:
                y.req("call.hangup", {"cid": cy})
            self.assertIsNotNone(a.wait_event("call.state", 15, ma, cid=cb, state="disconnected"))
            self.assertIsNotNone(y.wait_event("call.state", 15, my, cid=cy, state="disconnected"))
            a.req("media.musicbedSet", {"volume": 0.3})
        a.raw("__topoDelay", {"ms": 0})
        # the long-lived call still has the bed and follows the volume; only it is listed
        a.req("call.stopFile", {"cid": ca})
        a.req("call.mute", {"cid": ca, "mute": False})
        self.assertEqual(a.req("media.musicbedState")["calls"], [ca])
        self.assertIsNotNone(self.heard(x, cx, 8))
        x1 = self.tone_amp(x, cx, "mb_st_x1.wav")
        a.req("media.musicbedSet", {"volume": 1.2})
        time.sleep(0.4)
        x2 = self.tone_amp(x, cx, "mb_st_x2.wav")
        self.assertTrue(2.8 < x2 / max(x1, 1.0) < 5.5, "call A does not follow the volume after the stress (%s vs %s)" % (x1, x2))
