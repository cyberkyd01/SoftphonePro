
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:softphonepro/models/app_settings.dart';
import 'package:softphonepro/platform/desktop/desktop_shell.dart';
import 'package:softphonepro/platform/desktop/hotkeys.dart';
import 'package:softphonepro/platform/desktop/launch_args.dart';
import 'package:softphonepro/platform/desktop/window_state.dart';

void main() {
  group('launch arguments', () {
    test('sip link', () {
      final a = parseLaunchArgs(['sip:alice@example.com']);
      expect(a.link?.scheme, 'sip');
      expect(dialTargetFromLink(a.link!), 'alice@example.com');
      expect(a.minimized, isFalse);
    });

    test('--minimized with and without link', () {
      expect(parseLaunchArgs(['--minimized']).minimized, isTrue);
      expect(parseLaunchArgs(['--minimized']).link, isNull);
      final a = parseLaunchArgs(['--minimized', 'tel:+15550100']);
      expect(a.minimized, isTrue);
      expect(dialTargetFromLink(a.link!), '+15550100');
    });

    test('schemes are case-insensitive, unknown ones ignored', () {
      expect(parseLink('SIPS:bob@host:5061')?.scheme, 'sips');
      expect(parseLink('CallTo:100')?.scheme, 'callto');
      expect(parseLink('http://example.com'), isNull);
      expect(parseLink('sip:'), isNull);
      expect(parseLink('C:\\Windows\\x.exe'), isNull);
      expect(parseLaunchArgs(['--foo', 'file.txt']).isEmpty, isTrue);
    });

    test('tolerates spaces and percent-encoding', () {
      expect(dialTargetFromLink(parseLink('tel:+1 555 0100')!), '+1 555 0100');
      expect(dialTargetFromLink(parseLink('tel:%2B1555')!), '+1555');
      expect(dialTargetFromLink(parseLink('sip:bob@host?subject=hi')!), 'bob@host');
      expect(dialTargetFromLink(parseLink('callto://100')!), '100');
    });

    test('softphonepro: scheme', () {
      expect(dialTargetFromLink(parseLink('softphonepro://call?number=200')!), '200');
      expect(dialTargetFromLink(parseLink('softphonepro:300')!), '300');
    });

    test('forwarded command lines (newline separated)', () {
      final a = parseForwardedArgs('--minimized\nsip:carol@example.com');
      expect(a.minimized, isTrue);
      expect(a.link.toString(), 'sip:carol@example.com');
      expect(parseForwardedArgs('--show').show, isTrue);
      expect(parseForwardedArgs('').isEmpty, isTrue);
    });
  });

  group('hotkeys', () {
    test('parse / serialize round trip', () {
      final b = HotkeyBinding.parse('Ctrl+Alt+A')!;
      expect(b.serialize(), 'ctrl+alt+a');
      expect(b.ctrl && b.alt && !b.shift && !b.meta, isTrue);
      expect(HotkeyBinding.parse(b.serialize()), b);
      expect(HotkeyBinding.parse('cmd+shift+f5')!.serialize(), 'shift+meta+f5');
      expect(b.display(), 'Ctrl+Alt+A');
    });

    test('rejects invalid bindings', () {
      expect(HotkeyBinding.parse(''), isNull);
      expect(HotkeyBinding.parse('ctrl+alt'), isNull);
      expect(HotkeyBinding.parse('ctrl+a+b'), isNull);
      expect(HotkeyBinding.parse('ctrl+nope'), isNull);
      expect(HotkeyBinding.parse('a'), isNull); // would swallow typing
      expect(HotkeyBinding.parse('f9'), isNotNull); // function keys need no modifier
    });

    test('defaults, overrides and disabled actions', () {
      final d = resolveHotkeys(const {});
      expect(d[HotkeyAction.answer]!.serialize(), 'ctrl+alt+a');
      expect(d.length, HotkeyAction.values.length);
      final r = resolveHotkeys({
        'answer': 'ctrl+shift+1',
        'hangup': '', // disabled
        'mute': 'garbage', // invalid -> default
      });
      expect(r[HotkeyAction.answer]!.serialize(), 'ctrl+shift+1');
      expect(r[HotkeyAction.hangup], isNull);
      expect(r[HotkeyAction.mute]!.serialize(), 'ctrl+alt+m');
    });

    test('settings serialization survives AppSettings JSON', () {
      final bindings = {
        HotkeyAction.answer: HotkeyBinding.parse('ctrl+alt+y'),
        HotkeyAction.hangup: null,
        HotkeyAction.mute: HotkeyBinding.parse('meta+shift+m'),
        HotkeyAction.focusDialer: HotkeyBinding.parse('f8'),
      };
      final s = const AppSettings().update({'hotkeys': hotkeysToSettings(bindings)});
      final back = AppSettings.fromJson(s.toJson());
      expect(back.hotkeys, {
        'answer': 'ctrl+alt+y',
        'hangup': '',
        'mute': 'shift+meta+m',
        'focusDialer': 'f8',
      });
      expect(resolveHotkeys(back.hotkeys), bindings);
    });

    test('maps to a system hotkey', () {
      final hk = HotkeyBinding.parse('ctrl+alt+a')!.toHotKey();
      expect(hk.key, PhysicalKeyboardKey.keyA);
      expect(hk.modifiers!.length, 2);
      expect(keyNameOf(PhysicalKeyboardKey.digit7), '7');
      expect(keyNameOf(PhysicalKeyboardKey.escape), isNull);
    });
  });

  group('window state', () {
    test('json round trip and validation', () {
      const s = SavedWindowState(bounds: Rect.fromLTWH(10, 20, 900, 700), maximized: true);
      final back = SavedWindowState.fromJson(s.toJson())!;
      expect(back.bounds, s.bounds);
      expect(back.maximized, isTrue);
      expect(SavedWindowState.fromJson('x'), isNull);
      expect(SavedWindowState.fromJson({'x': 0, 'y': 0, 'w': 10, 'h': 10}), isNull);
      expect(SavedWindowState.fromJson({'x': 0, 'y': 0}), isNull);
    });

    test('off-screen bounds are dropped', () {
      const s = SavedWindowState(bounds: Rect.fromLTWH(3000, 100, 900, 700));
      const main = Rect.fromLTWH(0, 0, 1920, 1080);
      expect(s.onScreenBounds([main]), isNull);
      expect(s.onScreenBounds([main, const Rect.fromLTWH(1920, 0, 1920, 1080)]), isNotNull);
    });
  });

  group('tray', () {
    test('tooltip', () {
      expect(trayTooltipText(online: 2, total: 3), 'SoftphonePro - 2/3 online');
      expect(trayTooltipText(online: 0, total: 0), 'SoftphonePro - no accounts');
      expect(trayTooltipText(online: 1, total: 1, status: 'dnd'), 'SoftphonePro - 1/1 online (Do not disturb)');
    });

    test('menu structure', () {
      final m = buildTrayMenu(
        windowVisible: false,
        status: 'away',
        badge: 2,
        accounts: const [TrayAccount('a1', 'Work', true), TrayAccount('a2', 'Home', false)],
      );
      expect(m.first.label, 'Show SoftphonePro');
      expect(m.any((e) => e.key == 'recents'), isTrue);
      final status = m.firstWhere((e) => e.key == 'status');
      expect(status.children!.firstWhere((e) => e.key == 'status:away').checked, isTrue);
      expect(status.children!.firstWhere((e) => e.key == 'status:dnd').checked, isFalse);
      final accounts = m.firstWhere((e) => e.key == 'accounts');
      expect(accounts.children!.map((e) => e.key), ['acct:a1', 'acct:a2']);
      expect(m.last.key, 'quit');
      expect(buildTrayMenu(windowVisible: true, status: 'available', accounts: const []).first.label, 'Hide SoftphonePro');
    });
  });
}
