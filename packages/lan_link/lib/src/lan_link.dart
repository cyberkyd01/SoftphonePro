import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:meta/meta.dart';

import 'crypto.dart';
import 'discovery.dart';
import 'file_transfer.dart';
import 'identity.dart';
import 'messages.dart';
import 'models.dart';
import 'multicast_discovery.dart';
import 'pairing.dart';
import 'peer_connection.dart';
import 'trust.dart';
import 'util.dart';

class LanLinkConfig {
  LanLinkConfig({
    required this.deviceName,
    required this.platform,
    required this.downloadsDir,
    this.appVersion = '',
    this.linkPort = 0,
    this.sipPort = 0,
    this.discoveryProviders,
    KeyStore? keyStore,
    TrustStore? trustStore,
    this.allowedCapabilities = const {
      Capability.chat,
      Capability.files,
      Capability.handoff,
      Capability.intercom
    },
    this.aors = const [],
    this.maxFileSize = 4 * 1024 * 1024 * 1024,
    this.autoAcceptFile,
    this.keepConnected = true,
    this.bindAddress,
    this.pairingTimeout = const Duration(seconds: 120),
    this.handoffTimeout = const Duration(seconds: 45),
    this.acceptIncomingPairing = true,
  })  : keyStore = keyStore ?? InMemoryKeyStore(),
        trustStore = trustStore ?? InMemoryTrustStore();

  final String deviceName;
  final String platform;
  final String downloadsDir;
  final String appVersion;

  /// 0 = random free port.
  final int linkPort;

  /// LAN SIP UDP port advertised to peers (0 = none).
  final int sipPort;

  /// null = a default [MulticastDiscovery]. Pass `[]` for none. A
  /// [ManualDiscovery] is always added internally.
  final List<DiscoveryProvider>? discoveryProviders;
  final KeyStore keyStore;
  final TrustStore trustStore;
  final Set<Capability> allowedCapabilities;

  /// Registered AORs to advertise (only pass these if the user opted in).
  final List<String> aors;
  final int maxFileSize;

  /// Return true to accept an incoming file offer without asking.
  final bool Function(LanPeer peer, FileTransfer offer)? autoAcceptFile;

  /// Keep connections to online trusted peers (reconnect with backoff).
  final bool keepConnected;
  final InternetAddress? bindAddress;
  final Duration pairingTimeout;
  final Duration handoffTimeout;
  final bool acceptIncomingPairing;
}

/// Snapshot of a known peer.
class LanPeer {
  LanPeer({
    required this.deviceId,
    required this.name,
    required this.info,
    required this.trusted,
    required this.online,
    required this.connected,
    required this.lastSeen,
    required this.address,
  });

  final String deviceId;
  final String name;

  /// Latest public info (null for a trusted peer never seen this session).
  final DeviceInfo? info;
  final bool trusted;
  final bool online;
  final bool connected;
  final DateTime? lastSeen;
  final InternetAddress? address;

  PeerStatus get status => info?.status ?? PeerStatus.available;
  int get linkPort => info?.linkPort ?? 0;

  @override
  String toString() =>
      'LanPeer($deviceId $name trusted=$trusted online=$online connected=$connected)';
}

enum ChatStatus { queued, sending, sent, delivered, read, failed }

class ChatMessage {
  ChatMessage({
    required this.id,
    required this.peerId,
    required this.text,
    required this.ts,
    required this.incoming,
    this.replyTo,
    this.status = ChatStatus.sent,
  });
  final String id;
  final String peerId;
  final String text;
  final int ts;
  final bool incoming;
  final String? replyTo;
  ChatStatus status;

  @override
  String toString() =>
      'ChatMessage($id ${incoming ? "<-" : "->"} $peerId $status)';
}

class TypingEvent {
  TypingEvent(this.peerId, this.typing);
  final String peerId;
  final bool typing;
}

enum HandoffOutcome { accepted, declined, cancelled, timeout, failed }

class HandoffResult {
  HandoffResult(this.outcome, [this.reason]);
  final HandoffOutcome outcome;
  final String? reason;
  bool get accepted => outcome == HandoffOutcome.accepted;
  @override
  String toString() => 'HandoffResult($outcome, $reason)';
}

/// An incoming handoff offer awaiting a local decision.
class IncomingHandoff {
  IncomingHandoff._(this._link, this.peer, this.offer);
  final LanLink _link;
  final LanPeer peer;
  final HandoffOffer offer;
  bool cancelled = false;
  bool answered = false;

  Future<void> accept() => _answer(HandoffAccept(offer.handoffId));
  Future<void> decline([String reason = 'declined']) =>
      _answer(HandoffDecline(offer.handoffId, reason));

  Future<void> _answer(AppMessage m) async {
    if (answered || cancelled) return;
    answered = true;
    _link._incomingHandoffs.remove('${peer.deviceId}/${offer.handoffId}');
    await _link._send(peer.deviceId, m, connect: false);
  }
}

enum HandoffEventKind { cancelled, completed }

class HandoffEvent {
  HandoffEvent(this.peerId, this.handoffId, this.kind);
  final String peerId;
  final String handoffId;
  final HandoffEventKind kind;
}

