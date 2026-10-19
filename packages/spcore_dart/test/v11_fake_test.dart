import 'package:spcore_dart/spcore_dart.dart';
import 'package:spcore_dart/testing.dart';
import 'package:test/test.dart';

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
    await e.addAccount(
      const AccountConfig(
        uid: 'u1',
        username: '1001',
        password: 'p',
        domain: 'pbx.test',
      ),
    );
    await e.settle();
  });
  tearDown(() async {
    await e.dispose();
    chk.assertOk();
  });

  Future<int> answered({
    AssertedIdentity? ident,
    List<DiversionEntry> div = const [],
    String? referredBy,
  }) async {
    final r = e.simulateIncomingCall(
      assertedIdentity: ident,
      diversion: div,
      referredBy: referredBy,
    );
    await e.answer(r.cid);
    return r.cid;
  }

  List<CallPlayDoneEvent> done() => evs.whereType<CallPlayDoneEvent>().toList();

  test('playFile returns playId and emits eof; loop does not end', () async {
    final cid = await answered();
    final id = await e.playFile(cid, '/x/a.wav', volume: 0.5, muteMic: true);
    expect(id, greaterThan(0));
    expect(e.activePlays[cid], [id]);
    await e.settle();
    expect(done().single.reason, PlayDoneReason.eof);
    expect(done().single.playId, id);
    expect(done().single.file, '/x/a.wav');
    final id2 = await e.playFile(cid, '/x/b.mp3', loop: true);
    await e.settle();
    expect(done().length, 1);
    expect(id2, isNot(id));
  });

  test('stopFile by playId and all; unsupported file errors', () async {
    final cid = await answered();
    final a = await e.playFile(cid, 'a.wav', loop: true);
    final b = await e.playFile(cid, 'b.wav', loop: true);
    await e.stopFile(cid, playId: a);
    expect(done().single.playId, a);
    expect(done().single.reason, PlayDoneReason.stopped);
    await e.stopFile(cid);
    expect(done().map((d) => d.playId), [a, b]);
    await expectLater(
      e.stopFile(cid, playId: 999),
      throwsA(isA<EngineException>()),
    );
    await expectLater(
      e.playFile(cid, 'a.flac'),
      throwsA(
        isA<EngineException>().having(
          (x) => x.code,
          'c',
          ErrorCode.invalidParam,
        ),
      ),
    );
  });

  test(
    'hangup ends playback with reason hangup before terminal state',
    () async {
      final cid = await answered();
      await e.playFile(cid, 'a.wav', loop: true);
      await e.hangup(cid);
      expect(done().single.reason, PlayDoneReason.hangup);
      final names = evs.map((x) => x.name).toList();
      expect(
        names.indexOf('call.playDone'),
        lessThan(names.lastIndexOf('call.state')),
      );
    },
  );

  test('hold with music is recorded and cleared on unhold', () async {
    final cid = await answered();
    await e.hold(cid, music: const HoldMusic(file: 'm.mp3', volume: 0.4));
    expect(e.holdMusicPlaying[cid]!.file, 'm.mp3');
    expect((await e.callInfo(cid)).held, true);
    await e.unhold(cid);
    expect(e.holdMusicPlaying, isEmpty);
    await e.hold(cid);
    expect(e.holdMusicPlaying, isEmpty);
    await expectLater(
      e.hold(cid, music: const HoldMusic(file: 'm.txt')),
      throwsA(isA<EngineException>()),
    );
  });

  test('voice isolation state and vad', () async {
    var s = await e.voiceIsolationStatus();
    expect(s.mic.enabled, false);
    expect(s.mic.vad, 0);
    final r = await e.setVoiceIsolation(
      mic: const VoiceIsolationSide(enabled: true, strength: 0.6),
    );
    expect([r.available, r.engine], [true, 'rnnoise']);
    e.fakeVad = 0.8;
    s = await e.voiceIsolationStatus();
    expect([s.mic.enabled, s.mic.strength, s.mic.vad], [true, 0.6, 0.8]);
    expect(s.incoming.enabled, false);
    await e.setVoiceIsolation(
      incoming: const VoiceIsolationSide(enabled: true, strength: 0.2),
    );
    s = await e.voiceIsolationStatus();
    expect(s.mic.enabled, true); // omitted part unchanged
    expect(s.incoming.strength, 0.2);
  });

  test('core.start seeds voice isolation', () async {
    final f = FakeSipEngine(timings: FakeTimings.instant);
    await f.start(
      const CoreConfig(
        media: MediaConfig(
          voiceIsolation: VoiceIsolationConfig(
            mic: VoiceIsolationSide(enabled: true, strength: 0.4),
          ),
        ),
      ),
    );
    final s = await f.voiceIsolationStatus();
    expect([s.mic.enabled, s.mic.strength], [true, 0.4]);
    await f.dispose();
  });

  test('fileInfo', () async {
    expect((await e.fileInfo('a.WAV')).format, 'wav');
    final m = await e.fileInfo('b.mp3');
    expect([m.format, m.channels, m.sampleRate], ['mp3', 2, 44100]);
    await expectLater(
      e.fileInfo('c.ogg'),
      throwsA(
        isA<EngineException>().having(
          (x) => x.code,
          'c',
          ErrorCode.invalidParam,
        ),
      ),
    );
  });

  test('recordMic start/stop', () async {
    await expectLater(e.recordMicStop(), throwsA(isA<EngineException>()));
    expect(await e.recordMicStart('/t/m.wav'), '/t/m.wav');
    await expectLater(
      e.recordMicStart('/t/n.wav'),
      throwsA(
        isA<EngineException>().having((x) => x.code, 'c', ErrorCode.already),
      ),
    );
    final r = await e.recordMicStop();
    expect(r.file, '/t/m.wav');
    expect(r.format, RecordFormat.wav);
    expect(r.bytes, greaterThan(0));
  });

  test('recordStart format echoed in recordStop', () async {
    final cid = await answered();
    await e.recordStart(cid, '/t/a.ogg', format: RecordFormat.opus);
    expect((await e.recordStop(cid)).format, RecordFormat.opus);
    await e.recordStart(cid, '/t/b.wav', format: RecordFormat.wavStereo);
    expect((await e.recordStop(cid)).format, RecordFormat.wavStereo);
    await e.recordStart(cid, '/t/c.wav');
    expect((await e.recordStop(cid)).format, RecordFormat.wav);
  });

  test('incoming call identity, diversion, referredBy', () async {
    final r = e.simulateIncomingCall(
      assertedIdentity: const AssertedIdentity(
        display: 'Bob',
        user: '1002',
        uri: 'sip:1002@pbx.test',
      ),
      diversion: const [
        DiversionEntry(uri: 'sip:a@x', user: 'a', reason: 'busy', counter: 1),
      ],
      referredBy: 'sip:c@x',
    );
    final ev = evs.whereType<CallIncomingEvent>().last;
    expect(ev.call.assertedIdentity!.user, '1002');
    final i = await e.callInfo(r.cid);
    expect(i.diversion.single.reason, 'busy');
    expect(i.referredBy, 'sip:c@x');
    final plain = e.simulateIncomingCall();
    expect((await e.callInfo(plain.cid)).assertedIdentity, isNull);
  });

  test('auto transport resolves and tlsClientCert validated', () async {
    e.autoTransportResult = AccTransport.tls;
    final id = await e.addAccount(
      const AccountConfig(
        uid: 'u2',
        username: '2',
        password: 'p',
        domain: 'sip.example.com',
        transport: AccTransport.auto,
        tlsClientCert: TlsClientCert(certFile: 'c', keyFile: 'k'),
      ),
    );
    await e.settle();
    final i = await e.accountInfo(AccountRef.id(id));
    expect(i.transport, 'tls');
    expect(i.resolvedServer, 'sip.example.com:5061');
    final plain = (await e.listAccounts()).firstWhere((a) => a.uid == 'u1');
    expect(plain.resolvedServer, isNull);
    await expectLater(
      e.addAccount(
        const AccountConfig(
          uid: 'u3',
          username: '3',
          domain: 'd',
          tlsClientCert: TlsClientCert(certFile: 'c'),
        ),
      ),
      throwsA(isA<EngineException>()),
    );
  });
}
