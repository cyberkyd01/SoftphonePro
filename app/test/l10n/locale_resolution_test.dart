import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:softphonepro/l10n/l10n.dart';

void main() {
  test('system language falls back to English when nothing matches', () {
    expect(resolveLocale(kSystemLanguage, const [Locale('sv', 'SE')]), const Locale('en'));
    expect(resolveLocale(kSystemLanguage, const [Locale('C')]), const Locale('en'));
    expect(resolveLocale(kSystemLanguage, const []), const Locale('en'));
  });

  test('system language still matches supported languages and regions', () {
    expect(resolveLocale(kSystemLanguage, const [Locale('de', 'AT')]), const Locale('de'));
    expect(resolveLocale(kSystemLanguage, const [Locale('pt', 'BR')]), const Locale('pt', 'BR'));
    expect(resolveLocale(kSystemLanguage, const [Locale('ar', 'EG')]), const Locale('ar'));
    expect(resolveLocale(kSystemLanguage, const [Locale('sv'), Locale('fr', 'CA')]), const Locale('fr'));
  });

  test('an explicit language wins over the system', () {
    expect(resolveLocale('ja', const [Locale('de')]), const Locale('ja'));
  });
}
