import 'dart:convert';

import 'package:spcore_dart/spcore_dart.dart';
import 'package:test/test.dart';

Map<String, dynamic> rt(Map<String, dynamic> j) =>
    jsonDecode(jsonEncode(j)) as Map<String, dynamic>;

void main() {
  test('AccountConfig wsPath / rtcpFb round trip with defaults', () {
    final d = AccountConfig.fromJson({});
    expect(d.wsPath, '/ws');
    expect(d.rtcpFb, false);
    final c = AccountConfig.fromJson({'wsPath': '/sip', 'rtcpFb': true});
    expect(c.wsPath, '/sip');
    final j = rt(c.toJson());
    expect(j['wsPath'], '/sip');
    expect(j['rtcpFb'], true);
    expect(c.copyWith(wsPath: '/x').wsPath, '/x');
    expect(c.copyWith(rtcpFb: false).rtcpFb, false);
  });

  test('empty json yields defaults for every model', () {
    final models = <Map<String, dynamic> Function()>[
      () => CoreConfig.fromJson({}).toJson(),
      () => AccountConfig.fromJson({}).toJson(),
      () => AccountInfo.fromJson({}).toJson(),
      () => CallInfo.fromJson({}).toJson(),
      () => CallStats.fromJson({}).toJson(),
      () => AudioDevices.fromJson({}).toJson(),
      () => CodecInfo.fromJson({}).toJson(),
      () => BuddyInfo.fromJson({}).toJson(),
      () => MwiInfo.fromJson({}).toJson(),
      () => ImMessage.fromJson({}).toJson(),
      () => ImStatus.fromJson({}).toJson(),
      () => ImTyping.fromJson({}).toJson(),
      () => TransportStateInfo.fromJson({}).toJson(),
      () => TlsVerifyInfo.fromJson({}).toJson(),
      () => NatTypeInfo.fromJson({}).toJson(),
      () => OptionsResult.fromJson({}).toJson(),
      () => AutoAnswerHint.fromJson({}).toJson(),
      () => EngineError.fromJson({}).toJson(),
      () => EngineSnapshot.fromJson({}).toJson(),
      () => CoreStartResult.fromJson({}).toJson(),
      () => CoreInfo.fromJson({}).toJson(),
    ];
    for (final m in models) {
      expect(m, returnsNormally);
    }
  });

  test('CoreConfig defaults match the doc and round-trip', () {
    final c = const CoreConfig();
    final j = rt(c.toJson());
    expect(j['userAgent'], 'SoftphonePro/1.0');
    expect(j['nameservers'], 'auto');
    expect(j['maxCalls'], 16);
    expect(j['incomingAutoRingMs'], 1500);
    expect(asMapOf(j, 'transports')['tls']['port'], 5061);
    expect(asMapOf(j, 'media')['ec']['algo'], 'auto');
    expect(CoreConfig.fromJson(j), c);
    final c2 = c.copyWith(nameservers: ['8.8.8.8'], statsIntervalMs: 1000);
    expect(CoreConfig.fromJson(rt(c2.toJson())), c2);
    expect(CoreConfig.fromJson(rt(c2.toJson())).nameservers, ['8.8.8.8']);
    expect(CoreConfig.fromJson({'nameservers': []}).nameservers, isEmpty);
  });

  test('AccountConfig round trip with non-default values', () {
    final a = const AccountConfig(uid: 'u1', username: '1001').copyWith(
      password: 'x',
      domain: 'pbx',
      transport: AccTransport.tls,
      srtp: SrtpMode.mandatory,
      srtpKeying: [SrtpKeying.dtls, SrtpKeying.sdes],
      headers: {'X-A': 'b'},
      turn: const TurnConfig(enabled: true, server: 't:3478'),
      codecs: ['opus/48000/2'],
      proxies: ['sip:p;lr'],
      authUser: 'au',
      dtmfMethod: DtmfMethod.info,
    );
    final j = rt(a.toJson());
    expect(j['srtp'], 'mandatory');
    expect(j['transport'], 'tls');
    expect(j['srtpKeying'], ['dtls', 'sdes']);
    expect(j['regUseProxy'], 3);
    expect(j['dscp'], {'sip': 24, 'rtp': 46});
    expect(AccountConfig.fromJson(j), a);
    expect(rt(AccountConfig.fromJson(j).toJson()), j);
  });

  test('enums parse unknown safely', () {
    expect(RegState.parse('banana'), RegState.unknown);
    expect(RegState.parse(null), RegState.unknown);
    expect(RegState.parse(42), RegState.unknown);
    expect(CallState.parse('confirmed'), CallState.confirmed);
    expect(MediaStatus.parse('localHold'), MediaStatus.localHold);
    expect(ErrorCode.parse('PJ_ERROR'), ErrorCode.pjError);
    expect(ErrorCode.parse('???'), ErrorCode.unknown);
    expect(AccTransport.parse('zzz'), AccTransport.udp);
    for (final e in [
      ...RegState.values,
      ...CallState.values,
      ...NatType.values,
      ...ErrorCode.values,
    ]) {
      expect((e as WireEnum).wire, isNotEmpty);
    }
    expect(NatType.parse('symmetricUdp'), NatType.symmetricUdp);
  });

  test(
    'CallInfo / AccountInfo / BuddyInfo parse doc samples and round trip',
    () {
      final ci = {
        'cid': 42,
        'call': 0,
        'acc': 0,
        'uid': 'u',
        'proto': 'sip',
        'role': 'caller',
        'state': 'early',
        'stateCode': 180,
        'stateReason': 'Ringing',
        'lastCode': 180,
        'remoteUri': 'sip:1002@pbx',
        'remoteDisplay': 'Bob',
        'remoteUser': '1002',
        'media': 'bothHold',
        'codec': 'opus/48000/2',
        'conferenceWith': [43],
        'headers': {'Call-Info': 'x'},
        'futureField': 1,
      };
      final c = CallInfo.fromJson(ci);
      expect(c.state, CallState.early);
      expect(c.media, MediaStatus.bothHold);
      expect(c.conferenceWith, [43]);
      expect(CallInfo.fromJson(rt(c.toJson())), c);

      final ai = AccountInfo.fromJson({
        'acc': 1,
        'regState': 'registered',
        'regCode': 200,
        'presence': 'away',
        'online': true,
      });
      expect(ai.regState, RegState.registered);
      expect(ai.presence, PresenceStatus.away);
      expect(AccountInfo.fromJson(rt(ai.toJson())), ai);

      final b = BuddyInfo.fromJson({
        'buddy': 3,
        'presence': {'status': 'onthephone', 'note': 'n'},
        'blf': {
          'state': 'early',
          'dialogs': [
            {
              'id': 'd',
              'state': 'early',
              'direction': 'recipient',
              'durationSec': 12,
            },
          ],
        },
      });
      expect(b.blf.dialogs.single.direction, BlfDirection.recipient);
      expect(b.presence.status, PresenceStatus.onthephone);
      expect(BuddyInfo.fromJson(rt(b.toJson())), b);
    },
  );

  test('CallStats, devices, codecs, im, misc round trip', () {
    final s = CallStats.fromJson({
      'cid': 1,
      'rx': {'packets': 10, 'jitterMs': 4.1},
      'mos': 4.3,
      'ice': {'state': 'completed', 'localType': 'host'},
    });
    expect(s.rx.packets, 10);
    expect(s.rx.jitterMs, 4.1);
    expect(CallStats.fromJson(rt(s.toJson())), s);

    final d = AudioDevices.fromJson({
      'capture': [
        {
          'devId': 'a:b',
          'name': 'b',
          'driver': 'a',
          'inputs': 1,
          'outputs': 0,
          'isDefault': true,
        },
      ],
      'playback': [],
      'current': {'capture': 'a:b', 'playback': 'default', 'ringer': 'default'},
    });
    expect(AudioDevices.fromJson(rt(d.toJson())), d);

    for (final m in <Map<String, dynamic> Function()>[
      () => ImMessage.fromJson({
        'acc': 1,
        'from': 'x',
        'body': 'b',
        'isLan': true,
      }).toJson(),
      () => ImStatus.fromJson({'msgId': 'm', 'code': 202, 'ok': true}).toJson(),
      () => TransportStateInfo.fromJson({
        'type': 'TLS',
        'state': 'connected',
        'tls': {
          'cipher': 'c',
          'verifyStatus': ['a'],
          'remoteCert': {'subject': 's'},
        },
      }).toJson(),
      () => OptionsResult.fromJson({'code': 200, 'rttMs': 3}).toJson(),
    ]) {
      final j = rt(m());
      expect(j, isNotEmpty);
    }
    expect(OpusParams(bitrate: 24000).toJson(), {'bitrate': 24000});
    expect(
      ErrorCode.parse(EngineError.fromJson({'code': 'TIMEOUT'}).code.wire),
      ErrorCode.timeout,
    );
  });

  test('contract rev3 keys', () {
    expect(
      const CoreConfig(publicAddr: '127.0.0.1').toJson()['publicAddr'],
      '127.0.0.1',
    );
    final t = TransportStateInfo.fromJson({
      'transport': 'tls',
      'state': 'connected',
    });
    expect(t.transport, 'tls');
    expect(t.toJson()['transport'], 'tls');
    expect(
      NatTypeInfo.fromJson({'natType': 'fullCone'}).natType,
      NatType.fullCone,
    );
    expect(CallInfo.fromJson({'transferFrom': 7}).transferFrom, 7);
    final r = EngineEvent.fromJson({
      'event': 'call.transferRequest',
      'cid': 1,
      'accepted': true,
    });
    expect((r as CallTransferRequestEvent).accepted, isTrue);
  });

  test('CoreStartResult parses direct/lan', () {
    final r = CoreStartResult.fromJson({
      'version': '1',
      'pjsip': '2.17',
      'transports': [
        {'id': 0, 'type': 'udp', 'local': '1.2.3.4:5060', 'ipv6': false},
      ],
      'lan': {'acc': 5, 'port': 5070, 'transport': 'udp'},
      'direct': {'acc': 4},
    });
    expect(r.directAcc, 4);
    expect(r.lan!.acc, 5);
    expect(r.transports.single.local, '1.2.3.4:5060');
  });
}

Map<String, dynamic> asMapOf(Map<String, dynamic> j, String k) =>
    j[k] as Map<String, dynamic>;
