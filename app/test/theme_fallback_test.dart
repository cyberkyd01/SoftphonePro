import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:softphonepro/core/theme.dart';

void main() {
  for (final b in Brightness.values) {
    test('every text style carries the script fallback list ($b)', () {
      final t = buildTheme(b);
      for (final style in [
        t.textTheme.bodyMedium,
        t.textTheme.titleMedium,
        t.textTheme.labelSmall,
        t.primaryTextTheme.bodyLarge,
        t.navigationRailTheme.selectedLabelTextStyle,
        t.navigationRailTheme.unselectedLabelTextStyle,
        t.appBarTheme.titleTextStyle,
      ]) {
        expect(style!.fontFamilyFallback, containsAll(['Noto Sans Devanagari', 'Noto Sans Arabic', 'DejaVu Sans']));
      }
      expect(t.navigationBarTheme.labelTextStyle!.resolve({})!.fontFamilyFallback, contains('Noto Sans Arabic'));
    });
  }
}
