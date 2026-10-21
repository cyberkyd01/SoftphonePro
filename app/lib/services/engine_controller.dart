import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spcore_dart/spcore_dart.dart';

import '../l10n/l10n.dart';
import '../models/app_settings.dart';
import '../audio/monitor_state.dart';
import '../audio/voice_isolation.dart';
import '../platform/android/android_platform_services.dart';
import 'engine_files.dart';
import 'providers.dart';
import 'settings_controller.dart';

/// Must match `version:` in pubspec.yaml (without the build number); a test checks it.
const String kAppVersion = '1.1.3';
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

/// Bumped whenever the audio device list may have changed (hot-plug).
class DeviceRevision extends Notifier<int> {
  @override
  int build() => 0;
  void bump() => state++;
}

final deviceRevisionProvider = NotifierProvider<DeviceRevision, int>(DeviceRevision.new);

enum EnginePhase { idle, starting, running, failed }

class EngineState {
  const EngineState({
    this.phase = EnginePhase.idle,
    this.demo = false,
    this.generation = 0,
    this.version = '',
    this.note,
    this.error,
    this.startResult,
    this.libraryLoaded = true,
  });
  final EnginePhase phase;
  final bool demo;

  /// Increments every time the engine (re)starts; accounts are re-added.
  final int generation;
  final String version;
  final String? note;
  final String? error;

  /// Result of the last successful `core.start` (transports, pjsip, LAN).
  final CoreStartResult? startResult;

  /// False only when the native library could not be loaded at all.
  /// A failed phase with a loaded library is a blocking start failure.
  final bool libraryLoaded;

  bool get running => phase == EnginePhase.running;

  EngineState copyWith({
    EnginePhase? phase,
    bool? demo,
    int? generation,
    String? version,
    String? note,
    String? error,
    CoreStartResult? startResult,
    bool? libraryLoaded,
  }) => EngineState(
    phase: phase ?? this.phase,
    demo: demo ?? this.demo,
    generation: generation ?? this.generation,
    version: version ?? this.version,
    note: note ?? this.note,
    error: error,
    startResult: startResult ?? this.startResult,
    libraryLoaded: libraryLoaded ?? this.libraryLoaded,
  );
}

/// Loader for the CA bundle copy and engine log paths (override in tests).
final engineFilesProvider = Provider<EngineFilesLoader>((ref) => prepareEngineFiles);

