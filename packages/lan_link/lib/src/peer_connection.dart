import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:async/async.dart';

import 'crypto.dart';
import 'identity.dart';
import 'messages.dart';
import 'util.dart';

/// Maximum size of an encrypted binary WebSocket frame we accept.
const int maxWireFrame =
    chunkHeader + maxChunkData + 1 + SecureSession.overhead + 64;

const int _tJson = 1;
const int _tChunk = 2;

/// An authenticated, encrypted connection to one peer.
class PeerConnection {
  PeerConnection({
    required this.ws,
    required this.session,
    required this.peerHello,
    required this.initiator,
    required this.mode,
    required this.remoteAddress,
    required StreamQueue<dynamic> queue,
  }) : _queue = queue;

  final WebSocket ws;
  final SecureSession session;
  final Hello peerHello;
  final bool initiator;
  final HandshakeMode mode;
  final InternetAddress? remoteAddress;
  final StreamQueue<dynamic> _queue;

  String get peerId => peerHello.deviceId;

  /// deviceId of whoever opened this TCP connection (for tie-breaking).
  String? initiatorId;

  void Function(AppMessage msg)? onMessage;
  Future<void> Function(FileChunk chunk)? onChunk;
  void Function(Object? error)? onClosed;

  final _send = SerialQueue();
  final _limiter = RateLimiter(2000, const Duration(seconds: 1));
  final _done = Completer<void>();
  StreamSubscription<dynamic>? _sub;
  bool _closed = false;
  bool _closing = false;
  bool _closeStarted = false;

  bool get isClosed => _closed || _closing;
  Future<void> get done => _done.future;

  void start() {
    ws.pingInterval = const Duration(seconds: 10);
    ws.done.then((_) {}, onError: (Object _) {});
    _sub = _queue.rest.listen((data) async {
      _sub?.pause();
      try {
        await _handle(data);
      } catch (e) {
        await close(1008, 'protocol error');
        _finish(e);
      } finally {
        if (!_closed) _sub?.resume();
      }
    }, onDone: () => _finish(null), onError: (e) => _finish(e));
    unawaited(ws.done.then((_) => _finish(null), onError: (e) => _finish(e)));
  }

  void _finish(Object? err) {
    if (_done.isCompleted) return;
    _closed = true;
    _closing = true;
    if (!_done.isCompleted) {
      _done.complete();
      onClosed?.call(err);
    }
  }

  Future<void> _handle(dynamic data) async {
    if (data is! List<int>) return; // text frames are ignored after handshake
    if (data.length > maxWireFrame)
      throw const FormatException('frame too big');
    final pt = await session.open(data);
    if (pt.isEmpty) throw const FormatException('empty');
    final body = Uint8List.sublistView(pt, 1);
    switch (pt[0]) {
      case _tJson:
        if (!_limiter.allow()) throw const FormatException('rate limit');
        final msg = await parseMessage(body);
        if (msg != null) onMessage?.call(msg);
      case _tChunk:
        await onChunk?.call(FileChunk.decode(body));
      default:
        break;
    }
  }

  Future<void> _sendRaw(int type, List<int> body) {
    // Never start a write once close was initiated; fail the future instead.
    if (_closing || _closed) {
      return Future.error(PeerOfflineException(peerId));
    }
    return _send.run(() async {
      if (_closed || _closing && _closeStarted) {
        throw PeerOfflineException(peerId);
      }
      final frame = await session.seal(concatBytes([
        [type],
        body
      ]));
      // Re-check after the async gap: the socket may have been closed.
      if (_closed || _closeStarted || ws.readyState != WebSocket.open) {
        throw PeerOfflineException(peerId);
      }
      try {
        ws.add(frame);
      } catch (_) {
        throw PeerOfflineException(peerId);
      }
    });
  }

  Future<void> send(AppMessage m) => _sendRaw(_tJson, m.encode());

  Future<void> sendChunk(FileChunk c) => _sendRaw(_tChunk, c.encode());

  Future<void>? _closeFuture;

  /// Graceful close: frames queued before this call are flushed first, frames
  /// sent afterwards fail. Never throws.
  Future<void> close([int code = 1000, String reason = '']) =>
      _closeFuture ??= _doClose(code, reason);

  Future<void> _doClose(int code, String reason) async {
    _closing = true; // new sends are refused from now on
    try {
      await _send.run(() async {
        _closeStarted = true;
        ws.pingInterval = null;
        await safeCloseSocket(ws, code, reason);
      });
    } catch (_) {}
    _closed = true;
    // Do not cancel the socket subscription here: cancelling destroys the
    // socket and would race with a close frame that is still being written.
    _finish(null);
  }
}

