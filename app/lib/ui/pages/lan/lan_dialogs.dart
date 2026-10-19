import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lan_link/lan_link.dart' as ll;

import '../../../lan/lan_controller.dart';
import '../../../lan/lan_handoff_impl.dart';
import '../../../services/providers.dart';
import '../../router.dart';
import 'lan_widgets.dart';

/// Shows the 6-digit code on both devices; the user confirms or rejects.
class PairingDialog extends StatefulWidget {
  const PairingDialog({super.key, required this.session, this.isTrusted});
  final ll.PairingSession session;

  /// Whether [peerId] is stored as paired. lan_link can report `failed` for
  /// the side that finishes second (the other side closes the channel while
  /// it is still persisting) although the pairing was saved; trust wins.
  final bool Function(String peerId)? isTrusted;
  @override
  State<PairingDialog> createState() => _PairingDialogState();
}

class _PairingDialogState extends State<PairingDialog> {
  StreamSubscription<ll.PairingSession>? _sub;

  @override
  void initState() {
    super.initState();
    _sub = widget.session.updates.listen((_) {
      if (mounted) setState(() {});
    }, onDone: () {
      if (mounted) setState(() {});
    });
    widget.session.done.then((s) {
      if (!mounted) return;
      setState(() {});
      if (s.state == ll.PairingState.paired || (widget.isTrusted?.call(s.peerId) ?? false)) {
        Future.delayed(const Duration(milliseconds: 900), () {
          if (mounted && Navigator.of(context).canPop()) Navigator.of(context).pop();
        });
      }
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    if (!widget.session.isFinished) unawaited(widget.session.cancel());
    super.dispose();
  }

  String _failText(ll.PairingSession s) => switch (s.state) {
        ll.PairingState.rejected => s.failure == 'rejected by peer' ? '${s.peerName} rejected the pairing.' : 'Pairing rejected.',
        ll.PairingState.cancelled => 'Pairing cancelled.',
        ll.PairingState.timedOut => 'Pairing timed out. Try again.',
        _ => 'Pairing failed${s.failure == null ? '' : ': ${s.failure}'}',
      };

  @override
  Widget build(BuildContext context) {
    final s = widget.session;
    final t = Theme.of(context);
    final name = s.peerName.isEmpty ? 'this device' : s.peerName;
    final paired = s.state == ll.PairingState.paired ||
        (s.isFinished && s.state == ll.PairingState.failed && (widget.isTrusted?.call(s.peerId) ?? false));
    Widget body;
    List<Widget> actions;
    switch (paired ? ll.PairingState.paired : s.state) {
      case ll.PairingState.connecting:
        body = const Row(children: [SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5)), SizedBox(width: 14), Expanded(child: Text('Connecting securely...'))]);
        actions = [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel'))];
      case ll.PairingState.awaitingConfirm || ll.PairingState.confirmedLocally:
        final code = s.sas ?? '------';
        final spaced = '${code.substring(0, 3)} ${code.substring(3)}';
        final waiting = s.state == ll.PairingState.confirmedLocally;
        body = Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              s.incoming ? '$name wants to pair with this device.' : 'Pairing with $name.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text('Check that this code is the same on both screens.', textAlign: TextAlign.center, style: t.textTheme.bodySmall?.copyWith(color: t.colorScheme.onSurfaceVariant)),
            const SizedBox(height: 16),
            Semantics(
              label: 'Pairing code $code',
              child: Text(spaced, key: const Key('pair-sas'), style: t.textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w800, letterSpacing: 4, fontFeatures: const [FontFeature.tabularFigures()])),
            ),
            const SizedBox(height: 14),
            if (waiting)
              Row(mainAxisSize: MainAxisSize.min, children: [
                const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
                const SizedBox(width: 10),
                Flexible(child: Text('Waiting for $name to confirm...', style: t.textTheme.bodyMedium)),
              ])
            else if (s.remoteConfirmed)
              Text('$name has confirmed.', style: t.textTheme.bodyMedium?.copyWith(color: t.colorScheme.primary)),
          ],
        );
        actions = [
          TextButton(key: const Key('pair-reject'), onPressed: () async {
            await s.reject();
            if (context.mounted) Navigator.pop(context);
          }, child: const Text('Reject')),
          FilledButton(key: const Key('pair-confirm'), onPressed: waiting ? null : () => s.confirm(), child: const Text('Codes match')),
        ];
      case ll.PairingState.paired:
        body = Row(children: [Icon(Icons.check_circle_rounded, color: t.colorScheme.primary), const SizedBox(width: 12), Expanded(child: Text('Paired with $name.'))]);
        actions = [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Done'))];
      default:
        body = Row(children: [Icon(Icons.error_outline_rounded, color: t.colorScheme.error), const SizedBox(width: 12), Expanded(child: Text(_failText(s)))]);
        actions = [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))];
    }
    return AlertDialog(
      key: const Key('pairing-dialog'),
      title: Text(s.incoming ? 'Pairing request' : 'Pair with $name'),
      content: ConstrainedBox(constraints: const BoxConstraints(minWidth: 280, maxWidth: 360), child: body),
      actions: actions,
    );
  }
}

Future<void> showPairingDialog(BuildContext context, ll.PairingSession session, {bool Function(String)? isTrusted}) =>
    showDialog<void>(context: context, barrierDismissible: false, builder: (_) => PairingDialog(session: session, isTrusted: isTrusted));

