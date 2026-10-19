import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:softphonepro/models/app_settings.dart';
import 'package:softphonepro/services/providers.dart';
import 'package:softphonepro/services/settings_controller.dart';
import 'package:softphonepro/services/update_checker.dart';
import 'package:softphonepro/storage/app_database.dart';
import 'package:softphonepro/storage/secrets_store.dart';
import 'package:softphonepro/ui/widgets/update_banner.dart';
import 'package:softphonepro/l10n/app_localizations.dart';

http.Client replying(int code, Object? body, {List<Uri>? log}) => MockClient((req) async {
  log?.add(req.url);
  return http.Response(body is String ? body : jsonEncode(body), code);
});

Map<String, Object?> release(String tag, {bool pre = false, bool draft = false}) => {
  'tag_name': tag,
  'html_url': 'https://github.com/cyberkyd01/SoftphonePro/releases/tag/$tag',
  'body': 'notes',
  'prerelease': pre,
  'draft': draft,
};

Future<ProviderContainer> makeContainer({http.Client? client, Map<String, dynamic> settings = const {}, List<Uri>? opened}) async {
  final db = await AppDatabase.memory();
  final c = ProviderContainer(
    overrides: [
      appDatabaseProvider.overrideWithValue(db),
      secretsStoreProvider.overrideWithValue(MemorySecretsStore()),
      bootDataProvider.overrideWithValue(BootData(settings: AppSettings(settings))),
      updateHttpClientProvider.overrideWithValue(client ?? replying(200, release('v1.1.0'))),
      currentVersionProvider.overrideWithValue(Future.value(const SemVer(1, 0, 0))),
      updatesSupportedProvider.overrideWithValue(true),
      urlOpenerProvider.overrideWithValue((u) async {
        opened?.add(u);
        return true;
      }),
    ],
  );
  addTearDown(c.dispose);
  return c;
}

