import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spcore_dart/spcore_dart.dart';

import '../l10n/l10n.dart';
import '../models/app_settings.dart';
import '../services/engine_controller.dart';
import '../services/settings_controller.dart';

/// Low / Medium / High / Max for a 0-1 strength.
String strengthLabel(AppLocalizations l, double v) {
  if (v < 0.35) return l.audioStrengthLow;
  if (v < 0.65) return l.audioStrengthMedium;
  if (v < 0.9) return l.audioStrengthHigh;
  return l.audioStrengthMax;
}

/// "High (80%)".
String strengthText(AppLocalizations l, double v) => l.audioStrengthText(strengthLabel(l, v), (v * 100).round());

/// The voice-isolation parts of [s] as an engine config.
VoiceIsolationConfig voiceIsolationConfigOf(AppSettings s) => VoiceIsolationConfig(
  mic: VoiceIsolationSide(enabled: s.viMicOn, strength: s.viMicStrength.clamp(0.0, 1.0).toDouble()),
  incoming: VoiceIsolationSide(enabled: s.viInOn, strength: s.viInStrength.clamp(0.0, 1.0).toDouble()),
);

class VoiceIsolationState {
  const VoiceIsolationState({this.available, this.vad = 0});

  /// Null until probed; false when the engine has no voice isolation.
  final bool? available;

  /// Latest speech probability of the microphone (0-1).
  final double vad;

  VoiceIsolationState copyWith({bool? available, double? vad}) => VoiceIsolationState(
    available: available ?? this.available,
    vad: vad ?? this.vad,
  );
}

/// Availability probe and speech meter polling for the voice
/// isolation settings. The settings themselves are applied live by
/// [EngineController] when the `vi*` settings change.
class VoiceIsolationController extends Notifier<VoiceIsolationState> {
  Timer? _timer;
  int _watchers = 0;
  bool _polling = false;

  /// Meter refresh period (~10 Hz).
  static const pollEvery = Duration(milliseconds: 100);

  @override
  VoiceIsolationState build() {
    ref.onDispose(() => _timer?.cancel());
    return const VoiceIsolationState();
  }

  SipEngine? get _engine {
    final c = ref.read(engineProvider.notifier);
    return c.hasEngine ? c.engine : null;
  }

  /// Asks the engine whether noise suppression exists (re-applies the saved
  /// settings, which is harmless).
  Future<void> probe() async {
    final e = _engine;
    if (e == null) {
      state = state.copyWith(available: false);
      return;
    }
    try {
      final r = await e.setVoiceIsolation(
        mic: voiceIsolationConfigOf(ref.read(settingsProvider)).mic,
      );
      state = state.copyWith(available: r.available);
    } on EngineException {
      state = state.copyWith(available: false);
    } catch (_) {
      state = state.copyWith(available: false);
    }
  }

  /// Starts the ~10 Hz speech-detection poll; pair with [stopMeter].
  void startMeter() {
    _watchers++;
    if (_timer != null) return;
    _timer = Timer.periodic(pollEvery, (_) => unawaited(_poll()));
  }

  void stopMeter() {
    if (!ref.mounted) return;
    if (_watchers > 0) _watchers--;
    if (_watchers == 0) {
      _timer?.cancel();
      _timer = null;
      if (state.vad != 0) {
        // Called from dispose(): never touch provider state while unmounting.
        Future.microtask(() {
          if (ref.mounted && _timer == null) state = state.copyWith(vad: 0);
        });
      }
    }
  }

  bool get metering => _timer != null;

  Future<void> _poll() async {
    final e = _engine;
    if (e == null || _polling || _timer == null) return;
    _polling = true;
    try {
      final st = await e.voiceIsolationStatus();
      if (_timer != null) state = state.copyWith(vad: st.mic.vad);
    } on EngineException {
      // Not supported: stop hammering the engine.
      _timer?.cancel();
      _timer = null;
    } catch (_) {
    } finally {
      _polling = false;
    }
  }
}

final voiceIsolationProvider =
    NotifierProvider<VoiceIsolationController, VoiceIsolationState>(VoiceIsolationController.new);
