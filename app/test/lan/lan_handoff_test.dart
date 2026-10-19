import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:softphonepro/lan/lan_controller.dart';
import 'package:softphonepro/lan/lan_handoff_impl.dart';
import 'package:softphonepro/lan/lan_models.dart';
import 'package:softphonepro/models/call_record.dart';
import 'package:softphonepro/platform/lan_handoff.dart' as plat;
import 'package:softphonepro/services/calls_controller.dart';
import 'package:softphonepro/services/history_controller.dart';
import 'package:softphonepro/services/providers.dart';
import 'package:spcore_dart/spcore_dart.dart';

import 'lan_harness.dart';

class Pair {
  Pair(this.a, this.ca, this.b, this.cb);
  final LanNode a, b;
  final ProviderContainer ca, cb;
  int? extCid;
  LanHandoffImpl get implA => ca.read(lanHandoffImplProvider);
  LanHandoffImpl get implB => cb.read(lanHandoffImplProvider);
  CallsController get callsA => ca.read(callsProvider.notifier);
  plat.LanDevice get deviceB => ca.read(lanHandoffProvider).devices.firstWhere((d) => d.id == b.id(cb));

  /// B answers hand-off prompts with [accept]; A's LAN INVITE shows up on B.
  void wireNetwork({bool accept = true}) {
    implB.pendingOffers.listen((h) => implB.respond(h, accept));
    a.engine.onRequest = (m, p) {
      if (m == 'call.make' && p['uid'] == kLanAccountUid) {
        b.engine.simulateIncomingCall(
          acc: const AccountRef.uid(kLanAccountUid),
          from: 'sip:${a.id(ca)}@127.0.0.1:5070',
          headers: Map<String, String>.from(p['headers'] as Map),
          autoAnswerHint: (p['headers'] as Map).containsKey('Call-Info') ? const AutoAnswerHint(afterSec: 0, source: AutoAnswerSource.callInfo) : null,
        );
      }
    };
  }

  /// An external call from Alice that A has answered.
  Future<int> externalCall() async {
    final ref = a.engine.simulateIncomingCall(acc: const AccountRef.uid('acc1'), from: 'sip:1002@pbx.test', displayName: 'Alice');
    await until(() => ca.read(callsProvider).byCid(ref.cid) != null, what: 'incoming');
    await callsA.answer(ref.cid);
    await until(() => ca.read(callsProvider).byCid(ref.cid)!.isConfirmed, what: 'confirmed');
    return extCid = ref.cid;
  }
}

Future<Pair> setup({Map<String, dynamic> bSettings = const {}, bool bAccount = false, bool pull = false}) async {
  final a = await LanNode.create('Owner',
      profiles: [accountFor('acc1', '1001')], settings: {'lanAllowPull': pull, 'lanShareAors': const ['acc1']});
  final b = await LanNode.create('Taker',
      profiles: bAccount ? [accountFor('bacc', '2001')] : const [], settings: {'lanShareAors': bAccount ? const ['bacc'] : const [], ...bSettings});
  final ca = await a.boot();
  final cb = await b.boot();
  addTearDown(() async {
    await a.dispose();
    await b.dispose();
  });
  await pairNodes(a, ca, b, cb);
  // Let the registrations and the peer-info exchange settle.
  await until(() => ca.read(lanControllerProvider).peer(b.id(cb))?.info != null, what: 'peer info');
  return Pair(a, ca, b, cb);
}

Future<void> allLive(Pair p) => until(() => p.ca.read(lanHandoffProvider).devices.any((d) => d.online), what: 'device online');

