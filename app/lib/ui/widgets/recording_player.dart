import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format.dart';
import '../../l10n/l10n.dart';
import '../../recordings/recording_exporter.dart';
import '../../recordings/recording_formats.dart';
import '../../recordings/recording_playback.dart';

/// Play / pause + seek bar for a recording. Formats the platform cannot play
/// (Ogg Opus on iOS, macOS, Windows) show "Open with..." instead.
class RecordingPlayer extends ConsumerStatefulWidget {
  const RecordingPlayer({
    super.key,
    required this.path,
    this.format = 'wav',
    this.knownDuration = Duration.zero,
  });
  final String path;

  /// `wav`, `wavStereo` or `opus`.
  final String format;

  /// Duration from the metadata, shown until the player reports its own.
  final Duration knownDuration;
  @override
  ConsumerState<RecordingPlayer> createState() => _RecordingPlayerState();
}

class _RecordingPlayerState extends ConsumerState<RecordingPlayer> {
  RecordingPlayback? _p;
  bool _playing = false;
  bool _started = false;
  Duration _pos = Duration.zero;
  Duration _dur = Duration.zero;
  double? _drag;
  Duration? _pendingSeek;
  final _subs = <StreamSubscription<dynamic>>[];
  String? _error;

  @override
  void initState() {
    super.initState();
    _dur = widget.knownDuration;
  }

  Future<void> _ensure() async {
    if (_p != null) return;
    try {
      final p = ref.read(recordingPlaybackFactoryProvider)();
      _p = p;
      _subs.addAll([
        p.playing.listen((v) => mounted ? setState(() => _playing = v) : null),
        p.position.listen((d) => mounted ? setState(() => _pos = d) : null),
        p.duration.listen(
          (d) => mounted && d > Duration.zero ? setState(() => _dur = d) : null,
        ),
        p.completed.listen(
          (_) => mounted
              ? setState(() {
                  _playing = false;
                  _started = false;
                  _pos = Duration.zero;
                })
              : null,
        ),
      ]);
    } catch (e) {
      _error = '$e';
    }
  }

  Future<void> _toggle() async {
    if (!File(widget.path).existsSync()) {
      setState(() => _error = context.l10n.recPlayerNotFound);
      return;
    }
    await _ensure();
    final p = _p;
    if (p == null) {
      setState(() {});
      return;
    }
    try {
      if (_playing) {
        await p.pause();
        if (mounted) setState(() => _playing = false);
      } else if (_started) {
        await p.resume();
        if (mounted) setState(() => _playing = true);
      } else {
        _started = true;
        await p.play(widget.path);
        final seek = _pendingSeek;
        _pendingSeek = null;
        if (seek != null) await p.seek(seek);
        if (mounted) setState(() => _playing = true);
      }
    } catch (e) {
      if (mounted) setState(() => _error = context.l10n.recPlayerCannotPlay('$e'));
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
    final t = Theme.of(context);
    final l = context.l10n;
    if (!canPlayInApp(widget.format)) {
      return Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 18,
            color: t.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              l.recPlayerUnsupported,
              key: const Key('player-unsupported'),
              style: t.textTheme.bodySmall,
            ),
          ),
          TextButton.icon(
            key: const Key('player-open-with'),
            onPressed: () =>
                ref.read(recordingExporterProvider).openExternal(widget.path),
            icon: const Icon(Icons.open_in_new_rounded, size: 18),
            label: Text(l.recPlayerOpenWith),
          ),
        ],
      );
    }
    if (_error != null) {
      return Text(
        _error!,
        key: const Key('player-error'),
        style: TextStyle(color: t.colorScheme.error),
      );
    }
    final total = _dur.inMilliseconds;
    final value =
        _drag ??
        (total == 0 ? 0.0 : (_pos.inMilliseconds / total).clamp(0.0, 1.0));
    return Row(
      children: [
        IconButton.filledTonal(
          key: const Key('player-toggle'),
          tooltip: _playing ? l.recPlayerPause : l.recPlayerPlay,
          onPressed: _toggle,
          icon: Icon(_playing ? Icons.pause_rounded : Icons.play_arrow_rounded),
        ),
        Expanded(
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Slider(
              key: const Key('player-seek'),
              value: value,
              onChanged: total == 0 ? null : (v) => setState(() => _drag = v),
              onChangeEnd: (v) async {
                setState(() {
                  _drag = null;
                  _pos = Duration(milliseconds: (v * total).round());
                });
                final to = Duration(milliseconds: (v * total).round());
                if (_started) {
                  await _p?.seek(to);
                } else {
                  _pendingSeek = to;
                }
              },
            ),
          ),
        ),
        Text(
          '${formatDuration(_pos)} / ${formatDuration(_dur)}',
          key: const Key('player-time'),
          textDirection: TextDirection.ltr,
          style: const TextStyle(fontFeatures: [FontFeature.tabularFigures()]),
        ),
      ],
    );
  }
}
