import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'discovery.dart';
import 'models.dart';
import 'util.dart';

const int maxBeaconSize = 2048;

/// Beacon wire codec. `{"spp":1,"t":"beacon"|"probe","info":{...}}`.
class BeaconCodec {
  static Uint8List encodeBeacon(DeviceInfo info) => Uint8List.fromList(utf8
      .encode(jsonEncode({'spp': 1, 't': 'beacon', 'info': info.toJson()})));

  static Uint8List encodeProbe(String senderId) => Uint8List.fromList(
      utf8.encode(jsonEncode({'spp': 1, 't': 'probe', 'id': senderId})));

  /// Returns null on anything malformed. Never throws.
  static Future<ParsedBeacon?> decode(List<int> data) async {
    if (data.isEmpty || data.length > maxBeaconSize) return null;
    try {
      final j = Js.parse(utf8.decode(data), maxLength: maxBeaconSize);
      if (j.m['spp'] != 1) return null;
      final t = j.str('t', max: 16);
      if (t == 'probe') {
        return ParsedBeacon(probe: true, probeFrom: j.str('id', max: 16));
      }
      if (t == 'beacon') {
        return ParsedBeacon(info: await DeviceInfo.parse(j.obj('info')));
      }
    } catch (_) {}
    return null;
  }
}

class ParsedBeacon {
  ParsedBeacon({this.info, this.probe = false, this.probeFrom});
  final DeviceInfo? info;
  final bool probe;
  final String? probeFrom;
}

/// Minimal datagram abstraction so the discovery logic is testable.
abstract class BeaconSocket {
  Stream<Datagram> get datagrams;
  void send(List<int> data, InternetAddress address, int port);
  Future<void> close();
}

/// Binds the multicast port and joins the group on all IPv4 interfaces.
class RawBeaconSocket implements BeaconSocket {
  RawBeaconSocket._(this._socket) {
    _socket.listen((e) {
      if (e == RawSocketEvent.read) {
        Datagram? d;
        while ((d = _socket.receive()) != null) {
          _ctrl.add(d!);
        }
      }
    }, onError: (_) {}, onDone: () => _ctrl.close());
  }

  final RawDatagramSocket _socket;
  final _ctrl = StreamController<Datagram>.broadcast();

  static Future<RawBeaconSocket> bind(InternetAddress group, int port) async {
    RawDatagramSocket s;
    try {
      s = await RawDatagramSocket.bind(InternetAddress.anyIPv4, port,
          reuseAddress: true, reusePort: true);
    } catch (_) {
      // reusePort unsupported (e.g. Windows)
      s = await RawDatagramSocket.bind(InternetAddress.anyIPv4, port,
          reuseAddress: true);
    }
    s.multicastLoopback = true;
    s.multicastHops = 1;
    var joined = false;
    try {
      for (final ni in await NetworkInterface.list(
          type: InternetAddressType.IPv4, includeLoopback: true)) {
        try {
          s.joinMulticast(group, ni);
          joined = true;
        } catch (_) {
          // tolerate per-interface failure
        }
      }
    } catch (_) {}
    if (!joined) {
      try {
        s.joinMulticast(group);
      } catch (_) {}
    }
    return RawBeaconSocket._(s);
  }

  @override
  Stream<Datagram> get datagrams => _ctrl.stream;

  @override
  void send(List<int> data, InternetAddress address, int port) {
    try {
      _socket.send(data, address, port);
    } catch (_) {}
  }

  @override
  Future<void> close() async {
    _socket.close();
  }
}

class _Seen {
  _Seen(this.info, this.address, this.lastSeen);
  DeviceInfo info;
  InternetAddress address;
  DateTime lastSeen;
}

/// UDP multicast beacon discovery (fallback to mDNS).
class MulticastDiscovery implements DiscoveryProvider {
  MulticastDiscovery({
    String group = '239.255.77.77',
    this.port = 47777,
    this.beaconInterval = const Duration(seconds: 3),
    this.peerTimeout = const Duration(seconds: 12),
    Future<BeaconSocket> Function(InternetAddress group, int port)?
        socketFactory,
    DateTime Function()? now,
  })  : group = InternetAddress(group),
        _factory = socketFactory ?? RawBeaconSocket.bind,
        _now = now ?? DateTime.now;

