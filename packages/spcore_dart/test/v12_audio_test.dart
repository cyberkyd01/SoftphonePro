import 'dart:convert';

import 'package:spcore_dart/spcore_dart.dart';
import 'package:test/test.dart';

Map<String, dynamic> rt(Map<String, dynamic> j) =>
    jsonDecode(jsonEncode(j)) as Map<String, dynamic>;

void main() {
  group('models', () {
    test('MonitorState maps the wire "null" source to MonitorSource.nul', () {
      final m = MonitorState.fromJson({
        'active': false,
        'source': 'null',
        'capture': 'x',
        'playback': 'y',
      });
      expect(m.source, MonitorSource.nul);
      expect(rt(m.toJson())['source'], 'null');
      expect(MonitorState.fromJson(rt(m.toJson())), m);
      expect(MonitorState.fromJson({}).source, MonitorSource.none);
      expect(
        MonitorState.fromJson({'source': 'zzz'}).source,
        MonitorSource.none,
      );
    });

    test('AudioState round trips and tolerates missing fields', () {
      final j = {
        'source': 'device',
        'capture': {'devId': 'WMME:Mic', 'name': 'Mic', 'driver': 'WMME'},
        'playback': null,
        'clockRate': 16000,
        'sndClockRate': 48000,
        'ec': {'tailMs': 200, 'options': 3, 'bypassed': true},
        'loopback': true,
        'monitor': true,
        'lastError': {'op': 'openDevice', 'status': 5, 'message': 'boom'},
        'future': 1,
      };
      final a = AudioState.fromJson(j);
      expect(a.source, MonitorSource.device);
      expect(a.capture!.name, 'Mic');
      expect(a.playback, isNull);
      expect(a.ec.bypassed, isTrue);
      expect(a.lastError!.message, 'boom');
      expect(AudioState.fromJson(rt(a.toJson())), a);
      final e = AudioState.fromJson({});
      expect(e.capture, isNull);
      expect(e.lastError, isNull);
      expect(e.sndClockRate, 0);
    });

    test('MediaLevels.send defaults to 0 and round trips', () {
      expect(MediaLevels.fromJson({'mic': 3}).send, 0);
      final l = MediaLevels.fromJson({'mic': 3, 'send': 77});
      expect(l.send, 77);
      expect(MediaLevels.fromJson(rt(l.toJson())), l);
    });

    test('events parse', () {
      final m =
          EngineEvent.fromJson({
                'event': 'media.monitor',
                'active': true,
                'source': 'null',
              })
              as MediaMonitorEvent;
      expect(m.state.active, isTrue);
      expect(m.state.source, MonitorSource.nul);
      final l =
          EngineEvent.fromJson({
                'event': 'media.loopback',
                'enabled': false,
                'reason': 'timeout',
              })
              as MediaLoopbackEvent;
      expect(l.enabled, isFalse);
      expect(l.reason, 'timeout');
      final p =
          EngineEvent.fromJson({
                'event': 'media.playDone',
                'playId': 4,
                'file': 'a.wav',
                'reason': 'eof',
              })
              as MediaPlayDoneEvent;
      expect(p.playId, 4);
      expect(p.reason, PlayDoneReason.eof);
    });
  });

  group('FakeSipEngine', () {
    late FakeSipEngine e;
    late List<EngineEvent> evs;
    setUp(() async {
      e = FakeSipEngine(timings: FakeTimings.instant);
      evs = [];
      e.events.listen(evs.add);
      await e.init();
      await e.start(const CoreConfig());
    });
    tearDown(() => e.dispose());

    test('monitor is idempotent and reports the source', () async {
      var s = await e.setMonitor(true);
      expect(e.monitorEnabled, isTrue);
      expect(s.active, isTrue);
      expect(s.source, MonitorSource.device);
      s = await e.setMonitor(true);
      expect(s.active, isTrue);
      e.fakeMonitorSource = MonitorSource.nul;
      s = await e.setMonitor(true);
      expect(s.active, isFalse);
      expect(s.source, MonitorSource.nul);
      await e.setMonitor(false);
      expect(e.monitorEnabled, isFalse);
    });

    test('levels follow the monitor when animating', () async {
      e.animateLevels = true;
      expect((await e.levels()).mic, 0);
      await e.setMonitor(true);
      var max = 0;
      for (var i = 0; i < 12; i++) {
        final m = (await e.levels()).mic;
        if (m > max) max = m;
        await Future<void>.delayed(const Duration(milliseconds: 90));
      }
      expect(max, greaterThan(0));
    });

    test('loopback with timeout emits media.loopback on stop', () async {
      await e.loopback(true, timeoutMs: 60000);
      expect(e.loopbackEnabled, isTrue);
      expect(e.loopbackTimeoutMs, 60000);
      expect((await e.audioState()).ec.bypassed, isTrue);
      e.simulateLoopbackEnded('timeout');
      await e.settle();
      expect(e.loopbackEnabled, isFalse);
      final ev = evs.whereType<MediaLoopbackEvent>().last;
      expect(ev.enabled, isFalse);
      expect(ev.reason, 'timeout');
      expect((await e.audioState()).ec.bypassed, isFalse);
      await e.loopback(true);
      await e.loopback(false);
      await e.settle();
      expect(evs.whereType<MediaLoopbackEvent>().last.reason, 'stopped');
    });

    test('loopback is BUSY during a call', () async {
      await e.addAccount(
        const AccountConfig(
          uid: 'u1',
          username: '1001',
          password: 'p',
          domain: 'pbx.test',
        ),
      );
      await e.settle();
      e.simulateIncomingCall();
      await e.settle();
      await expectLater(
        e.loopback(true),
        throwsA(
          isA<EngineException>().having(
            (x) => x.error.code,
            'code',
            ErrorCode.busy,
          ),
        ),
      );
    });

    test('playLocal / playStop and playDone', () async {
      final a = await e.playLocal('/tmp/chime.wav', volume: 0.5);
      final b = await e.playLocal('/tmp/rec.wav');
      expect(e.localPlays.map((x) => x.$2), ['/tmp/chime.wav', '/tmp/rec.wav']);
      e.simulatePlayDone(a);
      await e.settle();
      final d = evs.whereType<MediaPlayDoneEvent>().single;
      expect(d.playId, a);
      expect(d.reason, PlayDoneReason.eof);
      expect(await e.playLocalStop(playId: b), 1);
      expect(e.localPlays, isEmpty);
      expect(await e.playLocalStop(), 0);
      await e.settle();
      expect(
        evs.whereType<MediaPlayDoneEvent>().last.reason,
        PlayDoneReason.stopped,
      );
    });

    test('audioState reflects monitor and the chime tone is accepted', () async {
      expect((await e.audioState()).sndClockRate, 0);
      await e.setMonitor(true);
      final a = await e.audioState();
      expect(a.monitor, isTrue);
      expect(a.sndClockRate, 16000);
      expect(a.capture!.name, 'Fake microphone');
      await e.playTone(ToneKind.chime);
      expect(e.activeTone, 'chime');
    });

    test('simulateMonitor emits media.monitor', () async {
      await e.setMonitor(true);
      e.simulateMonitor(MonitorSource.nul);
      await e.settle();
      final m = evs.whereType<MediaMonitorEvent>().last;
      expect(m.state.source, MonitorSource.nul);
      expect(m.state.active, isFalse);
    });
  });
}
