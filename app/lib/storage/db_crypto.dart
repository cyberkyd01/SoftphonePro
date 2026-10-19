import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:pointycastle/export.dart';
import 'package:sembast/sembast.dart';

/// Signature stored (encrypted) in the database header; opening with a wrong
/// key or a plain file fails cleanly.
const kDbCodecSignature = 'softphonepro-aes256gcm-v1';

/// Raised when a record cannot be decrypted or authenticated.
class DbCryptoException implements Exception {
  DbCryptoException(this.message);
  final String message;
  @override
  String toString() => 'DbCryptoException: $message';
}

/// 32 random bytes, base64 encoded (the form stored in the secrets store).
String generateDbKey([Random? random]) {
  final r = random ?? Random.secure();
  return base64Encode(List<int>.generate(32, (_) => r.nextInt(256)));
}

/// Synchronous AES-256-GCM over JSON records: each record gets a fresh random
/// 96-bit nonce; the stored line is `base64(nonce || ciphertext || tag)`.
class AesGcmJsonCodec extends Codec<Object?, String> {
  AesGcmJsonCodec(this._key, {Random? random})
    : _random = random ?? Random.secure() {
    if (_key.length != 32) {
      throw ArgumentError('AES-256 key must be 32 bytes');
    }
  }

  final Uint8List _key;
  final Random _random;

  factory AesGcmJsonCodec.fromBase64(String key) =>
      AesGcmJsonCodec(Uint8List.fromList(base64Decode(key)));

  @override
  late final Converter<Object?, String> encoder = _Enc(this);
  @override
  late final Converter<String, Object?> decoder = _Dec(this);

  Uint8List _run(bool encrypt, Uint8List nonce, Uint8List input) {
    final c = GCMBlockCipher(AESEngine())
      ..init(
        encrypt,
        AEADParameters(KeyParameter(_key), 128, nonce, Uint8List(0)),
      );
    return c.process(input);
  }
}

class _Enc extends Converter<Object?, String> {
  _Enc(this._c);
  final AesGcmJsonCodec _c;
  @override
  String convert(Object? input) {
    final nonce = Uint8List.fromList(
      List<int>.generate(12, (_) => _c._random.nextInt(256)),
    );
    final ct = _c._run(true, nonce, Uint8List.fromList(utf8.encode(jsonEncode(input))));
    return base64Encode(Uint8List(12 + ct.length)
      ..setRange(0, 12, nonce)
      ..setRange(12, 12 + ct.length, ct));
  }
}

class _Dec extends Converter<String, Object?> {
  _Dec(this._c);
  final AesGcmJsonCodec _c;
  @override
  Object? convert(String input) {
    try {
      final raw = base64Decode(input);
      if (raw.length < 12 + 16) throw DbCryptoException('record too short');
      final clear = _c._run(
        false,
        Uint8List.fromList(raw.sublist(0, 12)),
        Uint8List.fromList(raw.sublist(12)),
      );
      return jsonDecode(utf8.decode(clear));
    } on DbCryptoException {
      rethrow;
    } catch (e) {
      throw DbCryptoException('cannot decrypt (wrong key or corrupt data)');
    }
  }
}

SembastCodec sembastCodecForKey(String base64Key) => SembastCodec(
  signature: kDbCodecSignature,
  codec: AesGcmJsonCodec.fromBase64(base64Key),
);
