import 'dart:async';
import 'dart:io';

import 'messages.dart';
import 'models.dart';
import 'peer_connection.dart';

enum PairingState {
  connecting,
  awaitingConfirm,
  confirmedLocally,
  paired,
  rejected,
  timedOut,
  cancelled,
  failed,
}

/// A pairing attempt (outgoing via `LanLink.pair`, incoming via
/// `LanLink.pairingRequests`). Show [sas] on screen; the user must confirm on
/// BOTH devices for pairing to complete.
class PairingSession {
  PairingSession.internal({
    required this.incoming,
    required this.peerId,
    required this.peerName,
    required this.timeout,
    required this.ownInfo,
    required this.persist,
    this.onPaired,
  });

  final bool incoming;
  String peerId;
  String peerName;
  final Duration timeout;
  final DeviceInfo Function() ownInfo;
  final Future<void> Function(String id, String name, List<int> edPub) persist;

  /// Called after trust was persisted, with the peer's reported info and the
  /// address of the pairing socket.
  final void Function(DeviceInfo? info, InternetAddress? address)? onPaired;

  /// Peer info received over the secure channel (null until it arrives).
  DeviceInfo? peerInfo;
  InternetAddress? get peerAddress => _conn?.remoteAddress;
  bool _finishing = false;
  bool _sentDone = false;
  bool _peerDone = false;

  PairingState state = PairingState.connecting;

  /// 6-digit short authentication string (null until the channel is up).
  String? sas;
  String? failure;

  /// True once the other user pressed confirm.
  bool remoteConfirmed = false;

  PeerConnection? _conn;
  bool _localOk = false;
  Timer? _timer;
  final _updates = StreamController<PairingSession>.broadcast();
  final _done = Completer<PairingSession>();

  Stream<PairingSession> get updates => _updates.stream;

  /// Completes (never with an error) when the session reaches a final state.
  Future<PairingSession> get done => _done.future;
  bool get isFinished => _done.isCompleted;
  bool get success => state == PairingState.paired;

  void _emit() {
    if (!_updates.isClosed) _updates.add(this);
  }

  void _finish(PairingState s, [String? why]) {
    if (isFinished) return;
    state = s;
    failure = why;
    _timer?.cancel();
    _emit();
    _done.complete(this);
    _updates.close();
  }

  /// Called by LanLink once the encrypted channel is established.
  void attach(PeerConnection conn) {
    if (isFinished) {
      unawaited(conn.close());
      return;
    }
    _conn = conn;
    peerId = conn.peerId;
    sas = conn.session.sas;
    state = PairingState.awaitingConfirm;
    conn.onMessage = _onMessage;
    conn.onChunk = (_) async {};
    conn.onClosed = (_) {
      // Both users confirmed: trust is being persisted, so a close from the
      // peer (which finished first) is not a failure.
      if (!isFinished && !_finishing) _finish(PairingState.failed, 'disconnected');
    };
    conn.start();
    conn.send(PeerInfoMsg(ownInfo())).catchError((_) {});
    _timer = Timer(timeout, () {
      if (isFinished) return;
      _conn
          ?.send(const PairConfirm(ok: false, reason: 'timeout'))
          .catchError((_) {});
      _finish(PairingState.timedOut, 'timeout');
      _closeSoon();
    });
    _emit();
  }

  /// Called by LanLink when connecting failed before the channel was up.
  void fail(String why) => _finish(PairingState.failed, why);

  void _onMessage(AppMessage m) {
    if (m is PairDone) {
      _peerDone = true;
      _maybeCloseAfterDone();
      return;
    }
    if (isFinished) return;
    if (m is PeerInfoMsg) {
      if (m.info.deviceId == peerId) {
        peerInfo = m.info;
        peerName = m.info.name.isEmpty ? peerId : m.info.name;
        _emit();
      }
    } else if (m is PairConfirm) {
      if (!m.ok) {
        if (m.reason == 'timeout') {
          _finish(PairingState.timedOut, 'timeout');
        } else if (m.reason == 'cancelled') {
          _finish(PairingState.cancelled, 'cancelled by peer');
        } else {
          _finish(PairingState.rejected, 'rejected by peer');
        }
        _closeSoon();
      } else {
        remoteConfirmed = true;
        _emit();
        unawaited(_maybeFinish());
      }
    }
  }

  /// The local user confirms the SAS matches.
  Future<void> confirm() async {
    if (state != PairingState.awaitingConfirm || _conn == null) return;
    _localOk = true;
    state = PairingState.confirmedLocally;
    _emit();
    try {
      await _conn!.send(const PairConfirm(ok: true));
    } catch (_) {
      _finish(PairingState.failed, 'disconnected');
      return;
    }
    await _maybeFinish();
  }

  /// The local user says the codes do not match / declines.
  Future<void> reject([String reason = 'rejected']) async {
    if (isFinished) return;
    try {
      await _conn?.send(PairConfirm(ok: false, reason: reason));
    } catch (_) {}
    _finish(PairingState.rejected, reason);
    _closeSoon();
  }

  /// Alias of [reject] for outgoing sessions.
  Future<void> cancel() async {
    if (isFinished) return;
    try {
      await _conn?.send(const PairConfirm(ok: false, reason: 'cancelled'));
    } catch (_) {}
    _finish(PairingState.cancelled, 'cancelled');
    _closeSoon();
  }

  Future<void> _maybeFinish() async {
    if (!_localOk || !remoteConfirmed || isFinished || _finishing) return;
    _finishing = true;
    final c = _conn!;
    try {
      await persist(
          c.peerId, peerName.isEmpty ? c.peerId : peerName, c.peerHello.edPub);
    } catch (e) {
      _finish(PairingState.failed, 'storage_error');
      _closeSoon();
      return;
    }
    _finish(PairingState.paired);
    try {
      onPaired?.call(peerInfo, peerAddress);
    } catch (_) {}
    _sentDone = true;
    c.send(const PairDone()).catchError((_) {});
    _maybeCloseAfterDone();
    // Safety net if the peer never acknowledges.
    Timer(const Duration(seconds: 3), () => c.close());
  }

  void _maybeCloseAfterDone() {
    if (_sentDone && _peerDone) _closeSoon();
  }

  void _closeSoon() {
    final c = _conn;
    if (c != null) {
      // Let queued frames (our confirm) flush before closing.
      Timer(const Duration(milliseconds: 50), () => c.close());
    }
  }
}
