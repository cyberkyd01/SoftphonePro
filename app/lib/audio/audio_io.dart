import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Picks a WAV / MP3 from disk (null = cancelled). Overridden in tests.
final audioFilePickerProvider = Provider<Future<String?> Function()>(
  (ref) => () async {
    final r = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['wav', 'mp3'],
    );
    return r?.files.single.path;
  },
);

/// Local preview player for the audio library (one file at a time).
abstract class AudioPreview {
  /// Path currently playing (null when stopped).
  ValueListenable<String?> get playing;
  Future<void> play(String path);
  Future<void> stop();
  void dispose();
}

class AudioplayersPreview implements AudioPreview {
  AudioPlayer? _p;
  StreamSubscription<void>? _sub;
  final ValueNotifier<String?> _playing = ValueNotifier(null);

  @override
  ValueListenable<String?> get playing => _playing;

  @override
  Future<void> play(String path) async {
    try {
      final p = _p ??= AudioPlayer();
      _sub ??= p.onPlayerComplete.listen((_) => _playing.value = null);
      await p.stop();
      _playing.value = path;
      await p.play(DeviceFileSource(path));
    } catch (_) {
      _playing.value = null;
    }
  }

  @override
  Future<void> stop() async {
    _playing.value = null;
    try {
      await _p?.stop();
    } catch (_) {}
  }

  @override
  void dispose() {
    _sub?.cancel();
    _p?.dispose();
    _playing.dispose();
  }
}

final audioPreviewProvider = Provider<AudioPreview>((ref) {
  final p = AudioplayersPreview();
  ref.onDispose(p.dispose);
  return p;
});
