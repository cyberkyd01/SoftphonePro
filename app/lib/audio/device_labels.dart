import 'package:spcore_dart/spcore_dart.dart';

import '../l10n/l10n.dart';

/// "System default (MacBook Pro Microphone)" naming the device the OS
/// currently routes to; plain "System default" when the name adds nothing.
String systemDefaultLabel(AppLocalizations l, Iterable<AudioDevice>? devices) {
  final def = (devices ?? const <AudioDevice>[]).where((d) => d.isDefault).firstOrNull;
  final n = def?.name.trim() ?? '';
  final generic = n.isEmpty || n.toLowerCase() == 'default' || n.toLowerCase() == 'system default';
  return generic ? l.audioSystemDefault : l.audioSystemDefaultNamed(n);
}

/// Picker options for a device list: `default` first (named after the system
/// default), then every other device by id.
Map<String, String> audioDeviceOptions(AppLocalizations l, List<AudioDevice>? devices) => {
  'default': systemDefaultLabel(l, devices),
  for (final d in devices ?? const <AudioDevice>[])
    if (d.devId != 'default') d.devId: d.name,
};
