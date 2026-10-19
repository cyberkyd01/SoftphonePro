import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'automation_auth.dart';

/// A request after authentication, origin and size checks.
class ApiRequest {
  ApiRequest({required this.method, required this.path, required this.query, this.body});
  final String method;

  /// Path without the query string and without a trailing slash.
  final String path;
  final Map<String, String> query;

  /// Decoded JSON body (null when there was none).
  final Object? body;

  List<String> get segments => path.split('/').where((s) => s.isNotEmpty).toList();

  /// The body as an object; throws a 400 [ApiException] otherwise.
  Map<String, dynamic> get json {
    final b = body;
    if (b == null) return const {};
    if (b is! Map) throw ApiException(400, 'invalid_body', 'The request body must be a JSON object');
    return Map<String, dynamic>.from(b);
  }
}

/// A reply: JSON body, or a Server-Sent Events stream of preformatted frames.
class ApiResponse {
  ApiResponse(this.status, [this.body]) : sse = null;
  ApiResponse.sse(Stream<String> this.sse) : status = 200, body = null;
  final int status;
  final Object? body;
  final Stream<String>? sse;
}

/// Thrown by handlers; becomes `{"error": {"code", "message"}}`.
class ApiException implements Exception {
  ApiException(this.status, this.code, this.message);
  final int status;
  final String code;
  final String message;
  @override
  String toString() => '$status $code: $message';
}

typedef ApiHandler = Future<ApiResponse> Function(ApiRequest request);

/// A tiny loopback-only HTTP/1.1 server: bearer-token auth, origin allow
/// list, request size limit, JSON errors and SSE. Routing is done by the
/// [ApiHandler].
class AutomationServer {
  AutomationServer({
    required this.token,
    required this.handler,
    List<String> origins = const [],
    this.maxBodyBytes = 64 * 1024,
    this.maxStreams = 16,
    this.heartbeat = const Duration(seconds: 15),
  }) : origins = {
         for (final o in origins)
           if (normalizeOrigin(o) case final n?) n,
       }.toList();

  final String token;
  final ApiHandler handler;
  final List<String> origins;
  final int maxBodyBytes;
  final int maxStreams;
  final Duration heartbeat;

  HttpServer? _server;
  final Set<HttpResponse> _streams = {};

  int get port => _server?.port ?? 0;
  bool get running => _server != null;
  int get streamCount => _streams.length;

  /// Binds to 127.0.0.1 only; [port] 0 picks a free port.
  Future<void> start(int port) async {
    final s = await HttpServer.bind(InternetAddress.loopbackIPv4, port);
    s.idleTimeout = const Duration(seconds: 30);
    _server = s;
    s.listen(_onRequest, onError: (Object _) {});
  }

  Future<void> stop() async {
    final s = _server;
    _server = null;
    for (final r in _streams.toList()) {
      try {
        await r.close();
      } catch (_) {}
    }
    _streams.clear();
    await s?.close(force: true);
  }

  Future<void> _onRequest(HttpRequest req) async {
    final res = req.response;
    try {
      await _serve(req);
    } on ApiException catch (e) {
      _writeJson(req, e.status, _errorBody(e.code, e.message), origin: _allowedOrigin(req));
    } catch (e) {
      try {
        _writeJson(req, 500, _errorBody('internal_error', 'Internal error'), origin: _allowedOrigin(req));
      } catch (_) {
        await res.close().catchError((_) {});
      }
    }
  }

  /// The request's Origin when it is on the allow list (so browsers may read
  /// error bodies too), else null.
  String? _allowedOrigin(HttpRequest req) {
    final o = req.headers.value('origin');
    if (o == null) return null;
    final n = normalizeOrigin(o);
    return n != null && origins.contains(n) ? o : null;
  }

  Map<String, Object?> _errorBody(String code, String message) => {
    'error': {'code': code, 'message': message},
  };

