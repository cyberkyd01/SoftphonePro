import 'dart:async';
import 'dart:io';
import 'dart:ui' show AppExitResponse, Locale;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:window_manager/window_manager.dart';

import '../../l10n/l10n.dart';
import '../../models/app_settings.dart';
import '../../services/accounts_controller.dart';
import '../../services/app_services.dart';
import '../../services/calls_controller.dart';
import '../../services/engine_controller.dart';
import '../../services/history_controller.dart';
import '../../services/messages_controller.dart';
import '../../services/providers.dart';
import '../../services/settings_controller.dart';
import '../../ui/router.dart';
import '../desktop_platform_services.dart';
import 'hotkeys.dart';
import 'media_keys.dart';
import 'tray_controller.dart';
import 'window_state.dart';

/// Tooltip such as `SoftphonePro - 2/3 online (Away)`.
String trayTooltipText({
  required int online,
  required int total,
  String status = 'available',
  AppLocalizations? l10n,
}) {
  final l = l10n ?? lookupAppLocalizations(const Locale('en'));
  if (total == 0) return l.trayTooltipNoAccounts(status);
  return l.trayTooltipOnline(online, total, status);
}

/// One account row of the tray menu.
class TrayAccount {
  const TrayAccount(this.id, this.name, this.registered);
  final String id;
  final String name;
  final bool registered;
}

/// The tray / menu-bar menu. Keys: `toggle`, `status:<available|away|dnd>`,
/// `acct:<id>`, `recents`, `quit`.
List<TrayMenuEntry> buildTrayMenu({
  required bool windowVisible,
  required String status,
  required List<TrayAccount> accounts,
  int badge = 0,
  AppLocalizations? l10n,
}) {
  final l = l10n ?? lookupAppLocalizations(const Locale('en'));
  return [
  TrayMenuEntry('toggle', windowVisible ? l.trayHideApp : l.trayShowApp),
  if (badge > 0) TrayMenuEntry('recents', l.trayNewOpenRecents(badge)),
  const TrayMenuEntry.separator(),
  TrayMenuEntry(
    'status',
    l.trayStatus,
    children: [
      TrayMenuEntry('status:available', l.statusAvailable, checked: status == 'available'),
      TrayMenuEntry('status:away', l.trayStatusAway, checked: status == 'away'),
      TrayMenuEntry('status:dnd', l.statusDoNotDisturb, checked: status == 'dnd'),
    ],
  ),
  TrayMenuEntry(
    'accounts',
    l.trayAccounts,
    disabled: accounts.isEmpty,
    children: [
      for (final a in accounts)
        TrayMenuEntry('acct:${a.id}', a.name, checked: a.registered),
    ],
  ),
  const TrayMenuEntry.separator(),
  TrayMenuEntry('quit', l.trayQuit),
  ];
}

/// Glue between the desktop OS shell and the app's controllers: tray menu,
/// global hotkeys, close-to-tray, remembered window geometry, graceful quit.
class DesktopShell with WindowListener {
  DesktopShell(this.ref);
  final Ref ref;

  late final DesktopPlatformServices _platform;
  bool _trayOk = false;
  bool _visible = true;
  bool _quitting = false;
  Timer? _saveBounds;
  AppLifecycleListener? _lifecycle;
  final List<ProviderSubscription<dynamic>> _subs = [];
  Map<HotkeyAction, HotkeyBinding?> _activeHotkeys = const {};
  MediaKeyController? _media;
  HotkeyMediaKeyBackend? _winMediaBackend;

  AppSettings get _settings => ref.read(settingsProvider);

