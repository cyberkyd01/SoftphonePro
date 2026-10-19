import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:spcore_dart/spcore_dart.dart';
import 'package:spcore_dart/testing.dart';

final String pbxHost = Platform.environment['PBX_HOST'] ?? '127.0.0.1';

/// Returns a skip reason, or null when integration tests can run.
Future<String?> integrationSkipReason() async {
  final lib = Platform.environment['SPCORE_LIB'];
  if (lib == null || lib.isEmpty) return 'SPCORE_LIB not set';
  if (!File(lib).existsSync()) return 'SPCORE_LIB=$lib does not exist';
  try {
    final s = await Socket.connect(
      pbxHost,
      5060,
      timeout: const Duration(seconds: 1),
    );
    s.destroy();
  } catch (_) {
    return 'PBX $pbxHost:5060 not reachable (TCP)';
  }
  return null;
}

CoreConfig testCoreConfig({int statsMs = 0}) => CoreConfig(
  logLevel: 3,
  stunServers: const [],
  nameservers: const [],
  statsIntervalMs: statsMs,
  publicAddr: pbxHost == '127.0.0.1' ? '127.0.0.1' : null,
  transports: const TransportConfig(
    udp: TransportPort(port: 0),
    tcp: TransportPort(port: 0),
    tls: TlsTransportConfig(port: 0),
  ),
  media: const MediaConfig(noAudioDevice: true, rtpPort: 0),
);

AccountConfig pbxAccount(
  String ext, {
  AccTransport transport = AccTransport.udp,
  bool register = true,
}) => AccountConfig(
  uid: 'acc$ext-${transport.wire}',
  username: ext,
  password: 'pass$ext',
  domain: pbxHost,
  transport: transport,
  register: register,
  regExpires: 60,
);

/// Records engine events and lets tests await specific ones.
class EventLog {
  EventLog(Stream<EngineEvent> events) {
    _sub = events.listen((e) {
      all.add(e);
      for (final w in List.of(_waiters)) {
        w(e);
      }
    });
  }
  final List<EngineEvent> all = [];
  final List<void Function(EngineEvent)> _waiters = [];
  late final StreamSubscription<EngineEvent> _sub;

  Future<void> close() => _sub.cancel();

  /// Resolves with the first (past or future) event of type [T] matching
  /// [where].
  Future<T> wait<T extends EngineEvent>({
    bool Function(T e)? where,
    Duration timeout = const Duration(seconds: 15),
    String? what,
  }) {
    bool ok(EngineEvent e) => e is T && (where == null || where(e));
    for (final e in all) {
      if (ok(e)) return Future.value(e as T);
    }
    final c = Completer<T>();
    void w(EngineEvent e) {
      if (!c.isCompleted && ok(e)) c.complete(e as T);
    }

    _waiters.add(w);
    return c.future
        .timeout(
          timeout,
          onTimeout: () {
            throw TimeoutException('waiting for ${what ?? T}');
          },
        )
        .whenComplete(() => _waiters.remove(w));
  }

  /// Like [wait] but only considers events arriving after this call.
  Future<T> next<T extends EngineEvent>({
    bool Function(T e)? where,
    Duration timeout = const Duration(seconds: 15),
    String? what,
  }) {
    final skip = all.length;
    final c = Completer<T>();
    void w(EngineEvent e) {
      if (!c.isCompleted && e is T && (where == null || where(e))) {
        c.complete(e);
      }
    }

    _waiters.add(w);
    // Anything already past [skip] cannot exist yet (sync), so just wait.
    assert(skip == all.length);
    return c.future
        .timeout(
          timeout,
          onTimeout: () {
            throw TimeoutException('waiting for ${what ?? T}');
          },
        )
        .whenComplete(() => _waiters.remove(w));
  }

  Future<CallStateEvent> callState(int cid, CallState s) =>
      wait<CallStateEvent>(
        where: (e) => e.cid == cid && e.state == s,
        what: 'call $cid -> $s',
      );

  Future<AccountRegEvent> registered(String uid) => wait<AccountRegEvent>(
    where: (e) =>
        e.account.uid == uid && e.account.regState == RegState.registered,
    what: 'account $uid registered',
  );
}

/// An engine in a second OS process (tool/peer.dart), driven over JSON lines.
class RemoteSipEngine extends JsonSipEngine {
  RemoteSipEngine._(this._proc);
  final Process _proc;
  final _events = StreamController<EngineEvent>.broadcast(sync: true);
  final _pending = <int, Completer<Map<String, dynamic>>>{};
  final _ready = Completer<void>();
  int _id = 0;