/// Incoming file: name, size and who sent it.
class FileOfferDialog extends ConsumerStatefulWidget {
  const FileOfferDialog({super.key, required this.transfer});
  final ll.FileTransfer transfer;
  @override
  ConsumerState<FileOfferDialog> createState() => _FileOfferDialogState();
}

class _FileOfferDialogState extends ConsumerState<FileOfferDialog> {
  StreamSubscription<ll.FileTransfer>? _sub;

  @override
  void initState() {
    super.initState();
    // Sender cancelled while we were deciding: close.
    _sub = widget.transfer.updates.listen((t) {
      if (t.state != ll.TransferState.offered && mounted && Navigator.of(context).canPop()) Navigator.of(context).pop();
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.transfer;
    final lan = ref.read(lanControllerProvider.notifier);
    final from = lan.nameOf(t.peerId);
    return AlertDialog(
      key: const Key('file-offer-dialog'),
      title: const Text('Incoming file'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.insert_drive_file_rounded),
            const SizedBox(width: 12),
            Expanded(child: Text(t.name, style: const TextStyle(fontWeight: FontWeight.w600), maxLines: 2, overflow: TextOverflow.ellipsis)),
          ]),
          const SizedBox(height: 8),
          Text('${formatBytes(t.size)} from $from'),
        ],
      ),
      actions: [
        TextButton(
          key: const Key('file-decline'),
          onPressed: () {
            lan.declineFile(t);
            Navigator.pop(context);
          },
          child: const Text('Decline'),
        ),
        FilledButton(
          key: const Key('file-accept'),
          onPressed: () {
            lan.acceptFile(t);
            Navigator.pop(context);
          },
          child: const Text('Accept'),
        ),
      ],
    );
  }
}

/// "Alice's iPad wants to transfer a call to this device".
class HandoffOfferDialog extends ConsumerStatefulWidget {
  const HandoffOfferDialog({super.key, required this.offer});
  final ll.IncomingHandoff offer;
  @override
  ConsumerState<HandoffOfferDialog> createState() => _HandoffOfferDialogState();
}

class _HandoffOfferDialogState extends ConsumerState<HandoffOfferDialog> {
  Timer? _timer;
  StreamSubscription<String>? _sub;

  @override
  void initState() {
    super.initState();
    // The sender gives up after 30 s.
    _timer = Timer(const Duration(seconds: 30), () => _answer(false));
    _sub = ref.read(lanHandoffImplProvider).cancelledOffers.listen((id) {
      if (id == widget.offer.offer.handoffId && mounted && Navigator.of(context).canPop()) Navigator.of(context).pop();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _sub?.cancel();
    super.dispose();
  }

  void _answer(bool accept) {
    _timer?.cancel();
    unawaited(ref.read(lanHandoffImplProvider).respond(widget.offer, accept));
    if (mounted && Navigator.of(context).canPop()) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final o = widget.offer.offer;
    final from = widget.offer.peer.name;
    final who = o.caller.name.isNotEmpty ? '${o.caller.name} (${o.caller.number})' : o.caller.number;
    return AlertDialog(
      key: const Key('handoff-offer-dialog'),
      icon: const Icon(Icons.swap_horiz_rounded, size: 32),
      title: const Text('Transfer a call here?'),
      content: Text('$from wants to hand you a call${who.isEmpty ? '' : ' from $who'}${o.accountName.isEmpty ? '' : ' on ${o.accountName}'}.'
          '${o.attended ? ' They will talk to you first.' : ''}'),
      actions: [
        TextButton(key: const Key('handoff-decline'), onPressed: () => _answer(false), child: const Text('Decline')),
        FilledButton(key: const Key('handoff-accept'), onPressed: () => _answer(true), child: const Text('Take call')),
      ],
    );
  }
}

/// Pops LAN dialogs (pairing requests, file offers, hand-off offers) above
/// whatever page is showing, using the app's root navigator.
final lanUiCoordinatorProvider = Provider<void>((ref) {
  bool withContext(void Function(BuildContext) f) {
    final c = rootNavigatorKey.currentContext;
    if (c == null || !c.mounted) return false;
    f(c);
    return true;
  }

  final lan = ref.read(lanControllerProvider.notifier);
  final impl = ref.read(lanHandoffImplProvider);
  final subs = <StreamSubscription<dynamic>>[
    lan.pairingRequests.listen((s) => withContext((c) => showPairingDialog(c, s, isTrusted: (id) => lan.link?.peerById(id)?.trusted ?? false))),
    lan.incomingFileOffers.listen((t) {
      if (t.state != ll.TransferState.offered) return;
      withContext((c) => showDialog<void>(context: c, barrierDismissible: false, builder: (_) => FileOfferDialog(transfer: t)));
    }),
    impl.pendingOffers.listen((h) {
      final shown = withContext((c) => showDialog<void>(context: c, barrierDismissible: false, builder: (_) => HandoffOfferDialog(offer: h)));
      if (!shown) unawaited(impl.respond(h, false));
    }),
    lan.unpairedByPeer.listen((id) => ref.read(noticeProvider.notifier).show('${lan.nameOf(id)} removed this device from its paired list')),
  ];
  ref.onDispose(() {
    for (final s in subs) {
      s.cancel();
    }
  });
});
