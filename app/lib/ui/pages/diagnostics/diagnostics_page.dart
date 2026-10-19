import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/l10n.dart';
import 'audio_view.dart';
import 'logs_view.dart';
import 'overview_view.dart';
import 'quality_view.dart';
import 'trace_view.dart';
import 'wizard_view.dart';

/// The Diagnostics area: SIP trace, network wizard, call quality, audio test,
/// logs and system info. Plugged into Settings through
/// `diagnosticsPageBuilderProvider`.
class DiagnosticsPage extends ConsumerWidget {
  const DiagnosticsPage({super.key, this.initialTab});
  final int? initialTab;

  static List<(IconData, String)> tabs(AppLocalizations l) => [
    (Icons.account_tree_outlined, l.diagTabSipTrace),
    (Icons.network_check_rounded, l.diagTabNetwork),
    (Icons.graphic_eq_rounded, l.diagTabQuality),
    (Icons.mic_rounded, l.diagTabAudioTest),
    (Icons.receipt_long_rounded, l.diagTabLogs),
    (Icons.info_outline_rounded, l.diagTabSystem),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final start = initialTab ?? 0;
    final tabs = DiagnosticsPage.tabs(context.l10n);
    return DefaultTabController(
      length: tabs.length,
      initialIndex: start,
      child: Column(
        children: [
          TabBar(
            key: const Key('diag-tabs'),
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: [for (final t in tabs) Tab(icon: Icon(t.$1, size: 20), text: t.$2, height: 56)],
          ),
          const Divider(height: 1),
          const Expanded(
            child: TabBarView(
              children: [SipTraceView(), WizardView(), QualityView(), AudioTestView(), LogsView(), OverviewView()],
            ),
          ),
        ],
      ),
    );
  }
}
