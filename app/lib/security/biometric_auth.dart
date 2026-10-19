import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

/// Biometric unlock (Face ID / Touch ID / fingerprint / Windows Hello).
abstract class BiometricAuth {
  /// True when the device has enrolled biometrics the app can use.
  Future<bool> isAvailable();

  /// Prompts the user; false on cancel, failure or when unavailable.
  Future<bool> authenticate(String reason);
}

class LocalAuthBiometrics implements BiometricAuth {
  LocalAuthBiometrics([LocalAuthentication? auth]) : _auth = auth ?? LocalAuthentication();
  final LocalAuthentication _auth;

  @override
  Future<bool> isAvailable() async {
    try {
      if (!await _auth.canCheckBiometrics) return false;
      return (await _auth.getAvailableBiometrics()).isNotEmpty;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }

  @override
  Future<bool> authenticate(String reason) async {
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(biometricOnly: true, stickyAuth: true),
      );
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }
}

/// For tests and platforms without biometrics.
class NoBiometrics implements BiometricAuth {
  const NoBiometrics();
  @override
  Future<bool> isAvailable() async => false;
  @override
  Future<bool> authenticate(String reason) async => false;
}
