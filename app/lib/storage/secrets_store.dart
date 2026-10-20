import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:cryptography/cryptography.dart';
import 'package:dbus/dbus.dart';
import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path/path.dart' as p;

/// Storage for secrets (account passwords).
abstract class SecretsStore {
  /// Every key currently stored (used to migrate the file store into the
  /// keyring).
  Future<List<String>> keys();
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> delete(String key);
}

class MemorySecretsStore implements SecretsStore {
  final Map<String, String> data = {};
  @override
  Future<List<String>> keys() async => data.keys.toList();
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
  Future<List<String>> keys() async => (await _load()).keys.toList();

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

/// State of the freedesktop Secret Service as seen over D-Bus.
enum SecretServiceState {
  /// Not on the bus, not answering in time, or no default collection.
  unavailable,

  /// Answers and the default collection is locked.
  locked,

  /// Answers and the default collection is unlocked.
  unlocked,
}

/// The few Secret Service calls we need, so the logic can be tested with a fake.
abstract class SecretServiceBus {
  /// Path of the collection aliased `default`, or '/' when there is none.
  Future<String> defaultCollection();
  Future<bool> isLocked(String collection);

  /// `Service.Unlock([collection])`; returns the prompt path ('/' = none needed).
  Future<String> unlock(String collection);

  /// `Prompt.Prompt("")`, then waits for `Completed`; true when not dismissed.
  Future<bool> runPrompt(String prompt);
  Future<void> close();
}

class DBusSecretServiceBus implements SecretServiceBus {
  DBusSecretServiceBus([DBusClient? client])
    : _owned = client == null,
      _c = client ?? DBusClient.session();
  final DBusClient _c;
  final bool _owned;
  static const _name = 'org.freedesktop.secrets';

  DBusRemoteObject get _service => DBusRemoteObject(
    _c,
    name: _name,
    path: DBusObjectPath('/org/freedesktop/secrets'),
  );

  @override
  Future<String> defaultCollection() async {
    final reply = await _service.callMethod(
      'org.freedesktop.Secret.Service',
      'ReadAlias',
      [DBusString('default')],
      replySignature: DBusSignature('o'),
    );
    return (reply.returnValues.first as DBusObjectPath).value;
  }

  @override
  Future<bool> isLocked(String collection) async {
    final locked = await DBusRemoteObject(
      _c,
      name: _name,
      path: DBusObjectPath(collection),
    ).getProperty('org.freedesktop.Secret.Collection', 'Locked');
    return !(locked is DBusBoolean && !locked.value);
  }

  @override
  Future<String> unlock(String collection) async {
    final reply = await _service.callMethod(
      'org.freedesktop.Secret.Service',
      'Unlock',
      [
        DBusArray.objectPath([DBusObjectPath(collection)]),
      ],
      replySignature: DBusSignature('aoo'),
    );
    return (reply.returnValues[1] as DBusObjectPath).value;
  }

  @override
  Future<bool> runPrompt(String prompt) async {
    final obj = DBusRemoteObject(_c, name: _name, path: DBusObjectPath(prompt));
    final done = DBusRemoteObjectSignalStream(
      object: obj,
      interface: 'org.freedesktop.Secret.Prompt',
      name: 'Completed',
      signature: DBusSignature('bv'),
    ).first;
    await obj.callMethod('org.freedesktop.Secret.Prompt', 'Prompt', [
      DBusString(''),
    ], replySignature: DBusSignature(''));
    final signal = await done;
    return !(signal.values[0] as DBusBoolean).value;
  }

