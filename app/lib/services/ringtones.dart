import 'dart:io';

import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../l10n/l10n.dart';
import '../models/account_profile.dart';
import '../models/app_settings.dart';
import '../models/contact.dart';

/// Built-in ringtones: name -> asset path. `default` is the OS / engine
/// default and has no file.
const Map<String, String> kBuiltInRingtones = {
  'classic': 'assets/sounds/classic.wav',
  'soft': 'assets/sounds/soft.wav',
  'digital': 'assets/sounds/digital.wav',
};

const String kRecordBeepAsset = 'assets/sounds/record_beep.wav';

/// Ringtone picker option ids (global, account, contact); the values are the
/// English labels - the UI uses [ringtoneOptions].
const Map<String, String> kRingtoneOptions = {
  'default': 'System default',
  'classic': 'Classic',
  'soft': 'Soft',
  'digital': 'Digital',
};

/// Localised labels for the ringtone pickers, keyed like [kRingtoneOptions].
Map<String, String> ringtoneOptions(AppLocalizations l) => {
  'default': l.callRingtoneSystemDefault,
  'classic': l.callRingtoneClassic,
  'soft': l.callRingtoneSoft,
  'digital': l.callRingtoneDigital,
};

bool isRingtonePath(String name) => name.contains('/') || name.contains(r'\');

/// Ringtone selection: contact > account > global ('default' = inherit).
String resolveRingtoneName(
  AppSettings settings,
  AccountProfile? profile,
  Contact? contact,
) {
  if (contact != null && contact.ringtone != 'default') return contact.ringtone;
  if (profile != null && profile.ringtone != 'default') return profile.ringtone;
  return settings.ringtone;
}

/// Materialises a ringtone name into a local file path (null = system
/// default). Built-ins are copied from the asset bundle to the app support
/// directory once; custom paths are returned as they are.
typedef RingtoneFileResolver = Future<String?> Function(String name);

Future<String?> defaultRingtoneFile(String name) async {
  if (isRingtonePath(name)) return name;
  return supportAssetFile(kBuiltInRingtones[name]);
}

Future<String?> supportAssetFile(String? asset) async {
  if (asset == null) return null;
  final dir = await getApplicationSupportDirectory();
  final out = File(p.join(dir.path, 'sounds', p.basename(asset)));
  if (!await out.exists()) {
    final data = await rootBundle.load(asset);
    await out.parent.create(recursive: true);
    await out.writeAsBytes(
      data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
      flush: true,
    );
  }
  return out.path;
}
