import 'package:flutter_test/flutter_test.dart';
import 'package:softphonepro/audio/audio_library.dart';
import 'package:softphonepro/services/calls_controller.dart';
import 'package:softphonepro/services/accounts_controller.dart';

import '../harness.dart';
import 'audio_harness.dart';

void main() {
  test('PBX default holds without music', () async {
    final a = await AudioEnv.create();
    final cid = await a.dialConfirmed();
    await a.calls.hold(cid);
    expect(a.engine.holds, [null]);
    expect(a.engine.holdMusicPlaying, isEmpty);
    a.dispose();
  });

  test('a built-in track is passed to engine.hold with loop and volume', () async {
    final a = await AudioEnv.create(settings: {'holdMusic': 'builtin:hold_calm', 'holdMusicVolume': 0.4});
    final cid = await a.dialConfirmed();
    await a.calls.hold(cid);
    final m = a.engine.holds.single!;
    expect(m.file, endsWith('hold_calm.wav'));
    expect(m.loop, isTrue);
    expect(m.volume, closeTo(0.4, 1e-9));
    expect(a.engine.holdMusicPlaying.keys, [cid]);
    // Unhold is plain and stops the music.
    await a.calls.unhold(cid);
    await a.flush();
    expect(a.engine.holdMusicPlaying, isEmpty);
    a.dispose();
  });

  test('a library file is resolved to its path', () async {
    final a = await AudioEnv.create();
    final item = await a.container.read(audioLibraryProvider).import((await a.makeAudio('mine.wav')).path);
    await a.settings.update({'holdMusic': item.ref});
    final cid = await a.dialConfirmed();
    await a.calls.hold(cid);
    expect(a.engine.holds.single!.file, item.path);
    a.dispose();
  });

  test('per-account override wins over the global setting', () async {
    final a = await AudioEnv.create(settings: {'holdMusic': 'builtin:hold_calm'});
    var cid = await a.dialConfirmed();
    await a.container.read(accountsProvider.notifier).update(testProfile().copyWith(holdMusic: 'pbx'));
    await a.calls.hold(cid);
    expect(a.engine.holds.last, isNull, reason: 'account says PBX default');
    await a.calls.unhold(cid);
    await a.container.read(accountsProvider.notifier).update(testProfile().copyWith(holdMusic: 'builtin:hold_breeze'));
    await a.calls.hold(cid);
    expect(a.engine.holds.last!.file, endsWith('hold_breeze.wav'));
    a.dispose();
  });

  test('UNSUPPORTED music falls back to a plain hold', () async {
    final a = await AudioEnv.create(engine: LogEngine(unsupportedHoldMusic: true), settings: {'holdMusic': 'builtin:hold_calm'});
    final cid = await a.dialConfirmed();
    await a.calls.hold(cid);
    await a.flush();
    expect(a.engine.log.where((l) => l.startsWith('hold')), ['hold+music', 'hold']);
    expect(a.container.read(callsProvider).byCid(cid)!.isHeld, isTrue);
    a.dispose();
  });

  test('a missing file holds normally', () async {
    final a = await AudioEnv.create(settings: {'holdMusic': 'lib:gone.wav'});
    final cid = await a.dialConfirmed();
    await a.calls.hold(cid);
    expect(a.engine.holds, [null]);
    a.dispose();
  });
}
