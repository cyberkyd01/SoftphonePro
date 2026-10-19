/// Tolerant SIP message parser used by the trace viewer.
///
/// Never throws: hostile or garbage input yields a message with
/// [SipMessage.valid] == false and a descriptive [SipMessage.label].
library;

const int kMaxParseBytes = 256 * 1024;


// Compact header forms (RFC 3261 section 7.3.3).
const Map<String, String> kCompactHeaders = {
  'i': 'call-id',
  'm': 'contact',
  'e': 'content-encoding',
  'l': 'content-length',
  'c': 'content-type',
  'f': 'from',
  's': 'subject',
  'k': 'supported',
  't': 'to',
  'v': 'via',
  'o': 'event',
  'u': 'allow-events',
  'r': 'refer-to',
  'b': 'referred-by',
  'x': 'session-expires',
  'a': 'accept-contact',
  'j': 'reject-contact',
  'd': 'request-disposition',
  'y': 'identity',
  'n': 'identity-info',
};


String normalizeHeaderName(String name) {
  final n = name.trim().toLowerCase();
  return kCompactHeaders[n] ?? n;
}

class SipMessage {
  SipMessage({
    required this.id,
    required this.time,
    required this.outgoing,
    required this.transport,
    required this.local,
    required this.remote,
    required this.size,
    required this.raw,
    required this.valid,
    required this.isRequest,
    required this.startLine,
    this.method = '',
    this.status = 0,
    this.reason = '',
    this.requestUri = '',
    this.callId = '',
    this.cseqNum = 0,
    this.cseqMethod = '',
    this.fromUri = '',
    this.toUri = '',
    this.fromTag = '',
    this.toTag = '',
    this.branch = '',
    this.headers = const [],
    this.body = '',
    this.keepAlive = false,
  });

  /// Monotonic id assigned by the trace store.
  final int id;
  final DateTime time;

  /// true = sent by us (tx), false = received (rx).
  final bool outgoing;
  final String transport;
  final String local;
  final String remote;

  /// Size on the wire in bytes (as reported by the engine).
  final int size;
  final String raw;
  final bool valid;
  final bool isRequest;
  final String startLine;

  /// Request method; for responses the CSeq method (may be empty).
  final String method;

  /// Response status code (0 for requests).
  final int status;
  final String reason;
  final String requestUri;
  final String callId;
  final int cseqNum;
  final String cseqMethod;
  final String fromUri;
  final String toUri;
  final String fromTag;
  final String toTag;
  final String branch;

  /// Unfolded headers in order: (original name, value).
  final List<(String, String)> headers;
  final String body;
  final bool keepAlive;

  bool get isResponse => valid && !isRequest && !keepAlive;
  bool get isError => status >= 400;

  /// Short label for arrows and lists: `INVITE` or `200 OK`.
  String get label {
    if (keepAlive) return 'keep-alive';
    if (!valid) return 'Malformed';
    if (isRequest) return method;
    return reason.isEmpty ? '$status' : '$status $reason';
  }

  /// Label with CSeq method for responses: `200 OK (INVITE)`.
  String get longLabel =>
      isResponse && cseqMethod.isNotEmpty ? '$label ($cseqMethod)' : label;

  String? header(String name) {
    final n = normalizeHeaderName(name);
    for (final h in headers) {
      if (normalizeHeaderName(h.$1) == n) return h.$2;
    }
    return null;
  }

  /// Approximate memory held by this message.
  int get cost => raw.length + 256;

