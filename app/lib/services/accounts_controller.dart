import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spcore_dart/spcore_dart.dart';

import 'package:flutter/widgets.dart' show Locale;

import '../l10n/l10n.dart';
import '../models/account_profile.dart';
import '../models/app_settings.dart';
import 'calls_controller.dart';
import 'engine_controller.dart';
import 'providers.dart';
import 'settings_controller.dart';

enum AccountStatus { disabled, offline, registering, registered, failed }

/// Human readable explanation of a registration failure.
String describeRegistrationFailure(AccountInfo i, AppLocalizations l) {
  final err = i.lastError;
  if (err != null && err.trim().isNotEmpty) return err;
  switch (i.regCode) {
    case 401:
    case 403:
      return l.acctRegWrongCredentials(i.regCode);
    case 404:
      return l.acctRegNotFound;
    case 408:
      return l.acctRegNoAnswer;
    case 423:
      return l.acctRegIntervalTooShort;
    case 480:
      return l.acctRegTemporarilyUnavailable;
    case 503:
      return l.acctRegServiceUnavailable;
    case 0:
      return i.statusText.isNotEmpty ? i.statusText : l.acctRegFailed;
  }
  final r = i.regReason.isNotEmpty ? i.regReason : i.statusText;
  return r.isNotEmpty ? '$r (${i.regCode})' : l.acctRegFailedWithCode(i.regCode);
}

class AccountsState {
  const AccountsState({
    this.profiles = const [],
    this.infos = const {},
    this.mwi = const {},
    this.nextRetry = const {},
    this.applied = const {},
    this.retryHalted = const {},
    this.usingBackup = const {},
    this.l10n,
  });

  /// Strings for derived texts such as [errorOf]; null = English.
  final AppLocalizations? l10n;

  /// Accounts whose registration failed for good (401/403/404): no automatic
  /// retries until the profile changes or the user taps register.
  final Set<String> retryHalted;

  /// Accounts currently registered through their backup registrar.
  final Set<String> usingBackup;

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
    return describeRegistrationFailure(i, l10n ?? lookupAppLocalizations(const Locale('en')));
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
  // Final failures, failover bookkeeping.
  final Map<String, AccountConfig> _baseCfg = {};
  final Map<String, int> _failCount = {};
  final Map<String, Timer> _probe = {};
  final Set<String> _probing = {};
  final Set<String> _onBackup = {};
  final Set<String> _halted = {};

  /// Number of consecutive transient failures before failing over.
  static const int failoverAfter = 3;

  /// How often the primary registrar is tried again while on the backup.
  static Duration primaryProbeEvery = const Duration(minutes: 5);

  EngineController get _engineCtl => ref.read(engineProvider.notifier);

