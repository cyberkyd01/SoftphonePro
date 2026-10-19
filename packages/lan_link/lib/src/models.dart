import 'dart:typed_data';

import 'package:collection/collection.dart';

import 'identity.dart';
import 'util.dart';

enum PeerStatus { available, busy, dnd, onCall }

enum Capability { chat, files, handoff, intercom }

const int protocolVersion = 1;

String _ctl(String s) => s.replaceAll(RegExp(r'[\u0000-\u001f\u007f]'), ' ');

/// Public, unauthenticated description of a device (beacons and /info).
/// Authenticity comes only from the handshake.
class DeviceInfo {
  DeviceInfo({
    required this.deviceId,
    required this.name,
    required this.platform,
    required this.linkPort,
    this.sipPort = 0,
    required this.ed25519Pub,
    required this.x25519Pub,
    this.status = PeerStatus.available,
    this.appVersion = '',
    this.aors = const [],
    this.capabilities = const {
      Capability.chat,
      Capability.files,
      Capability.handoff,
      Capability.intercom
    },
  });

  final String deviceId;
  final String name;
  final String platform;
  final int linkPort;
  final int sipPort;
  final Uint8List ed25519Pub;
  final Uint8List x25519Pub;
  final PeerStatus status;
  final String appVersion;
  final List<String> aors;
  final Set<Capability> capabilities;

  DeviceInfo copyWith({
    String? name,
    int? linkPort,
    int? sipPort,
    PeerStatus? status,
    List<String>? aors,
    Set<Capability>? capabilities,
  }) =>
      DeviceInfo(
        deviceId: deviceId,
        name: name ?? this.name,
        platform: platform,
        linkPort: linkPort ?? this.linkPort,
        sipPort: sipPort ?? this.sipPort,
        ed25519Pub: ed25519Pub,
        x25519Pub: x25519Pub,
        status: status ?? this.status,
        appVersion: appVersion,
        aors: aors ?? this.aors,
        capabilities: capabilities ?? this.capabilities,
      );

  Map<String, dynamic> toJson() => {
        'deviceId': deviceId,
        'name': name,
        'platform': platform,
        'linkPort': linkPort,
        'sipPort': sipPort,
        'ed25519Pub': b64Encode(ed25519Pub),
        'x25519Pub': b64Encode(x25519Pub),
        'status': status.name,
        'appVersion': appVersion,
        'aors': aors,
        'capabilities': capabilities.map((e) => e.name).toList(),
      };

  /// Parses and validates; throws [FormatException] on anything suspicious.
  /// Checks that deviceId matches the hash of the ed25519 key.
  static Future<DeviceInfo> parse(Js j) async {
    final edPub = b64Decode(j.str('ed25519Pub', max: 64), length: 32);
    final xPub = b64Decode(j.str('x25519Pub', max: 64), length: 32);
    final id = j.str('deviceId', max: 16, allowEmpty: false);
    if (id != await deviceIdFor(edPub)) {
      throw const FormatException('deviceId does not match key');
    }
    final statusName = j.str('status', max: 16);
    final status =
        PeerStatus.values.firstWhereOrNull((e) => e.name == statusName) ??
            PeerStatus.available;
    final aors = <String>[];
    if (j.has('aors')) {
      for (final a in j.list('aors', max: 8)) {
        if (a is String && a.length <= 128) aors.add(_ctl(a));
      }
    }
    final caps = <Capability>{};
    if (j.has('capabilities')) {
      for (final c in j.list('capabilities', max: 16)) {
        final cap = Capability.values.firstWhereOrNull((e) => e.name == c);
        if (cap != null) caps.add(cap);
      }
    }
    return DeviceInfo(
      deviceId: id,
      name: _ctl(j.str('name', max: 64)).trim(),
      platform: _ctl(j.str('platform', max: 16)),
      linkPort: j.integer('linkPort', max: 65535),
      sipPort: j.optInt('sipPort', max: 65535) ?? 0,
      ed25519Pub: edPub,
      x25519Pub: xPub,
      status: status,
      appVersion: _ctl(j.optStr('appVersion', max: 32) ?? ''),
      aors: aors,
      capabilities: caps,
    );
  }

  /// Fields (other than keys) that matter for change detection.
  bool sameAs(DeviceInfo o) =>
      name == o.name &&
      platform == o.platform &&
      linkPort == o.linkPort &&
      sipPort == o.sipPort &&
      status == o.status &&
      appVersion == o.appVersion &&
      const ListEquality<String>().equals(aors, o.aors) &&
      const SetEquality<Capability>().equals(capabilities, o.capabilities);

  @override
  String toString() => 'DeviceInfo($deviceId, $name, $platform)';
}