/// Closes [ws] without ever throwing or leaking an async error, and without
/// waiting longer than [timeout] for the peer's close frame.
Future<void> safeCloseSocket(WebSocket ws,
    [int? code,
    String? reason,
    Duration timeout = const Duration(seconds: 2)]) async {
  ws.done.then((_) {}, onError: (Object _) {});
  try {
    if (ws.readyState == WebSocket.closed) return;
    final f = code == null ? ws.close() : ws.close(code, reason);
    f.then((_) {}, onError: (Object _) {});
    await f.timeout(timeout);
  } catch (_) {}
}

// ---------------------------------------------------------------------------
// Handshake over WebSocket
// ---------------------------------------------------------------------------

const int _maxHandshakeText = 4096;

String _errText(String code) => switch (code) {
      'unknown_device' => 'Unknown device — pair first',
      'rate_limited' => 'Too many attempts, try again later',
      'busy' => 'Device is busy',
      'key_mismatch' => 'Device key changed - pair again to trust it',
      _ => 'Handshake failed ($code)',
    };

Future<dynamic> _next(StreamQueue<dynamic> q, Duration t) async {
  try {
    return await q.next.timeout(t);
  } on TimeoutException {
    throw HandshakeException('timeout', 'Handshake timed out');
  } on StateError {
    throw HandshakeException('closed', 'Connection closed during handshake');
  }
}

Js _textFrame(dynamic d) {
  if (d is! String)
    throw HandshakeException('bad_hello', 'Expected text frame');
  try {
    final j = Js.parse(d, maxLength: _maxHandshakeText);
    if (j.m['t'] == 'error') {
      final c = j.m['code'];
      final code = c is String && RegExp(r'^[a-z_]{1,32}$').hasMatch(c)
          ? c
          : 'remote_error';
      throw HandshakeException(code, _errText(code));
    }
    return j;
  } on FormatException {
    throw HandshakeException('bad_hello', 'Malformed handshake');
  }
}

Future<void> _sendError(WebSocket ws, HandshakeException e) async {
  try {
    ws.add(jsonEncode({'t': 'error', 'code': e.code, 'message': e.message}));
    await safeCloseSocket(ws, 1008, e.code);
  } catch (_) {}
}

/// Client side. [expectedPeerEd] must be set for connect mode.
Future<PeerConnection> handshakeAsInitiator(
  WebSocket ws,
  LocalIdentity identity,
  HandshakeMode mode, {
  List<int>? expectedPeerEd,
  InternetAddress? remote,
  Duration timeout = const Duration(seconds: 10),
}) async {
  ws.done.then((_) {}, onError: (Object _) {});
  final q = StreamQueue<dynamic>(ws);
  try {
    final hs = await Handshake.create(
        identity: identity,
        initiator: true,
        mode: mode,
        expectedPeerEd: expectedPeerEd);
    ws.add(jsonEncode(hs.ownHello.toJson()));
    final j = _textFrame(await _next(q, timeout));
    if (j.m['t'] != 'hello') {
      throw HandshakeException('bad_hello', 'Expected hello');
    }
    try {
      await hs.setPeerHello(Hello.fromJson(j));
    } on FormatException {
      throw HandshakeException('bad_hello', 'Malformed hello');
    }
    ws.add(jsonEncode({'t': 'auth', 'sig': b64Encode(await hs.makeAuth())}));
    final a = _textFrame(await _next(q, timeout));
    if (a.m['t'] != 'auth')
      throw HandshakeException('bad_hello', 'Expected auth');
    final session =
        await hs.finish(b64Decode(a.str('sig', max: 128), length: 64));
    return PeerConnection(
        ws: ws,
        session: session,
        peerHello: hs.peerHello,
        initiator: true,
        mode: mode,
        remoteAddress: remote,
        queue: q)
      ..initiatorId = identity.deviceId;
  } on HandshakeException {
    await _closeQuiet(ws, q);
    rethrow;
  } on FormatException {
    await _closeQuiet(ws, q);
    throw HandshakeException('bad_hello', 'Malformed handshake');
  } catch (e) {
    await _closeQuiet(ws, q);
    rethrow;
  }
}

Future<void> _closeQuiet(WebSocket ws, StreamQueue<dynamic> q) async {
  // Close first (flushes pending writes), only then drop the subscription.
  await safeCloseSocket(ws, 1008, null, const Duration(seconds: 1));
  try {
    unawaited(Future.sync(() => q.cancel(immediate: true))
        .then((_) {}, onError: (Object _) {}));
  } catch (_) {}
}

