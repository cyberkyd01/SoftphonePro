import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:softphonepro/app.dart';
import 'package:softphonepro/models/app_settings.dart';
import 'package:softphonepro/models/call_record.dart';
import 'package:softphonepro/models/chat.dart';
import 'package:softphonepro/models/contact.dart';
import 'package:softphonepro/recordings/recording_exporter.dart';
import 'package:softphonepro/recordings/recording_playback.dart';
import 'package:softphonepro/recordings/recordings_controller.dart';
import 'package:softphonepro/services/history_controller.dart';
import 'package:softphonepro/services/providers.dart' show BootData;
import 'package:softphonepro/storage/repositories.dart';
import 'package:softphonepro/ui/router.dart';

import '../harness.dart';

class FakePlayback implements RecordingPlayback {
  final _playing = StreamController<bool>.broadcast();
  final _pos = StreamController<Duration>.broadcast();
  final _dur = StreamController<Duration>.broadcast();
  final _done = StreamController<void>.broadcast();
  final log = <String>[];
  @override
  Stream<bool> get playing => _playing.stream;
  @override
  Stream<Duration> get position => _pos.stream;
  @override
  Stream<Duration> get duration => _dur.stream;
  @override
  Stream<void> get completed => _done.stream;
  @override
  Future<void> play(String path) async {
    log.add('play');
    _playing.add(true);
    _dur.add(const Duration(seconds: 60));
  }

  @override
  Future<void> pause() async {
    log.add('pause');
    _playing.add(false);
  }

  @override
  Future<void> resume() async {
    log.add('resume');
    _playing.add(true);
  }

  @override
  Future<void> seek(Duration to) async {
    log.add('seek ${to.inSeconds}');
    _pos.add(to);
  }

  @override
  Future<void> stop() async {}
  @override
  Future<void> dispose() async {}
  void tick(Duration d) => _pos.add(d);
}

class FakeExporter implements RecordingExporter {
  final log = <String>[];
  @override
  Future<String?> saveAs(RecordingMeta m, {String? suggestedName}) async {
    log.add('saveAs ${m.id}');
    return '/tmp/saved.wav';
  }

  @override
  Future<void> share(List<RecordingMeta> items) async => log.add('share ${items.map((m) => m.id).join(',')}');
  @override
  Future<void> reveal(String path) async => log.add('reveal');
  @override
  Future<void> openExternal(String path) async => log.add('open $path');
  @override
  Future<void> openFolder(String dir) async => log.add('folder $dir');
}

late Directory tmp;
late FakePlayback player;
late FakeExporter exporter;

RecordingMeta meta(String id, String remote, DateTime time, {String format = 'wav', int bytes = 2 * 1024 * 1024, bool outgoing = false, String name = '', String acc = 'acc1', List<String> related = const []}) {
  final f = File('${tmp.path}/$id.${format == 'opus' ? 'ogg' : 'wav'}')..writeAsBytesSync(List.filled(16, 1));
  return RecordingMeta(id: id, path: f.path, remote: remote, time: time, durationMs: 65000, accountId: acc, format: format, bytes: bytes, outgoing: outgoing, remoteName: name, relatedIds: related);
}

Future<TestEnv> setup(WidgetTester tester, List<RecordingMeta> metas, {List<Contact> contacts = const [], Map<String, dynamic> settings = const {}, Size size = const Size(420, 900), List<CallRecord> history = const []}) async {
  player = FakePlayback();
  exporter = FakeExporter();
  final env = await TestEnv.create(
    profiles: [testProfile(), testProfile(id: 'acc2', user: '1002')],
    settings: AppSettings({'onboardingDone': true, ...settings}),
    contacts: contacts,
  );
  final built = metas.isEmpty ? <RecordingMeta>[] : metas;
  await tester.runAsync(() async {
    for (final m in built) {
      await RecordingsRepository(env.db).put(m);
    }
    for (final h in history) {
      await HistoryRepository(env.db).put(h);
    }
  });
  env.boot = BootData(settings: env.boot.settings, profiles: env.boot.profiles, contacts: env.boot.contacts, history: history);
  tester.view.physicalSize = size * 2;
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        ...env.overrides,
        recordingPlaybackFactoryProvider.overrideWithValue(() => player),
        recordingExporterProvider.overrideWithValue(exporter),
      ],
      child: const SoftphoneApp(),
    ),
  );
  await settle(tester, env.engine);
  return env;
}

Future<void> open(WidgetTester tester, TestEnv env, [String path = '/recordings']) async {
  containerOf(tester).read(routerProvider).go(path);
  await tester.pumpAndSettle();
  await settle(tester, env.engine);
}

