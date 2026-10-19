import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:softphonepro/app.dart';
import 'package:softphonepro/l10n/l10n.dart';
import 'package:softphonepro/models/app_settings.dart';
import 'package:softphonepro/models/contact.dart';
import 'package:softphonepro/recordings/recording_playback.dart';
import 'package:softphonepro/services/calls_controller.dart';
import 'package:softphonepro/models/chat.dart';
import 'package:softphonepro/services/settings_controller.dart';
import 'package:softphonepro/storage/repositories.dart';
import 'package:softphonepro/ui/router.dart';

import '../harness.dart';
import '../lan/lan_harness.dart';

const _phone = Size(412, 915);
const _desktop = Size(1280, 800);

Future<TestEnv> _env(String lang) => TestEnv.create(
  profiles: [
    testProfile(),
    testProfile(id: 'acc2', user: '1002'),
  ],
  settings: AppSettings({'onboardingDone': true, 'language': lang}),
  contacts: const [
    Contact(
      id: 'c1',
      name: 'Alice Johnson',
      numbers: [ContactNumber(label: 'work', value: '2002')],
    ),
  ],
);

Future<void> _pump(WidgetTester t, TestEnv env, Size size) async {
  t.view.physicalSize = size * 2;
  t.view.devicePixelRatio = 2;
  addTearDown(t.view.reset);
  await t.pumpWidget(env.app());
  await settle(t, env.engine);
  await waitRegistered(t, env);
}

Future<void> _go(WidgetTester t, TestEnv env, String path) async {
  containerOf(t).read(routerProvider).go(path);
  await t.pump(const Duration(milliseconds: 300));
  await settle(t, env.engine);
  await t.pump(const Duration(milliseconds: 300));
}

/// pumpAndSettle can spin forever on looping animations; a few frames suffice.
Future<void> _flush(WidgetTester t) async {
  for (var i = 0; i < 4; i++) {
    await t.pump(const Duration(milliseconds: 150));
  }
}

void _expectDirection(WidgetTester t, String lang) {
  final ctx = t.element(find.byType(Scaffold).first);
  expect(
    Directionality.of(ctx),
    lang == 'ar' ? TextDirection.rtl : TextDirection.ltr,
  );
  expect(Localizations.localeOf(ctx).languageCode, lang);
  expect(t.takeException(), isNull);
}

class _NoPlayback implements RecordingPlayback {
  @override
  Stream<bool> get playing => const Stream.empty();
  @override
  Stream<Duration> get position => const Stream.empty();
  @override
  Stream<Duration> get duration => const Stream.empty();
  @override
  Stream<void> get completed => const Stream.empty();
  @override
  Future<void> play(String path) async {}
  @override
  Future<void> pause() async {}
  @override
  Future<void> resume() async {}
  @override
  Future<void> seek(Duration to) async {}
  @override
  Future<void> stop() async {}
  @override
  Future<void> dispose() async {}
}