void main() {
  group('SemVer', () {
    test('parsing and ordering incl. pre-releases', () {
      SemVer v(String s) => SemVer.parse(s)!;
      expect(v('v1.2.3'), v('1.2.3+7'));
      expect(v('1.10.0') > v('1.9.9'), isTrue);
      expect(v('1.0.0') > v('1.0.0-rc.1'), isTrue);
      expect(v('1.0.0-rc.2') > v('1.0.0-rc.1'), isTrue);
      expect(v('1.0.0-rc.10') > v('1.0.0-rc.2'), isTrue);
      expect(v('1.0.0-beta') > v('1.0.0-alpha'), isTrue);
      expect(v('1.0.0-alpha.1') > v('1.0.0-alpha'), isTrue);
      expect(v('1.0.0-1') < v('1.0.0-a'), isTrue);
      expect(v('2') > v('1.9.9'), isTrue);
      expect(SemVer.parse('banana'), isNull);
      expect(SemVer.parse('1.x.0'), isNull);
    });
  });

  group('checkForUpdate', () {
    const cur = SemVer(1, 0, 0);
    test('newer release is reported, request goes to api.github.com only', () async {
      final log = <Uri>[];
      final r = await checkForUpdate(client: replying(200, release('v1.0.1'), log: log), current: cur);
      expect(r.outcome, UpdateOutcome.available);
      expect(r.release!.version, const SemVer(1, 0, 1));
      expect(log.single.host, 'api.github.com');
      expect(log.single.path, '/repos/cyberkyd01/SoftphonePro/releases/latest');
    });
    test('same / older / draft / prerelease are not offered', () async {
      expect((await checkForUpdate(client: replying(200, release('v1.0.0')), current: cur)).outcome, UpdateOutcome.upToDate);
      expect((await checkForUpdate(client: replying(200, release('v0.9.0')), current: cur)).outcome, UpdateOutcome.upToDate);
      expect((await checkForUpdate(client: replying(200, release('v2.0.0', pre: true)), current: cur)).outcome, UpdateOutcome.upToDate);
      expect((await checkForUpdate(client: replying(200, release('v2.0.0', draft: true)), current: cur)).outcome, UpdateOutcome.upToDate);
    });
    test('a pre-release build is offered its final release', () async {
      final r = await checkForUpdate(client: replying(200, release('v1.0.0')), current: SemVer.parse('1.0.0-rc.1')!);
      expect(r.outcome, UpdateOutcome.available);
    });
    test('rate limit, 404, errors and junk are handled', () async {
      expect((await checkForUpdate(client: replying(403, '{}'), current: cur)).outcome, UpdateOutcome.rateLimited);
      expect((await checkForUpdate(client: replying(429, '{}'), current: cur)).outcome, UpdateOutcome.rateLimited);
      expect((await checkForUpdate(client: replying(404, '{}'), current: cur)).outcome, UpdateOutcome.upToDate);
      expect((await checkForUpdate(client: replying(500, '{}'), current: cur)).outcome, UpdateOutcome.failed);
      expect((await checkForUpdate(client: replying(200, 'not json'), current: cur)).outcome, UpdateOutcome.failed);
      expect((await checkForUpdate(client: replying(200, {'tag_name': 'x'}), current: cur)).outcome, UpdateOutcome.failed);
      final err = await checkForUpdate(client: MockClient((_) async => throw Exception('offline')), current: cur);
      expect(err.outcome, UpdateOutcome.failed);
      expect(err.answered, isFalse);
    });
    test('times out', () async {
      final never = MockClient((_) => Completer<http.Response>().future);
      final r = await checkForUpdate(client: never, current: cur, timeout: const Duration(milliseconds: 50));
      expect(r.outcome, UpdateOutcome.failed);
      expect(r.error, 'Timed out');
    });
  });

  group('UpdateController', () {
    test('weekly schedule, opt-out and skip version', () async {
      final log = <Uri>[];
      final c = await makeContainer(client: replying(200, release('v1.1.0'), log: log));
      final ctl = c.read(updateProvider.notifier);
      await ctl.maybeAutoCheck();
      expect(log, hasLength(1));
      expect(c.read(updateProvider).release!.version.toString(), '1.1.0');
      expect(c.read(settingsProvider).updateLastCheck, greaterThan(0));
      await ctl.maybeAutoCheck(); // within a week: no request
      expect(log, hasLength(1));
      await ctl.maybeAutoCheck(now: DateTime.now().add(const Duration(days: 8)));
      expect(log, hasLength(2));

      await ctl.skipVersion();
      expect(c.read(settingsProvider).updateSkipVersion, '1.1.0');
      expect(c.read(updateProvider).release, isNull);
      await ctl.checkNow(); // skipped version stays hidden
      expect(c.read(updateProvider).release, isNull);
      expect(c.read(updateProvider).lastResult!.outcome, UpdateOutcome.available);
    });

    test('opt-out disables the automatic check but not "Check now"', () async {
      final log = <Uri>[];
      final c = await makeContainer(client: replying(200, release('v1.1.0'), log: log), settings: {'updateCheck': false});
      await c.read(updateProvider.notifier).maybeAutoCheck();
      expect(log, isEmpty);
      await c.read(updateProvider.notifier).checkNow();
      expect(log, hasLength(1));
    });

    test('unsupported platform (mobile) never checks', () async {
      final log = <Uri>[];
      final db = await AppDatabase.memory();
      final c = ProviderContainer(overrides: [
        appDatabaseProvider.overrideWithValue(db),
        secretsStoreProvider.overrideWithValue(MemorySecretsStore()),
        updateHttpClientProvider.overrideWithValue(replying(200, release('v9.0.0'), log: log)),
        updatesSupportedProvider.overrideWithValue(false),
      ]);
      addTearDown(c.dispose);
      await c.read(updateProvider.notifier).maybeAutoCheck();
      expect(log, isEmpty);
    });

    testWidgets('banner shows, opens the release page, dismisses', (tester) async {
      final opened = <Uri>[];
      final c = await makeContainer(opened: opened);
      await tester.runAsync(() => c.read(updateProvider.notifier).checkNow());
      await tester.pumpWidget(UncontrolledProviderScope(
        container: c,
        child: const MaterialApp(localizationsDelegates: AppLocalizations.localizationsDelegates, supportedLocales: AppLocalizations.supportedLocales, home: Scaffold(body: UpdateBanner())),
      ));
      expect(find.text('SoftphonePro 1.1.0 is available'), findsOneWidget);
      await tester.tap(find.byKey(const Key('update-download')));
      expect(opened.single.toString(), contains('/releases/tag/v1.1.0'));
      await tester.tap(find.byKey(const Key('update-dismiss')));
      await tester.pump();
      expect(find.byKey(const Key('update-banner')), findsNothing);
    });
  });
}
