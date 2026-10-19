import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/theme.dart';
import '../../models/account_profile.dart';
import '../../services/accounts_controller.dart';
import '../../services/calls_controller.dart';
import 'basic_widgets.dart';

/// Horizontal strip of account chips (mobile) or wrap (desktop top bar).
class AccountStrip extends ConsumerWidget {
  const AccountStrip({super.key, this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 8)});
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final acc = ref.watch(accountsProvider);
    if (acc.profiles.isEmpty) {
      return Padding(
        padding: padding,
        child: Align(
          alignment: Alignment.centerLeft,
          child: ActionChip(
            avatar: const Icon(Icons.add_rounded, size: 18),
            label: const Text('Add account'),
            onPressed: () => context.push('/account-wizard'),
          ),
        ),
      );
    }
    return SizedBox(
      height: 52,
      child: ListView.separated(
        padding: padding,
        scrollDirection: Axis.horizontal,
        itemCount: acc.profiles.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final p = acc.profiles[i];
          return AccountChip(
            name: p.name,
            status: acc.statusOf(p.id),
            reason: acc.errorOf(p.id),
            badge: (acc.mwi[p.id]?.waiting ?? false) ? acc.mwi[p.id]!.newMsgs : 0,
            onTap: () => showAccountSheet(context, p.id),
          );
        },
      ),
    );
  }
}

Future<void> showAccountSheet(BuildContext context, String id) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    constraints: const BoxConstraints(maxWidth: 560),
    builder: (_) => AccountSheet(accountId: id),
  );
}

class AccountSheet extends ConsumerWidget {
  const AccountSheet({super.key, required this.accountId});
  final String accountId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final acc = ref.watch(accountsProvider);
    final p = acc.byId(accountId);
    if (p == null) return const SizedBox(height: 120);
    final status = acc.statusOf(p.id);
    final info = acc.infos[p.id];
    final err = acc.errorOf(p.id);
    final t = Theme.of(context);
    final ctl = ref.read(accountsProvider.notifier);
    final retry = acc.nextRetry[p.id];
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Avatar(name: p.name, size: 44, color: Color(p.color)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p.name, style: t.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                      Text(p.address, style: t.textTheme.bodySmall?.copyWith(color: t.colorScheme.onSurfaceVariant)),
                    ],
                  ),
                ),
                StatusDot(color: statusColor(context, status), size: 12),
                const SizedBox(width: 6),
                Text(statusLabel(status), style: t.textTheme.labelLarge),
              ],
            ),
            if (err != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: context.colors.regFail.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(kRadius),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline_rounded, color: context.colors.regFail),
                    const SizedBox(width: 10),
                    Expanded(child: Text(err)),
                    TextButton(
                      onPressed: () => showErrorDetails(context, 'Registration error', err, info == null ? null : 'SIP ${info.regCode} ${info.regReason}\n${info.statusText}\nTransport: ${info.transport}'),
                      child: const Text('Details'),
                    ),
                  ],
                ),
              ),
              if (retry != null)
                Padding(
                  padding: const EdgeInsets.only(top: 6, left: 4),
                  child: Text('Retrying at ${DateFormat.Hms().format(retry)}', style: t.textTheme.bodySmall),
                ),
            ],
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (status == AccountStatus.registered || status == AccountStatus.registering)
                  OutlinedButton.icon(
                    onPressed: () => ctl.register(p.id, false),
                    icon: const Icon(Icons.cloud_off_rounded),
                    label: const Text('Unregister'),
                  )
                else
                  FilledButton.icon(
                    onPressed: p.enabled ? () => ctl.register(p.id, true) : null,
                    icon: const Icon(Icons.cloud_done_rounded),
                    label: const Text('Register'),
                  ),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    context.push('/settings/accounts/${p.id}');
                  },
                  icon: const Icon(Icons.tune_rounded),
                  label: const Text('Edit'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              secondary: const Icon(Icons.do_not_disturb_on_rounded),
              title: const Text('Do not disturb'),
              subtitle: const Text('Reject incoming calls on this account'),
              value: p.dnd,
              onChanged: (v) => ctl.setDnd(p.id, v),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              secondary: const Icon(Icons.power_settings_new_rounded),
              title: const Text('Enabled'),
              value: p.enabled,
              onChanged: (v) => ctl.setEnabled(p.id, v),
            ),
            if (info != null) ...[
              const Divider(),
              _kv(context, 'Server', p.config.domain),
              _kv(context, 'Transport', info.transport.isEmpty ? p.config.transport.wire : info.transport.toUpperCase()),
              if (info.contact.isNotEmpty) _kv(context, 'Contact', info.contact),
              if (info.expires > 0) _kv(context, 'Expires in', '${info.expires} s'),
              if (acc.mwi[p.id] != null)
                _kv(context, 'Voicemail', '${acc.mwi[p.id]!.newMsgs} new, ${acc.mwi[p.id]!.oldMsgs} old'),
            ],
          ],
        ),
      ),
    );
  }

  Widget _kv(BuildContext context, String k, String v) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 100, child: Text(k, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant))),
        Expanded(child: SelectableText(v, style: Theme.of(context).textTheme.bodyMedium)),
      ],
    ),
  );
}

