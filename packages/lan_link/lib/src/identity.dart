import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

import 'util.dart';

final Ed25519 ed25519 = Ed25519();
final X25519 x25519 = X25519();
final Sha256 sha256Algo = Sha256();

Future<Uint8List> sha256Bytes(List<int> data) async =>
    Uint8List.fromList((await sha256Algo.hash(data)).bytes);

/// deviceId = first 16 hex chars of SHA-256(ed25519 public key).
Future<String> deviceIdFor(List<int> ed25519Pub) async =>
    hexEncode(await sha256Bytes(ed25519Pub)).substring(0, 16);

/// Raw private seeds of a device identity.
class KeyMaterial {
  KeyMaterial(this.edSeed, this.xSeed);
  final Uint8List edSeed;
  final Uint8List xSeed;

  Map<String, dynamic> toJson() =>
      {'v': 1, 'ed': b64Encode(edSeed), 'x': b64Encode(xSeed)};

  factory KeyMaterial.fromJson(Map<String, dynamic> j) => KeyMaterial(
        b64Decode(j['ed'] as String, length: 32),
        b64Decode(j['x'] as String, length: 32),
      );
}

/// Persistence for the device's private keys. The Flutter app should back this
/// with the platform secure store (Keychain / Keystore / DPAPI).
abstract class KeyStore {
  Future<KeyMaterial?> load();
  Future<void> save(KeyMaterial material);
}

class InMemoryKeyStore implements KeyStore {
  KeyMaterial? _m;
  @override
  Future<KeyMaterial?> load() async => _m;
  @override
  Future<void> save(KeyMaterial material) async => _m = material;
}

/// JSON file key store (tests / desktop fallback). File mode is restricted to
/// the owner where the platform supports it. NOT encrypted at rest.
class FileKeyStore implements KeyStore {
  FileKeyStore(this.path);
  final String path;

  @override
  Future<KeyMaterial?> load() async {
    final f = File(path);
    if (!await f.exists()) return null;
    try {
      return KeyMaterial.fromJson(
          jsonDecode(await f.readAsString()) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> save(KeyMaterial material) async {
    await writeFileAtomic(path, jsonEncode(material.toJson()), private: true);
  }
}

/// Writes [content] to [path] via temp file + rename.
Future<void> writeFileAtomic(String path, String content,
    {bool private = false}) async {
  final f = File(path);
  await f.parent.create(recursive: true);
  final tmp = File('$path.tmp');
  await tmp.writeAsString(content, flush: true);
  if (private && !Platform.isWindows) {
    try {
      await Process.run('chmod', ['600', tmp.path]);
    } catch (_) {}
  }
  await tmp.rename(path);
}

/// The local device's cryptographic identity.
class LocalIdentity {
  LocalIdentity._(this.edKey, this.xKey, this.edPub, this.xPub, this.deviceId,
      this.material);

  final SimpleKeyPair edKey;
  final SimpleKeyPair xKey;
  final Uint8List edPub;
  final Uint8List xPub;
  final String deviceId;
  final KeyMaterial material;

  static Future<LocalIdentity> fromMaterial(KeyMaterial m) async {
    final ed = await ed25519.newKeyPairFromSeed(m.edSeed);
    final x = await x25519.newKeyPairFromSeed(m.xSeed);
    final edPub = Uint8List.fromList((await ed.extractPublicKey()).bytes);
    final xPub = Uint8List.fromList((await x.extractPublicKey()).bytes);
    return LocalIdentity._(ed, x, edPub, xPub, await deviceIdFor(edPub), m);
  }

  static Future<LocalIdentity> generate() =>
      fromMaterial(KeyMaterial(randomBytes(32), randomBytes(32)));

  static Future<LocalIdentity> loadOrCreate(KeyStore store) async {
    final m = await store.load();
    if (m != null) return fromMaterial(m);
    final id = await generate();
    await store.save(id.material);
    return id;
  }
}

final Random _rng = Random.secure();

Uint8List randomBytes(int n) {
  final b = Uint8List(n);
  for (var i = 0; i < n; i++) {
    b[i] = _rng.nextInt(256);
  }
  return b;
}
