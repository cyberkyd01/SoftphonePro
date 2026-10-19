import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/format.dart';
import '../../core/theme.dart';
import '../../services/accounts_controller.dart';
import '../../services/calls_controller.dart';
import '../../services/contacts_controller.dart';
import '../../services/history_controller.dart';
import '../../services/providers.dart';
import '../widgets/basic_widgets.dart';
import '../widgets/settings_tiles.dart';
import 'keypad_page.dart';
import 'recents_page.dart';

class LanPage extends StatelessWidget {
  const LanPage({super.key});
  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Column(
      children: [
        const PageHeader(title: 'LAN Link'),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: t.colorScheme.primary.withValues(alpha: 0.1)),
                      child: Icon(Icons.lan_rounded, size: 44, color: t.colorScheme.primary),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(color: t.colorScheme.primary.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(999)),
                      child: Text('Coming soon', style: t.textTheme.labelLarge?.copyWith(color: t.colorScheme.primary, fontWeight: FontWeight.w700)),
                    ),
                    const SizedBox(height: 12),
                    Text('Your devices, talking directly', style: t.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700), textAlign: TextAlign.center),
                    const SizedBox(height: 8),
                    Text(
                      'LAN Link finds SoftphonePro on your other devices and lets them work together without any server.',
                      style: t.textTheme.bodyMedium?.copyWith(color: t.colorScheme.onSurfaceVariant),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    const SettingsGroup(
                      children: [
                        ListTile(leading: Icon(Icons.radar_rounded), title: Text('Automatic discovery'), subtitle: Text('Secure pairing with a 6-digit code')),
                        ListTile(leading: Icon(Icons.chat_rounded), title: Text('LAN chat and file drop')),
                        ListTile(leading: Icon(Icons.call_rounded), title: Text('Direct calls and intercom')),
                        ListTile(leading: Icon(Icons.swap_horiz_rounded), title: Text('Hand off any call to another device')),
                      ],
                    ),
                    const SizedBox(height: 20),
                    OutlinedButton.icon(
                      onPressed: () => context.push('/settings/lan'),
                      icon: const Icon(Icons.tune_rounded),
                      label: const Text('LAN settings'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// "More" menu on compact layouts.
class MorePage extends ConsumerWidget {
  const MorePage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final acc = ref.watch(accountsProvider);
    final vm = acc.newVoicemail;
    return ListView(
      children: [
        const PageHeader(title: 'More'),
        const SizedBox(height: 8),
        SettingsGroup(
          children: [
            NavTile(icon: Icons.grid_view_rounded, title: 'Presence', subtitle: 'Busy lamp field', onTap: () => context.go('/presence')),
            NavTile(icon: Icons.lan_rounded, title: 'LAN Link', subtitle: 'Coming soon', onTap: () => context.go('/lan')),
            NavTile(
              icon: Icons.voicemail_rounded,
              title: 'Voicemail',
              subtitle: vm > 0 ? '$vm new message${vm == 1 ? '' : 's'}' : 'Dial your voicemail',
              trailing: vm > 0 ? Badge.count(count: vm) : const Icon(Icons.chevron_right_rounded),
              onTap: () => dialVoicemail(context, ref),
            ),
          ],
        ),
        SettingsGroup(
          children: [
            NavTile(icon: Icons.settings_rounded, title: 'Settings', onTap: () => context.go('/settings')),
            NavTile(icon: Icons.monitor_heart_rounded, title: 'Diagnostics', subtitle: 'SIP trace and network checks', onTap: () => context.push('/settings/diagnostics')),
            NavTile(icon: Icons.info_outline_rounded, title: 'About', onTap: () => context.push('/settings/about')),
          ],
        ),
      ],
    );
  }
}

/// Dials the voicemail number of the chosen account (or lets the user pick).
Future<void> dialVoicemail(BuildContext context, WidgetRef ref) async {
  final acc = ref.read(accountsProvider);
  final withVm = acc.enabled.where((p) => p.effectiveVoicemail.isNotEmpty).toList();
  if (withVm.isEmpty) {
    ref.read(noticeProvider.notifier).show('No voicemail number is set. Add one in the account settings.');
    return;
  }
  var target = withVm.firstWhere((p) => (acc.mwi[p.id]?.newMsgs ?? 0) > 0, orElse: () => withVm.first);
  if (withVm.length > 1 && !withVm.any((p) => (acc.mwi[p.id]?.newMsgs ?? 0) > 0)) {
    final id = await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final p in withVm)
              ListTile(leading: const Icon(Icons.voicemail_rounded), title: Text(p.name), subtitle: Text(p.effectiveVoicemail), onTap: () => Navigator.pop(ctx, p.id)),
          ],
        ),
      ),
    );
    if (id == null) return;
    target = withVm.firstWhere((p) => p.id == id);
  }
  await ref.read(callsProvider.notifier).dial(target.effectiveVoicemail, accountId: target.id, applyRules: false);
}