/// Shows an error with a Details dialog (SIP code/reason) and a trace link.
Future<void> showErrorDetails(BuildContext context, String title, String message, String? details) {
  return showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(message),
          if (details != null && details.trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(ctx).colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(kRadius),
              ),
              child: SelectableText(details, style: const TextStyle(fontFamily: 'monospace', fontSize: 12)),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(ctx);
            context.push('/settings/diagnostics');
          },
          child: const Text('Open SIP trace'),
        ),
        FilledButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
      ],
    ),
  );
}

/// Account selector (dropdown with status dots) for the dialler.
class AccountSelector extends ConsumerWidget {
  const AccountSelector({super.key, this.dense = false});
  final bool dense;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final acc = ref.watch(accountsProvider);
    final selectedId = ref.watch(dialAccountProvider);
    final direct = selectedId == kDirectAccountId;
    final selected = direct ? null : (selectedId != null ? acc.byId(selectedId) : null) ?? acc.defaultProfile;
    if (acc.profiles.isEmpty) {
      return TextButton.icon(
        onPressed: () => context.push('/account-wizard'),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add an account'),
      );
    }
    final t = Theme.of(context);
    return PopupMenuButton<String>(
      tooltip: 'Choose the account to call from',
      position: PopupMenuPosition.under,
      onSelected: (id) => ref.read(dialAccountProvider.notifier).select(id),
      itemBuilder: (_) => [
        for (final p in acc.enabled)
          PopupMenuItem(
            value: p.id,
            child: Row(
              children: [
                StatusDot(color: statusColor(context, acc.statusOf(p.id))),
                const SizedBox(width: 10),
                Flexible(child: Text(p.name, overflow: TextOverflow.ellipsis)),
                if (p.id == selected?.id) ...[const SizedBox(width: 8), const Icon(Icons.check_rounded, size: 18)],
              ],
            ),
          ),
        PopupMenuItem(
          key: const Key('account-direct'),
          value: kDirectAccountId,
          child: Row(
            children: [
              const Icon(Icons.alt_route_rounded, size: 14),
              const SizedBox(width: 10),
              const Flexible(child: Text('Direct (no account)', overflow: TextOverflow.ellipsis)),
              if (direct) ...[const SizedBox(width: 8), const Icon(Icons.check_rounded, size: 18)],
            ],
          ),
        ),
      ],
      child: Semantics(
        button: true,
        label: 'Calling from ${direct ? 'direct, no account' : (selected?.name ?? 'no account')}',
        child: Container(
          constraints: const BoxConstraints(minHeight: 40),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: t.colorScheme.outlineVariant),
            color: context.colors.card,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (selected != null) StatusDot(color: statusColor(context, acc.statusOf(selected.id))),
              if (direct) const Icon(Icons.alt_route_rounded, size: 16),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  direct ? 'Direct (no account)' : (selected?.name ?? 'No account'),
                  overflow: TextOverflow.ellipsis,
                  style: t.textTheme.labelLarge,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.arrow_drop_down_rounded),
            ],
          ),
        ),
      ),
    );
  }
}

/// Small helper to run async work without awaiting in callbacks.
void fire(Future<void> f) => unawaited(f);

/// Re-export so callers needing profile type avoid extra imports.
typedef Profile = AccountProfile;
