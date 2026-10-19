import 'dart:convert';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

import 'identity.dart';
import 'models.dart';
import 'util.dart';

enum HandshakeMode { pair, connect }

final AesGcm _aes = AesGcm.with256bits();
final Hkdf _hkdf64 = Hkdf(hmac: Hmac.sha256(), outputLength: 64);
final Hkdf _hkdf4 = Hkdf(hmac: Hmac.sha256(), outputLength: 4);

/// First handshake message.
class Hello {
  Hello({
    required this.deviceId,
    required this.edPub,
    required this.xStaticPub,
    required this.ephPub,
    required this.nonce,
    required this.mode,
    this.v = protocolVersion,
  });

  final int v;
  final String deviceId;
  final Uint8List edPub;
  final Uint8List xStaticPub;
  final Uint8List ephPub;
  final Uint8List nonce;
  final HandshakeMode mode;

  Map<String, dynamic> toJson() => {
        't': 'hello',
        'v': v,
        'deviceId': deviceId,
        'ed25519Pub': b64Encode(edPub),
        'x25519StaticPub': b64Encode(xStaticPub),
        'ephX25519Pub': b64Encode(ephPub),
        'nonce': b64Encode(nonce),
        'mode': mode.name,
      };

  static Hello fromJson(Js j) {
    final modeName = j.str('mode', max: 16);
    final mode = HandshakeMode.values.where((e) => e.name == modeName);
    if (mode.isEmpty) throw const FormatException('bad mode');
    return Hello(
      v: j.integer('v', max: 1000),
      deviceId: j.str('deviceId', max: 16, allowEmpty: false),
      edPub: b64Decode(j.str('ed25519Pub', max: 64), length: 32),
      xStaticPub: b64Decode(j.str('x25519StaticPub', max: 64), length: 32),
      ephPub: b64Decode(j.str('ephX25519Pub', max: 64), length: 32),
      nonce: b64Decode(j.str('nonce', max: 64), length: 32),
      mode: mode.first,
    );
  }

  /// Canonical binary form used in the transcript.
  Uint8List canonical() {
    final id = utf8.encode(deviceId);
    return concatBytes([
      [v, mode == HandshakeMode.pair ? 1 : 2, id.length],
      id,
      edPub,
      xStaticPub,
      ephPub,
      nonce,
    ]);
  }
}

/// Established, authenticated, encrypted session state (no I/O).
class SecureSession {
  SecureSession._(this.isInitiator, this._sendKey, this._recvKey, this.sas,
      this.transcriptHash);

  final bool isInitiator;
  final SecretKey _sendKey;
  final SecretKey _recvKey;

  /// 6 decimal digits shown on both devices in pair mode.
  final String sas;
  final Uint8List transcriptHash;

  int _sendCtr = 0;
  int _recvCtr = -1;

  static const int maxCounter = 1 << 48;
  static const int overhead = 8 + 16;

  int get _sendDir => isInitiator ? 1 : 2;
  int get _recvDir => isInitiator ? 2 : 1;

  static Uint8List _nonce(int counter) {
    final n = Uint8List(12);
    ByteData.sublistView(n).setUint64(4, counter, Endian.big);
    return n;
  }

  /// Frame = counter(8, BE) || ciphertext || tag(16). AAD = direction byte.
  Future<Uint8List> seal(List<int> plaintext) async {
    if (_sendCtr >= maxCounter) {
      throw HandshakeException('counter_exhausted', 'Session must be rekeyed');
    }
    final ctr = _sendCtr++;
    final box = await _aes.encrypt(plaintext,
        secretKey: _sendKey, nonce: _nonce(ctr), aad: [_sendDir]);
    final head = Uint8List(8);
    ByteData.sublistView(head).setUint64(0, ctr, Endian.big);
    return concatBytes([head, box.cipherText, box.mac.bytes]);
  }

  /// Throws [HandshakeException] on tampering, replay or reordering.
  Future<Uint8List> open(List<int> frame) async {
    if (frame.length < overhead) {
      throw HandshakeException('bad_frame', 'Frame too short');
    }
    final bytes = frame is Uint8List ? frame : Uint8List.fromList(frame);
    final ctr = ByteData.sublistView(bytes).getUint64(0, Endian.big);
    if (ctr < 0 || ctr >= maxCounter || ctr <= _recvCtr) {
      throw HandshakeException('replay', 'Replayed or out-of-order frame');
    }
    final ct = bytes.sublist(8, bytes.length - 16);
    final mac = Mac(bytes.sublist(bytes.length - 16));
    try {
      final pt = await _aes.decrypt(SecretBox(ct, nonce: _nonce(ctr), mac: mac),
          secretKey: _recvKey, aad: [_recvDir]);
      _recvCtr = ctr; // commit only after authentication succeeds
      return Uint8List.fromList(pt);
    } on SecretBoxAuthenticationError {
      throw HandshakeException('bad_frame', 'Authentication failed');
    }
  }
}

/// Pure handshake logic. One instance per connection attempt.
class Handshake {
  Handshake._(this.identity, this.isInitiator, this.mode, this._eph,
      this.ownHello, this.expectedPeerEd);