  @override
  Future<void> close() async {
    if (!_owned) return;
    try {
      await _c.close().timeout(const Duration(seconds: 1));
    } catch (_) {}
  }
}

/// Whether a Secret Service is reachable on the session bus and what state its
/// default collection is in. Bounded by [timeout]; any error -> unavailable.
///
/// flutter_secure_storage's Linux plugin calls libsecret synchronously on the
/// GTK main thread. A service that owns the name but never answers (hung
/// daemon) or a locked keyring waiting for a prompt blocks that thread for the
/// D-Bus timeout (25 s) per libsecret step, freezing every platform-channel
/// call, and a Dart-side `Future.timeout` cannot help. Probing over Dart's own
/// D-Bus connection costs nothing on the GTK thread.
Future<SecretServiceState> secretServiceState({
  SecretServiceBus? bus,
  Duration timeout = const Duration(seconds: 3),
}) async {
  SecretServiceBus? b = bus;
  try {
    b ??= DBusSecretServiceBus();
    return await () async {
      final path = await b!.defaultCollection();
      if (path == '/') return SecretServiceState.unavailable;
      return await b.isLocked(path)
          ? SecretServiceState.locked
          : SecretServiceState.unlocked;
    }().timeout(timeout);
  } catch (_) {
    return SecretServiceState.unavailable;
  } finally {
    if (bus == null) await b?.close();
  }
}

/// Asks the Secret Service (over Dart's D-Bus connection, never libsecret) to
/// unlock the default collection; the desktop shows its normal unlock dialog.
/// True when the collection ends up unlocked within [timeout].
Future<bool> unlockSecretService({
  SecretServiceBus? bus,
  Duration timeout = const Duration(seconds: 120),
}) async {
  SecretServiceBus? b = bus;
  try {
    b ??= DBusSecretServiceBus();
    return await () async {
      final path = await b!.defaultCollection();
      if (path == '/') return false;
      final prompt = await b.unlock(path);
      if (prompt != '/' && !await b.runPrompt(prompt)) return false;
      return !await b.isLocked(path);
    }().timeout(timeout);
  } catch (_) {
    return false;
  } finally {
    if (bus == null) await b?.close();
  }
}

/// Which backend a Linux session ended up on.
enum LinuxSecretsStatus {
  /// Secrets live in the Secret Service keyring.
  keyring,

  /// This install uses the encrypted file store (chosen on first run).
  file,

  /// This install uses the keyring but it could not be unlocked / reached this
  /// session: the file store is used for now and nothing was changed on disk.
  keyringLockedFallback,
}

/// OS keystore first; falls back to [EncryptedFileSecretsStore] when the
/// keystore throws (e.g. unsigned macOS builds without keychain entitlement).
///
/// On Linux the backend is chosen once per install and remembered in a marker
/// file (`keyring` / `file`, see [markerPath]); libsecret is only ever called
/// once the Secret Service is known to be unlocked (see [secretServiceState]).
/// If the marker says `keyring` but the keyring is locked, the user is asked to
/// unlock it ([unlockSecretService]); failing that, this session uses the file
/// store ([linuxStatus] == keyringLockedFallback) and the marker is untouched.
/// On a later start with the keyring available, keys that only exist in the
/// file store are moved into the keyring (the keyring's value wins).
class KeystoreSecretsStore implements SecretsStore {
  KeystoreSecretsStore(
    this._fallback, {
    FlutterSecureStorage? storage,
    Duration? keystoreTimeout,
    bool? isLinux,
    Future<SecretServiceState> Function()? probe,
    Future<bool> Function()? unlock,
    String? markerPath,
    Future<String?> Function()? readMarker,
    Future<void> Function(String)? writeMarker,
    Duration probeTimeout = const Duration(seconds: 5),
    Duration unlockTimeout = const Duration(seconds: 120),
  }) : _storage = storage ?? const FlutterSecureStorage(),
       _timeout =
           keystoreTimeout ??
           ((isLinux ?? (!kIsWeb && Platform.isLinux))
               ? const Duration(seconds: 8)
               : null),
       _probeTimeout = probeTimeout,
       _unlockTimeout = unlockTimeout,
       _probe =
           probe ??
           ((isLinux ?? (!kIsWeb && Platform.isLinux))
               ? secretServiceState
               : null),
       _unlock = unlock ?? unlockSecretService,
       _readMarker = readMarker ?? (() => _fileRead(markerPath)),
       _writeMarker = writeMarker ?? ((v) => _fileWrite(markerPath, v));

