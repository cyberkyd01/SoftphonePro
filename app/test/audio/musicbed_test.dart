import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:softphonepro/audio/audio_levels.dart';
import 'package:softphonepro/audio/audio_library.dart';
import 'package:softphonepro/audio/audio_platform.dart';
import 'package:softphonepro/audio/musicbed.dart';
import 'package:softphonepro/models/app_settings.dart';
import 'package:softphonepro/services/calls_controller.dart';
import 'package:softphonepro/services/engine_controller.dart';
import 'package:softphonepro/services/providers.dart';
import 'package:softphonepro/services/settings_controller.dart';
import 'package:spcore_dart/spcore_dart.dart';

import 'audio_harness.dart';

/// Records the musicbed requests.
class MbEngine extends LogEngine {
  MbEngine({this.failStart});

  /// Code of the failure `musicbedStart` throws.
  ErrorCode failStartCode = ErrorCode.invalidParam;

  /// The next N `musicbedStop` calls fail and leave the bed playing.
  int failStops = 0;
  final starts = <({String file, double volume, bool monitor, double monitorVolume})>[];
  final sets = <({double? volume, bool? monitor, double? monitorVolume})>[];
  int stops = 0;
  int levelCalls = 0;
  bool failLevels = false;

  /// Message of the EngineException `musicbedStart` throws (null: works).
  String? failStart;

  @override
  Future<MusicbedInfo> musicbedStart(String file, {double volume = 0.3, bool monitor = false, double monitorVolume = 0.5}) {
    starts.add((file: file, volume: volume, monitor: monitor, monitorVolume: monitorVolume));
    if (failStart != null) {
      return Future.error(EngineException(EngineError(code: failStartCode, message: failStart!)));
    }
    return super.musicbedStart(file, volume: volume, monitor: monitor, monitorVolume: monitorVolume);
  }

  @override
  Future<bool> musicbedStop() {
    stops++;
    if (failStops > 0) {
      failStops--;
      return Future.error(const EngineException(EngineError(code: ErrorCode.internal, message: 'stop failed')));
    }
    return super.musicbedStop();
  }

  @override
  Future<void> musicbedSet({double? volume, bool? monitor, double? monitorVolume, bool? paused}) {
    sets.add((volume: volume, monitor: monitor, monitorVolume: monitorVolume));
    return super.musicbedSet(volume: volume, monitor: monitor, monitorVolume: monitorVolume, paused: paused);
  }

  @override
  Future<MediaLevels> levels() {
    levelCalls++;
    if (failLevels) return Future.error(StateError('boom'));
    return super.levels();
  }
}

const _on = {'musicbedEnabled': true, 'musicbedFile': 'builtin:hold_calm'};

Future<void> _until(AudioEnv a, bool Function() cond) => a.until(cond, tries: 100);

String? _notice(AudioEnv a) => a.container.read(noticeProvider)?.message;

