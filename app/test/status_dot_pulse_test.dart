import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:softphonepro/ui/widgets/basic_widgets.dart';

void main() {
  testWidgets('pulsing StatusDot uses no animation ticker (low fps timer) and keeps the dot size', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Center(child: StatusDot(color: Colors.orange, size: 10, pulse: true))));
    expect(tester.getSize(find.byType(StatusDot)), const Size(10, 10));
    await tester.pump(const Duration(seconds: 2));
    // No ticker/animation controller: the framework does not request continuous frames.
    expect(tester.binding.transientCallbackCount, 0);
    expect(kStatusPulseFps, lessThanOrEqualTo(4));
  });

  testWidgets('reduced motion: static dot, no timer left running', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(disableAnimations: true),
        child: Center(child: StatusDot(color: Colors.orange, pulse: true)),
      ),
    ));
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('disposing a pulsing dot cancels its timer', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Center(child: StatusDot(color: Colors.orange, pulse: true))));
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpWidget(const SizedBox());
    // flutter_test fails the test if a periodic Timer is still pending here.
  });
}
