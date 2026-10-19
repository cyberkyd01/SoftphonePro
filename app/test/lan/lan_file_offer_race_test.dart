import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lan_link/lan_link.dart' as ll;
import 'package:softphonepro/l10n/app_localizations.dart';
import 'package:softphonepro/lan/lan_controller.dart';
import 'package:softphonepro/ui/pages/lan/lan_dialogs.dart';

import 'lan_harness.dart';
import 'lan_ui_test.dart' show waitW, drain, pumpNode;

void main() {
  setUpAll(() => HttpOverrides.global = null);

  testWidgets('first file offer right after pairing keeps its dialog (pairing dialog must not close it)', (tester) async {
    final a = await LanNode.create('Alpha');
    final b = await LanNode.create('Taker');
    final ca = await pumpNode(tester, a, route: '/keypad');
    final cb = await tester.runAsync(b.boot) as ProviderContainer;
    addTearDown(() => tester.runAsync(b.dispose));

    await tester.runAsync(() => b.lan(cb).connectManual('127.0.0.1:${a.port(ca)}'));
    final sb = b.lan(cb).pair(a.id(ca));
    await waitW(tester, () => find.byKey(const Key('pair-sas')).evaluate().isNotEmpty, what: 'sas');
    await waitW(tester, () => sb.sas != null, what: 'peer sas');
    await tester.tap(find.byKey(const Key('pair-confirm')));
    await tester.runAsync(sb.confirm);
    await waitW(tester, () => ca.read(lanControllerProvider).paired.isNotEmpty, what: 'paired');

    // The host offers a file the moment pairing completes.
    final src = File('${b.downloads.path}/first.txt')..writeAsStringSync('hello');
    final t = b.lan(cb).sendFile(a.id(ca), src.path)!;
    await waitW(tester, () => find.byKey(const Key('file-offer-dialog')).evaluate().isNotEmpty, what: 'offer dialog');

    // Past the pairing dialog's auto-close delay the offer dialog is still there.
    await tester.pump(const Duration(milliseconds: 950));
    expect(find.byKey(const Key('pairing-dialog')), findsNothing);
    expect(find.byKey(const Key('file-offer-dialog')), findsOneWidget);
    await tester.tap(find.byKey(const Key('file-accept')));
    await waitW(tester, () => t.isFinished, what: 'transfer finished');
    expect(t.state, ll.TransferState.completed);
    await tester.runAsync(() => b.lan(cb).unpair(a.id(ca)));
    await drain(tester);
  });

  group('FileOfferQueue', () {
    testWidgets('waits for the navigator, shows one at a time, re-shows a dismissed pending offer', (tester) async {
      final a = await LanNode.create('Alpha');
      final b = await LanNode.create('Taker');
      final ca = await tester.runAsync(a.boot) as ProviderContainer;
      final cb = await tester.runAsync(b.boot) as ProviderContainer;
      addTearDown(() => tester.runAsync(a.dispose));
      addTearDown(() => tester.runAsync(b.dispose));
      await tester.runAsync(() => pairNodes(a, ca, b, cb));

      final transfers = <ll.FileTransfer>[];
      final sub = a.lan(ca).incomingFileOffers.listen(transfers.add);
      addTearDown(sub.cancel);

      // Two offers arrive straight after pairing, before any UI exists.
      final f1 = File('${b.downloads.path}/one.txt')..writeAsStringSync('1');
      final f2 = File('${b.downloads.path}/two.txt')..writeAsStringSync('22');
      b.lan(cb).sendFile(a.id(ca), f1.path);
      b.lan(cb).sendFile(a.id(ca), f2.path);
      await waitW(tester, () => transfers.length >= 2, what: 'two offers');

      BuildContext? ctx;
      final q = FileOfferQueue(
        retry: const Duration(milliseconds: 50),
        withContext: (f) {
          if (ctx == null) return false;
          f(ctx!);
          return true;
        },
      );
      addTearDown(q.dispose);
      for (final t in transfers) {
        q.add(t);
      }
      await tester.pump(const Duration(milliseconds: 200));
      expect(q.showingId, isNull, reason: 'navigator not ready: offers wait');
      expect(q.queuedIds, hasLength(2));

      await tester.pumpWidget(UncontrolledProviderScope(
        container: ca,
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(builder: (c) {
            ctx = c;
            return const Scaffold();
          }),
        ),
      ));
      await waitW(tester, () => q.showingId != null, what: 'first dialog');
      expect(find.byKey(const Key('file-offer-dialog')), findsOneWidget);
      expect(q.showingId, transfers.first.id);
      expect(q.queuedIds, [transfers.last.id]);

      // Duplicate offer of the one on screen: no second dialog.
      q.add(transfers.first);
      expect(q.queuedIds, [transfers.last.id]);

      // Accept the first; the second dialog follows.
      await tester.tap(find.byKey(const Key('file-accept')));
      await tester.pump(const Duration(milliseconds: 300));
      await waitW(tester, () => q.showingId == transfers.last.id, what: 'second dialog');
      // Dismiss it without deciding (e.g. closed by something else): the
      // transfer is still offered, so a repeated offer shows it again.
      Navigator.of(ctx!).pop();
      await tester.pump(const Duration(milliseconds: 300));
      expect(q.showingId, isNull);
      expect(transfers.last.state, ll.TransferState.offered);
      q.add(transfers.last);
      await waitW(tester, () => q.showingId == transfers.last.id, what: 're-shown dialog');
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byKey(const Key('file-offer-dialog')), findsOneWidget);
      await tester.tap(find.byKey(const Key('file-decline')));
      await tester.pump(const Duration(milliseconds: 300));
      expect(q.showingId, isNull);
      await tester.runAsync(() => b.lan(cb).unpair(a.id(ca)));
      await drain(tester);
    });
  });
}
