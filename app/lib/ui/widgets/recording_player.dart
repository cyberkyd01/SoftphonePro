import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import '../../core/format.dart';

/// Minimal play/pause + seek bar for a WAV recording.
class RecordingPlayer extends StatefulWidget {
  const RecordingPlayer({super.key, required this.path});
  final String path;
  @override
  State<RecordingPlayer> createState() => _RecordingPlayerState();
}

class _RecordingPlayerState extends State<RecordingPlayer> {
  AudioPlayer? _p;
  PlayerState _state = PlayerState.stopped;
  Duration _pos = Duration.zero;
  Duration _dur = Duration.zero;
  final _subs = <StreamSubscription<dynamic>>[];
  String? _error;

  Future<void> _ensure() async {
    if (_p != null) return;
    try {
      final p = AudioPlayer();
      _p = p;
      _subs.addAll([
        p.onPlayerStateChanged.listen((s) => mounted ? setState(() => _state = s) : null),
        p.onPositionChanged.listen((d) => mounted ? setState(() => _pos = d) : null),
        p.onDurationChanged.listen((d) => mounted ? setState(() => _dur = d) : null),
      ]);
    } catch (e) {
      _error = '$e';
    }
  }

  Future<void> _toggle() async {
    if (!File(widget.path).existsSync()) {
      setState(() => _error = 'File not found');
      return;
    }
    await _ensure();
    final p = _p;
    if (p == null) return;
    try {
      if (_state == PlayerState.playing) {
        await p.pause();
      } else if (_state == PlayerState.paused) {
        await p.resume();
      } else {
        await p.play(DeviceFileSource(widget.path));
      }
    } catch (e) {
      setState(() => _error = 'Cannot play: $e');
    }
  }

  @override
  void dispose() {
    for (final s in _subs) {
      s.cancel();
    }
    _p?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final playing = _state == PlayerState.playing;
    if (_error != null) {
      return Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error));
    }
    return Row(
      children: [
        IconButton.filledTonal(
          tooltip: playing ? 'Pause recording' : 'Play recording',
          onPressed: _toggle,
          icon: Icon(playing ? Icons.pause_rounded : Icons.play_arrow_rounded),
        ),
        Expanded(
          child: Slider(
            value: _dur.inMilliseconds == 0 ? 0 : (_pos.inMilliseconds / _dur.inMilliseconds).clamp(0.0, 1.0),
            onChanged: (v) => _p?.seek(Duration(milliseconds: (v * _dur.inMilliseconds).round())),
          ),
        ),
        Text(formatDuration(_pos), style: const TextStyle(fontFeatures: [FontFeature.tabularFigures()])),
      ],
    );
  }
}