class IncomingCallsQuery {
  IncomingCallsQuery._(this._link, this.peer);
  final LanLink _link;
  final LanPeer peer;
  Future<void> respond(List<CallSummary> calls) =>
      _link.sendCallsList(peer.deviceId, calls);
}

class CallsListEvent {
  CallsListEvent(this.peer, this.calls);
  final LanPeer peer;
  final List<CallSummary> calls;
}

class PullRequest {
  PullRequest(this.peer, this.callId);
  final LanPeer peer;
  final String callId;
}

class IntercomEvent {
  IntercomEvent(this.peer, this.allowed);
  final LanPeer peer;
  final bool? allowed;
}

/// Result of [LanLink.requestIntercom].
class IntercomGrant {
  IntercomGrant(this.allowed, this.expiresAt);
  final bool allowed;
  final DateTime expiresAt;
  bool get valid => allowed && DateTime.now().isBefore(expiresAt);
}

/// A negotiated intercom request from a peer. Call [respond] once.
class IncomingIntercom {
  IncomingIntercom._(this._link, this.peer, this.requestId);
  final LanLink _link;
  final LanPeer peer;
  final String requestId;
  bool answered = false;

  /// Allows (for [expiresSec] seconds, 1..300) or denies. Untrusted peers are
  /// always denied.
  Future<void> respond(bool allowed, {int expiresSec = 30}) async {
    if (answered) return;
    answered = true;
    final ok = allowed && peer.trusted;
    final secs = expiresSec.clamp(1, 300);
    if (ok) {
      _link._intercomGrants[peer.deviceId] =
          DateTime.now().add(Duration(seconds: secs));
    }
    await _link._send(
        peer.deviceId,
        IntercomResponse(
            requestId: requestId, allowed: ok, expiresSec: ok ? secs : 0),
        connect: false);
  }
}

class _PeerState {
  DeviceInfo? info;
  InternetAddress? address;
  DateTime? lastSeen;
  bool online = false;
  bool manual = false;
  int failures = 0;
  DateTime nextAttempt = DateTime.fromMillisecondsSinceEpoch(0);
}

class _Queued {
  _Queued(this.msg, this.at);
  final ChatMessage msg;
  final DateTime at;
}

/// High-level facade. See PROTOCOL.md.
class LanLink {
  LanLink(this.config);

  final LanLinkConfig config;

  late LocalIdentity _identity;
  late DeviceInfo _info;
  late FileEngine _files;
  LanLinkServer? _server;
  CompositeDiscovery? _discovery;
  ManualDiscovery? _manual;
  StreamSubscription<DiscoveryEvent>? _discSub;
  StreamSubscription<FileTransfer>? _fileSub;
  Timer? _maintTimer;
  bool _started = false;

  final Map<String, _PeerState> _peers = {};
  final Map<String, TrustedPeer> _trusted = {};
  final Map<String, PeerConnection> _conns = {};
  final Set<PeerConnection> _retired = {};
  final Map<String, Future<PeerConnection>> _connecting = {};
  final Map<String, Completer<HandoffResult>> _handoffWaiters = {};
  final Map<String, IncomingHandoff> _incomingHandoffs = {};
  final Map<String, ChatMessage> _sentChats = {};
  final Map<String, List<_Queued>> _outbox = {};
  final Set<String> _seenChatIds = {};
  final Map<String, PeerConnection> _sentVia = {};
  final Set<String> _queueable = {};
  final Map<String, Completer<IntercomGrant>> _intercomWaiters = {};
  final Map<String, DateTime> _intercomGrants = {};
  final List<PairingSession> _pairings = [];
  final Map<String, RateLimiter> _pairLimits = {};
  final Map<String, RateLimiter> _connLimits = {};
  int _pendingHandshakes = 0;

  final _peersCtrl = StreamController<List<LanPeer>>.broadcast();
  final _chatCtrl = StreamController<ChatMessage>.broadcast();
  final _typingCtrl = StreamController<TypingEvent>.broadcast();
  final _fileCtrl = StreamController<FileTransfer>.broadcast();
  final _pairReqCtrl = StreamController<PairingSession>.broadcast();
  final _handoffCtrl = StreamController<IncomingHandoff>.broadcast();
  final _handoffEvtCtrl = StreamController<HandoffEvent>.broadcast();
  final _queryCtrl = StreamController<IncomingCallsQuery>.broadcast();
  final _listCtrl = StreamController<CallsListEvent>.broadcast();
  final _pullCtrl = StreamController<PullRequest>.broadcast();
  final _intercomCtrl = StreamController<IntercomEvent>.broadcast();
  final _intercomReqCtrl = StreamController<IncomingIntercom>.broadcast();
  final _unpairedCtrl = StreamController<String>.broadcast();

  // ---- public streams -----------------------------------------------------

  Stream<List<LanPeer>> get peers => _peersCtrl.stream;
  Stream<ChatMessage> get chatMessages => _chatCtrl.stream;
  Stream<TypingEvent> get typingEvents => _typingCtrl.stream;

