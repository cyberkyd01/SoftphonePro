import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lan_link/lan_link.dart' as ll;

import '../l10n/l10n.dart';
import '../lan/lan_controller.dart';
import '../ui/router.dart';
import 'app_services.dart';
import 'calls_controller.dart';
import 'dial_ready.dart';
import 'link_router.dart';
import 'providers.dart';
import 'provisioning.dart';
import 'provisioning_import.dart';
import 'settings_controller.dart';

/// Provisioning imports in flight, per container: a dial link that follows a
/// provisioning link must see the imported account.
final Expando<Future<void>> _provisioningInFlight = Expando('provisioning');

Future<void> _trackProvisioning(Ref ref, Future<void> work) {
  final prev = _provisioningInFlight[ref.container];
  final f = Future.wait([?prev, work]).then((_) {});
  _provisioningInFlight[ref.container] = f;
  return work;
}

/// Waits until the root navigator is mounted (a cold-start link can be handled
/// before the first frame, and onboarding may be showing) so dialogs can open.
Future<BuildContext?> _rootContext() async {
  final deadline = DateTime.now().add(const Duration(seconds: 20));
  while (true) {
    final ctx = rootNavigatorKey.currentContext;
    if (ctx != null && ctx.mounted && rootNavigatorKey.currentState?.overlay != null) return ctx;
    if (DateTime.now().isAfter(deadline)) return null;
    await Future<void>.delayed(const Duration(milliseconds: 100));
  }
}

/// Routes an incoming link / CLI intent (see [classifyLink]).
Future<void> handleIncomingLink(Ref ref, Uri uri) async {
  final notices = ref.read(noticeProvider.notifier);
  final l = ref.read(l10nProvider);
  final action = classifyLink(uri);
  switch (action) {
    case RejectedLinkAction(:final reason):
      notices.error(linkRejectionText(l, reason));
    case ProvisionCliAction(:final source):
      await _trackProvisioning(ref, () async {
        try {
          final r = await loadProvisioningSource(ref, source);
          // A command line is local intent: it may also configure the local
          // automation API (a web link never can).
          await importProvisioningResult(ref, r, allowAutomation: true);
          _leaveOnboarding(ref, r);
        } on ProvisioningException catch (e) {
          notices.error(e.message);
        }
      }());
    case ProvisionLinkAction(:final url):
      await _trackProvisioning(ref, _provisionFromLink(ref, url));
    case LanLinkAction(:final raw):
      try {
        final peer = await ref.read(lanControllerProvider.notifier).connectManual(raw);
        notices.show(l.callLinkConnectedTo(peer.name));
        ref.read(routerProvider).go('/lan');
      } on ll.LanLinkException catch (e) {
        notices.error(e.message);
      } catch (e) {
        notices.error(l.callLinkConnectFailed, details: '$e');
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

/// Brings the dialer forward so a prefilled number is visible (not during onboarding or a call).
void _showDialer(Ref ref) {
  try {
    if (ref.read(callRouteObserverProvider).open.value.isNotEmpty) return;
    final router = ref.read(routerProvider);
    final path = router.state.uri.path;
    if (path == '/onboarding' || path == '/keypad') return;
    router.go('/keypad');
  } catch (_) {}
}

Future<void> _dial(Ref ref, String target, {required bool immediately}) async {
  ref.read(dialInputProvider.notifier).set(target);
  ref.read(dialFocusProvider.notifier).request();
  _showDialer(ref);
  if (!immediately || target.trim().isEmpty) return;
  // Let a provisioning import that was just requested finish first.
  try {
    await _provisioningInFlight[ref.container];
  } catch (_) {}
  // At launch the engine is still starting and the account still registering.
  final ready = await waitForDialReady(ref, target);
  if (!ready.ok) {
    ref.read(noticeProvider.notifier).error(ref.read(l10nProvider).callLinkCallFailed(target), details: ready.message);
    return;
  }
  await ref.read(callsProvider.notifier).dial(target);
}

Future<void> _provisionFromLink(Ref ref, Uri url) async {
  final notices = ref.read(noticeProvider.notifier);
  final l = ref.read(l10nProvider);
  try {
    final vars = await provisioningVars(
      settings: ref.read(settingsProvider).toJson(),
      save: ref.read(settingsProvider.notifier).update,
    );
    final client = ref.read(provisioningClientProvider);
    final r = await Provisioning.fetch(url, vars: vars, client: client);
    final ctx = await _rootContext();
    if (ctx == null || !ctx.mounted) return;
    final ok = await showDialog<bool>(
      context: ctx,
      builder: (c) => AlertDialog(
        key: const Key('link-import-confirm'),
        title: Text(l.callLinkImportTitle),
        content: Text(
          r.settings.isEmpty
              ? l.callLinkImportBody(url.host, r.accounts.length)
              : l.callLinkImportBodyWithSettings(url.host, r.accounts.length, r.settings.length),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: Text(l.actionCancel)),
          FilledButton(key: const Key('link-import-yes'), onPressed: () => Navigator.pop(c, true), child: Text(l.actionImport)),
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
