import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:softphonepro/platform/ios/ios_platform_services.dart';
import 'package:softphonepro/platform/platform_services.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const ch = MethodChannel('softphonepro/platform');
  final log = <MethodCall>[];

  setUp(() {
    log.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(ch, (call) async {
          log.add(call);
          switch (call.method) {
            case 'requestPermissions':
              return {
                'microphone': 'granted',
                'notifications': 'permanentlyDenied',
              };
            case 'availableAudioRoutes':
              return ['speaker', 'earpiece', 'bluetooth', 'bogus'];
            case 'getAudioRoute':
              return 'speaker';
            case 'initialLink':
              return 'sip:alice@example.com';
          }
          return null;
        });
  });

  test('method encoding', () async {
    final p = IosPlatformServices();
    expect(p.ringsViaOs, isTrue);
    await p.reportIncomingCall(callKey: '7', handle: '100', displayName: 'Bob');
    await p.reportCallEnded('7', reason: 'failed');
    await p.setAudioRoute(AudioRoute.bluetooth);
    await p.setProximityEnabled(true);
    expect(log.map((c) => c.method), [
      'reportIncomingCall',
      'reportCallEnded',
      'setAudioRoute',
      'setProximityEnabled',
    ]);
    expect(log[0].arguments, {
      'callKey': '7',
      'handle': '100',
      'displayName': 'Bob',
    });
    expect(log[1].arguments, {'callKey': '7', 'reason': 'failed'});
    expect(log[2].arguments, {'route': 'bluetooth'});
  });

  test('result decoding', () async {
    final p = IosPlatformServices();
    final perms = await p.requestPermissions();
    expect(perms.microphone, PermissionStatus.granted);
    expect(perms.notifications, PermissionStatus.permanentlyDenied);
    expect(perms.contacts, PermissionStatus.unsupported);
    expect(await p.availableAudioRoutes(), {
      AudioRoute.speaker,
      AudioRoute.earpiece,
      AudioRoute.bluetooth,
    });
    expect(await p.getAudioRoute(), AudioRoute.speaker);
    expect((await p.initialLink()).toString(), 'sip:alice@example.com');
  });

  test('event decoding', () async {
    final p = IosPlatformServices();
    final actions = <SystemCallAction>[];
    final sessions = <bool>[];
    final routes = <AudioRoute>[];
    final links = <Uri>[];
    p.systemCallActions.listen(actions.add);
    p.audioSessionActive.listen(sessions.add);
    p.audioRouteChanges.listen(routes.add);
    p.incomingLinks.listen(links.add);
    p.handleEvent({'type': 'callAction', 'kind': 'decline', 'callKey': '3'});
    p.handleEvent({'type': 'callAction', 'kind': 'nope', 'callKey': '3'});
    p.handleEvent({'type': 'audioSession', 'active': true});
    p.handleEvent({'type': 'audioSession', 'active': false});
    p.handleEvent({'type': 'route', 'route': 'wired'});
    p.handleEvent({'type': 'link', 'url': 'tel:+4912345'});
    p.handleEvent('garbage');
    await Future<void>.delayed(Duration.zero);
    expect(actions.single.kind, SystemCallActionKind.decline);
    expect(actions.single.callKey, '3');
    expect(sessions, [true, false]);
    expect(routes, [AudioRoute.wired]);
    expect(links.single.toString(), 'tel:+4912345');
  });
}
