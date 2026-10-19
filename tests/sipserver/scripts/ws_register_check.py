#!/usr/bin/env python3
"""Minimal SIP-over-WebSocket REGISTER check (stdlib only).
usage: ws_register_check.py [host] [ws|wss] [ext]   -> prints status line of final REGISTER response."""
import base64, hashlib, os, re, socket, ssl, struct, sys, uuid
host = sys.argv[1] if len(sys.argv) > 1 else "127.0.0.1"
scheme = sys.argv[2] if len(sys.argv) > 2 else "ws"
ext = sys.argv[3] if len(sys.argv) > 3 else "1001"
port = 8089 if scheme == "wss" else 8088
here = os.path.dirname(os.path.abspath(__file__))
s = socket.create_connection((host, port), timeout=5)
if scheme == "wss":
    ctx = ssl.create_default_context(cafile=os.path.join(here, "..", "certs", "ca.crt"))
    s = ctx.wrap_socket(s, server_hostname=host)
key = base64.b64encode(os.urandom(16)).decode()
s.sendall((f"GET /ws HTTP/1.1\r\nHost: {host}:{port}\r\nUpgrade: websocket\r\nConnection: Upgrade\r\n"
           f"Sec-WebSocket-Key: {key}\r\nSec-WebSocket-Version: 13\r\nSec-WebSocket-Protocol: sip\r\n\r\n").encode())
resp = b""
while b"\r\n\r\n" not in resp: resp += s.recv(4096)
print(resp.split(b"\r\n")[0].decode())
def send(txt):
    d = txt.encode(); m = os.urandom(4); n = len(d)
    hdr = bytes([0x81]) + (bytes([0x80 | n]) if n < 126 else bytes([0x80 | 126]) + struct.pack(">H", n))
    s.sendall(hdr + m + bytes(b ^ m[i % 4] for i, b in enumerate(d)))
def recv():
    h = s.recv(2); n = h[1] & 0x7f
    if n == 126: n = struct.unpack(">H", s.recv(2))[0]
    d = b""
    while len(d) < n: d += s.recv(n - len(d))
    return d.decode()
cid = uuid.uuid4().hex; tag = uuid.uuid4().hex[:8]
def reg(cseq, auth=""):
    return (f"REGISTER sip:{host} SIP/2.0\r\nVia: SIP/2.0/{scheme.upper()} x.invalid;branch=z9hG4bK{uuid.uuid4().hex[:10]}\r\n"
            f"Max-Forwards: 70\r\nFrom: <sip:{ext}@{host}>;tag={tag}\r\nTo: <sip:{ext}@{host}>\r\nCall-ID: {cid}\r\nCSeq: {cseq} REGISTER\r\n"
            f"Contact: <sip:{ext}@x.invalid;transport={scheme}>;expires=60\r\n{auth}Content-Length: 0\r\n\r\n")
send(reg(1)); r = recv(); print(r.split("\r\n")[0])
realm = re.search(r'realm="([^"]*)"', r).group(1); nonce = re.search(r'nonce="([^"]*)"', r).group(1)
uri = f"sip:{host}"
h1 = hashlib.md5(f"{ext}:{realm}:pass{ext}".encode()).hexdigest(); h2 = hashlib.md5(f"REGISTER:{uri}".encode()).hexdigest()
resp_ = hashlib.md5(f"{h1}:{nonce}:{h2}".encode()).hexdigest()
send(reg(2, f'Authorization: Digest username="{ext}", realm="{realm}", nonce="{nonce}", uri="{uri}", response="{resp_}", algorithm=MD5\r\n'))
print(recv().split("\r\n")[0])
