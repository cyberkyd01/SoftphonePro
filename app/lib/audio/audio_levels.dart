import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/calls_controller.dart';
import '../services/engine_controller.dart';
import '../services/settings_controller.dart';
import 'mic_recorder.dart';
import 'musicbed.dart';
import 'voice_isolation.dart';

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
    if (changed) notifyListeners();
    return changed;
  }

  void reset() {
    final changed = level != 0 || peak != 0;
    level = peak = _held = 0;
    if (changed) notifyListeners();
  }
}

/// Microphone, speaker and musicbed meters. Each channel notifies its own
/// painter; the object itself never changes.
class AudioMeters {
  final mic = MeterChannel();
  final speaker = MeterChannel();
  final musicbed = MeterChannel();

  /// Feeds one `media.levels` sample taken [dtMs] after the previous one.
  void update(int micRaw, int speakerRaw, int bedRaw, double dtMs) {
    mic.step(micRaw, dtMs);
    speaker.step(speakerRaw, dtMs);
    musicbed.step(bedRaw, dtMs);
  }

  void clear() {
    mic.reset();
    speaker.reset();
    musicbed.reset();
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

/// Polling period while audio flows (~15 Hz).
const kMeterPollEvery = Duration(milliseconds: 66);

/// Polling period at idle: the meters are visible but nothing is playing.
const kMeterIdleEvery = Duration(seconds: 1);

/// Smoothed meters from `media.levels`, polled only while something watches
/// this provider and the app is in the foreground: at ~15 Hz while audio
/// flows (a live call, the musicbed monitor, a mic test or recording) and at
/// 1 Hz otherwise. A stopped engine or a failing request reads as silence;
/// the provider never throws.
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
  var echo = ref.read(voiceIsolationProvider).echoTest;
  var recording = ref.read(micRecorderProvider).recording;
  var boost = ref.read(meterBoostProvider);
  bool flowing() => inCall || (bedActive && monitor) || echo || recording || boost > 0;

  Future<void> poll() async {
    if (busy) return;
    busy = true;
    final dt = period.inMilliseconds.toDouble();
    var mic = 0, spk = 0, bed = 0;
    try {
      final ctl = ref.read(engineProvider.notifier);
      if (ctl.hasEngine) {
        final l = await ctl.engine.levels();
        mic = l.mic;
        spk = l.speaker;
        bed = l.musicbed;
      }
    } catch (_) {}
    busy = false;
    if (timer != null && ref.mounted) meters.update(mic, spk, bed, dt);
  }

  // Polls only while someone listens (the last listener leaving cancels the
  // timer at once, before Riverpod gets to dispose the provider) and while
  // the app is in the foreground.
  var listened = true;
  var foreground = true;
  void sync() {
    if (!(listened && foreground)) {
      timer?.cancel();
      timer = null;
      if (!foreground) meters.clear();
      return;
    }
    final want = flowing() ? kMeterPollEvery : kMeterIdleEvery;
    if (timer != null && want == period) return;
    timer?.cancel();
    period = want;
    timer = zone.run(() => Timer.periodic(period, (_) => unawaited(poll())));
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
  ref.listen(voiceIsolationProvider.select((v) => v.echoTest), (_, v) {
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
      AppLifecycleState.hidden || AppLifecycleState.paused || AppLifecycleState.detached => false,
    };
    sync();
  });
  final binding = WidgetsBinding.instance;
  binding.addObserver(observer);
  final st = binding.lifecycleState;
  foreground = st == null || st == AppLifecycleState.resumed || st == AppLifecycleState.inactive;
  sync();

  ref.onDispose(() {
    binding.removeObserver(observer);
    timer?.cancel();
    timer = null;
  });
  return meters;
});

class _LifecycleObserver with WidgetsBindingObserver {
  _LifecycleObserver(this.onChange);
  final void Function(AppLifecycleState) onChange;
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) => onChange(state);
}
