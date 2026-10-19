import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/accounts_controller.dart';
import '../../services/engine_controller.dart';
import '../../services/providers.dart';
import '../../services/settings_controller.dart';
import '../../ui/router.dart';
import '../platform_services.dart';
import 'android_platform_services.dart';

/// Glue between app state and the Android-only native pieces:
///  * keeps the registration foreground service in sync with the accounts
///  * multicast lock while LAN discovery is enabled
///  * DNS servers of the active network -> engine
///  * notification taps -> router
///  * first-run permission prompt
/// No-op on other platforms or when a different PlatformServices is in use.
final androidBackgroundProvider = Provider<void>((ref) {
  final platform = ref.watch(platformServicesProvider);
  if (platform is! AndroidPlatformServices) return;

  Timer? debounce;
  void syncService() {
    debounce?.cancel();
    debounce = Timer(const Duration(milliseconds: 400), () {
      final a = ref.read(accountsProvider);
      final enabled = a.enabled;
      final online = enabled.where((p) => a.statusOf(p.id) == AccountStatus.registered).length;
      unawaited(platform.setBackgroundService(enabled: enabled.isNotEmpty, online: online, total: enabled.length));
    });
  }

  ref.listen(accountsProvider, (_, _) => syncService(), fireImmediately: true);
  ref.onDispose(() => debounce?.cancel());

  ref.listen(settingsProvider.select((s) => s.lanEnabled), (_, on) {
    unawaited(platform.setMulticastLock(on));
  }, fireImmediately: true);

  final dnsSub = platform.dnsChanges.listen((servers) async {
    final eng = ref.read(engineProvider.notifier);
    if (!eng.hasEngine || servers.isEmpty) return;
    if (ref.read(settingsProvider).dnsServers.isNotEmpty) return;
    try {
      await eng.engine.setNameservers(servers);
    } catch (e) {
      debugPrint('setNameservers failed: $e');
    }
  });
  final navSub = platform.routeRequests.listen((route) {
    try {
      ref.read(routerProvider).go(route);
    } catch (e) {
      debugPrint('route $route failed: $e');
    }
  });
  ref.onDispose(() {
    dnsSub.cancel();
    navSub.cancel();
  });

  // Ask for the runtime permissions once the first frame is up.
  Future<void>.delayed(const Duration(milliseconds: 1200), () async {
    try {
      final st = await platform.status();
      if (st.microphone != PermissionStatus.granted || st.notifications == PermissionStatus.denied) {
        await platform.requestAll();
      }
    } catch (e) {
      debugPrint('permission request failed: $e');
    }
  });
});