  static Future<String?> _fileRead(String? path) async {
    if (path == null) return null;
    try {
      final f = File(path);
      return await f.exists() ? (await f.readAsString()).trim() : null;
    } catch (_) {
      return null;
    }
  }

  static Future<void> _fileWrite(String? path, String v) async {
    if (path == null) return;
    try {
      final f = File(path);
      await f.parent.create(recursive: true);
      await f.writeAsString(v, flush: true);
    } catch (e) {
      debugPrint('secrets: cannot write backend marker: $e');
    }
  }

  final FlutterSecureStorage _storage;
  final SecretsStore _fallback;
  final Duration? _timeout;
  final Future<SecretServiceState> Function()? _probe;
  final Future<bool> Function() _unlock;
  final Future<String?> Function() _readMarker;
  final Future<void> Function(String) _writeMarker;
  final Duration _probeTimeout;
  final Duration _unlockTimeout;
  Future<void>? _initFuture;
  bool _useFallback = false;
  LinuxSecretsStatus? _status;

  /// Linux only (null elsewhere, and before [init] completes).
  LinuxSecretsStatus? get linuxStatus => _status;

  /// Linux: pick the backend (may wait for the user to unlock the keyring, up
  /// to the unlock timeout) and migrate file-store keys. Idempotent; every
  /// operation awaits it, so calling it early from main() is optional.
  Future<void> init() {
    final probe = _probe;
    if (probe == null) return Future.value();
    return _initFuture ??= _init(probe);
  }

  Future<void> _init(Future<SecretServiceState> Function() probe) async {
    final marker = await _readMarker();
    if (marker == 'file') {
      _useFallback = true;
      _status = LinuxSecretsStatus.file;
      debugPrint('secrets: this install uses the encrypted file store');
      return;
    }
    SecretServiceState state;
    try {
      state = await probe().timeout(_probeTimeout);
    } catch (_) {
      state = SecretServiceState.unavailable;
    }
    if (marker != 'keyring') {
      // First run (or a pre-marker dev install): keyring only if usable now.
      final ok = state == SecretServiceState.unlocked;
      await _writeMarker(ok ? 'keyring' : 'file');
      _useFallback = !ok;
      _status = ok ? LinuxSecretsStatus.keyring : LinuxSecretsStatus.file;
      debugPrint(
        'secrets: first run, backend = ${ok ? 'keyring' : 'file (no usable unlocked Secret Service)'}',
      );
      return;
    }
    if (state == SecretServiceState.locked) {
      debugPrint(
        'secrets: the keyring is locked; waiting up to ${_unlockTimeout.inSeconds}s for the user to unlock it (the window appears afterwards)',
      );
      var ok = false;
      try {
        ok = await _unlock().timeout(_unlockTimeout);
      } catch (_) {}
      state = ok ? SecretServiceState.unlocked : SecretServiceState.locked;
    }
    if (state != SecretServiceState.unlocked) {
      _useFallback = true;
      _status = LinuxSecretsStatus.keyringLockedFallback;
      debugPrint(
        'secrets: keyring ${state == SecretServiceState.locked ? 'still locked' : 'unavailable'}; using the file store for this session only',
      );
      return;
    }
    _status = LinuxSecretsStatus.keyring;
    await _migrate();
  }

  /// Moves keys that exist only in the file store into the keyring; the
  /// keyring value wins when both exist. Failures leave the file entry alone.
  Future<void> _migrate() async {
    try {
      final keys = await _fallback.keys();
      for (final k in keys) {
        final f = _storage.read(key: k);
        final existing = await (_timeout == null ? f : f.timeout(_timeout));
        if (existing == null) {
          final v = await _fallback.read(k);
          if (v == null) continue;
          final w = _storage.write(key: k, value: v);
          await (_timeout == null ? w : w.timeout(_timeout));
        }
        await _fallback.delete(k);
      }
    } catch (e) {
      debugPrint(
        'secrets: migration to the keyring failed ($e); keys stay in the file store',
      );
    }
  }

  Future<T> _try<T>(Future<T> Function() op, Future<T> Function() fb) async {
    await init();
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
  Future<List<String>> keys() async => _fallback.keys();

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
