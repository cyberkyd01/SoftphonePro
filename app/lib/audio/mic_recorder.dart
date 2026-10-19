import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spcore_dart/spcore_dart.dart';

import '../services/engine_controller.dart';
import 'audio_library.dart';

enum RecorderPhase { idle, recording, saving }

class RecorderState {
  const RecorderState({
    this.phase = RecorderPhase.idle,
    this.elapsed = Duration.zero,
    this.level = 0,
    this.file,
    this.durationMs = 0,
    this.error,
  });
  final RecorderPhase phase;
  final Duration elapsed;

  /// Mic level 0-1 while recording.
  final double level;

  /// A finished recording not yet saved to the library (preview).
  final String? file;
  final int durationMs;
  final String? error;

  bool get recording => phase == RecorderPhase.recording;

  RecorderState copyWith({
    RecorderPhase? phase,
    Duration? elapsed,
    double? level,
    String? file,
    int? durationMs,
    String? error,
    bool clearFile = false,
  }) => RecorderState(
    phase: phase ?? this.phase,
    elapsed: elapsed ?? this.elapsed,
    level: level ?? this.level,
    file: clearFile ? null : (file ?? this.file),
    durationMs: durationMs ?? this.durationMs,
    error: error,
  );
}

/// Records the microphone to a WAV (works without a call) with a timer and
/// level meter, then lets the UI preview and save it into the library.
class MicRecorderController extends Notifier<RecorderState> {
  Timer? _timer;
  DateTime? _started;

  /// Hard limit; announcements are short.
  static const maxDuration = Duration(minutes: 5);

  @override
  RecorderState build() {
    final c = ref.read(engineProvider.notifier);
    ref.onDispose(() {
      _timer?.cancel();
      if (_started != null && _timer != null && c.hasEngine) {
        unawaited(c.engine.recordMicStop().then((_) {}, onError: (_) {}));
      }
    });
    return const RecorderState();
  }

  Future<void> start() async {
    final c = ref.read(engineProvider.notifier);
    if (!c.hasEngine) {
      state = state.copyWith(error: 'The call engine is not running.');
      return;
    }
    if (state.recording) return;
    final path = await ref.read(audioLibraryProvider).newRecordingPath();
    try {
      await c.engine.recordMicStart(path);
    } on EngineException catch (e) {
      state = state.copyWith(
        error: e.code == ErrorCode.unsupported
            ? 'This version of the call engine cannot record the microphone.'
            : 'Could not start recording: ${e.error.message}',
      );
      return;
    }
    _started = DateTime.now();
    state = RecorderState(phase: RecorderPhase.recording, file: null);
    _timer = Timer.periodic(const Duration(milliseconds: 200), (_) async {
      final el = DateTime.now().difference(_started!);
      double lvl = state.level;
      try {
        final l = await c.engine.levels();
        lvl = (l.mic / 255).clamp(0.0, 1.0).toDouble();
      } catch (_) {}
      if (!state.recording) return;
      state = state.copyWith(elapsed: el, level: lvl);
      if (el >= maxDuration) unawaited(stop());
    });
  }

  Future<void> stop() async {
    if (!state.recording) return;
    _timer?.cancel();
    _timer = null;
    _started = null;
    state = state.copyWith(phase: RecorderPhase.saving);
    final c = ref.read(engineProvider.notifier);
    try {
      final r = await c.engine.recordMicStop();
      state = RecorderState(file: r.file, durationMs: r.durationMs);
    } on EngineException catch (e) {
      state = RecorderState(error: 'Recording failed: ${e.error.message}');
    }
  }

  /// Saves the last recording into the library under [name].
  Future<AudioItem?> save(String name) async {
    final f = state.file;
    if (f == null) return null;
    try {
      final item = await ref.read(audioLibraryProvider).addRecorded(f, name: name, durationMs: state.durationMs);
      state = const RecorderState();
      return item;
    } on AudioLibraryException catch (e) {
      state = state.copyWith(error: e.message);
      return null;
    }
  }

  void discard() => state = const RecorderState();
}

final micRecorderProvider = NotifierProvider<MicRecorderController, RecorderState>(MicRecorderController.new);
