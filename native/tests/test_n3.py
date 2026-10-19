"""N3: per-account TLS client certificates (mutual TLS), transport:"auto" (SRV), sips: URIs.

PBX: TLS 5061 (no client cert), mTLS 5062 (client cert from the test CA required; certs/client.crt, client.key,
client-enc.key with password "secret"). SRV tests use the stdlib DNS stub in dns_stub.py (core.start nameservers
["127.0.0.1:<port>"]); the zone name pbx.test is covered by the PBX certificate's SAN.
"""
import os
import socket
import ssl
import subprocess
import tempfile
import threading
import time
import unittest

from run_tests import Base, RpcError, PBX, CA, CONTAINER, ROOT, TMP
from dns_stub import StubDns

CERTS = os.path.join(ROOT, "tests", "sipserver", "certs")
CCERT = os.path.join(CERTS, "client.crt")
CKEY = os.path.join(CERTS, "client.key")
CKEY_ENC = os.path.join(CERTS, "client-enc.key")
MTLS_PORT = 5062
HAVE_CERTS = all(os.path.exists(f) for f in (CCERT, CKEY, CKEY_ENC))


def tls_start(verify=True, **extra):
    t = {"port": 0, "verifyServer": verify}
    if verify:
        t["caFile"] = CA
    d = {"transports": {"tls": t}}
    d.update(extra)
    return d


def mtls_acct(c, ext=1019, **kw):
    cfg = c.acct(ext, uid="m%s" % ext, transport="tls", registrar="sip:%s:%d" % (PBX, MTLS_PORT))
    cfg.update(kw)
    return cfg


def n_tls_transports(c):
    return len([t for t in c.req("core.getSipTos")["transports"] if t["type"].upper() == "TLS"])


