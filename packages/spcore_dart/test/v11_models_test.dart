import 'dart:convert';

import 'package:spcore_dart/spcore_dart.dart';
import 'package:test/test.dart';

Map<String, dynamic> rt(Map<String, dynamic> j) =>
    jsonDecode(jsonEncode(j)) as Map<String, dynamic>;

void main() {
  test('voice isolation models round trip and never throw', () {
    final c = CoreConfig.fromJson({
      'media': {
        'voiceIsolation': {
          'mic': {'enabled': true, 'strength': 0.5},
        },
      },
    });
    expect(c.media.voiceIsolation.mic.enabled, true);
    expect(c.media.voiceIsolation.mic.strength, 0.5);
    expect(c.media.voiceIsolation.incoming.enabled, false);
    final j = rt(c.toJson());
    expect(CoreConfig.fromJson(j), c);
    expect(CoreConfig.fromJson({}).media.voiceIsolation.mic.enabled, false);
    expect(
      c.media.copyWith(voiceIsolation: const VoiceIsolationConfig()),
      isNot(c.media),
    );
    expect(VoiceIsolationSide.fromJson({'strength': 7}).strength, 1.0);
    final st = VoiceIsolationStatus.fromJson({
      'mic': {'enabled': true, 'strength': 0.3, 'vad': 0.9},
      'incoming': 'junk',
    });
    expect(st.mic.vad, 0.9);
    expect(st.incoming, const VoiceIsolationSide());
    expect(VoiceIsolationStatus.fromJson(rt(st.toJson())), st);
    expect(VoiceIsolationResult.fromJson({'available': true}).engine, '');
  });

  test('media file / hold music models', () {
    final i = MediaFileInfo.fromJson({
      'format': 'mp3',
      'durationMs': '1200',
      'sampleRate': 44100,
      'channels': 2,
    });
    expect(i.durationMs, 1200);
    expect(MediaFileInfo.fromJson(rt(i.toJson())), i);
    final m = HoldMusic.fromJson({'file': 'a.wav'});
    expect(m.loop, true);
    expect(m.volume, 1.0);
    expect(m.copyWith(loop: false).toJson()['loop'], false);
  });

  test('RecordingResult gains format and bytes', () {
    final r = RecordingResult.fromJson({
      'file': 'a.ogg',
      'durationMs': 5,
      'format': 'opus',
      'bytes': 99,
    });
    expect(r.format, RecordFormat.opus);
    expect(r.bytes, 99);
    expect(RecordingResult.fromJson(rt(r.toJson())), r);
    final old = RecordingResult.fromJson({'file': 'a.wav', 'durationMs': 1});
    expect(old.format, RecordFormat.wav);
    expect(old.bytes, 0);
    expect(RecordFormat.parse('bogus'), RecordFormat.wav);
  });

  test('AccountConfig.tlsClientCert / AccountInfo.resolvedServer', () {
    final a = AccountConfig.fromJson({
      'transport': 'auto',
      'tlsClientCert': {'certFile': 'c.pem', 'keyFile': 'k.pem'},
    });
    expect(a.transport, AccTransport.auto);
    expect(a.tlsClientCert!.certFile, 'c.pem');
    expect(a.tlsClientCert!.password, isNull);
    final j = rt(a.toJson());
    expect(j['tlsClientCert'], {'certFile': 'c.pem', 'keyFile': 'k.pem'});
    expect(AccountConfig.fromJson(j), a);
    expect(AccountConfig.fromJson({}).tlsClientCert, isNull);
    expect(
      AccountConfig.fromJson({}).toJson().containsKey('tlsClientCert'),
      false,
    );
    final w = a.copyWith(
      tlsClientCert: a.tlsClientCert!.copyWith(password: 'pw'),
    );
    expect(rt(w.toJson())['tlsClientCert']['password'], 'pw');
    final ai = AccountInfo.fromJson({
      'transport': 'tcp',
      'resolvedServer': 'sip.x.com:5060',
    });
    expect(ai.resolvedServer, 'sip.x.com:5060');
    expect(AccountInfo.fromJson(rt(ai.toJson())), ai);
    expect(AccountInfo.fromJson({}).resolvedServer, isNull);
  });

  test('CallInfo identity / diversion / referredBy', () {
    final c = CallInfo.fromJson({
      'cid': 1,
      'assertedIdentity': {'display': 'Bob', 'user': '1002', 'uri': 'sip:b@x'},
      'diversion': [
        {
          'uri': 'sip:a@x',
          'user': 'a',
          'reason': 'unconditional',
          'counter': 1,
        },
        'junk',
      ],
      'referredBy': 'sip:c@x',
    });
    expect(c.assertedIdentity!.display, 'Bob');
    expect(c.diversion.length, 2);
    expect(c.diversion.first.counter, 1);
    expect(c.diversion.last, const DiversionEntry());
    expect(c.referredBy, 'sip:c@x');
    final j = rt(c.toJson());
    expect(CallInfo.fromJson(j), c);
    final d = CallInfo.fromJson({});
    expect(d.assertedIdentity, isNull);
    expect(d.diversion, isEmpty);
    expect(d.referredBy, isNull);
    expect(c.copyWith(referredBy: 'z').referredBy, 'z');
    expect(CallInfo.fromJson({'assertedIdentity': 5}).assertedIdentity, isNull);
  });

  test('call.playDone event', () {
    final e = EngineEvent.fromJson({
      'event': 'call.playDone',
      'cid': 3,
      'playId': 7,
      'file': 'a.wav',
      'reason': 'stopped',
    });
    expect(e, isA<CallPlayDoneEvent>());
    e as CallPlayDoneEvent;
    expect(
      [e.cid, e.playId, e.file, e.reason],
      [3, 7, 'a.wav', PlayDoneReason.stopped],
    );
    final u =
        EngineEvent.fromJson({'event': 'call.playDone', 'reason': 'x'})
            as CallPlayDoneEvent;
    expect(u.reason, PlayDoneReason.unknown);
    expect(u.playId, 0);
  });
}
