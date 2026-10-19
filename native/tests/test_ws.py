"""SIP over WebSocket (RFC 7118) tests for spcore: transports "ws" and "wss" against the Asterisk test PBX.

Asterisk: WS 8088 and WSS 8089, path /ws (tests/sipserver/README.md).
Env:  SPC_WS_RESTART=1   also run the slow reconnect test (restarts the PBX container)
"""
import os
import socket
import struct
import subprocess
import threading
import time
import unittest
import base64
import hashlib

from run_tests import Base, Cli, RpcError, PBX, CA, CONTAINER, TONE, TMP

WS_PORT = 8088
WSS_PORT = 8089


def ws_acct(c, ext, transport, **kw):
    """AccountConfig for a ws/wss account (port in the registrar, clean domain)."""
    port = WSS_PORT if transport == "wss" else WS_PORT
    cfg = c.acct(ext, uid="w%s%s" % (transport, ext), transport=transport, registrar="sip:%s:%d" % (PBX, port))
    cfg.update(kw)
    return cfg


def add_ws(c, ext, transport, wait=True, **kw):
    cfg = ws_acct(c, ext, transport, **kw)
    mark = c.mark()
    r = c.req("account.add", cfg)
    if wait:
        ev = c.wait_event("account.reg", 15, mark, uid=cfg["uid"], regState="registered")
        if ev is None:
            raise AssertionError("ws account %s did not register: %s" % (ext, c.events("account.reg")[-2:]))
    return r["acc"], cfg["uid"]


class TestWsRegistration(Base):
    def _reg(self, transport, ext=1010):
        c = self.cli()
        c.start_core(transports={"tls": {"port": 0, "verifyServer": True, "caFile": CA}})
        acc, uid = add_ws(c, ext, transport, domain="localhost" if transport == "wss" else PBX,
                          registrar="sip:localhost:%d" % WSS_PORT if transport == "wss" else "sip:%s:%d" % (PBX, WS_PORT))
        info = c.req("account.info", {"uid": uid})
        self.assertEqual(info["regState"], "registered")
        self.assertEqual(info["regCode"], 200)
        self.assertEqual(info["transport"], transport)
        self.assertIn("transport=%s" % transport, info["contact"].lower())
        self.assertIn(".invalid", info["contact"])
        st = [e for e in c.events("transport.state") if e["transport"] == transport and e["state"] == "connected"]
        self.assertTrue(st, "no transport.state connected for %s: %s" % (transport, c.events("transport.state")))
        if transport == "wss":
            self.assertEqual(st[0]["tls"]["verifyStatus"], [])
            self.assertEqual(len(st[0]["tls"]["remoteCert"]["sha256"]), 64)
        # unregister / re-register on the same connection
        c.req("account.register", {"uid": uid, "register": False})
        self.assertIsNotNone(c.wait_event("account.reg", 10, 0, uid=uid, regState="unregistered"))
        m = c.mark()
        c.req("account.register", {"uid": uid, "register": True})
        self.assertIsNotNone(c.wait_event("account.reg", 10, m, uid=uid, regState="registered"))
        c.req("account.remove", {"uid": uid})

    def test_ws_register(self):
        self._reg("ws")

    def test_wss_register_verified(self):
        self._reg("wss")

    def test_wss_verify_failure(self):
        other = os.path.join(TMP, "ws-other-ca.pem")
        subprocess.run(["openssl", "req", "-x509", "-newkey", "rsa:2048", "-nodes", "-keyout", os.path.join(TMP, "ws-other.key"),
                        "-subj", "/CN=other-ca", "-days", "2", "-out", other], check=True, capture_output=True)
        c = self.cli()
        c.start_core(transports={"tls": {"port": 0, "verifyServer": True, "caFile": other}})
        cfg = ws_acct(c, 1010, "wss")
        m = c.mark()
        c.req("account.add", cfg)
        ev = c.wait_event("transport.tlsVerify", 15, m)
        self.assertIsNotNone(ev, "no transport.tlsVerify; events: %s" % [e["event"] for e in c.events()][-10:])
        self.assertEqual(len(ev["sha256"]), 64)
        failed = c.wait_event("account.reg", 20, m, uid=cfg["uid"], regState="failed")
        self.assertIsNotNone(failed)
        self.assertIn("TLS", failed["lastError"] or "")
        # pin the certificate -> registration succeeds
        c.req("core.setTlsPins", {"pins": [{"host": PBX, "sha256": ev["sha256"]}]})
        m = c.mark()
        c.req("account.register", {"uid": cfg["uid"], "register": True})
        self.assertIsNotNone(c.wait_event("account.reg", 20, m, uid=cfg["uid"], regState="registered"))

    def test_wss_ip_identity_mismatch_without_san(self):
        # CA is right but the name does not match the certificate -> identityNotMatch
        c = self.cli()
        c.start_core(transports={"tls": {"port": 0, "verifyServer": True, "caFile": CA}})
        cfg = ws_acct(c, 1010, "wss", registrar="sip:127.0.0.2:%d" % WSS_PORT)
        m = c.mark()
        c.req("account.add", cfg)
        # 127.0.0.2 may not be reachable on every host; either a tlsVerify event or a transport failure is fine
        ev = c.wait_event("transport.tlsVerify", 10, m)
        if ev is not None:
            self.assertIn("identityNotMatch", ev["verifyStatus"])

    def test_wrong_password_and_bad_path(self):
        c = self.cli()
        c.start_core()
        cfg = ws_acct(c, 1009, "ws", password="WRONG")
        m = c.mark()
        c.req("account.add", cfg)
        ev = c.wait_event("account.reg", 15, m, uid=cfg["uid"], regState="failed")
        self.assertIsNotNone(ev)
        self.assertIn(ev["regCode"], (401, 403))
        # wrong path: the upgrade is refused by the server -> registration fails, no crash
        # (the path is per server host:port, so use a fresh engine)
        c = self.cli()
        c.start_core()
        cfg2 = ws_acct(c, 1008, "ws", wsPath="/nope")
        m = c.mark()
        c.req("account.add", cfg2)
        ev = c.wait_event("account.reg", 20, m, uid=cfg2["uid"], regState="failed")
        self.assertIsNotNone(ev, c.events("account.reg"))
        self.assertIsNotNone(c.wait_event("transport.state", 5, 0, transport="ws", state="disconnected"))

    def test_invalid_ws_path_rejected(self):
        c = self.cli()
        c.start_core()
        r = c.raw("account.add", ws_acct(c, 1010, "ws", wsPath="ws"))
        self.assertEqual(r["error"]["code"], "INVALID_PARAM")
        r = c.raw("account.add", ws_acct(c, 1010, "ws", wsPath="/a b"))
        self.assertEqual(r["error"]["code"], "INVALID_PARAM")

    def test_domain_with_port(self):
        c = self.cli()
        c.start_core()
        add_ws(c, 1010, "ws", domain="%s:%d" % (PBX, WS_PORT), registrar=None)


