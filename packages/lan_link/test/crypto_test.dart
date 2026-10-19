import 'dart:typed_data';

import 'package:lan_link/lan_link.dart';
import 'package:lan_link/src/identity.dart';
import 'package:lan_link/src/util.dart';
import 'package:test/test.dart';

class Pair {
  Pair(this.i, this.r, this.idI, this.idR);
  final Handshake i, r;
  final LocalIdentity idI, idR;
}

Future<Pair> setup({
  HandshakeMode mode = HandshakeMode.connect,
  List<int>? expectI,
  List<int>? expectR,
  bool exchangeHellos = true,
}) async {
  final a = await LocalIdentity.generate();
  final b = await LocalIdentity.generate();
  final hi = await Handshake.create(
      identity: a,
      initiator: true,
      mode: mode,
      expectedPeerEd: expectI ?? b.edPub);
  final hr = await Handshake.create(
      identity: b,
      initiator: false,
      mode: mode,
      expectedPeerEd: expectR ?? a.edPub);
  if (exchangeHellos) {
    await hr.setPeerHello(hi.ownHello);
    await hi.setPeerHello(hr.ownHello);
  }
  return Pair(hi, hr, a, b);
}

void main() {
  test('good path: both sides derive matching keys and SAS', () async {
    final p = await setup(mode: HandshakeMode.pair);
    final si = await p.i.finish(await p.r.makeAuth());
    final sr = await p.r.finish(await p.i.makeAuth());
    expect(si.sas, sr.sas);
    expect(si.sas, matches(RegExp(r'^\d{6}$')));
    expect(si.transcriptHash, sr.transcriptHash);

    final f1 = await si.seal([1, 2, 3]);
    expect(await sr.open(f1), [1, 2, 3]);
    final f2 = await sr.seal([9, 8]);
    expect(await si.open(f2), [9, 8]);
    // ciphertext does not contain plaintext framing
    expect(f1.length, 8 + 3 + 16);
  });

  test('deviceId is first 16 hex chars of sha256(ed pub)', () async {
    final id = await LocalIdentity.generate();
    expect(
        id.deviceId, hexEncode(await sha256Bytes(id.edPub)).substring(0, 16));
  });

  test('different sessions have different SAS (overwhelmingly)', () async {
    final a = await setup();
    final b = await setup();
    final s1 = await a.i.finish(await a.r.makeAuth());
    final s2 = await b.i.finish(await b.r.makeAuth());
    expect(s1.sas == s2.sas && s1.transcriptHash == s2.transcriptHash, isFalse);
  });

  test('tampered signature is rejected', () async {
    final p = await setup();
    final sig = await p.r.makeAuth();
    sig[10] ^= 1;
    expect(
        p.i.finish(sig),
        throwsA(isA<HandshakeException>()
            .having((e) => e.code, 'code', 'auth_failed')));
  });

  test('signature by wrong key is rejected', () async {
    final p = await setup();
    final other = await setup();
    expect(p.i.finish(await other.r.makeAuth()),
        throwsA(isA<HandshakeException>()));
  });

  test('wrong trusted key is rejected (connect mode)', () async {
    final stranger = await LocalIdentity.generate();
    final a = await LocalIdentity.generate();
    final b = await LocalIdentity.generate();
    final hi = await Handshake.create(
        identity: a,
        initiator: true,
        mode: HandshakeMode.connect,
        expectedPeerEd: stranger.edPub);
    final hr = await Handshake.create(
        identity: b, initiator: false, mode: HandshakeMode.connect);
    expect(
        hi.setPeerHello(hr.ownHello),
        throwsA(isA<HandshakeException>()
            .having((e) => e.code, 'code', 'key_mismatch')));
  });

  test('MITM swapping ephemeral key breaks transcript signatures', () async {
    final a = await LocalIdentity.generate();
    final b = await LocalIdentity.generate();
    final m = await Handshake.create(
        identity: a, initiator: true, mode: HandshakeMode.pair);
    final hi = await Handshake.create(
        identity: a, initiator: true, mode: HandshakeMode.pair);
    final hr = await Handshake.create(
        identity: b, initiator: false, mode: HandshakeMode.pair);
    // Responder sees a Hello whose ephemeral key was replaced by the attacker.
    final forged = Hello(
        deviceId: hi.ownHello.deviceId,
        edPub: hi.ownHello.edPub,
        xStaticPub: hi.ownHello.xStaticPub,
        ephPub: m.ownHello.ephPub,
        nonce: hi.ownHello.nonce,
        mode: HandshakeMode.pair);
    await hr.setPeerHello(forged);
    await hi.setPeerHello(hr.ownHello);
    // Initiator's real Auth does not verify against the forged transcript.
    expect(hr.finish(await hi.makeAuth()), throwsA(isA<HandshakeException>()));
  });

  test('device id must match key', () async {
    final p = await setup(exchangeHellos: false);
    final bad = Hello(
        deviceId: '0000000000000000',
        edPub: p.r.ownHello.edPub,
        xStaticPub: p.r.ownHello.xStaticPub,
        ephPub: p.r.ownHello.ephPub,
        nonce: p.r.ownHello.nonce,
        mode: HandshakeMode.connect);
    expect(
        p.i.setPeerHello(bad),
        throwsA(isA<HandshakeException>()
            .having((e) => e.code, 'code', 'id_mismatch')));
  });

  test('replay, reorder, tamper and reflection are rejected', () async {
    final p = await setup();
    final si = await p.i.finish(await p.r.makeAuth());
    final sr = await p.r.finish(await p.i.makeAuth());
    final f0 = await si.seal([0]);
    final f1 = await si.seal([1]);
    final f2 = await si.seal([2]);
    expect(await sr.open(f0), [0]);
    expect(sr.open(f0), throwsA(isA<HandshakeException>())); // replay
    expect(await sr.open(f2), [2]); // gaps allowed, must increase
    expect(sr.open(f1), throwsA(isA<HandshakeException>())); // out of order

    final f3 = await si.seal([3]);
    final bad = Uint8List.fromList(f3)..[9] ^= 0x40;
    expect(sr.open(bad), throwsA(isA<HandshakeException>())); // tamper
    expect(await sr.open(f3), [3]); // forged frame did not advance counter

    // reflect initiator frame back to the initiator
    final f4 = await si.seal([4]);
    expect(si.open(f4), throwsA(isA<HandshakeException>()));
    // short frame
    expect(sr.open([1, 2, 3]), throwsA(isA<HandshakeException>()));
  });
}
