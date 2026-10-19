import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../../l10n/l10n.dart';
import '../../services/calls_controller.dart';

/// Progress of a blind transfer ("Transferring..."), and when it got no answer from the server within
/// [kTransferConfirmTimeout]: keep the call or send the transfer again.
class TransferStalledBanner extends ConsumerWidget {
  const TransferStalledBanner({super.key, required this.call, this.margin = const EdgeInsetsDirectional.only(top: 12)});
  final UiCall call;
  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Theme.of(context);
    if (call.transferPending && !call.transferStalled) {
      return Padding(
        padding: margin,
        child: Row(
          key: const Key('transfer-progress'),
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.sync_rounded, size: 16, color: t.colorScheme.primary),
            const SizedBox(width: 8),
            Text(context.l10n.callTransferring, style: t.textTheme.bodyMedium),
          ],
        ),
      );
    }
    if (!call.transferStalled) return const SizedBox.shrink();
    final calls = ref.read(callsProvider.notifier);
    return Container(
      key: const Key('transfer-stalled'),
      margin: margin,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.colors.holdAmber.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(kRadius),
      ),
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.warning_amber_rounded, size: 18, color: context.colors.holdAmber),
              const SizedBox(width: 6),
              Flexible(child: Text(context.l10n.callTransferNotConfirmed, style: t.textTheme.titleSmall)),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            context.l10n.callTransferStalledHint,
            textAlign: TextAlign.center,
            style: t.textTheme.bodySmall,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  key: const Key('transfer-keep'),
                  onPressed: () => calls.keepCallAfterStalledTransfer(call.cid),
                  child: Text(context.l10n.callTransferKeepCall),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton(
                  key: const Key('transfer-retry'),
                  onPressed: () => calls.retryStalledTransfer(call.cid),
                  child: Text(context.l10n.actionRetry),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
