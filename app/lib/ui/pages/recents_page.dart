import 'diagnostics/quality_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/format.dart';
import '../../core/theme.dart';
import '../../models/call_record.dart';
import '../../models/contact.dart';
import '../../services/accounts_controller.dart';
import '../../services/calls_controller.dart';
import '../../services/contacts_controller.dart';
import '../../services/history_controller.dart';
import '../../services/providers.dart';
import '../../services/settings_controller.dart';
import '../widgets/basic_widgets.dart';
import '../../recordings/recording_filter.dart';
import '../../recordings/recording_formats.dart';
import '../../recordings/recordings_controller.dart';
import '../widgets/caller_identity_block.dart';
import '../widgets/recording_player.dart';
import '../widgets/settings_tiles.dart';

IconData directionIcon(CallRecord r) {
  if (r.isMissed) return Icons.call_missed_rounded;
  if (r.result == CallResult.rejected && r.direction == CallDirection.incoming) return Icons.call_missed_outgoing_rounded;
  return r.direction == CallDirection.incoming ? Icons.call_received_rounded : Icons.call_made_rounded;
}

String durationLabel(CallRecord r) {
  if (r.result == CallResult.answered || r.result == CallResult.transferred || r.result == CallResult.handedOff || (r.result == CallResult.interrupted && r.durationMs > 0)) {
    return formatMs(r.durationMs);
  }
  return r.result.label;
}

String recordTitle(CallRecord r, List<Contact> contacts) {
  final c = findContact(contacts, r.remoteNumber);
  if (c != null) return c.displayName;
  if (r.remoteDisplay.isNotEmpty) return r.remoteDisplay;
  return r.remoteNumber.isEmpty ? 'Unknown' : r.remoteNumber;
}

class RecentsPage extends ConsumerStatefulWidget {
  const RecentsPage({super.key});
  @override
  ConsumerState<RecentsPage> createState() => _RecentsPageState();
}

class _RecentsPageState extends ConsumerState<RecentsPage> {
  String? _selected;
  bool _search = false;

  @override
  Widget build(BuildContext context) {
    final list = ref.watch(filteredHistoryProvider);
    final all = ref.watch(historyProvider);
    final filter = ref.watch(historyFilterProvider);
    final contacts = ref.watch(contactsProvider);
    final acc = ref.watch(accountsProvider);
    final expanded = context.isExpanded;

    final listPane = Column(
      children: [
        PageHeader(
          title: 'Recents',
          actions: [
            IconButton(
              tooltip: 'Search history',
              onPressed: () => setState(() => _search = !_search),
              icon: Icon(_search ? Icons.search_off_rounded : Icons.search_rounded),
            ),
            PopupMenuButton<String>(
              tooltip: 'More',
              onSelected: (v) async {
                if (v == 'clear') {
                  if (await confirm(context, title: 'Clear call history?', message: 'All ${all.length} entries will be deleted.', confirmLabel: 'Clear')) {
                    await ref.read(historyProvider.notifier).clear();
                  }
                } else if (v == 'export') {
                  await Clipboard.setData(ClipboardData(text: ref.read(historyProvider.notifier).exportCsv()));
                  if (context.mounted) ref.read(noticeProvider.notifier).show('History copied to clipboard as CSV');
                }
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'export', child: Text('Copy as CSV')),
                PopupMenuItem(value: 'clear', child: Text('Clear history')),
              ],
            ),
          ],
        ),
        if (_search)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
            child: TextField(
              autofocus: true,
              onChanged: (v) => ref.read(historyFilterProvider.notifier).set(filter.copyWith(query: v)),
              decoration: const InputDecoration(hintText: 'Search name or number', prefixIcon: Icon(Icons.search_rounded)),
            ),
          ),
        SizedBox(
          height: 52,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            children: [
              for (final k in HistoryKind.values)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(switch (k) {
                      HistoryKind.all => 'All',
                      HistoryKind.missed => 'Missed',
                      HistoryKind.incoming => 'Incoming',
                      HistoryKind.outgoing => 'Outgoing',
                    }),
                    selected: filter.kind == k,
                    onSelected: (_) => ref.read(historyFilterProvider.notifier).set(filter.copyWith(kind: k)),
                  ),
                ),
              if (acc.profiles.length > 1)
                PopupMenuButton<String?>(
                  tooltip: 'Filter by account',
                  onSelected: (id) => ref.read(historyFilterProvider.notifier).set(filter.copyWith(accountId: id == '' ? null : id)),
                  itemBuilder: (_) => [
                    const PopupMenuItem(value: '', child: Text('All accounts')),
                    for (final p in acc.profiles) PopupMenuItem(value: p.id, child: Text(p.name)),
                  ],
                  child: Chip(
                    avatar: const Icon(Icons.dns_rounded, size: 16),
                    label: Text(filter.accountId == null ? 'All accounts' : (acc.byId(filter.accountId!)?.name ?? 'Account')),
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: list.isEmpty
              ? EmptyState(
                  icon: Icons.history_rounded,
                  title: all.isEmpty ? 'No calls yet' : 'No matching calls',
                  subtitle: all.isEmpty ? 'Your calls will show up here.' : 'Try another filter.',
                  actionLabel: all.isEmpty ? 'Open keypad' : 'Show all',
                  onAction: () => all.isEmpty
                      ? context.go('/keypad')
                      : ref.read(historyFilterProvider.notifier).set(const HistoryFilter()),
                )
              : _HistoryList(
                  records: list,
                  contacts: contacts,
                  selectedNumber: expanded ? _selected : null,
                  onTap: (r) {
                    if (expanded) {
                      setState(() => _selected = r.remoteNumber);
                    } else {
                      context.push('/recents/detail?n=${Uri.encodeQueryComponent(r.remoteNumber)}');
                    }
                  },
                ),
        ),
      ],
    );

