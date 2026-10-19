import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/l10n.dart';
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
    final l = context.l10n;

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
          title: l.shortcutsGlobalTitle,
          footer: l.shortcutsGlobalFooter,
          children: [
            for (final a in HotkeyAction.values)
              ListTile(
                leading: const Icon(Icons.keyboard_rounded),
                title: Text(a.label(l)),
                subtitle: Text(bindings[a]?.display(mac: Platform.isMacOS) ?? l.commonNotSet, textDirection: bindings[a] == null ? null : TextDirection.ltr),
                onTap: () => edit(a),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      tooltip: l.actionClear,
                      icon: const Icon(Icons.clear_rounded),
                      onPressed: bindings[a] == null ? null : () => save({...bindings, a: null}),
                    ),
                    IconButton(tooltip: l.shortcutsChange, icon: const Icon(Icons.edit_rounded), onPressed: () => edit(a)),
                  ],
                ),
              ),
            ListTile(
              leading: const Icon(Icons.restart_alt_rounded),
              title: Text(l.shortcutsRestoreDefaults),
              onTap: () => ref.read(settingsProvider.notifier).update({'hotkeys': <String, String>{}}),
            ),
          ],
        ),
        SettingsGroup(
          title: l.shortcutsMediaTitle,
          footer: l.shortcutsMediaFooter,
          children: [
            SwitchTile(
              key: const Key('media-keys'),
              icon: Icons.headset_mic_rounded,
              title: l.shortcutsMediaSwitch,
              value: s.mediaKeys,
              onChanged: (v) => ref.read(settingsProvider.notifier).update({'mediaKeys': v}),
            ),
            if (s.mediaKeys)
              SelectTile<String>(
                key: const Key('media-key-active'),
                icon: Icons.touch_app_rounded,
                title: l.shortcutsMediaDuringCall,
                value: s.mediaKeyActive == 'mute' ? 'mute' : 'hangup',
                options: {'hangup': l.shortcutsMediaHangsUp, 'mute': l.shortcutsMediaMutes},
                onChanged: (v) => ref.read(settingsProvider.notifier).update({'mediaKeyActive': v}),
              ),
          ],
        ),
        SettingsGroup(
          title: l.shortcutsInApp,
          children: [
            for (final e in {
              '$mod+K': l.actionSearch,
              '$mod+D': l.shortcutsFocusDialer,
              '$mod+M': l.hotkeyMute,
              '$mod+Shift+H': l.shortcutsHoldResume,
              '$mod+Shift+T': l.shortcutsTransfer,
              '$mod+E': l.shortcutsEndCall,
              '$mod+Shift+A': l.trayNotificationAnswer,
              '$mod+,': l.actionSettings,
            }.entries)
              ListTile(dense: true, title: Text(e.value), trailing: Text(e.key, textDirection: TextDirection.ltr, style: Theme.of(context).textTheme.bodySmall)),
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
  String? _hint;

  KeyEventResult _onKey(FocusNode node, KeyEvent e) {
    if (e is! KeyDownEvent) return KeyEventResult.handled;
    if (e.logicalKey == LogicalKeyboardKey.escape) {
      Navigator.of(context).pop();
      return KeyEventResult.handled;
    }
    final b = HotkeyBinding.fromKeyEvent(e, pressed: HardwareKeyboard.instance.logicalKeysPressed);
    if (b == null) return KeyEventResult.handled; // a modifier alone, or an unsupported key
    if (HotkeyBinding.parse(b.serialize()) == null) {
      setState(() => _hint = context.l10n.shortcutsNeedModifier(Platform.isMacOS ? 'Cmd' : 'Win'));
      return KeyEventResult.handled;
    }
    Navigator.of(context).pop(b);
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return AlertDialog(
      title: Text(widget.action.label(l)),
      content: Focus(
        autofocus: true,
        onKeyEvent: _onKey,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(_hint ?? l.shortcutsPressNew),
        ),
      ),
      actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l.actionCancel))],
    );
  }
}
