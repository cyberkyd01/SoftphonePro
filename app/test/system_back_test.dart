import 'package:flutter_test/flutter_test.dart';
import 'package:softphonepro/ui/router.dart';
import 'package:softphonepro/ui/shell/app_shell.dart';

import 'harness.dart';

void main() {
  test('shellBackTarget maps pages to their parent', () {
    expect(shellBackTarget('/keypad'), isNull);
    expect(shellBackTarget('/settings/calls'), '/settings');
    expect(shellBackTarget('/settings'), '/more');
    expect(shellBackTarget('/recordings'), '/more');
    expect(shellBackTarget('/more'), '/keypad');
    expect(shellBackTarget('/recents'), '/keypad');
  });

  testWidgets('system Back from a settings page returns to Settings, then More, then Keypad', (tester) async {
    final env = await TestEnv.create(profiles: [testProfile()]);
    await pumpApp(tester, env);
    await waitRegistered(tester, env);
    final c = containerOf(tester);
    final r = c.read(routerProvider);
    r.go('/settings/calls');
    await tester.pumpAndSettle();
    expect(await tester.binding.handlePopRoute(), isTrue);
    await tester.pumpAndSettle();
    expect(r.state.uri.path, '/settings');
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(r.state.uri.path, '/more');
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(r.state.uri.path, '/keypad');
  });
}
