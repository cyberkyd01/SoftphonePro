import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../diagnostics/diagnostics_hub.dart';
import '../diagnostics/sip_trace_controller.dart';
import '../lan/lan_controller.dart';
import '../lan/lan_handoff_impl.dart';
import '../ui/pages/lan/lan_dialogs.dart';
import 'accounts_controller.dart';
import 'calls_controller.dart';
import 'contacts_controller.dart';
import 'engine_controller.dart';
import 'history_controller.dart';
import 'messages_controller.dart';
import 'presence_controller.dart';
import 'providers.dart';

/// Text in the dial field; shared so other screens can prefill it.
class DialInputController extends Notifier<String> {
  @override
  String build() => '';
  void set(String v) => state = v;
  void append(String d) => state = state + d;
  void backspace() {
    if (state.isNotEmpty) state = state.substring(0, state.length - 1);
  }

  void clear() => state = '';
}

final dialInputProvider = NotifierProvider<DialInputController, String>(
  DialInputController.new,
);

/// Incremented to ask the keypad to take keyboard focus.
class DialFocusController extends Notifier<int> {
  @override
  int build() => 0;
  void request() => state++;
}

final dialFocusProvider = NotifierProvider<DialFocusController, int>(
  DialFocusController.new,
);

/// Eagerly instantiates all controllers so they listen to engine events from
/// the first frame, starts the engine, and bridges platform links.
final appServicesProvider = Provider<void>((ref) {
  final platform = ref.watch(platformServicesProvider);
  ref.read(accountsProvider);
  ref.read(callsProvider);
  ref.read(messagesProvider);
  ref.read(presenceProvider);
  ref.read(historyProvider);
  ref.read(contactsProvider);
  // Diagnostics collectors listen from the first frame (trace, logs, TLS).
  ref.read(sipTraceProvider);
  ref.read(logsProvider);
  ref.read(diagnosticsHubProvider);
  ref.read(lanControllerProvider);
  ref.read(lanHandoffImplProvider);
  ref.read(lanUiCoordinatorProvider);

  Future.microtask(() => ref.read(engineProvider.notifier).start());

  // Incoming sip:/tel:/callto: links fill the dialer.
  Future<void> handleLink(Uri uri) async {
    final s = uri.toString();
    if (uri.scheme == 'softphonepro') {
      final target = uri.queryParameters['number'] ?? uri.host + uri.path;
      ref.read(dialInputProvider.notifier).set(target);
      return;
    }
    var n = s.replaceFirst(RegExp(r'^(sips?|tel|callto):(//)?', caseSensitive: false), '');
    n = Uri.decodeComponent(n.split('?').first);
    ref.read(dialInputProvider.notifier).set(n);
    ref.read(dialFocusProvider.notifier).request();
  }

  final linkSub = platform.incomingLinks.listen(handleLink);
  ref.onDispose(linkSub.cancel);
  unawaited(
    platform.initialLink().then((u) {
      if (u != null) handleLink(u);
    }),
  );

  // iOS (sndMode manual): CallKit owns the audio session; open the engine's
  // sound devices only while it is active (ENGINE_API section 5).
  final sessionSub = platform.audioSessionActive.listen((active) async {
    try {
      final name = active ? 'default' : 'none';
      await ref
          .read(engineProvider.notifier)
          .engine
          .setAudioDevices(capture: name, playback: name);
    } catch (_) {}
  });
  ref.onDispose(sessionSub.cancel);

  // Badge / tray reflect missed calls and unread messages.
  ref.listen<int>(unreadMessagesProvider, (_, n) {
    unawaited(platform.updateBadge(n + ref.read(missedCountProvider)));
  });
  ref.listen<int>(missedCountProvider, (_, n) {
    unawaited(platform.updateBadge(n + ref.read(unreadMessagesProvider)));
  });
});

