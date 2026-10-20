import 'dart:async';
import 'dart:io';

import 'package:dbus/dbus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:softphonepro/platform/desktop/default_handler.dart';
import 'package:softphonepro/platform/desktop/hotkeys.dart';
import 'package:softphonepro/platform/desktop/linux_session.dart';
import 'package:softphonepro/platform/desktop/mpris.dart';
import 'package:softphonepro/platform/desktop/tray_controller.dart';
import 'package:softphonepro/storage/secrets_store.dart';

/// A session bus address nobody listens on (no session bus).
DBusClient deadBus() => DBusClient(DBusAddress('unix:path=/nonexistent/softphonepro-test-bus'));

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('session detection', () {
    test('X11 vs Wayland', () {
      expect(isX11Session({'XDG_SESSION_TYPE': 'x11'}), isTrue);
      expect(isX11Session({'XDG_SESSION_TYPE': 'X11', 'WAYLAND_DISPLAY': 'wayland-0'}), isTrue);
      expect(isX11Session({'XDG_SESSION_TYPE': 'wayland', 'DISPLAY': ':0'}), isFalse); // XWayland
      expect(isX11Session({'DISPLAY': ':0'}), isTrue);
      expect(isX11Session({'DISPLAY': ':0', 'WAYLAND_DISPLAY': 'wayland-0'}), isFalse);
      expect(isX11Session({'XDG_SESSION_TYPE': 'tty', 'DISPLAY': ':1'}), isTrue);
      expect(isX11Session(const {}), isFalse);
    });

    test('global hotkeys: mac, Windows, Linux X11 only', () {
      bool on({bool mac = false, bool win = false, bool linux = false, Map<String, String> env = const {}}) =>
          hotkeysSupportedOn(isMacOS: mac, isWindows: win, isLinux: linux, env: env);
      expect(on(mac: true), isTrue);
      expect(on(win: true), isTrue);
      expect(on(linux: true, env: {'XDG_SESSION_TYPE': 'x11'}), isTrue);
      expect(on(linux: true, env: {'XDG_SESSION_TYPE': 'wayland', 'WAYLAND_DISPLAY': 'wayland-0'}), isFalse);
      expect(on(linux: true), isFalse);
      expect(on(), isFalse); // Android / iOS
    });

    test('Super is the Linux name of the meta modifier', () {
      final b = HotkeyBinding.parse('meta+shift+m')!;
      expect(b.display(linux: true), 'Shift+Super+M');
      expect(b.display(), 'Shift+Win+M');
      expect(b.display(mac: true), 'Shift+Cmd+M');
    });
  });

  group('tray availability', () {
    test('no session bus means no StatusNotifier host', () async {
      expect(await statusNotifierHostAvailable(client: deadBus()), isFalse);
    });

    test('waitForTrayHost retries and swallows errors', () async {
      var n = 0;
      expect(
        await waitForTrayHost(check: () async => ++n >= 3, attempts: 5, delay: Duration.zero),
        isTrue,
      );
      expect(n, 3);
      expect(await waitForTrayHost(check: () async => throw StateError('bus'), attempts: 2, delay: Duration.zero), isFalse);
      expect(await waitForTrayHost(check: () async => false), isFalse);
    });

    test('linux icons are PNG assets', () {
      expect(TrayController.linuxIcon(alert: false), endsWith('.png'));
      expect(TrayController.linuxIcon(alert: true), endsWith('.png'));
      expect(TrayController.linuxIcon(alert: true), isNot(TrayController.linuxIcon(alert: false)));
      for (final f in [TrayController.linuxIcon(alert: false), TrayController.linuxIcon(alert: true)]) {
        expect(File(f).existsSync(), isTrue, reason: f);
      }
    });

    test('without a host init reports false and never touches the plugin', () async {
      final calls = <String>[];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(const MethodChannel('tray_manager'), (c) async {
        calls.add(c.method);
        return true;
      });
      addTearDown(() => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(const MethodChannel('tray_manager'), null));
      final tray = TrayController(isLinux: true, linuxHostCheck: () async => false);
      expect(await tray.init(onMenu: (_) {}, onToggleWindow: () {}), isFalse);
      expect(tray.ready, isFalse);
      await tray.setMenu(const [TrayMenuEntry('quit', 'Quit')]);
      await tray.setState(tooltip: 'x', ringing: false, badge: 1);
      expect(calls, isEmpty);
    });

    test('with a host the PNG icon is set', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.linux;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);
      final icons = <String>[];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(const MethodChannel('tray_manager'), (c) async {
        if (c.method == 'setIcon') icons.add('${(c.arguments as Map)['iconPath']}');
        return true;
      });
      addTearDown(() => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(const MethodChannel('tray_manager'), null));
      final tray = TrayController(isLinux: true, linuxHostCheck: () async => true);
      expect(await tray.init(onMenu: (_) {}, onToggleWindow: () {}), isTrue);
      expect(icons.single, endsWith('assets/branding/tray_linux.png'));
      await tray.setState(badge: 2);
      expect(icons.last, endsWith('assets/branding/tray_linux_alert.png'));
      await tray.dispose();
    });
  });

  group('MPRIS', () {
    late int presses;
    late int raises;
    late MprisObject o;
    setUp(() {
      presses = 0;
      raises = 0;
      o = MprisObject(onPress: () => presses++, onRaise: () => raises++, title: 'Alice');
    });
    DBusMethodCall call(String iface, String name) => DBusMethodCall(sender: ':1.2', interface: iface, name: name);

    test('transport calls are presses', () async {
      for (final m in ['PlayPause', 'Play', 'Pause', 'Stop']) {
        expect(await o.handleMethodCall(call('org.mpris.MediaPlayer2.Player', m)), isA<DBusMethodSuccessResponse>());
      }
      expect(presses, 4);
      expect(await o.handleMethodCall(call('org.mpris.MediaPlayer2.Player', 'Next')), isA<DBusMethodSuccessResponse>());
      expect(presses, 4);
      expect(await o.handleMethodCall(call('org.mpris.MediaPlayer2.Player', 'Seek')), isA<DBusMethodErrorResponse>());
      expect(await o.handleMethodCall(call('org.example.Other', 'PlayPause')), isA<DBusMethodErrorResponse>());
    });

    test('Raise brings the window to the front; Quit is ignored', () async {
      await o.handleMethodCall(call('org.mpris.MediaPlayer2', 'Raise'));
      expect(raises, 1);
      expect(await o.handleMethodCall(call('org.mpris.MediaPlayer2', 'Quit')), isA<DBusMethodSuccessResponse>());
      expect(presses, 0);
    });

    Future<DBusValue> get(String iface, String name) async {
      final r = await o.getProperty(iface, name);
      expect(r, isA<DBusGetPropertyResponse>(), reason: name);
      return (r as DBusMethodSuccessResponse).returnValues.single.asVariant();
    }

    test('root properties', () async {
      expect((await get('org.mpris.MediaPlayer2', 'Identity')).asString(), 'SoftphonePro');
      expect((await get('org.mpris.MediaPlayer2', 'DesktopEntry')).asString(), 'com.softphonepro.softphonepro');
      expect((await get('org.mpris.MediaPlayer2', 'CanRaise')).asBoolean(), isTrue);
      expect((await get('org.mpris.MediaPlayer2', 'CanQuit')).asBoolean(), isFalse);
      expect((await get('org.mpris.MediaPlayer2', 'HasTrackList')).asBoolean(), isFalse);
    });

    test('player properties follow the claim', () async {
      expect((await get('org.mpris.MediaPlayer2.Player', 'PlaybackStatus')).asString(), 'Playing');
      o.playing = false;
      expect((await get('org.mpris.MediaPlayer2.Player', 'PlaybackStatus')).asString(), 'Stopped');
      expect((await get('org.mpris.MediaPlayer2.Player', 'CanControl')).asBoolean(), isTrue);
      final md = (await get('org.mpris.MediaPlayer2.Player', 'Metadata')).asStringVariantDict();
      expect(md['xesam:title']!.asString(), 'Alice');
      expect(md['mpris:trackid'], isA<DBusObjectPath>());
    });

    test('GetAll, unknown names and read-only properties', () async {
      final all = await o.getAllProperties('org.mpris.MediaPlayer2.Player');
      expect(all, isA<DBusGetAllPropertiesResponse>());
      final d = (all as DBusMethodSuccessResponse).returnValues.single.asStringVariantDict();
      expect(d.keys, containsAll(['PlaybackStatus', 'Metadata', 'CanPlay', 'CanPause']));
      expect(await o.getProperty('org.mpris.MediaPlayer2', 'Nope'), isA<DBusMethodErrorResponse>());
      expect(await o.getProperty('org.example.Other', 'Identity'), isA<DBusMethodErrorResponse>());
      expect(await o.getAllProperties('org.example.Other'), isA<DBusMethodErrorResponse>());
      expect(await o.setProperty('org.mpris.MediaPlayer2.Player', 'Volume', const DBusDouble(0.5)), isA<DBusMethodErrorResponse>());
    });

    test('introspection lists both interfaces', () {
      expect(o.introspect().map((i) => i.name), ['org.mpris.MediaPlayer2', 'org.mpris.MediaPlayer2.Player']);
    });

    test('backend without a session bus degrades quietly', () async {
      final b = MprisMediaKeyBackend(clientFactory: deadBus);
      await b.setActive(true);
      expect(b.owned, isFalse);
      await b.setActive(false);
      await b.dispose();
    });

    test('backend whose factory throws degrades quietly', () async {
      final b = MprisMediaKeyBackend(clientFactory: () => throw StateError('no bus'));
      await b.setActive(true);
      expect(b.owned, isFalse);
      await b.dispose();
    });
  });

  group('default handler (Linux)', () {
    late Directory tmp;
    late List<List<String>> log;
    setUp(() {
      tmp = Directory.systemTemp.createTempSync('spdh');
      log = [];
    });
    tearDown(() => tmp.deleteSync(recursive: true));

    DefaultHandlerService svc({
      Map<String, String> answers = const {},
      bool xdgMime = true,
      List<String> dataDirs = const [],
    }) => DefaultHandlerService(
      isLinux: true,
      isMacOS: false,
      isWindows: false,
      executable: p.join(tmp.path, 'My App', 'softphonepro'),
      environment: {'HOME': tmp.path, 'XDG_DATA_DIRS': dataDirs.join(':')},
      runProcess: (exe, args) async {
        log.add([exe, ...args]);
        if (exe == 'xdg-mime' && !xdgMime) throw const ProcessException('xdg-mime', []);
        if (exe == 'xdg-mime' && args.first == 'query') {
          return ProcessResult(1, 0, '${answers[args.last.split('/').last] ?? ''}\n', '');
        }
        return ProcessResult(1, 0, '', '');
      },
    );

    String userFile() => p.join(tmp.path, '.local', 'share', 'applications', 'com.softphonepro.softphonepro.desktop');

    test('current() compares with the desktop-file id', () async {
      final h = await svc(answers: {
        'sip': 'com.softphonepro.softphonepro.desktop',
        'tel': 'linphone.desktop',
        'callto': '',
      }).current();
      expect(h.map((e) => e.scheme), ['sip', 'tel', 'callto']);
      expect(h[0].isSelf, isTrue);
      expect(h[1].isSelf, isFalse);
      expect(h[1].name, 'linphone');
      expect(h[2].isSelf, isFalse);
      expect(log.first, ['xdg-mime', 'query', 'default', 'x-scheme-handler/sip']);
    });

    test('missing xdg-mime: unsupported, no crash', () async {
      final s = svc(xdgMime: false);
      expect(s.supported, isTrue);
      expect(await s.isAvailable(), isFalse);
      expect(await s.current(), isEmpty);
      final r = await s.makeDefault();
      expect(r.ok, isFalse);
      expect(r.failed, kHandlerSchemes);
      expect(File(userFile()).existsSync(), isFalse);
    });

    test('installed desktop file: only xdg-mime default for every scheme', () async {
      final share = Directory(p.join(tmp.path, 'share', 'applications'))..createSync(recursive: true);
      File(p.join(share.path, 'com.softphonepro.softphonepro.desktop')).writeAsStringSync('[Desktop Entry]\n');
      final r = await svc(dataDirs: [p.join(tmp.path, 'share')]).makeDefault();
      expect(r.ok, isTrue);
      expect(File(userFile()).existsSync(), isFalse);
      final defaults = log.where((c) => c.length > 1 && c[1] == 'default').toList();
      expect(defaults.map((c) => c.last), [for (final s in kLinuxSchemes) 'x-scheme-handler/$s']);
      expect(defaults.every((c) => c[2] == 'com.softphonepro.softphonepro.desktop'), isTrue);
      expect(log.any((c) => c.first == 'update-desktop-database'), isFalse);
    });

    test('tarball: writes a user-local desktop file first', () async {
      final r = await svc().makeDefault();
      expect(r.ok, isTrue);
      final text = File(userFile()).readAsStringSync();
      expect(text, contains('Exec="${p.join(tmp.path, 'My App', 'softphonepro')}" %u\n'));
      expect(text, contains('Icon=com.softphonepro.softphonepro\n')); // no bundled PNG in the temp dir
      expect(text, contains('MimeType=x-scheme-handler/sip;x-scheme-handler/sips;x-scheme-handler/tel;x-scheme-handler/callto;x-scheme-handler/softphonepro;'));
      expect(log.indexWhere((c) => c.first == 'update-desktop-database'), lessThan(log.indexWhere((c) => c.length > 1 && c[1] == 'default')));
      expect(log.firstWhere((c) => c.first == 'update-desktop-database').last, p.dirname(userFile()));
    });

    test('uses the bundled PNG as the icon when present', () async {
      final icon = File(p.join(tmp.path, 'My App', 'data', 'flutter_assets', 'assets', 'branding', 'icon_1024.png'))..createSync(recursive: true);
      await svc().makeDefault();
      expect(File(userFile()).readAsStringSync(), contains('Icon=${icon.path}\n'));
    });

    test('a failing scheme is reported', () async {
      final r = await DefaultHandlerService(
        isLinux: true,
        isMacOS: false,
        isWindows: false,
        executable: '/opt/softphonepro/softphonepro',
        environment: {'HOME': tmp.path, 'XDG_DATA_DIRS': ''},
        runProcess: (exe, args) async => ProcessResult(1, args.last.endsWith('/tel') ? 2 : 0, '', ''),
      ).makeDefault();
      expect(r.ok, isFalse);
      expect(r.failed, ['tel']);
    });

    test('Exec argument quoting follows the Desktop Entry spec', () {
      expect(desktopExecArg('/opt/softphonepro/softphonepro'), '/opt/softphonepro/softphonepro');
      expect(desktopExecArg('/home/a b/softphonepro'), '"/home/a b/softphonepro"');
      expect(desktopExecArg(r'/x/$y'), r'"/x/\\$y"');
      expect(desktopExecArg('/x/"q"'), r'"/x/\\"q\\""');
      expect(desktopExecArg(r'/x\y'), r'"/x\\\\y"');
      expect(desktopExecArg('/100%/app'), '/100%%/app');
    });
  });

  group('keystore fallback (Linux)', () {
    test('no Secret Service: errors fall back to the file store', () async {
      final fb = MemorySecretsStore();
      final s = KeystoreSecretsStore(fb, storage: _ThrowingStorage(), isLinux: true, probe: () async => SecretServiceState.unlocked);
      await s.write('k', 'v');
      expect(await s.read('k'), 'v');
      expect(fb.data, {'k': 'v'});
      await s.delete('k');
      expect(fb.data, isEmpty);
    });

    test('a hanging keyring times out instead of blocking startup', () async {
      final fb = MemorySecretsStore();
      final s = KeystoreSecretsStore(fb, storage: _HangingStorage(), isLinux: true, probe: () async => SecretServiceState.unlocked, keystoreTimeout: const Duration(milliseconds: 50));
      final sw = Stopwatch()..start();
      await s.write('k', 'v');
      expect(sw.elapsed, lessThan(const Duration(seconds: 2)));
      expect(await s.read('k'), 'v'); // sticky fallback: no second wait
      expect(sw.elapsed, lessThan(const Duration(seconds: 2)));
      expect(fb.data, {'k': 'v'});
    });

    test('unusable Secret Service (locked / unanswering): keystore is never called, file store works', () async {
      final fb = MemorySecretsStore();
      final storage = _CountingStorage();
      final s = KeystoreSecretsStore(fb, storage: storage, isLinux: true, probe: () async => SecretServiceState.locked);
      await s.write('automation', 'tok');
      expect(await s.read('automation'), 'tok');
      await s.delete('automation');
      expect(storage.calls, 0, reason: 'libsecret would block the GTK main thread');
      expect(fb.data, isEmpty);
    });

    test('a probe that never answers or throws falls back within its timeout', () async {
      for (final probe in <Future<SecretServiceState> Function()>[() => Completer<SecretServiceState>().future, () async => throw StateError('no bus')]) {
        final fb = MemorySecretsStore();
        final storage = _CountingStorage();
        final s = KeystoreSecretsStore(fb, storage: storage, isLinux: true, probe: probe, probeTimeout: const Duration(milliseconds: 50));
        final sw = Stopwatch()..start();
        await s.write('k', 'v');
        expect(await s.read('k'), 'v');
        expect(sw.elapsed, lessThan(const Duration(seconds: 2)));
        expect(storage.calls, 0);
        expect(fb.data, {'k': 'v'});
      }
    });

    test('usable Secret Service: the keystore is used', () async {
      final fb = MemorySecretsStore();
      final storage = _CountingStorage();
      final s = KeystoreSecretsStore(fb, storage: storage, isLinux: true, probe: () async => SecretServiceState.unlocked);
      await s.write('k', 'v');
      expect(storage.calls, 1);
      expect(fb.data, isEmpty);
    });

    test('secretServiceState never throws and is bounded (no session bus / no service)', () async {
      final sw = Stopwatch()..start();
      expect(await secretServiceState(timeout: const Duration(milliseconds: 500)), isA<SecretServiceState>());
      expect(sw.elapsed, lessThan(const Duration(seconds: 5)));
    });
  });
}

