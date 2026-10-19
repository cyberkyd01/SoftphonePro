import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lan_link/lan_link.dart' as ll;

import '../../../l10n/l10n.dart';
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
        // Close only this dialog's own route: a file offer that arrives right
        // after pairing may already sit on top of it.
        final route = ModalRoute.of(context);
        Future.delayed(const Duration(milliseconds: 900), () {
          if (mounted && route != null && route.isActive) Navigator.of(context).removeRoute(route);
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

  String _failText(AppLocalizations l, ll.PairingSession s) => switch (s.state) {
        ll.PairingState.rejected => s.failure == 'rejected by peer' ? l.lanPairRejectedBy(s.peerName) : l.lanPairRejected,
        ll.PairingState.cancelled => l.lanPairCancelled,
        ll.PairingState.timedOut => l.lanPairTimedOut,
        _ => s.failure == null ? l.lanPairFailed : l.lanPairFailedReason(s.failure!),
      };

  @override
  Widget build(BuildContext context) {
    final s = widget.session;
    final t = Theme.of(context);
    final l = context.l10n;
    final name = s.peerName.isEmpty ? l.lanPairThisDevice : s.peerName;
    final paired = s.state == ll.PairingState.paired ||
        (s.isFinished && s.state == ll.PairingState.failed && (widget.isTrusted?.call(s.peerId) ?? false));
    Widget body;
    List<Widget> actions;
    switch (paired ? ll.PairingState.paired : s.state) {
      case ll.PairingState.connecting:
        body = Row(children: [const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5)), const SizedBox(width: 14), Expanded(child: Text(l.lanPairConnecting))]);
        actions = [TextButton(onPressed: () => Navigator.pop(context), child: Text(l.actionCancel))];
      case ll.PairingState.awaitingConfirm || ll.PairingState.confirmedLocally:
        final code = s.sas ?? '------';
        final spaced = '${code.substring(0, 3)} ${code.substring(3)}';
        final waiting = s.state == ll.PairingState.confirmedLocally;
        body = Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              s.incoming ? l.lanPairWantsToPair(name) : l.lanPairPairingWith(name),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(l.lanPairCheckCode, textAlign: TextAlign.center, style: t.textTheme.bodySmall?.copyWith(color: t.colorScheme.onSurfaceVariant)),
            const SizedBox(height: 4),
            Text(l.lanPairIntercomNote, key: const Key('pair-intercom-note'), textAlign: TextAlign.center, style: t.textTheme.bodySmall?.copyWith(color: t.colorScheme.onSurfaceVariant)),
            const SizedBox(height: 16),
            Semantics(
              label: l.lanPairCodeSemantics(code),
              child: Text(spaced, textDirection: TextDirection.ltr, key: const Key('pair-sas'), style: t.textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w800, letterSpacing: 4, fontFeatures: const [FontFeature.tabularFigures()])),
            ),
            const SizedBox(height: 14),
            if (waiting)
              Row(mainAxisSize: MainAxisSize.min, children: [
                const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
                const SizedBox(width: 10),
                Flexible(child: Text(l.lanPairWaitingConfirm(name), style: t.textTheme.bodyMedium)),
              ])
            else if (s.remoteConfirmed)
              Text(l.lanPairRemoteConfirmed(name), style: t.textTheme.bodyMedium?.copyWith(color: t.colorScheme.primary)),
          ],
        );
        actions = [
          TextButton(key: const Key('pair-reject'), onPressed: () async {
            await s.reject();
            if (context.mounted) Navigator.pop(context);
          }, child: Text(l.lanPairReject)),
          FilledButton(key: const Key('pair-confirm'), onPressed: waiting ? null : () => s.confirm(), child: Text(l.lanPairCodesMatch)),
        ];
      case ll.PairingState.paired:
        body = Row(children: [Icon(Icons.check_circle_rounded, color: t.colorScheme.primary), const SizedBox(width: 12), Expanded(child: Text(l.lanPairPairedWith(name)))]);
        actions = [TextButton(onPressed: () => Navigator.pop(context), child: Text(l.actionDone))];
      default:
        body = Row(children: [Icon(Icons.error_outline_rounded, color: t.colorScheme.error), const SizedBox(width: 12), Expanded(child: Text(_failText(l, s)))]);
        actions = [TextButton(onPressed: () => Navigator.pop(context), child: Text(l.actionClose))];
    }
    return AlertDialog(
      key: const Key('pairing-dialog'),
      title: Text(s.incoming ? l.lanPairRequestTitle : l.lanPairTitle(name)),
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
    final l = context.l10n;
    return AlertDialog(
      key: const Key('file-offer-dialog'),
      title: Text(l.lanFileIncomingTitle),
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
          Text(l.lanFileSizeFrom(formatBytes(t.size), from)),
        ],
      ),
      actions: [
        TextButton(
          key: const Key('file-decline'),
          onPressed: () {
            lan.declineFile(t);
            Navigator.pop(context);
          },
          child: Text(l.lanActionDecline),
        ),
        FilledButton(
          key: const Key('file-accept'),
          onPressed: () {
            lan.acceptFile(t);
            Navigator.pop(context);
          },
          child: Text(l.lanActionAccept),
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
    final l = context.l10n;
    return AlertDialog(
      key: const Key('handoff-offer-dialog'),
      icon: const Icon(Icons.swap_horiz_rounded, size: 32),
      title: Text(l.lanHandoffOfferTitle),
      content: Text('${l.lanHandoffOfferBody(from, who.isEmpty ? 'none' : who, o.accountName.isEmpty ? 'none' : o.accountName)}'
          '${o.attended ? ' ${l.lanHandoffOfferAttended}' : ''}'),
      actions: [
        TextButton(key: const Key('handoff-decline'), onPressed: () => _answer(false), child: Text(l.lanActionDecline)),
        FilledButton(key: const Key('handoff-accept'), onPressed: () => _answer(true), child: Text(l.lanHandoffTakeCall)),
      ],
    );
  }
}

