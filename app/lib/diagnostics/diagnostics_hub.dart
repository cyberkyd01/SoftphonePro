import 'dart:async';
import 'dart:collection';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spcore_dart/spcore_dart.dart';

import '../services/engine_controller.dart';
import '../services/settings_controller.dart';

// ---------------------------------------------------------------- logs

class LogLine {
  const LogLine(this.time, this.level, this.msg);
  final DateTime time;
  final int level;
  final String msg;

  static const names = ['none', 'error', 'warn', 'info', 'debug', 'trace', 'verbose'];
  String get levelName => level >= 0 && level < names.length ? names[level] : 'L$level';
}

const int kLogMax = 3000;

class LogState {
  const LogState({this.version = 0, this.count = 0});
  final int version;
  final int count;
}

/// In-memory ring of forwarded engine `log` events.
class LogsController extends Notifier<LogState> {
  final ListQueue<LogLine> _buf = ListQueue();
  int _version = 0;
  Timer? _reapply;

  @override
  LogState build() {
    final sub = ref.read(engineProvider.notifier).events.listen((e) {
      if (e is LogEvent) ingest(e);
    });
    // The engine controller derives "forward" from the level; honour an
    // explicit user preference on top of it.
    ref.listen<EngineState>(engineProvider, (p, n) {
      if (n.running && n.generation != p?.generation && forward) _reapplyLater();
    });
    ref.listen(settingsProvider, (p, n) {
      if (p == null) return;
      if (p.logLevel != n.logLevel || p.toJson()['logForward'] != n.toJson()['logForward']) {
        _reapplyLater();
      }
    });
    ref.onDispose(() {
      sub.cancel();
      _reapply?.cancel();
    });
    return const LogState();
  }

  List<LogLine> get lines => List.unmodifiable(_buf);

  bool get forward {
    final s = ref.read(settingsProvider);
    return s.toJson()['logForward'] == true || s.logLevel >= 4;
  }

  void ingest(LogEvent e) {
    _buf.addLast(LogLine(e.ts > 0 ? DateTime.fromMillisecondsSinceEpoch(e.ts) : DateTime.now(), e.level, e.msg));
    while (_buf.length > kLogMax) {
      _buf.removeFirst();
    }
    _flush();
  }

  void _flush() {
    _version++;
    state = LogState(version: _version, count: _buf.length);
  }

  void clear() {
    _buf.clear();
    _flush();
  }

  Future<void> setForward(bool v) async {
    final s = ref.read(settingsProvider);
    await ref.read(settingsProvider.notifier).update({
      'logForward': v,
      if (v && s.logLevel < 3) 'logLevel': 3,
    });
    _reapplyLater();
  }

  Future<void> setLevel(int level) =>
      ref.read(settingsProvider.notifier).update({'logLevel': level.clamp(0, 6)});

  void _reapplyLater() {
    _reapply?.cancel();
    _reapply = Timer(const Duration(milliseconds: 250), () async {
      final c = ref.read(engineProvider.notifier);
      if (!c.hasEngine) return;
      try {
        final s = ref.read(settingsProvider);
        await c.engine.setLogLevel(s.logLevel, forward: forward);
      } catch (_) {}
    });
  }
}

final logsProvider = NotifierProvider<LogsController, LogState>(LogsController.new);

// ---------------------------------------------------------------- transports / TLS

class HubState {
  const HubState({this.transports = const {}, this.tlsRejects = const {}});

  /// Latest `transport.state` per remote endpoint key.
  final Map<String, TransportStateInfo> transports;

  /// Certificates rejected during handshakes, by SHA-256.
  final Map<String, TlsVerifyInfo> tlsRejects;

  /// Latest connected TLS transport info for a host (substring match on remote).
  TransportStateInfo? tlsFor(String host) {
    TransportStateInfo? any;
    for (final t in transports.values) {
      if (!t.transport.toLowerCase().startsWith('tls') || t.tls == null) continue;
      if (host.isNotEmpty && t.remote.contains(host)) return t;
      any ??= t;
    }
    return any;
  }

  List<TlsVerifyInfo> rejectsFor(String host) =>
      tlsRejects.values.where((r) => r.host == host || r.host.isEmpty || host.isEmpty || r.host.contains(host) || host.contains(r.host)).toList();
}

/// Remembers transport states and TLS verification failures for the wizard.
class DiagnosticsHub extends Notifier<HubState> {
  @override
  HubState build() {
    final sub = ref.read(engineProvider.notifier).events.listen(ingest);
    ref.onDispose(sub.cancel);
    return const HubState();
  }

  /// Engine entry point; also a test seam.
  void ingest(EngineEvent e) {
    if (e is TransportStateEvent) {
      final key = '${e.info.transport}|${e.info.remote}';
      final next = Map<String, TransportStateInfo>.from(state.transports);
      if (e.info.state == TransportStateKind.shutdown || e.info.state == TransportStateKind.disconnected) {
        // Keep the last TLS info of a disconnected transport for post-mortem.
        if (e.info.tls == null) next.remove(key);
      }
      if (e.info.tls != null || e.info.state == TransportStateKind.connected) next[key] = e.info;
      state = HubState(transports: next, tlsRejects: state.tlsRejects);
    } else if (e is TransportTlsVerifyEvent) {
      state = HubState(
        transports: state.transports,
        tlsRejects: {...state.tlsRejects, e.info.sha256: e.info},
      );
    } else if (e is CoreStoppedEvent) {
      state = const HubState();
    }
  }

  void clearReject(String sha256) {
    final m = Map<String, TlsVerifyInfo>.from(state.tlsRejects)..remove(sha256);
    state = HubState(transports: state.transports, tlsRejects: m);
  }
}

final diagnosticsHubProvider = NotifierProvider<DiagnosticsHub, HubState>(DiagnosticsHub.new);