class _CountingStorage extends FlutterSecureStorage {
  _CountingStorage();
  int calls = 0;
  final Map<String, String> data = {};
  @override
  Future<String?> read({required String key, iOptions, aOptions, lOptions, webOptions, mOptions, wOptions}) async {
    calls++;
    return data[key];
  }

  @override
  Future<void> write({required String key, required String? value, iOptions, aOptions, lOptions, webOptions, mOptions, wOptions}) async {
    calls++;
    data[key] = value!;
  }

  @override
  Future<void> delete({required String key, iOptions, aOptions, lOptions, webOptions, mOptions, wOptions}) async {
    calls++;
    data.remove(key);
  }
}

class _ThrowingStorage extends FlutterSecureStorage {
  const _ThrowingStorage();
  @override
  Future<String?> read({required String key, iOptions, aOptions, lOptions, webOptions, mOptions, wOptions}) =>
      throw PlatformException(code: 'Libsecret error', message: 'Failed to unlock the keyring');
  @override
  Future<void> write({required String key, required String? value, iOptions, aOptions, lOptions, webOptions, mOptions, wOptions}) =>
      throw PlatformException(code: 'Libsecret error', message: 'no secret service');
  @override
  Future<void> delete({required String key, iOptions, aOptions, lOptions, webOptions, mOptions, wOptions}) =>
      throw PlatformException(code: 'Libsecret error');
}

class _HangingStorage extends FlutterSecureStorage {
  const _HangingStorage();
  @override
  Future<String?> read({required String key, iOptions, aOptions, lOptions, webOptions, mOptions, wOptions}) => Completer<String?>().future;
  @override
  Future<void> write({required String key, required String? value, iOptions, aOptions, lOptions, webOptions, mOptions, wOptions}) => Completer<void>().future;
  @override
  Future<void> delete({required String key, iOptions, aOptions, lOptions, webOptions, mOptions, wOptions}) => Completer<void>().future;
}
