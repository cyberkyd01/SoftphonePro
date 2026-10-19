import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/providers.dart';

/// Saves bytes through a platform save dialog; returns the saved path/name,
/// or null when cancelled. Override in tests.
typedef SaveBytes = Future<String?> Function(String fileName, Uint8List bytes);

Future<String?> defaultSaveBytes(String fileName, Uint8List bytes) async {
  final isDesktop = !kIsWeb && (Platform.isMacOS || Platform.isWindows || Platform.isLinux);
  final path = await FilePicker.platform.saveFile(
    dialogTitle: 'Save $fileName',
    fileName: fileName,
    bytes: isDesktop ? null : bytes,
  );
  if (path == null) return null;
  if (isDesktop) await File(path).writeAsBytes(bytes);
  return path;
}

final diagnosticsSaveProvider = Provider<SaveBytes>((ref) => defaultSaveBytes);

String stamp([DateTime? t]) {
  final d = t ?? DateTime.now();
  String p(int n) => n.toString().padLeft(2, '0');
  return '${d.year}${p(d.month)}${p(d.day)}-${p(d.hour)}${p(d.minute)}${p(d.second)}';
}

/// Save/copy helpers that report through the app notice bar.
class DiagnosticsExporter {
  DiagnosticsExporter(this.ref);
  final Ref ref;

  Future<void> saveText(String fileName, String text) => saveBytes(fileName, Uint8List.fromList(utf8.encode(text)));

  Future<void> saveBytes(String fileName, Uint8List bytes) async {
    try {
      final p = await ref.read(diagnosticsSaveProvider)(fileName, bytes);
      if (p != null) ref.read(noticeProvider.notifier).show('Saved $fileName');
    } catch (e) {
      ref.read(noticeProvider.notifier).error('Could not save the file', details: '$e');
    }
  }

  Future<void> copy(String text, {String what = 'Text'}) async {
    await Clipboard.setData(ClipboardData(text: text));
    ref.read(noticeProvider.notifier).show('$what copied to the clipboard');
  }
}

final diagnosticsExporterProvider = Provider<DiagnosticsExporter>((ref) => DiagnosticsExporter(ref));