// ---------------------------------------------------------------------------

Future<void> showGlobalSearch(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (_) => Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 48),
      child: ConstrainedBox(constraints: BoxConstraints(maxWidth: 560, maxHeight: 560), child: _SearchBody()),
    ),
  );
}

class _SearchBody extends ConsumerStatefulWidget {
  const _SearchBody();
  @override
  ConsumerState<_SearchBody> createState() => _SearchBodyState();
}

class _SearchBodyState extends ConsumerState<_SearchBody> {
  final _ctl = TextEditingController();
  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final q = _ctl.text.trim();
    final contacts = ref.watch(contactsProvider);
    final history = ref.watch(historyProvider);
    final sugg = buildSuggestions(q, contacts, history, limit: 12);
    final calls = ref.read(callsProvider.notifier);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            key: const Key('global-search'),
            controller: _ctl,
            autofocus: true,
            onChanged: (_) => setState(() {}),
            onSubmitted: (v) {
              if (v.trim().isEmpty) return;
              Navigator.pop(context);
              calls.dial(v.trim());
            },
            decoration: const InputDecoration(hintText: 'Search contacts, history or type a number', prefixIcon: Icon(Icons.search_rounded)),
          ),
        ),
        Flexible(
          child: ListView(
            shrinkWrap: true,
            children: [
              if (q.isNotEmpty)
                ListTile(
                  leading: CircleAvatar(backgroundColor: context.colors.callGreen, child: const Icon(Icons.call_rounded, color: Colors.white)),
                  title: Text('Call $q'),
                  onTap: () {
                    Navigator.pop(context);
                    calls.dial(q);
                  },
                ),
              for (final s in sugg)
                ListTile(
                  leading: Avatar(name: s.name.isEmpty ? s.number : s.name),
                  title: Text(s.name.isEmpty ? s.number : s.name),
                  subtitle: s.name.isEmpty ? null : Text(s.number),
                  trailing: s.contact == null ? const Icon(Icons.history_rounded, size: 18) : const Icon(Icons.person_rounded, size: 18),
                  onTap: () {
                    Navigator.pop(context);
                    if (s.contact != null) {
                      context.go('/contacts');
                      context.push('/contacts/${s.contact!.id}');
                    } else {
                      context.push('/recents/detail?n=${Uri.encodeQueryComponent(s.number)}');
                    }
                  },
                ),
              if (q.isEmpty)
                for (final r in history.take(6))
                  ListTile(
                    leading: Avatar(name: recordTitle(r, contacts)),
                    title: Text(recordTitle(r, contacts)),
                    subtitle: Text('${dayLabel(r.start)}, ${timeLabel(r.start)}'),
                    onTap: () {
                      Navigator.pop(context);
                      calls.dial(r.remoteNumber);
                    },
                  ),
            ],
          ),
        ),
      ],
    );
  }
}