  Future<void> start() async {
    final p = ref.read(platformServicesProvider);
    if (p is! DesktopPlatformServices) return;
    _platform = p;
    _platform.l10n = () => ref.read(l10nProvider);

    _subs.add(ref.listen<AccountsState>(accountsProvider, (_, _) => _refreshTray()));
    _subs.add(ref.listen<Locale>(appLocaleProvider, (_, _) => _refreshTray()));
    _subs.add(ref.listen<AppSettings>(settingsProvider, _onSettings));
    _subs.add(ref.listen<int>(missedCountProvider, (_, _) => _refreshTray()));
    _subs.add(ref.listen<int>(unreadMessagesProvider, (_, _) => _refreshTray()));
    _platform.routeRequests.listen((r) => ref.read(routerProvider).go(r));

    windowManager.addListener(this);
    try {
      await windowManager.setPreventClose(true);
    } catch (_) {}

    _trayOk = await _platform.tray.init(
      onMenu: _onMenu,
      onToggleWindow: () => unawaited(_toggleWindow()),
    );
    _refreshTray();


    _lifecycle = AppLifecycleListener(onExitRequested: () async {
      await _shutdown();
      return AppExitResponse.exit;
    });

    await _applyHotkeys();
    final MediaKeyBackend? mediaBackend = Platform.isMacOS
        ? ChannelMediaKeyBackend(_platform.channel)
        : Platform.isWindows
        ? (_winMediaBackend = HotkeyMediaKeyBackend())
        : null;
    if (mediaBackend != null) {
      _media = MediaKeyController(ref, mediaBackend)..start();
    }
    unawaited(_platform.setStartAtLogin(_settings.startAtLogin));

    // Autostart / login item: stay in the tray.
    if (_platform.startMinimized) {
      if (_trayOk && _closeToTray) {
        _visible = false;
      } else {
        await windowManager.show();
        await windowManager.minimize();
      }
      _refreshTray();
    }
  }

  Future<void> dispose() async {
    windowManager.removeListener(this);
    _saveBounds?.cancel();
    _lifecycle?.dispose();
    unawaited(_media?.dispose());
    for (final s in _subs) {
      s.close();
    }
    try {
      await hotKeyManager.unregisterAll();
    } catch (_) {}
  }

  bool get _closeToTray {
    final v = _settings.toJson()['minimizeToTray'];
    return v is bool ? v : true;
  }

  // ---- tray -------------------------------------------------------------------

  void _refreshTray() {
    if (!_trayOk) return;
    final acc = ref.read(accountsProvider);
    final enabled = acc.enabled;
    final online = enabled.where((p) => acc.statusOf(p.id) == AccountStatus.registered).length;
    final status = _settings.globalStatus;
    final int badge = (ref.read(missedCountProvider) + ref.read(unreadMessagesProvider)).toInt();
    unawaited(_platform.setTrayTooltip(trayTooltipText(online: online, total: enabled.length, status: status, l10n: ref.read(l10nProvider))));
    unawaited(
      _platform.tray.setMenu(
        buildTrayMenu(
          windowVisible: _visible,
          status: status,
          badge: badge,
          l10n: ref.read(l10nProvider),
          accounts: [
            for (final p in enabled)
              TrayAccount(p.id, p.name, acc.statusOf(p.id) == AccountStatus.registered),
          ],
        ),
      ),
    );
  }

  void _onMenu(String key) {
    if (key == 'toggle') {
      unawaited(_toggleWindow());
    } else if (key == 'quit') {
      unawaited(quit());
    } else if (key == 'recents') {
      ref.read(routerProvider).go('/recents');
      unawaited(_platform.bringToFront());
    } else if (key.startsWith('status:')) {
      unawaited(ref.read(settingsProvider.notifier).update({'globalStatus': key.substring(7)}));
    } else if (key.startsWith('acct:')) {
      final id = key.substring(5);
      final acc = ref.read(accountsProvider);
      final registered = acc.statusOf(id) == AccountStatus.registered;
      unawaited(ref.read(accountsProvider.notifier).register(id, !registered));
    }
  }

  Future<void> _toggleWindow() async {
    try {
      final shown = await windowManager.isVisible() && !await windowManager.isMinimized();
      if (shown && await windowManager.isFocused()) {
        await windowManager.hide();
        _visible = false;
      } else {
        await _platform.bringToFront();
        _visible = true;
      }
    } catch (_) {}
    _refreshTray();
  }

  // ---- settings ----------------------------------------------------------------

  void _onSettings(AppSettings? prev, AppSettings next) {
    if (prev == null) return;
    if (prev.globalStatus != next.globalStatus) _refreshTray();
    if (!mapEquals(prev.hotkeys, next.hotkeys)) unawaited(_applyHotkeys());
    if (prev.startAtLogin != next.startAtLogin) {
      unawaited(_platform.setStartAtLogin(next.startAtLogin));
    }
  }

  // ---- hotkeys -------------------------------------------------------------------

