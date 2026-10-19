import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/l10n.dart';
import '../services/calls_controller.dart';
import '../services/contacts_controller.dart';
import '../ui/helpers.dart';
import '../ui/router.dart';
import 'app_lock_controller.dart';
import 'app_lock_service.dart';

/// Covers the app with the PIN screen while locked.
///
/// Calls are never blocked: a ringing or running call is answerable and
/// hangable from the lock screen, and the full-screen incoming / in-call
/// routes stay visible while they are open.
class AppLockGate extends ConsumerStatefulWidget {
  const AppLockGate({super.key, required this.child});
  final Widget child;
  @override
  ConsumerState<AppLockGate> createState() => _AppLockGateState();
}

class _AppLockGateState extends ConsumerState<AppLockGate>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _observer = ref.read(callRouteObserverProvider);
    _observer.open.addListener(_routesChanged);
    Future.microtask(() {
      if (mounted) ref.read(appLockProvider.notifier).recoverIfNoPin();
    });
  }

  late final CallRouteObserver _observer;

  // The observer fires while the navigator is building: rebuild afterwards.
  void _routesChanged() => WidgetsBinding.instance.addPostFrameCallback((_) {
    if (mounted) setState(() {});
  });

  @override
  void dispose() {
    _observer.open.removeListener(_routesChanged);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final c = ref.read(appLockProvider.notifier);
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
        c.onBackground();
      case AppLifecycleState.resumed:
        c.onResume();
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final locked = ref.watch(appLockProvider);
    if (!locked) return widget.child;
    final hasCalls = ref.watch(callsProvider.select((s) => s.hasCalls));
    // Full-screen call routes are shown as they are while a call is live.
    final callScreen = hasCalls && _observer.open.value.isNotEmpty;
    return Stack(
      children: [
        ExcludeFocus(
          excluding: !callScreen,
          child: ExcludeSemantics(excluding: !callScreen, child: widget.child),
        ),
        // Own Overlay: tooltips etc. need one and the Navigator's is covered.
        if (!callScreen)
          Positioned.fill(
            child: Overlay(
              initialEntries: [
                OverlayEntry(builder: (_) => const AppLockScreen()),
              ],
            ),
          ),
      ],
    );
  }
}

class AppLockScreen extends ConsumerStatefulWidget {
  const AppLockScreen({super.key});
  @override
  ConsumerState<AppLockScreen> createState() => _AppLockScreenState();
}

class _AppLockScreenState extends ConsumerState<AppLockScreen> {
  String _pin = '';
  String? _error;
  Duration _wait = Duration.zero;
  Timer? _timer;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final left = await ref.read(appLockServiceProvider).lockoutRemaining();
      if (mounted && left > Duration.zero) _startCountdown(left);
      if (mounted && left == Duration.zero) _biometric();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _biometric() async {
    await ref.read(appLockProvider.notifier).unlockWithBiometrics();
  }

