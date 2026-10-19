import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lan_link/lan_link.dart' as ll;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../l10n/l10n.dart';
import '../models/app_settings.dart';
import '../models/chat.dart';
import '../services/accounts_controller.dart';
import '../services/calls_controller.dart';
import '../services/engine_controller.dart';
import '../services/messages_controller.dart';
import '../services/providers.dart';
import '../services/settings_controller.dart';
import '../storage/repositories.dart';
import 'bonsoir_discovery.dart';
import 'lan_models.dart';
import 'lan_stores.dart';

// ---- overridable infrastructure ---------------------------------------------

/// Discovery providers for the link. `null` lets lan_link use its default
/// multicast discovery; tests return `[]` and use manual connect only.
typedef LanDiscoveryFactory = List<ll.DiscoveryProvider>? Function();

List<ll.DiscoveryProvider>? defaultLanDiscovery() {
  if (kIsWeb) return const [];
  final mdns = Platform.isAndroid || Platform.isIOS || Platform.isMacOS || Platform.isWindows;
  return [
    if (mdns) BonsoirDiscoveryProvider(),
    // iOS blocks raw multicast without a special entitlement: mDNS only.
    if (!Platform.isIOS) ll.MulticastDiscovery(),
  ];
}

final lanDiscoveryFactoryProvider = Provider<LanDiscoveryFactory>((ref) => defaultLanDiscovery);

/// Local IPv4 addresses (for the QR code and network-change detection).
final lanLocalAddressesProvider = Provider<Future<List<String>> Function()>((ref) => defaultLocalAddresses);

Future<List<String>> defaultLocalAddresses() async {
  try {
    final ifs = await NetworkInterface.list(type: InternetAddressType.IPv4);
    final out = <String>[];
    for (final i in ifs) {
      for (final a in i.addresses) {
        if (!a.isLoopback && !a.isLinkLocal) out.add(a.address);
      }
    }
    out.sort((a, b) => _rank(a).compareTo(_rank(b)));
    return out;
  } catch (_) {
    return const [];
  }
}

int _rank(String a) {
  if (a.startsWith('192.168.')) return 0;
  if (a.startsWith('10.')) return 1;
  if (a.startsWith('172.')) return 2;
  return 3;
}

/// Where received files go when no folder is configured.
final lanDownloadsDirProvider = Provider<Future<String> Function()>((ref) => () async {
      final s = ref.read(settingsProvider).lanDownloadsDir;
      if (s.isNotEmpty) return s;
      Directory base;
      try {
        base = await getDownloadsDirectory() ?? await getApplicationDocumentsDirectory();
      } catch (_) {
        base = await getApplicationDocumentsDirectory();
      }
      return p.join(base.path, 'SoftphonePro');
    });

final lanKeyStoreProvider = Provider<ll.KeyStore>((ref) => SecretsKeyStore(ref.watch(secretsStoreProvider)));
final lanTrustStoreProvider = Provider<ll.TrustStore>((ref) => SecretsTrustStore(ref.watch(secretsStoreProvider)));

/// Android needs a WifiManager.MulticastLock for multicast beacons / mDNS.
/// The Android platform layer answers this channel; elsewhere it is a no-op.
const MethodChannel _lanChannel = MethodChannel('com.softphonepro/lan');

Future<void> _multicastLock(bool acquire) async {
  if (kIsWeb || !Platform.isAndroid) return;
  try {
    await _lanChannel.invokeMethod<void>(acquire ? 'acquireMulticastLock' : 'releaseMulticastLock');
  } on MissingPluginException {
    // TODO(android): implement 'acquireMulticastLock' in the Android layer.
  } catch (_) {}
}

// ---- state ------------------------------------------------------------------

class LanState {
  const LanState({
    this.enabled = false,
    this.running = false,
    this.starting = false,
    this.error,
    this.self,
    this.addresses = const [],
    this.peers = const [],
    this.remoteCalls = const {},
    this.transfers = const [],
    this.history = const [],
    this.rev = 0,
    this.typing = const {},
  });

  final bool enabled;
  final bool running;
  final bool starting;
  final String? error;
  final ll.DeviceInfo? self;
  final List<String> addresses;
  final List<ll.LanPeer> peers;

