import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spcore_dart/spcore_dart.dart';

import '../models/account_profile.dart';
import '../models/app_settings.dart';
import 'engine_controller.dart';
import 'providers.dart';
import 'settings_controller.dart';

enum AccountStatus { disabled, offline, registering, registered, failed }

/// Human readable explanation of a registration failure.
String describeRegistrationFailure(AccountInfo i) {
  final err = i.lastError;
  if (err != null && err.trim().isNotEmpty) return err;
  switch (i.regCode) {
    case 401:
    case 403:
      return 'Wrong username or password (${i.regCode})';
    case 404:
      return 'Account not found on the server (404)';
    case 408:
      return 'Server did not answer (408)';
    case 423:
      return 'Registration interval too short (423)';
    case 480:
      return 'Server temporarily unavailable (480)';
    case 503:
      return 'Service unavailable (503)';
    case 0:
      return i.statusText.isNotEmpty ? i.statusText : 'Registration failed';
  }
  final r = i.regReason.isNotEmpty ? i.regReason : i.statusText;
  return r.isNotEmpty ? '$r (${i.regCode})' : 'Registration failed (${i.regCode})';
}

class AccountsState {
  const AccountsState({
    this.profiles = const [],
    this.infos = const {},
    this.mwi = const {},
    this.nextRetry = const {},
    this.applied = const {},
  });

  /// Profile ids currently added to the engine.
  final Set<String> applied;

  final List<AccountProfile> profiles;

  /// Latest engine info per profile id.
  final Map<String, AccountInfo> infos;
  final Map<String, MwiInfo> mwi;

  /// When the health monitor will retry a failed account.
  final Map<String, DateTime> nextRetry;

  AccountProfile? byId(String id) {
    for (final p in profiles) {
      if (p.id == id) return p;
    }
    return null;
  }

  List<AccountProfile> get enabled =>
      profiles.where((p) => p.enabled).toList();

  AccountProfile? get defaultProfile {
    final en = enabled;
    if (en.isEmpty) return null;
    return en.firstWhere(
      (p) => p.isDefault,
      orElse: () => en.firstWhere(
        (p) => statusOf(p.id) == AccountStatus.registered,
        orElse: () => en.first,
      ),
    );
  }

  AccountStatus statusOf(String id) {
    final p = byId(id);
    if (p == null || !p.enabled) return AccountStatus.disabled;
    final i = infos[id];
    if (i == null) {
      return applied.contains(id) ? AccountStatus.registering : AccountStatus.offline;
    }
    switch (i.regState) {
      case RegState.registered:
        return AccountStatus.registered;
      case RegState.registering:
        return AccountStatus.registering;
      case RegState.failed:
        return AccountStatus.failed;
      case RegState.unregistered:
      case RegState.unregistering:
      case RegState.none:
      case RegState.unknown:
        // Accounts with register:false are "online" without registering.
        if (!p.config.register && i.online) return AccountStatus.registered;
        return AccountStatus.offline;
    }
  }

  String? errorOf(String id) {
    final i = infos[id];
    if (i == null || statusOf(id) != AccountStatus.failed) return null;
    return describeRegistrationFailure(i);
  }

  int get newVoicemail =>
      mwi.values.fold(0, (a, m) => a + (m.waiting ? m.newMsgs : 0));
  bool get anyRegistered =>
      profiles.any((p) => statusOf(p.id) == AccountStatus.registered);
}

class AccountsController extends Notifier<AccountsState> {
  final Map<String, AccountConfig> _added = {};
  final Map<String, int> _attempt = {};
  final Map<String, Timer> _retry = {};
  Future<void> _queue = Future.value();
  int _generation = -1;

  EngineController get _engineCtl => ref.read(engineProvider.notifier);