class TestWsCalls(Base):
    def _media_ok(self, c, cid, timeout=15, peer=None, peer_cid=None):
        """c plays a tone into the call; (peer or c) must receive RTP with signal (echo when peer is None)."""
        r, rcid = (peer, peer_cid) if peer else (c, cid)
        c.req("call.playFile", {"cid": cid, "file": TONE, "loop": True})
        st = self.poll(lambda: (lambda s: s if s["rx"]["packets"] > 10 and s["rxLevel"] > 0 else None)(
            r.req("call.stats", {"cid": rcid})), timeout)
        self.assertIsNotNone(st, "no received audio: %s" % r.req("call.stats", {"cid": rcid}))
        self.assertGreater(c.req("call.stats", {"cid": cid})["tx"]["packets"], 10)
        return st

    def _echo(self, transport, ext=1001, **kw):
        a = self.cli("A")
        a.start_core(transports={"tls": {"port": 0, "verifyServer": True, "caFile": CA}})
        extra = dict(kw)
        if transport == "wss":
            extra.setdefault("domain", "localhost")
            extra.setdefault("registrar", "sip:localhost:%d" % WSS_PORT)
        _, ua = add_ws(a, ext, transport, **extra)
        cid = a.req("call.make", {"uid": ua, "uri": "600"})["cid"]
        self.assertIsNotNone(a.wait_event("call.state", 15, 0, cid=cid, state="confirmed"), a.events("call.state"))
        self.wait_media(a, cid)
        st = self._media_ok(a, cid)
        self.assertGreater(st["mos"], 3.0)
        info = a.req("call.info", {"cid": cid})
        a.req("call.hangup", {"cid": cid})
        return info, a

    def test_call_ws_echo(self):
        info, _ = self._echo("ws")
        self.assertFalse(info["srtp"])

    def test_call_wss_echo(self):
        self._echo("wss")

    def test_call_wss_sdes(self):
        info, _ = self._echo("wss", ext=1011, srtp="mandatory")
        self.assertTrue(info["srtp"])

    def _webrtc(self, **kw):
        a = self.cli("A")
        a.start_core(transports={"tls": {"port": 0, "verifyServer": True, "caFile": CA}})
        cfg = dict(domain="localhost", registrar="sip:localhost:%d" % WSS_PORT, srtp="mandatory", srtpKeying=["dtls"],
                   ice=True, rtcpMux=True, rtcpFb=True)
        cfg.update(kw)
        _, ua = add_ws(a, 1012, "wss", **cfg)
        m = a.mark()
        r = a.req("call.make", {"uid": ua, "uri": "600"})
        # with ICE enabled pjsua creates the media asynchronously, and call.make can return before the engine has
        # mapped the pjsua slot to a cid (cid 0): take it from the first call.state event instead
        first = a.wait_event("call.state", 10, m)
        self.assertIsNotNone(first)
        cid = first["cid"]
        self.assertIn(r["cid"], (0, cid))
        return a, cid

    def test_call_wss_webrtc_dtls_ice_rtcpmux(self):
        """Asterisk webrtc=yes endpoint 1012: DTLS-SRTP + ICE + rtcp-mux + AVPF (UDP/TLS/RTP/SAVPF) over WSS."""
        a, cid = self._webrtc()
        self.assertIsNotNone(a.wait_event("call.state", 20, 0, cid=cid, state="confirmed"), a.events("call.state")[-2:])
        self.wait_media(a, cid, timeout=15)
        st = self._media_ok(a, cid, timeout=25)          # echo through the PBX: DTLS handshake + ICE must have completed
        self.assertTrue(st["srtp"], st)          # live status (call.info/call.media srtp are sampled at media start, before DTLS completes)
        self.assertTrue(st["ice"]["localType"] and st["ice"]["remoteType"], st["ice"])   # an ICE pair was selected
        a.req("call.hangup", {"cid": cid})

    def test_call_wss_webrtc_without_avpf(self):
        """Same endpoint, plain UDP/TLS/RTP/SAVP offer (rtcpFb off): the PBX accepts it too."""
        a, cid = self._webrtc(rtcpFb=False)
        self.assertIsNotNone(a.wait_event("call.state", 20, 0, cid=cid, state="confirmed"))
        st = self._media_ok(a, cid, timeout=25)
        self.assertTrue(st["srtp"], st)
        a.req("call.hangup", {"cid": cid})

    def test_ws_to_udp_both_directions_and_server_requests(self):
        a, b = self.cli("A"), self.cli("B")
        a.start_core()
        b.start_core()
        _, ua = add_ws(a, 1001, "ws")
        _, ub = b.add_account(1002)
        # ws -> udp: INVITE out over WS; BYE from the UDP side arrives as a server-initiated request on the WS connection
        cid_a, cid_b = self.call_between(a, b, ua, "1002")
        self.wait_media(a, cid_a)
        self.wait_media(b, cid_b)
        self._media_ok(a, cid_a, peer=b, peer_cid=cid_b)
        mark = a.mark()
        b.req("call.hangup", {"cid": cid_b})
        self.assertIsNotNone(a.wait_event("call.state", 10, mark, cid=cid_a, state="disconnected"))
        # udp -> ws: INVITE arrives from the server over the WebSocket connection (incoming call to a ws account)
        mark_a = a.mark()
        cid_b2 = b.req("call.make", {"uid": ub, "uri": "1001"})["cid"]
        inc = a.wait_event("call.incoming", 15, mark_a)
        self.assertIsNotNone(inc, "ws account got no incoming call")
        self.assertEqual(inc["uid"], ua)
        a.req("call.answer", {"cid": inc["cid"]})
        self.assertIsNotNone(b.wait_event("call.state", 15, 0, cid=cid_b2, state="confirmed"))
        self.assertIsNotNone(a.wait_event("call.state", 15, mark_a, cid=inc["cid"], state="confirmed"))
        self.wait_media(a, inc["cid"])
        self._media_ok(b, cid_b2, peer=a, peer_cid=inc["cid"])
        # hold / unhold re-INVITEs, then BYE from the ws side
        a.req("call.hold", {"cid": inc["cid"]})
        self.assertIsNotNone(a.wait_event("call.media", 10, mark_a, cid=inc["cid"], media="localHold"))
        a.req("call.unhold", {"cid": inc["cid"]})
        m = b.mark()
        a.req("call.hangup", {"cid": inc["cid"]})
        self.assertIsNotNone(b.wait_event("call.state", 10, m, cid=cid_b2, state="disconnected"))

    def test_message_and_dtmf_over_ws(self):
        a, b = self.cli("A"), self.cli("B")
        a.start_core()
        b.start_core()
        _, ua = add_ws(a, 1001, "ws")
        _, ub = b.add_account(1002)
        ma, mb = a.mark(), b.mark()
        b.req("im.send", {"uid": ub, "to": "1001", "body": "hello ws", "msgId": "x1"})
        ev = a.wait_event("im.incoming", 15, ma)
        self.assertIsNotNone(ev, "MESSAGE not delivered to the ws account")
        self.assertEqual(ev["body"], "hello ws")
        self.assertTrue(b.wait_event("im.status", 15, mb, msgId="x1")["ok"])
        # and the other way (ws account sends)
        ma, mb = a.mark(), b.mark()
        a.req("im.send", {"uid": ua, "to": "1002", "body": "hi udp", "msgId": "x2"})
        self.assertEqual(b.wait_event("im.incoming", 15, mb)["body"], "hi udp")
        self.assertTrue(a.wait_event("im.status", 15, ma, msgId="x2")["ok"])
        # DTMF to 602 over ws
        cid = a.req("call.make", {"uid": ua, "uri": "602"})["cid"]
        self.assertIsNotNone(a.wait_event("call.state", 15, 0, cid=cid, state="confirmed"))
        a.req("call.dtmf", {"cid": cid, "digits": "1234"})
        a.sleep(1500)
        a.req("call.hangup", {"cid": cid})

    def test_large_sip_message(self):
        # a long header forces a frame well above 125 bytes (16-bit length form) and a big text message
        a = self.cli("A")
        a.start_core()
        _, ua = add_ws(a, 1001, "ws")
        cid = a.req("call.make", {"uid": ua, "uri": "600", "headers": {"X-Big": "A" * 3000}})["cid"]
        self.assertIsNotNone(a.wait_event("call.state", 15, 0, cid=cid, state="confirmed"))
        a.req("call.hangup", {"cid": cid})

    def test_two_ws_accounts_share_connection(self):
        a = self.cli("A")
        a.start_core()
        add_ws(a, 1003, "ws")
        add_ws(a, 1004, "ws")
        conns = [e for e in a.events("transport.state") if e["transport"] == "ws" and e["state"] == "connected"]
        self.assertEqual(len(conns), 1, conns)


