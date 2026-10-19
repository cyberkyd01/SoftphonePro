import 'dart:async';
import 'dart:io';

import 'package:bonsoir/bonsoir.dart';
import 'package:flutter/foundation.dart';
import 'package:lan_link/lan_link.dart' as ll;

const String kServiceType = '_softphonepro._tcp';

class _Known {
  _Known(this.host, this.port);
  final String host;
  final int port;
  ll.DeviceInfo? info;
}

/// mDNS / DNS-SD discovery (Bonsoir: Android NSD, Apple Bonjour, Windows).
///
/// The advertised service is named after the deviceId and carries the link
/// port; the full (self-verifying) DeviceInfo is then fetched from the peer's
/// `/spp/v1/info` endpoint, so nothing in the TXT record is trusted.
class BonsoirDiscoveryProvider implements ll.DiscoveryProvider {
  BonsoirDiscoveryProvider({
    this.type = kServiceType,
    this.refreshInterval = const Duration(seconds: 10),
  });

  final String type;
  final Duration refreshInterval;

  final _ctrl = StreamController<ll.DiscoveryEvent>.broadcast();
  final Map<String, _Known> _known = {};
  BonsoirBroadcast? _broadcast;
  BonsoirDiscovery? _discovery;
  StreamSubscription<BonsoirDiscoveryEvent>? _sub;
  Timer? _timer;
  ll.DeviceInfo? _own;
  ll.DeviceInfo? _advertised;
  bool _started = false;

  @override
  Stream<ll.DiscoveryEvent> get events => _ctrl.stream;

  @override
  void announce(ll.DeviceInfo info) {
    _own = info;
    if (!_started) return;
    final a = _advertised;
    if (a == null || a.linkPort != info.linkPort || a.sipPort != info.sipPort || a.name != info.name) {
      unawaited(_restartBroadcast());
    }
  }

  @override
  Future<void> start() async {
    if (_started) return;
    _started = true;
    final d = _discovery = BonsoirDiscovery(type: type, printLogs: false);
    await d.ready;
    _sub = d.eventStream?.listen(_onEvent, onError: (_) {});
    await d.start();
    _timer = Timer.periodic(refreshInterval, (_) => _refresh());
    await _restartBroadcast();
  }

  Future<void> _restartBroadcast() async {
    final own = _own;
    try {
      await _broadcast?.stop();
    } catch (_) {}
    _broadcast = null;
    _advertised = null;
    if (own == null || own.linkPort == 0 || !_started) return;
    final name = own.name.length > 40 ? own.name.substring(0, 40) : own.name;
    final b = BonsoirBroadcast(
      printLogs: false,
      service: BonsoirService(
        name: own.deviceId,
        type: type,
        port: own.linkPort,
        attributes: {'id': own.deviceId, 'v': '1', 'sip': '${own.sipPort}', 'n': name},
      ),
    );
    try {
      await b.ready;
      await b.start();
      _broadcast = b;
      _advertised = own;
    } catch (e) {
      debugPrint('mDNS advertise failed: $e');
    }
  }

  void _onEvent(BonsoirDiscoveryEvent e) {
    final s = e.service;
    if (s == null) return;
    switch (e.type) {
      case BonsoirDiscoveryEventType.discoveryServiceResolved:
        if (s is ResolvedBonsoirService) unawaited(_resolved(s));
      case BonsoirDiscoveryEventType.discoveryServiceLost:
        final id = s.name;
        if (_known.remove(id) != null) {
          _ctrl.add(ll.DiscoveryEvent(ll.DiscoveryEventType.lost, id));
        }
      default:
    }
  }

  Future<void> _resolved(ResolvedBonsoirService s) async {
    final host = s.ip;
    final id = s.name;
    if (host == null || host.isEmpty || host.contains(':')) return; // IPv4 only
    if (id == _own?.deviceId) return;
    try {
      final info = await ll.fetchDeviceInfo(host, s.port);
      if (info.deviceId != id) return; // name must match the verified key hash
      final k = _known[id] = _Known(host, s.port)..info = info;
      _ctrl.add(ll.DiscoveryEvent(ll.DiscoveryEventType.found, id,
          info: info, address: InternetAddress(k.host)));
    } catch (_) {}
  }

  Future<void> _refresh() async {
    for (final e in _known.entries.toList()) {
      try {
        final info = await ll.fetchDeviceInfo(e.value.host, e.value.port);
        final prev = e.value.info;
        e.value.info = info;
        if (prev == null || !prev.sameAs(info)) {
          _ctrl.add(ll.DiscoveryEvent(ll.DiscoveryEventType.updated, e.key,
              info: info, address: InternetAddress(e.value.host)));
        }
      } catch (_) {}
    }
  }

  @override
  Future<void> stop() async {
    _started = false;
    _timer?.cancel();
    _timer = null;
    await _sub?.cancel();
    _sub = null;
    try {
      await _discovery?.stop();
    } catch (_) {}
    try {
      await _broadcast?.stop();
    } catch (_) {}
    _discovery = null;
    _broadcast = null;
    for (final id in _known.keys.toList()) {
      _ctrl.add(ll.DiscoveryEvent(ll.DiscoveryEventType.lost, id));
    }
    _known.clear();
  }
}