  /// New transfers (incoming offers and outgoing sends).
  Stream<FileTransfer> get fileTransfers => _fileCtrl.stream;
  Stream<PairingSession> get pairingRequests => _pairReqCtrl.stream;
  Stream<IncomingHandoff> get handoffOffers => _handoffCtrl.stream;
  Stream<HandoffEvent> get handoffEvents => _handoffEvtCtrl.stream;
  Stream<IncomingCallsQuery> get callsQueries => _queryCtrl.stream;
  Stream<CallsListEvent> get callsLists => _listCtrl.stream;
  Stream<PullRequest> get pullRequests => _pullCtrl.stream;

  /// Legacy (non-negotiated) intercom messages.
  Stream<IntercomEvent> get intercomRequests => _intercomCtrl.stream;

  /// Negotiated intercom requests awaiting `respond()`.
  Stream<IncomingIntercom> get intercomNegotiations => _intercomReqCtrl.stream;

  /// deviceId of a peer that removed us (their `pair.revoke`).
  Stream<String> get unpairedByPeer => _unpairedCtrl.stream;

  String get deviceId => _identity.deviceId;
  DeviceInfo get info => _info;
  int get linkPort => _server!.boundPort;
  bool get isStarted => _started;

  List<LanPeer> get currentPeers {
    final ids = {
      ..._trusted.keys,
      ..._peers.entries.where((e) => e.value.online).map((e) => e.key),
      ..._conns.keys
    };
    final out = ids.map(_peerSnapshot).toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return out;
  }

  LanPeer? peerById(String id) {
    if (!_trusted.containsKey(id) &&
        !_peers.containsKey(id) &&
        !_conns.containsKey(id)) {
      return null;
    }
    return _peerSnapshot(id);
  }

  LanPeer _peerSnapshot(String id) {
    final ps = _peers[id];
    final t = _trusted[id];
    final conn = _conns[id];
    final connected = conn != null && !conn.isClosed;
    return LanPeer(
      deviceId: id,
      name: ps?.info?.name ?? t?.name ?? id,
      info: ps?.info,
      trusted: t != null,
      online: connected || (ps?.online ?? false),
      connected: connected,
      lastSeen: ps?.lastSeen,
      address: ps?.address ?? conn?.remoteAddress,
    );
  }

  void _emitPeers() {
    if (!_peersCtrl.isClosed) _peersCtrl.add(currentPeers);
  }

  // ---- lifecycle ----------------------------------------------------------

  Future<void> start() async {
    if (_started) return;
    _identity = await LocalIdentity.loadOrCreate(config.keyStore);
    for (final t in await config.trustStore.list()) {
      _trusted[t.deviceId] = t;
    }
    await Directory(config.downloadsDir).create(recursive: true);
    _files = FileEngine(
      downloadsDir: config.downloadsDir,
      maxFileSize: config.maxFileSize,
      sendMessage: (id, m) => _send(id, m, connect: m is FileOffer),
      sendChunk: (id, c) => _sendChunk(id, c),
    );
    unawaited(_files.cleanPartials());
    _fileSub = _files.transfers.listen(_onNewTransfer);

    _info = DeviceInfo(
      deviceId: _identity.deviceId,
      name: config.deviceName,
      platform: config.platform,
      linkPort: 0,
      sipPort: config.sipPort,
      ed25519Pub: _identity.edPub,
      x25519Pub: _identity.xPub,
      appVersion: config.appVersion,
      aors: config.aors,
      capabilities: config.allowedCapabilities,
    );
    final server = _server = LanLinkServer(
      infoProvider: () => _info.toJson(),
      onSocket: _onIncomingSocket,
      bindAddress: config.bindAddress,
      port: config.linkPort,
    );
    await server.start();
    _info = _info.copyWith(linkPort: server.boundPort);

    _manual = ManualDiscovery();
    final providers = [
      ...(config.discoveryProviders ?? [MulticastDiscovery()]),
      _manual!
    ];
    final disc = _discovery = CompositeDiscovery(providers);
    _discSub = disc.events.listen(_onDiscovery);
    disc.announce(_info);
    _started = true;
    await disc.start();
    _maintTimer =
        Timer.periodic(const Duration(seconds: 3), (_) => _maintain());
    _emitPeers();
  }

  Future<void> stop() async {
    if (!_started) return;
    _started = false;
    _maintTimer?.cancel();
    await _discSub?.cancel();
    await _discovery?.stop();
    await _server?.stop();
    for (final s in _pairings.toList()) {
      await s.cancel();
    }
    for (final c in _conns.values.toList()) {
      await c.close(1001, 'shutdown');
    }
    _conns.clear();
    for (final c in _retired.toList()) {
      await c.close(1001, 'shutdown');
    }
    _retired.clear();
    await _files.dispose();
    await _fileSub?.cancel();
    for (final w in _handoffWaiters.values) {
      if (!w.isCompleted)
        w.complete(HandoffResult(HandoffOutcome.failed, 'shutdown'));
    }
    _handoffWaiters.clear();
    _peers.clear();
  }

  // ---- discovery ----------------------------------------------------------

