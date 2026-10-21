import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spcore_dart/spcore_dart.dart';

import '../../../audio/audio_platform.dart';
import '../../../audio/echo_test.dart';
import '../../../audio/voice_isolation.dart';
import '../../../core/theme.dart';
import '../../../l10n/l10n.dart';
import '../../../services/providers.dart';
import '../../../services/settings_controller.dart';
import '../../widgets/settings_tiles.dart';

/// Settings > Audio > Voice isolation (AI noise cancellation).
class VoiceIsolationPage extends StatelessWidget {
  const VoiceIsolationPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(context.l10n.voiceTitle)),
    body: const VoiceIsolationBody(),
  );
}

class VoiceIsolationBody extends ConsumerStatefulWidget {
  const VoiceIsolationBody({super.key});
  @override
  ConsumerState<VoiceIsolationBody> createState() => _VoiceIsolationBodyState();
}

class _VoiceIsolationBodyState extends ConsumerState<VoiceIsolationBody> {
  late final VoiceIsolationController _vi;
  late final EchoTestController _echoCtl;

  @override
  void initState() {
    super.initState();
    _vi = ref.read(voiceIsolationProvider.notifier);
    _echoCtl = ref.read(echoTestProvider.notifier);
    Future.microtask(() {
      if (!mounted) return;
      _vi.startMeter();
      _vi.probe();
    });
  }

  @override
  void dispose() {
    _vi.stopMeter();
    _echoCtl.stopQuiet();
    super.dispose();
  }

  void _set(Map<String, dynamic> m) => ref.read(settingsProvider.notifier).update(m);

  Future<void> _echo(bool on) async {
    try {
      if (on) {
        await _echoCtl.start();
      } else {
        await _echoCtl.stop();
      }
    } on EngineException catch (e) {
      ref.read(noticeProvider.notifier).error(ref.read(l10nProvider).voiceEchoFailed, details: '$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(settingsProvider);
    final vi = ref.watch(voiceIsolationProvider);
    final platform = ref.watch(audioPlatformProvider);
    final l = context.l10n;
    final available = vi.available != false;
    final t = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.only(bottom: 32),
      children: [
        if (!available)
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
            child: Container(
              key: const Key('vi-unavailable'),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: t.colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(kRadius),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded, color: t.colorScheme.onSurfaceVariant),
                  const SizedBox(width: 12),
                  Expanded(child: Text(l.voiceUnavailable)),
                ],
              ),
            ),
          ),
        SettingsGroup(
          title: l.voiceGroupAi,
          footer: l.voiceAiFooter,
          children: [
            SwitchTile(
              key: const Key('vi-mic-switch'),
              icon: Icons.mic_rounded,
              title: l.voiceMic,
              subtitle: l.voiceMicHint,
              value: s.viMicOn,
              onChanged: available ? (v) => _set({'viMicOn': v}) : null,
            ),
            _StrengthTile(
              key: const Key('vi-mic-strength'),
              value: s.viMicStrength,
              enabled: available && s.viMicOn,
              onChanged: (v) => _set({'viMicStrength': v}),
            ),
            SwitchTile(
              key: const Key('vi-in-switch'),
              icon: Icons.record_voice_over_rounded,
              title: l.voiceOthers,
              subtitle: l.voiceOthersHint,
              value: s.viInOn,
              onChanged: available ? (v) => _set({'viInOn': v}) : null,
            ),
            _StrengthTile(
              key: const Key('vi-in-strength'),
              value: s.viInStrength,
              enabled: available && s.viInOn,
              onChanged: (v) => _set({'viInStrength': v}),
            ),
          ],
        ),
        SettingsGroup(
          title: l.voiceGroupTry,
          footer: l.voiceTryFooter,
          children: [
            _SpeechMeter(value: vi.vad, active: s.viMicOn && available),
            SwitchTile(
              key: const Key('vi-echo-test'),
              icon: Icons.hearing_rounded,
              title: l.voiceEchoTest,
              subtitle: l.voiceEchoTestHint,
              value: ref.watch(echoTestProvider).on,
              onChanged: _echo,
            ),
          ],
        ),
        if (platform.hasSystemMicrophoneModes)
          SettingsGroup(
            title: l.voiceGroupSystem,
            footer: l.voiceSystemFooter,
            children: [
              ListTile(
                key: const Key('vi-system-mode'),
                leading: const Icon(Icons.settings_voice_rounded),
                title: Text(l.voiceSystemMode),
                onTap: () async {
                  final ok = await platform.showSystemMicrophoneModes();
                  if (!ok && context.mounted) {
                    ref.read(noticeProvider.notifier).show(l.voiceSystemModeUnsupported);
                  }
                },
              ),
            ],
          ),
        const _AndroidEffectsGroup(),
      ],
    );
  }
}

class _StrengthTile extends StatelessWidget {
  const _StrengthTile({super.key, required this.value, required this.enabled, required this.onChanged});
  final double value;
  final bool enabled;
  final ValueChanged<double> onChanged;
  @override
  Widget build(BuildContext context) {
    return ListTile(
      enabled: enabled,
      contentPadding: const EdgeInsetsDirectional.only(start: 72, end: 16),
      title: Text(context.l10n.voiceStrength(strengthText(context.l10n, value)), style: Theme.of(context).textTheme.bodyMedium),
      subtitle: Slider(
        value: value.clamp(0.0, 1.0),
        divisions: 20,
        label: strengthText(context.l10n, value),
        onChanged: enabled ? onChanged : null,
      ),
    );
  }
}

class _SpeechMeter extends StatelessWidget {
  const _SpeechMeter({required this.value, required this.active});
  final double value;
  final bool active;
  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.colors;
    final v = active ? value.clamp(0.0, 1.0) : 0.0;
    return Semantics(
      label: l.voiceSpeechDetection,
      value: l.voiceSpeechPercent((v * 100).round()),
      child: ListTile(
        leading: const Icon(Icons.graphic_eq_rounded),
        title: Text(l.voiceSpeechDetection),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              key: const Key('vi-vad-meter'),
              value: v,
              minHeight: 8,
              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              color: c.regOk,
            ),
          ),
        ),
        trailing: Text(active ? l.voicePercent((v * 100).round()) : l.commonOff),
      ),
    );
  }
}

class _AndroidEffectsGroup extends ConsumerWidget {
  const _AndroidEffectsGroup();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<AndroidAudioEffects?>(
      future: ref.read(audioPlatformProvider).androidEffects(),
      builder: (context, snap) {
        final e = snap.data;
        if (e == null) return const SizedBox.shrink();
        final l = context.l10n;
        String yn(bool b) => b ? l.statusAvailable : l.voiceNotAvailableDevice;
        return SettingsGroup(
          title: l.voiceGroupAndroid,
          footer: l.voiceAndroidFooter,
          children: [
            ListTile(key: const Key('android-ns'), leading: const Icon(Icons.noise_aware_rounded), title: Text(l.voiceAndroidNs), subtitle: Text(yn(e.noiseSuppressor))),
            ListTile(key: const Key('android-aec'), leading: const Icon(Icons.surround_sound_rounded), title: Text(l.voiceAndroidAec), subtitle: Text(yn(e.echoCanceler))),
          ],
        );
      },
    );
  }
}