void main() {
  test('relay: offer, LAN call with headers, then bridge + detach in order; either leg ending ends the other', () async {
    final p = await setup();
    p.wireNetwork();
    await allLive(p);
    final cid = await p.externalCall();

    await p.callsA.handoffToLan(cid, p.deviceB);

    final m = p.a.engine.methods;
    expect(m, containsAllInOrder(['call.mute', 'call.make', 'call.bridge', 'call.detachLocal', 'call.detachLocal']));
    final make = p.a.engine.of('call.make').single;
    expect(make.params['uid'], kLanAccountUid);
    final h = Map<String, String>.from(make.params['headers'] as Map);
    expect(h[kHdrHandoff], isNotEmpty);
    expect(h[kHdrCallerName], 'Alice');
    expect(h[kHdrCallerNumber], '1002');
    expect(make.params['uri'], startsWith('sip:${p.b.id(p.cb)}@127.0.0.1:'));
    final bridge = p.a.engine.of('call.bridge').single;
    final lanCid = bridge.params['b'] as int;
    expect(bridge.params['a'], cid);
    expect(bridge.params['bridge'], true);
    final detaches = p.a.engine.of('call.detachLocal').toList();
    expect(detaches.map((e) => e.params['cid']), [cid, lanCid]);
    expect(detaches.every((e) => e.params['detached'] == true), isTrue);

    final s = p.ca.read(lanRelayProvider)[cid]!;
    expect(s.phase, RelayPhase.relayed);
    expect(s.peerName, 'Taker');
    // The LAN leg is internal: not shown, not in history.
    expect(p.ca.read(callsProvider).calls.map((c) => c.cid), [cid]);

    // Receiving side: auto-answered and labelled as a transferred call.
    await until(() => p.cb.read(callsProvider).ongoing.isNotEmpty, what: 'B call');
    final bc = p.cb.read(callsProvider).ongoing.single;
    expect(bc.lan!.isHandoff, isTrue);
    expect(bc.lan!.handoffText, 'Transferred call from Owner: Alice');
    expect(p.b.engine.methods, contains('call.answer'));

    // The LAN leg hangs up -> the external call is ended too.
    p.a.engine.simulateRemoteHangup(lanCid);
    await until(() => p.a.engine.of('call.hangup').any((e) => e.params['cid'] == cid), what: 'external hangup');
    await until(() => p.ca.read(callsProvider).calls.isEmpty, what: 'calls gone');
    expect(p.ca.read(lanRelayProvider), isEmpty);
    final rec = p.ca.read(historyProvider).single;
    expect(rec.result, CallResult.handedOff);
    expect(rec.remoteNumber, '1002');
  });

  test('relay: external caller hanging up ends the LAN leg', () async {
    final p = await setup();
    p.wireNetwork();
    await allLive(p);
    final cid = await p.externalCall();
    await p.callsA.handoffToLan(cid, p.deviceB);
    final lanCid = p.a.engine.of('call.bridge').single.params['b'] as int;
    p.a.engine.simulateRemoteHangup(cid);
    await until(() => p.a.engine.of('call.hangup').any((e) => e.params['cid'] == lanCid), what: 'lan leg hangup');
    expect(p.ca.read(lanRelayProvider), isEmpty);
  });

  test('take back: unbridge, reattach local audio, hang up the LAN leg, keep the call', () async {
    final p = await setup();
    p.wireNetwork();
    await allLive(p);
    final cid = await p.externalCall();
    await p.callsA.handoffToLan(cid, p.deviceB);
    final lanCid = p.a.engine.of('call.bridge').single.params['b'] as int;
    final mark = p.a.engine.log.length;
    await p.implA.takeBack(cid);
    final after = p.a.engine.log.skip(mark).toList();
    expect(after.map((e) => e.method), containsAllInOrder(['call.bridge', 'call.detachLocal', 'call.hangup']));
    expect(after.firstWhere((e) => e.method == 'call.bridge').params['bridge'], false);
    expect(after.firstWhere((e) => e.method == 'call.detachLocal').params, {'cid': cid, 'detached': false});
    expect(after.firstWhere((e) => e.method == 'call.hangup').params['cid'], lanCid);
    expect(p.ca.read(lanRelayProvider), isEmpty);
    // The external call is still up and is not recorded as handed off.
    await Future<void>.delayed(const Duration(milliseconds: 100));
    final c = p.ca.read(callsProvider).byCid(cid)!;
    expect(c.isConfirmed, isTrue);
    expect(c.forcedResult, isNull);
  });

  test('End on a relayed call hangs up both legs', () async {
    final p = await setup();
    p.wireNetwork();
    await allLive(p);
    final cid = await p.externalCall();
    await p.callsA.handoffToLan(cid, p.deviceB);
    final lanCid = p.a.engine.of('call.bridge').single.params['b'] as int;
    await p.implA.endRelayed(cid);
    final hung = p.a.engine.of('call.hangup').map((e) => e.params['cid']).toSet();
    expect(hung, containsAll([cid, lanCid]));
  });

  test('declined hand-off keeps the original call and shows a notice', () async {
    final p = await setup();
    p.wireNetwork(accept: false);
    await allLive(p);
    final cid = await p.externalCall();
    await p.callsA.handoffToLan(cid, p.deviceB);
    expect(p.a.engine.methods, isNot(contains('call.make')));
    expect(p.a.engine.methods, isNot(contains('call.bridge')));
    expect(p.ca.read(callsProvider).byCid(cid)!.isConfirmed, isTrue);
    expect(p.ca.read(noticeProvider)!.message, contains('declined'), reason: '${p.ca.read(noticeProvider)!.details}');
    expect(p.ca.read(lanRelayProvider), isEmpty);
  });

  test('peer that does not answer the LAN call: call stays, mute restored', () async {
    final p = await setup();
    p.implB.pendingOffers.listen((h) => p.implB.respond(h, true));
    // No INVITE reaches B and the fake LAN callee never answers.
    p.a.engine.calleeRules[p.b.id(p.cb)] = CalleeBehavior.decline;
    await allLive(p);
    final cid = await p.externalCall();
    await p.callsA.handoffToLan(cid, p.deviceB);
    expect(p.a.engine.methods, isNot(contains('call.bridge')));
    final mutes = p.a.engine.of('call.mute').map((e) => e.params['mute']).toList();
    expect(mutes, [true, false]);
    expect(p.ca.read(callsProvider).byCid(cid)!.isConfirmed, isTrue);
  });

  test('refer mode: peer registered on the same PBX gets a REFER, no relay', () async {
    final p = await setup(bAccount: true);
    p.wireNetwork();
    await until(() => (p.ca.read(lanControllerProvider).peer(p.b.id(p.cb))?.info?.aors ?? []).isNotEmpty, what: 'peer AOR');
    final cid = await p.externalCall();
    await p.callsA.handoffToLan(cid, p.deviceB);
    final t = p.a.engine.of('call.transfer').single;
    expect(t.params['cid'], cid);
    expect(t.params['target'], 'sip:2001@pbx.test');
    expect(p.a.engine.methods, isNot(contains('call.make')));
    expect(p.a.engine.methods, isNot(contains('call.bridge')));
    expect(p.ca.read(lanRelayProvider), isEmpty);
  });

  test('refer mode, attended: consult call to the AOR on the PBX', () async {
    final p = await setup(bAccount: true);
    p.wireNetwork();
    await until(() => (p.ca.read(lanControllerProvider).peer(p.b.id(p.cb))?.info?.aors ?? []).isNotEmpty, what: 'peer AOR');
    final cid = await p.externalCall();
    await p.callsA.handoffToLan(cid, p.deviceB, mode: plat.HandoffMode.attended);
    expect(p.a.engine.methods, containsAllInOrder(['call.hold', 'call.make']));
    expect(p.a.engine.of('call.make').last.params['uri'], 'sip:2001@pbx.test');
  });

  test('attended relay: talk first on the LAN call, then complete bridges and unholds', () async {
    final p = await setup();
    p.wireNetwork();
    await allLive(p);
    final cid = await p.externalCall();
    await p.callsA.handoffToLan(cid, p.deviceB, mode: plat.HandoffMode.attended);
    await until(() => p.ca.read(lanRelayProvider)[cid]?.lanCid != null, what: 'consult');
    await until(() => p.ca.read(callsProvider).byCid(p.ca.read(lanRelayProvider)[cid]!.lanCid!)!.isConfirmed, what: 'consult answered');
    final s = p.ca.read(lanRelayProvider)[cid]!;
    expect(s.phase, RelayPhase.consulting);
    expect(p.a.engine.methods, containsAllInOrder(['call.hold', 'call.make']));
    expect(p.a.engine.methods, isNot(contains('call.bridge')));
    // The consult leg is visible so the owner can talk to the peer.
    expect(p.ca.read(callsProvider).byCid(s.lanCid!), isNotNull);
    expect(p.ca.read(callsProvider).byCid(s.lanCid!)!.consultOf, cid);

    final ok = await p.callsA.completeAttended(s.lanCid!);
    expect(ok, isTrue);
    expect(p.a.engine.methods, containsAllInOrder(['call.unhold', 'call.bridge', 'call.detachLocal', 'call.detachLocal']));
    expect(p.ca.read(lanRelayProvider)[cid]!.phase, RelayPhase.relayed);
    expect(p.ca.read(callsProvider).calls.map((c) => c.cid), [cid]);
  });

  test('forward a ringing call: offer first, then answer and relay', () async {
    final p = await setup();
    p.wireNetwork();
    await allLive(p);
    final ref = p.a.engine.simulateIncomingCall(acc: const AccountRef.uid('acc1'), from: 'sip:1002@pbx.test', displayName: 'Alice');
    await until(() => p.ca.read(callsProvider).byCid(ref.cid) != null, what: 'ringing');
    await p.callsA.forwardIncomingToLan(ref.cid, p.deviceB);
    expect(p.a.engine.methods, containsAllInOrder(['call.answer', 'call.make', 'call.bridge', 'call.detachLocal']));
    expect(p.ca.read(lanRelayProvider)[ref.cid]!.phase, RelayPhase.relayed);
  });

  test('forward a ringing call to a refer-capable peer redirects (302)', () async {
    final p = await setup(bAccount: true);
    p.wireNetwork();
    await until(() => (p.ca.read(lanControllerProvider).peer(p.b.id(p.cb))?.info?.aors ?? []).isNotEmpty, what: 'peer AOR');
    final ref = p.a.engine.simulateIncomingCall(acc: const AccountRef.uid('acc1'), from: 'sip:1002@pbx.test');
    await until(() => p.ca.read(callsProvider).byCid(ref.cid) != null, what: 'ringing');
    await p.callsA.forwardIncomingToLan(ref.cid, p.deviceB);
    final r = p.a.engine.of('call.redirect').single;
    expect(r.params['targets'], ['sip:2001@pbx.test']);
    expect(p.a.engine.methods, isNot(contains('call.answer')));
  });

  test('call pull: peer lists active calls and pulls; owner relays automatically', () async {
    final p = await setup(pull: true);
    p.wireNetwork(accept: false); // prompts would decline: pull must auto-accept
    await allLive(p);
    final cid = await p.externalCall();
    await p.b.lan().requestCalls(p.a.id(p.ca));
    await until(() => (p.cb.read(lanControllerProvider).remoteCalls[p.a.id(p.ca)] ?? []).isNotEmpty, what: 'calls list');
    final call = p.cb.read(lanControllerProvider).remoteCalls[p.a.id(p.ca)]!.single;
    expect(call.callId, '$cid');
    expect(call.remoteNumber, '1002');
    await p.b.lan().pull(p.a.id(p.ca), call);
    await until(() => p.ca.read(lanRelayProvider)[cid]?.phase == RelayPhase.relayed, what: 'pull relay');
    expect(p.a.engine.methods, contains('call.bridge'));
  });

  test('call pull is ignored unless the owner allowed it', () async {
    final p = await setup(pull: false);
    p.wireNetwork();
    await allLive(p);
    await p.externalCall();
    await p.b.lan().requestCalls(p.a.id(p.ca));
    await Future<void>.delayed(const Duration(milliseconds: 400));
    expect(p.cb.read(lanControllerProvider).remoteCalls[p.a.id(p.ca)] ?? [], isEmpty);
  });

  test('intercom: paired, allowed peer is auto-answered; header alone from a stranger is not', () async {
    final p = await setup();
    p.wireNetwork();
    await allLive(p);
    final id = await p.a.lan().callPeer(p.b.id(p.cb), intercom: true);
    expect(id, isNotNull);
    final make = p.a.engine.of('call.make').single;
    expect(Map<String, String>.from(make.params['headers'] as Map)['Call-Info'], contains('answer-after=0'));
    await until(() => p.b.engine.methods.contains('call.answer'), what: 'auto answer');
    expect(p.cb.read(callsProvider).ongoing.single.lan!.intercom, isTrue);

    // A stranger (unknown device / no handshake) sending the same header rings.
    p.b.engine.log.clear();
    final ref = p.b.engine.simulateIncomingCall(
      acc: const AccountRef.uid(kLanAccountUid),
      from: 'sip:evil@127.0.0.9:5070',
      headers: {'Call-Info': '<sip:x>;answer-after=0', kHdrDevice: 'ffffffffffffffff'},
      autoAnswerHint: const AutoAnswerHint(afterSec: 0, source: AutoAnswerSource.callInfo),
    );
    await Future<void>.delayed(const Duration(milliseconds: 200));
    expect(p.b.engine.methods, isNot(contains('call.answer')));
    expect(p.cb.read(callsProvider).byCid(ref.cid)!.isRingingIn, isTrue);
  });

  test('intercom is refused when the callee disallows it', () async {
    final p = await setup(bSettings: {'lanAllowIntercom': false});
    p.wireNetwork();
    await allLive(p);
    final id = await p.a.lan().callPeer(p.b.id(p.cb), intercom: true);
    expect(id, isNull);
    expect(p.a.engine.methods, isNot(contains('call.make')));
  });

  test('intercom: prompt mode, user allows -> granted and auto-answered', () async {
    final p = await setup(bSettings: {'lanIntercomPrompt': true});
    p.wireNetwork();
    await allLive(p);
    p.cb.read(lanControllerProvider.notifier).intercomPrompts.listen((r) => r.respond(true, expiresSec: 30));
    final id = await p.a.lan().callPeer(p.b.id(p.cb), intercom: true);
    expect(id, isNotNull);
    await until(() => p.b.engine.methods.contains('call.answer'), what: 'auto answer');
    expect(p.cb.read(lanControllerProvider.notifier).intercomGranted(p.a.id(p.ca)), isTrue);
  });

  test('intercom: prompt mode, user denies -> no call', () async {
    final p = await setup(bSettings: {'lanIntercomPrompt': true});
    p.wireNetwork();
    await allLive(p);
    p.cb.read(lanControllerProvider.notifier).intercomPrompts.listen((r) => r.respond(false));
    final id = await p.a.lan().callPeer(p.b.id(p.cb), intercom: true);
    expect(id, isNull);
    expect(p.a.engine.methods, isNot(contains('call.make')));
    expect(p.cb.read(lanControllerProvider.notifier).intercomGranted(p.a.id(p.ca)), isFalse);
  });

  test('intercom: no answer within the timeout counts as denied', () async {
    final p = await setup(bSettings: {'lanIntercomPrompt': true});
    p.wireNetwork();
    await allLive(p);
    p.cb.read(lanControllerProvider.notifier).intercomPrompts.listen((_) {});
    p.a.lan().intercomRequestTimeout = const Duration(milliseconds: 400);
    final id = await p.a.lan().callPeer(p.b.id(p.cb), intercom: true);
    expect(id, isNull);
    expect(p.a.engine.methods, isNot(contains('call.make')));
  });

  test('refer failure: exactly one notice, no hold flap, relay fallback', () async {
    final p = await setup(bAccount: true);
    p.wireNetwork();
    await until(() => (p.ca.read(lanControllerProvider).peer(p.b.id(p.cb))?.info?.aors ?? []).isNotEmpty, what: 'peer AOR');
    p.a.engine.transferResultCode = 503;
    final cid = await p.externalCall();
    final notices = <String>[];
    p.ca.listen(noticeProvider, (_, n) {
      if (n != null) notices.add(n.message);
    }, fireImmediately: false);
    p.a.engine.log.clear();
    await p.callsA.handoffToLan(cid, p.deviceB);
    await Future<void>.delayed(const Duration(milliseconds: 300));
    expect(p.a.engine.of('call.transfer'), hasLength(1));
    // Relay fallback happened (call to B over LAN), and nothing unheld before it.
    expect(p.a.engine.methods, contains('call.make'));
    final m = p.a.engine.methods;
    final iMake = m.indexOf('call.make');
    expect(m.sublist(m.indexOf('call.transfer'), iMake), isNot(contains('call.unhold')));
    expect(notices.where((n) => n.contains('Transfer failed')), isEmpty);
    expect(notices.where((n) => n.contains('Relaying')), hasLength(1));
  });
}
