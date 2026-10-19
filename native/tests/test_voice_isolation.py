"""Voice isolation (ENGINE_API.md 9.1): RNNoise processors in the conference bridge.

Run via run_tests.py (auto-loaded). Needs a spcore build with -DSPC_TEST_HOOKS=ON for the offline tests
(`__denoise.processFile`); those tests are skipped on production builds. The call tests are direct IP calls between
two spcore_cli processes (no PBX): A plays a WAV, B measures what its speaker path carries (media.levels.speaker).

Test audio is synthetic (no `say`/ffmpeg dependency): a vowel-like signal (glottal pulse train with vibrato through
three gliding formant resonators and a 3.5 Hz syllable envelope) plus Gaussian white noise.
"""
import math
import os
import random
import struct
import time
import unittest
import wave

from run_tests import Base, CLI, RpcError, TMP

RATE = 16000


# ---------------------------------------------------------------- signal helpers
def synth_speech(seconds, rate=RATE, seed=3):
    rnd = random.Random(seed)
    n = int(seconds * rate)
    out = []
    ph = 0.0
    st = [[0.0, 0.0] for _ in range(3)]
    forms = [(700, 90), (1220, 110), (2600, 160)]
    for i in range(n):
        t = i / rate
        f0 = 120 + 12 * math.sin(2 * math.pi * 5 * t) + 20 * math.sin(2 * math.pi * 0.7 * t)
        ph += f0 / rate
        if ph >= 1:
            ph -= 1
        y = (1 - ph) ** 2 * (1 if ph < 0.7 else 0.3) - 0.3 + rnd.gauss(0, 0.02)
        for k, (f, bw) in enumerate(forms):
            fm = f * (1 + 0.25 * math.sin(2 * math.pi * (0.9 + 0.3 * k) * t))
            r = math.exp(-math.pi * bw / rate)
            th = 2 * math.pi * fm / rate
            z = y * (1 - r) + 2 * r * math.cos(th) * st[k][0] - r * r * st[k][1]
            st[k][1] = st[k][0]
            st[k][0] = z
            y = z
        out.append(y * 0.5 * (1 - math.cos(2 * math.pi * 3.5 * t)))
    pk = max(abs(v) for v in out) or 1.0
    return [v / pk * 14000.0 for v in out]


