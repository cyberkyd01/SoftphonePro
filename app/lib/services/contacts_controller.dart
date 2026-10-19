import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/format.dart';
import '../models/contact.dart';
import 'providers.dart';
import 'contact_io.dart';
import 'device_contacts.dart';

Contact? findContact(Iterable<Contact> contacts, String numberOrUri) {
  if (numberOrUri.trim().isEmpty) return null;
  for (final c in contacts) {
    for (final a in c.addresses) {
      if (sameNumber(a, numberOrUri)) return c;
    }
  }
  return null;
}

class ContactsController extends Notifier<List<Contact>> {
  @override
  List<Contact> build() => _sorted(ref.read(bootDataProvider).contacts);

  static List<Contact> _sorted(List<Contact> l) => [...l]..sort(
    (a, b) => a.displayName.toLowerCase().compareTo(b.displayName.toLowerCase()),
  );

  Future<void> save(Contact c) async {
    final exists = state.any((e) => e.id == c.id);
    state = _sorted([
      if (exists) ...state.map((e) => e.id == c.id ? c : e) else ...[...state, c],
    ]);
    await ref.read(contactsRepoProvider).put(c);
  }

  Future<void> delete(String id) async {
    state = state.where((c) => c.id != id).toList();
    await ref.read(contactsRepoProvider).delete(id);
  }

  Future<void> toggleFavorite(String id) async {
    final c = state.firstWhere((c) => c.id == id);
    await save(c.copyWith(favorite: !c.favorite));
  }

  Future<int> importAll(List<Contact> incoming) async {
    var n = 0;
    final merged = [...state];
    for (final c in incoming) {
      final dup = merged.any(
        (e) =>
            e.name.toLowerCase() == c.name.toLowerCase() &&
            e.primary == c.primary,
      );
      if (!dup) {
        merged.add(c);
        n++;
      }
    }
    state = _sorted(merged);
    await ref.read(contactsRepoProvider).putAll(state);
    return n;
  }

  /// Stores the result of [planDeviceImport]; returns how many contacts were
  /// added or changed.
  Future<int> applyImport(DeviceImportPlan plan) async {
    if (plan.isEmpty) return 0;
    final byId = {for (final c in plan.updated) c.id: c};
    state = _sorted([
      for (final c in state) byId[c.id] ?? c,
      ...plan.added,
    ]);
    await ref.read(contactsRepoProvider).putAll(state);
    return plan.added.length + plan.updated.length;
  }

  String exportVCard() => ContactIo.toVCard(state);
  String exportCsv() => ContactIo.toCsv(state);

  Contact? lookup(String number) => findContact(state, number);

  Future<void> clear() async {
    state = [];
    await ref.read(contactsRepoProvider).clear();
  }
}

final contactsProvider = NotifierProvider<ContactsController, List<Contact>>(
  ContactsController.new,
);

/// Display name for a number: contact name or the given fallback.
String nameForNumber(List<Contact> contacts, String number, String fallback) =>
    findContact(contacts, number)?.displayName ?? fallback;