@unittest.skipUnless(HAVE_CERTS, "tests/sipserver/certs/client.* missing (run tests/sipserver/scripts/up.sh)")
class TestClientCert(Base):
    def _wait_reg(self, c, uid, state, mark, timeout=15):
        return c.wait_event("account.reg", timeout, mark, uid=uid, regState=state)

    def test_mtls_register_with_cert(self):
        c = self.cli()
        c.start_core(**tls_start())
        base = n_tls_transports(c)
        cfg = mtls_acct(c, tlsClientCert={"certFile": CCERT, "keyFile": CKEY})
        mark = c.mark()
        c.req("account.add", cfg)
        self.assertIsNotNone(self._wait_reg(c, cfg["uid"], "registered", mark), c.events("account.reg")[-2:])
        info = c.req("account.info", {"uid": cfg["uid"]})
        self.assertEqual(info["transport"], "tls")
        self.assertEqual(info["regCode"], 200)
        self.assertEqual(n_tls_transports(c), base + 1)          # dedicated transport
        # the remote end is the mTLS port, and the connection came from the dedicated (random) local port
        st = [e for e in c.events("transport.state") if e["state"] == "connected" and e["remote"].endswith(":%d" % MTLS_PORT)]
        self.assertTrue(st, c.events("transport.state"))
        # a call over the account works (mutual TLS carries media setup)
        cid = c.req("call.make", {"uid": cfg["uid"], "uri": "600"})["cid"]
        self.assertIsNotNone(c.wait_event("call.state", 15, 0, cid=cid, state="confirmed"))
        c.req("call.hangup", {"cid": cid})
        # remove: the dedicated transport goes away
        c.req("account.remove", {"uid": cfg["uid"]})
        self.assertEqual(n_tls_transports(c), base)

    def test_mtls_without_cert_fails_clearly(self):
        c = self.cli()
        c.start_core(**tls_start())
        cfg = mtls_acct(c, regRetrySec=0, regFirstRetrySec=0)
        mark = c.mark()
        c.req("account.add", cfg)
        ev = self._wait_reg(c, cfg["uid"], "failed", mark, 15)
        self.assertIsNotNone(ev, c.events("account.reg")[-3:])
        self.assertTrue(ev["lastError"], ev)
        self.assertIsNone(self._wait_reg(c, cfg["uid"], "registered", mark, 1))
        self.assertIn("client certificate", ev["lastError"].lower() + " " + ev["lastError"].lower())
        # the same account with a certificate registers (account.modify attaches it and re-creates the transport)
        mark = c.mark()
        c.req("account.modify", {"uid": cfg["uid"], "tlsClientCert": {"certFile": CCERT, "keyFile": CKEY}})
        self.assertIsNotNone(self._wait_reg(c, cfg["uid"], "registered", mark), c.events("account.reg")[-3:])

    def test_mtls_encrypted_key_and_modify_cleanup(self):
        c = self.cli()
        c.start_core(**tls_start())
        base = n_tls_transports(c)
        cfg = mtls_acct(c, tlsClientCert={"certFile": CCERT, "keyFile": CKEY_ENC, "password": "secret"})
        mark = c.mark()
        c.req("account.add", cfg)
        self.assertIsNotNone(self._wait_reg(c, cfg["uid"], "registered", mark), c.events("account.reg")[-2:])
        self.assertEqual(n_tls_transports(c), base + 1)
        # modify to the plain TLS port without a certificate: dedicated transport is closed
        mark = c.mark()
        c.req("account.modify", {"uid": cfg["uid"], "tlsClientCert": None, "registrar": "sip:%s:5061" % PBX})
        self.assertIsNotNone(self._wait_reg(c, cfg["uid"], "registered", mark), c.events("account.reg")[-3:])
        self.assertEqual(n_tls_transports(c), base)

    def test_validation(self):
        c = self.cli()
        c.start_core(**tls_start())
        other = os.path.join(TMP, "other.key")
        subprocess.run(["openssl", "genrsa", "-out", other, "2048"], check=True, capture_output=True)
        junk = os.path.join(TMP, "junk.pem")
        with open(junk, "w") as f:
            f.write("not a pem\n")

        def bad(cc, needle, **kw):
            cfg = mtls_acct(c, tlsClientCert=cc, **kw)
            r = c.raw("account.add", cfg)
            self.assertFalse(r["ok"], r)
            self.assertEqual(r["error"]["code"], "INVALID_PARAM", r)
            self.assertIn(needle, r["error"]["message"], r)
            return r
        bad({"certFile": "/nonexistent/c.crt", "keyFile": CKEY}, "not readable")
        bad({"certFile": CCERT, "keyFile": "/nonexistent/k.key"}, "not readable")
        bad({"certFile": CCERT, "keyFile": other}, "does not match")
        bad({"certFile": junk, "keyFile": CKEY}, "valid PEM certificate")
        bad({"certFile": CCERT, "keyFile": CKEY_ENC}, "cannot be decrypted")
        bad({"certFile": CCERT, "keyFile": CKEY_ENC, "password": "wrong"}, "cannot be decrypted")
        bad({"certFile": CCERT}, "keyFile")
        bad("nope", "must be an object")
        bad({"certFile": CCERT, "keyFile": CKEY}, "needs transport", transport="udp")
        # modify validates too and leaves the account alone
        cfg = mtls_acct(c, tlsClientCert={"certFile": CCERT, "keyFile": CKEY})
        mark = c.mark()
        c.req("account.add", cfg)
        self.assertIsNotNone(self._wait_reg(c, cfg["uid"], "registered", mark))
        r = c.raw("account.modify", {"uid": cfg["uid"], "tlsClientCert": {"certFile": CCERT, "keyFile": other}})
        self.assertFalse(r["ok"])
        self.assertEqual(r["error"]["code"], "INVALID_PARAM")
        self.assertEqual(c.req("account.info", {"uid": cfg["uid"]})["regState"], "registered")

    def test_wss_presents_client_cert(self):
        """wss: the certificate is presented on the WebSocket's TLS connection (own TLS server requiring it)."""
        keyf = os.path.join(TMP, "srv.key")
        crtf = os.path.join(TMP, "srv.crt")
        for name, dst in (("asterisk.key", keyf), ("asterisk.crt", crtf)):
            r = subprocess.run(["docker", "exec", CONTAINER, "cat", "/etc/asterisk/keys/" + name], capture_output=True, text=True)
            if r.returncode != 0 or not r.stdout:
                self.skipTest("cannot read PBX server certificate")
            with open(dst, "w") as f:
                f.write(r.stdout)
        ctx = ssl.SSLContext(ssl.PROTOCOL_TLS_SERVER)
        ctx.load_cert_chain(crtf, keyf)
        ctx.verify_mode = ssl.CERT_REQUIRED
        ctx.load_verify_locations(CA)
        ls = socket.socket()
        ls.bind(("127.0.0.1", 0))
        ls.listen(2)
        ls.settimeout(15)
        port = ls.getsockname()[1]
        seen = {}

        def serve():
            try:
                s, _ = ls.accept()
                s.settimeout(5)
                try:
                    t = ctx.wrap_socket(s, server_side=True)
                    seen["subject"] = t.getpeercert()["subject"]
                    t.recv(100)
                    t.close()
                except Exception as e:      # noqa
                    seen["error"] = repr(e)
            except Exception as e:           # noqa
                seen["error"] = repr(e)
        th = threading.Thread(target=serve, daemon=True)
        th.start()
        c = self.cli()
        c.start_core(**tls_start())
        cfg = c.acct(1019, uid="w1019", transport="wss", domain="localhost", registrar="sip:localhost:%d" % port,
                     tlsClientCert={"certFile": CCERT, "keyFile": CKEY}, regRetrySec=0, regFirstRetrySec=0)
        c.req("account.add", cfg)
        th.join(12)
        ls.close()
        self.assertIn("subject", seen, seen)
        self.assertIn("spcore-test-client", str(seen["subject"]))
        c.req("account.remove", {"uid": "w1019"})

    def test_wss_without_cert_is_refused_by_cert_requiring_server(self):
        """control for the previous test: no tlsClientCert -> the same server sees no certificate"""
        keyf = os.path.join(TMP, "srv.key")
        crtf = os.path.join(TMP, "srv.crt")
        if not (os.path.exists(keyf) and os.path.exists(crtf)):
            self.skipTest("server cert not available")
        ctx = ssl.SSLContext(ssl.PROTOCOL_TLS_SERVER)
        ctx.load_cert_chain(crtf, keyf)
        ctx.verify_mode = ssl.CERT_REQUIRED
        ctx.load_verify_locations(CA)
        ls = socket.socket()
        ls.bind(("127.0.0.1", 0))
        ls.listen(2)
        ls.settimeout(15)
        port = ls.getsockname()[1]
        seen = {}

        def serve():
            try:
                s, _ = ls.accept()
                s.settimeout(5)
                try:
                    t = ctx.wrap_socket(s, server_side=True)
                    seen["subject"] = t.getpeercert()
                except Exception as e:      # noqa
                    seen["error"] = repr(e)
            except Exception as e:           # noqa
                seen["error"] = repr(e)
        th = threading.Thread(target=serve, daemon=True)
        th.start()
        c = self.cli()
        c.start_core(**tls_start())
        c.req("account.add", c.acct(1019, uid="w1019", transport="wss", domain="localhost", registrar="sip:localhost:%d" % port,
                                    regRetrySec=0, regFirstRetrySec=0))
        th.join(12)
        ls.close()
        self.assertIn("error", seen, seen)
        c.req("account.remove", {"uid": "w1019"})