def write_wav(path, samples, rate=RATE):
    with wave.open(path, "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(rate)
        w.writeframes(struct.pack("<%dh" % len(samples), *[max(-32768, min(32767, int(v))) for v in samples]))
    return path


def read_wav(path):
    with wave.open(path, "rb") as w:
        n = w.getnframes()
        d = struct.unpack("<%dh" % n, w.readframes(n))
        return list(d), w.getframerate()


def db(x):
    e = sum(v * v for v in x) / max(1, len(x))
    return 10 * math.log10(e + 1e-9)


def noise(n, sigma, seed):
    r = random.Random(seed)
    return [r.gauss(0, sigma) for _ in range(n)]


def level_to_lin(lv):
    """pjsua signal level (0-255, u-law magnitude code) -> approximate linear rms"""
    if lv <= 0:
        return 0.0
    exp, mant = (lv >> 4) & 7, lv & 15
    return float((((mant << 3) + 0x84) << exp) - 0x84)


def pct(xs, p):
    xs = sorted(xs)
    return xs[min(len(xs) - 1, int(p * len(xs)))]


def has_hooks(cli):
    r = cli.raw("__denoise.processFile", {})
    return r.get("error", {}).get("code") != "UNSUPPORTED"


class TestVoiceIsolationApi(Base):
    def test_defaults_and_validation(self):
        c = self.cli()
        c.start_core()
        st = c.req("media.voiceIsolationStatus")
        self.assertEqual(st["engine"], "rnnoise")
        self.assertTrue(st["available"])
        self.assertFalse(st["mic"]["enabled"])
        self.assertFalse(st["incoming"]["enabled"])
        self.assertEqual(st["mic"]["vad"], 0)
        r = c.req("media.setVoiceIsolation", {"mic": {"enabled": True, "strength": 0.6}})
        self.assertEqual(r["engine"], "rnnoise")
        self.assertTrue(r["available"])
        st = c.req("media.voiceIsolationStatus")
        self.assertTrue(st["mic"]["enabled"])
        self.assertAlmostEqual(st["mic"]["strength"], 0.6, places=3)
        self.assertFalse(st["incoming"]["enabled"])
        # omitted parts are unchanged; strength alone keeps the enabled flag
        c.req("media.setVoiceIsolation", {"incoming": {"enabled": True}})
        c.req("media.setVoiceIsolation", {"mic": {"strength": 0.25}})
        st = c.req("media.voiceIsolationStatus")
        self.assertTrue(st["mic"]["enabled"])
        self.assertAlmostEqual(st["mic"]["strength"], 0.25, places=3)
        self.assertTrue(st["incoming"]["enabled"])
        self.assertAlmostEqual(st["incoming"]["strength"], 1.0, places=3)
        c.req("media.setVoiceIsolation", {"mic": {"enabled": False}, "incoming": {"enabled": False}})
        st = c.req("media.voiceIsolationStatus")
        self.assertFalse(st["mic"]["enabled"])
        self.assertFalse(st["incoming"]["enabled"])
        self.assertTrue(c.raw("media.setVoiceIsolation", {})["ok"])        # no-op
        for bad in ({"mic": {"enabled": "yes"}}, {"mic": {"enabled": 1}}, {"mic": {"strength": 1.5}},
                    {"mic": {"strength": -0.1}}, {"incoming": {"strength": "high"}}, {"mic": 5}, {"incoming": [1]},
                    {"incoming": {"enabled": True, "strength": None}}):
            r = c.raw("media.setVoiceIsolation", bad)
            self.assertFalse(r["ok"], bad)
            self.assertEqual(r["error"]["code"], "INVALID_PARAM", bad)
        # a rejected request changes nothing
        st = c.req("media.voiceIsolationStatus")
        self.assertFalse(st["mic"]["enabled"])
        self.assertAlmostEqual(st["mic"]["strength"], 0.25, places=3)

    def test_core_start_config(self):
        c = self.cli()
        c.start_core(media={"voiceIsolation": {"mic": {"enabled": True, "strength": 0.5}, "incoming": {"enabled": True}}})
        st = c.req("media.voiceIsolationStatus")
        self.assertTrue(st["mic"]["enabled"])
        self.assertAlmostEqual(st["mic"]["strength"], 0.5, places=3)
        self.assertTrue(st["incoming"]["enabled"])
        # restart without the option: back to the default (off)
        c.req("core.stop")
        c.start_core()
        st = c.req("media.voiceIsolationStatus")
        self.assertFalse(st["mic"]["enabled"])
        self.assertFalse(st["incoming"]["enabled"])
        c.req("core.stop")
        r = c.raw("core.start", {"media": {"noAudioDevice": True, "voiceIsolation": {"mic": {"strength": 7}}},
                                 "transports": {"udp": {"port": 0}}})
        self.assertFalse(r["ok"])
        self.assertEqual(r["error"]["code"], "INVALID_PARAM")
        r = c.raw("core.start", {"media": {"noAudioDevice": True, "voiceIsolation": "on"}, "transports": {"udp": {"port": 0}}})
        self.assertEqual(r["error"]["code"], "INVALID_PARAM")
        self.assertFalse(c.req("core.info")["started"])


class TestVoiceIsolationOffline(Base):
    """The processor itself, run offline through the hidden test hook."""

    @classmethod
    def setUpClass(cls):
        sp = synth_speech(3.0)
        n_sil = 2 * RATE
        cls.sig = [0.0] * n_sil + sp + [0.0] * n_sil                 # silence | speech | silence
        cls.mix = [a + b for a, b in zip(cls.sig, noise(len(cls.sig), 1500, 9))]
        cls.mix_path = write_wav(os.path.join(TMP, "vi_mix.wav"), cls.mix)
        cls.sig_path = write_wav(os.path.join(TMP, "vi_clean.wav"), cls.sig)
        cls.n_sil = n_sil

    def run_file(self, c, strength, path=None, tag=""):
        out = os.path.join(TMP, "vi_out_%s%s.wav" % (strength, tag))
        r = c.req("__denoise.processFile", {"in": path or self.mix_path, "out": out, "strength": strength})
        o, rate = read_wav(out)
        return r, o, rate

    def delay(self, o):
        """latency of the processor in samples, by cross-correlation of the strength-0 (dry) output with the input"""
        best = (-1e30, 0)
        a, b = 20000, 26000
        for lag in range(0, 400):
            c = sum(x * y for x, y in zip(o[a + lag:b + lag], self.mix[a:b]))
            if c > best[0]:
                best = (c, lag)
        return best[1]

    def setUp(self):
        super().setUp()
        self.c = self.cli()
        self.c.start_core()
        if not has_hooks(self.c):
            self.skipTest("spcore built without SPC_TEST_HOOKS")

    def test_noise_reduction_and_speech_preserved(self):
        c = self.c
        r0, o0, _ = self.run_file(c, 0.0)
        lag = self.delay(o0)
        self.assertLess(lag, 400, "unexpected processing latency %d samples" % lag)
        r1, o1, rate = self.run_file(c, 1.0)
        self.assertEqual(rate, RATE)
        n, ns = len(self.mix), self.n_sil
        # noise-only segments (skip the first second: model/gain warm-up) must drop by more than 10 dB
        seg1 = (RATE, 2 * RATE - 1600)
        seg2 = (ns + 3 * RATE + 1600, n - 1600)
        for a, b in (seg1, seg2):
            red = db(o1[a + lag:b + lag]) - db(self.mix[a:b])
            self.assertLess(red, -10.0, "noise only reduced by %.1f dB in %s" % (red, (a, b)))
        # speech region: the denoised signal keeps the clean speech energy (> -3 dB)
        sa, sb = ns + 4000, ns + 3 * RATE - 4000
        kept = db(o1[sa + lag:sb + lag]) - db(self.sig[sa:sb])
        print("\n[voice isolation] offline: speech kept %.2f dB, noise reduction %s dB" % (kept, ["%.1f" % (db(o1[a + lag:b + lag]) - db(self.mix[a:b])) for a, b in (seg1, seg2)]))
        self.assertGreater(kept, -3.0, "speech attenuated by %.1f dB" % -kept)
        self.assertLess(kept, 3.0)
        # strength 0 is (nearly) transparent: dry path only
        for a, b in ((RATE, 2 * RATE), (sa, sb)):
            d0 = db(o0[a + lag:b + lag]) - db(self.mix[a:b])
            self.assertGreater(d0, -1.0, "strength 0 changed the level by %.1f dB" % d0)
            self.assertLess(d0, 1.0)
        # speech waveform is correlated with the clean one far better than the noisy input is (SNR improved)
        def snr(x, ref, a, b, off):
            e = sum((x[i + off] - ref[i]) ** 2 for i in range(a, b))
            s = sum(ref[i] ** 2 for i in range(a, b))
            return 10 * math.log10(s / e)
        # (scale the processed signal to the clean reference with a least squares gain to ignore small level changes)
        def lsq(x, ref, a, b, off):
            num = sum(x[i + off] * ref[i] for i in range(a, b))
            den = sum(x[i + off] ** 2 for i in range(a, b))
            g = num / den
            return [g * v for v in x[off:]]
        s_in = snr(self.mix, self.sig, sa, sb, 0)
        s_out = snr(lsq(o1, self.sig, sa, sb, lag), self.sig, sa, sb, 0)
        self.assertGreater(s_out, s_in + 3.0, "SNR in %.1f dB out %.1f dB" % (s_in, s_out))
        # the frame VAD saw speech
        self.assertGreater(r1["meanVad"], 0.1)

    def test_strength_scales_attenuation(self):
        c = self.c
        _, o0, _ = self.run_file(c, 0.0)
        lag = self.delay(o0)
        a, b = RATE, 2 * RATE - 1600
        red = {}
        for s in (0.25, 0.5, 1.0):
            _, o, _ = self.run_file(c, s)
            red[s] = db(o[a + lag:b + lag]) - db(self.mix[a:b])
        self.assertLess(red[1.0], red[0.5] - 3.0, red)
        self.assertLess(red[0.5], red[0.25] - 1.0, red)
        self.assertLess(red[0.25], -3.0, red)

    def test_no_clicks(self):
        """sample-to-sample jumps of the denoised noise-only tail stay small (gain is smoothed, no discontinuities)"""
        _, o, _ = self.run_file(self.c, 1.0)
        tail = o[len(o) - RATE:len(o) - 1600]
        self.assertLess(max(abs(tail[i + 1] - tail[i]) for i in range(len(tail) - 1)), 400)
        # speech onset: no step larger than the speech itself could produce
        ns = self.n_sil
        seg = o[ns - 1600:ns + 8000]
        self.assertLess(max(abs(seg[i + 1] - seg[i]) for i in range(len(seg) - 1)), 12000)

    def test_other_rates_and_errors(self):
        c = self.c
        for rate in (8000, 48000):
            sp = [v for v in synth_speech(1.0, rate=rate)]
            p = write_wav(os.path.join(TMP, "vi_%d.wav" % rate), [a + b for a, b in zip(sp, noise(len(sp), 800, 5))], rate)
            r, o, orate = self.run_file(c, 1.0, p, tag="_%d" % rate)
            self.assertEqual(orate, rate)
            self.assertGreaterEqual(len(o), len(sp))
            self.assertGreater(r["frames10ms"], 90)
        r = c.raw("__denoise.processFile", {"in": os.path.join(TMP, "nope.wav"), "out": os.path.join(TMP, "x.wav"), "strength": 1})
        self.assertEqual(r["error"]["code"], "INVALID_PARAM")
        r = c.raw("__denoise.processFile", {"in": self.mix_path, "out": os.path.join(TMP, "x.wav"), "strength": 2})
        self.assertEqual(r["error"]["code"], "INVALID_PARAM")
        p = write_wav(os.path.join(TMP, "vi_44.wav"), [0] * 4410, 44100)      # 882-sample frames map to 960: supported
        self.assertTrue(c.raw("__denoise.processFile", {"in": p, "out": os.path.join(TMP, "x.wav"), "strength": 1})["ok"])
        p = write_wav(os.path.join(TMP, "vi_11.wav"), [0] * 4410, 11025)      # 220.5 samples per 20 ms: unsupported
        self.assertEqual(c.raw("__denoise.processFile", {"in": p, "out": os.path.join(TMP, "x.wav"), "strength": 1})["error"]["code"], "UNSUPPORTED")
        # a hostile / truncated file is rejected, not crashed on
        bad = os.path.join(TMP, "vi_bad.wav")
        with open(bad, "wb") as f:
            f.write(b"RIFF\xff\xff\xff\xffWAVEfmt \x10\x00\x00\x00\x01\x00\x01\x00\x80>\x00\x00\x00}\x00\x00\x02\x00\x10\x00data\xff\xff\xff\xff\x01\x02")
        r = c.raw("__denoise.processFile", {"in": bad, "out": os.path.join(TMP, "x.wav"), "strength": 1})
        self.assertFalse(r["ok"])

    def test_cpu_cost(self):
        """RNNoise + resampling for one 10 ms frame must be far below real time (budget: < 1 ms of CPU, i.e. 10%)"""
        r, _, _ = self.run_file(self.c, 1.0)
        print("\n[voice isolation] CPU per 10 ms frame @16 kHz bridge: %.0f us (%.2f%% of one core)"
              % (r["cpuUsPer10ms"], r["cpuUsPer10ms"] / 100.0))
        # sanitizer/debug builds are ~15x slower; they only have to stay under real time (10 ms per 10 ms frame)
        self.assertLess(r["cpuUsPer10ms"], 8000.0 if "asan" in CLI.lower() else 1000.0)


class TestVoiceIsolationCalls(Base):
    """End to end over a direct call: A plays audio, B's speaker path carries it (incoming isolation on or off)."""

    @classmethod
    def setUpClass(cls):
        sp = synth_speech(3.0)
        lead = noise(2 * RATE, 2500, 21)
        gap = noise(2 * RATE, 2500, 22)
        cls.noise_only = write_wav(os.path.join(TMP, "vi_call_noise.wav"), noise(8 * RATE, 2500, 20))
        body = [a + b for a, b in zip(sp, noise(len(sp), 2500, 23))]
        cls.speech_noise = write_wav(os.path.join(TMP, "vi_call_speech.wav"), lead + body + gap)

    def direct_call(self, b_media=None):
        a, b = self.cli("A"), self.cli("B")
        a.start_core()
        kw = {"media": b_media} if b_media else {}
        rb = b.start_core(**kw)
        port = [t for t in rb["transports"] if t["type"] == "udp"][0]["local"].split(":")[1]
        mb = b.mark()
        cid_a = a.req("call.make", {"acc": -1, "uri": "sip:127.0.0.1:%s" % port})["cid"]
        inc = b.wait_event("call.incoming", 15, mb)
        self.assertIsNotNone(inc)
        cid_b = inc["cid"]
        b.req("call.answer", {"cid": cid_b})
        self.assertIsNotNone(a.wait_event("call.state", 15, 0, cid=cid_a, state="confirmed"))
        self.assertIsNotNone(b.wait_event("call.state", 15, mb, cid=cid_b, state="confirmed"))
        self.wait_media(a, cid_a)
        self.wait_media(b, cid_b)
        return a, b, cid_a, cid_b

    def sample_speaker(self, b, seconds, step=0.04):
        vals = []
        end = time.time() + seconds
        while time.time() < end:
            vals.append(level_to_lin(b.req("media.levels")["speaker"]))
            time.sleep(step)
        return vals

    def measure(self, wav, iso, seconds):
        a, b, ca, cb = self.direct_call()
        if iso:
            b.req("media.setVoiceIsolation", {"incoming": {"enabled": True, "strength": 1.0}})
        a.req("call.playFile", {"cid": ca, "file": wav, "loop": True})
        time.sleep(1.0)
        vals = self.sample_speaker(b, seconds)
        a.req("call.hangup", {"cid": ca})
        self.assertIsNotNone(b.wait_event("call.state", 10, 0, cid=cb, state="disconnected"))
        return vals

    def test_incoming_isolation_removes_noise(self):
        off = self.measure(self.noise_only, False, 4)
        on = self.measure(self.noise_only, True, 4)
        self.assertGreater(pct(off, 0.5), 300, "baseline too quiet: %s" % off[:10])
        red = 20 * math.log10(max(pct(on, 0.5), 1.0) / pct(off, 0.5))
        self.assertLess(red, -10.0, "noise-only speaker level reduced by only %.1f dB" % -red)

    def test_incoming_isolation_keeps_speech(self):
        off = self.measure(self.speech_noise, False, 7.5)
        on = self.measure(self.speech_noise, True, 7.5)
        # loop = 2 s noise, 3 s speech+noise, 2 s noise: the 25th percentile is the noise floor, the maximum is speech
        floor = 20 * math.log10(max(pct(on, 0.25), 1.0) / max(pct(off, 0.25), 1.0))
        self.assertLess(floor, -10.0, "noise floor reduced by only %.1f dB" % -floor)
        # speech-only reference for the "off" run: remove the noise power from the speech+noise peak level
        ref = math.sqrt(max(pct(off, 0.97) ** 2 - pct(off, 0.25) ** 2, 1.0))
        peak = 20 * math.log10(max(pct(on, 0.97), 1.0) / ref)
        # (coarse u-law level readout through G.711: -4.5 dB here; the exact -3 dB criterion is checked offline)
        self.assertGreater(peak, -4.5, "speech peaks attenuated by %.1f dB" % -peak)

    def test_live_toggle_keeps_call_and_audio(self):
        a, b, ca, cb = self.direct_call()
        a.req("call.playFile", {"cid": ca, "file": self.noise_only, "loop": True})
        time.sleep(1.0)
        base = pct(self.sample_speaker(b, 1.5), 0.5)
        self.assertGreater(base, 300)
        for i in range(3):
            b.req("media.setVoiceIsolation", {"incoming": {"enabled": True, "strength": 1.0}, "mic": {"enabled": True}})
            time.sleep(2.5)
            on = pct(self.sample_speaker(b, 1.0), 0.5)
            self.assertLess(on, base * 0.4, "iteration %d: isolation on but level %s vs %s" % (i, on, base))
            b.req("media.setVoiceIsolation", {"incoming": {"enabled": False}, "mic": {"enabled": False}})
            time.sleep(0.8)
            off = pct(self.sample_speaker(b, 1.0), 0.5)
            self.assertGreater(off, base * 0.6, "iteration %d: isolation off but level %s vs %s" % (i, off, base))
        # strength change while running
        b.req("media.setVoiceIsolation", {"incoming": {"enabled": True, "strength": 0.0}})
        time.sleep(1.0)
        self.assertGreater(pct(self.sample_speaker(b, 1.0), 0.5), base * 0.6)
        b.req("media.setVoiceIsolation", {"incoming": {"strength": 1.0}})
        time.sleep(2.0)
        self.assertLess(pct(self.sample_speaker(b, 1.0), 0.5), base * 0.4)
        # the call is still up and RTP kept flowing
        info = b.req("call.info", {"cid": cb})
        self.assertEqual(info["state"], "confirmed")
        self.assertEqual(info["media"], "active")
        self.assertGreater(b.req("call.stats", {"cid": cb})["rx"]["packets"], 100)
        a.req("call.hangup", {"cid": ca})
        self.assertIsNotNone(b.wait_event("call.state", 10, 0, cid=cb, state="disconnected"))

    def test_mic_isolation_topology(self):
        """mic isolation on (null capture device): mute/hold/unhold/record/hangup keep working, B still hears A, and
        the status reports a VAD value"""
        a, b, ca, cb = self.direct_call(b_media={"voiceIsolation": {"mic": {"enabled": True}, "incoming": {"enabled": True}}})
        a.req("call.playFile", {"cid": ca, "file": self.speech_noise, "loop": True})
        rec = os.path.join(TMP, "vi_rec.wav")
        b.req("call.recordStart", {"cid": cb, "file": rec})
        time.sleep(2.0)
        st = b.req("media.voiceIsolationStatus")
        self.assertTrue(st["mic"]["enabled"])
        self.assertGreaterEqual(st["mic"]["vad"], 0.0)
        self.assertLessEqual(st["mic"]["vad"], 1.0)
        b.req("call.mute", {"cid": cb, "mute": True})
        self.assertTrue(b.req("call.info", {"cid": cb})["muted"])
        time.sleep(0.5)
        b.req("call.mute", {"cid": cb, "mute": False})
        b.req("call.hold", {"cid": cb})
        time.sleep(1.0)
        b.req("call.unhold", {"cid": cb})
        self.assertIsNotNone(self.poll(lambda: b.req("call.info", {"cid": cb})["held"] is False and b.req("call.info", {"cid": cb})["state"] == "confirmed", 10))
        time.sleep(1.0)
        self.assertGreater(self.sample_speaker_max(b, 2.0), 100)
        r = b.req("call.recordStop", {"cid": cb})
        self.assertGreater(r["durationMs"], 1000)
        o, _ = read_wav(rec)
        self.assertGreater(db(o), 20.0)             # the remote audio reached the recording
        b.req("media.setVoiceIsolation", {"mic": {"enabled": False}})
        time.sleep(0.5)
        self.assertEqual(b.req("call.info", {"cid": cb})["state"], "confirmed")
        b.req("call.hangup", {"cid": cb})
        self.assertIsNotNone(a.wait_event("call.state", 10, 0, cid=ca, state="disconnected"))

    def sample_speaker_max(self, b, seconds):
        return max(self.sample_speaker(b, seconds))

    def test_conference_with_incoming_isolation(self):
        """B bridges A and C while incoming isolation is on: relay between the legs keeps working (isolation only
        shapes the local speaker path), and hangup of one leg frees its processor cleanly"""
        a, c, b = self.cli("A"), self.cli("C"), self.cli("B")
        a.start_core()
        c.start_core()
        rb = b.start_core(media={"voiceIsolation": {"incoming": {"enabled": True}}})
        port = [t for t in rb["transports"] if t["type"] == "udp"][0]["local"].split(":")[1]
        cids = {}
        for cli, name in ((a, "A"), (c, "C")):
            mb = b.mark()
            cid = cli.req("call.make", {"acc": -1, "uri": "sip:127.0.0.1:%s" % port})["cid"]
            inc = b.wait_event("call.incoming", 15, mb)
            self.assertIsNotNone(inc)
            b.req("call.answer", {"cid": inc["cid"]})
            self.assertIsNotNone(cli.wait_event("call.state", 15, 0, cid=cid, state="confirmed"))
            self.wait_media(cli, cid)
            cids[name] = (cid, inc["cid"])
        b.req("call.conference", {"cids": [cids["A"][1], cids["C"][1]]})
        c.req("call.playFile", {"cid": cids["C"][0], "file": TONE_PATH(), "loop": True})
        heard = self.poll(lambda: a.req("call.stats", {"cid": cids["A"][0]})["rxLevel"] > 5, 10, 0.1)
        self.assertTrue(heard, "A does not hear C through B's conference")
        a.req("call.hangup", {"cid": cids["A"][0]})
        self.assertIsNotNone(b.wait_event("call.state", 10, 0, cid=cids["A"][1], state="disconnected"))
        time.sleep(0.5)
        self.assertEqual(b.req("call.info", {"cid": cids["C"][1]})["state"], "confirmed")
        c.req("call.hangup", {"cid": cids["C"][0]})


def TONE_PATH():
    from run_tests import TONE
    return TONE


if __name__ == "__main__":
    unittest.main()
