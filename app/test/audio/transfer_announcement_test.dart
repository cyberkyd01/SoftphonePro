import 'package:flutter_test/flutter_test.dart';
import 'package:softphonepro/audio/announcement_service.dart';
import 'package:softphonepro/services/calls_controller.dart';

import 'audio_harness.dart';

void main() {
  test('blind transfer: playFile -> playDone -> transfer, in that order', () async {
    final a = await AudioEnv.create(settings: {'transferNoticeFile': 'builtin:chime'});
    final cid = await a.dialConfirmed();
    final f = a.calls.transferBlind(cid, '3003');
    await a.until(() => a.engine.plays.isNotEmpty);
    expect(a.engine.plays.single.cid, cid, reason: 'played to the party being transferred');
    expect(a.engine.plays.single.muteMic, isTrue);
    await Future<void>.delayed(const Duration(milliseconds: 30));
    expect(a.engine.log, ['playFile'], reason: 'the transfer waits for the announcement');
    await a.flush(); // playback reaches its end
    expect(await f, isTrue);
    expect(a.engine.log, ['playFile', 'transfer']);
    a.dispose();
  });

  test('Skip ends the announcement and the transfer still happens', () async {
    final a = await AudioEnv.create(settings: {'transferNoticeFile': 'builtin:chime'});
    final cid = await a.dialConfirmed();
    final f = a.calls.transferBlind(cid, '3003');
    await a.until(() => a.container.read(activeAnnouncementsProvider).containsKey(cid));
    expect(a.container.read(activeAnnouncementsProvider)[cid]!.kind, AnnouncementKind.transfer);
    await a.container.read(announcementServiceProvider).skip(cid);
    expect(await f, isTrue);
    expect(a.engine.log, ['playFile', 'stopFile', 'transfer']);
    a.dispose();
  });

  test('timeout path: stops the playback after 15 s (shortened here) and transfers', () async {
    final a = await AudioEnv.create(settings: {'transferNoticeFile': 'builtin:chime'});
    a.container.read(announcementServiceProvider).maxWait = const Duration(milliseconds: 100);
    final cid = await a.dialConfirmed();
    expect(await a.calls.transferBlind(cid, '3003'), isTrue);
    expect(a.engine.log, ['playFile', 'stopFile', 'transfer']);
    a.dispose();
  });

  test('default maximum wait is 15 seconds', () async {
    final a = await AudioEnv.create();
    expect(a.container.read(announcementServiceProvider).maxWait, const Duration(seconds: 15));
    a.dispose();
  });

  test('no notice configured: transfers immediately', () async {
    final a = await AudioEnv.create();
    final cid = await a.dialConfirmed();
    expect(await a.calls.transferBlind(cid, '3003'), isTrue);
    expect(a.engine.log, ['transfer']);
    a.dispose();
  });

  test('a notice that cannot be played does not block the transfer', () async {
    final a = await AudioEnv.create(engine: LogEngine(unsupportedFiles: true), settings: {'transferNoticeFile': 'builtin:chime'});
    final cid = await a.dialConfirmed();
    expect(await a.calls.transferBlind(cid, '3003'), isTrue);
    expect(a.engine.log, ['transfer']);
    a.dispose();
  });

  test('attended transfer plays the notice to the original caller before completing', () async {
    final a = await AudioEnv.create(settings: {'transferNoticeFile': 'builtin:chime'});
    final orig = await a.dialConfirmed();
    final consult = await a.calls.startConsult(orig, '3003');
    expect(consult, isNotNull);
    await a.until(() => a.container.read(callsProvider).byCid(consult!)?.isConfirmed ?? false);
    a.engine.log.clear();
    final f = a.calls.completeAttended(consult!);
    await a.until(() => a.engine.plays.isNotEmpty);
    expect(a.engine.plays.single.cid, orig);
    expect(a.engine.log, ['playFile']);
    await a.flush();
    expect(await f, isTrue);
    expect(a.engine.log, ['playFile', 'transferAttended']);
    a.dispose();
  });
}