CoreConfig buildCoreConfig(AppSettings s, {EngineFiles files = EngineFiles.none}) {
  final customCa = s.customCaFile.trim();
  return CoreConfig(
    userAgent: kUserAgent,
    logLevel: s.logLevel,
    logForward: s.logLevel >= 4,
    sipTrace: s.sipTrace,
    logFile: files.logFile,
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
        caFile: customCa.isNotEmpty ? customCa : files.caFile,
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
      ptime: s.ptime,
      jb: JbConfig(
        initMs: s.jbInitMs,
        minPreMs: s.jbMinPreMs,
        maxPreMs: s.jbMaxPreMs,
        maxMs: s.jbMaxMs,
      ),
      rtpPort: s.rtpPort,
      rtpPortRange: s.rtpPortRange,
      sndMode: (!kIsWeb && Platform.isIOS) ? SndMode.manual : SndMode.auto,
      voiceIsolation: voiceIsolationConfigOf(s),
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
  'customCaFile',
  'jbInitMs',
  'jbMinPreMs',
  'jbMaxPreMs',
  'jbMaxMs',
  'ptime',
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
  bool _forceSimulator = false;
  String? _lastAudioNoticeKey;
  DateTime? _lastAudioNotice;

  /// `logs/engine.log` of the running engine (diagnostics export).
  String? logFilePath;
  Timer? _devicePoll;

  SipEngine get engine => _engine ?? (throw StateError('Engine not started'));
  bool get hasEngine => _engine != null && state.running;
  Stream<EngineEvent> get events => _events.stream;

  @override
  EngineState build() {
    ref.onDispose(() {
      _disposed = true;
      _ipDebounce?.cancel();
      _devicePoll?.cancel();
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
    EngineHandle? handle;
    try {
      handle = await ref.read(engineFactoryProvider)(
        simulator: settings.useSimulator || _forceSimulator,
      );
      await _boot(handle, settings);
    } catch (e) {
      if (_disposed) return;
      final h = handle;
      if (h != null && !h.demo) {
        // The native library loaded but core.start failed: never fall back
        // silently, the UI shows a blocking error with Retry / Settings / demo.
        await _safeDispose(h.engine);
        _engine = null;
        ref.read(engineLogProvider.notifier).add('engine start failed: $e');
      }
      state = state.copyWith(
        phase: EnginePhase.failed,
        error: e is EngineException ? e.error.message : '$e',
        libraryLoaded: h != null && !h.demo,
      );
    } finally {
      _starting = false;
    }
  }

  /// User chose "Use simulator (demo)" after a start failure.
  Future<void> startSimulator() async {
    _forceSimulator = true;
    state = state.copyWith(phase: EnginePhase.idle);
    await start();
  }

  /// Retry after a start failure.
  Future<void> retry() async {
    if (_starting) return;
    state = state.copyWith(phase: EnginePhase.idle);
    await start();
  }

  Future<void> _boot(EngineHandle handle, AppSettings settings) async {
    final engine = handle.engine;
    await engine.init();
    _liveCalls.clear();
    _sub?.cancel();
    _sub = engine.events.listen(_onEvent);
    final files = await ref.read(engineFilesProvider)();
    logFilePath = files.logFile;
    final res = await engine.start(buildCoreConfig(settings, files: files));
    await _applyAndroidDns(engine, settings);
    _engine = engine;
    _startedAt = DateTime.now();
    if (_disposed) return;
    state = EngineState(
      phase: EnginePhase.running,
      demo: handle.demo,
      generation: state.generation + 1,
      version: res.version,
      note: handle.loadError != null ? ref.read(l10nProvider).appEngineNativeUnavailable(handle.loadError!) : handle.note,
      startResult: res,
    );
    await _applyLive(settings, initial: true);
  }

  /// Android has no res_ninit: hand the engine the active network's DNS servers.
  Future<void> _applyAndroidDns(SipEngine engine, AppSettings settings) async {
    if (kIsWeb || !Platform.isAndroid || settings.dnsServers.isNotEmpty) return;
    final p = ref.read(platformServicesProvider);
    if (p is! AndroidPlatformServices) return;
    try {
      final dns = await p.getDnsServers();
      if (dns.isNotEmpty) await engine.setNameservers(dns);
    } catch (e) {
      debugPrint('android dns failed: $e');
    }
  }

  /// Restarts the engine. Concurrent callers (a settings change and the LAN
  /// controller asking for its listener) share one restart: a second one
  /// would start a core while the first is still stopping the old one, fail
  /// with "already started", and its cleanup would stop the running core.
  Future<void> restart() {
    if (_starting) return Future.value();
    return _restarting ??= _restart().whenComplete(() => _restarting = null);
  }

  Future<void>? _restarting;

  Future<void> _restart() async {
    final e = _engine;
    _engine = null;
    // Report the restart at once, so nobody acts on the engine being stopped.
    state = state.copyWith(phase: EnginePhase.starting);
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
      case MediaDevicesChangedEvent():
        ref.read(deviceRevisionProvider.notifier).bump();
      case MediaErrorEvent():
        _onMediaError(e);
      case MediaMonitorEvent():
        ref.read(audioMonitorStateProvider.notifier).set(e.state);
      case CallIncomingEvent():
        _liveCalls.add(e.cid);
        _refreshDevicesOnDesktop();
      case CallStateEvent():
        if (!e.isTerminal && !_liveCalls.contains(e.cid)) _refreshDevicesOnDesktop();
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

  /// An audio-device failure is never silent: tell the user (once per 30 s,
  /// the engine can repeat the same error on every retry; a different error
  /// is always shown).
  void _onMediaError(MediaErrorEvent e) {
    final now = DateTime.now();
    final key = '${e.op}:${e.message}';
    final last = _lastAudioNotice;
    if (key == _lastAudioNoticeKey && last != null && now.difference(last) < const Duration(seconds: 30)) return;
    _lastAudioNoticeKey = key;
    _lastAudioNotice = now;
    ref.read(noticeProvider.notifier).error(ref.read(l10nProvider).audioDeviceErrorNotice(e.message));
  }

  bool get _desktop => !kIsWeb && (Platform.isMacOS || Platform.isWindows || Platform.isLinux);

  /// Re-enumerates audio devices and tells the UI to reload its lists.
  Future<void> refreshDevices() async {
    if (!hasEngine) return;
    try {
      await engine.refreshDevices();
    } catch (err) {
      debugPrint('refreshDevices failed: $err');
    }
    if (!_disposed) ref.read(deviceRevisionProvider.notifier).bump();
  }

  void _refreshDevicesOnDesktop() {
    // Deferred: the engine may be mid-dispatch of the event that got us here.
    if (_desktop) Future<void>.delayed(Duration.zero, refreshDevices);
  }

  /// Desktop: poll for plugged / unplugged devices while Settings > Audio is
  /// visible. Pair every call with [stopDevicePolling].
  void startDevicePolling({Duration every = const Duration(seconds: 10)}) {
    if (!_desktop && every == const Duration(seconds: 10)) return;
    _devicePoll?.cancel();
    _devicePoll = Timer.periodic(every, (_) => unawaited(refreshDevices()));
  }

  void stopDevicePolling() {
    _devicePoll?.cancel();
    _devicePoll = null;
  }

  static String _describe(EngineEvent e) => switch (e) {
    AccountRegEvent() => 'account.reg ${e.account.uid} ${e.account.regState.wire} ${e.account.regCode} ${e.account.lastError ?? ''}',
    CallStateEvent() => 'call.state ${e.cid} ${e.call.state.wire} ${e.call.stateCode}',
    CallIncomingEvent() => 'call.incoming ${e.cid} ${e.call.remoteUri}',
    MediaErrorEvent() => 'media.error ${e.op} ${e.status} ${e.message}',
    MediaMonitorEvent() => 'media.monitor ${e.state.source.wire} active=${e.state.active}',
    MediaLoopbackEvent() => 'media.loopback enabled=${e.enabled} ${e.reason ?? ''}',
    _ => e.name,
  };

  void _onSettings(AppSettings? old, AppSettings next) {
    if (old == null || (!state.running && state.phase != EnginePhase.failed)) return;
    final o = old.toJson();
    final n = next.toJson();
    final needsRestart = _restartKeys.any((k) => o[k] != n[k]);
    if (needsRestart && state.phase == EnginePhase.failed) unawaited(retry());
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
    if (!initial && any(['viMicOn', 'viMicStrength', 'viInOn', 'viInStrength'])) {
      // Initial values travel in core.start; an engine without voice
      // isolation answers UNSUPPORTED, which is ignored.
      final vi = voiceIsolationConfigOf(s);
      await guard(() => e.setVoiceIsolation(mic: vi.mic, incoming: vi.incoming));
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
    // On Android the engine outlives the activity (foreground service).
    if (!kIsWeb && Platform.isAndroid) return;
    final e = _engine;
    if (e is FfiSipEngine) e.detach();
  }
}

final engineProvider = NotifierProvider<EngineController, EngineState>(
  EngineController.new,
);
