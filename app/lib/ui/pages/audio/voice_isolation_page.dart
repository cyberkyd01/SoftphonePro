import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spcore_dart/spcore_dart.dart';

import '../../../audio/audio_platform.dart';
import '../../../audio/voice_isolation.dart';
import '../../../core/theme.dart';
import '../../../services/providers.dart';
import '../../../services/settings_controller.dart';
import '../../widgets/settings_tiles.dart';

/// Settings > Audio > Voice isolation (AI noise cancellation).
class VoiceIsolationPage extends StatelessWidget {
  const VoiceIsolationPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Voice isolation')),
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

  @override
  void initState() {
    super.initState();
    _vi = ref.read(voiceIsolationProvider.notifier);
    Future.microtask(() {
      if (!mounted) return;
      _vi.startMeter();
      _vi.probe();
    });
  }

  @override
  void dispose() {
    _vi.stopMeter();
    _vi.endEchoTest();
    super.dispose();
  }

  void _set(Map<String, dynamic> m) => ref.read(settingsProvider.notifier).update(m);

  Future<void> _echo(bool on) async {
    try {
      await _vi.setEchoTest(on);
    } on EngineException catch (e) {
      ref.read(noticeProvider.notifier).error('Echo test failed', details: '$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(settingsProvider);
    final vi = ref.watch(voiceIsolationProvider);
    final platform = ref.watch(audioPlatformProvider);
    final available = vi.available != false;
    final t = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.only(bottom: 32),
      children: [
        if (!available)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
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
                  const Expanded(child: Text('AI noise cancellation is not available in this build of the call engine. The standard noise suppression under Processing still works.')),
                ],
              ),
            ),
          ),
        SettingsGroup(
          title: 'AI noise cancellation',
          footer: 'Removes keyboard clicks, fans and background voices from the call using an on-device neural network (RNNoise). Nothing leaves your device. Higher strength removes more noise but can clip the start of words.',
          children: [
            SwitchTile(
              key: const Key('vi-mic-switch'),
              icon: Icons.mic_rounded,
              title: 'My microphone',
              subtitle: 'Clean up what the other person hears',
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
              title: 'Other participants',
              subtitle: 'Clean up noisy callers you hear',
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
          title: 'Try it',
          footer: 'Use headphones for the echo test, or you will hear feedback.',
          children: [
            _SpeechMeter(value: vi.vad, active: s.viMicOn && available),
            SwitchTile(
              key: const Key('vi-echo-test'),
              icon: Icons.hearing_rounded,
              title: 'Test with echo',
              subtitle: 'Plays your processed microphone back to you',
              value: vi.echoTest,
              onChanged: _echo,
            ),
          ],
        ),
        if (platform.hasSystemMicrophoneModes)
          SettingsGroup(
            title: 'System',
            footer: 'macOS and iOS can also isolate your voice for every app. Choose Voice Isolation in the system microphone mode.',
            children: [
              ListTile(
                key: const Key('vi-system-mode'),
                leading: const Icon(Icons.settings_voice_rounded),
                title: const Text('System microphone mode (Voice Isolation)…'),
                onTap: () async {
                  final ok = await platform.showSystemMicrophoneModes();
                  if (!ok && context.mounted) {
                    ref.read(noticeProvider.notifier).show('Microphone modes need macOS 12 or iOS 15 or later.');
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
      contentPadding: const EdgeInsets.only(left: 72, right: 16),
      title: Text('Strength: ${strengthText(value)}', style: Theme.of(context).textTheme.bodyMedium),
      subtitle: Slider(
        value: value.clamp(0.0, 1.0),
        divisions: 20,
        label: strengthText(value),
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
    final c = context.colors;
    final v = active ? value.clamp(0.0, 1.0) : 0.0;
    return Semantics(
      label: 'Speech detection',
      value: '${(v * 100).round()} percent',
      child: ListTile(
        leading: const Icon(Icons.graphic_eq_rounded),
        title: const Text('Speech detection'),
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
        trailing: Text(active ? '${(v * 100).round()}%' : 'Off'),
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
        String yn(bool b) => b ? 'Available' : 'Not available on this device';
        return SettingsGroup(
          title: 'Android audio effects',
          footer: 'The phone may also clean up the microphone itself. These are reported by Android and are separate from the setting above.',
          children: [
            ListTile(key: const Key('android-ns'), leading: const Icon(Icons.noise_aware_rounded), title: const Text('Noise suppressor'), subtitle: Text(yn(e.noiseSuppressor))),
            ListTile(key: const Key('android-aec'), leading: const Icon(Icons.surround_sound_rounded), title: const Text('Echo canceller'), subtitle: Text(yn(e.echoCanceler))),
          ],
        );
      },
    );
  }
}
