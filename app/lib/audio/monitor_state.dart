import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spcore_dart/spcore_dart.dart';

/// The engine's last report of the live monitor (`media.monitor`): whether the
/// sound device is open and whether it is a real device or the silent
/// fallback. Null while the monitor is off or nothing was reported yet.
class AudioMonitorState extends Notifier<MonitorState?> {
  @override
  MonitorState? build() => null;

  // Equal reports are dropped so listeners are not rebuilt for nothing.
  void set(MonitorState? v) {
    if (state != v) state = v;
  }
}

final audioMonitorStateProvider = NotifierProvider<AudioMonitorState, MonitorState?>(AudioMonitorState.new);