  void _onDiscovery(DiscoveryEvent e) {
    if (e.deviceId == _identity.deviceId) return;
    switch (e.type) {
      case DiscoveryEventType.found:
      case DiscoveryEventType.updated:
        if (e.info != null) _applyInfo(e.info!, e.address);
      case DiscoveryEventType.lost:
        final ps = _peers[e.deviceId];
        if (ps != null) {
          ps.online = false;
          if (!_trusted.containsKey(e.deviceId) &&
              !_conns.containsKey(e.deviceId)) {
            _peers.remove(e.deviceId);
          }
          _emitPeers();
        }
    }
  }

  void _applyInfo(DeviceInfo info, InternetAddress? address) {
    if (info.deviceId == _identity.deviceId) return;
    final ps = _peers.putIfAbsent(info.deviceId, () => _PeerState());
    ps.info = info;
    if (address != null) ps.address = address;
    ps.online = true;
    ps.lastSeen = DateTime.now();
    _emitPeers();
    _maintain();
  }

  /// Adds a peer by address (e.g. scanned from a QR code).
  Future<LanPeer> connectManual(String host, int port) async {
    final r = await _manual!.addPeer(host, port);
    _peers[r.info.deviceId]
      ?..failures = 0
      ..nextAttempt = DateTime.fromMillisecondsSinceEpoch(0);
    _applyInfo(r.info, r.address);
    _peers[r.info.deviceId]?.manual = true;
    _maintain();
    return _peerSnapshot(r.info.deviceId);
  }

  void _maintain() {
    if (!_started || !config.keepConnected) return;
    final now = DateTime.now();
    for (final t in _trusted.values) {
      final ps = _peers[t.deviceId];
      if (ps == null || !ps.online) continue;
      if (_conns[t.deviceId]?.isClosed == false) continue;
      if (_connecting.containsKey(t.deviceId)) continue;
      // Only the lexicographically smaller id auto-connects (avoids collisions).
      // (unless we hold a manual address for it: then we must dial).
      if (!ps.manual && _identity.deviceId.compareTo(t.deviceId) >= 0) continue;
      if (now.isBefore(ps.nextAttempt)) continue;
      _ensureConn(t.deviceId).then((_) {
        ps.failures = 0;
      }, onError: (Object _) {
        ps.failures++;
        final secs = (1 << (ps.failures < 5 ? ps.failures : 5)).clamp(1, 30);
        ps.nextAttempt = DateTime.now().add(Duration(seconds: secs));
      });
    }
  }

  // ---- incoming connections ----------------------------------------------

  void _onIncomingSocket(WebSocket ws, InternetAddress remote) {
    final lim = _connLimits.putIfAbsent(
        remote.address, () => RateLimiter(30, const Duration(minutes: 1)));
    if (_connLimits.length > 256) _connLimits.clear();
    if (!lim.allow() || _pendingHandshakes >= 8 || !_started) {
      unawaited(safeCloseSocket(ws, 1013, 'busy'));
      return;
    }
    _pendingHandshakes++;
    handshakeAsResponder(
      ws,
      _identity,
      remote: remote,
      policy: (h) => _policy(h, remote),
      expectedPeerEdFor: (h) => h.mode == HandshakeMode.connect
          ? _trusted[h.deviceId]?.ed25519Pub
          : null,
    )
        .then((conn) => _onHandshaked(conn, remote), onError: (_) {})
        .whenComplete(() {
      _pendingHandshakes--;
    });
  }

  Future<HandshakeException?> _policy(Hello h, InternetAddress remote) async {
    if (h.mode == HandshakeMode.connect) {
      final t = _trusted[h.deviceId];
      if (t == null) {
        return HandshakeException(
            'unknown_device', 'Unknown device — pair first');
      }
      return null;
    }
    // pair mode
    if (!config.acceptIncomingPairing) {
      return HandshakeException('busy', 'Pairing disabled');
    }
    final lim = _pairLimits.putIfAbsent(
        remote.address, () => RateLimiter(5, const Duration(minutes: 1)));
    if (_pairLimits.length > 256) _pairLimits.clear();
    if (!lim.allow()) {
      return HandshakeException('rate_limited', 'Too many pairing attempts');
    }
    final active = _pairings.where((s) => !s.isFinished && s.incoming).length;
    if (active >= 3)
      return HandshakeException('busy', 'Too many pairing requests');
    return null;
  }

  Future<void> _onHandshaked(
      PeerConnection conn, InternetAddress remote) async {
    if (!_started) {
      await conn.close();
      return;
    }
    if (conn.mode == HandshakeMode.pair) {
      final session = _newPairing(
          incoming: true,
          peerId: conn.peerId,
          name: _peers[conn.peerId]?.info?.name ?? conn.peerId);
      session.attach(conn);
      _pairReqCtrl.add(session);
      return;
    }
    await _registerConnection(conn);
  }

  PairingSession _newPairing(
      {required bool incoming, required String peerId, required String name}) {
    final s = PairingSession.internal(
      incoming: incoming,
      peerId: peerId,
      peerName: name,
      timeout: config.pairingTimeout,
      ownInfo: () => _info,
      persist: _persistTrust,
      onPaired: (info, addr) {
        if (info != null && info.deviceId == peerId) {
          _applyInfo(info, addr);
        } else if (addr != null) {
          // No info received: remember only that we have an address.
          final ps = _peers.putIfAbsent(peerId, () => _PeerState());
          ps.address ??= addr;
        }
      },
    );
    _pairings.add(s);
    s.done.then((_) => _pairings.remove(s));
    return s;
  }

