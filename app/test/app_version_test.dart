import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:softphonepro/services/engine_controller.dart';

void main() {
  test('kAppVersion matches the pubspec version', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final m = RegExp(r'^version:\s*([0-9]+\.[0-9]+\.[0-9]+)', multiLine: true).firstMatch(pubspec);
    expect(m, isNotNull);
    expect(kAppVersion, m!.group(1));
    expect(kUserAgent, 'SoftphonePro/${m.group(1)}');
    // The engine reports the same release version.
    final engine = File('../native/src/spc_internal.h').readAsStringSync();
    expect(RegExp(r'#define SPC_VERSION "([^"]+)"').firstMatch(engine)?.group(1), m.group(1));
  });
}
