import 'package:window_manager/window_manager.dart';

import 'platform_services.dart';

/// Desktop implementation that only needs pure Dart / plugins:
/// brings the window to the front on incoming calls. Tray, URL handlers and
/// start-at-login are left to the native desktop agent.
class DesktopPlatformServices extends NoopPlatformServices {
  @override
  Future<void> bringToFront() async {
    try {
      if (await windowManager.isMinimized()) await windowManager.restore();
      await windowManager.show();
      await windowManager.focus();
    } catch (_) {}
  }

  @override
  Future<void> showIncomingCallNotification({
    required String callKey,
    required String title,
    required String body,
    String? accountName,
  }) => bringToFront();

  @override
  Future<void> updateBadge(int count) async {
    try {
      await windowManager.setBadgeLabel(count > 0 ? '$count' : '');
    } catch (_) {}
  }
}