  /// Calls other devices offered to hand over (peerId -> calls).
  final Map<String, List<ll.CallSummary>> remoteCalls;

  /// Live (not yet finished) transfers.
  final List<ll.FileTransfer> transfers;
  final List<LanFileEntry> history;

  /// Bumped when a live transfer's progress changes.
  final int rev;

  /// peerIds currently typing.
  final Set<String> typing;

  List<ll.LanPeer> get paired => peers.where((e) => e.trusted).toList();
  List<ll.LanPeer> get nearby => peers.where((e) => !e.trusted && e.online).toList();
  ll.LanPeer? peer(String id) {
    for (final e in peers) {
      if (e.deviceId == id) return e;
    }
    return null;
  }

  LanState copyWith({
    bool? enabled,
    bool? running,
    bool? starting,
    Object? error = _keep,
    Object? self = _keep,
    List<String>? addresses,
    List<ll.LanPeer>? peers,
    Map<String, List<ll.CallSummary>>? remoteCalls,
    List<ll.FileTransfer>? transfers,
    List<LanFileEntry>? history,
    int? rev,
    Set<String>? typing,
  }) =>
      LanState(
        enabled: enabled ?? this.enabled,
        running: running ?? this.running,
        starting: starting ?? this.starting,
        error: identical(error, _keep) ? this.error : error as String?,
        self: identical(self, _keep) ? this.self : self as ll.DeviceInfo?,
        addresses: addresses ?? this.addresses,
        peers: peers ?? this.peers,
        remoteCalls: remoteCalls ?? this.remoteCalls,
        transfers: transfers ?? this.transfers,
        history: history ?? this.history,
        rev: rev ?? this.rev,
        typing: typing ?? this.typing,
      );
}

const Object _keep = Object();

String lanConversationKey(String peerId) => '$kChannelLan|$peerId|${ChatMessage.peerKey(peerId)}';

String _platformName() {
  if (kIsWeb) return 'web';
  if (Platform.isAndroid) return 'android';
  if (Platform.isIOS) return 'ios';
  if (Platform.isMacOS) return 'macos';
  if (Platform.isWindows) return 'windows';
  if (Platform.isLinux) return 'linux';
  return 'other';
}

String defaultDeviceName() {
  if (kIsWeb) return 'SoftphonePro';
  if (Platform.isAndroid) return 'Android phone';
  if (Platform.isIOS) return 'iPhone';
  try {
    final h = Platform.localHostname.replaceAll(RegExp(r'\.(local|lan|home)$'), '');
    if (h.isNotEmpty && h != 'localhost') return h;
  } catch (_) {}
  return 'SoftphonePro';
}

/// Owns the [ll.LanLink]: lifecycle, discovery, pairing, chat, files.
class LanController extends Notifier<LanState> {
  ll.LanLink? _link;
  bool _disposed = false;
  bool _busy = false;
  bool _again = false;
  final List<StreamSubscription<dynamic>> _subs = [];
  Timer? _netTimer;
  Timer? _bumpTimer;
  Timer? _infoTimer;
  Set<String> _addrs = {};
  final Map<String, Timer> _typingTimers = {};

  final _pairing = StreamController<ll.PairingSession>.broadcast();
  final _handoffOffers = StreamController<ll.IncomingHandoff>.broadcast();
  final _handoffEvents = StreamController<ll.HandoffEvent>.broadcast();
  final _pulls = StreamController<ll.PullRequest>.broadcast();
  final _incomingFiles = StreamController<ll.FileTransfer>.broadcast();
  final _unpaired = StreamController<String>.broadcast();
  final _intercomPrompts = StreamController<ll.IncomingIntercom>.broadcast();

  Stream<ll.PairingSession> get pairingRequests => _pairing.stream;
  Stream<ll.IncomingHandoff> get handoffOffers => _handoffOffers.stream;
  Stream<ll.HandoffEvent> get handoffEvents => _handoffEvents.stream;
  Stream<ll.PullRequest> get pullRequests => _pulls.stream;

  /// Incoming offers that need a user decision (not auto-accepted).
  Stream<ll.FileTransfer> get incomingFileOffers => _incomingFiles.stream;
  Stream<String> get unpairedByPeer => _unpaired.stream;

  ll.LanLink? get link => _link;
  AppSettings get _settings => ref.read(settingsProvider);

