import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:spcore_dart/spcore_dart.dart';

import '../../../core/theme.dart';
import '../../../services/engine_controller.dart';
import '../../widgets/settings_tiles.dart';

/// Mic meter, echo test, speaker tone.
class AudioTestView extends ConsumerStatefulWidget {
  const AudioTestView({super.key});
  @override
  ConsumerState<AudioTestView> createState() => _AudioTestViewState();
}

class _AudioTestViewState extends ConsumerState<AudioTestView> {
  Timer? _poll;
  bool _meter = false;
  bool _echo = false;
  String? _tone;
  int _mic = 0;
  int _spk = 0;
  String? _error;
  EngineController? _ctl;

  @override
  void initState() {
    super.initState();
    _ctl = ref.read(engineProvider.notifier);
  }

  @override
  void dispose() {
    _poll?.cancel();
    final c = _ctl;
    if (c != null && c.hasEngine) {
      if (_echo) c.engine.loopback(false).catchError((_) {});
      if (_tone != null) c.engine.stopTone().catchError((_) {});
    }
    super.dispose();
  }

  SipEngine? get _engine => (_ctl?.hasEngine ?? false) ? _ctl!.engine : null;

  Future<void> _guard<T>(Future<T> Function(SipEngine e) f) async {
    final e = _engine;
    if (e == null) {
      setState(() => _error = 'The SIP engine is not running.');
      return;
    }
    try {
      await f(e);
      if (mounted) setState(() => _error = null);
    } on EngineException catch (x) {
      if (mounted) setState(() => _error = x.error.message);
    } catch (x) {
      if (mounted) setState(() => _error = '$x');
    }
  }

  void _startMeter() {
    _poll?.cancel();
    _poll = Timer.periodic(const Duration(milliseconds: 120), (_) async {
      final e = _engine;
      if (e == null) return;
      try {
        final l = await e.levels();
        if (mounted) {
          setState(() {
            _mic = l.mic;
            _spk = l.speaker;
          });
        }
      } catch (_) {}
    });
  }

  void _stopMeter() {
    _poll?.cancel();
    _poll = null;
    setState(() {
      _mic = 0;
      _spk = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.only(bottom: 32),
      children: [
        if (_error != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Text(_error!, style: TextStyle(color: t.colorScheme.error)),
          ),
        SettingsGroup(
          title: 'Microphone',
          footer: 'The level meter reads the audio device, which the engine opens during a call or the echo test.',
          children: [
            SwitchTile(
              key: const Key('audio-meter'),
              icon: Icons.mic_rounded,
              title: 'Level meter',
              subtitle: 'Speak and watch the bar move',
              value: _meter,
              onChanged: (v) {
                setState(() => _meter = v);
                v ? _startMeter() : _stopMeter();
              },
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 14),
              child: Column(
                children: [
                  _LevelBar(key: const Key('mic-bar'), label: 'Mic', value: _mic / 255),
                  const SizedBox(height: 8),
                  _LevelBar(key: const Key('spk-bar'), label: 'Speaker', value: _spk / 255),
                ],
              ),
            ),
          ],
        ),
        SettingsGroup(
          title: 'Echo test',
          footer: 'Plays your voice back through the speaker. Use headphones to avoid feedback.',
          children: [
            SwitchTile(
              key: const Key('audio-echo'),
              icon: Icons.hearing_rounded,
              title: 'Echo test',
              subtitle: _echo ? 'Active: speak now' : 'Mic to speaker loopback',
              value: _echo,
              onChanged: (v) async {
                await _guard<void>((e) => e.loopback(v));
                if (mounted && _error == null) setState(() => _echo = v);
              },
            ),
          ],
        ),
        SettingsGroup(
          title: 'Speaker test',
          children: [
            ListTile(
              leading: const Icon(Icons.volume_up_rounded),
              title: const Text('Play test tone'),
              subtitle: Text(_tone == null ? 'Plays through the selected speaker' : 'Playing $_tone'),
              trailing: Wrap(
                spacing: 8,
                children: [
                  OutlinedButton(
                    key: const Key('tone-dtmf'),
                    onPressed: () async {
                      await _guard((e) => e.playTone(ToneKind.dtmf, digits: '123456789*0#'));
                      if (mounted && _error == null) setState(() => _tone = 'DTMF');
                    },
                    child: const Text('DTMF'),
                  ),
                  OutlinedButton(
                    key: const Key('tone-ringback'),
                    onPressed: () async {
                      await _guard((e) => e.playTone(ToneKind.ringback, loop: true));
                      if (mounted && _error == null) setState(() => _tone = 'ringback');
                    },
                    child: const Text('Ringback'),
                  ),
                  if (_tone != null)
                    IconButton(
                      key: const Key('tone-stop'),
                      tooltip: 'Stop',
                      icon: const Icon(Icons.stop_circle_outlined),
                      onPressed: () async {
                        await _guard((e) => e.stopTone());
                        if (mounted) setState(() => _tone = null);
                      },
                    ),
                ],
              ),
            ),
          ],
        ),
        SettingsGroup(
          title: 'Devices',
          children: [
            NavTile(
              key: const Key('audio-devices'),
              icon: Icons.settings_voice_rounded,
              title: 'Choose microphone and speaker',
              subtitle: 'Opens Settings > Audio',
              onTap: () => context.go('/settings/audio'),
            ),
          ],
        ),
      ],
    );
  }
}

class _LevelBar extends StatelessWidget {
  const _LevelBar({super.key, required this.label, required this.value});
  final String label;
  final double value;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = Theme.of(context);
    final v = value.clamp(0.0, 1.0);
    final color = v > 0.9 ? c.regFail : (v > 0.7 ? c.regWarn : c.regOk);
    return Semantics(
      label: '$label level ${(v * 100).round()} percent',
      child: Row(
        children: [
          SizedBox(width: 64, child: Text(label, style: t.textTheme.labelMedium)),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(value: v, minHeight: 12, color: color, backgroundColor: t.colorScheme.surfaceContainerHighest),
            ),
          ),
        ],
      ),
    );
  }
}
