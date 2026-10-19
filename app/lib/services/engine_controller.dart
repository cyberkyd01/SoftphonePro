import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spcore_dart/spcore_dart.dart';

import '../models/app_settings.dart';
import 'providers.dart';
import 'settings_controller.dart';

const String kAppVersion = '1.0.0';
const String kUserAgent = 'SoftphonePro/$kAppVersion';

/// Rolling log of engine events and app-side engine errors (diagnostics).
class EngineLogController extends Notifier<List<String>> {
  @override
  List<String> build() => const [];
  void add(String line) {
    final t = DateTime.now().toIso8601String().substring(11, 19);
    final next = [...state, '$t $line'];
    state = next.length > 200 ? next.sublist(next.length - 200) : next;
  }

  void clear() => state = const [];
}

final engineLogProvider = NotifierProvider<EngineLogController, List<String>>(
  EngineLogController.new,
);

enum EnginePhase { idle, starting, running, failed }

class EngineState {
  const EngineState({
    this.phase = EnginePhase.idle,
    this.demo = false,
    this.generation = 0,
    this.version = '',
    this.note,
    this.error,
  });
  final EnginePhase phase;
  final bool demo;

  /// Increments every time the engine (re)starts; accounts are re-added.
  final int generation;
  final String version;
  final String? note;
  final String? error;

  bool get running => phase == EnginePhase.running;

  EngineState copyWith({
    EnginePhase? phase,
    bool? demo,
    int? generation,
    String? version,
    String? note,
    String? error,
  }) => EngineState(
    phase: phase ?? this.phase,
    demo: demo ?? this.demo,
    generation: generation ?? this.generation,
    version: version ?? this.version,
    note: note ?? this.note,
    error: error,
  );
}

CoreConfig buildCoreConfig(AppSettings s) {
  return CoreConfig(
    userAgent: kUserAgent,
    logLevel: s.logLevel,
    logForward: s.logLevel >= 4,
    sipTrace: s.sipTrace,
    nameservers: s.dnsServers.isEmpty ? null : s.dnsServers,
    stunServers: s.stunServers,
    statsIntervalMs: 0,
    transports: TransportConfig(
      udp: TransportPort(port: s.udpPort, enabled: s.udpEnabled),
      tcp: TransportPort(port: s.tcpPort, enabled: s.tcpEnabled),
      tls: TlsTransportConfig(
        port: s.tlsPort == 0 ? 5061 : s.tlsPort,
        enabled: s.tlsEnabled,
        verifyServer: s.tlsVerify,
      ),
      ipv6: s.ipv6,
      qos: s.qos,
    ),
    lan: LanConfig(enabled: s.lanEnabled),
    media: MediaConfig(
      ec: EcConfig(
        algo: EcAlgo.parse(s.ecAlgo),
        tailMs: s.ecTailMs,
        ns: s.noiseSuppression,
        agc: s.agc,
      ),
      vad: s.vad,
      rtpPort: s.rtpPort,
      rtpPortRange: s.rtpPortRange,
      sndMode: (!kIsWeb && Platform.isIOS) ? SndMode.manual : SndMode.auto,
    ),
  );
}

const _restartKeys = [
  'udpEnabled',
  'udpPort',
  'tcpEnabled',
  'tcpPort',
  'tlsEnabled',
  'tlsPort',
  'tlsVerify',
  'stunServers',
  'ipv6',
  'qos',
  'rtpPort',
  'rtpPortRange',
  'lanEnabled',
  'useSimulator',
  'vad',
];

/// Owns the [SipEngine]: start/stop, settings application, connectivity,
/// watchdog recovery. Other controllers use [engine] and [events].
class EngineController extends Notifier<EngineState> {
  SipEngine? _engine;
  StreamSubscription<EngineEvent>? _sub;
  StreamSubscription<List<ConnectivityResult>>? _connSub;
  Timer? _ipDebounce;
  Set<ConnectivityResult>? _lastConn;
  final _events = StreamController<EngineEvent>.broadcast();
  final Set<int> _liveCalls = {};
  DateTime? _startedAt;
  bool _pendingRestart = false;
  bool _starting = false;
  bool _disposed = false;

  SipEngine get engine => _engine ?? (throw StateError('Engine not started'));
  bool get hasEngine => _engine != null && state.running;
  Stream<EngineEvent> get events => _events.stream;

