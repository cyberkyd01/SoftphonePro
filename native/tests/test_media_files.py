"""Media files, music on hold, mic recorder and recording formats (ENGINE_API.md 9.2 - 9.4).

Run via run_tests.py (auto-loaded). Calls are direct IP calls between two spcore_cli processes (no PBX), so the
audio path is exactly the engine: A plays/holds, B measures what arrives (call.stats rxLevel, remote recordings).
Test data: native/tests/data/tone440_22k_mono.mp3 is a 3 s 440 Hz sine, mono 22.05 kHz 32 kbps, generated once with
`ffmpeg -f lavfi -i sine=frequency=440:duration=3:sample_rate=22050 -ac 1 -codec:a libmp3lame -b:a 32k
 -id3v2_version 0 -write_xing 0` (no tags).
"""
import math
import os
import shutil
import struct
import subprocess
import time
import unittest
import wave

from run_tests import Base, RpcError, TMP, make_tone_wav

HERE = os.path.dirname(os.path.abspath(__file__))
MP3 = os.path.join(HERE, "data", "tone440_22k_mono.mp3")


# ---------------------------------------------------------------- audio helpers
def _ulaw(s):
    BIAS, CLIP = 0x84, 32635
    sign = 0x80 if s < 0 else 0
    s = min(abs(s), CLIP) + BIAS
    exp = 7
    mask = 0x4000
    while exp > 0 and not (s & mask):
        exp -= 1
        mask >>= 1
    return (~(sign | (exp << 4) | ((s >> (exp + 3)) & 0x0F))) & 0xFF


def _alaw(s):
    sign = 0x00 if s < 0 else 0x80
    s = abs(s)
    s = min(s, 32635)
    if s >= 256:
        exp = 7
        mask = 0x4000
        while exp > 1 and not (s & mask):
            exp -= 1
            mask >>= 1
        mant = (s >> (exp + 3)) & 0x0F
        v = (exp << 4) | mant
    else:
        v = s >> 4
    return (v | sign) ^ 0x55


