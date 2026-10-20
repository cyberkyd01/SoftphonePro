import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/l10n.dart';
import '../services/providers.dart';
import '../services/settings_controller.dart';
import 'app_lock_service.dart';
import 'biometric_auth.dart';

final appLockServiceProvider = Provider<AppLockService>((ref) => AppLockService(ref.watch(secretsStoreProvider)));

/// Linux has no biometric plugin: PIN only.
final biometricAuthProvider = Provider<BiometricAuth>(
  (ref) => !kIsWeb && Platform.isLinux ? const NoBiometrics() : LocalAuthBiometrics(),
);

/// Whether the app is currently locked. Starts locked when the lock is on.
class AppLockController extends Notifier<bool> {
  DateTime? _backgroundedAt;

  @override
  bool build() => ref.read(settingsProvider).appLock;

  AppLockService get _service => ref.read(appLockServiceProvider);

  void lock() {
    if (ref.read(settingsProvider).appLock) state = true;
  }

  /// Unlocks if the lock is enabled but no PIN exists (cannot be satisfied).
  Future<void> recoverIfNoPin() async {
    if (state && !await _service.hasPin()) {
      await ref.read(settingsProvider.notifier).update({'appLock': false});
      state = false;
    }
  }

  Future<PinCheck> unlockWithPin(String pin) async {
    final r = await _service.verify(pin);
    if (r.ok) state = false;
    return r;
  }

  Future<bool> unlockWithBiometrics() async {
    final s = ref.read(settingsProvider);
    if (!s.appLockBiometrics) return false;
    final bio = ref.read(biometricAuthProvider);
    if (!await bio.isAvailable()) return false;
    final ok = await bio.authenticate(ref.read(l10nProvider).appLockBiometricReason);
    if (ok) state = false;
    return ok;
  }

  /// Sets the PIN and turns the lock on (does not lock immediately).
  Future<void> enable(String pin) async {
    await _service.setPin(pin);
    await ref.read(settingsProvider.notifier).update({'appLock': true});
  }

  Future<void> disable() async {
    await _service.clear();
    await ref.read(settingsProvider.notifier).update({'appLock': false});
    state = false;
  }

  void onBackground([DateTime? now]) => _backgroundedAt = now ?? DateTime.now();

  /// Locks when the app was in the background for at least the configured
  /// delay (0 = lock as soon as it leaves the foreground).
  void onResume([DateTime? now]) {
    final at = _backgroundedAt;
    _backgroundedAt = null;
    final s = ref.read(settingsProvider);
    if (!s.appLock || at == null) return;
    final away = (now ?? DateTime.now()).difference(at);
    if (away >= Duration(minutes: s.appLockMinutes)) state = true;
  }
}

/// True when biometrics are enabled in settings and the device has them.
final biometricUsableProvider = FutureProvider<bool>((ref) async {
  if (!ref.watch(settingsProvider.select((s) => s.appLockBiometrics))) return false;
  return ref.watch(biometricAuthProvider).isAvailable();
});

final appLockProvider = NotifierProvider<AppLockController, bool>(AppLockController.new);
