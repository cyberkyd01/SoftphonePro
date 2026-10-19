import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sembast/sembast_io.dart';
import 'package:softphonepro/storage/app_database.dart';
import 'package:softphonepro/storage/db_crypto.dart';
import 'package:softphonepro/storage/db_migration.dart';
import 'package:softphonepro/storage/secrets_store.dart';

Future<void> seed(AppDatabase db, {int n = 5}) async {
  final h = StoreRef<String, Map<String, Object?>>('history');
  final c = StoreRef<String, Map<String, Object?>>('contacts');
  for (var i = 0; i < n; i++) {
    await h.record('h$i').put(db.db, {'number': '+1555000$i', 'name': 'Zebra$i'});
  }
  await c.record('c1').put(db.db, {'name': 'Alice Secretname'});
}

Future<int> count(AppDatabase db, String store) =>
    StoreRef<String, Map<String, Object?>>(store).count(db.db);

void main() {
  late Directory dir;
  late MemorySecretsStore secrets;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('encdb');
    secrets = MemorySecretsStore();
  });
  tearDown(() async {
    try {
      await dir.delete(recursive: true);
    } catch (_) {}
  });

  String dbPath() => p.join(dir.path, AppDatabase.fileName);

  test('codec round trip, unique nonces, tamper detection', () {
    final key = generateDbKey();
    final c = AesGcmJsonCodec.fromBase64(key);
    final v = {'a': 1, 'b': [1, 2, 'x'], 'n': null};
    final e1 = c.encoder.convert(v);
    final e2 = c.encoder.convert(v);
    expect(e1, isNot(e2));
    expect(e1, isNot(contains('"a"')));
    expect(c.decoder.convert(e1), v);
    final bytes = e1.codeUnits.toList();
    final tampered = String.fromCharCodes(bytes..[20] = bytes[20] == 65 ? 66 : 65);
    expect(() => c.decoder.convert(tampered), throwsA(isA<DbCryptoException>()));
    final other = AesGcmJsonCodec.fromBase64(generateDbKey());
    expect(() => other.decoder.convert(e1), throwsA(isA<DbCryptoException>()));
  });

  test('wrong key fails cleanly when opening', () async {
    final path = dbPath();
    final good = await databaseFactoryIo.openDatabase(path, codec: sembastCodecForKey(generateDbKey()));
    await StoreRef<String, Map<String, Object?>>('x').record('a').put(good, {'v': 1});
    await good.close();
    expect(await isEncryptedDbFile(path), isTrue);
    await expectLater(
      databaseFactoryIo.openDatabase(path, codec: sembastCodecForKey(generateDbKey())),
      throwsA(anything),
    );
  });

  test('migrates plain -> encrypted -> plain keeping all records', () async {
    var db = await AppDatabase.openIn(dir.path, secrets);
    expect(db.encrypted, isFalse);
    await seed(db);
    await db.close();

    await AppDatabase.requestMode(dir.path, encrypt: true);
    db = await AppDatabase.openIn(dir.path, secrets);
    expect(db.startupNotice, isNull);
    expect(db.encrypted, isTrue);
    expect(await count(db, 'history'), 5);
    expect(await count(db, 'contacts'), 1);
    await db.close();
    final raw = await File(dbPath()).readAsString();
    expect(raw, isNot(contains('Zebra')));
    expect(raw, isNot(contains('Secretname')));
    expect(await secrets.read(AppDatabase.keySecret), isNotNull);
    // The plaintext backup is shredded right after the verified first reopen.
    expect(await backupFiles(dbPath()), isEmpty);

    // Next successful start removes the backup.
    db = await AppDatabase.openIn(dir.path, secrets);
    expect(db.encrypted, isTrue);
    expect(await backupFiles(dbPath()), isEmpty);
    await db.close();

    await AppDatabase.requestMode(dir.path, encrypt: false);
    db = await AppDatabase.openIn(dir.path, secrets);
    expect(db.encrypted, isFalse);
    expect(await count(db, 'history'), 5);
    expect(await count(db, 'contacts'), 1);
    await db.close();
    expect(await File(dbPath()).readAsString(), contains('Zebra'));
    db = await AppDatabase.openIn(dir.path, secrets);
    expect(await secrets.read(AppDatabase.keySecret), isNull);
    await db.close();
  });

  test('failure after copy rolls back and leaves the original untouched', () async {
    final db = await AppDatabase.openIn(dir.path, secrets);
    await seed(db);
    await expectLater(
      migrateDatabaseFile(
        source: db.db,
        path: dbPath(),
        toCodec: sembastCodecForKey(generateDbKey()),
        failAfterCopy: true,
      ),
      throwsA(isA<DbMigrationException>()),
    );
    expect(File('${dbPath()}.new').existsSync(), isFalse);
    expect(await count(db, 'history'), 5);
    expect(await isEncryptedDbFile(dbPath()), isFalse);
    await db.close();
  });

  test('swap rollback restores the original when the final rename fails', () async {
    await File(dbPath()).writeAsString('original');
    await expectLater(swapInMigrated(dbPath(), p.join(dir.path, 'missing.new')), throwsA(isA<DbMigrationException>()));
    expect(await File(dbPath()).readAsString(), 'original');
  });

  test('missing key at startup asks for recovery; start fresh works', () async {
    var db = await AppDatabase.openIn(dir.path, secrets);
    await seed(db);
    await db.close();
    await AppDatabase.requestMode(dir.path, encrypt: true);
    await (await AppDatabase.openIn(dir.path, secrets)).close();

    await secrets.delete(AppDatabase.keySecret); // keystore wiped
    await expectLater(
      AppDatabase.openIn(dir.path, secrets),
      throwsA(isA<DbRecoveryNeeded>().having((e) => e.problem, 'problem', DbProblem.missingKey)),
    );

    // Wrong key is "unreadable", not a crash.
    await secrets.write(AppDatabase.keySecret, generateDbKey());
    await expectLater(
      AppDatabase.openIn(dir.path, secrets),
      throwsA(isA<DbRecoveryNeeded>().having((e) => e.problem, 'problem', DbProblem.unreadable)),
    );

    await AppDatabase.startFresh(dir.path, secrets);
    db = await AppDatabase.openIn(dir.path, secrets);
    expect(db.encrypted, isFalse);
    expect(await count(db, 'history'), 0);
    await db.close();
    expect(dir.listSync().any((e) => e.path.contains('.unreadable-')), isTrue);
  });
}
