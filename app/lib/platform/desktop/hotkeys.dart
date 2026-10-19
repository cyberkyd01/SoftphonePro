import 'package:flutter/services.dart';

import '../../l10n/l10n.dart';
import 'package:hotkey_manager/hotkey_manager.dart';

/// App-wide (system) hotkeys configurable in Settings > Shortcuts.
enum HotkeyAction {
  answer('ctrl+alt+a'),
  hangup('ctrl+alt+h'),
  mute('ctrl+alt+m'),
  focusDialer('ctrl+alt+d');

  const HotkeyAction(this.defaultBinding);

  /// Display name of the action.
  String label(AppLocalizations l) => switch (this) {
    answer => l.hotkeyAnswerCall,
    hangup => l.hotkeyHangUp,
    mute => l.hotkeyMute,
    focusDialer => l.hotkeyFocusDialer,
  };
  final String defaultBinding;
}

/// A key combination, serialised as `ctrl+alt+shift+meta+<key>`
/// (modifiers in that fixed order; `meta` is Cmd on macOS, Win on Windows).
class HotkeyBinding {
  const HotkeyBinding(this.key, {this.ctrl = false, this.alt = false, this.shift = false, this.meta = false});

  /// Lower-case key name: `a`..`z`, `0`..`9`, `f1`..`f12`, `space`.
  final String key;
  final bool ctrl, alt, shift, meta;

  bool get hasModifier => ctrl || alt || shift || meta;

  /// `ctrl+alt+a`.
  String serialize() => [
    if (ctrl) 'ctrl',
    if (alt) 'alt',
    if (shift) 'shift',
    if (meta) 'meta',
    key,
  ].join('+');

  /// Parses [s]; null when empty or invalid (unknown key, or a plain letter
  /// without any modifier, which would swallow normal typing system-wide).
  static HotkeyBinding? parse(String? s) {
    if (s == null) return null;
    final parts = s.toLowerCase().split('+').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    if (parts.isEmpty) return null;
    var ctrl = false, alt = false, shift = false, meta = false;
    String? key;
    for (final p in parts) {
      switch (p) {
        case 'ctrl' || 'control':
          ctrl = true;
        case 'alt' || 'option':
          alt = true;
        case 'shift':
          shift = true;
        case 'meta' || 'cmd' || 'command' || 'win' || 'super':
          meta = true;
        default:
          if (key != null) return null;
          key = p;
      }
    }
    if (key == null || !_physicalKeys.containsKey(key)) return null;
    final b = HotkeyBinding(key, ctrl: ctrl, alt: alt, shift: shift, meta: meta);
    final isFunctionKey = key.startsWith('f') && key.length > 1;
    if (!b.hasModifier && !isFunctionKey) return null;
    return b;
  }

  /// Human readable, e.g. `Ctrl+Alt+A`.
  String display({bool mac = false}) {
    final m = [
      if (ctrl) 'Ctrl',
      if (alt) mac ? 'Option' : 'Alt',
      if (shift) 'Shift',
      if (meta) mac ? 'Cmd' : 'Win',
    ];
    return [...m, key.length == 1 ? key.toUpperCase() : (key == 'space' ? 'Space' : key.toUpperCase())].join('+');
  }

  HotKey toHotKey({String? identifier}) => HotKey(
    identifier: identifier,
    key: _physicalKeys[key]!,
    modifiers: [
      if (ctrl) HotKeyModifier.control,
      if (alt) HotKeyModifier.alt,
      if (shift) HotKeyModifier.shift,
      if (meta) HotKeyModifier.meta,
    ],
    scope: HotKeyScope.system,
  );

  /// Builds a binding from a key press captured in the settings UI.
  static HotkeyBinding? fromKeyEvent(KeyEvent e, {required Set<LogicalKeyboardKey> pressed}) {
    final name = keyNameOf(e.physicalKey);
    if (name == null) return null;
    bool any(List<LogicalKeyboardKey> ks) => ks.any(pressed.contains);
    return HotkeyBinding(
      name,
      ctrl: any([LogicalKeyboardKey.controlLeft, LogicalKeyboardKey.controlRight]),
      alt: any([LogicalKeyboardKey.altLeft, LogicalKeyboardKey.altRight]),
      shift: any([LogicalKeyboardKey.shiftLeft, LogicalKeyboardKey.shiftRight]),
      meta: any([LogicalKeyboardKey.metaLeft, LogicalKeyboardKey.metaRight]),
    );
  }

