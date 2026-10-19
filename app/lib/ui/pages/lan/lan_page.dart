import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lan_link/lan_link.dart' as ll;
import 'package:qr_flutter/qr_flutter.dart';

import '../../../core/theme.dart';
import '../../../lan/lan_controller.dart';
import '../../../lan/lan_models.dart';
import '../../../models/chat.dart';
import '../../../services/providers.dart';
import '../../../services/settings_controller.dart';
import '../../widgets/basic_widgets.dart';
import '../../widgets/qr_scanner_sheet.dart';
import '../../widgets/settings_tiles.dart';
import 'lan_dialogs.dart';
import 'lan_widgets.dart';

/// LAN Link: this device, paired and nearby devices, files and active calls.
class LanPage extends ConsumerStatefulWidget {
  const LanPage({super.key});
  @override
  ConsumerState<LanPage> createState() => _LanPageState();
}

class _LanPageState extends ConsumerState<LanPage> {
  Timer? _poll;
  final Set<String> _queried = {};

  @override
  void initState() {
    super.initState();
    _poll = Timer.periodic(const Duration(seconds: 6), (_) => _queryAll());
    WidgetsBinding.instance.addPostFrameCallback((_) => _queryAll());
  }

  @override
  void dispose() {
    _poll?.cancel();
    super.dispose();
  }

  /// Ask paired, online devices which calls they could hand to us.
  void _queryAll() {
    if (!mounted) return;
    final lan = ref.read(lanControllerProvider);
    for (final p in lan.paired.where((p) => p.online)) {
      ref.read(lanControllerProvider.notifier).requestCalls(p.deviceId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lan = ref.watch(lanControllerProvider);
    final settings = ref.watch(settingsProvider);
    final t = Theme.of(context);
    ref.listen<LanState>(lanControllerProvider, (prev, next) {
      for (final p in next.paired.where((p) => p.online && p.connected)) {
        if (_queried.add(p.deviceId)) ref.read(lanControllerProvider.notifier).requestCalls(p.deviceId);
      }
      _queried.removeWhere((id) => next.peer(id)?.connected != true);
    });

    final header = PageHeader(
      title: 'LAN Link',
      subtitle: 'Your devices, talking directly',
      actions: [
        if (lan.running)
          IconButton(key: const Key('lan-connect'), tooltip: 'Connect by address', onPressed: () => showManualConnect(context, ref), icon: const Icon(Icons.add_link_rounded)),
        IconButton(tooltip: 'LAN settings', onPressed: () => context.push('/settings/lan'), icon: const Icon(Icons.tune_rounded)),
      ],
    );

    if (!settings.lanEnabled) {
      return Column(children: [
        header,
        Expanded(
          child: EmptyState(
            icon: Icons.lan_rounded,
            title: 'LAN Link is off',
            subtitle: 'Find your other SoftphonePro devices, chat, drop files and hand calls over, without any server.',
            actionLabel: 'Turn on LAN Link',
            onAction: () => ref.read(settingsProvider.notifier).update({'lanEnabled': true}),
          ),
        ),
      ]);
    }

    final selfCard = _ThisDeviceCard(state: lan);
    final devices = _DevicesColumn(state: lan);
    return Column(
      children: [
        header,
        if (lan.error != null)
          Container(
            margin: const EdgeInsets.fromLTRB(16, 4, 16, 4),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: t.colorScheme.errorContainer, borderRadius: BorderRadius.circular(kRadius)),
            child: Row(children: [
              Icon(Icons.error_outline_rounded, color: t.colorScheme.onErrorContainer),
              const SizedBox(width: 10),
              Expanded(child: Text('LAN Link could not start: ${lan.error}', style: TextStyle(color: t.colorScheme.onErrorContainer))),
              TextButton(onPressed: () => ref.read(lanControllerProvider.notifier).restart(), child: const Text('Retry')),
            ]),
          ),
        Expanded(
          child: LayoutBuilder(builder: (context, box) {
            if (box.maxWidth >= 920) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(width: 360, child: ListView(padding: const EdgeInsets.fromLTRB(16, 8, 8, 24), children: [selfCard])),
                  Expanded(child: ListView(padding: const EdgeInsets.fromLTRB(8, 0, 16, 24), children: [devices])),
                ],
              );
            }
            return ListView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 24), children: [selfCard, devices]);
          }),
        ),
      ],
    );
  }
}

