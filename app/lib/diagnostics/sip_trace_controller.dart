import 'dart:collection';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spcore_dart/spcore_dart.dart';

import '../services/engine_controller.dart';
import '../services/settings_controller.dart';
import 'sip_message.dart';

const int kTraceMaxMessages = 5000;
const int kTraceMaxBytes = 20 * 1024 * 1024;

/// Notification-only state: widgets watch it and re-read [SipTraceController.messages].
class TraceState {
  const TraceState({this.version = 0, this.count = 0, this.bytes = 0, this.dropped = 0});
  final int version;
  final int count;
  final int bytes;
  final int dropped;
}

/// Ring buffer of parsed SIP messages fed by `sip.trace` engine events.
class SipTraceController extends Notifier<TraceState> {
  final ListQueue<SipMessage> _buf = ListQueue();
  int _bytes = 0;
  int _nextId = 1;
  int _dropped = 0;
  int _version = 0;
  int maxMessages = kTraceMaxMessages;
  int maxBytes = kTraceMaxBytes;

  @override
  TraceState build() {
    final sub = ref.read(engineProvider.notifier).events.listen((e) {
      if (e is SipTraceEvent) ingest(e);
    });
    ref.onDispose(sub.cancel);
    return const TraceState();
  }

  /// Whether capture is switched on (persisted in settings).
  bool get enabled => ref.read(settingsProvider).sipTrace;

  /// Turns capture on/off; the engine controller applies it to `core.setSipTrace`.
  Future<void> setEnabled(bool v) async {
    await ref.read(settingsProvider.notifier).update({'sipTrace': v});
    final c = ref.read(engineProvider.notifier);
    if (c.hasEngine) {
      try {
        await c.engine.setSipTrace(v);
      } catch (_) {}
    }
  }

  /// Snapshot of the buffer, oldest first.
  List<SipMessage> get messages => List.unmodifiable(_buf);
  int get length => _buf.length;

  bool hasCallId(String callId) => callId.isNotEmpty && _buf.any((m) => m.callId == callId);

  /// Test seam and engine entry point. Never throws.
  SipMessage? ingest(SipTraceEvent e) {
    try {
      final m = SipMessage.parse(
        e.msg,
        id: _nextId++,
        time: e.ts > 0 ? DateTime.fromMillisecondsSinceEpoch(e.ts) : DateTime.now(),
        outgoing: e.dir == SipDir.tx,
        transport: e.transport,
        local: e.local,
        remote: e.remote,
        size: e.len > 0 ? e.len : e.msg.length,
      );
      add(m);
      return m;
    } catch (_) {
      return null;
    }
  }

  void add(SipMessage m) {
    _buf.addLast(m);
    _bytes += m.cost;
    while (_buf.length > maxMessages || (_bytes > maxBytes && _buf.length > 1)) {
      _bytes -= _buf.removeFirst().cost;
      _dropped++;
    }
    _notify();
  }

  void clear() {
    _buf.clear();
    _bytes = 0;
    _dropped = 0;
    _version++;
    state = TraceState(version: _version);
  }

  // Riverpod coalesces rebuilds per frame, so no explicit throttling is needed.
  void _notify() => _flush();

  void _flush() {
    _version++;
    state = TraceState(version: _version, count: _buf.length, bytes: _bytes, dropped: _dropped);
  }
}

final sipTraceProvider = NotifierProvider<SipTraceController, TraceState>(SipTraceController.new);

/// A Call-ID the trace page should focus on when it next opens (set by the
/// in-call menu and by Recents).
class DiagnosticsFocus extends Notifier<String?> {
  @override
  String? build() => null;
  void focus(String? callId) => state = callId;
}

final diagnosticsFocusProvider = NotifierProvider<DiagnosticsFocus, String?>(DiagnosticsFocus.new);