  Future<void> _applyHotkeys() async {
    final wanted = resolveHotkeys(_settings.hotkeys);
    if (mapEquals(wanted, _activeHotkeys)) return;
    try {
      await hotKeyManager.unregisterAll();
    } catch (_) {}
    for (final e in wanted.entries) {
      final b = e.value;
      if (b == null) continue;
      try {
        await hotKeyManager.register(
          b.toHotKey(identifier: 'softphonepro.${e.key.name}'),
          keyDownHandler: (_) => _runHotkey(e.key),
        );
      } catch (err) {
        debugPrint('hotkey ${e.key.name} (${b.serialize()}) not registered: $err');
      }
    }
    _activeHotkeys = wanted;
    // unregisterAll() also dropped the media-key hotkey (Windows).
    _winMediaBackend?.forgetRegistration();
    unawaited(_media?.reclaim());
  }

  void _runHotkey(HotkeyAction a) {
    final calls = ref.read(callsProvider);
    final ctl = ref.read(callsProvider.notifier);
    switch (a) {
      case HotkeyAction.answer:
        if (calls.ringing.isNotEmpty) unawaited(ctl.answer(calls.ringing.first.cid));
      case HotkeyAction.hangup:
        if (calls.ringing.isNotEmpty && calls.ongoing.isEmpty) {
          unawaited(ctl.decline(calls.ringing.first.cid));
        } else {
          final c = calls.focused ?? (calls.ongoing.isEmpty ? null : calls.ongoing.first);
          if (c != null) unawaited(ctl.hangup(c.cid));
        }
      case HotkeyAction.mute:
        final c = calls.focused;
        if (c != null) unawaited(ctl.toggleMute(c.cid));
      case HotkeyAction.focusDialer:
        unawaited(_platform.bringToFront());
        ref.read(routerProvider).go('/keypad');
        ref.read(dialFocusProvider.notifier).request();
    }
  }

  // ---- window events ---------------------------------------------------------------

  @override
  void onWindowClose() {
    if (_quitting) return;
    if (_trayOk && _closeToTray) {
      unawaited(windowManager.hide());
      _visible = false;
      _refreshTray();
    } else {
      unawaited(quit());
    }
  }

  @override
  void onWindowFocus() {
    if (!_visible) {
      _visible = true;
      _refreshTray();
    }
  }

  @override
  void onWindowResized() => _scheduleSaveBounds();
  @override
  void onWindowMoved() => _scheduleSaveBounds();
  @override
  void onWindowMaximize() => _scheduleSaveBounds();
  @override
  void onWindowUnmaximize() => _scheduleSaveBounds();

  void _scheduleSaveBounds() {
    _saveBounds?.cancel();
    _saveBounds = Timer(const Duration(milliseconds: 600), _saveWindowState);
  }

  Future<void> _saveWindowState() async {
    try {
      if (_quitting || await windowManager.isMinimized() || await windowManager.isFullScreen()) return;
      final maximized = await windowManager.isMaximized();
      final prev = SavedWindowState.fromJson(_settings.toJson()['windowBounds']);
      // While maximized keep the restored size/position.
      final bounds = maximized && prev != null ? prev.bounds : await windowManager.getBounds();
      await ref.read(settingsProvider.notifier).update({
        'windowBounds': SavedWindowState(bounds: bounds, maximized: maximized).toJson(),
      });
    } catch (_) {}
  }

  // ---- quit ----------------------------------------------------------------------------

  /// Unregisters accounts and stops the engine, then ends the process.
  Future<void> quit() async {
    await _shutdown();
    try {
      await windowManager.setPreventClose(false);
      await windowManager.destroy();
    } catch (_) {
      exit(0);
    }
  }

  Future<void> _shutdown() async {
    if (_quitting) return;
    _quitting = true;
    _saveBounds?.cancel();
    try {
      await hotKeyManager.unregisterAll();
    } catch (_) {}
    try {
      await _platform.tray.dispose();
    } catch (_) {}
    final ctl = ref.read(engineProvider.notifier);
    if (ctl.hasEngine) {
      try {
        await ctl.engine.stop(graceful: true).timeout(const Duration(seconds: 5));
      } catch (_) {}
    }
  }
}

/// Starts the desktop shell once; read it from the app root on desktop.
final desktopShellProvider = Provider<DesktopShell?>((ref) {
  final p = ref.read(platformServicesProvider);
  if (p is! DesktopPlatformServices) return null;
  final shell = DesktopShell(ref);
  unawaited(shell.start());
  ref.onDispose(() => unawaited(shell.dispose()));
  return shell;
});
