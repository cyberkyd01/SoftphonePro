"""Conference-bridge port lifetime stress: the bridge removes ports asynchronously and keeps a reference on the
port's group lock, so the memory of an inband-DTMF tone generator / tone port / denoiser must outlive the removal.
Meant for ASan builds (Base.tearDown fails the test on any sanitizer report); also runs in Release.
"""
import random
import time

from run_tests import Base
from test_review_fixes import async_req, wait_response, direct_pair, direct_call

ITER = 50


class TestConfPortLifetime(Base):
    def test_inband_dtmf_then_immediate_hangup_x50(self):
        """50 direct calls: inband DTMF (async) immediately followed by hangup, with tone start/stop and
        mic isolation toggles racing against the call teardown."""
        a, b, port = direct_pair(self)
        rnd = random.Random(1234)
        for i in range(ITER):
            cid_a, cid_b = direct_call(self, a, b, port)
            pending = [async_req(a, "call.dtmf", {"cid": cid_a, "digits": "1234567890*#"[:rnd.randint(1, 12)],
                                                  "method": "inband"})]
            if i % 2:
                pending.append(async_req(b, "call.dtmf", {"cid": cid_b, "digits": "9", "method": "inband"}))
            if i % 3 == 0:
                pending.append(async_req(a, "media.tone", {"kind": "dtmf", "digits": "12"}))
            if i % 5 == 0:
                pending.append(async_req(a, "media.setVoiceIsolation",
                                         {"incoming": {"enabled": True}, "mic": {"enabled": True}}))
            if rnd.random() < 0.5:
                time.sleep(rnd.random() * 0.05)
            pending.append(async_req(a, "call.hangup", {"cid": cid_a}))
            if i % 4 == 0:
                pending.append(async_req(a, "media.toneStop"))
            for rid in pending:
                self.assertIsNotNone(wait_response(a, rid, 30), "no response (iteration %d)" % i)
            self.assertIsNotNone(b.wait_event("call.state", 15, 0, cid=cid_b, state="disconnected"),
                                 "B not disconnected (iteration %d)" % i)
            if i % 5 == 0:
                a.req("media.setVoiceIsolation", {"incoming": {"enabled": False}, "mic": {"enabled": False}})
        a.req("core.ping")

    def test_tone_start_stop_races(self):
        a = self.cli("A")
        a.start_core()
        rnd = random.Random(7)
        for i in range(ITER * 4):
            ids = [async_req(a, "media.tone", {"kind": rnd.choice(["dial", "ringback", "busy", "dtmf"]),
                                               "digits": "123", "loop": bool(i % 2)})]
            if rnd.random() < 0.7:
                ids.append(async_req(a, "media.toneStop"))
            for rid in ids:
                self.assertIsNotNone(wait_response(a, rid, 30))
        a.req("media.toneStop")
        a.req("core.ping")
