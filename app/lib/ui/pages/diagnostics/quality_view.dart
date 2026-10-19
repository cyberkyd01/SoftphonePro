import '../../../core/bidi.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/format.dart';
import '../../../diagnostics/sip_trace_controller.dart';
import '../../../l10n/l10n.dart';
import '../../../models/call_record.dart';
import '../../../services/calls_controller.dart';
import '../../../services/history_controller.dart';
import '../../widgets/basic_widgets.dart';
import 'quality_widgets.dart';

/// Bottom sheet with the stored quality series of a finished call.
Future<void> showCallQualitySheet(BuildContext context, CallRecord r) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    constraints: const BoxConstraints(maxWidth: 720),
    builder: (_) => CallQualitySheet(record: r),
  );
}

class CallQualitySheet extends ConsumerWidget {
  const CallQualitySheet({super.key, required this.record});
  final CallRecord record;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Theme.of(context);
    final l = context.l10n;
    final trace = ref.read(sipTraceProvider.notifier);
    final hasTrace = trace.hasCallId(record.callId);
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.diagQualityTitle, style: t.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
          Text(
            '${dayLabel(record.start, context.l10n)}, ${timeLabel(record.start, context.l10n)}  ·  ${formatMs(record.durationMs)}',
            style: t.textTheme.bodyMedium?.copyWith(color: t.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 16),
          if (record.quality.isEmpty)
            Text(l.diagQualityNoData)
          else
            QualityPanel(samples: record.quality.samples, summary: record.quality),
          const SizedBox(height: 16),
          if (record.callId.isNotEmpty)
            OutlinedButton.icon(
              key: const Key('sheet-trace'),
              onPressed: hasTrace
                  ? () {
                      ref.read(diagnosticsFocusProvider.notifier).focus(record.callId);
                      Navigator.pop(context);
                      context.push('/settings/diagnostics');
                    }
                  : null,
              icon: const Icon(Icons.account_tree_outlined),
              label: Text(hasTrace ? l.diagQualityTraceForCall : l.diagQualityTraceNotCaptured),
            ),
        ],
      ),
    );
  }
}

/// The Quality tab: live panel for the focused call plus recent history.
class QualityView extends ConsumerWidget {
  const QualityView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final calls = ref.watch(callsProvider);
    final live = calls.focused;
    final history = ref.watch(historyProvider).where((r) => !r.quality.isEmpty).take(12).toList();
    final t = Theme.of(context);
    final l = context.l10n;
    final active = live != null && live.isConfirmed;
    return ListView(
      padding: const EdgeInsets.only(bottom: 32),
      children: [
        SectionHeader(l.diagQualityLiveCall),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: active
              ? Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(ltr(live.info.remoteUri), style: t.textTheme.titleSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 8),
                        QualityPanel(samples: live.samples, stats: live.stats),
                      ],
                    ),
                  ),
                )
              : Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(l.diagQualityNoActiveCall, style: t.textTheme.bodyMedium?.copyWith(color: t.colorScheme.onSurfaceVariant)),
                  ),
                ),
        ),
        SectionHeader(l.diagQualityRecentCalls),
        if (history.isEmpty)
          Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Text(l.diagQualityNoFinished))
        else
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              child: Column(
                children: [
                  for (var i = 0; i < history.length; i++) ...[
                    ListTile(
                      key: Key('quality-hist-$i'),
                      title: Text(bidiSafe(history[i].remoteDisplay.isNotEmpty ? history[i].remoteDisplay : history[i].remoteNumber)),
                      subtitle: Text('${dayLabel(history[i].start, context.l10n)}, ${timeLabel(history[i].start, context.l10n)}  ·  ${formatMs(history[i].durationMs)}'),
                      trailing: QualityIndicator(mos: history[i].quality.mosAvg),
                      onTap: () => showCallQualitySheet(context, history[i]),
                    ),
                    if (i != history.length - 1) const Divider(height: 1, indent: 16),
                  ],
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// Live quality sheet for an ongoing call (in-call "More" menu).
Future<void> showLiveQuality(BuildContext context, int cid) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    constraints: const BoxConstraints(maxWidth: 560),
    builder: (_) => Consumer(
      builder: (context, ref, _) {
        final c = ref.watch(callsProvider).byCid(cid);
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: c == null
              ? Text(context.l10n.diagQualityCallEnded)
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(context.l10n.diagQualityTitle, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 12),
                    QualityPanel(samples: c.samples, stats: c.stats),
                  ],
                ),
        );
      },
    ),
  );
}
