import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme.dart';
import '../../../diagnostics/export_service.dart';
import '../../../diagnostics/network_wizard.dart';
import '../../../diagnostics/system_info.dart';

class WizardView extends ConsumerWidget {
  const WizardView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final w = ref.watch(networkWizardProvider);
    final ctl = ref.read(networkWizardProvider.notifier);
    final t = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      children: [
        Text(
          'Checks your connection, DNS, NAT, server reachability, TLS and registration, and explains what to fix.',
          style: t.textTheme.bodyMedium?.copyWith(color: t.colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            if (w.running)
              OutlinedButton.icon(key: const Key('wizard-stop'), onPressed: ctl.cancel, icon: const Icon(Icons.stop_rounded), label: const Text('Stop'))
            else
              FilledButton.icon(
                key: const Key('wizard-run'),
                onPressed: ctl.run,
                icon: const Icon(Icons.play_arrow_rounded),
                label: Text(w.steps.isEmpty ? 'Run checks' : 'Run again'),
              ),
            if (w.steps.isNotEmpty && !w.running) ...[
              OutlinedButton.icon(
                key: const Key('wizard-copy'),
                onPressed: () => ref.read(diagnosticsExporterProvider).copy(_report(ref), what: 'Report'),
                icon: const Icon(Icons.copy_rounded),
                label: const Text('Copy report'),
              ),
              OutlinedButton.icon(
                key: const Key('wizard-save'),
                onPressed: () => ref.read(diagnosticsExporterProvider).saveText('network-report-${stamp()}.txt', _report(ref)),
                icon: const Icon(Icons.ios_share_rounded),
                label: const Text('Save report'),
              ),
            ],
          ],
        ),
        if (w.steps.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              _count(context, 'Passed', w.count(StepStatus.pass), context.colors.regOk),
              _count(context, 'Warnings', w.count(StepStatus.warn), context.colors.regWarn),
              _count(context, 'Failed', w.count(StepStatus.fail), context.colors.regFail),
            ],
          ),
        ],
        const SizedBox(height: 8),
        for (final s in w.steps) _StepCard(step: s, key: Key('step-${s.id}')),
      ],
    );
  }

  String _report(WidgetRef ref) {
    final info = ref.read(systemInfoProvider).asData?.value;
    return ref.read(networkWizardProvider.notifier).buildReport(header: info?.toText());
  }

  Widget _count(BuildContext context, String l, int n, Color c) =>
      Chip(visualDensity: VisualDensity.compact, avatar: CircleAvatar(backgroundColor: c, radius: 5), label: Text('$l $n'));
}

class _StepCard extends ConsumerWidget {
  const _StepCard({super.key, required this.step});
  final WizardStep step;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Theme.of(context);
    final c = context.colors;
    final (icon, color) = switch (step.status) {
      StepStatus.pass => (Icons.check_circle_rounded, c.regOk),
      StepStatus.warn => (Icons.warning_amber_rounded, c.regWarn),
      StepStatus.fail => (Icons.cancel_rounded, c.regFail),
      StepStatus.skipped => (Icons.remove_circle_outline_rounded, c.disabled),
      StepStatus.running => (Icons.hourglass_top_rounded, t.colorScheme.primary),
      StepStatus.pending => (Icons.radio_button_unchecked_rounded, c.disabled),
    };
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            step.status == StepStatus.running
                ? const SizedBox(width: 24, height: 24, child: Padding(padding: EdgeInsets.all(2), child: CircularProgressIndicator(strokeWidth: 2.5)))
                : Icon(icon, color: color, semanticLabel: step.status.name),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(step.title, style: t.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                  if (step.summary.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 2), child: Text(step.summary)),
                  for (final d in step.details)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: SelectableText(d, style: t.textTheme.bodySmall?.copyWith(color: t.colorScheme.onSurfaceVariant)),
                    ),
                  if (step.suggestion.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.lightbulb_outline_rounded, size: 18, color: color),
                          const SizedBox(width: 8),
                          Expanded(child: Text(step.suggestion, style: t.textTheme.bodySmall)),
                        ],
                      ),
                    ),
                  if (step.action != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: FilledButton.tonal(
                        key: const Key('step-action'),
                        onPressed: () => step.action!.run(),
                        child: Text(step.action!.label),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
