import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

/// Golden images are generated on macOS; CI runs on Linux where text is
/// rasterised slightly differently. Accept a small fraction of differing
/// pixels so genuine layout regressions still fail but font anti-aliasing
/// does not.
const double _goldenTolerance = 0.03; // 3 % of pixels

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  final comparator = goldenFileComparator;
  if (comparator is LocalFileComparator) {
    goldenFileComparator = _TolerantGoldenComparator(
      // Any file name inside the test's directory keeps the same basedir.
      comparator.basedir.resolve('flutter_test_config.dart'),
    );
  }
  await testMain();
}

class _TolerantGoldenComparator extends LocalFileComparator {
  _TolerantGoldenComparator(super.testFile);

  @override
  Future<bool> compare(Uint8List imageBytes, Uri golden) async {
    final result = await GoldenFileComparator.compareLists(
      imageBytes,
      await getGoldenBytes(golden),
    );
    if (result.passed || result.diffPercent <= _goldenTolerance) {
      if (!result.passed) {
        debugPrint(
          'Golden $golden differs by '
          '${(result.diffPercent * 100).toStringAsFixed(2)}% (tolerated).',
        );
      }
      result.dispose();
      return true;
    }
    final error = await generateFailureOutput(result, golden, basedir);
    result.dispose();
    throw FlutterError(error);
  }
}
