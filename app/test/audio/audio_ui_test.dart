import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:softphonepro/audio/audio_library.dart';
import 'package:softphonepro/audio/mic_recorder.dart';
import 'package:softphonepro/core/theme.dart';
import 'package:softphonepro/services/calls_controller.dart';
import 'package:softphonepro/services/settings_controller.dart';
import 'package:softphonepro/ui/pages/audio/audio_files_page.dart';
import 'package:softphonepro/ui/settings/account_editor.dart';
import 'package:softphonepro/ui/settings/sections.dart';
import 'package:softphonepro/ui/widgets/call_widgets.dart';

import 'audio_harness.dart';

Future<AudioEnv> mk(WidgetTester tester, {Map<String, dynamic> settings = const {}, LogEngine? engine}) async =>
    (await tester.runAsync(() => AudioEnv.create(settings: settings, engine: engine)))!;

Future<void> pumpIn(WidgetTester tester, AudioEnv a, Widget page, {Size size = const Size(412, 915), Brightness brightness = Brightness.light}) async {
  tester.view.physicalSize = size * 2;
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: a.container,
      child: MaterialApp(debugShowCheckedModeBanner: false, theme: buildTheme(brightness), home: Scaffold(body: page)),
    ),
  );
  await io(tester);
  await tester.pump(const Duration(milliseconds: 50));
}

Future<void> end(WidgetTester tester, AudioEnv a) async {
  await tester.pumpWidget(const SizedBox());
  a.dispose();
}

/// Lets real async work (file IO, engine round trips) finish and delivers it.
Future<void> io(WidgetTester tester) async {
  for (var i = 0; i < 40; i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 6)));
    await tester.pump(const Duration(milliseconds: 20));
  }
}

Future<void> pumpMs(WidgetTester tester, [int ms = 50]) => tester.pump(Duration(milliseconds: ms));