void main() {
  test('settings defaults', () {
    const a = AppSettings();
    expect(a.musicbedEnabled, isFalse);
    expect(a.musicbedFile, '');
    expect(a.musicbedVolume, 0.3);
    expect(a.musicbedMonitor, isFalse);
    expect(a.musicbedMonitorVolume, 0.5);
  });

  group('MusicbedController', () {
    test('enabled + file starts at app start with the library path and settings', () async {
      final e = MbEngine();
      final a = await AudioEnv.create(engine: e, settings: {..._on, 'musicbedVolume': 0.8, 'musicbedMonitor': true, 'musicbedMonitorVolume': 0.2});
      await _until(a, () => e.musicbed.active);
      expect(e.starts.single.file, endsWith('hold_calm.wav'));
      expect(e.starts.single.volume, 0.8);
      expect(e.starts.single.monitor, isTrue);
      expect(e.starts.single.monitorVolume, 0.2);
      await _until(a, () => a.container.read(musicbedProvider).active);
      final st = a.container.read(musicbedProvider);
      expect(st.file, endsWith('hold_calm.wav'));
      expect(st.volume, 0.8);
      a.dispose();
    });

    test('disabled does not start; enabling starts; disabling stops', () async {
      final e = MbEngine();
      final a = await AudioEnv.create(engine: e, settings: {'musicbedFile': 'builtin:hold_calm'});
      await a.flush();
      expect(e.starts, isEmpty);
      expect(e.musicbed.active, isFalse);
      await a.settings.update({'musicbedEnabled': true});
      await _until(a, () => a.container.read(musicbedProvider).active);
      expect(e.musicbed.active, isTrue);
      await a.settings.update({'musicbedEnabled': false});
      await _until(a, () => !e.musicbed.active);
      expect(e.musicbed.active, isFalse);
      await _until(a, () => !a.container.read(musicbedProvider).active);
      expect(a.container.read(musicbedProvider).active, isFalse);
      a.dispose();
    });

    test('changing the file while playing replaces the track', () async {
      final e = MbEngine();
      final a = await AudioEnv.create(engine: e, settings: _on);
      await _until(a, () => e.musicbed.active);
      await a.settings.update({'musicbedFile': 'builtin:hold_breeze'});
      await _until(a, () => e.starts.length == 2);
      expect(e.starts.last.file, endsWith('hold_breeze.wav'));
      await _until(a, () => a.container.read(musicbedProvider).file?.endsWith('hold_breeze.wav') ?? false);
      a.dispose();
    });

    test('starts again on the new engine after an engine restart', () async {
      final engines = <MbEngine>[MbEngine()];
      var calls = 0;
      final a = await AudioEnv.create(
        engine: engines.first,
        settings: _on,
        factory: ({required bool simulator}) async {
          if (calls++ > 0) engines.add(MbEngine());
          return EngineHandle(engines.last, demo: false);
        },
      );
      await _until(a, () => engines.first.musicbed.active);
      expect(engines.first.musicbed.active, isTrue);
      await a.container.read(engineProvider.notifier).restart();
      await _until(a, () => engines.length == 2 && engines.last.musicbed.active);
      expect(engines, hasLength(2));
      expect(engines.last.starts.single.file, endsWith('hold_calm.wav'));
      expect(a.container.read(engineProvider).generation, 2);
      await _until(a, () => a.container.read(musicbedProvider).active);
      a.dispose();
    });

    test('volume and monitor changes are applied live', () async {
      final e = MbEngine();
      final a = await AudioEnv.create(engine: e, settings: _on);
      await _until(a, () => a.container.read(musicbedProvider).active);
      await a.settings.update({'musicbedVolume': 0.9});
      await _until(a, () => e.sets.isNotEmpty);
      expect(e.musicbed.volume, 0.9);
      await Future<void>.delayed(const Duration(milliseconds: 80));
      await a.settings.update({'musicbedMonitor': true});
      await _until(a, () => e.musicbed.monitor);
      await Future<void>.delayed(const Duration(milliseconds: 80));
      await a.settings.update({'musicbedMonitorVolume': 0.1});
      await _until(a, () => e.musicbed.monitorVolume == 0.1);
      expect(e.starts, hasLength(1), reason: 'no restart for live changes');
      a.dispose();
    });

    test('a slider drag is throttled and the final value always lands', () async {
      final e = MbEngine();
      final a = await AudioEnv.create(engine: e, settings: _on);
      await _until(a, () => a.container.read(musicbedProvider).active);
      for (var i = 1; i <= 40; i++) {
        unawaited(a.settings.update({'musicbedVolume': i / 40}));
        await Future<void>.delayed(const Duration(milliseconds: 2));
      }
      await Future<void>.delayed(const Duration(milliseconds: 250));
      expect(e.sets.length, lessThan(12), reason: '~80 ms of drag must not send 40 requests: ${e.sets.length}');
      expect(e.sets.length, greaterThan(1));
      expect(e.sets.last.volume, 1.0);
      expect(e.musicbed.volume, 1.0);
      a.dispose();
    });

    test('only the changed field is sent; the final value lands', () async {
      final e = MbEngine();
      final a = await AudioEnv.create(engine: e, settings: {..._on, 'musicbedMonitor': true});
      await _until(a, () => a.container.read(musicbedProvider).active);
      for (var i = 1; i <= 30; i++) {
        unawaited(a.settings.update({'musicbedVolume': 0.3 + i / 40}));
        await Future<void>.delayed(const Duration(milliseconds: 3));
      }
      await Future<void>.delayed(const Duration(milliseconds: 250));
      expect(e.sets, isNotEmpty);
      for (final s in e.sets) {
        expect(s.volume, isNotNull);
        expect(s.monitor, isNull, reason: 'monitor did not change: not re-sent');
        expect(s.monitorVolume, isNull);
      }
      expect(e.sets.last.volume, closeTo(0.3 + 30 / 40, 1e-9));
      expect(e.musicbed.volume, closeTo(0.3 + 30 / 40, 1e-9));

      e.sets.clear();
      await a.settings.update({'musicbedMonitor': false});
      await _until(a, () => e.sets.isNotEmpty);
      expect(e.sets.single, (volume: null, monitor: false, monitorVolume: null));
      // Same value again: nothing to send.
      await a.settings.update({'musicbedVolume': e.musicbed.volume});
      await Future<void>.delayed(const Duration(milliseconds: 100));
      expect(e.sets, hasLength(1));
      a.dispose();
    });

    test('a failed live update is retried with the next change', () async {
      final e = MbEngine();
      final a = await AudioEnv.create(engine: e, settings: _on);
      await _until(a, () => a.container.read(musicbedProvider).active);
      await a.settings.update({'musicbedVolume': 0.7, 'musicbedMonitorVolume': 0.9});
      await _until(a, () => e.sets.isNotEmpty);
      expect(e.sets.first, (volume: 0.7, monitor: null, monitorVolume: 0.9));
      a.dispose();
    });

    for (final code in [ErrorCode.notStarted, ErrorCode.internal, ErrorCode.pjError]) {
      test('a ${code.wire} start failure keeps the setting on, warns, and retries on the next trigger only', () async {
        final e = MbEngine(failStart: 'engine hiccup')..failStartCode = code;
        final a = await AudioEnv.create(engine: e, settings: _on);
        await _until(a, () => e.starts.isNotEmpty);
        await Future<void>.delayed(const Duration(milliseconds: 300));
        expect(e.starts, hasLength(1), reason: 'no tight retry loop');
        expect(a.container.read(settingsProvider).musicbedEnabled, isTrue);
        expect(_notice(a), contains('engine hiccup'));
        expect(a.container.read(noticeProvider)!.isError, isTrue);
        expect(a.container.read(musicbedProvider).active, isFalse);

        // The next trigger (here: the file changes) tries again and works.
        e.failStart = null;
        await a.settings.update({'musicbedFile': 'builtin:hold_breeze'});
        await _until(a, () => e.musicbed.active);
        expect(e.starts, hasLength(2));
        expect(a.container.read(settingsProvider).musicbedEnabled, isTrue);
        await _until(a, () => a.container.read(musicbedProvider).active);
        a.dispose();
      });
    }

    test('after a transient start failure an engine restart tries again', () async {
      final engines = <MbEngine>[MbEngine(failStart: 'not ready')..failStartCode = ErrorCode.notStarted];
      var calls = 0;
      final a = await AudioEnv.create(
        engine: engines.first,
        settings: _on,
        factory: ({required bool simulator}) async {
          if (calls++ > 0) engines.add(MbEngine());
          return EngineHandle(engines.last, demo: false);
        },
      );
      await _until(a, () => engines.first.starts.isNotEmpty);
      expect(a.container.read(settingsProvider).musicbedEnabled, isTrue);
      await a.container.read(engineProvider.notifier).restart();
      await _until(a, () => engines.length == 2 && engines.last.musicbed.active);
      expect(engines.last.starts, hasLength(1));
      a.dispose();
    });

    test('a failed stop is retried once when the engine still plays', () async {
      final e = MbEngine();
      final a = await AudioEnv.create(engine: e, settings: _on);
      await _until(a, () => a.container.read(musicbedProvider).active);
      e.failStops = 1;
      await a.settings.update({'musicbedEnabled': false});
      await _until(a, () => !e.musicbed.active);
      expect(e.stops, 2);
      await _until(a, () => !a.container.read(musicbedProvider).active);
      expect(_notice(a), isNull, reason: 'the retry worked: nothing to warn about');
      a.dispose();
    });

    test('a stop that keeps failing says the music may still be playing; the state stays active', () async {
      final e = MbEngine();
      final a = await AudioEnv.create(engine: e, settings: _on);
      await _until(a, () => a.container.read(musicbedProvider).active);
      e.failStops = 5;
      await a.settings.update({'musicbedEnabled': false});
      await _until(a, () => _notice(a) != null);
      expect(e.stops, 2, reason: 'one retry, no loop');
      expect(_notice(a), contains('may still be playing'));
      expect(a.container.read(noticeProvider)!.isError, isTrue);
      expect(e.musicbed.active, isTrue);
      expect(a.container.read(musicbedProvider).active, isTrue, reason: 'the in-call chip reads this');
      a.dispose();
    });

    test('a failed stop with the engine already silent is quiet', () async {
      final e = MbEngine();
      final a = await AudioEnv.create(engine: e, settings: _on);
      await _until(a, () => a.container.read(musicbedProvider).active);
      e.failStops = 1;
      // The bed ends on its own just as the stop fails.
      e.failMusicbed('gone');
      await _until(a, () => !a.container.read(settingsProvider).musicbedEnabled);
      await Future<void>.delayed(const Duration(milliseconds: 100));
      expect(a.container.read(musicbedProvider).active, isFalse);
      a.dispose();
    });

    test('an engine error turns the setting off and shows a notice', () async {
      final e = MbEngine();
      final a = await AudioEnv.create(engine: e, settings: _on);
      await _until(a, () => a.container.read(musicbedProvider).active);
      e.failMusicbed('decoder died');
      await _until(a, () => !a.container.read(settingsProvider).musicbedEnabled);
      expect(a.container.read(settingsProvider).musicbedEnabled, isFalse);
      expect(a.container.read(musicbedProvider).active, isFalse);
      expect(_notice(a), contains('decoder died'));
      expect(a.container.read(noticeProvider)!.isError, isTrue);
      a.dispose();
    });

    test('a missing library file turns it off with a notice', () async {
      final e = MbEngine();
      final a = await AudioEnv.create(engine: e, settings: {'musicbedEnabled': true, 'musicbedFile': 'lib:gone.wav'});
      await _until(a, () => !a.container.read(settingsProvider).musicbedEnabled);
      expect(e.starts, isEmpty);
      expect(a.container.read(settingsProvider).musicbedEnabled, isFalse);
      expect(_notice(a), contains('no longer available'));
      a.dispose();
    });

    test('enabled without a file asks for one', () async {
      final e = MbEngine();
      final a = await AudioEnv.create(engine: e, settings: {'musicbedEnabled': true});
      await _until(a, () => !a.container.read(settingsProvider).musicbedEnabled);
      expect(e.starts, isEmpty);
      expect(_notice(a), contains('Choose a musicbed file'));
      a.dispose();
    });

    test('an engine that rejects the file turns it off with its message', () async {
      final e = MbEngine(failStart: 'unreadable media file');
      final a = await AudioEnv.create(engine: e, settings: _on);
      await _until(a, () => !a.container.read(settingsProvider).musicbedEnabled);
      expect(e.starts, hasLength(1));
      expect(_notice(a), contains('unreadable media file'));
      expect(a.container.read(musicbedProvider).active, isFalse);
      a.dispose();
    });

    test('a library file picked by the user is played by path', () async {
      final e = MbEngine();
      final a = await AudioEnv.create(engine: e);
      final item = await a.container.read(audioLibraryProvider).import((await a.makeAudio('loop.mp3')).path);
      await a.settings.update({'musicbedFile': item.ref, 'musicbedEnabled': true});
      await _until(a, () => e.musicbed.active);
      expect(e.starts.single.file, item.path);
      a.dispose();
    });
  });

  group('audio levels', () {
    test('meter math: fast attack, ~300 ms release, peak hold then fall', () {
      final m = MeterChannel();
      expect(m.step(0, 66), isFalse);
      m.step(255, 66);
      expect(m.level, greaterThan(0.9), reason: 'attack reaches the target within a poll');
      expect(m.peak, m.level);
      m.step(255, 66);
      m.step(255, 66);
      expect(m.level, 1.0);
      // Release: full scale to zero in ~300 ms.
      m.step(0, 150);
      expect(m.level, closeTo(0.5, 1e-9));
      m.step(0, 150);
      expect(m.level, 0.0);
      // Peak holds for 700 ms (300 ms are gone), then falls.
      expect(m.peak, 1.0);
      m.step(0, 300);
      expect(m.peak, 1.0);
      m.step(0, 200);
      expect(m.peak, closeTo(1 - 200 / MeterChannel.peakFallMs, 1e-9));
      for (var i = 0; i < 20; i++) {
        m.step(0, 100);
      }
      expect(m.peak, 0.0);
    });

    test('the level never drops below a quieter sample and clamps to 0-1', () {
      final m = MeterChannel();
      m.step(255, 66);
      m.step(200, 1000);
      expect(m.level, closeTo(200 / 255, 1e-9));
      m.step(999, 1000);
      expect(m.level, 1.0);
      m.reset();
      expect(m.level + m.peak, 0);
    });

    testWidgets('polls only while something listens: 1 Hz idle, ~15 Hz while a call is up', (tester) async {
      final e = MbEngine();
      final a = (await tester.runAsync(() => AudioEnv.create(engine: e)))!;
      e.levelsOverride = const MediaLevels(mic: 255, speaker: 128, musicbed: 64);
      await tester.pump(const Duration(seconds: 1));
      final before = e.levelCalls;
      await tester.pump(const Duration(seconds: 1));
      expect(e.levelCalls, before, reason: 'nobody listens: no polling');

      final sub = a.container.listen(audioLevelsProvider, (_, __) {});
      final meters = sub.read();
      final idle = e.levelCalls;
      await tester.pump(const Duration(seconds: 3));
      expect(e.levelCalls - idle, inInclusiveRange(2, 4), reason: 'idle: ~1 Hz');

      // A live call switches to ~15 Hz.
      await tester.runAsync(() => a.dialConfirmed());
      await tester.pump(const Duration(milliseconds: 50));
      final fast = e.levelCalls;
      await tester.pump(const Duration(seconds: 1));
      expect(e.levelCalls - fast, inInclusiveRange(13, 16));
      expect(meters.mic.level, greaterThan(0.95));
      expect(meters.speaker.level, closeTo(128 / 255, 0.02));
      expect(meters.musicbed.level, closeTo(64 / 255, 0.02));

      // Hang up: back to the slow rate.
      await tester.runAsync(() async {
        await a.calls.hangup(a.container.read(callsProvider).focused!.cid);
        await a.flush();
      });
      await tester.pump(const Duration(milliseconds: 100));
      final slow = e.levelCalls;
      await tester.pump(const Duration(seconds: 3));
      expect(e.levelCalls - slow, lessThanOrEqualTo(4));

      sub.close();
      await tester.pump(const Duration(milliseconds: 10));
      final stopped = e.levelCalls;
      await tester.pump(const Duration(seconds: 3));
      expect(e.levelCalls, stopped, reason: 'last listener gone: polling stops');
      await tester.runAsync(() async => a.dispose());
    });

    testWidgets('the monitor preview and a mic test also raise the rate', (tester) async {
      final e = MbEngine();
      final a = (await tester.runAsync(() => AudioEnv.create(engine: e, settings: {..._on, 'musicbedMonitor': true})))!;
      final sub = a.container.listen(audioLevelsProvider, (_, __) {});
      await tester.runAsync(() => _until(a, () => a.container.read(musicbedProvider).active));
      await tester.pump(const Duration(milliseconds: 100));
      var n = e.levelCalls;
      await tester.pump(const Duration(seconds: 1));
      expect(e.levelCalls - n, greaterThan(10), reason: 'musicbed monitor is playing to the user');
      await tester.runAsync(() => a.settings.update({'musicbedEnabled': false}));
      await tester.runAsync(() => _until(a, () => !e.musicbed.active));
      await tester.pump(const Duration(milliseconds: 200));
      n = e.levelCalls;
      await tester.pump(const Duration(seconds: 3));
      expect(e.levelCalls - n, lessThanOrEqualTo(4));
      final boost = a.container.read(meterBoostProvider.notifier)..hold();
      await tester.pump(const Duration(milliseconds: 100));
      n = e.levelCalls;
      await tester.pump(const Duration(seconds: 1));
      expect(e.levelCalls - n, greaterThan(10), reason: 'mic test');
      boost.release();
      sub.close();
      await tester.pump(const Duration(milliseconds: 10));
      await tester.runAsync(() async => a.dispose());
    });

    testWidgets('on iOS the monitor does not boost polling without a call; a call does', (tester) async {
      final e = MbEngine();
      final a = (await tester.runAsync(() => AudioEnv.create(engine: e, settings: {..._on, 'musicbedMonitor': true}, overrides: [isIosProvider.overrideWithValue(true)])))!;
      final sub = a.container.listen(audioLevelsProvider, (_, __) {});
      await tester.runAsync(() => _until(a, () => a.container.read(musicbedProvider).active));
      await tester.pump(const Duration(milliseconds: 100));
      var n = e.levelCalls;
      await tester.pump(const Duration(seconds: 3));
      expect(e.levelCalls - n, lessThanOrEqualTo(4), reason: 'nothing is audible: 1 Hz');

      await tester.runAsync(() => a.dialConfirmed());
      await tester.pump(const Duration(milliseconds: 100));
      n = e.levelCalls;
      await tester.pump(const Duration(seconds: 1));
      expect(e.levelCalls - n, greaterThan(10), reason: 'in a call the bed is audible');
      sub.close();
      await tester.pump(const Duration(milliseconds: 10));
      await tester.runAsync(() async => a.dispose());
    });

    testWidgets('idle costs nothing: no repaints, one poll per second at most', (tester) async {
      final e = MbEngine();
      final a = (await tester.runAsync(() => AudioEnv.create(engine: e)))!;
      final sub = a.container.listen(audioLevelsProvider, (_, __) {});
      final meters = sub.read();
      var repaints = 0;
      for (final c in [meters.mic, meters.speaker, meters.musicbed]) {
        c.addListener(() => repaints++);
      }
      final n = e.levelCalls;
      await tester.pump(const Duration(seconds: 10));
      expect(e.levelCalls - n, lessThanOrEqualTo(11));
      expect(repaints, 0, reason: 'zeros stay zeros: nothing to repaint');

      // A burst of sound decays to zero, then the meters go quiet again.
      e.levelsOverride = const MediaLevels(mic: 255);
      await tester.pump(const Duration(seconds: 1));
      expect(meters.mic.level, greaterThan(0.9));
      e.levelsOverride = null;
      await tester.pump(const Duration(seconds: 3));
      expect(meters.mic.level, 0);
      expect(meters.mic.peak, 0);
      final settled = repaints;
      expect(settled, greaterThan(0));
      await tester.pump(const Duration(seconds: 10));
      expect(repaints, settled, reason: 'decay finished: no more repaints');
      sub.close();
      await tester.pump(const Duration(milliseconds: 10));
      await tester.runAsync(() async => a.dispose());
    });

    testWidgets('pauses in the background and resumes', (tester) async {
      final e = MbEngine();
      final a = (await tester.runAsync(() => AudioEnv.create(engine: e)))!;
      final sub = a.container.listen(audioLevelsProvider, (_, __) {});
      a.container.read(meterBoostProvider.notifier).hold();
      e.levelsOverride = const MediaLevels(mic: 255);
      await tester.pump(const Duration(milliseconds: 500));
      final meters = sub.read();
      expect(meters.mic.level, greaterThan(0.9));

      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      await tester.pump(const Duration(milliseconds: 200));
      final inactive = e.levelCalls;
      await tester.pump(const Duration(milliseconds: 200));
      expect(e.levelCalls, greaterThan(inactive), reason: 'inactive is transient: keep metering');

      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await tester.pump(const Duration(milliseconds: 100));
      final paused = e.levelCalls;
      expect(meters.mic.level, 0, reason: 'meters read silence while hidden');
      await tester.pump(const Duration(seconds: 2));
      expect(e.levelCalls, paused);

      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump(const Duration(milliseconds: 500));
      expect(e.levelCalls, greaterThan(paused));
      expect(meters.mic.level, greaterThan(0.9));
      sub.close();
      await tester.pump(const Duration(milliseconds: 10));
      await tester.runAsync(() async => a.dispose());
    });

    testWidgets('a stopped engine or a failing request reads as zeros and never throws', (tester) async {
      final stopped = (await tester.runAsync(() => AudioEnv.create(start: false)))!;
      stopped.container.read(meterBoostProvider.notifier).hold();
      final s1 = stopped.container.listen(audioLevelsProvider, (_, __) {});
      await tester.pump(const Duration(milliseconds: 400));
      expect(s1.read().mic.level, 0);
      expect(s1.read().musicbed.peak, 0);
      s1.close();

      final e = MbEngine()..failLevels = true;
      final a = (await tester.runAsync(() => AudioEnv.create(engine: e)))!;
      a.container.read(meterBoostProvider.notifier).hold();
      final s2 = a.container.listen(audioLevelsProvider, (_, __) {});
      await tester.pump(const Duration(milliseconds: 400));
      expect(e.levelCalls, greaterThan(3));
      expect(s2.read().speaker.level, 0);
      expect(tester.takeException(), isNull);

      // Values decay to zero once the engine stops answering.
      e.failLevels = false;
      e.levelsOverride = const MediaLevels(mic: 255);
      await tester.pump(const Duration(milliseconds: 300));
      expect(s2.read().mic.level, greaterThan(0.9));
      e.failLevels = true;
      await tester.pump(const Duration(milliseconds: 500));
      expect(s2.read().mic.level, 0);
      s2.close();
      await tester.pump(const Duration(milliseconds: 10));
      await tester.runAsync(() async {
        a.dispose();
        stopped.dispose();
      });
    });
  });
}
