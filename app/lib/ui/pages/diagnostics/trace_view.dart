import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../diagnostics/export_service.dart';
import '../../../diagnostics/sip_dialogs.dart';
import '../../../diagnostics/sip_message.dart';
import '../../../diagnostics/sip_trace_controller.dart';
import '../../../diagnostics/trace_export.dart';
import '../../../l10n/l10n.dart';
import '../../../models/account_profile.dart';
import '../../../services/accounts_controller.dart';
import '../../../services/settings_controller.dart';
import '../../widgets/basic_widgets.dart';
import 'ladder_view.dart';
import 'raw_message_view.dart';
import 'trace_style.dart';

/// Filter applied to the captured messages.
class TraceFilter {
  const TraceFilter({this.text = '', this.method, this.errorsOnly = false, this.callId, this.accountId});
  final String text;
  final String? method;
  final bool errorsOnly;
  final String? callId;
  final String? accountId;

  bool get active => text.isNotEmpty || method != null || errorsOnly || callId != null || accountId != null;

  TraceFilter copyWith({String? text, Object? method = _keep, bool? errorsOnly, Object? callId = _keep, Object? accountId = _keep}) => TraceFilter(
    text: text ?? this.text,
    method: identical(method, _keep) ? this.method : method as String?,
    errorsOnly: errorsOnly ?? this.errorsOnly,
    callId: identical(callId, _keep) ? this.callId : callId as String?,
    accountId: identical(accountId, _keep) ? this.accountId : accountId as String?,
  );
}

const Object _keep = Object();

bool matchesAccount(SipMessage m, AccountProfile p) {
  final user = p.config.username;
  final dom = p.config.domain.split(':').first;
  bool has(String uri) => user.isNotEmpty && uri.contains('$user@') && (dom.isEmpty || uri.contains(dom));
  return has(m.fromUri) || has(m.toUri) || has(m.requestUri);
}

/// Applies [f] to [all]. Pure; used by the UI and tests.
List<SipMessage> filterMessages(List<SipMessage> all, TraceFilter f, {AccountProfile? account}) {
  final q = f.text.trim().toLowerCase();
  return [
    for (final m in all)
      if ((!f.errorsOnly || m.isError) &&
          (f.method == null || m.method == f.method) &&
          (f.callId == null || m.callId == f.callId) &&
          (account == null || matchesAccount(m, account)) &&
          (q.isEmpty || m.raw.toLowerCase().contains(q)))
        m,
  ];
}

class SipTraceView extends ConsumerStatefulWidget {
  const SipTraceView({super.key});
  @override
  ConsumerState<SipTraceView> createState() => _SipTraceViewState();
}

class _SipTraceViewState extends ConsumerState<SipTraceView> {
  TraceFilter _f = const TraceFilter();
  bool _ladder = false;
  String? _ladderId;
  bool _redact = true;
  final _search = TextEditingController();

