import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:cryptography/cryptography.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path/path.dart' as p;

/// Storage for secrets (account passwords).
abstract class SecretsStore {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> delete(String key);
}

class MemorySecretsStore implements SecretsStore {
  final Map<String, String> data = {};
  @override
  Future<String?> read(String key) async => data[key];
  @override
  Future<void> write(String key, String value) async => data[key] = value;
  @override
  Future<void> delete(String key) async => data.remove(key);
}

/// AES-GCM encrypted JSON file. The key lives in a sibling file with
/// restrictive permissions; this is a fallback for platforms without a
/// working keystore and is weaker than the OS keystore.
class EncryptedFileSecretsStore implements SecretsStore {
  EncryptedFileSecretsStore(String directory)
    : _file = File(p.join(directory, 'secrets.enc')),
      _keyFile = File(p.join(directory, 'secrets.key'));

  final File _file;
  final File _keyFile;
  final AesGcm _algo = AesGcm.with256bits();
  Map<String, String>? _cache;

  Future<SecretKey> _key() async {
    if (await _keyFile.exists()) {
      return SecretKey(base64Decode(await _keyFile.readAsString()));
    }
    final rnd = Random.secure();
    final bytes = List<int>.generate(32, (_) => rnd.nextInt(256));
    await _keyFile.parent.create(recursive: true);
    await _keyFile.writeAsString(base64Encode(bytes), flush: true);
    if (!Platform.isWindows) {
      await Process.run('chmod', ['600', _keyFile.path]);
    }
    return SecretKey(bytes);
  }

  Future<Map<String, String>> _load() async {
    if (_cache != null) return _cache!;
    if (!await _file.exists()) return _cache = {};
    try {
      final raw = base64Decode(await _file.readAsString());
      final box = SecretBox.fromConcatenation(
        raw,
        nonceLength: 12,
        macLength: 16,
      );
      final clear = await _algo.decrypt(box, secretKey: await _key());
      final m = jsonDecode(utf8.decode(clear)) as Map;
      return _cache = {for (final e in m.entries) '${e.key}': '${e.value}'};
    } catch (_) {
      return _cache = {};
    }
  }

  Future<void> _save(Map<String, String> m) async {
    final box = await _algo.encrypt(
      utf8.encode(jsonEncode(m)),
      secretKey: await _key(),
    );
    await _file.parent.create(recursive: true);
    await _file.writeAsString(base64Encode(box.concatenation()), flush: true);
  }

  @override
  Future<String?> read(String key) async => (await _load())[key];

  @override
  Future<void> write(String key, String value) async {
    final m = await _load();
    m[key] = value;
    await _save(m);
  }

  @override
  Future<void> delete(String key) async {
    final m = await _load();
    if (m.remove(key) != null) await _save(m);
  }
}

/// OS keystore first; falls back to [EncryptedFileSecretsStore] when the
/// keystore throws (e.g. unsigned macOS builds without keychain entitlement)
/// or, on Linux, has no Secret Service / a locked keyring (libsecret then
/// errors or waits for an unlock prompt: [keystoreTimeout] bounds the wait so
/// startup never hangs).
class KeystoreSecretsStore implements SecretsStore {
  KeystoreSecretsStore(
    this._fallback, {
    FlutterSecureStorage? storage,
    Duration? keystoreTimeout,
    bool? isLinux,
  }) : _storage = storage ?? const FlutterSecureStorage(),
       _timeout = keystoreTimeout ?? ((isLinux ?? (!kIsWeb && Platform.isLinux)) ? const Duration(seconds: 8) : null);

  final FlutterSecureStorage _storage;
  final SecretsStore _fallback;
  final Duration? _timeout;
  bool _useFallback = false;

  Future<T> _try<T>(Future<T> Function() op, Future<T> Function() fb) async {
    if (_useFallback) return fb();
    try {
      final f = op();
      return await (_timeout == null ? f : f.timeout(_timeout));
    } on PlatformException {
      _useFallback = true;
      return fb();
    } on MissingPluginException {
      _useFallback = true;
      return fb();
    } on TimeoutException {
      _useFallback = true;
      return fb();
    }
  }

  @override
  Future<String?> read(String key) async {
    final v = await _try(() => _storage.read(key: key), () async => null);
    return v ?? await _fallback.read(key);
  }

  @override
  Future<void> write(String key, String value) => _try(
    () => _storage.write(key: key, value: value),
    () => _fallback.write(key, value),
  );

  @override
  Future<void> delete(String key) async {
    await _try(() => _storage.delete(key: key), () async {});
    await _fallback.delete(key);
  }
}