Future<void> showManualConnect(BuildContext context, WidgetRef ref) async {
  final ctl = TextEditingController();
  final text = await showDialog<String>(
    context: context,
    builder: (ctx) => AlertDialog(
      key: const Key('manual-connect-dialog'),
      title: const Text('Connect by address'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Type host:port, or paste the text of the QR code shown on the other device.'),
          const SizedBox(height: 12),
          TextField(
            key: const Key('manual-connect-field'),
            controller: ctl,
            autofocus: true,
            decoration: const InputDecoration(hintText: '192.168.1.20:4711', prefixIcon: Icon(Icons.link_rounded)),
            onSubmitted: (v) => Navigator.pop(ctx, v),
          ),
        ],
      ),
      actions: [
        TextButton(
          key: const Key('manual-connect-scan'),
          onPressed: () async {
            final code = await showQrScannerSheet(ctx, title: 'Scan LAN pairing QR', pasteHint: 'softphonepro://lan?... or host:port');
            if (code != null && ctx.mounted) Navigator.pop(ctx, code);
          },
          child: const Text('Scan QR'),
        ),
        TextButton(
          onPressed: () async {
            final d = await Clipboard.getData(Clipboard.kTextPlain);
            if (d?.text != null) ctl.text = d!.text!;
          },
          child: const Text('Paste'),
        ),
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        FilledButton(key: const Key('manual-connect-go'), onPressed: () => Navigator.pop(ctx, ctl.text), child: const Text('Connect')),
      ],
    ),
  );
  if (text == null || text.trim().isEmpty || !context.mounted) return;
  final lan = ref.read(lanControllerProvider.notifier);
  try {
    final peer = await lan.connectManual(text);
    if (!context.mounted) return;
    if (!peer.trusted) {
      await startPairing(context, ref, peer.deviceId);
    } else {
      ref.read(noticeProvider.notifier).show('Connected to ${peer.name}');
    }
  } on ll.LanLinkException catch (e) {
    ref.read(noticeProvider.notifier).error(e.message);
  } catch (e) {
    ref.read(noticeProvider.notifier).error('Could not connect', details: '$e');
  }
}

Future<void> startPairing(BuildContext context, WidgetRef ref, String peerId) async {
  try {
    final lan = ref.read(lanControllerProvider.notifier);
    final session = lan.pair(peerId);
    await showPairingDialog(context, session, isTrusted: (id) => lan.link?.peerById(id)?.trusted ?? false);
  } catch (e) {
    ref.read(noticeProvider.notifier).error('Could not start pairing', details: '$e');
  }
}

// ---------------------------------------------------------------------------

class _ThisDeviceCard extends ConsumerStatefulWidget {
  const _ThisDeviceCard({required this.state});
  final LanState state;
  @override
  ConsumerState<_ThisDeviceCard> createState() => _ThisDeviceCardState();
}

class _ThisDeviceCardState extends ConsumerState<_ThisDeviceCard> {
  bool _qr = false;

