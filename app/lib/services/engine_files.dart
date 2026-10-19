import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Files the engine reads / writes in the app support directory.
class EngineFiles {
  const EngineFiles({this.caFile, this.logFile});

  /// Mozilla CA bundle copied from the app assets (null if unavailable).
  final String? caFile;

  /// `logs/engine.log` (rotated at [kEngineLogMaxBytes], [kEngineLogKeep] kept).
  final String? logFile;

  static const none = EngineFiles();
}

const String kCaBundleAsset = 'assets/certs/cacert.pem';
const int kEngineLogMaxBytes = 5 * 1024 * 1024;
const int kEngineLogKeep = 3;

typedef EngineFilesLoader = Future<EngineFiles> Function();

/// Copies the bundled CA list to the support dir (only when it changed) and
/// rotates the engine log. Never throws: a missing file just means the engine
/// uses its platform defaults.
Future<EngineFiles> prepareEngineFiles({
  Directory? supportDir,
  AssetBundle? bundle,
  int maxLogBytes = kEngineLogMaxBytes,
}) async {
  Directory dir;
  try {
    dir = supportDir ?? await getApplicationSupportDirectory();
  } catch (_) {
    return EngineFiles.none;
  }
  String? ca;
  try {
    final data = await (bundle ?? rootBundle).load(kCaBundleAsset);
    final bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    final f = File(p.join(dir.path, 'certs', 'cacert.pem'));
    var same = false;
    if (f.existsSync() && f.lengthSync() == bytes.length) {
      same = _bytesEqual(await f.readAsBytes(), bytes);
    }
    if (!same) {
      await f.parent.create(recursive: true);
      await f.writeAsBytes(bytes, flush: true);
    }
    ca = f.path;
  } catch (_) {}
  String? log;
  try {
    final f = File(p.join(dir.path, 'logs', 'engine.log'));
    await f.parent.create(recursive: true);
    await rotateLog(f, maxBytes: maxLogBytes);
    log = f.path;
  } catch (_) {}
  return EngineFiles(caFile: ca, logFile: log);
}

bool _bytesEqual(List<int> a, List<int> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

/// engine.log -> engine.log.1 -> .2 -> .3 (oldest dropped) when over [maxBytes].
Future<void> rotateLog(File f, {int maxBytes = kEngineLogMaxBytes, int keep = kEngineLogKeep}) async {
  if (!f.existsSync() || f.lengthSync() < maxBytes) return;
  final oldest = File('${f.path}.$keep');
  if (oldest.existsSync()) await oldest.delete();
  for (var i = keep - 1; i >= 1; i--) {
    final src = File('${f.path}.$i');
    if (src.existsSync()) await src.rename('${f.path}.${i + 1}');
  }
  await f.rename('${f.path}.1');
}
