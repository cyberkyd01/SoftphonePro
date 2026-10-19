import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast_io.dart';
import 'package:sembast/sembast_memory.dart';

import 'db_crypto.dart';
import 'db_migration.dart';
import 'secrets_store.dart';

/// Why the database could not be opened.
enum DbProblem { missingKey, unreadable }

/// The database exists but cannot be opened (key missing from the keystore,
/// wrong key, corrupt file). The app shows a recovery screen instead of
/// crashing.
/// A user-visible message about a failed start-up database conversion; the
/// UI turns it into text (see main.dart).
class DbStartupNotice {
  const DbStartupNotice({required this.encrypt, required this.error});

  /// True when switching encryption on failed, false when switching it off.
  final bool encrypt;
  final String error;
}

class DbRecoveryNeeded implements Exception {
  DbRecoveryNeeded(this.problem, this.path, [this.detail]);
  final DbProblem problem;
  final String path;
  final String? detail;
  @override
  String toString() => 'DbRecoveryNeeded($problem, $path, $detail)';
}

/// Thin owner of the sembast [Database].
class AppDatabase {
  AppDatabase(
    this.db, {
    this.directory,
    this.encrypted = false,
    this.startupNotice,
  });
  final Database db;

  /// Directory of the database file (null for in-memory).
  final String? directory;

  /// Whether the open file is AES-256-GCM encrypted.
  final bool encrypted;

  /// Set when a requested encryption change failed at startup and was rolled
  /// back (shown once as an error notice).
  final DbStartupNotice? startupNotice;

  static const fileName = 'softphonepro.db';

  /// Secrets-store entry holding the base64 database key.
  static const keySecret = 'db.key';

  /// A pending change is requested by writing `encrypt` or `plain` here; it
  /// is applied at the next start, before the database is opened by the app.
  static const modeMarker = 'softphonepro.dbmode';

  static Future<AppDatabase> openDefault(SecretsStore secrets) async {
    final dir = await getApplicationSupportDirectory();
    return openIn(dir.path, secrets);
  }

  /// Opens (and if requested migrates) the database in [dir]. Throws
  /// [DbRecoveryNeeded] when the existing file cannot be opened.
  static Future<AppDatabase> openIn(String dir, SecretsStore secrets) async {
    await Directory(dir).create(recursive: true);
    final path = p.join(dir, fileName);
    await _recoverInterruptedSwap(path);
    try {
      final f = File('$path.new');
      if (await f.exists()) await f.delete();
    } catch (_) {}

    final encrypted = await isEncryptedDbFile(path);
    final db = await _open(path, encrypted, secrets);

    // A successful start: backups from an earlier migration are obsolete.
    for (final b in await backupFiles(path)) {
      try {
        await b.delete();
      } catch (_) {}
    }
    if (!encrypted) {
      // No backup can need the key any more.
      try {
        if (await secrets.read(keySecret) != null) await secrets.delete(keySecret);
      } catch (_) {}
    }

    final marker = File(p.join(dir, modeMarker));
    String? want;
    try {
      if (await marker.exists()) want = (await marker.readAsString()).trim();
    } catch (_) {}
    if (want != 'encrypt' && want != 'plain') {
      if (want != null) await _deleteQuiet(marker);
      return AppDatabase(db, directory: dir, encrypted: encrypted);
    }
    await _deleteQuiet(marker);
    if ((want == 'encrypt') == encrypted) {
      return AppDatabase(db, directory: dir, encrypted: encrypted);
    }
    return _applyMigration(
      db: db,
      dir: dir,
      path: path,
      secrets: secrets,
      toEncrypted: want == 'encrypt',
    );
  }

