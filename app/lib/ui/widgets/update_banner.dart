import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/update_checker.dart';

/// "SoftphonePro X.Y.Z is available" banner for the desktop shell. Renders
/// nothing when there is no newer release (or on mobile).
class UpdateBanner extends ConsumerWidget {
  const UpdateBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(updateProvider);
    final r = s.release;
    if (!s.showBanner || r == null) return const SizedBox.shrink();
    final ctl = ref.read(updateProvider.notifier);
    final t = Theme.of(context);
    return Material(
      color: t.colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 4,
          children: [
            Icon(Icons.system_update_alt_rounded, size: 18, color: t.colorScheme.onPrimaryContainer),
            Text('SoftphonePro ${r.version} is available', key: const Key('update-banner'), style: TextStyle(color: t.colorScheme.onPrimaryContainer)),
            TextButton(key: const Key('update-notes'), onPressed: () => ctl.open(r.url), child: const Text('Release notes')),
            TextButton(key: const Key('update-download'), onPressed: () => ctl.open(r.url), child: const Text('Download')),
            TextButton(key: const Key('update-skip'), onPressed: ctl.skipVersion, child: const Text('Skip this version')),
            IconButton(key: const Key('update-dismiss'), tooltip: 'Dismiss', icon: const Icon(Icons.close_rounded, size: 18), onPressed: ctl.dismiss),
          ],
        ),
      ),
    );
  }
}
