import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:softphonepro/core/theme.dart';
import 'package:softphonepro/diagnostics/diagnostics_hub.dart';
import 'package:softphonepro/diagnostics/export_service.dart';
import 'package:softphonepro/diagnostics/network_wizard.dart';
import 'package:softphonepro/diagnostics/sip_trace_controller.dart';
import 'package:softphonepro/models/account_profile.dart';
import 'package:softphonepro/models/app_settings.dart';
import 'package:softphonepro/models/call_record.dart';
import 'package:softphonepro/services/accounts_controller.dart';
import 'package:softphonepro/services/app_services.dart';
import 'package:softphonepro/services/settings_controller.dart';
import 'package:softphonepro/ui/pages/diagnostics/diagnostics_page.dart';
import 'package:softphonepro/ui/pages/diagnostics/quality_widgets.dart';
import 'package:spcore_dart/spcore_dart.dart';

import '../harness.dart';

Future<void> loadInter() async {
  final loader = FontLoader('Inter');
  for (final f in ['Regular', 'Medium', 'SemiBold', 'Bold']) {
    final bytes = File('assets/fonts/Inter-$f.ttf').readAsBytesSync();
    loader.addFont(Future.value(ByteData.view(bytes.buffer)));
  }
  await loader.load();
}

const _t0 = 1700000000000;

SipTraceEvent ev(String dir, String msg, {int ms = 0, String remote = '192.0.2.10:5060'}) => SipTraceEvent({
  'type': 'event',
  'event': 'sip.trace',
  'ts': _t0 + ms,
  'seq': 1,
  'dir': dir,
  'transport': 'UDP',
  'local': '10.0.0.2:5060',
  'remote': remote,
  'len': msg.length,
  'msg': msg,
});

String invite(String callId) => 'INVITE sip:2002@pbx.test SIP/2.0\r\nVia: SIP/2.0/UDP 10.0.0.2:5060;branch=z9hG4bKinv1\r\nFrom: <sip:1001@pbx.test>;tag=aa\r\nTo: <sip:2002@pbx.test>\r\nCall-ID: $callId\r\nCSeq: 1 INVITE\r\nContact: <sip:1001@10.0.0.2:5060>\r\n\r\n';
String resp(String line, String callId, String m) => 'SIP/2.0 $line\r\nVia: SIP/2.0/UDP 10.0.0.2:5060;branch=z9hG4bKinv1\r\nFrom: <sip:1001@pbx.test>;tag=aa\r\nTo: <sip:2002@pbx.test>;tag=bb\r\nCall-ID: $callId\r\nCSeq: 1 $m\r\n\r\n';
const register = 'REGISTER sip:pbx.test SIP/2.0\r\nVia: SIP/2.0/UDP 10.0.0.2:5060;branch=z9hG4bKreg\r\nFrom: <sip:1001@pbx.test>;tag=rr\r\nTo: <sip:1001@pbx.test>\r\nCall-ID: reg-1\r\nCSeq: 2 REGISTER\r\nAuthorization: Digest username="1001", realm="pbx", nonce="NONCE-SECRET-123", response="RESPONSE-SECRET-456", uri="sip:pbx.test"\r\n\r\n';

Future<void> pumpDiag(
  WidgetTester tester,
  TestEnv env, {
  Size size = const Size(412, 915),
  List<Override> extra = const [],
  Brightness brightness = Brightness.light,
}) async {
  tester.view.physicalSize = size * 2;
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [...env.overrides, ...extra],
      child: Consumer(
        builder: (context, ref, _) {
          ref.watch(appServicesProvider);
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: buildTheme(brightness),
            home: Scaffold(
              body: Align(alignment: Alignment.topCenter, child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 720), child: const DiagnosticsPage())),
            ),
          );
        },
      ),
    ),
  );
  await settle(tester, env.engine);
}

Future<void> waitReg(WidgetTester tester, TestEnv env, [String id = 'acc1']) async {
  for (var i = 0; i < 10; i++) {
    await settle(tester, env.engine);
    if (cont(tester).read(accountsProvider).statusOf(id) == AccountStatus.registered) return;
  }
}

ProviderContainer cont(WidgetTester tester) => ProviderScope.containerOf(tester.element(find.byType(DiagnosticsPage)));

