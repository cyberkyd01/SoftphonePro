"""Tiny UDP DNS responder for spcore tests (stdlib only): A, AAAA (always empty) and SRV records.

    srv = StubDns({"pbx.test": [("A", "127.0.0.1")],
                   "_sips._tcp.pbx.test": [("SRV", 10, 5, 5061, "pbx.test")]})
    srv.port            # random UDP port on 127.0.0.1 -> core.start nameservers ["127.0.0.1:%d" % srv.port]
    srv.records[...] = ...   # may be changed while running
    srv.drop = True     # never answer (timeout tests)
    srv.queries         # list of (type_name, qname) seen
Unknown names get NXDOMAIN; a known name without records of the asked type gets an empty NOERROR answer.
"""
import socket
import struct
import threading

T_A, T_AAAA, T_SRV = 1, 28, 33
TYPE_NAMES = {T_A: "A", T_AAAA: "AAAA", T_SRV: "SRV", 2: "NS", 5: "CNAME", 6: "SOA", 35: "NAPTR"}


def _name(n):
    out = b""
    for lab in n.rstrip(".").split("."):
        out += bytes([len(lab)]) + lab.encode()
    return out + b"\0"


class StubDns:
    def __init__(self, records=None, drop=False, ttl=30):
        self.ttl = ttl
        self.records = {k.lower(): list(v) for k, v in (records or {}).items()}
        self.drop = drop
        self.queries = []
        self.sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        self.sock.bind(("127.0.0.1", 0))
        self.sock.settimeout(0.2)
        self.port = self.sock.getsockname()[1]
        self._stop = False
        self._t = threading.Thread(target=self._run, daemon=True)
        self._t.start()

    def close(self):
        self._stop = True
        self._t.join(2)
        self.sock.close()

    def set(self, records):
        self.records = {k.lower(): list(v) for k, v in records.items()}

    @staticmethod
    def _parse_q(data):
        i = 12
        labels = []
        while data[i]:
            n = data[i]
            labels.append(data[i + 1:i + 1 + n].decode("ascii", "replace"))
            i += n + 1
        qtype, _qclass = struct.unpack("!HH", data[i + 1:i + 5])
        return ".".join(labels).lower(), qtype, data[12:i + 5]

    def _answer(self, qname, qtype):
        recs = self.records.get(qname)
        if recs is None:
            return 3, []
        out = []
        for r in recs:
            if r[0] == "A" and qtype == T_A:
                out.append((T_A, socket.inet_aton(r[1])))
            elif r[0] == "SRV" and qtype == T_SRV:
                _, prio, weight, port, target = r
                out.append((T_SRV, struct.pack("!HHH", prio, weight, port) + _name(target)))
        return 0, out

    def _run(self):
        while not self._stop:
            try:
                data, addr = self.sock.recvfrom(1500)
            except socket.timeout:
                continue
            except OSError:
                return
            try:
                qid = data[:2]
                qname, qtype, question = self._parse_q(data)
            except Exception:
                continue
            self.queries.append((TYPE_NAMES.get(qtype, str(qtype)), qname))
            if self.drop:
                continue
            rcode, ans = self._answer(qname, qtype)
            hdr = qid + struct.pack("!HHHHH", 0x8180 | rcode, 1, len(ans), 0, 0)
            body = b"".join(b"\xc0\x0c" + struct.pack("!HHIH", t, 1, self.ttl, len(rd)) + rd for t, rd in ans)
            try:
                self.sock.sendto(hdr + question + body, addr)
            except OSError:
                pass
