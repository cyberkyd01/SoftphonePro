import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/l10n.dart';
import '../services/providers.dart';
import '../services/settings_controller.dart';
import '../ui/widgets/settings_tiles.dart';
import 'app_lock_controller.dart';
import 'app_lock_service.dart';

/// Settings > Privacy & Security > App lock.
class AppLockSettingsGroup extends ConsumerWidget {
  const AppLockSettingsGroup({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(settingsProvider);
    final bio = ref.watch(biometricAvailableProvider).maybeWhen(data: (v) => v, orElse: () => false);
    final lock = ref.read(appLockProvider.notifier);
    final notice = ref.read(noticeProvider.notifier);
    final l = context.l10n;
    return SettingsGroup(
      title: l.appLockTitle,
      footer: l.appLockFooter,
      children: [
        SwitchTile(
          key: const Key('applock-switch'),
          icon: Icons.lock_rounded,
          title: l.appLockRequirePin,
          subtitle: s.appLock ? l.appLockOnHint : l.commonOff,
          value: s.appLock,
          onChanged: (on) async {
            if (on) {
              final pin = await showNewPinDialog(context);
              if (pin == null) return;
              await lock.enable(pin);
              notice.show(l.appLockIsOn);
            } else {
              final ok = await verifyPinDialog(context, ref, title: l.appLockTurnOff);
              if (ok) {
                await lock.disable();
                notice.show(l.appLockIsOff);
              }
            }
          },
        ),
        if (s.appLock) ...[
          NavTile(
            key: const Key('applock-change'),
            icon: Icons.password_rounded,
            title: l.appLockChangePin,
            onTap: () async {
              if (!await verifyPinDialog(context, ref, title: l.appLockEnterCurrent)) return;
              if (!context.mounted) return;
              final pin = await showNewPinDialog(context);
              if (pin == null) return;
              await ref.read(appLockServiceProvider).setPin(pin);
              notice.show(l.appLockPinChanged);
            },
          ),
          SelectTile<int>(
            icon: Icons.timer_outlined,
            title: l.appLockLockAfter,
            subtitle: l.appLockLockAfterHint,
            value: const [0, 1, 5, 15, 30, 60].contains(s.appLockMinutes) ? s.appLockMinutes : 1,
            options: {0: l.appLockImmediately, 1: l.appLockMinutes(1), 5: l.appLockMinutes(5), 15: l.appLockMinutes(15), 30: l.appLockMinutes(30), 60: l.appLockHour},
            onChanged: (v) => ref.read(settingsProvider.notifier).update({'appLockMinutes': v}),
          ),
          if (bio)
            SwitchTile(
              icon: Icons.fingerprint_rounded,
              title: l.appLockBiometrics,
              value: s.appLockBiometrics,
              onChanged: (v) => ref.read(settingsProvider.notifier).update({'appLockBiometrics': v}),
            ),
          NavTile(
            key: const Key('applock-now'),
            icon: Icons.lock_clock_rounded,
            title: l.appLockNow,
            onTap: lock.lock,
          ),
        ],
      ],
    );
  }
}

final biometricAvailableProvider = FutureProvider<bool>((ref) => ref.watch(biometricAuthProvider).isAvailable());

/// Asks twice for a new 4-8 digit PIN; null when cancelled.
Future<String?> showNewPinDialog(BuildContext context) {
  final l = context.l10n;
  final a = TextEditingController();
  final b = TextEditingController();
  String? error;
  return showDialog<String>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) => AlertDialog(
        title: Text(l.appLockSetPin),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              key: const Key('pin-new'),
              controller: a,
              autofocus: true,
              obscureText: true,
              keyboardType: TextInputType.number,
              textDirection: TextDirection.ltr,
              maxLength: AppLockService.maxPinLength,
              decoration: InputDecoration(labelText: l.appLockPinDigits, counterText: ''),
            ),
            TextField(
              key: const Key('pin-confirm'),
              controller: b,
              obscureText: true,
              keyboardType: TextInputType.number,
              textDirection: TextDirection.ltr,
              maxLength: AppLockService.maxPinLength,
              decoration: InputDecoration(labelText: l.appLockRepeatPin, counterText: '', errorText: error),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l.actionCancel)),
          FilledButton(
            key: const Key('pin-save'),
            onPressed: () {
              if (!AppLockService.isValidPin(a.text)) {
                setState(() => error = l.appLockUseDigits);
              } else if (a.text != b.text) {
                setState(() => error = l.appLockMismatch);
              } else {
                Navigator.pop(ctx, a.text);
              }
            },
            child: Text(l.actionSave),
          ),
        ],
      ),
    ),
  );
}

/// Prompts for the current PIN and checks it (with the same backoff as the
/// lock screen). True when it was right.
Future<bool> verifyPinDialog(BuildContext context, WidgetRef ref, {required String title}) async {
  final l = context.l10n;
  final c = TextEditingController();
  final svc = ref.read(appLockServiceProvider);
  String? error;
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) => AlertDialog(
        title: Text(title),
        content: TextField(
          key: const Key('pin-current'),
          controller: c,
          autofocus: true,
          obscureText: true,
          keyboardType: TextInputType.number,
              textDirection: TextDirection.ltr,
          maxLength: AppLockService.maxPinLength,
          decoration: InputDecoration(labelText: l.appLockPin, counterText: '', errorText: error),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l.actionCancel)),
          FilledButton(
            key: const Key('pin-verify'),
            onPressed: () async {
              final r = await svc.verify(c.text);
              if (r.ok) {
                if (ctx.mounted) Navigator.pop(ctx, true);
              } else {
                setState(() {
                  error = r.result == PinResult.lockedOut || r.retryAfter > Duration.zero
                      ? l.appLockTooManyTryIn(r.retryAfter.inSeconds)
                      : l.appLockWrongPin;
                  c.clear();
                });
              }
            },
            child: Text(l.actionOk),
          ),
        ],
      ),
    ),
  );
  return ok == true;
}
