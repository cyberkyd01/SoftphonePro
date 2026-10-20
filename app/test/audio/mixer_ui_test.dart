import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:softphonepro/audio/audio_levels.dart';
import 'package:softphonepro/core/theme.dart';
import 'package:softphonepro/l10n/app_localizations.dart';
import 'package:softphonepro/platform/platform_services.dart';
import 'package:softphonepro/services/providers.dart';
import 'package:softphonepro/services/settings_controller.dart';
import 'package:softphonepro/ui/pages/audio/audio_call_widgets.dart';
import 'package:softphonepro/ui/settings/audio_call_settings.dart';
import 'package:softphonepro/ui/widgets/audio_mixer.dart';
import 'package:softphonepro/ui/widgets/level_meter.dart';
import 'package:spcore_dart/spcore_dart.dart';

import 'audio_harness.dart';
import 'musicbed_test.dart' show MbEngine;

/// A phone: output routes instead of device lists; records route changes.
class MobilePlatform extends NoopPlatformServices {
  final routes = <AudioRoute>[];
  @override
  bool get ringsViaOs => true;
  @override
  Future<Set<AudioRoute>> availableAudioRoutes() async => {AudioRoute.earpiece, AudioRoute.speaker, AudioRoute.bluetooth};
  @override
  Future<void> setAudioRoute(AudioRoute route) {
    routes.add(route);
    return super.setAudioRoute(route);
  }
}

Future<AudioEnv> mk(WidgetTester tester, {Map<String, dynamic> settings = const {}, MbEngine? engine, PlatformServices? platform}) async =>
    (await tester.runAsync(() => AudioEnv.create(settings: settings, engine: engine ?? MbEngine(), platform: platform)))!;

/// Lets real async work (engine round trips, file IO) finish and delivers it.
Future<void> io(WidgetTester tester, [int rounds = 12]) async {
  for (var i = 0; i < rounds; i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 6)));
    await tester.pump(const Duration(milliseconds: 20));
  }
}

Future<void> pumpIn(
  WidgetTester tester,
  AudioEnv a,
  Widget body, {
  Size size = const Size(412, 915),
  Brightness brightness = Brightness.light,
  PlatformServices? platform,
  TextDirection? dir,
  double textScale = 1.0,
}) async {
  tester.view.physicalSize = size * 2;
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: a.container,
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: dir == TextDirection.rtl ? const Locale('ar') : const Locale('en'),
        debugShowCheckedModeBanner: false,
        theme: buildTheme(brightness),
        builder: (c, child) => MediaQuery(data: MediaQuery.of(c).copyWith(textScaler: TextScaler.linear(textScale)), child: child!),
        home: Scaffold(body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: body)),
      ),
    ),
  );
  await io(tester);
}

Future<void> end(WidgetTester tester, AudioEnv a) async {
  await tester.pumpWidget(const SizedBox());
  a.dispose();
}

