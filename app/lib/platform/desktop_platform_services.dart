import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:launch_at_startup/launch_at_startup.dart';
import 'package:window_manager/window_manager.dart';
import 'dart:ui' show Locale;

import '../l10n/l10n.dart';
import 'desktop/desktop_channel.dart';
import 'desktop/desktop_notifier.dart';
import 'desktop/tray_controller.dart';
import 'platform_services.dart';

/// macOS + Windows implementation of [PlatformServices]:
///  * notifications with Answer / Decline actions (local_notifier)
///  * tray / menu bar icon, flashing on incoming calls ([tray])
///  * sip:/sips:/tel:/callto:/softphonepro: links and second-launch arguments
///    ([DesktopChannel])
///  * start at login, bring-to-front, dock / taskbar badge
///
/// The app-level wiring (tray menu contents, hotkeys, close-to-tray, quit)
/// lives in `DesktopShell`.
class DesktopPlatformServices extends NoopPlatformServices {
  DesktopPlatformServices({
    this.startupArgs = const [],
    DesktopChannel? channel,
    TrayController? tray,
    DesktopNotifier? notifier,
  }) : channel = channel ?? DesktopChannel(),
       tray = tray ?? TrayController(),
       notifier = notifier ?? DesktopNotifier();

  final List<String> startupArgs;

  /// Supplies the current strings (set by the desktop shell, which can read
  /// the language setting); English until then.
  AppLocalizations Function()? l10n;
  AppLocalizations get _l => l10n?.call() ?? lookupAppLocalizations(const Locale('en'));
  final DesktopChannel channel;
  final TrayController tray;
  final DesktopNotifier notifier;

  final _links = StreamController<Uri>.broadcast();
  final _actions = StreamController<SystemCallAction>.broadcast();
  final _routes = StreamController<String>.broadcast();
  StreamSubscription<Uri>? _linkSub;
  StreamSubscription<void>? _showSub;
  Uri? _initial;
  bool _inCall = false;
  bool _ringing = false;
  int _badge = 0;
  String? _callTooltip;
  String _baseTooltip = 'SoftphonePro';
  Timer? _pulseOff;

  /// Routes (e.g. `/recents`) requested by clicking a notification.
  Stream<String> get routeRequests => _routes.stream;

  /// The app was launched with `--minimized` or as a macOS login item.
  bool get startMinimized => channel.startMinimized || channel.launchedAtLogin;

  @override
  bool get ringsViaOs => false;

  @override
  Future<void> init() async {
    await channel.init(startupArgs);
    _initial = channel.initialLink;
    _linkSub = channel.links.listen((u) {
      _links.add(u);
      unawaited(bringToFront());
    });
    _showSub = channel.showRequests.listen((_) => unawaited(bringToFront()));
    await notifier.init();
    if (Platform.isWindows) {
      launchAtStartup.setup(
        appName: 'SoftphonePro',
        appPath: Platform.resolvedExecutable,
        args: const ['--minimized'],
      );
    }
  }

  @override
  Future<void> dispose() async {
    _pulseOff?.cancel();
    await _linkSub?.cancel();
    await _showSub?.cancel();
    await tray.dispose();
    await channel.dispose();
    await _links.close();
    await _actions.close();
    await _routes.close();
  }

  // ---- links ----------------------------------------------------------------

  @override
  Stream<Uri> get incomingLinks => _links.stream;

  @override
  Future<Uri?> initialLink() async {
    final u = _initial;
    _initial = null;
    return u;
  }

  // ---- notifications ----------------------------------------------------------

  @override
  Stream<SystemCallAction> get systemCallActions => _actions.stream;

  @override
  Future<void> showIncomingCallNotification({
    required String callKey,
    required String title,
    required String body,
    String? accountName,
  }) async {
    // The window itself is the incoming banner while it is in front.
    if (await _windowInFront()) return;
    await notifier.showIncomingCall(
      callKey: callKey,
      title: title,
      body: body,
      answerLabel: _l.trayNotificationAnswer,
      declineLabel: _l.trayNotificationDecline,
      onTap: (tap) {
        switch (tap) {
          case NotificationTap.answer:
            _actions.add(SystemCallAction(SystemCallActionKind.answer, callKey));
            unawaited(bringToFront());
          case NotificationTap.decline:
            _actions.add(SystemCallAction(SystemCallActionKind.decline, callKey));
          case NotificationTap.body:
            unawaited(bringToFront());
        }
      },
    );
  }

  @override
  Future<void> cancelIncomingCallNotification(String callKey) =>
      notifier.cancelIncomingCall(callKey);

  @override
  Future<void> showMissedCallNotification({
    required String title,
    required String body,
    String? payload,
  }) => notifier.show(
    title: title,
    body: body,
    onClick: () {
      _routes.add('/recents');
      unawaited(bringToFront());
    },
  );

  @override
  Future<void> showMessageNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    if (await _windowInFront()) return;
    await notifier.show(
      title: title,
      body: body,
      onClick: () {
        _routes.add('/messages');
        unawaited(bringToFront());
      },
    );
  }

  Future<bool> _windowInFront() async {
    try {
      return await windowManager.isVisible() &&
          !await windowManager.isMinimized() &&
          await windowManager.isFocused();
    } catch (_) {
      return false;
    }
  }

  // ---- window / tray ---------------------------------------------------------

  @override
  Future<void> bringToFront() async {
    try {
      if (await windowManager.isMinimized()) await windowManager.restore();
      await windowManager.show();
      // Pulse always-on-top so Windows lets the window past focus-stealing
      // prevention; macOS needs the app activated.
      await windowManager.setAlwaysOnTop(true);
      await windowManager.focus();
      _pulseOff?.cancel();
      _pulseOff = Timer(const Duration(milliseconds: 1500), () async {
        try {
          await windowManager.setAlwaysOnTop(false);
        } catch (_) {}
      });
    } catch (e) {
      debugPrint('bringToFront failed: $e');
    }
  }

  @override
  Future<void> updateBadge(int count) async {
    _badge = count;
    unawaited(_pushTray());
    try {
      if (Platform.isMacOS) {
        await windowManager.setBadgeLabel(count > 0 ? '$count' : '');
      }
    } catch (_) {}
  }

  @override
  Future<void> updateTray({
    String? tooltip,
    int missedCalls = 0,
    bool inCall = false,
    bool ringing = false,
  }) async {
    _inCall = inCall;
    _ringing = ringing;
    _callTooltip = tooltip;
    await _pushTray();
  }

  /// Account summary shown in the tooltip, e.g. `SoftphonePro - 2/3 online`.
  Future<void> setTrayTooltip(String tooltip) {
    _baseTooltip = tooltip;
    return _pushTray();
  }

  Future<void> _pushTray() {
    var tip = _inCall ? (_callTooltip ?? _l.trayTooltipInCall) : _baseTooltip;
    if (_badge > 0) tip = _l.trayTooltipWithNew(tip, _badge);
    return tray.setState(tooltip: tip, ringing: _ringing, badge: _badge);
  }

  // ---- start at login ---------------------------------------------------------

  @override
  Future<void> setStartAtLogin(bool enabled) async {
    try {
      if (Platform.isMacOS) {
        await channel.setLoginItem(enabled);
      } else if (Platform.isWindows) {
        if (enabled) {
          await launchAtStartup.enable();
        } else {
          await launchAtStartup.disable();
        }
      }
    } catch (e) {
      debugPrint('setStartAtLogin failed: $e');
    }
  }
}
