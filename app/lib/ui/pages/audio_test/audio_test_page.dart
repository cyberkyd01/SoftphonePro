import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spcore_dart/spcore_dart.dart' show MonitorSource;

import '../../../audio/audio_levels.dart';
import '../../../audio/audio_platform.dart';
import '../../../audio/device_labels.dart';
import '../../../audio/echo_test.dart';
import '../../../audio/musicbed.dart';
import '../../../core/theme.dart';
import '../../../l10n/l10n.dart';
import '../../../services/calls_controller.dart';
import '../../../services/engine_controller.dart';
import '../../../services/providers.dart';
import '../../../services/settings_controller.dart';
import '../../../services/update_checker.dart' show urlOpenerProvider;
import '../../widgets/audio_mixer.dart';
import '../../widgets/call_widgets.dart' show audioDevicesProvider;
import '../../widgets/level_meter.dart';
import '../../widgets/settings_tiles.dart';
import 'audio_test_controller.dart';

/// Width from which the steps and the summary sit side by side.
const kAudioTestWide = 840.0;

/// Settings > Audio > Test microphone and speakers: a guided check of the
/// devices, the microphone, the speaker, a recording, the echo test and the
/// background music, with a summary that can be copied for support.
class AudioTestPage extends ConsumerStatefulWidget {
  const AudioTestPage({super.key});
  @override
  ConsumerState<AudioTestPage> createState() => _AudioTestPageState();
}

/// Holds the meter boost: a phone only keeps the microphone open for the
/// meters while a page like this one is showing.
class _AudioTestPageState extends ConsumerState<AudioTestPage> with MeterBoostHolder<AudioTestPage>, WidgetsBindingObserver {
  late final AudioTestController _ctl;

  @override
  void initState() {
    super.initState();
    _ctl = ref.read(audioTestProvider.notifier);
    WidgetsBinding.instance.addObserver(this);
    Future.microtask(() {
      if (mounted) _ctl.start();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _ctl.stopAll(quiet: true);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState s) {
    switch (s) {
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
        _ctl.setForeground(false);
        _ctl.stopAll();
      case AppLifecycleState.resumed:
        _ctl.setForeground(true);
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final st = ref.watch(audioTestProvider);
    final inCall = ref.watch(callsProvider.select((c) => c.live.isNotEmpty));
    final ios = ref.watch(isIosProvider);
    final meters = ref.watch(audioLevelsProvider);

    final banners = <Widget>[
      if (inCall) _Banner(key: const Key('audio-test-in-call'), icon: Icons.phone_in_talk_rounded, text: l.audioTestInCall),
      if (ios) _Banner(key: const Key('audio-test-ios-note'), icon: Icons.info_outline_rounded, text: l.audioTestIosNote),
    ];
    final steps = <Widget>[
      _DevicesStep(st: st, ctl: _ctl),
      _MicStep(st: st, meters: meters, disabled: ios),
      _SpeakerStep(st: st, ctl: _ctl, meters: meters, disabled: inCall || ios),
      _RecordStep(st: st, ctl: _ctl, meters: meters, disabled: inCall || ios),
      _EchoStep(st: st, ctl: _ctl, disabled: inCall || ios),
      _MusicStep(st: st, ctl: _ctl, meters: meters, disabled: inCall || ios),
    ];
    final summary = _SummaryCard(st: st, ctl: _ctl);

    return Scaffold(
      appBar: AppBar(title: Text(l.audioTestTitle)),
      body: LayoutBuilder(
        builder: (context, box) {
          if (box.maxWidth >= kAudioTestWide) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: ListView(padding: const EdgeInsets.only(bottom: 32), children: [...banners, ...steps]),
                ),
                SizedBox(
                  key: const Key('audio-test-summary-side'),
                  width: 320,
                  child: SingleChildScrollView(padding: const EdgeInsets.only(bottom: 32), child: summary),
                ),
              ],
            );
          }
          return ListView(padding: const EdgeInsets.only(bottom: 32), children: [...banners, ...steps, summary]);
        },
      ),
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner({super.key, required this.icon, required this.text});
  final IconData icon;
  final String text;
  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: t.colorScheme.surfaceContainerHigh, borderRadius: BorderRadius.circular(kRadius)),
        child: Row(
          children: [
            Icon(icon, color: t.colorScheme.onSurfaceVariant),
            const SizedBox(width: 12),
            Expanded(child: Text(text)),
          ],
        ),
      ),
    );
  }
}

