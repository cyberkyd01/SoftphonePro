import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:screen_retriever/screen_retriever.dart';
import 'package:window_manager/window_manager.dart';

import 'app.dart';
import 'l10n/l10n.dart';
import 'platform/android/android_background.dart';
import 'platform/android/android_platform_services.dart';
import 'platform/desktop/window_state.dart';
import 'platform/desktop_platform_services.dart';
import 'platform/ios/ios_platform_services.dart';
import 'platform/platform_services.dart';
import 'services/app_services.dart';
import 'services/providers.dart';
import 'storage/secrets_store.dart';
import 'ui/pages/db_recovery.dart';
import 'ui/settings/native_licenses.dart';

Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  registerNativeLicenses();

  final desktop = !kIsWeb && (Platform.isMacOS || Platform.isWindows || Platform.isLinux);
  // Tray, hotkeys, URL handlers and notifications exist for macOS + Windows.
  final fullDesktop = !kIsWeb && (Platform.isMacOS || Platform.isWindows);

  final supportDir = (await getApplicationSupportDirectory()).path;
  final secrets = KeystoreSecretsStore(EncryptedFileSecretsStore(p.join(supportDir, 'secrets')));
  final db = await openDatabaseOrRecover(supportDir, secrets);
  final boot = await loadBootData(db, secrets);

  final PlatformServices platform = fullDesktop
      ? DesktopPlatformServices(startupArgs: args)
      : desktop
          ? NoopPlatformServices()
          : (!kIsWeb && Platform.isAndroid)
              ? AndroidPlatformServices()
              : (!kIsWeb && Platform.isIOS)
                  ? IosPlatformServices()
                  : NoopPlatformServices(mobile: true);
  await platform.init();
  final startMinimized = platform is DesktopPlatformServices ? platform.startMinimized : args.contains('--minimized');

  if (desktop) {
    await windowManager.ensureInitialized();
    final saved = SavedWindowState.fromJson(boot.settings.toJson()['windowBounds']);
    Rect? restore;
    try {
      final displays = await screenRetriever.getAllDisplays();
      restore = saved?.onScreenBounds([
        for (final d in displays)
          (d.visiblePosition ?? Offset.zero) & (d.visibleSize ?? d.size),
      ]);
    } catch (_) {}
    await windowManager.waitUntilReadyToShow(
      WindowOptions(
        size: restore?.size ?? const Size(1200, 780),
        minimumSize: const Size(380, 640),
        center: restore == null,
        title: 'SoftphonePro',
        titleBarStyle: TitleBarStyle.normal,
      ),
      () async {
        if (restore != null) await windowManager.setBounds(restore);
        if (startMinimized) {
          // Autostart: stay in the tray (DesktopShell shows the window again
          // if there is no tray icon).
          if (Platform.isMacOS) await windowManager.hide();
        } else {
          if (saved?.maximized == true) await windowManager.maximize();
          await windowManager.show();
          await windowManager.focus();
        }
      },
    );
  }

  final container = ProviderContainer(
    overrides: [
      appDatabaseProvider.overrideWithValue(db),
      secretsStoreProvider.overrideWithValue(secrets),
      bootDataProvider.overrideWithValue(boot),
      platformServicesProvider.overrideWithValue(platform),
    ],
  );
  if (!kIsWeb && Platform.isAndroid) {
    // The Android engine may run headless (boot / background service): start
    // the controllers now instead of waiting for the first frame.
    container.read(appServicesProvider);
    container.read(androidBackgroundProvider);
  }

  final startupNotice = db.startupNotice;
  if (startupNotice != null) {
    Future<void>.delayed(const Duration(seconds: 1), () => container.read(noticeProvider.notifier).error(container.read(l10nProvider).appDbConversionFailed(startupNotice.encrypt ? 'encrypt' : 'decrypt', startupNotice.error)));
  }

  runApp(UncontrolledProviderScope(container: container, child: const SoftphoneApp()));
}