  @override
  LanState build() {
    ref.onDispose(() {
      _disposed = true;
      _netTimer?.cancel();
      _bumpTimer?.cancel();
      _infoTimer?.cancel();
      for (final t in _typingTimers.values) {
        t.cancel();
      }
      final l = _link;
      _link = null;
      for (final s in _subs) {
        s.cancel();
      }
      if (l != null) unawaited(l.stop().catchError((_) {}));
      for (final c in [_pairing, _handoffOffers, _handoffEvents, _pulls, _incomingFiles, _unpaired, _intercomPrompts]) {
        c.close();
      }
    });
    ref.listen<AppSettings>(settingsProvider, _onSettings);
    ref.listen<EngineState>(engineProvider, (prev, next) {
      if (prev?.startResult?.lan?.port != next.startResult?.lan?.port) _pushInfoSoon();
    });
    ref.listen(callsProvider, (_, __) => _pushInfoSoon());
    ref.listen(accountsProvider, (_, __) => _pushInfoSoon());
    ref.read(connectivityStreamProvider).listen((_) => _checkNetwork());
    Future.microtask(() async {
      state = state.copyWith(history: await _loadHistory());
      await _sync();
    });
    return LanState(enabled: _settings.lanEnabled);
  }

  // ---- lifecycle -----------------------------------------------------------

  void _onSettings(AppSettings? old, AppSettings next) {
    if (old == null) return;
    if (old.lanEnabled != next.lanEnabled) {
      unawaited(_sync());
      return;
    }
    if (_link == null) return;
    if (old.lanLinkPort != next.lanLinkPort ||
        old.lanAllowIntercom != next.lanAllowIntercom ||
        old.lanDownloadsDir != next.lanDownloadsDir) {
      unawaited(restart());
    } else {
      _pushInfoSoon();
    }
  }

  Future<void> _sync() async {
    if (_disposed) return;
    final want = _settings.lanEnabled;
    state = state.copyWith(enabled: want);
    if (want && _link == null) {
      await _start();
    } else if (!want && _link != null) {
      await _stop();
    }
  }

  Future<void> restart() async {
    if (_busy) {
      _again = true;
      return;
    }
    await _stop();
    if (_settings.lanEnabled) await _start();
  }

  String get deviceName {
    final n = _settings.lanDeviceName.trim();
    return n.isNotEmpty ? n : defaultDeviceName();
  }

  Set<ll.Capability> get _caps => {
        ll.Capability.chat,
        ll.Capability.files,
        ll.Capability.handoff,
        if (_settings.lanAllowIntercom) ll.Capability.intercom,
      };

  /// Registered accounts the user opted to share, as `sip:user@domain`.
  List<String> _aors() {
    final s = _settings;
    final acc = ref.read(accountsProvider);
    final out = <String>[];
    for (final id in s.lanShareAors) {
      final prof = acc.byId(id);
      if (prof == null || acc.statusOf(id) != AccountStatus.registered) continue;
      if (prof.config.username.isEmpty || prof.config.domain.isEmpty) continue;
      out.add('sip:${prof.config.username}@${prof.config.domain}');
    }
    return out.take(8).toList();
  }

  ll.PeerStatus _status() {
    final s = _settings;
    if (s.dnd || s.globalStatus == 'dnd') return ll.PeerStatus.dnd;
    if (ref.read(callsProvider).live.isNotEmpty) return ll.PeerStatus.onCall;
    return ll.PeerStatus.available;
  }

