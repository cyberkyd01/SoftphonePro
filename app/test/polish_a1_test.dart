import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart' hide EnginePhase;
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:softphonepro/app.dart';
import 'package:softphonepro/models/account_profile.dart';
import 'package:softphonepro/models/app_settings.dart';
import 'package:softphonepro/platform/desktop/launch_args.dart';
import 'package:softphonepro/platform/platform_services.dart';
import 'package:softphonepro/services/accounts_controller.dart';
import 'package:softphonepro/services/app_services.dart';
import 'package:softphonepro/services/dial_rules.dart';
import 'package:softphonepro/services/engine_controller.dart';
import 'package:softphonepro/services/engine_files.dart';
import 'package:softphonepro/services/link_router.dart';
import 'package:softphonepro/services/providers.dart';
import 'package:softphonepro/services/provisioning.dart';
import 'package:softphonepro/services/provisioning_import.dart';
import 'package:softphonepro/services/settings_controller.dart';
import 'package:spcore_dart/spcore_dart.dart';

import 'harness.dart';

class _FailingStartEngine extends FakeSipEngine {
  _FailingStartEngine() : super(timings: FakeTimings.instant);
  @override
  Future<CoreStartResult> start(CoreConfig config) =>
      Future.error(const EngineException(EngineError(code: ErrorCode.invalidParam, message: 'tls.caFile: cannot load')));
}

class _RecEngine extends FakeSipEngine {
  _RecEngine() : super(timings: FakeTimings.instant);
  final modified = <AccountConfig>[];
  bool primaryDown = false;
  final dialled = <String>[];
  CoreConfig? startConfig;
  @override
  Future<CoreStartResult> start(CoreConfig config) {
    startConfig = config;
    return super.start(config);
  }

  @override
  Future<void> modifyAccount(AccountRef acc, AccountConfig config) async {
    modified.add(config);
    await super.modifyAccount(acc, config);
    if (primaryDown && config.registrar == null) simulateRegistrationLost(acc, code: 503);
  }

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

class _MemBundle extends CachingAssetBundle {
  _MemBundle(this.bytes);
  final List<int> bytes;
  @override
  Future<ByteData> load(String key) async => ByteData.sublistView(Uint8List.fromList(bytes));
}

Future<void> _pumpWith(WidgetTester tester, TestEnv env, List<dynamic> extra, {EngineFactory? factory}) async {
  tester.view.physicalSize = const Size(420, 900) * 2;
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.reset);
  final overrides = [
    appDatabaseProvider.overrideWithValue(env.db),
    secretsStoreProvider.overrideWithValue(env.secrets),
    bootDataProvider.overrideWithValue(env.boot),
    engineFactoryProvider.overrideWithValue(factory ?? ({required bool simulator}) async => EngineHandle(env.engine, demo: false)),
    connectivityStreamProvider.overrideWithValue(const Stream.empty()),
    recordingsDirProvider.overrideWithValue(() async => env.tempDir.path),
    ...extra.cast<Override>(),
  ];
  await tester.pumpWidget(ProviderScope(overrides: overrides, child: const SoftphoneApp()));
  await settle(tester, env.engine);
}

