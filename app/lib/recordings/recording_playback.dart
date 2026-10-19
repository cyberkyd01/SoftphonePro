import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Minimal player abstraction so the UI can be tested without audio plugins.
abstract class RecordingPlayback {
  Stream<bool> get playing;
  Stream<Duration> get position;
  Stream<Duration> get duration;
  Stream<void> get completed;
  Future<void> play(String path);
  Future<void> pause();
  Future<void> resume();
  Future<void> seek(Duration to);
  Future<void> stop();
  Future<void> dispose();
}

/// [RecordingPlayback] over audioplayers.
class AudioPlayersPlayback implements RecordingPlayback {
  AudioPlayersPlayback() : _p = AudioPlayer();
  final AudioPlayer _p;

  @override
  Stream<bool> get playing => _p.onPlayerStateChanged.map((s) => s == PlayerState.playing);
  @override
  Stream<Duration> get position => _p.onPositionChanged;
  @override
  Stream<Duration> get duration => _p.onDurationChanged;
  @override
  Stream<void> get completed => _p.onPlayerComplete;

  @override
  Future<void> play(String path) => _p.play(DeviceFileSource(path));
  @override
  Future<void> pause() => _p.pause();
  @override
  Future<void> resume() => _p.resume();
  @override
  Future<void> seek(Duration to) => _p.seek(to);
  @override
  Future<void> stop() => _p.stop();
  @override
  Future<void> dispose() => _p.dispose();
}

/// Creates a player per recording view. Override in tests.
final recordingPlaybackFactoryProvider = Provider<RecordingPlayback Function()>((ref) => AudioPlayersPlayback.new);