  Future<void> _start() async {
    if (_busy || _link != null || _disposed) return;
    _busy = true;
    state = state.copyWith(starting: true, error: null);
    try {
      await _multicastLock(true);
      final dir = await ref.read(lanDownloadsDirProvider)();
      final link = ll.LanLink(ll.LanLinkConfig(
        deviceName: deviceName,
        platform: _platformName(),
        downloadsDir: dir,
        appVersion: kAppVersion,
        linkPort: _settings.lanLinkPort,
        sipPort: ref.read(engineProvider).startResult?.lan?.port ?? 0,
        discoveryProviders: ref.read(lanDiscoveryFactoryProvider)(),
        keyStore: ref.read(lanKeyStoreProvider),
        trustStore: ref.read(lanTrustStoreProvider),
        allowedCapabilities: _caps,
        aors: _aors(),
        handoffTimeout: const Duration(seconds: 30),
        autoAcceptFile: (peer, t) => peer.trusted && ref.read(settingsProvider).lanAutoAcceptFiles,
      ));
      await link.start();
      if (_disposed) {
        await link.stop();
        return;
      }
      _link = link;
      _wire(link);
      _addrs = (await ref.read(lanLocalAddressesProvider)()).toSet();
      _netTimer?.cancel();
      _netTimer = Timer.periodic(const Duration(seconds: 10), (_) => _checkNetwork());
      state = state.copyWith(
        running: true,
        starting: false,
        self: link.info,
        peers: link.currentPeers,
        addresses: _addrs.toList()..sort((a, b) => _rank(a).compareTo(_rank(b))),
      );
      _pushInfoSoon();
    } catch (e) {
      debugPrint('LAN Link failed to start: $e');
      state = state.copyWith(running: false, starting: false, error: _friendly(e));
      _link = null;
    } finally {
      _busy = false;
    }
    if (_again) {
      _again = false;
      await restart();
    }
  }

  String _friendly(Object e) {
    if (e is ll.LanLinkException) return e.message;
    if (e is SocketException) return ref.read(l10nProvider).lanNetworkError(e.message);
    return '$e';
  }

  Future<void> _stop() async {
    final l = _link;
    _link = null;
    _netTimer?.cancel();
    for (final s in _subs) {
      await s.cancel();
    }
    _subs.clear();
    if (l != null) {
      try {
        await l.stop();
      } catch (_) {}
    }
    await _multicastLock(false);
    if (_disposed) return;
    state = state.copyWith(running: false, starting: false, self: null, peers: const [], remoteCalls: const {}, transfers: const []);
  }

  void _wire(ll.LanLink l) {
    _subs
      ..add(l.peers.listen(_onPeers))
      ..add(l.chatMessages.listen(_onChat))
      ..add(l.typingEvents.listen(_onTyping))
      ..add(l.fileTransfers.listen(_trackTransfer))
      ..add(l.pairingRequests.listen((s) {
        if (!_pairing.isClosed) _pairing.add(s);
      }))
      ..add(l.handoffOffers.listen((h) {
        if (!_handoffOffers.isClosed) _handoffOffers.add(h);
      }))
      ..add(l.handoffEvents.listen((h) {
        if (!_handoffEvents.isClosed) _handoffEvents.add(h);
      }))
      ..add(l.pullRequests.listen((r) {
        if (!_pulls.isClosed) _pulls.add(r);
      }))
      ..add(l.callsQueries.listen(_onCallsQuery))
      ..add(l.callsLists.listen(_onCallsList))
      ..add(l.intercomNegotiations.listen(_onIntercomRequest))
      ..add(l.unpairedByPeer.listen((id) {
        if (!_unpaired.isClosed) _unpaired.add(id);
      }));
  }

  // ---- network / info ------------------------------------------------------

  void _pushInfoSoon() {
    if (_link == null) return;
    _infoTimer?.cancel();
    _infoTimer = Timer(const Duration(milliseconds: 250), () async {
      final l = _link;
      if (l == null || _disposed) return;
      try {
        await l.updateInfo(
          status: _status(),
          aors: _aors(),
          sipPort: ref.read(engineProvider).startResult?.lan?.port ?? 0,
          name: deviceName,
        );
        if (!_disposed) state = state.copyWith(self: l.info);
      } catch (_) {}
    });
  }

  Future<void> _checkNetwork() async {
    if (_link == null || _disposed) return;
    final now = (await ref.read(lanLocalAddressesProvider)()).toSet();
    if (now.length == _addrs.length && now.containsAll(_addrs)) return;
    _addrs = now;
    debugPrint('LAN: network changed, restarting LAN Link');
    await restart();
  }

  // ---- peers ---------------------------------------------------------------

  void _onPeers(List<ll.LanPeer> peers) {
    if (_disposed) return;
    final online = {for (final p in peers) if (p.connected || p.online) p.deviceId};
    final rc = {...state.remoteCalls}..removeWhere((k, _) => !online.contains(k));
    state = state.copyWith(peers: peers, remoteCalls: rc);
    _keepConnected(peers);
  }

