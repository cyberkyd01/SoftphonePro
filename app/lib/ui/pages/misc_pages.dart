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
import '../widgets/call_widgets.dart' show promptRetrieveParked;
import '../widgets/settings_tiles.dart';
import 'keypad_page.dart';
import 'recents_page.dart';

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
            NavTile(key: const Key('more-retrieve-parked'), icon: Icons.local_parking_rounded, title: 'Retrieve parked call', subtitle: 'Dial a park slot', onTap: () => promptRetrieveParked(context, ref)),
            NavTile(icon: Icons.lan_rounded, title: 'LAN Link', subtitle: 'Nearby devices, chat and file drop', onTap: () => context.go('/lan')),
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
