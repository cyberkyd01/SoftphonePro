import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/l10n.dart';
import 'accounts_controller.dart';
import 'calls_controller.dart';
import 'engine_controller.dart';

/// Result of [waitForDialReady].
class DialReadiness {
  const DialReadiness.ready() : ok = true, message = null;
  const DialReadiness.blocked(String this.message) : ok = false;
  final bool ok;

  /// Why the call cannot be placed (names the account and its state).
  final String? message;
}

/// How long a link / CLI driven call waits for the engine and the account.
const Duration kDialReadyTimeout = Duration(seconds: 15);

String _accountState(AppLocalizations l, String name, AccountStatus s) =>
    switch (s) {
      AccountStatus.registered => l.callDialAccountRegistered(name),
      AccountStatus.registering => l.callDialAccountRegistering(name),
      AccountStatus.offline => l.callDialAccountOffline(name),
      AccountStatus.failed => l.callDialAccountFailed(name),
      AccountStatus.disabled => l.callDialAccountDisabled(name),
    };

/// `null` = ready, `(true, msg)` = keep waiting, `(false, msg)` = give up.
({bool wait, String message})? _evaluate(
  Ref ref,
  String target,
  String? accountId,
) {
  final l = ref.read(l10nProvider);
  final eng = ref.read(engineProvider);
  if (eng.phase == EnginePhase.failed) {
    return (
      wait: false,
      message: eng.error == null
          ? l.callDialEngineFailed
          : l.callDialEngineFailedWithReason('${eng.error}'),
    );
  }
  if (!eng.running) {
    return (wait: true, message: l.callDialEngineStarting);
  }
  final calls = ref.read(callsProvider.notifier);
  final res = calls.dialRules().apply(target);
  if (res.target.isEmpty || res.emergency || ipLiteralHost(res.target) != null) {
    return null;
  }
  final selected = accountId ?? res.accountId ?? ref.read(dialAccountProvider);
  if (selected == kDirectAccountId) return null;
  final acc = ref.read(accountsProvider);
  final profile =
      (selected == null ? null : acc.byId(selected)) ?? acc.defaultProfile;
  // No account (the dialler reports it) or a disabled one: nothing to wait for.
  if (profile == null || !profile.enabled) return null;
  final st = acc.statusOf(profile.id);
  if (st == AccountStatus.registered) return null;
  final base = _accountState(l, profile.name, st);
  if (st == AccountStatus.failed) {
    final why = acc.errorOf(profile.id);
    return (
      wait: false,
      message: why == null || why.isEmpty
          ? base
          : l.callDialBlockedWithReason(base, why),
    );
  }
  return (wait: true, message: base);
}

/// Waits until the engine is running and the account that will carry the call
/// to [target] is registered. A link or `--dial` at launch arrives while the
/// engine is still starting and the account still registering; dialling then
/// fails. Gives up at once when the engine or the account failed, and after
/// [timeout] with a message naming the account state.
Future<DialReadiness> waitForDialReady(
  Ref ref,
  String target, {
  String? accountId,
  Duration timeout = kDialReadyTimeout,
}) async {
  var r = _evaluate(ref, target, accountId);
  if (r == null) return const DialReadiness.ready();
  if (!r.wait) return DialReadiness.blocked(r.message);

  final done = Completer<DialReadiness>();
  late final Timer timer;
  final subs = <ProviderSubscription<Object?>>[];
  void check() {
    if (done.isCompleted) return;
    final e = _evaluate(ref, target, accountId);
    if (e == null) {
      done.complete(const DialReadiness.ready());
    } else if (!e.wait) {
      done.complete(DialReadiness.blocked(e.message));
    } else {
      r = e;
    }
  }

  subs.add(ref.listen<EngineState>(engineProvider, (_, _) => check()));
  subs.add(ref.listen<AccountsState>(accountsProvider, (_, _) => check()));
  timer = Timer(timeout, () {
    if (done.isCompleted) return;
    check();
    if (!done.isCompleted) {
      done.complete(
        DialReadiness.blocked(
          ref
              .read(l10nProvider)
              .callDialTimedOut(r!.message, timeout.inSeconds),
        ),
      );
    }
  });
  try {
    return await done.future;
  } finally {
    timer.cancel();
    for (final s in subs) {
      s.close();
    }
  }
}
