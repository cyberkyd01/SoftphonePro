"""Polish batch D: secureSignaling semantics, dscp.sip, TLS start failures, TLS global reset."""
import os
import sys
import unittest

from run_tests import Base, RpcError, PBX, CA, TMP
from test_ws import add_ws, WSS_PORT


class TestSecureSignaling(Base):
    def _call(self, transport, ws=False, ext=1001, **kw):
        c = self.cli("A")   # (the PBX only offers SDES on wss, so SRTP cases use wss)
        c.start_core(transports={"tls": {"port": 0, "verifyServer": True, "caFile": CA}} if ws else {})
        if ws:
            extra = {"domain": "localhost", "registrar": "sip:localhost:%d" % WSS_PORT} if transport == "wss" else {}
            extra.update(kw)
            _, uid = add_ws(c, ext, transport, **extra)
        else:
            _, uid = c.add_account(1001, transport=transport, **kw)
        cid = c.req("call.make", {"uid": uid, "uri": "600"})["cid"]
        self.assertIsNotNone(c.wait_event("call.state", 15, 0, cid=cid, state="confirmed"))
        ev = self.wait_media(c, cid)
        st = [e for e in c.events("call.state") if e["cid"] == cid and e["state"] == "confirmed"][-1]
        info = c.req("call.info", {"cid": cid})
        c.req("call.hangup", {"cid": cid})
        return ev, st, info

    def test_udp_false(self):
        ev, st, info = self._call("udp")
        for o in (ev, st, info):
            self.assertFalse(o["secureSignaling"], o)
        self.assertFalse(info["srtp"])

    def test_tls_true_without_srtp(self):
        ev, st, info = self._call("tls")
        for o in (ev, st, info):
            self.assertTrue(o["secureSignaling"], o)
        self.assertFalse(info["srtp"])      # signalling security is independent of SRTP

    def test_wss_true(self):
        ev, st, info = self._call("wss", ws=True)
        for o in (ev, st, info):
            self.assertTrue(o["secureSignaling"], o)


class TestDscp(Base):
    def _tos(self, c):
        return [t for t in c.req("core.getSipTos")["transports"] if t["type"].upper() == "UDP"]

    @unittest.skipIf(sys.platform.startswith("win"), "IP_TOS not inspectable")
    def test_dscp_sip_shared_and_own_transport(self):
        c = self.cli()
        c.start_core(transports={"dscpSip": 26})
        udp = self._tos(c)
        self.assertTrue(udp and udp[0]["dscp"] == 26, udp)
        # shared UDP transport follows the account's dscp.sip
        c.add_account(1010, dscp={"sip": 34})
        self.assertEqual(self._tos(c)[0]["dscp"], 34, self._tos(c))
        # an account with its own transport owns its socket
        cfg = c.acct(1011, localPort=0, dscp={"sip": 10})
        c.req("account.add", dict(cfg, uid="own", localPort=55061))
        own = [t for t in self._tos(c) if t["port"] == 55061]
        self.assertTrue(own and own[0]["dscp"] == 10, self._tos(c))
        c.req("account.modify", {"uid": "own", "dscp": {"sip": 18}})
        own = [t for t in self._tos(c) if t["port"] == 55061]
        self.assertEqual(own[0]["dscp"], 18, self._tos(c))

    def test_dscp_validation_and_qos_off(self):
        c = self.cli()
        c.start_core()
        r = c.raw("account.add", c.acct(1010, dscp={"sip": 64}))
        self.assertEqual(r["error"]["code"], "INVALID_PARAM")
        r = c.raw("account.add", c.acct(1010, dscp={"sip": 0}))
        self.assertTrue(r["ok"], r)
        c2 = self.cli("c2")
        self.assertEqual(c2.raw("core.start", {"transports": {"dscpSip": 99}, "media": {"noAudioDevice": True}})["error"]["code"], "INVALID_PARAM")


class TestTlsStart(Base):
    def test_bad_cert_fails_start(self):
        c = self.cli()
        r = c.raw("core.start", {"media": {"noAudioDevice": True}, "stunServers": [],
                                 "transports": {"udp": {"port": 0}, "tls": {"port": 0, "certFile": "/nonexistent/cert.pem", "keyFile": "/nonexistent/key.pem"}}})
        self.assertFalse(r["ok"], r)
        self.assertEqual(r["error"]["code"], "PJ_ERROR")
        self.assertIn("/nonexistent/cert.pem", r["error"]["message"])
        self.assertIn("TLS", r["error"]["message"])
        # a failed start leaves the engine startable
        c.start_core()
        self.assertTrue(c.req("core.info"))

    def test_bad_cert_optional_continues(self):
        c = self.cli()
        r = c.raw("core.start", {"media": {"noAudioDevice": True}, "stunServers": [],
                                 "transports": {"udp": {"port": 0}, "tls": {"port": 0, "optional": True, "certFile": "/nonexistent/cert.pem", "keyFile": "/nonexistent/key.pem"}}})
        self.assertTrue(r["ok"], r)
        c.started = True
        self.assertFalse(any(t["type"] == "tls" for t in r["result"]["transports"]), r)

    def test_tls_globals_reset_between_starts(self):
        c = self.cli()
        c.start_core(transports={"tls": {"port": 0, "verifyServer": True, "caFile": CA}})
        c.req("core.stop")
        c.started = False
        # second start without a tls object: verification must be off again
        r = c.raw("core.start", {"media": {"noAudioDevice": True}, "stunServers": [], "transports": {"udp": {"port": 0}, "tcp": {"port": 0}}})
        self.assertTrue(r["ok"], r)
        c.started = True
        _, uid = c.add_account(1010, transport="tls", domain=PBX)   # would fail verification (IP vs cert) if verify leaked
        self.assertEqual(c.req("account.info", {"uid": uid})["regState"], "registered")
        self.assertEqual(c.events("transport.tlsVerify"), [])


class TestSecureSignalingSrtp(TestSecureSignaling):
    test_udp_false = test_tls_true_without_srtp = test_wss_true = None
    def test_wss_with_srtp(self):
        ev, st, info = self._call("wss", ws=True, ext=1011, srtp="mandatory")
        self.assertTrue(info["secureSignaling"])
        self.assertTrue(info["srtp"])
