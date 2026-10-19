import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme.dart';
import '../../../diagnostics/diagnostics_hub.dart';
import '../../../diagnostics/export_service.dart';
import '../../../diagnostics/redaction.dart';
import '../../../l10n/l10n.dart';
import '../../../services/settings_controller.dart';
import 'trace_style.dart';

String formatLogs(Iterable<LogLine> lines, {bool redact = true}) {
  final b = StringBuffer();
  for (final l in lines) {
    final line = '${l.time.toIso8601String()} [${l.levelName}] ${l.msg}';
    b.writeln(redact ? redactSecrets(line) : line);
  }
  return b.toString();
}

class LogsView extends ConsumerStatefulWidget {
  const LogsView({super.key});
  @override
  ConsumerState<LogsView> createState() => _LogsViewState();
}

class _LogsViewState extends ConsumerState<LogsView> {
  String _q = '';
  bool _redact = true;

  @override
  Widget build(BuildContext context) {
    ref.watch(logsProvider);
    final settings = ref.watch(settingsProvider);
    final ctl = ref.read(logsProvider.notifier);
    final t = Theme.of(context);
    final l10n = context.l10n;
    final c = context.colors;
    final q = _q.trim().toLowerCase();
    final all = ctl.lines;
    final lines = q.isEmpty ? all : all.where((l) => l.msg.toLowerCase().contains(q)).toList();
    Color lc(int level) => level <= 1 ? c.regFail : (level == 2 ? c.regWarn : t.colorScheme.onSurface);
    return Column(
      children: [
        SwitchListTile(
          key: const Key('logs-forward'),
          title: Text(l10n.diagLogsForward),
          subtitle: Text(l10n.diagLogsForwardSub),
          value: ctl.forward,
          onChanged: (v) => ctl.setForward(v),
          secondary: PopupMenuButton<String>(
            key: const Key('logs-menu'),
            icon: const Icon(Icons.more_vert_rounded),
            onSelected: (v) async {
              final ex = ref.read(diagnosticsExporterProvider);
              switch (v) {
                case 'save':
                  await ex.saveText('engine-log-${stamp()}.log', formatLogs(lines, redact: _redact));
                case 'copy':
                  await ex.copy(formatLogs(lines, redact: _redact), confirmation: l10n.diagCopiedLogs);
                case 'clear':
                  ctl.clear();
              }
            },
            itemBuilder: (_) => [
              PopupMenuItem(value: 'save', child: Text(l10n.diagSaveAsLog)),
              PopupMenuItem(value: 'copy', child: Text(l10n.actionCopy)),
              PopupMenuItem(value: 'clear', child: Text(l10n.actionClear)),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Row(
            children: [
              DropdownButton<int>(
                key: const Key('logs-level'),
                value: settings.logLevel.clamp(0, 6),
                items: [for (var i = 0; i <= 6; i++) DropdownMenuItem(value: i, child: Text(l10n.diagLogsLevel(i, LogLine.names[i])))],
                onChanged: (v) => v == null ? null : ctl.setLevel(v),
              ),
              const Spacer(),
              FilterChip(
                key: const Key('logs-redact'),
                label: Text(l10n.diagLogsRedact),
                selected: _redact,
                onSelected: (v) => setState(() => _redact = v),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: TextField(
            key: const Key('logs-search'),
            decoration: InputDecoration(
              isDense: true,
              prefixIcon: const Icon(Icons.search_rounded),
              hintText: l10n.diagLogsSearch,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onChanged: (v) => setState(() => _q = v),
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: lines.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      all.isEmpty ? (ctl.forward ? l10n.diagLogsEmpty : l10n.diagLogsForwardingOff) : l10n.diagLogsNoMatch,
                      textAlign: TextAlign.center,
                      style: t.textTheme.bodyMedium?.copyWith(color: t.colorScheme.onSurfaceVariant),
                    ),
                  ),
                )
              : ListView.builder(
                  key: const Key('logs-list'),
                  itemCount: lines.length,
                  itemBuilder: (_, i) {
                    final l = lines[lines.length - 1 - i];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                      child: SelectableText(
                        '${clockLabel(l.time)} ${l.levelName.padRight(5)} ${l.msg}',
                        textDirection: TextDirection.ltr,
                        style: TextStyle(fontFamily: kMono, fontSize: 11.5, color: lc(l.level)),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
