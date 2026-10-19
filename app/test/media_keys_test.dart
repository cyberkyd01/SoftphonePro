import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:softphonepro/platform/desktop/desktop_channel.dart';
import 'package:softphonepro/platform/desktop/media_keys.dart';
import 'package:softphonepro/services/calls_controller.dart';
import 'package:softphonepro/services/settings_controller.dart';

import 'harness.dart';

final _refProvider = Provider<Ref>((ref) => ref);

class FakeBackend extends MediaKeyBackend {
  final List<bool> calls = [];
  @override
  Future<void> setActive(bool active) async => calls.add(active);
  void press() => onPress?.call();
}

void main() {
  test('policy', () {
    expect(decideMediaKey(ringing: true, ongoing: true, activeAction: 'hangup'), MediaKeyAction.answer);
    expect(decideMediaKey(ringing: false, ongoing: true, activeAction: 'hangup'), MediaKeyAction.hangup);
    expect(decideMediaKey(ringing: false, ongoing: true, activeAction: 'mute'), MediaKeyAction.mute);
    expect(decideMediaKey(ringing: false, ongoing: false, activeAction: 'hangup'), MediaKeyAction.none);
  });

  testWidgets('claims keys only during calls; ring -> answer, active -> hang up / mute', (tester) async {
    final env = await TestEnv.create(profiles: [testProfile()]);
    await pumpApp(tester, env);
    await waitRegistered(tester, env);
    final c = containerOf(tester);
    final backend = FakeBackend();
    var t = DateTime(2026);
    final mk = MediaKeyController(c.read(_refProvider), backend, clock: () => t)..start();
    await tester.pump();
    expect(backend.calls, isEmpty); // nothing claimed while idle

    env.engine.simulateIncomingCall(from: 'sip:3003@pbx.test');
    await settle(tester, env.engine);
    expect(backend.calls, [true]);
    unawaited(mk.handlePress()); // ringing -> answer
    await settle(tester, env.engine);
    expect(c.read(callsProvider).focused?.isConfirmed, isTrue);
    expect(backend.calls, [true]);

    t = t.add(const Duration(seconds: 2));
    unawaited(mk.handlePress()); // active -> hang up (default)
    await settle(tester, env.engine);
    expect(c.read(callsProvider).hasCalls, isFalse);
    expect(backend.calls, [true, false]); // released after the call

    // mute mode
    await tester.runAsync(() => c.read(settingsProvider.notifier).update({'mediaKeyActive': 'mute'}));
    env.engine.simulateIncomingCall(from: 'sip:3004@pbx.test');
    await settle(tester, env.engine);
    t = t.add(const Duration(seconds: 2));
    unawaited(mk.handlePress());
    await settle(tester, env.engine);
    t = t.add(const Duration(seconds: 2));
    unawaited(mk.handlePress());
    await settle(tester, env.engine);
    expect(c.read(callsProvider).focused?.muted, isTrue);
    // a repeated press within 500 ms is ignored
    unawaited(mk.handlePress());
    expect(c.read(callsProvider).focused?.muted, isTrue);

    // disabled in settings: released and presses do nothing
    await tester.runAsync(() => c.read(settingsProvider.notifier).update({'mediaKeys': false}));
    await settle(tester, env.engine);
    expect(backend.calls.last, isFalse);
    t = t.add(const Duration(seconds: 2));
    unawaited(mk.handlePress());
    await settle(tester, env.engine);
    expect(c.read(callsProvider).hasCalls, isTrue);
    await mk.dispose();
  });

  test('DesktopChannel forwards onMediaKey and setMediaKeys', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    const ch = MethodChannel('test/desktop');
    final sent = <MethodCall>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(ch, (call) async {
      sent.add(call);
      return call.method == 'ready' ? <Object?, Object?>{} : true;
    });
    final d = DesktopChannel(ch);
    await d.init(const []);
    expect(await d.setMediaKeysActive(true), isTrue);
    expect(sent.last.method, 'setMediaKeys');
    expect(sent.last.arguments, true);
    var presses = 0;
    final backend = ChannelMediaKeyBackend(d)..onPress = () => presses++;
    await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.handlePlatformMessage(
      'test/desktop',
      const StandardMethodCodec().encodeMethodCall(const MethodCall('onMediaKey')),
      (_) {},
    );
    await Future<void>.delayed(Duration.zero);
    expect(presses, 1);
    await backend.dispose();
  });
}
