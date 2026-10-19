import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:softphonepro/core/bidi.dart';
import 'package:softphonepro/core/theme.dart';
import 'package:softphonepro/l10n/app_localizations.dart';
import 'package:softphonepro/services/accounts_controller.dart';
import 'package:softphonepro/ui/widgets/basic_widgets.dart';

Widget _app(Widget child) => MaterialApp(
  theme: buildTheme(Brightness.light),
  locale: const Locale('ar'),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(body: Center(child: child)),
);

void main() {
  test('bidiSafe isolates technical strings only', () {
    expect(stripBidi(bidiSafe('1016@127.0.0.1')), '1016@127.0.0.1');
    expect(bidiSafe('1016@127.0.0.1'), isNot('1016@127.0.0.1'));
    expect(bidiSafe('Alice'), 'Alice');
    expect(bidiSafe('أحمد'), 'أحمد');
    expect(bidiSafe('أحمد 5'), 'أحمد 5', reason: 'RTL text is left alone');
    expect(ltr(ltr('1.2.3.4')), ltr('1.2.3.4'), reason: 'idempotent');
    expect(bidiSafe(''), '');
  });

  testWidgets('Arabic: account chip shows the SIP address in LTR order', (tester) async {
    await tester.pumpWidget(_app(const AccountChip(name: '1016@127.0.0.1', status: AccountStatus.registered)));
    final t = tester.widget<Text>(find.descendant(of: find.byType(AccountChip), matching: find.byType(Text)));
    expect(Directionality.of(tester.element(find.byType(AccountChip))), TextDirection.rtl);
    expect(stripBidi(t.data!), '1016@127.0.0.1');
    // The isolate wraps the whole address so the paragraph lays it out LTR.
    expect(t.data!.runes.first, 0x2066);
    expect(t.data!.runes.last, 0x2069);
  });
}
