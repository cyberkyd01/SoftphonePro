@TestOn('mac-os || linux')
library;

import 'dart:async';
import 'dart:io';

import 'package:spcore_dart/spcore_dart.dart';
import 'package:test/test.dart';

/// Tests FfiSipEngine plumbing (ports, response routing, timeouts, seq gaps,
/// watchdog) against a tiny C stub implementing the spcore ABI.
Future<void> main() async {
  final include =
      '${File(Platform.resolvedExecutable).parent.parent.path}/include';
  final dir = Directory.systemTemp.createTempSync('spc_stub');
  final lib = '${dir.path}/libspcore_stub.${Platform.isMacOS ? 'dylib' : 'so'}';
  String? skip;
  if (!File('$include/dart_api_dl.c').existsSync()) {
    skip = 'dart SDK include dir not found';
  } else {
    final r = await Process.run('cc', [
      '-shared',
      '-fPIC',
      '-o',
      lib,
      'test/ffi/stub_spcore.c',
      '$include/dart_api_dl.c',
      '-I$include',
      '-lpthread',
    ]);
    if (r.exitCode != 0) skip = 'cannot compile stub: ${r.stderr}';
  }

  FfiSipEngine make({Duration? wd}) => FfiSipEngine(
    libraryPath: lib,
    watchdogInterval: wd,
    defaultTimeout: const Duration(seconds: 2),
  );

  test('init, request/response routing and error mapping', () async {
    final e = make();
    await e.init();
    expect(e.library.versionString(), 'stub');
    expect(await e.request('anything', {}), {'echo': 'anything'});
    final results = await Future.wait([
      for (var i = 0; i < 20; i++) e.request('m$i', {}),
    ]);
    expect(
      [for (final r in results) r['echo']],
      [for (var i = 0; i < 20; i++) 'm$i'],
    );
    await expectLater(
      e.request('test.fail', {}),
      throwsA(
        isA<EngineException>()
            .having((x) => x.code, 'code', ErrorCode.pjError)
            .having((x) => x.error.status, 'status', 70004),
      ),
    );
    await e.dispose();
  }, skip: skip);

  test('events precede the response; timeout; dispose fails pending', () async {
    final e = make();
    await e.init();
    final seen = <String>[];
    e.events.listen((ev) => seen.add(ev.name));
    await e.request('test.event', {});
    expect(seen, ['log']);
    await expectLater(
      e.request('test.never', {}, timeout: const Duration(milliseconds: 100)),
      throwsA(
        isA<EngineException>().having((x) => x.code, 'code', ErrorCode.timeout),
      ),
    );
    final pend = e.request('test.never', {});
    final f = expectLater(
      pend,
      throwsA(
        isA<EngineException>().having(
          (x) => x.code,
          'code',
          ErrorCode.disposed,
        ),
      ),
    );
    await e.dispose();
    await f;
    await expectLater(e.request('x', {}), throwsA(isA<EngineException>()));
  }, skip: skip);

  test('seq gap triggers ResyncNeeded + snapshot', () async {
    final e = make();
    await e.init();
    final evs = <EngineEvent>[];
    e.events.listen(evs.add);
    await e.request('test.event', {}); // seq 1
    await e.request('test.gap', {}); // seq 2, then 8
    await Future<void>.delayed(const Duration(milliseconds: 300));
    expect(evs.whereType<ResyncNeededEvent>(), hasLength(1));
    expect(evs.whereType<ResyncSnapshotEvent>(), hasLength(1));
    await e.dispose();
  }, skip: skip);

  test(
    'already-running core (spc_init == 1) resyncs; detach is safe',
    () async {
      final e1 = make();
      await e1.init();
      final e2 =
          make(); // same process/library instance: stub reports already running
      await e2.init();
      expect(e2.attachedToRunningCore, isTrue);
      final snap = await e2.events
          .firstWhere((x) => x is ResyncSnapshotEvent)
          .timeout(const Duration(seconds: 2));
      expect(snap, isA<ResyncSnapshotEvent>());
      await e2.dispose();
      await e1.dispose();
    },
    skip: skip,
  );

  test('watchdog reports unresponsive engine', () async {
    final e = FfiSipEngine(
      libraryPath: lib,
      watchdogInterval: const Duration(milliseconds: 100),
      watchdogTimeout: const Duration(milliseconds: 100),
    );
    await e.init();
    // The stub answers core.ping unless STUB_NO_PING is set; use start() to arm the watchdog,
    // then make pings fail by pointing them at a method that never answers.
    final evs = <EngineEvent>[];
    e.events.listen(evs.add);
    await e.start(const CoreConfig());
    await Future<void>.delayed(const Duration(milliseconds: 350));
    expect(evs.whereType<EngineUnresponsiveEvent>(), isEmpty);
    await e.request('test.mute', {});
    await e.events
        .firstWhere((x) => x is EngineUnresponsiveEvent)
        .timeout(const Duration(seconds: 2));
    await e.request('test.unmute', {});
    await e.events
        .firstWhere((x) => x is EngineResponsiveEvent)
        .timeout(const Duration(seconds: 2));
    await e.dispose();
  }, skip: skip);

  test('library load errors list every attempt', () {
    expect(
      () => SpcoreLibrary.load(path: '/nonexistent/libspcore.dylib'),
      throwsA(isA<StateError>()),
    );
  });

  tearDownAll(() => dir.deleteSync(recursive: true));
}