  @override
  Widget build(BuildContext context) {
    final st = widget.state;
    final t = Theme.of(context);
    final colors = context.colors;
    final self = st.self;
    final name = ref.read(lanControllerProvider.notifier).deviceName;
    final host = st.addresses.isNotEmpty ? st.addresses.first : null;
    final running = st.running;
    final payload = (self != null && host != null)
        ? LanTarget.encode(host: host, port: self.linkPort, deviceId: self.deviceId, name: self.name)
        : null;
    return Card(
      key: const Key('lan-this-device'),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Avatar(name: name, size: 48, icon: Icons.smartphone_rounded),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('This device', style: t.textTheme.labelMedium?.copyWith(color: t.colorScheme.onSurfaceVariant)),
                      Text(name, style: t.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Rename',
                  onPressed: () async {
                    final v = await promptText(context, title: 'Device name', initial: name, hint: 'This device');
                    if (v != null && v.trim().isNotEmpty) ref.read(settingsProvider.notifier).update({'lanDeviceName': v.trim()});
                  },
                  icon: const Icon(Icons.edit_rounded, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                _Pill(
                  icon: running ? Icons.wifi_tethering_rounded : Icons.wifi_tethering_off_rounded,
                  text: st.starting ? 'Starting...' : (running ? 'Visible on your network' : 'Not running'),
                  color: running ? colors.regOk : colors.disabled,
                ),
                if (host != null) _Pill(icon: Icons.router_rounded, text: host),
                if (self != null && self.sipPort > 0) _Pill(icon: Icons.call_rounded, text: 'SIP ${self.sipPort}'),
                if (self != null && self.aors.isNotEmpty) _Pill(icon: Icons.alternate_email_rounded, text: '${self.aors.length} account${self.aors.length == 1 ? '' : 's'} shared'),
              ],
            ),
            if (self != null) ...[
              const SizedBox(height: 10),
              Text('Fingerprint', style: t.textTheme.labelSmall?.copyWith(color: t.colorScheme.onSurfaceVariant)),
              SelectableText(fingerprintOf(self.deviceId), key: const Key('lan-fingerprint'), style: const TextStyle(fontFeatures: [FontFeature.tabularFigures()], fontWeight: FontWeight.w600)),
            ],
            if (payload != null) ...[
              const SizedBox(height: 6),
              TextButton.icon(
                key: const Key('lan-show-qr'),
                onPressed: () => setState(() => _qr = !_qr),
                icon: Icon(_qr ? Icons.expand_less_rounded : Icons.qr_code_2_rounded),
                label: Text(_qr ? 'Hide QR code' : 'Show QR code to connect another device'),
              ),
              if (_qr)
                Center(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                        child: QrImageView(data: payload, size: 180, backgroundColor: Colors.white),
                      ),
                      const SizedBox(height: 8),
                      SelectableText('$host:${self!.linkPort}', key: const Key('lan-address'), style: t.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                      TextButton(
                        onPressed: () async {
                          await Clipboard.setData(ClipboardData(text: payload));
                          ref.read(noticeProvider.notifier).show('Connection text copied');
                        },
                        child: const Text('Copy connection text'),
                      ),
                    ],
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.icon, required this.text, this.color});
  final IconData icon;
  final String text;
  final Color? color;
  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final c = color ?? t.colorScheme.onSurfaceVariant;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: c.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(999)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 14, color: c),
        const SizedBox(width: 6),
        Flexible(child: Text(text, style: t.textTheme.labelMedium?.copyWith(color: c, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis)),
      ]),
    );
  }
}

// ---------------------------------------------------------------------------

class _DevicesColumn extends ConsumerWidget {
  const _DevicesColumn({required this.state});
  final LanState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paired = state.paired;
    final nearby = state.nearby;
    final remote = [
      for (final e in state.remoteCalls.entries)
        for (final c in e.value) (peer: state.peer(e.key), call: c),
    ].where((e) => e.peer != null).toList();
    final transfers = state.transfers;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (remote.isNotEmpty) ...[
          const SectionHeader('Active on your other devices', padding: EdgeInsets.fromLTRB(4, 8, 4, 8)),
          for (final r in remote) _RemoteCallTile(peer: r.peer!, call: r.call),
        ],
        SectionHeader('Paired devices', padding: const EdgeInsets.fromLTRB(4, 8, 4, 8), trailing: Text('${paired.length}')),
        if (paired.isEmpty)
          const _Hint('No paired devices yet. Pair a nearby device to chat, send files and hand calls over.')
        else
          for (final p in paired) _DeviceTile(peer: p, typing: state.typing.contains(p.deviceId)),
        SectionHeader(
          'Nearby',
          padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
          trailing: state.running ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2)) : null,
        ),
        if (nearby.isEmpty)
          const _Hint('Looking for SoftphonePro on your network. Other devices need LAN Link turned on. You can also connect by address with the link button above.')
        else
          for (final p in nearby) _DeviceTile(peer: p),
        if (transfers.isNotEmpty) ...[
          const SectionHeader('Transfers', padding: EdgeInsets.fromLTRB(4, 16, 4, 8)),
          for (final t in transfers) _TransferTile(transfer: t),
        ],
        if (state.history.isNotEmpty) ...[
          SectionHeader(
            'Files',
            padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
            trailing: TextButton(onPressed: () => ref.read(lanControllerProvider.notifier).clearHistory(), child: const Text('Clear')),
          ),
          for (final h in state.history.take(20)) _FileTile(entry: h),
        ],
      ],
    );
  }
}

