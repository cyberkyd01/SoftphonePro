@Tags(['integration'])
library;

import 'dart:async';
import 'dart:io';

import 'package:spcore_dart/spcore_dart.dart';
import 'package:spcore_dart/testing.dart';
import 'package:test/test.dart';

import 'support.dart';

/// End-to-end scenarios against the local Asterisk test PBX
/// (tests/sipserver). Engine A lives in this process; engine B (the "peer")
/// runs in a separate OS process because pjsua is one-instance-per-process.
///
/// Run: SPCORE_LIB=/path/libspcore.dylib PBX_HOST=127.0.0.1 dart test -t integration
Future<void> main() async {
  final skip = await integrationSkipReason();
  late FfiSipEngine a;
  late RemoteSipEngine b;
  late EventLog la;
  late EventLog lb;
  late InvariantChecker ia;
  late InvariantChecker ib;
  late Directory tmp;
  late String wav;
  late String peerLocal; // "ip:port" of B's UDP transport
  late AccountRef a1001;
  late AccountRef b1002;

  setUpAll(() async {
    if (skip != null) return;
    tmp = Directory.systemTemp.createTempSync('spcore_it');
    wav = writeToneWav(tmp.path);
    a = FfiSipEngine();
    await a.init();
    ia = watchInvariants(a);
    la = EventLog(a.events);
    await a.start(testCoreConfig());

    b = await RemoteSipEngine.spawn();
    ib = watchInvariants(b);
    lb = EventLog(b.events);
    final started = await b.start(testCoreConfig());
    peerLocal = started.transports
        .firstWhere((t) => t.type.toLowerCase() == 'udp')
        .local;

    final c1001 = pbxAccount('1001');
    await a.addAccount(c1001);
    a1001 = AccountRef.uid(c1001.uid);
    final c1002 = pbxAccount('1002');
    final c1003 = pbxAccount('1003');
    await b.addAccount(c1002);
    await b.addAccount(c1003);
    final c1014 = pbxAccount(
      '1014',
    ); // no voicemail fallback: rejects reach the caller
    await b.addAccount(c1014);
    await lb.registered(c1014.uid);
    b1002 = AccountRef.uid(c1002.uid);
    await la.registered(c1001.uid);
    await lb.registered(c1002.uid);
    await lb.registered(c1003.uid);
  });

  tearDownAll(() async {
    if (skip != null) return;
    try {
      await a.hangupAll();
      await b.hangupAll();
    } catch (_) {}
    await Future<void>.delayed(const Duration(milliseconds: 300));
    ia.assertOk();
    ib.assertOk();
    await b.dispose();
    try {
      await a.stop();
    } catch (_) {}
    await a.dispose();
    tmp.deleteSync(recursive: true);
  });

  tearDown(() async {
    if (skip != null) return;
    await a.hangupAll();
    await b.hangupAll();
    await Future<void>.delayed(const Duration(milliseconds: 200));
  });

  /// A calls [uri]; returns (A's ref, B's incoming cid) once both ring.
  Future<(CallRef, int)> callPeer(String uri, {AccountRef? acc}) async {
    final inc = lb.next<CallIncomingEvent>(what: 'incoming at peer');
    final ref = await a.makeCall(acc: acc ?? a1001, uri: uri);
    final ev = await inc;
    return (ref, ev.cid);
  }

  Future<void> connect(CallRef ref, int bcid) async {
    final ca = la.callState(ref.cid, CallState.confirmed);
    final cb = lb.callState(bcid, CallState.confirmed);
    await b.answer(bcid);
    await ca;
    await cb;
  }

  test('core.info / snapshot / version', () async {
    final i = await a.info();
    expect(i.started, isTrue);
    final s = await a.snapshot();
    expect(s.accounts.any((x) => x.uid == '__direct__' || x.isDirect), isTrue);
    expect(a.library.versionString(), isNotEmpty);
  }, skip: skip);

  group('registration', () {
    for (final t in [AccTransport.udp, AccTransport.tcp, AccTransport.tls]) {
      test('REGISTER over ${t.wire}', () async {
        final cfg = pbxAccount('1004', transport: t);
        await a.addAccount(cfg);
        final ev = await la.registered(cfg.uid);
        expect(ev.account.regCode, 200);
        await a.removeAccount(AccountRef.uid(cfg.uid));
      }, skip: skip);
    }

    test('wrong password fails with a lastError', () async {
      final cfg = pbxAccount(
        '1005',
      ).copyWith(uid: 'bad1005', password: 'wrong');
      await a.addAccount(cfg);
      final ev = await la.wait<AccountRegEvent>(
        where: (e) =>
            e.account.uid == 'bad1005' && e.account.regState == RegState.failed,
      );
      expect(ev.account.regCode, anyOf(401, 403));
      expect(ev.account.lastError, isNotNull);
      await a.removeAccount(const AccountRef.uid('bad1005'));
    }, skip: skip);

    test('multiple accounts registered in one engine', () async {
      final c1 = pbxAccount('1006');
      final c2 = pbxAccount('1007', transport: AccTransport.tcp);
      await a.addAccount(c1);
      await a.addAccount(c2);
      await la.registered(c1.uid);
      await la.registered(c2.uid);
      final regs = (await a.listAccounts()).where(
        (x) => x.regState == RegState.registered,
      );
      expect(regs.length, greaterThanOrEqualTo(3));
      await a.removeAccount(AccountRef.uid(c1.uid));
      await a.removeAccount(AccountRef.uid(c2.uid));
    }, skip: skip);

    test(
      'MWI delivered on registration (1001/1002 have seeded messages)',
      () async {
        final cfg = pbxAccount(
          '1002',
          transport: AccTransport.tcp,
        ).copyWith(uid: 'mwi1002');
        final got = la.wait<AccountMwiEvent>(
          where: (e) => e.mwi.uid == 'mwi1002',
          what: 'mwi',
        );
        await a.addAccount(cfg);
        final ev = await got;
        expect(ev.mwi.waiting, isTrue);
        expect(ev.mwi.newMsgs, greaterThan(0));
        await a.removeAccount(const AccountRef.uid('mwi1002'));
      },
      skip: skip,
    );
  });

  group('calls', () {
    test('A->B call with media flowing, hold/unhold, hangup', () async {
      final (ref, bcid) = await callPeer('1002');
      await connect(ref, bcid);
      await a.playFile(ref.cid, wav, loop: true);
      await Future<void>.delayed(const Duration(seconds: 3));
      final sa = await a.callStats(ref.cid);
      final sb = await b.callStats(bcid);
      expect(sa.rx.packets, greaterThan(20), reason: 'A received RTP');
      expect(sb.rx.packets, greaterThan(20), reason: 'B received RTP');
      expect(sb.codec, isNotEmpty);

      final localHold = la.next<CallMediaEvent>(
        where: (e) => e.cid == ref.cid && e.media == MediaStatus.localHold,
      );
      await a.hold(ref.cid);
      await localHold;
      expect((await a.callInfo(ref.cid)).media, MediaStatus.localHold);
      final active = la.next<CallMediaEvent>(
        where: (e) => e.cid == ref.cid && e.media == MediaStatus.active,
      );
      await a.unhold(ref.cid);
      await active;

      await ia.checkRequest(() => a.hangup(ref.cid), terminalCids: [ref.cid]);
      await lb.callState(bcid, CallState.disconnected);
    }, skip: skip);

    test('B rejects with 486', () async {
      final (ref, bcid) = await callPeer('1014');
      await b.reject(bcid);
      final t = await la.callState(ref.cid, CallState.disconnected);
      expect(t.call.lastCode, 486);
    }, skip: skip);

    test('mute and levels are accepted', () async {
      final (ref, bcid) = await callPeer('1002');
      await connect(ref, bcid);
      await a.mute(ref.cid, true);
      expect((await a.callInfo(ref.cid)).muted, isTrue);
      await a.mute(ref.cid, false);
      await a.setCallLevels(ref.cid, rx: 0.5, tx: 1.5);
    }, skip: skip);

    test('DTMF to 602 (rfc2833)', () async {
      final ref = await a.makeCall(acc: a1001, uri: '602');
      await la.callState(ref.cid, CallState.confirmed);
      await Future<void>.delayed(const Duration(milliseconds: 500));
      await a.sendDtmf(ref.cid, '1234');
      await Future<void>.delayed(const Duration(seconds: 3));
      final got = await pbxDtmf('1001');
      if (got != null) expect(got, contains('1234'));
    }, skip: skip);

    test('echo call 600 receives its own audio back', () async {
      final ref = await a.makeCall(acc: a1001, uri: '600');
      await la.callState(ref.cid, CallState.confirmed);
      await a.playFile(ref.cid, wav, loop: true);
      await Future<void>.delayed(const Duration(seconds: 3));
      expect((await a.callStats(ref.cid)).rx.packets, greaterThan(50));
    }, skip: skip);

    test('direct IP call (acc -1) to peer', () async {
      final inc = lb.next<CallIncomingEvent>();
      final ref = await a.makeCall(
        acc: const AccountRef.direct(),
        uri: 'sip:$peerLocal',
      );
      final ev = await inc;
      await connect(ref, ev.cid);
      expect((await a.callInfo(ref.cid)).state, CallState.confirmed);
    }, skip: skip);

    // Asterisk performs REFER-based transfers itself (B is not sent a REFER):
    // A sees NOTIFY progress; the transfer target rings as a new call.
    test('blind transfer: A refers B to 1003', () async {
      final (ref, bcid) = await callPeer('1002');
      await connect(ref, bcid);
      final incC = lb.next<CallIncomingEvent>(
        what: 'call to 1003 (transferred)',
      );
      final fin = la.next<CallTransferStatusEvent>(
        where: (e) => e.cid == ref.cid && e.isFinal,
      );
      await a.transfer(ref.cid, 'sip:1003@$pbxHost');
      expect((await fin).code, inInclusiveRange(200, 299));
      final ev = await incC;
      expect(ev.call.state, CallState.incoming);
    }, skip: skip);

    test('attended transfer', () async {
      final (r1, b1) = await callPeer('1002');
      await connect(r1, b1);
      await a.hold(r1.cid);
      final (r2, b2) = await callPeer('1003');
      await connect(r2, b2);
      final fin = la.next<CallTransferStatusEvent>(
        where: (e) => e.cid == r1.cid && e.isFinal,
      );
      await a.transferAttended(r1.cid, r2.cid);
      expect((await fin).code, inInclusiveRange(200, 299));
    }, skip: skip);

    test('three-way conference with media from both parties', () async {
      final (r1, b1) = await callPeer('1002');
      await connect(r1, b1);
      final (r2, b2) = await callPeer('1003');
      await connect(r2, b2);
      await a.conference([r1.cid, r2.cid]);
      final i1 = await a.callInfo(r1.cid);
      expect(i1.conferenceWith, contains(r2.cid));
      await a.playFile(r1.cid, wav, loop: true);
      await Future<void>.delayed(const Duration(seconds: 3));
      expect((await b.callStats(b2)).rx.packets, greaterThan(20));
      await a.unconference([r1.cid, r2.cid]);
      expect((await a.callInfo(r1.cid)).conferenceWith, isEmpty);
    }, skip: skip);

    test('recording produces a WAV file', () async {
      final (ref, bcid) = await callPeer('1002');
      await connect(ref, bcid);
      await a.playFile(ref.cid, wav, loop: true);
      final file = '${tmp.path}/rec.wav';
      expect(await a.recordStart(ref.cid, file), file);
      expect((await a.callInfo(ref.cid)).recording, isTrue);
      await Future<void>.delayed(const Duration(seconds: 2));
      final r = await a.recordStop(ref.cid);
      expect(r.durationMs, greaterThan(1000));
      expect(File(file).lengthSync(), greaterThan(1000));
    }, skip: skip);

    test('incoming REFER from PBX (1999 -> 600) is followed', () async {
      final tr = la.next<CallTransferRequestEvent>(what: 'transferRequest');
      final ref = await a.makeCall(acc: a1001, uri: '1999');
      await la.callState(ref.cid, CallState.confirmed);
      final ev = await tr;
      expect(ev.target, contains('600'));
      expect(ev.accepted, isTrue);
      final spawned = await la.wait<CallStateEvent>(
        where: (e) => e.call.transferFrom == ref.cid,
        what: 'spawned call with transferFrom',
      );
      expect(spawned.cid, isNot(ref.cid));
    }, skip: skip);

    test('unknown cid fails with NOT_FOUND', () async {
      await expectLater(
        a.hangup(999999),
        throwsA(
          isA<EngineException>().having(
            (e) => e.code,
            'code',
            ErrorCode.notFound,
          ),
        ),
      );
    }, skip: skip);
  });

  group('presence / IM', () {
    test('BLF of 1002 reflects a call', () async {
      final bd = await a.addBuddy(
        acc: a1001,
        uri: '1002',
        presence: true,
        blf: true,
      );
      final early = la.wait<BuddyStateEvent>(
        where: (e) =>
            e.buddy.buddy == bd &&
            e.buddy.blf.state != BlfState.unknown &&
            e.buddy.blf.state != BlfState.idle &&
            e.buddy.blf.state != BlfState.terminated,
        what: 'BLF busy',
      );
      await Future<void>.delayed(const Duration(seconds: 1));
      final ref = await b.makeCall(acc: b1002, uri: '600');
      await lb.callState(ref.cid, CallState.confirmed);
      final ev = await early;
      expect(ev.buddy.blf.dialogs, isNotEmpty);
      await a.removeBuddy(bd);
    }, skip: skip);

    test('IM A -> B delivered', () async {
      final got = lb.next<ImIncomingEvent>(
        where: (e) => e.message.body == 'hello from A',
      );
      final st = la.next<ImStatusEvent>(where: (e) => e.status.msgId == 'm-1');
      await a.sendIm(
        acc: a1001,
        to: '1002',
        body: 'hello from A',
        msgId: 'm-1',
      );
      expect((await st).status.ok, isTrue);
      expect((await got).message.from, contains('1001'));
    }, skip: skip);

    test('own presence and typing do not fail', () async {
      await a.setPresence(a1001, PresenceStatus.away, note: 'lunch');
      await a.sendTyping(acc: a1001, to: '1002', typing: true);
    }, skip: skip);
  });

  group('diagnostics / media', () {
    test('devices, codecs, tones', () async {
      final d = await a.audioDevices();
      expect(d.current.capture, isNotEmpty);
      final cs = await a.codecs();
      expect(cs, isNotEmpty);
      await a.playTone(ToneKind.dial);
      await a.stopTone();
      await a.setMicLevel(1.0);
      expect((await a.levels()).mic, greaterThanOrEqualTo(0));
    }, skip: skip);

    test('OPTIONS ping and resolve', () async {
      final r = la.next<DiagOptionsEvent>();
      await a.optionsPing(a1001);
      expect(
        (await r).result.code,
        anyOf(200, 401),
      ); // PBX may challenge OPTIONS
      final res = await a.resolve(pbxHost);
      expect(res.addresses, isNotEmpty);
    }, skip: skip);

    test(
      'seq numbers are strictly increasing; no invariant violations so far',
      () {
        expect(ia.violations, isEmpty);
        expect(ib.violations, isEmpty);
        expect(ia.eventCount, greaterThan(10));
      },
      skip: skip,
    );
  });
}