class TestAutoTransport(Base):
    ZONE_A = {"pbx.test": [("A", "127.0.0.1")], "a.pbx.test": [("A", "127.0.0.1")], "b.pbx.test": [("A", "127.0.0.1")],
              "dead.pbx.test": [("A", "127.0.0.1")]}

    def setUp(self):
        super().setUp()
        self.dns = None

    def tearDown(self):
        try:
            super().tearDown()
        finally:
            if self.dns:
                self.dns.close()

    def zone(self):
        return dict(self.ZONE_A)

    def start(self, records, verify=True, **extra):
        self.dns = StubDns(records)
        c = self.cli()
        c.start_core(nameservers=["127.0.0.1:%d" % self.dns.port], **tls_start(verify, **extra))
        return c

    def add_auto(self, c, ext=1020, wait="registered", **kw):
        cfg = c.acct(ext, uid="auto%s" % ext, domain="pbx.test", transport="auto", **kw)
        mark = c.mark()
        t0 = time.time()
        c.req("account.add", cfg)
        dt = time.time() - t0
        self.assertLess(dt, 1.5, "account.add blocked for %.1fs" % dt)
        if wait:
            ev = c.wait_event("account.reg", 20, mark, uid=cfg["uid"], regState=wait)
            self.assertIsNotNone(ev, c.events("account.reg")[-3:])
        return cfg["uid"]

    def test_sips_srv_selects_tls(self):
        c = self.start(self.zone() | {"_sips._tcp.pbx.test": [("SRV", 10, 5, 5061, "pbx.test")],
                                          "_sip._tcp.pbx.test": [("SRV", 10, 5, 5060, "pbx.test")],
                                          "_sip._udp.pbx.test": [("SRV", 10, 5, 5060, "pbx.test")]})
        uid = self.add_auto(c)
        info = c.req("account.info", {"uid": uid})
        self.assertEqual(info["transport"], "tls", info)
        self.assertEqual(info["resolvedServer"], "pbx.test:5061", info)
        st = [e for e in c.events("transport.state") if e["state"] == "connected" and e["transport"] == "tls"]
        self.assertTrue(st)
        self.assertEqual(st[0]["tls"]["verifyStatus"], [])     # CA verification with SAN pbx.test
        # calls go over the resolved transport
        cid = c.req("call.make", {"uid": uid, "uri": "600"})["cid"]
        self.assertIsNotNone(c.wait_event("call.state", 15, 0, cid=cid, state="confirmed"))
        self.assertTrue(c.req("call.info", {"cid": cid})["secureSignaling"])
        c.req("call.hangup", {"cid": cid})

    def test_priority_and_weight(self):
        c = self.start(self.zone() | {"_sips._tcp.pbx.test": [("SRV", 20, 100, 5099, "dead.pbx.test"),
                                                              ("SRV", 10, 1, 5061, "a.pbx.test"),
                                                              ("SRV", 10, 60, 5061, "b.pbx.test")]})
        uid = self.add_auto(c)
        info = c.req("account.info", {"uid": uid})
        self.assertEqual((info["transport"], info["resolvedServer"]), ("tls", "b.pbx.test:5061"), info)

    def test_tcp_beats_udp(self):
        c = self.start(self.zone() | {"_sip._tcp.pbx.test": [("SRV", 10, 5, 5060, "pbx.test")],
                                      "_sip._udp.pbx.test": [("SRV", 10, 5, 5060, "a.pbx.test")]})
        uid = self.add_auto(c)
        info = c.req("account.info", {"uid": uid})
        self.assertEqual((info["transport"], info["resolvedServer"]), ("tcp", "pbx.test:5060"), info)
        self.assertTrue([e for e in c.events("transport.state") if e["state"] == "connected" and e["transport"] == "tcp"])

    def test_only_udp_srv(self):
        c = self.start(self.zone() | {"_sip._udp.pbx.test": [("SRV", 10, 5, 5060, "a.pbx.test")]})
        uid = self.add_auto(c)
        info = c.req("account.info", {"uid": uid})
        self.assertEqual((info["transport"], info["resolvedServer"]), ("udp", "a.pbx.test:5060"), info)

    def test_no_srv_falls_back_to_udp(self):
        c = self.start(self.zone())
        uid = self.add_auto(c)
        info = c.req("account.info", {"uid": uid})
        self.assertEqual((info["transport"], info["resolvedServer"]), ("udp", "pbx.test:5060"), info)

    def test_no_resolver_falls_back_to_udp(self):
        c = self.cli()
        c.start_core(nameservers=[])
        cfg = c.acct(1020, uid="autoL", domain="localhost", transport="auto")
        mark = c.mark()
        c.req("account.add", cfg)
        self.assertIsNotNone(c.wait_event("account.reg", 15, mark, uid="autoL", regState="registered"))
        info = c.req("account.info", {"uid": "autoL"})
        self.assertEqual((info["transport"], info["resolvedServer"]), ("udp", "localhost:5060"), info)

    def test_dead_dns_does_not_block(self):
        self.dns = StubDns(self.zone(), drop=True)
        c = self.cli()
        c.start_core(nameservers=["127.0.0.1:%d" % self.dns.port], **tls_start())
        cfg = c.acct(1020, uid="autoD", domain="pbx.test", transport="auto", regRetrySec=0, regFirstRetrySec=0)
        t0 = time.time()
        c.req("account.add", cfg)
        self.assertLess(time.time() - t0, 1.5)
        t0 = time.time()
        c.req("core.ping") if False else c.req("account.list")
        self.assertLess(time.time() - t0, 1.0)          # worker stays responsive during the lookup
        info = c.req("account.info", {"uid": "autoD"})
        self.assertEqual(info["transport"], "auto", info)
        self.assertIsNone(info["resolvedServer"])
        ok = self.poll(lambda: c.req("account.info", {"uid": "autoD"})["transport"] == "udp", 12)
        self.assertTrue(ok)
        info = c.req("account.info", {"uid": "autoD"})
        self.assertEqual(info["resolvedServer"], "pbx.test:5060", info)

    def test_handle_ip_change_reresolves_and_modify(self):
        # (the resolver caches answers for their TTL, negative answers for 60 s: the stub uses TTL 1 and the zone
        # change removes a cached positive record)
        self.dns = StubDns(self.zone() | {"_sips._tcp.pbx.test": [("SRV", 10, 5, 5061, "pbx.test")],
                                          "_sip._udp.pbx.test": [("SRV", 10, 5, 5060, "pbx.test")]}, ttl=1)
        c = self.cli()
        c.start_core(nameservers=["127.0.0.1:%d" % self.dns.port], **tls_start())
        uid = self.add_auto(c)
        info = c.req("account.info", {"uid": uid})
        self.assertEqual((info["transport"], info["resolvedServer"]), ("tls", "pbx.test:5061"), info)
        # the zone changes (e.g. new network, new DNS view): TLS is no longer offered
        self.dns.set(self.zone() | {"_sip._udp.pbx.test": [("SRV", 10, 5, 5060, "a.pbx.test")]})
        time.sleep(1.5)
        mark = c.mark()
        c.req("core.handleIpChange")
        ok = self.poll(lambda: c.req("account.info", {"uid": uid})["transport"] == "udp", 15)
        self.assertTrue(ok, c.req("account.info", {"uid": uid}))
        self.assertIsNotNone(c.wait_event("account.reg", 15, mark, uid=uid, regState="registered"))
        info = c.req("account.info", {"uid": uid})
        self.assertEqual(info["resolvedServer"], "a.pbx.test:5060")
        # modify to a fixed transport clears resolvedServer; back to auto resolves again
        c.req("account.modify", {"uid": uid, "transport": "tcp"})
        info = c.req("account.info", {"uid": uid})
        self.assertEqual((info["transport"], info["resolvedServer"]), ("tcp", None), info)
        c.req("account.modify", {"uid": uid, "transport": "auto"})
        ok = self.poll(lambda: c.req("account.info", {"uid": uid})["resolvedServer"], 10)
        self.assertEqual(ok, "a.pbx.test:5060")

    def test_register_false_defers_registration(self):
        c = self.start(self.zone() | {"_sips._tcp.pbx.test": [("SRV", 10, 5, 5061, "pbx.test")]})
        uid = self.add_auto(c, wait=None, register=False)
        ok = self.poll(lambda: c.req("account.info", {"uid": uid})["transport"] == "tls", 10)
        self.assertTrue(ok)
        time.sleep(1)
        info = c.req("account.info", {"uid": uid})
        self.assertEqual(info["regState"], "none", info)
        mark = c.mark()
        c.req("account.register", {"uid": uid, "register": True})
        self.assertIsNotNone(c.wait_event("account.reg", 15, mark, uid=uid, regState="registered"))

    def test_auto_with_client_cert(self):
        if not HAVE_CERTS:
            self.skipTest("client certs missing")
        c = self.start(self.zone() | {"_sips._tcp.pbx.test": [("SRV", 10, 5, MTLS_PORT, "pbx.test")]})
        uid = self.add_auto(c, tlsClientCert={"certFile": CCERT, "keyFile": CKEY})
        info = c.req("account.info", {"uid": uid})
        self.assertEqual((info["transport"], info["resolvedServer"]), ("tls", "pbx.test:%d" % MTLS_PORT), info)

    def test_account_removed_during_lookup(self):
        self.dns = StubDns(self.zone() | {"_sip._udp.pbx.test": [("SRV", 10, 5, 5060, "pbx.test")]}, drop=True)
        c = self.cli()
        c.start_core(nameservers=["127.0.0.1:%d" % self.dns.port], **tls_start())
        cfg = c.acct(1020, uid="autoR", domain="pbx.test", transport="auto")
        c.req("account.add", cfg)
        c.req("account.remove", {"uid": "autoR"})
        time.sleep(5.5)                                 # lookup timeout passes with no account left
        self.assertEqual([a for a in c.req("account.list")["accounts"] if a["uid"] == "autoR"], [])


