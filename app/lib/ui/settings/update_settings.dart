import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/settings_controller.dart';
import '../../services/update_checker.dart';
import '../widgets/settings_tiles.dart';

/// Settings > About > Updates (desktop only).
class UpdatesSettingsGroup extends ConsumerWidget {
  const UpdatesSettingsGroup({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!ref.watch(updatesSupportedProvider)) return const SizedBox.shrink();
    final s = ref.watch(settingsProvider);
    final u = ref.watch(updateProvider);
    final res = u.lastResult;
    final status = u.checking
        ? 'Checking...'
        : switch (res?.outcome) {
            UpdateOutcome.available => 'SoftphonePro ${res!.release!.version} is available',
            UpdateOutcome.upToDate => 'You are up to date',
            UpdateOutcome.rateLimited || UpdateOutcome.failed => res!.error ?? 'Could not check',
            null => s.updateLastCheck == 0
                ? 'Not checked yet'
                : 'Last checked ${DateTime.fromMillisecondsSinceEpoch(s.updateLastCheck).toLocal().toString().split('.').first}',
          };
    return SettingsGroup(
      title: 'Updates',
      footer:
          'Checking contacts api.github.com only (once a week) and sends nothing but the request itself: no identifier, no account or call data. SoftphonePro never downloads or installs anything by itself.',
      children: [
        SwitchTile(
          key: const Key('update-check'),
          icon: Icons.system_update_alt_rounded,
          title: 'Check for updates',
          value: s.updateCheck,
          onChanged: (v) => ref.read(settingsProvider.notifier).update({'updateCheck': v}),
        ),
        ListTile(
          key: const Key('update-check-now'),
          leading: const Icon(Icons.refresh_rounded),
          title: const Text('Check now'),
          subtitle: Text(status),
          enabled: !u.checking,
          onTap: () => ref.read(updateProvider.notifier).checkNow(),
        ),
        if (s.updateSkipVersion.isNotEmpty)
          ListTile(
            leading: const Icon(Icons.undo_rounded),
            title: Text('Skipping version ${s.updateSkipVersion}'),
            trailing: TextButton(
              onPressed: () => ref.read(settingsProvider.notifier).update({'updateSkipVersion': ''}),
              child: const Text('Stop skipping'),
            ),
          ),
      ],
    );
  }
}
