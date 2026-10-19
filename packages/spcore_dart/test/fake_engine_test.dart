import 'package:spcore_dart/spcore_dart.dart';
import 'package:spcore_dart/testing.dart';
import 'package:test/test.dart';

AccountConfig acct(String ext, {String? pw}) => AccountConfig(
  uid: 'uid$ext',
  username: ext,
  password: pw ?? 'pass$ext',
  domain: 'pbx.test',
);

void main() {
  late FakeSipEngine e;
  late InvariantChecker chk;
  late List<EngineEvent> evs;

  setUp(() async {
    e = FakeSipEngine(timings: FakeTimings.instant);
    chk = InvariantChecker()..attach(e.events);
    evs = [];
    e.events.listen(evs.add);
    await e.init();
    await e.start(const CoreConfig());
  });
  tearDown(() async {
    await e.dispose();
    chk.assertOk();
  });

  Future<int> reg(String ext) async {
    final id = await e.addAccount(acct(ext));
    await e.settle();
    return id;
  }

  test(
    'requests before start fail with NOT_STARTED; start twice ALREADY',
    () async {
      final f = FakeSipEngine();
      await expectLater(
        f.listAccounts(),
        throwsA(
          isA<EngineException>().having(
            (x) => x.code,
            'code',
            ErrorCode.notStarted,
          ),
        ),
      );
      await f.start(const CoreConfig());
      await expectLater(
        f.start(const CoreConfig()),
        throwsA(
          isA<EngineException>().having(
            (x) => x.code,
            'code',
            ErrorCode.already,
          ),
        ),
      );
      await f.dispose();
    },
  );

  test('account registers; wrong password fails', () async {
    final id = await e.addAccount(acct('1001'));
    expect(
      (await e.accountInfo(AccountRef.id(id))).regState,
      RegState.registering,
    );
    await e.settle();
    expect(
      (await e.accountInfo(const AccountRef.uid('uid1001'))).regState,
      RegState.registered,
    );
    await e.addAccount(acct('1002', pw: 'wrong'));
    await e.settle();
    final bad = await e.accountInfo(const AccountRef.uid('uid1002'));
    expect(bad.regState, RegState.failed);
    expect(bad.regCode, 403);
    expect(bad.lastError, contains('403'));
    await e.setRegistration(const AccountRef.uid('uid1001'), false);
    await e.settle();
    expect(
      (await e.accountInfo(const AccountRef.uid('uid1001'))).regState,
      RegState.unregistered,
    );
    final regs = evs
        .whereType<AccountRegEvent>()
        .where((x) => x.account.uid == 'uid1001')
        .map((x) => x.account.regState);
    expect(regs, [
      RegState.registering,
      RegState.registered,
      RegState.unregistering,
      RegState.unregistered,
    ]);
  });

  test('outgoing call calling->early->confirmed, stats, hangup', () async {
    final a = await reg('1001');
    final ref = await e.makeCall(acc: AccountRef.id(a), uri: '1002');
    await e.settle();
    final states = evs.whereType<CallStateEvent>().map((x) => x.state).toList();
    expect(states, [CallState.calling, CallState.early, CallState.confirmed]);
    expect(evs.whereType<CallMediaEvent>().last.media, MediaStatus.active);
    final st = await e.callStats(ref.cid);
    expect(st.mos, inInclusiveRange(1, 4.5));
    expect(st.rx.jitterMs, greaterThan(0));
    await chk.checkRequest(() => e.hangup(ref.cid), terminalCids: [ref.cid]);
    expect(
      evs.whereType<CallStateEvent>().where((x) => x.isTerminal),
      hasLength(1),
    );
    await expectLater(
      e.hangup(ref.cid),
      throwsA(
        isA<EngineException>().having(
          (x) => x.code,
          'code',
          ErrorCode.notFound,
        ),
      ),
    );
  });

  test('stats packets grow with injected clock', () async {
    var t = DateTime(2025);
    final f = FakeSipEngine(timings: FakeTimings.instant, clock: () => t);
    await f.start(const CoreConfig());
    final a = await f.addAccount(acct('1001'));
    await f.settle();
    final c = await f.makeCall(acc: AccountRef.id(a), uri: '1002');
    await f.settle();
    t = t.add(const Duration(seconds: 2));
    expect((await f.callStats(c.cid)).rx.packets, 100);
    await f.hold(c.cid);
    t = t.add(const Duration(seconds: 2));
    expect((await f.callStats(c.cid)).rx.packets, 100);
    await f.dispose();
  });

  test('callee behaviours', () async {
    final a = await reg('1001');
    e.calleeRules['busy'] = CalleeBehavior.busy;
    e.calleeRules['ring'] = CalleeBehavior.noAnswer;
    final b = await e.makeCall(acc: AccountRef.id(a), uri: 'busy');
    final r = await e.makeCall(acc: AccountRef.id(a), uri: 'ring');
    await e.settle();
    expect((await e.listCalls()).map((c) => c.cid), [r.cid]);
    expect((await e.callInfo(r.cid)).state, CallState.early);
    final term = evs.whereType<CallStateEvent>().firstWhere(
      (x) => x.cid == b.cid && x.isTerminal,
    );
    expect(term.call.lastCode, 486);
    e.simulateRemoteAnswer(r.cid);
    expect((await e.callInfo(r.cid)).state, CallState.confirmed);
  });

  test(
    'incoming call: incoming first, answer, hold, mute, dtmf, record, remote hangup',
    () async {
      await reg('1001');
      final ref = e.simulateIncomingCall(
        from: 'sip:1002@pbx.test',
        displayName: 'Bob',
        autoAnswerHint: const AutoAnswerHint(
          afterSec: 0,
          source: AutoAnswerSource.callInfo,
        ),
      );
      expect(evs.last, isA<CallIncomingEvent>());
      expect((evs.last as CallIncomingEvent).autoAnswerHint!.afterSec, 0);
      await e.ring(ref.cid);
      await e.answer(ref.cid);
      expect((await e.callInfo(ref.cid)).state, CallState.confirmed);
      await e.hold(ref.cid);
      final i = await e.callInfo(ref.cid);
      expect([i.media, i.held], [MediaStatus.localHold, true]);
      e.simulateRemoteHold(ref.cid, true);
      expect((await e.callInfo(ref.cid)).media, MediaStatus.bothHold);
      e.simulateRemoteHold(ref.cid, false);
      await e.unhold(ref.cid);
      expect((await e.callInfo(ref.cid)).media, MediaStatus.active);
      await e.mute(ref.cid, true);
      expect((await e.callInfo(ref.cid)).muted, isTrue);
      await e.sendDtmf(ref.cid, '12#');
      expect(e.sentDtmf[ref.cid], '12#');
      await expectLater(
        e.sendDtmf(ref.cid, 'xyz'),
        throwsA(isA<EngineException>()),
      );
      expect(await e.recordStart(ref.cid, '/tmp/a.wav'), '/tmp/a.wav');
      await expectLater(
        e.recordStart(ref.cid, '/tmp/a.wav'),
        throwsA(
          isA<EngineException>().having((x) => x.code, 'c', ErrorCode.already),
        ),
      );
      expect((await e.recordStop(ref.cid)).file, '/tmp/a.wav');
      await e.recordStart(ref.cid, '/tmp/b.wav');
      e.simulateRemoteHangup(ref.cid);
      // recording stopped event precedes the terminal state
      final names = evs.map((x) => x.name).toList();
      expect(
        names.lastIndexOf('call.recording') < names.lastIndexOf('call.state'),
        isTrue,
      );
      expect(
        evs.whereType<CallStateEvent>().where((x) => x.isTerminal),
        hasLength(1),
      );
    },
  );

  test('reject, cids monotonic and never reused across stop/start', () async {
    await reg('1001');
    final a = e.simulateIncomingCall();
    await e.reject(a.cid, code: 603);
    final b = e.simulateIncomingCall();
    expect(b.cid, greaterThan(a.cid));
    await e.stop();
    await e.start(const CoreConfig());
    await e.addAccount(acct('1001'));
    final c = e.simulateIncomingCall();
    expect(c.cid, greaterThan(b.cid));
    expect(
      evs.whereType<CallStateEvent>().where(
        (x) => x.cid == b.cid && x.isTerminal,
      ),
      hasLength(1),
    );
  });

  test('conference, bridge, transfer, attended transfer', () async {
    final a = await reg('1001');
    final c1 = await e.makeCall(acc: AccountRef.id(a), uri: '1002');
    final c2 = await e.makeCall(acc: AccountRef.id(a), uri: '1003');
    await e.settle();
    await e.hold(c1.cid);
    await e.conference([c1.cid, c2.cid]);
    final i1 = await e.callInfo(c1.cid);
    expect(i1.held, isFalse);
    expect(i1.conferenceWith, [c2.cid]);
    await e.unconference([c1.cid, c2.cid]);
    expect((await e.callInfo(c2.cid)).conferenceWith, isEmpty);
    await e.bridge(c1.cid, c2.cid, true);
    expect((await e.callInfo(c2.cid)).bridgedWith, [c1.cid]);
    await e.transfer(c1.cid, 'sip:1999@pbx.test');
    await e.transferAttended(c1.cid, c2.cid);
    await e.settle();
    final ts = evs.whereType<CallTransferStatusEvent>().toList();
    expect(ts.map((x) => x.code), [100, 100, 200, 200]);
    expect(ts.where((x) => x.isFinal), hasLength(2));
    await expectLater(
      e.transferAttended(c1.cid, c1.cid),
      throwsA(isA<EngineException>()),
    );
    await e.hangupAll();
    expect(await e.listCalls(), isEmpty);
    expect(chk.liveCids, isEmpty);
  });

  test('incoming REFER and Replaces simulations obey invariants', () async {
    await reg('1001');
    final i = e.simulateIncomingCall();
    await e.answer(i.cid);
    final n = e.simulateTransferRequest(i.cid, 'sip:1003@pbx.test');
    await e.settle();
    expect((await e.callInfo(n.cid)).state, CallState.confirmed);
    final r = e.simulateReplaced(n.cid);
    expect(evs.whereType<CallReplacedEvent>().single.newCid, r.cid);
    expect((await e.listCalls()).map((c) => c.cid), contains(r.cid));
  });

  test('mwi, im, buddy, presence, nat, options, devices, codecs', () async {
    final a = await reg('1001');
    e.simulateMwi(AccountRef.id(a), newMsgs: 3);
    expect((evs.last as AccountMwiEvent).mwi.newMsgs, 3);
    e.simulateIm(body: 'hi');
    expect((evs.last as ImIncomingEvent).message.body, 'hi');
    await e.sendIm(acc: AccountRef.id(a), to: '1002', body: 'yo', msgId: 'm1');
    await e.settle();
    expect((evs.last as ImStatusEvent).status.msgId, 'm1');
    e.unreachableUsers.add('9');
    await e.sendIm(acc: AccountRef.id(a), to: '9', body: 'yo', msgId: 'm2');
    await e.settle();
    expect((evs.last as ImStatusEvent).status.ok, isFalse);

    final b = await e.addBuddy(
      acc: AccountRef.id(a),
      uri: 'sip:1002@pbx.test',
      blf: true,
    );
    e.simulateBuddyState(
      buddy: b,
      presence: PresenceStatus.busy,
      blf: BlfState.early,
      dialogs: [const BlfDialog(id: 'd', state: BlfState.early)],
    );
    final bs = evs.last as BuddyStateEvent;
    expect(bs.buddy.blf.state, BlfState.early);
    expect((await e.listBuddies()).single.presence.status, PresenceStatus.busy);
    await e.removeBuddy(b);
    expect(await e.listBuddies(), isEmpty);

    await e.setPresence(AccountRef.id(a), PresenceStatus.dnd);
    expect(
      (await e.accountInfo(AccountRef.id(a))).presence,
      PresenceStatus.dnd,
    );
    await e.natType();
    await e.optionsPing(AccountRef.id(a));
    await e.settle();
    expect(
      evs.whereType<DiagNatTypeEvent>().single.info.type,
      NatType.fullCone,
    );
    expect(evs.whereType<DiagOptionsEvent>().single.result.code, 200);

    final d = await e.audioDevices();
    expect(d.capture, isNotEmpty);
    await e.setAudioDevices(capture: 'fake:USB Headset');
    expect((await e.audioDevices()).current.capture, 'fake:USB Headset');
    await expectLater(
      e.setAudioDevices(capture: 'nope'),
      throwsA(isA<EngineException>()),
    );
    await e.setCodecPriorities(['PCMU/8000/1'], disableOthers: true);
    final cs = await e.codecs();
    expect(cs.where((c) => c.enabled).map((c) => c.id), ['PCMU/8000/1']);
    await e.refreshDevices();
    expect(evs.last, isA<MediaDevicesChangedEvent>());
  });

  test('snapshot reflects state and generic request works', () async {
    await reg('1001');
    final c = e.simulateIncomingCall();
    final s = await e.snapshot();
    expect(s.calls.single.cid, c.cid);
    expect(s.accounts.where((a) => a.isDirect), hasLength(1));
    expect(s.seq, evs.last.seq);
    final r = await e.request('core.ping', {});
    expect(r, isEmpty);
    await expectLater(
      e.request('nope.nope', {}),
      throwsA(
        isA<EngineException>().having(
          (x) => x.code,
          'c',
          ErrorCode.unsupported,
        ),
      ),
    );
  });

  group('InvariantChecker', () {
    EngineEvent st(int seq, int cid, String state, {String role = 'caller'}) =>
        EngineEvent.fromJson({
          'type': 'event',
          'event': 'call.state',
          'seq': seq,
          'cid': cid,
          'state': state,
          'role': role,
        });
    test('detects violations', () {
      expect(
        InvariantChecker.validate([st(1, 1, 'incoming', role: 'callee')]),
        isNotEmpty,
      );
      expect(
        InvariantChecker.validate([
          st(1, 1, 'calling'),
          st(2, 1, 'disconnected'),
          st(3, 1, 'early'),
        ]),
        isNotEmpty,
      );
      expect(
        InvariantChecker.validate([st(1, 1, 'calling'), st(1, 1, 'early')]),
        isNotEmpty,
      );
      expect(
        InvariantChecker.validate([
          st(1, 1, 'calling'),
          st(2, 1, 'disconnected'),
        ]),
        isEmpty,
      );
      expect(
        InvariantChecker.validate([
          st(1, 1, 'calling'),
        ], requireAllTerminated: true),
        isNotEmpty,
      );
    });
  });
}
