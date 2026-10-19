import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/l10n.dart';
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
    final l = context.l10n;
    return Material(
      color: t.colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 4,
          children: [
            Icon(Icons.system_update_alt_rounded, size: 18, color: t.colorScheme.onPrimaryContainer),
            Text(l.updatesAvailable('${r.version}'), key: const Key('update-banner'), style: TextStyle(color: t.colorScheme.onPrimaryContainer)),
            TextButton(key: const Key('update-notes'), onPressed: () => ctl.open(r.url), child: Text(l.updatesReleaseNotes)),
            TextButton(key: const Key('update-download'), onPressed: () => ctl.open(r.url), child: Text(l.updatesDownload)),
            TextButton(key: const Key('update-skip'), onPressed: ctl.skipVersion, child: Text(l.updatesSkipVersion)),
            IconButton(key: const Key('update-dismiss'), tooltip: l.updatesDismiss, icon: const Icon(Icons.close_rounded, size: 18), onPressed: ctl.dismiss),
          ],
        ),
      ),
    );
  }
}