  final LocalIdentity identity;
  final bool isInitiator;
  final HandshakeMode mode;
  final SimpleKeyPair _eph;
  final Hello ownHello;

  /// If non-null the peer's ed25519 key must equal this (connect mode).
  final List<int>? expectedPeerEd;

  Hello? _peer;
  Hello get peerHello => _peer!;

  static Future<Handshake> create({
    required LocalIdentity identity,
    required bool initiator,
    required HandshakeMode mode,
    List<int>? expectedPeerEd,
  }) async {
    final eph = await x25519.newKeyPair();
    final ephPub = Uint8List.fromList((await eph.extractPublicKey()).bytes);
    final hello = Hello(
      deviceId: identity.deviceId,
      edPub: identity.edPub,
      xStaticPub: identity.xPub,
      ephPub: ephPub,
      nonce: randomBytes(32),
      mode: mode,
    );
    return Handshake._(identity, initiator, mode, eph, hello, expectedPeerEd);
  }

  /// Validates the peer's Hello.
  Future<void> setPeerHello(Hello h) async {
    if (h.v != protocolVersion) {
      throw HandshakeException('version', 'Unsupported protocol version');
    }
    if (h.mode != mode) {
      throw HandshakeException('bad_hello', 'Handshake mode mismatch');
    }
    if (h.deviceId != await deviceIdFor(h.edPub)) {
      throw HandshakeException('id_mismatch', 'Device id does not match key');
    }
    if (h.deviceId == identity.deviceId ||
        bytesEqual(h.ephPub, ownHello.ephPub)) {
      throw HandshakeException('bad_hello', 'Reflected handshake');
    }
    final exp = expectedPeerEd;
    if (exp != null && !bytesEqual(exp, h.edPub)) {
      throw HandshakeException(
          'key_mismatch', 'Device key changed - pair again to trust it');
    }
    _peer = h;
  }

  Hello get _hi => isInitiator ? ownHello : peerHello;
  Hello get _hr => isInitiator ? peerHello : ownHello;

  Uint8List get transcript {
    final a = _hi.canonical(), b = _hr.canonical();
    return concatBytes([
      utf8.encode('spp-v1 transcript'),
      [a.length >> 8, a.length & 255],
      a,
      [b.length >> 8, b.length & 255],
      b,
    ]);
  }

  Uint8List _signData(bool signerIsInitiator, Uint8List th) => concatBytes([
        utf8.encode(signerIsInitiator ? 'spp-v1 auth-i' : 'spp-v1 auth-r'),
        th,
      ]);

  /// Our Auth signature: Ed25519 over SHA256(transcript) (role-labelled).
  Future<Uint8List> makeAuth() async {
    final th = await sha256Bytes(transcript);
    final sig =
        await ed25519.sign(_signData(isInitiator, th), keyPair: identity.edKey);
    return Uint8List.fromList(sig.bytes);
  }

  /// Verifies the peer's Auth and derives the session.
  Future<SecureSession> finish(List<int> peerSig) async {
    final th = await sha256Bytes(transcript);
    final ok = await ed25519.verify(
      _signData(!isInitiator, th),
      signature: Signature(peerSig,
          publicKey:
              SimplePublicKey(peerHello.edPub, type: KeyPairType.ed25519)),
    );
    if (!ok) {
      throw HandshakeException('auth_failed', 'Peer signature invalid');
    }
    final peer = peerHello;
    Future<List<int>> dh(SimpleKeyPair kp, List<int> pub) async {
      final s = await x25519.sharedSecretKey(
          keyPair: kp,
          remotePublicKey: SimplePublicKey(pub, type: KeyPairType.x25519));
      final b = await s.extractBytes();
      if (b.every((e) => e == 0)) {
        throw HandshakeException('bad_hello', 'Degenerate key');
      }
      return b;
    }

    final ee = await dh(_eph, peer.ephPub);
    final ss = await dh(identity.xKey, peer.xStaticPub);
    // initiator eph x responder static, then initiator static x responder eph
    final List<int> es, se;
    if (isInitiator) {
      es = await dh(_eph, peer.xStaticPub);
      se = await dh(identity.xKey, peer.ephPub);
    } else {
      es = await dh(identity.xKey, peer.ephPub);
      se = await dh(_eph, peer.xStaticPub);
    }
    final ikm = SecretKey(concatBytes([ee, ss, es, se]));
    final keys = await (await _hkdf64.deriveKey(
            secretKey: ikm, nonce: th, info: utf8.encode('spp-v1 keys')))
        .extractBytes();
    final sasBytes = await (await _hkdf4.deriveKey(
            secretKey: ikm, nonce: th, info: utf8.encode('spp-v1 sas')))
        .extractBytes();
    final sasNum = ByteData.sublistView(Uint8List.fromList(sasBytes))
            .getUint32(0, Endian.big) %
        1000000;
    final k1 = SecretKey(keys.sublist(0, 32)); // initiator -> responder
    final k2 = SecretKey(keys.sublist(32, 64)); // responder -> initiator
    return SecureSession._(isInitiator, isInitiator ? k1 : k2,
        isInitiator ? k2 : k1, sasNum.toString().padLeft(6, '0'), th);
  }
}
