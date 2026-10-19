import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show LicenseEntry, LicenseRegistry;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:softphonepro/ui/settings/native_licenses.dart';
import 'package:softphonepro/ui/settings/sections.dart';
import 'package:softphonepro/l10n/app_localizations.dart';

void main() {
  testWidgets('About lists the bundled native components', (tester) async {
    tester.view.physicalSize = const Size(900, 3000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const ProviderScope(child: MaterialApp(localizationsDelegates: AppLocalizations.localizationsDelegates, supportedLocales: AppLocalizations.supportedLocales, home: Scaffold(body: AboutSection()))));
    for (final name in ['PJSIP', 'OpenSSL', 'Opus', 'bcg729', 'RNNoise', 'minimp3', 'cJSON', 'Mozilla CA certificate bundle', 'Inter typeface']) {
      expect(find.text(name), findsOneWidget, reason: name);
    }
  });

  test('native components are registered with the licence registry', () async {
    LicenseRegistry.reset();
    registerNativeLicenses(force: true);
    final entries = await LicenseRegistry.licenses.toList();
    String packages(LicenseEntry e) => e.packages.join(',');
    final names = entries.map(packages).toList();
    expect(names.any((n) => n.startsWith('RNNoise')), isTrue, reason: '$names');
    expect(names.any((n) => n.startsWith('PJSIP')), isTrue, reason: '$names');
    final rnnoise = entries.firstWhere((e) => packages(e).startsWith('RNNoise'));
    final text = rnnoise.paragraphs.map((p) => p.text).join('\n');
    expect(text, contains('BSD-3-Clause'));
    expect(text, contains('Xiph.Org'));
    expect(entries.length, kNativeNotices.length);
  });
}
