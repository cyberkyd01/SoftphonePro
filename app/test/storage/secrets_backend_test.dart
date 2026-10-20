import 'dart:async';
import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:softphonepro/storage/secrets_store.dart';

class _Storage extends FlutterSecureStorage {
  _Storage();
  int calls = 0;
  final Map<String, String> data = {};
  @override
  Future<String?> read({
    required String key,
    iOptions,
    aOptions,
    lOptions,
    webOptions,
    mOptions,
    wOptions,
  }) async {
    calls++;
    return data[key];
  }

  @override
  Future<void> write({
    required String key,
    required String? value,
    iOptions,
    aOptions,
    lOptions,
    webOptions,
    mOptions,
    wOptions,
  }) async {
    calls++;
    data[key] = value!;
  }

  @override
  Future<void> delete({
    required String key,
    iOptions,
    aOptions,
    lOptions,
    webOptions,
    mOptions,
    wOptions,
  }) async {
    calls++;
    data.remove(key);
  }
}

class _Fixture {
  _Fixture({
    this.marker,
    SecretServiceState state = SecretServiceState.unlocked,
    Future<bool> Function()? unlock,
  }) {
    store = KeystoreSecretsStore(
      file,
      storage: storage,
      isLinux: true,
      probe: () async {
        probes++;
        return state;
      },
      unlock: () async {
        unlocks++;
        return unlock == null ? false : unlock();
      },
      readMarker: () async => marker,
      writeMarker: (v) async => marker = v,
      unlockTimeout: const Duration(milliseconds: 100),
    );
  }
  String? marker;
  int probes = 0;
  int unlocks = 0;
  final storage = _Storage();
  final file = MemorySecretsStore();
  late final KeystoreSecretsStore store;
}

class _FakeBus implements SecretServiceBus {
  _FakeBus({
    this.collection = '/c/default',
    this.locked = true,
    this.prompt = '/p/1',
    this.dismissed = false,
    this.hang = false,
  });
  String collection;
  bool locked;
  String prompt;
  bool dismissed;
  bool hang;
  final calls = <String>[];
  @override
  Future<String> defaultCollection() async {
    calls.add('alias');
    if (hang) await Completer<void>().future;
    return collection;
  }

  @override
  Future<bool> isLocked(String c) async {
    calls.add('locked?');
    return locked;
  }

  @override
  Future<String> unlock(String c) async {
    calls.add('unlock $c');
    if (prompt == '/') locked = false;
    return prompt;
  }

  @override
  Future<bool> runPrompt(String pr) async {
    calls.add('prompt $pr');
    if (!dismissed) locked = false;
    return !dismissed;
  }

  @override
  Future<void> close() async {}
}