void main() {
  setUpAll(loadInter);

  group('SIP trace page', () {
    testWidgets('list, filters, raw viewer, redaction, ladder, export, clear', (tester) async {
      final saved = <String, Uint8List>{};
      final env = await TestEnv.create(profiles: [testProfile()], settings: const AppSettings({'onboardingDone': true, 'sipTrace': true}));
      await pumpDiag(tester, env, extra: [
        diagnosticsSaveProvider.overrideWithValue((name, bytes) async {
          saved[name] = bytes;
          return '/tmp/$name';
        }),
      ]);
      expect(find.text('SIP trace'), findsWidgets);
      expect(find.text('Waiting for SIP traffic'), findsOneWidget);

      final c = cont(tester);
      final ctl = c.read(sipTraceProvider.notifier);
      ctl.ingest(ev('tx', invite('call-A'), ms: 0));
      ctl.ingest(ev('rx', resp('100 Trying', 'call-A', 'INVITE'), ms: 15));
      ctl.ingest(ev('rx', resp('486 Busy Here', 'call-A', 'INVITE'), ms: 220));
      ctl.ingest(ev('tx', register, ms: 500));
      ctl.ingest(ev('rx', 'not sip at all \x01', ms: 600));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('INVITE'), findsOneWidget);
      expect(find.text('486 Busy Here  INVITE'), findsOneWidget);
      expect(find.text('REGISTER'), findsOneWidget);
      expect(find.text('Malformed'), findsOneWidget);

      // Errors only
      await tester.tap(find.byKey(const Key('filter-errors')));
      await tester.pump();
      expect(find.text('INVITE'), findsNothing);
      expect(find.text('486 Busy Here  INVITE'), findsOneWidget);
      await tester.tap(find.byKey(const Key('filter-errors')));
      await tester.pump();

      // Text search
      await tester.enterText(find.byKey(const Key('trace-search')), 'reg-1');
      await tester.pump();
      expect(find.text('REGISTER'), findsOneWidget);
      expect(find.text('INVITE'), findsNothing);
      await tester.enterText(find.byKey(const Key('trace-search')), '');
      await tester.pump();

      // Raw viewer is redacted by default.
      await tester.tap(find.text('REGISTER'));
      await tester.pumpAndSettle();
      final raw = tester.widget<SelectableText>(find.byKey(const Key('raw-text')));
      final shown = raw.textSpan!.toPlainText();
      expect(shown, contains('REGISTER sip:pbx.test'));
      expect(shown, isNot(contains('RESPONSE-SECRET-456')));
      expect(shown, isNot(contains('NONCE-SECRET-123')));
      await tester.tap(find.byKey(const Key('raw-redact')));
      await tester.pump();
      expect(tester.widget<SelectableText>(find.byKey(const Key('raw-text'))).textSpan!.toPlainText(), contains('RESPONSE-SECRET-456'));
      await tester.tapAt(const Offset(10, 10)); // dismiss
      await tester.pumpAndSettle();

      // Ladder
      await tester.tap(find.text('Ladder').first);
      await tester.pump();
      expect(find.byKey(const Key('dialog-list')), findsOneWidget);
      expect(find.textContaining('INVITE  ·  486 Busy Here'), findsOneWidget);
      await tester.tap(find.textContaining('INVITE  ·  486 Busy Here'));
      await tester.pump();
      expect(find.byKey(const Key('ladder-row-0')), findsOneWidget);
      expect(find.byKey(const Key('ladder-row-2')), findsOneWidget);
      expect(find.text('100 Trying (INVITE)'), findsOneWidget);
      expect(find.text('+15 ms'), findsOneWidget);
      await tester.tap(find.byKey(const Key('ladder-row-1')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('raw-text')), findsOneWidget);
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      // Export .log (redacted by default) and .pcap
      await tester.tap(find.byKey(const Key('trace-menu')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save as .log'));
      await tester.pumpAndSettle();
      final log = saved.entries.firstWhere((e) => e.key.endsWith('.log')).value;
      final text = utf8.decode(log);
      expect(text, contains('REDACTED'));
      expect(text, isNot(contains('RESPONSE-SECRET-456')));
      await tester.tap(find.byKey(const Key('trace-menu')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save as .pcap'));
      await tester.pumpAndSettle();
      final pcap = saved.entries.firstWhere((e) => e.key.endsWith('.pcap')).value;
      expect(ByteData.sublistView(pcap).getUint32(0, Endian.little), 0xa1b2c3d4);
      expect(utf8.decode(pcap, allowMalformed: true), isNot(contains('RESPONSE-SECRET-456')));

      // Clear
      await tester.tap(find.byKey(const Key('trace-menu')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Clear'));
      await tester.pump();
      expect(ctl.length, 0);
      expect(find.text('Waiting for SIP traffic'), findsOneWidget);
    });

    testWidgets('ring buffer drops oldest beyond the cap', (tester) async {
      final env = await TestEnv.create(settings: const AppSettings({'onboardingDone': true, 'sipTrace': true}));
      await pumpDiag(tester, env);
      final ctl = cont(tester).read(sipTraceProvider.notifier)..maxMessages = 50;
      for (var i = 0; i < 80; i++) {
        ctl.ingest(ev('rx', resp('200 OK', 'c$i', 'OPTIONS'), ms: i));
      }
      expect(ctl.length, 50);
      expect(ctl.messages.first.callId, 'c30');
      ctl.maxBytes = 3000;
      ctl.ingest(ev('rx', resp('200 OK', 'big', 'OPTIONS')));
      expect(ctl.messages.fold<int>(0, (a, m) => a + m.cost), lessThanOrEqualTo(3000 + 400));
    });

    testWidgets('toggle persists the setting', (tester) async {
      final env = await TestEnv.create(settings: const AppSettings({'onboardingDone': true}));
      await pumpDiag(tester, env);
      expect(find.text('SIP trace is off'), findsOneWidget);
      await tester.tap(find.byKey(const Key('trace-toggle')));
      await settle(tester, env.engine);
      expect(cont(tester).read(settingsProvider).sipTrace, isTrue);
    });
  });

  group('network wizard', () {
    Future<void> runWizard(WidgetTester tester, TestEnv env) async {
      await tester.tap(find.text('Network'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('wizard-run')));
      for (var i = 0; i < 12; i++) {
        await settle(tester, env.engine);
        if (cont(tester).read(networkWizardProvider).finished) break;
      }
    }

    final fakeIfaces = interfaceListerProvider.overrideWithValue(() async => [
      const NetIface('en0', ['192.168.1.20']),
    ]);

    testWidgets('healthy setup passes every step', (tester) async {
      final env = await TestEnv.create(profiles: [testProfile()]);
      await pumpDiag(tester, env, extra: [fakeIfaces]);
      await waitReg(tester, env);
      await runWizard(tester, env);
      final w = cont(tester).read(networkWizardProvider);
      expect(w.finished, isTrue);
      expect(w.steps.map((s) => s.id), ['net', 'dns:acc1', 'nat', 'options:acc1', 'reg:acc1', 'alg']);
      for (final s in w.steps) {
        expect(s.status, StepStatus.pass, reason: '${s.id}: ${s.summary}');
      }
      expect(find.text('Network connectivity'), findsOneWidget);
      expect(find.textContaining('Full cone NAT'), findsOneWidget);
      expect(find.textContaining('Server answered 200 OK in 12 ms'), findsOneWidget);
      final report = cont(tester).read(networkWizardProvider.notifier).buildReport();
      expect(report, contains('[PASS] Network connectivity'));
    });

    testWidgets('symmetric NAT and no network produce actionable advice', (tester) async {
      final env = await TestEnv.create(profiles: [testProfile()]);
      env.engine.natTypeResult = NatType.symmetric;
      await pumpDiag(tester, env, extra: [interfaceListerProvider.overrideWithValue(() async => [])]);
      await waitReg(tester, env);
      await runWizard(tester, env);
      final w = cont(tester).read(networkWizardProvider);
      expect(w.steps.firstWhere((s) => s.id == 'net').status, StepStatus.fail);
      final nat = w.steps.firstWhere((s) => s.id == 'nat');
      expect(nat.status, StepStatus.warn);
      expect(nat.suggestion, contains('TURN'));
    });

    testWidgets('untrusted TLS certificate can be trusted and pinned', (tester) async {
      final tls = AccountProfile(
        id: 'tls1',
        isDefault: true,
        config: AccountConfig(uid: 'tls1', username: '1001', password: 'pw', domain: 'pbx.test', transport: AccTransport.tls),
      );
      final env = await TestEnv.create(profiles: [tls]);
      await pumpDiag(tester, env, extra: [fakeIfaces]);
      await waitReg(tester, env, 'tls1');
      cont(tester).read(diagnosticsHubProvider.notifier).ingest(
        TransportTlsVerifyEvent({
          'event': 'transport.tlsVerify',
          'host': 'pbx.test',
          'sha256': 'AA:BB:CC',
          'verifyStatus': ['self-signed'],
          'subject': 'CN=pbx.test',
          'issuer': 'CN=pbx.test',
        }),
      );
      await runWizard(tester, env);
      var step = cont(tester).read(networkWizardProvider).steps.firstWhere((s) => s.id == 'tls:tls1');
      expect(step.status, StepStatus.fail);
      expect(step.details.join(), contains('AA:BB:CC'));
      await tester.ensureVisible(find.text('Trust this certificate'));
      await tester.pump();
      await tester.tap(find.text('Trust this certificate'));
      await settle(tester, env.engine);
      expect(cont(tester).read(settingsProvider).tlsPins, contains('pbx.test=AA:BB:CC'));
      expect(env.engine.tlsPins.single.sha256, 'AA:BB:CC');
      step = cont(tester).read(networkWizardProvider).steps.firstWhere((s) => s.id == 'tls:tls1');
      expect(step.status, isNot(StepStatus.fail));
    });
  });

  group('quality', () {
    test('history model is backwards compatible', () {
      final old = CallRecord.fromJson({'id': 'x', 'quality': {'mosAvg': 4.1, 'mosMin': 3.9, 'jitterMax': 5, 'lossPct': 0.1}});
      expect(old.quality.samples, isEmpty);
      expect(old.callId, '');
      final rec = CallRecord(
        id: 'y',
        accountId: 'a',
        direction: CallDirection.outgoing,
        remoteUri: 'sip:b',
        remoteNumber: 'b',
        remoteDisplay: 'b',
        start: DateTime.fromMillisecondsSinceEpoch(1000),
        callId: 'cid-1',
        quality: const QualitySummary(mosAvg: 4, mosMin: 3.5, samples: [QualitySample(t: 1, mos: 4.2, jitter: 3, loss: 0.5, rtt: 40), QualitySample(t: 2, mos: 3.8, jitter: 6, loss: 1, rtt: 60)]),
      );
      final back = CallRecord.fromJson(jsonDecode(jsonEncode(rec.toJson())) as Map<String, dynamic>);
      expect(back.callId, 'cid-1');
      expect(back.quality.samples, hasLength(2));
      expect(back.quality.samples.last.rtt, 60);
    });

    testWidgets('quality panel renders gauge and charts', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildTheme(Brightness.light),
          home: Scaffold(
            body: SingleChildScrollView(
              child: QualityPanel(samples: [for (var i = 0; i < 30; i++) QualitySample(t: i.toDouble(), mos: 4.3 - i * 0.02, jitter: 4.0 + i % 5, loss: i % 7 == 0 ? 1.2 : 0, rtt: 40.0 + i)]),
            ),
          ),
        ),
      );
      expect(find.byType(MosGauge), findsOneWidget);
      expect(find.byType(QualityChart), findsNWidgets(4));
      expect(find.text('Jitter'), findsOneWidget);
    });
  });

  group('audio and logs', () {
    testWidgets('echo test toggles loopback; tones play; logs are listed and searchable', (tester) async {
      final env = await TestEnv.create(settings: const AppSettings({'onboardingDone': true}));
      await pumpDiag(tester, env);
      await tester.tap(find.text('Audio test'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('audio-echo')));
      await settle(tester, env.engine);
      expect(env.engine.loopbackEnabled, isTrue);
      await tester.tap(find.byKey(const Key('tone-ringback')));
      await settle(tester, env.engine);
      expect(env.engine.activeTone, isNotNull);
      await tester.tap(find.byKey(const Key('tone-stop')));
      await settle(tester, env.engine);
      expect(env.engine.activeTone, isNull);
      await tester.tap(find.byKey(const Key('audio-echo')));
      await settle(tester, env.engine);
      expect(env.engine.loopbackEnabled, isFalse);

      await tester.tap(find.text('Logs'));
      await tester.pumpAndSettle();
      final logs = cont(tester).read(logsProvider.notifier);
      logs.ingest(LogEvent({'event': 'log', 'ts': _t0, 'level': 2, 'msg': 'transport failed password=hunter2'}));
      logs.ingest(LogEvent({'event': 'log', 'ts': _t0 + 5, 'level': 4, 'msg': 'rtp stream started'}));
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.textContaining('rtp stream started'), findsOneWidget);
      await tester.enterText(find.byKey(const Key('logs-search')), 'transport');
      await tester.pump();
      expect(find.textContaining('rtp stream started'), findsNothing);
      expect(find.textContaining('transport failed'), findsOneWidget);
    });
  });

  group('screenshots', () {
    Future<void> seed(WidgetTester tester) async {
      final ctl = cont(tester).read(sipTraceProvider.notifier);
      ctl.ingest(ev('tx', register, ms: 0));
      ctl.ingest(ev('rx', 'SIP/2.0 401 Unauthorized\r\nVia: SIP/2.0/UDP 10.0.0.2:5060;branch=z9hG4bKreg\r\nFrom: <sip:1001@pbx.test>;tag=rr\r\nTo: <sip:1001@pbx.test>;tag=ss\r\nCall-ID: reg-1\r\nCSeq: 2 REGISTER\r\nWWW-Authenticate: Digest realm="pbx", nonce="abc"\r\n\r\n', ms: 24));
      ctl.ingest(ev('tx', invite('call-A'), ms: 1200));
      ctl.ingest(ev('rx', resp('100 Trying', 'call-A', 'INVITE'), ms: 1215));
      ctl.ingest(ev('rx', resp('180 Ringing', 'call-A', 'INVITE'), ms: 1380));
      ctl.ingest(ev('rx', resp('200 OK', 'call-A', 'INVITE'), ms: 4100));
      ctl.ingest(ev('tx', 'ACK sip:2002@192.0.2.10 SIP/2.0\r\nCall-ID: call-A\r\nCSeq: 1 ACK\r\nFrom: <sip:1001@pbx.test>;tag=aa\r\nTo: <sip:2002@pbx.test>;tag=bb\r\n\r\n', ms: 4110));
      ctl.ingest(ev('tx', 'BYE sip:2002@192.0.2.10 SIP/2.0\r\nCall-ID: call-A\r\nCSeq: 2 BYE\r\nFrom: <sip:1001@pbx.test>;tag=aa\r\nTo: <sip:2002@pbx.test>;tag=bb\r\n\r\n', ms: 9000));
      ctl.ingest(ev('rx', resp('200 OK', 'call-A', 'BYE').replaceFirst('CSeq: 1 BYE', 'CSeq: 2 BYE'), ms: 9030));
      await tester.pump(const Duration(milliseconds: 300));
    }

    for (final (name, size) in [('desktop', const Size(1280, 800)), ('phone', const Size(412, 915))]) {
      testWidgets('trace list and ladder $name', (tester) async {
        final env = await TestEnv.create(profiles: [testProfile()], settings: const AppSettings({'onboardingDone': true, 'sipTrace': true}));
        await pumpDiag(tester, env, size: size);
        await seed(tester);
        await expectLater(find.byType(MaterialApp), matchesGoldenFile('goldens/trace_list_$name.png'));
        await tester.tap(find.text('Ladder').first);
        await tester.pump();
        await tester.tap(find.textContaining('INVITE  ·  200 OK').first);
        await tester.pump();
        await expectLater(find.byType(MaterialApp), matchesGoldenFile('goldens/trace_ladder_$name.png'));
      });

      testWidgets('wizard $name', (tester) async {
        final env = await TestEnv.create(profiles: [testProfile()]);
        env.engine.natTypeResult = NatType.symmetric;
        await pumpDiag(tester, env, size: size, extra: [
          interfaceListerProvider.overrideWithValue(() async => [const NetIface('en0', ['192.168.1.20'])]),
        ]);
        await waitReg(tester, env);
        await tester.tap(find.text('Network'));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('wizard-run')));
        for (var i = 0; i < 12; i++) {
          await settle(tester, env.engine);
          if (cont(tester).read(networkWizardProvider).finished) break;
        }
        await expectLater(find.byType(MaterialApp), matchesGoldenFile('goldens/wizard_$name.png'));
      });
    }
  });
}
