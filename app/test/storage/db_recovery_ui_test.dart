import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sembast/sembast_memory.dart';
import 'package:softphonepro/services/providers.dart';
import 'package:softphonepro/storage/app_database.dart';
import 'package:softphonepro/ui/pages/db_recovery.dart';
import 'package:softphonepro/ui/settings/encryption_settings.dart';
import 'package:softphonepro/l10n/app_localizations.dart';

void main() {
  testWidgets('recovery screen explains a missing key and offers retry / start fresh', (tester) async {
    var retry = 0, fresh = 0;
    await tester.pumpWidget(DbRecoveryApp(
      problem: DbRecoveryNeeded(DbProblem.missingKey, '/x/softphonepro.db'),
      onRetry: () => retry++,
      onStartFresh: () => fresh++,
    ));
    expect(find.text('Your data is locked'), findsOneWidget);
    await tester.tap(find.byKey(const Key('db-retry')));
    await tester.tap(find.byKey(const Key('db-fresh')));
    expect((retry, fresh), (1, 1));
  });

  testWidgets('the encryption switch requests a change for the next start', (tester) async {
    final dir = Directory.systemTemp.createTempSync('encui');
    addTearDown(() => dir.deleteSync(recursive: true));
    final mem = await databaseFactoryMemory.openDatabase('encui-${DateTime.now().microsecondsSinceEpoch}');
    final db = AppDatabase(mem, directory: dir.path);
    await tester.pumpWidget(ProviderScope(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
      child: const MaterialApp(localizationsDelegates: AppLocalizations.localizationsDelegates, supportedLocales: AppLocalizations.supportedLocales, home: Scaffold(body: SingleChildScrollView(child: EncryptionSettingsGroup()))),
    ));
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
    await tester.pump();
    await tester.tap(find.byKey(const Key('encrypt-data')));
    for (var i = 0; i < 6; i++) {
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
      await tester.pump();
    }
    expect(await tester.runAsync(() => AppDatabase.pendingMode(dir.path)), isTrue);
  });
}
