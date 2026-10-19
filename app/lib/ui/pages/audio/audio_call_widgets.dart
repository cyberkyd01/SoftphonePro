import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../audio/announcement_service.dart';
import '../../../audio/voice_isolation.dart';
import '../../../services/settings_controller.dart';

/// "Playing announcement..." with a Skip button, shown while an opening,
/// recording or transfer announcement plays into the call.
class AnnouncementChip extends ConsumerWidget {
  const AnnouncementChip({super.key, required this.cid, this.center = false});
  final int cid;
  final bool center;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final play = ref.watch(activeAnnouncementsProvider)[cid];
    if (play == null) return const SizedBox.shrink();
    final t = Theme.of(context);
    final label = switch (play.kind) {
      AnnouncementKind.opening => 'Playing announcement…',
      AnnouncementKind.transfer => 'Playing transfer notice…',
      AnnouncementKind.recordingNotice => 'Playing recording notice…',
    };
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Align(
        alignment: center ? Alignment.center : Alignment.centerLeft,
        child: Container(
          key: Key('announcement-chip-$cid'),
          padding: const EdgeInsets.only(left: 12, right: 4),
          decoration: BoxDecoration(
            color: t.colorScheme.primary.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.campaign_rounded, size: 16, color: t.colorScheme.primary),
              const SizedBox(width: 6),
              Flexible(child: Text(label, style: t.textTheme.labelMedium)),
              TextButton(
                key: Key('skip-announcement-$cid'),
                style: TextButton.styleFrom(minimumSize: const Size(44, 32), padding: const EdgeInsets.symmetric(horizontal: 10)),
                onPressed: () => ref.read(announcementServiceProvider).skip(cid),
                child: const Text('Skip'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Small "Noise cancellation on" indicator for the call screen.
class NoiseCancellationChip extends ConsumerWidget {
  const NoiseCancellationChip({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(settingsProvider);
    final avail = ref.watch(voiceIsolationProvider).available;
    if (!(s.viMicOn || s.viInOn) || avail == false) return const SizedBox.shrink();
    final t = Theme.of(context);
    return Tooltip(
      message: 'AI noise cancellation: ${[if (s.viMicOn) 'your microphone', if (s.viInOn) 'other participants'].join(' and ')}',
      child: Container(
        key: const Key('noise-cancellation-chip'),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: t.colorScheme.primary.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.noise_control_off_rounded, size: 13, color: t.colorScheme.primary),
            const SizedBox(width: 4),
            Text('Noise cancellation on', style: t.textTheme.labelSmall?.copyWith(color: t.colorScheme.primary, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

/// On/off and strength for the in-call More sheet.
class NoiseCancellationTile extends ConsumerWidget {
  const NoiseCancellationTile({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(settingsProvider);
    final avail = ref.watch(voiceIsolationProvider).available;
    if (avail == false) return const SizedBox.shrink();
    void set(Map<String, dynamic> m) => ref.read(settingsProvider.notifier).update(m);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SwitchListTile(
          key: const Key('incall-noise-switch'),
          secondary: const Icon(Icons.noise_control_off_rounded),
          title: const Text('Noise cancellation'),
          subtitle: Text(s.viMicOn ? 'My microphone: ${strengthText(s.viMicStrength)}' : 'Remove background noise from my microphone'),
          value: s.viMicOn,
          onChanged: (v) => set({'viMicOn': v}),
        ),
        if (s.viMicOn)
          Padding(
            padding: const EdgeInsets.only(left: 56, right: 16),
            child: Slider(
              key: const Key('incall-noise-strength'),
              value: s.viMicStrength.clamp(0.0, 1.0),
              divisions: 20,
              label: strengthText(s.viMicStrength),
              onChanged: (v) => set({'viMicStrength': v}),
            ),
          ),
      ],
    );
  }
}