  @override
  AccountsState build() {
    final sub = _engineCtl.events.listen(_onEvent);
    ref.onDispose(() {
      sub.cancel();
      for (final t in _retry.values) {
        t.cancel();
      }
      for (final t in _probe.values) {
        t.cancel();
      }
    });
    ref.listen<EngineState>(engineProvider, (prev, next) {
      if (next.running && next.generation != _generation) {
        _generation = next.generation;
        // Clear inside the queue: a sync that is still iterating must not see
        // _added emptied underneath it (it also aborts on a generation change).
        _enqueue(() async {
          _added.clear();
          _baseCfg.clear();
          state = AccountsState(
            profiles: state.profiles,
            mwi: state.mwi,
            retryHalted: state.retryHalted,
            usingBackup: state.usingBackup,
            l10n: state.l10n,
          );
          await _sync();
        });
      }
    });
    ref.listen<AppSettings>(settingsProvider, (prev, next) {
      if (prev != null && prev.globalStatus != next.globalStatus) {
        _enqueue(_publishPresence);
      }
    });
    // Deferred: the locale can change while the widget tree is building.
    ref.listen<AppLocalizations>(l10nProvider, (prev, next) {
      Future.microtask(() {
        if (ref.mounted) state = _with(l10n: next);
      });
    });
    return AccountsState(profiles: ref.read(bootDataProvider).profiles, l10n: ref.read(l10nProvider));
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
      retryHalted: state.retryHalted,
      usingBackup: state.usingBackup,
      l10n: state.l10n,
    );
    _enqueue(_sync);
    await _persist();
  }

  Future<void> update(AccountProfile profile) async {
    final before = state.byId(profile.id);
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
    if (before != null) _maybeSyncFeatureCodes(before, profile);
  }

  Future<void> remove(String id) async {
    _retry.remove(id)?.cancel();
    _probe.remove(id)?.cancel();
    _probing.remove(id);
    _onBackup.remove(id);
    _halted.remove(id);
    _failCount.remove(id);
    _baseCfg.remove(id);
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
    Set<String>? retryHalted,
    Set<String>? usingBackup,
    AppLocalizations? l10n,
  }) => AccountsState(
    profiles: profiles ?? state.profiles,
    infos: infos ?? state.infos,
    mwi: mwi ?? state.mwi,
    nextRetry: nextRetry ?? state.nextRetry,
    applied: applied ?? state.applied,
    retryHalted: retryHalted ?? state.retryHalted,
    usingBackup: usingBackup ?? state.usingBackup,
    l10n: l10n ?? state.l10n,
  );

  void _publishFlags() {
    if (setEquals(state.retryHalted, _halted) && setEquals(state.usingBackup, _onBackup)) return;
    state = _with(retryHalted: {..._halted}, usingBackup: {..._onBackup});
  }

  // ---- registration controls ---------------------------------------------

  Future<void> register(String id, bool register) async {
    if (!_engineCtl.hasEngine || !_added.containsKey(id)) return;
    _retry.remove(id)?.cancel();
    if (register) {
      // An explicit tap overrides a halted retry loop.
      _halted.remove(id);
      _attempt[id] = 0;
      _failCount[id] = 0;
      _publishFlags();
    }
    try {
      await _engineCtl.engine.setRegistration(AccountRef.uid(id), register);
    } catch (e) {
      ref.read(noticeProvider.notifier).error(ref.read(l10nProvider).acctNoticeRegistrationChange, details: '$e');
    }
  }

  // ---- PBX feature codes (opt-in) -----------------------------------------

  Future<void> _codeQueue = Future.value();

  /// Dials the PBX star codes for a changed DND / forwarding toggle when
  /// "Sync DND / forwarding to PBX via feature codes" is on.
  void _maybeSyncFeatureCodes(AccountProfile a, AccountProfile b) {
    if (!ref.read(settingsProvider).syncFeatureCodes) return;
    final codes = b.featureCodes;
    final out = <String>[];
    if (a.dnd != b.dnd) {
      final c = (b.dnd ? codes.dndOn : codes.dndOff).trim();
      if (c.isNotEmpty) out.add(c);
    }
    final fa = a.forwarding.active;
    final fb = b.forwarding.active;
    if (fa != fb || (fb && a.forwarding.target != b.forwarding.target)) {
      if (fb) {
        final c = codes.forwardOn.trim();
        if (c.isNotEmpty) out.add('$c${b.forwarding.target.trim()}');
      } else {
        final c = codes.forwardOff.trim();
        if (c.isNotEmpty) out.add(c);
      }
    }
    for (final code in out) {
      _codeQueue = _codeQueue.then((_) => dialFeatureCode(b.id, code)).catchError((Object e) {
        debugPrint('feature code failed: $e');
      });
    }
  }

  /// Duration the silent feature-code call is kept before hanging up.
  static Duration featureCodeHold = const Duration(seconds: 3);

  /// Places a short hidden call to [code] and hangs up after
  /// [featureCodeHold] (or when the call ends sooner).
  Future<void> dialFeatureCode(String accountId, String code) async {
    if (!_engineCtl.hasEngine) return;
    final done = Completer<void>();
    int? cid;
    final sub = _engineCtl.events.listen((e) {
      if (e is CallStateEvent && e.cid == cid && e.isTerminal && !done.isCompleted) {
        done.complete();
      }
    });
    try {
      cid = await ref.read(callsProvider.notifier).dialSilent(code, accountId: accountId);
      if (cid == null) return;
      await done.future.timeout(featureCodeHold, onTimeout: () {});
      if (_engineCtl.hasEngine) {
        try {
          await _engineCtl.engine.hangup(cid);
        } catch (_) {}
      }
    } finally {
      await sub.cancel();
    }
  }

  // ---- engine sync --------------------------------------------------------

  Future<void> _sync() async {
    ref.read(engineLogProvider.notifier).add('sync accounts (engine ready: ${_engineCtl.hasEngine}, profiles: ${state.profiles.length})');
    if (!_engineCtl.hasEngine) return;
    final engine = _engineCtl.engine;
    final gen = _generation;
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
        _baseCfg.remove(id);
        _halted.remove(id);
        _onBackup.remove(id);
        _failCount.remove(id);
        _probe.remove(id)?.cancel();
        _probing.remove(id);
        final infos = {...state.infos}..remove(id);
        state = _with(infos: infos);
      }
    }
    for (final p in wanted.values) {
      // A newer engine generation queued its own full sync: stop using the
      // stale view of _added.
      if (gen != _generation) return;
      final base = engineConfigOf(p.config.copyWith(uid: p.id));
      if (p.backupRegistrar.trim().isEmpty && _onBackup.remove(p.id)) {
        _probe.remove(p.id)?.cancel();
        _probing.remove(p.id);
      }
      final prevBase = _baseCfg[p.id];
      if (prevBase != null && prevBase != base) {
        // The profile changed: allow registration again, start counting anew.
        _halted.remove(p.id);
        _failCount.remove(p.id);
        _attempt.remove(p.id);
        if (_onBackup.remove(p.id)) {
          _probe.remove(p.id)?.cancel();
          _probing.remove(p.id);
        }
      }
      _baseCfg[p.id] = base;
      final cfg = _onBackup.contains(p.id) && !_probing.contains(p.id) ? _backupConfig(base, p.backupRegistrar) : base;
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
          ref.read(l10nProvider).acctNoticeApplyFailed(p.name),
          details: e.toString(),
        );
      }
    }
    _publishFlags();
    await _publishPresence();
  }

  /// [base] pointed at the backup registrar (outbound proxies are replaced).
  static AccountConfig _backupConfig(AccountConfig base, String backup) {
    final b = backup.trim();
    final uri = b.toLowerCase().startsWith('sip') ? b : 'sip:$b';
    return base.copyWith(
      registrar: uri,
      proxies: base.proxies.isEmpty ? null : [uri],
    );
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

  /// Final failures: retrying cannot help (and risks a fail2ban lockout).
  static bool isFinalFailure(int code) => code == 401 || code == 403 || code == 404;

  void _onReg(AccountInfo info) {
    final id = info.uid;
    if (state.byId(id) == null) return;
    state = _with(infos: {...state.infos, id: info});
    if (info.regState == RegState.registered) {
      _attempt[id] = 0;
      _failCount[id] = 0;
      _retry.remove(id)?.cancel();
      if (_halted.remove(id)) _publishFlags();
      if (state.nextRetry.containsKey(id)) {
        state = _with(nextRetry: {...state.nextRetry}..remove(id));
      }
      if (_probing.remove(id)) {
        // The primary registrar answers again.
        _onBackup.remove(id);
        _probe.remove(id)?.cancel();
        _publishFlags();
        final p = state.byId(id);
        if (p != null) {
          ref.read(noticeProvider.notifier).show(ref.read(l10nProvider).acctNoticeBackOnPrimary(p.name));
        }
      }
    } else if (info.regState == RegState.failed) {
      if (isFinalFailure(info.regCode)) {
        _retry.remove(id)?.cancel();
        _attempt.remove(id);
        _failCount[id] = 0;
        _halted.add(id);
        if (state.nextRetry.containsKey(id)) {
          state = _with(nextRetry: {...state.nextRetry}..remove(id));
        }
        _publishFlags();
        return;
      }
      if (_probing.contains(id)) {
        // Primary still down: go straight back to the backup.
        _probing.remove(id);
        _enqueue(_sync);
        _scheduleProbe(id);
        return;
      }
      if (_maybeFailOver(id)) return;
      _scheduleRetry(id);
    }
  }

  /// After [failoverAfter] consecutive transient failures, moves the account
  /// to its backup registrar. Returns true when it did.
  bool _maybeFailOver(String id) {
    final p = state.byId(id);
    if (p == null || p.backupRegistrar.trim().isEmpty || _onBackup.contains(id)) {
      return false;
    }
    final n = _failCount[id] = (_failCount[id] ?? 0) + 1;
    if (n < failoverAfter) return false;
    _failCount[id] = 0;
    _retry.remove(id)?.cancel();
    _onBackup.add(id);
    _publishFlags();
    ref.read(noticeProvider.notifier).show(ref.read(l10nProvider).acctNoticeUsingBackup(p.name));
    _enqueue(_sync);
    _scheduleProbe(id);
    return true;
  }

  /// While on the backup, try the primary again periodically.
  void _scheduleProbe(String id) {
    _probe.remove(id)?.cancel();
    _probe[id] = Timer(primaryProbeEvery, () {
      _probe.remove(id);
      if (!_onBackup.contains(id)) return;
      _probing.add(id);
      // Re-apply the primary config without leaving the backup state; a
      // failure puts the backup back (see _onReg).
      _enqueue(() => _applyPrimaryProbe(id));
    });
  }

  Future<void> _applyPrimaryProbe(String id) async {
    final p = state.byId(id);
    if (p == null || !_engineCtl.hasEngine || !_onBackup.contains(id)) {
      _probing.remove(id);
      return;
    }
    final cfg = engineConfigOf(p.config.copyWith(uid: id));
    try {
      await _engineCtl.engine.modifyAccount(AccountRef.uid(id), cfg);
      _added[id] = cfg;
    } catch (_) {
      _probing.remove(id);
      _scheduleProbe(id);
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

/// The config as the engine accepts it: a client certificate is only sent
/// when both the certificate and the key file are set (otherwise the engine
/// answers INVALID_PARAM and the account would not register at all).
AccountConfig engineConfigOf(AccountConfig c) {
  final cert = c.tlsClientCert;
  if (cert == null || (cert.certFile.isNotEmpty && cert.keyFile.isNotEmpty)) return c;
  final j = c.toJson()..remove('tlsClientCert');
  return AccountConfig.fromJson(j);
}
