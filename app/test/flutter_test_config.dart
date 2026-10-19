import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

/// Golden images are generated on macOS. On the generating platform only a
/// tiny difference is accepted; elsewhere (Linux CI) text is rasterised
/// differently, so text-heavy screens can differ by a few percent while the
/// layout is identical. The looser bound still catches broken layouts
/// (missing panels, overflow stripes, wrong theme) which change far more.
final double _goldenTolerance = Platform.isMacOS ? 0.005 : 0.08;

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
