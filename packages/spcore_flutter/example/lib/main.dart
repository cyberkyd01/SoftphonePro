import 'package:flutter/material.dart';
import 'package:spcore_dart/spcore_dart.dart';

/// Packaging smoke test: loads the bundled native library through spcore_dart
/// and shows the engine version string.
void main() => runApp(const MaterialApp(home: Home()));

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    String text;
    try {
      final lib = SpcoreLibrary.load();
      text = 'OK api=${lib.apiVersion()} ${lib.versionString()} (${lib.path})';
    } catch (e) {
      text = 'FAILED: $e';
    }
    // Printed so that `adb logcat` / `flutter run` can assert on it.
    debugPrint('SPCORE_LOAD: $text');
    return Scaffold(
      appBar: AppBar(title: const Text('spcore_flutter example')),
      body: Center(child: Padding(padding: const EdgeInsets.all(16), child: Text(text, key: const Key('result')))),
    );
  }
}
