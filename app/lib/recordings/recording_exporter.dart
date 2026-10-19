import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';

import '../models/chat.dart';

/// Getting recordings out of the app: save a copy, share, reveal in the
/// file manager, open with another app. Replaceable in tests.
abstract class RecordingExporter {
  /// Desktop (Save as...) / mobile (system save dialog). Returns the saved
  /// path, or null when cancelled.
  Future<String?> saveAs(RecordingMeta m, {String? suggestedName});

  /// Mobile share sheet (also works on desktop where supported).
  Future<void> share(List<RecordingMeta> items);

  /// Shows the file in Finder / Explorer / the file manager.
  Future<void> reveal(String path);

  /// Opens the file with the system's default app ("Open with...").
  Future<void> openExternal(String path);

  /// Opens a folder in the file manager (desktop).
  Future<void> openFolder(String dir);
}

bool get _isDesktop => !kIsWeb && (Platform.isMacOS || Platform.isWindows || Platform.isLinux);

class PlatformRecordingExporter implements RecordingExporter {
  const PlatformRecordingExporter();

  @override
  Future<String?> saveAs(RecordingMeta m, {String? suggestedName}) async {
    final name = suggestedName ?? p.basename(m.path);
    if (_isDesktop) {
      final dest = await FilePicker.platform.saveFile(dialogTitle: 'Save recording', fileName: name);
      if (dest == null) return null;
      await File(m.path).copy(dest);
      return dest;
    }
    // Android / iOS: the picker writes the bytes itself.
    final bytes = await File(m.path).readAsBytes();
    return FilePicker.platform.saveFile(dialogTitle: 'Save recording', fileName: name, bytes: bytes);
  }

  @override
  Future<void> share(List<RecordingMeta> items) async {
    await SharePlus.instance.share(
      ShareParams(
        files: [for (final m in items) XFile(m.path)],
        subject: items.length == 1 ? p.basename(items.first.path) : 'Call recordings',
      ),
    );
  }

  @override
  Future<void> reveal(String path) async {
    if (Platform.isMacOS) {
      await Process.run('open', ['-R', path]);
    } else if (Platform.isWindows) {
      await Process.run('explorer', ['/select,', path]);
    } else {
      await Process.run('xdg-open', [p.dirname(path)]);
    }
  }

  @override
  Future<void> openExternal(String path) async {
    if (Platform.isMacOS) {
      await Process.run('open', [path]);
    } else if (Platform.isWindows) {
      await Process.run('cmd', ['/c', 'start', '', path]);
    } else if (Platform.isLinux) {
      await Process.run('xdg-open', [path]);
    } else {
      await SharePlus.instance.share(ShareParams(files: [XFile(path)]));
    }
  }

  @override
  Future<void> openFolder(String dir) async {
    if (Platform.isMacOS) {
      await Process.run('open', [dir]);
    } else if (Platform.isWindows) {
      await Process.run('explorer', [dir]);
    } else if (Platform.isLinux) {
      await Process.run('xdg-open', [dir]);
    }
  }
}

final recordingExporterProvider = Provider<RecordingExporter>((ref) => const PlatformRecordingExporter());

/// Desktop platforms get "Save as..." / "Show in folder"; others share.
bool get recordingsUseDesktopExport => _isDesktop;