/// "Allow intercom from X?" (auto-denied by the controller after a few seconds).
class IntercomRequestDialog extends StatefulWidget {
  const IntercomRequestDialog({super.key, required this.request});
  final ll.IncomingIntercom request;

  @override
  State<IntercomRequestDialog> createState() => _IntercomRequestDialogState();
}

class _IntercomRequestDialogState extends State<IntercomRequestDialog> {
  Timer? _t;

  @override
  void initState() {
    super.initState();
    _t = Timer(LanController.intercomPromptTimeout, () {
      if (mounted) Navigator.of(context).pop();
    });
  }

  @override
  void dispose() {
    _t?.cancel();
    super.dispose();
  }

  void _answer(bool ok) {
    unawaited(widget.request.respond(ok, expiresSec: LanController.intercomGrantSeconds));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return AlertDialog(
      key: const Key('intercom-request-dialog'),
      icon: const Icon(Icons.record_voice_over_rounded, size: 32),
      title: Text(l.lanIntercomRequestTitle(widget.request.peer.name)),
      content: Text(l.lanIntercomRequestBody),
      actions: [
        TextButton(key: const Key('intercom-deny'), onPressed: () => _answer(false), child: Text(l.lanIntercomDeny)),
        FilledButton(key: const Key('intercom-allow'), onPressed: () => _answer(true), child: Text(l.lanIntercomAllow)),
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
  final fileOffers = FileOfferQueue(withContext: withContext);
  ref.onDispose(fileOffers.dispose);
  final subs = <StreamSubscription<dynamic>>[
    lan.pairingRequests.listen((s) => withContext((c) => showPairingDialog(c, s, isTrusted: (id) => lan.link?.peerById(id)?.trusted ?? false))),
    lan.incomingFileOffers.listen(fileOffers.add),
    impl.pendingOffers.listen((h) {
      final shown = withContext((c) => showDialog<void>(context: c, barrierDismissible: false, builder: (_) => HandoffOfferDialog(offer: h)));
      if (!shown) unawaited(impl.respond(h, false));
    }),
    lan.intercomPrompts.listen((req) {
      final shown = withContext((c) => showDialog<void>(context: c, barrierDismissible: false, builder: (_) => IntercomRequestDialog(request: req)));
      if (!shown) unawaited(req.respond(false));
    }),
    lan.unpairedByPeer.listen((id) => ref.read(noticeProvider.notifier).show(ref.read(l10nProvider).lanNoticeUnpairedByPeer(lan.nameOf(id)))),
  ];
  ref.onDispose(() {
    for (final s in subs) {
      s.cancel();
    }
  });
});

/// Shows incoming file offers one dialog at a time. An offer that arrives
/// before the navigator is ready (or while another offer's dialog is open)
/// waits in the queue; a repeated offer of a transfer that is still pending
/// re-shows its dialog unless that dialog is already on screen.
class FileOfferQueue {
  FileOfferQueue({
    required this.withContext,
    this.retry = const Duration(milliseconds: 300),
    this.maxWait = const Duration(seconds: 30),
  });

  final bool Function(void Function(BuildContext)) withContext;
  final Duration retry;
  final Duration maxWait;
  final List<ll.FileTransfer> _queue = [];
  String? _showing;
  Timer? _timer;
  DateTime? _since;
  bool _disposed = false;

  /// Transfer ids waiting for a dialog (not the one on screen).
  List<String> get queuedIds => [for (final t in _queue) t.id];
  String? get showingId => _showing;

  void add(ll.FileTransfer t) {
    if (_disposed || t.state != ll.TransferState.offered) return;
    if (_showing == t.id || _queue.any((e) => e.id == t.id)) return;
    _queue.add(t);
    _pump();
  }

  void _pump() {
    if (_disposed || _showing != null) return;
    while (_queue.isNotEmpty && _queue.first.state != ll.TransferState.offered) {
      _queue.removeAt(0);
    }
    if (_queue.isEmpty) {
      _since = null;
      return;
    }
    final t = _queue.first;
    Future<void>? shown;
    final ok = withContext((c) {
      shown = showDialog<void>(context: c, barrierDismissible: false, builder: (_) => FileOfferDialog(transfer: t));
    });
    if (!ok || shown == null) {
      // Navigator not ready yet: try again shortly, give up after maxWait.
      _since ??= DateTime.now();
      if (DateTime.now().difference(_since!) > maxWait) {
        _queue.removeAt(0);
        _since = null;
        _pump();
        return;
      }
      _timer?.cancel();
      _timer = Timer(retry, _pump);
      return;
    }
    _since = null;
    _queue.removeAt(0);
    _showing = t.id;
    unawaited(shown!.whenComplete(() {
      _showing = null;
      _pump();
    }));
  }

  void dispose() {
    _disposed = true;
    _timer?.cancel();
    _queue.clear();
  }
}
