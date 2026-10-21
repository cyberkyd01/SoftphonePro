import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:spcore_dart/spcore_dart.dart';

import '../../../audio/audio_levels.dart';
import '../../../audio/echo_test.dart';
import '../../../l10n/l10n.dart';
import '../../../services/engine_controller.dart';
import '../../widgets/level_meter.dart';
import '../../widgets/settings_tiles.dart';

/// Mic meter, echo test, speaker tone.
class AudioTestView extends ConsumerStatefulWidget {
  const AudioTestView({super.key});
  @override
  ConsumerState<AudioTestView> createState() => _AudioTestViewState();
}

class _AudioTestViewState extends ConsumerState<AudioTestView> {
  bool _meter = false;
  String? _tone;
  String? _error;
  EngineController? _ctl;
  EchoTestController? _echoCtl;

  @override
  void initState() {
    super.initState();
    _ctl = ref.read(engineProvider.notifier);
    _echoCtl = ref.read(echoTestProvider.notifier);
  }

  @override
  void dispose() {
    final c = _ctl;
    if (c != null && c.hasEngine) {
      if (_tone != null) c.engine.stopTone().catchError((_) {});
    }
    _echoCtl?.stopQuiet();
    super.dispose();
  }

  SipEngine? get _engine => (_ctl?.hasEngine ?? false) ? _ctl!.engine : null;

  Future<void> _guard<T>(Future<T> Function(SipEngine e) f) async {
    final e = _engine;
    if (e == null) {
      setState(() => _error = ref.read(l10nProvider).diagAudioEngineNotRunning);
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

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final l = context.l10n;
    final echo = ref.watch(echoTestProvider).on;
    return ListView(
      padding: const EdgeInsets.only(bottom: 32),
      children: [
        if (_error != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Text(_error!, style: TextStyle(color: t.colorScheme.error)),
          ),
        SettingsGroup(
          children: [
            NavTile(
              key: const Key('audio-test-open'),
              icon: Icons.fact_check_rounded,
              title: l.audioTestEntry,
              subtitle: l.audioTestEntrySub,
              onTap: () => context.push('/audio-test'),
            ),
          ],
        ),
        SettingsGroup(
          title: l.diagAudioMicrophone,
          footer: l.diagAudioMicFooter,
          children: [
            SwitchTile(
              key: const Key('audio-meter'),
              icon: Icons.mic_rounded,
              title: l.diagAudioLevelMeter,
              subtitle: l.diagAudioLevelMeterSub,
              value: _meter,
              onChanged: (v) => setState(() => _meter = v),
            ),
            // Polls `media.levels` only while the switch is on.
            if (_meter) const _MeterBars(),
          ],
        ),
        SettingsGroup(
          title: l.diagAudioEchoTest,
          footer: l.diagAudioEchoFooter,
          children: [
            SwitchTile(
              key: const Key('audio-echo'),
              icon: Icons.hearing_rounded,
              title: l.diagAudioEchoTest,
              subtitle: echo ? l.diagAudioEchoActive : l.diagAudioEchoIdle,
              value: echo,
              onChanged: (v) {
                final c = ref.read(echoTestProvider.notifier);
                unawaited(_guard<void>((e) => v ? c.start() : c.stop()));
              },
            ),
          ],
        ),
        SettingsGroup(
          title: l.diagAudioSpeakerTest,
          children: [
            ListTile(
              leading: const Icon(Icons.volume_up_rounded),
              title: Text(l.diagAudioPlayTone),
              subtitle: Text(_tone == null ? l.diagAudioPlayToneSub : (_tone == 'DTMF' ? l.diagAudioPlayingDtmf : l.diagAudioPlayingRingback)),
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
                    child: Text(l.diagAudioRingback),
                  ),
                  if (_tone != null)
                    IconButton(
                      key: const Key('tone-stop'),
                      tooltip: l.diagWizStop,
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
          title: l.diagAudioDevices,
          children: [
            NavTile(
              key: const Key('audio-devices'),
              icon: Icons.settings_voice_rounded,
              title: l.diagAudioChooseDevices,
              subtitle: l.diagAudioChooseDevicesSub,
              onTap: () => context.go('/settings/audio'),
            ),
          ],
        ),
      ],
    );
  }
}

class _MeterBars extends ConsumerStatefulWidget {
  const _MeterBars();
  @override
  ConsumerState<_MeterBars> createState() => _MeterBarsState();
}

/// A running mic test keeps the meters at the fast rate.
class _MeterBarsState extends ConsumerState<_MeterBars> with MeterBoostHolder<_MeterBars> {
  @override
  Widget build(BuildContext context) {
    final meters = ref.watch(audioLevelsProvider);
    final l = context.l10n;
    Widget bar(Key key, String label, MeterChannel c) => Row(
      children: [
        SizedBox(width: 64, child: Text(label, style: Theme.of(context).textTheme.labelMedium)),
        Expanded(
          child: LevelMeter(key: key, channel: c, label: l.mixerMeterLabel(label), height: 12),
        ),
      ],
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 14),
      child: Column(
        children: [
          bar(const Key('mic-bar'), l.diagAudioMic, meters.mic),
          const SizedBox(height: 8),
          bar(const Key('spk-bar'), l.diagAudioSpeaker, meters.speaker),
        ],
      ),
    );
  }
}
