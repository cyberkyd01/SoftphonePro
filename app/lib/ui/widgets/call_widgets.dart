import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:spcore_dart/spcore_dart.dart';

import '../../core/format.dart';
import '../../core/theme.dart';
import '../../diagnostics/sip_trace_controller.dart';
import '../pages/diagnostics/quality_view.dart';
import '../../platform/lan_handoff.dart' show HandoffMode;
import '../../platform/platform_services.dart';
import '../../services/accounts_controller.dart';
import '../../services/calls_controller.dart';
import '../../services/contacts_controller.dart';
import '../../services/engine_controller.dart';
import '../../services/providers.dart';
import '../../services/settings_controller.dart';
import '../helpers.dart';
import '../../audio/device_labels.dart';
import '../pages/audio/audio_call_widgets.dart';
import '../pages/lan/lan_call_widgets.dart';
import 'basic_widgets.dart';
import 'caller_identity_block.dart';
import 'transfer_stalled_banner.dart';
import 'dial_pad.dart';
import 'settings_tiles.dart';

/// Live call timer, ticking once a second.
class CallTimer extends StatefulWidget {
  const CallTimer({super.key, required this.call, this.style});
  final UiCall call;
  final TextStyle? style;
  @override
  State<CallTimer> createState() => _CallTimerState();
}

class _CallTimerState extends State<CallTimer> {
  Timer? _t;
  @override
  void initState() {
    super.initState();
    _t = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _t?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.call;
    return Text(
      c.connectedAt == null ? '--:--' : formatDuration(c.duration),
      style: tabular(widget.style ?? Theme.of(context).textTheme.titleMedium),
    );
  }
}

final audioRouteProvider = StreamProvider<AudioRoute>((ref) async* {
  final p = ref.watch(platformServicesProvider);
  yield await p.getAudioRoute();
  yield* p.audioRouteChanges;
});

final audioDevicesProvider = FutureProvider.autoDispose<AudioDevices?>((ref) async {
  final ctl = ref.watch(engineProvider.notifier);
  ref.watch(deviceRevisionProvider);
  if (!ctl.hasEngine) return null;
  try {
    return await ctl.engine.audioDevices();
  } catch (_) {
    return null;
  }
});

// ---------------------------------------------------------------------------
// Call quality stats

class CallStatsPanel extends StatelessWidget {
  const CallStatsPanel({super.key, required this.call});
  final UiCall call;

  @override
  Widget build(BuildContext context) {
    final s = call.stats;
    final t = Theme.of(context);
    Widget cell(String k, String v) => SizedBox(
      width: 120,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(k, style: t.textTheme.labelSmall?.copyWith(color: t.colorScheme.onSurfaceVariant)),
          Text(v, style: tabular(t.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600))),
        ],
      ),
    );
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: t.colorScheme.surfaceContainerHigh.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(kRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            runSpacing: 10,
            children: [
              cell('Codec', s?.codec.isNotEmpty == true ? s!.codec : (call.info.codec.isEmpty ? '--' : call.info.codec)),
              cell('MOS', s == null || s.mos == 0 ? '--' : s.mos.toStringAsFixed(2)),
              cell('Jitter', s == null ? '--' : '${s.rx.jitterMs.toStringAsFixed(1)} ms'),
              cell('Packet loss', s == null ? '--' : '${s.rx.lossPct.toStringAsFixed(1)} %'),
              cell('Round trip', s == null ? '--' : '${s.rtt.lastMs.toStringAsFixed(0)} ms'),
              cell('Media', s == null ? '--' : (s.srtp ? 'SRTP' : 'RTP')),
            ],
          ),
          const SizedBox(height: 10),
          Text('MOS history', style: t.textTheme.labelSmall?.copyWith(color: t.colorScheme.onSurfaceVariant)),
          const SizedBox(height: 4),
          Sparkline(values: call.mosHistory),
        ],
      ),
    );
  }
}

void showStatsSheet(BuildContext context, int cid) {
  showModalBottomSheet<void>(
    context: context,
    constraints: const BoxConstraints(maxWidth: 560),
    builder: (_) => Consumer(
      builder: (context, ref, _) {
        final c = ref.watch(callsProvider).byCid(cid);
        if (c == null) return const SizedBox(height: 100);
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Call quality', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              CallStatsPanel(call: c),
            ],
          ),
        );
      },
    ),
  );
}