  Future<void> _persistTrust(String id, String name, List<int> edPub) async {
    final t = TrustedPeer(
        deviceId: id,
        name: name,
        ed25519Pub: Uint8List.fromList(edPub),
        pairedAt: DateTime.now());
    await config.trustStore.put(t);
    _trusted[id] = t;
    _emitPeers();
    _maintain();
  }

  /// Registers an authenticated connect-mode connection, resolving duplicates.
  ///
  /// When both sides dial at once there are briefly two connections. The one
  /// opened by the smaller deviceId becomes the primary (used for sending); the
  /// other is *retired*: it keeps delivering inbound frames for a grace period
  /// (the protocol is addressed by peer id, not by connection) and is then
  /// closed, so nothing in flight is lost.
  Future<void> _registerConnection(PeerConnection conn) async {
    final id = conn.peerId;
    if (!_started) {
      await conn.close(1001, 'shutdown');
      return;
    }
    conn.onMessage = (m) => _onMessage(conn, m);
    conn.onChunk = (c) => _files.onChunk(id, c);
    conn.onClosed = (_) {
      _retired.remove(conn);
      _requeueUnacked(conn);
      if (_conns[id] == conn) {
        _conns.remove(id);
        _files.onPeerDisconnected(id);
        _emitPeers();
      }
    };
    conn.start();
    final existing = _conns[id];
    if (existing != null && !existing.isClosed) {
      final keepNew = existing.initiatorId == conn.initiatorId ||
          conn.initiatorId!.compareTo(existing.initiatorId!) < 0;
      if (!keepNew) {
        _retire(conn);
        return;
      }
      _retire(existing);
    }
    _conns[id] = conn;
    _emitPeers();
    conn.send(PeerInfoMsg(_info)).catchError((_) {});
    unawaited(_flushOutbox(id));
  }

  void _retire(PeerConnection c) {
    _retired.add(c);
    Timer(const Duration(seconds: 3), () {
      _retired.remove(c);
      c.close(1000, 'duplicate');
    });
  }

  // ---- outgoing connections ----------------------------------------------

  Future<PeerConnection> _ensureConn(String id) {
    final c = _conns[id];
    if (c != null && !c.isClosed) return Future.value(c);
    return _connecting[id] ??= _connect(id).whenComplete(() {
      _connecting.remove(id);
    });
  }

  Future<WebSocket> _openSocket(String id) async {
    final ps = _peers[id];
    final addr = ps?.address;
    final port = ps?.info?.linkPort ?? 0;
    if (ps == null || !ps.online || addr == null || port == 0) {
      throw PeerOfflineException(id);
    }
    try {
      return await WebSocket.connect(
              Uri(
                      scheme: 'ws',
                      host: addr.address,
                      port: port,
                      path: '/spp/v1/ws')
                  .toString(),
              compression: CompressionOptions.compressionOff)
          .timeout(const Duration(seconds: 5));
    } catch (_) {
      throw PeerOfflineException(id);
    }
  }

  Future<PeerConnection> _connect(String id) async {
    final t = _trusted[id];
    if (t == null) {
      throw HandshakeException('unknown_device', 'Unknown device — pair first');
    }
    final ws = await _openSocket(id);
    final conn = await handshakeAsInitiator(
        ws, _identity, HandshakeMode.connect,
        expectedPeerEd: t.ed25519Pub, remote: _peers[id]?.address);
    await _registerConnection(conn);
    final c = _conns[id];
    if (c == null || c.isClosed) throw PeerOfflineException(id);
    return c;
  }

  /// Starts pairing with [peer]. Show `session.sas` once `state` becomes
  /// `awaitingConfirm`, then call `session.confirm()` if both codes match.
  PairingSession pair(LanPeer peer) => pairWith(peer.deviceId);

  PairingSession pairWith(String peerId) {
    final s = _newPairing(
        incoming: false,
        peerId: peerId,
        name: _peers[peerId]?.info?.name ?? peerId);
    () async {
      try {
        final ws = await _openSocket(peerId);
        final conn = await handshakeAsInitiator(
            ws, _identity, HandshakeMode.pair,
            remote: _peers[peerId]?.address);
        if (conn.peerId != peerId) {
          await conn.close(1008, 'unexpected device');
          s.fail('Connected device is not the selected one');
          return;
        }
        s.attach(conn);
      } on LanLinkException catch (e) {
        s.fail(e.message);
      } catch (e) {
        s.fail('$e');
      }
    }();
    return s;
  }

  /// Removes trust for [peerId] and tells the peer (best effort).
  Future<void> unpair(String peerId) async {
    final c = _conns[peerId];
    if (c != null && !c.isClosed) {
      try {
        await c.send(const PairRevoke());
      } catch (_) {}
    }
    await config.trustStore.remove(peerId);
    _trusted.remove(peerId);
    _conns.remove(peerId);
    await c?.close(1000, 'unpaired');
    _files.onPeerDisconnected(peerId);
    final ps = _peers[peerId];
    if (ps != null && !ps.online) _peers.remove(peerId);
    _emitPeers();
  }

