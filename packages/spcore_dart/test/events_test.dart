import 'package:spcore_dart/spcore_dart.dart';
import 'package:test/test.dart';

Map<String, dynamic> ev(String name, [Map<String, dynamic> f = const {}]) => {
  'type': 'event',
  'event': name,
  'ts': 1729312345123,
  'seq': 7,
  ...f,
};

void main() {
  test('parses every documented event to its type', () {
    final cases = <String, Type>{
      'core.started': CoreStartedEvent,
      'core.stopped': CoreStoppedEvent,
      'core.ipChangeProgress': CoreIpChangeProgressEvent,
      'log': LogEvent,
      'sip.trace': SipTraceEvent,
      'transport.state': TransportStateEvent,
      'transport.tlsVerify': TransportTlsVerifyEvent,
      'account.reg': AccountRegEvent,
      'account.mwi': AccountMwiEvent,
      'account.incomingSubscribe': AccountIncomingSubscribeEvent,
      'call.incoming': CallIncomingEvent,
      'call.state': CallStateEvent,
      'call.media': CallMediaEvent,
      'call.dtmf': CallDtmfEvent,
      'call.transferRequest': CallTransferRequestEvent,
      'call.transferStatus': CallTransferStatusEvent,
      'call.replaced': CallReplacedEvent,
      'call.redirected': CallRedirectedEvent,
      'call.recording': CallRecordingEvent,
      'call.stats': CallStatsEvent,
      'buddy.state': BuddyStateEvent,
      'im.incoming': ImIncomingEvent,
      'im.status': ImStatusEvent,
      'im.typing': ImTypingEvent,
      'media.devicesChanged': MediaDevicesChangedEvent,
      'media.error': MediaErrorEvent,
      'media.musicbed': MusicbedEvent,
      'media.monitor': MediaMonitorEvent,
      'media.loopback': MediaLoopbackEvent,
      'media.playDone': MediaPlayDoneEvent,
      'diag.natType': DiagNatTypeEvent,
      'diag.options': DiagOptionsEvent,
      'future.thing': UnknownEvent,
    };
    cases.forEach((name, type) {
      final e = EngineEvent.fromJson(ev(name));
      expect(e.runtimeType, type, reason: name);
      expect(e.seq, 7);
      expect(e.ts, 1729312345123);
    });
  });

  test('typed fields and tolerance for extra/missing fields', () {
    final e =
        EngineEvent.fromJson(
              ev('call.incoming', {
                'cid': 9,
                'state': 'incoming',
                'role': 'callee',
                'newField': [1],
                'headers': {'Alert-Info': '<x>;info=alert-autoanswer;delay=2'},
                'replacesCid': 3,
                'autoAnswerHint': {
                  'afterSec': 2,
                  'source': 'alertInfo',
                  'require': true,
                },
              }),
            )
            as CallIncomingEvent;
    expect(e.cid, 9);
    expect(e.replacesCid, 3);
    expect(e.autoAnswerHint!.source, AutoAnswerSource.alertInfo);
    expect(e.headers['Alert-Info'], contains('autoanswer'));

    final t =
        EngineEvent.fromJson(
              ev('call.transferStatus', {'cid': 1, 'code': 200, 'final': true}),
            )
            as CallTransferStatusEvent;
    expect(t.isFinal, isTrue);
    final bad = EngineEvent.fromJson(
      ev('call.state', {'cid': 'oops', 'state': 5}),
    );
    expect(bad, isA<CallStateEvent>());
    expect(EngineEvent.fromJson({}), isA<UnknownEvent>());
    final u = EngineEvent.fromJson(ev('zzz', {'a': 1})) as UnknownEvent;
    expect(u.raw['a'], 1);
    expect(u.name, 'zzz');
  });
}
