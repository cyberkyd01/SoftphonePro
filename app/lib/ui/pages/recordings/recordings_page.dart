import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/format.dart';
import '../../../core/theme.dart';
import '../../../l10n/l10n.dart';
import '../../../models/call_record.dart';
import '../../../models/chat.dart';
import '../../../recordings/recording_exporter.dart';
import '../../../recordings/recording_filter.dart';
import '../../../recordings/recording_formats.dart';
import '../../../recordings/recordings_controller.dart';
import '../../../services/accounts_controller.dart';
import '../../../services/contacts_controller.dart';
import '../../../services/providers.dart';
import '../../../services/settings_controller.dart';
import '../../widgets/basic_widgets.dart';
import '../../widgets/recording_player.dart';
import '../../widgets/settings_tiles.dart';

/// The recordings manager: list by day, search and filters, player, rename,
/// delete, export / share, storage summary.
class RecordingsPage extends ConsumerStatefulWidget {
  const RecordingsPage({super.key, this.focusId});

  /// Recording to open when the page is shown (link from the history).
  final String? focusId;

  @override
  ConsumerState<RecordingsPage> createState() => _RecordingsPageState();
}

class _RecordingsPageState extends ConsumerState<RecordingsPage> {
  bool _search = false;
  bool _selecting = false;
  final Set<String> _selected = {};
  String? _open;

  @override
  void initState() {
    super.initState();
    _open = widget.focusId;
  }

  @override
  void didUpdateWidget(RecordingsPage old) {
    super.didUpdateWidget(old);
    if (widget.focusId != old.focusId && widget.focusId != null) _open = widget.focusId;
  }

  void _exitSelect() => setState(() {
    _selecting = false;
    _selected.clear();
  });

  Future<void> _deleteSelected(List<RecordingMeta> all) async {
    final ids = _selected.toList();
    if (ids.isEmpty) return;
    final ok = await confirm(
      context,
      title: context.l10n.recDeleteManyTitle(ids.length),
      message: context.l10n.recDeleteManyMessage,
    );
    if (!ok) return;
    await ref.read(recordingsProvider.notifier).delete(ids);
    if (mounted) _exitSelect();
  }