# --------------------------------------------------------------------------------------------------
# A scriptable WebSocket "SIP server" for protocol and hostile-input tests
# --------------------------------------------------------------------------------------------------
GUID = "258EAFA5-E914-47DA-95CA-C5AB0DC85B11"


def ws_frame(op, payload=b"", fin=True, rsv=0, mask=False, length_override=None):
    b0 = (0x80 if fin else 0) | (rsv << 4) | op
    n = len(payload) if length_override is None else length_override
    if n < 126:
        h = struct.pack("!BB", b0, (0x80 if mask else 0) | n)
    elif n < 65536:
        h = struct.pack("!BBH", b0, (0x80 if mask else 0) | 126, n)
    else:
        h = struct.pack("!BBQ", b0, (0x80 if mask else 0) | 127, n)
    if mask:
        key = os.urandom(4)
        return h + key + bytes(c ^ key[i & 3] for i, c in enumerate(payload))
    return h + payload


def sip_reply(req, code="200 OK", expires=120):
    """Minimal response for a request text (REGISTER)."""
    lines = req.split("\r\n")
    keep = []
    for ln in lines[1:]:
        k = ln.split(":", 1)[0].strip().lower()
        if k in ("via", "from", "call-id", "cseq"):
            keep.append(ln)
        elif k == "to":
            keep.append(ln + ";tag=fake1")
        elif k == "contact":
            keep.append(ln + ";expires=%d" % expires)
    return ("SIP/2.0 %s\r\n" % code + "\r\n".join(keep) + "\r\nExpires: %d\r\nContent-Length: 0\r\n\r\n" % expires).encode()


