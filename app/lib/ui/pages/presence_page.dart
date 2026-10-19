import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/format.dart';
import '../../core/theme.dart';
import '../../models/contact.dart';
import '../../services/calls_controller.dart';
import '../../services/contacts_controller.dart';
import '../../services/presence_controller.dart';
import '../widgets/basic_widgets.dart';

String lampText(LampState s) => switch (s) {
  LampState.idle => 'Available',
  LampState.ringing => 'Ringing',
  LampState.busy => 'On a call',
  LampState.offline => 'Offline',
  LampState.unknown => 'Unknown',
};

class PresencePage extends ConsumerWidget {
  const PresencePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contacts = ref.watch(contactsProvider).where((c) => c.blf).toList();
    final presence = ref.watch(presenceProvider);
    return Column(
      children: [
        PageHeader(
          title: 'Presence',
          subtitle: 'Busy lamp field',
          actions: [
            IconButton(tooltip: 'Choose contacts to watch', onPressed: () => context.go('/contacts'), icon: const Icon(Icons.group_add_rounded)),
          ],
        ),
        Expanded(
          child: contacts.isEmpty
              ? EmptyState(
                  icon: Icons.grid_view_rounded,
                  title: 'No extensions on the board',
                  subtitle: 'Turn on "Show on BLF board" for a contact to see when they are free, ringing or busy.',
                  actionLabel: 'Open contacts',
                  onAction: () => context.go('/contacts'),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 200, mainAxisExtent: 148, crossAxisSpacing: 12, mainAxisSpacing: 12),
                  itemCount: contacts.length,
                  itemBuilder: (context, i) => _BlfTile(contact: contacts[i], lamp: presence.lampOf(contacts[i].id)),
                ),
        ),
      ],
    );
  }
}

class _BlfTile extends ConsumerWidget {
  const _BlfTile({required this.contact, required this.lamp});
  final Contact contact;
  final LampState lamp;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Theme.of(context);
    final colors = context.colors;
    final lampColor = switch (lamp) {
      LampState.idle => colors.regOk,
      LampState.ringing => colors.regWarn,
      LampState.busy => colors.regFail,
      _ => colors.disabled,
    };
    return Semantics(
      button: true,
      label: '${contact.displayName}, ${lampText(lamp)}. Tap to call, long press for more',
      excludeSemantics: true,
      child: Material(
        color: colors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kRadius),
          side: BorderSide(color: lamp == LampState.ringing ? lampColor : t.colorScheme.outlineVariant, width: lamp == LampState.ringing ? 2 : 1),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(kRadius),
          onTap: () => ref.read(callsProvider.notifier).dial(contact.primary),
          onLongPress: () => _menu(context, ref),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Avatar(name: contact.displayName, size: 52, color: Color(contact.avatarColor), lamp: lamp),
                const SizedBox(height: 8),
                Text(contact.displayName, maxLines: 1, overflow: TextOverflow.ellipsis, style: t.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    StatusDot(color: lampColor, size: 8, pulse: lamp == LampState.ringing),
                    const SizedBox(width: 6),
                    Text(lampText(lamp), style: t.textTheme.bodySmall),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _menu(BuildContext context, WidgetRef ref) {
    final calls = ref.read(callsProvider.notifier);
    final active = ref.read(callsProvider).focused;
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.call_rounded),
              title: Text('Call ${contact.displayName}'),
              onTap: () {
                Navigator.pop(ctx);
                calls.dial(contact.primary);
              },
            ),
            ListTile(
              leading: const Icon(Icons.pan_tool_alt_rounded),
              title: const Text('Pick up this extension'),
              subtitle: const Text('Answer their ringing call (directed pickup)'),
              enabled: lamp == LampState.ringing || lamp == LampState.unknown,
              onTap: () {
                Navigator.pop(ctx);
                calls.pickup(extension: userPart(contact.primary));
              },
            ),
            ListTile(
              leading: const Icon(Icons.phone_forwarded_rounded),
              title: const Text('Transfer current call here'),
              enabled: active != null && active.isConfirmed,
              onTap: () {
                Navigator.pop(ctx);
                if (active != null) calls.transferBlind(active.cid, contact.primary);
              },
            ),
            ListTile(
              leading: const Icon(Icons.visibility_off_rounded),
              title: const Text('Remove from board'),
              onTap: () {
                Navigator.pop(ctx);
                ref.read(contactsProvider.notifier).save(contact.copyWith(blf: false));
              },
            ),
          ],
        ),
      ),
    );
  }
}