  static Future<AppDatabase> _applyMigration({
    required Database db,
    required String dir,
    required String path,
    required SecretsStore secrets,
    required bool toEncrypted,
  }) async {
    var current = db;
    String? bak;
    try {
      String? key;
      if (toEncrypted) {
        key = await secrets.read(keySecret);
        if (key == null) {
          key = generateDbKey();
          await secrets.write(keySecret, key);
          if (await secrets.read(keySecret) != key) {
            throw DbMigrationException('the key could not be saved to the keystore');
          }
        }
      } else {
        key = await secrets.read(keySecret); // kept until the next start
      }
      final tmp = await migrateDatabaseFile(
        source: current,
        path: path,
        toCodec: toEncrypted ? sembastCodecForKey(key!) : null,
      );
      await current.close();
      bak = await swapInMigrated(path, tmp);
      final reopened = await databaseFactoryIo.openDatabase(
        path,
        codec: toEncrypted ? sembastCodecForKey(key!) : null,
      );
      return AppDatabase(reopened, directory: dir, encrypted: toEncrypted);
    } catch (e) {
      // Roll back: put the original file back if it was moved.
      try {
        await current.close();
      } catch (_) {}
      try {
        if (bak != null) {
          await _deleteQuiet(File(path));
          await File(bak).rename(path);
        }
      } catch (_) {}
      final wasEncrypted = !toEncrypted;
      final Database back;
      try {
        back = await _open(path, wasEncrypted, secrets);
      } on DbRecoveryNeeded {
        rethrow;
      }
      return AppDatabase(
        back,
        directory: dir,
        encrypted: wasEncrypted,
        startupNotice: DbStartupNotice(encrypt: toEncrypted, error: '$e'),
      );
    }
  }

  static Future<Database> _open(String path, bool encrypted, SecretsStore secrets) async {
    SembastCodec? codec;
    if (encrypted) {
      final key = await secrets.read(keySecret);
      if (key == null || key.isEmpty) {
        throw DbRecoveryNeeded(DbProblem.missingKey, path);
      }
      try {
        codec = sembastCodecForKey(key);
      } catch (e) {
        throw DbRecoveryNeeded(DbProblem.unreadable, path, '$e');
      }
    }
    try {
      return await databaseFactoryIo.openDatabase(path, codec: codec);
    } catch (e) {
      throw DbRecoveryNeeded(DbProblem.unreadable, path, '$e');
    }
  }

  /// A crash between the two renames of a swap leaves no main file but a
  /// backup: restore the newest one.
  static Future<void> _recoverInterruptedSwap(String path) async {
    if (await File(path).exists()) return;
    final baks = await backupFiles(path);
    if (baks.isEmpty) return;
    baks.sort((a, b) => a.path.compareTo(b.path));
    await baks.last.rename(path);
  }

  /// Requests an encryption change; applied at the next start.
  static Future<void> requestMode(String dir, {required bool encrypt}) =>
      File(p.join(dir, modeMarker)).writeAsString(encrypt ? 'encrypt' : 'plain', flush: true);

  static Future<void> cancelRequest(String dir) => _deleteQuiet(File(p.join(dir, modeMarker)));

  /// The change waiting for the next start: true = encrypt, false = decrypt.
  static Future<bool?> pendingMode(String dir) async {
    try {
      final f = File(p.join(dir, modeMarker));
      if (!await f.exists()) return null;
      final v = (await f.readAsString()).trim();
      return v == 'encrypt' ? true : (v == 'plain' ? false : null);
    } catch (_) {
      return null;
    }
  }

  /// Recovery "start fresh": the unreadable file is kept next to the data as
  /// `softphonepro.db.unreadable-<timestamp>`, a new plain database is used
  /// and the stale key is removed.
  static Future<void> startFresh(String dir, SecretsStore secrets) async {
    final path = p.join(dir, fileName);
    final f = File(path);
    if (await f.exists()) {
      await f.rename('$path.unreadable-${DateTime.now().millisecondsSinceEpoch}');
    }
    for (final b in await backupFiles(path)) {
      await _deleteQuiet(b);
    }
    await cancelRequest(dir);
    try {
      await secrets.delete(keySecret);
    } catch (_) {}
  }

  static Future<void> _deleteQuiet(File f) async {
    try {
      if (await f.exists()) await f.delete();
    } catch (_) {}
  }

  static Future<AppDatabase> memory([String name = 'test']) async {
    final db = await databaseFactoryMemory.openDatabase(
      '$name-${DateTime.now().microsecondsSinceEpoch}',
    );
    return AppDatabase(db);
  }

  Future<void> close() => db.close();
}
