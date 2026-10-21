import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spcore_dart/spcore_dart.dart';

import '../services/engine_controller.dart';

class EchoTestState {
  const EchoTestState({this.on = false, this.endedReason});

  /// The microphone is being played back locally.
  final bool on;

  /// Why the last test ended on its own (`timeout`, `call`, `shutdown`) or
  /// null while it runs / after the user stopped it.
  final String? endedReason;
}

/// The one echo test (microphone played back with echo cancellation bypassed).
/// Settings, Diagnostics, Voice isolation and the Audio test page all use it,
/// so they agree on the state and a call or the engine's own timeout switches
/// every switch off.
class EchoTestController extends Notifier<EchoTestState> {
  /// Longest test the app starts: the engine stops it by itself.
  static const defaultTimeout = Duration(seconds: 60);

  @override
  EchoTestState build() {
    final ctl = ref.read(engineProvider.notifier);
    final sub = ctl.events.listen(_onEvent);
    ref.onDispose(sub.cancel);
    // A new engine knows nothing of the old test.
    ref.listen(engineProvider.select((e) => e.running ? e.generation : -1), (_, __) {
      if (state.on) state = const EchoTestState();
    });
    return const EchoTestState();
  }

  void _onEvent(EngineEvent e) {
    if (e is! MediaLoopbackEvent || !ref.mounted) return;
    if (e.enabled) {
      if (!state.on) state = const EchoTestState(on: true);
    } else if (state.on) {
      // Ends of our own stop() were already applied; this is the engine's
      // timeout, a call, or a shutdown.
      state = EchoTestState(endedReason: e.reason);
    }
  }

  SipEngine? get _engine {
    final c = ref.read(engineProvider.notifier);
    return c.hasEngine ? c.engine : null;
  }

  /// Starts the echo test. Throws [EngineException] (`BUSY` during a call).
  Future<void> start({Duration timeout = defaultTimeout}) async {
    final e = _engine;
    if (e == null) return;
    await e.loopback(true, timeoutMs: timeout.inMilliseconds);
    if (ref.mounted) state = const EchoTestState(on: true);
  }

  Future<void> stop() async {
    final e = _engine;
    if (ref.mounted && state.on) state = const EchoTestState();
    if (e == null) return;
    try {
      await e.loopback(false);
    } catch (_) {}
  }

  /// [stop] for a widget's dispose: engine call and state change both run
  /// once the tree is no longer being torn down.
  void stopQuiet() {
    if (!ref.mounted || !state.on) return;
    final e = _engine;
    // Deferred: an engine may deliver its events synchronously, which must
    // not change providers while the tree is being torn down.
    Future.microtask(() {
      if (e != null) unawaited(e.loopback(false).then((_) {}, onError: (_) {}));
      if (ref.mounted && state.on) state = const EchoTestState();
    });
  }
}

final echoTestProvider = NotifierProvider<EchoTestController, EchoTestState>(EchoTestController.new);