  @override
  bool operator ==(Object other) => other is HotkeyBinding && other.serialize() == serialize();
  @override
  int get hashCode => serialize().hashCode;
  @override
  String toString() => 'HotkeyBinding(${serialize()})';
}

/// Key name for [k], or null if it cannot be used in a hotkey.
String? keyNameOf(PhysicalKeyboardKey k) {
  for (final e in _physicalKeys.entries) {
    if (e.value == k) return e.key;
  }
  return null;
}

/// The effective bindings: [stored] (settings `hotkeys` map; an empty string
/// disables an action) over the defaults. Invalid entries fall back to the
/// default.
Map<HotkeyAction, HotkeyBinding?> resolveHotkeys(Map<String, String> stored) {
  final out = <HotkeyAction, HotkeyBinding?>{};
  for (final a in HotkeyAction.values) {
    final raw = stored[a.name];
    if (raw == null) {
      out[a] = HotkeyBinding.parse(a.defaultBinding);
    } else if (raw.trim().isEmpty) {
      out[a] = null; // explicitly disabled
    } else {
      out[a] = HotkeyBinding.parse(raw) ?? HotkeyBinding.parse(a.defaultBinding);
    }
  }
  return out;
}

/// The settings `hotkeys` map for [bindings] (null = disabled = '').
Map<String, String> hotkeysToSettings(Map<HotkeyAction, HotkeyBinding?> bindings) => {
  for (final e in bindings.entries) e.key.name: e.value?.serialize() ?? '',
};

final Map<String, PhysicalKeyboardKey> _physicalKeys = () {
  const letters = [
    PhysicalKeyboardKey.keyA, PhysicalKeyboardKey.keyB, PhysicalKeyboardKey.keyC, PhysicalKeyboardKey.keyD,
    PhysicalKeyboardKey.keyE, PhysicalKeyboardKey.keyF, PhysicalKeyboardKey.keyG, PhysicalKeyboardKey.keyH,
    PhysicalKeyboardKey.keyI, PhysicalKeyboardKey.keyJ, PhysicalKeyboardKey.keyK, PhysicalKeyboardKey.keyL,
    PhysicalKeyboardKey.keyM, PhysicalKeyboardKey.keyN, PhysicalKeyboardKey.keyO, PhysicalKeyboardKey.keyP,
    PhysicalKeyboardKey.keyQ, PhysicalKeyboardKey.keyR, PhysicalKeyboardKey.keyS, PhysicalKeyboardKey.keyT,
    PhysicalKeyboardKey.keyU, PhysicalKeyboardKey.keyV, PhysicalKeyboardKey.keyW, PhysicalKeyboardKey.keyX,
    PhysicalKeyboardKey.keyY, PhysicalKeyboardKey.keyZ,
  ];
  const digits = [
    PhysicalKeyboardKey.digit0, PhysicalKeyboardKey.digit1, PhysicalKeyboardKey.digit2,
    PhysicalKeyboardKey.digit3, PhysicalKeyboardKey.digit4, PhysicalKeyboardKey.digit5,
    PhysicalKeyboardKey.digit6, PhysicalKeyboardKey.digit7, PhysicalKeyboardKey.digit8,
    PhysicalKeyboardKey.digit9,
  ];
  const fkeys = [
    PhysicalKeyboardKey.f1, PhysicalKeyboardKey.f2, PhysicalKeyboardKey.f3, PhysicalKeyboardKey.f4,
    PhysicalKeyboardKey.f5, PhysicalKeyboardKey.f6, PhysicalKeyboardKey.f7, PhysicalKeyboardKey.f8,
    PhysicalKeyboardKey.f9, PhysicalKeyboardKey.f10, PhysicalKeyboardKey.f11, PhysicalKeyboardKey.f12,
  ];
  return {
    for (var i = 0; i < letters.length; i++) String.fromCharCode(0x61 + i): letters[i],
    for (var i = 0; i < digits.length; i++) '$i': digits[i],
    for (var i = 0; i < fkeys.length; i++) 'f${i + 1}': fkeys[i],
    'space': PhysicalKeyboardKey.space,
  };
}();