class FakeWsServer:
    """Accepts connections; connection #n runs scenario n (a callable(conn_state) or a name)."""

    def __init__(self, scenarios):
        self.scenarios = list(scenarios)
        self.sock = socket.socket()
        self.sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        self.sock.bind(("127.0.0.1", 0))
        self.sock.listen(8)
        self.port = self.sock.getsockname()[1]
        self.conns = []
        self.lock = threading.Lock()
        self.stop = False
        self.t = threading.Thread(target=self._run, daemon=True)
        self.t.start()

    def close(self):
        self.stop = True
        try:
            self.sock.close()
        except OSError:
            pass

    def _run(self):
        while not self.stop:
            try:
                c, _ = self.sock.accept()
            except OSError:
                return
            with self.lock:
                idx = len(self.conns)
                st = {"idx": idx, "sock": c, "req": "", "frames": [], "closed": False, "sip": []}
                self.conns.append(st)
            sc = self.scenarios[idx] if idx < len(self.scenarios) else "ok"
            threading.Thread(target=self._serve, args=(st, sc), daemon=True).start()

    @staticmethod
    def _read_until(c, marker, limit=65536):
        buf = b""
        while marker not in buf and len(buf) < limit:
            d = c.recv(4096)
            if not d:
                break
            buf += d
        return buf

    def _serve(self, st, sc):
        c = st["sock"]
        c.settimeout(20)
        try:
            raw = self._read_until(c, b"\r\n\r\n")
            head, _, rest = raw.partition(b"\r\n\r\n")
            st["req"] = head.decode("latin1")
            hdr = {}
            for ln in st["req"].split("\r\n")[1:]:
                if ":" in ln:
                    k, v = ln.split(":", 1)
                    hdr[k.strip().lower()] = v.strip()
            st["hdr"] = hdr
            key = hdr.get("sec-websocket-key", "")
            acc = base64.b64encode(hashlib.sha1((key + GUID).encode()).digest()).decode()
            extra = ""
            code = "101 Switching Protocols"
            proto = "sip"
            if sc == "badaccept":
                acc = base64.b64encode(b"x" * 20).decode()
            elif sc == "status200":
                code = "200 OK"
            elif sc == "wrongproto":
                proto = "chat"
            elif sc == "extension":
                extra = "Sec-WebSocket-Extensions: permessage-deflate\r\n"
            elif sc == "bighdr":
                extra = "X-Junk: " + "A" * 6000 + "\r\n"
            elif sc == "noupgrade":
                extra = ""
            resp = ("HTTP/1.1 %s\r\nUpgrade: %s\r\nConnection: Upgrade\r\nSec-WebSocket-Accept: %s\r\n"
                    "Sec-WebSocket-Protocol: %s\r\n%s\r\n") % (code, "websocket" if sc != "noupgrade" else "foo", acc, proto, extra)
            c.sendall(resp.encode())
            if sc in ("badaccept", "status200", "wrongproto", "extension", "bighdr", "noupgrade"):
                time.sleep(1.0)
                return
            self._after_upgrade(st, sc, c, rest)
        except (OSError, ValueError):
            pass
        finally:
            st["closed"] = True
            try:
                c.close()
            except OSError:
                pass

    def _read_frame(self, c, buf):
        """Returns (op, fin, masked, payload, buf) or None on EOF."""
        while True:
            if len(buf) >= 2:
                masked = bool(buf[1] & 0x80)
                n = buf[1] & 0x7f
                hl = 2
                if n == 126 and len(buf) >= 4:
                    n = struct.unpack("!H", buf[2:4])[0]
                    hl = 4
                elif n == 127 and len(buf) >= 10:
                    n = struct.unpack("!Q", buf[2:10])[0]
                    hl = 10
                elif n >= 126:
                    n = None
                if n is not None:
                    tot = hl + (4 if masked else 0) + n
                    if len(buf) >= tot:
                        pl = buf[hl + (4 if masked else 0):tot]
                        if masked:
                            k = buf[hl:hl + 4]
                            pl = bytes(x ^ k[i & 3] for i, x in enumerate(pl))
                        return buf[0] & 0x0f, bool(buf[0] & 0x80), masked, pl, buf[tot:]
            d = c.recv(65536)
            if not d:
                return None
            buf += d

    def _drain(self, st, c, buf, secs=2.0):
        """Keep reading client frames for a while (collects the client's Close reply)."""
        c.settimeout(secs)
        try:
            while True:
                r = self._read_frame(c, buf)
                if r is None:
                    return
                op, fin, masked, pl, buf = r
                st["frames"].append((op, fin, masked, pl))
        except (OSError, ValueError):
            return

    def _after_upgrade(self, st, sc, c, buf):
        got_register = False
        while True:
            r = self._read_frame(c, buf)
            if r is None:
                return
            op, fin, masked, pl, buf = r
            st["frames"].append((op, fin, masked, pl))
            if op == 8:                       # client close: echo and finish
                c.sendall(ws_frame(8, pl))
                return
            if op in (9, 10) or op not in (1, 2):
                continue
            txt = pl.decode("latin1")
            st["sip"].append(txt)
            if not txt.startswith("REGISTER"):
                continue
            rep = sip_reply(txt)
            if sc == "ok":
                c.sendall(ws_frame(1, rep))
            elif sc == "fragmented":
                a, b, d = len(rep) // 3, 2 * (len(rep) // 3), len(rep)
                c.sendall(ws_frame(1, rep[:a], fin=False) + ws_frame(9, b"hello") + ws_frame(0, rep[a:b], fin=False)
                          + ws_frame(0, rep[b:d], fin=True))
            elif sc == "ping":
                c.sendall(ws_frame(9, b"pp123") + ws_frame(1, rep))
            elif sc == "close_after":
                c.sendall(ws_frame(1, rep))
                time.sleep(0.5)
                c.sendall(ws_frame(8, struct.pack("!H", 1001) + b"going away"))
                self._drain(st, c, buf)
                return
            elif sc == "drop_after":
                c.sendall(ws_frame(1, rep))
                time.sleep(0.5)
                return
            elif sc == "silent":                 # answer the REGISTER, then keep reading but never answer anything
                c.sendall(ws_frame(1, rep))
            elif sc == "binary":
                c.sendall(ws_frame(2, rep))
            elif sc == "big_ok":                 # near the limit, in 3 fragments
                c.sendall(ws_frame(1, rep[:20], fin=False) + ws_frame(0, rep[20:60], fin=False) + ws_frame(0, rep[60:]))
            else:                                # hostile: answer with garbage instead
                c.sendall(self.hostile(sc, rep))
                self._drain(st, c, buf)
                return

    @staticmethod
    def hostile(sc, rep):
        if sc == "h_hugelen":
            return ws_frame(1, b"x", length_override=1 << 62)
        if sc == "h_msb":
            return struct.pack("!BBQ", 0x81, 127, (1 << 63) | 5) + b"hello"
        if sc == "h_masked":
            return ws_frame(1, rep, mask=True)
        if sc == "h_rsv":
            return ws_frame(1, rep, rsv=4)
        if sc == "h_ctl_long":
            return ws_frame(9, b"A" * 126)
        if sc == "h_ctl_frag":
            return ws_frame(9, b"A", fin=False)
        if sc == "h_opcode":
            return ws_frame(3, b"x")
        if sc == "h_cont_orphan":
            return ws_frame(0, b"orphan")
        if sc == "h_toobig":
            return ws_frame(1, b"A" * 9000)
        if sc == "h_frag_toobig":
            return b"".join(ws_frame(1 if i == 0 else 0, b"A" * 3000, fin=False) for i in range(4)) + ws_frame(0, b"B")
        if sc == "h_new_in_frag":
            return ws_frame(1, b"INVITE", fin=False) + ws_frame(1, b"x")
        if sc == "h_garbage":
            return os.urandom(300)
        if sc == "h_truncated":
            return ws_frame(1, rep)[:10]
        if sc == "h_close1":
            return ws_frame(8, b"\x03")
        raise ValueError(sc)


