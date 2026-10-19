import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:softphonepro/audio/audio_library.dart';
import 'package:spcore_dart/spcore_dart.dart';

import 'audio_harness.dart';

void main() {
  test('lists the built-in tracks first and resolves them to files', () async {
    final a = await AudioEnv.create();
    final items = await a.container.read(audioLibraryProvider).list();
    expect(items.map((i) => i.ref).take(3), ['builtin:hold_calm', 'builtin:hold_breeze', 'builtin:chime']);
    expect(items.first.builtin, isTrue);
    final lib = a.container.read(audioLibraryProvider);
    expect(await lib.resolve('builtin:hold_calm'), endsWith('hold_calm.wav'));
    expect(await lib.resolve('builtin:nope'), isNull);
    expect(await lib.resolve(''), isNull);
    // The chime is a notice, not hold music.
    expect(items.firstWhere((i) => i.ref == 'builtin:chime').holdMusic, isFalse);
    a.dispose();
  });

  test('import validates through the engine, copies into audio/ and indexes', () async {
    final a = await AudioEnv.create();
    a.engine.fileInfos[(await a.makeAudio('greeting.wav')).path] = const MediaFileInfo(format: 'wav', durationMs: 4200, sampleRate: 8000, channels: 1);
    final src = await a.makeAudio('greeting.wav');
    a.engine.fileInfos[src.path] = const MediaFileInfo(format: 'wav', durationMs: 4200, sampleRate: 8000, channels: 1);
    final lib = a.container.read(audioLibraryProvider);
    final item = await lib.import(src.path);
    expect(item.ref, 'lib:greeting.wav');
    expect(item.name, 'greeting');
    expect(item.durationMs, 4200);
    expect(File('${a.audioDir.path}/greeting.wav').existsSync(), isTrue);
    expect(src.existsSync(), isTrue, reason: 'the original is left alone');
    final idx = jsonDecode(File('${a.audioDir.path}/index.json').readAsStringSync()) as Map;
    expect((idx['greeting.wav'] as Map)['durationMs'], 4200);
    expect((await lib.list()).map((i) => i.ref), contains('lib:greeting.wav'));
    expect(await lib.resolve('lib:greeting.wav'), item.path);
    // Same name again gets a unique file name.
    final again = await lib.import(src.path);
    expect(again.ref, 'lib:greeting-2.wav');
    a.dispose();
  });

  test('import rejects unsupported extensions, missing files and unreadable audio', () async {
    final a = await AudioEnv.create();
    final lib = a.container.read(audioLibraryProvider);
    final txt = await a.makeAudio('notes.txt');
    await expectLater(lib.import(txt.path), throwsA(isA<AudioLibraryException>()));
    await expectLater(lib.import('${a.env.tempDir.path}/missing.wav'), throwsA(isA<AudioLibraryException>()));
    // The engine says the content is not a decodable file.
    final bad = await a.makeAudio('bad.wav');
    a.engine.fileInfos.remove(bad.path);
    final broken = await a.makeAudio('broken.mp3');
    a.engine.fileInfos[broken.path] = const MediaFileInfo();
    await expectLater(lib.import(broken.path), throwsA(isA<AudioLibraryException>()));
    expect(File('${a.audioDir.path}/broken.mp3').existsSync(), isFalse);
    a.dispose();
  });

  test('an engine without media.fileInfo falls back to the extension', () async {
    final eng = _NoFileInfoEngine();
    final a = await AudioEnv.create(engine: eng);
    final f = await a.makeAudio('hello.mp3');
    final item = await a.container.read(audioLibraryProvider).import(f.path);
    expect(item.format, 'mp3');
    a.dispose();
  });

  test('rename changes the display name only; delete removes file and index', () async {
    final a = await AudioEnv.create();
    final lib = a.container.read(audioLibraryProvider);
    final src = await a.makeAudio('music.wav');
    final item = await lib.import(src.path);
    await lib.rename(item.ref, '  Waiting room  ');
    expect((await lib.find(item.ref))!.name, 'Waiting room');
    expect(await lib.nameOf(item.ref), 'Waiting room');
    await lib.rename('builtin:hold_calm', 'Hacked');
    expect((await lib.find('builtin:hold_calm'))!.name, 'Calm (built-in)');
    await lib.delete(item.ref);
    expect(File(item.path!).existsSync(), isFalse);
    expect(await lib.find(item.ref), isNull);
    expect(await lib.resolve(item.ref), isNull);
    final idx = jsonDecode(File('${a.audioDir.path}/index.json').readAsStringSync()) as Map;
    expect(idx.containsKey('music.wav'), isFalse);
    // Built-ins cannot be deleted.
    await lib.delete('builtin:hold_calm');
    expect(await lib.find('builtin:hold_calm'), isNotNull);
    a.dispose();
  });

  test('files dropped into audio/ by hand show up', () async {
    final a = await AudioEnv.create();
    File('${a.audioDir.path}/manual.mp3').writeAsBytesSync([1, 2, 3]);
    final items = await a.container.read(audioLibraryProvider).list();
    expect(items.map((i) => i.ref), contains('lib:manual.mp3'));
    a.dispose();
  });
}

class _NoFileInfoEngine extends LogEngine {
  @override
  Future<MediaFileInfo> fileInfo(String file) =>
      Future.error(const EngineException(EngineError(code: ErrorCode.unsupported, message: 'unknown method')));
}
