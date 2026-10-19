import 'dart:convert';
import 'dart:math';

/// Generates a 32-byte random token as 64 hex characters.
String generateAutomationToken([Random? random]) {
  final r = random ?? Random.secure();
  return [for (var i = 0; i < 32; i++) r.nextInt(256).toRadixString(16).padLeft(2, '0')].join();
}

/// Constant-time comparison: the time depends only on the length of the
/// longer input, not on where the first difference is.
bool constantTimeEquals(String a, String b) {
  final x = utf8.encode(a);
  final y = utf8.encode(b);
  var diff = x.length ^ y.length;
  final n = max(x.length, y.length);
  for (var i = 0; i < n; i++) {
    diff |= (i < x.length ? x[i] : 0) ^ (i < y.length ? y[i] : 0);
  }
  return diff == 0;
}

/// Extracts the token of an `Authorization: Bearer <token>` header.
String? bearerToken(String? header) {
  if (header == null) return null;
  final m = RegExp(r'^\s*Bearer\s+(\S+)\s*$', caseSensitive: false).firstMatch(header);
  return m?.group(1);
}

/// True when [given] authenticates against [expected] (never for an empty
/// expected token).
bool tokenMatches(String expected, String? given) {
  if (expected.isEmpty || given == null || given.isEmpty) {
    // Still burn comparable time.
    constantTimeEquals(expected, given ?? '');
    return false;
  }
  return constantTimeEquals(expected, given);
}

/// Normalises a configured origin (`https://CRM.example.com/` ->
/// `https://crm.example.com`). Returns null for anything that is not an
/// http(s) origin; wildcards are not supported on purpose.
String? normalizeOrigin(String s) {
  final t = s.trim();
  if (t.isEmpty || t.contains('*')) return null;
  final u = Uri.tryParse(t);
  if (u == null || !(u.scheme == 'http' || u.scheme == 'https') || u.host.isEmpty) return null;
  if (u.path.isNotEmpty && u.path != '/') return null;
  final port = u.hasPort && !((u.scheme == 'http' && u.port == 80) || (u.scheme == 'https' && u.port == 443))
      ? ':${u.port}'
      : '';
  return '${u.scheme}://${u.host.toLowerCase()}$port';
}

/// Host header values that mean "this machine" (defence against DNS
/// rebinding: a browser tricked into sending `Host: evil.example` is refused).
bool isLoopbackHost(String? hostHeader, int port) {
  if (hostHeader == null || hostHeader.isEmpty) return false;
  final h = hostHeader.toLowerCase();
  const names = ['127.0.0.1', 'localhost', '[::1]'];
  for (final n in names) {
    if (h == n || h == '$n:$port') return true;
  }
  return false;
}
