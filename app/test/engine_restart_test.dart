import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart' hide EnginePhase;
import 'package:softphonepro/services/engine_controller.dart';
import 'package:softphonepro/services/providers.dart';
import 'package:spcore_dart/spcore_dart.dart';

import 'harness.dart';

/// One native core per process, like libspcore: starting it while it runs
/// fails with "already started", and stopping it takes a moment.
class _Core {
  bool running = false;
}

class _NativeLikeEngine extends FakeSipEngine {
  _NativeLikeEngine(this.core) : super(timings: FakeTimings.instant);
  final _Core core;

  @override
  Future<CoreStartResult> start(CoreConfig config) async {
    if (core.running) {
      throw const EngineException(EngineError(code: ErrorCode.already, message: 'core already started'));
    }
    final r = await super.start(config);
    core.running = true;
    return r;
  }

  @override
  Future<void> stop({bool graceful = true}) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    core.running = false;
    await super.stop(graceful: graceful);
  }
}

void main() {
  testWidgets('concurrent restarts (settings change + LAN listener) share one restart and keep the core running', (t) async {
    await t.runAsync(() async {
      final core = _Core();
      var made = 0;
      final env = await TestEnv.create(
        factory: ({required bool simulator}) async {
          made++;
          return EngineHandle(_NativeLikeEngine(core), demo: false);
        },
      );
      final c = ProviderContainer(overrides: env.overrides);
      addTearDown(c.dispose);
      final ctl = c.read(engineProvider.notifier);
      await ctl.start();
      expect(c.read(engineProvider).phase, EnginePhase.running);

      final first = ctl.restart();
      // Observers (the LAN controller) see the restart while the old core stops.
      expect(c.read(engineProvider).phase, EnginePhase.starting);
      final second = ctl.restart();
      await Future.wait([first, second]);

      expect(c.read(engineProvider).phase, EnginePhase.running, reason: c.read(engineProvider).error ?? '');
      expect(core.running, isTrue);
      expect(made, 2, reason: 'one initial start and one restart');
    });
  });
}
