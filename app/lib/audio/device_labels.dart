import 'package:spcore_dart/spcore_dart.dart';

/// "System default (MacBook Pro Microphone)" naming the device the OS
/// currently routes to; plain "System default" when the name adds nothing.
String systemDefaultLabel(Iterable<AudioDevice>? devices) {
  final def = (devices ?? const <AudioDevice>[]).where((d) => d.isDefault).firstOrNull;
  final n = def?.name.trim() ?? '';
  final generic = n.isEmpty || n.toLowerCase() == 'default' || n.toLowerCase() == 'system default';
  return generic ? 'System default' : 'System default ($n)';
}
