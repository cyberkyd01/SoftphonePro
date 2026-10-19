import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:softphonepro/app.dart';
import 'package:softphonepro/core/format.dart';
import 'package:softphonepro/models/account_profile.dart';
import 'package:softphonepro/models/app_settings.dart';
import 'package:softphonepro/models/contact.dart';
import 'package:softphonepro/platform/platform_services.dart';
import 'package:softphonepro/services/app_services.dart';
import 'package:softphonepro/services/calls_controller.dart';
import 'package:softphonepro/services/presence_controller.dart';
import 'package:softphonepro/services/providers.dart';
import 'package:softphonepro/services/ringtones.dart';
import 'package:softphonepro/services/settings_controller.dart';
import 'package:softphonepro/ui/widgets/account_widgets.dart';
import 'package:spcore_dart/spcore_dart.dart';

import 'harness.dart';

/// FakeSipEngine that records the calls the polish features make.
class RecEngine extends FakeSipEngine {
  RecEngine({super.timings, super.defaultCallee, super.calleeRules});
  final List<String> tones = [];
  final List<String?> ringFiles = [];
  final List<String> playedFiles = [];
  final List<Map<String, Object?>> pickups = [];
  final List<String> levelLog = [];
  final List<String> redirects = [];
  final List<int> buddyAccs = [];
  final List<String> buddyAccUids = [];

  @override
  Future<void> playTone(ToneKind kind, {String? digits, bool loop = false}) {
    tones.add('play:${kind.wire}${loop ? ':loop' : ''}');
    return super.playTone(kind, digits: digits, loop: loop);
  }

  @override
  Future<void> stopTone() {
    tones.add('stop');
    return super.stopTone();
  }

  @override
  Future<void> ringStart({String? file, String devId = 'default', bool loop = true, double volume = 1}) {
    ringFiles.add(file);
    return super.ringStart(file: file, devId: devId, loop: loop, volume: volume);
  }

  @override
  Future<void> playFile(int cid, String file, {bool loop = false}) {
    playedFiles.add(file);
    return super.playFile(cid, file, loop: loop);
  }

  @override
  Future<CallRef> pickup({
    required AccountRef acc,
    required String uri,
    required String callId,
    required String toTag,
    required String fromTag,
    Map<String, String>? headers,
  }) {
    pickups.add({'acc': acc.toJson(), 'uri': uri, 'callId': callId, 'toTag': toTag, 'fromTag': fromTag});
    return super.pickup(acc: acc, uri: uri, callId: callId, toTag: toTag, fromTag: fromTag, headers: headers);
  }

  @override
  Future<void> setCallLevels(int cid, {double rx = 1.0, double tx = 1.0}) {
    levelLog.add('$cid:$rx:$tx');
    return super.setCallLevels(cid, rx: rx, tx: tx);
  }

  @override
  Future<void> processRedirect(int cid, RedirectAction action) {
    redirects.add('$cid:${action.wire}');
    return super.processRedirect(cid, action);
  }

  @override
  Future<int> addBuddy({
    required AccountRef acc,
    required String uri,
    bool presence = true,
    bool blf = false,
  }) {
    buddyAccUids.add('${acc.toJson()['uid'] ?? acc.toJson()['acc']}|$uri');
    return super.addBuddy(acc: acc, uri: uri, presence: presence, blf: blf);
  }
}

class CountingPlatform extends NoopPlatformServices {
  int proximity = 0;
  int keepOn = 0;
  int tray = 0;
  @override
  Future<void> setProximityEnabled(bool enabled) async => proximity++;
  @override
  Future<void> setKeepScreenOn(bool keepOn) async => this.keepOn++;
  @override
  Future<void> updateTray({String? tooltip, int missedCalls = 0, bool inCall = false, bool ringing = false}) async => tray++;
}