/// Server side. [policy] receives the initiator's Hello and may return a
/// [HandshakeException] to reject (unknown device, rate limit...). If it
/// returns null, [expectedPeerEdFor] decides the expected key (connect mode).
Future<PeerConnection> handshakeAsResponder(
  WebSocket ws,
  LocalIdentity identity, {
  required Future<HandshakeException?> Function(Hello hello) policy,
  required List<int>? Function(Hello hello) expectedPeerEdFor,
  InternetAddress? remote,
  Duration timeout = const Duration(seconds: 10),
}) async {
  ws.done.then((_) {}, onError: (Object _) {});
  final q = StreamQueue<dynamic>(ws);
  try {
    final j = _textFrame(await _next(q, timeout));
    if (j.m['t'] != 'hello') {
      throw HandshakeException('bad_hello', 'Expected hello');
    }
    final Hello theirs;
    try {
      theirs = Hello.fromJson(j);
    } on FormatException {
      throw HandshakeException('bad_hello', 'Malformed hello');
    }
    final rej = await policy(theirs);
    if (rej != null) throw rej;
    final hs = await Handshake.create(
        identity: identity,
        initiator: false,
        mode: theirs.mode,
        expectedPeerEd: expectedPeerEdFor(theirs));
    await hs.setPeerHello(theirs);
    ws.add(jsonEncode(hs.ownHello.toJson()));
    ws.add(jsonEncode({'t': 'auth', 'sig': b64Encode(await hs.makeAuth())}));
    final a = _textFrame(await _next(q, timeout));
    if (a.m['t'] != 'auth')
      throw HandshakeException('bad_hello', 'Expected auth');
    final session =
        await hs.finish(b64Decode(a.str('sig', max: 128), length: 64));
    return PeerConnection(
        ws: ws,
        session: session,
        peerHello: theirs,
        initiator: false,
        mode: theirs.mode,
        remoteAddress: remote,
        queue: q)
      ..initiatorId = theirs.deviceId;
  } on HandshakeException catch (e) {
    await _sendError(ws, e);
    unawaited(Future.sync(() => q.cancel(immediate: true))
        .then((_) {}, onError: (Object _) {}));
    rethrow;
  } on FormatException {
    final e = HandshakeException('bad_hello', 'Malformed handshake');
    await _sendError(ws, e);
    throw e;
  } catch (e) {
    await _closeQuiet(ws, q);
    rethrow;
  }
}

// ---------------------------------------------------------------------------
// Server
// ---------------------------------------------------------------------------

/// HTTP + WebSocket listener: `GET /spp/v1/info`, upgrade at `/spp/v1/ws`.
class LanLinkServer {
  LanLinkServer({
    required this.infoProvider,
    required this.onSocket,
    this.bindAddress,
    this.port = 0,
    this.maxConnections = 32,
  });

  final Map<String, dynamic> Function() infoProvider;
  final void Function(WebSocket ws, InternetAddress remote) onSocket;
  final InternetAddress? bindAddress;
  final int port;
  final int maxConnections;

  HttpServer? _server;
  int _active = 0;
  final Map<String, RateLimiter> _infoLimit = {};

  int get boundPort => _server!.port;

  Future<void> start() async {
    _server = await HttpServer.bind(
        bindAddress ?? InternetAddress.anyIPv4, port,
        shared: false);
    _server!.idleTimeout = const Duration(seconds: 15);
    _server!.listen(_onRequest, onError: (_) {});
  }

  Future<void> stop() async {
    await _server?.close(force: true);
    _server = null;
  }

  Future<void> _onRequest(HttpRequest req) async {
    try {
      final path = req.uri.path;
      if (req.method == 'GET' && path == '/spp/v1/info') {
        final ip = req.connectionInfo?.remoteAddress.address ?? '';
        final rl = _infoLimit.putIfAbsent(
            ip, () => RateLimiter(30, const Duration(seconds: 10)));
        if (_infoLimit.length > 512) _infoLimit.clear();
        if (!rl.allow()) {
          req.response.statusCode = HttpStatus.tooManyRequests;
          await req.response.close();
          return;
        }
        req.response.headers.contentType = ContentType.json;
        req.response.write(jsonEncode(infoProvider()));
        await req.response.close();
      } else if (path == '/spp/v1/ws' &&
          WebSocketTransformer.isUpgradeRequest(req)) {
        if (_active >= maxConnections) {
          req.response.statusCode = HttpStatus.serviceUnavailable;
          await req.response.close();
          return;
        }
        final remote = req.connectionInfo!.remoteAddress;
        final ws = await WebSocketTransformer.upgrade(req,
            compression: CompressionOptions.compressionOff);
        _active++;
        unawaited(ws.done.whenComplete(() => _active--).catchError((_) {}));
        onSocket(ws, remote);
      } else {
        req.response.statusCode = HttpStatus.notFound;
        await req.response.close();
      }
    } catch (_) {
      try {
        await req.response.close();
      } catch (_) {}
    }
  }
}
