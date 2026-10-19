import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:softphonepro/models/app_settings.dart';
import 'package:softphonepro/models/contact.dart';
import 'package:softphonepro/services/accounts_controller.dart';
import 'package:softphonepro/services/contacts_controller.dart';
import 'package:softphonepro/services/settings_controller.dart';
import 'package:softphonepro/ui/router.dart';

import '../harness.dart';

Future<TestEnv> boot(WidgetTester tester, {List<Contact> contacts = const []}) async {
  final env = await TestEnv.create(profiles: [testProfile()], contacts: contacts);
  tester.view.physicalSize = const Size(1000, 4000) * 2;
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(env.app());
  await settle(tester, env.engine);
  return env;
}

Future<void> pick<T>(WidgetTester tester, Key key, String label) async {
  await tester.tap(find.descendant(of: find.byKey(key), matching: find.byType(DropdownButton<T>)));
  await tester.pumpAndSettle();
  await tester.tap(find.text(label).last);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Settings > Recording: format, rules, notices, transfers, auto-delete', (tester) async {
    final env = await boot(tester);
    final c = containerOf(tester);
    c.read(routerProvider).go('/settings/recording');
    await tester.pumpAndSettle();
    expect(find.text('Standard (WAV)'), findsOneWidget);
    expect(find.textContaining('separate channels (WAV)'), findsOneWidget);
    expect(find.text('Compressed (Opus)'), findsOneWidget);
    expect(c.read(settingsProvider).recordFormat, 'wav');

    await tester.tap(find.byKey(const Key('rec-format-wavStereo')));
    await tester.pumpAndSettle();
    expect(c.read(settingsProvider).recordFormat, 'wavStereo');
    await tester.tap(find.byKey(const Key('rec-format-opus')));
    await tester.pumpAndSettle();
    expect(c.read(settingsProvider).recordFormat, 'opus');
    expect(find.textContaining('cannot open it'), findsOneWidget, reason: 'Opus caveat is explained');

    await pick<String>(tester, const Key('rec-rule'), 'Incoming calls only');
    expect(c.read(settingsProvider).recordRule, 'incoming');
    await pick<String>(tester, const Key('rec-rule'), 'All calls');
    expect(c.read(settingsProvider).recordRule, 'all');
    expect(c.read(settingsProvider).autoRecord, isTrue, reason: 'legacy flag kept in sync');

    await pick<String>(tester, const Key('rec-acc-acc1'), 'Never record');
    expect(c.read(accountsProvider).byId('acc1')!.autoRecord, 'never');
    await pick<String>(tester, const Key('rec-acc-acc1'), 'Record outgoing calls only');
    expect(c.read(accountsProvider).byId('acc1')!.autoRecord, 'outgoing');

    await tester.tap(find.byKey(const Key('rec-notice')));
    await tester.pumpAndSettle();
    expect(c.read(settingsProvider).recordNotice, isTrue);
    await tester.tap(find.byKey(const Key('rec-beep')));
    await tester.pumpAndSettle();
    expect(c.read(settingsProvider).recordBeep, isTrue);
    expect(c.read(settingsProvider).recordContinueTransfers, isTrue);
    await tester.tap(find.byKey(const Key('rec-continue')));
    await tester.pumpAndSettle();
    expect(c.read(settingsProvider).recordContinueTransfers, isFalse);

    await pick<int>(tester, const Key('rec-auto-delete'), 'After 30 days');
    expect(c.read(settingsProvider).recordAutoDeleteDays, 30);

    expect(find.byKey(const Key('rec-open-manager')), findsOneWidget);
    await tester.tap(find.byKey(const Key('rec-open-manager')));
    await tester.pumpAndSettle();
    expect(find.text('No recordings yet'), findsOneWidget);
    expect(env.engine, isNotNull);
  });

  testWidgets('contact editor: "Always record calls with this contact"', (tester) async {
    await boot(tester, contacts: [const Contact(id: 'c1', name: 'Dana', numbers: [ContactNumber(label: 'mobile', value: '3003')])]);
    final c = containerOf(tester);
    c.read(routerProvider).push('/contacts/c1/edit');
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('contact-auto-record')));
    await tester.tap(find.byKey(const Key('contact-auto-record')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save').first);
    await tester.pumpAndSettle();
    expect(c.read(contactsProvider).single.autoRecord, isTrue);
    expect(Contact.fromJson(c.read(contactsProvider).single.toJson()).autoRecord, isTrue);
  });

  test('settings: new recording fields default sensibly', () {
    const s = AppSettings();
    expect(s.recordFormat, 'wav');
    expect(s.recordRule, 'off');
    expect(s.recordNotice, isFalse);
    expect(s.recordAutoDeleteDays, 0);
    expect(s.recordContinueTransfers, isTrue);
    expect(Contact.fromJson(const Contact(id: 'x', name: 'X').toJson()).autoRecord, isFalse);
  });
}