  final Map<String, DateTime> _lastDial = {};

  /// lan_link only auto-connects from the side with the smaller deviceId. A
  /// device we added by address may be the larger one, and then the other
  /// side has no way to reach us. Dialling once ourselves (a harmless
  /// calls query) registers the connection on both ends.
  void _keepConnected(List<ll.LanPeer> peers) {
    final l = _link;
    if (l == null) return;
    final now = DateTime.now();
    for (final p in peers) {
      if (!p.trusted || !p.online || p.connected || p.address == null) continue;
      final last = _lastDial[p.deviceId];
      if (last != null && now.difference(last) < const Duration(seconds: 15)) continue;
      _lastDial[p.deviceId] = now;
      unawaited(l.requestCallsList(p.deviceId).catchError((_) {}));
    }
  }

  String nameOf(String peerId) {
    final p = _link?.peerById(peerId);
    if (p != null && p.name.isNotEmpty) return p.name;
    return peerId;
  }

  ll.PairingSession pair(String peerId) {
    final l = _link;
    if (l == null) throw StateError('LAN Link is not running');
    return l.pairWith(peerId);
  }

  Future<void> unpair(String peerId) async {
    await _link?.unpair(peerId);
  }

  /// Handles a `softphonepro://lan?...` deep link / scanned QR payload.
  Future<ll.LanPeer> connectFromLink(Uri link) => connectManual(link.toString());

  /// Connects to a device by `host:port` or QR payload. Returns the peer.
  Future<ll.LanPeer> connectManual(String raw) async {
    final l = _link;
    final l10n = ref.read(l10nProvider);
    if (l == null) throw ll.LanLinkException('not_running', l10n.lanErrNotRunning);
    final t = LanTarget.parse(raw);
    if (t == null) throw ll.LanLinkException('bad_address', l10n.lanErrBadAddress);
    if (t.deviceId != null) {
      final info = await ll.fetchDeviceInfo(t.host, t.port);
      if (info.deviceId != t.deviceId) {
        throw ll.LanLinkException('fingerprint_mismatch', l10n.lanErrFingerprint);
      }
    }
    return l.connectManual(t.host, t.port);
  }

  // ---- chat ----------------------------------------------------------------

  ChatMessage _toApp(ll.ChatMessage m) {
    final status = m.incoming
        ? MessageStatus.received
        : switch (m.status) {
            ll.ChatStatus.queued || ll.ChatStatus.sending => MessageStatus.sending,
            ll.ChatStatus.sent => MessageStatus.sent,
            ll.ChatStatus.delivered => MessageStatus.delivered,
            ll.ChatStatus.read => MessageStatus.read,
            ll.ChatStatus.failed => MessageStatus.failed,
          };
    return ChatMessage(
      id: 'lan-${m.id}',
      channel: kChannelLan,
      accountId: m.peerId,
      peer: m.peerId,
      outgoing: !m.incoming,
      body: m.text,
      time: DateTime.fromMillisecondsSinceEpoch(m.ts),
      status: status,
      read: !m.incoming,
      peerDisplay: nameOf(m.peerId),
    );
  }

  void _onChat(ll.ChatMessage m) {
    if (_disposed) return;
    final msgs = ref.read(messagesProvider.notifier);
    var app = _toApp(m);
    if (m.incoming) {
      final key = lanConversationKey(m.peerId);
      final open = ref.read(lanOpenThreadProvider) == m.peerId;
      app = ChatMessage(
        id: app.id,
        channel: app.channel,
        accountId: app.accountId,
        peer: app.peer,
        outgoing: false,
        body: app.body,
        time: DateTime.now(),
        status: MessageStatus.received,
        read: open,
        peerDisplay: app.peerDisplay,
      );
      msgs.addExternal(app);
      msgs.setExternalTyping(key, false);
      if (open) {
        unawaited(_link?.markRead(m.peerId, m.id).catchError((_) {}));
      } else {
        unawaited(ref.read(platformServicesProvider).showMessageNotification(
              title: app.peerDisplay,
              body: app.body,
              payload: app.conversationKey,
            ));
      }
    } else {
      msgs.addExternal(app);
    }
  }