class _Hint extends StatelessWidget {
  const _Hint(this.text);
  final String text;
  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      child: Text(text, style: t.textTheme.bodyMedium?.copyWith(color: t.colorScheme.onSurfaceVariant)),
    );
  }
}

class _DeviceTile extends ConsumerWidget {
  const _DeviceTile({required this.peer, this.typing = false});
  final ll.LanPeer peer;
  final bool typing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Theme.of(context);
    final lan = ref.read(lanControllerProvider.notifier);
    final platform = peer.info?.platform ?? '';
    final online = peer.online;
    final sip = peer.hasSip && online;
    final intercomOk = sip && peer.canIntercom && (peer.info?.capabilities.contains(ll.Capability.intercom) ?? false);

    Widget action(Key key, IconData icon, String label, VoidCallback? onTap) => Tooltip(
          message: label,
          child: IconButton.filledTonal(key: key, onPressed: onTap, icon: Icon(icon, size: 20)),
        );

    return Card(
      key: Key('lan-device-${peer.deviceId}'),
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Avatar(name: peer.name, size: 44, icon: platformIcon(platform)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Flexible(child: Text(peer.name, style: t.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis)),
                        if (peer.trusted) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(color: t.colorScheme.primary.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6)),
                            child: Row(mainAxisSize: MainAxisSize.min, children: [
                              Icon(Icons.verified_user_rounded, size: 12, color: t.colorScheme.primary),
                              const SizedBox(width: 3),
                              Text('Paired', style: t.textTheme.labelSmall?.copyWith(color: t.colorScheme.primary, fontWeight: FontWeight.w700)),
                            ]),
                          ),
                        ],
                      ]),
                      const SizedBox(height: 2),
                      Row(children: [
                        Container(width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: statusColorOf(context, peer))),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            [typing ? 'typing...' : statusLabelOf(peer), if (peer.address != null && online) peer.address!.address].join('  ·  '),
                            style: t.textTheme.bodySmall?.copyWith(color: t.colorScheme.onSurfaceVariant),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ]),
                    ],
                  ),
                ),
                if (!peer.trusted)
                  FilledButton.icon(
                    key: Key('lan-pair-${peer.deviceId}'),
                    onPressed: () => startPairing(context, ref, peer.deviceId),
                    icon: const Icon(Icons.link_rounded, size: 18),
                    label: const Text('Pair'),
                  )
                else
                  PopupMenuButton<String>(
                    key: Key('lan-menu-${peer.deviceId}'),
                    tooltip: 'More',
                    onSelected: (v) async {
                      if (v == 'unpair') {
                        final ok = await confirm(context, title: 'Unpair ${peer.name}?', message: 'You will have to pair again to chat, send files or hand over calls.', confirmLabel: 'Unpair');
                        if (ok) await lan.unpair(peer.deviceId);
                      }
                    },
                    itemBuilder: (_) => [PopupMenuItem(key: Key('lan-unpair-${peer.deviceId}'), value: 'unpair', child: const Text('Unpair'))],
                  ),
              ],
            ),
            if (peer.trusted) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  action(Key('lan-msg-${peer.deviceId}'), Icons.chat_bubble_rounded, 'Message', () => context.push('/thread?acc=${peer.deviceId}&peer=${peer.deviceId}&ch=$kChannelLan')),
                  action(Key('lan-file-${peer.deviceId}'), Icons.attach_file_rounded, 'Send file', online ? () => pickAndSendLanFile(context, ref, peer.deviceId) : null),
                  action(Key('lan-call-${peer.deviceId}'), Icons.call_rounded, 'Call', sip ? () => lan.callPeer(peer.deviceId) : null),
                  action(Key('lan-intercom-${peer.deviceId}'), Icons.record_voice_over_rounded, 'Intercom', intercomOk ? () => lan.callPeer(peer.deviceId, intercom: true) : null),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _RemoteCallTile extends ConsumerWidget {
  const _RemoteCallTile({required this.peer, required this.call});
  final ll.LanPeer peer;
  final ll.CallSummary call;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Theme.of(context);
    final who = call.remoteName.isNotEmpty ? call.remoteName : (call.remoteNumber.isNotEmpty ? call.remoteNumber : 'Unknown');
    return Card(
      key: Key('lan-remote-call-${peer.deviceId}-${call.callId}'),
      margin: const EdgeInsets.only(bottom: 8),
      color: t.colorScheme.primaryContainer.withValues(alpha: 0.5),
      child: ListTile(
        leading: Icon(Icons.phone_in_talk_rounded, color: context.colors.callGreen),
        title: Text('$who  ·  ${call.remoteNumber}'.replaceAll(RegExp(r'\s+·\s+$'), ''), maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text('Active on ${peer.name}${call.accountName.isEmpty ? '' : '  ·  ${call.accountName}'}'),
        trailing: FilledButton(
          key: Key('lan-pull-${peer.deviceId}-${call.callId}'),
          onPressed: () => ref.read(lanControllerProvider.notifier).pull(peer.deviceId, call),
          child: const Text('Pull'),
        ),
      ),
    );
  }
}