void main() {
  group('engine files and core config', () {
    test('CA bundle is copied only when changed; log rotates', () async {
      final dir = Directory.systemTemp.createTempSync('a1files');
      addTearDown(() => dir.deleteSync(recursive: true));
      final f1 = await prepareEngineFiles(supportDir: dir, bundle: _MemBundle([1, 2, 3]));
      expect(File(f1.caFile!).readAsBytesSync(), [1, 2, 3]);
      final m1 = File(f1.caFile!).lastModifiedSync();
      await Future<void>.delayed(const Duration(milliseconds: 20));
      await prepareEngineFiles(supportDir: dir, bundle: _MemBundle([1, 2, 3]));
      expect(File(f1.caFile!).lastModifiedSync(), m1);
      final f2 = await prepareEngineFiles(supportDir: dir, bundle: _MemBundle([9, 9]));
      expect(File(f2.caFile!).readAsBytesSync(), [9, 9]);
      expect(f2.logFile, endsWith('logs${Platform.pathSeparator}engine.log'));

      final log = File(f2.logFile!)..writeAsStringSync('x' * 100);
      for (var i = 0; i < 5; i++) {
        File(log.path).writeAsStringSync('gen$i${'x' * 100}');
        await rotateLog(log, maxBytes: 50);
      }
      expect(File('${log.path}.1').existsSync(), isTrue);
      expect(File('${log.path}.3').existsSync(), isTrue);
      expect(File('${log.path}.4').existsSync(), isFalse);
      expect(log.existsSync(), isFalse);
    });

    test('buildCoreConfig sets CA file, custom CA override, jitter buffer, ptime, log file', () {
      const files = EngineFiles(caFile: '/s/cacert.pem', logFile: '/s/logs/engine.log');
      var c = buildCoreConfig(const AppSettings(), files: files);
      expect(c.transports.tls.caFile, '/s/cacert.pem');
      expect(c.logFile, '/s/logs/engine.log');
      expect(c.media.ptime, 20);
      c = buildCoreConfig(const AppSettings({'customCaFile': '/my/ca.pem', 'jbInitMs': 60, 'jbMinPreMs': 40, 'jbMaxPreMs': 80, 'jbMaxMs': 200, 'ptime': 40}), files: files);
      expect(c.transports.tls.caFile, '/my/ca.pem');
      expect(c.media.jb, const JbConfig(initMs: 60, minPreMs: 40, maxPreMs: 80, maxMs: 200));
      expect(c.media.ptime, 40);
    });

    test('the bundled asset is a real PEM bundle', () {
      final s = File('assets/certs/cacert.pem').readAsStringSync();
      expect(s, contains('BEGIN CERTIFICATE'));
      expect(File('assets/certs/README').readAsStringSync(), contains('MPL'));
    });
  });

  group('link routing', () {
    test('provision links need https (localhost may use http)', () {
      expect(classifyLink(Uri.parse('softphonepro://provision?url=https%3A%2F%2Fpbx.test%2Fp.json')), isA<ProvisionLinkAction>());
      expect(classifyLink(Uri.parse('softphonepro://provision?url=http%3A%2F%2Flocalhost%3A8080%2Fp.json')), isA<ProvisionLinkAction>());
      expect(classifyLink(Uri.parse('softphonepro://provision?url=http%3A%2F%2F127.0.0.1%2Fp.json')), isA<ProvisionLinkAction>());
      expect(classifyLink(Uri.parse('softphonepro://provision?url=http%3A%2F%2Fevil.test%2Fp.json')), isA<RejectedLinkAction>());
      expect(classifyLink(Uri.parse('softphonepro://provision')), isA<RejectedLinkAction>());
    });
    test('lan links go to LAN connect', () {
      final a = classifyLink(Uri.parse('softphonepro://lan?h=192.168.1.20&p=4711&id=ab&n=Desk'));
      expect(a, isA<LanLinkAction>());
      expect((a as LanLinkAction).target.port, 4711);
      expect(classifyLink(Uri.parse('softphonepro://lan?h=x')), isA<RejectedLinkAction>());
    });
    test('call-ish links go to the dialer', () {
      for (final u in ['sip:alice@example.com', 'sips:bob@x.org', 'tel:+1555', 'callto:100', 'softphonepro://call?number=100']) {
        expect(classifyLink(Uri.parse(u)), isA<DialLinkAction>(), reason: u);
      }
      expect((classifyLink(Uri.parse('softphonepro://call?number=100')) as DialLinkAction).target, '100');
    });
    test('CLI flags become local intents; links cannot forge them', () {
      var a = parseLaunchArgs(['--provision', '/tmp/p.json']);
      expect(classifyLink(a.link!), isA<ProvisionCliAction>());
      expect((classifyLink(a.link!) as ProvisionCliAction).source, '/tmp/p.json');
      a = parseLaunchArgs(['--dial=sip:100@x.org', '--minimized']);
      expect((classifyLink(a.link!) as DialCliAction).target, 'sip:100@x.org');
      expect(a.minimized, isTrue);
      expect(parseLink('softphonepro-cli://provision?v=/etc/passwd'), isNull);
      expect(parseLaunchArgs(['--dial']).link, isNull);
    });
  });

  group('dial plan', () {
    test('strip prefix, plus replacement and default country prefix', () {
      expect(const DialRules(stripPrefix: '9').apply('915551234567').target, '15551234567');
      expect(const DialRules(plusReplacement: '00').apply('+441234567890').target, '00441234567890');
      expect(const DialRules(defaultCountryPrefix: '+44').apply('01234 567890').target, '+441234567890');
      expect(const DialRules(defaultCountryPrefix: '+44').apply('00441234567890').target, '00441234567890');
      expect(const DialRules(defaultCountryPrefix: '+44').apply('+441234567890').target, '+441234567890');
      expect(const DialRules(defaultCountryPrefix: '+44').apply('100').target, '100');
    });
  });

  group('provisioning variables', () {
    test('MAC is stable per install; USER and HOSTNAME present', () async {
      final saved = <String, dynamic>{};
      final v1 = await provisioningVars(settings: {}, save: (c) async => saved.addAll(c));
      expect(v1['MAC'], matches(RegExp(r'^([0-9a-f]{2}:){5}[0-9a-f]{2}$')));
      final v2 = await provisioningVars(settings: saved, save: (c) async => fail('must not regenerate'));
      expect(v2['MAC'], v1['MAC']);
      expect(v1.keys, containsAll(['USER', 'HOSTNAME']));
      final r = Provisioning.parse('{"accounts":[{"username":"u","domain":"d.test","password":"\${MAC}"}]}', vars: v1);
      expect(r.accounts.single.config.password, v1['MAC']);
    });
  });

  group('engine start failure', () {
    testWidgets('blocking error with Retry / network settings / simulator', (tester) async {
      final failing = _FailingStartEngine();
      final env = await TestEnv.create(engine: failing);
      var simulatorRequested = false;
      final working = FakeSipEngine(timings: FakeTimings.instant);
      await _pumpWith(tester, env, [], factory: ({required bool simulator}) async {
        if (simulator) {
          simulatorRequested = true;
          return EngineHandle(working, demo: true, note: 'demo');
        }
        return EngineHandle(failing, demo: false);
      });
      expect(find.byKey(const Key('engine-failure')), findsOneWidget);
      expect(find.textContaining('tls.caFile: cannot load'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
      expect(find.text('Open network settings'), findsOneWidget);
      expect(find.text('Use simulator (demo)'), findsOneWidget);
      expect(simulatorRequested, isFalse, reason: 'no silent fallback');
      final c = containerOf(tester);
      expect(c.read(engineProvider).phase, EnginePhase.failed);
      expect(c.read(engineProvider).libraryLoaded, isTrue);

      await tester.tap(find.byKey(const Key('engine-use-simulator')));
      await settle(tester, working);
      await tester.pump(const Duration(milliseconds: 300));
      expect(simulatorRequested, isTrue);
      expect(find.byKey(const Key('engine-failure')), findsNothing);
      expect(c.read(engineProvider).running, isTrue);
      expect(c.read(engineProvider).demo, isTrue);
    });

    testWidgets('Retry starts the engine again; network settings opens Network', (tester) async {
      final failing = _FailingStartEngine();
      final good = FakeSipEngine(timings: FakeTimings.instant);
      final env = await TestEnv.create(engine: failing);
      var attempts = 0;
      await _pumpWith(tester, env, [], factory: ({required bool simulator}) async {
        attempts++;
        return EngineHandle(attempts >= 3 ? good : failing, demo: false);
      });
      expect(attempts, 1);
      await tester.tap(find.byKey(const Key('engine-retry')));
      await settle(tester, failing);
      expect(attempts, 2);
      expect(find.byKey(const Key('engine-failure')), findsOneWidget);

      await tester.tap(find.byKey(const Key('engine-network-settings')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('engine-failure')), findsNothing);
      expect(find.byKey(const Key('engine-banner-retry')), findsOneWidget);
      expect(find.text('Verify server certificates'), findsOneWidget);

      await tester.tap(find.byKey(const Key('engine-banner-retry')));
      await settle(tester, good);
      await tester.pump(const Duration(milliseconds: 300));
      expect(attempts, 3);
      expect(containerOf(tester).read(engineProvider).running, isTrue);
      expect(find.byKey(const Key('engine-banner-retry')), findsNothing);
    });

    testWidgets('a library that cannot load still falls back to the demo engine', (tester) async {
      final env = await TestEnv.create();
      final demo = FakeSipEngine(timings: FakeTimings.instant);
      await _pumpWith(tester, env, [], factory: ({required bool simulator}) async => EngineHandle(demo, demo: true, note: 'Native engine not available (x)'));
      expect(find.byKey(const Key('engine-failure')), findsNothing);
      expect(containerOf(tester).read(engineProvider).demo, isTrue);
    });

    testWidgets('the engine gets the CA file and log file', (tester) async {
      final rec = _RecEngine();
      final env = await TestEnv.create(engine: rec);
      await _pumpWith(tester, env, [
        engineFilesProvider.overrideWithValue(() async => const EngineFiles(caFile: '/s/ca.pem', logFile: '/s/engine.log')),
      ]);
      expect(rec.startConfig!.transports.tls.caFile, '/s/ca.pem');
      expect(rec.startConfig!.logFile, '/s/engine.log');
    });
  });

  group('links in the app', () {
    testWidgets('provision link: confirm, import, onboarding completes', (tester) async {
      final env = await TestEnv.create(settings: const AppSettings());
      final platform = _LinkPlatform();
      final client = MockClient((req) async {
        expect(req.url.host, 'prov.test');
        return http.Response('{"version":1,"accounts":[{"username":"u1","password":"p","domain":"pbx.test","displayName":"\${USER}"}]}', 200);
      });
      await _pumpWith(tester, env, [
        platformServicesProvider.overrideWithValue(platform),
        provisioningClientProvider.overrideWithValue(client),
      ]);
      expect(find.text('Welcome to SoftphonePro'), findsOneWidget);
      platform.links.add(Uri.parse('softphonepro://provision?url=${Uri.encodeComponent('https://prov.test/p.json')}'));
      await settle(tester, env.engine);
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('link-import-confirm')), findsOneWidget);
      expect(find.textContaining('Import configuration from prov.test'), findsOneWidget);
      expect(find.textContaining('add 1 account'), findsOneWidget);
      final c = containerOf(tester);
      expect(c.read(accountsProvider).profiles, isEmpty);
      await tester.tap(find.byKey(const Key('link-import-yes')));
      await settle(tester, env.engine);
      await tester.pumpAndSettle();
      expect(c.read(accountsProvider).profiles.single.config.username, 'u1');
      expect(c.read(settingsProvider).onboardingDone, isTrue);
      expect(find.text('Welcome to SoftphonePro'), findsNothing);
    });

    testWidgets('provision link: cancel imports nothing; http (non-local) is refused', (tester) async {
      final env = await TestEnv.create();
      final platform = _LinkPlatform();
      var fetched = 0;
      final client = MockClient((req) async {
        fetched++;
        return http.Response('{"accounts":[{"username":"u1","password":"p","domain":"pbx.test"}]}', 200);
      });
      await _pumpWith(tester, env, [platformServicesProvider.overrideWithValue(platform), provisioningClientProvider.overrideWithValue(client)]);
      platform.links.add(Uri.parse('softphonepro://provision?url=${Uri.encodeComponent('http://evil.test/p.json')}'));
      await settle(tester, env.engine);
      expect(fetched, 0);
      platform.links.add(Uri.parse('softphonepro://provision?url=${Uri.encodeComponent('https://prov.test/p.json')}'));
      await settle(tester, env.engine);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(containerOf(tester).read(accountsProvider).profiles, isEmpty);
    });

    testWidgets('sip link fills the dialer; with "call links immediately" it dials', (tester) async {
      final rec = _RecEngine();
      final env = await TestEnv.create(engine: rec, profiles: [testProfile()]);
      final platform = _LinkPlatform();
      await _pumpWith(tester, env, [platformServicesProvider.overrideWithValue(platform)]);
      await waitRegistered(tester, env);
      platform.links.add(Uri.parse('sip:alice@example.com'));
      await settle(tester, rec);
      expect(containerOf(tester).read(dialInputProvider), 'alice@example.com');
      expect(rec.dialled, isEmpty);

      await tester.runAsync(() => containerOf(tester).read(settingsProvider.notifier).update({'callLinksImmediately': true}));
      platform.links.add(Uri.parse('tel:+15550100'));
      await settle(tester, rec);
      expect(rec.dialled, hasLength(1));
      expect(rec.dialled.single, contains('15550100'));
    });

    testWidgets('--dial places the call even with the setting off', (tester) async {
      final rec = _RecEngine();
      final env = await TestEnv.create(engine: rec, profiles: [testProfile()]);
      final platform = _LinkPlatform();
      await _pumpWith(tester, env, [platformServicesProvider.overrideWithValue(platform)]);
      await waitRegistered(tester, env);
      platform.links.add(parseLaunchArgs(['--dial', '1002']).link!);
      await settle(tester, rec);
      expect(rec.dialled, ['1002']);
    });

    testWidgets('--provision <file> imports without a prompt', (tester) async {
      final env = await TestEnv.create(settings: const AppSettings());
      final f = File('${env.tempDir.path}/prov.json')..writeAsStringSync('{"accounts":[{"username":"cli1","password":"p","domain":"pbx.test"}]}');
      final platform = _LinkPlatform();
      await _pumpWith(tester, env, [platformServicesProvider.overrideWithValue(platform)]);
      platform.links.add(parseLaunchArgs(['--provision', f.path]).link!);
      for (var i = 0; i < 6; i++) {
        await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
        await tester.pump(const Duration(milliseconds: 50));
      }
      await settle(tester, env.engine);
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
      final c = containerOf(tester);
      expect(c.read(accountsProvider).profiles.single.config.username, 'cli1');
      expect(c.read(settingsProvider).onboardingDone, isTrue);
    });
  });

  group('registration', () {
    testWidgets('401/403/404 stop auto retries until the user taps register', (tester) async {
      final rec = _RecEngine();
      final env = await TestEnv.create(engine: rec, profiles: [testProfile()]);
      await _pumpWith(tester, env, []);
      await waitRegistered(tester, env);
      final c = containerOf(tester);
      final uid = AccountRef.uid('acc1');
      rec.simulateRegistrationLost(uid, code: 403, error: 'Forbidden (403)');
      await settle(tester, rec);
      expect(c.read(accountsProvider).retryHalted, contains('acc1'));
      await tester.pump(const Duration(minutes: 10));
      await settle(tester, rec);
      expect(c.read(accountsProvider).statusOf('acc1'), AccountStatus.failed, reason: 'no automatic retry');
      expect(c.read(accountsProvider).nextRetry, isEmpty);

      await tester.runAsync(() => c.read(accountsProvider.notifier).register('acc1', true));
      await settle(tester, rec);
      expect(c.read(accountsProvider).statusOf('acc1'), AccountStatus.registered);
      expect(c.read(accountsProvider).retryHalted, isEmpty);
    });

    testWidgets('a profile change re-enables registration after a 401', (tester) async {
      final rec = _RecEngine();
      final env = await TestEnv.create(engine: rec, profiles: [testProfile()]);
      await _pumpWith(tester, env, []);
      await waitRegistered(tester, env);
      final c = containerOf(tester);
      rec.simulateRegistrationLost(AccountRef.uid('acc1'), code: 401, error: 'Unauthorized');
      await settle(tester, rec);
      expect(c.read(accountsProvider).retryHalted, contains('acc1'));
      final p = c.read(accountsProvider).byId('acc1')!;
      await tester.runAsync(() => c.read(accountsProvider.notifier).update(p.copyWith(config: p.config.copyWith(password: 'new'))));
      await settle(tester, rec);
      expect(c.read(accountsProvider).retryHalted, isEmpty);
    });

    testWidgets('transient failures (408) keep retrying with backoff', (tester) async {
      final rec = _RecEngine();
      final env = await TestEnv.create(engine: rec, profiles: [testProfile()]);
      await _pumpWith(tester, env, []);
      await waitRegistered(tester, env);
      final c = containerOf(tester);
      rec.simulateRegistrationLost(AccountRef.uid('acc1'), code: 408);
      await settle(tester, rec);
      expect(c.read(accountsProvider).retryHalted, isEmpty);
      expect(c.read(accountsProvider).nextRetry, contains('acc1'));
      await tester.pump(const Duration(seconds: 12));
      await settle(tester, rec);
      expect(c.read(accountsProvider).statusOf('acc1'), AccountStatus.registered);
    });

    testWidgets('engine restart re-adds every account (sync race)', (tester) async {
      final engines = <_RecEngine>[_RecEngine()];
      final env = await TestEnv.create(engine: engines.first, profiles: [testProfile(), testProfile(id: 'acc2', user: '1002').copyWith(isDefault: false)]);
      var n = 0;
      await _pumpWith(tester, env, [], factory: ({required bool simulator}) async {
        if (n++ > 0) engines.add(_RecEngine());
        return EngineHandle(engines.last, demo: false);
      });
      await waitRegistered(tester, env);
      final c = containerOf(tester);
      // A sync is queued right before the restart bumps the generation.
      unawaited(c.read(accountsProvider.notifier).setDnd('acc1', false));
      await tester.runAsync(() => c.read(engineProvider.notifier).restart());
      expect(engines, hasLength(2));
      for (var i = 0; i < 4; i++) {
        await settle(tester, engines.last);
      }
      await tester.runAsync(() => c.read(accountsProvider.notifier).settled());
      for (var i = 0; i < 4; i++) {
        await settle(tester, engines.last);
      }
      expect(c.read(accountsProvider).statusOf('acc1'), AccountStatus.registered);
      expect(c.read(accountsProvider).statusOf('acc2'), AccountStatus.registered);
      final ids = ((await tester.runAsync(engines.last.listAccounts))!).map((a) => a.uid).toSet();
      expect(ids, containsAll(['acc1', 'acc2']));
    });

    testWidgets('failover to the backup registrar after 3 failures and back to the primary', (tester) async {
      AccountsController.primaryProbeEvery = const Duration(minutes: 5);
      final rec = _RecEngine();
      final prof = testProfile().copyWith(backupRegistrar: 'backup.test:5060');
      final env = await TestEnv.create(engine: rec, profiles: [prof]);
      await _pumpWith(tester, env, []);
      await waitRegistered(tester, env);
      final c = containerOf(tester);
      final uid = AccountRef.uid('acc1');
      for (var i = 0; i < 3; i++) {
        rec.simulateRegistrationLost(uid, code: 408);
        await settle(tester, rec);
      }
      expect(c.read(accountsProvider).usingBackup, contains('acc1'));
      expect(rec.modified.last.registrar, 'sip:backup.test:5060');
      expect(c.read(noticeProvider)?.message, contains('backup server'));

      // Primary probe after 5 minutes: still down -> back on the backup.
      rec.primaryDown = true;
      final before = rec.modified.length;
      await tester.pump(const Duration(minutes: 5, seconds: 1));
      await settle(tester, rec);
      await settle(tester, rec);
      expect(rec.modified.length, greaterThanOrEqualTo(before + 2));
      expect(rec.modified.last.registrar, 'sip:backup.test:5060');
      expect(c.read(accountsProvider).usingBackup, contains('acc1'));

      // Next probe: the primary answers again.
      rec.primaryDown = false;
      await tester.pump(const Duration(minutes: 5, seconds: 1));
      await settle(tester, rec);
      await settle(tester, rec);
      expect(c.read(accountsProvider).usingBackup, isEmpty);
      expect(c.read(accountsProvider).statusOf('acc1'), AccountStatus.registered);
    });
  });

  group('feature codes', () {
    testWidgets('DND toggle dials *78 / *79 silently when enabled', (tester) async {
      AccountsController.featureCodeHold = const Duration(milliseconds: 200);
      addTearDown(() => AccountsController.featureCodeHold = const Duration(seconds: 3));
      final rec = _RecEngine();
      final env = await TestEnv.create(
        engine: rec,
        profiles: [testProfile()],
        settings: const AppSettings({'onboardingDone': true, 'syncFeatureCodes': true}),
      );
      await _pumpWith(tester, env, []);
      await waitRegistered(tester, env);
      final c = containerOf(tester);
      await tester.runAsync(() => c.read(accountsProvider.notifier).setDnd('acc1', true));
      await settle(tester, rec);
      expect(rec.dialled, ['*78']);
      expect(rec.activeCallCount, 1);
      // The hold timer was created inside runAsync, i.e. on the real clock.
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 500)));
      await settle(tester, rec);
      expect(rec.activeCallCount, 0, reason: 'hung up after the hold time');
      await tester.runAsync(() => c.read(accountsProvider.notifier).setDnd('acc1', false));
      await settle(tester, rec);
      expect(rec.dialled, ['*78', '*79']);
    });

    testWidgets('forwarding toggle dials forwardOn with the target; off by default', (tester) async {
      final rec = _RecEngine();
      final env = await TestEnv.create(engine: rec, profiles: [testProfile()]);
      await _pumpWith(tester, env, []);
      await waitRegistered(tester, env);
      final c = containerOf(tester);
      final p = c.read(accountsProvider).byId('acc1')!;
      await tester.runAsync(() => c.read(accountsProvider.notifier).update(p.copyWith(dnd: true)));
      await settle(tester, rec);
      expect(rec.dialled, isEmpty, reason: 'opt-in setting is off');

      await tester.runAsync(() => c.read(settingsProvider.notifier).update({'syncFeatureCodes': true}));
      final p2 = c.read(accountsProvider).byId('acc1')!;
      await tester.runAsync(() => c.read(accountsProvider.notifier).update(p2.copyWith(forwarding: const ForwardingConfig(mode: ForwardMode.always, target: '1002'))));
      await settle(tester, rec);
      expect(rec.dialled, ['*721002']);
    });
  });

  group('audio hot-plug', () {
    testWidgets('MediaDevicesChangedEvent refreshes the device provider revision', (tester) async {
      final rec = _RecEngine();
      final env = await TestEnv.create(engine: rec);
      await _pumpWith(tester, env, []);
      final c = containerOf(tester);
      final r0 = c.read(deviceRevisionProvider);
      rec.simulateDevicesChanged((await tester.runAsync(rec.audioDevices))!);
      await settle(tester, rec);
      expect(c.read(deviceRevisionProvider), greaterThan(r0));
    });

    testWidgets('desktop polling refreshes devices on a timer and stops', (tester) async {
      final rec = _RecEngine();
      final env = await TestEnv.create(engine: rec);
      await _pumpWith(tester, env, []);
      final c = containerOf(tester);
      final ctl = c.read(engineProvider.notifier);
      final r0 = c.read(deviceRevisionProvider);
      ctl.startDevicePolling(every: const Duration(seconds: 10));
      await tester.pump(const Duration(seconds: 21));
      expect(c.read(deviceRevisionProvider), greaterThanOrEqualTo(r0 + 2));
      ctl.stopDevicePolling();
      final r1 = c.read(deviceRevisionProvider);
      await tester.pump(const Duration(seconds: 30));
      expect(c.read(deviceRevisionProvider), r1);
    });
  });

  group('settings UI', () {
    testWidgets('new settings are reachable', (tester) async {
      final env = await TestEnv.create();
      await _pumpWith(tester, env, []);
      final c = containerOf(tester);
      await tester.runAsync(() => c.read(settingsProvider.notifier).update({'ptime': 40, 'jbMaxMs': 200}));
      expect(c.read(settingsProvider).ptime, 40);
      expect(const AppSettings().callLinksImmediately, isFalse);
      expect(const AppSettings().syncFeatureCodes, isFalse);
    });
  });
}
