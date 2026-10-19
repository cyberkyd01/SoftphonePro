import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  final action = await showDialog<String>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text('Speed dial $slot'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              key: const Key('speed-dial-number'),
              controller: number,
              autofocus: true,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Number or SIP address'),
            ),
            const SizedBox(height: 10),
            TextField(
              key: const Key('speed-dial-label'),
              controller: label,
              decoration: const InputDecoration(labelText: 'Label (optional)'),
            ),
            if (accounts.length > 1) ...[
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: acc,
                decoration: const InputDecoration(labelText: 'Call from'),
                items: [
                  const DropdownMenuItem(value: '', child: Text('Selected account')),
                  for (final a in accounts) DropdownMenuItem(value: a.id, child: Text(a.name)),
                ],
                onChanged: (v) => acc = v ?? '',
              ),
            ],
          ],
        ),
      ),
      actions: [
        if (existing != null) TextButton(onPressed: () => Navigator.pop(ctx, 'clear'), child: const Text('Clear')),
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        FilledButton(key: const Key('speed-dial-save'), onPressed: () => Navigator.pop(ctx, 'save'), child: const Text('Save')),
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
    return Scaffold(
      appBar: AppBar(title: const Text('Speed dial')),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Text(
              'Long-press a digit (1-9) on the empty keypad to call its number.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          ),
          for (var i = 1; i <= 9; i++)
            ListTile(
              key: Key('speed-dial-slot-$i'),
              leading: CircleAvatar(child: Text('$i')),
              title: Text(dial[i] == null ? 'Not assigned' : (dial[i]!.label.isEmpty ? dial[i]!.number : dial[i]!.label)),
              subtitle: dial[i] == null || dial[i]!.label.isEmpty ? null : Text(dial[i]!.number),
              trailing: const Icon(Icons.edit_rounded),
              onTap: () => showSpeedDialEditor(context, ref, i),
            ),
        ],
      ),
    );
  }
}