  /// Sends a LAN chat message. Failures are stored as a failed message.
  Future<void> sendChat(String peerId, String text) async {
    final l = _link;
    final body = text.trim();
    if (body.isEmpty) return;
    if (l == null) {
      _putFailed(peerId, body, 'LAN Link is off');
      return;
    }
    try {
      await l.sendChat(peerId, body, queue: true);
    } on ll.LanLinkException catch (e) {
      _putFailed(peerId, body, e.message);
    } catch (e) {
      _putFailed(peerId, body, '$e');
    }
  }

  void _putFailed(String peerId, String body, String why) {
    ref.read(messagesProvider.notifier).addExternal(ChatMessage(
          id: 'lan-local-${DateTime.now().microsecondsSinceEpoch}',
          channel: kChannelLan,
          accountId: peerId,
          peer: peerId,
          outgoing: true,
          body: body,
          time: DateTime.now(),
          status: MessageStatus.failed,
          peerDisplay: nameOf(peerId),
          error: why,
        ));
  }

  /// Removes a failed message and sends it again.
  Future<void> retryChat(ChatMessage m) async {
    await ref.read(messagesProvider.notifier).removeMessage(m.id);
    await sendChat(m.peer, m.body);
  }

  Future<void> sendTyping(String peerId, bool typing) async {
    if (!_settings.sendTyping) return;
    try {
      await _link?.sendTyping(peerId, typing);
    } catch (_) {}
  }

  /// Marks the thread read locally and tells the sender (read receipts).
  Future<void> readThread(String peerId) async {
    final msgs = ref.read(messagesProvider.notifier);
    final key = lanConversationKey(peerId);
    final unread = ref
        .read(messagesProvider)
        .thread(key)
        .where((m) => !m.outgoing && !m.read)
        .toList();
    msgs.markRead(key);
    for (final m in unread) {
      try {
        await _link?.markRead(peerId, m.id.replaceFirst('lan-', ''));
      } catch (_) {}
    }
  }

  void _onTyping(ll.TypingEvent e) {
    if (_disposed) return;
    final set = {...state.typing};
    _typingTimers.remove(e.peerId)?.cancel();
    if (e.typing) {
      set.add(e.peerId);
      _typingTimers[e.peerId] = Timer(const Duration(seconds: 8), () {
        if (_disposed) return;
        state = state.copyWith(typing: {...state.typing}..remove(e.peerId));
        ref.read(messagesProvider.notifier).setExternalTyping(lanConversationKey(e.peerId), false);
      });
    } else {
      set.remove(e.peerId);
    }
    state = state.copyWith(typing: set);
    ref.read(messagesProvider.notifier).setExternalTyping(lanConversationKey(e.peerId), e.typing);
  }

  // ---- files ---------------------------------------------------------------

  JsonStore get _fileStore => JsonStore(ref.read(appDatabaseProvider).db, 'lan_files');

  Future<List<LanFileEntry>> _loadHistory() async {
    try {
      final all = [for (final j in await _fileStore.all()) LanFileEntry.fromJson(j)];
      all.sort((a, b) => b.time.compareTo(a.time));
      return all.take(100).toList();
    } catch (_) {
      return const [];
    }
  }

  ll.FileTransfer? sendFile(String peerId, String path) {
    final l = _link;
    if (l == null) return null;
    try {
      return l.sendFile(peerId, path);
    } on ll.LanLinkException catch (e) {
      ref.read(noticeProvider.notifier).error(e.message);
      return null;
    }
  }

  Future<void> acceptFile(ll.FileTransfer t) async {
    try {
      await t.accept();
    } catch (_) {}
  }

  Future<void> declineFile(ll.FileTransfer t) async {
    try {
      await t.decline();
    } catch (_) {}
  }

  Future<void> cancelTransfer(ll.FileTransfer t) async {
    try {
      await t.cancel();
    } catch (_) {}
  }

  void _trackTransfer(ll.FileTransfer t) {
    if (_disposed) return;
    state = state.copyWith(transfers: [t, ...state.transfers.where((e) => e.id != t.id)]);
    final auto = t.incoming && _settings.lanAutoAcceptFiles && (_link?.peerById(t.peerId)?.trusted ?? false);
    if (t.incoming && !auto && !_incomingFiles.isClosed) _incomingFiles.add(t);
    final sub = t.updates.listen((_) => _bump(), onDone: () {});
    unawaited(t.done.then((_) async {
      await sub.cancel();
      await _finished(t);
    }));
  }