// ---------------------------------------------------------------------------
// In-call keypad (DTMF)

class InCallKeypad extends ConsumerStatefulWidget {
  const InCallKeypad({super.key, required this.cid, this.compact = false});
  final int cid;
  final bool compact;
  @override
  ConsumerState<InCallKeypad> createState() => _InCallKeypadState();
}

class _InCallKeypadState extends ConsumerState<InCallKeypad> {
  String sent = '';
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 36,
          child: Text(sent, style: tabular(Theme.of(context).textTheme.headlineSmall), maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
        DialPad(
          compact: widget.compact,
          maxWidth: 300,
          onDigit: (d) {
            setState(() => sent += d);
            ref.read(callsProvider.notifier).sendDtmf(widget.cid, d);
          },
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Sheets

Future<void> showTransferSheet(BuildContext context, int cid) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    constraints: const BoxConstraints(maxWidth: 560),
    // The sheet's own context: the call page's Scaffold has already consumed
    // the keyboard inset for its own context.
    builder: (sheetContext) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(sheetContext).bottom),
      child: TransferSheet(cid: cid),
    ),
  );
}

class TransferSheet extends ConsumerStatefulWidget {
  const TransferSheet({super.key, required this.cid});
  final int cid;
  @override
  ConsumerState<TransferSheet> createState() => _TransferSheetState();
}