  @override
  AccountsState build() {
    final sub = _engineCtl.events.listen(_onEvent);
    ref.onDispose(() {
      sub.cancel();
      for (final t in _retry.values) {
        t.cancel();
      }
    });
    ref.listen<EngineState>(engineProvider, (prev, next) {
      if (next.running && next.generation != _generation) {
        _generation = next.generation;
        _added.clear();
        state = AccountsState(profiles: state.profiles, mwi: state.mwi);
        _enqueue(_sync);
      }
    });
    ref.listen<AppSettings>(settingsProvider, (prev, next) {
      if (prev != null && prev.globalStatus != next.globalStatus) {
        _enqueue(_publishPresence);
      }
    });
    return AccountsState(profiles: ref.read(bootDataProvider).profiles);
  }

  void _enqueue(Future<void> Function() job) {
    _queue = _queue.then((_) => job()).catchError((Object e) {
      debugPrint('accounts sync error: $e');
      ref.read(engineLogProvider.notifier).add('accounts sync error: $e');
    });
  }

  /// Completes when pending engine synchronisation has finished (tests).
  Future<void> settled() => _queue;

  Future<void> _persist() =>
      ref.read(accountsRepoProvider).saveAll(state.profiles);

  // ---- CRUD ---------------------------------------------------------------

  Future<void> add(AccountProfile profile) async {
    var list = [...state.profiles];
    var p = profile;
    if (list.isEmpty || p.isDefault) {
      list = [for (final e in list) e.copyWith(isDefault: false)];
      p = p.copyWith(isDefault: true);
    }
    state = AccountsState(
      profiles: [...list, p],
      infos: state.infos,
      mwi: state.mwi,
      nextRetry: state.nextRetry,
      applied: state.applied,
    );
    _enqueue(_sync);
    await _persist();
  }

  Future<void> update(AccountProfile profile) async {
    var list = [
      for (final e in state.profiles) e.id == profile.id ? profile : e,
    ];
    if (profile.isDefault) {
      list = [
        for (final e in list) e.id == profile.id ? e : e.copyWith(isDefault: false),
      ];
    }
    state = _with(profiles: list);
    _enqueue(_sync);
    await _persist();
  }

  Future<void> remove(String id) async {
    _retry.remove(id)?.cancel();
    var list = state.profiles.where((p) => p.id != id).toList();
    if (list.isNotEmpty && !list.any((p) => p.isDefault)) {
      list[0] = list[0].copyWith(isDefault: true);
    }
    state = _with(
      profiles: list,
      infos: {...state.infos}..remove(id),
      mwi: {...state.mwi}..remove(id),
    );
    _enqueue(_sync);
    await _persist();
  }

  Future<void> setEnabled(String id, bool enabled) async {
    final p = state.byId(id);
    if (p != null) await update(p.copyWith(enabled: enabled));
  }

  Future<void> setDefault(String id) async {
    final p = state.byId(id);
    if (p != null) await update(p.copyWith(isDefault: true));
  }

  Future<void> setDnd(String id, bool dnd) async {
    final p = state.byId(id);
    if (p != null) await update(p.copyWith(dnd: dnd));
  }

  Future<void> reorder(int oldIndex, int newIndex) async {
    final list = [...state.profiles];
    if (newIndex > oldIndex) newIndex -= 1;
    list.insert(newIndex, list.removeAt(oldIndex));
    state = _with(profiles: list);
    await _persist();
  }

  AccountsState _with({
    List<AccountProfile>? profiles,
    Map<String, AccountInfo>? infos,
    Map<String, MwiInfo>? mwi,
    Map<String, DateTime>? nextRetry,
    Set<String>? applied,
  }) => AccountsState(
    profiles: profiles ?? state.profiles,
    infos: infos ?? state.infos,
    mwi: mwi ?? state.mwi,
    nextRetry: nextRetry ?? state.nextRetry,
    applied: applied ?? state.applied,
  );

  // ---- registration controls ---------------------------------------------

  Future<void> register(String id, bool register) async {
    if (!_engineCtl.hasEngine || !_added.containsKey(id)) return;
    _retry.remove(id)?.cancel();
    try {
      await _engineCtl.engine.setRegistration(AccountRef.uid(id), register);
    } catch (e) {
      ref.read(noticeProvider.notifier).error('Could not change registration', details: '$e');
    }
  }

