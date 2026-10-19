import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

  static const tabs = [
    (Icons.account_tree_outlined, 'SIP trace'),
    (Icons.network_check_rounded, 'Network'),
    (Icons.graphic_eq_rounded, 'Quality'),
    (Icons.mic_rounded, 'Audio test'),
    (Icons.receipt_long_rounded, 'Logs'),
    (Icons.info_outline_rounded, 'System'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final start = initialTab ?? 0;
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
