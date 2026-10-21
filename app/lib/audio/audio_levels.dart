import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' show FrameTiming;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/calls_controller.dart';
import 'audio_platform.dart';
import '../services/engine_controller.dart';
import '../services/settings_controller.dart';
import 'echo_test.dart';
import 'mic_recorder.dart';
import 'monitor_state.dart';
import 'musicbed.dart';

/// One smoothed meter: fast attack, ~300 ms release and a peak-hold marker.
/// Pure math (no clock): [step] is fed the time since the previous sample.
/// Notifies (for repaint) only when [level] or [peak] actually changed, so a
/// silent meter costs nothing.
class MeterChannel extends ChangeNotifier {
  /// Time for a full-scale meter to fall to zero.
  static const releaseMs = 300.0;

  /// Time constant of the rise towards a louder sample.
  static const attackMs = 25.0;

  /// How long the peak marker stays put before it falls.
  static const peakHoldMs = 700.0;

  /// Time for the falling peak marker to cross the full scale.
  static const peakFallMs = 600.0;

  /// Smoothed level, 0-1.
  double level = 0;

  /// Peak-hold marker, 0-1 (always >= [level]).
  double peak = 0;
  double _held = 0;

  /// Finest bar resolution the painter draws (its maximum segment count).
  /// Listeners are only notified when the lit segment of the level or of the
  /// peak (at this resolution) changes, so a flickering signal does not
  /// repaint more often than the picture can actually change.
  static const resolution = 64;
  int _shownLevel = 0, _shownPeak = 0;

  /// Advances by [dtMs] with the raw 0-255 engine sample [raw].
  /// Returns true when [level] or [peak] changed.
  bool step(int raw, double dtMs) {
    final target = (raw / 255).clamp(0.0, 1.0);
    final l0 = level, p0 = peak;
    if (target > level) {
      level += (target - level) * (1 - math.exp(-dtMs / attackMs));
      if (target - level < 0.002) level = target;
    } else {
      level = (level - dtMs / releaseMs).clamp(target, 1.0);
    }
    if (level >= peak) {
      peak = level;
      _held = 0;
    } else {
      _held += dtMs;
      if (_held > peakHoldMs) {
        peak = (peak - dtMs / peakFallMs).clamp(level, 1.0);
      }
    }
    final changed = level != l0 || peak != p0;
    _notifyIfVisible();
    return changed;
  }

  void _notifyIfVisible() {
    final l = (level * resolution).ceil(), p = (peak * resolution).ceil();
    if (l == _shownLevel && p == _shownPeak) return;
    _shownLevel = l;
    _shownPeak = p;
    notifyListeners();
  }

  void reset() {
    level = peak = _held = 0;
    _notifyIfVisible();
  }
}

/// Microphone, speaker, musicbed and "sent to callers" meters. Each channel
/// notifies its own painter; the object itself never changes.
class AudioMeters {
  final mic = MeterChannel();
  final speaker = MeterChannel();
  final musicbed = MeterChannel();

  /// The mix sent to callers (microphone plus musicbed); only moves while the
  /// live monitor runs.
  final send = MeterChannel();

  /// Feeds one `media.levels` sample taken [dtMs] after the previous one.
  void update(int micRaw, int speakerRaw, int bedRaw, double dtMs, {int sendRaw = 0}) {
    mic.step(micRaw, dtMs);
    speaker.step(speakerRaw, dtMs);
    musicbed.step(bedRaw, dtMs);
    send.step(sendRaw, dtMs);
  }

  void clear() {
    mic.reset();
    speaker.reset();
    musicbed.reset();
    send.reset();
  }
}

/// Screens that run an audio test (level meter, echo test, recording) raise
/// this while active, which switches metering to the fast rate.
class MeterBoost extends Notifier<int> {
  @override
  int build() => 0;
  void hold() => state++;
  void release() {
    if (state > 0) state--;
  }
}

final meterBoostProvider = NotifierProvider<MeterBoost, int>(MeterBoost.new);

/// Holds the meter boost for as long as the state is mounted. Hold and
/// release are paired through one flag, so a state that is disposed before
/// its deferred hold ran never releases another holder's count.
mixin MeterBoostHolder<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  late final MeterBoost _boostCtl;
  bool _boostHeld = false;

  @override
  void initState() {
    super.initState();
    _boostCtl = ref.read(meterBoostProvider.notifier);
    Future.microtask(() {
      if (mounted && !_boostHeld) {
        _boostHeld = true;
        _boostCtl.hold();
      }
    });
  }

  @override
  void dispose() {
    if (_boostHeld) {
      _boostHeld = false;
      // Providers must not change during dispose (the tree is being torn down).
      Future.microtask(() {
        try {
          _boostCtl.release();
        } catch (_) {
          // The whole container is gone (app or test teardown): nothing to release.
        }
      });
    }
    super.dispose();
  }
}