void main() {
  group('AudioMixer (full)', () {
    testWidgets('mic and speaker sliders call setMicLevel / setSpeakerLevel', (tester) async {
      final a = await mk(tester);
      await pumpIn(tester, a, const AudioMixer());
      expect(find.text('100%'), findsNWidgets(2));
      await tester.drag(find.byKey(const Key('mixer-mic-slider')), const Offset(120, 0));
      await io(tester);
      expect(a.engine.micLevel, greaterThan(1.0));
      expect(a.container.read(settingsProvider).micLevel, a.engine.micLevel);
      await tester.drag(find.byKey(const Key('mixer-speaker-slider')), const Offset(-150, 0));
      await io(tester);
      expect(a.engine.speakerLevel, lessThan(1.0));
      expect(a.container.read(settingsProvider).speakerLevel, a.engine.speakerLevel);
      // The percentage text follows.
      expect(find.text('${(a.engine.speakerLevel * 100).round()}%'), findsOneWidget);
      await end(tester, a);
    });

    testWidgets('sliders carry semantics labels and percent values', (tester) async {
      final a = await mk(tester);
      final h = tester.ensureSemantics();
      await pumpIn(tester, a, const AudioMixer());
      for (final (key, label) in [
        ('mixer-mic-slider', 'Microphone volume'),
        ('mixer-speaker-slider', 'Speaker volume'),
        ('mixer-musicbed-slider', 'Musicbed volume'),
      ]) {
        final n = tester.getSemantics(find.descendant(of: find.byKey(Key(key)), matching: find.byType(Slider)));
        final d = n.getSemanticsData();
        expect(d.label, contains(label), reason: key);
        expect(d.value, endsWith('%'), reason: key);
      }
      expect(find.bySemanticsLabel('Microphone level'), findsOneWidget);
      expect(find.bySemanticsLabel('Headphones & speaker level'), findsOneWidget);
      expect(find.bySemanticsLabel('Musicbed level'), findsOneWidget);
      h.dispose();
      await end(tester, a);
    });

    testWidgets('desktop device pickers change the engine devices', (tester) async {
      final a = await mk(tester);
      await pumpIn(tester, a, const AudioMixer());
      expect(find.byKey(const Key('mixer-input-device')), findsOneWidget);
      expect(find.byKey(const Key('mixer-output-device')), findsOneWidget);
      final devs = (await tester.runAsync(a.engine.audioDevices))!;
      final cap = devs.capture.firstWhere((d) => d.devId != 'default');
      final play = devs.playback.firstWhere((d) => d.devId != 'default');
      await tester.tap(find.byKey(const Key('mixer-input-device')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(Key('captureDev-${cap.devId}')));
      await tester.pumpAndSettle();
      await io(tester);
      expect((await tester.runAsync(a.engine.audioDevices))!.current.capture, cap.devId);
      expect(a.container.read(settingsProvider).captureDev, cap.devId);
      expect(find.text(cap.name), findsOneWidget, reason: 'the picker shows the chosen device');

      await tester.tap(find.byKey(const Key('mixer-output-device')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(Key('playbackDev-${play.devId}')));
      await tester.pumpAndSettle();
      await io(tester);
      expect((await tester.runAsync(a.engine.audioDevices))!.current.playback, play.devId);
      await end(tester, a);
    });

    testWidgets('mobile: output route chips call setAudioRoute; the microphone follows', (tester) async {
      final p = MobilePlatform();
      final a = await mk(tester, platform: p);
      await pumpIn(tester, a, const AudioMixer());
      expect(find.byKey(const Key('mixer-input-device')), findsNothing);
      expect(find.byKey(const Key('mixer-output-device')), findsNothing);
      expect(find.text('The microphone follows the selected audio output.'), findsOneWidget);
      expect(find.byKey(const Key('mixer-route-earpiece')), findsOneWidget);
      expect(find.byKey(const Key('mixer-route-bluetooth')), findsOneWidget);
      expect(find.byKey(const Key('mixer-route-wired')), findsNothing, reason: 'not offered by this phone');
      await tester.tap(find.byKey(const Key('mixer-route-speaker')));
      await io(tester);
      expect(p.routes, [AudioRoute.speaker]);
      expect(tester.widget<ChoiceChip>(find.byKey(const Key('mixer-route-speaker'))).selected, isTrue);
      await tester.tap(find.byKey(const Key('mixer-route-bluetooth')));
      await io(tester);
      expect(p.routes, [AudioRoute.speaker, AudioRoute.bluetooth]);
      await end(tester, a);
    });

    testWidgets('musicbed switch starts and stops the engine; no file asks for one first', (tester) async {
      final a = await mk(tester);
      final e = a.engine as MbEngine;
      await pumpIn(tester, a, const AudioMixer());
      expect(find.text('Choose a file'), findsOneWidget);
      // No file yet: the sheet opens, picking a library track enables it.
      await tester.tap(find.byKey(const Key('mixer-musicbed-switch')));
      await tester.pumpAndSettle();
      expect(find.text('Musicbed file'), findsWidgets);
      await tester.tap(find.byKey(const Key('musicbed-file-builtin:hold_breeze')));
      await tester.pumpAndSettle();
      await io(tester);
      expect(a.container.read(settingsProvider).musicbedFile, 'builtin:hold_breeze');
      expect(a.container.read(settingsProvider).musicbedEnabled, isTrue);
      expect(e.musicbed.active, isTrue);
      expect(find.text('Breeze (built-in)'), findsOneWidget, reason: 'file chip names the track');
      // Off again.
      await tester.tap(find.byKey(const Key('mixer-musicbed-switch')));
      await io(tester);
      expect(e.musicbed.active, isFalse);
      expect(a.container.read(settingsProvider).musicbedEnabled, isFalse);
      // On again with the remembered file: no sheet.
      await tester.tap(find.byKey(const Key('mixer-musicbed-switch')));
      await io(tester);
      expect(e.musicbed.active, isTrue);
      expect(e.starts, hasLength(2));
      await end(tester, a);
    });

    testWidgets('musicbed volume and "hear it myself" reach the engine live', (tester) async {
      final a = await mk(tester, settings: {'musicbedEnabled': true, 'musicbedFile': 'builtin:hold_calm'});
      final e = a.engine as MbEngine;
      await pumpIn(tester, a, const AudioMixer());
      expect(e.musicbed.active, isTrue);
      expect(find.byKey(const Key('mixer-monitor-slider')), findsNothing, reason: 'monitor volume only while monitoring');
      await tester.drag(find.byKey(const Key('mixer-musicbed-slider')), const Offset(200, 0));
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 120)));
      await io(tester);
      expect(e.musicbed.volume, greaterThan(0.3));
      expect(e.musicbed.volume, a.container.read(settingsProvider).musicbedVolume);

      await tester.tap(find.byKey(const Key('mixer-monitor-switch')));
      await io(tester);
      expect(e.musicbed.monitor, isTrue);
      expect(find.byKey(const Key('mixer-monitor-slider')), findsOneWidget);
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 80)));
      await tester.drag(find.byKey(const Key('mixer-monitor-slider')), const Offset(-200, 0));
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 120)));
      await io(tester);
      expect(e.musicbed.monitorVolume, lessThan(0.5));
      await end(tester, a);
    });

    testWidgets('the file chip lists the library and imports a new file', (tester) async {
      final a = await mk(tester);
      await pumpIn(tester, a, const AudioMixer());
      await tester.tap(find.byKey(const Key('mixer-musicbed-file')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('musicbed-file-builtin:hold_calm')), findsOneWidget);
      final f = (await tester.runAsync(() => a.makeAudio('theme.mp3')))!;
      a.picked.add(f.path);
      await tester.tap(find.byKey(const Key('musicbed-add-file')));
      await io(tester);
      await tester.pumpAndSettle();
      await io(tester);
      expect(a.container.read(settingsProvider).musicbedFile, 'lib:theme.mp3');
      expect(find.text('theme'), findsOneWidget);
      // A bad import is reported and nothing is chosen.
      await tester.tap(find.byKey(const Key('mixer-musicbed-file')));
      await tester.pumpAndSettle();
      a.picked.add('/nope/song.ogg');
      await tester.tap(find.byKey(const Key('musicbed-add-file')));
      await io(tester);
      expect(a.container.read(noticeProvider)!.isError, isTrue);
      expect(a.container.read(settingsProvider).musicbedFile, 'lib:theme.mp3');
      await end(tester, a);
    });

    testWidgets('the meters repaint without rebuilding the mixer', (tester) async {
      final e = MbEngine();
      final a = await mk(tester, engine: e);
      await pumpIn(tester, a, const AudioMixer());
      var rebuilds = 0;
      final old = debugOnRebuildDirtyWidget;
      debugOnRebuildDirtyWidget = (el, built) {
        if (el.widget is AudioMixer || el.widget is LevelMeter) rebuilds++;
      };
      e.levelsOverride = const MediaLevels(mic: 220, speaker: 90, musicbed: 40);
      a.container.read(meterBoostProvider.notifier).hold();
      for (var i = 0; i < 20; i++) {
        await tester.pump(const Duration(milliseconds: 66));
      }
      debugOnRebuildDirtyWidget = old;
      expect(rebuilds, 0, reason: 'only the painters repaint');
      final meters = a.container.read(audioLevelsProvider);
      expect(meters.mic.level, greaterThan(0.8));
      expect(meters.speaker.level, closeTo(90 / 255, 0.03));
      await end(tester, a);
    });
  });

  group('AudioMixer (compact)', () {
    testWidgets('three slim rows; expand reveals devices and the musicbed file', (tester) async {
      final a = await mk(tester);
      await pumpIn(tester, a, const AudioMixer(compact: true));
      expect(find.byKey(const Key('mixer-mic-slider')), findsOneWidget);
      expect(find.byKey(const Key('mixer-speaker-slider')), findsOneWidget);
      expect(find.byKey(const Key('mixer-musicbed-slider')), findsOneWidget);
      expect(find.byKey(const Key('mixer-input-device')), findsNothing);
      expect(find.byKey(const Key('mixer-musicbed-file')), findsNothing);
      await tester.tap(find.byKey(const Key('mixer-expand')));
      await io(tester, 3);
      expect(find.byKey(const Key('mixer-input-device')), findsOneWidget);
      expect(find.byKey(const Key('mixer-output-device')), findsOneWidget);
      expect(find.byKey(const Key('mixer-musicbed-file')), findsOneWidget);
      expect(find.byKey(const Key('mixer-monitor-switch')), findsOneWidget);
      await tester.tap(find.byKey(const Key('mixer-expand')));
      await io(tester, 3);
      expect(find.byKey(const Key('mixer-input-device')), findsNothing);
      await end(tester, a);
    });

    testWidgets('compact sliders and the musicbed icon work', (tester) async {
      final a = await mk(tester, settings: {'musicbedFile': 'builtin:hold_calm'});
      await pumpIn(tester, a, const AudioMixer(compact: true));
      await tester.drag(find.byKey(const Key('mixer-mic-slider')), const Offset(-60, 0));
      await io(tester);
      expect(a.engine.micLevel, lessThan(1.0));
      await tester.tap(find.byKey(const Key('mixer-musicbed-switch')));
      await io(tester);
      expect((a.engine as MbEngine).musicbed.active, isTrue);
      await tester.tap(find.byKey(const Key('mixer-musicbed-switch')));
      await io(tester);
      expect((a.engine as MbEngine).musicbed.active, isFalse);
      await end(tester, a);
    });

    testWidgets('the strip shows three meters and opens the compact mixer', (tester) async {
      final a = await mk(tester);
      await pumpIn(tester, a, const MixerStrip());
      expect(find.byType(LevelMeter), findsNWidgets(3));
      expect(find.byKey(const Key('mixer-mic-slider')), findsNothing);
      await tester.tap(find.byKey(const Key('mixer-strip')));
      await io(tester, 3);
      expect(find.byKey(const Key('mixer-mic-slider')), findsOneWidget);
      expect(find.byType(LevelMeter), findsNWidgets(3));
      await tester.tap(find.byKey(const Key('mixer-strip')));
      await io(tester, 3);
      expect(find.byKey(const Key('mixer-mic-slider')), findsNothing);
      await end(tester, a);
    });
  });

  group('Settings and chip', () {
    testWidgets('Musicbed settings group edits the settings', (tester) async {
      final a = await mk(tester, settings: {'musicbedFile': 'builtin:hold_calm'});
      await pumpIn(tester, a, const MusicbedGroup());
      await tester.tap(find.byKey(const Key('musicbed-enabled')));
      await io(tester);
      expect((a.engine as MbEngine).musicbed.active, isTrue);
      expect(find.byKey(const Key('musicbed-monitor-volume')), findsNothing);
      await tester.tap(find.byKey(const Key('musicbed-monitor')));
      await io(tester);
      expect(find.byKey(const Key('musicbed-monitor-volume')), findsOneWidget);
      expect(a.container.read(settingsProvider).musicbedMonitor, isTrue);
      await end(tester, a);
    });

    testWidgets('"Musicbed on" chip follows the engine state', (tester) async {
      final a = await mk(tester, settings: {'musicbedFile': 'builtin:hold_calm'});
      await pumpIn(tester, a, const MusicbedChip());
      expect(find.byKey(const Key('musicbed-chip')), findsNothing);
      await tester.runAsync(() => a.settings.update({'musicbedEnabled': true}));
      await io(tester);
      expect(find.byKey(const Key('musicbed-chip')), findsOneWidget);
      expect(find.text('Musicbed on'), findsOneWidget);
      await tester.runAsync(() => a.settings.update({'musicbedEnabled': false}));
      await io(tester);
      expect(find.byKey(const Key('musicbed-chip')), findsNothing);
      await end(tester, a);
    });
  });

  group('goldens', () {
    final lit = const MediaLevels(mic: 150, speaker: 215, musicbed: 250);
    for (final b in Brightness.values) {
      testWidgets('full mixer (${b.name})', (tester) async {
        final e = MbEngine()..levelsOverride = lit;
        final a = await mk(tester, engine: e, settings: {'musicbedEnabled': true, 'musicbedFile': 'builtin:hold_calm', 'musicbedMonitor': true, 'micLevel': 1.4});
        await pumpIn(tester, a, const AudioMixer(), size: const Size(380, 760), brightness: b);
        a.container.read(meterBoostProvider.notifier).hold();
        for (var i = 0; i < 12; i++) {
          await tester.pump(const Duration(milliseconds: 66));
        }
        await expectLater(find.byType(MaterialApp), matchesGoldenFile('goldens/mixer_full_${b.name}.png'));
        await end(tester, a);
      });
    }

    testWidgets('compact mixer expanded (dark)', (tester) async {
      final e = MbEngine()..levelsOverride = lit;
      final a = await mk(tester, engine: e, settings: {'musicbedEnabled': true, 'musicbedFile': 'builtin:hold_breeze'});
      await pumpIn(tester, a, const MixerStrip(), size: const Size(360, 560), brightness: Brightness.dark);
      await tester.tap(find.byKey(const Key('mixer-strip')));
      await io(tester, 3);
      await tester.tap(find.byKey(const Key('mixer-expand')));
      await io(tester, 3);
      a.container.read(meterBoostProvider.notifier).hold();
      for (var i = 0; i < 12; i++) {
        await tester.pump(const Duration(milliseconds: 66));
      }
      await expectLater(find.byType(MaterialApp), matchesGoldenFile('goldens/mixer_compact_dark.png'));
      await end(tester, a);
    });

    testWidgets('mobile mixer with output routes (light)', (tester) async {
      final e = MbEngine()..levelsOverride = lit;
      final a = await mk(tester, engine: e, platform: MobilePlatform());
      await pumpIn(tester, a, const AudioMixer(), size: const Size(380, 800));
      a.container.read(meterBoostProvider.notifier).hold();
      for (var i = 0; i < 12; i++) {
        await tester.pump(const Duration(milliseconds: 66));
      }
      await expectLater(find.byType(MaterialApp), matchesGoldenFile('goldens/mixer_mobile_light.png'));
      await end(tester, a);
    });
  });
}
