import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:softphonepro/app.dart';
import 'package:softphonepro/diagnostics/redaction.dart';
import 'package:softphonepro/l10n/app_localizations.dart';
import 'package:softphonepro/models/app_settings.dart';
import 'package:softphonepro/platform/desktop/desktop_channel.dart';
import 'package:softphonepro/platform/desktop/launch_args.dart';
import 'package:softphonepro/platform/platform_services.dart';
import 'package:softphonepro/services/accounts_controller.dart';
import 'package:softphonepro/services/link_router.dart';
import 'package:softphonepro/services/providers.dart';
import 'package:softphonepro/services/provisioning.dart';
import 'package:softphonepro/services/provisioning_import.dart';
import 'package:softphonepro/services/settings_controller.dart';
import 'package:softphonepro/ui/settings/provisioning_section.dart';

import 'harness.dart';

class _LinkPlatform extends NoopPlatformServices {
  final links = StreamController<Uri>.broadcast();
  @override
  Stream<Uri> get incomingLinks => links.stream;
}

/// Every setting an attacker would like to change. Refused ones abort the whole import.
const _refused = <String, Object?>{
  'tlsVerify': false,
  'customCaFile': '/tmp/evil-ca.pem',
  'tlsPins': ['sha256/AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA='],
  'dnsServers': ['6.6.6.6'],
  'automationEnabled': true,
  'automationToken': 'abababababababababababababababab',
  'automationPort': 9999,
  'automationOrigins': ['https://evil.test'],
  'appLock': true,
  'appLockMinutes': 1,
};

/// Dropped (listed as ignored) when present next to harmless settings.
const _dropped = <String, Object?>{
  'recordingFolder': r'\\evil\share',
  'lanDownloadsDir': '/tmp/dl',
  'lanAutoAcceptFiles': true,
  'lanEnabled': true,
  'lanShareAors': ['*'],
  'announceOpeningFile': '/etc/passwd',
  'recordingNoticeFile': '/etc/passwd',
  'transferNoticeFile': '/etc/passwd',
  'captureDev': 'evil',
  'playbackDev': 'evil',
  'ringerDev': 'evil',
  'hotkeys': {'answer': 'ctrl+a'},
  'startAtLogin': true,
  'globalStatus': 'away',
  'useSimulator': true,
  'instanceMac': '02:de:ad:be:ef:00',
  'updateCheck': false,
  'updateLastCheck': 5,
  'updateSkipVersion': '9.9',
  'onboardingDone': true,
  'stunServers': ['stun.evil.test:3478'],
  'tlsEnabled': false,
  'udpPort': 5060,
  'unknownFutureSetting': 'x',
};

const _good = <String, Object?>{'ptime': 30, 'themeMode': 'dark', 'opusBitrate': 24000, 'callWaiting': false, 'viMicStrength': 0.5};

/// Applied, but flagged in the dialog.
const _flagged = <String, Object?>{
  'autoRecord': true,
  'recordRule': 'all',
  'blocklist': ['100'],
  'emergencyNumbers': ['112'],
  'speedDial': {
    '1': {'number': '0900'},
  },
  'autoAnswer': true,
  'stripPrefix': '0',
  'recordAutoDeleteDays': 1,
};

String _json(Map<String, Object?> settings, {List<Map<String, Object?>> accounts = const []}) => jsonEncode({'version': 1, 'accounts': accounts, 'settings': settings});

const _acc = {'username': 'u1', 'password': 'p', 'domain': 'pbx.test'};

/// An account with every risky account-level feature.
const _riskyAccount = <String, Object?>{
  'label': 'X',
  'sip': {
    'username': 'u2',
    'password': 'p',
    'domain': 'pbx.test',
    'registrar': 'sip:reg.evil.test',
    'proxies': ['sip:proxy.evil.test'],
    'transport': 'tls',
    'srtp': 'off',
    'headers': {'X-Evil': '1'},
    'callerId': 'sip:boss@x',
    'tlsClientCert': {'certFile': '/home/me/cert.pem', 'keyFile': '/home/me/key.pem'},
  },
  'autoAnswer': {'enabled': true},
  'autoRecord': 'always',
  'forwarding': {'mode': 'always', 'target': '0900123'},
  'ringtone': '../../etc/passwd',
  'holdMusic': '/abs/path.mp3',
  'openingAnnouncement': 'lib:../../x',
};

/// Real settings keys that are read / written outside the AppSettings getters.
const _notInAppSettings = {'instanceMac'};

