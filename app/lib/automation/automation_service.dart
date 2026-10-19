import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/settings_controller.dart';
import 'automation_api.dart';
import 'automation_auth.dart';
import 'automation_events.dart';
import 'automation_server.dart';

/// Whether the local automation API is listening.
class AutomationStatus {
  const AutomationStatus({this.running = false, this.port = 0, this.error});
  final bool running;
  final int port;

  /// Why it is not listening although enabled (port in use, no token, ...).
  final String? error;
}

/// Starts / stops / rebinds the API when the settings change. Disabled by
/// default; binds 127.0.0.1 only.
class AutomationService extends Notifier<AutomationStatus> {
  AutomationServer? _server;
  AutomationEventBridge? _bridge;
  AutomationEventHub? _hub;
  String _key = '';
  int _gen = 0;

  /// Heartbeat of the SSE streams (tests shorten it).
  Duration heartbeat = const Duration(seconds: 15);

  @override
  AutomationStatus build() {
    ref.onDispose(() {
      _gen++;
      unawaited(_stop());
    });
    ref.listen(settingsProvider, (_, _) => unawaited(_sync()), fireImmediately: false);
    unawaited(Future.microtask(_sync));
    return const AutomationStatus();
  }

  Future<void> _stop() async {
    _bridge?.dispose();
    _bridge = null;
    final s = _server;
    _server = null;
    await s?.stop();
    await _hub?.close();
    _hub = null;
  }

  Future<void> _sync() async {
    final s = ref.read(settingsProvider);
    final wanted = s.automationEnabled;
    final key = wanted
        ? '${s.automationPort}|${s.automationToken}|${s.automationOrigins.join(',')}'
        : 'off';
    if (key == _key) return;
    _key = key;
    final gen = ++_gen;
    await _stop();
    if (gen != _gen) return;
    if (!wanted) {
      state = const AutomationStatus();
      return;
    }
    if (s.automationToken.length < 16) {
      state = const AutomationStatus(error: 'No access token set. Generate one in Settings > Advanced.');
      return;
    }
    final port = s.automationPort;
    if (port < 0 || port > 65535) {
      state = AutomationStatus(error: 'Invalid port $port');
      return;
    }
    final hub = AutomationEventHub();
    final api = AutomationApi(ref, hub);
    final server = AutomationServer(
      token: s.automationToken,
      origins: s.automationOrigins,
      handler: api.handle,
      heartbeat: heartbeat,
    );
    try {
      await server.start(port);
    } on SocketException catch (e) {
      if (gen != _gen) return;
      await hub.close();
      state = AutomationStatus(
        error: port == 0
            ? 'Could not start: ${e.message}'
            : 'Port $port is not available (${e.osError?.message ?? e.message}). Choose another port.',
      );
      return;
    }
    if (gen != _gen) {
      await server.stop();
      await hub.close();
      return;
    }
    _hub = hub;
    _server = server;
    _bridge = AutomationEventBridge(ref, hub);
    state = AutomationStatus(running: true, port: server.port);
    debugPrint('Automation API listening on 127.0.0.1:${server.port}');
  }

  /// Generates a fresh token (invalidates the old one at once).
  Future<String> regenerateToken() async {
    final t = generateAutomationToken();
    await ref.read(settingsProvider.notifier).update({'automationToken': t});
    return t;
  }

  /// Switches the API on or off; creates a token on first use.
  Future<void> setEnabled(bool on) async {
    final s = ref.read(settingsProvider);
    await ref.read(settingsProvider.notifier).update({
      'automationEnabled': on,
      if (on && s.automationToken.length < 16) 'automationToken': generateAutomationToken(),
    });
  }
}

final automationServiceProvider = NotifierProvider<AutomationService, AutomationStatus>(
  AutomationService.new,
);
