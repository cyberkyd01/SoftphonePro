import 'dart:async';
import 'dart:io';

import 'package:lan_link/lan_link.dart';
import 'package:lan_link/src/peer_connection.dart';
import 'package:test/test.dart';

import 'helpers.dart';

void main() {
  test('stress: close / abrupt close / reject during in-flight sends',
      () async {
    final errors = <Object>[];
    await runZonedGuarded(() async {
      final idA = await LocalIdentity.generate();
      final idB = await LocalIdentity.generate();
      final accepted = StreamController<PeerConnection>();
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      server.listen((req) async {
        try {
          final ws = await WebSocketTransformer.upgrade(req);
          final c = await handshakeAsResponder(ws, idB,
              policy: (_) async => null, expectedPeerEdFor: (_) => null);
          accepted.add(c);
        } catch (_) {}
      });
      final incoming = StreamIterator(accepted.stream);

      for (var i = 0; i < 200; i++) {
        final ws =
            await WebSocket.connect('ws://127.0.0.1:${server.port}/spp/v1/ws');
        final a = await handshakeAsInitiator(ws, idA, HandshakeMode.connect);
        expect(await incoming.moveNext(), isTrue);
        final b = incoming.current;
        a.onMessage = (_) {};
        b.onMessage = (_) {};
        a.start();
        b.start();

        final sends = <Future<void>>[];
        void burst(PeerConnection c, int n) {
          for (var k = 0; k < n; k++) {
            sends.add(c
                .send(ChatTyping(k.isEven))
                .then((_) {}, onError: (Object _) {}));
          }
        }

        burst(a, 20);
        burst(b, 20);
        switch (i % 6) {
          case 0:
            unawaited(a.close());
            burst(b, 20);
          case 1:
            unawaited(ws.close(1001)); // bypasses the connection object
            burst(a, 20);
            burst(b, 20);
          case 2:
            unawaited(a.close(1000, 'x'));
            unawaited(b.close(1000, 'y'));
            burst(a, 5);
            burst(b, 5);
          case 3:
            unawaited(a
                .send(const PairConfirm(ok: false, reason: 'rejected'))
                .then((_) {}, onError: (Object _) {}));
            unawaited(a.close());
            unawaited(a.close()); // double close
            burst(a, 10);
          case 4:
            await Future<void>.delayed(const Duration(milliseconds: 1));
            unawaited(b.ws.close(1001));
            burst(a, 30);
          default:
            burst(a, 50);
            unawaited(a.close());
            unawaited(b.close());
        }
        await Future.wait(sends).timeout(const Duration(seconds: 10));
        await Future.wait([a.done, b.done])
            .timeout(const Duration(seconds: 10));
        // sends after close fail cleanly
        await expectLater(a.send(const ChatTyping(true)),
            throwsA(isA<PeerOfflineException>()));
      }
      await incoming.cancel();
      await accepted.close();
      await server.close(force: true);
      await Future<void>.delayed(const Duration(milliseconds: 300));
    }, (e, st) => errors.add('$e\n$st'));
    expect(errors, isEmpty);
  }, timeout: const Timeout(Duration(minutes: 4)));

  test('stress: rejected and aborted handshakes leak no errors', () async {
    final errors = <Object>[];
    await runZonedGuarded(() async {
      final idA = await LocalIdentity.generate();
      final idB = await LocalIdentity.generate();
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      server.listen((req) async {
        try {
          final ws = await WebSocketTransformer.upgrade(req);
          await handshakeAsResponder(ws, idB,
              policy: (_) async =>
                  HandshakeException('unknown_device', 'Unknown device'),
              expectedPeerEdFor: (_) => null);
        } catch (_) {}
      });
      for (var i = 0; i < 100; i++) {
        final ws = await WebSocket.connect(
            'ws://127.0.0.1:${server.port}/spp/v1/ws');
        if (i % 3 == 0) {
          unawaited(ws.close(1001)); // abort mid-handshake
          unawaited(handshakeAsInitiator(ws, idA, HandshakeMode.connect)
              .then((_) {}, onError: (Object _) {}));
          await Future<void>.delayed(const Duration(milliseconds: 5));
        } else {
          await expectLater(
              handshakeAsInitiator(ws, idA, HandshakeMode.connect),
              throwsA(isA<HandshakeException>()));
        }
      }
      await server.close(force: true);
      await Future<void>.delayed(const Duration(milliseconds: 500));
    }, (e, st) => errors.add('$e\n$st'));
    expect(errors, isEmpty);
  });

  test('pairing reject / cancel repeated: no unhandled errors', () async {
    final errors = <Object>[];
    await runZonedGuarded(() async {
      final a = await makeNode('A');
      final b = await makeNode('B');
      await introduce(a, b);
      for (var i = 0; i < 4; i++) {
        final inc = b.link.pairingRequests.first;
        final sa = a.link.pair(a.link.peerById(b.id)!);
        final sb = await inc;
        await until(() =>
            sa.state == PairingState.awaitingConfirm &&
            sb.state == PairingState.awaitingConfirm);
        if (i.isEven) {
          await sb.reject();
        } else {
          await sa.cancel();
        }
        await sa.done.timeout(const Duration(seconds: 5));
        await sb.done.timeout(const Duration(seconds: 5));
      }
      await Future<void>.delayed(const Duration(milliseconds: 500));
      await stopNode(a);
      await stopNode(b);
      await Future<void>.delayed(const Duration(milliseconds: 300));
    }, (e, st) => errors.add('$e\n$st'));
    expect(errors, isEmpty);
  });
}