void main() {
  setUpAll(() => HttpOverrides.global = null);

  for (final lang in ['ar', 'de', 'ja']) {
    for (final entry in {'phone': _phone, 'desktop': _desktop}.entries) {
      final size = entry.value;
      final tag = '$lang ${entry.key}';

      testWidgets('shell + keypad ($tag)', (t) async {
        final env = await _env(lang);
        await _pump(t, env, size);
        await _go(t, env, '/keypad');
        _expectDirection(t, lang);
      });

      testWidgets('in-call page ($tag)', (t) async {
        final env = await _env(lang);
        await _pump(t, env, size);
        await containerOf(t).read(callsProvider.notifier).dial('2002');
        await settle(t, env.engine);
        await t.pump(const Duration(milliseconds: 500));
        if (size == _phone) {
          await _go(t, env, '/call');
        }
        _expectDirection(t, lang);
      });

      testWidgets('settings ($tag)', (t) async {
        final env = await _env(lang);
        await _pump(t, env, size);
        await _go(t, env, '/settings');
        _expectDirection(t, lang);
        for (final s in [
          'audio',
          'calls',
          'network',
          'recording',
          'appearance',
          'privacy',
          'lan',
          'advanced',
          'about',
        ]) {
          await _go(t, env, '/settings/$s');
          expect(t.takeException(), isNull, reason: 'settings/$s');
        }
      });

      testWidgets('recordings page ($tag)', (t) async {
        final tmp = Directory.systemTemp.createTempSync('l10n_rec');
        addTearDown(() => tmp.deleteSync(recursive: true));
        final f = File('${tmp.path}/r1.wav')
          ..writeAsBytesSync(List.filled(16, 1));
        final now = DateTime.now();
        final env = await _env(lang);
        await t.runAsync(() async {
          await RecordingsRepository(env.db).put(
            RecordingMeta(
              id: 'r1',
              path: f.path,
              remote: '3003',
              time: DateTime(now.year, now.month, now.day, 12),
              durationMs: 65000,
              accountId: 'acc1',
              format: 'wav',
              bytes: 2 * 1024 * 1024,
              outgoing: true,
            ),
          );
        });
        t.view.physicalSize = size * 2;
        t.view.devicePixelRatio = 2;
        addTearDown(t.view.reset);
        await t.pumpWidget(
          ProviderScope(
            overrides: [
              ...env.overrides,
              recordingPlaybackFactoryProvider.overrideWithValue(
                () => _NoPlayback(),
              ),
            ],
            child: const SoftphoneApp(),
          ),
        );
        await settle(t, env.engine);
        await _go(t, env, '/recordings');
        _expectDirection(t, lang);
      });

      testWidgets('LAN page ($tag)', (t) async {
        final n = await LanNode.create('Alpha');
        final c = (await t.runAsync(n.boot))!;
        addTearDown(() => t.runAsync(n.dispose));
        c.read(settingsProvider.notifier).update({'language': lang});
        t.view.physicalSize = size * 2;
        t.view.devicePixelRatio = 2;
        addTearDown(t.view.reset);
        await t.pumpWidget(
          UncontrolledProviderScope(container: c, child: const SoftphoneApp()),
        );
        c.read(routerProvider).go('/lan');
        for (var i = 0; i < 8; i++) {
          await t.runAsync(
            () => Future<void>.delayed(const Duration(milliseconds: 30)),
          );
          await t.pump(const Duration(milliseconds: 100));
        }
        _expectDirection(t, lang);
        await t.pumpWidget(const SizedBox());
        for (var i = 0; i < 4; i++) {
          await t.runAsync(
            () => Future<void>.delayed(const Duration(milliseconds: 30)),
          );
          await t.pump(const Duration(seconds: 6));
        }
      });
    }
  }

  testWidgets('language setting switches the app locale live', (t) async {
    final env = await TestEnv.create(profiles: [testProfile()]);
    await pumpApp(t, env);
    Locale loc() =>
        Localizations.localeOf(t.element(find.byType(Scaffold).first));
    expect(loc().languageCode, 'en');
    expect(find.text('Keypad'), findsWidgets);

    final c = containerOf(t);
    await t.runAsync(() => c.read(settingsProvider.notifier).update({'language': 'de'}));
    await _flush(t);
    expect(loc().languageCode, 'de');
    expect(find.text('Keypad'), findsNothing);
    expect(c.read(l10nProvider).localeName, 'de');

    await t.runAsync(() => c.read(settingsProvider.notifier).update({'language': 'ar'}));
    await _flush(t);
    expect(
      Directionality.of(t.element(find.byType(Scaffold).first)),
      TextDirection.rtl,
    );

    await t.runAsync(() => c.read(settingsProvider.notifier).update({'language': 'pt_BR'}));
    await _flush(t);
    expect(loc().languageCode, 'pt');
    expect(loc().countryCode, 'BR');

    await t.runAsync(() => c.read(settingsProvider.notifier).update({'language': 'system'}));
    await _flush(t);
    expect(loc().languageCode, 'en');
  });

  testWidgets(
    'picking a language in Settings > Appearance applies and persists it',
    (t) async {
      final env = await TestEnv.create(profiles: [testProfile()]);
      await pumpApp(t, env);
      await _go(t, env, '/settings/appearance');
      await t.tap(find.byKey(const Key('language-tile')));
      await _flush(t);
      expect(find.text('Deutsch'), findsOneWidget);
      await t.scrollUntilVisible(find.byKey(const Key('language-ja')), 100, scrollable: find.descendant(of: find.byType(SimpleDialog), matching: find.byType(Scrollable)).last);
    expect(find.text('日本語'), findsOneWidget);
      await t.tap(find.byKey(const Key('language-ja')));
      await _flush(t);
      expect(containerOf(t).read(settingsProvider).language, 'ja');
      expect(
        Localizations.localeOf(
          t.element(find.byType(Scaffold).first),
        ).languageCode,
        'ja',
      );
    },
  );

  testWidgets('system locale is followed when language is "system"', (t) async {
    t.platformDispatcher.localesTestValue = const [Locale('fr', 'FR')];
    addTearDown(t.platformDispatcher.clearLocalesTestValue);
    final env = await TestEnv.create(profiles: [testProfile()]);
    await pumpApp(t, env);
    expect(
      Localizations.localeOf(
        t.element(find.byType(Scaffold).first),
      ).languageCode,
      'fr',
    );
    t.platformDispatcher.localesTestValue = const [Locale('ar')];
    await _flush(t);
    expect(
      Localizations.localeOf(
        t.element(find.byType(Scaffold).first),
      ).languageCode,
      'ar',
    );
  });
}