  final InternetAddress group;
  final int port;
  final Duration beaconInterval;
  final Duration peerTimeout;
  final Future<BeaconSocket> Function(InternetAddress, int) _factory;
  final DateTime Function() _now;

  final _ctrl = StreamController<DiscoveryEvent>.broadcast();
  final Map<String, _Seen> _seen = {};
  BeaconSocket? _socket;
  StreamSubscription<Datagram>? _sub;
  Timer? _beaconTimer;
  Timer? _sweepTimer;
  DeviceInfo? _own;
  final _rng = Random();

  @override
  Stream<DiscoveryEvent> get events => _ctrl.stream;

  @override
  Future<void> start() async {
    if (_socket != null) return;
    final s = await _factory(group, port);
    _socket = s;
    _sub = s.datagrams.listen((d) => handlePacket(d.data, d.address));
    _beaconTimer = Timer.periodic(beaconInterval, (_) => _sendBeacon());
    _sweepTimer = Timer.periodic(const Duration(seconds: 1), (_) => sweep());
    // Ask everyone to answer immediately.
    final own = _own;
    s.send(BeaconCodec.encodeProbe(own?.deviceId ?? ''), group, port);
    _sendBeacon();
  }

  @override
  Future<void> stop() async {
    _beaconTimer?.cancel();
    _sweepTimer?.cancel();
    _beaconTimer = _sweepTimer = null;
    await _sub?.cancel();
    _sub = null;
    await _socket?.close();
    _socket = null;
    for (final id in _seen.keys.toList()) {
      _ctrl.add(DiscoveryEvent(DiscoveryEventType.lost, id));
    }
    _seen.clear();
  }

  @override
  void announce(DeviceInfo info) {
    final changed = _own == null || !_own!.sameAs(info);
    _own = info;
    if (changed && _socket != null) _sendBeacon();
  }

  void _sendBeacon([InternetAddress? to, int? toPort]) {
    final own = _own;
    final s = _socket;
    if (own == null || s == null) return;
    s.send(BeaconCodec.encodeBeacon(own), to ?? group, toPort ?? port);
  }

  /// Processes one received datagram. Never throws.
  Future<void> handlePacket(List<int> data, InternetAddress from) async {
    final b = await BeaconCodec.decode(data);
    if (b == null) return;
    final ownId = _own?.deviceId;
    if (b.probe) {
      if (b.probeFrom == ownId) return;
      // Jittered unicast reply to the prober.
      Timer(Duration(milliseconds: _rng.nextInt(300)),
          () => _sendBeacon(from, port));
      return;
    }
    final info = b.info!;
    if (info.deviceId == ownId) return;
    final prev = _seen[info.deviceId];
    if (prev == null) {
      if (_seen.length >= 256) return; // bound memory against beacon floods
      _seen[info.deviceId] = _Seen(info, from, _now());
      _ctrl.add(DiscoveryEvent(DiscoveryEventType.found, info.deviceId,
          info: info, address: from));
      return;
    }
    // Reject key substitution for a known id (cannot happen: id = hash(key)).
    final changed = !prev.info.sameAs(info) || prev.address != from;
    prev
      ..info = info
      ..address = from
      ..lastSeen = _now();
    if (changed) {
      _ctrl.add(DiscoveryEvent(DiscoveryEventType.updated, info.deviceId,
          info: info, address: from));
    }
  }

  /// Expires peers not heard from within [peerTimeout].
  void sweep() {
    final t = _now();
    for (final e in _seen.entries.toList()) {
      if (t.difference(e.value.lastSeen) > peerTimeout) {
        _seen.remove(e.key);
        _ctrl.add(DiscoveryEvent(DiscoveryEventType.lost, e.key));
      }
    }
  }
}
