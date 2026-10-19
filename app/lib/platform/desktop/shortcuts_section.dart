import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/settings_controller.dart';
import '../../ui/widgets/settings_tiles.dart';
import 'hotkeys.dart';

/// Global hotkeys are implemented for macOS and Windows.
bool get hotkeysSupported => Platform.isMacOS || Platform.isWindows;

/// Settings > Shortcuts: system-wide hotkeys (work while the app is in the
/// background) plus a reference of the in-app shortcuts.
class ShortcutsSection extends ConsumerWidget {
  const ShortcutsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(settingsProvider);
    final bindings = resolveHotkeys(s.hotkeys);
    final mod = Platform.isMacOS ? 'Cmd' : 'Ctrl';

    Future<void> save(Map<HotkeyAction, HotkeyBinding?> next) =>
        ref.read(settingsProvider.notifier).update({'hotkeys': hotkeysToSettings(next)});

    Future<void> edit(HotkeyAction a) async {
      final b = await showHotkeyCaptureDialog(context, a);
      if (b == null) return;
      final next = {...bindings};
      for (final e in next.entries) {
        if (e.key != a && e.value == b) next[e.key] = null; // steal from the other action
      }
      next[a] = b;
      await save(next);
    }

    return ListView(
      padding: const EdgeInsets.only(bottom: 32),
      children: [
        SettingsGroup(
          title: 'Global hotkeys',
          footer: 'Work from any application. Another program that already uses a combination may prevent it from registering.',
          children: [
            for (final a in HotkeyAction.values)
              ListTile(
                leading: const Icon(Icons.keyboard_rounded),
                title: Text(a.label),
                subtitle: Text(bindings[a]?.display(mac: Platform.isMacOS) ?? 'Not set'),
                onTap: () => edit(a),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      tooltip: 'Clear',
                      icon: const Icon(Icons.clear_rounded),
                      onPressed: bindings[a] == null ? null : () => save({...bindings, a: null}),
                    ),
                    IconButton(tooltip: 'Change', icon: const Icon(Icons.edit_rounded), onPressed: () => edit(a)),
                  ],
                ),
              ),
            ListTile(
              leading: const Icon(Icons.restart_alt_rounded),
              title: const Text('Restore defaults'),
              onTap: () => ref.read(settingsProvider.notifier).update({'hotkeys': <String, String>{}}),
            ),
          ],
        ),
        SettingsGroup(
          title: 'In the app',
          children: [
            for (final e in {
              '$mod+K': 'Search',
              '$mod+D': 'Focus the dialer',
              '$mod+M': 'Mute / unmute',
              '$mod+Shift+H': 'Hold / resume',
              '$mod+Shift+T': 'Transfer',
              '$mod+E': 'End call',
              '$mod+Shift+A': 'Answer',
              '$mod+,': 'Settings',
            }.entries)
              ListTile(dense: true, title: Text(e.value), trailing: Text(e.key, style: Theme.of(context).textTheme.bodySmall)),
          ],
        ),
      ],
    );
  }
}

/// Asks the user to press a key combination; null if cancelled.
Future<HotkeyBinding?> showHotkeyCaptureDialog(BuildContext context, HotkeyAction action) {
  return showDialog<HotkeyBinding>(
    context: context,
    builder: (_) => _CaptureDialog(action: action),
  );
}

class _CaptureDialog extends StatefulWidget {
  const _CaptureDialog({required this.action});
  final HotkeyAction action;
  @override
  State<_CaptureDialog> createState() => _CaptureDialogState();
}

class _CaptureDialogState extends State<_CaptureDialog> {
  String _hint = 'Press the new key combination';

  KeyEventResult _onKey(FocusNode node, KeyEvent e) {
    if (e is! KeyDownEvent) return KeyEventResult.handled;
    if (e.logicalKey == LogicalKeyboardKey.escape) {
      Navigator.of(context).pop();
      return KeyEventResult.handled;
    }
    final b = HotkeyBinding.fromKeyEvent(e, pressed: HardwareKeyboard.instance.logicalKeysPressed);
    if (b == null) return KeyEventResult.handled; // a modifier alone, or an unsupported key
    if (HotkeyBinding.parse(b.serialize()) == null) {
      setState(() => _hint = 'Add Ctrl, Alt, Shift or ${Platform.isMacOS ? 'Cmd' : 'Win'} to a letter or digit');
      return KeyEventResult.handled;
    }
    Navigator.of(context).pop(b);
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.action.label),
      content: Focus(
        autofocus: true,
        onKeyEvent: _onKey,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(_hint),
        ),
      ),
      actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel'))],
    );
  }
}
