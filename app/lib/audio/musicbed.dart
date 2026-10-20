import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spcore_dart/spcore_dart.dart';

import '../l10n/l10n.dart';
import '../models/app_settings.dart';
import '../services/engine_controller.dart';
import '../services/providers.dart';
import '../services/settings_controller.dart';
import 'audio_library.dart';

/// Live musicbed volume changes are sent at most this often while a slider is
/// dragged; the final value is always sent.
const kMusicbedSetEvery = Duration(milliseconds: 50);

/// Keeps the engine's musicbed (a looping library track mixed into every call)
/// in line with the `musicbed*` settings: starts it when enabled (also after
/// an engine restart), stops it when disabled, pushes volume / monitor changes
/// live and switches the setting off, with a notice, when the engine reports
/// an error or the file is gone. The state is the engine's last known one.
class MusicbedController extends Notifier<MusicbedState> {
  Future<void> _chain = Future.value();
  Timer? _throttle;
  bool _dirty = false;

  @override
  MusicbedState build() {
    ref.onDispose(() => _throttle?.cancel());
    ref.listen<AppSettings>(settingsProvider, _onSettings);
    ref.listen<EngineState>(engineProvider, (prev, next) {
      if (!next.running) {
        if (state.active) state = MusicbedState.idle;
      } else if (prev == null || !prev.running || prev.generation != next.generation) {
        // A new engine knows nothing of the old bed.
        state = MusicbedState.idle;
        _enqueue(_reconcile);
      }
    });
    final sub = ref.read(engineProvider.notifier).events.listen(_onEvent);
    ref.onDispose(sub.cancel);
    if (ref.read(engineProvider).running) Future.microtask(() => _enqueue(_reconcile));
    return MusicbedState.idle;
  }

  EngineController get _ctl => ref.read(engineProvider.notifier);

  /// Runs [f] after everything queued before it, never overlapping.
  void _enqueue(Future<void> Function() f) {
    _chain = _chain.then((_) async {
      if (!ref.mounted) return;
      try {
        await f();
      } catch (e) {
        debugPrint('musicbed: $e');
      }
    });
  }

  void _onSettings(AppSettings? old, AppSettings s) {
    if (old == null) return;
    if (old.musicbedEnabled != s.musicbedEnabled || old.musicbedFile != s.musicbedFile) {
      _enqueue(_reconcile);
    } else if (old.musicbedVolume != s.musicbedVolume ||
        old.musicbedMonitor != s.musicbedMonitor ||
        old.musicbedMonitorVolume != s.musicbedMonitorVolume) {
      _pushSet();
    }
  }

  void _onEvent(EngineEvent e) {
    if (e is! MusicbedEvent || !ref.mounted) return;
    if (e.isError) {
      state = MusicbedState.idle;
      _giveUp(ref.read(l10nProvider).musicbedStopped(e.message ?? ''));
    } else if (e.active) {
      _enqueue(_refresh);
    } else if (e.reason != 'replaced') {
      // ("replaced" is followed by the new bed's "started".)
      state = MusicbedState.idle;
    }
  }

  /// Switches the setting off and tells the user why.
  void _giveUp(String message, {bool error = true}) {
    final s = ref.read(settingsProvider);
    if (s.musicbedEnabled) {
      unawaited(ref.read(settingsProvider.notifier).update({'musicbedEnabled': false}));
    }
    final n = ref.read(noticeProvider.notifier);
    error ? n.error(message) : n.show(message);
  }

  Future<void> _refresh() async {
    if (!_ctl.hasEngine) return;
    try {
      final st = await _ctl.engine.musicbedState();
      if (ref.mounted) state = st;
    } catch (_) {}
  }

  /// Makes the engine match the settings.
  Future<void> _reconcile() async {
    if (!_ctl.hasEngine) return;
    final e = _ctl.engine;
    final s = ref.read(settingsProvider);
    final l = ref.read(l10nProvider);
    if (!s.musicbedEnabled) {
      try {
        await e.musicbedStop();
      } catch (_) {}
      return _refresh();
    }
    if (s.musicbedFile.isEmpty) return _giveUp(l.musicbedNeedsFile, error: false);
    final path = await ref.read(audioLibraryProvider).resolve(s.musicbedFile);
    if (path == null) return _giveUp(l.musicbedFileMissing);
    if (state.active && state.file == path) return;
    try {
      await e.musicbedStart(
        path,
        volume: s.musicbedVolume,
        monitor: s.musicbedMonitor,
        monitorVolume: s.musicbedMonitorVolume,
      );
    } on EngineException catch (err) {
      _giveUp(l.musicbedStopped(err.error.message));
    }
    await _refresh();
  }

  /// Leading + trailing throttle for slider drags.
  void _pushSet() {
    if (_throttle != null) {
      _dirty = true;
      return;
    }
    _enqueue(_sendSet);
    _throttle = Timer(kMusicbedSetEvery, () {
      _throttle = null;
      if (_dirty) {
        _dirty = false;
        _pushSet();
      }
    });
  }

  /// Sends the *current* settings, so the last value always wins.
  Future<void> _sendSet() async {
    if (!_ctl.hasEngine || !state.active) return;
    final s = ref.read(settingsProvider);
    try {
      await _ctl.engine.musicbedSet(
        volume: s.musicbedVolume,
        monitor: s.musicbedMonitor,
        monitorVolume: s.musicbedMonitorVolume,
      );
    } on EngineException catch (err) {
      if (err.error.code == ErrorCode.notFound) {
        await _refresh();
      }
    }
  }

  /// Turns the musicbed on or off from the UI.
  Future<void> setEnabled(bool on) =>
      ref.read(settingsProvider.notifier).update({'musicbedEnabled': on});
}

final musicbedProvider = NotifierProvider<MusicbedController, MusicbedState>(
  MusicbedController.new,
);