  Future<void> _openFolder() async {
    final s = ref.read(settingsProvider);
    try {
      final dir = s.recordingFolder.isNotEmpty ? s.recordingFolder : await ref.read(recordingsDirProvider)();
      await ref.read(recordingExporterProvider).openFolder(dir);
    } catch (e) {
      ref.read(noticeProvider.notifier).error(ref.read(l10nProvider).callErrCouldNotStartRecording, details: '$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final all = ref.watch(recordingsProvider);
    final list = ref.watch(filteredRecordingsProvider);
    final filter = ref.watch(recordingFilterProvider);
    final usage = ref.watch(recordingsUsageProvider);
    final contacts = ref.watch(contactsProvider);
    final acc = ref.watch(accountsProvider);
    final settings = ref.watch(settingsProvider);
    final t = Theme.of(context);
    final l = context.l10n;
    final fctl = ref.read(recordingFilterProvider.notifier);

    final items = <Object>[];
    String? lastDay;
    for (final m in list) {
      final d = dayLabel(m.time, l);
      if (d != lastDay) {
        items.add(d);
        lastDay = d;
      }
      items.add(m);
    }

    return Column(
      children: [
        PageHeader(
          title: _selecting ? l.recSelectedCount(_selected.length) : l.recPageTitle,
          leading: _selecting ? IconButton(tooltip: l.recCancelSelection, onPressed: _exitSelect, icon: const Icon(Icons.close_rounded)) : null,
          actions: _selecting
              ? [
                  IconButton(
                    key: const Key('rec-select-all'),
                    tooltip: l.recSelectAll,
                    onPressed: () => setState(() => _selected.addAll(list.map((m) => m.id))),
                    icon: const Icon(Icons.select_all_rounded),
                  ),
                  if (!recordingsUseDesktopExport)
                    IconButton(
                      key: const Key('rec-share-selected'),
                      tooltip: l.recShareSelected,
                      onPressed: _selected.isEmpty
                          ? null
                          : () => ref.read(recordingExporterProvider).share([for (final m in all) if (_selected.contains(m.id)) m]),
                      icon: const Icon(Icons.ios_share_rounded),
                    ),
                  IconButton(
                    key: const Key('rec-delete-selected'),
                    tooltip: l.recDeleteSelected,
                    onPressed: _selected.isEmpty ? null : () => _deleteSelected(all),
                    icon: const Icon(Icons.delete_outline_rounded),
                  ),
                ]
              : [
                  IconButton(
                    key: const Key('rec-search-toggle'),
                    tooltip: l.recSearchTooltip,
                    onPressed: () => setState(() {
                      _search = !_search;
                      if (!_search) fctl.set(filter.copyWith(query: ''));
                    }),
                    icon: Icon(_search ? Icons.search_off_rounded : Icons.search_rounded),
                  ),
                  IconButton(
                    key: const Key('rec-select-mode'),
                    tooltip: l.recSelectTooltip,
                    onPressed: all.isEmpty ? null : () => setState(() => _selecting = true),
                    icon: const Icon(Icons.checklist_rounded),
                  ),
                  PopupMenuButton<String>(
                    tooltip: l.actionMore,
                    onSelected: (v) {
                      if (v == 'folder') _openFolder();
                      if (v == 'settings') context.go('/settings/recording');
                    },
                    itemBuilder: (_) => [
                      if (recordingsUseDesktopExport) PopupMenuItem(value: 'folder', child: Text(l.recSettingsOpenFolder)),
                      PopupMenuItem(value: 'settings', child: Text(l.recMenuSettings)),
                    ],
                  ),
                ],
        ),
        if (_search)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: TextField(
              key: const Key('rec-search'),
              autofocus: true,
              onChanged: (v) => fctl.set(filter.copyWith(query: v)),
              decoration: InputDecoration(hintText: l.recSearchHint, prefixIcon: const Icon(Icons.search_rounded)),
            ),
          ),
        _FilterBar(accounts: acc.profiles.map((p) => (p.id, p.name)).toList()),
        Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 4),
          child: Row(
            children: [
              Icon(Icons.storage_rounded, size: 16, color: t.colorScheme.onSurfaceVariant),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  settings.recordAutoDeleteDays > 0
                      ? l.recUsageSummaryAutoDelete(usage.count, formatBytes(usage.bytes), settings.recordAutoDeleteDays)
                      : l.recUsageSummary(usage.count, formatBytes(usage.bytes)),
                  key: const Key('rec-usage'),
                  style: t.textTheme.bodySmall?.copyWith(color: t.colorScheme.onSurfaceVariant),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: list.isEmpty
              ? EmptyState(
                  icon: Icons.graphic_eq_rounded,
                  title: all.isEmpty ? l.recEmptyNone : l.recEmptyNoMatch,
                  subtitle: all.isEmpty
                      ? l.recEmptyNoneHint
                      : l.recEmptyNoMatchHint,
                  actionLabel: all.isEmpty ? l.recMenuSettings : l.recClearFilters,
                  onAction: () => all.isEmpty ? context.go('/settings/recording') : fctl.set(const RecordingFilter()),
                )
              : ListView.builder(
                  padding: const EdgeInsetsDirectional.only(bottom: 24),
                  itemCount: items.length,
                  itemBuilder: (context, i) {
                    final it = items[i];
                    if (it is String) return SectionHeader(it, padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 4));
                    final m = it as RecordingMeta;
                    return RecordingTile(
                      key: ValueKey('rec-${m.id}'),
                      meta: m,
                      title: recordingTitle(m, contacts, l),
                      accountName: acc.byId(m.accountId)?.name ?? '',
                      expanded: _open == m.id && !_selecting,
                      selecting: _selecting,
                      selected: _selected.contains(m.id),
                      onTap: () => setState(() {
                        if (_selecting) {
                          _selected.contains(m.id) ? _selected.remove(m.id) : _selected.add(m.id);
                        } else {
                          _open = _open == m.id ? null : m.id;
                        }
                      }),
                      onLongPress: () => setState(() {
                        _selecting = true;
                        _selected.add(m.id);
                      }),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _FilterBar extends ConsumerWidget {
  const _FilterBar({required this.accounts});
  final List<(String, String)> accounts;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final f = ref.watch(recordingFilterProvider);
    final ctl = ref.read(recordingFilterProvider.notifier);
    final l = context.l10n;
    final range = f.range;
    final fmt = DateFormat.MMMd(Localizations.localeOf(context).toString());
    return SizedBox(
      height: 52,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        children: [
          for (final (id, label, dir) in [
            ('All', l.recFilterAll, null),
            ('Incoming', l.recFilterIncoming, CallDirection.incoming),
            ('Outgoing', l.recFilterOutgoing, CallDirection.outgoing),
          ])
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 8),
              child: ChoiceChip(
                key: Key('rec-dir-$id'),
                label: Text(label),
                selected: f.direction == dir,
                onSelected: (_) => ctl.set(f.copyWith(direction: dir)),
              ),
            ),
          if (accounts.length > 1)
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 8),
              child: PopupMenuButton<String>(
                key: const Key('rec-account-filter'),
                tooltip: l.recFilterByAccount,
                onSelected: (id) => ctl.set(f.copyWith(accountId: id.isEmpty ? null : id)),
                itemBuilder: (_) => [
                  PopupMenuItem(value: '', child: Text(l.recFilterAllAccounts)),
                  for (final a in accounts) PopupMenuItem(value: a.$1, child: Text(a.$2)),
                ],
                child: Chip(
                  avatar: const Icon(Icons.dns_rounded, size: 16),
                  label: Text(f.accountId == null ? l.recFilterAllAccounts : accounts.firstWhere((a) => a.$1 == f.accountId, orElse: () => ('', l.recFilterAccountFallback)).$2),
                ),
              ),
            ),
          ActionChip(
            key: const Key('rec-date-filter'),
            avatar: const Icon(Icons.date_range_rounded, size: 16),
            label: Text(range == null ? l.recFilterAnyDate : l.recFilterDateRange(fmt.format(range.start), fmt.format(range.end))),
            onPressed: () async {
              final now = DateTime.now();
              final r = await showDateRangePicker(
                context: context,
                firstDate: DateTime(now.year - 5),
                lastDate: DateTime(now.year + 1),
                initialDateRange: range,
              );
              if (r != null) ctl.set(f.copyWith(range: r));
            },
          ),
          if (range != null)
            Padding(
              padding: const EdgeInsetsDirectional.only(start: 8),
              child: ActionChip(
                key: const Key('rec-date-clear'),
                avatar: const Icon(Icons.close_rounded, size: 16),
                label: Text(l.recFilterClearDates),
                onPressed: () => ctl.set(f.copyWith(range: null)),
              ),
            ),
        ],
      ),
    );
  }
}

/// One recording: summary row, expandable into player and actions.
class RecordingTile extends ConsumerWidget {
  const RecordingTile({
    super.key,
    required this.meta,
    required this.title,
    required this.accountName,
    required this.expanded,
    required this.selecting,
    required this.selected,
    required this.onTap,
    required this.onLongPress,
  });
  final RecordingMeta meta;
  final String title;
  final String accountName;
  final bool expanded;
  final bool selecting;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Theme.of(context);
    final l = context.l10n;
    final colors = context.colors;
    final m = meta;
    final exists = File(m.path).existsSync();
    final size = recordingBytes(m);
    final sub = [
      if (title != m.remote && m.remote.isNotEmpty) m.remote,
      if (accountName.isNotEmpty) accountName,
      formatMs(m.durationMs),
      if (size > 0) formatBytes(size),
    ].join('  ·  ');
    return Column(
      children: [
        ListTile(
          selected: selected,
          selectedTileColor: t.colorScheme.primary.withValues(alpha: 0.08),
          leading: selecting
              ? Checkbox(value: selected, onChanged: (_) => onTap())
              : Avatar(name: title, size: 40),
          title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Row(
            children: [
              Icon(m.outgoing ? Icons.call_made_rounded : Icons.call_received_rounded, size: 15, color: t.colorScheme.onSurfaceVariant),
              const SizedBox(width: 4),
              Flexible(child: Text(sub, maxLines: 1, overflow: TextOverflow.ellipsis, style: tabular(t.textTheme.bodySmall))),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!exists) Icon(Icons.error_outline_rounded, size: 18, color: colors.endRed),
              Container(
                key: Key('rec-badge-${m.id}'),
                margin: const EdgeInsetsDirectional.only(end: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: t.colorScheme.surfaceContainerHigh, borderRadius: BorderRadius.circular(999)),
                child: Text(recordFormatBadge(m.format), style: t.textTheme.labelSmall),
              ),
              Text(timeLabel(m.time, l), style: t.textTheme.bodySmall),
            ],
          ),
          onTap: onTap,
          onLongPress: onLongPress,
        ),
        if (expanded)
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
            child: Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (exists)
                      RecordingPlayer(path: m.path, format: m.format, knownDuration: Duration(milliseconds: m.durationMs))
                    else
                      Text(l.recMissingFile, key: const Key('rec-missing'), style: TextStyle(color: colors.endRed)),
                    _RelatedLinks(meta: m),
                    RecordingActions(meta: m, exists: exists),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Links to the related recordings of transfer legs.
class _RelatedLinks extends ConsumerWidget {
  const _RelatedLinks({required this.meta});
  final RecordingMeta meta;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (meta.relatedIds.isEmpty) return const SizedBox.shrink();
    final all = ref.watch(recordingsProvider);
    final contacts = ref.watch(contactsProvider);
    final rel = [for (final id in meta.relatedIds) all.where((m) => m.id == id).firstOrNull].whereType<RecordingMeta>().toList();
    if (rel.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsetsDirectional.only(top: 4),
      child: Wrap(
        spacing: 8,
        children: [
          for (final r in rel)
            ActionChip(
              key: Key('rec-related-${r.id}'),
              avatar: const Icon(Icons.link_rounded, size: 16),
              label: Text(context.l10n.recRelated(recordingTitle(r, contacts, context.l10n))),
              onPressed: () => context.go('/recordings?id=${r.id}'),
            ),
        ],
      ),
    );
  }
}

/// Rename, export / share, show in folder, view call, delete.
class RecordingActions extends ConsumerWidget {
  const RecordingActions({super.key, required this.meta, required this.exists});
  final RecordingMeta meta;
  final bool exists;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final m = meta;
    final desktop = recordingsUseDesktopExport;
    final exporter = ref.read(recordingExporterProvider);
    final notices = ref.read(noticeProvider.notifier);
    return Wrap(
      spacing: 4,
      children: [
        TextButton.icon(
          key: const Key('rec-rename'),
          onPressed: () async {
            final title = await promptText(
              context,
              title: l.recRenameTitle,
              initial: m.title.isNotEmpty ? m.title : (m.remoteName.isNotEmpty ? m.remoteName : m.remote),
              hint: l.recRenameHint,
            );
            if (title != null) await ref.read(recordingsProvider.notifier).rename(m.id, title);
          },
          icon: const Icon(Icons.edit_rounded, size: 18),
          label: Text(l.actionRename),
        ),
        if (desktop) ...[
          TextButton.icon(
            key: const Key('rec-save-as'),
            onPressed: exists
                ? () async {
                    try {
                      final dest = await exporter.saveAs(m);
                      if (dest != null) notices.show(l.recSavedTo(dest));
                    } catch (e) {
                      notices.error(l.recSaveFailed, details: '$e');
                    }
                  }
                : null,
            icon: const Icon(Icons.save_alt_rounded, size: 18),
            label: Text(l.recSaveAs),
          ),
          TextButton.icon(
            key: const Key('rec-reveal'),
            onPressed: exists ? () => exporter.reveal(m.path) : null,
            icon: const Icon(Icons.folder_open_rounded, size: 18),
            label: Text(Platform.isMacOS ? l.recShowInFinder : l.recShowInFolder),
          ),
        ] else
          TextButton.icon(
            key: const Key('rec-share'),
            onPressed: exists
                ? () async {
                    try {
                      await exporter.share([m]);
                    } catch (e) {
                      notices.error(l.recShareFailed, details: '$e');
                    }
                  }
                : null,
            icon: const Icon(Icons.ios_share_rounded, size: 18),
            label: Text(l.actionShare),
          ),
        if (m.remote.isNotEmpty)
          TextButton.icon(
            key: const Key('rec-view-call'),
            onPressed: () => context.push('/recents/detail?n=${Uri.encodeQueryComponent(m.remote)}'),
            icon: const Icon(Icons.history_rounded, size: 18),
            label: Text(l.recViewCall),
          ),
        TextButton.icon(
          key: const Key('rec-delete'),
          style: TextButton.styleFrom(foregroundColor: context.colors.endRed),
          onPressed: () async {
            final ok = await confirm(
              context,
              title: l.recDeleteOneTitle,
              message: l.recDeleteOneMessage,
            );
            if (ok) await ref.read(recordingsProvider.notifier).delete([m.id]);
          },
          icon: const Icon(Icons.delete_outline_rounded, size: 18),
          label: Text(l.actionDelete),
        ),
      ],
    );
  }
}
