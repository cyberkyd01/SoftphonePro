import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// The user's documents directory.
///
/// On Linux without the `xdg-user-dirs` package `path_provider` throws
/// `MissingPlatformDirectoryException`; fall back to `$XDG_DOCUMENTS_DIR`,
/// else `$HOME/Documents`, and create it. Other platforms rethrow.
Future<Directory> appDocumentsDir({
  Future<Directory> Function()? provider,
  Map<String, String>? env,
  bool? isLinux,
}) async {
  try {
    return await (provider ?? getApplicationDocumentsDirectory)();
  } catch (_) {
    if (!(isLinux ?? Platform.isLinux)) rethrow;
    final e = env ?? Platform.environment;
    final x = e['XDG_DOCUMENTS_DIR'];
    final home = e['HOME'];
    final String path;
    if (x != null && x.isNotEmpty) {
      path = x;
    } else if (home != null && home.isNotEmpty) {
      path = p.join(home, 'Documents');
    } else {
      rethrow;
    }
    final d = Directory(path);
    await d.create(recursive: true);
    return d;
  }
}
