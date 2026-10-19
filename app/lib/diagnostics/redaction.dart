/// Credential redaction for exported SIP traces and logs.
library;

const String kRedacted = '[REDACTED]';

final RegExp _authHeader = RegExp(
  r'^((?:proxy-)?authorization|www-authenticate|proxy-authenticate|authentication-info)[ \t]*:[^\r\n]*(?:\r?\n[ \t][^\r\n]*)*',
  caseSensitive: false,
  multiLine: true,
);

final RegExp _authParam = RegExp(
  r'\b(response|nonce|cnonce|nextnonce|rspauth|opaque|password|passwd|pwd|secret|token)\s*=\s*("[^"]*"|[^\s,;]+)',
  caseSensitive: false,
);

final RegExp _globalParam = RegExp(
  r'([?&;\s"])(password|passwd|pwd|secret|token|apikey|api_key|auth_token)\s*=\s*("[^"]*"|[^\s,;&>"]+)',
  caseSensitive: false,
);

final RegExp _uriPassword = RegExp(r'(sips?:[^:@\s;>/]+):[^@\s>]+@', caseSensitive: false);

final RegExp _srtpKey = RegExp(r'(a=crypto:[^\r\n]*?inline:)[^|;\s\r\n]+', caseSensitive: false);

final RegExp _bearer = RegExp(r'\b(Bearer|Basic)\s+[A-Za-z0-9._~+/=-]{8,}', caseSensitive: false);

/// Redacts digest responses/nonces/cnonces, password-like parameters,
/// passwords in URIs and SRTP keys from a SIP message or log text.
String redactSecrets(String text) {
  try {
    var out = text.replaceAllMapped(_authHeader, (m) {
      return m.group(0)!.replaceAllMapped(_authParam, (p) => '${p.group(1)}="$kRedacted"');
    });
    out = out.replaceAllMapped(_globalParam, (m) => '${m.group(1)}${m.group(2)}=$kRedacted');
    out = out.replaceAllMapped(_uriPassword, (m) => '${m.group(1)}:$kRedacted@');
    out = out.replaceAllMapped(_srtpKey, (m) => '${m.group(1)}$kRedacted');
    out = out.replaceAllMapped(_bearer, (m) => '${m.group(1)} $kRedacted');
    return out;
  } catch (_) {
    return text;
  }
}
