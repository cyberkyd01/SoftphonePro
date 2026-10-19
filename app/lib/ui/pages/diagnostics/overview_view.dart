import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../diagnostics/diagnostics_hub.dart';
import '../../../diagnostics/export_service.dart';
import '../../../diagnostics/network_wizard.dart';
import '../../../diagnostics/sip_trace_controller.dart';
import '../../../diagnostics/system_info.dart';
import '../../../diagnostics/trace_export.dart';
import '../../../l10n/l10n.dart';
import '../../../services/engine_controller.dart';
import '../../widgets/settings_tiles.dart';
import 'logs_view.dart';

/// Engine and system information plus the "export everything" action.
class OverviewView extends ConsumerWidget {
  const OverviewView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final info = ref.watch(systemInfoProvider);
    final t = Theme.of(context);
    final l = context.l10n;
    return ListView(
      padding: const EdgeInsets.only(bottom: 32),
      children: [
        info.when(
          loading: () => const Padding(padding: EdgeInsets.all(32), child: Center(child: CircularProgressIndicator())),
          error: (e, _) => Padding(padding: const EdgeInsets.all(16), child: Text(l.diagSysReadError('$e'))),
          data: (i) => Column(
            children: [
              SettingsGroup(
                title: l.diagTabSystem,
                children: [
                  for (final r in i.localizedRows(l))
                    ListTile(
                      dense: true,
                      title: Text(r.$1),
                      trailing: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 240),
                        child: Text(r.$2, textAlign: TextAlign.end, maxLines: 2, overflow: TextOverflow.ellipsis),
                      ),
                    ),
                ],
              ),
              SettingsGroup(
                title: l.diagSysTransports,
                children: [
                  if (i.transports.isEmpty) ListTile(dense: true, title: Text(l.diagSysNoneReported)),
                  for (final tr in i.transports) ListTile(dense: true, leading: const Icon(Icons.settings_ethernet_rounded), title: Text(tr)),
                ],
              ),
              SettingsGroup(
                title: l.diagSysCodecs,
                footer: i.codecs.isEmpty ? null : l.diagSysCodecsFooter,
                children: [
                  if (i.codecs.isEmpty) ListTile(dense: true, title: Text(l.diagSysEngineNotRunning)),
                  for (final c in ([...i.codecs]..sort((a, b) => b.priority.compareTo(a.priority))))
                    ListTile(
                      dense: true,
                      leading: Icon(c.enabled ? Icons.check_circle_outline_rounded : Icons.block_rounded, size: 20),
                      title: Text(c.id),
                      trailing: Text(c.enabled ? l.diagSysCodecPriority(c.priority) : l.diagSysCodecDisabled, style: t.textTheme.bodySmall),
                    ),
                ],
              ),
            ],
          ),
        ),
        SettingsGroup(
          title: l.diagSysExport,
          footer: l.diagSysExportFooter,
          children: [
            NavTile(
              key: const Key('bundle-copy'),
              icon: Icons.copy_all_rounded,
              title: l.diagSysCopyBundle,
              onTap: () => ref.read(diagnosticsExporterProvider).copy(_bundle(ref), confirmation: l.diagCopiedBundle),
              trailing: const SizedBox.shrink(),
            ),
            NavTile(
              key: const Key('bundle-save'),
              icon: Icons.ios_share_rounded,
              title: l.diagSysSaveBundle,
              onTap: () => ref.read(diagnosticsExporterProvider).saveText('softphonepro-diagnostics-${stamp()}.txt', _bundle(ref)),
              trailing: const SizedBox.shrink(),
            ),
            NavTile(
              key: const Key('info-refresh'),
              icon: Icons.refresh_rounded,
              title: l.actionRefresh,
              onTap: () => ref.invalidate(systemInfoProvider),
              trailing: const SizedBox.shrink(),
            ),
          ],
        ),
      ],
    );
  }

  String _bundle(WidgetRef ref) {
    final b = StringBuffer();
    final info = ref.read(systemInfoProvider).asData?.value;
    b.writeln('SoftphonePro diagnostic bundle ${DateTime.now().toIso8601String()}');
    b.writeln();
    if (info != null) b.writeln(info.toText());
    final wiz = ref.read(networkWizardProvider);
    if (wiz.steps.isNotEmpty) {
      b.writeln('== Network checks ==');
      b.writeln(ref.read(networkWizardProvider.notifier).buildReport());
    }
    final hub = ref.read(diagnosticsHubProvider);
    if (hub.transports.isNotEmpty) {
      b.writeln('== Transports ==');
      for (final t in hub.transports.values) {
        b.writeln('${t.transport} ${t.local} -> ${t.remote} ${t.state.wire}');
      }
      b.writeln();
    }
    final logs = ref.read(logsProvider.notifier).lines;
    b.writeln('== Engine log (last ${logs.length > 300 ? 300 : logs.length}) ==');
    b.writeln(formatLogs(logs.length > 300 ? logs.sublist(logs.length - 300) : logs));
    final fileLog = readEngineLogTail(ref.read(engineProvider.notifier).logFilePath);
    if (fileLog.isNotEmpty) {
      b.writeln('== Engine log file (logs/engine.log, tail) ==');
      b.writeln(fileLog);
    }
    final msgs = ref.read(sipTraceProvider.notifier).messages;
    b.writeln('== SIP trace (last ${msgs.length > 200 ? 200 : msgs.length}) ==');
    b.writeln(buildTraceText(msgs.length > 200 ? msgs.sublist(msgs.length - 200) : msgs));
    return b.toString();
  }
}
