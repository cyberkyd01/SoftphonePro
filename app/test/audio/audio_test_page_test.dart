import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:softphonepro/audio/audio_levels.dart';
import 'package:softphonepro/audio/audio_library.dart';
import 'package:softphonepro/audio/audio_platform.dart';
import 'package:softphonepro/audio/musicbed.dart';
import 'package:softphonepro/services/engine_controller.dart';
import 'package:softphonepro/core/theme.dart';
import 'package:softphonepro/l10n/app_localizations.dart';
import 'package:softphonepro/models/app_settings.dart';
import 'package:softphonepro/services/accounts_controller.dart';
import 'package:softphonepro/services/app_services.dart';
import 'package:softphonepro/services/calls_controller.dart';
import 'package:softphonepro/services/providers.dart';
import 'package:softphonepro/ui/pages/audio_test/audio_test_page.dart';
import 'package:softphonepro/ui/widgets/audio_mixer.dart';
import 'package:spcore_dart/spcore_dart.dart';

import '../harness.dart';
import 'audio_harness.dart';
import 'mixer_ui_test.dart' show MobilePlatform, end, io, mk, pumpIn;
import 'musicbed_test.dart' show MbEngine;

DateTime _clock = DateTime(2026, 1, 1);

/// Whether the page is mounted (the tests close it without tearing the app down).
final _show = ValueNotifier<bool>(true);

FakeSipEngine _engine() => FakeSipEngine(timings: FakeTimings.instant, clock: () => _clock);

Future<void> pumpPage(
  WidgetTester tester,
  TestEnv env, {
  Size size = const Size(412, 1800),
  List<Override> extra = const [],
}) async {
  tester.view.physicalSize = size * 2;
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        ...env.overrides,
        audioAssetFileProvider.overrideWithValue((asset) async => '/tmp/chime.wav'),
        audioOsProvider.overrideWithValue('windows'),
        ...extra,
      ],
      child: Consumer(
        builder: (context, ref, _) {
          ref.watch(appServicesProvider);
          return MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            debugShowCheckedModeBanner: false,
            theme: buildTheme(Brightness.light),
            home: ValueListenableBuilder<bool>(valueListenable: _show, builder: (_, on, __) => on ? const AudioTestPage() : const SizedBox()),
          );
        },
      ),
    ),
  );
  await settle(tester, env.engine);
}