  void _bump() {
    if (_bumpTimer != null || _disposed) return;
    _bumpTimer = Timer(const Duration(milliseconds: 120), () {
      _bumpTimer = null;
      if (!_disposed) state = state.copyWith(rev: state.rev + 1);
    });
  }

  Future<void> _finished(ll.FileTransfer t) async {
    if (_disposed) return;
    final ok = t.state == ll.TransferState.completed;
    final entry = LanFileEntry(
      id: t.id,
      peerId: t.peerId,
      peerName: nameOf(t.peerId),
      name: t.savedPath != null ? p.basename(t.savedPath!) : t.name,
      size: t.size,
      incoming: t.incoming,
      time: DateTime.now(),
      path: t.savedPath ?? t.sourcePath ?? '',
      ok: ok,
      error: ok ? '' : (t.error ?? t.state.name),
    );
    // Declined/cancelled offers that never moved data are not worth listing.
    final listed = ok || t.state == ll.TransferState.failed || t.bytesDone > 0;
    state = state.copyWith(
      transfers: state.transfers.where((e) => e.id != t.id).toList(),
      history: listed ? [entry, ...state.history].take(100).toList() : state.history,
      rev: state.rev + 1,
    );
    if (listed) {
      try {
        await _fileStore.put(entry.id, entry.toJson());
      } catch (_) {}
    }
    final notices = ref.read(noticeProvider.notifier);
    final l10n = ref.read(l10nProvider);
    if (ok && t.incoming) {
      notices.show(l10n.lanNoticeReceived(entry.name, entry.peerName));
    } else if (ok) {
      notices.show(l10n.lanNoticeSent(entry.name, entry.peerName));
    } else if (t.state == ll.TransferState.declined && !t.incoming) {
      notices.error(l10n.lanNoticeDeclined(entry.peerName, t.name));
    } else if (t.state == ll.TransferState.failed) {
      notices.error(l10n.lanNoticeTransferFailed(entry.error));
    }
  }

  Future<void> clearHistory() async {
    state = state.copyWith(history: const []);
    try {
      await _fileStore.clear();
    } catch (_) {}
  }

  // ---- remote call lists (call pull) --------------------------------------

  Future<void> requestCalls(String peerId) async {
    try {
      await _link?.requestCallsList(peerId);
    } catch (_) {}
  }

  void _onCallsList(ll.CallsListEvent e) {
    if (_disposed) return;
    state = state.copyWith(remoteCalls: {...state.remoteCalls, e.peer.deviceId: e.calls});
  }

  /// Calls we would hand to a requesting device.
  List<ll.CallSummary> _localCalls() {
    final out = <ll.CallSummary>[];
    final acc = ref.read(accountsProvider);
    for (final c in ref.read(callsProvider).live) {
      if (c.info.uid == kLanAccountUid || !c.isConfirmed || c.lan != null) continue;
      out.add(ll.CallSummary(
        callId: '${c.cid}',
        remoteName: c.info.remoteDisplay,
        remoteNumber: c.number,
        durationSec: c.duration.inSeconds,
        accountName: acc.byId(c.accountId)?.name ?? '',
      ));
    }
    return out;
  }

  void _onCallsQuery(ll.IncomingCallsQuery q) {
    if (!q.peer.trusted) return;
    unawaited(q.respond(_settings.lanAllowPull ? _localCalls() : const []).catchError((_) {}));
  }

  Future<void> pull(String peerId, ll.CallSummary call) async {
    await _link?.requestPull(peerId, call.callId);
    ref.read(lanPullIntentProvider.notifier).expect(peerId, call.callId);
  }

  // ---- intercom ------------------------------------------------------------

  /// Intercom requests the user has to approve ("Allow intercom from X?").
  /// Answer with [ll.IncomingIntercom.respond]; unanswered requests are denied
  /// after [intercomPromptTimeout].
  Stream<ll.IncomingIntercom> get intercomPrompts => _intercomPrompts.stream;

  static const intercomPromptTimeout = Duration(seconds: 9);
  static const intercomGrantSeconds = 30;
  Duration intercomRequestTimeout = const Duration(seconds: 10);

