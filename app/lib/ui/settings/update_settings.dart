import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/l10n.dart';
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
    final l = context.l10n;
    final status = u.checking
        ? l.updatesChecking
        : switch (res?.outcome) {
            UpdateOutcome.available => l.updatesAvailable('${res!.release!.version}'),
            UpdateOutcome.upToDate => l.updatesUpToDate,
            UpdateOutcome.rateLimited || UpdateOutcome.failed => res!.error ?? l.updatesCouldNotCheck,
            null => s.updateLastCheck == 0
                ? l.updatesNotCheckedYet
                : l.updatesLastChecked(DateTime.fromMillisecondsSinceEpoch(s.updateLastCheck).toLocal()),
          };
    return SettingsGroup(
      title: l.updatesTitle,
      footer: l.updatesFooter,
      children: [
        SwitchTile(
          key: const Key('update-check'),
          icon: Icons.system_update_alt_rounded,
          title: l.updatesCheckSwitch,
          value: s.updateCheck,
          onChanged: (v) => ref.read(settingsProvider.notifier).update({'updateCheck': v}),
        ),
        ListTile(
          key: const Key('update-check-now'),
          leading: const Icon(Icons.refresh_rounded),
          title: Text(l.updatesCheckNow),
          subtitle: Text(status),
          enabled: !u.checking,
          onTap: () => ref.read(updateProvider.notifier).checkNow(),
        ),
        if (s.updateSkipVersion.isNotEmpty)
          ListTile(
            leading: const Icon(Icons.undo_rounded),
            title: Text(l.updatesSkippingVersion(s.updateSkipVersion)),
            trailing: TextButton(
              onPressed: () => ref.read(settingsProvider.notifier).update({'updateSkipVersion': ''}),
              child: Text(l.updatesStopSkipping),
            ),
          ),
      ],
    );
  }
}
