import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme.dart';
import '../../services/accounts_controller.dart';
import '../../services/calls_controller.dart';
import '../../services/engine_controller.dart';
import '../../services/history_controller.dart';
import '../../services/messages_controller.dart';
import '../../services/settings_controller.dart';
import '../pages/call_pages.dart';
import '../pages/misc_pages.dart';
import '../shortcuts.dart';
import '../widgets/account_widgets.dart';
import '../widgets/basic_widgets.dart';
import '../widgets/call_widgets.dart';

class _Dest {
  const _Dest(this.path, this.label, this.icon, this.selectedIcon);
  final String path;
  final String label;
  final IconData icon;
  final IconData selectedIcon;
}

const _compact = [
  _Dest('/keypad', 'Keypad', Icons.dialpad_outlined, Icons.dialpad_rounded),
  _Dest('/recents', 'Recents', Icons.history_rounded, Icons.history_rounded),
  _Dest('/contacts', 'Contacts', Icons.people_outline_rounded, Icons.people_alt_rounded),
  _Dest('/messages', 'Messages', Icons.chat_bubble_outline_rounded, Icons.chat_bubble_rounded),
  _Dest('/more', 'More', Icons.more_horiz_rounded, Icons.more_horiz_rounded),
];

const _wide = [
  _Dest('/keypad', 'Keypad', Icons.dialpad_outlined, Icons.dialpad_rounded),
  _Dest('/recents', 'Recents', Icons.history_rounded, Icons.history_rounded),
  _Dest('/contacts', 'Contacts', Icons.people_outline_rounded, Icons.people_alt_rounded),
  _Dest('/messages', 'Messages', Icons.chat_bubble_outline_rounded, Icons.chat_bubble_rounded),
  _Dest('/presence', 'Presence', Icons.grid_view_rounded, Icons.grid_view_rounded),
  _Dest('/lan', 'LAN', Icons.lan_outlined, Icons.lan_rounded),
  _Dest('/settings', 'Settings', Icons.settings_outlined, Icons.settings_rounded),
];

int _indexFor(String loc, List<_Dest> dests, {required bool compact}) {
  for (var i = 0; i < dests.length; i++) {
    if (loc.startsWith(dests[i].path)) return i;
  }
  if (compact) return dests.length - 1; // presence/lan/settings live under More
  return 0;
}

