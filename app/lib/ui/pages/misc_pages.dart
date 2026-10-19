import '../../core/bidi.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/format.dart';
import '../../core/theme.dart';
import '../../l10n/l10n.dart';
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
    final l = context.l10n;
    return ListView(
      children: [
        PageHeader(title: l.morePageTitle),
        const SizedBox(height: 8),
        SettingsGroup(
          children: [
            NavTile(icon: Icons.grid_view_rounded, title: l.morePresence, subtitle: l.morePresenceHint, onTap: () => context.go('/presence')),
            NavTile(key: const Key('more-retrieve-parked'), icon: Icons.local_parking_rounded, title: l.moreRetrieveParked, subtitle: l.moreRetrieveParkedHint, onTap: () => promptRetrieveParked(context, ref)),
            NavTile(icon: Icons.lan_rounded, title: l.moreLanLink, subtitle: l.moreLanLinkHint, onTap: () => context.go('/lan')),
            NavTile(key: const Key('more-recordings'), icon: Icons.graphic_eq_rounded, title: l.moreRecordings, subtitle: l.moreRecordingsHint, onTap: () => context.go('/recordings')),
            NavTile(
              icon: Icons.voicemail_rounded,
              title: l.moreVoicemail,
              subtitle: vm > 0 ? l.moreVoicemailNew(vm) : l.moreVoicemailDial,
              trailing: vm > 0 ? Badge.count(count: vm) : const Icon(Icons.chevron_right_rounded),
              onTap: () => dialVoicemail(context, ref),
            ),
          ],
        ),
        SettingsGroup(
          children: [
            NavTile(icon: Icons.settings_rounded, title: l.actionSettings, onTap: () => context.go('/settings')),
            NavTile(icon: Icons.monitor_heart_rounded, title: l.moreDiagnostics, subtitle: l.moreDiagnosticsHint, onTap: () => context.push('/settings/diagnostics')),
            NavTile(icon: Icons.info_outline_rounded, title: l.moreAbout, onTap: () => context.push('/settings/about')),
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
    ref.read(noticeProvider.notifier).show(ref.read(l10nProvider).moreNoVoicemailNumber);
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
            decoration: InputDecoration(hintText: context.l10n.moreSearchHint, prefixIcon: Icon(Icons.search_rounded)),
          ),
        ),
        Flexible(
          child: ListView(
            shrinkWrap: true,
            children: [
              if (q.isNotEmpty)
                ListTile(
                  leading: CircleAvatar(backgroundColor: context.colors.callGreen, child: const Icon(Icons.call_rounded, color: Colors.white)),
                  title: Text(context.l10n.moreCallNumber(q)),
                  onTap: () {
                    Navigator.pop(context);
                    calls.dial(q);
                  },
                ),
              for (final s in sugg)
                ListTile(
                  leading: Avatar(name: s.name.isEmpty ? s.number : s.name),
                  title: Text(bidiSafe(s.name.isEmpty ? s.number : s.name)),
                  subtitle: s.name.isEmpty ? null : Text(ltr(s.number)),
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
                    leading: Avatar(name: recordTitle(r, contacts, context.l10n)),
                    title: Text(recordTitle(r, contacts, context.l10n)),
                    subtitle: Text(context.l10n.moreRecentWhen(dayLabel(r.start, context.l10n), timeLabel(r.start, context.l10n))),
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