String _statusLabel(AppLocalizations l, StepStatus s) => switch (s) {
  StepStatus.notRun => l.audioTestNotRun,
  StepStatus.running => l.audioTestRunning,
  StepStatus.pass => l.audioTestPass,
  StepStatus.fail => l.audioTestFail,
  StepStatus.skipped => l.audioTestSkipped,
};

IconData _statusIcon(StepStatus s) => switch (s) {
  StepStatus.notRun => Icons.radio_button_unchecked_rounded,
  StepStatus.running => Icons.hourglass_top_rounded,
  StepStatus.pass => Icons.check_circle_rounded,
  StepStatus.fail => Icons.error_rounded,
  StepStatus.skipped => Icons.remove_circle_outline_rounded,
};

Color _statusColor(BuildContext context, StepStatus s) {
  final c = context.colors;
  final t = Theme.of(context).colorScheme;
  return switch (s) {
    StepStatus.pass => c.callGreen,
    StepStatus.fail => t.error,
    StepStatus.running => t.primary,
    _ => t.onSurfaceVariant,
  };
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({super.key, required this.status});
  final StepStatus status;
  @override
  Widget build(BuildContext context) {
    final color = _statusColor(context, status);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(_statusIcon(status), size: 18, color: color),
        const SizedBox(width: 4),
        Text(_statusLabel(context.l10n, status), style: Theme.of(context).textTheme.labelMedium?.copyWith(color: color)),
      ],
    );
  }
}

/// One numbered step: title, status and the step's controls.
class _StepCard extends StatelessWidget {
  const _StepCard({required this.step, required this.title, required this.status, required this.child, this.message});
  final AudioTestStep step;
  final String title;
  final StepStatus status;
  final Widget child;

  /// Engine error text of a failed step.
  final String? message;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Card(
        key: Key('audio-step-${step.name}'),
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: t.colorScheme.primaryContainer,
                    child: Text('${step.index + 1}', style: t.textTheme.labelMedium?.copyWith(color: t.colorScheme.onPrimaryContainer)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Text(title, style: t.textTheme.titleMedium)),
                  _StatusChip(key: Key('audio-step-status-${step.name}'), status: status),
                ],
              ),
              const SizedBox(height: 12),
              child,
              if (message != null && message!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(message!, style: t.textTheme.bodySmall?.copyWith(color: t.colorScheme.error)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Hint extends StatelessWidget {
  const _Hint(this.text, {super.key, this.error = false, this.ok = false});
  final String text;
  final bool error;
  final bool ok;
  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final color = error ? t.colorScheme.error : (ok ? context.colors.callGreen : t.colorScheme.onSurfaceVariant);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(error ? Icons.warning_amber_rounded : (ok ? Icons.check_circle_outline_rounded : Icons.info_outline_rounded), size: 18, color: color),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: t.textTheme.bodyMedium?.copyWith(color: color))),
      ],
    );
  }
}

class _YesNo extends StatelessWidget {
  const _YesNo({required this.question, required this.yesKey, required this.noKey, required this.onYes, required this.onNo, this.enabled = true});
  final String question;
  final Key yesKey;
  final Key noKey;
  final VoidCallback onYes;
  final VoidCallback onNo;
  final bool enabled;
  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(question, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilledButton.tonal(key: yesKey, onPressed: enabled ? onYes : null, child: Text(l.actionYes)),
            OutlinedButton(key: noKey, onPressed: enabled ? onNo : null, child: Text(l.actionNo)),
          ],
        ),
      ],
    );
  }
}

class _LevelRow extends StatelessWidget {
  const _LevelRow({super.key, required this.icon, required this.label, required this.channel});
  final IconData icon;
  final String label;
  final MeterChannel channel;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.onSurfaceVariant),
        const SizedBox(width: 12),
        Expanded(child: LevelMeter(channel: channel, label: context.l10n.mixerMeterLabel(label), height: 12)),
      ],
    );
  }
}

