import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:lan_link/lan_link.dart';
import 'package:test/test.dart';

import 'helpers.dart';

void main() {
  group('pairing', () {
    test('both confirm -> trusted on both sides, SAS equal', () async {
      final a = await makeNode('A');
      final b = await makeNode('B');
      addTearDown(() => stopNode(a));
      addTearDown(() => stopNode(b));
      await pairNodes(a, b);
      expect((await a.trust.get(b.id))!.name, 'B');
      expect((await b.trust.get(a.id))!.name, 'A');
      expect(a.link.peerById(b.id)!.trusted, isTrue);
    });

    test('one side rejects -> nobody trusted', () async {
      final a = await makeNode('A');
      final b = await makeNode('B');
      addTearDown(() => stopNode(a));
      addTearDown(() => stopNode(b));
      await introduce(a, b);
      final incoming = b.link.pairingRequests.first;
      final sa = a.link.pair(a.link.peerById(b.id)!);
      final sb = await incoming;
      await until(() =>
          sa.state == PairingState.awaitingConfirm &&
          sb.state == PairingState.awaitingConfirm);
      await sa.confirm();
      await sb.reject();
      await sa.done;
      expect(sa.state, PairingState.rejected);
      expect(sb.state, PairingState.rejected);
      expect(await a.trust.list(), isEmpty);
      expect(await b.trust.list(), isEmpty);
    });

    test('timeout if the other user never confirms', () async {
      final a = await makeNode('A', pairingTimeout: const Duration(seconds: 1));
      final b = await makeNode('B', pairingTimeout: const Duration(seconds: 1));
      addTearDown(() => stopNode(a));
      addTearDown(() => stopNode(b));
      await introduce(a, b);
      final incoming = b.link.pairingRequests.first;
      final sa = a.link.pair(a.link.peerById(b.id)!);
      final sb = await incoming;
      await until(() => sa.state == PairingState.awaitingConfirm);
      await sa.confirm();
      await sa.done.timeout(const Duration(seconds: 6));
      await sb.done.timeout(const Duration(seconds: 6));
      expect(sa.state, PairingState.timedOut);
      expect(sb.state, PairingState.timedOut);
      expect(await a.trust.list(), isEmpty);
      expect(await b.trust.list(), isEmpty);
    });

    test('cancel by initiator', () async {
      final a = await makeNode('A');
      final b = await makeNode('B');
      addTearDown(() => stopNode(a));
      addTearDown(() => stopNode(b));
      await introduce(a, b);
      final incoming = b.link.pairingRequests.first;
      final sa = a.link.pair(a.link.peerById(b.id)!);
      final sb = await incoming;
      await until(() => sa.state == PairingState.awaitingConfirm);
      await sa.cancel();
      await sb.done.timeout(const Duration(seconds: 5));
      expect(sa.state, PairingState.cancelled);
      expect(sb.state, PairingState.cancelled);
    });

    test('pairing attempts are rate limited per source address', () async {
      final a = await makeNode('A');
      final b = await makeNode('B');
      addTearDown(() => stopNode(a));
      addTearDown(() => stopNode(b));
      await introduce(a, b);
      PairingSession? last;
      for (var i = 0; i < 6; i++) {
        final s = last = a.link.pair(a.link.peerById(b.id)!);
        await until(() => s.state != PairingState.connecting);
        if (i < 5) {
          expect(s.state, PairingState.awaitingConfirm, reason: 'attempt $i');
          await s.cancel();
        }
      }
      expect(last!.state, PairingState.failed);
      expect(last.failure, contains('Too many'));
    });

    test('connect to a device that does not trust us: "Unknown device"',
        () async {
      final bKeys = InMemoryKeyStore();
      final bId = await LocalIdentity.loadOrCreate(bKeys);
      final aTrust = InMemoryTrustStore();
      await aTrust.put(TrustedPeer(
          deviceId: bId.deviceId,
          name: 'B',
          ed25519Pub: bId.edPub,
          pairedAt: DateTime.now()));
      final a = await makeNode('A', trust: aTrust);
      final b = await makeNode('B', keys: bKeys);
      addTearDown(() => stopNode(a));
      addTearDown(() => stopNode(b));
      await introduce(a, b);
      await expectLater(
          a.link.sendChat(b.id, 'hi'),
          throwsA(isA<HandshakeException>()
              .having((e) => e.code, 'code', 'unknown_device')
              .having((e) => e.message, 'message', contains('pair first'))));
    });

    test('sending to an unpaired device fails with unknown_device', () async {
      final a = await makeNode('A');
      final b = await makeNode('B');
      addTearDown(() => stopNode(a));
      addTearDown(() => stopNode(b));
      await introduce(a, b);
      await expectLater(
          a.link.sendChat(b.id, 'hi'),
          throwsA(isA<HandshakeException>()
              .having((e) => e.code, 'code', 'unknown_device')));
    });

    test('unpair notifies the peer and removes trust', () async {
      final a = await makeNode('A');
      final b = await makeNode('B');
      addTearDown(() => stopNode(a));
      addTearDown(() => stopNode(b));
      await pairNodes(a, b);
      await a.link.sendChat(b.id, 'warmup');
      final revoked = b.link.unpairedByPeer.first;
      await a.link.unpair(b.id);
      expect(await revoked.timeout(const Duration(seconds: 5)), a.id);
      expect(await a.trust.list(), isEmpty);
      await until(() => b.link.peerById(a.id)?.trusted != true);
      expect(await b.trust.list(), isEmpty);
    });

    test('persisted identity and trust survive restart (file stores)',
        () async {
      final dir = await Directory.systemTemp.createTemp('lanlink_persist');
      addTearDown(() => dir.delete(recursive: true));
      final k = FileKeyStore('${dir.path}/keys.json');
      final id1 = await LocalIdentity.loadOrCreate(k);
      final id2 = await LocalIdentity.loadOrCreate(
          FileKeyStore('${dir.path}/keys.json'));
      expect(id2.deviceId, id1.deviceId);
      final t = FileTrustStore('${dir.path}/trust.json');
      await t.put(TrustedPeer(
          deviceId: id1.deviceId,
          name: 'x',
          ed25519Pub: id1.edPub,
          pairedAt: DateTime.now()));
      expect(
          (await FileTrustStore('${dir.path}/trust.json').list()).single.name,
          'x');
      await t.remove(id1.deviceId);
      expect(await FileTrustStore('${dir.path}/trust.json').list(), isEmpty);
    });
  });

  group('connected', () {
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

    test('chat round trip with delivered and read acks', () async {
      final got = b.link.chatMessages.where((m) => m.incoming).first;
      final updates = <ChatStatus>[];
      final sub = a.link.chatMessages
          .where((m) => !m.incoming)
          .listen((m) => updates.add(m.status));
      final sent =
          await a.link.sendChat(b.id, 'hello \u{1F600}', replyTo: 'abc');
      final m = await got.timeout(const Duration(seconds: 10));
      expect(m.text, 'hello \u{1F600}');
      expect(m.peerId, a.id);
      expect(m.replyTo, 'abc');
      await until(() => sent.status == ChatStatus.delivered);
      await b.link.markRead(a.id, m.id);
      await until(() => sent.status == ChatStatus.read);
      expect(updates, containsAll([ChatStatus.delivered, ChatStatus.read]));
      await sub.cancel();

      // reverse direction + typing
      final typing = a.link.typingEvents.first;
      await b.link.sendTyping(a.id, true);
      expect((await typing.timeout(const Duration(seconds: 5))).typing, isTrue);
      final back = a.link.chatMessages.where((m) => m.incoming).first;
      await b.link.sendChat(a.id, 'pong');
      expect((await back.timeout(const Duration(seconds: 5))).text, 'pong');
    });

    test('invalid chat is rejected locally', () async {
      expect(a.link.sendChat(b.id, ''), throwsA(isA<LanLinkException>()));
      expect(
          a.link.sendChat(b.id, 'x' * 9000), throwsA(isA<LanLinkException>()));
    });

    test('offline peer: fail fast, optional outbox retries on return',
        () async {
      final bPort = b.port;
      final bKeys = b.keys, bTrust = b.trust, bDir = b.dir;
      await b.link.stop();
      await expectLater(
          a.link.sendChat(b.id, 'x').timeout(const Duration(seconds: 8)),
          throwsA(isA<PeerOfflineException>()));
      final queued = await a.link.sendChat(b.id, 'later', queue: true);
      expect(queued.status, ChatStatus.queued);

      b = await makeNode('B',
          keys: bKeys, trust: bTrust, dir: bDir, port: bPort);
      await introduce(a, b);
      await until(() => b.inbox.any((m) => m.text == 'later'));
      await until(() =>
          queued.status == ChatStatus.delivered ||
          queued.status == ChatStatus.sent);
    });

    test('status update propagates', () async {
      await a.link.sendChat(b.id, 'connect');
      await a.link.updateStatus(PeerStatus.dnd);
      await until(() => b.link.peerById(a.id)?.status == PeerStatus.dnd);
    });

    test('disabled capability on the other side', () async {
      final c = await makeNode('C', caps: {Capability.chat});
      addTearDown(() => stopNode(c));
      await pairNodes(a, c);
      final f = File('${a.dir.path}/x.txt')..writeAsStringSync('x');
      expect(() => a.link.sendFile(c.id, f.path),
          throwsA(isA<LanLinkException>()));
    });

    test('handoff offer accept / decline / cancel / timeout', () async {
      const offer = HandoffOffer(
          handoffId: 'h1',
          mode: HandoffMode.relay,
          caller: CallerInfo(
              name: 'Alice', number: '+15551234', uri: 'sip:alice@x'),
          accountName: 'Work',
          lanSipUri: 'sip:aaaa@192.168.1.2:5070',
          attended: true);
      final inc = b.link.handoffOffers.first;
      final res = a.link.offerHandoff(b.id, offer);
      final h = await inc.timeout(const Duration(seconds: 10));
      expect(h.offer.caller.name, 'Alice');
      expect(h.offer.attended, isTrue);
      expect(h.offer.lanSipUri, 'sip:aaaa@192.168.1.2:5070');
      expect(h.peer.deviceId, a.id);
      await h.accept();
      expect((await res).accepted, isTrue);
      final done = b.link.handoffEvents.first;
      await a.link.completeHandoff(b.id, 'h1');
      expect((await done.timeout(const Duration(seconds: 5))).kind,
          HandoffEventKind.completed);

      // decline
      final inc2 = b.link.handoffOffers.first;
      final res2 = a.link.offerHandoff(
          b.id,
          const HandoffOffer(
              handoffId: 'h2',
              mode: HandoffMode.refer,
              caller: CallerInfo(),
              referTarget: 'sip:b@pbx'));
      await (await inc2).decline('busy');
      final r2 = await res2;
      expect(r2.outcome, HandoffOutcome.declined);
      expect(r2.reason, 'busy');
    });

    test('handoff timeout cancels on the peer', () async {
      final a2 =
          await makeNode('A2', handoffTimeout: const Duration(seconds: 1));
      addTearDown(() => stopNode(a2));
      await pairNodes(a2, b);
      final inc = b.link.handoffOffers.first;
      final evt = b.link.handoffEvents.first;
      final r = await a2.link.offerHandoff(
          b.id,
          const HandoffOffer(
              handoffId: 'h3', mode: HandoffMode.relay, caller: CallerInfo()));
      expect(r.outcome, HandoffOutcome.timeout);
      final h = await inc;
      expect((await evt.timeout(const Duration(seconds: 5))).kind,
          HandoffEventKind.cancelled);
      expect(h.cancelled, isTrue);
    });

    test('calls list, pull and intercom', () async {
      final q = b.link.callsQueries.first;
      await a.link.requestCallsList(b.id);
      final query = await q.timeout(const Duration(seconds: 10));
      final lst = a.link.callsLists.first;
      await query.respond(const [
        CallSummary(
            callId: 'c1',
            remoteName: 'Bob',
            remoteNumber: '100',
            durationSec: 12,
            accountName: 'W')
      ]);
      final l = await lst.timeout(const Duration(seconds: 5));
      expect(l.calls.single.remoteName, 'Bob');
      expect(l.calls.single.durationSec, 12);

      final pull = b.link.pullRequests.first;
      await a.link.requestPull(b.id, 'c1');
      expect((await pull.timeout(const Duration(seconds: 5))).callId, 'c1');

      final ic = b.link.intercomRequests.first;
      await a.link.sendIntercomRequest(b.id, allowed: true);
      expect((await ic.timeout(const Duration(seconds: 5))).allowed, isTrue);
    });
  });

  group('files', () {
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

    test('5 MB random file arrives intact with progress; collisions renamed',
        () async {
      final src = await randomFile(a.dir, 'blob.bin', 5 * 1024 * 1024 + 123);
      final srcHash = await sha256OfFile(src.path);
      for (var round = 0; round < 2; round++) {
        final inc = b.link.fileTransfers.where((t) => t.incoming).first;
        final out = a.link.sendFile(b.id, src.path);
        final progress = <int>[];
        out.updates.listen((t) => progress.add(t.bytesDone));
        final t = await inc.timeout(const Duration(seconds: 15));
        expect(t.name, 'blob.bin');
        expect(t.size, src.lengthSync());
        await until(() => t.state == TransferState.offered);
        await t.accept();
        await out.done.timeout(const Duration(seconds: 60));
        await t.done.timeout(const Duration(seconds: 60));
        expect(out.state, TransferState.completed, reason: '${out.error}');
        expect(t.state, TransferState.completed, reason: '${t.error}');
        expect(t.savedPath,
            '${b.downloads}/${round == 0 ? 'blob.bin' : 'blob (1).bin'}');
        expect(await sha256OfFile(t.savedPath!), srcHash);
        expect(progress.length, greaterThan(3));
        for (var i = 1; i < progress.length; i++) {
          expect(progress[i], greaterThanOrEqualTo(progress[i - 1]));
        }
      }
      // no leftover partial data
      final partial = Directory('${b.downloads}/.spp-partial');
      expect(!partial.existsSync() || partial.listSync().isEmpty, isTrue);
    });

    test('empty file', () async {
      final src = File('${a.dir.path}/empty.txt')..writeAsBytesSync([]);
      final inc = b.link.fileTransfers.where((t) => t.incoming).first;
      final out = a.link.sendFile(b.id, src.path);
      final t = await inc;
      await until(() => t.state == TransferState.offered);
      await t.accept();
      await out.done.timeout(const Duration(seconds: 20));
      expect(out.state, TransferState.completed);
      expect(File(t.savedPath!).lengthSync(), 0);
    });

    test('decline', () async {
      final src = await randomFile(a.dir, 'd.bin', 1000);
      final inc = b.link.fileTransfers.where((t) => t.incoming).first;
      final out = a.link.sendFile(b.id, src.path);
      final t = await inc;
      await until(() => t.state == TransferState.offered);
      await t.decline('no thanks');
      await out.done.timeout(const Duration(seconds: 10));
      expect(out.state, TransferState.declined);
      expect(out.error, contains('no thanks'));
      expect(Directory(b.downloads).listSync().whereType<File>(), isEmpty);
    });

    test('cancel mid-transfer by sender removes partial data', () async {
      final src = await randomFile(a.dir, 'big.bin', 12 * 1024 * 1024);
      final inc = b.link.fileTransfers.where((t) => t.incoming).first;
      final out = a.link.sendFile(b.id, src.path);
      final t = await inc;
      await until(() => t.state == TransferState.offered);
      await t.accept();
      await until(() => out.bytesDone > 512 * 1024);
      await out.cancel();
      await t.done.timeout(const Duration(seconds: 10));
      expect(out.state, TransferState.cancelled);
      expect(t.state, TransferState.cancelled);
      await Future<void>.delayed(const Duration(milliseconds: 200));
      expect(Directory(b.downloads).listSync(recursive: true).whereType<File>(),
          isEmpty);
    });

    test('cancel by receiver', () async {
      final src = await randomFile(a.dir, 'big2.bin', 12 * 1024 * 1024);
      final inc = b.link.fileTransfers.where((t) => t.incoming).first;
      final out = a.link.sendFile(b.id, src.path);
      final t = await inc;
      await until(() => t.state == TransferState.offered);
      await t.accept();
      await until(() => t.bytesDone > 512 * 1024);
      await t.cancel();
      await out.done.timeout(const Duration(seconds: 10));
      expect(out.state, TransferState.cancelled);
    });

    test('resume after connection drop continues from partial offset',
        () async {
      final src = await randomFile(a.dir, 'resume.bin', 10 * 1024 * 1024);
      final srcHash = await sha256OfFile(src.path);
      var inc = b.link.fileTransfers.where((t) => t.incoming).first;
      final out1 = a.link.sendFile(b.id, src.path);
      var t = await inc;
      await until(() => t.state == TransferState.offered);
      await t.accept();
      await until(() => t.bytesDone > 1024 * 1024);
      await a.link.debugDropConnection(b.id);
      await out1.done.timeout(const Duration(seconds: 15));
      await t.done.timeout(const Duration(seconds: 15));
      expect(out1.state, TransferState.failed);
      expect(t.state, TransferState.failed);
      final partial = Directory('${b.downloads}/.spp-partial')
          .listSync()
          .whereType<File>()
          .single;
      final partialLen = partial.lengthSync();
      expect(partialLen, greaterThan(0));
      expect(partialLen, lessThan(src.lengthSync()));

      inc = b.link.fileTransfers.where((t) => t.incoming).first;
      final out2 = a.link.sendFile(b.id, src.path);
      t = await inc.timeout(const Duration(seconds: 20));
      await until(() => t.state == TransferState.offered);
      await t.accept();
      await out2.done.timeout(const Duration(seconds: 60));
      expect(out2.state, TransferState.completed, reason: '${out2.error}');
      expect(out2.resumedFrom, greaterThanOrEqualTo(partialLen));
      expect(t.resumedFrom, greaterThanOrEqualTo(partialLen));
      expect(await sha256OfFile(t.savedPath!), srcHash);
    });

    test('path traversal names are rejected, nothing written outside',
        () async {
      final seen = <FileTransfer>[];
      b.link.fileTransfers.listen(seen.add);
      final declines = <String>[];
      // Intercept declines arriving at A via its fileTransfers? They are
      // protocol-level; verify by absence of transfers and files instead.
      for (final bad in [
        '../../evil.txt',
        '..\\..\\evil.txt',
        'a/b.txt',
        '..',
        '/etc/passwd',
        'x\u0000y'
      ]) {
        await a.link.debugSend(
            b.id,
            FileOffer(
                transferId: 'aa' * 16, name: bad, size: 3, sha256: '00' * 32));
      }
      await Future<void>.delayed(const Duration(milliseconds: 500));
      expect(seen, isEmpty, reason: declines.join());
      expect(File('${b.dir.path}/evil.txt').existsSync(), isFalse);
      expect(File('${b.dir.path}/../evil.txt').existsSync(), isFalse);
      // connection is still healthy
      await a.link.sendChat(b.id, 'still ok');
    });

    test('wrong hash is detected and file is discarded', () async {
      final inc = b.link.fileTransfers.where((t) => t.incoming).first;
      final tid = 'bb' * 16;
      await a.link.debugSend(
          b.id,
          FileOffer(
              transferId: tid, name: 'bad.bin', size: 5, sha256: 'ab' * 32));
      final t = await inc;
      await until(() => t.state == TransferState.offered);
      await t.accept();
      await until(() => t.state == TransferState.transferring);
      await a.link.debugSendChunk(
          b.id, FileChunk(tid, 0, Uint8List.fromList([1, 2, 3, 4, 5])));
      await a.link.debugSend(b.id, FileComplete(tid));
      await t.done.timeout(const Duration(seconds: 10));
      expect(t.state, TransferState.failed);
      expect(t.error, 'hash_mismatch');
      expect(Directory(b.downloads).listSync(recursive: true).whereType<File>(),
          isEmpty);
    });

    test('out-of-order chunk offset aborts the transfer', () async {
      final inc = b.link.fileTransfers.where((t) => t.incoming).first;
      final tid = 'cc' * 16;
      await a.link.debugSend(
          b.id,
          FileOffer(
              transferId: tid, name: 'o.bin', size: 100, sha256: 'ab' * 32));
      final t = await inc;
      await until(() => t.state == TransferState.offered);
      await t.accept();
      await until(() => t.state == TransferState.transferring);
      await a.link.debugSendChunk(b.id, FileChunk(tid, 50, Uint8List(10)));
      await t.done.timeout(const Duration(seconds: 10));
      expect(t.state, TransferState.failed);
    });

    test('offers above the size limit are declined', () async {
      final c = await makeNode('C', maxFileSize: 1000);
      addTearDown(() => stopNode(c));
      await pairNodes(a, c);
      final src = await randomFile(a.dir, 'toobig.bin', 5000);
      final out = a.link.sendFile(c.id, src.path);
      await out.done.timeout(const Duration(seconds: 15));
      expect(out.state, TransferState.declined);
      expect(out.error, contains('too_large'));
    });
  });

  group('sanitizeFileName', () {
    test('rejects traversal, cleans odd characters', () {
      expect(sanitizeFileName('../x'), isNull);
      expect(sanitizeFileName('a\\b'), isNull);
      expect(sanitizeFileName('..'), isNull);
      expect(sanitizeFileName(''), isNull);
      expect(sanitizeFileName('ok.txt'), 'ok.txt');
      expect(sanitizeFileName('a:b?.txt'), 'a_b_.txt');
      expect(sanitizeFileName('.hidden'), '_hidden');
      expect(sanitizeFileName('CON.txt'), '_CON.txt');
      expect(sanitizeFileName('trail. '), 'trail');
      expect(sanitizeFileName('${'a' * 300}.pdf')!.length, 200);
      expect(sanitizeFileName('${'a' * 300}.pdf')!.endsWith('.pdf'), isTrue);
    });
  });

  group('transport hardening', () {
    test('/info works; garbage and oversized handshakes do not hurt the server',
        () async {
      final b = await makeNode('B');
      addTearDown(() => stopNode(b));
      final info = await fetchDeviceInfo('127.0.0.1', b.port);
      expect(info.deviceId, b.id);
      expect(info.linkPort, b.port);

      for (final payload in [
        'not json',
        '{"t":"hello"}',
        '[]',
        'x' * 100000,
        '{"t":"hello","v":1,"deviceId":5}'
      ]) {
        final ws =
            await WebSocket.connect('ws://127.0.0.1:${b.port}/spp/v1/ws');
        ws.listen((_) {}, onError: (_) {});
        ws.add(payload);
        await ws.done.timeout(const Duration(seconds: 12), onTimeout: () {});
      }
      // binary garbage
      final ws = await WebSocket.connect('ws://127.0.0.1:${b.port}/spp/v1/ws');
      ws.listen((_) {}, onError: (_) {});
      ws.add(List<int>.filled(500, 7));
      await ws.done.timeout(const Duration(seconds: 12), onTimeout: () {});

      final again = await fetchDeviceInfo('127.0.0.1', b.port);
      expect(again.deviceId, b.id);
      // other paths 404
      final c = HttpClient();
      final r =
          await (await c.getUrl(Uri.parse('http://127.0.0.1:${b.port}/nope')))
              .close();
      expect(r.statusCode, 404);
      c.close();
    });

    test('manual discovery rejects non-SoftphonePro endpoints', () async {
      final srv = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      addTearDown(() => srv.close(force: true));
      srv.listen((r) {
        r.response.write('{"deviceId":"x"}');
        r.response.close();
      });
      final a = await makeNode('A');
      addTearDown(() => stopNode(a));
      await expectLater(a.link.connectManual('127.0.0.1', srv.port),
          throwsA(isA<LanLinkException>()));
      await expectLater(a.link.connectManual('127.0.0.1', 1),
          throwsA(isA<LanLinkException>()));
    });
  });
}
