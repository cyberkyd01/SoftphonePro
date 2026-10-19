import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/engine_controller.dart';
import '../router.dart';

/// Blocks the app with a friendly error when the engine failed to start.
/// A missing native library is handled elsewhere (demo mode + banner).
class EngineFailureGate extends ConsumerStatefulWidget {
  const EngineFailureGate({super.key, required this.child});
  final Widget child;
  @override
  ConsumerState<EngineFailureGate> createState() => _EngineFailureGateState();
}

class _EngineFailureGateState extends ConsumerState<EngineFailureGate> {
  bool _dismissed = false;

  @override
  Widget build(BuildContext context) {
    final st = ref.watch(engineProvider);
    final failed = st.phase == EnginePhase.failed;
    if (!failed && _dismissed) _dismissed = false;
    if (!failed) return widget.child;
    final ctl = ref.read(engineProvider.notifier);
    final scheme = Theme.of(context).colorScheme;
    if (_dismissed) {
      return Column(
        children: [
          Material(
            color: scheme.errorContainer,
            child: SafeArea(
              bottom: false,
              child: ListTile(
                dense: true,
                leading: Icon(Icons.error_outline_rounded, color: scheme.onErrorContainer),
                title: Text('The calling engine is not running', style: TextStyle(color: scheme.onErrorContainer)),
                trailing: TextButton(key: const Key('engine-banner-retry'), onPressed: ctl.retry, child: const Text('Retry')),
              ),
            ),
          ),
          Expanded(child: widget.child),
        ],
      );
    }
    return Scaffold(
      key: const Key('engine-failure'),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(Icons.phonelink_erase_rounded, size: 56, color: scheme.error),
                  const SizedBox(height: 16),
                  Text("Couldn't start the calling engine", textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  Text(
                    'Calls and registration will not work until this is fixed. '
                    'A bad network or certificate setting is the usual cause.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: scheme.errorContainer, borderRadius: BorderRadius.circular(12)),
                    child: SelectableText(
                      st.error ?? 'Unknown error',
                      key: const Key('engine-failure-message'),
                      style: TextStyle(color: scheme.onErrorContainer),
                    ),
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    key: const Key('engine-retry'),
                    onPressed: ctl.retry,
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Retry'),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    key: const Key('engine-network-settings'),
                    onPressed: () {
                      setState(() => _dismissed = true);
                      ref.read(routerProvider).go('/settings/network');
                    },
                    icon: const Icon(Icons.settings_ethernet_rounded),
                    label: const Text('Open network settings'),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    key: const Key('engine-use-simulator'),
                    onPressed: ctl.startSimulator,
                    child: const Text('Use simulator (demo)'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