class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.child, required this.location});
  final Widget child;
  final String location;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expanded = context.isExpanded;
    final engine = ref.watch(engineProvider);
    if (location.startsWith('/recents')) {
      Future.microtask(() => ref.read(recentsSeenProvider.notifier).markSeen());
    }
    final demo = engine.demo
        ? _DemoBanner(note: engine.note)
        : const SizedBox.shrink();
    final body = expanded ? _wideLayout(context, ref, demo) : _compactLayout(context, ref, demo);
    return AppShortcuts(child: body);
  }

  Widget _compactLayout(BuildContext context, WidgetRef ref, Widget demo) {
    final missed = ref.watch(missedCountProvider);
    final unread = ref.watch(unreadMessagesProvider);
    final idx = _indexFor(location, _compact, compact: true);
    final isTab = _compact.any((d) => location.startsWith(d.path)) ||
        location.startsWith('/presence') ||
        location.startsWith('/lan') ||
        location.startsWith('/settings');
    final showStrip = location.startsWith('/keypad') || location.startsWith('/recents') || location.startsWith('/contacts');
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            demo,
            if (showStrip) const AccountStrip(),
            Expanded(child: child),
            const CallBar(),
          ],
        ),
      ),
      bottomNavigationBar: !isTab
          ? null
          : NavigationBar(
              selectedIndex: idx,
              onDestinationSelected: (i) => context.go(_compact[i].path),
              destinations: [
                for (var i = 0; i < _compact.length; i++)
                  NavigationDestination(
                    icon: _badge(_compact[i].icon, i == 1 ? missed : (i == 3 ? unread : 0)),
                    selectedIcon: _badge(_compact[i].selectedIcon, i == 1 ? missed : (i == 3 ? unread : 0)),
                    label: _compact[i].label,
                    tooltip: _compact[i].label,
                  ),
              ],
            ),
    );
  }

  Widget _badge(IconData icon, int n) => n > 0 ? Badge.count(count: n, child: Icon(icon)) : Icon(icon);

  Widget _wideLayout(BuildContext context, WidgetRef ref, Widget demo) {
    final width = MediaQuery.sizeOf(context).width;
    final extended = width >= 1200;
    final idx = _indexFor(location, _wide, compact: false);
    final missed = ref.watch(missedCountProvider);
    final unread = ref.watch(unreadMessagesProvider);
    final hasCalls = ref.watch(callsProvider.select((s) => s.live.any((c) => !c.isRingingIn || c.waiting)));
    final t = Theme.of(context);
    return Scaffold(
      body: Stack(
        children: [
          Row(
            children: [
              NavigationRail(
                extended: extended,
                selectedIndex: idx,
                labelType: extended ? NavigationRailLabelType.none : NavigationRailLabelType.all,
                minExtendedWidth: 200,
                onDestinationSelected: (i) => context.go(_wide[i].path),
                leading: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.asset('assets/branding/icon_1024.png', width: 36, height: 36, errorBuilder: (_, __, ___) => const Icon(Icons.phone_rounded))),
                      if (extended) ...[
                        const SizedBox(width: 10),
                        Text('SoftphonePro', style: t.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                      ],
                    ],
                  ),
                ),
                trailing: Expanded(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(padding: const EdgeInsets.only(bottom: 16), child: _StatusSelector(extended: extended)),
                  ),
                ),
                destinations: [
                  for (var i = 0; i < _wide.length; i++)
                    NavigationRailDestination(
                      icon: _badge(_wide[i].icon, i == 1 ? missed : (i == 3 ? unread : 0)),
                      selectedIcon: _badge(_wide[i].selectedIcon, i == 1 ? missed : (i == 3 ? unread : 0)),
                      label: Text(_wide[i].label),
                    ),
                ],
              ),
              VerticalDivider(width: 1, color: t.colorScheme.outlineVariant),
              Expanded(
                child: Column(
                  children: [
                    demo,
                    const _TopBar(),
                    Divider(height: 1, color: t.colorScheme.outlineVariant),
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(child: child),
                          if (hasCalls) const CallsPanel(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const IncomingBanners(),
        ],
      ),
    );
  }
}

class _TopBar extends ConsumerWidget {
  const _TopBar();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final acc = ref.watch(accountsProvider);
    final t = Theme.of(context);
    final vm = acc.newVoicemail;
    final mac = Theme.of(context).platform == TargetPlatform.macOS;
    return Container(
      color: context.colors.card,
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Semantics(
                button: true,
                label: 'Search contacts, history or dial a number',
                child: InkWell(
                  borderRadius: BorderRadius.circular(kRadius),
                  onTap: () => showGlobalSearch(context),
                  child: Container(
                    height: 40,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(color: t.colorScheme.surfaceContainerHigh, borderRadius: BorderRadius.circular(kRadius)),
                    child: Row(
                      children: [
                        Icon(Icons.search_rounded, size: 20, color: t.colorScheme.onSurfaceVariant),
                        const SizedBox(width: 8),
                        Expanded(child: Text('Search or dial', style: t.textTheme.bodyMedium?.copyWith(color: t.colorScheme.onSurfaceVariant))),
                        Text(mac ? '⌘K' : 'Ctrl+K', style: t.textTheme.labelSmall?.copyWith(color: t.colorScheme.onSurfaceVariant)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 4,
            child: SizedBox(
              height: 52,
              child: acc.profiles.isEmpty
                  ? const Align(alignment: Alignment.centerRight, child: AccountStrip(padding: EdgeInsets.zero))
                  : ListView.separated(
                      scrollDirection: Axis.horizontal,
                      reverse: true,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: acc.profiles.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, i) {
                        final p = acc.profiles[acc.profiles.length - 1 - i];
                        return AccountChip(name: p.name, status: acc.statusOf(p.id), reason: acc.errorOf(p.id), onTap: () => showAccountSheet(context, p.id));
                      },
                    ),
            ),
          ),
          const SizedBox(width: 8),
          Tooltip(
            message: vm > 0 ? '$vm new voicemail${vm == 1 ? '' : 's'}. Click to call voicemail' : 'Voicemail',
            child: IconButton(
              onPressed: () => dialVoicemail(context, ref),
              icon: vm > 0 ? Badge.count(count: vm, child: const Icon(Icons.voicemail_rounded)) : const Icon(Icons.voicemail_rounded),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusSelector extends ConsumerWidget {
  const _StatusSelector({required this.extended});
  final bool extended;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(settingsProvider);
    final c = context.colors;
    final (label, color) = switch (s.globalStatus) {
      'away' => ('Away', c.holdAmber),
      'dnd' => ('Do not disturb', c.regFail),
      _ => ('Available', c.regOk),
    };
    return PopupMenuButton<String>(
      tooltip: 'Your status',
      position: PopupMenuPosition.over,
      onSelected: (v) => ref.read(settingsProvider.notifier).update({'globalStatus': v}),
      itemBuilder: (_) => [
        PopupMenuItem(value: 'available', child: Row(children: [StatusDot(color: c.regOk), const SizedBox(width: 10), const Text('Available')])),
        PopupMenuItem(value: 'away', child: Row(children: [StatusDot(color: c.holdAmber), const SizedBox(width: 10), const Text('Away')])),
        PopupMenuItem(value: 'dnd', child: Row(children: [StatusDot(color: c.regFail), const SizedBox(width: 10), const Text('Do not disturb')])),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(999), border: Border.all(color: Theme.of(context).colorScheme.outlineVariant)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            StatusDot(color: color),
            if (extended) ...[const SizedBox(width: 8), Text(label, style: Theme.of(context).textTheme.labelLarge)],
            const Icon(Icons.arrow_drop_down_rounded, size: 18),
          ],
        ),
      ),
    );
  }
}

class _DemoBanner extends ConsumerWidget {
  const _DemoBanner({this.note});
  final String? note;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Theme.of(context);
    return Material(
      color: context.colors.holdAmber.withValues(alpha: 0.16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        child: Row(
          children: [
            Icon(Icons.science_rounded, size: 16, color: context.colors.holdAmber),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Demo mode: calls are simulated, nothing reaches a real network.',
                style: t.textTheme.labelMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (note != null) Tooltip(message: note!, child: const Icon(Icons.info_outline_rounded, size: 16)),
            TextButton(
              style: TextButton.styleFrom(minimumSize: const Size(0, 28), padding: const EdgeInsets.symmetric(horizontal: 8)),
              onPressed: () => context.go('/settings/advanced'),
              child: const Text('Settings'),
            ),
          ],
        ),
      ),
    );
  }
}
