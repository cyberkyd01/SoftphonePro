import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:softphonepro/app.dart';
import 'package:softphonepro/automation/automation_service.dart';
import 'package:softphonepro/diagnostics/export_service.dart';
import 'package:softphonepro/models/app_settings.dart';
import 'package:softphonepro/platform/android/android_platform_services.dart';
import 'package:softphonepro/platform/desktop/launch_args.dart';
import 'package:softphonepro/platform/platform_services.dart';
import 'package:softphonepro/services/accounts_controller.dart';
import 'package:softphonepro/services/app_services.dart';
import 'package:softphonepro/services/link_router.dart';
import 'package:softphonepro/services/providers.dart';
import 'package:softphonepro/services/provisioning.dart';
import 'package:softphonepro/services/provisioning_import.dart';
import 'package:softphonepro/services/settings_controller.dart';
import 'package:spcore_dart/spcore_dart.dart';

import 'harness.dart';

class _RecEngine extends FakeSipEngine {
  _RecEngine() : super(timings: FakeTimings.instant);
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

Future<void> _pump(WidgetTester tester, TestEnv env, List<Override> extra) async {
  tester.view.physicalSize = const Size(420, 900) * 2;
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(ProviderScope(overrides: [...env.overrides, ...extra], child: const SoftphoneApp()));
  await settle(tester, env.engine);
}

Uri _provLink(String url) => Uri.parse('softphonepro://provision?url=${Uri.encodeComponent(url)}');

void main() {
  group('C2: links delivered by the OS can never be CLI actions', () {
    test('softphonepro-cli from the OS is rejected on every platform', () {
      final forged = Uri.parse('softphonepro-cli://dial?v=600');
      expect(isLocalLaunchLink(forged), isFalse);
      expect(classifyLink(forged), isA<RejectedLinkAction>());
      expect(classifyLink(Uri.parse('softphonepro-cli://provision?v=https://attacker.test/p.json')), isA<RejectedLinkAction>());
      expect(classifyLink(forged, isLocal: false), isA<RejectedLinkAction>());
      // A Uri built to look identical to a real launch link is still not local.
      final a = parseLaunchArgs(['--dial', '600']).link!;
      expect(isLocalLaunchLink(a), isTrue);
      expect(isLocalLaunchLink(Uri.parse(a.toString())), isFalse);
      expect(classifyLink(a, isLocal: true), isA<DialCliAction>());
    });

    test('allowed schemes pass, others are refused', () {
      for (final u in ['tel:600', 'sip:a@b.org', 'sips:a@b.org', 'callto:100', 'softphonepro://call?number=1']) {
        expect(classifyLink(Uri.parse(u)), isA<DialLinkAction>(), reason: u);
        expect(parseLink(u), isNotNull, reason: u);
      }
      for (final u in ['http://x.test', 'intent://x#Intent;end', 'file:///etc/passwd', 'content://x/y', 'javascript:alert(1)', 'softphonepro-cli://dial?v=1']) {
        expect(parseLink(u), isNull, reason: u);
        expect(classifyLink(Uri.parse(u)), isA<RejectedLinkAction>(), reason: u);
      }
    });

    test('Android link events go through the allowlist parser', () {
      final p = AndroidPlatformServices();
      final got = <Uri>[];
      p.incomingLinks.listen(got.add);
      p.debugDeliverEvent({'type': 'link', 'uri': 'softphonepro-cli://dial?v=600'});
      p.debugDeliverEvent({'type': 'link', 'uri': 'https://evil.test/'});
      p.debugDeliverEvent({'type': 'link', 'uri': 'tel:600'});
      return Future<void>.delayed(Duration.zero).then((_) => expect(got.map((e) => e.toString()), ['tel:600']));
    });

    testWidgets('an OS-delivered softphonepro-cli dial link places no call', (tester) async {
      final e = _RecEngine();
      final env = await TestEnv.create(engine: e, profiles: [testProfile(id: 'acc1', user: '1016')]);
      final platform = _LinkPlatform();
      await _pump(tester, env, [platformServicesProvider.overrideWithValue(platform)]);
      platform.links.add(Uri.parse('softphonepro-cli://dial?v=600'));
      for (var i = 0; i < 4; i++) {
        await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
        await tester.pump(const Duration(milliseconds: 300));
      }
      expect(e.dialled, isEmpty);
    });

    testWidgets('an OS-delivered softphonepro-cli provision link imports nothing', (tester) async {
      final env = await TestEnv.create();
      final platform = _LinkPlatform();
      var fetched = false;
      final client = MockClient((req) async {
        fetched = true;
        return http.Response('{"accounts":[{"username":"evil","domain":"a.test"}],"settings":{"automationEnabled":true}}', 200);
      });
      await _pump(tester, env, [platformServicesProvider.overrideWithValue(platform), provisioningClientProvider.overrideWithValue(client)]);
      platform.links.add(Uri.parse('softphonepro-cli://provision?v=https://attacker.test/p.json'));
      await settle(tester, env.engine);
      await tester.pumpAndSettle();
      expect(fetched, isFalse);
      expect(containerOf(tester).read(accountsProvider).profiles, isEmpty);
      expect(containerOf(tester).read(settingsProvider).automationEnabled, isFalse);
    });

    testWidgets('a real --dial launch argument still dials', (tester) async {
      final e = _RecEngine();
      final env = await TestEnv.create(engine: e, profiles: [testProfile(id: 'acc1', user: '1016')]);
      final platform = _LinkPlatform();
      await _pump(tester, env, [platformServicesProvider.overrideWithValue(platform)]);
      platform.links.add(parseLaunchArgs(['--dial', '600']).link!);
      for (var i = 0; i < 4; i++) {
        await settle(tester, e);
      }
      expect(e.dialled, ['600']);
    });
  });

  group('C2c: automation service is desktop only', () {
    for (final tp in [TargetPlatform.android, TargetPlatform.iOS]) {
      test('does not start on $tp even when enabled in the settings', () async {
        final env = await TestEnv.create(
          settings: const AppSettings({
            'onboardingDone': true,
            'automationEnabled': true,
            'automationPort': 0,
            'automationToken': 'test-token-0123456789abcdef0123456789abcdef',
          }),
        );
        final c = ProviderContainer(overrides: env.overridesWith(automationSupported: false));
        addTearDown(c.dispose);
        c.read(appServicesProvider);
        await Future<void>.delayed(const Duration(milliseconds: 200));
        expect(c.read(automationServiceProvider).running, isFalse);
        expect(c.read(automationServiceProvider).port, 0);
      });
    }
    test('platform predicate', () {
      for (final tp in TargetPlatform.values) {
        debugDefaultTargetPlatformOverride = tp;
        final desktop = tp == TargetPlatform.macOS || tp == TargetPlatform.windows || tp == TargetPlatform.linux;
        expect(automationSupportedOnThisPlatform(), desktop, reason: '$tp');
      }
      debugDefaultTargetPlatformOverride = null;
    });
  });

  group('M2: provisioning export allowlist', () {
    test('never contains automation, app lock, instance id or update state', () {
      const secret = 'S3cretTokenValue0123456789abcdef';
      final all = const AppSettings({
        'automationToken': secret,
        'automationEnabled': true,
        'automationOrigins': ['https://crm.example.com'],
        'automationPort': 7771,
        'instanceMac': '02:aa:bb:cc:dd:ee',
        'updateCheck': true,
        'updateLastCheck': 123,
        'updateSkipVersion': '9.9',
        'appLock': true,
        'appLockMinutes': 5,
        'appLockBiometrics': false,
        'onboardingDone': true,
        'customCaFile': '/home/me/ca.pem',
        'ptime': 30,
        'stripPrefix': '9',
      }).toJson();
      final out = Provisioning.export(const [], all);
      for (final bad in [secret, 'automation', 'instanceMac', '02:aa:bb', 'appLock', 'update', 'onboardingDone', 'customCaFile', 'ca.pem']) {
        expect(out, isNot(contains(bad)), reason: bad);
      }
      final settings = (jsonDecode(out) as Map)['settings'] as Map;
      expect(settings, {'ptime': 30, 'stripPrefix': '9'});
    });

    test('every exported key is a real user-facing setting', () {
      for (final k in Provisioning.exportableSettings) {
        expect(k.startsWith('automation') || k.startsWith('appLock') || k.startsWith('update') || k == 'instanceMac' || k == 'onboardingDone', isFalse, reason: k);
      }
    });
  });

  group('M3: web-link provisioning consent', () {
    testWidgets('dialog flags sensitive items; auto-answer is off unless accepted', (tester) async {
      final env = await TestEnv.create(settings: const AppSettings());
      final platform = _LinkPlatform();
      final client = MockClient((req) async => http.Response(
        jsonEncode({
          'version': 1,
          'accounts': [
            {'username': 'u1', 'password': 'p', 'domain': 'pbx.test'},
            {
              'label': 'X',
              'sip': {'username': 'u2', 'password': 'p', 'domain': 'pbx.test'},
              'autoAnswer': {'enabled': true},
              'forwarding': {'mode': 'always', 'target': '0900123'},
            },
          ],
          'settings': {
            'autoAnswer': true,
            'stripPrefix': '0',
            'callLinksImmediately': true,
            'lanAllowIntercom': true,
            'sipTrace': true,
            'ptime': 30,
            'automationToken': 'x' * 32,
            'instanceMac': 'zz',
          },
        }),
        200,
      ));
      await _pump(tester, env, [platformServicesProvider.overrideWithValue(platform), provisioningClientProvider.overrideWithValue(client)]);
      platform.links.add(_provLink('https://prov.test/p.json'));
      await settle(tester, env.engine);
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('link-import-confirm')), findsOneWidget);
      for (final k in ['autoAnswer', 'forwarding', 'intercom', 'dialRewrite', 'linksImmediately', 'diagnostics']) {
        expect(find.byKey(Key('link-import-flag-$k')), findsOneWidget, reason: k);
      }
      expect(find.textContaining('0900123'), findsOneWidget);
      expect(find.byKey(const Key('link-import-allow-autoanswer')), findsOneWidget);
      await tester.tap(find.byKey(const Key('link-import-yes')));
      await settle(tester, env.engine);
      await tester.pumpAndSettle();
      final c = containerOf(tester);
      expect(c.read(accountsProvider).profiles.length, 2);
      expect(c.read(accountsProvider).profiles.any((p) => p.autoAnswer.enabled), isFalse);
      final st = c.read(settingsProvider);
      expect(st.autoAnswer, isFalse);
      expect(st.stripPrefix, '0');
      expect(st.automationToken, '');
      expect(st.toJson().containsKey('instanceMac') && st.toJson()['instanceMac'] == 'zz', isFalse);
    });

    testWidgets('auto-answer applies only when the checkbox is ticked', (tester) async {
      final env = await TestEnv.create(settings: const AppSettings());
      final platform = _LinkPlatform();
      final client = MockClient((req) async => http.Response(
        jsonEncode({'accounts': [{'label': 'X', 'sip': {'username': 'u2', 'password': 'p', 'domain': 'pbx.test'}, 'autoAnswer': {'enabled': true}}]}),
        200,
      ));
      await _pump(tester, env, [platformServicesProvider.overrideWithValue(platform), provisioningClientProvider.overrideWithValue(client)]);
      platform.links.add(_provLink('https://prov.test/p.json'));
      await settle(tester, env.engine);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('link-import-allow-autoanswer')));
      await tester.pump();
      await tester.tap(find.byKey(const Key('link-import-yes')));
      await settle(tester, env.engine);
      await tester.pumpAndSettle();
      expect(containerOf(tester).read(accountsProvider).profiles.single.autoAnswer.enabled, isTrue);
    });

    for (final body in [
      {'settings': {'tlsVerify': false}},
      {'settings': {'customCaFile': '/tmp/evil.pem'}},
    ]) {
      testWidgets('refuses ${body['settings']} from a web link entirely', (tester) async {
        final env = await TestEnv.create(settings: const AppSettings());
        final platform = _LinkPlatform();
        final client = MockClient((req) async => http.Response(
          jsonEncode({'accounts': [{'username': 'u1', 'password': 'p', 'domain': 'pbx.test'}], ...body}),
          200,
        ));
        await _pump(tester, env, [platformServicesProvider.overrideWithValue(platform), provisioningClientProvider.overrideWithValue(client)]);
        platform.links.add(_provLink('https://prov.test/p.json'));
        await settle(tester, env.engine);
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('link-import-confirm')), findsNothing);
        expect(find.textContaining('file or the command line'), findsOneWidget);
        expect(containerOf(tester).read(accountsProvider).profiles, isEmpty);
        expect(containerOf(tester).read(settingsProvider).tlsVerify, isTrue);
        expect(containerOf(tester).read(settingsProvider).customCaFile, '');
      });
    }

    test('refusedWebSetting / sanitizeForWebLink', () {
      expect(refusedWebSetting(const ProvisioningResult(settings: {'tlsVerify': true})), isNull);
      expect(refusedWebSetting(const ProvisioningResult(settings: {'tlsVerify': false})), 'tlsVerify');
      expect(refusedWebSetting(const ProvisioningResult(settings: {'customCaFile': ''})), isNull);
      final r = sanitizeForWebLink(const ProvisioningResult(settings: {'appLock': true, 'updateCheck': false, 'onboardingDone': true, 'ptime': 40}), allowAutoAnswer: false);
      expect(r.settings, {'ptime': 40});
    });
  });

  group('M4: diagnostic bundle redacts the engine log tail', () {
    test('digest Authorization and a=crypto lines are masked', () {
      final dir = Directory.systemTemp.createTempSync('enginelog');
      addTearDown(() => dir.deleteSync(recursive: true));
      final f = File('${dir.path}/engine.log')
        ..writeAsStringSync(
          'INVITE sip:bob@x SIP/2.0\r\n'
          'Authorization: Digest username="alice", realm="x", nonce="NONCEVALUE123", response="deadbeefcafe0123456789", cnonce="CNONCE99"\r\n'
          'a=crypto:1 AES_CM_128_HMAC_SHA1_80 inline:WVNfX19zZWNyZXRrZXlfc2VjcmV0a2V5c2VjcmV0\r\n'
          'sip:alice:hunter2pass@pbx.test\r\n'
          'plain line stays\r\n',
        );
      final out = redactedEngineLogTail(f.path);
      for (final leak in ['deadbeefcafe', 'NONCEVALUE123', 'CNONCE99', 'WVNfX19zZWNyZXRrZXlf', 'hunter2pass']) {
        expect(out, isNot(contains(leak)), reason: leak);
      }
      expect(out, contains('plain line stays'));
      expect(out, contains('[REDACTED]'));
      // The raw reader is unchanged (proves the test data really holds secrets).
      expect(readEngineLogTail(f.path), contains('deadbeefcafe'));
    });
  });

  group('MINOR 2: LAN links ask first', () {
    testWidgets('softphonepro://lan shows a confirm dialog; cancel does not connect', (tester) async {
      final env = await TestEnv.create();
      final platform = _LinkPlatform();
      await _pump(tester, env, [platformServicesProvider.overrideWithValue(platform)]);
      platform.links.add(Uri.parse('softphonepro://lan?h=192.168.1.20&p=4711&id=ab&n=Desk'));
      await settle(tester, env.engine);
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('link-lan-confirm')), findsOneWidget);
      expect(find.textContaining('Connect to device Desk (192.168.1.20)?'), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('link-lan-confirm')), findsNothing);
    });
  });

  group('MINOR 4: intercom asks by default', () {
    test('default is true; an explicit false is kept', () {
      expect(const AppSettings().lanIntercomPrompt, isTrue);
      expect(const AppSettings({'lanIntercomPrompt': false}).lanIntercomPrompt, isFalse);
    });
  });
}
