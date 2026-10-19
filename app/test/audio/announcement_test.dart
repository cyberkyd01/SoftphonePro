import 'package:flutter_test/flutter_test.dart';
import 'package:softphonepro/audio/announcement_service.dart';
import 'package:softphonepro/models/call_record.dart';
import 'package:softphonepro/services/accounts_controller.dart';
import 'package:softphonepro/services/calls_controller.dart';

import '../harness.dart';
import 'audio_harness.dart';

const _on = {'announceOpening': true, 'announceOpeningFile': 'builtin:chime'};

Future<void> settleShort(AudioEnv a) => Future<void>.delayed(const Duration(milliseconds: 40));

void main() {
  group('opening announcement', () {
    test('plays once when an outgoing call connects, muting the mic', () async {
      final a = await AudioEnv.create(settings: _on);
      final cid = await a.dialConfirmed();
      await a.until(() => a.engine.plays.isNotEmpty);
      expect(a.engine.plays, hasLength(1));
      expect(a.engine.plays.single.cid, cid);
      expect(a.engine.plays.single.file, endsWith('chime.wav'));
      expect(a.engine.plays.single.muteMic, isTrue);
      expect(a.engine.plays.single.monitor, isFalse);
      a.dispose();
    });

    test('mute and monitor options are passed to playFile', () async {
      final a = await AudioEnv.create(settings: {..._on, 'announceMuteMic': false, 'announceMonitor': true});
      await a.dialConfirmed();
      await a.until(() => a.engine.plays.isNotEmpty);
      expect(a.engine.plays.single.muteMic, isFalse);
      expect(a.engine.plays.single.monitor, isTrue);
      a.dispose();
    });

    test('disabled setting plays nothing', () async {
      final a = await AudioEnv.create(settings: {'announceOpening': false, 'announceOpeningFile': 'builtin:chime'});
      await a.dialConfirmed();
      await settleShort(a);
      expect(a.engine.plays, isEmpty);
      a.dispose();
    });

    test('direction: incoming only skips outgoing calls and vice versa', () async {
      final a = await AudioEnv.create(settings: {..._on, 'announceDirection': 'incoming'});
      await a.dialConfirmed();
      await settleShort(a);
      expect(a.engine.plays, isEmpty, reason: 'outgoing call, incoming-only setting');
      await a.calls.hangupAll();
      await a.until(() => a.container.read(callsProvider).ongoing.isEmpty);
      final cid = await a.incomingConfirmed();
      await a.until(() => a.engine.plays.isNotEmpty);
      expect(a.engine.plays.single.cid, cid);
      a.dispose();

      final b = await AudioEnv.create(settings: {..._on, 'announceDirection': 'outgoing'});
      await b.incomingConfirmed();
      await settleShort(b);
      expect(b.engine.plays, isEmpty);
      await b.dialConfirmed('3003');
      await b.until(() => b.engine.plays.isNotEmpty);
      expect(b.engine.plays, hasLength(1));
      b.dispose();
    });

    test('only once per call, even when the trigger fires again (unhold / re-INVITE)', () async {
      final a = await AudioEnv.create(settings: _on);
      final cid = await a.dialConfirmed();
      await a.until(() => a.engine.plays.isNotEmpty);
      await a.flush();
      await a.calls.hold(cid);
      await a.calls.unhold(cid);
      await a.flush();
      await a.container.read(announcementServiceProvider).onCallConfirmed(cid: cid, incoming: false, accountId: 'acc1');
      await settleShort(a);
      expect(a.engine.plays, hasLength(1));
      a.dispose();
    });

    test('per-account override: off beats the global setting', () async {
      final a = await AudioEnv.create(settings: _on);
      await a.container.read(accountsProvider.notifier).update(testProfile().copyWith(openingAnnouncement: 'off'));
      await a.dialConfirmed();
      await settleShort(a);
      expect(a.engine.plays, isEmpty);
      a.dispose();
    });

    test('per-account override: its own file plays even when the global switch is off', () async {
      final a = await AudioEnv.create(settings: {'announceOpening': false});
      await a.container.read(accountsProvider.notifier).update(testProfile().copyWith(openingAnnouncement: 'builtin:hold_calm'));
      await a.dialConfirmed();
      await a.until(() => a.engine.plays.isNotEmpty);
      expect(a.engine.plays.single.file, endsWith('hold_calm.wav'));
      a.dispose();
    });

    test('a missing file or an engine without playFile is ignored', () async {
      final a = await AudioEnv.create(settings: {'announceOpening': true, 'announceOpeningFile': 'lib:gone.wav'});
      await a.dialConfirmed();
      await settleShort(a);
      expect(a.engine.plays, isEmpty);
      a.dispose();
      final b = await AudioEnv.create(engine: LogEngine(unsupportedFiles: true), settings: _on);
      final cid = await b.dialConfirmed();
      await settleShort(b);
      expect(b.container.read(callsProvider).byCid(cid)!.isConfirmed, isTrue);
      expect(b.container.read(activeAnnouncementsProvider), isEmpty);
      b.dispose();
    });

    test('shows an active announcement and Skip stops it', () async {
      final a = await AudioEnv.create(settings: _on);
      final cid = await a.dialConfirmed();
      await a.until(() => a.container.read(activeAnnouncementsProvider).containsKey(cid));
      final play = a.container.read(activeAnnouncementsProvider)[cid]!;
      expect(play.kind, AnnouncementKind.opening);
      await a.container.read(announcementServiceProvider).skip(cid);
      await a.until(() => a.container.read(activeAnnouncementsProvider).isEmpty);
      expect(a.engine.log, contains('stopFile'));
      expect(a.container.read(activeAnnouncementsProvider), isEmpty);
      // The call itself is untouched.
      expect(a.container.read(callsProvider).byCid(cid)!.isConfirmed, isTrue);
      a.dispose();
    });

    test('the chip state clears when the playback finishes by itself', () async {
      final a = await AudioEnv.create(settings: _on);
      final cid = await a.dialConfirmed();
      await a.until(() => a.container.read(activeAnnouncementsProvider).containsKey(cid));
      await a.flush();
      expect(a.container.read(activeAnnouncementsProvider), isEmpty);
      a.dispose();
    });
  });

  group('recording notice', () {
    test('plays the configured file and returns when it is done', () async {
      final a = await AudioEnv.create(settings: {'recordingNoticeFile': 'builtin:chime'});
      final cid = await a.dialConfirmed();
      final svc = a.container.read(announcementServiceProvider);
      var done = false;
      final f = svc.playRecordingNotice(cid).then((_) => done = true);
      await a.until(() => a.engine.plays.isNotEmpty);
      expect(done, isFalse);
      await a.flush();
      await f;
      expect(done, isTrue);
      expect(a.engine.plays.single.muteMic, isTrue);
      a.dispose();
    });

    test('does nothing without a configured file', () async {
      final a = await AudioEnv.create();
      final cid = await a.dialConfirmed();
      await a.container.read(announcementServiceProvider).playRecordingNotice(cid);
      expect(a.engine.plays, isEmpty);
      a.dispose();
    });

    test('gives up after the maximum wait and stops the playback', () async {
      final a = await AudioEnv.create(settings: {'recordingNoticeFile': 'builtin:chime'});
      final cid = await a.dialConfirmed();
      final svc = a.container.read(announcementServiceProvider)..maxWait = const Duration(milliseconds: 80);
      await svc.playRecordingNotice(cid);
      expect(a.engine.log, contains('stopFile'));
      expect(a.container.read(activeAnnouncementsProvider), isEmpty);
      a.dispose();
    });
  });

  test('CallRecord direction enum sanity (used by the trigger)', () {
    expect(CallDirection.values, containsAll([CallDirection.incoming, CallDirection.outgoing]));
  });
}
