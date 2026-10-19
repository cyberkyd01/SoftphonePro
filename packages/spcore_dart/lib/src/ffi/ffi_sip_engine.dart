import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:isolate';

import '../events.dart';
import '../json_sip_engine.dart';
import '../models/json_util.dart';
import '../models/models.dart';
import '../sip_engine.dart';
import 'spcore_library.dart';

class _Pending {
  _Pending(this.completer, this.method, this.timer);
  final Completer<Map<String, dynamic>> completer;
  final String method;
  final Timer? timer;
}

/// [SipEngine] backed by the native spcore library through dart:ffi.
///
/// Requests use the asynchronous `spc_request` only, so the isolate never
/// blocks. Responses are matched to requests by id; events go to [events].
class FfiSipEngine extends JsonSipEngine {
  FfiSipEngine({
    this.libraryPath,
    SpcoreLibrary? library,
    this.defaultTimeout = const Duration(seconds: 10),
    this.watchdogInterval = const Duration(seconds: 15),
    this.watchdogTimeout = const Duration(seconds: 5),
  }) : _lib = library;

  final String? libraryPath;
  final Duration defaultTimeout;

  /// Interval of the `core.ping` liveness check; null disables it.
  final Duration? watchdogInterval;
  final Duration watchdogTimeout;

  SpcoreLibrary? _lib;
  ReceivePort? _port;
  final StreamController<EngineEvent> _events =
      StreamController<EngineEvent>.broadcast(sync: true);
  final Map<int, _Pending> _pending = {};
  Timer? _watchdog;
  int _wdFailures = 0;
  bool _wdBusy = false;
  int _lastSeq = 0;
  bool _resyncing = false;
  bool _initialised = false;
  bool _disposed = false;
  bool _detached = false;

  /// True when `spc_init` reported the core was already running (hot restart).
  bool attachedToRunningCore = false;

  SpcoreLibrary get library => _lib ??= SpcoreLibrary.load(path: libraryPath);

  @override
  Stream<EngineEvent> get events => _events.stream;

  @override
  Future<void> init() async {
    if (_initialised) return;
    _checkNotDisposed();
    final lib = library;
    final r = lib.initDartApi(NativeApi.initializeApiDLData);
    if (r != 0) {
      throw EngineException(
        EngineError(
          code: ErrorCode.internal,
          status: r,
          message: 'Dart_InitializeApiDL failed ($r)',
        ),
      );
    }
    final port = ReceivePort('spcore');
    _port = port;
    port.listen(_onMessage);
    final h = lib.init(port.sendPort.nativePort);
    if (h < 0) {
      port.close();
      _port = null;
      throw EngineException(
        EngineError(
          code: ErrorCode.internal,
          status: h,
          message: 'spc_init failed ($h)',
        ),
      );
    }
    _initialised = true;
    _detached = false;
    if (h == 1) {
      attachedToRunningCore = true;
      _startWatchdog();
      unawaited(_resync(0, 0));
    }
  }

  void _checkNotDisposed() {
    if (_disposed) {
      throw const EngineException(
        EngineError(code: ErrorCode.disposed, message: 'engine disposed'),
      );
    }
  }

  @override
  Future<CoreStartResult> start(CoreConfig config) async {
    final r = await super.start(config);
    _startWatchdog();
    return r;
  }

  @override
  Future<void> stop({bool graceful = true}) async {
    _stopWatchdog();
    await super.stop(graceful: graceful);
  }

  @override
  Future<Map<String, dynamic>> request(
    String method,
    Map<String, dynamic> params, {
    Duration? timeout,
  }) async {
    _checkNotDisposed();
    if (!_initialised) {
      throw const EngineException(
        EngineError(code: ErrorCode.notStarted, message: 'call init() first'),
      );
    }
    final id = library.request(method, jsonEncode(params));
    if (id <= 0) {
      return Future.error(
        EngineException(
          EngineError(
            code: ErrorCode.internal,
            status: id,
            message: 'spc_request($method) failed ($id)',
          ),
        ),
      );
    }
    final c = Completer<Map<String, dynamic>>();
    final t = timeout ?? defaultTimeout;
    final timer = Timer(t, () {
      final p = _pending.remove(id);
      if (p != null && !p.completer.isCompleted) {
        p.completer.completeError(
          EngineException(
            EngineError(
              code: ErrorCode.timeout,
              message: '$method timed out after ${t.inMilliseconds} ms',
            ),
          ),
        );
      }
    });
    _pending[id] = _Pending(c, method, timer);
    return c.future;
  }

