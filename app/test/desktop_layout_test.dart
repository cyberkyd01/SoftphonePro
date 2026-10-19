import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:softphonepro/models/app_settings.dart';
import 'package:softphonepro/models/call_record.dart';
import 'package:softphonepro/models/contact.dart';
import 'package:softphonepro/services/calls_controller.dart';
import 'package:softphonepro/services/history_controller.dart';
import 'package:softphonepro/services/settings_controller.dart';
import 'package:softphonepro/ui/shell/app_shell.dart';

import 'harness.dart';

Future<void> loadInter() async {
  final loader = FontLoader('Inter');
  for (final f in ['Regular', 'Medium', 'SemiBold', 'Bold']) {
    final bytes = File('assets/fonts/Inter-$f.ttf').readAsBytesSync();
    loader.addFont(Future.value(ByteData.view(bytes.buffer)));
  }
  await loader.load();
}

void main() {
  setUpAll(loadInter);

  Future<TestEnv> env() => TestEnv.create(
    profiles: [testProfile(), testProfile(id: 'acc2', user: '2000', domain: 'sip.example.org').copyWith(isDefault: false, label: 'Home line')],
    settings: const AppSettings({'onboardingDone': true}),
    contacts: [
      const Contact(id: 'c1', name: 'Alice Johnson', company: 'Acme', numbers: [ContactNumber(label: 'work', value: '2002')], favorite: true),
      const Contact(id: 'c2', name: 'Bob Marley', numbers: [ContactNumber(value: '2003')], blf: true),
    ],
  );

  testWidgets('desktop layout 1280x800: rail, top bar, keypad, calls panel', (tester) async {
    final e = await env();
    await pumpApp(tester, e, size: const Size(1280, 800));
    await waitRegistered(tester, e);
    await waitRegistered(tester, e, 'acc2');
    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
    expect(find.text('Search or dial'), findsOneWidget);
    await expectLater(find.byType(AppShell), matchesGoldenFile('goldens/desktop_keypad.png'));

    final c = containerOf(tester);
    await c.read(callsProvider.notifier).dial('2002');
    await settle(tester, e.engine);
    expect(find.text('Active calls'), findsOneWidget);
    expect(find.text('Alice Johnson'), findsWidgets);
    await expectLater(find.byType(AppShell), matchesGoldenFile('goldens/desktop_in_call.png'));
    await c.read(callsProvider.notifier).hangupAll();
    await settle(tester, e.engine);
    expect(find.text('Active calls'), findsNothing);
  });

  testWidgets('desktop incoming banner answers via button', (tester) async {
    final e = await env();
    await pumpApp(tester, e, size: const Size(1280, 800));
    await waitRegistered(tester, e);
    final ref = e.engine.simulateIncomingCall(from: 'sip:2003@pbx.test');
    await settle(tester, e.engine);
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Incoming call'), findsOneWidget);
    await expectLater(find.byType(AppShell), matchesGoldenFile('goldens/desktop_incoming.png'));
    await tester.tap(find.byKey(Key('banner-answer-${ref.cid}')));
    await settle(tester, e.engine);
    expect(containerOf(tester).read(callsProvider).focused?.isConfirmed, isTrue);
  });

  testWidgets('desktop settings is two-pane and changes persist in state', (tester) async {
    final e = await env();
    await pumpApp(tester, e, size: const Size(1280, 800));
    await tester.tap(find.text('Settings').last);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('settings-audio')), findsOneWidget);
    await tester.tap(find.byKey(const Key('settings-appearance')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();
    expect(containerOf(tester).read(settingsProvider).themeMode, ThemeMode.dark);
    await expectLater(find.byType(AppShell), matchesGoldenFile('goldens/desktop_settings_dark.png'));
  });

  testWidgets('desktop recents, contacts and messages master-detail', (tester) async {
    final e = await env();
    await pumpApp(tester, e, size: const Size(1280, 800));
    final c = containerOf(tester);
    await tester.runAsync(() => c.read(historyProvider.notifier).add(CallRecord(
      id: 'r1', accountId: 'acc1', direction: CallDirection.incoming, remoteUri: 'sip:2002@pbx.test', remoteNumber: '2002', remoteDisplay: '',
      start: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 10, 2), durationMs: 83000, result: CallResult.answered,
      quality: const QualitySummary(mosAvg: 4.3, mosMin: 4.1, jitterMax: 6, lossPct: 0.2))));
    await tester.runAsync(() => c.read(historyProvider.notifier).add(CallRecord(
      id: 'r2', accountId: 'acc1', direction: CallDirection.incoming, remoteUri: 'sip:9000@pbx.test', remoteNumber: '9000', remoteDisplay: 'Support',
      start: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 10, 57), result: CallResult.missed)));
    await tester.tap(find.text('Recents').last);
    await tester.pumpAndSettle();
    expect(find.text('Alice Johnson'), findsOneWidget);
    expect(find.text('Support'), findsOneWidget);
    await tester.tap(find.text('Alice Johnson'));
    await tester.pumpAndSettle();
    expect(find.text('CALL QUALITY'), findsOneWidget);
    await expectLater(find.byType(AppShell), matchesGoldenFile('goldens/desktop_recents.png'));
    await tester.tap(find.text('Contacts').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Bob Marley'));
    await tester.pumpAndSettle();
    expect(find.text('Shown on the BLF board'), findsOneWidget);
    await tester.tap(find.text('Presence').last);
    await tester.pumpAndSettle();
    expect(find.text('Bob Marley'), findsOneWidget);
    await tester.tap(find.text('LAN').last);
    await tester.pumpAndSettle();
    expect(find.text('LAN Link is off'), findsOneWidget);
  });
}
