import 'dart:io';

import 'package:sembast/utils/database_utils.dart';
import 'package:sembast/sembast_io.dart';


/// Thrown by [migrateDatabaseFile] when the copy could not be verified. The
/// original file is untouched.
class DbMigrationException implements Exception {
  DbMigrationException(this.message);
  final String message;
  @override
  String toString() => 'DbMigrationException: $message';
}

/// True when the file's header line carries a codec signature.
Future<bool> isEncryptedDbFile(String path) async {
  final f = File(path);
  if (!await f.exists()) return false;
  try {
    final raf = await f.open();
    try {
      final bytes = await raf.read(4096);
      final first = String.fromCharCodes(bytes).split('\n').first;
      return first.contains('"codec"');
    } finally {
      await raf.close();
    }
  } catch (_) {
    return false;
  }
}

Future<Map<String, int>> _counts(Database db) async {
  final out = <String, int>{};
  for (final name in getNonEmptyStoreNames(db)) {
    out[name] = await StoreRef<Object?, Object?>(name).count(db);
  }
  return out;
}

/// Copies every record of the open database [source] into a fresh database
/// at `<path>.new` using [toCodec] (null = plain), verifies the record counts
/// by reopening the copy, then swaps it in. The previous file is kept as
/// `<path>.bak-<timestamp>` and its path returned. On any failure the
/// original stays in place, the temp file is removed and an exception is
/// thrown.
Future<String> migrateDatabaseFile({
  required Database source,
  required String path,
  required SembastCodec? toCodec,
  bool failAfterCopy = false, // test hook
}) async {
  final tmp = '$path.new';
  await _delete(tmp);
  try {
    final want = await _counts(source);
    final dest = await databaseFactoryIo.openDatabase(tmp, codec: toCodec);
    try {
      for (final name in want.keys) {
        final store = StoreRef<Object?, Object?>(name);
        final recs = await store.find(source);
        await dest.transaction((txn) async {
          for (final r in recs) {
            await store.record(r.key).put(txn, r.value);
          }
        });
      }
    } finally {
      await dest.close();
    }
    if (failAfterCopy) throw DbMigrationException('simulated failure');
    final check = await databaseFactoryIo.openDatabase(tmp, codec: toCodec);
    try {
      final got = await _counts(check);
      for (final e in want.entries) {
        if ((got[e.key] ?? 0) != e.value) {
          throw DbMigrationException(
            'record count mismatch in "${e.key}": ${e.value} vs ${got[e.key] ?? 0}',
          );
        }
      }
    } finally {
      await check.close();
    }
  } catch (e) {
    await _delete(tmp);
    if (e is DbMigrationException) rethrow;
    throw DbMigrationException('$e');
  }
  // Swap: the original is only closed by the caller; rename needs it closed
  // on Windows, so the caller closes [source] before calling [swapInMigrated].
  return tmp;
}

/// Moves the verified copy [tmp] over [path], keeping the old file as
/// `<path>.bak-<timestamp>` (returned). Rolls back if the second rename fails.
Future<String> swapInMigrated(String path, String tmp, {DateTime? now}) async {
  final stamp = (now ?? DateTime.now()).millisecondsSinceEpoch;
  final bak = '$path.bak-$stamp';
  await File(path).rename(bak);
  try {
    await File(tmp).rename(path);
  } catch (e) {
    await File(bak).rename(path); // roll back
    await _delete(tmp);
    throw DbMigrationException('swap failed: $e');
  }
  return bak;
}

Future<void> _delete(String path) async {
  try {
    final f = File(path);
    if (await f.exists()) await f.delete();
  } catch (_) {}
}

/// Backup files next to [path].
Future<List<File>> backupFiles(String path) async {
  final dir = File(path).parent;
  final base = File(path).uri.pathSegments.last;
  if (!await dir.exists()) return [];
  return [
    await for (final e in dir.list())
      if (e is File && e.uri.pathSegments.last.startsWith('$base.bak-')) e,
  ];
}
