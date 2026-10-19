import 'dart:io';

import 'package:flutter/widgets.dart' show Size;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:softphonepro/app.dart';
import 'package:softphonepro/audio/announcement_service.dart';
import 'package:softphonepro/models/app_settings.dart';
import 'package:softphonepro/models/call_record.dart';
import 'package:softphonepro/models/chat.dart';
import 'package:softphonepro/models/contact.dart';
import 'package:softphonepro/recordings/recordings_controller.dart';
import 'package:softphonepro/services/calls_controller.dart';
import 'package:softphonepro/services/history_controller.dart';
import 'package:softphonepro/services/settings_controller.dart';
import 'package:spcore_dart/spcore_dart.dart';

import '../harness.dart';

/// Remembers how recording was started.
class RecEng extends FakeSipEngine {
  RecEng() : super(timings: FakeTimings.instant);
  final List<({int cid, String file, RecordFormat format})> starts = [];

  @override
  Future<String> recordStart(int cid, String file, {RecordMix mix = RecordMix.both, RecordFormat format = RecordFormat.wav}) {
    starts.add((cid: cid, file: file, format: format));
    return super.recordStart(cid, file, mix: mix, format: format);
  }
}

Future<TestEnv> env({Map<String, dynamic> settings = const {}, List<Contact> contacts = const []}) =>
    TestEnv.create(
      profiles: [testProfile()],
      settings: AppSettings({'onboardingDone': true, ...settings}),
      contacts: contacts,
      engine: RecEng(),
    );

Future<void> flush(WidgetTester tester, TestEnv e) async {
  for (var i = 0; i < 3; i++) {
    await settle(tester, e.engine);
  }
}

/// Records when the recording notice is played.
class NoticeSvc extends AnnouncementService {
  NoticeSvc(super.ref, this.log, this.eng);
  final List<String> log;
  final RecEng eng;
  @override
  Future<void> playRecordingNotice(int cid) async {
    log.add('notice(recordings started: ${eng.starts.length})');
  }
}