  Future<void> _serve(HttpRequest req) async {
    // DNS rebinding: only requests addressed to this machine.
    if (!isLoopbackHost(req.headers.value(HttpHeaders.hostHeader), port)) {
      throw ApiException(403, 'bad_host', 'Requests must be addressed to localhost or 127.0.0.1');
    }
    final origin = req.headers.value('origin');
    String? allowedOrigin;
    if (origin != null) {
      final n = normalizeOrigin(origin);
      if (n == null || !origins.contains(n)) {
        throw ApiException(403, 'origin_not_allowed', 'This origin is not allowed to use the API');
      }
      allowedOrigin = origin;
    }
    if (req.method == 'OPTIONS') {
      // CORS preflight; carries no credentials by design.
      if (allowedOrigin == null) {
        throw ApiException(403, 'origin_not_allowed', 'Preflight requires an allowed Origin');
      }
      req.response.statusCode = 204;
      _cors(req.response, allowedOrigin);
      req.response.headers.set('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
      req.response.headers.set('Access-Control-Allow-Headers', 'Authorization, Content-Type');
      req.response.headers.set('Access-Control-Max-Age', '600');
      await req.response.close();
      return;
    }
    if (!tokenMatches(token, bearerToken(req.headers.value(HttpHeaders.authorizationHeader)))) {
      req.response.headers.set(HttpHeaders.wwwAuthenticateHeader, 'Bearer realm="SoftphonePro"');
      throw ApiException(401, 'unauthorized', 'Missing or invalid bearer token');
    }

    final declared = req.contentLength;
    if (declared > maxBodyBytes) {
      throw ApiException(413, 'payload_too_large', 'Request body exceeds $maxBodyBytes bytes');
    }
    Object? body;
    if (req.method == 'POST' || req.method == 'PUT') {
      final bytes = <int>[];
      await for (final chunk in req) {
        bytes.addAll(chunk);
        if (bytes.length > maxBodyBytes) {
          throw ApiException(413, 'payload_too_large', 'Request body exceeds $maxBodyBytes bytes');
        }
      }
      if (bytes.isNotEmpty) {
        try {
          body = jsonDecode(utf8.decode(bytes));
        } on FormatException {
          throw ApiException(400, 'invalid_json', 'The request body is not valid JSON');
        }
      }
    }
    var path = req.uri.path;
    if (path.length > 1 && path.endsWith('/')) path = path.substring(0, path.length - 1);
    final r = await handler(
      ApiRequest(
        method: req.method,
        path: path,
        query: req.uri.queryParameters,
        body: body,
      ),
    );
    if (r.sse != null) {
      await _stream(req, r.sse!, allowedOrigin);
    } else {
      _writeJson(req, r.status, r.body, origin: allowedOrigin);
    }
  }

  void _cors(HttpResponse res, String origin) {
    res.headers.set('Access-Control-Allow-Origin', origin);
    res.headers.set('Vary', 'Origin');
  }

  void _writeJson(HttpRequest req, int status, Object? body, {String? origin}) {
    final res = req.response;
    res.statusCode = status;
    if (origin != null) _cors(res, origin);
    res.headers.set(HttpHeaders.cacheControlHeader, 'no-store');
    if (status != 204) {
      res.headers.contentType = ContentType('application', 'json', charset: 'utf-8');
      res.write(jsonEncode(body ?? const {}));
    }
    unawaited(res.close().catchError((_) {}));
  }

  Future<void> _stream(HttpRequest req, Stream<String> frames, String? origin) async {
    final res = req.response;
    if (_streams.length >= maxStreams) {
      frames.listen(null).cancel();
      throw ApiException(429, 'too_many_streams', 'Too many open event streams');
    }
    res.statusCode = 200;
    res.bufferOutput = false;
    res.headers.contentType = ContentType('text', 'event-stream', charset: 'utf-8');
    res.headers.set(HttpHeaders.cacheControlHeader, 'no-cache, no-store');
    res.headers.set('X-Accel-Buffering', 'no');
    if (origin != null) _cors(res, origin);
    _streams.add(res);
    final done = Completer<void>();
    late final StreamSubscription<String> sub;
    Timer? beat;
    void finish() {
      if (done.isCompleted) return;
      beat?.cancel();
      sub.cancel();
      _streams.remove(res);
      done.complete();
    }

    void write(String s) {
      try {
        res.write(s);
      } catch (_) {
        finish();
      }
    }

    write(': connected\n\n');
    sub = frames.listen(write, onDone: finish, onError: (Object _) => finish());
    beat = Timer.periodic(heartbeat, (_) => write(': ping\n\n'));
    // The client closing the socket completes flush() with an error.
    unawaited(res.done.then((_) => finish(), onError: (Object _) => finish()));
    await done.future;
    try {
      await res.close();
    } catch (_) {}
  }
}