  @override
  EngineState build() {
    ref.onDispose(() {
      _disposed = true;
      _ipDebounce?.cancel();
      _connSub?.cancel();
      _sub?.cancel();
      final e = _engine;
      _engine = null;
      if (e != null) unawaited(_safeDispose(e));
      _events.close();
    });
    ref.listen<AppSettings>(settingsProvider, _onSettings);
    _connSub = ref.read(connectivityStreamProvider).listen(_onConnectivity);
    return const EngineState();
  }

  Future<void> _safeDispose(SipEngine e) async {
    try {
      await e.stop(graceful: false).timeout(const Duration(seconds: 3));
    } catch (_) {}
    try {
      await e.dispose();
    } catch (_) {}
  }

  Future<void> start() async {
    if (_starting || _disposed || state.phase == EnginePhase.running) return;
    _starting = true;
    state = state.copyWith(phase: EnginePhase.starting);
    final settings = ref.read(settingsProvider);
    try {
      var handle = await ref.read(engineFactoryProvider)(
        simulator: settings.useSimulator,
      );
      try {
        await _boot(handle, settings);
      } catch (e) {
        if (handle.demo) rethrow;
        // Real engine loaded but could not start: fall back to the simulator.
        await _safeDispose(handle.engine);
        handle = await ref.read(engineFactoryProvider)(simulator: true);
        handle = EngineHandle(
          handle.engine,
          demo: true,
          note: 'Native engine failed to start ($e)',
        );
        await _boot(handle, settings);
      }
    } catch (e) {
      if (_disposed) return;
      state = state.copyWith(phase: EnginePhase.failed, error: '$e');
    } finally {
      _starting = false;
    }
  }

  Future<void> _boot(EngineHandle handle, AppSettings settings) async {
    final engine = handle.engine;
    await engine.init();
    _liveCalls.clear();
    _sub?.cancel();
    _sub = engine.events.listen(_onEvent);
    final res = await engine.start(buildCoreConfig(settings));
    _engine = engine;
    _startedAt = DateTime.now();
    if (_disposed) return;
    state = EngineState(
      phase: EnginePhase.running,
      demo: handle.demo,
      generation: state.generation + 1,
      version: res.version,
      note: handle.note,
    );
    await _applyLive(settings, initial: true);
  }

  Future<void> restart() async {
    if (_starting) return;
    final e = _engine;
    _engine = null;
    await _sub?.cancel();
    _sub = null;
    if (e != null) await _safeDispose(e);
    state = state.copyWith(phase: EnginePhase.idle);
    await start();
  }

  void _onEvent(EngineEvent e) {
    if (_disposed) return;
    if (e is! LogEvent && e is! SipTraceEvent) {
      ref.read(engineLogProvider.notifier).add(_describe(e));
    }
    switch (e) {
      case CallIncomingEvent():
        _liveCalls.add(e.cid);
      case CallStateEvent():
        if (e.isTerminal) {
          _liveCalls.remove(e.cid);
          if (_pendingRestart && _liveCalls.isEmpty) {
            _pendingRestart = false;
            unawaited(restart());
          }
        } else {
          _liveCalls.add(e.cid);
        }
      case EngineUnresponsiveEvent():
        if (e.consecutiveFailures >= 2) unawaited(restart());
      default:
    }
    _events.add(e);
  }

  static String _describe(EngineEvent e) => switch (e) {
    AccountRegEvent() => 'account.reg ${e.account.uid} ${e.account.regState.wire} ${e.account.regCode} ${e.account.lastError ?? ''}',
    CallStateEvent() => 'call.state ${e.cid} ${e.call.state.wire} ${e.call.stateCode}',
    CallIncomingEvent() => 'call.incoming ${e.cid} ${e.call.remoteUri}',
    _ => e.name,
  };

  void _onSettings(AppSettings? old, AppSettings next) {
    if (old == null || !state.running) return;
    final o = old.toJson();
    final n = next.toJson();
    final needsRestart = _restartKeys.any((k) => o[k] != n[k]);
    if (needsRestart) {
      if (_liveCalls.isEmpty) {
        unawaited(restart());
      } else {
        _pendingRestart = true;
      }
      return;
    }
    unawaited(_applyLive(next, old: old));
  }

