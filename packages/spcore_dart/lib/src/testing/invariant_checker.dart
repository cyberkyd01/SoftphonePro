import 'dart:async';

import '../events.dart';
import '../models/models.dart';

/// Validates an event stream against the invariants of ENGINE_API.md §3:
///
/// 1. `call.incoming` precedes any other event for an incoming cid.
/// 2. Each cid gets exactly one terminal `call.state` (`disconnected`) and no
///    events for that cid follow it.
/// 3. Events caused by a request precede the request's response (checked with
///    [checkRequest] / [expectTerminalSeen]).
///
/// Additionally `seq` must be strictly increasing and a cid is never reused.
class InvariantChecker {
  InvariantChecker({this.allowUnknownCids = false});

  /// When true, events for cids never seen before are accepted (e.g. after
  /// attaching to a running engine, before a snapshot was applied).
  final bool allowUnknownCids;

  final List<String> violations = [];
  final Set<int> _live = {};
  final Set<int> _terminal = {};
  final Set<int> _incoming = {};
  int _lastSeq = 0;
  int _count = 0;
  StreamSubscription<EngineEvent>? _sub;

  int get eventCount => _count;
  bool get ok => violations.isEmpty;

  /// Cids that have been seen and not yet terminated.
  Set<int> get liveCids => Set.unmodifiable(_live);

  /// Cids with a terminal state.
  Set<int> get terminatedCids => Set.unmodifiable(_terminal);

  /// Subscribes to [events] (synchronously, so request ordering can be
  /// checked). Call [dispose] when done.
  void attach(Stream<EngineEvent> events) {
    _sub = events.listen(onEvent);
  }

  Future<void> dispose() async => _sub?.cancel();

  void _fail(EngineEvent e, String msg) =>
      violations.add('seq ${e.seq} ${e.name}: $msg');

  /// Feeds one event.
  void onEvent(EngineEvent e) {
    _count++;
    if (e.seq != 0) {
      if (e.seq <= _lastSeq) {
        _fail(e, 'seq not increasing (last $_lastSeq)');
      }
      _lastSeq = e.seq;
    }
    switch (e) {
      case CallIncomingEvent():
        if (_live.contains(e.cid) || _terminal.contains(e.cid)) {
          _fail(e, 'cid ${e.cid} reused or announced twice');
        }
        _live.add(e.cid);
        _incoming.add(e.cid);
      case CallStateEvent():
        _onState(e);
      case CallReplacedEvent():
        _touch(e, e.oldCid);
      case CallEvent():
        _touch(e, e.cid);
      default:
        break;
    }
  }

  void _onState(CallStateEvent e) {
    final cid = e.cid;
    if (_terminal.contains(cid)) {
      _fail(e, 'event for cid $cid after terminal state');
      return;
    }
    if (!_live.contains(cid)) {
      if (e.call.role == CallRole.callee && !allowUnknownCids) {
        _fail(e, 'call.state for incoming cid $cid before call.incoming');
      } else if (e.call.state == CallState.disconnected &&
          !allowUnknownCids &&
          e.call.role != CallRole.caller) {
        _fail(e, 'terminal state for unseen cid $cid');
      }
      _live.add(cid);
    }
    if (e.call.state == CallState.disconnected) {
      _live.remove(cid);
      _terminal.add(cid);
    } else if (e.call.state == CallState.incoming && !_incoming.contains(cid)) {
      _fail(e, 'incoming state without call.incoming for cid $cid');
    }
  }

  void _touch(EngineEvent e, int cid) {
    if (_terminal.contains(cid)) {
      _fail(e, 'event for cid $cid after terminal state');
    } else if (!_live.contains(cid) && !allowUnknownCids) {
      _fail(e, 'event for unseen cid $cid');
    }
  }

  /// Invariant 3 helper: call right after a request that must have ended
  /// [cid] has completed.
  void expectTerminalSeen(int cid) {
    if (!_terminal.contains(cid)) {
      violations.add(
        'response arrived before terminal call.state of cid $cid (invariant 3)',
      );
    }
  }

  /// Runs [op] and verifies that, when it completes, the events it was
  /// expected to cause were already delivered: every cid in
  /// [terminalCids] must be terminal, and [expectEvents] must hold.
  Future<T> checkRequest<T>(
    Future<T> Function() op, {
    Iterable<int> terminalCids = const [],
    bool Function()? expectEvents,
  }) async {
    final r = await op();
    for (final c in terminalCids) {
      expectTerminalSeen(c);
    }
    if (expectEvents != null && !expectEvents()) {
      violations.add('expected events were not delivered before the response');
    }
    return r;
  }

  /// Throws a [StateError] listing all violations, if any.
  void assertOk() {
    if (violations.isNotEmpty) {
      throw StateError(
        'Engine invariant violations:\n${violations.join('\n')}',
      );
    }
  }

  /// One-shot validation of a recorded event list.
  static List<String> validate(
    Iterable<EngineEvent> events, {
    bool allowUnknownCids = false,
    bool requireAllTerminated = false,
  }) {
    final c = InvariantChecker(allowUnknownCids: allowUnknownCids);
    events.forEach(c.onEvent);
    if (requireAllTerminated && c._live.isNotEmpty) {
      c.violations.add('calls without terminal state: ${c._live}');
    }
    return c.violations;
  }
}
