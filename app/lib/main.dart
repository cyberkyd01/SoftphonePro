import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:window_manager/window_manager.dart';

import 'app.dart';
import 'platform/android/android_background.dart';
import 'platform/android/android_platform_services.dart';
import 'platform/desktop_platform_services.dart';
import 'platform/platform_services.dart';
import 'services/app_services.dart';
import 'services/providers.dart';
import 'storage/app_database.dart';
import 'storage/secrets_store.dart';

Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();

  final desktop = !kIsWeb && (Platform.isMacOS || Platform.isWindows || Platform.isLinux);
  final minimized = args.contains('--minimized');
  if (desktop) {
    await windowManager.ensureInitialized();
    await windowManager.waitUntilReadyToShow(
      const WindowOptions(
        size: Size(1200, 780),
        minimumSize: Size(380, 640),
        center: true,
        title: 'SoftphonePro',
        titleBarStyle: TitleBarStyle.normal,
      ),
      () async {
        if (minimized) {
          await windowManager.minimize();
        } else {
          await windowManager.show();
          await windowManager.focus();
        }
      },
    );
  }

  final db = await AppDatabase.openDefault();
  final supportDir = db.directory ?? (await getApplicationSupportDirectory()).path;
  final secrets = KeystoreSecretsStore(EncryptedFileSecretsStore(p.join(supportDir, 'secrets')));
  final boot = await loadBootData(db, secrets);
  final PlatformServices platform = desktop
      ? DesktopPlatformServices()
      : (!kIsWeb && Platform.isAndroid)
      ? AndroidPlatformServices()
      : NoopPlatformServices(mobile: true);
  await platform.init();

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

  runApp(UncontrolledProviderScope(container: container, child: const SoftphoneApp()));
}