  // ---- sending ------------------------------------------------------------

  void _requireCap(String peerId, Capability cap) {
    if (!config.allowedCapabilities.contains(cap)) {
      throw LanLinkException('capability_disabled', '${cap.name} is disabled');
    }
    final caps = _peers[peerId]?.info?.capabilities;
    if (caps != null && !caps.contains(cap)) {
      throw LanLinkException(
          'unsupported', 'The other device does not support ${cap.name}');
    }
  }

  Future<void> _send(String peerId, AppMessage m, {bool connect = true}) async {
    PeerConnection c;
    if (connect) {
      c = await _ensureConn(peerId);
    } else {
      final x = _conns[peerId];
      if (x == null || x.isClosed) throw PeerOfflineException(peerId);
      c = x;
    }
    try {
      await c.send(m);
    } on PeerOfflineException {
      rethrow;
    } catch (_) {
      throw PeerOfflineException(peerId);
    }
  }

  Future<void> _sendChunk(String peerId, FileChunk ch) async {
    final x = _conns[peerId];
    if (x == null || x.isClosed) throw PeerOfflineException(peerId);
    await x.sendChunk(ch);
  }

  // chat ---------------------------------------------------------------

  /// Sends a chat message. Fails fast with [PeerOfflineException] unless
  /// [queue] is true, in which case it is held (bounded) and retried when the
  /// peer reconnects.
  Future<ChatMessage> sendChat(String peerId, String text,
      {String? replyTo, bool queue = false}) async {
    _requireCap(peerId, Capability.chat);
    if (text.isEmpty || text.length > maxChatText) {
      throw LanLinkException(
          'bad_message', 'Message must be 1-$maxChatText characters');
    }
    final msg = ChatMessage(
        id: hexEncode(randomBytes(12)),
        peerId: peerId,
        text: text,
        ts: DateTime.now().millisecondsSinceEpoch,
        incoming: false,
        replyTo: replyTo,
        status: ChatStatus.sending);
    try {
      await _sendChatWire(msg);
    } on PeerOfflineException {
      if (!queue) rethrow;
      final q = _outbox.putIfAbsent(peerId, () => []);
      if (q.length >= 50) q.removeAt(0).msg.status = ChatStatus.failed;
      msg.status = ChatStatus.queued;
      q.add(_Queued(msg, DateTime.now()));
    }
    if (queue) _queueable.add(msg.id);
    _rememberSent(msg);
    _chatCtrl.add(msg);
    return msg;
  }

  Future<void> _sendChatWire(ChatMessage msg) async {
    final c = await _ensureConn(msg.peerId);
    try {
      await c.send(ChatText(
          id: msg.id, text: msg.text, ts: msg.ts, replyTo: msg.replyTo));
    } catch (_) {
      throw PeerOfflineException(msg.peerId);
    }
    _sentVia[msg.id] = c;
    if (msg.status == ChatStatus.sending || msg.status == ChatStatus.queued) {
      msg.status = ChatStatus.sent;
    }
  }

  /// Queued messages that were written to a connection which then died before
  /// the delivery ack arrived go back to the outbox (receiver de-duplicates).
  void _requeueUnacked(PeerConnection dead) {
    final peers = <String>{};
    for (final m in _sentChats.values) {
      if (_sentVia[m.id] == dead &&
          m.status == ChatStatus.sent &&
          _queueable.contains(m.id)) {
        m.status = ChatStatus.queued;
        _outbox.putIfAbsent(m.peerId, () => []).add(_Queued(m, DateTime.now()));
        _sentVia.remove(m.id);
        _chatCtrl.add(m);
        peers.add(m.peerId);
      }
    }
    for (final p in peers) {
      final c = _conns[p];
      if (c != null && !c.isClosed) unawaited(_flushOutbox(p));
    }
  }

  void _rememberSent(ChatMessage m) {
    _sentChats[m.id] = m;
    if (_sentChats.length > 500) {
      final old = _sentChats.keys.first;
      _sentChats.remove(old);
      _sentVia.remove(old);
      _queueable.remove(old);
    }
  }

  Future<void> _flushOutbox(String peerId) async {
    final q = _outbox.remove(peerId);
    if (q == null) return;
    for (var i = 0; i < q.length; i++) {
      final e = q[i];
      if (DateTime.now().difference(e.at) > const Duration(minutes: 10)) {
        e.msg.status = ChatStatus.failed;
        _chatCtrl.add(e.msg);
        continue;
      }
      try {
        await _sendChatWire(e.msg);
      } on PeerOfflineException {
        // Connection died again: keep this and the rest for the next attempt.
        _outbox.putIfAbsent(peerId, () => []).insertAll(0, q.sublist(i));
        return;
      } catch (_) {
        e.msg.status = ChatStatus.failed;
      }
      _chatCtrl.add(e.msg);
    }
  }

  /// Tell the sender we read a message.
  Future<void> markRead(String peerId, String messageId) =>
      _send(peerId, ChatAck(messageId, AckStatus.read), connect: false);

  /// Best effort; silently ignored if not connected.
  Future<void> sendTyping(String peerId, bool typing) async {
    try {
      await _send(peerId, ChatTyping(typing), connect: false);
    } catch (_) {}
  }

