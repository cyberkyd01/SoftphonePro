import 'dart:async';
import 'dart:io';

import 'package:dbus/dbus.dart';

/// Linux session facts, as pure functions of the environment so tests can
/// feed any combination.
///
/// X11 session: `XDG_SESSION_TYPE=x11`, or (when that is unset/unknown) a
/// `DISPLAY` without a `WAYLAND_DISPLAY`. XWayland also sets `DISPLAY`, hence
/// `WAYLAND_DISPLAY` wins.
bool isX11Session(Map<String, String> env) {
  final type = (env['XDG_SESSION_TYPE'] ?? '').toLowerCase();
  if (type == 'x11') return true;
  if (type == 'wayland') return false;
  final display = env['DISPLAY'] ?? '';
  final wayland = env['WAYLAND_DISPLAY'] ?? '';
  return display.isNotEmpty && wayland.isEmpty;
}

/// Global hotkeys (hotkey_manager/keybinder) exist on macOS, Windows and X11.
bool hotkeysSupportedOn({
  required bool isMacOS,
  required bool isWindows,
  required bool isLinux,
  Map<String, String> env = const {},
}) => isMacOS || isWindows || (isLinux && isX11Session(env));

/// Name of the StatusNotifierItem host that AppIndicator icons need.
const kStatusNotifierWatcher = 'org.kde.StatusNotifierWatcher';

/// True when a StatusNotifierWatcher owns its name on the session bus (so a
/// tray icon would actually be visible). No session bus / any error -> false.
Future<bool> statusNotifierHostAvailable({
  DBusClient? client,
  Duration timeout = const Duration(seconds: 3),
}) async {
  final c = client ?? DBusClient.session();
  try {
    return await c.nameHasOwner(kStatusNotifierWatcher).timeout(timeout);
  } catch (_) {
    return false;
  } finally {
    if (client == null) {
      try {
        await c.close().timeout(const Duration(seconds: 1));
      } catch (_) {}
    }
  }
}

/// Polls [check] up to [attempts] times, [delay] apart (a panel started at
/// login may publish its watcher a few seconds after the app).
Future<bool> waitForTrayHost({
  Future<bool> Function()? check,
  int attempts = 1,
  Duration delay = const Duration(seconds: 1),
}) async {
  final probe = check ?? statusNotifierHostAvailable;
  for (var i = 0; i < attempts; i++) {
    if (i > 0) await Future<void>.delayed(delay);
    try {
      if (await probe()) return true;
    } catch (_) {}
  }
  return false;
}

Map<String, String> get linuxEnvironment => Platform.environment;
