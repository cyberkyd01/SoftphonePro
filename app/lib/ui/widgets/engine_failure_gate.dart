import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/l10n.dart';
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
                title: Text(context.l10n.appEngineNotRunning, style: TextStyle(color: scheme.onErrorContainer)),
                trailing: TextButton(key: const Key('engine-banner-retry'), onPressed: ctl.retry, child: Text(context.l10n.actionRetry)),
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
                  Text(context.l10n.appEngineFailedTitle, textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  Text(
context.l10n.appEngineFailedBody,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: scheme.errorContainer, borderRadius: BorderRadius.circular(12)),
                    child: SelectableText(
                      st.error ?? context.l10n.appUnknownError,
                      key: const Key('engine-failure-message'),
                      style: TextStyle(color: scheme.onErrorContainer),
                    ),
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    key: const Key('engine-retry'),
                    onPressed: ctl.retry,
                    icon: const Icon(Icons.refresh_rounded),
                    label: Text(context.l10n.actionRetry),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    key: const Key('engine-network-settings'),
                    onPressed: () {
                      setState(() => _dismissed = true);
                      ref.read(routerProvider).go('/settings/network');
                    },
                    icon: const Icon(Icons.settings_ethernet_rounded),
                    label: Text(context.l10n.appEngineOpenNetworkSettings),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    key: const Key('engine-use-simulator'),
                    onPressed: ctl.startSimulator,
                    child: Text(context.l10n.appEngineUseSimulator),
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
