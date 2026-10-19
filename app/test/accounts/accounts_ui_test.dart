import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:softphonepro/models/account_profile.dart';
import 'package:softphonepro/models/provider_templates.dart';
import 'package:softphonepro/services/accounts_controller.dart';
import 'package:softphonepro/services/app_services.dart';
import 'package:softphonepro/ui/pages/add_account.dart';
import 'package:softphonepro/ui/settings/account_editor.dart';
import 'package:softphonepro/core/theme.dart';
import 'package:spcore_dart/spcore_dart.dart';

import '../harness.dart';
import 'package:softphonepro/l10n/app_localizations.dart';

Future<void> pumpPage(WidgetTester tester, TestEnv env, Widget page, {Size size = const Size(412, 915), Brightness brightness = Brightness.light}) async {
  tester.view.physicalSize = size * 2;
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: env.overrides,
      child: Consumer(
        builder: (context, ref, _) {
          ref.watch(appServicesProvider);
          return MaterialApp(localizationsDelegates: AppLocalizations.localizationsDelegates, supportedLocales: AppLocalizations.supportedLocales, debugShowCheckedModeBanner: false, theme: buildTheme(brightness), home: page);
        },
      ),
    ),
  );
  await settle(tester, env.engine);
}

ProviderContainer cont(WidgetTester tester) => ProviderScope.containerOf(tester.element(find.byType(MaterialApp)));

AccountProfile iaxProfile() => templateById('iax2').build(id: 'iax1', username: 'alice', password: 'pw', domain: 'pbx.test', displayName: 'Alice', label: 'Asterisk IAX', port: 4569, iaxContext: 'from-iax');

