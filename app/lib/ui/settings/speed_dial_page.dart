import '../../core/bidi.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/l10n.dart';
import '../../models/app_settings.dart';
import '../../services/accounts_controller.dart';
import '../../services/settings_controller.dart';

/// Stores (or clears, when [entry] is null) speed dial [slot] (1-9).
Future<void> saveSpeedDial(WidgetRef ref, int slot, SpeedDialEntry? entry) {
  final cur = ref.read(settingsProvider).speedDial;
  final next = <String, dynamic>{
    for (final e in cur.entries)
      if (e.key != slot) '${e.key}': e.value.toJson(),
    if (entry != null && entry.number.trim().isNotEmpty) '$slot': entry.toJson(),
  };
  return ref.read(settingsProvider.notifier).update({'speedDial': next});
}

/// Dialog to assign / edit a speed dial slot.
Future<void> showSpeedDialEditor(BuildContext context, WidgetRef ref, int slot) async {
  final existing = ref.read(settingsProvider).speedDial[slot];
  final number = TextEditingController(text: existing?.number ?? '');
  final label = TextEditingController(text: existing?.label ?? '');
  String acc = existing?.accountId ?? '';
  final accounts = ref.read(accountsProvider).profiles;
  if (!accounts.any((a) => a.id == acc)) acc = '';
  final l = context.l10n;
  final action = await showDialog<String>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(l.speedDialSlotTitle(slot)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              key: const Key('speed-dial-number'),
              controller: number,
              textDirection: TextDirection.ltr,
              autofocus: true,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(labelText: l.speedDialNumberLabel),
            ),
            const SizedBox(height: 10),
            TextField(
              key: const Key('speed-dial-label'),
              controller: label,
              decoration: InputDecoration(labelText: l.speedDialLabelOptional),
            ),
            if (accounts.length > 1) ...[
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: acc,
                decoration: InputDecoration(labelText: l.speedDialCallFrom),
                items: [
                  DropdownMenuItem(value: '', child: Text(l.speedDialSelectedAccount)),
                  for (final a in accounts) DropdownMenuItem(value: a.id, child: Text(a.name)),
                ],
                onChanged: (v) => acc = v ?? '',
              ),
            ],
          ],
        ),
      ),
      actions: [
        if (existing != null) TextButton(onPressed: () => Navigator.pop(ctx, 'clear'), child: Text(l.actionClear)),
        TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l.actionCancel)),
        FilledButton(key: const Key('speed-dial-save'), onPressed: () => Navigator.pop(ctx, 'save'), child: Text(l.actionSave)),
      ],
    ),
  );
  if (action == 'clear') {
    await saveSpeedDial(ref, slot, null);
  } else if (action == 'save' && number.text.trim().isNotEmpty) {
    await saveSpeedDial(
      ref,
      slot,
      SpeedDialEntry(number: number.text.trim(), label: label.text.trim(), accountId: acc.isEmpty ? null : acc),
    );
  }
}

/// Settings > Calls > Speed dial.
class SpeedDialPage extends ConsumerWidget {
  const SpeedDialPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dial = ref.watch(settingsProvider.select((s) => s.speedDial));
    final l = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l.speedDialTitle)),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 8),
            child: Text(
              l.speedDialHint,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          ),
          for (var i = 1; i <= 9; i++)
            ListTile(
              key: Key('speed-dial-slot-$i'),
              leading: CircleAvatar(child: Text('$i')),
              title: Text(dial[i] == null ? l.speedDialNotAssigned : (dial[i]!.label.isEmpty ? bidiSafe(dial[i]!.number) : dial[i]!.label)),
              subtitle: dial[i] == null || dial[i]!.label.isEmpty ? null : Text(ltr(dial[i]!.number)),
              trailing: const Icon(Icons.edit_rounded),
              onTap: () => showSpeedDialEditor(context, ref, i),
            ),
        ],
      ),
    );
  }
}
