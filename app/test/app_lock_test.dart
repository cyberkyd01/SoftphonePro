import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:softphonepro/models/app_settings.dart';
import 'package:softphonepro/security/app_lock_controller.dart';
import 'package:softphonepro/security/app_lock_service.dart';
import 'package:softphonepro/services/calls_controller.dart';
import 'package:softphonepro/services/settings_controller.dart';
import 'package:softphonepro/ui/router.dart';
import 'package:softphonepro/storage/secrets_store.dart';

import 'harness.dart';

void main() {
  group('AppLockService', () {
    late MemorySecretsStore store;
    late DateTime now;
    late AppLockService svc;
    setUp(() {
      store = MemorySecretsStore();
      now = DateTime(2026, 1, 1, 12);
      svc = AppLockService(store, iterations: 10, now: () => now);
    });

    test('validates PIN shape', () {
      expect(AppLockService.isValidPin('1234'), isTrue);
      expect(AppLockService.isValidPin('12345678'), isTrue);
      expect(AppLockService.isValidPin('123'), isFalse);
      expect(AppLockService.isValidPin('123456789'), isFalse);
      expect(AppLockService.isValidPin('12a4'), isFalse);
      expect(() => svc.setPin('12'), throwsArgumentError);
    });

    test('set / verify stores only a salted hash', () async {
      expect(await svc.hasPin(), isFalse);
      await svc.setPin('4821');
      expect(await svc.hasPin(), isTrue);
      final stored = store.data['applock.pin']!;
      expect(stored.startsWith(r'pbkdf2-sha256$10$'), isTrue);
      expect(stored.contains('4821'), isFalse);
      expect((await svc.verify('4821')).ok, isTrue);
      expect((await svc.verify('0000')).result, PinResult.wrong);
      // Same PIN, new salt -> different hash.
      await svc.setPin('4821');
      expect(store.data['applock.pin'], isNot(stored));
    });

    test('backoff after repeated wrong PINs, reset on success', () async {
      await svc.setPin('1357');
      for (var i = 0; i < AppLockService.freeAttempts; i++) {
        final r = await svc.verify('0000');
        expect(r.result, PinResult.wrong);
        expect(r.retryAfter, Duration.zero);
      }
      final fifth = await svc.verify('0000');
      expect(fifth.result, PinResult.wrong);
      expect(fifth.retryAfter, const Duration(seconds: 30));
      // Even the right PIN is refused during the lockout.
      final locked = await svc.verify('1357');
      expect(locked.result, PinResult.lockedOut);
      expect(locked.retryAfter, const Duration(seconds: 30));
      now = now.add(const Duration(seconds: 31));
      final sixth = await svc.verify('0000');
      expect(sixth.retryAfter, const Duration(seconds: 60));
      now = now.add(const Duration(seconds: 61));
      expect((await svc.verify('1357')).ok, isTrue);
      expect(await svc.lockoutRemaining(), Duration.zero);
      expect((await svc.verify('0000')).failures, 1);
    });

    test('backoff is capped', () {
      expect(AppLockService.backoffFor(3), Duration.zero);
      expect(AppLockService.backoffFor(5), const Duration(seconds: 30));
      expect(AppLockService.backoffFor(20), const Duration(minutes: 15));
    });

    test('clear removes the PIN', () async {
      await svc.setPin('1357');
      await svc.clear();
      expect(await svc.hasPin(), isFalse);
    });
  });

  Future<TestEnv> lockedEnv() async {
    final env = await TestEnv.create(
      profiles: [testProfile()],
      settings: const AppSettings({'onboardingDone': true, 'appLock': true, 'appLockBiometrics': false}),
    );
    await AppLockService(env.secrets, iterations: 10).setPin('2468');
    return env;
  }

  Future<void> tapPin(WidgetTester tester, String pin) async {
    for (final d in pin.split('')) {
      await tester.tap(find.byKey(Key('lock-digit-$d')));
      await tester.pump();
    }
    await tester.tap(find.byKey(const Key('lock-submit')));
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 100)));
    await tester.pump(const Duration(milliseconds: 100));
  }

  testWidgets('locked at start; wrong PIN rejected; right PIN unlocks', (tester) async {
    final env = await lockedEnv();
    await pumpApp(tester, env);
    expect(find.byKey(const Key('lock-screen')), findsOneWidget);
    expect(containerOf(tester).read(appLockProvider), isTrue);

    await tapPin(tester, '1111');
    expect(find.text('Wrong PIN'), findsOneWidget);
    expect(find.byKey(const Key('lock-screen')), findsOneWidget);

    await tapPin(tester, '2468');
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byKey(const Key('lock-screen')), findsNothing);
    expect(containerOf(tester).read(appLockProvider), isFalse);
  });

  testWidgets('lock-after-background honours the delay', (tester) async {
    final env = await lockedEnv();
    await pumpApp(tester, env);
    final c = containerOf(tester);
    c.read(appLockProvider.notifier).state = false;
    await tester.pump();
    final n = c.read(appLockProvider.notifier);
    final t0 = DateTime(2026, 1, 1, 12);
    n.onBackground(t0);
    n.onResume(t0.add(const Duration(seconds: 30)));
    expect(c.read(appLockProvider), isFalse); // default delay is 1 minute
    n.onBackground(t0);
    n.onResume(t0.add(const Duration(minutes: 2)));
    expect(c.read(appLockProvider), isTrue);
  });

  testWidgets('incoming call stays visible and answerable while locked', (tester) async {
    final env = await lockedEnv();
    await pumpApp(tester, env);
    await waitRegistered(tester, env);
    final c = containerOf(tester);
    expect(find.byKey(const Key('lock-screen')), findsOneWidget);

    env.engine.simulateIncomingCall(from: 'sip:3003@pbx.test', displayName: 'Carol');
    await settle(tester, env.engine);
    await tester.pump(const Duration(milliseconds: 500));
    expect(c.read(appLockProvider), isTrue);
    expect(find.byKey(const Key('answer-call')), findsOneWidget);
    expect(find.byKey(const Key('lock-screen')), findsNothing);

    await tester.tap(find.byKey(const Key('answer-call')));
    await settle(tester, env.engine);
    expect(c.read(callsProvider).focused?.isConfirmed, isTrue);
    expect(find.byKey(const Key('end-call')), findsOneWidget);

    await tester.tap(find.byKey(const Key('end-call')));
    await settle(tester, env.engine);
    await tester.pump(const Duration(milliseconds: 500));
    // Call over: the app is locked again.
    expect(find.byKey(const Key('lock-screen')), findsOneWidget);
  });

  testWidgets('lock screen offers answer / decline on wide layouts', (tester) async {
    final env = await lockedEnv();
    await pumpApp(tester, env, size: const Size(1200, 800));
    await waitRegistered(tester, env);
    env.engine.simulateIncomingCall(from: 'sip:3003@pbx.test', displayName: 'Carol');
    await settle(tester, env.engine);
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byKey(const Key('lock-screen')), findsOneWidget);
    expect(find.byKey(const Key('lock-calls')), findsOneWidget);
    final c = containerOf(tester);
    final cid = c.read(callsProvider).ringing.single.cid;
    await tester.tap(find.byKey(Key('lock-answer-$cid')));
    await settle(tester, env.engine);
    expect(c.read(callsProvider).focused?.isConfirmed, isTrue);
    expect(c.read(appLockProvider), isTrue);
  });

  testWidgets('settings: enable app lock with a PIN, then turn it off', (tester) async {
    final env = await TestEnv.create(profiles: [testProfile()]);
    await pumpApp(tester, env, size: const Size(1200, 900));
    final c = containerOf(tester);
    c.read(routerProvider).go('/settings/privacy');
    await settle(tester, env.engine);
    await tester.pump(const Duration(milliseconds: 500));
    await tester.tap(find.byKey(const Key('applock-switch')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('pin-new')), '1234');
    await tester.enterText(find.byKey(const Key('pin-confirm')), '9999');
    await tester.tap(find.byKey(const Key('pin-save')));
    await tester.pump();
    expect(find.text('PINs do not match'), findsOneWidget);
    await tester.enterText(find.byKey(const Key('pin-confirm')), '1234');
    await tester.tap(find.byKey(const Key('pin-save')));
    await tester.runAsync(() => Future<void>.delayed(const Duration(seconds: 2)));
    await tester.pumpAndSettle();
    expect(c.read(settingsProvider).appLock, isTrue);
    expect(env.secrets.data['applock.pin'], isNotNull);
    expect(c.read(appLockProvider), isFalse); // enabling does not lock immediately

    await tester.tap(find.byKey(const Key('applock-switch')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('pin-current')), '1234');
    await tester.tap(find.byKey(const Key('pin-verify')));
    await tester.runAsync(() => Future<void>.delayed(const Duration(seconds: 2)));
    await tester.pumpAndSettle();
    expect(c.read(settingsProvider).appLock, isFalse);
    expect(env.secrets.data['applock.pin'], isNull);
  });
}