void main() {
  group('templates', () {
    test('iax2 template builds an IAX2 profile', () {
      final p = iaxProfile();
      expect(p.config.proto, SipProto.iax2);
      expect(p.config.iax.host, 'pbx.test');
      expect(p.config.iax.port, 4569);
      expect(p.config.iax.context, 'from-iax');
      expect(p.config.codecs, ['PCMU/8000/1', 'PCMA/8000/1', 'GSM/8000/1']);
      expect(p.config.useStun, isFalse);
    });

    test('webrtc template is prefilled', () {
      final p = templateById('webrtc').build(id: 'w', username: 'u', password: 'p', domain: 'pbx.test');
      final c = p.config;
      expect(c.transport, AccTransport.wss);
      expect(c.domain, 'pbx.test:8089');
      expect(c.wsPath, '/ws');
      expect(c.srtp, SrtpMode.mandatory);
      expect(c.srtpKeying, [SrtpKeying.dtls]);
      expect(c.ice, isTrue);
      expect(c.rtcpMux, isTrue);
      expect(c.rtcpFb, isTrue);
      // An explicit port is kept.
      final q = templateById('webrtc').build(id: 'w', username: 'u', password: 'p', domain: 'pbx.test:443');
      expect(q.config.domain, 'pbx.test:443');
    });

    test('every template has sane defaults', () {
      for (final t in kProviderTemplates) {
        expect(t.name, isNotEmpty);
        expect(t.regExpires, inInclusiveRange(10, 86400), reason: t.id);
        for (final c in t.codecs) {
          expect(c.split('/'), hasLength(3), reason: '${t.id} codec $c');
        }
      }
      expect(templateById('twilio').notes, isNotEmpty);
      expect(templateById('telnyx').notes, isNotEmpty);
    });

    test('profile json round trip keeps wsPath, rtcpFb and iax', () {
      final j = AccountProfile.fromJson(iaxProfile().toJson(includePassword: true));
      expect(j.config.proto, SipProto.iax2);
      expect(j.config.iax.context, 'from-iax');
      final w = templateById('webrtc').build(id: 'w', username: 'u', password: 'p', domain: 'h');
      final k = AccountProfile.fromJson(w.toJson());
      expect(k.config.wsPath, '/ws');
      expect(k.config.rtcpFb, isTrue);
    });
  });

  test('validators', () {
    expect(validateInt('0', min: 1, max: 65535), isNotNull);
    expect(validateInt('65536', min: 1, max: 65535), isNotNull);
    expect(validateInt('abc'), isNotNull);
    expect(validateInt('4569', min: 1, max: 65535), isNull);
    expect(validateWsPath('ws'), isNotNull);
    expect(validateWsPath('/ws'), isNull);
    expect(validateHost(''), isNotNull);
    expect(validateHost('a b'), isNotNull);
    expect(validateHost('host:99999'), isNotNull);
    expect(validateHost('host:5060'), isNull);
  });

  testWidgets('add IAX2 account via the protocol picker registers with the engine', (tester) async {
    final env = await TestEnv.create();
    await pumpPage(tester, env, Scaffold(body: AddAccountFlow(onDone: () {})));
    await tester.tap(find.descendant(of: find.byKey(const Key('acc-proto')), matching: find.text('IAX2')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('acc-port')), findsOneWidget);
    expect(find.byKey(const Key('acc-notes')), findsOneWidget);
    await tester.enterText(find.byKey(const Key('acc-username')), 'alice');
    await tester.enterText(find.byKey(const Key('acc-password')), 'secret');
    await tester.enterText(find.byKey(const Key('acc-domain')), 'pbx.test');
    await tester.enterText(find.byKey(const Key('acc-port')), '70000');
    await tester.ensureVisible(find.byKey(const Key('acc-save')));
    await tester.tap(find.byKey(const Key('acc-save')));
    await tester.pump();
    expect(find.text('Must be at most 65535'), findsOneWidget);
    await tester.enterText(find.byKey(const Key('acc-port')), '4570');
    await tester.enterText(find.byKey(const Key('acc-context')), 'from-iax');
    await tester.tap(find.byKey(const Key('acc-save')));
    await tester.pump();
    var id = '';
    for (var i = 0; i < 10; i++) {
      await settle(tester, env.engine);
      final a = cont(tester).read(accountsProvider);
      if (a.profiles.isNotEmpty) {
        id = a.profiles.single.id;
        if (a.statusOf(id) == AccountStatus.registered) break;
      }
    }
    final acc = cont(tester).read(accountsProvider);
    final p = acc.profiles.single;
    expect(p.config.proto, SipProto.iax2);
    expect(p.config.iax.port, 4570);
    expect(p.config.iax.context, 'from-iax');
    expect(acc.statusOf(id), AccountStatus.registered);
    final info = acc.infos[id];
    expect(info?.proto, SipProto.iax2);
    expect(info!.acc, greaterThanOrEqualTo(1000));
  });

  testWidgets('add WebRTC gateway account', (tester) async {
    final env = await TestEnv.create();
    await pumpPage(tester, env, Scaffold(body: AddAccountFlow(onDone: () {})));
    await tester.scrollUntilVisible(find.byKey(const Key('tpl-webrtc')), 200, scrollable: find.byType(Scrollable).first);
    await tester.tap(find.byKey(const Key('tpl-webrtc')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('acc-username')), '1001');
    await tester.enterText(find.byKey(const Key('acc-password')), 'pw');
    await tester.enterText(find.byKey(const Key('acc-domain')), 'pbx.test');
    await tester.ensureVisible(find.byKey(const Key('acc-save')));
    await tester.tap(find.byKey(const Key('acc-save')));
    await tester.pump();
    await settle(tester, env.engine);
    final c = cont(tester).read(accountsProvider).profiles.single.config;
    expect(c.transport, AccTransport.wss);
    expect(c.domain, 'pbx.test:8089');
    expect(c.rtcpFb, isTrue);
  });

  testWidgets('editor hides SIP-only groups for IAX2', (tester) async {
    final env = await TestEnv.create(profiles: [iaxProfile().copyWith(isDefault: true)]);
    await pumpPage(tester, env, const AccountEditorPage(accountId: 'iax1'), size: const Size(412, 5000));
    expect(find.text('Protocol'), findsOneWidget);
    expect(find.text('IAX2'), findsOneWidget);
    expect(find.text('Context'), findsOneWidget);
    expect(find.text('REGISTRATION'), findsOneWidget);
    expect(find.text('SERVER AND TRANSPORT'), findsNothing);
    expect(find.text('NAT'), findsNothing);
    expect(find.text('Use STUN'), findsNothing);
    expect(find.text('SECURITY'), findsNothing);
    expect(find.text('ADVANCED MEDIA'), findsNothing);
    expect(find.text('Session timers'), findsNothing);
    expect(find.text('PCMU'), findsOneWidget);
    expect(find.text('GSM'), findsOneWidget);
    expect(find.text('Opus'), findsNothing);
  });

  testWidgets('editor: wsPath shown for wss only and validated', (tester) async {
    final p = templateById('webrtc').build(id: 'w1', username: 'u', password: 'p', domain: 'h').copyWith(isDefault: true);
    final env = await TestEnv.create(profiles: [p]);
    await pumpPage(tester, env, const AccountEditorPage(accountId: 'w1'), size: const Size(412, 5000));
    expect(find.text('Rewrite Contact header'), findsNothing);
    expect(find.text('Keep-alive (s)'), findsNothing);
    expect(find.text('RTCP feedback (AVPF)'), findsOneWidget);
    await tester.tap(find.text('WebSocket path'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'ws');
    await tester.tap(find.text('Save').last);
    await tester.pump();
    expect(find.text('The path must start with "/"'), findsOneWidget);
    await tester.enterText(find.byType(TextField), '/sip');
    await tester.tap(find.text('Save').last);
    await tester.pumpAndSettle();
    expect(find.text('/sip'), findsOneWidget);
  });

  testWidgets('editor: numeric fields validate engine ranges', (tester) async {
    final env = await TestEnv.create(profiles: [testProfile()]);
    await pumpPage(tester, env, const AccountEditorPage(accountId: 'acc1'), size: const Size(412, 5000));
    expect(find.text('WebSocket path'), findsNothing);
    expect(find.text('Keep-alive (s)'), findsOneWidget);
    await tester.tap(find.text('Registration expiry (s)'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '5');
    await tester.tap(find.text('Save').last);
    await tester.pump();
    expect(find.text('Must be at least 10'), findsOneWidget);
    await tester.enterText(find.byType(TextField), '120');
    await tester.tap(find.text('Save').last);
    await tester.pumpAndSettle();
    expect(find.text('120'), findsOneWidget);
  });

  group('goldens', () {
    for (final (name, size) in [('phone', const Size(412, 915)), ('desktop', const Size(1280, 800))]) {
      testWidgets('add account list $name', (tester) async {
        final env = await TestEnv.create();
        await pumpPage(tester, env, Scaffold(body: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 560), child: AddAccountFlow(onDone: () {})))), size: size);
        await expectLater(find.byType(MaterialApp), matchesGoldenFile('goldens/add_list_$name.png'));
      });
      testWidgets('add iax2 form $name', (tester) async {
        final env = await TestEnv.create();
        await pumpPage(tester, env, Scaffold(body: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 560), child: AddAccountFlow(onDone: () {})))), size: size);
        await tester.tap(find.descendant(of: find.byKey(const Key('acc-proto')), matching: find.text('IAX2')));
        await tester.pumpAndSettle();
        await expectLater(find.byType(MaterialApp), matchesGoldenFile('goldens/add_iax_$name.png'));
      });
      testWidgets('editor sip $name', (tester) async {
        final env = await TestEnv.create(profiles: [testProfile()]);
        await pumpPage(tester, env, const AccountEditorPage(accountId: 'acc1'), size: size);
        await expectLater(find.byType(MaterialApp), matchesGoldenFile('goldens/editor_sip_$name.png'));
      });
      testWidgets('editor iax $name', (tester) async {
        final env = await TestEnv.create(profiles: [iaxProfile().copyWith(isDefault: true)]);
        await pumpPage(tester, env, const AccountEditorPage(accountId: 'iax1'), size: size);
        await expectLater(find.byType(MaterialApp), matchesGoldenFile('goldens/editor_iax_$name.png'));
      });
    }
  });
}