class TestSips(Base):
    def test_sips_on_tls_account(self):
        c = self.cli()
        c.start_core(**tls_start())
        _, uid = c.add_account(1020, transport="tls")
        cid = c.req("call.make", {"uid": uid, "uri": "sips:600@%s" % PBX})["cid"]
        self.assertIsNotNone(c.wait_event("call.state", 15, 0, cid=cid, state="confirmed"))
        info = c.req("call.info", {"cid": cid})
        self.assertTrue(info["secureSignaling"], info)
        c.req("call.hangup", {"cid": cid})

    def test_sips_rejected_on_non_tls_accounts(self):
        c = self.cli()
        c.start_core(**tls_start())
        for tr in ("udp", "tcp"):
            _, uid = c.add_account(1020, uid="s%s" % tr, transport=tr)
            r = c.raw("call.make", {"uid": uid, "uri": "sips:600@%s" % PBX})
            self.assertFalse(r["ok"], r)
            self.assertEqual(r["error"]["code"], "INVALID_PARAM")
            self.assertIn("sips:", r["error"]["message"])
            self.assertIn(tr, r["error"]["message"])
            # sip: still works
            cid = c.req("call.make", {"uid": uid, "uri": "600"})["cid"]
            self.assertIsNotNone(c.wait_event("call.state", 15, 0, cid=cid, state="confirmed"))
            c.req("call.hangup", {"cid": cid})
            c.req("account.remove", {"uid": uid})


if __name__ == "__main__":
    import sys
    sys.modules.setdefault("run_tests", sys.modules.get("run_tests"))
    unittest.main(verbosity=2)
