import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:softphonepro/services/app_dirs.dart';

void main() {
  Future<Directory> boom() async => throw Exception('MissingPlatformDirectoryException');

  test('Linux falls back to XDG_DOCUMENTS_DIR, then HOME/Documents, and creates it', () async {
    final tmp = Directory.systemTemp.createTempSync('spc_docs');
    addTearDown(() => tmp.deleteSync(recursive: true));
    final x = await appDocumentsDir(provider: boom, isLinux: true, env: {'XDG_DOCUMENTS_DIR': '${tmp.path}/xdg', 'HOME': tmp.path});
    expect(x.path, '${tmp.path}/xdg');
    expect(x.existsSync(), isTrue);
    final h = await appDocumentsDir(provider: boom, isLinux: true, env: {'HOME': tmp.path});
    expect(h.path, '${tmp.path}/Documents');
    expect(h.existsSync(), isTrue);
  });

  test('rethrows off Linux or without any usable path', () async {
    expect(appDocumentsDir(provider: boom, isLinux: false, env: {'HOME': '/x'}), throwsException);
    expect(appDocumentsDir(provider: boom, isLinux: true, env: {}), throwsException);
  });

  test('uses the platform answer when it works', () async {
    final d = Directory.systemTemp;
    expect((await appDocumentsDir(provider: () async => d, isLinux: true, env: {})).path, d.path);
  });
}