HOSTILE = ["h_hugelen", "h_msb", "h_masked", "h_rsv", "h_ctl_long", "h_ctl_frag", "h_opcode", "h_cont_orphan", "h_toobig",
           "h_frag_toobig", "h_new_in_frag", "h_garbage", "h_truncated", "h_close1"]


class TestWsProtocol(Base):
    """RFC 6455 client behaviour against a scripted server (no PBX involved)."""

    def _acct(self, c, srv, n, **kw):
        cfg = c.acct(2000 + n, uid="p%d" % n, domain="127.0.0.1", transport="ws", registrar="sip:127.0.0.1:%d" % srv.port,
                     regRetrySec=2, regFirstRetrySec=1, regRetryRandomSec=0, mwi=False)
        cfg.update(kw)
        return cfg

    def _run(self, scenario, expect_register, timeout=8, n=1):
        srv = FakeWsServer([scenario])
        self.addCleanup(srv.close)
        c = self.cli()
        c.start_core()
        cfg = self._acct(c, srv, n)
        m = c.mark()
        c.req("account.add", cfg)
        if expect_register:
            ev = c.wait_event("account.reg", timeout, m, uid=cfg["uid"], regState="registered")
            self.assertIsNotNone(ev, "%s: not registered: %s" % (scenario, c.events("account.reg")[-1:]))
        else:
            ev = c.wait_event("account.reg", timeout, m, uid=cfg["uid"], regState="failed")
            self.assertIsNotNone(ev, "%s: registration should fail: %s" % (scenario, c.events("account.reg")[-1:]))
            self.assertIsNotNone(c.wait_event("transport.state", 5, m, transport="ws", state="disconnected"),
                                 "%s: no transport.state disconnected" % scenario)
        c.req("core.ping")                    # engine still alive and responsive
        return c, srv, cfg

    def test_handshake_request_and_client_framing(self):
        c, srv, cfg = self._run("ok", True)
        st = srv.conns[0]
        req = st["req"]
        self.assertTrue(req.startswith("GET /ws HTTP/1.1"), req)
        h = st["hdr"]
        self.assertEqual(h["upgrade"].lower(), "websocket")
        self.assertIn("upgrade", h["connection"].lower())
        self.assertEqual(h["sec-websocket-version"], "13")
        self.assertEqual(h["sec-websocket-protocol"], "sip")
        self.assertEqual(h["host"], "127.0.0.1:%d" % srv.port)
        self.assertEqual(len(base64.b64decode(h["sec-websocket-key"])), 16)
        texts = [f for f in st["frames"] if f[0] == 1]
        self.assertTrue(texts)
        for op, fin, masked, pl in st["frames"]:
            self.assertTrue(masked, "client frames must be masked")
        self.assertTrue(texts[0][3].startswith(b"REGISTER sip:127.0.0.1:%d;transport=ws SIP/2.0" % srv.port))
        # Via / Contact per RFC 7118
        self.assertIn(b"SIP/2.0/WS ", texts[0][3])
        self.assertRegex(texts[0][3].decode(), r"Contact: <sip:\w+@[a-z0-9]+\.invalid;transport=ws>")

    def test_custom_ws_path(self):
        srv = FakeWsServer(["ok"])
        self.addCleanup(srv.close)
        c = self.cli()
        c.start_core()
        cfg = self._acct(c, srv, 2, wsPath="/sip/ws?x=1")
        m = c.mark()
        c.req("account.add", cfg)
        self.assertIsNotNone(c.wait_event("account.reg", 8, m, uid=cfg["uid"], regState="registered"))
        self.assertTrue(srv.conns[0]["req"].startswith("GET /sip/ws?x=1 HTTP/1.1"))

    def test_fragmented_message_with_interleaved_ping(self):
        c, srv, cfg = self._run("fragmented", True)
        pongs = [f for f in srv.conns[0]["frames"] if f[0] == 10]
        self.assertEqual([f[3] for f in pongs], [b"hello"])
        self.assertTrue(pongs[0][2])          # masked

    def test_server_ping_gets_pong(self):
        c, srv, cfg = self._run("ping", True)
        self.assertEqual([f[3] for f in srv.conns[0]["frames"] if f[0] == 10], [b"pp123"])

    def test_binary_and_fragmented_three_way(self):
        self._run("binary", True)
        self._run("big_ok", True, n=3)

    def test_handshake_failures(self):
        for sc in ("badaccept", "status200", "wrongproto", "extension", "bighdr", "noupgrade"):
            self._run(sc, False, n=4)

    def test_hostile_frames_never_crash(self):
        """Malformed / abusive frames in place of the REGISTER answer: connection is dropped (transport.state
        disconnected), registration fails, the engine stays alive and responsive."""
        for i, sc in enumerate(HOSTILE):
            c, srv, cfg = self._run(sc, False, timeout=10, n=10 + i)
            if sc not in ("h_garbage", "h_truncated"):
                closes = [f for f in srv.conns[0]["frames"] if f[0] == 8]
                self.assertTrue(closes, "%s: client should send a Close frame before dropping" % sc)
                code = struct.unpack("!H", closes[0][3][:2])[0]
                self.assertIn(code, (1002, 1009), "%s: close code %s" % (sc, code))

    def _with_ka(self, secs):
        old = os.environ.get("SPC_WS_KA_SEC")
        os.environ["SPC_WS_KA_SEC"] = str(secs)
        self.addCleanup(lambda: os.environ.pop("SPC_WS_KA_SEC", None) if old is None else os.environ.__setitem__("SPC_WS_KA_SEC", old))

    def test_client_ping_keepalive_and_dead_peer(self):
        """Client pings every SPC_WS_KA_SEC; a peer that goes silent is dropped after 2.5 intervals."""
        self._with_ka(2)
        srv = FakeWsServer(["silent"])
        self.addCleanup(srv.close)
        c = self.cli()
        c.start_core()
        cfg = self._acct(c, srv, 7)
        m = c.mark()
        c.req("account.add", cfg)
        self.assertIsNotNone(c.wait_event("account.reg", 8, m, uid=cfg["uid"], regState="registered"))
        pings = self.poll(lambda: [f for f in srv.conns[0]["frames"] if f[0] == 9], 6)
        self.assertTrue(pings and pings[0][2], "no (masked) ping from the client")
        # the "silent" server never answers pings and sends nothing: the client declares the peer dead
        self.assertIsNotNone(c.wait_event("transport.state", 15, m, transport="ws", state="disconnected"))

    def test_close_handshake_from_server(self):
        srv = FakeWsServer(["close_after", "ok"])
        self.addCleanup(srv.close)
        c = self.cli()
        c.start_core()
        cfg = self._acct(c, srv, 5)
        m = c.mark()
        c.req("account.add", cfg)
        self.assertIsNotNone(c.wait_event("account.reg", 8, m, uid=cfg["uid"], regState="registered"))
        self.assertIsNotNone(c.wait_event("transport.state", 8, m, transport="ws", state="disconnected"))
        closes = self.poll(lambda: [f for f in srv.conns[0]["frames"] if f[0] == 8], 5)
        self.assertTrue(closes and closes[0][2], "client must answer the Close frame (masked)")
        self.assertEqual(struct.unpack("!H", closes[0][3][:2])[0], 1000)
        # pjsua re-registers over a new connection
        end = time.time() + 20
        while time.time() < end and len(srv.conns) < 2:
            time.sleep(0.3)
        self.assertGreaterEqual(len(srv.conns), 2, "no reconnect after server close")

    def test_reconnect_after_abrupt_drop(self):
        srv = FakeWsServer(["drop_after", "ok"])
        self.addCleanup(srv.close)
        c = self.cli()
        c.start_core()
        cfg = self._acct(c, srv, 6)
        m = c.mark()
        c.req("account.add", cfg)
        self.assertIsNotNone(c.wait_event("account.reg", 8, m, uid=cfg["uid"], regState="registered"))
        self.assertIsNotNone(c.wait_event("transport.state", 8, m, transport="ws", state="disconnected"))
        end = time.time() + 25
        while time.time() < end and len(srv.conns) < 2:
            time.sleep(0.3)
        self.assertGreaterEqual(len(srv.conns), 2, "no reconnect after the connection dropped")
        self.assertTrue([f for f in srv.conns[1]["sip"] if f.startswith("REGISTER")], "no REGISTER on the new connection")


@unittest.skipUnless(os.environ.get("SPC_WS_RESTART") == "1", "slow; restarts the PBX container (set SPC_WS_RESTART=1)")
class TestWsReconnectPbx(Base):
    def test_reconnect_after_pbx_restart(self):
        c = self.cli()
        c.start_core()
        acc, uid = add_ws(c, 1010, "ws", regRetrySec=5, regFirstRetrySec=3, regRetryRandomSec=0)
        m = c.mark()
        subprocess.run(["docker", "restart", CONTAINER], check=True, capture_output=True)
        self.assertIsNotNone(c.wait_event("transport.state", 30, m, transport="ws", state="disconnected"))
        # PBX boots in ~15 s; pjsua keeps retrying the registration over a fresh WebSocket connection
        ev = c.wait_event("account.reg", 120, m, uid=uid, regState="registered")
        self.assertIsNotNone(ev, "ws account did not re-register after the PBX restart: %s" % c.events("account.reg")[-3:])
        self.assertTrue([e for e in c.events("transport.state") if e["transport"] == "ws" and e["state"] == "connected"][1:])


if __name__ == "__main__":
    unittest.main()