void main() {
  testWidgets('"play a notice before recording": the notice comes first, then recording starts', (tester) async {
    final e = await env(settings: {'recordNotice': true});
    final log = <String>[];
    final eng = e.engine as RecEng;
    tester.view.physicalSize = const Size(840, 1800);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [...e.overrides, announcementServiceProvider.overrideWith((ref) => NoticeSvc(ref, log, eng))],
        child: const SoftphoneApp(),
      ),
    );
    await settle(tester, e.engine);
    await waitRegistered(tester, e);
    final calls = containerOf(tester).read(callsProvider.notifier);
    final cid = (await calls.dial('2002'))!;
    await flush(tester, e);
    await calls.startRecording(cid);
    await flush(tester, e);
    expect(log, ['notice(recordings started: 0)']);
    expect(eng.starts, hasLength(1));
    // Continuing a recording through a transfer does not repeat the notice.
    final b = (await calls.startConsult(cid, '3003'))!;
    await flush(tester, e);
    expect(eng.starts.map((s) => s.cid), [cid, b]);
    expect(log, hasLength(1));
    await calls.hangupAll();
    await flush(tester, e);
  });

  testWidgets('stereo format: engine gets wavStereo, library and history are linked', (tester) async {
    final e = await env(settings: {'recordFormat': 'wavStereo'});
    await pumpApp(tester, e);
    await waitRegistered(tester, e);
    final c = containerOf(tester);
    final calls = c.read(callsProvider.notifier);
    final cid = (await calls.dial('2002'))!;
    await flush(tester, e);
    await calls.startRecording(cid);
    await flush(tester, e);
    final eng = e.engine as RecEng;
    expect(eng.starts.single.format, RecordFormat.wavStereo);
    expect(eng.starts.single.file, endsWith('.wav'));
    await calls.stopRecording(cid);
    await flush(tester, e);
    await calls.hangup(cid);
    await flush(tester, e);

    final recs = c.read(recordingsProvider);
    expect(recs, hasLength(1));
    expect(recs.single.format, 'wavStereo');
    expect(recs.single.bytes, greaterThan(0));
    expect(recs.single.outgoing, isTrue);
    expect(recs.single.remote, '2002');
    final h = c.read(historyProvider).single;
    expect(h.recordingId, recs.single.id);
    expect(h.recordingPath, recs.single.path);
    expect(recs.single.callRecordId, h.id);
    expect(recordingForCall(recs, h)?.id, recs.single.id);
    await flush(tester, e);
  });

  testWidgets('opus format uses an .ogg file and is kept in the library', (tester) async {
    final e = await env(settings: {'recordFormat': 'opus'});
    await pumpApp(tester, e);
    await waitRegistered(tester, e);
    final c = containerOf(tester);
    final calls = c.read(callsProvider.notifier);
    final cid = (await calls.dial('2002'))!;
    await flush(tester, e);
    await calls.startRecording(cid);
    await flush(tester, e);
    final eng = e.engine as RecEng;
    expect(eng.starts.single.format, RecordFormat.opus);
    expect(eng.starts.single.file, endsWith('.ogg'));
    await calls.stopRecording(cid);
    await calls.hangup(cid);
    await flush(tester, e);
    expect(c.read(recordingsProvider).single.format, 'opus');
    await flush(tester, e);
  });

  testWidgets('a call that ends while recording still lands in the library', (tester) async {
    final e = await env(settings: {'recordRule': 'all'});
    await pumpApp(tester, e);
    await waitRegistered(tester, e);
    final c = containerOf(tester);
    final calls = c.read(callsProvider.notifier);
    final cid = (await calls.dial('2002'))!;
    await flush(tester, e);
    expect((e.engine as RecEng).starts, hasLength(1), reason: 'auto-record on connect');
    await calls.hangup(cid);
    await flush(tester, e);
    final recs = c.read(recordingsProvider);
    expect(recs, hasLength(1));
    expect(c.read(historyProvider).single.recordingId, recs.single.id);
    await flush(tester, e);
  });

  testWidgets('rule "incoming only": incoming recorded, outgoing not', (tester) async {
    final e = await env(settings: {'recordRule': 'incoming'});
    await pumpApp(tester, e);
    await waitRegistered(tester, e);
    final c = containerOf(tester);
    final calls = c.read(callsProvider.notifier);
    final eng = e.engine as RecEng;
    final out = (await calls.dial('2002'))!;
    await flush(tester, e);
    expect(eng.starts, isEmpty);
    await calls.hangup(out);
    await flush(tester, e);
    final inc = e.engine.simulateIncomingCall(from: 'sip:3003@pbx.test');
    await flush(tester, e);
    await calls.answer(inc.cid);
    await flush(tester, e);
    expect(eng.starts, hasLength(1));
    expect(eng.starts.single.cid, inc.cid);
    await calls.hangup(inc.cid);
    await flush(tester, e);
  });

  testWidgets('contact "always record" records even with the rule off', (tester) async {
    final e = await env(
      settings: {'recordRule': 'off'},
      contacts: [
        const Contact(id: 'c1', name: 'Dana', numbers: [ContactNumber(label: 'work', value: '3003')], autoRecord: true),
      ],
    );
    await pumpApp(tester, e);
    await waitRegistered(tester, e);
    final calls = containerOf(tester).read(callsProvider.notifier);
    final eng = e.engine as RecEng;
    final other = (await calls.dial('2002'))!;
    await flush(tester, e);
    expect(eng.starts, isEmpty);
    await calls.hangup(other);
    await flush(tester, e);
    final cid = (await calls.dial('3003'))!;
    await flush(tester, e);
    expect(eng.starts.single.cid, cid);
    await calls.hangup(cid);
    await flush(tester, e);
  });

  testWidgets('attended transfer: the consultation call is recorded too and linked', (tester) async {
    final e = await env();
    await pumpApp(tester, e);
    await waitRegistered(tester, e);
    final c = containerOf(tester);
    final calls = c.read(callsProvider.notifier);
    final eng = e.engine as RecEng;
    final a = (await calls.dial('2002'))!;
    await flush(tester, e);
    await calls.startRecording(a);
    await flush(tester, e);
    final b = (await calls.startConsult(a, '3003'))!;
    await flush(tester, e);
    expect(eng.starts.map((s) => s.cid), [a, b], reason: 'consult leg recorded automatically');
    final idA = c.read(callsProvider.notifier).rawCall(a)!.recordingId!;
    final idB = c.read(callsProvider.notifier).rawCall(b)!.recordingId!;
    await calls.completeAttended(b);
    await flush(tester, e);
    await flush(tester, e);
    await calls.hangupAll();
    await flush(tester, e);
    await flush(tester, e);

    final recs = c.read(recordingsProvider);
    expect(recs.map((r) => r.id), containsAll([idA, idB]));
    expect(recs.firstWhere((r) => r.id == idA).relatedIds, contains(idB));
    expect(recs.firstWhere((r) => r.id == idB).relatedIds, contains(idA));
    final hist = c.read(historyProvider);
    final hA = hist.firstWhere((r) => r.recordingId == idA);
    final hB = hist.firstWhere((r) => r.recordingId == idB);
    expect(hA.relatedRecordingIds, contains(idB));
    expect(hB.relatedRecordingIds, contains(idA));
  });

  testWidgets('"continue recording through transfers" off: consult leg is not recorded', (tester) async {
    final e = await env(settings: {'recordContinueTransfers': false});
    await pumpApp(tester, e);
    await waitRegistered(tester, e);
    final calls = containerOf(tester).read(callsProvider.notifier);
    final eng = e.engine as RecEng;
    final a = (await calls.dial('2002'))!;
    await flush(tester, e);
    await calls.startRecording(a);
    await flush(tester, e);
    await calls.startConsult(a, '3003');
    await flush(tester, e);
    expect(eng.starts.map((s) => s.cid), [a]);
    await calls.hangupAll();
    await flush(tester, e);
  });

  testWidgets('a call spawned by an incoming REFER keeps recording the relay', (tester) async {
    final e = await env();
    await pumpApp(tester, e);
    await waitRegistered(tester, e);
    final c = containerOf(tester);
    final calls = c.read(callsProvider.notifier);
    final eng = e.engine as RecEng;
    final a = (await calls.dial('2002'))!;
    await flush(tester, e);
    await calls.startRecording(a);
    await flush(tester, e);
    final n = eng.simulateTransferRequest(a, 'sip:4004@pbx.test');
    await flush(tester, e);
    expect(eng.starts.map((s) => s.cid), contains(n.cid));
    final nCall = calls.rawCall(n.cid)!;
    expect(nCall.linkedRecordingIds, contains(calls.rawCall(a)?.recordingId ?? nCall.linkedRecordingIds.first));
    await calls.hangupAll();
    await flush(tester, e);
  });

  test('retention deletes recordings older than N days and clears history links', () async {
    final tmp = Directory.systemTemp.createTempSync('rec_ret');
    addTearDown(() => tmp.deleteSync(recursive: true));
    File('${tmp.path}/old.wav').writeAsBytesSync([1, 2, 3]);
    File('${tmp.path}/new.wav').writeAsBytesSync([1, 2, 3]);
    final env0 = await TestEnv.create(settings: const AppSettings({'recordAutoDeleteDays': 30}));
    final container = ProviderContainer(overrides: env0.overrides);
    addTearDown(container.dispose);
    final ctl = container.read(recordingsProvider.notifier);
    await Future<void>.delayed(const Duration(milliseconds: 50));
    final now = DateTime.now();
    await ctl.add(RecordingMeta(id: 'old', path: '${tmp.path}/old.wav', remote: '1', time: now.subtract(const Duration(days: 45)), callRecordId: 'h1'));
    await ctl.add(RecordingMeta(id: 'new', path: '${tmp.path}/new.wav', remote: '2', time: now.subtract(const Duration(days: 3))));
    await container.read(historyProvider.notifier).add(
      CallRecord(
        id: 'h1',
        accountId: 'a',
        direction: CallDirection.outgoing,
        remoteUri: 'sip:1@x',
        remoteNumber: '1',
        remoteDisplay: '',
        start: now,
        recordingPath: '${tmp.path}/old.wav',
        recordingId: 'old',
      ),
    );
    expect(await ctl.applyRetention(), 1);
    expect(container.read(recordingsProvider).map((r) => r.id), ['new']);
    expect(File('${tmp.path}/old.wav').existsSync(), isFalse);
    expect(File('${tmp.path}/new.wav').existsSync(), isTrue);
    final h = container.read(historyProvider).single;
    expect(h.recordingPath, isNull);
    expect(h.recordingId, isNull);
    expect(container.read(settingsProvider).recordAutoDeleteDays, 30);
  });
}
