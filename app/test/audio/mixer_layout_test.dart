import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:softphonepro/app.dart';
import 'package:softphonepro/audio/audio_library.dart';
import 'package:softphonepro/models/app_settings.dart';
import 'package:softphonepro/services/calls_controller.dart';
import 'package:softphonepro/ui/pages/call_pages.dart';
import 'package:softphonepro/ui/router.dart';
import 'package:softphonepro/ui/widgets/audio_mixer.dart';
import 'package:softphonepro/ui/widgets/dial_pad.dart';

import '../harness.dart';

const _sizes = <String, Size>{
  'phone 360x740': Size(360, 740),
  'phone landscape 740x360': Size(740, 360),
  'wide landscape 915x412': Size(915, 412),
  'desktop 1200x780': Size(1200, 780),
};

Future<TestEnv> _env({String lang = 'en'}) => TestEnv.create(
  profiles: [testProfile()],
  settings: AppSettings({'onboardingDone': true, 'language': lang, 'musicbedFile': 'builtin:hold_calm', 'musicbedEnabled': true}),
);

/// Like [pumpApp], with the audio library pointing at the test directory.
Future<void> _pump(WidgetTester t, TestEnv env, Size size) async {
  final dir = Directory('${env.tempDir.path}/audio')..createSync(recursive: true);
  t.view.physicalSize = size * 2;
  t.view.devicePixelRatio = 2;
  addTearDown(t.view.reset);
  await t.pumpWidget(
    ProviderScope(
      overrides: [
        ...env.overrides,
        audioDirProvider.overrideWithValue(() async => dir.path),
        audioAssetFileProvider.overrideWithValue((asset) async {
          final f = File('${env.tempDir.path}/assets/${asset.split('/').last}');
          if (!f.existsSync()) {
            f.createSync(recursive: true);
            f.writeAsBytesSync(List.filled(64, 0));
          }
          return f.path;
        }),
      ],
      child: const SoftphoneApp(),
    ),
  );
  await settle(t, env.engine);
}

Future<void> _go(WidgetTester t, TestEnv env, String path) async {
  containerOf(t).read(routerProvider).go(path);
  await t.pump(const Duration(milliseconds: 300));
  await settle(t, env.engine);
  await t.pump(const Duration(milliseconds: 300));
}

/// Taps [key] after scrolling it into view.
Future<void> _tap(WidgetTester t, Finder f) async {
  await t.ensureVisible(f);
  await t.pump();
  await t.tap(f);
  await t.pump(const Duration(milliseconds: 300));
}

