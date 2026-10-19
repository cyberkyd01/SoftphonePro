import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:softphonepro/app.dart';
import 'package:softphonepro/diagnostics/network_wizard.dart';
import 'package:softphonepro/models/call_record.dart';
import 'package:softphonepro/platform/platform_services.dart';
import 'package:softphonepro/services/call_journal.dart';
import 'package:softphonepro/services/calls_controller.dart';
import 'package:softphonepro/services/history_controller.dart';
import 'package:softphonepro/services/providers.dart';
import 'package:softphonepro/storage/repositories.dart';
import 'package:softphonepro/ui/router.dart';
import 'package:softphonepro/ui/settings/sections.dart';
import 'package:softphonepro/ui/widgets/basic_widgets.dart';
import 'package:softphonepro/ui/widgets/dial_pad.dart';
import 'package:spcore_dart/spcore_dart.dart';

import '../harness.dart';

class TransferEng extends FakeSipEngine {
  TransferEng()
    : super(
        timings: const FakeTimings(
          register: Duration.zero,
          ring: Duration.zero,
          answer: Duration.zero,
          transfer: Duration(hours: 1),
          im: Duration.zero,
          diag: Duration.zero,
        ),
      );
  final List<String> transfers = [];
  @override
  Future<void> transfer(int cid, String target) {
    transfers.add(target);
    return super.transfer(cid, target);
  }
}

class NotifPlatform extends NoopPlatformServices {
  final List<String> shown = [];
  @override
  Future<void> showIncomingCallNotification({required String callKey, required String title, required String body, String? accountName}) async {
    shown.add(callKey);
  }
}

