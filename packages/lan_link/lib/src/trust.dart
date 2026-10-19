import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'identity.dart';
import 'util.dart';

/// A device the user has paired with.
class TrustedPeer {
  TrustedPeer({
    required this.deviceId,
    required this.name,
    required this.ed25519Pub,
    required this.pairedAt,
  });

  final String deviceId;
  final String name;
  final Uint8List ed25519Pub;
  final DateTime pairedAt;

  Map<String, dynamic> toJson() => {
        'deviceId': deviceId,
        'name': name,
        'ed25519Pub': b64Encode(ed25519Pub),
        'pairedAt': pairedAt.toUtc().toIso8601String(),
      };

  factory TrustedPeer.fromJson(Map<String, dynamic> j) => TrustedPeer(
        deviceId: j['deviceId'] as String,
        name: j['name'] as String,
        ed25519Pub: b64Decode(j['ed25519Pub'] as String, length: 32),
        pairedAt: DateTime.parse(j['pairedAt'] as String),
      );
}

abstract class TrustStore {
  Future<List<TrustedPeer>> list();
  Future<TrustedPeer?> get(String deviceId);
  Future<void> put(TrustedPeer peer);
  Future<void> remove(String deviceId);
}

class InMemoryTrustStore implements TrustStore {
  final Map<String, TrustedPeer> _m = {};
  @override
  Future<List<TrustedPeer>> list() async => _m.values.toList();
  @override
  Future<TrustedPeer?> get(String deviceId) async => _m[deviceId];
  @override
  Future<void> put(TrustedPeer peer) async => _m[peer.deviceId] = peer;
  @override
  Future<void> remove(String deviceId) async => _m.remove(deviceId);
}

class FileTrustStore implements TrustStore {
  FileTrustStore(this.path);
  final String path;
  Map<String, TrustedPeer>? _cache;

  Future<Map<String, TrustedPeer>> _load() async {
    final c = _cache;
    if (c != null) return c;
    final m = <String, TrustedPeer>{};
    final f = File(path);
    if (await f.exists()) {
      try {
        final d = jsonDecode(await f.readAsString());
        for (final e in (d['peers'] as List)) {
          final p = TrustedPeer.fromJson(e as Map<String, dynamic>);
          // Never trust a record whose id does not match its key.
          if (await deviceIdFor(p.ed25519Pub) == p.deviceId) {
            m[p.deviceId] = p;
          }
        }
      } catch (_) {}
    }
    return _cache = m;
  }

  Future<void> _save() => writeFileAtomic(
      path,
      jsonEncode({
        'v': 1,
        'peers': _cache!.values.map((e) => e.toJson()).toList(),
      }),
      private: true);

  @override
  Future<List<TrustedPeer>> list() async => (await _load()).values.toList();
  @override
  Future<TrustedPeer?> get(String deviceId) async => (await _load())[deviceId];
  @override
  Future<void> put(TrustedPeer peer) async {
    (await _load())[peer.deviceId] = peer;
    await _save();
  }

  @override
  Future<void> remove(String deviceId) async {
    (await _load()).remove(deviceId);
    await _save();
  }
}