  // status -------------------------------------------------------------

  Future<void> updateStatus(PeerStatus status) => updateInfo(status: status);

  Future<void> updateInfo(
      {PeerStatus? status,
      List<String>? aors,
      int? sipPort,
      String? name}) async {
    _info = _info.copyWith(
        status: status, aors: aors, sipPort: sipPort, name: name);
    _discovery?.announce(_info);
    for (final c in _conns.values.toList()) {
      c.send(PeerInfoMsg(_info)).catchError((_) {});
    }
  }

  // files --------------------------------------------------------------

  /// Streams a file to [peerId]. The peer must accept first.
  FileTransfer sendFile(String peerId, String path) {
    _requireCap(peerId, Capability.files);
    return _files.sendFile(peerId, path);
  }

  Future<void> acceptFile(FileTransfer t) => t.accept();
  Future<void> declineFile(FileTransfer t, [String reason = 'declined']) =>
      t.decline(reason);

  void _onNewTransfer(FileTransfer t) {
    _fileCtrl.add(t);
    if (t.incoming) {
      if (!config.allowedCapabilities.contains(Capability.files)) {
        t.decline('unsupported');
        return;
      }
      final peer = _peerSnapshot(t.peerId);
      if (config.autoAcceptFile?.call(peer, t) ?? false) t.accept();
    }
  }

  // handoff ------------------------------------------------------------

  /// Offers a call handoff and waits for the peer's decision.
  Future<HandoffResult> offerHandoff(String peerId, HandoffOffer offer) async {
    _requireCap(peerId, Capability.handoff);
    final w = Completer<HandoffResult>();
    final key = '$peerId/${offer.handoffId}';
    _handoffWaiters[key] = w;
    try {
      await _send(peerId, offer);
    } catch (e) {
      _handoffWaiters.remove(key);
      return HandoffResult(
          HandoffOutcome.failed, e is LanLinkException ? e.message : '$e');
    }
    final r = await w.future.timeout(config.handoffTimeout, onTimeout: () {
      _send(peerId, HandoffCancel(offer.handoffId), connect: false)
          .catchError((_) {});
      return HandoffResult(HandoffOutcome.timeout);
    });
    _handoffWaiters.remove(key);
    return r;
  }

  Future<void> cancelHandoff(String peerId, String handoffId) async {
    _handoffWaiters
        .remove('$peerId/$handoffId')
        ?.complete(HandoffResult(HandoffOutcome.cancelled));
    await _send(peerId, HandoffCancel(handoffId), connect: false);
  }

  Future<void> completeHandoff(String peerId, String handoffId) =>
      _send(peerId, HandoffComplete(handoffId), connect: false);

  Future<void> requestCallsList(String peerId) {
    _requireCap(peerId, Capability.handoff);
    return _send(peerId, const CallsQuery());
  }

  Future<void> sendCallsList(String peerId, List<CallSummary> calls) {
    _requireCap(peerId, Capability.handoff);
    return _send(peerId, CallsList(calls.take(64).toList()));
  }

  /// Ask [peerId] to hand call [callId] over to us.
  Future<void> requestPull(String peerId, String callId) {
    _requireCap(peerId, Capability.handoff);
    return _send(peerId, CallPull(callId));
  }

  /// Negotiates an intercom grant with [peerId]. Completes with the callee's
  /// decision; if allowed, [IntercomGrant.expiresAt] bounds the call setup.
  Future<IntercomGrant> requestIntercom(String peerId,
      {Duration timeout = const Duration(seconds: 10)}) async {
    _requireCap(peerId, Capability.intercom);
    final rid = hexEncode(randomBytes(8));
    final c = Completer<IntercomGrant>();
    _intercomWaiters['$peerId/$rid'] = c;
    try {
      await _send(peerId, IntercomRequest(requestId: rid));
    } catch (e) {
      _intercomWaiters.remove('$peerId/$rid');
      rethrow;
    }
    return c.future.timeout(timeout, onTimeout: () {
      _intercomWaiters.remove('$peerId/$rid');
      return IntercomGrant(false, DateTime.now());
    });
  }

  /// True while [peerId] holds an unexpired grant (given by us) to intercom
  /// this device. The SIP layer must check this before auto-answering.
  bool intercomGranted(String peerId) {
    final until = _intercomGrants[peerId];
    if (until == null) return false;
    if (DateTime.now().isAfter(until)) {
      _intercomGrants.remove(peerId);
      return false;
    }
    return true;
  }

  void revokeIntercom(String peerId) => _intercomGrants.remove(peerId);

  Future<void> sendIntercomRequest(String peerId, {bool? allowed}) {
    _requireCap(peerId, Capability.intercom);
    return _send(peerId, IntercomRequest(allowed: allowed));
  }

  // ---- incoming messages ---------------------------------------------------