class _TransferSheetState extends ConsumerState<TransferSheet> {
  final _ctl = TextEditingController();
  int _mode = 0; // 0 blind, 1 attended, 2 LAN
  bool _busy = false;

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  Future<void> _go() async {
    final n = _ctl.text.trim();
    if (n.isEmpty || _busy) return;
    setState(() => _busy = true);
    final calls = ref.read(callsProvider.notifier);
    if (_mode == 0) {
      final ok = await calls.transferBlind(widget.cid, n);
      if (ok && mounted) Navigator.pop(context);
    } else {
      final cid = await calls.startConsult(widget.cid, n);
      if (cid != null && mounted) Navigator.pop(context);
    }
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final contacts = ref.watch(contactsProvider);
    final lan = ref.watch(lanHandoffProvider);
    final favs = contacts.where((c) => c.addresses.isNotEmpty).take(8).toList();
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Transfer call', style: t.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 0, label: Text('Blind'), icon: Icon(Icons.call_made_rounded)),
                ButtonSegment(value: 1, label: Text('Attended'), icon: Icon(Icons.support_agent_rounded)),
                ButtonSegment(value: 2, label: Text('LAN', maxLines: 1, softWrap: false), icon: Icon(Icons.devices_rounded), tooltip: 'LAN device'),
              ],
              selected: {_mode},
              showSelectedIcon: false,
              onSelectionChanged: (s) => setState(() => _mode = s.first),
            ),
            const SizedBox(height: 12),
            if (_mode == 2) ...[
              if (!lan.available || lan.devices.isEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: t.colorScheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(kRadius),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.lan_rounded),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          lan.available
                              ? 'No paired SoftphonePro devices found on your network. Pair one on the LAN page.'
                              : 'Turn on LAN Link (Settings, LAN Link) to hand this call to another device on your network.',
                        ),
                      ),
                    ],
                  ),
                )
              else
                for (final d in lan.devices)
                  ListTile(
                    leading: const Icon(Icons.devices_rounded),
                    title: Text(d.name),
                    subtitle: Text(d.busy ? 'On a call' : (d.online ? 'Available' : 'Offline')),
                    enabled: d.online,
                    trailing: TextButton(
                      key: Key('lan-talk-first-${d.id}'),
                      onPressed: d.online
                          ? () async {
                              final calls = ref.read(callsProvider.notifier);
                              Navigator.pop(context);
                              await calls.handoffToLan(widget.cid, d, mode: HandoffMode.attended);
                            }
                          : null,
                      child: const Text('Talk first'),
                    ),
                    onTap: () async {
                      final calls = ref.read(callsProvider.notifier);
                      Navigator.pop(context);
                      await calls.handoffToLan(widget.cid, d);
                    },
                  ),
            ] else ...[
              Text(
                _mode == 0
                    ? 'Hands the caller over immediately. You are disconnected.'
                    : 'Puts the caller on hold and calls the target first. Complete the transfer once they answer.',
                style: t.textTheme.bodySmall?.copyWith(color: t.colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 12),
              TextField(
                key: const Key('transfer-number'),
                controller: _ctl,
                autofocus: true,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.go,
                onSubmitted: (_) => _go(),
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(labelText: 'Number or SIP address', prefixIcon: Icon(Icons.dialpad_rounded)),
              ),
              if (favs.isNotEmpty) ...[
                const SizedBox(height: 12),
                SizedBox(
                  height: 40,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: favs.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (_, i) => ActionChip(
                      avatar: Avatar(name: favs[i].displayName, size: 24),
                      label: Text(favs[i].displayName),
                      onPressed: () => setState(() => _ctl.text = favs[i].primary),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  key: Key(_mode == 0 ? 'transfer-blind' : 'transfer-attended'),
                  onPressed: _ctl.text.trim().isEmpty || _busy ? null : _go,
                  icon: Icon(_mode == 0 ? Icons.call_made_rounded : Icons.support_agent_rounded),
                  label: Text(_mode == 0 ? 'Transfer now' : 'Call and consult'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Asks for a park slot and dials it to retrieve the parked call.
Future<void> promptRetrieveParked(BuildContext context, WidgetRef ref) async {
  final slot = await promptText(context, title: 'Retrieve parked call', hint: 'Park slot, e.g. 701', keyboardType: TextInputType.phone);
  if (slot == null || slot.isEmpty) return;
  final sel = ref.read(dialAccountProvider);
  await ref.read(callsProvider.notifier).retrieveParked(slot, accountId: sel == kDirectAccountId ? null : sel);
}

Future<void> showMoreSheet(BuildContext context, int cid) {
  return showModalBottomSheet<void>(
    context: context,
    constraints: const BoxConstraints(maxWidth: 560),
    builder: (ctx) => Consumer(
      builder: (context, ref, _) {
        final c = ref.watch(callsProvider).byCid(cid);
        final calls = ref.read(callsProvider.notifier);
        final pad = <Widget>[
          ListTile(
            key: const Key('more-audio-devices'),
            leading: const Icon(Icons.headset_mic_rounded),
            title: Text(isMobilePlatform ? 'Audio output' : 'Audio devices'),
            subtitle: Text(isMobilePlatform ? 'Phone, speaker, Bluetooth, headset' : 'Choose microphone and speaker'),
            onTap: () {
              Navigator.pop(ctx);
              showAudioSheet(context);
            },
          ),
          const NoiseCancellationTile(),
          if (c != null)
            ListTile(
              leading: const Icon(Icons.local_parking_rounded),
              title: const Text('Park call'),
              subtitle: const Text('Transfer to the park feature code'),
              onTap: () {
                Navigator.pop(ctx);
                calls.park(cid);
              },
            ),
          ListTile(
            key: const Key('retrieve-parked'),
            leading: const Icon(Icons.local_parking_rounded),
            title: const Text('Retrieve parked call'),
            subtitle: const Text('Dial a park slot'),
            onTap: () {
              Navigator.pop(ctx);
              promptRetrieveParked(context, ref);
            },
          ),
          ListTile(
            leading: const Icon(Icons.dialpad_rounded),
            title: const Text('Send DTMF digits'),
            subtitle: const Text('Type a whole sequence, e.g. a PIN'),
            onTap: () async {
              Navigator.pop(ctx);
              final s = await promptText(context, title: 'Send DTMF', hint: '1234#', keyboardType: TextInputType.phone);
              if (s != null && s.isNotEmpty) calls.sendDtmf(cid, s);
            },
          ),
          ListTile(
            leading: const Icon(Icons.info_outline_rounded),
            title: const Text('Call info'),
            onTap: () {
              Navigator.pop(ctx);
              if (c != null) showCallInfo(context, c);
            },
          ),
          ListTile(
            leading: const Icon(Icons.graphic_eq_rounded),
            title: const Text('Call quality'),
            subtitle: const Text('Live MOS, jitter, loss and round-trip time'),
            onTap: () {
              Navigator.pop(ctx);
              showLiveQuality(context, cid);
            },
          ),
          ListTile(
            leading: const Icon(Icons.account_tree_outlined),
            title: const Text('SIP trace'),
            subtitle: const Text('Ladder diagram of this call'),
            onTap: () {
              Navigator.pop(ctx);
              if (c != null && c.info.callId.isNotEmpty) {
                ref.read(diagnosticsFocusProvider.notifier).focus(c.info.callId);
              }
              context.push('/settings/diagnostics');
            },
          ),
        ];
        return SafeArea(child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: pad)));
      },
    ),
  );
}

void showCallInfo(BuildContext context, UiCall c) {
  final i = c.info;
  final rows = <(String, String)>[
    ('Remote', i.remoteUri),
    ('Account', i.localUri),
    ('State', '${i.state.wire} (${i.stateCode} ${i.stateReason})'),
    ('Codec', i.codec.isEmpty ? '--' : i.codec),
    ('Secure', '${i.srtp ? 'SRTP' : 'RTP'} / ${i.secureSignaling ? 'TLS' : 'plain signalling'}'),
    ('Call-ID', i.callId),
  ];
  showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Call info'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final r in rows)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(width: 80, child: Text(r.$1, style: Theme.of(ctx).textTheme.bodySmall)),
                    Expanded(child: SelectableText(r.$2)),
                  ],
                ),
              ),
          ],
        ),
      ),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close'))],
    ),
  );
}

