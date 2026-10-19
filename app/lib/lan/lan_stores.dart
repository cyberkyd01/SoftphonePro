import 'dart:convert';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:lan_link/lan_link.dart' as ll;

import '../storage/secrets_store.dart';

/// Device identity keys kept in the app's secrets storage (OS keystore with an
/// encrypted-file fallback).
class SecretsKeyStore implements ll.KeyStore {
  SecretsKeyStore(this._secrets);
  final SecretsStore _secrets;
  static const key = 'lan.identity.v1';

  @override
  Future<ll.KeyMaterial?> load() async {
    final raw = await _secrets.read(key);
    if (raw == null || raw.isEmpty) return null;
    try {
      return ll.KeyMaterial.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> save(ll.KeyMaterial material) => _secrets.write(key, jsonEncode(material.toJson()));
}

/// Paired devices, stored in the secrets storage so they cannot be tampered
/// with by editing the app database. Records whose id does not match their
/// key are discarded.
class SecretsTrustStore implements ll.TrustStore {
  SecretsTrustStore(this._secrets);
  final SecretsStore _secrets;
  static const key = 'lan.trust.v1';
  Map<String, ll.TrustedPeer>? _cache;

  static Future<String> _idFor(Uint8List pub) async {
    final h = await Sha256().hash(pub);
    final b = StringBuffer();
    for (final x in h.bytes.take(8)) {
      b.write(x.toRadixString(16).padLeft(2, '0'));
    }
    return b.toString();
  }

  Future<Map<String, ll.TrustedPeer>> _load() async {
    final c = _cache;
    if (c != null) return c;
    final m = <String, ll.TrustedPeer>{};
    final raw = await _secrets.read(key);
    if (raw != null && raw.isNotEmpty) {
      try {
        for (final e in (jsonDecode(raw)['peers'] as List)) {
          final p = ll.TrustedPeer.fromJson(Map<String, dynamic>.from(e as Map));
          if (await _idFor(p.ed25519Pub) == p.deviceId) m[p.deviceId] = p;
        }
      } catch (_) {}
    }
    return _cache = m;
  }

  Future<void> _save() => _secrets.write(key, jsonEncode({'v': 1, 'peers': _cache!.values.map((e) => e.toJson()).toList()}));

  @override
  Future<List<ll.TrustedPeer>> list() async => (await _load()).values.toList();
  @override
  Future<ll.TrustedPeer?> get(String deviceId) async => (await _load())[deviceId];
  @override
  Future<void> put(ll.TrustedPeer peer) async {
    (await _load())[peer.deviceId] = peer;
    await _save();
  }

  @override
  Future<void> remove(String deviceId) async {
    (await _load()).remove(deviceId);
    await _save();
  }
}
