import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:softphonepro/models/account_profile.dart';
import 'package:softphonepro/services/contact_io.dart';
import 'package:softphonepro/services/provisioning.dart';
import 'package:spcore_dart/spcore_dart.dart';

void main() {
  test('parses flat accounts with variable substitution', () {
    const json = '''
{
  "version": 1,
  "accounts": [
    {"label": "Office", "username": "\${EXT}", "password": "\${PW}", "domain": "\${PBX:-pbx.example.com}",
     "template": "asterisk", "transport": "tls", "voicemail": "*97"}
  ],
  "settings": {"callWaiting": false}
}''';
    final r = Provisioning.parse(json, vars: {'EXT': '1001', 'PW': 's3cret'});
    expect(r.accounts, hasLength(1));
    final a = r.accounts.single;
    expect(a.config.username, '1001');
    expect(a.config.password, 's3cret');
    expect(a.config.domain, 'pbx.example.com');
    expect(a.config.transport, AccTransport.tls);
    expect(a.voicemailNumber, '*97');
    expect(a.providerTemplateId, 'asterisk');
    expect(a.id, isNotEmpty);
    expect(a.config.uid, a.id);
    expect(r.settings['callWaiting'], false);
  });

  test('missing username is reported as warning', () {
    final r = Provisioning.parse('{"accounts":[{"domain":"x.org"}]}');
    expect(r.accounts, isEmpty);
    expect(r.warnings, isNotEmpty);
  });

  test('invalid JSON throws', () {
    expect(() => Provisioning.parse('nope'), throwsA(isA<ProvisioningException>()));
    expect(() => Provisioning.parse('[1]'), throwsA(isA<ProvisioningException>()));
    expect(() => Provisioning.parse('{"version": 99}'), throwsA(isA<ProvisioningException>()));
  });

  test('export / import round trip, passwords optional', () {
    final p = AccountProfile(
      id: 'abc',
      label: 'Home',
      voicemailNumber: '*98',
      forwarding: const ForwardingConfig(mode: ForwardMode.busy, target: '200'),
      config: const AccountConfig(uid: 'abc', username: 'u', password: 'pw', domain: 'd.org', transport: AccTransport.tcp),
    );
    final without = Provisioning.export([p], {'x': 1});
    expect(without.contains('"pw"'), isFalse);
    final withPw = Provisioning.export([p], {'x': 1}, includePasswords: true);
    final r = Provisioning.parse(withPw);
    expect(r.accounts.single.config.password, 'pw');
    expect(r.accounts.single.label, 'Home');
    expect(r.accounts.single.forwarding.mode, ForwardMode.busy);
    expect(r.accounts.single.id, isNot('abc'), reason: 'imports get fresh ids');
    expect(r.settings['x'], 1);
  });

  test('fetch from URL', () async {
    final client = MockClient((req) async {
      expect(req.url.toString(), 'https://prov.example.com/c.json');
      return http.Response(jsonEncode({'accounts': [{'username': '7', 'domain': 'z.org'}]}), 200);
    });
    final r = await Provisioning.fetch(Uri.parse('https://prov.example.com/c.json'), client: client);
    expect(r.accounts.single.config.username, '7');
    final bad = MockClient((_) async => http.Response('no', 404));
    expect(() => Provisioning.fetch(Uri.parse('https://x.org'), client: bad), throwsA(isA<ProvisioningException>()));
  });

  group('contact io', () {
    test('vCard round trip', () {
      const vcf = '''BEGIN:VCARD
VERSION:3.0
FN:Alice Doe
ORG:Acme
TEL;TYPE=WORK:+1 555 0100
IMPP;X-SERVICE-TYPE=SIP:sip:alice@acme.org
EMAIL:alice@acme.org
END:VCARD
BEGIN:VCARD
VERSION:3.0
N:Smith;Bob;;;
TEL:555-0199
END:VCARD''';
      final cs = ContactIo.fromVCard(vcf);
      expect(cs, hasLength(2));
      expect(cs[0].name, 'Alice Doe');
      expect(cs[0].company, 'Acme');
      expect(cs[0].numbers.single.label, 'work');
      expect(cs[0].sipUris.single, 'sip:alice@acme.org');
      expect(cs[1].name, 'Bob Smith');
      final out = ContactIo.toVCard(cs);
      expect(ContactIo.fromVCard(out).map((c) => c.name), ['Alice Doe', 'Bob Smith']);
    });

    test('CSV round trip with quotes', () {
      const csv = 'name,company,mobile,email\n"Doe, Jane",Acme,555 0100,j@x.org\nBob,,,\n';
      final cs = ContactIo.fromCsv(csv);
      expect(cs.first.name, 'Doe, Jane');
      expect(cs.first.numbers.map((n) => n.value), ['555', '0100']);
      final again = ContactIo.fromCsv(ContactIo.toCsv(cs));
      expect(again.first.name, 'Doe, Jane');
    });
  });
}
