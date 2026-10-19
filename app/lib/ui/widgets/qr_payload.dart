import 'dart:convert';

/// What a scanned / pasted QR text means for the app.
sealed class QrPayload {
  const QrPayload();
}

/// A provisioning document (JSON) carried directly in the code.
class QrProvisionJson extends QrPayload {
  const QrProvisionJson(this.json);
  final String json;
}

/// A provisioning document to download.
class QrProvisionUrl extends QrPayload {
  const QrProvisionUrl(this.url);
  final Uri url;
}

/// `softphonepro://lan?h=..&p=..&id=..&n=..` or a bare `host:port`.
class QrLan extends QrPayload {
  const QrLan(this.raw);
  final String raw;
}

class QrUnknown extends QrPayload {
  const QrUnknown(this.raw);
  final String raw;
}

final _hostPort = RegExp(r'^(\[[0-9a-fA-F:]+\]|[A-Za-z0-9.\-]+):\d{1,5}$');

/// Classifies [raw]. Accepted forms:
///  * a JSON object (`{...}`) -> provisioning JSON
///  * `softphonepro://provision?url=<https url>` / `?data=<json>` / `?b64=<base64 json>`
///  * `https://...` / `http://...` -> provisioning URL
///  * `softphonepro://lan?...` or `host:port` -> LAN pairing
QrPayload parseQrPayload(String raw) {
  final t = raw.trim();
  if (t.isEmpty) return QrUnknown(raw);
  if (t.startsWith('{')) return QrProvisionJson(t);
  final u = Uri.tryParse(t);
  if (u != null && u.scheme.toLowerCase() == 'softphonepro') {
    final kind = u.host.toLowerCase();
    if (kind == 'lan') return QrLan(t);
    if (kind == 'provision') {
      final q = u.queryParameters;
      final url = q['url'];
      if (url != null) {
        final parsed = Uri.tryParse(url);
        if (parsed != null && (parsed.scheme == 'https' || parsed.scheme == 'http')) {
          return QrProvisionUrl(parsed);
        }
      }
      final data = q['data'];
      if (data != null && data.trimLeft().startsWith('{')) return QrProvisionJson(data);
      final b64 = q['b64'];
      if (b64 != null) {
        try {
          final s = utf8.decode(base64Url.decode(base64Url.normalize(b64)));
          if (s.trimLeft().startsWith('{')) return QrProvisionJson(s);
        } on FormatException {
          // falls through to unknown
        }
      }
    }
    return QrUnknown(raw);
  }
  if (u != null && (u.scheme == 'https' || u.scheme == 'http') && u.host.isNotEmpty) {
    return QrProvisionUrl(u);
  }
  if (_hostPort.hasMatch(t)) return QrLan(t);
  return QrUnknown(raw);
}
