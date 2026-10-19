import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:lan_link/lan_link.dart' as ll;
import 'package:softphonepro/lan/lan_models.dart';
import 'package:softphonepro/lan/lan_stores.dart';
import 'package:softphonepro/storage/secrets_store.dart';

void main() {
  test('LanTarget parses host:port, URLs and QR payloads', () {
    expect(LanTarget.parse('192.168.1.5:4711')!.port, 4711);
    expect(LanTarget.parse(' host.local:80 ')!.host, 'host.local');
    expect(LanTarget.parse('nope'), isNull);
    expect(LanTarget.parse('1.2.3.4:99999'), isNull);
    final q = LanTarget.encode(host: '10.0.0.2', port: 5000, deviceId: 'abcdef0123456789', name: 'Kitchen iPad');
    final t = LanTarget.parse(q)!;
    expect((t.host, t.port, t.deviceId, t.name), ('10.0.0.2', 5000, 'abcdef0123456789', 'Kitchen iPad'));
    expect(fingerprintOf('abcdef0123456789'), 'ABCD EF01 2345 6789');
  });

  test('secure key and trust stores persist and reject forged records', () async {
    final secrets = MemorySecretsStore();
    final ks = SecretsKeyStore(secrets);
    expect(await ks.load(), isNull);
    final id = await ll.LocalIdentity.loadOrCreate(ks);
    expect((await ll.LocalIdentity.loadOrCreate(SecretsKeyStore(secrets))).deviceId, id.deviceId);

    final ts = SecretsTrustStore(secrets);
    await ts.put(ll.TrustedPeer(deviceId: id.deviceId, name: 'Me', ed25519Pub: id.edPub, pairedAt: DateTime.now()));
    expect((await SecretsTrustStore(secrets).list()).single.name, 'Me');
    // A record whose id does not match its key is dropped.
    final raw = jsonDecode((await secrets.read(SecretsTrustStore.key))!) as Map<String, dynamic>;
    (raw['peers'] as List).first['deviceId'] = '0000000000000000';
    await secrets.write(SecretsTrustStore.key, jsonEncode(raw));
    expect(await SecretsTrustStore(secrets).list(), isEmpty);
  });
}
