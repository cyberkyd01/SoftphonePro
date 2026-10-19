import 'dart:convert';
import 'dart:math';

import 'package:cryptography/cryptography.dart';

import '../storage/secrets_store.dart';

/// Result of checking a PIN.
enum PinResult { ok, wrong, lockedOut }

class PinCheck {
  const PinCheck(this.result, {this.retryAfter = Duration.zero, this.failures = 0});
  final PinResult result;

  /// How long until another attempt is accepted (only for [PinResult.lockedOut]
  /// and for the wrong attempt that started a lockout).
  final Duration retryAfter;

  /// Consecutive wrong attempts so far.
  final int failures;

  bool get ok => result == PinResult.ok;
}

/// Stores a salted PBKDF2-HMAC-SHA256 hash of the app-lock PIN in the secrets
/// store and rate-limits guesses with exponential backoff.
class AppLockService {
  AppLockService(
    this._store, {
    this.iterations = 100000,
    DateTime Function()? now,
    Random? random,
  }) : _now = now ?? DateTime.now,
       _random = random ?? Random.secure();

  static const minPinLength = 4;
  static const maxPinLength = 8;

  /// Wrong attempts allowed before the first lockout.
  static const freeAttempts = 4;

  static const _kHash = 'applock.pin';
  static const _kFails = 'applock.fails';
  static const _kUntil = 'applock.until';

  final SecretsStore _store;
  final int iterations;
  final DateTime Function() _now;
  final Random _random;

  static bool isValidPin(String pin) =>
      pin.length >= minPinLength &&
      pin.length <= maxPinLength &&
      RegExp(r'^[0-9]+$').hasMatch(pin);

  /// Lockout after [failures] consecutive wrong PINs: none for the first
  /// [freeAttempts], then 30 s doubling up to 15 min.
  static Duration backoffFor(int failures) {
    if (failures <= freeAttempts) return Duration.zero;
    final secs = 30 * pow(2, failures - freeAttempts - 1).toInt();
    return Duration(seconds: min(secs, 15 * 60));
  }

  Future<bool> hasPin() async => (await _store.read(_kHash)) != null;

  Future<List<int>> _derive(String pin, List<int> salt, int iters) async {
    final algo = Pbkdf2.hmacSha256(iterations: iters, bits: 256);
    final key = await algo.deriveKeyFromPassword(password: pin, nonce: salt);
    return key.extractBytes();
  }

  Future<void> setPin(String pin) async {
    if (!isValidPin(pin)) {
      throw ArgumentError('PIN must be $minPinLength-$maxPinLength digits');
    }
    final salt = List<int>.generate(16, (_) => _random.nextInt(256));
    final hash = await _derive(pin, salt, iterations);
    await _store.write(_kHash, 'pbkdf2-sha256\$$iterations\$${base64Encode(salt)}\$${base64Encode(hash)}');
    await _resetFailures();
  }

  Future<void> clear() async {
    await _store.delete(_kHash);
    await _resetFailures();
  }

  Future<void> _resetFailures() async {
    await _store.delete(_kFails);
    await _store.delete(_kUntil);
  }

  /// Remaining lockout, or zero.
  Future<Duration> lockoutRemaining() async {
    final until = int.tryParse(await _store.read(_kUntil) ?? '');
    if (until == null) return Duration.zero;
    final left = DateTime.fromMillisecondsSinceEpoch(until).difference(_now());
    return left.isNegative ? Duration.zero : left;
  }

  Future<PinCheck> verify(String pin) async {
    final fails = int.tryParse(await _store.read(_kFails) ?? '') ?? 0;
    final left = await lockoutRemaining();
    if (left > Duration.zero) {
      return PinCheck(PinResult.lockedOut, retryAfter: left, failures: fails);
    }
    final stored = await _store.read(_kHash);
    if (stored == null) return const PinCheck(PinResult.ok);
    final parts = stored.split(r'$');
    var good = false;
    if (parts.length == 4 && parts[0] == 'pbkdf2-sha256') {
      final iters = int.tryParse(parts[1]) ?? iterations;
      final expect = base64Decode(parts[3]);
      final got = await _derive(pin, base64Decode(parts[2]), iters);
      good = _constantTimeEquals(expect, got);
    }
    if (good) {
      await _resetFailures();
      return const PinCheck(PinResult.ok);
    }
    final n = fails + 1;
    final wait = backoffFor(n);
    await _store.write(_kFails, '$n');
    if (wait > Duration.zero) {
      await _store.write(_kUntil, '${_now().add(wait).millisecondsSinceEpoch}');
    }
    return PinCheck(PinResult.wrong, retryAfter: wait, failures: n);
  }

  static bool _constantTimeEquals(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    var d = 0;
    for (var i = 0; i < a.length; i++) {
      d |= a[i] ^ b[i];
    }
    return d == 0;
  }
}