void main() {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day, 12);
  final yesterday = today.subtract(const Duration(days: 1));

  setUp(() => tmp = Directory.systemTemp.createTempSync('rec_page'));
  tearDown(() {
    if (tmp.existsSync()) tmp.deleteSync(recursive: true);
  });

  testWidgets('lists recordings by day with name, direction, account, duration, size and format badge', (tester) async {
    final env = await setup(
      tester,
      [
        meta('r1', '3003', today, outgoing: true),
        meta('r2', '4004', yesterday, format: 'opus', bytes: 300 * 1024, name: 'Vendor line'),
        meta('r3', '5005', yesterday.subtract(const Duration(hours: 2)), format: 'wavStereo', acc: 'acc2'),
      ],
      contacts: [const Contact(id: 'c', name: 'Dana', numbers: [ContactNumber(label: 'w', value: '3003')])],
    );
    await open(tester, env);
    expect(find.text('Recordings'), findsWidgets);
    expect(find.text('TODAY'), findsOneWidget);
    expect(find.text('YESTERDAY'), findsOneWidget);
    expect(find.text('Dana'), findsOneWidget);
    expect(find.text('Vendor line'), findsOneWidget);
    expect(find.byKey(const Key('rec-badge-r1')), findsOneWidget);
    expect(find.descendant(of: find.byKey(const Key('rec-badge-r2')), matching: find.text('Opus')), findsOneWidget);
    expect(find.descendant(of: find.byKey(const Key('rec-badge-r3')), matching: find.text('WAV stereo')), findsOneWidget);
    expect(find.textContaining('01:05'), findsWidgets);
    expect(find.textContaining('2.0 MB'), findsNWidgets(2));
    expect(find.textContaining('300 KB'), findsOneWidget);
    expect(tester.widget<Text>(find.byKey(const Key('rec-usage'))).data, contains('3 recordings'));
  });

  testWidgets('search and filters narrow the list; empty state offers to clear them', (tester) async {
    final env = await setup(tester, [
      meta('r1', '3003', today, outgoing: true),
      meta('r2', '4004', today),
      meta('r3', '5005', yesterday, acc: 'acc2'),
    ], size: const Size(1000, 900));
    await open(tester, env);
    await tester.tap(find.byKey(const Key('rec-search-toggle')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('rec-search')), '400');
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('rec-badge-r2')), findsOneWidget);
    expect(find.byKey(const Key('rec-badge-r1')), findsNothing);
    await tester.enterText(find.byKey(const Key('rec-search')), '');
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('rec-dir-Outgoing')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('rec-badge-r1')), findsOneWidget);
    expect(find.byKey(const Key('rec-badge-r2')), findsNothing);
    await tester.tap(find.byKey(const Key('rec-dir-All')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('rec-account-filter')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('1002@pbx.test').last);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('rec-badge-r3')), findsOneWidget);
    expect(find.byKey(const Key('rec-badge-r1')), findsNothing);
    await tester.tap(find.byKey(const Key('rec-dir-Outgoing')));
    await tester.pumpAndSettle();
    expect(find.text('No matching recordings'), findsOneWidget);
    await tester.tap(find.text('Clear filters'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('rec-badge-r1')), findsOneWidget);
    expect(find.byKey(const Key('rec-badge-r3')), findsOneWidget);
  });

  testWidgets('player: play, pause, resume, seek and position', (tester) async {
    final env = await setup(tester, [meta('r1', '3003', today)]);
    await open(tester, env);
    await tester.tap(find.byKey(const Key('rec-badge-r1')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('player-toggle')), findsOneWidget);
    expect(find.text('00:00 / 01:05'), findsOneWidget);
    await tester.tap(find.byKey(const Key('player-toggle')));
    await tester.pumpAndSettle();
    expect(player.log, ['play']);
    player.tick(const Duration(seconds: 12));
    await tester.pumpAndSettle();
    expect(find.text('00:12 / 01:00'), findsOneWidget);
    await tester.tap(find.byKey(const Key('player-toggle')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('player-toggle')));
    await tester.pumpAndSettle();
    expect(player.log, ['play', 'pause', 'resume']);
    final slider = find.byKey(const Key('player-seek'));
    await tester.tapAt(tester.getCenter(slider));
    await tester.pumpAndSettle();
    expect(player.log.last, startsWith('seek '));
  });

  testWidgets('Opus on a platform without an Ogg Opus decoder offers "Open with..." instead of playing', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);
    final env = await setup(tester, [meta('r1', '3003', today, format: 'opus')]);
    await open(tester, env);
    await tester.tap(find.byKey(const Key('rec-badge-r1')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('player-unsupported')), findsOneWidget);
    expect(find.byKey(const Key('player-toggle')), findsNothing);
    await tester.tap(find.byKey(const Key('player-open-with')));
    await tester.pump();
    expect(exporter.log.single, startsWith('open '));
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('rename, export and delete (with confirmation)', (tester) async {
    final env = await setup(tester, [meta('r1', '3003', today), meta('r2', '4004', today)]);
    final c = containerOf(tester);
    await open(tester, env);
    await tester.tap(find.byKey(const Key('rec-badge-r1')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('rec-rename')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, 'Quote call');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('Quote call'), findsOneWidget);
    expect(c.read(recordingsProvider).firstWhere((m) => m.id == 'r1').title, 'Quote call');

    await tester.tap(find.byKey(const Key('rec-save-as')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('rec-reveal')));
    await tester.pump();
    expect(exporter.log, ['saveAs r1', 'reveal']);

    final file = c.read(recordingsProvider).firstWhere((m) => m.id == 'r1').path;
    await tester.tap(find.byKey(const Key('rec-delete')));
    await tester.pumpAndSettle();
    expect(find.text('Delete this recording?'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(c.read(recordingsProvider), hasLength(2));
    await tester.tap(find.byKey(const Key('rec-delete')));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
    await tester.pumpAndSettle();
    await settle(tester, env.engine);
    expect(c.read(recordingsProvider).map((m) => m.id), ['r2']);
    expect(File(file).existsSync(), isFalse);
  });

  testWidgets('bulk select and delete', (tester) async {
    final env = await setup(tester, [meta('r1', '1', today), meta('r2', '2', today), meta('r3', '3', today)]);
    final c = containerOf(tester);
    await open(tester, env);
    await tester.tap(find.byKey(const Key('rec-select-mode')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('rec-badge-r1')));
    await tester.tap(find.byKey(const Key('rec-badge-r3')));
    await tester.pumpAndSettle();
    expect(find.text('2 selected'), findsOneWidget);
    await tester.tap(find.byKey(const Key('rec-delete-selected')));
    await tester.pumpAndSettle();
    expect(find.text('Delete 2 recordings?'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
    await tester.pumpAndSettle();
    await settle(tester, env.engine);
    expect(c.read(recordingsProvider).map((m) => m.id), ['r2']);
    expect(find.text('Recordings'), findsWidgets);
  });

  testWidgets('a missing audio file is flagged', (tester) async {
    final env = await setup(tester, [meta('r1', '3003', today)]);
    final c = containerOf(tester);
    await open(tester, env);
    File(c.read(recordingsProvider).single.path).deleteSync();
    await tester.tap(find.byKey(const Key('rec-badge-r1')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('rec-missing')), findsOneWidget);
  });

  testWidgets('history detail shows the recording and links to the manager; related recordings link both ways', (tester) async {
    final rec = meta('r1', '3003', today, related: ['r2']);
    final rec2 = meta('r2', '4004', today, related: ['r1']);
    final hist = CallRecord(
      id: 'h1',
      accountId: 'acc1',
      direction: CallDirection.outgoing,
      remoteUri: 'sip:3003@pbx.test',
      remoteNumber: '3003',
      remoteDisplay: '',
      start: today,
      durationMs: 65000,
      recordingPath: rec.path,
      recordingId: 'r1',
      relatedRecordingIds: const ['r2'],
    );
    final env = await setup(tester, [rec, rec2], history: [hist]);
    await open(tester, env, '/recents/detail?n=3003');
    expect(find.byKey(const Key('open-recording-r1')), findsOneWidget);
    expect(find.byKey(const Key('related-recording-r2')), findsOneWidget);
    await tester.ensureVisible(find.byKey(const Key('related-recording-r2')));
    await tester.tap(find.byKey(const Key('related-recording-r2')));
    await tester.pumpAndSettle();
    // The manager opens with the related recording expanded.
    expect(find.byKey(const Key('player-toggle')), findsOneWidget);
    expect(find.byKey(const Key('rec-related-r1')), findsOneWidget);
    expect(containerOf(tester).read(historyProvider).single.recordingId, 'r1');
  });

  testWidgets('mobile: More > Recordings; desktop: rail entry', (tester) async {
    final env = await setup(tester, [meta('r1', '3003', today)]);
    await open(tester, env, '/more');
    expect(find.byKey(const Key('more-recordings')), findsOneWidget);
    await tester.tap(find.byKey(const Key('more-recordings')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('rec-badge-r1')), findsOneWidget);
  });

  testWidgets('desktop navigation rail has a Recordings destination', (tester) async {
    final env = await setup(tester, [meta('r1', '3003', today)], size: const Size(1300, 900));
    await open(tester, env, '/keypad');
    await tester.tap(find.text('Recordings'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('rec-badge-r1')), findsOneWidget);
  });
}
