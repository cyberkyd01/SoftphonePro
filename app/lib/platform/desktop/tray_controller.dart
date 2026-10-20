import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:tray_manager/tray_manager.dart';

import 'linux_session.dart';

/// Platform independent description of a tray menu entry.
class TrayMenuEntry {
  const TrayMenuEntry(
    this.key,
    this.label, {
    this.checked,
    this.disabled = false,
    this.children,
  }) : separator = false;
  const TrayMenuEntry.separator()
    : key = '',
      label = '',
      checked = null,
      disabled = true,
      children = null,
      separator = true;

  final String key;
  final String label;
  final bool? checked;
  final bool disabled;
  final List<TrayMenuEntry>? children;
  final bool separator;
}

/// System tray (Windows) / menu bar (macOS) / AppIndicator (Linux) icon with
/// a context menu, a tooltip and an alert state (flashing while ringing,
/// steady for missed calls / unread messages).
///
/// Linux: AppIndicator gives no click events (a click opens the menu, which
/// therefore carries a Show / Hide item) and only shows up when a
/// StatusNotifierItem host runs, so [init] probes for one first.
class TrayController with TrayListener {
  TrayController({bool? isLinux, Future<bool> Function()? linuxHostCheck})
    : _linux = isLinux ?? (!kIsWeb && Platform.isLinux),
      _mac = isLinux == true ? false : (!kIsWeb && Platform.isMacOS),
      _hostCheck = linuxHostCheck;

  static const _iconWin = 'assets/branding/tray_icon.ico';
  static const _iconWinAlert = 'assets/branding/tray_icon_alert.ico';
  static const _iconMac = 'assets/branding/tray_mac_template.png';
  static const _iconLinux = 'assets/branding/tray_linux.png';
  static const _iconLinuxAlert = 'assets/branding/tray_linux_alert.png';

  final bool _linux;
  final bool _mac;
  final Future<bool> Function()? _hostCheck;

  /// Asset used for the tray icon on Linux (AppIndicator needs PNG / SVG).
  static String linuxIcon({required bool alert}) => alert ? _iconLinuxAlert : _iconLinux;

  bool _ready = false;
  bool get ready => _ready;

  void Function(String key)? _onMenu;
  VoidCallback? _onToggleWindow;

  String _tooltip = 'SoftphonePro';
  bool _ringing = false;
  int _badge = 0;
  bool _flashOn = false;
  Timer? _flash;
  String? _lastIcon;
  String? _lastTitle;
  String? _lastTooltip;

  /// Creates the tray icon. Returns false if the platform refuses (the app
  /// then must not hide its window).
  ///
  /// Linux: false without a StatusNotifierWatcher (e.g. stock GNOME), checked
  /// [linuxHostAttempts] times one second apart (use more at login, when the
  /// panel may still be starting).
  Future<bool> init({
    required void Function(String key) onMenu,
    required VoidCallback onToggleWindow,
    int linuxHostAttempts = 1,
  }) async {
    _onMenu = onMenu;
    _onToggleWindow = onToggleWindow;
    if (_linux && !await waitForTrayHost(check: _hostCheck, attempts: linuxHostAttempts)) {
      debugPrint('tray unavailable: no StatusNotifierWatcher on the session bus');
      _ready = false;
      return false;
    }
    try {
      trayManager.addListener(this);
      await _applyIcon(force: true);
      await _applyTooltip(force: true);
      _ready = true;
    } catch (e) {
      debugPrint('tray init failed: $e');
      _ready = false;
    }
    return _ready;
  }

  Future<void> setMenu(List<TrayMenuEntry> entries) async {
    if (!_ready) return;
    try {
      await trayManager.setContextMenu(Menu(items: _convert(entries)));
    } catch (e) {
      debugPrint('tray menu failed: $e');
    }
  }

  /// Updates tooltip / alert state. [ringing] flashes; [badge] > 0 shows the
  /// steady alert.
  Future<void> setState({String? tooltip, bool? ringing, int? badge}) async {
    if (tooltip != null) _tooltip = tooltip;
    if (badge != null) _badge = badge;
    if (ringing != null && ringing != _ringing) {
      _ringing = ringing;
      _flash?.cancel();
      _flash = null;
      _flashOn = false;
      if (ringing) {
        _flashOn = true;
        _flash = Timer.periodic(const Duration(milliseconds: 700), (_) {
          _flashOn = !_flashOn;
          unawaited(_applyIcon());
        });
      }
    }
    if (!_ready) return;
    await _applyIcon();
    await _applyTooltip();
  }

  bool get _alert => _ringing ? _flashOn : _badge > 0;

  Future<void> _applyIcon({bool force = false}) async {
    try {
      if (_mac) {
        if (_lastIcon != _iconMac || force) {
          _lastIcon = _iconMac;
          await trayManager.setIcon(_iconMac, isTemplate: true);
        }
        // Menu-bar images are templates (cannot be coloured): flash a
        // title next to the icon instead.
        final title = _alert ? (_badge > 0 && !_ringing ? ' $_badge' : ' ●') : '';
        if (title != _lastTitle || force) {
          _lastTitle = title;
          await trayManager.setTitle(title);
        }
      } else {
        final icon = _linux ? linuxIcon(alert: _alert) : (_alert ? _iconWinAlert : _iconWin);
        if (icon != _lastIcon || force) {
          _lastIcon = icon;
          await trayManager.setIcon(icon);
        }
      }
    } catch (e) {
      debugPrint('tray icon failed: $e');
    }
  }

  Future<void> _applyTooltip({bool force = false}) async {
    if (_tooltip == _lastTooltip && !force) return;
    _lastTooltip = _tooltip;
    try {
      await trayManager.setToolTip(_tooltip);
    } catch (e) {
      debugPrint('tray tooltip failed: $e');
    }
  }

  List<MenuItem> _convert(List<TrayMenuEntry> entries) => [
    for (final e in entries)
      if (e.separator)
        MenuItem.separator()
      else if (e.children != null)
        MenuItem.submenu(
          key: e.key,
          label: e.label,
          disabled: e.disabled,
          submenu: Menu(items: _convert(e.children!)),
        )
      else if (e.checked != null)
        MenuItem.checkbox(
          key: e.key,
          label: e.label,
          checked: e.checked!,
          disabled: e.disabled,
        )
      else
        MenuItem(key: e.key, label: e.label, disabled: e.disabled),
  ];

  Future<void> dispose() async {
    _flash?.cancel();
    _flash = null;
    if (!_ready) return;
    _ready = false;
    try {
      trayManager.removeListener(this);
      await trayManager.destroy();
    } catch (_) {}
  }

  // ---- TrayListener ----------------------------------------------------------

  @override
  void onTrayIconMouseDown() {
    if (_mac) {
      unawaited(trayManager.popUpContextMenu());
    } else {
      _onToggleWindow?.call();
    }
  }

  @override
  void onTrayIconRightMouseDown() {
    unawaited(trayManager.popUpContextMenu());
  }

  @override
  void onTrayMenuItemClick(MenuItem menuItem) {
    final k = menuItem.key;
    if (k != null && k.isNotEmpty) _onMenu?.call(k);
  }
}