  /// Applies settings that do not need an engine restart.
  Future<void> _applyLive(
    AppSettings s, {
    AppSettings? old,
    bool initial = false,
  }) async {
    final e = _engine;
    if (e == null) return;
    bool changed(String k) => initial || old?.toJson()[k] != s.toJson()[k];
    bool any(List<String> ks) => ks.any(changed);
    Future<void> guard(Future<void> Function() f) async {
      try {
        await f();
      } catch (err) {
        debugPrint('engine setting failed: $err');
      }
    }

    if (any(['ecAlgo', 'ecTailMs', 'noiseSuppression', 'agc'])) {
      await guard(
        () => e.setEc(
          EcConfig(
            algo: EcAlgo.parse(s.ecAlgo),
            tailMs: s.ecTailMs,
            ns: s.noiseSuppression,
            agc: s.agc,
          ),
        ),
      );
    }
    if (changed('micLevel')) await guard(() => e.setMicLevel(s.micLevel));
    if (changed('speakerLevel')) {
      await guard(() => e.setSpeakerLevel(s.speakerLevel));
    }
    if (any(['captureDev', 'playbackDev']) &&
        (!initial || s.captureDev != 'default' || s.playbackDev != 'default')) {
      await guard(
        () => e.setAudioDevices(capture: s.captureDev, playback: s.playbackDev),
      );
    }
    if (any(['codecOrder', 'codecsDisabled'])) {
      await guard(() => applyCodecs(e, s));
    }
    if (any(['opusBitrate', 'opusFec', 'opusDtx', 'opusCbr', 'opusComplexity'])) {
      await guard(() async {
        final cs = await e.codecs();
        for (final c in cs.where((c) => c.id.toLowerCase().contains('opus'))) {
          await e.setCodecParam(
            c.id,
            opus: OpusParams(
              bitrate: s.opusBitrate,
              fec: s.opusFec,
              dtx: s.opusDtx,
              cbr: s.opusCbr,
              complexity: s.opusComplexity,
            ),
          );
        }
      });
    }
    if (changed('dnsServers') && s.dnsServers.isNotEmpty) {
      await guard(() => e.setNameservers(s.dnsServers));
    }
    if (changed('tlsPins')) {
      await guard(
        () => e.setTlsPins([
          for (final p in s.tlsPins)
            if (p.contains('=')) 
              TlsPin(
                host: p.substring(0, p.indexOf('=')),
                sha256: p.substring(p.indexOf('=') + 1),
              ),
        ]),
      );
    }
    if (!initial && changed('logLevel')) {
      await guard(() => e.setLogLevel(s.logLevel, forward: s.logLevel >= 4));
    }
    if (!initial && changed('sipTrace')) {
      await guard(() => e.setSipTrace(s.sipTrace));
    }
  }

  /// Orders/enables codecs according to settings.
  static Future<void> applyCodecs(SipEngine e, AppSettings s) async {
    if (s.codecOrder.isEmpty && s.codecsDisabled.isEmpty) return;
    final all = await e.codecs();
    final ids = all.map((c) => c.id).toList();
    final order = <String>[
      ...s.codecOrder.where(ids.contains),
      ...ids.where((i) => !s.codecOrder.contains(i)),
    ].where((i) => !s.codecsDisabled.contains(i)).toList();
    await e.setCodecPriorities(order, disableOthers: true);
  }

  void _onConnectivity(List<ConnectivityResult> results) {
    final now = results.toSet();
    final prev = _lastConn;
    _lastConn = now;
    if (prev != null && setEquals(prev, now)) return;
    // Ignore the network flaps that happen while the app is starting up.
    if (_startedAt != null && DateTime.now().difference(_startedAt!) < const Duration(seconds: 15)) return;
    _ipDebounce?.cancel();
    _ipDebounce = Timer(const Duration(milliseconds: 1500), () async {
      if (!hasEngine) return;
      try {
        await engine.handleIpChange();
      } catch (e) {
        debugPrint('handleIpChange failed: $e');
      }
    });
  }

  /// App going away: stop sending events to a dead isolate.
  void onAppDetached() {
    final e = _engine;
    if (e is FfiSipEngine) e.detach();
  }
}

final engineProvider = NotifierProvider<EngineController, EngineState>(
  EngineController.new,
);
