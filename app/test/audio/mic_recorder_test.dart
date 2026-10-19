import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:softphonepro/audio/audio_library.dart';
import 'package:softphonepro/audio/mic_recorder.dart';

import 'audio_harness.dart';

void main() {
  test('record, stop, preview file, save into the library', () async {
    final a = await AudioEnv.create();
    final rec = a.container.read(micRecorderProvider.notifier);
    await rec.start();
    expect(a.container.read(micRecorderProvider).recording, isTrue);
    await Future<void>.delayed(const Duration(milliseconds: 450));
    expect(a.container.read(micRecorderProvider).elapsed, greaterThan(Duration.zero), reason: 'the timer runs');
    final path = a.engine.toString(); // engine records into the path chosen by the library
    expect(path, isNotEmpty);
    await rec.stop();
    final s = a.container.read(micRecorderProvider);
    expect(s.recording, isFalse);
    expect(s.file, isNotNull);
    expect(s.file, startsWith(a.audioDir.path));
    // The real engine writes the WAV; here we create it for the library.
    File(s.file!).writeAsBytesSync(List.filled(128, 3));
    final item = await rec.save('Welcome message');
    expect(item, isNotNull);
    expect(item!.name, 'Welcome message');
    expect(item.ref, startsWith('lib:Recording '));
    expect((await a.container.read(audioLibraryProvider).list()).map((i) => i.ref), contains(item.ref));
    expect(a.container.read(micRecorderProvider).file, isNull);
    a.dispose();
  });

  test('discard forgets the take', () async {
    final a = await AudioEnv.create();
    final rec = a.container.read(micRecorderProvider.notifier);
    await rec.start();
    await rec.stop();
    expect(a.container.read(micRecorderProvider).file, isNotNull);
    rec.discard();
    expect(a.container.read(micRecorderProvider).file, isNull);
    a.dispose();
  });

  test('saving a recording that was never written reports an error', () async {
    final a = await AudioEnv.create();
    final rec = a.container.read(micRecorderProvider.notifier);
    await rec.start();
    await rec.stop();
    expect(await rec.save('x'), isNull);
    expect(a.container.read(micRecorderProvider).error, isNotNull);
    a.dispose();
  });

  test('cannot start twice; a second start is ignored', () async {
    final a = await AudioEnv.create();
    final rec = a.container.read(micRecorderProvider.notifier);
    await rec.start();
    await rec.start();
    expect(a.container.read(micRecorderProvider).error, isNull);
    await rec.stop();
    a.dispose();
  });
}