Future<void> showAudioSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    constraints: const BoxConstraints(maxWidth: 560),
    builder: (_) => const _AudioSheet(),
  );
}

class _AudioSheet extends ConsumerWidget {
  const _AudioSheet();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final platform = ref.watch(platformServicesProvider);
    final mobile = platform.ringsViaOs || isMobilePlatform;
    if (mobile) {
      final cur = ref.watch(audioRouteProvider).value ?? AudioRoute.earpiece;
      return FutureBuilder<Set<AudioRoute>>(
        future: platform.availableAudioRoutes(),
        builder: (context, snap) {
          final routes = snap.data ?? {AudioRoute.earpiece, AudioRoute.speaker};
          return SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final r in AudioRoute.values.where(routes.contains))
                  ListTile(
                    leading: Icon(_routeIcon(r)),
                    title: Text(_routeLabel(r)),
                    trailing: r == cur ? const Icon(Icons.check_rounded) : null,
                    onTap: () {
                      platform.setAudioRoute(r);
                      Navigator.pop(context);
                    },
                  ),
              ],
            ),
          );
        },
      );
    }
    final dev = ref.watch(audioDevicesProvider);
    final s = ref.watch(settingsProvider);
    return SafeArea(
      child: dev.when(
        loading: () => const SizedBox(height: 120, child: Center(child: CircularProgressIndicator())),
        error: (e, _) => Padding(padding: const EdgeInsets.all(24), child: Text('$e')),
        data: (d) {
          final outs = d?.playback ?? const <AudioDevice>[];
          final ins = d?.capture ?? const <AudioDevice>[];
          String defName(List<AudioDevice> l) => systemDefaultLabel(l);

          Widget header(String t) => Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
            child: Align(alignment: Alignment.centerLeft, child: Text(t, style: Theme.of(context).textTheme.titleMedium)),
          );
          Widget row(IconData icon, String name, bool on, String key, String id, String field) => ListTile(
            key: Key(key),
            leading: Icon(icon),
            title: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis),
            trailing: on ? const Icon(Icons.check_rounded) : null,
            onTap: () {
              ref.read(settingsProvider.notifier).update({field: id});
              Navigator.pop(context);
            },
          );
          return SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                header('Microphone'),
                row(Icons.mic_rounded, defName(ins), s.captureDev == 'default', 'in-dev-default', 'default', 'captureDev'),
                for (final o in ins.where((d) => d.devId != 'default')) row(Icons.mic_rounded, o.name, s.captureDev == o.devId, 'in-dev-${o.devId}', o.devId, 'captureDev'),
                header('Speaker'),
                row(Icons.speaker_rounded, defName(outs), s.playbackDev == 'default', 'out-dev-default', 'default', 'playbackDev'),
                for (final o in outs.where((d) => d.devId != 'default')) row(Icons.speaker_rounded, o.name, s.playbackDev == o.devId, 'out-dev-${o.devId}', o.devId, 'playbackDev'),
                const SizedBox(height: 8),
              ],
            ),
          );
        },
      ),
    );
  }
}

