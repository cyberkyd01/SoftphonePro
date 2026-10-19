import 'dart:io';

/// This package only bundles the prebuilt `spcore` native library.
/// The FFI bindings and loading logic live in `package:spcore_dart`
/// (`SpcoreLibrary.load()`); this helper just names the platform library.
class SpcoreFlutter {
  const SpcoreFlutter._();

  /// Name to pass to `DynamicLibrary.open` for the bundled library.
  static String get libraryPath {
    if (Platform.isAndroid || Platform.isLinux) return 'libspcore.so';
    if (Platform.isMacOS || Platform.isIOS) return 'spcore.framework/spcore';
    if (Platform.isWindows) return 'spcore.dll';
    throw UnsupportedError('spcore is not bundled for this platform');
  }
}
