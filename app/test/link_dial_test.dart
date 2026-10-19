import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:softphonepro/app.dart';
import 'package:softphonepro/models/app_settings.dart';
import 'package:softphonepro/platform/desktop/default_handler.dart';
import 'package:softphonepro/platform/desktop/launch_args.dart';
import 'package:softphonepro/platform/platform_services.dart';
import 'package:softphonepro/services/accounts_controller.dart';
import 'package:softphonepro/services/dial_ready.dart';
import 'package:softphonepro/services/providers.dart';
import 'package:softphonepro/services/provisioning.dart';
import 'package:softphonepro/services/provisioning_import.dart';
import 'package:softphonepro/ui/settings/sections.dart';
import 'package:softphonepro/services/settings_controller.dart';
import 'package:softphonepro/storage/app_database.dart';
import 'package:softphonepro/storage/secrets_store.dart';
import 'package:spcore_dart/spcore_dart.dart';

import 'harness.dart';
import 'package:softphonepro/l10n/app_localizations.dart';

/// Engine that records dialled URIs and registers only when told to.
class _SlowRegEngine extends FakeSipEngine {
  _SlowRegEngine() : super(timings: const FakeTimings(register: Duration(seconds: 30), ring: Duration.zero, answer: Duration.zero, transfer: Duration.zero, im: Duration.zero, diag: Duration.zero));
  final dialled = <String>[];
  @override
  Future<CallRef> makeCall({required AccountRef acc, required String uri, Map<String, String>? headers, String? displayName, bool anonymous = false}) {
    dialled.add(uri);
    return super.makeCall(acc: acc, uri: uri, headers: headers, displayName: displayName, anonymous: anonymous);
  }
}

class _LinkPlatform extends NoopPlatformServices {
  final links = StreamController<Uri>.broadcast();
  @override
  Stream<Uri> get incomingLinks => links.stream;
}

/// Gives tests a [Ref] to call link-handler functions with.
final _refProvider = Provider<Ref>((ref) => ref);

Future<void> _pump(WidgetTester tester, TestEnv env, List<Override> extra) async {
  tester.view.physicalSize = const Size(420, 900) * 2;
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(ProviderScope(overrides: [...env.overrides, ...extra], child: const SoftphoneApp()));
  for (var i = 0; i < 3; i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 10)));
    await tester.pump(const Duration(milliseconds: 50));
  }
}

Future<void> _flow(WidgetTester tester, FakeSipEngine e) => settle(tester, e);