  void _onIntercomRequest(ll.IncomingIntercom req) {
    if (_disposed) return;
    if (!req.peer.trusted || !_settings.lanAllowIntercom) {
      unawaited(req.respond(false).catchError((_) {}));
      return;
    }
    if (_settings.lanIntercomPrompt && _intercomPrompts.hasListener) {
      _intercomPrompts.add(req);
      Timer(intercomPromptTimeout, () {
        if (!req.answered) unawaited(req.respond(false).catchError((_) {}));
      });
      return;
    }
    unawaited(req.respond(true, expiresSec: intercomGrantSeconds).catchError((_) {}));
  }

  /// True while [peerId] holds an unexpired intercom grant given by us.
  bool intercomGranted(String peerId) => _settings.lanAllowIntercom && (_link?.intercomGranted(peerId) ?? false);

  // ---- direct calls --------------------------------------------------------

  /// Direct LAN SIP call (or intercom) to a paired device.
  Future<int?> callPeer(String peerId, {bool intercom = false}) async {
    final l = _link;
    final notices = ref.read(noticeProvider.notifier);
    final l10n = ref.read(l10nProvider);
    if (l == null) {
      notices.error(l10n.lanNoticeNeedLanOn);
      return null;
    }
    final peer = l.peerById(peerId);
    final uri = peer?.sipUri;
    if (peer == null || !peer.trusted) {
      notices.error(l10n.lanNoticePairFirst);
      return null;
    }
    if (uri == null || !peer.online) {
      notices.error(l10n.lanNoticeNotReachable(peer.name));
      return null;
    }
    if (intercom) {
      notices.show(l10n.lanNoticeAsking(peer.name));
      var allowed = false;
      try {
        allowed = (await l.requestIntercom(peerId, timeout: intercomRequestTimeout)).allowed;
      } catch (_) {}
      if (!allowed) {
        notices.error(l10n.lanNoticeIntercomDenied(peer.name));
        return null;
      }
    }
    return ref.read(callsProvider.notifier).dialLan(
          uri,
          headers: {
            kHdrDevice: l.deviceId,
            if (intercom) 'Call-Info': '<sip:intercom@softphonepro.local>;answer-after=0',
            if (intercom) kHdrIntercom: '1',
          },
          meta: LanCallMeta(peerId: peerId, peerName: peer.name, paired: true, intercom: intercom, outgoing: true),
        );
  }

  /// IP address of this device that [peer] can reach (same subnet if possible).
  String localAddressFor(InternetAddress? peer) {
    if (peer != null && peer.isLoopback) return '127.0.0.1';
    final addrs = state.addresses;
    if (peer != null) {
      final pp = peer.address.split('.');
      for (final a in addrs) {
        final ap = a.split('.');
        if (ap.length == 4 && pp.length == 4 && ap[0] == pp[0] && ap[1] == pp[1] && ap[2] == pp[2]) return a;
      }
    }
    return addrs.isNotEmpty ? addrs.first : '127.0.0.1';
  }
}

final lanControllerProvider = NotifierProvider<LanController, LanState>(LanController.new);

/// Peer whose LAN chat thread is currently on screen (for read receipts).
class LanOpenThread extends Notifier<String?> {
  @override
  String? build() => null;
  void set(String? v) => state = v;

  /// Clears the marker only if [peer] is still the open thread.
  void clearIf(String peer) {
    if (state == peer) state = null;
  }
}

final lanOpenThreadProvider = NotifierProvider<LanOpenThread, String?>(LanOpenThread.new);

/// Pull requests we sent: lets us auto-accept the resulting handoff offer.
class LanPullIntent extends Notifier<Map<String, ({String callId, DateTime at})>> {
  @override
  Map<String, ({String callId, DateTime at})> build() => {};
  void expect(String peerId, String callId) => state = {...state, peerId: (callId: callId, at: DateTime.now())};
  bool consume(String peerId) {
    final e = state[peerId];
    if (e == null) return false;
    state = {...state}..remove(peerId);
    return DateTime.now().difference(e.at) < const Duration(seconds: 30);
  }
}

final lanPullIntentProvider = NotifierProvider<LanPullIntent, Map<String, ({String callId, DateTime at})>>(LanPullIntent.new);