/// Advances the fake clock in 100 ms steps so the sampling timer runs.
Future<void> elapse(WidgetTester tester, int ms) async {
  for (var i = 0; i < ms ~/ 100; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

ProviderContainer cont(WidgetTester tester) => ProviderScope.containerOf(tester.element(find.byType(AudioTestPage)));

Future<void> tap(WidgetTester tester, String key) async {
  final f = find.byKey(Key(key));
  if (f.evaluate().isEmpty) await tester.scrollUntilVisible(f, 300, scrollable: find.byType(Scrollable).first);
  await tester.ensureVisible(f);
  await tester.pump();
  await tester.tap(f);
  await tester.pump(const Duration(milliseconds: 50));
}

Future<TestEnv> mkEnv({FakeSipEngine? engine, bool account = false}) async {
  final e = engine ?? _engine();
  e.autoFinishLocalPlays = false;
  return TestEnv.create(
    engine: e,
    settings: const AppSettings({'onboardingDone': true}),
    profiles: account ? [testProfile()] : const [],
  );
}

void main() {
  setUp(() {
    _clock = DateTime(2026, 1, 1);
    _show.value = true;
  });

  testWidgets('opening the page turns the monitor on, closing it turns it off', (tester) async {
    final env = await mkEnv();
    await pumpPage(tester, env);
    await elapse(tester, 300);
    expect(env.engine.monitorEnabled, isTrue);
    expect(find.byKey(const Key('audio-step-devices')), findsOneWidget);
    _show.value = false;
    await tester.pump();
    await settle(tester, env.engine);
    expect(env.engine.monitorEnabled, isFalse);
  });

  testWidgets('a live microphone shows mic-ok; step 1 reports the opened device', (tester) async {
    final env = await mkEnv();
    env.engine.levelsOverride = const MediaLevels(mic: 120);
    await pumpPage(tester, env);
    await elapse(tester, 1000);
    expect(find.byKey(const Key('mic-ok')), findsOneWidget);
    expect(find.byKey(const Key('devices-opened')), findsOneWidget);
    expect(find.textContaining('Fake microphone'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    await settle(tester, env.engine);
  });

  testWidgets('6 s of zero with a device shows the silent hint and OS settings links', (tester) async {
    final env = await mkEnv();
    env.engine.levelsOverride = const MediaLevels();
    await pumpPage(tester, env);
    await elapse(tester, 3000);
    expect(find.byKey(const Key('mic-silent')), findsNothing);
    await elapse(tester, 4000);
    expect(find.byKey(const Key('mic-silent')), findsOneWidget);
    expect(find.byKey(const Key('mic-open-settings')), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    await settle(tester, env.engine);
  });

  testWidgets('speaker: chime plays locally, playDone then Yes passes the step', (tester) async {
    final env = await mkEnv();
    await pumpPage(tester, env);
    await tap(tester, 'play-chime');
    await settle(tester, env.engine);
    expect(env.engine.localPlays.length, 1);
    expect(env.engine.localPlays.single.$2, '/tmp/chime.wav');
    env.engine.simulatePlayDone(env.engine.localPlays.single.$1);
    await settle(tester, env.engine);
    await tap(tester, 'spk-yes');
    expect(find.descendant(of: find.byKey(const Key('audio-step-status-speaker')), matching: find.text('OK')), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    await settle(tester, env.engine);
  });

  testWidgets('record: stops after 5 s, plays the recording back', (tester) async {
    final env = await mkEnv();
    await pumpPage(tester, env);
    await tap(tester, 'rec-start');
    await settle(tester, env.engine);
    expect(find.byKey(const Key('rec-countdown')), findsOneWidget);
    _clock = _clock.add(const Duration(seconds: 5));
    await elapse(tester, 5500);
    await settle(tester, env.engine);
    expect(env.engine.localPlayHistory.length, 1);
    expect(env.engine.localPlayHistory.single, contains('softphonepro_audiotest_'));
    env.engine.simulatePlayDone(env.engine.localPlays.single.$1);
    await settle(tester, env.engine);
    await tap(tester, 'rec-yes');
    expect(find.descendant(of: find.byKey(const Key('audio-step-status-record')), matching: find.text('OK')), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    await settle(tester, env.engine);
  });

  testWidgets('echo test: headphones dialog once, 60 s timeout, engine end flips the switch', (tester) async {
    final env = await mkEnv();
    await pumpPage(tester, env);
    await tap(tester, 'echo-switch');
    expect(find.byKey(const Key('echo-headphones-dialog')), findsOneWidget);
    await tap(tester, 'echo-headphones-ok');
    await settle(tester, env.engine);
    expect(env.engine.loopbackEnabled, isTrue);
    expect(env.engine.loopbackTimeoutMs, 60000);
    expect(tester.widget<SwitchListTile>(find.byKey(const Key('echo-switch'))).value, isTrue);
    env.engine.simulateLoopbackEnded('timeout');
    await settle(tester, env.engine);
    expect(tester.widget<SwitchListTile>(find.byKey(const Key('echo-switch'))).value, isFalse);
    expect(find.byKey(const Key('echo-ended')), findsOneWidget);
    // The dialog is not shown a second time.
    await tap(tester, 'echo-switch');
    await settle(tester, env.engine);
    expect(find.byKey(const Key('echo-headphones-dialog')), findsNothing);
    expect(env.engine.loopbackEnabled, isTrue);
    _show.value = false;
    await tester.pump();
    await settle(tester, env.engine);
    expect(env.engine.loopbackEnabled, isFalse);
  });

  testWidgets('during a call: banner, play-chime disabled', (tester) async {
    final env = await mkEnv(account: true);
    await pumpPage(tester, env);
    for (var i = 0; i < 10; i++) {
      await settle(tester, env.engine);
      if (cont(tester).read(accountsProvider).statusOf('acc1') == AccountStatus.registered) break;
    }
    await cont(tester).read(callsProvider.notifier).dial('2002');
    await settle(tester, env.engine);
    expect(find.byKey(const Key('audio-test-in-call')), findsOneWidget);
    final btn = tester.widget<FilledButton>(find.byKey(const Key('play-chime')));
    expect(btn.onPressed, isNull);
    await tester.pumpWidget(const SizedBox());
    await settle(tester, env.engine);
  });

  testWidgets('copy-diagnostics puts the report on the clipboard', (tester) async {
    final env = await mkEnv();
    String? copied;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'Clipboard.setData') copied = (call.arguments as Map)['text'] as String?;
      return null;
    });
    addTearDown(() => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, null));
    await pumpPage(tester, env);
    await elapse(tester, 300);
    await tap(tester, 'copy-diagnostics');
    await settle(tester, env.engine);
    expect(copied, isNotNull);
    expect(copied, contains('SoftphonePro $kAppVersion'));
    expect(copied, contains('Audio state:'));
    expect(copied, contains('EC settings:'));
    await tester.pumpWidget(const SizedBox());
    await settle(tester, env.engine);
  });

  testWidgets('wide layout puts the summary beside the steps', (tester) async {
    final env = await mkEnv();
    await pumpPage(tester, env, size: const Size(1200, 900));
    expect(find.byKey(const Key('audio-test-summary-side')), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    await settle(tester, env.engine);
  });

  testWidgets('going to the background turns the monitor off and stops the echo test', (tester) async {
    final env = await mkEnv();
    await pumpPage(tester, env);
    await tap(tester, 'echo-switch');
    await tap(tester, 'echo-headphones-ok');
    await settle(tester, env.engine);
    expect(env.engine.monitorEnabled, isTrue);
    expect(env.engine.loopbackEnabled, isTrue);
    for (final s in [AppLifecycleState.inactive, AppLifecycleState.hidden, AppLifecycleState.paused]) {
      tester.binding.handleAppLifecycleStateChanged(s);
    }
    await settle(tester, env.engine);
    expect(env.engine.monitorEnabled, isFalse);
    expect(env.engine.loopbackEnabled, isFalse);
    await tester.pumpWidget(const SizedBox());
    await settle(tester, env.engine);
  });

  testWidgets('media.error shows a notice', (tester) async {
    final a = (await tester.runAsync(() => AudioEnv.create()))!;
    a.engine.simulateMediaError('openDevice', message: 'no such device');
    await tester.runAsync(() => a.flush());
    expect(a.container.read(noticeProvider)?.message, contains('no such device'));
    a.dispose();
  });

  testWidgets('music step passes through the send level when the bed is not monitored', (tester) async {
    final env = await mkEnv();
    await pumpPage(tester, env);
    final c = cont(tester);
    c.read(musicbedProvider);
    await settle(tester, env.engine);
    await env.engine.musicbedStart('/m/a.wav', volume: 0.5);
    await settle(tester, env.engine);
    await elapse(tester, 500);
    expect(env.engine.monitorEnabled, isTrue);
    expect((await env.engine.levels()).musicbed, 0, reason: 'the engine does not meter an unmonitored bed');
    expect(find.descendant(of: find.byKey(const Key('audio-step-status-music')), matching: find.text('OK')), findsOneWidget);
    _show.value = false;
    await tester.pump();
    await settle(tester, env.engine);
  });

  testWidgets('music step explains that the bed is not audible without the monitor', (tester) async {
    final env = await mkEnv();
    await pumpPage(tester, env);
    cont(tester).read(musicbedProvider);
    await settle(tester, env.engine);
    await env.engine.musicbedStart('/m/a.wav');
    await settle(tester, env.engine);
    await tester.scrollUntilVisible(find.byKey(const Key('music-silent-hint')), 300, scrollable: find.byType(Scrollable).first);
    expect(find.byKey(const Key('music-silent-hint')), findsOneWidget);
    _show.value = false;
    await tester.pump();
    await settle(tester, env.engine);
  });

  testWidgets('closing the page right after a tap does not throw', (tester) async {
    final env = await mkEnv();
    await pumpPage(tester, env);
    await tap(tester, 'play-chime');
    _show.value = false;
    await tester.pump();
    await settle(tester, env.engine);
    await tap(tester, 'rec-start').catchError((_) {});
    expect(tester.takeException(), isNull);
  });

  testWidgets('narrow screen with every step used does not overflow', (tester) async {
    final env = await mkEnv();
    await pumpPage(tester, env, size: const Size(360, 1800));
    await tap(tester, 'play-chime');
    await settle(tester, env.engine);
    env.engine.simulatePlayDone(env.engine.localPlays.single.$1);
    await settle(tester, env.engine);
    await tap(tester, 'rec-start');
    await settle(tester, env.engine);
    _clock = _clock.add(const Duration(seconds: 5));
    await elapse(tester, 5500);
    await settle(tester, env.engine);
    env.engine.simulatePlayDone(env.engine.localPlays.single.$1);
    await settle(tester, env.engine);
    await tap(tester, 'echo-switch');
    await tap(tester, 'echo-headphones-ok');
    await settle(tester, env.engine);
    env.engine.simulateLoopbackEnded('call');
    await settle(tester, env.engine);
    await tap(tester, 'preview-switch');
    await settle(tester, env.engine);
    await tester.scrollUntilVisible(find.byKey(const Key('copy-diagnostics')), 300, scrollable: find.byType(Scrollable).first);
    expect(tester.takeException(), isNull);
    _show.value = false;
    await tester.pump();
    await settle(tester, env.engine);
  });

  group('mixer monitor', () {

    testWidgets('an engine restart re-asks for the monitor', (tester) async {
      final engines = <LogEngine>[];
      final a = (await tester.runAsync(
        () => AudioEnv.create(
          start: false,
          factory: ({required bool simulator}) async {
            final e = LogEngine();
            engines.add(e);
            return EngineHandle(e, demo: false);
          },
        ),
      ))!;
      await tester.runAsync(() async {
        a.container.read(engineProvider.notifier).start();
        await a.until(() => a.container.read(engineProvider).running);
      });
      await pumpIn(tester, a, const AudioMixer());
      await io(tester);
      expect(engines.single.monitorEnabled, isTrue);
      await tester.runAsync(() async {
        await a.container.read(engineProvider.notifier).restart();
        await a.until(() => engines.length == 2 && a.container.read(engineProvider).running);
      });
      await io(tester);
      expect(engines.length, 2);
      expect(engines.last.monitorEnabled, isTrue);
      expect(engines.last.monitorCalls, greaterThan(0));
      await end(tester, a);
    });

    testWidgets('desktop: fast polling and the monitor stop in the background and come back', (tester) async {
      final e = MbEngine();
      final a = (await tester.runAsync(() => AudioEnv.create(engine: e)))!;
      final sub = a.container.listen(audioLevelsProvider, (_, __) {});
      await tester.pump(const Duration(milliseconds: 300));
      await tester.runAsync(() => a.flush());
      expect(e.monitorEnabled, isTrue);
      var n = e.levelCalls;
      await tester.pump(const Duration(seconds: 1));
      expect(e.levelCalls - n, greaterThan(10));
      for (final s in [AppLifecycleState.inactive, AppLifecycleState.hidden, AppLifecycleState.paused]) {
        tester.binding.handleAppLifecycleStateChanged(s);
      }
      await tester.runAsync(() => a.flush());
      await tester.pump(const Duration(milliseconds: 200));
      expect(e.monitorEnabled, isFalse);
      n = e.levelCalls;
      await tester.pump(const Duration(seconds: 2));
      expect(e.levelCalls, n);
      for (final s in [AppLifecycleState.hidden, AppLifecycleState.inactive, AppLifecycleState.resumed]) {
        tester.binding.handleAppLifecycleStateChanged(s);
      }
      await tester.runAsync(() => a.flush());
      await tester.pump(const Duration(milliseconds: 200));
      expect(e.monitorEnabled, isTrue);
      n = e.levelCalls;
      await tester.pump(const Duration(seconds: 1));
      expect(e.levelCalls - n, greaterThan(10));
      sub.close();
      await tester.pump(const Duration(milliseconds: 10));
      await tester.runAsync(() async => a.dispose());
    });
    testWidgets('desktop: the mixer turns the monitor on and off', (tester) async {
      final a = await mk(tester);
      await pumpIn(tester, a, const AudioMixer());
      expect(a.engine.monitorEnabled, isTrue);
      await end(tester, a);
      await tester.runAsync(() => a.flush());
      expect(a.engine.monitorEnabled, isFalse);
    });

    testWidgets('mobile: off until a page holds the meter boost; never on iOS', (tester) async {
      final a = await mk(tester, platform: MobilePlatform());
      await pumpIn(tester, a, const AudioMixer(), platform: MobilePlatform());
      await io(tester);
      expect(a.engine.monitorEnabled, isFalse);
      await pumpIn(tester, a, const _Holder(), platform: MobilePlatform());
      await io(tester);
      expect(a.engine.monitorEnabled, isTrue);
      await end(tester, a);

      final b = (await tester.runAsync(() => AudioEnv.create(platform: MobilePlatform(), overrides: [isIosProvider.overrideWithValue(true)])))!;
      await pumpIn(tester, b, const _Holder(), platform: MobilePlatform());
      await io(tester);
      expect(b.engine.monitorEnabled, isFalse);
      await end(tester, b);
    });
  });
}

class _Holder extends ConsumerStatefulWidget {
  const _Holder();
  @override
  ConsumerState<_Holder> createState() => _HolderState();
}

class _HolderState extends ConsumerState<_Holder> with MeterBoostHolder<_Holder> {
  @override
  Widget build(BuildContext context) => const AudioMixer();
}