  void _startCountdown(Duration d) {
    _timer?.cancel();
    setState(() => _wait = d);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      final next = _wait - const Duration(seconds: 1);
      if (next <= Duration.zero) {
        t.cancel();
        setState(() {
          _wait = Duration.zero;
          _error = null;
        });
      } else {
        setState(() => _wait = next);
      }
    });
  }

  void _digit(String d) {
    if (_wait > Duration.zero ||
        _busy ||
        _pin.length >= AppLockService.maxPinLength) {
      return;
    }
    setState(() {
      _pin += d;
      _error = null;
    });
  }

  Future<void> _submit() async {
    if (_busy ||
        _wait > Duration.zero ||
        _pin.length < AppLockService.minPinLength) {
      return;
    }
    setState(() => _busy = true);
    final r = await ref.read(appLockProvider.notifier).unlockWithPin(_pin);
    if (!mounted) return;
    setState(() {
      _busy = false;
      _pin = '';
      if (!r.ok) {
        _error = r.result == PinResult.lockedOut
            ? context.l10n.appLockTooMany
            : context.l10n.appLockWrongPin;
      }
    });
    if (r.retryAfter > Duration.zero) _startCountdown(r.retryAfter);
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final l = context.l10n;
    final bio = ref
        .watch(biometricUsableProvider)
        .maybeWhen(data: (v) => v, orElse: () => false);
    final locked = _wait > Duration.zero;
    return Material(
      key: const Key('lock-screen'),
      color: t.colorScheme.surface,
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 340),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const _LockCalls(),
                  Icon(
                    Icons.lock_rounded,
                    size: 40,
                    color: t.colorScheme.primary,
                  ),
                  const SizedBox(height: 12),
                  Text(l.appLockIsLocked, style: t.textTheme.titleLarge),
                  const SizedBox(height: 4),
                  Text(
                    l.appLockEnterPin,
                    style: t.textTheme.bodyMedium?.copyWith(
                      color: t.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    key: const Key('lock-dots'),
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (
                        var i = 0;
                        i < (_pin.length < 4 ? 4 : _pin.length);
                        i++
                      )
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 5),
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: i < _pin.length
                                ? t.colorScheme.primary
                                : null,
                            border: Border.all(color: t.colorScheme.outline),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(
                    height: 36,
                    child: Center(
                      child: Text(
                        locked
                            ? l.appLockTryAgainIn(_fmt(_wait, l))
                            : (_error ?? ''),
                        key: const Key('lock-error'),
                        style: TextStyle(color: t.colorScheme.error),
                      ),
                    ),
                  ),
                  // The keypad keeps its 1-2-3 layout in right-to-left languages.
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (final row in const [
                          ['1', '2', '3'],
                          ['4', '5', '6'],
                          ['7', '8', '9'],
                        ])
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              for (final d in row)
                                _key(
                                  d,
                                  () => _digit(d),
                                  key: Key('lock-digit-$d'),
                                ),
                            ],
                          ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            bio
                                ? _key(
                                    '',
                                    _biometric,
                                    icon: Icons.fingerprint_rounded,
                                    key: const Key('lock-biometric'),
                                  )
                                : const SizedBox(width: 88, height: 64),
                            _key(
                              '0',
                              () => _digit('0'),
                              key: const Key('lock-digit-0'),
                            ),
                            _key(
                              '',
                              () => setState(
                                () => _pin = _pin.isEmpty
                                    ? ''
                                    : _pin.substring(0, _pin.length - 1),
                              ),
                              icon: Icons.backspace_outlined,
                              key: const Key('lock-back'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      key: const Key('lock-submit'),
                      onPressed:
                          locked || _pin.length < AppLockService.minPinLength
                          ? null
                          : _submit,
                      child: Text(l.appLockUnlock),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  static String _fmt(Duration d, AppLocalizations l) {
    if (d.inMinutes >= 1) {
      return l.appLockDurationMinSec(d.inMinutes, d.inSeconds % 60);
    }
    return l.appLockDurationSec(d.inSeconds);
  }

  Widget _key(
    String label,
    VoidCallback onTap, {
    IconData? icon,
    required Key key,
  }) => SizedBox(
    width: 88,
    height: 64,
    child: Center(
      child: TextButton(
        key: key,
        style: TextButton.styleFrom(
          shape: const CircleBorder(),
          minimumSize: const Size(56, 56),
        ),
        onPressed: onTap,
        child: icon != null
            ? Icon(icon)
            : Text(label, style: const TextStyle(fontSize: 24)),
      ),
    ),
  );
}

/// Calls that ring or run while the app is locked: answer / decline / hang up
/// without unlocking.
class _LockCalls extends ConsumerWidget {
  const _LockCalls();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final calls = ref.watch(callsProvider).live;
    if (calls.isEmpty) return const SizedBox.shrink();
    final contacts = ref.watch(contactsProvider);
    final ctl = ref.read(callsProvider.notifier);
    final t = Theme.of(context);
    final l = context.l10n;
    return Column(
      key: const Key('lock-calls'),
      children: [
        for (final c in calls)
          Card(
            margin: const EdgeInsetsDirectional.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Icon(
                    c.isRingingIn
                        ? Icons.ring_volume_rounded
                        : Icons.call_rounded,
                    color: t.colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          c.isRingingIn
                              ? l.appLockIncomingCall
                              : callStateText(c, context.l10n),
                          style: t.textTheme.labelMedium,
                        ),
                        Text(
                          callTitle(c, contacts, context.l10n),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: t.textTheme.titleMedium,
                        ),
                      ],
                    ),
                  ),
                  if (c.isRingingIn) ...[
                    IconButton.filled(
                      key: Key('lock-decline-${c.cid}'),
                      tooltip: l.appLockDecline,
                      style: IconButton.styleFrom(
                        backgroundColor: t.colorScheme.error,
                        foregroundColor: t.colorScheme.onError,
                      ),
                      onPressed: () => ctl.decline(c.cid),
                      icon: const Icon(Icons.call_end_rounded),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filled(
                      key: Key('lock-answer-${c.cid}'),
                      tooltip: l.appLockAnswer,
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () => ctl.answer(c.cid),
                      icon: const Icon(Icons.call_rounded),
                    ),
                  ] else
                    IconButton.filled(
                      key: Key('lock-hangup-${c.cid}'),
                      tooltip: l.appLockHangUp,
                      style: IconButton.styleFrom(
                        backgroundColor: t.colorScheme.error,
                        foregroundColor: t.colorScheme.onError,
                      ),
                      onPressed: () => ctl.hangup(c.cid),
                      icon: const Icon(Icons.call_end_rounded),
                    ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