void main() {
  group('blind transfer without REFER response', () {
    testWidgets('after 10 s: "Transfer not confirmed by the server" with keep / retry', (tester) async {
      final eng = TransferEng();
      final env = await TestEnv.create(profiles: [testProfile()], engine: eng);
      await pumpApp(tester, env);
      await waitRegistered(tester, env);
      final calls = containerOf(tester).read(callsProvider.notifier);
      final cid = (await calls.dial('2002'))!;
      await settle(tester, env.engine);
      containerOf(tester).read(routerProvider).push('/call');
      await tester.pumpAndSettle();
      // No settle() here: it would fast-forward the fake's (one hour) NOTIFY.
      expect(await calls.transferBlind(cid, '3003'), isTrue);
      await tester.pump(const Duration(milliseconds: 10));
      expect(find.byKey(const Key('transfer-stalled')), findsNothing);
      expect(find.text('Transferring...'), findsOneWidget);

      await tester.pump(const Duration(seconds: 9));
      expect(find.byKey(const Key('transfer-stalled')), findsNothing);
      await tester.pump(const Duration(seconds: 2));
      expect(find.text('Transfer not confirmed by the server'), findsOneWidget);
      expect(find.text('Transferring...'), findsNothing);

      // Retry sends the REFER again and re-arms the timer.
      await tester.tap(find.byKey(const Key('transfer-retry')));
      await tester.pump(const Duration(milliseconds: 10));
      await tester.pump(const Duration(milliseconds: 10));
      expect(eng.transfers, ['3003', '3003']);
      expect(find.byKey(const Key('transfer-stalled')), findsNothing);
      await tester.pump(const Duration(seconds: 11));
      expect(find.byKey(const Key('transfer-stalled')), findsOneWidget);

      // Keep the call: banner gone, call still up and not "transferring".
      await tester.tap(find.byKey(const Key('transfer-keep')));
      await tester.pump(const Duration(milliseconds: 10));
      await tester.pump(const Duration(milliseconds: 10));
      expect(find.byKey(const Key('transfer-stalled')), findsNothing);
      final c = containerOf(tester).read(callsProvider).focused!;
      expect(c.isConfirmed, isTrue);
      expect(c.transferPending, isFalse);
      expect(find.text('Transferring...'), findsNothing);
      await tester.pump(const Duration(hours: 2)); // let the fake's late NOTIFYs drain
    });

    testWidgets('a server answer within 10 s cancels the timer', (tester) async {
      final eng = FakeSipEngine(timings: FakeTimings.instant);
      final env = await TestEnv.create(profiles: [testProfile()], engine: eng);
      await pumpApp(tester, env);
      await waitRegistered(tester, env);
      final calls = containerOf(tester).read(callsProvider.notifier);
      final cid = (await calls.dial('2002'))!;
      await settle(tester, env.engine);
      await calls.transferBlind(cid, '3003');
      await settle(tester, env.engine);
      await tester.pump(const Duration(seconds: 12));
      expect(find.byKey(const Key('transfer-stalled')), findsNothing);
    });
  });

  testWidgets('in-call keypad: the bottom row is fully visible above the End button', (tester) async {
    final env = await TestEnv.create(profiles: [testProfile()]);
    await pumpApp(tester, env, size: const Size(411, 700));
    await waitRegistered(tester, env);
    await containerOf(tester).read(callsProvider.notifier).dial('2002');
    await settle(tester, env.engine);
    containerOf(tester).read(routerProvider).push('/call');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Keypad'));
    await tester.pumpAndSettle();
    final end = tester.getRect(find.byKey(const Key('end-call')));
    for (final d in ['*', '0', '#']) {
      final r = tester.getRect(find.byWidgetPredicate((w) => w is DialKey && w.digit == d));
      expect(r.bottom, lessThanOrEqualTo(end.top + 0.5), reason: '"$d" key $r must end above the End button $end');
      expect(r.top, greaterThanOrEqualTo(0));
    }
    // The keypad can be closed again.
    await tester.tap(find.byKey(const Key('keypad-hide')));
    await tester.pumpAndSettle();
    expect(find.text('Mute'), findsOneWidget);
  });

  testWidgets('transfer sheet: the LAN segment label stays on one line at 411 dp', (tester) async {
    final env = await TestEnv.create(profiles: [testProfile()]);
    await pumpApp(tester, env, size: const Size(411, 800));
    await waitRegistered(tester, env);
    await containerOf(tester).read(callsProvider.notifier).dial('2002');
    await settle(tester, env.engine);
    await tester.tap(find.text('Transfer'));
    await tester.pumpAndSettle();
    final lan = tester.getSize(find.text('LAN'));
    // One line of the 14 px test font (the old "LAN device" label wrapped to two).
    expect(lan.height, lessThan(24), reason: 'LAN label height $lan');
    expect(find.text('LAN device'), findsNothing);
    expect(find.byTooltip('LAN device'), findsOneWidget);
  });

  test('network wizard maps the raw "ErrUnknown" to plain language', () {
    expect(friendlyNatDescription('ErrUnknown'), isNot(contains('ErrUnknown')));
    expect(friendlyNatDescription('ErrUnknown'), contains('STUN server did not answer'));
    expect(friendlyNatDescription('Unknown'), 'The NAT type could not be determined.');
    expect(friendlyNatDescription('Full Cone'), 'Full Cone');
    expect(friendlyNatDescription(''), '');
  });

  testWidgets('dial rules page uses the same header as the other settings pages', (tester) async {
    final env = await TestEnv.create(profiles: [testProfile()]);
    await pumpApp(tester, env);
    rootNavigatorKey.currentState!.push(MaterialPageRoute<void>(builder: (_) => const DialRulesEditor()));
    await tester.pumpAndSettle();
    expect(find.byType(AppBar), findsNothing);
    final header = find.widgetWithText(PageHeader, 'Dial rules');
    expect(header, findsOneWidget);
    expect(find.byTooltip('Add rule'), findsOneWidget);
    expect(find.byTooltip('Back'), findsWidgets);
  });

  group('incoming call while the app is in the foreground (Android)', () {
    Future<NotifPlatform> run(WidgetTester tester, {required bool inAppUiVisible}) async {
      final platform = NotifPlatform();
      final env = await TestEnv.create(profiles: [testProfile()]);
      tester.view.physicalSize = const Size(420, 900) * 2;
      tester.view.devicePixelRatio = 2;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            ...env.overrides,
            platformServicesProvider.overrideWithValue(platform),
            incomingUiVisibleProvider.overrideWithValue(() => inAppUiVisible),
          ],
          child: const SoftphoneApp(),
        ),
      );
      await settle(tester, env.engine);
      await waitRegistered(tester, env);
      env.engine.simulateIncomingCall(from: 'sip:3003@pbx.test');
      await settle(tester, env.engine);
      return platform;
    }

    testWidgets('foreground: only the in-app page, no heads-up notification', (tester) async {
      final p = await run(tester, inAppUiVisible: true);
      expect(find.byKey(const Key('answer-call')), findsOneWidget);
      expect(p.shown, isEmpty);
    });

    testWidgets('backgrounded or locked: the notification is posted', (tester) async {
      final p = await run(tester, inAppUiVisible: false);
      expect(p.shown, hasLength(1));
    });
  });

  group('active calls journal', () {
    testWidgets('a call interrupted by a force-stop becomes an "interrupted" history entry on the next start', (tester) async {
      final env = await TestEnv.create(profiles: [testProfile()]);
      final start = DateTime.now().subtract(const Duration(minutes: 5));
      await tester.runAsync(() async {
        await CallJournal(JsonStore(env.db.db, 'call_journal')).put(
          JournalEntry(
            key: 'old-1',
            session: 'previous-run',
            cid: 3,
            accountId: 'acc1',
            direction: CallDirection.outgoing,
            remoteUri: 'sip:2002@pbx.test',
            remoteNumber: '2002',
            remoteDisplay: 'Eve',
            start: start,
            answeredAt: start.add(const Duration(seconds: 4)),
            lastSeen: start.add(const Duration(seconds: 94)),
            callId: 'cid-xyz',
          ),
        );
      });
      await pumpApp(tester, env);
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 100)));
      await settle(tester, env.engine);
      await settle(tester, env.engine);
      final h = containerOf(tester).read(historyProvider);
      expect(h, hasLength(1));
      expect(h.single.result, CallResult.interrupted);
      expect(h.single.result.label, 'Interrupted');
      expect(h.single.remoteNumber, '2002');
      expect(h.single.remoteDisplay, 'Eve');
      expect(h.single.durationMs, 90000);
      expect(h.single.callId, 'cid-xyz');
      // The journal is empty afterwards.
      final left = await tester.runAsync(() => CallJournal(JsonStore(env.db.db, 'call_journal')).all());
      expect(left, isEmpty);
    });

    testWidgets('calls are journaled while active and removed when they end normally', (tester) async {
      final env = await TestEnv.create(profiles: [testProfile()]);
      await pumpApp(tester, env);
      await waitRegistered(tester, env);
      final c = containerOf(tester);
      final cid = (await c.read(callsProvider.notifier).dial('2002'))!;
      await settle(tester, env.engine);
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
      final journal = c.read(callJournalProvider);
      var entries = await tester.runAsync(journal.all);
      expect(entries, hasLength(1));
      expect(entries!.single.remoteNumber, '2002');
      expect(entries.single.session, kJournalSession);
      expect(entries.single.answeredAt, isNotNull);
      await c.read(callsProvider.notifier).hangup(cid);
      await settle(tester, env.engine);
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
      entries = await tester.runAsync(journal.all);
      expect(entries, isEmpty);
      // Entries of the current session are never recovered.
      expect(await tester.runAsync(() => journal.recoverInto(c.read(historyProvider.notifier))), 0);
      expect(c.read(historyProvider).where((r) => r.result == CallResult.interrupted), isEmpty);
    });
  });
}
