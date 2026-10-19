import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    return SettingsGroup(
      title: 'App lock',
      footer: 'Calls still ring and can be answered while the app is locked.',
      children: [
        SwitchTile(
          key: const Key('applock-switch'),
          icon: Icons.lock_rounded,
          title: 'Require PIN to open the app',
          subtitle: s.appLock ? 'History, contacts, messages and settings are locked' : 'Off',
          value: s.appLock,
          onChanged: (on) async {
            if (on) {
              final pin = await showNewPinDialog(context);
              if (pin == null) return;
              await lock.enable(pin);
              notice.show('App lock is on');
            } else {
              final ok = await verifyPinDialog(context, ref, title: 'Turn off app lock');
              if (ok) {
                await lock.disable();
                notice.show('App lock is off');
              }
            }
          },
        ),
        if (s.appLock) ...[
          NavTile(
            key: const Key('applock-change'),
            icon: Icons.password_rounded,
            title: 'Change PIN',
            onTap: () async {
              if (!await verifyPinDialog(context, ref, title: 'Enter current PIN')) return;
              if (!context.mounted) return;
              final pin = await showNewPinDialog(context);
              if (pin == null) return;
              await ref.read(appLockServiceProvider).setPin(pin);
              notice.show('PIN changed');
            },
          ),
          SelectTile<int>(
            icon: Icons.timer_outlined,
            title: 'Lock after',
            subtitle: 'Time in the background before the PIN is needed again',
            value: const [0, 1, 5, 15, 30, 60].contains(s.appLockMinutes) ? s.appLockMinutes : 1,
            options: const {0: 'Immediately', 1: '1 minute', 5: '5 minutes', 15: '15 minutes', 30: '30 minutes', 60: '1 hour'},
            onChanged: (v) => ref.read(settingsProvider.notifier).update({'appLockMinutes': v}),
          ),
          if (bio)
            SwitchTile(
              icon: Icons.fingerprint_rounded,
              title: 'Unlock with biometrics',
              value: s.appLockBiometrics,
              onChanged: (v) => ref.read(settingsProvider.notifier).update({'appLockBiometrics': v}),
            ),
          NavTile(
            key: const Key('applock-now'),
            icon: Icons.lock_clock_rounded,
            title: 'Lock now',
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
  final a = TextEditingController();
  final b = TextEditingController();
  String? error;
  return showDialog<String>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) => AlertDialog(
        title: const Text('Set a PIN'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              key: const Key('pin-new'),
              controller: a,
              autofocus: true,
              obscureText: true,
              keyboardType: TextInputType.number,
              maxLength: AppLockService.maxPinLength,
              decoration: const InputDecoration(labelText: 'PIN (4-8 digits)', counterText: ''),
            ),
            TextField(
              key: const Key('pin-confirm'),
              controller: b,
              obscureText: true,
              keyboardType: TextInputType.number,
              maxLength: AppLockService.maxPinLength,
              decoration: InputDecoration(labelText: 'Repeat PIN', counterText: '', errorText: error),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            key: const Key('pin-save'),
            onPressed: () {
              if (!AppLockService.isValidPin(a.text)) {
                setState(() => error = 'Use 4 to 8 digits');
              } else if (a.text != b.text) {
                setState(() => error = 'PINs do not match');
              } else {
                Navigator.pop(ctx, a.text);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    ),
  );
}

/// Prompts for the current PIN and checks it (with the same backoff as the
/// lock screen). True when it was right.
Future<bool> verifyPinDialog(BuildContext context, WidgetRef ref, {required String title}) async {
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
          maxLength: AppLockService.maxPinLength,
          decoration: InputDecoration(labelText: 'PIN', counterText: '', errorText: error),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(
            key: const Key('pin-verify'),
            onPressed: () async {
              final r = await svc.verify(c.text);
              if (r.ok) {
                if (ctx.mounted) Navigator.pop(ctx, true);
              } else {
                setState(() {
                  error = r.result == PinResult.lockedOut || r.retryAfter > Duration.zero
                      ? 'Too many attempts. Try again in ${r.retryAfter.inSeconds}s'
                      : 'Wrong PIN';
                  c.clear();
                });
              }
            },
            child: const Text('OK'),
          ),
        ],
      ),
    ),
  );
  return ok == true;
}
