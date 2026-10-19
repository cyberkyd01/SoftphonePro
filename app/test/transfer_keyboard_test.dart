import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:softphonepro/services/calls_controller.dart';

import 'harness.dart';

void main() {
  testWidgets('transfer sheet stays above the on-screen keyboard', (tester) async {
    final env = await TestEnv.create(profiles: [testProfile()]);
    await pumpApp(tester, env);
    await waitRegistered(tester, env);
    final c = containerOf(tester);
    final view = tester.view;
    view.physicalSize = const Size(1080, 2400);
    view.devicePixelRatio = 2.625;
    addTearDown(view.reset);
    addTearDown(view.resetViewInsets);
    await c.read(callsProvider.notifier).dial('2002');
    await settle(tester, env.engine);
    await tester.tap(find.text('Transfer'));
    await tester.pumpAndSettle();
    const kb = 880.0;
    view.viewInsets = const FakeViewPadding(bottom: kb);
    await tester.pumpAndSettle();
    final top = view.physicalSize.height - kb;
    final button = tester.getRect(find.byKey(const Key('transfer-blind')));
    final field = tester.getRect(find.byKey(const Key('transfer-number')));
    expect(field.top, greaterThan(0));
    expect(button.bottom * view.devicePixelRatio, lessThanOrEqualTo(top + 1), reason: 'button $button above keyboard top ${top / view.devicePixelRatio}');
    expect(button.top, greaterThan(0));
  });
}