  // ---- engine sync --------------------------------------------------------

  Future<void> _sync() async {
    ref.read(engineLogProvider.notifier).add('sync accounts (engine ready: ${_engineCtl.hasEngine}, profiles: ${state.profiles.length})');
    if (!_engineCtl.hasEngine) return;
    final engine = _engineCtl.engine;
    final wanted = {for (final p in state.profiles.where((p) => p.enabled)) p.id: p};
    // Remove accounts no longer wanted.
    for (final id in _added.keys.toList()) {
      if (!wanted.containsKey(id)) {
        try {
          await engine.removeAccount(AccountRef.uid(id));
        } catch (_) {}
        _added.remove(id);
        state = _with(applied: {...state.applied}..remove(id));
        _attempt.remove(id);
        _retry.remove(id)?.cancel();
        final infos = {...state.infos}..remove(id);
        state = _with(infos: infos);
      }
    }
    for (final p in wanted.values) {
      final cfg = p.config.copyWith(uid: p.id);
      final existing = _added[p.id];
      try {
        if (existing == null) {
          final n = await engine.addAccount(cfg);
          ref.read(engineLogProvider.notifier).add('account added ${p.id} -> $n');
          state = _with(applied: {...state.applied, p.id});
          _added[p.id] = cfg;
        } else if (existing != cfg) {
          await engine.modifyAccount(AccountRef.uid(p.id), cfg);
          _added[p.id] = cfg;
        }
      } on EngineException catch (e) {
        ref.read(noticeProvider.notifier).error(
          'Could not apply account "${p.name}"',
          details: e.toString(),
        );
      }
    }
    await _publishPresence();
  }

  Future<void> _publishPresence() async {
    if (!_engineCtl.hasEngine) return;
    final status = switch (ref.read(settingsProvider).globalStatus) {
      'away' => PresenceStatus.away,
      'dnd' => PresenceStatus.dnd,
      _ => PresenceStatus.online,
    };
    for (final id in _added.keys) {
      try {
        await _engineCtl.engine.setPresence(AccountRef.uid(id), status);
      } catch (_) {}
    }
  }

  // ---- events -------------------------------------------------------------

  void _onEvent(EngineEvent e) {
    switch (e) {
      case AccountRegEvent():
        _onReg(e.account);
      case AccountMwiEvent():
        if (state.byId(e.mwi.uid) != null) {
          state = _with(mwi: {...state.mwi, e.mwi.uid: e.mwi});
        }
      case ResyncSnapshotEvent():
        for (final a in e.snapshot.accounts) {
          _onReg(a);
        }
      default:
    }
  }

  void _onReg(AccountInfo info) {
    final id = info.uid;
    if (state.byId(id) == null) return;
    state = _with(infos: {...state.infos, id: info});
    if (info.regState == RegState.registered) {
      _attempt[id] = 0;
      _retry.remove(id)?.cancel();
      if (state.nextRetry.containsKey(id)) {
        state = _with(nextRetry: {...state.nextRetry}..remove(id));
      }
    } else if (info.regState == RegState.failed) {
      _scheduleRetry(id);
    }
  }

  /// Exponential backoff: 10 s, 20 s, 40 s ... capped at 5 min.
  void _scheduleRetry(String id) {
    if (_retry.containsKey(id)) return;
    final n = _attempt[id] = (_attempt[id] ?? 0) + 1;
    final secs = min(300, 5 * pow(2, n).toInt());
    state = _with(
      nextRetry: {
        ...state.nextRetry,
        id: DateTime.now().add(Duration(seconds: secs)),
      },
    );
    _retry[id] = Timer(Duration(seconds: secs), () async {
      _retry.remove(id);
      final p = state.byId(id);
      if (p == null || !p.enabled || !_engineCtl.hasEngine) return;
      try {
        await _engineCtl.engine.setRegistration(AccountRef.uid(id), true);
      } catch (_) {}
    });
  }
}

final accountsProvider = NotifierProvider<AccountsController, AccountsState>(
  AccountsController.new,
);