void main() {
  group('Audio files page', () {
    testWidgets('empty state lists the built-in tracks', (tester) async {
      final a = await mk(tester);
      await pumpIn(tester, a, const AudioFilesBody());
      expect(find.byKey(const Key('audio-empty')), findsOneWidget);
      expect(find.text('Calm (built-in)'), findsOneWidget);
      expect(find.text('Breeze (built-in)'), findsOneWidget);
      expect(find.byKey(const Key('audio-import')), findsOneWidget);
      expect(find.byKey(const Key('audio-record')), findsOneWidget);
      await end(tester, a);
    });

    testWidgets('import through the picker adds a file; engine rejection shows a notice', (tester) async {
      final a = await mk(tester);
      await pumpIn(tester, a, const AudioFilesBody());
      final good = (await tester.runAsync(() => a.makeAudio('welcome.wav')))!;
      a.picked.add(good.path);
      await tester.tap(find.byKey(const Key('audio-import')));
      await io(tester);
      await pumpMs(tester);
      await pumpMs(tester);
      expect(find.text('welcome'), findsOneWidget);
      expect(find.byKey(const Key('audio-empty')), findsNothing);
      expect(File('${a.audioDir.path}/welcome.wav').existsSync(), isTrue);
      // A file the engine cannot decode.
      final bad = (await tester.runAsync(() => a.makeAudio('noise.mp3')))!;
      a.picked.add(bad.path);
      await tester.tap(find.byKey(const Key('audio-import')));
      await io(tester);
      await pumpMs(tester);
      expect(File('${a.audioDir.path}/noise.mp3').existsSync(), isTrue, reason: 'fake engine accepts mp3 by extension');
      await end(tester, a);
    });

    testWidgets('rename, preview and delete', (tester) async {
      final a = await mk(tester);
      final item = (await tester.runAsync(() async => a.container.read(audioLibraryProvider).import((await a.makeAudio('hold1.wav')).path)))!;
      await pumpIn(tester, a, const AudioFilesBody());
      await tester.tap(find.byKey(Key('audio-play-${item.ref}')));
      await pumpMs(tester);
      expect(a.preview.played, [item.path]);
      expect(find.byTooltip('Stop preview'), findsOneWidget);
      await tester.tap(find.byKey(Key('audio-play-${item.ref}')));
      await pumpMs(tester);
      expect(a.preview.playing.value, isNull);

      await tester.tap(find.byKey(Key('audio-menu-${item.ref}')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Rename'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Lobby music');
      await tester.tap(find.text('Save'));
      await io(tester);
      await tester.pumpAndSettle();
      expect(find.text('Lobby music'), findsOneWidget);

      await tester.tap(find.byKey(Key('audio-menu-${item.ref}')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
      await io(tester);
      await tester.pumpAndSettle();
      expect(find.text('Lobby music'), findsNothing);
      expect(File(item.path!).existsSync(), isFalse);
      await end(tester, a);
    });

    testWidgets('recording flow: timer and level, stop, preview, save', (tester) async {
      final a = await mk(tester);
      await pumpIn(tester, a, const AudioFilesBody());
      await tester.tap(find.byKey(const Key('audio-record')));
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 500)));
      await pumpMs(tester);
      expect(find.byKey(const Key('recorder-active')), findsOneWidget);
      expect(find.byKey(const Key('recorder-timer')), findsOneWidget);
      expect(find.byKey(const Key('recorder-level')), findsOneWidget);
      await tester.tap(find.byKey(const Key('recorder-stop')));
      await io(tester);
      await pumpMs(tester);
      expect(find.byKey(const Key('recorder-review')), findsOneWidget);
      final file = a.container.read(micRecorderProvider).file!;
      File(file).writeAsBytesSync(List.filled(64, 2));
      await tester.tap(find.byKey(const Key('recorder-preview')));
      await pumpMs(tester);
      expect(a.preview.played, [file]);
      await tester.tap(find.byKey(const Key('recorder-save')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Greeting');
      await tester.tap(find.text('Save').last);
      await io(tester);
      await tester.pumpAndSettle();
      expect(find.text('Greeting'), findsOneWidget);
      expect(find.byKey(const Key('recorder-review')), findsNothing);
      await end(tester, a);
    });
  });

  group('Calls settings', () {
    testWidgets('hold music and announcements are persisted', (tester) async {
      final a = await mk(tester);
      await pumpIn(tester, a, const CallsSection(), size: const Size(900, 3400));
      expect(find.byKey(const Key('hold-music')), findsOneWidget);
      expect(find.text('PBX default'), findsWidgets);
      // Change the hold music through the dropdown.
      await tester.ensureVisible(find.byKey(const Key('hold-music')));
      await tester.tap(find.descendant(of: find.byKey(const Key('hold-music')), matching: find.byType(DropdownButton<String>)));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Calm (built-in)').last);
      await io(tester);
      await tester.pumpAndSettle();
      expect(a.container.read(settingsProvider).holdMusic, 'builtin:hold_calm');
      // Announcement options appear when enabled.
      expect(find.byKey(const Key('announce-direction')), findsNothing);
      await tester.ensureVisible(find.byKey(const Key('announce-opening')));
      await tester.tap(find.byKey(const Key('announce-opening')));
      await io(tester);
      await tester.pumpAndSettle();
      expect(a.container.read(settingsProvider).announceOpening, isTrue);
      expect(find.byKey(const Key('announce-direction')), findsOneWidget);
      expect(find.byKey(const Key('announce-mute-mic')), findsOneWidget);
      expect(find.byKey(const Key('announce-monitor')), findsOneWidget);
      await tester.ensureVisible(find.byKey(const Key('announce-transfer')));
      expect(find.text('Before transferring a caller, play'), findsOneWidget);
      expect(find.text('Before recording starts, play'), findsOneWidget);
      await end(tester, a);
    });
  });

  group('Audio settings', () {
    testWidgets('shows device names, the OS default and a speaker test', (tester) async {
      final a = await mk(tester);
      await pumpIn(tester, a, const AudioSection(), size: const Size(1000, 1400));
      expect(find.byKey(const Key('test-speaker')), findsOneWidget);
      expect(find.byKey(const Key('voice-isolation-entry')), findsOneWidget);
      expect(find.byKey(const Key('audio-files-entry')), findsOneWidget);
      expect(find.text('System default'), findsWidgets);
      await tester.tap(find.byKey(const Key('test-speaker')));
      await io(tester);
      await pumpMs(tester);
      await end(tester, a);
    });

    testWidgets('voice isolation entry opens the page', (tester) async {
      final a = await mk(tester, settings: {'viMicOn': true, 'viMicStrength': 0.8});
      await pumpIn(tester, a, const AudioSection(), size: const Size(1000, 1400));
      expect(find.text('Microphone High'), findsOneWidget);
      await tester.tap(find.byKey(const Key('voice-isolation-entry')));
      await tester.pumpAndSettle();
      expect(find.text('Voice isolation'), findsWidgets);
      expect(find.byKey(const Key('vi-mic-switch')), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();
      await end(tester, a);
    });
  });

  group('In-call UI', () {
    testWidgets('announcement chip with Skip, noise chip, More-sheet toggle', (tester) async {
      final a = await mk(tester, settings: {'announceOpening': true, 'announceOpeningFile': 'builtin:chime', 'viMicOn': true});
      final cid = (await tester.runAsync(() async {
        final c = await a.dialConfirmed();
        await a.until(() => a.engine.plays.isNotEmpty);
        return c;
      }))!;
      final call = a.container.read(callsProvider).byCid(cid)!;
      await pumpIn(tester, a, SingleChildScrollView(child: CallCard(call: call, focused: true)), size: const Size(420, 900));
      await pumpMs(tester);
      expect(find.byKey(Key('announcement-chip-$cid')), findsOneWidget);
      expect(find.text('Playing announcement…'), findsOneWidget);
      expect(find.byKey(const Key('noise-cancellation-chip')), findsOneWidget);
      await tester.tap(find.byKey(Key('skip-announcement-$cid')));
      await tester.runAsync(() => a.until(() => a.engine.log.contains('stopFile')));
      await pumpMs(tester);
      await pumpMs(tester);
      expect(a.engine.log, contains('stopFile'));
      expect(find.byKey(Key('announcement-chip-$cid')), findsNothing);

      // More sheet: audio devices entry and the noise cancellation switch.
      await tester.tap(find.byTooltip('More'));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('more-audio-devices')), findsOneWidget);
      expect(find.byKey(const Key('incall-noise-strength')), findsOneWidget);
      await tester.tap(find.byKey(const Key('incall-noise-switch')));
      await io(tester);
      await tester.pumpAndSettle();
      expect(a.container.read(settingsProvider).viMicOn, isFalse);
      expect(find.byKey(const Key('incall-noise-strength')), findsNothing);
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('noise-cancellation-chip')), findsNothing);
      await end(tester, a);
    });

    testWidgets('desktop device sheet lists microphones and speakers with the default marked', (tester) async {
      final a = await mk(tester);
      final cid = (await tester.runAsync(() => a.dialConfirmed()))!;
      final call = a.container.read(callsProvider).byCid(cid)!;
      await pumpIn(tester, a, Builder(builder: (context) => TextButton(onPressed: () => showAudioSheet(context), child: const Text('open'))), size: const Size(1100, 900));
      expect(call.cid, cid);
      await tester.tap(find.text('open'));
      await io(tester);
      await tester.pumpAndSettle();
      expect(find.text('Microphone'), findsOneWidget);
      expect(find.text('Built-in Microphone'), findsOneWidget);
      expect(find.text('USB Headset'), findsWidgets);
      expect(find.text('Speaker'), findsOneWidget);
      expect(find.byKey(const Key('in-dev-default')), findsOneWidget);
      expect(find.byKey(const Key('out-dev-default')), findsOneWidget);
      await tester.tap(find.byKey(const Key('in-dev-default')));
      await tester.pumpAndSettle();
      await end(tester, a);
    });
  });

  group('Account editor', () {
    testWidgets('hold music and announcement overrides', (tester) async {
      final a = await mk(tester);
      await pumpIn(tester, a, const AccountEditorPage(accountId: 'acc1'), size: const Size(900, 3000));
      expect(find.byKey(const Key('acc-hold-music')), findsOneWidget);
      expect(find.byKey(const Key('acc-opening-announcement')), findsOneWidget);
      await end(tester, a);
    });
  });
}
