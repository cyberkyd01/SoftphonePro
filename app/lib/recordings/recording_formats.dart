import 'package:flutter/foundation.dart';
import 'package:spcore_dart/spcore_dart.dart' show RecordFormat;

import '../l10n/l10n.dart';

/// Settings label of a recording format.
String recordFormatLabel(AppLocalizations l, RecordFormat f) => switch (f) {
  RecordFormat.wav => l.recFormatWav,
  RecordFormat.wavStereo => l.recFormatWavStereo,
  RecordFormat.opus => l.recFormatOpus,
};

/// Short subtitle under the format choice.
String recordFormatHint(AppLocalizations l, RecordFormat f) => switch (f) {
  RecordFormat.wav => l.recFormatWavHint,
  RecordFormat.wavStereo => l.recFormatWavStereoHint,
  RecordFormat.opus => l.recFormatOpusHint,
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