/// Polling period while audio flows (~15 Hz).
const kMeterPollEvery = Duration(milliseconds: 66);

/// Polling period at idle: the meters are visible but nothing is playing.
const kMeterIdleEvery = Duration(seconds: 1);

/// Polling period while audio flows when frames are expensive to draw
/// (software rendering: a VM, a remote desktop, no GPU driver): ~5 Hz.
const kMeterLowPowerEvery = Duration(milliseconds: 200);

/// The same, when only the idle live monitor runs (no call, test or
/// recording): ~2 Hz, so an idle window doesn't cost a share of a core.
const kMeterLowPowerIdleEvery = Duration(milliseconds: 500);

/// Linux: whether Mesa draws in software (llvmpipe / softpipe worker threads
/// in this process; their GPU work never shows in Flutter's raster times).
bool linuxSoftwareGl({String tasks = '/proc/self/task'}) {
  try {
    for (final t in Directory(tasks).listSync()) {
      final name = File('${t.path}/comm').readAsStringSync().trim();
      if (name.startsWith('llvmpipe') || name.startsWith('softpipe')) {
        return true;
      }
    }
  } catch (_) {}
  return false;
}

/// Tells from recent frame raster times whether drawing is expensive. Slow
/// when the median of the last [window] frames exceeds [threshold]; fast again
/// below half of it (hysteresis, so the rate doesn't flap).
class RasterCostMonitor {
  RasterCostMonitor({
    this.threshold = const Duration(milliseconds: 12),
    this.window = 30,
  });

  final Duration threshold;
  final int window;
  final _us = <int>[];
  bool slow = false;

  /// Adds raster durations; returns true when [slow] changed.
  bool add(Iterable<Duration> raster) {
    for (final d in raster) {
      _us.add(d.inMicroseconds);
    }
    if (_us.length > window) _us.removeRange(0, _us.length - window);
    if (_us.length < window ~/ 3) return false;
    final median = ([..._us]..sort())[_us.length ~/ 2];
    final limit = slow
        ? threshold.inMicroseconds ~/ 2
        : threshold.inMicroseconds;
    final now = median > limit;
    if (now == slow) return false;
    slow = now;
    return true;
  }
}

