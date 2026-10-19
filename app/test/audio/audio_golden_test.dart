import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:softphonepro/audio/audio_library.dart';
import 'package:softphonepro/core/theme.dart';
import 'package:softphonepro/ui/pages/audio/audio_files_page.dart';
import 'package:softphonepro/ui/pages/audio/voice_isolation_page.dart';
import 'package:spcore_dart/spcore_dart.dart';

import 'audio_harness.dart';
import 'package:softphonepro/l10n/app_localizations.dart';

Future<void> _io(WidgetTester tester) async {
  for (var i = 0; i < 40; i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 6)));
    await tester.pump(const Duration(milliseconds: 20));
  }
}

Future<AudioEnv> _pump(WidgetTester tester, Widget page, Map<String, dynamic> settings, Size size, Brightness b, {Future<void> Function(AudioEnv)? prepare}) async {
  final a = (await tester.runAsync(() async {
    final e = await AudioEnv.create(settings: settings);
    await prepare?.call(e);
    return e;
  }))!;
  tester.view.physicalSize = size * 2;
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: a.container,
      child: MaterialApp(localizationsDelegates: AppLocalizations.localizationsDelegates, supportedLocales: AppLocalizations.supportedLocales, debugShowCheckedModeBanner: false, theme: buildTheme(b), home: page),
    ),
  );
  await _io(tester);
  return a;
}

void main() {
  for (final (name, size) in [('phone', const Size(412, 1150)), ('desktop', const Size(900, 1000))]) {
    testWidgets('voice isolation $name', (tester) async {
      final a = await _pump(tester, const VoiceIsolationPage(), {'viMicOn': true, 'viMicStrength': 0.8, 'viInOn': true, 'viInStrength': 0.4}, size, Brightness.light,
          prepare: (e) async => e.engine.fakeVad = 0.62);
      await expectLater(find.byType(MaterialApp), matchesGoldenFile('goldens/voice_isolation_$name.png'));
      await tester.pumpWidget(const SizedBox());
      a.dispose();
    });

    testWidgets('audio files $name (dark)', (tester) async {
      final a = await _pump(tester, const AudioFilesPage(), const {}, Size(size.width, name == 'phone' ? 760 : 700), Brightness.dark, prepare: (e) async {
        e.engine.fileInfos[(await e.makeAudio('Welcome message.wav')).path] = const MediaFileInfo(format: 'wav', durationMs: 7400, sampleRate: 16000, channels: 1);
        e.engine.fileInfos[(await e.makeAudio('Office jazz.mp3')).path] = const MediaFileInfo(format: 'mp3', durationMs: 185000, sampleRate: 44100, channels: 2);
        final lib = e.container.read(audioLibraryProvider);
        await lib.import((await e.makeAudio('Welcome message.wav')).path);
        await lib.import((await e.makeAudio('Office jazz.mp3')).path);
      });
      await expectLater(find.byType(MaterialApp), matchesGoldenFile('goldens/audio_files_$name.png'));
      await tester.pumpWidget(const SizedBox());
      a.dispose();
    });
  }
}