void main() {
  group('Linux backend choice', () {
    test('first run, usable keyring -> marker keyring, keyring used', () async {
      final f = _Fixture();
      await f.store.write('k', 'v');
      expect(f.marker, 'keyring');
      expect(f.store.linuxStatus, LinuxSecretsStatus.keyring);
      expect(f.storage.data, {'k': 'v'});
      expect(f.file.data, isEmpty);
    });

    test(
      'first run, unusable keyring (locked or missing) -> marker file, libsecret never called',
      () async {
        for (final st in [
          SecretServiceState.locked,
          SecretServiceState.unavailable,
        ]) {
          final f = _Fixture(state: st);
          await f.store.write('k', 'v');
          expect(await f.store.read('k'), 'v');
          await f.store.delete('k');
          expect(f.marker, 'file');
          expect(f.store.linuxStatus, LinuxSecretsStatus.file);
          expect(f.storage.calls, 0);
          expect(f.unlocks, 0);
        }
      },
    );

    test('marker file -> never probes or touches libsecret', () async {
      final f = _Fixture(marker: 'file');
      await f.store.write('k', 'v');
      expect(await f.store.read('k'), 'v');
      expect(f.probes, 0);
      expect(f.storage.calls, 0);
      expect(f.store.linuxStatus, LinuxSecretsStatus.file);
      expect(f.file.data, {'k': 'v'});
    });

    test('marker keyring + locked + unlock succeeds -> keyring used', () async {
      final f = _Fixture(
        marker: 'keyring',
        state: SecretServiceState.locked,
        unlock: () async => true,
      );
      await f.store.write('k', 'v');
      expect(f.unlocks, 1);
      expect(f.store.linuxStatus, LinuxSecretsStatus.keyring);
      expect(f.storage.data, {'k': 'v'});
    });

    test(
      'unlock dismissed or timed out -> session fallback, marker unchanged, writes go to the file',
      () async {
        for (final unlock in <Future<bool> Function()>[
          () async => false,
          () => Completer<bool>().future,
        ]) {
          final f = _Fixture(
            marker: 'keyring',
            state: SecretServiceState.locked,
            unlock: unlock,
          );
          await f.store.write('k', 'v');
          expect(await f.store.read('k'), 'v');
          expect(f.store.linuxStatus, LinuxSecretsStatus.keyringLockedFallback);
          expect(f.marker, 'keyring');
          expect(f.storage.calls, 0);
          expect(f.file.data, {'k': 'v'});
        }
      },
    );

    test(
      'marker keyring + service missing -> session fallback with status',
      () async {
        final f = _Fixture(
          marker: 'keyring',
          state: SecretServiceState.unavailable,
        );
        expect(await f.store.read('k'), isNull);
        await f.store.write('k', 'v');
        expect(f.store.linuxStatus, LinuxSecretsStatus.keyringLockedFallback);
        expect(f.marker, 'keyring');
        expect(f.unlocks, 0);
        expect(f.storage.calls, 0);
        expect(f.file.data, {'k': 'v'});
      },
    );

    test(
      'a later start with the keyring migrates file keys (keyring wins) and deletes them from the file',
      () async {
        final f = _Fixture(marker: 'keyring');
        f.file.data.addAll({'only_file': 'a', 'both': 'old'});
        f.storage.data.addAll({'both': 'new', 'only_keyring': 'z'});
        expect(await f.store.read('only_file'), 'a');
        expect(f.storage.data, {
          'only_file': 'a',
          'both': 'new',
          'only_keyring': 'z',
        });
        expect(f.file.data, isEmpty);
      },
    );

    test('no migration when the marker is file', () async {
      final f = _Fixture(marker: 'file');
      f.file.data['k'] = 'v';
      await f.store.read('k');
      expect(f.file.data, {'k': 'v'});
      expect(f.storage.calls, 0);
    });

    test('init() is idempotent and does not repeat the unlock', () async {
      final f = _Fixture(
        marker: 'keyring',
        state: SecretServiceState.locked,
        unlock: () async => true,
      );
      await Future.wait([f.store.init(), f.store.init(), f.store.read('x')]);
      expect(f.unlocks, 1);
      expect(f.probes, 1);
    });

    test('the file marker round-trips on disk', () async {
      final dir = Directory.systemTemp.createTempSync('marker');
      addTearDown(() => dir.deleteSync(recursive: true));
      final path = p.join(dir.path, 'secrets', 'backend');
      final s = KeystoreSecretsStore(
        MemorySecretsStore(),
        storage: _Storage(),
        isLinux: true,
        probe: () async => SecretServiceState.unlocked,
        markerPath: path,
      );
      await s.init();
      expect(File(path).readAsStringSync(), 'keyring');
    });

    test('non-Linux: no probing, no status', () async {
      final s = KeystoreSecretsStore(
        MemorySecretsStore(),
        storage: _Storage(),
        isLinux: false,
      );
      await s.write('k', 'v');
      expect(s.linuxStatus, isNull);
    });
  });

  group('Secret Service D-Bus logic (fake bus)', () {
    test('state: unlocked / locked / no default collection / hang', () async {
      expect(
        await secretServiceState(bus: _FakeBus(locked: false)),
        SecretServiceState.unlocked,
      );
      expect(
        await secretServiceState(bus: _FakeBus()),
        SecretServiceState.locked,
      );
      expect(
        await secretServiceState(bus: _FakeBus(collection: '/')),
        SecretServiceState.unavailable,
      );
      expect(
        await secretServiceState(
          bus: _FakeBus(hang: true),
          timeout: const Duration(milliseconds: 50),
        ),
        SecretServiceState.unavailable,
      );
    });

    test(
      'unlock via prompt: Unlock then Prompt, then re-checks the lock',
      () async {
        final bus = _FakeBus();
        expect(await unlockSecretService(bus: bus), isTrue);
        expect(bus.calls, [
          'alias',
          'unlock /c/default',
          'prompt /p/1',
          'locked?',
        ]);
      },
    );

    test('unlock without prompt ("/") needs no Prompt call', () async {
      final bus = _FakeBus(prompt: '/');
      expect(await unlockSecretService(bus: bus), isTrue);
      expect(bus.calls.any((c) => c.startsWith('prompt')), isFalse);
    });

    test('dismissed prompt, no default collection, hang -> false', () async {
      expect(
        await unlockSecretService(bus: _FakeBus(dismissed: true)),
        isFalse,
      );
      expect(
        await unlockSecretService(bus: _FakeBus(collection: '/')),
        isFalse,
      );
      expect(
        await unlockSecretService(
          bus: _FakeBus(hang: true),
          timeout: const Duration(milliseconds: 50),
        ),
        isFalse,
      );
    });
  });
}