IconData _routeIcon(AudioRoute r) => switch (r) {
  AudioRoute.earpiece => Icons.phone_in_talk_rounded,
  AudioRoute.speaker => Icons.volume_up_rounded,
  AudioRoute.bluetooth => Icons.bluetooth_audio_rounded,
  AudioRoute.wired => Icons.headphones_rounded,
};
String _routeLabel(AudioRoute r) => switch (r) {
  AudioRoute.earpiece => 'Phone',
  AudioRoute.speaker => 'Speaker',
  AudioRoute.bluetooth => 'Bluetooth',
  AudioRoute.wired => 'Wired headset',
};

IconData audioRouteIcon(AudioRoute r) => _routeIcon(r);

// ---------------------------------------------------------------------------
// Call card (desktop panel and stacked cards)

class CallCard extends ConsumerStatefulWidget {
  const CallCard({super.key, required this.call, this.focused = false});
  final UiCall call;
  final bool focused;
  @override
  ConsumerState<CallCard> createState() => _CallCardState();
}

class _CallCardState extends ConsumerState<CallCard> {
  bool _keypad = false;
  bool _stats = false;

  @override
  Widget build(BuildContext context) {
    final c = widget.call;
    final calls = ref.read(callsProvider.notifier);
    final contacts = ref.watch(contactsProvider);
    final acc = ref.watch(accountsProvider);
    final t = Theme.of(context);
    final colors = context.colors;
    final title = callTitle(c, contacts);
    final profile = acc.byId(c.accountId);
    final state = ref.watch(callsProvider);
    final consult = c.consultOf != null;
    final others = state.ongoing.where((o) => o.cid != c.cid && o.isConfirmed).toList();

    Widget mini(IconData icon, String label, VoidCallback? onTap, {bool active = false, Color? color}) {
      return Semantics(
        button: true,
        toggled: active,
        label: label,
        excludeSemantics: true,
        child: Tooltip(
          message: label,
          child: Material(
            color: active ? (color ?? t.colorScheme.primary) : t.colorScheme.surfaceContainerHigh,
            shape: const CircleBorder(),
            child: InkResponse(
              onTap: onTap,
              customBorder: const CircleBorder(),
              child: SizedBox(
                width: 44,
                height: 44,
                child: Icon(icon, size: 20, color: active ? Colors.white : t.colorScheme.onSurface),
              ),
            ),
          ),
        ),
      );
    }

    return Semantics(
      container: true,
      label: 'Call with $title, ${callStateText(c)}',
      child: Container(
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: BorderRadius.circular(kRadius),
          border: Border.all(
            color: widget.focused ? t.colorScheme.primary : t.colorScheme.outlineVariant,
            width: widget.focused ? 1.6 : 1,
          ),
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () => calls.focus(c.cid),
              borderRadius: BorderRadius.circular(8),
              child: Row(
                children: [
                  Avatar(name: title, size: 44),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: t.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                        Text(
                          [if (title != c.number && c.number.isNotEmpty) c.number, if (profile != null) profile.name].join('  ·  '),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: t.textTheme.bodySmall?.copyWith(color: t.colorScheme.onSurfaceVariant),
                        ),
                        CallerIdentityBlock(call: c, title: title, center: false, dense: true, showNumber: false),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                callStateText(c),
                                style: t.textTheme.bodySmall?.copyWith(
                                  color: c.isHeld ? colors.holdAmber : (c.isConfirmed ? colors.callGreen : t.colorScheme.onSurfaceVariant),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            if (c.isConfirmed) ...[
                              const Text('  ·  '),
                              CallTimer(call: c, style: t.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (c.isConfirmed)
                    QualityIndicator(
                      mos: c.stats?.mos ?? 0,
                      onTap: () => setState(() => _stats = !_stats),
                    ),
                ],
              ),
            ),
            if (c.isConfirmed) ...[
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  SecureBadge(srtp: c.info.srtp, tls: c.info.secureSignaling),
                  const NoiseCancellationChip(),
                  if (c.recording)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.fiber_manual_record_rounded, size: 14, color: colors.endRed),
                        const SizedBox(width: 2),
                        Text('REC', style: t.textTheme.labelSmall?.copyWith(color: colors.endRed, fontWeight: FontWeight.w700)),
                      ],
                    ),
                ],
              ),
            ],
            LanCallLabel(call: c, center: false),
            RelayedBanner(call: c),
            TransferStalledBanner(call: c, margin: const EdgeInsets.only(top: 10)),
            AnnouncementChip(cid: c.cid),
            if (_stats && c.isConfirmed) ...[const SizedBox(height: 10), CallStatsPanel(call: c)],
            if (consult) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: t.colorScheme.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(kRadius),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Attended transfer: the original caller is on hold.', style: t.textTheme.bodySmall),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton(
                            key: const Key('complete-transfer'),
                            onPressed: c.isConfirmed ? () => calls.completeAttended(c.cid) : null,
                            child: const Text('Complete transfer'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton(
                          key: const Key('cancel-transfer'),
                          onPressed: () => calls.cancelConsult(c.cid),
                          child: const Text('Cancel'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 12),
            if (c.isRingingIn)
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => calls.answer(c.cid),
                      style: FilledButton.styleFrom(backgroundColor: colors.callGreen),
                      icon: const Icon(Icons.call_rounded),
                      label: const Text('Answer'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => calls.decline(c.cid),
                      style: FilledButton.styleFrom(backgroundColor: colors.endRed),
                      icon: const Icon(Icons.call_end_rounded),
                      label: const Text('Decline'),
                    ),
                  ),
                ],
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  mini(c.muted ? Icons.mic_off_rounded : Icons.mic_rounded, c.muted ? 'Unmute' : 'Mute', c.isConfirmed ? () => calls.toggleMute(c.cid) : null, active: c.muted),
                  mini(Icons.pause_rounded, c.isHeld ? 'Resume' : 'Hold', c.isConfirmed ? () => calls.toggleHold(c.cid) : null, active: c.isHeld, color: colors.holdAmber),
                  mini(Icons.dialpad_rounded, 'Keypad', c.isConfirmed ? () => setState(() => _keypad = !_keypad) : null, active: _keypad),
                  mini(Icons.phone_forwarded_rounded, 'Transfer', c.isConfirmed ? () => showTransferSheet(context, c.cid) : null),
                  mini(Icons.fiber_manual_record_rounded, c.recording ? 'Stop recording' : 'Record', c.isConfirmed ? () => calls.toggleRecording(c.cid) : null, active: c.recording, color: colors.endRed),
                  if (c.isConference)
                    mini(Icons.call_split_rounded, 'Split conference', () => calls.split(), active: true)
                  else if (others.isNotEmpty) ...[
                    mini(Icons.call_merge_rounded, 'Merge calls', () => calls.merge()),
                    mini(Icons.swap_calls_rounded, 'Swap calls', () => calls.swap()),
                  ],
                  mini(Icons.more_horiz_rounded, 'More', () => showMoreSheet(context, c.cid)),
                ],
              ),
            if (c.isConference && c.isConfirmed) const ConferenceLevels(),
            if (!c.isRingingIn) ...[
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  key: Key('card-end-${c.cid}'),
                  onPressed: () => calls.hangup(c.cid),
                  style: FilledButton.styleFrom(backgroundColor: colors.endRed, minimumSize: const Size(44, 40)),
                  icon: const Icon(Icons.call_end_rounded, size: 18),
                  label: const Text('End call'),
                ),
              ),
            ],
            if (_keypad && c.isConfirmed) ...[
              const SizedBox(height: 12),
              Center(child: InCallKeypad(cid: c.cid, compact: true)),
            ],
          ],
        ),
      ),
    );
  }
}

