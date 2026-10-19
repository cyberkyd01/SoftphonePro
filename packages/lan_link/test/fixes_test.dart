import 'dart:async';

import 'package:lan_link/lan_link.dart';
import 'package:test/test.dart';

import 'helpers.dart';

class SlowTrustStore extends InMemoryTrustStore {
  @override
  Future<void> put(TrustedPeer peer) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    await super.put(peer);
  }
}

/// Pairs where only [a] knows [b]'s address.
Future<void> pairOneWay(Node a, Node b) async {
  await a.link.connectManual('127.0.0.1', b.port);
  final incoming = b.link.pairingRequests.first;
  final sa = a.link.pair(a.link.peerById(b.id)!);
  final sb = await incoming;
  await until(() =>
      sa.state == PairingState.awaitingConfirm &&
      sb.state == PairingState.awaitingConfirm);
  await sa.confirm();
  await sb.confirm();
  await sa.done;
  await sb.done;
  expect(sa.state, PairingState.paired, reason: sa.failure);
  expect(sb.state, PairingState.paired, reason: sb.failure);
}

void main() {
  test('larger-id side that added the peer by address dials it', () async {
    Node a, b;
    while (true) {
      a = await makeNode('A', keepConnected: true);
      b = await makeNode('B', keepConnected: false);
      if (a.id.compareTo(b.id) > 0) break;
      await stopNode(a);
      await stopNode(b);
    }
    addTearDown(() => stopNode(a));
    addTearDown(() => stopNode(b));
    await pairOneWay(a, b);
    await until(() => a.link.peerById(b.id)?.connected == true,
        timeout: const Duration(seconds: 10));
    await a.link.sendChat(b.id, 'hi');
    await until(() => b.inbox.any((m) => m.text == 'hi'));
  });

  test('pairing succeeds on both sides even if persisting is slow', () async {
    final a = await makeNode('A', trust: SlowTrustStore());
    final b = await makeNode('B', trust: SlowTrustStore());
    addTearDown(() => stopNode(a));
    addTearDown(() => stopNode(b));
    await pairOneWay(a, b);
    expect(await a.trust.get(b.id), isNotNull);
    expect(await b.trust.get(a.id), isNotNull);
  });

  test('pairing records the peer address and link port', () async {
    final a = await makeNode('A');
    final b = await makeNode('B');
    addTearDown(() => stopNode(a));
    addTearDown(() => stopNode(b));
    await pairOneWay(a, b);
    // b never saw a via discovery.
    final p = b.link.peerById(a.id)!;
    expect(p.trusted, isTrue);
    expect(p.online, isTrue);
    expect(p.address?.address, '127.0.0.1');
    expect(p.linkPort, a.port);
    await b.link.sendChat(a.id, 'back');
    await until(() => a.inbox.any((m) => m.text == 'back'));
  });

  group('intercom negotiation', () {
    late Node a, b;
    setUp(() async {
      a = await makeNode('A');
      b = await makeNode('B');
      await pairNodes(a, b);
    });
    tearDown(() async {
      await stopNode(a);
      await stopNode(b);
    });

    test('allowed grant is short lived and checked by the callee', () async {
      b.link.intercomNegotiations.listen((r) => r.respond(true, expiresSec: 1));
      expect(b.link.intercomGranted(a.id), isFalse);
      final g = await a.link.requestIntercom(b.id);
      expect(g.allowed, isTrue);
      expect(g.valid, isTrue);
      expect(b.link.intercomGranted(a.id), isTrue);
      await Future<void>.delayed(const Duration(milliseconds: 1200));
      expect(b.link.intercomGranted(a.id), isFalse);
      expect(g.valid, isFalse);
    });

    test('denied', () async {
      b.link.intercomNegotiations.listen((r) => r.respond(false));
      final g = await a.link.requestIntercom(b.id);
      expect(g.allowed, isFalse);
      expect(b.link.intercomGranted(a.id), isFalse);
    });

    test('no answer times out as denied; revoke works', () async {
      final g = await a.link
          .requestIntercom(b.id, timeout: const Duration(milliseconds: 500));
      expect(g.allowed, isFalse);
      b.link.intercomNegotiations.listen((r) => r.respond(true));
      await a.link.requestIntercom(b.id);
      expect(b.link.intercomGranted(a.id), isTrue);
      b.link.revokeIntercom(a.id);
      expect(b.link.intercomGranted(a.id), isFalse);
    });

    test('legacy intercom.request still reaches intercomRequests', () async {
      final e = b.link.intercomRequests.first;
      await a.link.sendIntercomRequest(b.id, allowed: true);
      expect((await e.timeout(const Duration(seconds: 5))).allowed, isTrue);
    });
  });
}
