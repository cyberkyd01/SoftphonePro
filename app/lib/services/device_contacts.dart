import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../core/format.dart';
import '../models/contact.dart';
import '../platform/android/android_platform_services.dart';
import '../platform/ios/ios_platform_services.dart';
import '../platform/platform_services.dart';
import 'providers.dart';

/// Where "Import from device" reads the address book from.
abstract class DeviceContactsSource {
  /// Asks for access; true when granted.
  Future<bool> requestPermission();
  Future<List<DeviceContact>> read();
}

class AndroidContactsSource implements DeviceContactsSource {
  AndroidContactsSource(this._p);
  final AndroidPlatformServices _p;
  @override
  Future<bool> requestPermission() async =>
      (await _p.requestContactsPermission()).contacts == PermissionStatus.granted;
  @override
  Future<List<DeviceContact>> read() => _p.readDeviceContacts();
}

class IosContactsSource implements DeviceContactsSource {
  IosContactsSource(this._p);
  final IosPlatformServices _p;
  @override
  Future<bool> requestPermission() => _p.requestContactsPermission();
  @override
  Future<List<DeviceContact>> read() => _p.readDeviceContacts();
}

/// macOS: Contacts framework behind the `softphonepro/desktop` channel
/// (MainFlutterWindow.swift).
class MacosContactsSource implements DeviceContactsSource {
  MacosContactsSource([MethodChannel? channel])
    : _c = channel ?? const MethodChannel('softphonepro/desktop');
  final MethodChannel _c;

  @override
  Future<bool> requestPermission() async {
    try {
      return await _c.invokeMethod<String>('requestContactsPermission') == 'granted';
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }

  @override
  Future<List<DeviceContact>> read() async {
    try {
      return IosPlatformServices.parseDeviceContacts(
        await _c.invokeMethod<List<Object?>>('readContacts'),
      );
    } on PlatformException {
      return const [];
    } on MissingPluginException {
      return const [];
    }
  }
}

/// Null when the platform has no address book to import (Windows, Linux).
final deviceContactsSourceProvider = Provider<DeviceContactsSource?>((ref) {
  final p = ref.watch(platformServicesProvider);
  if (p is AndroidPlatformServices) return AndroidContactsSource(p);
  if (p is IosPlatformServices) return IosContactsSource(p);
  if (Platform.isMacOS) return MacosContactsSource();
  return null;
});

/// Outcome of comparing device contacts with the stored ones.
class DeviceImportPlan {
  const DeviceImportPlan({
    this.added = const [],
    this.updated = const [],
    this.skipped = 0,
  });

  /// Brand-new contacts.
  final List<Contact> added;

  /// Existing contacts that gain numbers / an email from the device entry.
  final List<Contact> updated;

  /// Device entries that add nothing (already present / no phone number).
  final int skipped;

  bool get isEmpty => added.isEmpty && updated.isEmpty;
}

/// Dedupes [incoming] against [existing] by normalised number and merges new
/// numbers / email into matching contacts. Pure; nothing is stored here.
DeviceImportPlan planDeviceImport(
  List<Contact> existing,
  List<DeviceContact> incoming, {
  String Function()? newId,
}) {
  final gen = newId ?? () => const Uuid().v4();
  final work = <String, Contact>{for (final c in existing) c.id: c};
  final order = [...existing.map((c) => c.id)];
  final added = <String>{};
  final changed = <String>{};
  var skipped = 0;

  String? match(String number) {
    for (final id in order) {
      if (work[id]!.numbers.any((n) => sameNumber(n.value, number))) return id;
    }
    return null;
  }

  for (final d in incoming) {
    final nums = <(String, String)>[];
    for (final n in d.numbers) {
      if (digitsOf(n.$2).isEmpty) continue;
      if (!nums.any((e) => sameNumber(e.$2, n.$2))) nums.add(n);
    }
    if (nums.isEmpty) {
      skipped++;
      continue;
    }
    final hit = nums.map((n) => match(n.$2)).whereType<String>().firstOrNull;
    if (hit == null) {
      final c = Contact(
        id: gen(),
        name: d.name.trim(),
        numbers: [
          for (final n in nums)
            ContactNumber(label: _label(n.$1), value: n.$2.trim()),
        ],
        email: d.emails.firstOrNull?.trim() ?? '',
      );
      work[c.id] = c;
      order.add(c.id);
      added.add(c.id);
      continue;
    }
    var c = work[hit]!;
    final extra = [
      for (final n in nums)
        if (!c.numbers.any((e) => sameNumber(e.value, n.$2)))
          ContactNumber(label: _label(n.$1), value: n.$2.trim()),
    ];
    final email = c.email.isEmpty ? (d.emails.firstOrNull?.trim() ?? '') : '';
    if (extra.isEmpty && email.isEmpty) {
      skipped++;
      continue;
    }
    c = c.copyWith(
      numbers: [...c.numbers, ...extra],
      email: email.isEmpty ? null : email,
    );
    work[hit] = c;
    (added.contains(hit) ? added : changed).add(hit);
  }

  return DeviceImportPlan(
    added: [for (final id in order) if (added.contains(id)) work[id]!],
    updated: [for (final id in order) if (changed.contains(id)) work[id]!],
    skipped: skipped,
  );
}

String _label(String l) {
  final s = l.trim().toLowerCase();
  return s.isEmpty ? 'mobile' : s;
}
