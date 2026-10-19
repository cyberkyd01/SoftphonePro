import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lan_link/lan_link.dart' as ll;
import 'package:softphonepro/app.dart';
import 'package:softphonepro/lan/lan_controller.dart';
import 'package:softphonepro/lan/lan_handoff_impl.dart';
import 'package:softphonepro/lan/lan_models.dart';
import 'package:softphonepro/models/chat.dart';
import 'package:softphonepro/platform/lan_handoff.dart' show LanDevice;
import 'package:softphonepro/services/calls_controller.dart';
import 'package:softphonepro/services/messages_controller.dart';
import 'package:softphonepro/ui/router.dart';
import 'package:spcore_dart/spcore_dart.dart';

import 'lan_harness.dart';

Future<void> waitW(WidgetTester t, bool Function() cond, {String what = 'condition', int seconds = 10}) async {
  final end = DateTime.now().add(Duration(seconds: seconds));
  while (!cond()) {
    if (DateTime.now().isAfter(end)) throw StateError('timed out waiting for $what');
    await t.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 30)));
    await t.pump(const Duration(milliseconds: 30));
  }
}

/// Lets timers that LAN Link created in the test zone (socket close, ping) run out.
Future<void> drain(WidgetTester t) async {
  await t.pumpWidget(const SizedBox());
  for (var i = 0; i < 4; i++) {
    await t.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 30)));
    await t.pump(const Duration(seconds: 6));
  }
}

Future<ProviderContainer> pumpNode(WidgetTester t, LanNode n, {String route = '/lan', Size size = const Size(420, 900)}) async {
  t.view.physicalSize = size * 2;
  t.view.devicePixelRatio = 2;
  addTearDown(t.view.reset);
  // Boot in the real zone (sockets + timers), render through the same container.
  final c = (await t.runAsync(n.boot))!;
  addTearDown(() => t.runAsync(n.dispose));
  await t.pumpWidget(UncontrolledProviderScope(container: c, child: const SoftphoneApp()));
  await waitW(t, () => c.read(lanControllerProvider).running, what: 'LAN running');
  c.read(routerProvider).go(route);
  for (var i = 0; i < 6; i++) {
    await t.pump(const Duration(milliseconds: 100));
  }
  return c;
}

