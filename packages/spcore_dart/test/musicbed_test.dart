import 'package:spcore_dart/spcore_dart.dart';
import 'package:test/test.dart';

Matcher _code(ErrorCode c) => throwsA(
  isA<EngineException>().having((x) => x.error.code, 'code', c),
);

void main() {
  group('models', () {
    test('MediaLevels tolerates old engines', () {
      final l = MediaLevels.fromJson({'mic': 10, 'speaker': 20});
      expect(l.musicbed, 0);
      expect(l.calls, isEmpty);
      expect(MediaLevels.fromJson({}), const MediaLevels());
    });

    test('MediaLevels parses musicbed and per-call levels', () {
      final l = MediaLevels.fromJson({
        'mic': 1,
        'speaker': 2,
        'musicbed': 3,
        'calls': [
          {'cid': 7, 'rx': 4, 'tx': 5},
          'junk',
        ],
      });
      expect(l.musicbed, 3);
      expect(l.calls, [const CallLevel(cid: 7, rx: 4, tx: 5)]);
      expect(MediaLevels.fromJson(l.toJson()), l);
    });

    test('MusicbedState defaults and round trip', () {
      final s = MusicbedState.fromJson({});
      expect(s.active, isFalse);
      expect(s.file, isNull);
      expect(s.volume, 0.3);
      expect(s.monitorVolume, 0.5);
      final full = MusicbedState.fromJson({
        'active': true,
        'file': '/a.mp3',
        'format': 'mp3',
        'volume': 1,
        'monitor': true,
        'monitorVolume': 0.25,
        'paused': true,
        'positionMs': 5,
        'durationMs': 9,
        'calls': [1, 2],
      });
      expect(full.volume, 1.0);
      expect(full.calls, [1, 2]);
      expect(MusicbedState.fromJson(full.toJson()), full);
    });

    test('MusicbedInfo parses', () {
      final i = MusicbedInfo.fromJson({
        'file': 'x.wav',
        'format': 'wav',
        'durationMs': 1200,
      });
      expect(i.durationMs, 1200);
      expect(MusicbedInfo.fromJson(i.toJson()), i);
    });
  });

  test('event parser yields MusicbedEvent', () {
    final e = EngineEvent.fromJson({
      'type': 'event',
      'event': 'media.musicbed',
      'seq': 1,
      'active': false,
      'file': 'a.mp3',
      'reason': 'error',
      'message': 'boom',
    });
    expect(e, isA<MusicbedEvent>());
    e as MusicbedEvent;
    expect(e.active, isFalse);
    expect(e.isError, isTrue);
    expect(e.message, 'boom');
    final bare = EngineEvent.fromJson({
      'type': 'event',
      'event': 'media.musicbed',
    });
    expect((bare as MusicbedEvent).file, isNull);
  });

  group('FakeSipEngine musicbed', () {
    late FakeSipEngine e;
    late List<MusicbedEvent> evs;

    setUp(() async {
      e = FakeSipEngine(timings: FakeTimings.instant);
      evs = [];
      e.events.listen((x) {
        if (x is MusicbedEvent) evs.add(x);
      });
      await e.init();
      await e.start(const CoreConfig());
    });
    tearDown(() => e.dispose());

    test('start returns info, emits event and exposes state', () async {
      final i = await e.musicbedStart('/m/loop.mp3', volume: 0.6);
      expect(i.format, 'mp3');
      expect(i.durationMs, greaterThan(0));
      await e.settle();
      expect(evs.single.reason, 'started');
      expect(evs.single.active, isTrue);
      final s = await e.musicbedState();
      expect(s.active, isTrue);
      expect(s.file, '/m/loop.mp3');
      expect(s.volume, 0.6);
      expect(s.monitor, isFalse);
    });

    test('rejects bad files and volumes', () async {
      await expectLater(
        e.musicbedStart('/m/loop.ogg'),
        _code(ErrorCode.invalidParam),
      );
      await expectLater(
        e.musicbedStart('/m/a.wav', volume: 2.5),
        _code(ErrorCode.invalidParam),
      );
      expect((await e.musicbedState()).active, isFalse);
    });

    test('set updates live; NOT_FOUND when none runs', () async {
      await expectLater(
        e.musicbedSet(volume: 0.5),
        _code(ErrorCode.notFound),
      );
      await e.musicbedStart('/m/a.wav');
      await e.musicbedSet(volume: 1.5, monitor: true, monitorVolume: 0.1);
      var s = await e.musicbedState();
      expect(s.volume, 1.5);
      expect(s.monitor, isTrue);
      expect(s.monitorVolume, 0.1);
      await e.musicbedSet(paused: true);
      s = await e.musicbedState();
      expect(s.paused, isTrue);
      expect((await e.levels()).musicbed, 0);
    });

    test('replacing emits replaced; stop reports stopped', () async {
      await e.musicbedStart('/m/a.wav');
      await e.musicbedStart('/m/b.wav');
      expect(await e.musicbedStop(), isTrue);
      expect(await e.musicbedStop(), isFalse);
      await e.settle();
      expect(evs.map((x) => x.reason), ['started', 'replaced', 'started', 'stopped']);
      expect(evs[1].active, isFalse);
      expect(evs[1].file, '/m/a.wav');
      expect(evs.last.active, isFalse);
    });

    test('core.stop shuts the bed down', () async {
      await e.musicbedStart('/m/a.wav');
      await e.stop();
      await e.settle();
      expect(evs.last.reason, 'shutdown');
    });

    test('failMusicbed emits error and deactivates', () async {
      await e.musicbedStart('/m/a.wav');
      e.failMusicbed('bad frame');
      await e.settle();
      expect(evs.last.isError, isTrue);
      expect(evs.last.message, 'bad frame');
      expect((await e.musicbedState()).active, isFalse);
    });

    test('levels: zero without calls, bed level when playing', () async {
      expect(await e.levels(), const MediaLevels());
      await e.musicbedStart('/m/a.wav', volume: 0.5);
      final l = await e.levels();
      expect(l.musicbed, greaterThan(0));
      expect(l.mic, 0);
    });

    test('levelsOverride wins', () async {
      e.levelsOverride = const MediaLevels(mic: 200, musicbed: 9);
      final l = await e.levels();
      expect(l.mic, 200);
      expect(l.musicbed, 9);
    });
  });
}
