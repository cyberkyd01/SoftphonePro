import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:softphonepro/diagnostics/redaction.dart';
import 'package:softphonepro/diagnostics/sip_dialogs.dart';
import 'package:softphonepro/diagnostics/sip_message.dart';
import 'package:softphonepro/diagnostics/trace_export.dart';

String invite({String callId = 'abc123@host', int cseq = 1}) => [
  'INVITE sip:bob@example.com SIP/2.0',
  'Via: SIP/2.0/UDP 10.0.0.2:5060;branch=z9hG4bK776asdhds;rport',
  'From: "Alice" <sip:alice@example.com>;tag=1928301774',
  'To: Bob <sip:bob@example.com>',
  'Call-ID: $callId',
  'CSeq: $cseq INVITE',
  'Contact: <sip:alice@10.0.0.2:5060>',
  'Content-Length: 0',
  '',
  '',
].join('\r\n');

void main() {
  group('parser', () {
    test('request', () {
      final m = SipMessage.parse(invite(), id: 1, outgoing: true);
      expect(m.valid, isTrue);
      expect(m.isRequest, isTrue);
      expect(m.method, 'INVITE');
      expect(m.requestUri, 'sip:bob@example.com');
      expect(m.callId, 'abc123@host');
      expect(m.cseqNum, 1);
      expect(m.cseqMethod, 'INVITE');
      expect(m.fromTag, '1928301774');
      expect(m.toTag, '');
      expect(m.fromUri, 'sip:alice@example.com');
      expect(m.branch, 'z9hG4bK776asdhds');
      expect(m.label, 'INVITE');
      expect(m.isError, isFalse);
    });

    test('response', () {
      final m = SipMessage.parse(
        'SIP/2.0 486 Busy Here\r\nVia: SIP/2.0/UDP a;branch=z9hG4bKx\r\nFrom: <sip:a@b>;tag=1\r\nTo: <sip:c@d>;tag=2\r\nCall-ID: x\r\nCSeq: 7 INVITE\r\n\r\n',
        id: 2,
      );
      expect(m.isResponse, isTrue);
      expect(m.status, 486);
      expect(m.reason, 'Busy Here');
      expect(m.method, 'INVITE');
      expect(m.isError, isTrue);
      expect(m.toTag, '2');
      expect(m.label, '486 Busy Here');
      expect(m.longLabel, '486 Busy Here (INVITE)');
    });

    test('response without reason phrase', () {
      final m = SipMessage.parse('SIP/2.0 200\r\nCall-ID: x\r\nCSeq: 1 BYE\r\n\r\n', id: 1);
      expect(m.valid, isTrue);
      expect(m.status, 200);
      expect(m.label, '200');
    });

    test('folded headers and LF-only line endings', () {
      final m = SipMessage.parse(
        'OPTIONS sip:x@y SIP/2.0\nVia: SIP/2.0/UDP a\n ;branch=z9hG4bKfold\nCall-ID: fold1\nCSeq: 5 OPTIONS\nSubject: hello\n\tworld\n\n',
        id: 3,
      );
      expect(m.valid, isTrue);
      expect(m.branch, 'z9hG4bKfold');
      expect(m.header('subject'), 'hello world');
      expect(m.callId, 'fold1');
    });

    test('compact header forms', () {
      final m = SipMessage.parse(
        'MESSAGE sip:b@c SIP/2.0\r\nv: SIP/2.0/TCP h;branch=z9hG4bKc\r\nf: <sip:a@b>;tag=ft\r\nt: <sip:b@c>;tag=tt\r\ni: compact-id\r\nCSeq: 2 MESSAGE\r\nc: text/plain\r\nl: 2\r\n\r\nhi',
        id: 4,
      );
      expect(m.callId, 'compact-id');
      expect(m.fromTag, 'ft');
      expect(m.toTag, 'tt');
      expect(m.branch, 'z9hG4bKc');
      expect(m.header('Content-Type'), 'text/plain');
      expect(m.body, 'hi');
    });

    test('garbage never throws', () {
      final rnd = Random(42);
      final samples = <String>[
        '',
        '\r\n',
        '\r\n\r\n',
        'garbage',
        'SIP/2.0',
        'SIP/2.0 abc',
        'INVITE',
        'INVITE sip:x',
        '\x00\x01\x02binary',
        'INVITE sip:x SIP/2.0\r\nno colon line\r\n\r\n',
        'SIP/2.0 999999 Huge\r\n\r\n',
        ' leading fold\r\n',
        'A' * 600000,
        'INVITE sip:x SIP/2.0\r\n${'X-H: ${'y' * 100000}\r\n' * 5}\r\n',
        'SIP/2.0 200 OK\r\nCSeq: notanumber INVITE\r\nFrom: <\r\nTo: >>\r\nVia: branch=\r\n\r\n',
        for (var i = 0; i < 50; i++) String.fromCharCodes(List.generate(rnd.nextInt(200), (_) => rnd.nextInt(256))),
        for (var i = 0; i < 20; i++) utf8.decode(List.generate(rnd.nextInt(200), (_) => rnd.nextInt(256)), allowMalformed: true),
      ];
      for (final s in samples) {
        final m = SipMessage.parse(s, id: 1);
        expect(m.label, isA<String>());
        // Accessors must not throw either.
        m.longLabel;
        m.cost;
        m.header('call-id');
      }
      final bad = SipMessage.parse('garbage', id: 1);
      expect(bad.valid, isFalse);
      expect(bad.label, 'Malformed');
      final ka = SipMessage.parse('\r\n\r\n', id: 2);
      expect(ka.keepAlive, isTrue);
      expect(ka.label, 'keep-alive');
    });
  });

  group('redaction', () {
    const auth = 'REGISTER sip:example.com SIP/2.0\r\n'
        'Authorization: Digest username="1001", realm="example.com", nonce="dcd98b7102dd2f0e8b11d0f600bfb0c093", uri="sip:example.com", response="6629fae49393a05397450978507c4ef1", cnonce="0a4f113b", nc=00000001, qop=auth, algorithm=MD5\r\n'
        'Proxy-Authorization: Digest username="1001",\r\n  nonce="n2", response="r2"\r\n'
        'Call-ID: keepme\r\n\r\n';

    test('digest secrets removed, other fields kept', () {
      final r = redactSecrets(auth);
      expect(r, isNot(contains('6629fae49393a05397450978507c4ef1')));
      expect(r, isNot(contains('dcd98b7102dd2f0e8b11d0f600bfb0c093')));
      expect(r, isNot(contains('0a4f113b')));
      expect(r, isNot(contains('"r2"')));
      expect(r, isNot(contains('"n2"')));
      expect(r, contains('username="1001"'));
      expect(r, contains('realm="example.com"'));
      expect(r, contains('Call-ID: keepme'));
      expect(r, contains(kRedacted));
    });

    test('password-like params, uri passwords, srtp keys', () {
      final r = redactSecrets(
        'GET /prov?user=a&password=hunter2&x=1\r\nContact: <sip:bob:s3cret@host>\r\n\r\nm=audio 4000 RTP/SAVP 0\r\na=crypto:1 AES_CM_128_HMAC_SHA1_80 inline:WVNfX19zZW1jdGwgKCkgewkyMjA7fQp9CnVubGVz|2^31\r\n',
      );
      expect(r, isNot(contains('hunter2')));
      expect(r, isNot(contains('s3cret')));
      expect(r, isNot(contains('WVNfX19zZW1jdGwg')));
      expect(r, contains('user=a'));
      expect(r, contains('sip:bob:'));
    });

    test('plain messages are untouched; huge input is safe', () {
      final m = invite();
      expect(redactSecrets(m), m);
      expect(() => redactSecrets('Authorization: ' * 20000), returnsNormally);
    });

    test('export text honours the toggle', () {
      final msg = SipMessage.parse(auth, id: 1, outgoing: true, transport: 'UDP', local: '1.1.1.1:5060', remote: '2.2.2.2:5060');
      expect(buildTraceText([msg]), isNot(contains('6629fae49393')));
      expect(buildTraceText([msg], redact: false), contains('6629fae49393'));
      expect(buildTraceText([msg]), contains('tx UDP to 2.2.2.2:5060'));
    });

    test('pcap has valid header and one record per message', () {
      final msgs = [
        SipMessage.parse(invite(), id: 1, outgoing: true, local: '10.0.0.2:5060', remote: '192.0.2.1:5060'),
        SipMessage.parse('SIP/2.0 200 OK\r\nCall-ID: a\r\nCSeq: 1 INVITE\r\n\r\n', id: 2, local: '10.0.0.2:5060', remote: '192.0.2.1:5060'),
      ];
      final b = buildPcap(msgs);
      final d = ByteData.sublistView(b);
      expect(d.getUint32(0, Endian.little), 0xa1b2c3d4);
      expect(d.getUint32(20, Endian.little), 101);
      // first record: incl_len = 20 + 8 + payload
      final len1 = d.getUint32(24 + 8, Endian.little);
      expect(len1, 28 + utf8.encode(msgs[0].raw).length);
      // IPv4 version/IHL and UDP protocol
      expect(b[24 + 16], 0x45);
      expect(b[24 + 16 + 9], 17);
      // src ip 10.0.0.2 for a tx message
      expect(b.sublist(24 + 16 + 12, 24 + 16 + 16), [10, 0, 0, 2]);
    });
  });

  group('ladder', () {
    SipMessage m(int id, String raw, {required bool tx, String remote = '192.0.2.1:5060', int ms = 0}) =>
        SipMessage.parse(raw, id: id, outgoing: tx, local: '10.0.0.2:5060', remote: remote, time: DateTime.fromMillisecondsSinceEpoch(1700000000000 + ms));

    test('groups by Call-ID in first-seen order', () {
      final msgs = [
        m(1, invite(callId: 'A'), tx: true, ms: 0),
        m(2, invite(callId: 'B'), tx: true, ms: 10),
        m(3, 'SIP/2.0 100 Trying\r\nCall-ID: A\r\nCSeq: 1 INVITE\r\n\r\n', tx: false, ms: 20),
        m(4, 'SIP/2.0 486 Busy Here\r\nCall-ID: A\r\nCSeq: 1 INVITE\r\n\r\n', tx: false, ms: 120),
        m(5, 'garbage', tx: false, ms: 130),
      ];
      final d = groupDialogs(msgs);
      expect(d.map((e) => e.callId), ['A', 'B', '']);
      expect(d[0].messages, hasLength(3));
      expect(d[0].kind, 'INVITE');
      expect(d[0].summary, '486 Busy Here');
      expect(d[0].hasError, isTrue);
      expect(d[1].summary, 'no response');
    });

    test('lanes, directions and timing deltas', () {
      final msgs = [
        m(1, invite(callId: 'A'), tx: true, ms: 0),
        m(2, 'SIP/2.0 180 Ringing\r\nCall-ID: A\r\nCSeq: 1 INVITE\r\n\r\n', tx: false, ms: 250),
        m(3, 'SIP/2.0 302 Moved\r\nCall-ID: A\r\nCSeq: 1 INVITE\r\n\r\n', tx: false, remote: '198.51.100.9:5060', ms: 400),
      ];
      final l = buildLadder(groupDialogs(msgs).single);
      expect(l.lanes, ['10.0.0.2:5060', '192.0.2.1:5060', '198.51.100.9:5060']);
      expect(l.arrows[0].fromLane, 0);
      expect(l.arrows[0].toLane, 1);
      expect(l.arrows[1].fromLane, 1);
      expect(l.arrows[1].toLane, 0);
      expect(l.arrows[2].fromLane, 2);
      expect(l.arrows[1].delta, const Duration(milliseconds: 250));
      expect(l.arrows[2].offset, const Duration(milliseconds: 400));
    });
  });
}