    if (!expanded) return listPane;
    return Row(
      children: [
        SizedBox(width: 400, child: listPane),
        VerticalDivider(width: 1, color: Theme.of(context).colorScheme.outlineVariant),
        Expanded(
          child: _selected == null
              ? const EmptyState(icon: Icons.touch_app_rounded, title: 'Select a call', subtitle: 'Details, quality and recordings appear here.')
              : RecentDetailView(number: _selected!, embedded: true),
        ),
      ],
    );
  }
}

class _HistoryList extends ConsumerWidget {
  const _HistoryList({required this.records, required this.contacts, required this.onTap, this.selectedNumber});
  final List<CallRecord> records;
  final List<Contact> contacts;
  final void Function(CallRecord) onTap;
  final String? selectedNumber;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Theme.of(context);
    final colors = context.colors;
    final items = <Object>[];
    String? lastDay;
    for (final r in records) {
      final d = dayLabel(r.start);
      if (d != lastDay) {
        items.add(d);
        lastDay = d;
      }
      items.add(r);
    }
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 16),
      itemCount: items.length,
      itemBuilder: (context, i) {
        final it = items[i];
        if (it is String) return SectionHeader(it, padding: const EdgeInsets.fromLTRB(16, 16, 16, 4));
        final r = it as CallRecord;
        final name = recordTitle(r, contacts);
        final missed = r.isMissed;
        final selected = selectedNumber != null && selectedNumber == r.remoteNumber;
        return Semantics(
          label: '${missed ? 'Missed call' : '${r.direction.name} call'} ${name == r.remoteNumber ? '' : name}, ${r.remoteNumber}, ${timeLabel(r.start)}',
          child: ListTile(
            key: ValueKey(r.id),
            selected: selected,
            selectedTileColor: t.colorScheme.primary.withValues(alpha: 0.08),
            minVerticalPadding: 8,
            leading: Avatar(name: name),
            title: Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: missed ? colors.endRed : null, fontWeight: FontWeight.w600),
            ),
            subtitle: Row(
              children: [
                Icon(directionIcon(r), size: 15, color: missed ? colors.endRed : t.colorScheme.onSurfaceVariant),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    [if (name != r.remoteNumber) r.remoteNumber, durationLabel(r)].where((e) => e.isNotEmpty).join('  ·  '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: tabular(t.textTheme.bodySmall),
                  ),
                ),
                if (r.recordingPath != null) ...[
                  const SizedBox(width: 6),
                  Icon(Icons.mic_rounded, size: 14, color: t.colorScheme.onSurfaceVariant),
                ],
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(timeLabel(r.start), style: t.textTheme.bodySmall),
                IconButton(
                  tooltip: 'Call $name',
                  icon: Icon(Icons.call_rounded, color: colors.callGreen),
                  onPressed: () => ref.read(callsProvider.notifier).dial(
                    r.remoteNumber.isEmpty ? r.remoteUri : r.remoteNumber,
                    accountId: r.accountId.isEmpty ? null : r.accountId,
                  ),
                ),
              ],
            ),
            onTap: () => onTap(r),
          ),
        );
      },
    );
  }
}