/// Desktop right-hand panel listing active calls.
class CallsPanel extends ConsumerWidget {
  const CallsPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(callsProvider);
    final calls = s.live.where((c) => !c.isRingingIn || c.waiting).toList();
    final t = Theme.of(context);
    return Container(
      width: 360,
      decoration: BoxDecoration(
        color: t.colorScheme.surface,
        border: Border(left: BorderSide(color: t.colorScheme.outlineVariant)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Row(
              children: [
                Icon(Icons.call_rounded, size: 18, color: context.colors.callGreen),
                const SizedBox(width: 8),
                Text('Active calls', style: t.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                const Spacer(),
                Text('${calls.length}', style: t.textTheme.labelLarge),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
              itemCount: calls.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) => CallCard(
                key: ValueKey(calls[i].cid),
                call: calls[i],
                focused: calls.length > 1 && s.focused?.cid == calls[i].cid,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Desktop in-app incoming call banners (top-right).
class IncomingBanners extends ConsumerWidget {
  const IncomingBanners({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(callsProvider);
    final ringing = s.ringing;
    if (ringing.isEmpty) return const SizedBox.shrink();
    final contacts = ref.watch(contactsProvider);
    final acc = ref.watch(accountsProvider);
    final t = Theme.of(context);
    final calls = ref.read(callsProvider.notifier);
    return Positioned(
      top: 12,
      right: 12,
      width: 380,
      child: Column(
        children: [
          for (final c in ringing)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Material(
                elevation: 8,
                shadowColor: Colors.black45,
                borderRadius: BorderRadius.circular(16),
                color: context.colors.raised,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          PulseRing(size: 44, child: Avatar(name: callTitle(c, contacts), size: 44)),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(c.waiting ? 'Call waiting' : 'Incoming call', style: t.textTheme.labelMedium?.copyWith(color: t.colorScheme.primary, fontWeight: FontWeight.w700)),
                                Text(callTitle(c, contacts), maxLines: 1, overflow: TextOverflow.ellipsis, style: t.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                                Text(
                                  [if (callTitle(c, contacts) != c.number) c.number, acc.byId(c.accountId)?.name ?? ''].where((e) => e.isNotEmpty).join('  ·  '),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: t.textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      CallerIdentityBlock(call: c, title: callTitle(c, contacts), center: false, dense: true, showNumber: false),
                      LanCallLabel(call: c, center: false),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: FilledButton.icon(
                              key: Key('banner-answer-${c.cid}'),
                              onPressed: () => calls.answer(c.cid),
                              style: FilledButton.styleFrom(backgroundColor: context.colors.callGreen),
                              icon: const Icon(Icons.call_rounded),
                              label: const Text('Answer'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: FilledButton.icon(
                              key: Key('banner-decline-${c.cid}'),
                              onPressed: () => calls.decline(c.cid),
                              style: FilledButton.styleFrom(backgroundColor: context.colors.endRed),
                              icon: const Icon(Icons.call_end_rounded),
                              label: const Text('Decline'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}


/// Per-party volume (rx) and microphone-to-party (tx) sliders for the calls
/// of a conference.
class ConferenceLevels extends ConsumerWidget {
  const ConferenceLevels({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final parties = ref.watch(callsProvider.select((s) => s.live.where((c) => c.isConference).toList()));
    final contacts = ref.watch(contactsProvider);
    if (parties.isEmpty) return const SizedBox.shrink();
    final t = Theme.of(context);
    return Container(
      key: const Key('conference-levels'),
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.colors.card,
        borderRadius: BorderRadius.circular(kRadius),
        border: Border.all(color: t.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Conference levels', style: t.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
          for (final c in parties) _PartyLevels(call: c, title: callTitle(c, contacts)),
        ],
      ),
    );
  }
}

class _PartyLevels extends ConsumerStatefulWidget {
  const _PartyLevels({required this.call, required this.title});
  final UiCall call;
  final String title;
  @override
  ConsumerState<_PartyLevels> createState() => _PartyLevelsState();
}

class _PartyLevelsState extends ConsumerState<_PartyLevels> {
  late double _rx = widget.call.rxLevel;
  late double _tx = widget.call.txLevel;

  @override
  Widget build(BuildContext context) {
    final cid = widget.call.cid;
    final calls = ref.read(callsProvider.notifier);
    final t = Theme.of(context);
    Widget row(Key k, IconData icon, String label, double v, ValueChanged<double> on, ValueChanged<double> end) => Row(
      children: [
        Icon(icon, size: 18, color: t.colorScheme.onSurfaceVariant),
        const SizedBox(width: 6),
        SizedBox(width: 62, child: Text(label, style: t.textTheme.labelSmall)),
        Expanded(
          child: Slider(
            key: k,
            value: v,
            min: 0,
            max: 2,
            divisions: 20,
            label: '${(v * 100).round()}%',
            semanticFormatterCallback: (x) => '${(x * 100).round()} percent',
            onChanged: on,
            onChangeEnd: end,
          ),
        ),
      ],
    );
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: t.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
          row(Key('party-rx-$cid'), Icons.volume_up_rounded, 'Volume', _rx, (v) => setState(() => _rx = v), (v) => calls.setPartyLevels(cid, rx: v)),
          row(Key('party-tx-$cid'), Icons.mic_rounded, 'Mic to party', _tx, (v) => setState(() => _tx = v), (v) => calls.setPartyLevels(cid, tx: v)),
        ],
      ),
    );
  }
}