  void _onMessage(PeerConnection conn, AppMessage m) {
    final id = conn.peerId;
    final cap = m.capability;
    if (cap != null && !config.allowedCapabilities.contains(cap)) {
      if (m is FileOffer) _safe(id, FileDecline(m.transferId, 'unsupported'));
      if (m is HandoffOffer)
        _safe(id, HandoffDecline(m.handoffId, 'unsupported'));
      return;
    }
    switch (m) {
      case PeerInfoMsg():
        if (m.info.deviceId != id ||
            !bytesEqual(m.info.ed25519Pub, conn.peerHello.edPub)) {
          return;
        }
        final ps = _peers.putIfAbsent(id, () => _PeerState());
        // Keep the discovered address; fall back to the socket's.
        ps.info = m.info;
        ps.address ??= conn.remoteAddress;
        ps.lastSeen = DateTime.now();
        ps.online = true;
        _emitPeers();
      case StatusUpdate():
        final ps = _peers[id];
        if (ps?.info != null) {
          ps!.info = ps.info!.copyWith(status: m.status);
          _emitPeers();
        }
      case PairRevoke():
        unawaited(() async {
          await config.trustStore.remove(id);
          _trusted.remove(id);
          _unpairedCtrl.add(id);
          _conns.remove(id);
          await conn.close(1000, 'unpaired');
          _emitPeers();
        }());
      case PairConfirm():
        break;
      case ChatText():
        if (!_seenChatIds.add('$id/${m.id}')) return;
        if (_seenChatIds.length > 2000) _seenChatIds.remove(_seenChatIds.first);
        _safe(id, ChatAck(m.id, AckStatus.delivered));
        _chatCtrl.add(ChatMessage(
            id: m.id,
            peerId: id,
            text: m.text,
            ts: m.ts,
            incoming: true,
            replyTo: m.replyTo,
            status: ChatStatus.delivered));
      case ChatAck():
        final c = _sentChats[m.id];
        if (c != null && c.peerId == id) {
          final newer = m.status == AckStatus.read
              ? ChatStatus.read
              : (c.status == ChatStatus.read
                  ? ChatStatus.read
                  : ChatStatus.delivered);
          if (newer != c.status) {
            c.status = newer;
            _chatCtrl.add(c);
          }
        }
      case ChatTyping():
        _typingCtrl.add(TypingEvent(id, m.typing));
      case FileOffer() ||
            FileAccept() ||
            FileDecline() ||
            FileChunkAck() ||
            FileComplete() ||
            FileVerified() ||
            FileCancel():
        unawaited(_files.onMessage(id, m));
      case HandoffOffer():
        final key = '$id/${m.handoffId}';
        final pending =
            _incomingHandoffs.keys.where((k) => k.startsWith('$id/')).length;
        if (_incomingHandoffs.containsKey(key) || pending >= 8) {
          _safe(id, HandoffDecline(m.handoffId, 'busy'));
          return;
        }
        final h = IncomingHandoff._(this, _peerSnapshot(id), m);
        _incomingHandoffs[key] = h;
        _handoffCtrl.add(h);
      case HandoffAccept():
        _handoffWaiters
            .remove('$id/${m.handoffId}')
            ?.complete(HandoffResult(HandoffOutcome.accepted));
      case HandoffDecline():
        _handoffWaiters
            .remove('$id/${m.handoffId}')
            ?.complete(HandoffResult(HandoffOutcome.declined, m.reason));
      case HandoffCancel():
        final h = _incomingHandoffs.remove('$id/${m.handoffId}');
        h?.cancelled = true;
        _handoffWaiters
            .remove('$id/${m.handoffId}')
            ?.complete(HandoffResult(HandoffOutcome.cancelled));
        _handoffEvtCtrl
            .add(HandoffEvent(id, m.handoffId, HandoffEventKind.cancelled));
      case HandoffComplete():
        _handoffEvtCtrl
            .add(HandoffEvent(id, m.handoffId, HandoffEventKind.completed));
      case CallsQuery():
        _queryCtrl.add(IncomingCallsQuery._(this, _peerSnapshot(id)));
      case CallsList():
        _listCtrl.add(CallsListEvent(_peerSnapshot(id), m.calls));
      case CallPull():
        _pullCtrl.add(PullRequest(_peerSnapshot(id), m.callId));
      case IntercomRequest():
        if (m.requestId == null) {
          _intercomCtrl.add(IntercomEvent(_peerSnapshot(id), m.allowed));
        } else {
          _intercomReqCtrl
              .add(IncomingIntercom._(this, _peerSnapshot(id), m.requestId!));
        }
      case IntercomResponse():
        final w = _intercomWaiters.remove('$id/${m.requestId}');
        w?.complete(IntercomGrant(m.allowed && _peerSnapshot(id).trusted,
            DateTime.now().add(Duration(seconds: m.expiresSec))));
      default:
        break;
    }
  }

  void _safe(String id, AppMessage m) {
    _send(id, m, connect: false).catchError((_) {});
  }

  // ---- test hooks -----------------------------------------------------------

  @visibleForTesting
  Future<void> debugSend(String peerId, AppMessage m) => _send(peerId, m);

  @visibleForTesting
  Future<void> debugSendChunk(String peerId, FileChunk c) =>
      _sendChunk(peerId, c);

  @visibleForTesting
  Future<void> debugDropConnection(String peerId) async {
    final c = _conns[peerId];
    if (c != null) await safeCloseSocket(c.ws, 1001);
  }
}
