import 'dart:convert';
import 'dart:typed_data';

import 'redaction.dart';
import 'sip_message.dart';

String _ts(DateTime t) {
  String p(int n, [int w = 2]) => n.toString().padLeft(w, '0');
  return '${t.year}-${p(t.month)}-${p(t.day)} ${p(t.hour)}:${p(t.minute)}:${p(t.second)}.${p(t.millisecond, 3)}';
}

/// Plain-text trace in the familiar "---- rx/tx" layout.
String buildTraceText(Iterable<SipMessage> messages, {bool redact = true, String? header}) {
  final b = StringBuffer();
  if (header != null) b.writeln(header);
  b.writeln('# SoftphonePro SIP trace${redact ? ' (credentials redacted)' : ' (UNREDACTED)'}');
  for (final m in messages) {
    final arrow = m.outgoing ? 'tx' : 'rx';
    final peer = m.outgoing ? 'to ${m.remote}' : 'from ${m.remote}';
    b.writeln();
    b.writeln('---- ${_ts(m.time)} $arrow ${m.transport} $peer (${m.size} bytes) ----');
    final text = redact ? redactSecrets(m.raw) : m.raw;
    b.writeln(text.trimRight());
  }
  return b.toString();
}

({List<int> ip, int port}) _endpoint(String s) {
  final m = RegExp(r'^\[?([0-9.]+)\]?:(\d+)$').firstMatch(s.trim());
  if (m != null) {
    final parts = m.group(1)!.split('.').map(int.tryParse).toList();
    if (parts.length == 4 && parts.every((p) => p != null && p >= 0 && p < 256)) {
      return (ip: parts.cast<int>(), port: int.tryParse(m.group(2)!) ?? 0);
    }
    return (ip: [0, 0, 0, 0], port: int.tryParse(m.group(2)!) ?? 0);
  }
  return (ip: [0, 0, 0, 0], port: 0);
}

int _ipChecksum(Uint8List h) {
  var sum = 0;
  for (var i = 0; i < h.length; i += 2) {
    sum += (h[i] << 8) | h[i + 1];
  }
  while (sum >> 16 != 0) {
    sum = (sum & 0xffff) + (sum >> 16);
  }
  return ~sum & 0xffff;
}

/// A libpcap file (LINKTYPE_RAW) with synthetic IPv4/UDP headers around each
/// SIP message so Wireshark can dissect it. TCP/TLS messages are also wrapped
/// as UDP; IPv6 endpoints are shown as 0.0.0.0.
Uint8List buildPcap(Iterable<SipMessage> messages, {bool redact = true}) {
  final out = BytesBuilder();
  final g = ByteData(24)
    ..setUint32(0, 0xa1b2c3d4, Endian.little)
    ..setUint16(4, 2, Endian.little)
    ..setUint16(6, 4, Endian.little)
    ..setUint32(16, 65535, Endian.little)
    ..setUint32(20, 101, Endian.little);
  out.add(g.buffer.asUint8List());
  var ident = 1;
  for (final m in messages) {
    var payload = utf8.encode(redact ? redactSecrets(m.raw) : m.raw);
    if (payload.length > 60000) payload = payload.sublist(0, 60000);
    final local = _endpoint(m.local);
    final remote = _endpoint(m.remote);
    final src = m.outgoing ? local : remote;
    final dst = m.outgoing ? remote : local;
    final total = 20 + 8 + payload.length;
    final ip = Uint8List(20);
    final ipd = ByteData.view(ip.buffer);
    ip[0] = 0x45;
    ipd.setUint16(2, total);
    ipd.setUint16(4, ident++ & 0xffff);
    ip[8] = 64;
    ip[9] = 17;
    ip.setRange(12, 16, src.ip);
    ip.setRange(16, 20, dst.ip);
    ipd.setUint16(10, _ipChecksum(ip));
    final udp = ByteData(8)
      ..setUint16(0, src.port)
      ..setUint16(2, dst.port)
      ..setUint16(4, 8 + payload.length);
    final rec = ByteData(16)
      ..setUint32(0, m.time.millisecondsSinceEpoch ~/ 1000, Endian.little)
      ..setUint32(4, (m.time.millisecondsSinceEpoch % 1000) * 1000, Endian.little)
      ..setUint32(8, total, Endian.little)
      ..setUint32(12, total, Endian.little);
    out
      ..add(rec.buffer.asUint8List())
      ..add(ip)
      ..add(udp.buffer.asUint8List())
      ..add(payload);
  }
  return out.toBytes();
}
