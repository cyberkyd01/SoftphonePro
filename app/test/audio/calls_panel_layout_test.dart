import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:softphonepro/app.dart';
import 'package:softphonepro/audio/audio_library.dart';
import 'package:softphonepro/lan/lan_handoff_impl.dart';
import 'package:softphonepro/lan/lan_models.dart';
import 'package:softphonepro/models/app_settings.dart';
import 'package:softphonepro/services/calls_controller.dart';
import 'package:softphonepro/ui/pages/call_pages.dart';
import 'package:softphonepro/ui/router.dart';

import '../harness.dart';

Future<TestEnv> _env({Map<String, dynamic> extra = const {}}) => TestEnv.create(
  profiles: [testProfile()],
  settings: AppSettings({'onboardingDone': true, 'musicbedFile': 'builtin:hold_calm', 'musicbedEnabled': true, ...extra}),
);

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
  await waitRegistered(t, env);
}

void main() {
  for (final size in const [Size(1280, 800), Size(1024, 700)]) {
    for (final n in [1, 2, 3]) {
      testWidgets('calls panel ${size.width.toInt()}x${size.height.toInt()}: $n calls with banners, no clipped actions', (t) async {
        final env = await _env();
        await _pump(t, env, size);
        final c = containerOf(t);
        for (var i = 0; i < n; i++) {
          await c.read(callsProvider.notifier).dial('200${2 + i}');
          await settle(t, env.engine);
        }
        final live = c.read(callsProvider).live;
        expect(live.length, n);
        for (final call in live) {
          c.read(lanRelayProvider.notifier).put(RelaySession(handoffId: 'h${call.cid}', cid: call.cid, peerId: 'p', peerName: 'Desk-B', phase: RelayPhase.relayed));
        }
        await t.pump(const Duration(milliseconds: 400));
        expect(t.takeException(), isNull);

        final mixer = find.byKey(const Key('mixer-card'));
        expect(mixer, findsOneWidget);
        final panel = find.byKey(const Key('calls-panel-scroll'));
        for (final call in live) {
          for (final k in ['card-end-${call.cid}', 'relay-take-back', 'relay-end']) {
            final f = k.startsWith('relay') ? find.byKey(Key(k)).at(live.indexOf(call)) : find.byKey(Key(k));
            await t.ensureVisible(f);
            await t.pump();
            expect(f.hitTestable(), findsOneWidget, reason: '$k of call ${call.cid} is reachable');
            // The mixer never overlaps a call action.
            expect(t.getRect(f).overlaps(t.getRect(mixer)), isFalse, reason: '$k is not under the mixer card');
          }
        }
        // The mixer's lowest control is reachable too.
        final hear = find.byKey(const Key('mixer-monitor-switch'));
        await t.ensureVisible(hear);
        await t.pump();
        expect(hear.hitTestable(), findsOneWidget);
        final panelRect = t.getRect(panel);
        expect(t.getRect(hear).bottom, lessThanOrEqualTo(panelRect.bottom + 0.5));
        expect(t.takeException(), isNull);
      });
    }
  }

  for (final lang in ['en', 'de']) {
    testWidgets('Settings > Audio during a call at 1280x800 ($lang): labels never break mid-word', (t) async {
      final env = await _env(extra: {'language': lang});
      await _pump(t, env, const Size(1280, 800));
      final c = containerOf(t);
      await c.read(callsProvider.notifier).dial('2002');
      await settle(t, env.engine);
      c.read(routerProvider).go('/settings/audio');
      await t.pump(const Duration(milliseconds: 400));
      await settle(t, env.engine);
      expect(t.takeException(), isNull);
      // Device rows: the label sits on one line (a mid-word break would make
      // the text two lines tall) and the dropdown is fully inside the pane.
      final label = find.text(lang == 'en' ? 'Microphone' : 'Mikrofon');
      expect(label, findsWidgets);
      final box = t.getRect(label.first);
      expect(box.height, lessThan(26), reason: 'single line');
      final dd = find.descendant(of: find.byType(DropdownButton<String>), matching: find.byType(Text)).first;
      expect(t.getRect(dd).right, lessThan(1280 - 360));
    });
  }

  testWidgets('musicbed chip is muted while the call is on hold', (t) async {
    final env = await _env();
    await _pump(t, env, const Size(1280, 800));
    final c = containerOf(t);
    await c.read(callsProvider.notifier).dial('2002');
    await settle(t, env.engine);
    await t.pump(const Duration(milliseconds: 500));
    expect(find.byKey(const Key('musicbed-chip')), findsOneWidget);
    expect(find.byKey(const Key('musicbed-chip-paused')), findsNothing);
    await c.read(callsProvider.notifier).toggleHold(c.read(callsProvider).live.single.cid);
    await settle(t, env.engine);
    await t.pump(const Duration(milliseconds: 500));
    expect(find.byKey(const Key('musicbed-chip')), findsNothing, reason: 'no "Musicbed on" claim for a held call');
    expect(find.byKey(const Key('musicbed-chip-paused')), findsOneWidget);
    expect(find.text('Musicbed paused (on hold)'), findsOneWidget);
  });

  const phones = <String, (Size, double)>{
    'portrait 360x740': (Size(360, 740), 1.0),
    'landscape 740x360': (Size(740, 360), 1.0),
    'portrait 360x740 text x1.6': (Size(360, 740), 1.6),
    'landscape 740x360 text x1.6': (Size(740, 360), 1.6),
  };
  for (final e in phones.entries) {
    testWidgets('phone in-call (${e.key}): meter strip on screen without scrolling; expanding keeps it reachable', (t) async {
      final env = await _env();
      t.platformDispatcher.textScaleFactorTestValue = e.value.$2;
      addTearDown(t.platformDispatcher.clearTextScaleFactorTestValue);
      await _pump(t, env, e.value.$1);
      await containerOf(t).read(callsProvider.notifier).dial('2002');
      await settle(t, env.engine);
      containerOf(t).read(routerProvider).go('/call');
      await t.pump(const Duration(milliseconds: 300));
      await settle(t, env.engine);
      final page = find.byType(InCallPage).last;
      Finder inCall(String k) => find.descendant(of: page, matching: find.byKey(Key(k)));
      final size = e.value.$1;
      final strip = inCall('mixer-strip');
      expect(strip, findsOneWidget);
      var r = t.getRect(strip);
      final end = t.getRect(inCall('end-call'));
      expect(r.top, greaterThanOrEqualTo(0));
      expect(r.bottom, lessThanOrEqualTo(size.height));
      if (size.width < size.height) expect(r.bottom, lessThanOrEqualTo(end.top), reason: 'strip above the pinned End button');
      expect(strip.hitTestable(), findsOneWidget, reason: 'meters reachable with no scrolling');
      // Above the action grid.
      final mute = find.descendant(of: page, matching: find.text('Mute'));
      if (size.width < size.height) expect(r.bottom, lessThanOrEqualTo(t.getRect(mute).top));

      await t.tap(strip);
      await t.pump(const Duration(milliseconds: 400));
      await t.ensureVisible(inCall('mixer-expand'));
      await t.pump();
      await t.tap(inCall('mixer-expand'));
      for (var i = 0; i < 6; i++) {
        await t.pump(const Duration(milliseconds: 150)); // the reveal scroll animates
      }
      expect(t.takeException(), isNull);
      // Expanded: its top is visible and the End button is still hittable.
      r = t.getRect(inCall('mixer-strip'));
      expect(r.top, greaterThanOrEqualTo(0));
      expect(inCall('end-call').hitTestable(), findsOneWidget);
      final slider = inCall('mixer-mic-slider');
      expect(slider, findsOneWidget);
      await t.ensureVisible(slider);
      await t.pump();
      expect(slider.hitTestable(), findsOneWidget);
    });
  }

  testWidgets('keypad strip expanded at 400x820 sizes to its content, nothing cut mid-row', (t) async {
    final env = await _env();
    await _pump(t, env, const Size(400, 820));
    containerOf(t).read(routerProvider).go('/keypad');
    await t.pump(const Duration(milliseconds: 300));
    await t.tap(find.byKey(const Key('mixer-strip')));
    await t.pump(const Duration(milliseconds: 300));
    await t.tap(find.byKey(const Key('mixer-expand')));
    await t.pump(const Duration(milliseconds: 500));
    expect(t.takeException(), isNull);
    final zero = t.getRect(find.text('0').first);
    expect(zero.bottom, lessThanOrEqualTo(820));
    // Every control of the opened strip is fully inside the screen or reachable by scrolling.
    for (final k in ['mixer-input-device', 'mixer-output-device', 'mixer-musicbed-file', 'mixer-monitor-switch', 'mixer-expand']) {
      final f = find.byKey(Key(k));
      expect(f, findsOneWidget, reason: k);
      await t.ensureVisible(f);
      await t.pump();
      expect(f.hitTestable(), findsOneWidget, reason: k);
    }
  });
}