/// Details for all calls with one number.
class RecentDetailView extends ConsumerWidget {
  const RecentDetailView({super.key, required this.number, this.embedded = false});
  final String number;
  final bool embedded;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final all = ref.watch(historyProvider).where((r) => r.remoteNumber == number).toList();
    final contacts = ref.watch(contactsProvider);
    final contact = findContact(contacts, number);
    final t = Theme.of(context);
    final colors = context.colors;
    final settings = ref.watch(settingsProvider);
    final blocked = settings.blocklist.contains(number);
    final name = all.isEmpty ? number : recordTitle(all.first, contacts);
    final q = all.where((r) => !r.quality.isEmpty).toList();
    final rec = all.where((r) => r.recordingPath != null).toList();
    final recMeta = ref.watch(recordingsProvider);
    final acc = ref.watch(accountsProvider);

    final body = ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      children: [
        Column(
          children: [
            Avatar(name: name, size: 84),
            const SizedBox(height: 12),
            Text(name, style: t.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700), textAlign: TextAlign.center),
            if (name != number) Text(number, style: tabular(t.textTheme.bodyLarge?.copyWith(color: t.colorScheme.onSurfaceVariant))),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: [
                _Action(icon: Icons.call_rounded, label: 'Call', color: colors.callGreen, onTap: () => ref.read(callsProvider.notifier).dial(number)),
                _Action(
                  icon: Icons.message_rounded,
                  label: 'Message',
                  onTap: () {
                    final accId = (acc.defaultProfile?.id ?? '');
                    if (accId.isEmpty) {
                      ref.read(noticeProvider.notifier).error('Add an account to send messages');
                      return;
                    }
                    context.push('/thread?acc=$accId&peer=${Uri.encodeQueryComponent(number)}');
                  },
                ),
                if (contact != null)
                  _Action(icon: Icons.person_rounded, label: 'Contact', onTap: () => context.push('/contacts/${contact.id}'))
                else
                  _Action(icon: Icons.person_add_alt_1_rounded, label: 'Add contact', onTap: () => context.push('/contacts/new?number=${Uri.encodeQueryComponent(number)}')),
                _Action(
                  icon: blocked ? Icons.check_circle_outline_rounded : Icons.block_rounded,
                  label: blocked ? 'Unblock' : 'Block',
                  color: blocked ? null : colors.endRed,
                  onTap: () async {
                    final s = ref.read(settingsProvider.notifier);
                    if (blocked) {
                      await s.update({'blocklist': settings.blocklist.where((e) => e != number).toList()});
                    } else if (await confirm(context, title: 'Block $number?', message: 'Calls from this number will be rejected automatically.', confirmLabel: 'Block')) {
                      await s.update({'blocklist': [...settings.blocklist, number]});
                    }
                  },
                ),
              ],
            ),
          ],
        ),
        if (q.isNotEmpty) ...[
          const SectionHeader('Call quality'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  QualityIndicator(mos: q.map((r) => r.quality.mosAvg).reduce((a, b) => a + b) / q.length),
                  const Spacer(),
                  Text('Worst MOS ${q.map((r) => r.quality.mosMin).reduce((a, b) => a < b ? a : b).toStringAsFixed(1)}   ·   '
                      'Jitter ${q.map((r) => r.quality.jitterMax).reduce((a, b) => a > b ? a : b).toStringAsFixed(0)} ms   ·   '
                      'Loss ${q.map((r) => r.quality.lossPct).reduce((a, b) => a > b ? a : b).toStringAsFixed(1)} %',
                      style: t.textTheme.bodySmall),
                ],
              ),
            ),
          ),
        ],
        if (rec.isNotEmpty) ...[
          const SectionHeader('Recordings'),
          for (final r in rec)
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: Text('${dayLabel(r.start)}, ${timeLabel(r.start)}', style: t.textTheme.labelLarge)),
                        if (recordingForCall(recMeta, r) case final m?) ...[
                          Text(recordFormatBadge(m.format), style: t.textTheme.labelSmall),
                          TextButton(
                            key: Key('open-recording-${m.id}'),
                            onPressed: () => context.go('/recordings?id=${m.id}'),
                            child: const Text('Open in Recordings'),
                          ),
                        ],
                      ],
                    ),
                    RecordingPlayer(path: r.recordingPath!, format: recordingForCall(recMeta, r)?.format ?? 'wav'),
                    if (r.relatedRecordingIds.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Wrap(
                          spacing: 8,
                          children: [
                            for (final id in r.relatedRecordingIds)
                              if (recMeta.where((m) => m.id == id).firstOrNull case final rel?)
                                ActionChip(
                                  key: Key('related-recording-${rel.id}'),
                                  avatar: const Icon(Icons.link_rounded, size: 16),
                                  label: Text('Related call: ${recordingTitle(rel, contacts)}'),
                                  onPressed: () => context.go('/recordings?id=${rel.id}'),
                                ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
        ],
        const SectionHeader('History'),
        Card(
          child: Column(
            children: [
              for (var i = 0; i < all.length; i++) ...[
                ListTile(
                  leading: Icon(directionIcon(all[i]), color: all[i].isMissed ? colors.endRed : null),
                  title: Text('${all[i].direction == CallDirection.incoming ? 'Incoming' : 'Outgoing'}  ·  ${all[i].result.label}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${dayLabel(all[i].start)}, ${timeLabel(all[i].start)}'
                        '${acc.byId(all[i].accountId) != null ? '  ·  ${acc.byId(all[i].accountId)!.name}' : ''}'
                        '${all[i].sipCode >= 300 ? '  ·  SIP ${all[i].sipCode}' : ''}',
                      ),
                      RecordIdentityLines(record: all[i]),
                    ],
                  ),
                  trailing: Text(formatMs(all[i].durationMs), style: tabular(t.textTheme.bodyMedium)),
                  onTap: all[i].quality.isEmpty && all[i].callId.isEmpty ? null : () => showCallQualitySheet(context, all[i]),
                ),
                if (i != all.length - 1) const Divider(height: 1, indent: 16),
              ],
              if (all.isEmpty) const ListTile(title: Text('No calls with this number')),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Align(
          child: TextButton.icon(
            onPressed: () async {
              if (await confirm(context, title: 'Delete these calls?', message: 'Removes ${all.length} entries for $name.')) {
                for (final r in all) {
                  await ref.read(historyProvider.notifier).delete(r.id);
                }
                if (!embedded && context.mounted) context.pop();
              }
            },
            icon: const Icon(Icons.delete_outline_rounded),
            label: const Text('Delete from history'),
          ),
        ),
      ],
    );
    if (embedded) return body;
    return Scaffold(appBar: AppBar(title: const Text('Call details')), body: body);
  }
}

class _Action extends StatelessWidget {
  const _Action({required this.icon, required this.label, required this.onTap, this.color});
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;
  @override
  Widget build(BuildContext context) {
    final c = color ?? Theme.of(context).colorScheme.primary;
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: SizedBox(
          width: 72,
          child: Column(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(shape: BoxShape.circle, color: c.withValues(alpha: 0.12)),
                child: Icon(icon, color: c),
              ),
              const SizedBox(height: 6),
              Text(label, style: Theme.of(context).textTheme.labelMedium),
            ],
          ),
        ),
      ),
    );
  }
}

class RecentDetailPage extends StatelessWidget {
  const RecentDetailPage({super.key, required this.number});
  final String number;
  @override
  Widget build(BuildContext context) => RecentDetailView(number: number);
}
