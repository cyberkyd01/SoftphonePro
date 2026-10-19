import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:softphonepro/models/contact.dart';
import 'package:softphonepro/services/caller_identity.dart';
import 'package:softphonepro/services/calls_controller.dart';
import 'package:softphonepro/services/history_controller.dart';
import 'package:softphonepro/ui/router.dart';
import 'package:spcore_dart/spcore_dart.dart';

import '../harness.dart';

const _pai = AssertedIdentity(display: 'Alice Smith', user: '+15551234', uri: 'sip:+15551234@carrier.example');
const _div = [DiversionEntry(uri: 'sip:2001@pbx.test', user: '2001', reason: 'no-answer', counter: 1)];

CallRef _ring(TestEnv env, {AssertedIdentity? pai = _pai, List<DiversionEntry> div = _div, String? referredBy = 'sip:1005@pbx.test'}) =>
    env.engine.simulateIncomingCall(
      from: 'sip:1002@pbx.test',
      displayName: 'ext 1002',
      assertedIdentity: pai,
      diversion: div,
      referredBy: referredBy,
    );

void main() {
  test('CallerIdentity: asserted identity wins for the name, From number is secondary', () {
    final info = CallInfo(
      cid: 1,
      remoteUri: 'sip:1002@pbx.test',
      remoteUser: '1002',
      remoteDisplay: 'ext 1002',
      assertedIdentity: _pai,
      diversion: _div,
      referredBy: 'sip:1005@pbx.test',
    );
    final who = CallerIdentity.of(info, const []);
    expect(who.name, 'Alice Smith');
    expect(who.number, '+15551234');
    expect(who.secondaryNumber, '1002');
    expect(who.forwardedText, 'Forwarded from 2001 (no-answer)');
    expect(who.transferredText, 'Transferred by 1005');
  });

  test('CallerIdentity: a contact name beats the asserted display; same number has no secondary', () {
    final info = CallInfo(
      cid: 1,
      remoteUri: 'sip:1002@pbx.test',
      remoteUser: '1002',
      assertedIdentity: const AssertedIdentity(display: 'Carrier name', user: '1002'),
    );
    final who = CallerIdentity.of(info, const [Contact(id: 'c', name: 'Bob', numbers: [ContactNumber(label: 'w', value: '1002')])]);
    expect(who.name, 'Bob');
    expect(who.secondaryNumber, isEmpty);
    expect(who.forwardedFrom, isEmpty);
    expect(who.transferredBy, isEmpty);
    // No asserted identity at all: plain From.
    final plain = CallerIdentity.of(CallInfo(cid: 2, remoteUri: 'sip:7@x', remoteUser: '7', remoteDisplay: 'Seven'), const []);
    expect((plain.name, plain.number, plain.hasExtras), ('Seven', '7', false));
  });

  testWidgets('mobile incoming page and in-call page show asserted name, From, forwarded and transferred', (tester) async {
    final env = await TestEnv.create(profiles: [testProfile()]);
    await pumpApp(tester, env);
    await waitRegistered(tester, env);
    final ref = _ring(env);
    await settle(tester, env.engine);
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byKey(const Key('answer-call')), findsOneWidget);
    expect(find.text('Alice Smith'), findsWidgets);
    expect(find.text('+15551234'), findsOneWidget);
    expect(find.byKey(const Key('identity-from')), findsOneWidget);
    expect(find.text('From 1002'), findsOneWidget);
    expect(find.text('Forwarded from 2001 (no-answer)'), findsOneWidget);
    expect(find.text('Transferred by 1005'), findsOneWidget);

    await tester.tap(find.byKey(const Key('answer-call')));
    await settle(tester, env.engine);
    expect(find.byKey(const Key('end-call')), findsOneWidget);
    expect(find.text('Alice Smith'), findsWidgets);
    expect(find.text('Forwarded from 2001 (no-answer)'), findsOneWidget);
    expect(find.text('Transferred by 1005'), findsOneWidget);

    await tester.tap(find.byKey(const Key('end-call')));
    await settle(tester, env.engine);
    final h = containerOf(tester).read(historyProvider).single;
    expect(h.assertedName, 'Alice Smith');
    expect(h.assertedNumber, '+15551234');
    expect(h.divertedFrom, '2001');
    expect(h.divertReason, 'no-answer');
    expect(h.referredBy, '1005');
    expect(h.remoteDisplay, 'Alice Smith');
    expect(h.remoteNumber, '1002');
    expect(ref.cid, isNonZero);
  });

  testWidgets('history detail shows caller ID, forwarded and transferred lines', (tester) async {
    final env = await TestEnv.create(profiles: [testProfile()]);
    await pumpApp(tester, env);
    await waitRegistered(tester, env);
    _ring(env);
    await settle(tester, env.engine);
    await tester.tap(find.byKey(const Key('answer-call')));
    await settle(tester, env.engine);
    await tester.tap(find.byKey(const Key('end-call')));
    await settle(tester, env.engine);
    containerOf(tester).read(routerProvider).go('/recents/detail?n=1002');
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('hist-asserted')), findsOneWidget);
    expect(find.textContaining('+15551234'), findsWidgets);
    expect(tester.widget<Text>(find.byKey(const Key('hist-forwarded'))).data, 'Forwarded from 2001 (no-answer)');
    expect(tester.widget<Text>(find.byKey(const Key('hist-transferred'))).data, 'Transferred by 1005');
  });

  testWidgets('desktop: incoming banner and call card carry the identity lines', (tester) async {
    final env = await TestEnv.create(profiles: [testProfile()]);
    await pumpApp(tester, env, size: const Size(1300, 900));
    await waitRegistered(tester, env);
    _ring(env);
    await settle(tester, env.engine);
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Alice Smith'), findsWidgets);
    expect(find.text('Forwarded from 2001 (no-answer)'), findsOneWidget);
    expect(find.text('Transferred by 1005'), findsOneWidget);
    await tester.tap(find.byKey(Key('banner-answer-${containerOf(tester).read(callsProvider).ringing.first.cid}')));
    await settle(tester, env.engine);
    // Now in the call card of the right-hand panel.
    expect(find.text('Alice Smith'), findsWidgets);
    expect(find.text('Forwarded from 2001 (no-answer)'), findsOneWidget);
    await tester.tap(find.byKey(Key('card-end-${containerOf(tester).read(callsProvider).focused!.cid}')));
    await settle(tester, env.engine);
  });

  testWidgets('a call spawned by a transfer says who transferred it', (tester) async {
    final e = FakeSipEngine(timings: FakeTimings.instant);
    final env = await TestEnv.create(profiles: [testProfile()], engine: e);
    await pumpApp(tester, env);
    await waitRegistered(tester, env);
    final calls = containerOf(tester).read(callsProvider.notifier);
    final a = (await calls.dial('2002'))!;
    await settle(tester, env.engine);
    final n = e.simulateTransferRequest(a, 'sip:4004@pbx.test', referredBy: 'sip:1009@pbx.test');
    await settle(tester, env.engine);
    expect(find.text('Transferred by 1009'), findsWidgets);
    await calls.hangup(n.cid);
    await settle(tester, env.engine);
    expect(containerOf(tester).read(historyProvider).any((r) => r.referredBy == '1009'), isTrue);
  });
}
