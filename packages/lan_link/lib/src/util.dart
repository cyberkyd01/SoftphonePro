import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

/// Base class for all errors surfaced by lan_link.
class LanLinkException implements Exception {
  LanLinkException(this.code, this.message);

  /// Stable machine readable code (e.g. `unknown_device`, `peer_offline`).
  final String code;

  /// Human readable text suitable for UI.
  final String message;

  @override
  String toString() => 'LanLinkException($code): $message';
}

/// Thrown when a peer cannot be reached right now.
class PeerOfflineException extends LanLinkException {
  PeerOfflineException(String peer)
      : super('peer_offline', 'Device is offline or unreachable ($peer)');
}

/// Handshake / authentication failure.
class HandshakeException extends LanLinkException {
  HandshakeException(super.code, super.message);
}

String hexEncode(List<int> b) {
  final sb = StringBuffer();
  for (final x in b) {
    sb.write(x.toRadixString(16).padLeft(2, '0'));
  }
  return sb.toString();
}

final _hexRe = RegExp(r'^[0-9a-fA-F]*$');

Uint8List hexDecode(String s) {
  if (s.length.isOdd || !_hexRe.hasMatch(s)) {
    throw const FormatException('bad hex');
  }
  final out = Uint8List(s.length ~/ 2);
  for (var i = 0; i < out.length; i++) {
    out[i] = int.parse(s.substring(i * 2, i * 2 + 2), radix: 16);
  }
  return out;
}

String b64Encode(List<int> b) => base64Url.encode(b).replaceAll('=', '');

Uint8List b64Decode(String s, {int? length, int maxLength = 1 << 20}) {
  if (s.length > maxLength * 2) throw const FormatException('too long');
  try {
    final r = Uint8List.fromList(base64Url.decode(base64Url.normalize(s)));
    if (length != null && r.length != length) {
      throw const FormatException('bad length');
    }
    return r;
  } on FormatException {
    rethrow;
  } catch (_) {
    throw const FormatException('bad base64');
  }
}

bool bytesEqual(List<int> a, List<int> b) {
  if (a.length != b.length) return false;
  var d = 0;
  for (var i = 0; i < a.length; i++) {
    d |= a[i] ^ b[i];
  }
  return d == 0;
}

Uint8List concatBytes(Iterable<List<int>> parts) {
  final bb = BytesBuilder(copy: false);
  for (final p in parts) {
    bb.add(p);
  }
  return bb.takeBytes();
}

/// Strict JSON object reader. Throws [FormatException] on any type mismatch.
class Js {
  Js(this.m);
  final Map<String, dynamic> m;

  static Js parse(String text, {int maxLength = 64 * 1024}) {
    if (text.length > maxLength) throw const FormatException('too large');
    final d = jsonDecode(text);
    if (d is! Map<String, dynamic>) throw const FormatException('not object');
    return Js(d);
  }

  bool has(String k) => m.containsKey(k) && m[k] != null;

  String str(String k, {int max = 256, bool allowEmpty = true}) {
    final v = m[k];
    if (v is! String) throw FormatException('$k: expected string');
    if (v.length > max) throw FormatException('$k: too long');
    if (!allowEmpty && v.isEmpty) throw FormatException('$k: empty');
    return v;
  }

  String? optStr(String k, {int max = 256}) => has(k) ? str(k, max: max) : null;

  int integer(String k, {int min = 0, int max = 1 << 53}) {
    final v = m[k];
    if (v is! int) throw FormatException('$k: expected int');
    if (v < min || v > max) throw FormatException('$k: out of range');
    return v;
  }

  int? optInt(String k, {int min = 0, int max = 1 << 53}) =>
      has(k) ? integer(k, min: min, max: max) : null;

  bool boolean(String k, {bool? def}) {
    final v = m[k];
    if (v is bool) return v;
    if (v == null && def != null) return def;
    throw FormatException('$k: expected bool');
  }

  Js obj(String k) {
    final v = m[k];
    if (v is! Map<String, dynamic>)
      throw FormatException('$k: expected object');
    return Js(v);
  }

  List<dynamic> list(String k, {int max = 64}) {
    final v = m[k];
    if (v is! List) throw FormatException('$k: expected list');
    if (v.length > max) throw FormatException('$k: too many');
    return v;
  }
}

/// Runs async tasks one after another.
class SerialQueue {
  Future<void> _tail = Future.value();

  Future<T> run<T>(Future<T> Function() task) {
    final c = Completer<T>();
    _tail = _tail.then((_) async {
      try {
        c.complete(await task());
      } catch (e, st) {
        c.completeError(e, st);
      }
    });
    return c.future;
  }
}

/// Sliding one-second window rate limiter.
class RateLimiter {
  RateLimiter(this.maxEvents, this.window, {DateTime Function()? now})
      : _now = now ?? DateTime.now;
  final int maxEvents;
  final Duration window;
  final DateTime Function() _now;
  final List<DateTime> _events = [];

  /// Returns true if the event is allowed (and records it).
  bool allow() {
    final t = _now();
    _events.removeWhere((e) => t.difference(e) > window);
    if (_events.length >= maxEvents) return false;
    _events.add(t);
    return true;
  }
}
