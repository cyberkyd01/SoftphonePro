import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lan_link/lan_link.dart' as ll;

import '../lan/lan_controller.dart';
import '../ui/router.dart';
import 'app_services.dart';
import 'calls_controller.dart';
import 'engine_controller.dart';
import 'link_router.dart';
import 'providers.dart';
import 'provisioning.dart';
import 'provisioning_import.dart';
import 'settings_controller.dart';

/// Waits (briefly) for the engine, e.g. a link that launched the app.
Future<bool> _engineReady(Ref ref) async {
  if (ref.read(engineProvider).running) return true;
  final c = Completer<bool>();
  final sub = ref.listen<EngineState>(engineProvider, (_, n) {
    if (n.running && !c.isCompleted) c.complete(true);
    if (n.phase == EnginePhase.failed && !c.isCompleted) c.complete(false);
  });
  try {
    return await c.future.timeout(const Duration(seconds: 20), onTimeout: () => false);
  } finally {
    sub.close();
  }
}

/// Routes an incoming link / CLI intent (see [classifyLink]).
Future<void> handleIncomingLink(Ref ref, Uri uri) async {
  final notices = ref.read(noticeProvider.notifier);
  final action = classifyLink(uri);
  switch (action) {
    case RejectedLinkAction(:final reason):
      notices.error(reason);
    case ProvisionCliAction(:final source):
      try {
        final r = await loadProvisioningSource(ref, source);
        await importProvisioningResult(ref, r);
        _leaveOnboarding(ref, r);
      } on ProvisioningException catch (e) {
        notices.error(e.message);
      }
    case ProvisionLinkAction(:final url):
      await _provisionFromLink(ref, url);
    case LanLinkAction(:final raw):
      try {
        final peer = await ref.read(lanControllerProvider.notifier).connectManual(raw);
        notices.show('Connected to ${peer.name}');
        ref.read(routerProvider).go('/lan');
      } on ll.LanLinkException catch (e) {
        notices.error(e.message);
      } catch (e) {
        notices.error('Could not connect to that device', details: '$e');
      }
    case DialCliAction(:final target):
      await _dial(ref, target, immediately: true);
    case DialLinkAction(:final target):
      await _dial(ref, target, immediately: ref.read(settingsProvider).callLinksImmediately);
  }
}

void _leaveOnboarding(Ref ref, ProvisioningResult r) {
  if (r.accounts.isEmpty) return;
  try {
    final router = ref.read(routerProvider);
    if (router.state.uri.path == '/onboarding') router.go('/keypad');
  } catch (_) {}
}

Future<void> _dial(Ref ref, String target, {required bool immediately}) async {
  ref.read(dialInputProvider.notifier).set(target);
  ref.read(dialFocusProvider.notifier).request();
  if (!immediately || target.trim().isEmpty) return;
  if (!await _engineReady(ref)) return;
  await ref.read(callsProvider.notifier).dial(target);
}

Future<void> _provisionFromLink(Ref ref, Uri url) async {
  final notices = ref.read(noticeProvider.notifier);
  try {
    final vars = await provisioningVars(
      settings: ref.read(settingsProvider).toJson(),
      save: ref.read(settingsProvider.notifier).update,
    );
    final client = ref.read(provisioningClientProvider);
    final r = await Provisioning.fetch(url, vars: vars, client: client);
    final ctx = rootNavigatorKey.currentContext;
    if (ctx == null || !ctx.mounted) return;
    final n = r.accounts.length;
    final ok = await showDialog<bool>(
      context: ctx,
      builder: (c) => AlertDialog(
        key: const Key('link-import-confirm'),
        title: const Text('Import configuration'),
        content: Text(
          'Import configuration from ${url.host}? It will add $n account${n == 1 ? '' : 's'}'
          '${r.settings.isEmpty ? '' : ' and ${r.settings.length} setting(s)'}.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
          FilledButton(key: const Key('link-import-yes'), onPressed: () => Navigator.pop(c, true), child: const Text('Import')),
        ],
      ),
    );
    if (ok != true) return;
    await importProvisioningResult(ref, r);
    _leaveOnboarding(ref, r);
  } on ProvisioningException catch (e) {
    notices.error(e.message);
  }
}
