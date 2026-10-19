import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme.dart';
import '../../../lan/lan_handoff_impl.dart';
import '../../../lan/lan_models.dart';
import '../../../platform/lan_handoff.dart';
import '../../../services/calls_controller.dart';
import '../../../services/providers.dart';

/// Label for LAN calls: transferred call, intercom or plain LAN call.
/// Renders nothing for ordinary calls.
class LanCallLabel extends StatelessWidget {
  const LanCallLabel({super.key, required this.call, this.center = true});
  final UiCall call;
  final bool center;

  @override
  Widget build(BuildContext context) {
    final m = call.lan;
    if (m == null) return const SizedBox.shrink();
    final t = Theme.of(context);
    final text = m.isHandoff
        ? (m.outgoing ? 'Handing over to ${m.peerName}' : m.handoffText)
        : m.intercom
            ? '${m.outgoing ? 'Intercom to' : 'Intercom from'} ${m.peerName.isEmpty ? 'a nearby device' : m.peerName}'
            : '${m.outgoing ? 'LAN call to' : 'LAN call from'} ${m.peerName.isEmpty ? 'an unpaired device' : m.peerName}';
    final icon = m.isHandoff ? Icons.swap_horiz_rounded : (m.intercom ? Icons.record_voice_over_rounded : Icons.lan_rounded);
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        key: const Key('lan-call-label'),
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: center ? MainAxisAlignment.center : MainAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: t.colorScheme.tertiary),
          const SizedBox(width: 6),
          Flexible(child: Text(text, textAlign: center ? TextAlign.center : TextAlign.start, style: t.textTheme.bodyMedium?.copyWith(color: t.colorScheme.tertiary, fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }
}

/// Owner side of a relayed call: "Relayed to ..." with Take back and End.
class RelayedBanner extends ConsumerWidget {
  const RelayedBanner({super.key, required this.call});
  final UiCall call;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(lanRelayProvider)[call.cid];
    if (s == null) return const SizedBox.shrink();
    final t = Theme.of(context);
    final impl = ref.read(lanHandoffImplProvider);
    final (title, subtitle) = switch (s.phase) {
      RelayPhase.relayed => ('Relayed to ${s.peerName}', 'The caller is talking to ${s.peerName}. You are not on the call.'),
      RelayPhase.dialing => ('Calling ${s.peerName}...', 'The caller stays connected while ${s.peerName} answers.'),
      RelayPhase.offering => ('Asking ${s.peerName}...', 'Waiting for them to accept the call.'),
      RelayPhase.consulting => ('Talking to ${s.peerName}', 'The caller is on hold. Complete the hand-off when ready.'),
      RelayPhase.takingBack => ('Taking the call back...', ''),
    };
    return Container(
      key: const Key('relayed-banner'),
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: t.colorScheme.tertiary.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(kRadius)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(Icons.swap_horiz_rounded, color: t.colorScheme.tertiary),
            const SizedBox(width: 8),
            Expanded(child: Text(title, style: t.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700))),
          ]),
          if (subtitle.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 4), child: Text(subtitle, style: t.textTheme.bodySmall)),
          if (s.phase == RelayPhase.relayed) ...[
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: FilledButton(key: const Key('relay-take-back'), onPressed: () => impl.takeBack(call.cid), child: const Text('Take back'))),
              const SizedBox(width: 8),
              OutlinedButton(
                key: const Key('relay-end'),
                style: OutlinedButton.styleFrom(foregroundColor: context.colors.endRed),
                onPressed: () => impl.endRelayed(call.cid),
                child: const Text('End'),
              ),
            ]),
          ],
        ],
      ),
    );
  }
}

/// Lets the user pick the target when several devices could take a call.
Future<LanDevice?> pickLanDevice(BuildContext context, List<LanDevice> devices) {
  if (devices.length == 1) return Future.value(devices.first);
  return showModalBottomSheet<LanDevice>(
    context: context,
    showDragHandle: true,
    builder: (ctx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: Align(alignment: Alignment.centerLeft, child: Text('Send to device', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600))),
          ),
          for (final d in devices)
            ListTile(
              leading: const Icon(Icons.devices_rounded),
              title: Text(d.name),
              subtitle: Text(d.busy ? 'On a call' : (d.online ? 'Available' : 'Offline')),
              enabled: d.online,
              onTap: () => Navigator.pop(ctx, d),
            ),
        ],
      ),
    ),
  );
}

/// Consumed by the incoming-call page "To device" button.
Future<void> forwardRingingToLan(BuildContext context, WidgetRef ref, int cid) async {
  final lan = ref.read(lanHandoffProvider);
  final online = lan.devices.where((d) => d.online).toList();
  if (online.isEmpty) {
    ref.read(noticeProvider.notifier).show('No paired device is online');
    return;
  }
  final d = await pickLanDevice(context, online);
  if (d != null) await ref.read(callsProvider.notifier).forwardIncomingToLan(cid, d);
}