void _expectNothingDangerous(AppSettings s) {
  expect(s.tlsVerify, isTrue);
  expect(s.customCaFile, '');
  expect(s.tlsPins, isEmpty);
  expect(s.dnsServers, isEmpty);
  expect(s.automationEnabled, isFalse);
  expect(s.automationToken, '');
  expect(s.automationOrigins, isEmpty);
  expect(s.appLock, isFalse);
  final j = s.toJson();
  for (final k in _dropped.keys) {
    if (k == 'onboardingDone') continue; // set true by the import of an account, tested separately
    if (k == 'instanceMac') {
      expect(j['instanceMac'], isNot(_dropped['instanceMac'])); // the app itself creates its own id
      continue;
    }
    expect(j.containsKey(k), isFalse, reason: k);
  }
}

void main() {
  group('policy: every AppSettings key is classified', () {
    final src = File('lib/models/app_settings.dart').readAsStringSync();
    final keys = <String>{
      for (final m in RegExp(r"""\b_[bidsl]\(\s*'(\w+)'""").allMatches(src)) m.group(1)!,
      for (final m in RegExp(r"""_m\[\s*'(\w+)'\s*\]""").allMatches(src)) m.group(1)!,
    };

    test('found a plausible number of keys', () => expect(keys.length, greaterThan(100)));

    test('no unclassified key (new settings must be classified here to be importable)', () {
      final missing = keys.where((k) => !kSettingImportPolicy.containsKey(k)).toList()..sort();
      expect(missing, isEmpty, reason: 'classify these in kSettingImportPolicy (allowed / flagged / forbidden / refused): $missing');
    });

    test('the policy lists only real keys', () {
      final stale = kSettingImportPolicy.keys.where((k) => !keys.contains(k) && !_notInAppSettings.contains(k)).toList();
      expect(stale, isEmpty);
    });

    test('security-relevant keys are never allowed or flagged', () {
      const never = [
        'tlsVerify', 'customCaFile', 'tlsPins', 'dnsServers', 'automationEnabled', 'automationPort', 'automationToken',
        'automationOrigins', 'appLock', 'appLockMinutes', 'appLockBiometrics', 'recordingFolder', 'lanDownloadsDir',
        'lanAutoAcceptFiles', 'lanEnabled', 'announceOpeningFile', 'recordingNoticeFile', 'transferNoticeFile',
        'captureDev', 'playbackDev', 'ringerDev', 'hotkeys', 'startAtLogin', 'globalStatus', 'useSimulator',
        'instanceMac', 'updateCheck', 'stunServers', 'onboardingDone',
      ];
      for (final k in never) {
        expect(const {ImportClass.forbidden, ImportClass.refused}, contains(classifyImportSetting(k)), reason: k);
      }
      for (final k in ['tlsVerify', 'customCaFile', 'tlsPins', 'dnsServers', 'automationEnabled', 'appLock']) {
        expect(classifyImportSetting(k), ImportClass.refused, reason: k);
      }
      expect(classifyImportSetting('automationSomethingNew'), ImportClass.refused);
      expect(classifyImportSetting('appLockSomethingNew'), ImportClass.refused);
      expect(classifyImportSetting('somethingNew'), ImportClass.forbidden);
    });

    test('exports only carry classified, non-refused keys', () {
      for (final k in Provisioning.exportableSettings) {
        expect(kSettingImportPolicy.containsKey(k), isTrue, reason: k);
        expect(classifyImportSetting(k), isNot(ImportClass.refused), reason: k);
      }
    });
  });

  group('prepareUntrustedImport', () {
    test('every refused setting refuses the whole import', () {
      for (final e in _refused.entries) {
        final p = prepareUntrustedImport(ProvisioningResult(settings: {'ptime': 30, e.key: e.value}));
        expect(p.refusedKey, e.key, reason: e.key);
      }
    });

    test('harmless values of refused keys are dropped, not refused', () {
      final p = prepareUntrustedImport(const ProvisioningResult(settings: {'tlsVerify': true, 'customCaFile': '', 'tlsPins': [], 'dnsServers': [], 'ptime': 30}));
      expect(p.refusedKey, isNull);
      expect(p.safeSettings, {'ptime': 30});
      expect(p.ignored, containsAll(['tlsVerify', 'customCaFile', 'tlsPins', 'dnsServers']));
    });

    test('allowlisted keys apply, the rest is listed as ignored', () {
      final p = prepareUntrustedImport(ProvisioningResult(settings: {..._good, ..._dropped}));
      expect(p.refusedKey, isNull);
      expect(p.safeSettings, _good);
      expect(p.ignored.toSet(), _dropped.keys.toSet());
      expect(p.resolve(const ImportDecision()).settings, _good);
    });

    test('wrongly typed values are ignored', () {
      final p = prepareUntrustedImport(const ProvisioningResult(settings: {'ptime': 'x', 'themeMode': 5, 'ringtone': '/etc/passwd', 'codecOrder': 'a'}));
      expect(p.safeSettings, isEmpty);
      expect(p.ignored, hasLength(4));
    });

    test('flagged settings carry flags; auto-answer and auto-record are off unless ticked', () {
      final p = prepareUntrustedImport(ProvisioningResult(settings: {..._flagged, ..._good}));
      expect(p.flags.map((f) => f.kind.name).toSet(), containsAll(['autoAnswer', 'autoRecord', 'blocklist', 'emergencyNumbers', 'speedDial', 'dialRewrite', 'recordingDeletion']));
      final off = p.resolve(const ImportDecision()).settings;
      expect(off.containsKey('autoAnswer'), isFalse);
      expect(off.containsKey('autoRecord'), isFalse);
      expect(off.containsKey('recordRule'), isFalse);
      expect(off['blocklist'], ['100']);
      expect(off['stripPrefix'], '0');
      final on = p.resolve(const ImportDecision(allowAutoAnswer: true, allowAutoRecord: true)).settings;
      expect(on['autoAnswer'], true);
      expect(on['autoRecord'], true);
      expect(on['recordRule'], 'all');
    });

    test('turning auto-record off or recordRule off needs no consent', () {
      final p = prepareUntrustedImport(const ProvisioningResult(settings: {'autoRecord': false, 'recordRule': 'off', 'autoAnswer': false}));
      expect(p.flags, isEmpty);
      expect(p.resolve(const ImportDecision()).settings, {'autoRecord': false, 'recordRule': 'off', 'autoAnswer': false});
    });

    test('accounts: client cert dropped, risky features flagged and off, bad audio refs reset', () {
      final r = Provisioning.parse(_json({}, accounts: [_riskyAccount]));
      expect(r.accounts.single.config.tlsClientCert, isNotNull);
      final p = prepareUntrustedImport(r);
      expect(p.accounts.single.config.tlsClientCert, isNull);
      expect(p.ignored, contains('accounts[0].tlsClientCert'));
      expect(p.flags.map((f) => f.kind.name), containsAll(['autoAnswer', 'autoRecord', 'forwarding']));
      expect(p.flags.firstWhere((f) => f.kind == ImportFlagKind.forwarding).arg, '0900123');
      final a = p.resolve(const ImportDecision()).accounts.single;
      expect(a.autoAnswer.enabled, isFalse);
      expect(a.autoRecord, 'inherit');
      expect(a.ringtone, 'default');
      expect(a.holdMusic, 'inherit');
      expect(a.openingAnnouncement, 'inherit');
      expect(a.config.registrar, 'sip:reg.evil.test'); // shown in the dialog, not hidden
      final t = p.resolve(const ImportDecision(allowAutoAnswer: true, allowAutoRecord: true)).accounts.single;
      expect(t.autoAnswer.enabled, isTrue);
      expect(t.autoRecord, 'always');
      expect(t.config.tlsClientCert, isNull);
    });

    test('safe audio refs survive', () {
      final r = Provisioning.parse(_json({'ringtone': 'builtin:classic', 'holdMusic': 'lib:music.mp3'}, accounts: [
        {'sip': {'username': 'u', 'domain': 'd'}, 'ringtone': 'builtin:classic', 'holdMusic': 'pbx', 'openingAnnouncement': 'off'},
      ]));
      final p = prepareUntrustedImport(r);
      expect(p.safeSettings, {'ringtone': 'builtin:classic', 'holdMusic': 'lib:music.mp3'});
      expect(p.accounts.single.ringtone, 'builtin:classic');
      expect(p.ignored, isEmpty);
    });
  });

  group('trusted (CLI) vs untrusted import', () {
    late ProviderContainer c;
    late Provider<Ref> refP;
    setUp(() async {
      final env = await TestEnv.create(settings: const AppSettings());
      refP = Provider<Ref>((ref) => ref);
      c = ProviderContainer(overrides: env.overrides);
      addTearDown(c.dispose);
    });

    test('applyTrustedImport applies the automation API; the default entry point never does', () async {
      final r = Provisioning.parse(_json({'automationEnabled': true, 'automationToken': 'x' * 32, 'tlsVerify': false, 'ptime': 30}));
      await expectLater(importProvisioningResult(c.read(refP), r), throwsA(isA<ProvisioningException>()));
      var s = c.read(settingsProvider);
      expect(s.automationEnabled, isFalse);
      expect(s.tlsVerify, isTrue);
      expect(s.ptime, 20, reason: 'a refused import applies nothing at all');
      await applyTrustedImport(c.read(refP).read, r);
      s = c.read(settingsProvider);
      expect(s.automationEnabled, isTrue);
      expect(s.automationToken, 'x' * 32);
      expect(s.tlsVerify, isFalse);
      expect(s.ptime, 30);
      await c.read(settingsProvider.notifier).update({'automationEnabled': false});
    });
  });

  // ---- the five untrusted channels ------------------------------------------------

  Future<_Harness> harness(WidgetTester tester, {http.Client? client}) async {
    final env = await TestEnv.create(settings: const AppSettings());
    final h = _Harness(env);
    tester.view.physicalSize = const Size(420, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [...env.overrides, if (client != null) provisioningClientProvider.overrideWithValue(client)],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Consumer(
            builder: (context, ref, _) {
              h.context = context;
              h.ref = ref;
              return const Scaffold(body: SizedBox());
            },
          ),
        ),
      ),
    );
    return h;
  }

  // Each channel turns an untrusted document into an import. (b) QR, (c) pasted
  // JSON / URL text, (d) file, (e) Settings URL fetch all end in applyProvisioning.
  final channels = <String, Future<void> Function(_Harness h, String doc)>{
    'QR (softphonepro://provision?b64=)': (h, doc) => importProvisioningText(h.context, h.ref, 'softphonepro://provision?b64=${base64Url.encode(utf8.encode(doc))}'),
    'QR (softphonepro://provision?data=)': (h, doc) => importProvisioningText(h.context, h.ref, 'softphonepro://provision?data=${Uri.encodeComponent(doc)}'),
    'pasted JSON': (h, doc) => importProvisioningText(h.context, h.ref, doc),
    'file import': (h, doc) async {
      await applyProvisioning(h.context, h.ref, Provisioning.parse(doc));
    },
    'Settings URL fetch': (h, doc) => importProvisioningText(h.context, h.ref, 'https://prov.test/p.json'),
  };

  for (final ch in channels.entries) {
    group('channel: ${ch.key}', () {
      testWidgets('a refused setting imports nothing, even the harmless parts', (tester) async {
        for (final e in _refused.entries) {
          final doc = _json({..._good, e.key: e.value}, accounts: [_acc]);
          final h = await harness(tester, client: MockClient((_) async => http.Response(doc, 200)));
          unawaited(ch.value(h, doc));
          await tester.pumpAndSettle();
          expect(find.byKey(const Key('link-import-confirm')), findsNothing, reason: e.key);
          final c = h.container(tester);
          expect(c.read(accountsProvider).profiles, isEmpty, reason: e.key);
          expect(c.read(settingsProvider).ptime, 20, reason: e.key);
          _expectNothingDangerous(c.read(settingsProvider));
        }
      });

      testWidgets('dangerous settings are dropped and listed; allowlisted apply; flags are shown', (tester) async {
        final doc = _json({..._good, ..._dropped, ..._flagged}, accounts: [_riskyAccount]);
        final h = await harness(tester, client: MockClient((_) async => http.Response(doc, 200)));
        unawaited(ch.value(h, doc));
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('link-import-confirm')), findsOneWidget);
        for (final k in ['autoAnswer', 'autoRecord', 'forwarding', 'blocklist', 'emergencyNumbers', 'speedDial', 'dialRewrite', 'recordingDeletion']) {
          expect(find.byKey(Key('link-import-flag-$k')), findsOneWidget, reason: k);
        }
        expect(find.textContaining('0900123'), findsOneWidget);
        expect(find.textContaining('reg.evil.test'), findsWidgets);
        expect(find.textContaining('proxy.evil.test'), findsOneWidget);
        expect(find.textContaining('X-Evil'), findsOneWidget);
        expect(find.byKey(const Key('link-import-ignored')), findsOneWidget);
        final ignored = tester.widget<Text>(find.byKey(const Key('link-import-ignored'))).data!;
        for (final k in ['recordingFolder', 'lanDownloadsDir', 'captureDev', 'instanceMac', 'accounts[0].tlsClientCert']) {
          expect(ignored, contains(k));
        }
        await tester.tap(find.byKey(const Key('link-import-yes')));
        await tester.pumpAndSettle();
        final c = h.container(tester);
        final s = c.read(settingsProvider);
        _expectNothingDangerous(s);
        expect(s.ptime, 30);
        expect(s.themeMode, ThemeMode.dark);
        expect(s.callWaiting, isFalse);
        expect(s.blocklist, ['100']);
        expect(s.stripPrefix, '0');
        expect(s.autoAnswer, isFalse);
        expect(s.autoRecord, isFalse);
        expect(s.toJson().containsKey('recordRule'), isFalse);
        final a = c.read(accountsProvider).profiles.single;
        expect(a.autoAnswer.enabled, isFalse);
        expect(a.autoRecord, 'inherit');
        expect(a.config.tlsClientCert, isNull);
        expect(a.ringtone, 'default');
        expect(a.forwarding.target, '0900123');
      });

      testWidgets('ticking the boxes enables auto-answer and auto-record; cancel imports nothing', (tester) async {
        final doc = _json({'autoAnswer': true, 'autoRecord': true, 'recordRule': 'all', 'ptime': 30}, accounts: [_riskyAccount]);
        final h = await harness(tester, client: MockClient((_) async => http.Response(doc, 200)));
        unawaited(ch.value(h, doc));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();
        expect(h.container(tester).read(accountsProvider).profiles, isEmpty);
        expect(h.container(tester).read(settingsProvider).ptime, 20);
        unawaited(ch.value(h, doc));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('link-import-allow-autoanswer')));
        await tester.tap(find.byKey(const Key('link-import-allow-autorecord')));
        await tester.pump();
        await tester.tap(find.byKey(const Key('link-import-yes')));
        await tester.pumpAndSettle();
        final c = h.container(tester);
        final s = c.read(settingsProvider);
        expect(s.autoAnswer, isTrue);
        expect(s.recordRule, 'all');
        final a = c.read(accountsProvider).profiles.single;
        expect(a.autoAnswer.enabled, isTrue);
        expect(a.autoRecord, 'always');
        expect(a.config.tlsClientCert, isNull, reason: 'a client certificate path is never importable');
        _expectNothingDangerous(s);
      });
    });
  }

  group('channel: web link', () {
    Future<void> pumpLink(WidgetTester tester, TestEnv env, _LinkPlatform platform, String doc) async {
      tester.view.physicalSize = const Size(420, 2400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final client = MockClient((_) async => http.Response(doc, 200));
      await tester.pumpWidget(ProviderScope(
        overrides: [...env.overrides, platformServicesProvider.overrideWithValue(platform), provisioningClientProvider.overrideWithValue(client)],
        child: const SoftphoneApp(),
      ));
      await settle(tester, env.engine);
      platform.links.add(Uri.parse('softphonepro://provision?url=${Uri.encodeComponent('https://prov.test/p.json')}'));
      await settle(tester, env.engine);
      await tester.pumpAndSettle();
    }

    testWidgets('every refused setting imports nothing', (tester) async {
      for (final e in _refused.entries) {
        final env = await TestEnv.create(settings: const AppSettings());
        await pumpLink(tester, env, _LinkPlatform(), _json({..._good, e.key: e.value}, accounts: [_acc]));
        expect(find.byKey(const Key('link-import-confirm')), findsNothing, reason: e.key);
        final c = containerOf(tester);
        expect(c.read(accountsProvider).profiles, isEmpty, reason: e.key);
        expect(c.read(settingsProvider).ptime, 20, reason: e.key);
        _expectNothingDangerous(c.read(settingsProvider));
        await tester.pumpWidget(const SizedBox());
      }
    });

    testWidgets('dangerous settings are dropped, allowlisted apply, flags shown', (tester) async {
      final env = await TestEnv.create(settings: const AppSettings());
      await pumpLink(tester, env, _LinkPlatform(), _json({..._good, ..._dropped, ..._flagged}, accounts: [_riskyAccount]));
      expect(find.byKey(const Key('link-import-confirm')), findsOneWidget);
      for (final k in ['autoAnswer', 'autoRecord', 'forwarding', 'blocklist', 'emergencyNumbers', 'speedDial', 'dialRewrite', 'recordingDeletion']) {
        expect(find.byKey(Key('link-import-flag-$k')), findsOneWidget, reason: k);
      }
      expect(find.byKey(const Key('link-import-ignored')), findsOneWidget);
      await tester.tap(find.byKey(const Key('link-import-yes')));
      await settle(tester, env.engine);
      await tester.pumpAndSettle();
      final c = containerOf(tester);
      final s = c.read(settingsProvider);
      _expectNothingDangerous(s);
      expect(s.ptime, 30);
      expect(s.autoRecord, isFalse);
      final a = c.read(accountsProvider).profiles.single;
      expect(a.autoAnswer.enabled, isFalse);
      expect(a.autoRecord, 'inherit');
      expect(a.config.tlsClientCert, isNull);
    });
  });

  group('classifyLink', () {
    test('unsupported scheme is distinct from notLocal', () {
      final a = classifyLink(Uri.parse('ftp://x/y')) as RejectedLinkAction;
      expect(a.reason, LinkRejection.unsupportedScheme);
      final b = classifyLink(Uri.parse('softphonepro-cli://dial?v=1')) as RejectedLinkAction;
      expect(b.reason, LinkRejection.notLocal);
    });
  });

  group('macOS Apple-event payloads are links, never command-line flags', () {
    Future<(DesktopChannel, List<Uri>)> make({required bool mac}) async {
      TestWidgetsFlutterBinding.ensureInitialized();
      const ch = MethodChannel('test/desktop-trust');
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(ch, (call) async => call.method == 'ready' ? <Object?, Object?>{} : null);
      addTearDown(() => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(ch, null));
      final d = DesktopChannel(ch, mac);
      await d.init(const []);
      final got = <Uri>[];
      d.links.listen(got.add);
      return (d, got);
    }

    Future<void> send(String payload) async {
      await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.handlePlatformMessage(
        'test/desktop-trust',
        const StandardMethodCodec().encodeMethodCall(MethodCall('onArgs', payload)),
        (_) {},
      );
      await Future<void>.delayed(Duration.zero);
    }

    test('macOS: a URL with embedded newlines / flags never yields a CLI action', () async {
      final (_, got) = await make(mac: true);
      await send('--provision\nhttps://attacker.test/p.json');
      await send('sip:alice@x\n--provision\nhttps://attacker.test/p.json');
      await send('softphonepro://lan?h=1.2.3.4&p=1&id=a');
      for (final u in got) {
        expect(isLocalLaunchLink(u), isFalse);
        expect(u.scheme, isNot(kCliScheme));
      }
      expect(got.any((u) => u.scheme == 'softphonepro'), isTrue);
    });

    test('Windows forwarded argv keeps honouring --provision (same-user privilege)', () async {
      final (_, got) = await make(mac: false);
      await send('--provision\n/tmp/p.json');
      expect(got.single.scheme, kCliScheme);
      expect(isLocalLaunchLink(got.single), isTrue);
    });
  });

  group('redactSecrets: ICE passwords and JSON secrets', () {
    test('a=ice-pwd', () {
      final out = redactSecrets('a=ice-ufrag:abcd\r\na=ice-pwd:Zm9vYmFyYmF6cXV4MTIzNDU2\r\na=candidate:1 1 UDP 1 1.2.3.4 5 typ host\r\n');
      expect(out, isNot(contains('Zm9vYmFy')));
      expect(out, contains('a=ice-pwd:[REDACTED]'));
      expect(out, contains('a=ice-ufrag:abcd'));
      expect(out, contains('a=candidate:1'));
    });

    test('JSON-form password / token, plain and escaped', () {
      final out = redactSecrets(
        '{"username":"alice","password":"hunter2pass","nested":{"token": "tok-123456"},"n":1,"authToken":"zzz999"}\n'
        r'log: {\"password\":\"escapedSecret\",\"x\":2}',
      );
      for (final leak in ['hunter2pass', 'tok-123456', 'zzz999', 'escapedSecret']) {
        expect(out, isNot(contains(leak)), reason: leak);
      }
      expect(out, contains('"username":"alice"'));
      expect(out, contains('"n":1'));
      expect(out, contains('"password":"[REDACTED]"'));
    });

    test('values containing escaped quotes are fully masked', () {
      final out = redactSecrets(r'{"password":"ab\"cd-secret","k":1}');
      expect(out, isNot(contains('cd-secret')));
      expect(out, contains('"k":1'));
    });
  });
}

class _Harness {
  _Harness(this.env);
  final TestEnv env;
  late BuildContext context;
  late WidgetRef ref;
  ProviderContainer container(WidgetTester tester) => ProviderScope.containerOf(context);
}
