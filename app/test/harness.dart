import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:softphonepro/automation/automation_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:softphonepro/app.dart';
import 'package:softphonepro/models/account_profile.dart';
import 'package:softphonepro/models/app_settings.dart';
import 'package:softphonepro/models/contact.dart';
import 'package:softphonepro/services/accounts_controller.dart';
import 'package:softphonepro/services/providers.dart';
import 'package:softphonepro/storage/app_database.dart';
import 'package:softphonepro/storage/secrets_store.dart';
import 'package:spcore_dart/spcore_dart.dart';

AccountProfile testProfile({String id = 'acc1', String user = '1001', String domain = 'pbx.test', String vm = '*97'}) => AccountProfile(
  id: id,
  isDefault: true,
  voicemailNumber: vm,
  config: AccountConfig(uid: id, username: user, password: 'pw', domain: domain),
);

class TestEnv {
  TestEnv._(this.engine, this.db, this.secrets, this.boot, this.tempDir);
  final FakeSipEngine engine;
  final AppDatabase db;
  final MemorySecretsStore secrets;
  BootData boot;
  final Directory tempDir;

  static Future<TestEnv> create({
    List<AccountProfile> profiles = const [],
    AppSettings settings = const AppSettings({'onboardingDone': true}),
    List<Contact> contacts = const [],
    FakeSipEngine? engine,
  }) async {
    final db = await AppDatabase.memory();
    final secrets = MemorySecretsStore();
    final tmp = Directory.systemTemp.createTempSync('spro_test');
    return TestEnv._(
      engine ?? FakeSipEngine(timings: FakeTimings.instant),
      db,
      secrets,
      BootData(settings: settings, profiles: profiles, contacts: contacts),
      tmp,
    );
  }

  List<Override> get overrides => overridesWith();

  List<Override> overridesWith({bool automationSupported = true}) => [
    appDatabaseProvider.overrideWithValue(db),
    secretsStoreProvider.overrideWithValue(secrets),
    bootDataProvider.overrideWithValue(boot),
    engineFactoryProvider.overrideWithValue(({required bool simulator}) async => EngineHandle(engine, demo: false)),
    connectivityStreamProvider.overrideWithValue(const Stream.empty()),
    recordingsDirProvider.overrideWithValue(() async => tempDir.path),
    // Widget tests report Android as the platform; the API itself is desktop-only.
    automationSupportedProvider.overrideWithValue(automationSupported),
  ];

  Widget app() => ProviderScope(overrides: overrides, child: const SoftphoneApp());
}

ProviderContainer containerOf(WidgetTester tester) => ProviderScope.containerOf(tester.element(find.byType(SoftphoneApp)));

/// Lets engine events, timers and futures flow.
Future<void> settle(WidgetTester tester, FakeSipEngine engine) async {
  for (var i = 0; i < 4; i++) {
    await tester.runAsync(() async {
      await engine.settle();
      await Future<void>.delayed(const Duration(milliseconds: 10));
    });
    await tester.pump(const Duration(milliseconds: 50));
  }
}

Future<void> pumpApp(WidgetTester tester, TestEnv env, {Size size = const Size(420, 900)}) async {
  tester.view.physicalSize = size * 2;
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(env.app());
  await settle(tester, env.engine);
}

Future<void> waitRegistered(WidgetTester tester, TestEnv env, [String id = 'acc1']) async {
  for (var i = 0; i < 10; i++) {
    await settle(tester, env.engine);
    final c = containerOf(tester);
    if (c.read(accountsProvider).statusOf(id) == AccountStatus.registered) return;
  }
}
