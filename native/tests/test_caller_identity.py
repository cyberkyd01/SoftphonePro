"""Caller identity in CallInfo (ENGINE_API.md 9.5): assertedIdentity, identityWithheld, diversion, referredBy.

Run via run_tests.py (auto-loaded). Direct IP calls between two spcore_cli processes (custom headers are allowed on
call.make / call.answer, only core headers like Via/From/To are rejected), plus raw SIP INVITEs over UDP for cases the
header map cannot express (several header lines) and for hostile input.
"""
import socket
import time
import unittest

from run_tests import Base, RpcError


class Ident(Base):
    def pair(self):
        a, b = self.cli("A"), self.cli("B")
        a.start_core()
        rb = b.start_core()
        self.port = [t for t in rb["transports"] if t["type"] == "udp"][0]["local"].split(":")[1]
        return a, b

    def incoming(self, headers):
        a, b = self.pair()
        mb = b.mark()
        cid = a.req("call.make", {"acc": -1, "uri": "sip:127.0.0.1:%s" % self.port, "headers": headers})["cid"]
        inc = b.wait_event("call.incoming", 10, mb)
        self.assertIsNotNone(inc, "no call.incoming")
        info = b.req("call.info", {"cid": inc["cid"]})
        for k in ("assertedIdentity", "identityWithheld", "diversion", "referredBy"):
            self.assertEqual(inc[k], info[k], k)         # call.incoming and call.info agree
        b.req("call.reject", {"cid": inc["cid"], "code": 486})
        return inc

    # ---- P-Asserted-Identity / Remote-Party-ID ----
    def test_no_identity_headers(self):
        inc = self.incoming({"X-Test": "1"})
        self.assertIsNone(inc["assertedIdentity"])
        self.assertFalse(inc["identityWithheld"])
        self.assertEqual(inc["diversion"], [])
        self.assertIsNone(inc["referredBy"])

    def test_pai_sip_and_tel_prefers_sip(self):
        inc = self.incoming({"P-Asserted-Identity": '"Alice, A." <sip:+4930123@carrier.example;user=phone>, <tel:+4930123>'})
        self.assertEqual(inc["assertedIdentity"], {"display": "Alice, A.", "user": "+4930123",
                                                   "uri": "sip:+4930123@carrier.example;user=phone"})
        self.assertFalse(inc["identityWithheld"])

    def test_pai_tel_only(self):
        inc = self.incoming({"P-Asserted-Identity": "<tel:+15551234;ext=9>"})
        self.assertEqual(inc["assertedIdentity"]["uri"], "tel:+15551234;ext=9")
        self.assertEqual(inc["assertedIdentity"]["user"], "+15551234")
        self.assertEqual(inc["assertedIdentity"]["display"], "")

    def test_pai_tel_then_sip_prefers_sip(self):
        inc = self.incoming({"P-Asserted-Identity": "<tel:+1555>, Bob <sip:bob@x.example>"})
        self.assertEqual(inc["assertedIdentity"]["uri"], "sip:bob@x.example")
        self.assertEqual(inc["assertedIdentity"]["display"], "Bob")

    def test_privacy_id_withholds_pai(self):
        inc = self.incoming({"P-Asserted-Identity": "<sip:alice@x.example>", "Privacy": "id"})
        self.assertIsNone(inc["assertedIdentity"])
        self.assertTrue(inc["identityWithheld"])
        inc = self.incoming({"P-Asserted-Identity": "<sip:alice@x.example>", "Privacy": "none"})
        self.assertEqual(inc["assertedIdentity"]["user"], "alice")
        self.assertFalse(inc["identityWithheld"])
        inc = self.incoming({"P-Asserted-Identity": "<sip:alice@x.example>", "Privacy": "header;critical"})
        self.assertEqual(inc["assertedIdentity"]["user"], "alice")       # only "id" hides the identity

    def test_rpid(self):
        inc = self.incoming({"Remote-Party-ID": '"Carol" <sip:carol@x.example>;party=calling;screen=yes;privacy=off'})
        self.assertEqual(inc["assertedIdentity"], {"display": "Carol", "user": "carol", "uri": "sip:carol@x.example"})
        self.assertFalse(inc["identityWithheld"])
        inc = self.incoming({"Remote-Party-ID": '"Carol" <sip:carol@x.example>;party=calling;privacy=full'})
        self.assertIsNone(inc["assertedIdentity"])
        self.assertTrue(inc["identityWithheld"])
        inc = self.incoming({"Remote-Party-ID": '"Carol" <sip:carol@x.example>;party=calling;privacy=name'})
        self.assertEqual(inc["assertedIdentity"]["display"], "")
        self.assertEqual(inc["assertedIdentity"]["user"], "carol")
        inc = self.incoming({"Remote-Party-ID": '"Carol" <sip:carol@x.example>;privacy=uri'})
        self.assertEqual(inc["assertedIdentity"]["display"], "Carol")
        self.assertEqual(inc["assertedIdentity"]["uri"], "")
        # PAI wins over RPID
        inc = self.incoming({"P-Asserted-Identity": "<sip:pai@x.example>", "Remote-Party-ID": "<sip:rpid@x.example>"})
        self.assertEqual(inc["assertedIdentity"]["user"], "pai")

    # ---- Diversion / History-Info / Referred-By ----
    def test_diversion_multiple_earliest_first(self):
        # topmost value = most recent diversion; the API lists the earliest first
        inc = self.incoming({"Diversion": '<sip:carol@x.example>;reason=no-answer;counter=2;privacy=off, '
                                          '"Bob" <sip:bob@x.example>;reason="user-busy"'})
        self.assertEqual(inc["diversion"], [
            {"uri": "sip:bob@x.example", "user": "bob", "reason": "user-busy", "counter": 1},
            {"uri": "sip:carol@x.example", "user": "carol", "reason": "no-answer", "counter": 2}])

    def test_history_info_index_order(self):
        hi = ('<sip:carol@x.example?Reason=SIP%3Bcause%3D408>;index=1.1.1, '
              '<sip:alice@x.example>;index=1, '
              '<sip:bob@x.example?Reason=SIP%3Bcause%3D486>;index=1.1')
        inc = self.incoming({"History-Info": hi})
        # alice (1) -> bob (1.1, because of 486 busy at ... ) -> carol (1.1.1, 408): two diversions
        self.assertEqual([d["user"] for d in inc["diversion"]], ["alice", "bob"])
        self.assertEqual([d["reason"] for d in inc["diversion"]], ["user-busy", "no-answer"])
        self.assertEqual([d["counter"] for d in inc["diversion"]], [1, 1])
        for d in inc["diversion"]:
            self.assertNotIn("?", d["uri"])
        # a single History-Info entry is just the original target: no diversion
        inc = self.incoming({"History-Info": "<sip:alice@x.example>;index=1"})
        self.assertEqual(inc["diversion"], [])
        # Diversion wins when both are present
        inc = self.incoming({"Diversion": "<sip:dd@x.example>;reason=unconditional", "History-Info": hi})
        self.assertEqual([d["user"] for d in inc["diversion"]], ["dd"])

    def test_referred_by(self):
        inc = self.incoming({"Referred-By": '"Dave" <sip:dave@x.example>;cid="123@x.example"'})
        self.assertEqual(inc["referredBy"], "sip:dave@x.example")
        inc = self.incoming({"Referred-By": "sip:erin@x.example"})
        self.assertEqual(inc["referredBy"], "sip:erin@x.example")

    def test_identity_in_call_state_events(self):
        a, b = self.pair()
        mb = b.mark()
        cid = a.req("call.make", {"acc": -1, "uri": "sip:127.0.0.1:%s" % self.port,
                                  "headers": {"P-Asserted-Identity": "<sip:alice@x.example>"}})["cid"]
        inc = b.wait_event("call.incoming", 10, mb)
        b.req("call.answer", {"cid": inc["cid"]})
        ev = b.wait_event("call.state", 10, mb, cid=inc["cid"], state="confirmed")
        self.assertEqual(ev["assertedIdentity"]["user"], "alice")
        b.req("call.hangup", {"cid": inc["cid"]})

    # ---- outgoing calls: PAI of the answering party ----
    def test_outgoing_pai_from_200_and_183(self):
        a, b = self.pair()
        mb = b.mark()
        cid = a.req("call.make", {"acc": -1, "uri": "sip:127.0.0.1:%s" % self.port})["cid"]
        self.assertIsNone(a.req("call.info", {"cid": cid})["assertedIdentity"])
        inc = b.wait_event("call.incoming", 10, mb)
        ma = a.mark()
        b.req("call.answer", {"cid": inc["cid"], "code": 183, "headers": {"P-Asserted-Identity": '"Early" <sip:early@y.example>'}})
        ev = a.wait(lambda m: m.get("type") == "event" and m.get("event") == "call.state" and m.get("cid") == cid
                    and m.get("state") == "early", 10, ma)
        self.assertIsNotNone(ev)
        self.assertEqual(ev["assertedIdentity"], {"display": "Early", "user": "early", "uri": "sip:early@y.example"})
        b.req("call.answer", {"cid": inc["cid"]})
        ev = a.wait_event("call.state", 10, ma, cid=cid, state="confirmed")
        self.assertIsNotNone(ev)
        self.assertEqual(a.req("call.info", {"cid": cid})["assertedIdentity"]["user"], "early")     # kept from the 183
        a.req("call.hangup", {"cid": cid})

    def test_outgoing_pai_from_200(self):
        a, b = self.pair()
        mb = b.mark()
        cid = a.req("call.make", {"acc": -1, "uri": "sip:127.0.0.1:%s" % self.port})["cid"]
        inc = b.wait_event("call.incoming", 10, mb)
        ma = a.mark()
        b.req("call.answer", {"cid": inc["cid"], "headers": {"P-Asserted-Identity": '"Final" <sip:final@y.example>', "Privacy": "none"}})
        ev = a.wait_event("call.state", 10, ma, cid=cid, state="confirmed")
        self.assertIsNotNone(ev)
        self.assertEqual(ev["assertedIdentity"], {"display": "Final", "user": "final", "uri": "sip:final@y.example"})
        self.assertEqual(a.req("call.info", {"cid": cid})["assertedIdentity"]["user"], "final")
        a.req("call.hangup", {"cid": cid})

    def test_outgoing_pai_withheld_by_privacy(self):
        a, b = self.pair()
        mb = b.mark()
        cid = a.req("call.make", {"acc": -1, "uri": "sip:127.0.0.1:%s" % self.port})["cid"]
        inc = b.wait_event("call.incoming", 10, mb)
        b.req("call.answer", {"cid": inc["cid"], "headers": {"P-Asserted-Identity": "<sip:hidden@y.example>", "Privacy": "id"}})
        self.assertIsNotNone(a.wait_event("call.state", 10, 0, cid=cid, state="confirmed"))
        info = a.req("call.info", {"cid": cid})
        self.assertIsNone(info["assertedIdentity"])
        self.assertTrue(info["identityWithheld"])
        a.req("call.hangup", {"cid": cid})

    # ---- raw SIP: several header lines, hostile input ----
    def raw_invite(self, port, extra_lines, body_sdp=True, call_id="raw-ident-1"):
        sdp = ("v=0\r\no=- 1 1 IN IP4 127.0.0.1\r\ns=-\r\nc=IN IP4 127.0.0.1\r\nt=0 0\r\n"
               "m=audio 40000 RTP/AVP 0\r\na=rtpmap:0 PCMU/8000\r\n") if body_sdp else ""
        sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        sock.settimeout(5)
        sock.bind(("127.0.0.1", 0))
        lp = sock.getsockname()[1]
        msg = ("INVITE sip:test@127.0.0.1:%s SIP/2.0\r\n"
               "Via: SIP/2.0/UDP 127.0.0.1:%d;branch=z9hG4bK%s\r\n"
               "Max-Forwards: 70\r\n"
               "From: \"Raw\" <sip:raw@127.0.0.1>;tag=rawtag\r\n"
               "To: <sip:test@127.0.0.1:%s>\r\n"
               "Call-ID: %s\r\n"
               "CSeq: 1 INVITE\r\n"
               "Contact: <sip:raw@127.0.0.1:%d>\r\n"
               "%s"
               "Content-Type: application/sdp\r\n"
               "Content-Length: %d\r\n\r\n%s") % (port, lp, call_id, port, call_id, lp, "".join(l + "\r\n" for l in extra_lines),
                                                  len(sdp), sdp)
        sock.sendto(msg.encode(), ("127.0.0.1", int(port)))
        return sock

    def test_raw_multiple_header_lines(self):
        b = self.cli("B")
        rb = b.start_core()
        port = [t for t in rb["transports"] if t["type"] == "udp"][0]["local"].split(":")[1]
        mb = b.mark()
        sock = self.raw_invite(port, [
            "P-Asserted-Identity: <tel:+49301111>",
            "P-Asserted-Identity: \"Zed\" <sip:zed@pbx.example>",
            "Diversion: <sip:third@x.example>;reason=no-answer;counter=3",
            "Diversion: <sip:second@x.example>;reason=user-busy",
            "Diversion: <sip:first@x.example>;reason=unconditional",
            "Referred-By: <sip:ref@x.example>",
        ])
        inc = b.wait_event("call.incoming", 10, mb)
        self.assertIsNotNone(inc)
        self.assertEqual(inc["assertedIdentity"]["user"], "zed")
        self.assertEqual([d["user"] for d in inc["diversion"]], ["first", "second", "third"])
        self.assertEqual([d["counter"] for d in inc["diversion"]], [1, 1, 3])
        self.assertEqual(inc["referredBy"], "sip:ref@x.example")
        b.req("call.reject", {"cid": inc["cid"], "code": 603})
        sock.close()

    def test_raw_hostile_input(self):
        """oversized / pathological identity headers: bounded output, no crash, the call is still delivered"""
        b = self.cli("B")
        rb = b.start_core()
        port = [t for t in rb["transports"] if t["type"] == "udp"][0]["local"].split(":")[1]
        big_name = "N" * 400
        many = ", ".join("<sip:d%d@x.example>;reason=r%d;counter=%d" % (i, i, i) for i in range(14))
        lines = [
            "P-Asserted-Identity: \"%s\" <sip:%s@x.example>" % (big_name, "u" * 300),
            "Diversion: " + many,
        ] + ["Diversion: <sip:extra%d@x.example>;reason=%s;counter=99999999999999" % (i, "z" * 120) for i in range(6)] + [
            "History-Info: <<<>>>;index=;;;, \"unterminated <sip:x@y;index=1.1.1.1.1.1.1.1.1.1.1.1.1.1.1.1.1.1.1.1.1.1",
            "Referred-By: " + "<" * 200,
            "Remote-Party-ID: \"\x01\x02ctl\" <sip:\x7f@x>;privacy=",
            "Privacy: " + ";".join(["id"] * 50),
        ]
        mb = b.mark()
        sock = self.raw_invite(port, lines, call_id="raw-hostile-1")
        inc = b.wait_event("call.incoming", 10, mb)
        self.assertIsNotNone(inc, "hostile INVITE not delivered; stderr=%s" % "".join(b.stderr[-5:]))
        self.assertLessEqual(len(inc["diversion"]), 8)
        for d in inc["diversion"]:
            self.assertLessEqual(len(d["uri"]), 199)
            self.assertLessEqual(len(d["reason"]), 39)
            self.assertGreaterEqual(d["counter"], 1)
            self.assertLessEqual(d["counter"], 999)
        ai = inc["assertedIdentity"]
        if ai:
            self.assertLessEqual(len(ai["display"]), 95)
            self.assertLessEqual(len(ai["uri"]), 199)
        self.assertLessEqual(len(inc["referredBy"] or ""), 199)
        b.req("call.reject", {"cid": inc["cid"], "code": 603})
        sock.close()
        # still healthy
        b.req("core.ping")


    # ---- liveness regressions: malformed History-Info index values used to spin the pjsua thread forever ----
    def core_port(self, b):
        self._rejected = set()
        rb = b.start_core()
        return [t for t in rb["transports"] if t["type"] == "udp"][0]["local"].split(":")[1]

    def assert_alive(self, b, port, tag):
        """core.ping alone is answered by the request worker even when the pjsua thread is wedged, so also push a
        canary INVITE through the pjsua thread: call.incoming must still be delivered (timeout based)."""
        t0 = time.time()
        try:
            b.req("core.ping", timeout=2)
        except TimeoutError:
            self.fail("engine did not answer core.ping within 2 s after %s" % tag)
        self.assertLess(time.time() - t0, 2.0)
        mb = b.mark()
        self._canary = getattr(self, "_canary", 0) + 1
        sock = self.raw_invite(port, ["X-Canary: 1"], call_id="canary-%s-%d" % (abs(hash(tag)) % 100000, self._canary))
        inc = b.wait_event("call.incoming", 5, mb)
        if inc is None:
            try:
                ncalls = "%s incoming-events=%d list=%s" % ("", len(b.events("call.incoming")), [(c["cid"], c["state"], c.get("lastCode")) for c in b.req("call.list", timeout=3)["calls"]])
            except Exception as ex:
                ncalls = "call.list failed: %s" % ex
            self.fail("no call.incoming for canary INVITE after %s (calls=%s) lastrejerr=%s; stderr=%s" % (tag, ncalls, getattr(self, '_rej_err', None), "".join(b.stderr[-8:])))
        b.req("call.reject", {"cid": inc["cid"], "code": 603}, timeout=5)
        self.ack_finals(sock, port)
        sock.close()

    def ack_finals(self, sock, port):
        """ACK every final response (>= 300) to our INVITE so the engine's server transaction ends and the call slot
        is freed; without it the slots stay busy for the 32 s transaction timeout (PJSUA_MAX_CALLS is 32)."""
        sock.settimeout(0.05)
        try:
            while True:
                data, _ = sock.recvfrom(65535)
                txt = data.decode("latin1", "replace")
                lines = txt.split("\r\n")
                m = lines[0].split(" ")
                if len(m) < 2 or not m[1].isdigit() or int(m[1]) < 300:
                    continue
                h = {}
                for ln in lines[1:]:
                    if ":" in ln:
                        k, v = ln.split(":", 1)
                        h.setdefault(k.strip().lower(), v.strip())
                if not all(k in h for k in ("via", "from", "to", "call-id", "cseq")):
                    continue
                ack = ("ACK sip:test@127.0.0.1:%s SIP/2.0\r\nVia: %s\r\nMax-Forwards: 70\r\nFrom: %s\r\nTo: %s\r\n"
                       "Call-ID: %s\r\nCSeq: %s ACK\r\nContent-Length: 0\r\n\r\n") % (
                    port, h["via"], h["from"], h["to"], h["call-id"], h["cseq"].split()[0])
                sock.sendto(ack.encode(), ("127.0.0.1", int(port)))
        except (socket.timeout, OSError):
            pass

    def reject_all_incoming(self, b):
        for e in b.events("call.incoming"):
            if e["cid"] in self._rejected:
                continue
            try:
                b.req("call.reject", {"cid": e["cid"], "code": 603}, timeout=5)
                self._rejected.add(e["cid"])
            except RpcError as ex:
                self._rejected.add(e["cid"])
                self._rej_err = str(ex)

    def test_raw_history_info_malformed_index_no_hang(self):
        b = self.cli("B")
        port = self.core_port(b)
        long_dotted = ".".join(str(i % 10) for i in range(300))
        cases = [
            ["<sip:a@x.example>;index=a", "<sip:b@x.example>;index=b"],
            ["<sip:a@x.example>;index=1.a", "<sip:b@x.example>;index=1.b"],
            ["<sip:a@x.example>;index=-", "<sip:b@x.example>;index=-"],
            ["<sip:a@x.example>;index=..", "<sip:b@x.example>;index=.."],
            ["<sip:a@x.example>;index=1..2", "<sip:b@x.example>;index=1..2", "<sip:c@x.example>;index=1...3"],
            ["<sip:a@x.example>;index=%s" % long_dotted, "<sip:b@x.example>;index=%s.1" % long_dotted],
            ["<sip:a@x.example>;index=1.2.x", "<sip:b@x.example>;index=1.2", "<sip:c@x.example>;index=zz",
             "<sip:d@x.example>;index=1.1.1", "<sip:e@x.example>;index=+1", "<sip:f@x.example>;index=0x10",
             "<sip:g@x.example>;index=1e5", "<sip:h@x.example>;index=\"a\""],
            ["<sip:a@x.example>;index=a", "<sip:b@x.example>;index=1", "<sip:c@x.example>;index=b", "<sip:d@x.example>;index=2"],
        ]
        for n, entries in enumerate(cases):
            # as one comma separated header and as separate header lines
            for style in ("single", "multi"):
                lines = ["History-Info: " + ", ".join(entries)] if style == "single" else ["History-Info: " + e for e in entries]
                sock = self.raw_invite(port, lines, call_id="hi-malformed-%d-%s" % (n, style))
                self.assert_alive(b, port, "History-Info case %d (%s): %s" % (n, style, entries[0][:40]))
                self.reject_all_incoming(b)
                time.sleep(0.2)
                self.ack_finals(sock, port)
                sock.close()

    def test_raw_history_info_valid_order_survives_sanitising(self):
        b = self.cli("B")
        port = self.core_port(b)
        mb = b.mark()
        sock = self.raw_invite(port, ["History-Info: <sip:c@x.example>;index=1.1.1, <sip:a@x.example>;index=1, "
                                      "<sip:b@x.example>;index=1.1"], call_id="hi-valid-1")
        inc = b.wait_event("call.incoming", 10, mb)
        self.assertIsNotNone(inc)
        self.assertEqual([d["user"] for d in inc["diversion"]], ["a", "b"])
        b.req("call.reject", {"cid": inc["cid"], "code": 603})
        sock.close()

    def test_raw_identity_fuzz_liveness(self):
        import random
        rnd = random.Random(0x5EC0DE)
        b = self.cli("B")
        port = self.core_port(b)
        alphabet = list("ab01.-_;,<>\"'=:@ \t%+xyz()[]\\/?&#") + ["index=", ";reason=", ";counter=", "sip:", "tel:", "<sip:", ">;",
                                                                    "cause%3D", "cause=", "privacy=", "Reason=SIP%3Bcause%3D", "1.1.", "..", ";index="]

        def garbage(maxlen):
            return "".join(rnd.choice(alphabet) for _ in range(rnd.randint(0, maxlen)))

        def hi_entry():
            idx = rnd.choice(["", "a", "b", "1.a", "-", "..", "1..2", "%d" % rnd.randint(0, 9), "1.%d" % rnd.randint(0, 9),
                              "1.%d.%d" % (rnd.randint(0, 3), rnd.randint(0, 3)), garbage(12)])
            return "<sip:u%d@h%d.example%s>;index=%s%s" % (rnd.randint(0, 9), rnd.randint(0, 3),
                                                       rnd.choice(["", "?Reason=SIP%3Bcause%3D486", "?" + garbage(10)]), idx, rnd.choice(["", ";" + garbage(8)]))

        total = 0
        for batch in range(30):
            socks = []
            for k in range(10):
                lines = []
                for _ in range(rnd.randint(1, 5)):
                    kind = rnd.choice(["History-Info", "Diversion", "P-Asserted-Identity", "Remote-Party-ID", "Referred-By", "Privacy"])
                    if kind == "History-Info":
                        val = ", ".join(hi_entry() for _ in range(rnd.randint(1, 12)))
                    elif rnd.random() < 0.5:
                        val = garbage(200)
                    else:
                        val = ", ".join("%s<sip:%s@x.example>%s" % (rnd.choice(["", "\"N\" ", garbage(5)]), garbage(6), rnd.choice(["", ";reason=" + garbage(5), ";counter=" + garbage(4)]))
                                        for _ in range(rnd.randint(1, 6)))
                    lines.append("%s: %s" % (kind, val.replace("\r", " ").replace("\n", " ")))
                socks.append(self.raw_invite(port, lines, call_id="fuzz-%d-%d" % (batch, k)))
                total += 1
            self.assert_alive(b, port, "fuzz batch %d" % batch)
            self.reject_all_incoming(b)
            for wait in (0.2, 0.7):                     # second pass catches 603 retransmissions (T1 = 500 ms)
                time.sleep(wait)
                for sk in socks:
                    self.ack_finals(sk, port)
            for sk in socks:
                sk.close()
        self.assertEqual(total, 300)


if __name__ == "__main__":
    unittest.main()
