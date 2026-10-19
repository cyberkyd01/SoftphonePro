import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast_io.dart';
import 'package:sembast/sembast_memory.dart';

/// Thin owner of the sembast [Database].
class AppDatabase {
  AppDatabase(this.db, {this.directory});
  final Database db;

  /// Directory of the database file (null for in-memory).
  final String? directory;

  static Future<AppDatabase> openDefault() async {
    final dir = await getApplicationSupportDirectory();
    await Directory(dir.path).create(recursive: true);
    final db = await databaseFactoryIo.openDatabase(
      p.join(dir.path, 'softphonepro.db'),
    );
    return AppDatabase(db, directory: dir.path);
  }

  static Future<AppDatabase> memory([String name = 'test']) async {
    final db = await databaseFactoryMemory.openDatabase(
      '$name-${DateTime.now().microsecondsSinceEpoch}',
    );
    return AppDatabase(db);
  }

  Future<void> close() => db.close();
}
