import 'package:flutter/foundation.dart';
import 'package:spcore_dart/spcore_dart.dart' show RecordFormat;

/// Settings label of a recording format.
String recordFormatLabel(RecordFormat f) => switch (f) {
  RecordFormat.wav => 'Standard (WAV)',
  RecordFormat.wavStereo => 'Stereo, you and the caller on separate channels (WAV)',
  RecordFormat.opus => 'Compressed (Opus)',
};

/// Short subtitle under the format choice.
String recordFormatHint(RecordFormat f) => switch (f) {
  RecordFormat.wav => 'Mono, about 2 MB per minute. Plays everywhere.',
  RecordFormat.wavStereo => 'Two channels, about 4 MB per minute. You on the left, the caller on the right.',
  RecordFormat.opus => 'About 0.2 MB per minute. Ogg Opus; some players on iPhone, Mac and Windows cannot open it.',
};

/// Badge text in the recordings list.
String recordFormatBadge(String wire) => switch (wire) {
  'wavStereo' => 'WAV stereo',
  'opus' => 'Opus',
  _ => 'WAV',
};

/// File extension (without dot) the engine should be given.
String recordFormatExtension(RecordFormat f) => f == RecordFormat.opus ? 'ogg' : 'wav';

RecordFormat recordFormatOf(String wire) => RecordFormat.parse(wire);

/// Whether audioplayers can play [wire] on [platform].
///
/// WAV plays everywhere. Ogg Opus plays on Android (ExoPlayer/MediaPlayer)
/// and Linux (GStreamer); iOS and macOS (AVFoundation) and Windows (Media
/// Foundation) have no Ogg Opus decoder, so the app offers "Open with..."
/// and export instead.
bool canPlayInApp(String wire, [TargetPlatform? platform]) {
  if (wire != 'opus') return true;
  final p = platform ?? defaultTargetPlatform;
  return p == TargetPlatform.android || p == TargetPlatform.linux;
}

/// Human size, e.g. `1.4 MB`.
String formatBytes(int bytes) {
  if (bytes <= 0) return '0 B';
  const units = ['B', 'KB', 'MB', 'GB'];
  var v = bytes.toDouble();
  var i = 0;
  while (v >= 1024 && i < units.length - 1) {
    v /= 1024;
    i++;
  }
  return '${v.toStringAsFixed(i == 0 || v >= 100 ? 0 : 1)} ${units[i]}';
}
