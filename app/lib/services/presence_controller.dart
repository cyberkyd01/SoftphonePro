import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spcore_dart/spcore_dart.dart';

import '../core/format.dart';
import '../models/account_profile.dart';
import '../models/contact.dart';
import 'accounts_controller.dart';
import 'contacts_controller.dart';
import 'engine_controller.dart';

/// Simplified lamp state for the BLF board.
enum LampState { unknown, idle, ringing, busy, offline }

LampState lampFor(BuddyInfo b) {
  switch (b.blf.state) {
    case BlfState.early:
      return LampState.ringing;
    case BlfState.confirmed:
      return LampState.busy;
    case BlfState.idle:
    case BlfState.terminated:
      return LampState.idle;
    case BlfState.unknown:
      break;
  }
  switch (b.presence.status) {
    case PresenceStatus.online:
      return LampState.idle;
    case PresenceStatus.offline:
      return LampState.offline;
    case PresenceStatus.busy:
    case PresenceStatus.onthephone:
    case PresenceStatus.dnd:
      return LampState.busy;
    case PresenceStatus.away:
      return LampState.idle;
    case PresenceStatus.unknown:
      return LampState.unknown;
  }
}

class PresenceState {
  const PresenceState({this.buddies = const {}});

  /// Contact id -> latest buddy info.
  final Map<String, BuddyInfo> buddies;
  LampState lampOf(String contactId) {
    final b = buddies[contactId];
    return b == null ? LampState.unknown : lampFor(b);
  }
}

/// Keeps engine buddies in sync with contacts that have BLF/presence on.
class PresenceController extends Notifier<PresenceState> {
  final Map<String, int> _buddyIds = {}; // contactId -> buddy id
  final Map<String, String> _uris = {}; // contactId -> uri used
  final Map<String, String> _subAccount = {}; // contactId -> account id used
  Future<void> _queue = Future.value();
  int _generation = -1;

  @override
  PresenceState build() {
    final sub = ref.read(engineProvider.notifier).events.listen(_onEvent);
    ref.onDispose(sub.cancel);
    ref.listen<List<Contact>>(contactsProvider, (_, __) => _enqueue());
    ref.listen<AccountsState>(accountsProvider, (prev, next) {
      final a = prev?.defaultProfile?.id;
      final b = next.defaultProfile?.id;
      final regA = prev?.anyRegistered;
      if (a != b ||
          regA != next.anyRegistered ||
          prev?.profiles.length != next.profiles.length) {
        _enqueue();
      }
    });
    ref.listen<EngineState>(engineProvider, (_, next) {
      if (next.running && next.generation != _generation) {
        _generation = next.generation;
        _buddyIds.clear();
        _uris.clear();
        _subAccount.clear();
        state = const PresenceState();
        _enqueue();
      }
    });
    return const PresenceState();
  }

  void _enqueue() {
    _queue = _queue.then((_) => _sync()).catchError((Object e) {
      debugPrint('presence sync: $e');
    });
  }

  Future<void> settled() => _queue;

  Future<void> _sync() async {
    final ctl = ref.read(engineProvider.notifier);
    if (!ctl.hasEngine) return;
    final accounts = ref.read(accountsProvider);
    final defaultAcc = accounts.defaultProfile;
    AccountProfile? accFor(Contact c) {
      final id = c.presenceAccountId;
      if (id != null && id.isNotEmpty) {
        final p = accounts.byId(id);
        if (p != null) return p;
      }
      return defaultAcc;
    }

    final contacts = ref.read(contactsProvider);
    final want = {
      for (final c in contacts)
        if (c.blf && c.watchTarget.isNotEmpty) c.id: c,
    };
    for (final id in _buddyIds.keys.toList()) {
      final c = want[id];
      if (c == null ||
          _uris[id] != c.watchTarget ||
          _subAccount[id] != accFor(c)?.id) {
        try {
          await ctl.engine.removeBuddy(_buddyIds[id]!);
        } catch (_) {}
        _buddyIds.remove(id);
        _uris.remove(id);
        _subAccount.remove(id);
        state = PresenceState(buddies: {...state.buddies}..remove(id));
      }
    }
    for (final c in want.values) {
      if (_buddyIds.containsKey(c.id)) continue;
      final acc = accFor(c);
      if (acc == null) continue;
      try {
        final uri = c.watchTarget;
        final id = await ctl.engine.addBuddy(
          acc: AccountRef.uid(acc.id),
          uri: uri,
          presence: true,
          blf: true,
        );
        _buddyIds[c.id] = id;
        _uris[c.id] = uri;
        _subAccount[c.id] = acc.id;
      } catch (e) {
        debugPrint('addBuddy failed: $e');
      }
    }
  }

  void _onEvent(EngineEvent e) {
    if (e is! BuddyStateEvent) return;
    final b = e.buddy;
    for (final entry in _buddyIds.entries) {
      if (entry.value == b.buddy) {
        state = PresenceState(buddies: {...state.buddies, entry.key: b});
        return;
      }
    }
    // Unknown buddy id: match by URI.
    final contacts = ref.read(contactsProvider);
    final c = findContact(contacts, b.uri);
    if (c != null && userPart(b.uri).isNotEmpty) {
      state = PresenceState(buddies: {...state.buddies, c.id: b});
    }
  }
}

final presenceProvider = NotifierProvider<PresenceController, PresenceState>(
  PresenceController.new,
);
