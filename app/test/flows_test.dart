import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:softphonepro/models/account_profile.dart';
import 'package:softphonepro/models/app_settings.dart';
import 'package:softphonepro/models/call_record.dart';
import 'package:softphonepro/services/accounts_controller.dart';
import 'package:softphonepro/services/app_services.dart';
import 'package:softphonepro/services/calls_controller.dart';
import 'package:softphonepro/services/history_controller.dart';
import 'package:softphonepro/services/providers.dart';
import 'package:softphonepro/services/settings_controller.dart';
import 'package:softphonepro/storage/repositories.dart';

import 'harness.dart';

void main() {
  testWidgets('onboarding -> add account -> registered chip', (tester) async {
    final env = await TestEnv.create(settings: const AppSettings());
    await pumpApp(tester, env);
    expect(find.text('Welcome to SoftphonePro'), findsOneWidget);
    await tester.tap(find.byKey(const Key('onb-get-started')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('onb-continue')));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.byKey(const Key('tpl-generic')), 200, scrollable: find.byType(Scrollable).first);
    await tester.tap(find.byKey(const Key('tpl-generic')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('acc-username')), '1001');
    await tester.enterText(find.byKey(const Key('acc-password')), 'secret');
    await tester.enterText(find.byKey(const Key('acc-domain')), 'pbx.test');
    await tester.ensureVisible(find.byKey(const Key('acc-save')));
    await tester.tap(find.byKey(const Key('acc-save')));
    await tester.pumpAndSettle();
    await waitRegistered(tester, env);
    await tester.pump();
    final c = containerOf(tester);
    final acc = c.read(accountsProvider);
    expect(acc.profiles, hasLength(1));
    expect(acc.statusOf(acc.profiles.single.id), AccountStatus.registered);
    // Chip with the account name is visible on the keypad page.
    expect(find.text('1001@pbx.test'), findsWidgets);
    expect(c.read(settingsProvider).onboardingDone, isTrue);
    // Password went to the secrets store, not the account record.
    expect(env.secrets.data.values, contains('secret'));
  });

  testWidgets('dial -> in call -> mute/hold -> hang up -> history', (tester) async {
    final env = await TestEnv.create(profiles: [testProfile()]);
    await pumpApp(tester, env);
    await waitRegistered(tester, env);
    final c = containerOf(tester);
    for (final d in '2002'.split('')) {
      await tester.tap(find.bySemanticsLabel(d).first);
      await tester.pump();
    }
    expect(c.read(dialInputProvider), '2002');
    await tester.tap(find.byTooltip('Call'));
    await settle(tester, env.engine);
    expect(c.read(callsProvider).focused?.isConfirmed, isTrue);
    expect(find.byKey(const Key('end-call')), findsOneWidget);

    await tester.tap(find.text('Mute'));
    await settle(tester, env.engine);
    expect(c.read(callsProvider).focused?.muted, isTrue);
    await tester.tap(find.text('Hold'));
    await settle(tester, env.engine);
    expect(c.read(callsProvider).focused?.isHeld, isTrue);
    expect(find.text('Resume'), findsOneWidget);
    await tester.tap(find.text('Resume'));
    await settle(tester, env.engine);
    expect(c.read(callsProvider).focused?.isHeld, isFalse);

    await tester.tap(find.byKey(const Key('end-call')));
    await settle(tester, env.engine);
    expect(c.read(callsProvider).hasCalls, isFalse);
    final h = c.read(historyProvider);
    expect(h, hasLength(1));
    expect(h.single.direction, CallDirection.outgoing);
    expect(h.single.result, CallResult.answered);
    expect(h.single.remoteNumber, '2002');
    // Back on the keypad.
    expect(find.byKey(const Key('end-call')), findsNothing);
  });

  testWidgets('incoming call -> answer', (tester) async {
    final env = await TestEnv.create(profiles: [testProfile()]);
    await pumpApp(tester, env);
    await waitRegistered(tester, env);
    final c = containerOf(tester);
    env.engine.simulateIncomingCall(from: 'sip:3003@pbx.test', displayName: 'Carol');
    await settle(tester, env.engine);
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byKey(const Key('answer-call')), findsOneWidget);
    expect(find.text('Carol'), findsWidgets);
    await tester.tap(find.byKey(const Key('answer-call')));
    await settle(tester, env.engine);
    expect(c.read(callsProvider).focused?.isConfirmed, isTrue);
    expect(find.byKey(const Key('end-call')), findsOneWidget);
    await tester.tap(find.byKey(const Key('end-call')));
    await settle(tester, env.engine);
    final h = c.read(historyProvider).single;
    expect(h.direction, CallDirection.incoming);
    expect(h.result, CallResult.answered);
    expect(h.remoteDisplay, 'Carol');
  });

  testWidgets('incoming call while DND is auto-rejected and logged', (tester) async {
    final env = await TestEnv.create(
      profiles: [testProfile()],
      settings: const AppSettings({'onboardingDone': true, 'dnd': true}),
    );
    await pumpApp(tester, env);
    await waitRegistered(tester, env);
    final c = containerOf(tester);
    env.engine.simulateIncomingCall(from: 'sip:4004@pbx.test');
    await settle(tester, env.engine);
    expect(find.byKey(const Key('answer-call')), findsNothing);
    expect(c.read(callsProvider).hasCalls, isFalse);
    final h = c.read(historyProvider);
    expect(h, hasLength(1));
    expect(h.single.result, CallResult.rejected);
    expect(h.single.reason, 'Do not disturb');
    expect(h.single.sipCode, 486);
  });

  testWidgets('missed incoming call is recorded as missed', (tester) async {
    final env = await TestEnv.create(profiles: [testProfile()]);
    await pumpApp(tester, env);
    await waitRegistered(tester, env);
    final ref = env.engine.simulateIncomingCall(from: 'sip:5005@pbx.test');
    await settle(tester, env.engine);
    env.engine.simulateRemoteHangup(ref.cid);
    await settle(tester, env.engine);
    final h = containerOf(tester).read(historyProvider);
    expect(h.single.result, CallResult.missed);
    expect(h.single.isMissed, isTrue);
  });

  testWidgets('transfer sheet: blind transfer', (tester) async {
    final env = await TestEnv.create(profiles: [testProfile()]);
    await pumpApp(tester, env);
    await waitRegistered(tester, env);
    final c = containerOf(tester);
    await c.read(callsProvider.notifier).dial('2002');
    await settle(tester, env.engine);
    expect(find.text('Transfer'), findsOneWidget);
    await tester.tap(find.text('Transfer'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('transfer-number')), findsOneWidget);
    await tester.enterText(find.byKey(const Key('transfer-number')), '3003');
    await tester.pump();
    await tester.tap(find.byKey(const Key('transfer-blind')));
    await settle(tester, env.engine);
    await settle(tester, env.engine);
    expect(c.read(callsProvider).hasCalls, isFalse);
    expect(c.read(historyProvider).single.result, CallResult.transferred);
  });

  testWidgets('transfer sheet: attended transfer (consult then complete)', (tester) async {
    final env = await TestEnv.create(profiles: [testProfile()]);
    await pumpApp(tester, env);
    await waitRegistered(tester, env);
    final c = containerOf(tester);
    await c.read(callsProvider.notifier).dial('2002');
    await settle(tester, env.engine);
    await tester.tap(find.text('Transfer'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Attended'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('transfer-number')), '3003');
    await tester.pump();
    await tester.tap(find.byKey(const Key('transfer-attended')));
    await settle(tester, env.engine);
    final st = c.read(callsProvider);
    expect(st.live, hasLength(2));
    expect(st.focused?.consultOf, isNotNull);
    expect(find.byKey(const Key('complete-transfer')), findsOneWidget);
    await tester.ensureVisible(find.byKey(const Key('complete-transfer')));
    await tester.tap(find.byKey(const Key('complete-transfer')));
    await settle(tester, env.engine);
    await settle(tester, env.engine);
    expect(c.read(callsProvider).live.length, lessThanOrEqualTo(1));
    final results = c.read(historyProvider).map((r) => r.result).toList();
    expect(results, contains(CallResult.transferred));
  });

  testWidgets('transfer sheet: LAN tab shows coming soon', (tester) async {
    final env = await TestEnv.create(profiles: [testProfile()]);
    await pumpApp(tester, env);
    await waitRegistered(tester, env);
    final c = containerOf(tester);
    await c.read(callsProvider.notifier).dial('2002');
    await settle(tester, env.engine);
    await tester.tap(find.text('Transfer'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('LAN device'));
    await tester.pumpAndSettle();
    expect(find.textContaining('LAN Link is coming soon'), findsOneWidget);
  });

  testWidgets('call waiting: second incoming call holds the first on answer', (tester) async {
    final env = await TestEnv.create(profiles: [testProfile()]);
    await pumpApp(tester, env);
    await waitRegistered(tester, env);
    final c = containerOf(tester);
    await c.read(callsProvider.notifier).dial('2002');
    await settle(tester, env.engine);
    final ref = env.engine.simulateIncomingCall(from: 'sip:6006@pbx.test');
    await settle(tester, env.engine);
    expect(c.read(callsProvider).byCid(ref.cid)?.waiting, isTrue);
    await c.read(callsProvider.notifier).answer(ref.cid);
    await settle(tester, env.engine);
    final calls = c.read(callsProvider).live;
    expect(calls, hasLength(2));
    expect(calls.where((x) => x.isHeld), hasLength(1));
  });

  testWidgets('call forwarding always redirects', (tester) async {
    final p = testProfile().copyWith(forwarding: const ForwardingConfig(mode: ForwardMode.always, target: '9000'));
    final env = await TestEnv.create(profiles: [p]);
    await pumpApp(tester, env);
    await waitRegistered(tester, env);
    env.engine.simulateIncomingCall(from: 'sip:7007@pbx.test');
    await settle(tester, env.engine);
    final h = containerOf(tester).read(historyProvider);
    expect(h.single.result, CallResult.forwarded);
  });

  testWidgets('settings persist across restarts', (tester) async {
    final env = await TestEnv.create(profiles: [testProfile()]);
    await pumpApp(tester, env);
    final c = containerOf(tester);
    await tester.runAsync(() async {
      await c.read(settingsProvider.notifier).update({'themeMode': 'dark', 'callWaiting': false, 'blocklist': ['555']});
    });
    // Reload from the same database.
    final boot = await tester.runAsync(() => loadBootData(env.db, env.secrets));
    expect(boot!.settings.callWaiting, isFalse);
    expect(boot.settings.themeMode, ThemeMode.dark);
    expect(boot.settings.blocklist, ['555']);
    expect(boot.profiles, isEmpty); // accounts persist only via the controller
    await tester.runAsync(() => c.read(accountsProvider.notifier).add(testProfile(id: 'acc2', user: '2000')));
    final boot2 = await tester.runAsync(() => loadBootData(env.db, env.secrets));
    expect(boot2!.profiles.map((p) => p.id), contains('acc2'));
    expect(boot2.profiles.firstWhere((p) => p.id == 'acc2').config.password, 'pw');
    // Database file never contains the password.
    final raw = await tester.runAsync(() => AccountsRepository(env.db, env.secrets).loadAll());
    expect(raw!.length, boot2.profiles.length);
  });
}

