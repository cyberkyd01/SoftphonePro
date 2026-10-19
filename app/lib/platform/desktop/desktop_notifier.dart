import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:local_notifier/local_notifier.dart';

enum NotificationTap { body, answer, decline }

/// Desktop notifications (macOS Notification Center, Windows toasts).
class DesktopNotifier {
  bool _ready = false;
  final Map<String, LocalNotification> _incoming = {};
  final Set<LocalNotification> _alive = {}; // keep listeners referenced

  Future<void> init() async {
    try {
      await localNotifier.setup(
        appName: 'SoftphonePro',
        shortcutPolicy: ShortcutPolicy.requireCreate,
      );
      _ready = true;
    } catch (e) {
      debugPrint('notifications unavailable: $e');
    }
  }

  /// Incoming call banner with Answer / Decline buttons; [onTap] reports what
  /// the user pressed.
  Future<void> showIncomingCall({
    required String callKey,
    required String title,
    required String body,
    required void Function(NotificationTap tap) onTap,
  }) async {
    if (!_ready) return;
    await cancelIncomingCall(callKey);
    final n = LocalNotification(
      identifier: 'call-$callKey',
      title: title,
      body: body,
      actions: [
        LocalNotificationAction(text: 'Answer'),
        LocalNotificationAction(text: 'Decline'),
      ],
    );
    n.onClick = () => onTap(NotificationTap.body);
    n.onClickAction = (i) => onTap(i == 0 ? NotificationTap.answer : NotificationTap.decline);
    n.onClose = (_) => _alive.remove(n);
    _incoming[callKey] = n;
    _alive.add(n);
    await _show(n);
  }

  Future<void> cancelIncomingCall(String callKey) async {
    final n = _incoming.remove(callKey);
    if (n == null) return;
    _alive.remove(n);
    try {
      await n.close();
    } catch (_) {}
  }

  /// A plain notification; [onClick] runs when the body is clicked.
  Future<void> show({
    required String title,
    required String body,
    required VoidCallback onClick,
  }) async {
    if (!_ready) return;
    final n = LocalNotification(title: title, body: body);
    n.onClick = onClick;
    n.onClose = (_) => _alive.remove(n);
    _alive.add(n);
    await _show(n);
  }

  Future<void> _show(LocalNotification n) async {
    try {
      await n.show();
    } catch (e) {
      debugPrint('notification failed: $e');
      _alive.remove(n);
    }
  }
}