def write_wav(path, samples_by_ch, rate, tag=1):
    """samples_by_ch: list of per-channel int16 lists. tag 1 = PCM16, 6 = A-law, 7 = mu-law (8 bit)"""
    nch = len(samples_by_ch)
    n = len(samples_by_ch[0])
    if tag == 1:
        data = b"".join(struct.pack("<%dh" % nch, *[c[i] for c in samples_by_ch]) for i in range(n))
        bits = 16
    else:
        fn = _ulaw if tag == 7 else _alaw
        data = bytes(fn(c[i]) for i in range(n) for c in samples_by_ch)
        bits = 8
    fmt = struct.pack("<HHIIHH", tag, nch, rate, rate * nch * bits // 8, nch * bits // 8, bits)
    if tag != 1:
        fmt += struct.pack("<H", 0)
    with open(path, "wb") as f:
        f.write(b"RIFF" + struct.pack("<I", 4 + 8 + len(fmt) + 8 + len(data)) + b"WAVE")
        f.write(b"fmt " + struct.pack("<I", len(fmt)) + fmt)
        f.write(b"data" + struct.pack("<I", len(data)) + data)
    return path


def sine(rate, seconds, freq=440.0, amp=0.5):
    return [int(amp * 32767 * math.sin(2 * math.pi * freq * i / rate)) for i in range(int(rate * seconds))]


def read_wav(path):
    with wave.open(path, "rb") as w:
        n, ch, rate = w.getnframes(), w.getnchannels(), w.getframerate()
        raw = w.readframes(n)
    s = struct.unpack("<%dh" % (len(raw) // 2), raw)
    return [list(s[c::ch]) for c in range(ch)], rate


def rms(x):
    return math.sqrt(sum(v * v for v in x) / len(x)) if x else 0.0


def goertzel(x, rate, f):
    """amplitude estimate of frequency f"""
    if not x:
        return 0.0
    w = 2 * math.pi * f / rate
    c = 2 * math.cos(w)
    s1 = s2 = 0.0
    for v in x:
        s = v + c * s1 - s2
        s2, s1 = s1, s
    p = s1 * s1 + s2 * s2 - c * s1 * s2
    return 2 * math.sqrt(max(p, 0)) / len(x)


OGG_CRC = []
for _i in range(256):
    _r = _i << 24
    for _ in range(8):
        _r = ((_r << 1) ^ 0x04C11DB7) & 0xFFFFFFFF if _r & 0x80000000 else (_r << 1) & 0xFFFFFFFF
    OGG_CRC.append(_r)


def ogg_crc(data):
    crc = 0
    for b in data:
        crc = ((crc << 8) & 0xFFFFFFFF) ^ OGG_CRC[((crc >> 24) & 0xFF) ^ b]
    return crc


def parse_ogg_opus(path):
    """strict structural validation; returns dict(channels, pre_skip, rate, granule, packets, pages)"""
    with open(path, "rb") as fh:
        d = fh.read()
    pos = 0
    pages = []
    seq_expect = 0
    serial = None
    packets = []
    cur = b""
    while pos < len(d):
        assert d[pos:pos + 4] == b"OggS", "no capture pattern at %d" % pos
        assert d[pos + 4] == 0, "bad stream structure version"
        htype = d[pos + 5]
        gp = struct.unpack("<q", d[pos + 6:pos + 14])[0]
        ser, seq, crc = struct.unpack("<III", d[pos + 14:pos + 26])
        nseg = d[pos + 26]
        lace = list(d[pos + 27:pos + 27 + nseg])
        hl = 27 + nseg
        dl = sum(lace)
        page = bytearray(d[pos:pos + hl + dl])
        assert len(page) == hl + dl, "truncated page"
        page[22:26] = b"\0\0\0\0"
        assert ogg_crc(bytes(page)) == crc, "bad CRC on page %d" % seq
        if serial is None:
            serial = ser
        assert ser == serial, "serial changed"
        assert seq == seq_expect, "page sequence %d != %d" % (seq, seq_expect)
        seq_expect += 1
        body = d[pos + hl:pos + hl + dl]
        off = 0
        for l in lace:
            cur += body[off:off + l]
            off += l
            if l < 255:
                packets.append((cur, gp))
                cur = b""
        pages.append((htype, gp, len(lace)))
        pos += hl + dl
    assert cur == b"", "unterminated packet"
    assert pages[0][0] & 0x02, "first page must be BOS"
    assert all(not (p[0] & 0x02) for p in pages[1:]), "BOS only on the first page"
    assert pages[-1][0] & 0x04, "last page must be EOS"
    assert all(not (p[0] & 0x04) for p in pages[:-1]), "EOS only on the last page"
    head = packets[0][0]
    assert head[:8] == b"OpusHead" and len(head) == 19, head
    ver, ch, pre_skip, rate, gain, mapping = struct.unpack("<BBHIhB", head[8:19])
    assert ver == 1 and ch == 1 and mapping == 0 and gain == 0, head
    assert pages[0][2] == 1 and pages[0][1] == 0, "OpusHead alone on first page, granule 0"
    assert packets[1][0][:8] == b"OpusTags"
    vl = struct.unpack("<I", packets[1][0][8:12])[0]
    assert struct.unpack("<I", packets[1][0][12 + vl:16 + vl])[0] == 0
    audio = packets[2:]
    last_gp = -1
    for pg in pages[2:]:
        assert pg[1] > last_gp or pg[1] == last_gp, "granule must not decrease"
        last_gp = pg[1]
    assert last_gp > pre_skip
    return {"channels": ch, "pre_skip": pre_skip, "rate": rate, "granule": last_gp, "npackets": len(audio), "pages": len(pages),
            "ms": (last_gp - pre_skip) * 1000.0 / 48000}


# ---------------------------------------------------------------- tests
class MediaBase(Base):
    def direct_call(self, **kw):
        """A (caller) -> B over direct IP; returns (a, b, cid_a, cid_b) with media active on both"""
        a, b = self.cli("A"), self.cli("B")
        a.start_core(**kw)
        rb = b.start_core(**kw)
        port = [t for t in rb["transports"] if t["type"] == "udp"][0]["local"].split(":")[1]
        mb = b.mark()
        cid_a = a.req("call.make", {"acc": -1, "uri": "sip:127.0.0.1:%s" % port})["cid"]
        inc = b.wait_event("call.incoming", 15, mb)
        self.assertIsNotNone(inc, "B got no call")
        cid_b = inc["cid"]
        b.req("call.answer", {"cid": cid_b})
        self.assertIsNotNone(a.wait_event("call.state", 15, 0, cid=cid_a, state="confirmed"))
        self.assertIsNotNone(b.wait_event("call.state", 15, mb, cid=cid_b, state="confirmed"))
        self.wait_media(a, cid_a)
        self.wait_media(b, cid_b)
        return a, b, cid_a, cid_b

    def heard(self, b, cid_b, timeout=10, level=5):
        st = self.poll(lambda: (lambda s: s if s["rxLevel"] > level else None)(b.req("call.stats", {"cid": cid_b})), timeout, 0.1)
        return st

    def silent(self, b, cid_b, timeout=10):
        def f():
            s = b.req("call.stats", {"cid": cid_b})
            return s if s["rxLevel"] == 0 else None
        return self.poll(f, timeout, 0.1)

    def record_remote(self, b, cid_b, seconds, name, **kw):
        path = os.path.join(TMP, name)
        b.req("call.recordStart", dict({"cid": cid_b, "file": path, "mix": "remote"}, **kw))
        time.sleep(seconds)
        r = b.req("call.recordStop", {"cid": cid_b})
        return path, r


class TestFileInfo(Base):
    def test_file_info_formats_and_errors(self):
        c = self.cli()
        # works before core.start (pure file probe)
        ul = write_wav(os.path.join(TMP, "i_ulaw.wav"), [sine(8000, 1.5)], 8000, tag=7)
        al = write_wav(os.path.join(TMP, "i_alaw.wav"), [sine(8000, 1.0)], 8000, tag=6)
        st = write_wav(os.path.join(TMP, "i_st.wav"), [sine(44100, 2.0), sine(44100, 2.0, 880)], 44100)
        r = c.req("media.fileInfo", {"file": ul})
        self.assertEqual((r["format"], r["sampleRate"], r["channels"]), ("wav", 8000, 1))
        self.assertAlmostEqual(r["durationMs"], 1500, delta=5)
        self.assertEqual(c.req("media.fileInfo", {"file": al})["durationMs"], 1000)
        r = c.req("media.fileInfo", {"file": st})
        self.assertEqual((r["format"], r["sampleRate"], r["channels"], r["durationMs"]), ("wav", 44100, 2, 2000))
        r = c.req("media.fileInfo", {"file": MP3})
        self.assertEqual((r["format"], r["sampleRate"], r["channels"]), ("mp3", 22050, 1))
        self.assertAlmostEqual(r["durationMs"], 3000, delta=100)
        garbage = os.path.join(TMP, "garbage.wav")
        with open(garbage, "wb") as f:
            f.write(b"this is definitely not audio " * 100)
        trunc = os.path.join(TMP, "trunc.wav")
        with open(trunc, "wb") as f:
            f.write(b"RIFF\x00\x00\x00\x00WAVEfmt ")
        for p in ({}, {"file": ""}, {"file": os.path.join(TMP, "nope.wav")}, {"file": garbage}, {"file": trunc}, {"file": TMP}):
            r = c.raw("media.fileInfo", p)
            self.assertFalse(r["ok"], p)
            self.assertEqual(r["error"]["code"], "INVALID_PARAM", (p, r))


class TestPlayback(MediaBase):
    def test_play_formats_playdone_and_signal(self):
        a, b, ca, cb = self.direct_call()
        files = {
            "mulaw8k": write_wav(os.path.join(TMP, "p_ulaw.wav"), [sine(8000, 1.5)], 8000, tag=7),
            "alaw8k": write_wav(os.path.join(TMP, "p_alaw.wav"), [sine(8000, 1.5)], 8000, tag=6),
            "stereo44k": write_wav(os.path.join(TMP, "p_st44.wav"), [sine(44100, 1.5), sine(44100, 1.5)], 44100),
            "pcm48k": write_wav(os.path.join(TMP, "p_48.wav"), [sine(48000, 1.5)], 48000),
            "mp3": MP3,
        }
        for name, f in sorted(files.items()):
            mark = a.mark()
            pid = a.req("call.playFile", {"cid": ca, "file": f})["playId"]
            self.assertGreater(pid, 0, name)
            self.assertIsNotNone(self.heard(b, cb, 8), "B did not hear %s" % name)
            ev = a.wait_event("call.playDone", 12, mark, cid=ca, playId=pid)
            self.assertIsNotNone(ev, "no playDone for %s" % name)
            self.assertEqual(ev["reason"], "eof", name)
            self.assertEqual(ev["file"], f)
            self.assertIsNotNone(self.silent(b, cb, 6), "B still hears audio after %s ended" % name)

    def test_resampling_keeps_the_tone(self):
        """44.1 kHz stereo PCM and a 22.05 kHz MP3 arrive at B as a clean 440 Hz tone"""
        a, b, ca, cb = self.direct_call()
        st = write_wav(os.path.join(TMP, "r_st44.wav"), [sine(44100, 4.0, 440, 0.6), sine(44100, 4.0, 440, 0.6)], 44100)
        for name, f, expect_dur in (("st44", st, 3.0), ("mp3", MP3, 2.0)):
            pid = a.req("call.playFile", {"cid": ca, "file": f})["playId"]
            self.assertIsNotNone(self.heard(b, cb, 8))
            path, r = self.record_remote(b, cb, 1.2, "rs_%s.wav" % name)
            ch, rate = read_wav(path)
            x = ch[0][len(ch[0]) // 5:]       # skip the start
            tone = goertzel(x, rate, 440)
            other = max(goertzel(x, rate, f2) for f2 in (300, 600, 1000, 1700))
            self.assertGreater(tone, 2500, "%s: tone too weak (%s)" % (name, tone))
            self.assertGreater(tone, 8 * other, "%s: spectrum not clean (440=%s other=%s)" % (name, tone, other))
            a.req("call.stopFile", {"cid": ca, "playId": pid})

    def test_loop_multiple_plays_stop_and_hangup(self):
        a, b, ca, cb = self.direct_call()
        f = os.path.join(TMP, "m_tone.wav")
        make_tone_wav(f, 0.5, 8000, 330.0)
        mark = a.mark()
        p1 = a.req("call.playFile", {"cid": ca, "file": f, "loop": True})["playId"]
        p2 = a.req("call.playFile", {"cid": ca, "file": f, "loop": True, "volume": 0.5})["playId"]
        p3 = a.req("call.playFile", {"cid": ca, "file": f})["playId"]
        self.assertEqual(len({p1, p2, p3}), 3)
        self.assertIsNotNone(self.heard(b, cb))
        # non-looping one ends by itself even though the others keep going
        self.assertEqual(a.wait_event("call.playDone", 8, mark, playId=p3)["reason"], "eof")
        time.sleep(0.6)
        self.assertEqual(a.events("call.playDone", playId=p1), [])
        # stop by id
        r = a.req("call.stopFile", {"cid": ca, "playId": p2})
        self.assertEqual(r["stopped"], 1)
        self.assertEqual(a.wait_event("call.playDone", 5, mark, playId=p2)["reason"], "stopped")
        self.assertEqual(a.events("call.playDone", playId=p1), [])
        self.assertEqual(a.req("call.stopFile", {"cid": ca, "playId": p2})["stopped"], 0)     # idempotent
        self.assertIsNotNone(self.heard(b, cb))
        # looping one is still audible; play another and leave both for the hangup
        p4 = a.req("call.playFile", {"cid": ca, "file": f, "loop": True})["playId"]
        mark2 = a.mark()
        a.req("call.hangup", {"cid": ca})
        for pid in (p1, p4):
            ev = a.wait_event("call.playDone", 8, mark2, playId=pid)
            self.assertIsNotNone(ev, "no playDone(hangup) for %s" % pid)
            self.assertEqual(ev["reason"], "hangup")
        done = [m for m in a.events("call.playDone", playId=p1)]
        disc = a.wait_event("call.state", 10, 0, cid=ca, state="disconnected")
        self.assertIsNotNone(disc)
        self.assertLess(a.log.index(done[0]), a.log.index(disc), "playDone must precede the terminal call.state")

    def test_stop_all_without_id_and_validation(self):
        a, b, ca, cb = self.direct_call()
        f = os.path.join(TMP, "v_tone.wav")
        make_tone_wav(f, 1.0, 8000, 500.0)
        mark = a.mark()
        ids = [a.req("call.playFile", {"cid": ca, "file": f, "loop": True})["playId"] for _ in range(3)]
        self.assertEqual(a.req("call.stopFile", {"cid": ca})["stopped"], 3)
        for pid in ids:
            self.assertEqual(a.wait_event("call.playDone", 5, mark, playId=pid)["reason"], "stopped")
        self.assertIsNotNone(self.silent(b, cb, 8))
        for params in ({"file": f, "volume": -1}, {"file": f, "volume": 9}, {"file": f, "loop": "yes"},
                       {"file": os.path.join(TMP, "missing.wav")}, {"file": ""}, {}):
            r = a.raw("call.playFile", dict({"cid": ca}, **params))
            self.assertFalse(r["ok"], params)
            self.assertEqual(r["error"]["code"], "INVALID_PARAM", (params, r))
        r = a.raw("call.playFile", {"cid": 987654, "file": f})
        self.assertEqual(r["error"]["code"], "NOT_FOUND")
        r = a.raw("call.stopFile", {"cid": ca, "playId": "x"})
        self.assertEqual(r["error"]["code"], "INVALID_PARAM")

    def test_mute_mic_is_separate_from_user_mute(self):
        a, b, ca, cb = self.direct_call()
        f = os.path.join(TMP, "mm_tone.wav")
        make_tone_wav(f, 30.0, 8000, 400.0)
        info = lambda: a.req("call.info", {"cid": ca})
        self.assertFalse(info()["announcementMuted"])
        # 1. user not muted: announcement mute is set while the file plays and cleared afterwards
        p = a.req("call.playFile", {"cid": ca, "file": f, "muteMic": True})["playId"]
        i = info()
        self.assertTrue(i["announcementMuted"])
        self.assertFalse(i["muted"])
        a.req("call.stopFile", {"cid": ca, "playId": p})
        a.wait_event("call.playDone", 5, 0, playId=p)
        self.assertFalse(info()["announcementMuted"])
        self.assertFalse(info()["muted"])
        # 2. user muted before: stays muted after the announcement
        a.req("call.mute", {"cid": ca, "mute": True})
        p = a.req("call.playFile", {"cid": ca, "file": f, "muteMic": True})["playId"]
        i = info()
        self.assertTrue(i["announcementMuted"] and i["muted"])
        a.req("call.stopFile", {"cid": ca})
        a.wait_event("call.playDone", 5, 0, playId=p)
        i = info()
        self.assertFalse(i["announcementMuted"])
        self.assertTrue(i["muted"], "announcement end must not unmute the user")
        # 3. user unmutes during the announcement: announcement mute stays until the file is done
        p = a.req("call.playFile", {"cid": ca, "file": f, "muteMic": True})["playId"]
        a.req("call.mute", {"cid": ca, "mute": False})
        i = info()
        self.assertTrue(i["announcementMuted"])
        self.assertFalse(i["muted"])
        # 4. two overlapping muteMic plays: mute lasts until the last one is done
        p2 = a.req("call.playFile", {"cid": ca, "file": f, "muteMic": True})["playId"]
        a.req("call.stopFile", {"cid": ca, "playId": p})
        self.assertTrue(info()["announcementMuted"])
        a.req("call.stopFile", {"cid": ca, "playId": p2})
        self.assertFalse(info()["announcementMuted"])
        # 5. a plain play does not mute
        p3 = a.req("call.playFile", {"cid": ca, "file": f})["playId"]
        self.assertFalse(info()["announcementMuted"])
        a.req("call.stopFile", {"cid": ca})

    def test_local_monitor_accepted(self):
        a, b, ca, cb = self.direct_call()
        f = os.path.join(TMP, "lm_tone.wav")
        make_tone_wav(f, 0.8, 8000, 600.0)
        mark = a.mark()
        pid = a.req("call.playFile", {"cid": ca, "file": f, "localMonitor": True})["playId"]
        self.assertIsNotNone(self.heard(b, cb))
        self.assertEqual(a.wait_event("call.playDone", 6, mark, playId=pid)["reason"], "eof")


class TestMusicOnHold(MediaBase):
    def moh_file(self, name="moh.wav", seconds=1.0, rate=8000, freq=500.0):
        return make_tone_wav(os.path.join(TMP, name), seconds, rate, freq, 0.6)

    def test_moh_plays_during_hold_and_stops_on_unhold(self):
        a, b, ca, cb = self.direct_call()
        moh = self.moh_file()
        self.assertIsNone(self.heard(b, cb, 1.0), "B hears something before the hold")
        mark = a.mark()
        a.req("call.hold", {"cid": ca, "music": {"file": moh, "loop": True, "volume": 1.0}})
        self.assertIsNotNone(a.wait_event("call.media", 10, mark, cid=ca, media="localHold"))
        st = self.heard(b, cb, 10)
        self.assertIsNotNone(st, "B did not receive music during the hold")
        self.assertGreater(st["rxLevel"], 20)
        self.assertEqual(a.events("call.playDone", cid=ca), [])          # looping: still running
        time.sleep(1.5)                                                   # longer than the file: it loops
        self.assertGreater(b.req("call.stats", {"cid": cb})["rx"]["packets"], 30)
        self.assertIsNotNone(self.heard(b, cb, 3), "music stopped after one pass although loop=true")
        mark = a.mark()
        a.req("call.unhold", {"cid": ca})
        ev = a.wait_event("call.playDone", 5, mark, cid=ca)
        self.assertIsNotNone(ev, "no playDone for the music at unhold")
        self.assertEqual((ev["reason"], ev["file"], ev.get("moh")), ("stopped", moh, True))
        self.assertIsNotNone(a.wait_event("call.media", 10, mark, cid=ca, media="active"))
        self.assertIsNotNone(self.silent(b, cb, 10), "B still hears music after unhold")
        # and after unhold the user can talk again: a normal playFile reaches B
        f = self.moh_file("after.wav", 0.5, 8000, 700.0)
        a.req("call.playFile", {"cid": ca, "file": f})
        self.assertIsNotNone(self.heard(b, cb, 8))

    def test_plain_hold_without_music(self):
        a, b, ca, cb = self.direct_call()
        f = os.path.join(TMP, "ph.wav")
        make_tone_wav(f, 30.0, 8000, 450.0)
        a.req("call.playFile", {"cid": ca, "file": f, "loop": True})
        self.assertIsNotNone(self.heard(b, cb))
        mark = a.mark()
        a.req("call.hold", {"cid": ca})
        self.assertIsNotNone(a.wait_event("call.media", 10, mark, cid=ca, media="localHold"))
        self.assertEqual(a.req("call.info", {"cid": ca})["media"], "localHold")
        self.assertIsNotNone(self.silent(b, cb, 10), "audio leaked through a plain hold")
        time.sleep(1.0)
        self.assertEqual(a.events("call.playDone", cid=ca, moh=True), [])
        a.req("call.unhold", {"cid": ca})
        self.assertIsNotNone(a.wait_event("call.media", 10, mark, cid=ca, media="active"))
        self.assertIsNotNone(self.heard(b, cb, 8), "playback did not resume after unhold")

    def test_moh_validation_nonloop_and_hangup(self):
        a, b, ca, cb = self.direct_call()
        for music in ({"file": os.path.join(TMP, "none.wav")}, {"loop": True}, "x", {"file": self.moh_file(), "volume": 99}):
            r = a.raw("call.hold", {"cid": ca, "music": music})
            self.assertFalse(r["ok"], music)
            self.assertEqual(r["error"]["code"], "INVALID_PARAM", (music, r))
        self.assertFalse(a.req("call.info", {"cid": ca})["held"], "a rejected hold request must not hold the call")
        # non-looping: plays once and ends by itself with eof; the call stays on hold
        short = self.moh_file("short.wav", 0.6)
        mark = a.mark()
        a.req("call.hold", {"cid": ca, "music": {"file": short, "loop": False}})
        ev = a.wait_event("call.playDone", 10, mark, cid=ca)
        self.assertIsNotNone(ev)
        self.assertEqual((ev["reason"], ev.get("moh")), ("eof", True))
        self.assertTrue(a.req("call.info", {"cid": ca})["held"])
        a.req("call.unhold", {"cid": ca})
        a.wait_event("call.media", 10, mark, cid=ca, media="active")
        # hangup while the music plays -> playDone(hangup)
        mark = a.mark()
        a.req("call.hold", {"cid": ca, "music": {"file": self.moh_file(), "loop": True}})
        self.assertIsNotNone(self.heard(b, cb, 10))
        mark = a.mark()
        a.req("call.hangup", {"cid": ca})
        ev = a.wait_event("call.playDone", 8, mark, cid=ca)
        self.assertIsNotNone(ev)
        self.assertEqual(ev["reason"], "hangup")

    def test_moh_mp3(self):
        a, b, ca, cb = self.direct_call()
        a.req("call.hold", {"cid": ca, "music": {"file": MP3}})        # loop defaults to true
        self.assertIsNotNone(self.heard(b, cb, 10), "no MP3 music on hold")
        time.sleep(3.5)
        self.assertIsNotNone(self.heard(b, cb, 2), "MP3 hold music did not loop")
        a.req("call.unhold", {"cid": ca})


class TestBridgeRates(MediaBase):
    def test_other_bridge_clock_rates(self):
        """player resampling and recorders at an 8 kHz and a 48 kHz conference clock"""
        src = write_wav(os.path.join(TMP, "br_44k.wav"), [sine(44100, 6.0, 440, 0.6), sine(44100, 6.0, 440, 0.6)], 44100)
        for clock in (8000, 48000):
            a, b, ca, cb = self.direct_call(media={"clockRate": clock})
            a.req("call.playFile", {"cid": ca, "file": src, "loop": True})
            self.assertIsNotNone(self.heard(b, cb, 8), "clock %d" % clock)
            op = os.path.join(TMP, "br_%d.ogg" % clock)
            st = os.path.join(TMP, "br_%d.wav" % clock)
            b.req("call.recordStart", {"cid": cb, "file": op, "format": "opus", "mix": "remote"})
            time.sleep(1.5)
            r = b.req("call.recordStop", {"cid": cb})
            b.req("call.recordStart", {"cid": cb, "file": st, "format": "wavStereo"})
            time.sleep(1.5)
            r2 = b.req("call.recordStop", {"cid": cb})
            info = parse_ogg_opus(op)
            self.assertAlmostEqual(info["ms"], r["durationMs"], delta=2)
            self.assertAlmostEqual(r["durationMs"], 1500, delta=400)
            (left, right), rate = read_wav(st)
            self.assertEqual(rate, clock)
            self.assertLess(rms(left), 30)
            self.assertGreater(goertzel(right[rate // 4:], rate, 440), 3000, "clock %d" % clock)
            a.req("call.hangup", {"cid": ca})
            a.wait_event("call.state", 10, 0, cid=ca, state="disconnected")
            b.wait_event("call.state", 10, 0, cid=cb, state="disconnected")
            a.req("core.stop"); b.req("core.stop")
            a.started = b.started = False


class TestShutdown(MediaBase):
    def test_core_stop_with_active_music_players_and_recorders(self):
        a, b, ca, cb = self.direct_call()
        f = os.path.join(TMP, "sd.wav")
        make_tone_wav(f, 1.0, 8000, 440.0)
        a.req("call.playFile", {"cid": ca, "file": f, "loop": True, "localMonitor": True, "muteMic": True})
        a.req("call.recordStart", {"cid": ca, "file": os.path.join(TMP, "sd_st.wav"), "format": "wavStereo"})
        a.req("media.recordMicStart", {"file": os.path.join(TMP, "sd_mic.wav")})
        b.req("call.hold", {"cid": cb, "music": {"file": f}})
        self.assertIsNotNone(self.heard(a, ca, 10))
        for c in (a, b):
            c.raw("core.stop", {"graceful": False}, timeout=30)
        for c in (a, b):
            self.assertIsNotNone(c.wait_event("core.stopped", 20))
        with wave.open(os.path.join(TMP, "sd_st.wav"), "rb") as w:
            self.assertEqual(w.getnchannels(), 2)
        # the cores can be started again and still play files
        a.start_core()
        a.req("media.fileInfo", {"file": f})


class TestRecording(MediaBase):
    def test_mic_recorder(self):
        c = self.cli()
        c.start_core()
        out = os.path.join(TMP, "mic.wav")
        r = c.req("media.recordMicStart", {"file": out})
        self.assertEqual(r["file"], out)
        self.assertEqual(c.raw("media.recordMicStart", {"file": out + "2"})["error"]["code"], "ALREADY")
        time.sleep(2.0)
        r = c.req("media.recordMicStop")
        self.assertEqual((r["file"], r["format"]), (out, "wav"))
        self.assertAlmostEqual(r["durationMs"], 2000, delta=300)
        self.assertEqual(r["bytes"], os.path.getsize(out))
        ch, rate = read_wav(out)
        self.assertEqual(len(ch), 1)
        self.assertAlmostEqual(len(ch[0]) * 1000.0 / rate, r["durationMs"], delta=2)
        self.assertEqual(c.raw("media.recordMicStop")["error"]["code"], "INVALID_PARAM")
        self.assertEqual(c.raw("media.recordMicStart", {"file": ""})["error"]["code"], "INVALID_PARAM")
        self.assertEqual(c.raw("media.recordMicStart", {"file": os.path.join(TMP, "no", "such", "dir.wav")})["error"]["code"], "INVALID_PARAM")
        # can be restarted
        c.req("media.recordMicStart", {"file": out})
        time.sleep(0.5)
        self.assertGreater(c.req("media.recordMicStop")["durationMs"], 300)

    def test_wav_default_and_result_fields(self):
        a, b, ca, cb = self.direct_call()
        a.req("call.playFile", {"cid": ca, "file": os.path.join(TMP, "tone.wav"), "loop": True})
        path, r = self.record_remote(b, cb, 1.5, "def.wav")
        self.assertEqual(r["format"], "wav")
        self.assertEqual(r["file"], path)
        self.assertEqual(r["bytes"], os.path.getsize(path))
        self.assertAlmostEqual(r["durationMs"], 1500, delta=400)
        ch, rate = read_wav(path)
        self.assertEqual(len(ch), 1)
        self.assertGreater(rms(ch[0]), 500)
        for bad in ("mp3", "", 5):
            rr = b.raw("call.recordStart", {"cid": cb, "file": path, "format": bad})
            self.assertEqual(rr["error"]["code"], "INVALID_PARAM", bad)
        self.assertFalse(b.req("call.info", {"cid": cb})["recording"])

    def test_wav_stereo_channel_separation(self):
        a, b, ca, cb = self.direct_call()
        a.req("call.playFile", {"cid": ca, "file": os.path.join(TMP, "tone.wav"), "loop": True})
        self.assertIsNotNone(self.heard(b, cb))
        path = os.path.join(TMP, "stereo.wav")
        b.req("call.recordStart", {"cid": cb, "file": path, "format": "wavStereo", "mix": "local"})   # mix is ignored
        self.assertTrue(b.req("call.info", {"cid": cb})["recording"])
        time.sleep(2.5)
        r = b.req("call.recordStop", {"cid": cb})
        self.assertEqual(r["format"], "wavStereo")
        self.assertEqual(r["bytes"], os.path.getsize(path))
        self.assertAlmostEqual(r["durationMs"], 2500, delta=400)
        with wave.open(path, "rb") as w:
            self.assertEqual((w.getnchannels(), w.getsampwidth()), (2, 2))
            self.assertAlmostEqual(w.getnframes() * 1000.0 / w.getframerate(), r["durationMs"], delta=2)
        (left, right), rate = read_wav(path)
        self.assertEqual(len(left), len(right))
        self.assertLess(rms(left), 30, "left (B's own null mic) must be silent")
        self.assertGreater(rms(right), 3000, "right (remote) must carry A's tone")
        tail = right[rate // 2:]
        self.assertGreater(goertzel(tail, rate, 440), 4000)

    def test_wav_stereo_finalised_on_hangup(self):
        a, b, ca, cb = self.direct_call()
        a.req("call.playFile", {"cid": ca, "file": os.path.join(TMP, "tone.wav"), "loop": True})
        path = os.path.join(TMP, "stereo_hup.wav")
        mark = b.mark()
        b.req("call.recordStart", {"cid": cb, "file": path, "format": "wavStereo"})
        time.sleep(1.2)
        a.req("call.hangup", {"cid": ca})
        ev = b.wait_event("call.recording", 10, mark, cid=cb, recording=False)
        self.assertIsNotNone(ev, "no call.recording(false) at hangup")
        self.assertIsNotNone(b.wait_event("call.state", 10, mark, cid=cb, state="disconnected"))
        with wave.open(path, "rb") as w:
            self.assertEqual(w.getnchannels(), 2)
            self.assertGreater(w.getnframes() / float(w.getframerate()), 0.8)

    def test_opus_recording_valid_and_decodable(self):
        a, b, ca, cb = self.direct_call()
        a.req("call.playFile", {"cid": ca, "file": os.path.join(TMP, "tone.wav"), "loop": True})
        self.assertIsNotNone(self.heard(b, cb))
        path = os.path.join(TMP, "rec.ogg")
        b.req("call.recordStart", {"cid": cb, "file": path, "format": "opus", "mix": "remote"})
        time.sleep(3.0)
        r = b.req("call.recordStop", {"cid": cb})
        self.assertEqual(r["format"], "opus")
        self.assertEqual(r["bytes"], os.path.getsize(path))
        self.assertAlmostEqual(r["durationMs"], 3000, delta=400)
        info = parse_ogg_opus(path)
        self.assertEqual(info["channels"], 1)
        self.assertAlmostEqual(info["ms"], r["durationMs"], delta=2)
        self.assertAlmostEqual(info["npackets"] * 20, info["ms"], delta=25)
        self.assertGreaterEqual(info["pages"], 3)
        # ~24 kbps VBR voice: well below 64 kbps average
        self.assertLess(r["bytes"] * 8.0 / (r["durationMs"] / 1000.0), 64000)
        if shutil.which("ffmpeg"):
            pcm = subprocess.run(["ffmpeg", "-v", "error", "-i", path, "-f", "s16le", "-ar", "16000", "-ac", "1", "-"],
                                 capture_output=True, check=True).stdout
            x = struct.unpack("<%dh" % (len(pcm) // 2), pcm)
            self.assertAlmostEqual(len(x) / 16000.0 * 1000, r["durationMs"], delta=60)
            body = list(x[8000:])
            self.assertGreater(goertzel(body, 16000, 440), 3000, "decoded Opus does not contain A's 440 Hz tone")
            self.assertLess(goertzel(body, 16000, 1500), 400)
        if shutil.which("opusinfo"):
            oi = subprocess.run(["opusinfo", path], capture_output=True, text=True)
            self.assertEqual(oi.returncode, 0, oi.stdout + oi.stderr)
            self.assertNotIn("WARNING", oi.stdout + oi.stderr)
            self.assertNotIn("ERROR", oi.stdout + oi.stderr)

    def test_opus_recording_both_and_hangup_finalise(self):
        a, b, ca, cb = self.direct_call()
        path = os.path.join(TMP, "both.opus")
        mark = b.mark()
        b.req("call.recordStart", {"cid": cb, "file": path, "format": "opus"})    # mix both, silence + silence
        time.sleep(1.0)
        a.req("call.hangup", {"cid": ca})
        self.assertIsNotNone(b.wait_event("call.recording", 10, mark, cid=cb, recording=False))
        self.assertIsNotNone(b.wait_event("call.state", 10, mark, cid=cb, state="disconnected"))
        info = parse_ogg_opus(path)
        self.assertGreater(info["ms"], 500)
        self.assertLess(info["ms"], 2500)


if __name__ == "__main__":
    unittest.main()
