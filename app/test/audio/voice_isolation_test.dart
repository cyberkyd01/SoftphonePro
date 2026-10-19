import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:softphonepro/audio/voice_isolation.dart';
import 'package:softphonepro/core/theme.dart';
import 'package:softphonepro/services/settings_controller.dart';
import 'package:softphonepro/ui/pages/audio/voice_isolation_page.dart';
import 'package:softphonepro/ui/widgets/settings_tiles.dart';

import 'audio_harness.dart';

Future<void> pumpVi(WidgetTester tester, AudioEnv a, {Size size = const Size(412, 915)}) async {
  tester.view.physicalSize = size * 2;
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: a.container,
      child: MaterialApp(debugShowCheckedModeBanner: false, theme: buildTheme(Brightness.light), home: const VoiceIsolationPage()),
    ),
  );
  await tester.runAsync(() => a.flush());
  await tester.pump(const Duration(milliseconds: 50));
}

void main() {
  test('strength labels', () {
    expect(strengthLabel(0.1), 'Low');
    expect(strengthLabel(0.5), 'Medium');
    expect(strengthLabel(0.8), 'High');
    expect(strengthLabel(1.0), 'Max');
    expect(strengthText(0.8), 'High (80%)');
  });

  test('settings are applied live through setVoiceIsolation', () async {
    final a = await AudioEnv.create();
    await a.settings.update({'viMicOn': true, 'viMicStrength': 0.9});
    await a.flush();
    expect(a.engine.voiceIsolationMic.enabled, isTrue);
    expect(a.engine.voiceIsolationMic.strength, closeTo(0.9, 1e-9));
    expect(a.engine.voiceIsolationIncoming.enabled, isFalse);
    await a.settings.update({'viInOn': true, 'viInStrength': 0.4});
    await a.flush();
    expect(a.engine.voiceIsolationIncoming.enabled, isTrue);
    expect(a.engine.voiceIsolationIncoming.strength, closeTo(0.4, 1e-9));
    await a.settings.update({'viMicOn': false});
    await a.flush();
    expect(a.engine.voiceIsolationMic.enabled, isFalse);
    a.dispose();
  });

  test('saved settings travel in core.start', () async {
    final a = await AudioEnv.create(settings: {'viMicOn': true, 'viMicStrength': 0.55, 'viInOn': true, 'viInStrength': 0.25});
    final vi = a.engine.startConfig!.media.voiceIsolation;
    expect(vi.mic.enabled, isTrue);
    expect(vi.mic.strength, closeTo(0.55, 1e-9));
    expect(vi.incoming.enabled, isTrue);
    expect(vi.incoming.strength, closeTo(0.25, 1e-9));
    expect(a.engine.voiceIsolationMic.enabled, isTrue);
    a.dispose();
  });

  test('an engine without voice isolation does not break settings', () async {
    final a = await AudioEnv.create(engine: LogEngine(unsupportedVoiceIsolation: true));
    await a.settings.update({'viMicOn': true});
    await a.flush();
    expect(a.container.read(settingsProvider).viMicOn, isTrue);
    await a.container.read(voiceIsolationProvider.notifier).probe();
    expect(a.container.read(voiceIsolationProvider).available, isFalse);
    a.dispose();
  });

  testWidgets('page: toggles and sliders persist and apply', (tester) async {
    final a = (await tester.runAsync(() => AudioEnv.create()))!;
    await pumpVi(tester, a);
    expect(find.text('AI NOISE CANCELLATION'), findsOneWidget);
    expect(find.byKey(const Key('vi-unavailable')), findsNothing);
    await tester.tap(find.byKey(const Key('vi-mic-switch')));
    await tester.runAsync(() => a.flush());
    await tester.pump(const Duration(milliseconds: 20));
    expect(a.engine.voiceIsolationMic.enabled, isTrue);
    expect(find.textContaining('Strength: High (70%)'), findsOneWidget);
    // Drag the mic strength slider to the maximum.
    final slider = find.descendant(of: find.byKey(const Key('vi-mic-strength')), matching: find.byType(Slider));
    await tester.drag(slider, const Offset(400, 0));
    await tester.runAsync(() => a.flush());
    await tester.pump(const Duration(milliseconds: 20));
    expect(a.engine.voiceIsolationMic.strength, 1.0);
    expect(find.textContaining('Max (100%)'), findsWidgets);
    // Incoming side is independent.
    expect(a.engine.voiceIsolationIncoming.enabled, isFalse);
    await tester.tap(find.byKey(const Key('vi-in-switch')));
    await tester.runAsync(() => a.flush());
    await tester.pump(const Duration(milliseconds: 20));
    expect(a.engine.voiceIsolationIncoming.enabled, isTrue);
    await tester.pumpWidget(const SizedBox());
    a.dispose();
  });

  testWidgets('page: speech meter polls while visible and stops after closing', (tester) async {
    final a = (await tester.runAsync(() => AudioEnv.create(settings: {'viMicOn': true})))!;
    a.engine.fakeVad = 0.8;
    await pumpVi(tester, a);
    final before = a.engine.statusPolls;
    for (var i = 0; i < 10; i++) {
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
      await tester.pump(const Duration(milliseconds: 100));
    }
    final during = a.engine.statusPolls;
    expect(during - before, greaterThanOrEqualTo(3));
    final meter = tester.widget<LinearProgressIndicator>(find.byKey(const Key('vi-vad-meter')));
    expect(meter.value, closeTo(0.8, 1e-9));
    // Close the page.
    await tester.pumpWidget(const SizedBox());
    final atClose = a.engine.statusPolls;
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 400)));
    expect(a.engine.statusPolls, atClose);
    expect(a.container.read(voiceIsolationProvider.notifier).metering, isFalse);
    await tester.pumpWidget(const SizedBox());
    a.dispose();
  });

  testWidgets('page: shows a notice and disables toggles when unsupported', (tester) async {
    final a = (await tester.runAsync(() => AudioEnv.create(engine: LogEngine(unsupportedVoiceIsolation: true))))!;
    await pumpVi(tester, a);
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byKey(const Key('vi-unavailable')), findsOneWidget);
    final sw = tester.widget<SwitchTile>(find.byKey(const Key('vi-mic-switch')));
    expect(sw.onChanged, isNull);
    await tester.pumpWidget(const SizedBox());
    a.dispose();
  });

  testWidgets('page: echo test toggles loopback and stops when closing', (tester) async {
    final a = (await tester.runAsync(() => AudioEnv.create()))!;
    await pumpVi(tester, a);
    await tester.tap(find.byKey(const Key('vi-echo-test')));
    await tester.runAsync(() => a.flush());
    await tester.pump(const Duration(milliseconds: 20));
    expect(a.engine.loopbackEnabled, isTrue);
    await tester.pumpWidget(const SizedBox());
    await tester.runAsync(() => a.flush());
    expect(a.engine.loopbackEnabled, isFalse);
    await tester.pumpWidget(const SizedBox());
    a.dispose();
  });
}
