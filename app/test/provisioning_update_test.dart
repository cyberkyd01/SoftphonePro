import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:softphonepro/l10n/app_localizations.dart';
import 'package:softphonepro/models/app_settings.dart';
import 'package:softphonepro/services/accounts_controller.dart';
import 'package:softphonepro/services/provisioning.dart';
import 'package:softphonepro/services/provisioning_import.dart';
import 'package:softphonepro/ui/widgets/import_confirm_dialog.dart';
import 'package:spcore_dart/spcore_dart.dart';

import 'harness.dart';

String _doc(String domain, {String pw = '', String user = '1001', String label = 'New'}) =>
    '{"accounts":[{"username":"$user","password":"$pw","domain":"$domain","label":"$label"}]}';

void main() {
  recordFormatTests();
  late ProviderContainer c;
  late Provider<Ref> refP;
  setUp(() async {
    final env = await TestEnv.create(
      settings: const AppSettings(),
      profiles: [testProfile(id: 'keep', user: '1001', domain: 'pbx.test')],
    );
    refP = Provider<Ref>((ref) => ref);
    c = ProviderContainer(overrides: env.overrides);
    addTearDown(c.dispose);
    c.read(accountsProvider);
  });

  for (final trusted in [true, false]) {
    test('re-import updates the matching account (${trusted ? 'trusted' : 'untrusted'})', () async {
      final r = Provisioning.parse(_doc('PBX.Test'));
      final ref = c.read(refP);
      if (trusted) {
        await applyTrustedImport(ref.read, r);
      } else {
        await importProvisioningResult(ref, r);
      }
      final list = c.read(accountsProvider).profiles;
      expect(list, hasLength(1));
      expect(list.single.id, 'keep');
      expect(list.single.config.uid, 'keep');
      expect(list.single.label, 'New');
      expect(list.single.config.password, 'pw', reason: 'no password in import keeps the old one');
      expect(list.single.isDefault, isTrue);
    });
  }

  test('import password replaces, different user adds', () async {
    final ref = c.read(refP);
    await applyTrustedImport(ref.read, Provisioning.parse(_doc('pbx.test', pw: 'fresh')));
    expect(c.read(accountsProvider).profiles.single.config.password, 'fresh');
    await applyTrustedImport(ref.read, Provisioning.parse(_doc('pbx.test', user: '1002')));
    expect(c.read(accountsProvider).profiles, hasLength(2));
  });

  test('countImportMatches', () {
    final existing = c.read(accountsProvider).profiles;
    final inc = Provisioning.parse(
      '{"accounts":[{"username":"1001","domain":"PBX.TEST"},{"username":"7","domain":"x.org"}]}',
    ).accounts;
    final m = countImportMatches(existing, inc);
    expect((m.updated, m.added), (1, 1));
  });

  testWidgets('consent dialog says update N existing, add M new', (tester) async {
    final existing = c.read(accountsProvider).profiles;
    final plan = prepareUntrustedImport(Provisioning.parse(
      '{"accounts":[{"username":"1001","domain":"pbx.test"},{"username":"7","domain":"x.org"}]}',
    ));
    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Builder(
        builder: (ctx) => TextButton(
          onPressed: () => showImportConfirmDialog(ctx, plan, existing: existing),
          child: const Text('go'),
        ),
      ),
    ));
    await tester.tap(find.text('go'));
    await tester.pumpAndSettle();
    expect(find.text('Update 1 existing, add 1 new'), findsOneWidget);
  });
}

void recordFormatTests() {
  test('recordFormat aliases are parsed tolerantly', () {
    String f(String v) => AppSettings({'recordFormat': v}).recordFormat;
    expect(f('stereo'), 'wavStereo');
    expect(f('wav-stereo'), 'wavStereo');
    expect(f('WAV_Stereo'), 'wavStereo');
    expect(f('wavStereo'), 'wavStereo');
    expect(f('ogg'), 'opus');
    expect(f('opus'), 'opus');
    expect(f('wav'), 'wav');
    expect(f('garbage'), 'wav');
    expect(RecordFormat.parse(f('stereo')), RecordFormat.wavStereo);
    expect(RecordFormat.parse(f('ogg')), RecordFormat.opus);
  });
}