Future<TestEnv> env0({
  List<AccountProfile>? profiles,
  Map<String, dynamic> settings = const {},
  List<Contact> contacts = const [],
  CalleeBehavior callee = CalleeBehavior.answer,
  Map<String, CalleeBehavior>? rules,
  RecEngine? engine,
}) {
  return TestEnv.create(
    profiles: profiles ?? [testProfile()],
    settings: AppSettings({'onboardingDone': true, ...settings}),
    contacts: contacts,
    engine: engine ?? RecEngine(timings: FakeTimings.instant, defaultCallee: callee, calleeRules: rules),
  );
}

Future<void> pumpWith(WidgetTester tester, TestEnv env, List<Override> extra, {Size size = const Size(420, 900)}) async {
  tester.view.physicalSize = size * 2;
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(ProviderScope(overrides: [...env.overrides, ...extra], child: const SoftphoneApp()));
  await settle(tester, env.engine);
}

void main() {
  group('call-progress tones', () {
    testWidgets('ringback while calling/early with no media; stopped on answer and hangup', (tester) async {
      final env = await env0(callee: CalleeBehavior.noAnswer);
      final eng = env.engine as RecEngine;
      await pumpApp(tester, env);
      await waitRegistered(tester, env);
      final c = containerOf(tester);
      final cid = await c.read(callsProvider.notifier).dial('2002');
      await settle(tester, env.engine);
      expect(eng.tones, contains('play:ringback:loop'));
      expect(eng.activeTone, 'ringback');
      eng.simulateRemoteAnswer(cid!);
      await settle(tester, env.engine);
      expect(eng.activeTone, isNull);
      expect(eng.tones.last, 'stop');
      await c.read(callsProvider.notifier).hangup(cid);
      await settle(tester, env.engine);
      expect(eng.activeTone, isNull);
    });

    testWidgets('hanging up while ringing stops the ringback (no leak) and plays no busy tone', (tester) async {
      final env = await env0(callee: CalleeBehavior.noAnswer);
      final eng = env.engine as RecEngine;
      await pumpApp(tester, env);
      await waitRegistered(tester, env);
      final c = containerOf(tester);
      final cid = await c.read(callsProvider.notifier).dial('2002');
      await settle(tester, env.engine);
      expect(eng.activeTone, 'ringback');
      await c.read(callsProvider.notifier).hangup(cid!);
      await settle(tester, env.engine);
      expect(eng.activeTone, isNull);
      expect(eng.tones.where((t) => t.startsWith('play:busy') || t.startsWith('play:congestion')), isEmpty);
    });

    testWidgets('busy tone for ~3 s on 486 then stops', (tester) async {
      final env = await env0(rules: {'2002': CalleeBehavior.busy});
      final eng = env.engine as RecEngine;
      await pumpApp(tester, env);
      await waitRegistered(tester, env);
      await containerOf(tester).read(callsProvider.notifier).dial('2002');
      await settle(tester, env.engine);
      expect(eng.activeTone, 'busy');
      await tester.pump(const Duration(seconds: 2));
      expect(eng.activeTone, 'busy');
      await tester.pump(const Duration(seconds: 2));
      await settle(tester, env.engine);
      expect(eng.activeTone, isNull);
    });

    testWidgets('busy tone also for 603; congestion for 503 and 408', (tester) async {
      final env = await env0(callee: CalleeBehavior.manual);
      final eng = env.engine as RecEngine;
      await pumpApp(tester, env);
      await waitRegistered(tester, env);
      final calls = containerOf(tester).read(callsProvider.notifier);
      final a = await calls.dial('2001');
      await settle(tester, env.engine);
      eng.simulateRemoteReject(a!, code: 603);
      await settle(tester, env.engine);
      expect(eng.activeTone, 'busy');
      await tester.pump(const Duration(seconds: 4));
      await settle(tester, env.engine);
      expect(eng.activeTone, isNull);
      for (final code in [503, 408]) {
        final b = await calls.dial('2002');
        await settle(tester, env.engine);
        eng.simulateRemoteReject(b!, code: code);
        await settle(tester, env.engine);
        expect(eng.activeTone, 'congestion', reason: '$code');
        await tester.pump(const Duration(seconds: 4));
        await settle(tester, env.engine);
        expect(eng.activeTone, isNull);
      }
    });

    testWidgets('progressTones=false plays nothing', (tester) async {
      final env = await env0(callee: CalleeBehavior.noAnswer, settings: {'progressTones': false});
      final eng = env.engine as RecEngine;
      await pumpApp(tester, env);
      await waitRegistered(tester, env);
      final c = containerOf(tester);
      final cid = await c.read(callsProvider.notifier).dial('2002');
      await settle(tester, env.engine);
      eng.simulateRemoteReject(cid!, code: 486);
      await settle(tester, env.engine);
      expect(eng.tones, isEmpty);
    });
  });

  group('ringtones', () {
    test('resolution order: contact > account > global', () {
      const s = AppSettings({'ringtone': 'soft'});
      final acc = testProfile().copyWith(ringtone: 'digital');
      final plain = testProfile();
      const none = Contact(id: 'c', name: 'N');
      const mine = Contact(id: 'c', name: 'N', ringtone: 'classic');
      expect(resolveRingtoneName(s, plain, none), 'soft');
      expect(resolveRingtoneName(s, acc, none), 'digital');
      expect(resolveRingtoneName(s, acc, mine), 'classic');
      expect(resolveRingtoneName(s, null, null), 'soft');
      expect(resolveRingtoneName(const AppSettings(), null, null), 'default');
    });

    testWidgets('the engine ringer gets the resolved file', (tester) async {
      final env = await env0(
        profiles: [testProfile().copyWith(ringtone: 'digital')],
        settings: {'ringtone': 'soft'},
        contacts: const [
          Contact(id: 'k1', name: 'Kay', numbers: [ContactNumber(value: '3003')], ringtone: 'classic'),
        ],
      );
      final eng = env.engine as RecEngine;
      await pumpWith(tester, env, [
        ringtoneFileProvider.overrideWithValue((name) async => name == 'default' ? null : '/sounds/$name.wav'),
      ]);
      await waitRegistered(tester, env);
      eng.simulateIncomingCall(from: 'sip:3003@pbx.test');
      await settle(tester, env.engine);
      expect(eng.ringFiles.last, '/sounds/classic.wav');
      eng.simulateIncomingCall(from: 'sip:4004@pbx.test');
      await settle(tester, env.engine);
      // The first call is still ringing, so only one ringer start; hang up and retry.
      final c = containerOf(tester);
      await c.read(callsProvider.notifier).hangupAll();
      for (final call in c.read(callsProvider).live) {
        await c.read(callsProvider.notifier).decline(call.cid);
      }
      await settle(tester, env.engine);
    });

    test('bundled ringtones exist as assets', () {
      for (final f in kBuiltInRingtones.values) {
        expect(f, startsWith('assets/sounds/'));
      }
      expect(kRingtoneOptions.keys, containsAll(['default', 'classic', 'soft', 'digital']));
    });
  });

  group('models', () {
    test('Contact.presenceAccountId, AccountProfile.autoRecord and parkRetrieve round-trip', () {
      const c = Contact(id: 'a', name: 'A', presenceAccountId: 'acc2');
      expect(Contact.fromJson(c.toJson()).presenceAccountId, 'acc2');
      expect(Contact.fromJson({'id': 'x'}).presenceAccountId, isNull);
      expect(c.copyWith(name: 'B').presenceAccountId, 'acc2');
      expect(c.copyWith(presenceAccountId: null).presenceAccountId, isNull);
      final p = testProfile().copyWith(
        autoRecord: 'always',
        featureCodes: const FeatureCodes(parkRetrieve: '*86'),
      );
      final back = AccountProfile.fromJson(p.toJson());
      expect(back.autoRecord, 'always');
      expect(back.featureCodes.parkRetrieve, '*86');
      expect(AccountProfile.fromJson(testProfile().toJson()).autoRecord, 'inherit');
    });

    test('speed dial settings parse slots 1-9 only', () {
      final s = const AppSettings({}).update({
        'speedDial': {
          '2': {'number': '2002', 'label': 'Bob'},
          '0': {'number': 'x'},
          '10': {'number': 'y'},
          '3': {'number': ''},
        },
      });
      expect(s.speedDial.keys, [2]);
      expect(s.speedDial[2]!.label, 'Bob');
      expect(const AppSettings().progressTones, isTrue);
    });

    test('formatPhone groups only unambiguous NANP numbers', () {
      expect(formatPhone('+15550102030'), '+1 (555) 010-2030');
      expect(formatPhone('2002'), '2002');
      expect(formatPhone('alice@x.com'), 'alice@x.com');
    });

    test('ipLiteralHost', () {
      expect(ipLiteralHost('sip:bob@10.1.2.3'), '10.1.2.3');
      expect(ipLiteralHost('sip:bob@10.1.2.3:5070;transport=tcp'), '10.1.2.3');
      expect(ipLiteralHost('bob@[2001:db8::1]:5060'), '2001:db8::1');
      expect(ipLiteralHost('10.0.0.5'), '10.0.0.5');
      expect(ipLiteralHost('sip:bob@pbx.test'), isNull);
      expect(ipLiteralHost('2002'), isNull);
    });
  });

  group('speed dial', () {
    testWidgets('long-press digit dials the assigned slot', (tester) async {
      final env = await env0(settings: {
        'speedDial': {'5': {'number': '2002', 'label': 'Bob'}},
      });
      await pumpApp(tester, env);
      await waitRegistered(tester, env);
      await tester.longPress(find.bySemanticsLabel('5').first);
      await settle(tester, env.engine);
      final f = containerOf(tester).read(callsProvider).focused;
      expect(f, isNotNull);
      expect(f!.dialed, '2002');
    });

    testWidgets('long-press on an empty slot opens the assignment dialog and saves', (tester) async {
      final env = await env0();
      await pumpApp(tester, env);
      await waitRegistered(tester, env);
      await tester.longPress(find.bySemanticsLabel('7').first);
      await tester.pumpAndSettle();
      expect(find.text('Speed dial 7'), findsOneWidget);
      await tester.enterText(find.byKey(const Key('speed-dial-number')), '7007');
      await tester.tap(find.byKey(const Key('speed-dial-save')));
      await tester.pumpAndSettle();
      expect(containerOf(tester).read(settingsProvider).speedDial[7]!.number, '7007');
      expect(containerOf(tester).read(callsProvider).hasCalls, isFalse);
    });

    testWidgets('long-press does nothing while a number is being typed', (tester) async {
      final env = await env0(settings: {
        'speedDial': {'5': {'number': '2002'}},
      });
      await pumpApp(tester, env);
      await waitRegistered(tester, env);
      await tester.tap(find.bySemanticsLabel('9').first);
      await tester.pump();
      await tester.longPress(find.bySemanticsLabel('5').first);
      await settle(tester, env.engine);
      expect(containerOf(tester).read(callsProvider).hasCalls, isFalse);
    });
  });

  group('recording', () {
    testWidgets('per-account autoRecord: always overrides global off', (tester) async {
      final always = testProfile(id: 'acc1').copyWith(autoRecord: 'always');
      final env = await env0(profiles: [always], settings: {'autoRecord': false});
      await pumpApp(tester, env);
      await waitRegistered(tester, env);
      final c = containerOf(tester);
      final a = await c.read(callsProvider.notifier).dial('2002', accountId: 'acc1');
      await settle(tester, env.engine);
      expect(c.read(callsProvider).byCid(a!)!.recording, isTrue);
    });

    testWidgets('per-account autoRecord: never overrides global on', (tester) async {
      final never = testProfile(id: 'acc1').copyWith(autoRecord: 'never');
      final env = await env0(profiles: [never], settings: {'autoRecord': true});
      await pumpApp(tester, env);
      await waitRegistered(tester, env);
      final c = containerOf(tester);
      final a = await c.read(callsProvider.notifier).dial('2002', accountId: 'acc1');
      await settle(tester, env.engine);
      expect(c.read(callsProvider).byCid(a!)!.recording, isFalse);
    });

    testWidgets('inherit follows the global setting', (tester) async {
      final env = await env0(settings: {'autoRecord': true});
      await pumpApp(tester, env);
      await waitRegistered(tester, env);
      final c = containerOf(tester);
      final a = await c.read(callsProvider.notifier).dial('2002');
      await settle(tester, env.engine);
      expect(c.read(callsProvider).byCid(a!)!.recording, isTrue);
    });

    testWidgets('recordBeep plays the beep file every 15 s while recording', (tester) async {
      final env = await env0(settings: {'autoRecord': true, 'recordBeep': true});
      final eng = env.engine as RecEngine;
      await pumpWith(tester, env, [recordBeepFileProvider.overrideWithValue(() async => '/sounds/beep.wav')]);
      await waitRegistered(tester, env);
      final c = containerOf(tester);
      final a = await c.read(callsProvider.notifier).dial('2002');
      await settle(tester, env.engine);
      expect(eng.playedFiles, ['/sounds/beep.wav']);
      await tester.pump(const Duration(seconds: 15));
      await settle(tester, env.engine);
      expect(eng.playedFiles.length, 2);
      await tester.runAsync(() => c.read(callsProvider.notifier).stopRecording(a!));
      await tester.pump(const Duration(seconds: 30));
      expect(eng.playedFiles.length, 2);
      await c.read(callsProvider.notifier).hangup(a!);
      await settle(tester, env.engine);
    });

    testWidgets('no beep when recordBeep is off', (tester) async {
      final env = await env0(settings: {'autoRecord': true});
      final eng = env.engine as RecEngine;
      await pumpWith(tester, env, [recordBeepFileProvider.overrideWithValue(() async => '/sounds/beep.wav')]);
      await waitRegistered(tester, env);
      await containerOf(tester).read(callsProvider.notifier).dial('2002');
      await settle(tester, env.engine);
      await tester.pump(const Duration(seconds: 16));
      expect(eng.playedFiles, isEmpty);
    });
  });

  group('conference levels', () {
    testWidgets('sliders call setCallLevels for the party', (tester) async {
      final env = await env0();
      final eng = env.engine as RecEngine;
      await pumpApp(tester, env);
      await waitRegistered(tester, env);
      final c = containerOf(tester);
      final calls = c.read(callsProvider.notifier);
      final a = await calls.dial('2001');
      await settle(tester, env.engine);
      final b = await calls.dial('2002');
      await settle(tester, env.engine);
      await calls.merge();
      await settle(tester, env.engine);
      expect(c.read(callsProvider).focused!.isConference, isTrue);
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('conference-levels')), findsOneWidget);
      final rx = find.byKey(Key('party-rx-$a'));
      await tester.ensureVisible(rx);
      await tester.drag(rx, const Offset(-60, 0));
      await tester.pump();
      expect(eng.levelLog, isNotEmpty);
      expect(eng.levelLog.last.startsWith('$a:'), isTrue);
      final tx = find.byKey(Key('party-tx-$b'));
      await tester.ensureVisible(tx);
      await tester.drag(tx, const Offset(-60, 0));
      await tester.pump();
      expect(eng.levelLog.last.startsWith('$b:'), isTrue);
      final ua = c.read(callsProvider).byCid(a!)!;
      expect(ua.rxLevel, lessThan(1.0));
    });
  });

  group('park and pickup', () {
    testWidgets('retrieveParked dials prefix + slot', (tester) async {
      final env = await env0(
        profiles: [testProfile().copyWith(featureCodes: const FeatureCodes(parkRetrieve: '*86'))],
      );
      await pumpApp(tester, env);
      await waitRegistered(tester, env);
      final c = containerOf(tester);
      final cid = await c.read(callsProvider.notifier).retrieveParked('701');
      await settle(tester, env.engine);
      expect(c.read(callsProvider).byCid(cid!)!.dialed, '*86701');
    });

    testWidgets('retrieveParked without prefix dials the slot itself', (tester) async {
      final env = await env0();
      await pumpApp(tester, env);
      await waitRegistered(tester, env);
      final c = containerOf(tester);
      final cid = await c.read(callsProvider.notifier).retrieveParked(' 702 ');
      await settle(tester, env.engine);
      expect(c.read(callsProvider).byCid(cid!)!.dialed, '702');
    });

    testWidgets('BLF pickup uses INVITE with Replaces when an early dialog is known', (tester) async {
      final env = await env0();
      final eng = env.engine as RecEngine;
      await pumpApp(tester, env);
      await waitRegistered(tester, env);
      final c = containerOf(tester);
      final b = BuddyInfo(
        uri: 'sip:1002@pbx.test',
        uid: 'acc1',
        blf: BlfInfo(
          state: BlfState.early,
          dialogs: const [
            BlfDialog(id: 'd1', state: BlfState.early, callId: 'cid-1', localTag: 'LT', remoteTag: 'RT'),
          ],
        ),
      );
      final cid = await c.read(callsProvider.notifier).pickupBuddy(b);
      await settle(tester, env.engine);
      expect(cid, isNotNull);
      expect(eng.pickups, hasLength(1));
      expect(eng.pickups.single['callId'], 'cid-1');
      expect(eng.pickups.single['toTag'], 'LT');
      expect(eng.pickups.single['fromTag'], 'RT');
      expect(eng.pickups.single['uri'], 'sip:1002@pbx.test');
    });

    testWidgets('BLF pickup without dialog info falls back to the feature code', (tester) async {
      final env = await env0();
      final eng = env.engine as RecEngine;
      await pumpApp(tester, env);
      await waitRegistered(tester, env);
      final c = containerOf(tester);
      const b = BuddyInfo(uri: 'sip:1002@pbx.test', uid: 'acc1', blf: BlfInfo(state: BlfState.early));
      final cid = await c.read(callsProvider.notifier).pickupBuddy(b);
      await settle(tester, env.engine);
      expect(eng.pickups, isEmpty);
      expect(c.read(callsProvider).byCid(cid!)!.dialed, '**1002');
    });
  });

  group('direct calls, emergency, blocklist', () {
    testWidgets('IP-literal target with a different account domain goes out directly', (tester) async {
      final env = await env0();
      await pumpApp(tester, env);
      await waitRegistered(tester, env);
      final c = containerOf(tester);
      final calls = c.read(callsProvider.notifier);
      final a = await calls.dial('sip:bob@10.1.2.3');
      await settle(tester, env.engine);
      expect(c.read(callsProvider).byCid(a!)!.info.uid, isNot('acc1'));
      // Same host as the account domain: use the account.
      final cfg = testProfile(domain: '10.9.9.9');
      expect(cfg.config.domain, '10.9.9.9');
    });

    testWidgets('IP literal equal to the account domain uses the account', (tester) async {
      final env = await env0(profiles: [testProfile(domain: '10.9.9.9')]);
      await pumpApp(tester, env);
      await waitRegistered(tester, env);
      final c = containerOf(tester);
      final a = await c.read(callsProvider.notifier).dial('sip:bob@10.9.9.9');
      await settle(tester, env.engine);
      expect(c.read(callsProvider).byCid(a!)!.info.uid, 'acc1');
    });

    testWidgets('explicit Direct selector entry routes any target directly', (tester) async {
      final env = await env0();
      await pumpApp(tester, env);
      await waitRegistered(tester, env);
      final c = containerOf(tester);
      expect(find.byType(AccountSelector), findsOneWidget);
      await tester.tap(find.byType(AccountSelector));
      await tester.pumpAndSettle();
      expect(find.text('Direct (no account)'), findsOneWidget);
      await tester.tap(find.text('Direct (no account)'));
      await tester.pumpAndSettle();
      expect(c.read(dialAccountProvider), kDirectAccountId);
      final a = await c.read(callsProvider.notifier).dial('sip:bob@pbx.test');
      await settle(tester, env.engine);
      expect(c.read(callsProvider).byCid(a!)!.info.uid, isNot('acc1'));
    });

    testWidgets('an account chosen on purpose is respected for IP targets', (tester) async {
      final env = await env0();
      await pumpApp(tester, env);
      await waitRegistered(tester, env);
      final c = containerOf(tester);
      c.read(dialAccountProvider.notifier).select('acc1');
      final a = await c.read(callsProvider.notifier).dial('sip:bob@10.1.2.3');
      await settle(tester, env.engine);
      expect(c.read(callsProvider).byCid(a!)!.info.uid, 'acc1');
    });

    testWidgets('emergency dial with zero profiles does not throw and goes direct', (tester) async {
      final env = await env0(profiles: const []);
      await pumpApp(tester, env);
      final c = containerOf(tester);
      final a = await c.read(callsProvider.notifier).dial('911');
      await settle(tester, env.engine);
      expect(a, isNotNull);
      expect(c.read(callsProvider).byCid(a!), isNotNull);
    });

    testWidgets('blocklist matches the exact number only', (tester) async {
      final env = await env0(settings: {'blocklist': ['100']});
      await pumpApp(tester, env);
      await waitRegistered(tester, env);
      final c = containerOf(tester);
      env.engine.simulateIncomingCall(from: 'sip:1001@pbx.test');
      await settle(tester, env.engine);
      expect(c.read(callsProvider).ringing, hasLength(1), reason: '1001 is not 100');
      env.engine.simulateIncomingCall(from: 'sip:100@pbx.test');
      await settle(tester, env.engine);
      expect(c.read(callsProvider).ringing, hasLength(1), reason: '100 is blocked');
    });
  });

  group('presence per account', () {
    testWidgets('contact presenceAccountId picks the subscribing account', (tester) async {
      final p1 = testProfile(id: 'acc1');
      final p2 = testProfile(id: 'acc2', user: '1002').copyWith(isDefault: false);
      final env = await env0(
        profiles: [p1, p2],
        contacts: const [
          Contact(id: 'k1', name: 'Via two', numbers: [ContactNumber(value: '3003')], blf: true, presenceAccountId: 'acc2'),
          Contact(id: 'k2', name: 'Via default', numbers: [ContactNumber(value: '4004')], blf: true),
        ],
      );
      final eng = env.engine as RecEngine;
      await pumpApp(tester, env);
      await waitRegistered(tester, env);
      await waitRegistered(tester, env, 'acc2');
      final c = containerOf(tester);
      c.read(presenceProvider);
      await c.read(presenceProvider.notifier).settled();
      await settle(tester, env.engine);
      await c.read(presenceProvider.notifier).settled();
      final byUri = {for (final e in eng.buddyAccUids) e.split('|').last: e.split('|').first};
      expect(byUri['3003'], 'acc2');
      expect(byUri['4004'], 'acc1');
    });
  });

  group('redirect policy', () {
    testWidgets('ask: prompts, Follow accepts', (tester) async {
      final p = testProfile();
      final ask = p.copyWith(config: p.config.copyWith(redirect: RedirectPolicy.ask));
      final env = await env0(profiles: [ask], callee: CalleeBehavior.manual);
      final eng = env.engine as RecEngine;
      await pumpApp(tester, env);
      await waitRegistered(tester, env);
      final c = containerOf(tester);
      final cid = await c.read(callsProvider.notifier).dial('2002');
      await settle(tester, env.engine);
      eng.simulateRedirected(cid!, 'sip:2003@pbx.test');
      await settle(tester, env.engine);
      await tester.pumpAndSettle();
      expect(c.read(redirectPromptProvider)?.target, 'sip:2003@pbx.test');
      expect(find.textContaining('Call redirected to sip:2003@pbx.test'), findsOneWidget);
      expect(eng.redirects, isEmpty);
      await tester.tap(find.byKey(const Key('redirect-follow')));
      await settle(tester, env.engine);
      await tester.pumpAndSettle();
      expect(eng.redirects, ['$cid:accept']);
      expect(c.read(redirectPromptProvider), isNull);
    });

    testWidgets('ask: Cancel rejects', (tester) async {
      final p = testProfile();
      final ask = p.copyWith(config: p.config.copyWith(redirect: RedirectPolicy.ask));
      final env = await env0(profiles: [ask], callee: CalleeBehavior.manual);
      final eng = env.engine as RecEngine;
      await pumpApp(tester, env);
      await waitRegistered(tester, env);
      final c = containerOf(tester);
      final cid = await c.read(callsProvider.notifier).dial('2002');
      await settle(tester, env.engine);
      eng.simulateRedirected(cid!, 'sip:2003@pbx.test');
      await settle(tester, env.engine);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('redirect-reject')));
      await settle(tester, env.engine);
      expect(eng.redirects, ['$cid:reject']);
    });

    testWidgets('auto policy follows without a prompt', (tester) async {
      final env = await env0(callee: CalleeBehavior.manual);
      final eng = env.engine as RecEngine;
      await pumpApp(tester, env);
      await waitRegistered(tester, env);
      final c = containerOf(tester);
      final cid = await c.read(callsProvider.notifier).dial('2002');
      await settle(tester, env.engine);
      eng.simulateRedirected(cid!, 'sip:2003@pbx.test');
      await settle(tester, env.engine);
      expect(eng.redirects, ['$cid:accept']);
      expect(c.read(redirectPromptProvider), isNull);
    });
  });

  group('CallKit DTMF', () {
    testWidgets('systemDtmf digits are sent on the matching call', (tester) async {
      final env = await env0();
      final dtmf = StreamController<({String callKey, String digits})>.broadcast();
      addTearDown(dtmf.close);
      await pumpWith(tester, env, [systemDtmfProvider.overrideWithValue(dtmf.stream)]);
      await waitRegistered(tester, env);
      final c = containerOf(tester);
      final cid = await c.read(callsProvider.notifier).dial('2002');
      await settle(tester, env.engine);
      dtmf.add((callKey: '$cid', digits: '5#'));
      await settle(tester, env.engine);
      expect(env.engine.sentDtmf[cid], '5#');
      dtmf.add((callKey: '999', digits: '1'));
      await settle(tester, env.engine);
      expect(env.engine.sentDtmf.length, 1);
    });
  });

  group('side effects', () {
    testWidgets('proximity / keep-screen / tray are only invoked on change, not every stats tick', (tester) async {
      final env = await env0();
      final plat = CountingPlatform();
      await pumpWith(tester, env, [platformServicesProvider.overrideWithValue(plat)]);
      await waitRegistered(tester, env);
      final c = containerOf(tester);
      final cid = await c.read(callsProvider.notifier).dial('2002');
      await settle(tester, env.engine);
      final p0 = plat.proximity, k0 = plat.keepOn, t0 = plat.tray;
      for (var i = 0; i < 6; i++) {
        await tester.pump(const Duration(seconds: 1));
        await settle(tester, env.engine);
      }
      expect(plat.proximity, p0);
      expect(plat.keepOn, k0);
      expect(plat.tray, t0);
      await c.read(callsProvider.notifier).hangup(cid!);
      await settle(tester, env.engine);
      expect(plat.proximity, greaterThan(p0));
    });
  });

  group('keypad layout', () {
    testWidgets('the account appears once (selector only, no duplicate chip strip)', (tester) async {
      final env = await env0();
      await pumpApp(tester, env);
      await waitRegistered(tester, env);
      expect(find.byType(AccountStrip), findsNothing);
      expect(find.byType(AccountSelector), findsOneWidget);
      expect(find.text('1001@pbx.test'), findsOneWidget);
    });

    testWidgets('tall phones show top suggestions above the keypad', (tester) async {
      final env = await env0(contacts: const [
        Contact(id: 'k1', name: 'Alice', numbers: [ContactNumber(value: '2001')]),
        Contact(id: 'k2', name: 'Alan', numbers: [ContactNumber(value: '2002')]),
      ]);
      await pumpApp(tester, env, size: const Size(420, 900));
      await waitRegistered(tester, env);
      containerOf(tester).read(dialInputProvider.notifier).set('2');
      await tester.pump();
      expect(find.byKey(const Key('keypad-quick-list')), findsOneWidget);
      expect(find.text('Alice'), findsOneWidget);
      expect(find.text('Suggestions'), findsOneWidget);
    });
  });
}