void main() {
  group('--dial / links wait for engine and registration', () {
    testWidgets('--dial at launch waits for the account to register, then dials', (tester) async {
      final e = _SlowRegEngine();
      final env = await TestEnv.create(engine: e, profiles: [testProfile(id: 'acc1', user: '1016')]);
      final platform = _LinkPlatform();
      await _pump(tester, env, [platformServicesProvider.overrideWithValue(platform)]);
      final c = containerOf(tester);
      expect(c.read(accountsProvider).statusOf('acc1'), isNot(AccountStatus.registered));

      platform.links.add(parseLaunchArgs(['--dial', '600']).link!);
      for (var i = 0; i < 5; i++) {
        await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
        await tester.pump(const Duration(milliseconds: 500));
      }
      expect(e.dialled, isEmpty, reason: 'must not dial while the account is registering');
      expect(find.textContaining('Could not place the call'), findsNothing);

      await _flow(tester, e); // registration completes
      await _flow(tester, e);
      expect(c.read(accountsProvider).statusOf('acc1'), AccountStatus.registered);
      expect(e.dialled, ['600']);
    });

    testWidgets('a failed registration reports the account state instead of a generic error', (tester) async {
      final e = _SlowRegEngine();
      final env = await TestEnv.create(engine: e, profiles: [testProfile(id: 'acc1', user: '1016')]);
      final platform = _LinkPlatform();
      await _pump(tester, env, [platformServicesProvider.overrideWithValue(platform)]);
      platform.links.add(parseLaunchArgs(['--dial', '600']).link!);
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
      await tester.pump(const Duration(milliseconds: 100));
      e.simulateRegistrationLost(AccountRef.uid('acc1'), code: 403, error: 'Forbidden (403)');
      await _flow(tester, e);
      await tester.pump(const Duration(milliseconds: 200));
      expect(e.dialled, isEmpty);
      expect(find.textContaining('Could not place the call to 600'), findsOneWidget);
    });

    testWidgets('waitForDialReady times out naming the account and its state', (tester) async {
      final e = _SlowRegEngine();
      final env = await TestEnv.create(engine: e, profiles: [testProfile(id: 'acc1', user: '1016')]);
      await _pump(tester, env, []);
      final ref = containerOf(tester).read(_refProvider);
      late DialReadiness r;
      unawaited(waitForDialReady(ref, '600', timeout: const Duration(seconds: 2)).then((v) => r = v));
      await tester.pump(const Duration(seconds: 3));
      expect(r.ok, isFalse);
      expect(r.message, contains('1016@pbx.test'));
      expect(r.message, anyOf(contains('registering'), contains('not registered yet')));
      expect(r.message, contains('2 s'));
    });

    testWidgets('waitForDialReady: ready at once for emergency numbers, IP targets and no account', (tester) async {
      final e = _SlowRegEngine();
      final env = await TestEnv.create(engine: e, profiles: [testProfile(id: 'acc1', user: '1016')]);
      await _pump(tester, env, []);
      final ref = containerOf(tester).read(_refProvider);
      expect((await tester.runAsync(() => waitForDialReady(ref, '911')))!.ok, isTrue);
      expect((await tester.runAsync(() => waitForDialReady(ref, 'sip:bob@10.1.2.3')))!.ok, isTrue);
    });

    testWidgets('provisioning then dialling: the dial waits for the import and the registration', (tester) async {
      final e = _SlowRegEngine();
      final env = await TestEnv.create(engine: e, settings: const AppSettings());
      final f = File('${env.tempDir.path}/prov.json')
        ..writeAsStringSync('{"accounts":[{"username":"1016","password":"pass1016","domain":"pbx.test"}],"settings":{"automationEnabled":true,"automationToken":"${'ab' * 20}","automationPort":0,"dnd":false}}');
      final platform = _LinkPlatform();
      await _pump(tester, env, [platformServicesProvider.overrideWithValue(platform)]);
      final c = containerOf(tester);
      platform.links.add(parseLaunchArgs(['--provision', f.path]).link!);
      platform.links.add(parseLaunchArgs(['--dial', '600']).link!);
      for (var i = 0; i < 6; i++) {
        await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 40)));
        await tester.pump(const Duration(milliseconds: 100));
      }
      expect(c.read(accountsProvider).profiles, hasLength(1));
      // Local command-line provisioning may configure the automation API.
      expect(c.read(settingsProvider).automationEnabled, isTrue);
      expect(c.read(settingsProvider).automationToken, 'ab' * 20);
      for (var i = 0; i < 4; i++) {
        await _flow(tester, e);
      }
      expect(e.dialled, ['600']);
      // Stop the API the provisioning switched on.
      await tester.runAsync(() => c.read(settingsProvider.notifier).update({'automationEnabled': false}));
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
    });
  });

  group('provisioned settings cannot enable the automation API from the web', () {
    test('automation keys are dropped for non-CLI imports', () async {
      final db = await AppDatabase.memory();
      final container = ProviderContainer(overrides: [
        appDatabaseProvider.overrideWithValue(db),
        secretsStoreProvider.overrideWithValue(MemorySecretsStore()),
        bootDataProvider.overrideWithValue(BootData(settings: const AppSettings({'onboardingDone': true}))),
      ]);
      addTearDown(container.dispose);
      final ref = container.read(_refProvider);
      final r = Provisioning.parse('{"settings":{"automationEnabled":true,"automationToken":"x","dnd":true}}');
      await importProvisioningResult(ref, r);
      var s = container.read(settingsProvider);
      expect(s.automationEnabled, isFalse);
      expect(s.automationToken, '');
      expect(s.dnd, isTrue);
      await importProvisioningResult(ref, r, allowAutomation: true);
      s = container.read(settingsProvider);
      expect(s.automationEnabled, isTrue);
      expect(s.automationToken, 'x');
    });
  });

  group('DefaultHandlerService (mocked channel)', () {
    const ch = MethodChannel('test/desktop');
    final calls = <String>[];
    Map<String, Object?> handlers = {};
    Object? setResult = {'ok': true, 'failed': <String>[]};

    setUp(() {
      calls.clear();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(ch, (call) async {
        calls.add(call.method);
        if (call.method == 'defaultHandlers') return handlers;
        if (call.method == 'setDefaultHandler') return setResult;
        return null;
      });
    });
    tearDown(() => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(ch, null));

    test('reads the current handlers per scheme', () async {
      handlers = {
        'sip': {'name': 'Zoiper5', 'bundleId': 'com.securax.zoiper5', 'isSelf': false},
        'tel': {'name': 'FaceTime', 'bundleId': 'com.apple.FaceTime', 'isSelf': false},
        'callto': {'name': 'SoftphonePro', 'bundleId': 'com.softphonepro.softphonepro', 'isSelf': true},
      };
      final svc = DefaultHandlerService(channel: ch, isMacOS: true, isWindows: false);
      expect(svc.supported, isTrue);
      final h = await svc.current();
      expect(h.map((e) => e.scheme), ['sip', 'tel', 'callto']);
      expect(h[0].label, 'Zoiper5');
      expect(h[0].isSelf, isFalse);
      expect(h[2].isSelf, isTrue);
      expect(calls, ['defaultHandlers']);
    });

    test('makeDefault asks macOS and reports failures per scheme', () async {
      final svc = DefaultHandlerService(channel: ch, isMacOS: true, isWindows: false);
      setResult = {'ok': true, 'failed': <String>[]};
      expect((await svc.makeDefault()).ok, isTrue);
      setResult = {'ok': false, 'failed': ['tel']};
      final r = await svc.makeDefault();
      expect(r.ok, isFalse);
      expect(r.failed, ['tel']);
      expect(calls, ['setDefaultHandler', 'setDefaultHandler']);
    });

    test('missing native side degrades quietly', () async {
      final svc = DefaultHandlerService(channel: const MethodChannel('test/none'), isMacOS: true, isWindows: false);
      expect(await svc.current(), isEmpty);
      expect((await svc.makeDefault()).ok, isFalse);
    });

    test('Windows opens the Default apps settings page; other platforms are unsupported', () async {
      final opened = <String>[];
      final win = DefaultHandlerService(channel: ch, isMacOS: false, isWindows: true, openUri: (u) async => opened.add(u));
      expect(win.supported, isTrue);
      expect(await win.current(), isEmpty);
      final r = await win.makeDefault();
      expect(r.ok, isTrue);
      expect(r.openedSettings, isTrue);
      expect(opened, ['ms-settings:defaultapps']);
      expect(calls, isEmpty, reason: 'no native channel call on Windows');

      final other = DefaultHandlerService(channel: ch, isMacOS: false, isWindows: false);
      expect(other.supported, isFalse);
      expect((await other.makeDefault()).ok, isFalse);
    });
  });

  testWidgets('Settings > Calls shows the default-handler tile and calls the service', (tester) async {
    final env = await TestEnv.create(profiles: [testProfile()]);
    final fake = _FakeHandlerService();
    tester.view.physicalSize = const Size(1200, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(ProviderScope(
      overrides: [...env.overrides, defaultHandlerServiceProvider.overrideWithValue(fake)],
      child: const MaterialApp(localizationsDelegates: AppLocalizations.localizationsDelegates, supportedLocales: AppLocalizations.supportedLocales, home: Scaffold(body: CallsSection())),
    ));
    await tester.pump();
    await tester.pump();
    expect(find.text('Make SoftphonePro the default app for sip:, tel: and callto: links'), findsOneWidget);
    expect(find.textContaining('sip: Zoiper5'), findsOneWidget);
    expect(find.textContaining('tel: FaceTime'), findsOneWidget);
    await tester.tap(find.byKey(const Key('make-default-handler')));
    await tester.pump();
    await tester.pump();
    expect(fake.made, 1);
    expect(find.textContaining('now opens sip:'), findsOneWidget);
  });
}

class _FakeHandlerService extends DefaultHandlerService {
  _FakeHandlerService() : super(isMacOS: true, isWindows: false);
  int made = 0;
  @override
  Future<List<SchemeHandler>> current() async => const [
    SchemeHandler(scheme: 'sip', name: 'Zoiper5', bundleId: 'z'),
    SchemeHandler(scheme: 'tel', name: 'FaceTime', bundleId: 'f'),
    SchemeHandler(scheme: 'callto', name: 'Zoom', bundleId: 'zm'),
  ];
  @override
  Future<MakeDefaultResult> makeDefault() async {
    made++;
    return const MakeDefaultResult(ok: true);
  }
}
