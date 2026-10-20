import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dbus/dbus.dart';
import 'package:flutter/foundation.dart';

const kNetworkManagerName = 'org.freedesktop.NetworkManager';

/// True when NetworkManager owns its name on the system bus. connectivity_plus
/// on Linux talks to NetworkManager (package `nm`) and throws an unhandled
/// SocketException / DBus error when there is no system bus (containers, lean
/// installs) or no NetworkManager (systemd-networkd, ifupdown, ...).
Future<bool> networkManagerAvailable({
  DBusClient? client,
  Duration timeout = const Duration(seconds: 3),
}) async {
  DBusClient? c = client;
  try {
    c ??= DBusClient.system();
    return await c.nameHasOwner(kNetworkManagerName).timeout(timeout);
  } catch (_) {
    return false;
  } finally {
    if (client == null) {
      try {
        await c?.close().timeout(const Duration(seconds: 1));
      } catch (_) {}
    }
  }
}

/// Connectivity changes that can never throw: when the platform source cannot
/// be created or fails, the stream simply ends / goes quiet, which callers treat
/// as "network unknown, assume online" (they only react to *changes*).
///
/// On Linux the source is not touched at all unless NetworkManager is present
/// ([nmAvailable], injectable for tests); [source] is created lazily.
///
/// Broadcast, like the plugin's own stream: the engine and the LAN controller both listen.
Stream<List<ConnectivityResult>> guardedConnectivityStream({
  Stream<List<ConnectivityResult>> Function()? source,
  Future<bool> Function()? nmAvailable,
  bool? isLinux,
}) => _guarded(source, nmAvailable, isLinux).asBroadcastStream();

Stream<List<ConnectivityResult>> _guarded(
  Stream<List<ConnectivityResult>> Function()? source,
  Future<bool> Function()? nmAvailable,
  bool? isLinux,
) async* {
  final linux = isLinux ?? (!kIsWeb && Platform.isLinux);
  try {
    if (linux && !await (nmAvailable ?? networkManagerAvailable)()) {
      debugPrint('connectivity: NetworkManager not available, network changes will not be tracked');
      return;
    }
    final stream = (source ?? () => Connectivity().onConnectivityChanged)();
    await for (final e in stream.handleError((Object err) => debugPrint('connectivity: $err'))) {
      yield e;
    }
  } catch (e) {
    debugPrint('connectivity: stream failed: $e');
  }
}

/// One-shot check that never throws; unknown means "online".
Future<List<ConnectivityResult>> safeCheckConnectivity({
  Future<List<ConnectivityResult>> Function()? check,
  Future<bool> Function()? nmAvailable,
  bool? isLinux,
}) async {
  final linux = isLinux ?? (!kIsWeb && Platform.isLinux);
  try {
    if (linux && !await (nmAvailable ?? networkManagerAvailable)()) return const [ConnectivityResult.other];
    return await (check ?? Connectivity().checkConnectivity)();
  } catch (_) {
    return const [ConnectivityResult.other];
  }
}
