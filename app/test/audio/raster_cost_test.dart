import 'package:flutter_test/flutter_test.dart';
import 'package:softphonepro/audio/audio_levels.dart';

List<Duration> ms(int value, int n) => List.filled(n, Duration(milliseconds: value));

void main() {
  test('cheap frames keep the fast meter rate', () {
    final m = RasterCostMonitor();
    expect(m.add(ms(2, 30)), isFalse);
    expect(m.slow, isFalse);
  });

  test('expensive frames (software rendering) switch to low power, cheap ones switch back', () {
    final m = RasterCostMonitor();
    expect(m.add(ms(25, 30)), isTrue);
    expect(m.slow, isTrue);
    // Between half the threshold and the threshold: stays slow (hysteresis).
    expect(m.add(ms(8, 30)), isFalse);
    expect(m.slow, isTrue);
    expect(m.add(ms(3, 30)), isTrue);
    expect(m.slow, isFalse);
  });

  test('a few slow frames among cheap ones do not switch (median)', () {
    final m = RasterCostMonitor();
    m.add(ms(2, 20));
    expect(m.add(ms(40, 9)), isFalse);
    expect(m.slow, isFalse);
  });

  test('needs a minimum number of frames before deciding', () {
    final m = RasterCostMonitor();
    expect(m.add(ms(30, 5)), isFalse);
    expect(m.slow, isFalse);
  });
}