  void _onMessage(dynamic msg) {
    if (msg is! String) return;
    Map<String, dynamic> j;
    try {
      final d = jsonDecode(msg);
      if (d is! Map) return;
      j = asMap(d);
    } catch (_) {
      return;
    }
    switch (j['type']) {
      case 'response':
        _onResponse(j);
      case 'event':
        _onEvent(j);
    }
  }

  void _onResponse(Map<String, dynamic> j) {
    final p = _pending.remove(asInt(j['id']));
    if (p == null) return; // timed out earlier
    p.timer?.cancel();
    if (asBool(j['ok'])) {
      p.completer.complete(asMap(j['result']));
    } else {
      p.completer.completeError(
        EngineException(EngineError.fromJson(asMap(j['error']))),
      );
    }
  }

  void _onEvent(Map<String, dynamic> j) {
    final seq = asInt(j['seq']);
    final gap = _lastSeq != 0 && seq > _lastSeq + 1;
    final expected = _lastSeq + 1;
    if (seq > _lastSeq) _lastSeq = seq;
    final e = EngineEvent.fromJson(j);
    if (!_events.isClosed) _events.add(e);
    if (gap) unawaited(_resync(expected, seq));
  }

  Future<void> _resync(int expected, int got) async {
    if (_resyncing || _disposed) return;
    _resyncing = true;
    try {
      if (!_events.isClosed) {
        _events.add(ResyncNeededEvent(expectedSeq: expected, receivedSeq: got));
      }
      final s = await snapshot();
      if (s.seq > _lastSeq) _lastSeq = s.seq;
      if (!_events.isClosed) _events.add(ResyncSnapshotEvent(s));
    } catch (_) {
      // Surfaces through the watchdog / next gap.
    } finally {
      _resyncing = false;
    }
  }

  // ---- watchdog

  void _startWatchdog() {
    final iv = watchdogInterval;
    if (iv == null || _watchdog != null || _disposed) return;
    _watchdog = Timer.periodic(iv, (_) async {
      if (_wdBusy || _disposed) return;
      _wdBusy = true;
      try {
        await request('core.ping', const {}, timeout: watchdogTimeout);
        if (_wdFailures > 0) {
          _wdFailures = 0;
          if (!_events.isClosed) _events.add(EngineResponsiveEvent());
        }
      } on EngineException {
        _wdFailures++;
        if (!_events.isClosed) {
          _events.add(EngineUnresponsiveEvent(_wdFailures));
        }
      } finally {
        _wdBusy = false;
      }
    });
  }

  void _stopWatchdog() {
    _watchdog?.cancel();
    _watchdog = null;
    _wdFailures = 0;
  }

  /// Stops event delivery to this isolate (`spc_set_event_port(0)`); events
  /// are buffered natively until a new engine attaches. Call before isolate
  /// shutdown / on `AppLifecycleState.detached`.
  void detach() {
    if (_detached || _lib == null || !_initialised) return;
    _detached = true;
    _lib!.setEventPort(0);
  }

  @override
  Future<void> dispose() async {
    if (_disposed) return;
    _stopWatchdog();
    detach();
    _disposed = true;
    _port?.close();
    _port = null;
    for (final p in _pending.values) {
      p.timer?.cancel();
      if (!p.completer.isCompleted) {
        p.completer.completeError(
          const EngineException(
            EngineError(code: ErrorCode.disposed, message: 'engine disposed'),
          ),
        );
      }
    }
    _pending.clear();
    await Future<void>.delayed(Duration.zero);
    await _events.close();
  }
}