class _TransferTile extends ConsumerWidget {
  const _TransferTile({required this.transfer});
  final ll.FileTransfer transfer;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Theme.of(context);
    final lan = ref.read(lanControllerProvider.notifier);
    ref.watch(lanControllerProvider.select((s) => s.rev));
    final st = transfer.state;
    final waiting = st == ll.TransferState.offered || st == ll.TransferState.preparing;
    final status = switch (st) {
      ll.TransferState.preparing => 'Preparing...',
      ll.TransferState.offered => transfer.incoming ? 'Waiting for you' : 'Waiting for ${lan.nameOf(transfer.peerId)} to accept',
      ll.TransferState.transferring => '${formatBytes(transfer.bytesDone)} of ${formatBytes(transfer.size)}',
      ll.TransferState.verifying => 'Verifying...',
      _ => st.name,
    };
    return Card(
      key: Key('lan-transfer-${transfer.id}'),
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 10, 6, 10),
        child: Row(
          children: [
            Icon(transfer.incoming ? Icons.download_rounded : Icons.upload_rounded, color: t.colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(transfer.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600)),
                  Text('${transfer.incoming ? 'From' : 'To'} ${lan.nameOf(transfer.peerId)}  ·  $status', style: t.textTheme.bodySmall?.copyWith(color: t.colorScheme.onSurfaceVariant)),
                  const SizedBox(height: 6),
                  LinearProgressIndicator(value: waiting ? null : transfer.progress.clamp(0.0, 1.0), minHeight: 4, borderRadius: BorderRadius.circular(2)),
                ],
              ),
            ),
            IconButton(tooltip: 'Cancel', onPressed: () => lan.cancelTransfer(transfer), icon: const Icon(Icons.close_rounded)),
          ],
        ),
      ),
    );
  }
}

class _FileTile extends ConsumerWidget {
  const _FileTile({required this.entry});
  final LanFileEntry entry;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Theme.of(context);
    final ops = ref.read(lanFileOpsProvider);
    return Card(
      key: Key('lan-file-entry-${entry.id}'),
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(entry.ok ? (entry.incoming ? Icons.download_done_rounded : Icons.upload_file_rounded) : Icons.error_outline_rounded, color: entry.ok ? t.colorScheme.primary : t.colorScheme.error),
        title: Text(entry.name, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(entry.ok
            ? '${formatBytes(entry.size)}  ·  ${entry.incoming ? 'from' : 'to'} ${entry.peerName}'
            : 'Failed: ${entry.error}'),
        trailing: entry.ok && entry.incoming && entry.path.isNotEmpty
            ? PopupMenuButton<String>(
                tooltip: 'File actions',
                onSelected: (v) async {
                  if (v == 'copy') {
                    await Clipboard.setData(ClipboardData(text: entry.path));
                    ref.read(noticeProvider.notifier).show('Path copied');
                  } else {
                    await openLanFile(context, ref, entry.path, reveal: v == 'reveal');
                  }
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(value: 'open', child: Text('Open')),
                  if (ops.isDesktop) const PopupMenuItem(value: 'reveal', child: Text('Show in folder')),
                  const PopupMenuItem(value: 'copy', child: Text('Copy path')),
                ],
              )
            : null,
      ),
    );
  }
}