class _GainSlider extends StatelessWidget {
  const _GainSlider({super.key, required this.label, required this.value, required this.onChanged});
  final String label;
  final double value;
  final ValueChanged<double> onChanged;
  static const max = 2.0;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: MergeSemantics(
            child: Semantics(
              label: label,
              child: Slider(
                padding: const EdgeInsets.symmetric(vertical: 4),
                value: value.clamp(0.0, max).toDouble(),
                max: max,
                onChanged: onChanged,
                semanticFormatterCallback: (v) => '${(v * 100).round()}%',
              ),
            ),
          ),
        ),
        SizedBox(
          width: 48,
          child: Align(alignment: AlignmentDirectional.centerEnd, child: Text('${(value * 100).round()}%', style: tabular(Theme.of(context).textTheme.labelMedium))),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// 1 Devices

class _DevicesStep extends ConsumerWidget {
  const _DevicesStep({required this.st, required this.ctl});
  final AudioTestState st;
  final AudioTestController ctl;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final s = ref.watch(settingsProvider);
    final dev = ref.watch(audioDevicesProvider).value;
    final mobile = ref.watch(audioMobileProvider);
    final audio = st.audio;
    Map<String, String> opts(bool capture) => audioDeviceOptions(l, capture ? dev?.capture : dev?.playback);
    void set(Map<String, dynamic> m) => ref.read(settingsProvider.notifier).update(m);

    Widget opened;
    if (audio == null) {
      opened = const SizedBox.shrink();
    } else if (audio.source == MonitorSource.device) {
      final name = audio.capture?.name ?? audio.playback?.name ?? '';
      opened = _Hint(l.audioTestOpened(name), key: const Key('devices-opened'), ok: true);
    } else {
      opened = _Hint(l.audioTestNoDevice, key: const Key('devices-none'), error: true);
    }

    return _StepCard(
      step: AudioTestStep.devices,
      title: l.audioTestStepDevices,
      status: st.statusOf(AudioTestStep.devices),
      message: st.messages[AudioTestStep.devices],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (mobile) ...[
            MixerRouteSelector(label: l.mixerOutputRoute),
            const SizedBox(height: 6),
            Text(l.mixerInputFollowsOutput, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ] else ...[
            SelectTile<String>(
              key: const Key('devices-capture'),
              icon: Icons.mic_rounded,
              title: l.settingsAudioMicrophone,
              value: s.captureDev,
              options: opts(true),
              onChanged: (v) => set({'captureDev': v}),
            ),
            SelectTile<String>(
              key: const Key('devices-playback'),
              icon: Icons.speaker_rounded,
              title: l.settingsAudioSpeaker,
              value: s.playbackDev,
              options: opts(false),
              onChanged: (v) => set({'playbackDev': v}),
            ),
            SelectTile<String>(
              key: const Key('devices-ringer'),
              icon: Icons.notifications_active_rounded,
              title: l.settingsAudioRinger,
              value: s.ringerDev,
              options: opts(false),
              onChanged: (v) => set({'ringerDev': v}),
            ),
          ],
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: opened),
              IconButton(
                key: const Key('devices-refresh'),
                tooltip: l.settingsAudioRefreshDevices,
                icon: const Icon(Icons.refresh_rounded),
                onPressed: () async {
                  await ref.read(engineProvider.notifier).refreshDevices();
                  await ctl.refreshAudioState();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 2 Microphone

class _MicStep extends ConsumerWidget {
  const _MicStep({required this.st, required this.meters, required this.disabled});
  final AudioTestState st;
  final AudioMeters meters;
  final bool disabled;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final s = ref.watch(settingsProvider);
    final os = ref.watch(audioOsProvider);
    final opener = ref.read(urlOpenerProvider);
    final verdict = st.mic;

    Widget check;
    if (disabled) {
      check = const SizedBox.shrink();
    } else if (verdict == MicVerdict.clipping) {
      check = _Hint(l.audioTestMicClipping, key: const Key('mic-clipping'), error: true);
    } else if (st.micPassed || verdict == MicVerdict.ok) {
      check = _Hint(l.audioTestMicOk, key: const Key('mic-ok'), ok: true);
    } else if (verdict == MicVerdict.quiet) {
      check = _Hint(l.audioTestMicQuiet, key: const Key('mic-quiet'), error: true);
    } else if (verdict == MicVerdict.silent) {
      check = _Hint(l.audioTestMicSilent, key: const Key('mic-silent'), error: true);
    } else {
      check = _Hint(l.audioTestMicWaiting, key: const Key('mic-waiting'));
    }

    // Links into the OS settings are only offered where they exist.
    final links = <Widget>[];
    if (!disabled && verdict == MicVerdict.silent) {
      if (os == 'windows') {
        links.add(OutlinedButton(key: const Key('mic-open-settings'), onPressed: () => opener(Uri.parse('ms-settings:sound')), child: Text(l.audioTestOpenSoundSettings)));
        links.add(OutlinedButton(key: const Key('mic-open-privacy'), onPressed: () => opener(Uri.parse('ms-settings:privacy-microphone')), child: Text(l.audioTestOpenPrivacySettings)));
      } else if (os == 'macos') {
        links.add(
          OutlinedButton(
            key: const Key('mic-open-settings'),
            onPressed: () => opener(Uri.parse('x-apple.systempreferences:com.apple.preference.security?Privacy_Microphone')),
            child: Text(l.audioTestOpenPrivacySettings),
          ),
        );
      }
    }

    return _StepCard(
      step: AudioTestStep.mic,
      title: l.audioTestStepMic,
      status: disabled ? StepStatus.skipped : st.statusOf(AudioTestStep.mic),
      message: st.messages[AudioTestStep.mic],
      child: Opacity(
        opacity: disabled ? 0.5 : 1,
        child: IgnorePointer(
          ignoring: disabled,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _LevelRow(key: const Key('mic-meter'), icon: Icons.mic_rounded, label: l.mixerMicrophone, channel: meters.mic),
              _GainSlider(
                key: const Key('mic-gain'),
                label: l.mixerMicVolume,
                value: s.micLevel,
                onChanged: (v) => ref.read(settingsProvider.notifier).update({'micLevel': v}),
              ),
              check,
              if (links.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 8), child: Wrap(spacing: 8, runSpacing: 8, children: links)),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 3 Speaker

class _SpeakerStep extends ConsumerWidget {
  const _SpeakerStep({required this.st, required this.ctl, required this.meters, required this.disabled});
  final AudioTestState st;
  final AudioTestController ctl;
  final AudioMeters meters;
  final bool disabled;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final s = ref.watch(settingsProvider);
    final status = st.statusOf(AudioTestStep.speaker);
    return _StepCard(
      step: AudioTestStep.speaker,
      title: l.audioTestStepSpeaker,
      status: disabled ? StepStatus.skipped : status,
      message: st.messages[AudioTestStep.speaker],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: FilledButton.icon(
              key: const Key('play-chime'),
              onPressed: disabled || st.speakerPlaying ? null : ctl.playChime,
              icon: const Icon(Icons.volume_up_rounded),
              label: Text(l.audioTestPlaySound),
            ),
          ),
          const SizedBox(height: 8),
          _LevelRow(key: const Key('speaker-meter'), icon: Icons.headphones_rounded, label: l.mixerSpeaker, channel: meters.speaker),
          _GainSlider(
            key: const Key('spk-gain'),
            label: l.mixerSpeakerVolume,
            value: s.speakerLevel,
            onChanged: (v) => ref.read(settingsProvider.notifier).update({'speakerLevel': v}),
          ),
          if (st.speakerPlayed && st.speakerNoLevel) _Hint(l.audioTestNoOutputLevel, key: const Key('spk-no-level'), error: true),
          if (st.speakerPlayed || st.speakerPlaying)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: _YesNo(
                question: l.audioTestDidYouHear,
                yesKey: const Key('spk-yes'),
                noKey: const Key('spk-no'),
                enabled: !disabled,
                onYes: () => ctl.answerSpeaker(true),
                onNo: () => ctl.answerSpeaker(false),
              ),
            ),
          if (status == StepStatus.fail && !st.speakerPlaying && st.speakerPlayed)
            Padding(padding: const EdgeInsets.only(top: 8), child: _Hint(l.audioTestSpeakerHints, key: const Key('spk-hints'))),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 4 Record and play back

class _RecordStep extends StatelessWidget {
  const _RecordStep({required this.st, required this.ctl, required this.meters, required this.disabled});
  final AudioTestState st;
  final AudioTestController ctl;
  final AudioMeters meters;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final recording = st.rec == RecPhase.recording;
    return _StepCard(
      step: AudioTestStep.record,
      title: l.audioTestStepRecord,
      status: disabled ? StepStatus.skipped : st.statusOf(AudioTestStep.record),
      message: st.messages[AudioTestStep.record],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              FilledButton.icon(
                key: const Key('rec-start'),
                onPressed: disabled || recording || st.rec == RecPhase.playing ? null : ctl.startRecording,
                icon: const Icon(Icons.fiber_manual_record_rounded),
                label: Text(l.audioTestRecord5s),
              ),
              if (st.rec == RecPhase.done)
                OutlinedButton.icon(
                  key: const Key('rec-again'),
                  onPressed: disabled ? null : ctl.playRecording,
                  icon: const Icon(Icons.replay_rounded),
                  label: Text(l.audioTestPlayAgain),
                ),
            ],
          ),
          const SizedBox(height: 8),
          _LevelRow(key: const Key('rec-meter'), icon: Icons.mic_rounded, label: l.mixerMicrophone, channel: meters.mic),
          if (recording) Padding(padding: const EdgeInsets.only(top: 8), child: _Hint(l.audioTestRecording(st.recSecondsLeft), key: const Key('rec-countdown'))),
          if (st.rec == RecPhase.playing) Padding(padding: const EdgeInsets.only(top: 8), child: _Hint(l.audioTestPlayingBack, key: const Key('rec-playing'))),
          if (st.recEmpty) Padding(padding: const EdgeInsets.only(top: 8), child: _Hint(l.audioTestRecEmpty, key: const Key('rec-empty'), error: true)),
          if (st.rec == RecPhase.done)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: _YesNo(
                question: l.audioTestDidYouHearVoice,
                yesKey: const Key('rec-yes'),
                noKey: const Key('rec-no'),
                enabled: !disabled,
                onYes: () => ctl.answerRecord(true),
                onNo: () => ctl.answerRecord(false),
              ),
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 5 Hear yourself

Future<bool> _confirmHeadphones(BuildContext context) async {
  final l = context.l10n;
  final ok = await showDialog<bool>(
    context: context,
    builder: (c) => AlertDialog(
      key: const Key('echo-headphones-dialog'),
      title: Text(l.audioTestStepEcho),
      content: Text(l.audioTestEchoHeadphones),
      actions: [
        TextButton(key: const Key('echo-headphones-cancel'), onPressed: () => Navigator.pop(c, false), child: Text(l.actionCancel)),
        FilledButton(key: const Key('echo-headphones-ok'), onPressed: () => Navigator.pop(c, true), child: Text(l.actionContinue)),
      ],
    ),
  );
  return ok ?? false;
}

/// The engine's end reason in words (unknown reasons are shown as they are).
String _endReason(AppLocalizations l, String r) => switch (r) {
  'timeout' => l.audioTestEchoEndedTimeout,
  'call' => l.audioTestEchoEndedCall,
  'shutdown' => l.audioTestEchoEndedShutdown,
  _ => r,
};

class _EchoStep extends ConsumerWidget {
  const _EchoStep({required this.st, required this.ctl, required this.disabled});
  final AudioTestState st;
  final AudioTestController ctl;
  final bool disabled;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final echoOn = ref.watch(echoTestProvider.select((e) => e.on)) && !st.previewOn;
    return _StepCard(
      step: AudioTestStep.echo,
      title: l.audioTestStepEcho,
      status: disabled ? StepStatus.skipped : st.statusOf(AudioTestStep.echo),
      message: st.messages[AudioTestStep.echo],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SwitchListTile(
            key: const Key('echo-switch'),
            contentPadding: EdgeInsets.zero,
            secondary: const Icon(Icons.hearing_rounded),
            title: Text(l.audioTestStepEcho),
            subtitle: Text(l.audioTestEchoHeadphones),
            value: echoOn,
            onChanged: disabled
                ? null
                : (v) async {
                    if (v && !st.headphonesAck) {
                      final ok = await _confirmHeadphones(context);
                      if (!ok) return;
                      ctl.acknowledgeHeadphones();
                    }
                    await ctl.setEcho(v);
                  },
          ),
          if (echoOn && st.echoSecondsLeft > 0) _Hint(l.audioTestEchoSecondsLeft(st.echoSecondsLeft), key: const Key('echo-countdown')),
          if (st.echoBusy) _Hint(l.audioTestInCall, key: const Key('echo-busy'), error: true),
          if (!echoOn && st.echoEndedReason != null) _Hint(l.audioTestEchoEnded(_endReason(l, st.echoEndedReason!)), key: const Key('echo-ended')),
          if (st.echoUsed)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: _YesNo(
                question: l.audioTestDidYouHearVoice,
                yesKey: const Key('echo-yes'),
                noKey: const Key('echo-no'),
                enabled: !disabled,
                onYes: () => ctl.answerEcho(true),
                onNo: () => ctl.answerEcho(false),
              ),
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 6 Background music

class _MusicStep extends ConsumerWidget {
  const _MusicStep({required this.st, required this.ctl, required this.meters, required this.disabled});
  final AudioTestState st;
  final AudioTestController ctl;
  final AudioMeters meters;
  final bool disabled;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final s = ref.watch(settingsProvider);
    void set(Map<String, dynamic> m) => ref.read(settingsProvider.notifier).update(m);
    return _StepCard(
      step: AudioTestStep.music,
      title: l.audioTestStepMusic,
      status: disabled ? StepStatus.skipped : st.statusOf(AudioTestStep.music),
      message: st.messages[AudioTestStep.music],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(alignment: AlignmentDirectional.centerStart, child: MusicbedFileChip(file: s.musicbedFile)),
          SwitchListTile(
            key: const Key('music-switch'),
            contentPadding: EdgeInsets.zero,
            title: Text(l.musicbedPlay),
            value: s.musicbedEnabled,
            onChanged: disabled ? null : (v) => toggleMusicbed(context, ref, v),
          ),
          _LevelRow(key: const Key('music-meter'), icon: Icons.music_note_rounded, label: l.musicbedTitle, channel: meters.musicbed),
          _GainSlider(key: const Key('music-volume'), label: l.musicbedVolume, value: s.musicbedVolume, onChanged: (v) => set({'musicbedVolume': v})),
          SwitchListTile(
            key: const Key('music-monitor'),
            contentPadding: EdgeInsets.zero,
            title: Text(l.musicbedHearIt),
            value: s.musicbedMonitor,
            onChanged: disabled ? null : (v) => set({'musicbedMonitor': v}),
          ),
          if (ref.watch(musicbedProvider.select((m) => m.active)) && !s.musicbedMonitor && !st.previewOn)
            Padding(padding: const EdgeInsets.only(top: 4), child: _Hint(l.audioTestMusicSilentHint, key: const Key('music-silent-hint'))),
          const Divider(),
          SwitchListTile(
            key: const Key('preview-switch'),
            contentPadding: EdgeInsets.zero,
            secondary: const Icon(Icons.record_voice_over_rounded),
            title: Text(l.audioTestPreview),
            subtitle: Text(l.audioTestPreviewSub),
            value: st.previewOn,
            onChanged: disabled
                ? null
                : (v) async {
                    if (v && !st.headphonesAck) {
                      final ok = await _confirmHeadphones(context);
                      if (!ok) return;
                      ctl.acknowledgeHeadphones();
                    }
                    await ctl.setPreview(v);
                  },
          ),
          _LevelRow(key: const Key('send-meter'), icon: Icons.call_made_rounded, label: l.audioTestSendLevel, channel: meters.send),
          const SizedBox(height: 4),
          Text(l.audioTestSendLevel, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
          const SizedBox(height: 8),
          _Hint(l.audioTestEcNotPreviewed, key: const Key('preview-ec-note')),
          if (st.previewUsed)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: _YesNo(
                question: l.audioTestDidYouHearVoice,
                yesKey: const Key('preview-yes'),
                noKey: const Key('preview-no'),
                enabled: !disabled,
                onYes: () => ctl.answerPreview(true),
                onNo: () => ctl.answerPreview(false),
              ),
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 7 Summary

class _SummaryCard extends ConsumerWidget {
  const _SummaryCard({required this.st, required this.ctl});
  final AudioTestState st;
  final AudioTestController ctl;

  String _title(AppLocalizations l, AudioTestStep s) => switch (s) {
    AudioTestStep.devices => l.audioTestStepDevices,
    AudioTestStep.mic => l.audioTestStepMic,
    AudioTestStep.speaker => l.audioTestStepSpeaker,
    AudioTestStep.record => l.audioTestStepRecord,
    AudioTestStep.echo => l.audioTestStepEcho,
    AudioTestStep.music => l.audioTestStepMusic,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final t = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Card(
        key: const Key('audio-test-summary'),
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l.audioTestStepSummary, style: t.textTheme.titleMedium),
              const SizedBox(height: 8),
              for (final s in AudioTestStep.values)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Expanded(child: Text(_title(l, s), style: t.textTheme.bodyMedium)),
                      _StatusChip(key: Key('summary-status-${s.name}'), status: st.statusOf(s)),
                    ],
                  ),
                ),
              const SizedBox(height: 8),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: OutlinedButton.icon(
                  key: const Key('copy-diagnostics'),
                  icon: const Icon(Icons.copy_rounded),
                  label: Text(l.audioTestCopyDiagnostics),
                  onPressed: () async {
                    final notice = ref.read(noticeProvider.notifier);
                    final text = await ctl.diagnosticsText();
                    await Clipboard.setData(ClipboardData(text: text));
                    notice.show(ref.read(l10nProvider).audioTestCopied);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