void main() {
  for (final lang in ['en', 'ar']) {
    for (final scale in [1.0, 1.6]) {
      for (final e in _sizes.entries) {
        final tag = '${e.key} text x$scale $lang';
        final size = e.value;
        final desktop = size.width >= 840 && size.height > 500;

        testWidgets('keypad: mixer fits, dial pad stays reachable ($tag)', (t) async {
          final env = await _env(lang: lang);
          t.platformDispatcher.textScaleFactorTestValue = scale;
          addTearDown(t.platformDispatcher.clearTextScaleFactorTestValue);
          await _pump(t, env, size);
          await waitRegistered(t, env);
          await _go(t, env, '/keypad');
          expect(t.takeException(), isNull);
          if (size.width >= 840) {
            // Tablet / desktop: the full mixer card sits beside or under the dial pad.
            expect(find.byKey(const Key('mixer-card')), findsOneWidget);
            expect(find.byKey(const Key('mixer-mic-slider')), findsOneWidget);
          } else {
            expect(find.byKey(const Key('mixer-strip')), findsOneWidget);
            if (size.height >= 700 && scale == 1.0) {
              final zero = t.getRect(find.byWidgetPredicate((w) => w is DialKey && w.digit == '0'));
              expect(zero.bottom, lessThanOrEqualTo(size.height), reason: 'dial pad stays on screen with the strip collapsed');
              expect(zero.top, greaterThanOrEqualTo(0));
            }
            // Open the strip, then the details: nothing overflows.
            await _tap(t, find.byKey(const Key('mixer-strip')));
            expect(t.takeException(), isNull, reason: 'strip open');
            expect(find.byKey(const Key('mixer-mic-slider')), findsOneWidget);
            await _tap(t, find.byKey(const Key('mixer-expand')));
            expect(t.takeException(), isNull, reason: 'details open');
            expect(find.byKey(const Key('mixer-input-device')), findsOneWidget);
            await _tap(t, find.byKey(const Key('mixer-strip')));
            expect(t.takeException(), isNull);
          }
          expect(desktop || size.width < 840 || size.height <= 500, isTrue);
        });

        testWidgets('in-call: mixer visible, Mute/Hold/Keypad/End reachable ($tag)', (t) async {
          final env = await _env(lang: lang);
          t.platformDispatcher.textScaleFactorTestValue = scale;
          addTearDown(t.platformDispatcher.clearTextScaleFactorTestValue);
          await _pump(t, env, size);
          await waitRegistered(t, env);
          await containerOf(t).read(callsProvider.notifier).dial('2002');
          await settle(t, env.engine);
          await t.pump(const Duration(milliseconds: 500));
          if (size.width >= 840) {
            // Side panel next to every page.
            expect(find.byKey(const Key('mixer-card')), findsOneWidget);
            expect(find.byKey(const Key('mixer-mic-slider')), findsOneWidget);
            await t.pump(const Duration(milliseconds: 300));
            expect(t.takeException(), isNull);
            // The musicbed indicator is part of the call card.
            expect(find.byKey(const Key('musicbed-chip')), findsOneWidget);
            return;
          }
          await _go(t, env, '/call');
          expect(t.takeException(), isNull);
          // The keypad page stays mounted below the call page: look inside the latter.
          Finder inCall(String key) => find.descendant(of: find.byType(InCallPage).last, matching: find.byKey(Key(key)));
          expect(inCall('mixer-strip'), findsOneWidget);
          expect(inCall('musicbed-chip'), findsOneWidget);
          for (final label in ['Mute', 'Hold', 'Keypad']) {
            if (lang != 'en') break;
            final f = find.descendant(of: find.byType(InCallPage).last, matching: find.text(label));
            await t.ensureVisible(f);
            await t.pump();
            expect(f.hitTestable(), findsOneWidget, reason: label);
          }
          expect(find.descendant(of: find.byType(InCallPage).last, matching: find.byKey(const Key('end-call'))).hitTestable(), findsOneWidget, reason: 'End stays pinned');
          // Open the strip and the details.
          await _tap(t, inCall('mixer-strip'));
          expect(t.takeException(), isNull);
          await _tap(t, inCall('mixer-expand'));
          expect(t.takeException(), isNull);
          expect(inCall('mixer-musicbed-file'), findsOneWidget);
          expect(find.descendant(of: find.byType(InCallPage).last, matching: find.byKey(const Key('end-call'))).hitTestable(), findsOneWidget, reason: 'End stays pinned with the mixer open');
        });
      }
    }
  }

  testWidgets('in-call keypad (phone): mixer strip does not hide the dial keys', (t) async {
    final env = await _env();
    await _pump(t, env, const Size(360, 740));
    await waitRegistered(t, env);
    await containerOf(t).read(callsProvider.notifier).dial('2002');
    await settle(t, env.engine);
    await _go(t, env, '/call');
    final page = find.byType(InCallPage).last;
    await t.tap(find.descendant(of: page, matching: find.text('Keypad')));
    await t.pumpAndSettle();
    final end = t.getRect(find.descendant(of: page, matching: find.byKey(const Key('end-call'))));
    final zero = t.getRect(find.descendant(of: page, matching: find.byWidgetPredicate((w) => w is DialKey && w.digit == '0')));
    expect(zero.bottom, lessThanOrEqualTo(end.top + 0.5));
    expect(t.takeException(), isNull);
  });

  testWidgets('the details open state is shared by the keypad and call screens', (t) async {
    final env = await _env();
    await _pump(t, env, const Size(360, 740));
    await waitRegistered(t, env);
    await _go(t, env, '/keypad');
    await _tap(t, find.byKey(const Key('mixer-strip')));
    expect(containerOf(t).read(mixerStripOpenProvider), isTrue);
    await containerOf(t).read(callsProvider.notifier).dial('2002');
    await settle(t, env.engine);
    await _go(t, env, '/call');
    expect(find.descendant(of: find.byType(InCallPage).last, matching: find.byKey(const Key('mixer-mic-slider'))), findsOneWidget, reason: 'still open on the call page');
  });
}