  /// Parses [raw] into a message. Never throws.
  static SipMessage parse(
    String raw, {
    required int id,
    DateTime? time,
    bool outgoing = false,
    String transport = '',
    String local = '',
    String remote = '',
    int? size,
  }) {
    final t = time ?? DateTime.now();
    final sz = size ?? raw.length;
    SipMessage bad(String why) => SipMessage(
      id: id,
      time: t,
      outgoing: outgoing,
      transport: transport,
      local: local,
      remote: remote,
      size: sz,
      raw: raw,
      valid: false,
      isRequest: false,
      startLine: _clip(raw.split(RegExp(r'[\r\n]')).first, 120),
      reason: why,
    );
    try {
      final text = raw.length > kMaxParseBytes
          ? raw.substring(0, kMaxParseBytes)
          : raw;
      if (text.trim().isEmpty) {
        return SipMessage(
          id: id,
          time: t,
          outgoing: outgoing,
          transport: transport,
          local: local,
          remote: remote,
          size: sz,
          raw: raw,
          valid: false,
          isRequest: false,
          startLine: '',
          keepAlive: text.isNotEmpty,
          reason: 'keep-alive',
        );
      }
      // Skip leading CRLF keep-alives.
      final stripped = text.replaceFirst(RegExp(r'^[\r\n]+'), '');
      final split = RegExp(r'\r?\n\r?\n').firstMatch(stripped);
      final head = split == null ? stripped : stripped.substring(0, split.start);
      final body = split == null ? '' : stripped.substring(split.end);
      final lines = head.split(RegExp(r'\r?\n'));
      final start = lines.first.trim();
      if (start.isEmpty || start.codeUnits.any((c) => c < 9 || (c > 13 && c < 32))) {
        return bad('not a SIP message');
      }

      var isRequest = false;
      var method = '';
      var status = 0;
      var reason = '';
      var ruri = '';
      final resp = RegExp(r'^SIP/\d(?:\.\d)?\s+(\d{3})(?:\s+(.*))?$', caseSensitive: false).firstMatch(start);
      final req = RegExp(r'^([A-Za-z][A-Za-z0-9._!%*+~-]*)\s+(\S+)\s+SIP/\d(?:\.\d)?\s*$').firstMatch(start);
      if (resp != null) {
        status = int.parse(resp.group(1)!);
        reason = (resp.group(2) ?? '').trim();
      } else if (req != null) {
        isRequest = true;
        method = req.group(1)!.toUpperCase();
        ruri = req.group(2)!;
      } else {
        return bad('not a SIP message');
      }

      // Header unfolding.
      final hdrs = <(String, String)>[];
      for (var i = 1; i < lines.length; i++) {
        final l = lines[i];
        if (l.isEmpty) continue;
        if ((l.startsWith(' ') || l.startsWith('\t')) && hdrs.isNotEmpty) {
          final last = hdrs.removeLast();
          hdrs.add((last.$1, '${last.$2} ${l.trim()}'));
          continue;
        }
        final c = l.indexOf(':');
        if (c <= 0) continue;
        hdrs.add((l.substring(0, c).trim(), l.substring(c + 1).trim()));
      }
      String? h(String n) {
        for (final e in hdrs) {
          if (normalizeHeaderName(e.$1) == n) return e.$2;
        }
        return null;
      }

      final callId = (h('call-id') ?? '').trim();
      var cseqNum = 0;
      var cseqMethod = '';
      final cs = RegExp(r'^\s*(\d+)\s+(\S+)').firstMatch(h('cseq') ?? '');
      if (cs != null) {
        cseqNum = int.tryParse(cs.group(1)!) ?? 0;
        cseqMethod = cs.group(2)!.toUpperCase();
      }
      final from = h('from') ?? '';
      final to = h('to') ?? '';
      final via = h('via') ?? '';
      final br = RegExp(r'branch\s*=\s*([^;,\s>]+)', caseSensitive: false).firstMatch(via);

      return SipMessage(
        id: id,
        time: t,
        outgoing: outgoing,
        transport: transport,
        local: local,
        remote: remote,
        size: sz,
        raw: raw,
        valid: true,
        isRequest: isRequest,
        startLine: _clip(start, 200),
        method: isRequest ? method : cseqMethod,
        status: status,
        reason: reason,
        requestUri: ruri,
        callId: callId,
        cseqNum: cseqNum,
        cseqMethod: cseqMethod,
        fromUri: _uriOf(from),
        toUri: _uriOf(to),
        fromTag: _tagOf(from),
        toTag: _tagOf(to),
        branch: br?.group(1) ?? '',
        headers: hdrs,
        body: body,
      );
    } catch (_) {
      return bad('unparseable');
    }
  }

  static String _clip(String s, int n) => s.length <= n ? s : s.substring(0, n);

  static String _uriOf(String v) {
    final m = RegExp(r'<([^>]*)>').firstMatch(v);
    if (m != null) return m.group(1)!;
    final i = v.indexOf(';');
    return (i < 0 ? v : v.substring(0, i)).trim();
  }

  static String _tagOf(String v) =>
      RegExp(r'[;\s]tag\s*=\s*([^;,\s>]+)', caseSensitive: false).firstMatch(v)?.group(1) ?? '';
}