  @override
  void initState() {
    super.initState();
    final focus = ref.read(diagnosticsFocusProvider);
    if (focus != null && focus.isNotEmpty) {
      _f = _f.copyWith(callId: focus);
      _ladder = true;
      _ladderId = focus;
      Future.microtask(() => ref.read(diagnosticsFocusProvider.notifier).focus(null));
    }
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _openLadder(String callId) => setState(() {
    _ladder = true;
    _ladderId = callId;
  });

  @override
  Widget build(BuildContext context) {
    ref.watch(sipTraceProvider);
    final ctl = ref.read(sipTraceProvider.notifier);
    final enabled = ref.watch(settingsProvider.select((s) => s.sipTrace));
    final accounts = ref.watch(accountsProvider).profiles;
    final all = ctl.messages;
    final stats = ref.read(sipTraceProvider);
    final account = _f.accountId == null ? null : accounts.where((a) => a.id == _f.accountId).firstOrNull;
    final shown = filterMessages(all, _f, account: account);
    final l = context.l10n;
    final methods = {for (final m in all) if (m.isRequest && m.method.isNotEmpty) m.method}.toList()..sort();
    final t = Theme.of(context);

    return Column(
      children: [
        SwitchListTile(
          key: const Key('trace-toggle'),
          title: Text(l.diagTraceCapture),
          subtitle: Text(
            enabled
                ? (stats.dropped > 0
                      ? l.diagTraceStatsDropped(stats.count, bytesLabel(stats.bytes), stats.dropped)
                      : l.diagTraceStats(stats.count, bytesLabel(stats.bytes)))
                : l.diagTraceOffHint,
          ),
          value: enabled,
          onChanged: (v) => ctl.setEnabled(v),
          secondary: PopupMenuButton<String>(
            key: const Key('trace-menu'),
            tooltip: l.diagTraceExportOrClear,
            icon: const Icon(Icons.more_vert_rounded),
            onSelected: (v) => _menu(v, shown.isEmpty ? all : shown),
            itemBuilder: (_) => [
              PopupMenuItem(value: 'log', child: ListTile(leading: const Icon(Icons.description_outlined), title: Text(l.diagSaveAsLog), dense: true)),
              PopupMenuItem(value: 'pcap', child: ListTile(leading: const Icon(Icons.hub_outlined), title: Text(l.diagTraceSaveAsPcap), dense: true)),
              PopupMenuItem(value: 'copy', child: ListTile(leading: const Icon(Icons.copy_rounded), title: Text(l.diagTraceCopyAsText), dense: true)),
              const PopupMenuDivider(),
              PopupMenuItem(value: 'clear', child: ListTile(leading: const Icon(Icons.delete_outline_rounded), title: Text(l.actionClear), dense: true)),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
          child: TextField(
            key: const Key('trace-search'),
            controller: _search,
            decoration: InputDecoration(
              isDense: true,
              prefixIcon: const Icon(Icons.search_rounded),
              hintText: l.diagTraceSearchHint,
              suffixIcon: _f.text.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () {
                        _search.clear();
                        setState(() => _f = _f.copyWith(text: ''));
                      },
                    ),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onChanged: (v) => setState(() => _f = _f.copyWith(text: v)),
          ),
        ),
        SizedBox(
          height: 44,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            children: [
              _chip(
                FilterChip(
                  key: const Key('filter-errors'),
                  label: Text(l.diagTraceErrorsOnly),
                  selected: _f.errorsOnly,
                  onSelected: (v) => setState(() => _f = _f.copyWith(errorsOnly: v)),
                ),
              ),
              _chip(
                PopupMenuButton<String?>(
                  key: const Key('filter-method'),
                  tooltip: l.diagTraceFilterMethod,
                  onSelected: (v) => setState(() => _f = _f.copyWith(method: v == '' ? null : v)),
                  itemBuilder: (_) => [
                    PopupMenuItem(value: '', child: Text(l.diagTraceAllMethods)),
                    for (final m in methods) PopupMenuItem(value: m, child: Text(m)),
                  ],
                  child: Chip(
                    avatar: const Icon(Icons.filter_list_rounded, size: 18),
                    label: Text(_f.method ?? l.diagTraceMethod),
                  ),
                ),
              ),
              if (accounts.isNotEmpty)
                _chip(
                  PopupMenuButton<String>(
                    key: const Key('filter-account'),
                    tooltip: l.diagTraceFilterAccount,
                    onSelected: (v) => setState(() => _f = _f.copyWith(accountId: v == '' ? null : v)),
                    itemBuilder: (_) => [
                      PopupMenuItem(value: '', child: Text(l.diagTraceAllAccounts)),
                      for (final a in accounts) PopupMenuItem(value: a.id, child: Text(a.name)),
                    ],
                    child: Chip(
                      avatar: const Icon(Icons.dns_rounded, size: 18),
                      label: Text(account?.name ?? l.diagTraceAccount),
                    ),
                  ),
                ),
              if (_f.callId != null)
                _chip(
                  InputChip(
                    key: const Key('filter-callid'),
                    label: Text('Call-ID ${shortId(_f.callId!, 14)}'),
                    onDeleted: () => setState(() => _f = _f.copyWith(callId: null)),
                  ),
                ),
              _chip(
                FilterChip(
                  key: const Key('filter-redact'),
                  avatar: const Icon(Icons.visibility_off_outlined, size: 18),
                  label: Text(l.diagTraceRedact),
                  selected: _redact,
                  onSelected: (v) => setState(() => _redact = v),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
          child: SegmentedButton<bool>(
            key: const Key('trace-mode'),
            showSelectedIcon: false,
            segments: [
              ButtonSegment(value: false, icon: const Icon(Icons.list_rounded), label: Text(l.diagTraceList)),
              ButtonSegment(value: true, icon: const Icon(Icons.account_tree_outlined), label: Text(l.diagRawLadder)),
            ],
            selected: {_ladder},
            onSelectionChanged: (s) => setState(() {
              _ladder = s.first;
              if (!_ladder) _ladderId = null;
            }),
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: all.isEmpty
              ? EmptyState(
                  icon: Icons.account_tree_outlined,
                  title: enabled ? l.diagTraceWaiting : l.diagTraceOff,
                  subtitle: enabled
                      ? l.diagTraceWaitingSub
                      : l.diagTraceOffSub,
                )
              : shown.isEmpty
              ? EmptyState(icon: Icons.filter_alt_off_rounded, title: l.diagTraceNoMatch)
              : _ladder
              ? _ladderBody(shown, t)
              : _listBody(shown),
        ),
      ],
    );
  }

  Widget _chip(Widget c) => Padding(padding: const EdgeInsetsDirectional.only(end: 8), child: Center(child: c));

  Widget _listBody(List<SipMessage> shown) {
    final t = Theme.of(context);
    return ListView.builder(
      key: const Key('trace-list'),
      itemCount: shown.length,
      itemExtent: 58,
      itemBuilder: (context, i) {
        final m = shown[shown.length - 1 - i];
        final color = sipColor(m, context);
        return InkWell(
          key: Key('msg-${m.id}'),
          onTap: () => showRawMessage(context, m, redact: _redact, onLadder: m.callId.isEmpty ? null : () => _openLadder(m.callId)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: [
                Container(width: 4, height: 38, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
                const SizedBox(width: 10),
                Icon(m.outgoing ? Icons.north_east_rounded : Icons.south_west_rounded, size: 16, color: t.colorScheme.onSurfaceVariant),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        m.valid && m.isResponse && m.cseqMethod.isNotEmpty ? '${m.label}  ${m.cseqMethod}' : m.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: t.textTheme.titleSmall?.copyWith(color: color, fontWeight: FontWeight.w700),
                      ),
                      Text(
                        m.valid ? '${m.fromUri.isEmpty ? '?' : _short(m.fromUri)} → ${m.toUri.isEmpty ? _short(m.requestUri) : _short(m.toUri)}' : m.startLine,
                        textDirection: TextDirection.ltr,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: t.textTheme.bodySmall?.copyWith(color: t.colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(clockLabel(m.time), style: t.textTheme.labelSmall?.copyWith(fontFamily: kMono, fontSize: 11)),
                    Text('${m.transport} ${bytesLabel(m.size)}', style: t.textTheme.labelSmall?.copyWith(color: t.colorScheme.onSurfaceVariant, fontSize: 10)),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _short(String uri) => uri.replaceFirst(RegExp(r'^sips?:', caseSensitive: false), '');

  Widget _ladderBody(List<SipMessage> shown, ThemeData t) {
    final dialogs = groupDialogs(shown);
    SipDialog? sel;
    if (_ladderId != null) sel = dialogs.where((d) => d.callId == _ladderId).firstOrNull;
    final l = context.l10n;
    if (sel != null) {
      final d = sel;
      return Column(
        children: [
          ListTile(
            dense: true,
            leading: IconButton(
              key: const Key('ladder-back'),
              tooltip: l.diagTraceAllDialogs,
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => setState(() => _ladderId = null),
            ),
            title: Text('${d.kind}  ·  ${d.hasResponse ? d.summary : l.diagTraceNoResponse}', style: t.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
            subtitle: Text('${_short(d.from)} → ${_short(d.to)}  ·  ${l.diagTraceMessageCount(d.messages.length)}  ·  ${deltaLabel(d.duration).substring(1)}', textDirection: TextDirection.ltr, maxLines: 1, overflow: TextOverflow.ellipsis),
            trailing: IconButton(
              tooltip: l.diagTraceCopyDialog,
              icon: const Icon(Icons.copy_rounded),
              onPressed: () => ref.read(diagnosticsExporterProvider).copy(buildTraceText(d.messages, redact: _redact), confirmation: l.diagCopiedDialog),
            ),
          ),
          Expanded(
            child: LadderDiagram(
              ladder: buildLadder(d),
              onTap: (m) => showRawMessage(context, m, redact: _redact),
            ),
          ),
        ],
      );
    }
    return ListView.builder(
      key: const Key('dialog-list'),
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: dialogs.length,
      itemBuilder: (context, i) {
        final d = dialogs[dialogs.length - 1 - i];
        final color = sipColor(d.finalResponse ?? d.first, context);
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: ListTile(
            key: Key('dialog-$i'),
            onTap: () => _openLadder(d.callId),
            leading: CircleAvatar(
              backgroundColor: color.withValues(alpha: 0.15),
              child: Icon(d.hasError ? Icons.error_outline_rounded : Icons.swap_horiz_rounded, color: color),
            ),
            title: Text('${d.kind}  ·  ${d.hasResponse ? d.summary : l.diagTraceNoResponse}', style: TextStyle(fontWeight: FontWeight.w700, color: color)),
            subtitle: Text(
              '${_short(d.from)} → ${_short(d.to)}\n${clockLabel(d.start)}  ·  ${l.diagTraceMessageCount(d.messages.length)}  ·  ${d.callId.isEmpty ? l.diagTraceNoCallId : shortId(d.callId, 16)}',
              textDirection: TextDirection.ltr,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            isThreeLine: true,
            trailing: const Icon(Icons.chevron_right_rounded),
          ),
        );
      },
    );
  }

  Future<void> _menu(String v, List<SipMessage> msgs) async {
    final ctl = ref.read(sipTraceProvider.notifier);
    final ex = ref.read(diagnosticsExporterProvider);
    final l = ref.read(l10nProvider);
    switch (v) {
      case 'clear':
        ctl.clear();
      case 'log':
        await ex.saveText('sip-trace-${stamp()}.log', buildTraceText(msgs, redact: _redact));
      case 'pcap':
        await ex.saveBytes('sip-trace-${stamp()}.pcap', buildPcap(msgs, redact: _redact));
      case 'copy':
        await ex.copy(buildTraceText(msgs, redact: _redact), confirmation: l.diagCopiedTrace);
    }
  }
}
