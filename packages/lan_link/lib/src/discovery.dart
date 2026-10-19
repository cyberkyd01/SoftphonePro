import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'models.dart';
import 'util.dart';

enum DiscoveryEventType { found, updated, lost }

class DiscoveryEvent {
  DiscoveryEvent(this.type, this.deviceId, {this.info, this.address});
  final DiscoveryEventType type;
  final String deviceId;

  /// Present for found / updated.
  final DeviceInfo? info;
  final InternetAddress? address;

  @override
  String toString() => 'DiscoveryEvent($type, $deviceId, $address)';
}

/// Pluggable peer discovery. The Flutter app can add an mDNS (bonsoir)
/// implementation of this interface.
abstract class DiscoveryProvider {
  Stream<DiscoveryEvent> get events;
  Future<void> start();
  Future<void> stop();

  /// Publish (or update) our own info. May be called before or after [start].
  void announce(DeviceInfo info);
}

/// Fetches public info from `http://host:port/spp/v1/info`.
Future<DeviceInfo> fetchDeviceInfo(String host, int port,
    {Duration timeout = const Duration(seconds: 5)}) async {
  final client = HttpClient()..connectionTimeout = timeout;
  try {
    final req = await client
        .getUrl(
            Uri(scheme: 'http', host: host, port: port, path: '/spp/v1/info'))
        .timeout(timeout);
    final resp = await req.close().timeout(timeout);
    if (resp.statusCode != 200) {
      throw LanLinkException('bad_response', 'HTTP ${resp.statusCode}');
    }
    final bytes = <int>[];
    await for (final c in resp.timeout(timeout)) {
      bytes.addAll(c);
      if (bytes.length > 8 * 1024) {
        throw LanLinkException('bad_response', 'Response too large');
      }
    }
    return await DeviceInfo.parse(
        Js.parse(utf8.decode(bytes), maxLength: 8192));
  } on LanLinkException {
    rethrow;
  } on TimeoutException {
    throw LanLinkException('timeout', 'Device did not respond');
  } on SocketException catch (e) {
    throw LanLinkException(
        'unreachable', 'Cannot reach $host:$port (${e.message})');
  } on FormatException catch (e) {
    throw LanLinkException('bad_response', 'Invalid device info: ${e.message}');
  } finally {
    client.close(force: true);
  }
}

/// Peers added by hand (host:port, e.g. from a QR code).
class ManualDiscovery implements DiscoveryProvider {
  ManualDiscovery(
      {this.refreshInterval = const Duration(seconds: 10),
      this.maxFailures = 3});

  final Duration refreshInterval;
  final int maxFailures;
  final _ctrl = StreamController<DiscoveryEvent>.broadcast();
  final Map<String, _Manual> _peers = {}; // key host:port
  Timer? _timer;
  bool _started = false;

  @override
  Stream<DiscoveryEvent> get events => _ctrl.stream;

  @override
  void announce(DeviceInfo info) {}

  @override
  Future<void> start() async {
    _started = true;
    _timer ??= Timer.periodic(refreshInterval, (_) => _refreshAll());
  }

  @override
  Future<void> stop() async {
    _started = false;
    _timer?.cancel();
    _timer = null;
    for (final p in _peers.values) {
      if (p.deviceId != null) {
        _ctrl.add(DiscoveryEvent(DiscoveryEventType.lost, p.deviceId!));
      }
    }
    _peers.clear();
  }

  /// Adds a peer and returns its info. Throws [LanLinkException] on failure.
  Future<({DeviceInfo info, InternetAddress address})> addPeer(
      String host, int port) async {
    if (port <= 0 || port > 65535 || host.isEmpty || host.length > 255) {
      throw LanLinkException('bad_address', 'Invalid host or port');
    }
    final info = await fetchDeviceInfo(host, port);
    final key = '$host:$port';
    final addr =
        (await InternetAddress.lookup(host, type: InternetAddressType.IPv4))
            .first;
    final p = _peers[key] = _Manual(host, port)..deviceId = info.deviceId;
    p.last = info;
    p.address = addr;
    _ctrl.add(DiscoveryEvent(DiscoveryEventType.found, info.deviceId,
        info: info, address: addr));
    return (info: info, address: addr);
  }

  void removePeer(String host, int port) {
    final p = _peers.remove('$host:$port');
    if (p?.deviceId != null) {
      _ctrl.add(DiscoveryEvent(DiscoveryEventType.lost, p!.deviceId!));
    }
  }

  Future<void> _refreshAll() async {
    if (!_started) return;
    for (final p in _peers.values.toList()) {
      try {
        final info = await fetchDeviceInfo(p.host, p.port);
        p.failures = 0;
        if (p.last == null || !p.last!.sameAs(info)) {
          p.last = info;
          _ctrl.add(DiscoveryEvent(DiscoveryEventType.updated, info.deviceId,
              info: info, address: p.address));
        }
      } catch (_) {
        if (++p.failures >= maxFailures && p.deviceId != null) {
          _peers.remove('${p.host}:${p.port}');
          _ctrl.add(DiscoveryEvent(DiscoveryEventType.lost, p.deviceId!));
        }
      }
    }
  }
}

class _Manual {
  _Manual(this.host, this.port);
  final String host;
  final int port;
  String? deviceId;
  DeviceInfo? last;
  InternetAddress? address;
  int failures = 0;
}

/// Merges several providers; a device is "lost" only when every provider lost it.
class CompositeDiscovery implements DiscoveryProvider {
  CompositeDiscovery(this.providers);
  final List<DiscoveryProvider> providers;
  final _ctrl = StreamController<DiscoveryEvent>.broadcast();
  final List<StreamSubscription<DiscoveryEvent>> _subs = [];
  // deviceId -> providerIndex -> latest event
  final Map<String, Map<int, DiscoveryEvent>> _state = {};

  @override
  Stream<DiscoveryEvent> get events => _ctrl.stream;

  @override
  void announce(DeviceInfo info) {
    for (final p in providers) {
      p.announce(info);
    }
  }

  @override
  Future<void> start() async {
    for (var i = 0; i < providers.length; i++) {
      final idx = i;
      _subs.add(providers[i].events.listen((e) => _onEvent(idx, e)));
    }
    for (final p in providers) {
      try {
        await p.start();
      } catch (_) {
        // one failing provider must not break the others
      }
    }
  }

  void _onEvent(int idx, DiscoveryEvent e) {
    final m = _state.putIfAbsent(e.deviceId, () => {});
    if (e.type == DiscoveryEventType.lost) {
      m.remove(idx);
      if (m.isEmpty) {
        _state.remove(e.deviceId);
        _ctrl.add(e);
      }
      return;
    }
    final wasKnown = m.isNotEmpty;
    final prev = m.values.isEmpty ? null : m.values.last;
    m[idx] = e;
    final changed = prev == null ||
        prev.address != e.address ||
        (prev.info != null && e.info != null && !prev.info!.sameAs(e.info!));
    if (!wasKnown) {
      _ctrl.add(DiscoveryEvent(DiscoveryEventType.found, e.deviceId,
          info: e.info, address: e.address));
    } else if (changed) {
      _ctrl.add(DiscoveryEvent(DiscoveryEventType.updated, e.deviceId,
          info: e.info, address: e.address));
    }
  }

  @override
  Future<void> stop() async {
    for (final s in _subs) {
      await s.cancel();
    }
    _subs.clear();
    for (final p in providers) {
      try {
        await p.stop();
      } catch (_) {}
    }
    _state.clear();
  }
}