void main() {
  // flutter_test blocks real HTTP; LAN Link talks to 127.0.0.1 for real.
  setUpAll(() => HttpOverrides.global = null);

  testWidgets('LAN page: connect, pair with the 6-digit code on both sides', (tester) async {
    final a = await LanNode.create('Alpha');
    final b = await LanNode.create('Taker');
    final ca = await pumpNode(tester, a);
    final cb = await tester.runAsync(b.boot) as ProviderContainer;
    addTearDown(() => tester.runAsync(b.dispose));
    expect(find.byKey(const Key('lan-this-device')), findsOneWidget);
    expect(find.byKey(const Key('lan-fingerprint')), findsOneWidget);

    final incoming = <ll.PairingSession>[];
    b.lan(cb).pairingRequests.listen(incoming.add);
    await tester.runAsync(() => a.lan(ca).connectManual('127.0.0.1:${b.port(cb)}'));
    await waitW(tester, () => find.byKey(Key('lan-pair-${b.id(cb)}')).evaluate().isNotEmpty, what: 'nearby device');
    expect(find.text('Taker'), findsWidgets);

    await tester.tap(find.byKey(Key('lan-pair-${b.id(cb)}')));
    await tester.pump(const Duration(milliseconds: 200));
    await waitW(tester, () => find.byKey(const Key('pair-sas')).evaluate().isNotEmpty && incoming.isNotEmpty, what: 'SAS dialog');
    final sb = incoming.single;
    await waitW(tester, () => sb.sas != null, what: 'peer SAS');
    final shown = (tester.widget<Text>(find.byKey(const Key('pair-sas'))).data!).replaceAll(' ', '');
    expect(shown, sb.sas, reason: 'both screens show the same code');
    expect(shown, hasLength(6));

    // Peer rejects first -> dialog reports it; then try again and succeed.
    await tester.tap(find.byKey(const Key('pair-confirm')));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.textContaining('Waiting for'), findsOneWidget);
    await tester.runAsync(sb.confirm);
    await waitW(tester, () => find.textContaining('Paired with').evaluate().isNotEmpty, what: 'paired');
    await waitW(tester, () => find.byKey(Key('lan-msg-${b.id(cb)}')).evaluate().isNotEmpty, what: 'paired actions');
    expect(find.text('Paired'), findsOneWidget);
    expect(find.byKey(Key('lan-unpair-${b.id(cb)}')), findsNothing); // inside the menu
    await tester.pump(const Duration(seconds: 2));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byKey(const Key('pairing-dialog')), findsNothing);
    await drain(tester);
  });

  testWidgets('incoming pairing request pops up app-wide; the peer rejecting is reported', (tester) async {
    final a = await LanNode.create('Alpha');
    final b = await LanNode.create('Taker');
    final ca = await pumpNode(tester, a, route: '/keypad');
    final cb = await tester.runAsync(b.boot) as ProviderContainer;
    addTearDown(() => tester.runAsync(b.dispose));
    await tester.runAsync(() => b.lan(cb).connectManual('127.0.0.1:${a.port(ca)}'));
    final sb = b.lan(cb).pair(a.id(ca));
    await waitW(tester, () => find.byKey(const Key('pairing-dialog')).evaluate().isNotEmpty, what: 'popup');
    await waitW(tester, () => find.byKey(const Key('pair-sas')).evaluate().isNotEmpty, what: 'sas');
    expect(find.textContaining('wants to pair'), findsOneWidget);
    expect(find.byKey(const Key('pair-reject')), findsOneWidget);
    expect(find.byKey(const Key('pair-confirm')), findsOneWidget);
    final shown = tester.widget<Text>(find.byKey(const Key('pair-sas'))).data!.replaceAll(' ', '');
    expect(shown, sb.sas);
    // The other user says the codes differ.
    await tester.runAsync(sb.reject);
    await waitW(tester, () => find.textContaining('rejected').evaluate().isNotEmpty, what: 'rejection shown');
    await tester.tap(find.text('Close'));
    await waitW(tester, () => find.byKey(const Key('pairing-dialog')).evaluate().isEmpty, what: 'dialog closed');
    expect(ca.read(lanControllerProvider).paired, isEmpty);
    await drain(tester);
  });

  testWidgets('LAN chat appears in Messages with a LAN badge, replies and read ticks', (tester) async {
    final a = await LanNode.create('Alpha');
    final b = await LanNode.create('Taker');
    final ca = await pumpNode(tester, a, route: '/messages');
    final cb = await tester.runAsync(b.boot) as ProviderContainer;
    addTearDown(() => tester.runAsync(b.dispose));
    await tester.runAsync(() => pairNodes(a, ca, b, cb));

    await tester.runAsync(() => b.lan(cb).sendChat(a.id(ca), 'hello from beta'));
    await waitW(tester, () => ca.read(messagesProvider).messages.isNotEmpty, what: 'message in state');
    await waitW(tester, () => find.text('hello from beta').evaluate().isNotEmpty, what: 'conversation row');
    expect(find.text('LAN'), findsWidgets);
    expect(ca.read(messagesProvider).unreadTotal, 1);

    await tester.tap(find.text('Taker'));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('hello from beta'), findsWidgets);
    await waitW(tester, () => ca.read(messagesProvider).unreadTotal == 0, what: 'marked read');
    await waitW(tester, () => cb.read(messagesProvider).messages.single.status == MessageStatus.read, what: 'read receipt at B');

    await tester.enterText(find.byKey(const Key('message-input')), 'reply from alpha');
    await tester.pump();
    await tester.tap(find.byKey(const Key('send-message')));
    await waitW(tester, () => cb.read(messagesProvider).messages.any((m) => m.body == 'reply from alpha'), what: 'reply at B');
    await waitW(tester, () => ca.read(messagesProvider).messages.any((m) => m.body == 'reply from alpha' && m.status == MessageStatus.delivered), what: 'delivered tick');
    expect(find.byIcon(Icons.done_all_rounded), findsWidgets);
    final stored = ca.read(messagesProvider).messages.where((m) => m.channel == kChannelLan);
    expect(stored, hasLength(2));
    await drain(tester);
  });

  testWidgets('incoming file offer: dialog with name and size, accept, file lands in downloads and is listed', (tester) async {
    final a = await LanNode.create('Alpha');
    final b = await LanNode.create('Taker');
    final ca = await pumpNode(tester, a);
    final cb = await tester.runAsync(b.boot) as ProviderContainer;
    addTearDown(() => tester.runAsync(b.dispose));
    await tester.runAsync(() => pairNodes(a, ca, b, cb));
    final src = File('${b.downloads.path}/report.txt')..writeAsStringSync('x' * 5000);
    final t = b.lan(cb).sendFile(a.id(ca), src.path)!;

    await waitW(tester, () => find.byKey(const Key('file-offer-dialog')).evaluate().isNotEmpty, what: 'offer dialog');
    expect(find.descendant(of: find.byKey(const Key('file-offer-dialog')), matching: find.text('report.txt')), findsOneWidget);
    expect(find.textContaining('4.9 KB'), findsOneWidget);
    expect(find.textContaining('Taker'), findsWidgets);
    await tester.tap(find.byKey(const Key('file-accept')));
    await tester.pump(const Duration(milliseconds: 200));
    await waitW(tester, () => t.isFinished, what: 'transfer finished');
    expect(t.state, ll.TransferState.completed);
    await waitW(tester, () => ca.read(lanControllerProvider).history.isNotEmpty, what: 'history');
    final saved = File('${a.downloads.path}/report.txt');
    expect(saved.existsSync(), isTrue);
    expect(saved.lengthSync(), 5000);
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.textContaining('report.txt', skipOffstage: false), findsWidgets);
    await drain(tester);
  });

  testWidgets('declining a file offer sends nothing', (tester) async {
    final a = await LanNode.create('Alpha');
    final b = await LanNode.create('Taker');
    final ca = await pumpNode(tester, a);
    final cb = await tester.runAsync(b.boot) as ProviderContainer;
    addTearDown(() => tester.runAsync(b.dispose));
    await tester.runAsync(() => pairNodes(a, ca, b, cb));
    final src = File('${b.downloads.path}/secret.bin')..writeAsBytesSync(List.filled(100, 1));
    final t = b.lan(cb).sendFile(a.id(ca), src.path)!;
    await waitW(tester, () => find.byKey(const Key('file-offer-dialog')).evaluate().isNotEmpty, what: 'offer dialog');
    await tester.tap(find.byKey(const Key('file-decline')));
    await waitW(tester, () => t.isFinished, what: 'transfer finished');
    expect(t.state, ll.TransferState.declined);
    expect(File('${a.downloads.path}/secret.bin').existsSync(), isFalse);
    await drain(tester);
  });

  testWidgets('hand-off offer dialog, then the transferred call is answered and labelled', (tester) async {
    final owner = await LanNode.create('Owner', profiles: [accountFor('acc1', '1001')]);
    final taker = await LanNode.create('Taker');
    final cb = await pumpNode(tester, taker, route: '/keypad');
    final ca = await tester.runAsync(owner.boot) as ProviderContainer;
    addTearDown(() => tester.runAsync(owner.dispose));
    await tester.runAsync(() => pairNodes(owner, ca, taker, cb));
    owner.engine.onRequest = (m, p) {
      if (m == 'call.make' && p['uid'] == kLanAccountUid) {
        taker.engine.simulateIncomingCall(
          acc: const AccountRef.uid(kLanAccountUid),
          from: 'sip:${owner.id(ca)}@127.0.0.1:5070',
          headers: Map<String, String>.from(p['headers'] as Map),
        );
      }
    };
    await waitW(tester, () => ca.read(lanControllerProvider).peer(taker.id(cb))?.online == true, what: 'online');
    await tester.runAsync(() async {
      final ref = owner.engine.simulateIncomingCall(acc: const AccountRef.uid('acc1'), from: 'sip:1002@pbx.test', displayName: 'Alice');
      await until(() => ca.read(callsProvider).byCid(ref.cid) != null, what: 'ringing');
      await ca.read(callsProvider.notifier).answer(ref.cid);
      await until(() => ca.read(callsProvider).byCid(ref.cid)!.isConfirmed, what: 'confirmed');
    });
    final cid = ca.read(callsProvider).focused!.cid;
    final dev = ca.read(lanControllerProvider).paired.single;
    var handoffDone = false;
    final future = ca.read(callsProvider.notifier).handoffToLan(cid, _device(dev)).whenComplete(() => handoffDone = true);

    await waitW(tester, () => find.byKey(const Key('handoff-offer-dialog')).evaluate().isNotEmpty, what: 'offer dialog');
    expect(find.textContaining('Owner wants to hand you a call from Alice'), findsOneWidget);
    await tester.tap(find.byKey(const Key('handoff-accept')));
    await tester.pump(const Duration(milliseconds: 300));
    await waitW(tester, () => handoffDone, what: 'hand-off done');
    await future;
    await waitW(tester, () => cb.read(callsProvider).ongoing.isNotEmpty, what: 'taker call');
    await waitW(tester, () => find.text('Transferred call from Owner: Alice').evaluate().isNotEmpty, what: 'transferred label');
    expect(taker.engine.methods, contains('call.answer'));
    expect(ca.read(lanRelayProvider)[cid]!.phase, RelayPhase.relayed);
    await drain(tester);
  });

  testWidgets('owner sees "Relayed to" with Take back and End', (tester) async {
    final owner = await LanNode.create('Owner', profiles: [accountFor('acc1', '1001')]);
    final taker = await LanNode.create('Taker');
    final ca = await pumpNode(tester, owner, route: '/keypad');
    final cb = await tester.runAsync(taker.boot) as ProviderContainer;
    addTearDown(() => tester.runAsync(taker.dispose));
    await tester.runAsync(() => pairNodes(owner, ca, taker, cb));
    cb.read(lanHandoffImplProvider).pendingOffers.listen((h) => cb.read(lanHandoffImplProvider).respond(h, true));
    owner.engine.onRequest = (m, p) {
      if (m == 'call.make' && p['uid'] == kLanAccountUid) {
        taker.engine.simulateIncomingCall(
            acc: const AccountRef.uid(kLanAccountUid), from: 'sip:${owner.id(ca)}@127.0.0.1:5070', headers: Map<String, String>.from(p['headers'] as Map));
      }
    };
    await waitW(tester, () => ca.read(lanControllerProvider).peer(taker.id(cb))?.online == true, what: 'online');
    await tester.runAsync(() async {
      final ref = owner.engine.simulateIncomingCall(acc: const AccountRef.uid('acc1'), from: 'sip:1002@pbx.test', displayName: 'Alice');
      await until(() => ca.read(callsProvider).byCid(ref.cid) != null, what: 'ringing');
    });
    final cid = ca.read(callsProvider).ringing.single.cid;
    await tester.runAsync(() => ca.read(callsProvider.notifier).answer(cid));
    await waitW(tester, () => ca.read(callsProvider).byCid(cid)!.isConfirmed, what: 'confirmed');
    final dev = ca.read(lanControllerProvider).paired.single;
    unawaited(ca.read(callsProvider.notifier).handoffToLan(cid, _device(dev)));
    await waitW(tester, () => find.text('Relayed to Taker').evaluate().isNotEmpty, what: 'banner');
    expect(find.byKey(const Key('relay-take-back')), findsOneWidget);
    await tester.tap(find.byKey(const Key('relay-take-back')));
    await waitW(tester, () => find.byKey(const Key('relayed-banner')).evaluate().isEmpty, what: 'banner gone');
    expect(owner.engine.methods, contains('call.hangup'));
    await drain(tester);
  });
}

LanDevice _device(ll.LanPeer p) => LanDevice(id: p.deviceId, name: p.name);
