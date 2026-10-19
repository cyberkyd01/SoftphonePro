import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:softphonepro/services/calls_controller.dart';

import 'package:softphonepro/ui/pages/call_pages.dart';

import 'harness.dart';

void main() {
  testWidgets('in-call page: landscape 915x412 at 1.6 text scale keeps every action reachable', (tester) async {
    final env = await TestEnv.create(profiles: [testProfile()]);
    tester.platformDispatcher.textScaleFactorTestValue = 1.6;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await pumpApp(tester, env, size: const Size(915, 412));
    await waitRegistered(tester, env);
    env.engine.simulateIncomingCall(from: 'sip:3003@pbx.test', displayName: 'Carol');
    await settle(tester, env.engine);
    final c = containerOf(tester);
    await c.read(callsProvider.notifier).answer(c.read(callsProvider).ringing.single.cid);
    await settle(tester, env.engine);
    // The wide shell shows calls in a side panel; open the full-screen phone
    // in-call page (what a handset in landscape uses) directly.
    GoRouter.of(tester.element(find.byType(Scaffold).first)).go('/call');
    await settle(tester, env.engine);
    expect(find.byKey(const Key('end-call')), findsOneWidget);
    for (final label in ['Mute', 'Hold', 'Keypad']) {
      final f = find.descendant(of: find.byType(InCallPage), matching: find.text(label));
      expect(f, findsOneWidget, reason: label);
      await tester.ensureVisible(f);
      await tester.pump();
      expect(f.hitTestable(), findsOneWidget, reason: '$label hittable');
    }
    expect(find.byKey(const Key('end-call')).hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