  static Future<RemoteSipEngine> spawn() async {
    final proc = await Process.start(
      Platform.resolvedExecutable,
      ['run', 'tool/peer.dart'],
      environment: {...Platform.environment},
    );
    final r = RemoteSipEngine._(proc);
    proc.stdout
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .listen(r._onLine);
    proc.stderr
        .transform(utf8.decoder)
        .listen((s) => stderr.write('[peer] $s'));
    await r._ready.future.timeout(const Duration(seconds: 60));
    return r;
  }

  void _onLine(String line) {
    Map<String, dynamic> j;
    try {
      j = jsonDecode(line) as Map<String, dynamic>;
    } catch (_) {
      return;
    }
    switch (j['type']) {
      case 'peer.ready':
        _ready.complete();
      case 'peer.error':
        if (!_ready.isCompleted) {
          _ready.completeError(StateError('${j['message']}'));
        }
      case 'response':
        final c = _pending.remove(j['id']);
        if (c == null) return;
        if (j['ok'] == true) {
          c.complete((j['result'] as Map).cast<String, dynamic>());
        } else {
          c.completeError(
            EngineException(
              EngineError.fromJson((j['error'] as Map).cast<String, dynamic>()),
            ),
          );
        }
      case 'event':
        _events.add(EngineEvent.fromJson(j));
    }
  }

  @override
  Stream<EngineEvent> get events => _events.stream;

  @override
  Future<void> init() async {}

  @override
  Future<Map<String, dynamic>> request(
    String method,
    Map<String, dynamic> params, {
    Duration? timeout,
  }) {
    final id = ++_id;
    final c = Completer<Map<String, dynamic>>();
    _pending[id] = c;
    _proc.stdin.writeln(
      jsonEncode({'id': id, 'method': method, 'params': params}),
    );
    return c.future.timeout(timeout ?? const Duration(seconds: 20));
  }

  @override
  Future<void> dispose() async {
    try {
      await request('peer.exit', {}, timeout: const Duration(seconds: 10));
    } catch (_) {
      _proc.kill();
    }
    await _events.close();
  }
}

/// Writes a mono PCM16 sine WAV and returns its path.
String writeToneWav(
  String dir, {
  int hz = 440,
  int rate = 8000,
  double secs = 5,
}) {
  final n = (rate * secs).round();
  final data = ByteData(44 + n * 2);
  void s(int o, String v) {
    for (var i = 0; i < v.length; i++) {
      data.setUint8(o + i, v.codeUnitAt(i));
    }
  }

  s(0, 'RIFF');
  data.setUint32(4, 36 + n * 2, Endian.little);
  s(8, 'WAVEfmt ');
  data.setUint32(16, 16, Endian.little);
  data.setUint16(20, 1, Endian.little);
  data.setUint16(22, 1, Endian.little);
  data.setUint32(24, rate, Endian.little);
  data.setUint32(28, rate * 2, Endian.little);
  data.setUint16(32, 2, Endian.little);
  data.setUint16(34, 16, Endian.little);
  s(36, 'data');
  data.setUint32(40, n * 2, Endian.little);
  for (var i = 0; i < n; i++) {
    data.setInt16(
      44 + i * 2,
      (12000 * math.sin(2 * math.pi * hz * i / rate)).round(),
      Endian.little,
    );
  }
  final f = File('$dir/tone_${hz}_$rate.wav')
    ..writeAsBytesSync(data.buffer.asUint8List());
  return f.path;
}

/// Digits received by extension 602 for [ext] (via docker), or null when
/// docker/the container is unavailable.
Future<String?> pbxDtmf(String ext) async {
  try {
    final r = await Process.run('docker', [
      'exec',
      'softphonepro-pbx',
      'cat',
      '/var/log/asterisk/dtmf_$ext.txt',
    ]);
    if (r.exitCode != 0) return null;
    return (r.stdout as String).trim();
  } catch (_) {
    return null;
  }
}

/// Starts an in-process engine on the real library.
Future<FfiSipEngine> startLocalEngine({int statsMs = 0}) async {
  final e = FfiSipEngine(watchdogInterval: const Duration(seconds: 15));
  await e.init();
  await e.start(testCoreConfig(statsMs: statsMs));
  return e;
}

/// Convenience: attach an invariant checker.
InvariantChecker watchInvariants(SipEngine e) =>
    InvariantChecker(allowUnknownCids: false)..attach(e.events);