/// Smoothed meters from `media.levels`, polled only while something watches
/// this provider and the app is in the foreground: at ~15 Hz while audio
/// flows (a live call, the musicbed monitor, a mic test or recording) and at
/// 1 Hz otherwise. A stopped engine or a failing request reads as silence;
/// the provider never throws.
///
/// While watched in the foreground it also asks the engine to keep the sound
/// device open (`media.monitor`), without which the meters read zero outside
/// calls. On a phone or tablet that happens only while a screen that tests the
/// audio holds the [meterBoostProvider] (the microphone indicator would
/// otherwise stay on); never on iOS, which has no device outside a call.
///
/// Widgets `ref.watch` it once (it never changes identity) and give a channel
/// to a [LevelMeter], which repaints only when that channel's value moves.
final audioLevelsProvider = Provider.autoDispose<AudioMeters>((ref) {
  final meters = AudioMeters();
  var busy = false;
  Timer? timer;
  var period = kMeterIdleEvery;
  // Timers belong to the zone the provider was built in, whoever triggers a sync.
  final zone = Zone.current;

  // Cached: Riverpod forbids `ref.read` inside onCancel / onResume.
  var inCall = ref.read(callsProvider).live.isNotEmpty;
  var bedActive = ref.read(musicbedProvider).active;
  var monitor = ref.read(settingsProvider).musicbedMonitor;
  var echo = ref.read(echoTestProvider).on;
  var recording = ref.read(micRecorderProvider).recording;
  var boost = ref.read(meterBoostProvider);
  var engineRunning = ref.read(engineProvider).running;
  var generation = ref.read(engineProvider).generation;
  // iOS has no audio device outside a call: the monitor plays nowhere then.
  final ios = ref.read(isIosProvider);
  final mobile = ref.read(audioMobileProvider);
  final engineCtl = ref.read(engineProvider.notifier);
  final monitorState = ref.read(audioMonitorStateProvider.notifier);
  var monitorOn = false;
  bool active() => inCall || (bedActive && monitor && !ios) || echo || recording || boost > 0;
  bool flowing() => active() || monitorOn;
  // Animated meters cost a full-window redraw per update: slow down when
  // frames are expensive (software rendering).
  final raster = RasterCostMonitor();
  // Checked once the GL context exists (the meters are built after the first frame).
  final softwareGl = !kIsWeb && Platform.isLinux && linuxSoftwareGl();

  Future<void> poll() async {
    if (busy) return;
    busy = true;
    final dt = period.inMilliseconds.toDouble();
    var mic = 0, spk = 0, bed = 0, send = 0;
    try {
      final ctl = ref.read(engineProvider.notifier);
      if (ctl.hasEngine) {
        final l = await ctl.engine.levels();
        mic = l.mic;
        spk = l.speaker;
        bed = l.musicbed;
        send = l.send;
      }
    } catch (_) {}
    busy = false;
    if (timer != null && ref.mounted) meters.update(mic, spk, bed, dt, sendRaw: send);
  }

  // Polls only while someone listens (the last listener leaving cancels the
  // timer at once, before Riverpod gets to dispose the provider) and while
  // the app is in the foreground.
  var listened = true;
  var foreground = true;

  // The live monitor: asked for only while the meters are watched in the
  // foreground; re-asked after an engine restart (a new engine starts with the
  // monitor off). Requests run one after the other so the last one wins.
  var applied = false;
  var appliedGen = generation;
  var monChain = Future<void>.value();
  void syncMonitor() {
    if (generation != appliedGen) {
      appliedGen = generation;
      applied = false;
    }
    final want = listened && foreground && engineRunning && !ios && (!mobile || boost > 0);
    monitorOn = want;
    if (want == applied) return;
    applied = want;
    monChain = monChain.then((_) async {
      try {
        if (!engineCtl.hasEngine) {
          applied = false;
          if (!want) monitorState.set(null);
          return;
        }
        final r = await engineCtl.engine.setMonitor(want);
        monitorState.set(want ? r : null);
      } catch (_) {
        // Retried at the next trigger (a state change or an engine restart).
        applied = !want;
      }
    });
  }

  void sync() {
    syncMonitor();
    if (!(listened && foreground)) {
      timer?.cancel();
      timer = null;
      if (!foreground) meters.clear();
      return;
    }
    final want = !flowing()
        ? kMeterIdleEvery
        : !(raster.slow || softwareGl)
        ? kMeterPollEvery
        : active()
        ? kMeterLowPowerEvery
        : kMeterLowPowerIdleEvery;
    if (timer != null && want == period) return;
    timer?.cancel();
    period = want;
    timer = zone.run(() => Timer.periodic(period, (_) => unawaited(poll())));
  }

  void onTimings(List<FrameTiming> timings) {
    if (raster.add(timings.map((t) => t.rasterDuration))) sync();
  }

  ref.listen(callsProvider.select((c) => c.live.isNotEmpty), (_, v) {
    inCall = v;
    sync();
  });
  ref.listen(musicbedProvider.select((m) => m.active), (_, v) {
    bedActive = v;
    sync();
  });
  ref.listen(settingsProvider.select((s) => s.musicbedMonitor), (_, v) {
    monitor = v;
    sync();
  });
  ref.listen(engineProvider.select((e) => (e.running, e.generation)), (_, v) {
    engineRunning = v.$1;
    generation = v.$2;
    if (!engineRunning) monitorState.set(null);
    sync();
  });
  ref.listen(echoTestProvider.select((v) => v.on), (_, v) {
    echo = v;
    sync();
  });
  ref.listen(micRecorderProvider.select((r) => r.recording), (_, v) {
    recording = v;
    sync();
  });
  ref.listen(meterBoostProvider, (_, v) {
    boost = v;
    sync();
  });

  ref.onCancel(() {
    listened = false;
    sync();
  });
  ref.onResume(() {
    listened = true;
    sync();
  });

  // `inactive` is transient (focus loss, iOS control centre): keep metering.
  final observer = _LifecycleObserver((state) {
    foreground = switch (state) {
      AppLifecycleState.resumed || AppLifecycleState.inactive => true,
      AppLifecycleState.hidden ||
      AppLifecycleState.paused ||
      AppLifecycleState.detached => false,
    };
    sync();
  });
  final binding = WidgetsBinding.instance;
  binding.addObserver(observer);
  binding.addTimingsCallback(onTimings);
  final st = binding.lifecycleState;
  foreground =
      st == null ||
      st == AppLifecycleState.resumed ||
      st == AppLifecycleState.inactive;
  sync();

  ref.onDispose(() {
    binding.removeObserver(observer);
    binding.removeTimingsCallback(onTimings);
    timer?.cancel();
    timer = null;
    if (applied) {
      applied = false;
      try {
        if (engineCtl.hasEngine) {
          unawaited(engineCtl.engine.setMonitor(false).then((_) {}, onError: (_) {}));
        }
      } catch (_) {}
      Future.microtask(() {
        try {
          monitorState.set(null);
        } catch (_) {}
      });
    }
  });
  return meters;
});

class _LifecycleObserver with WidgetsBindingObserver {
  _LifecycleObserver(this.onChange);
  final void Function(AppLifecycleState) onChange;
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) => onChange(state);
}
