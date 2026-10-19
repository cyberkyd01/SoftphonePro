import 'sip_message.dart';

/// All messages sharing one Call-ID, in capture order.
class SipDialog {
  SipDialog(this.callId);
  final String callId;
  final List<SipMessage> messages = [];

  SipMessage get first => messages.first;
  SipMessage get last => messages.last;
  DateTime get start => first.time;
  Duration get duration => last.time.difference(first.time);

  /// The method that opened the dialog (first request seen, else first label).
  String get kind {
    for (final m in messages) {
      if (m.isRequest) return m.method;
    }
    for (final m in messages) {
      if (m.cseqMethod.isNotEmpty) return m.cseqMethod;
    }
    return 'SIP';
  }

  /// Highest-impact final response (last non-1xx response), if any.
  SipMessage? get finalResponse {
    for (var i = messages.length - 1; i >= 0; i--) {
      final m = messages[i];
      if (m.isResponse && m.status >= 200) return m;
    }
    return null;
  }

  bool get hasError => messages.any((m) => m.isError);

  String get from => first.fromUri;
  String get to => first.toUri;

  /// Whether any response was captured for this dialog.
  bool get hasResponse => messages.any((m) => m.isResponse);

  String get summary {
    final f = finalResponse;
    if (f != null) return f.label;
    final r = messages.where((m) => m.isResponse).toList();
    if (r.isNotEmpty) return r.last.label;
    return 'no response';
  }
}

/// Groups messages by Call-ID, preserving first-seen order. Messages without a
/// Call-ID are grouped under the empty id.
List<SipDialog> groupDialogs(Iterable<SipMessage> messages) {
  final map = <String, SipDialog>{};
  for (final m in messages) {
    final d = map.putIfAbsent(m.callId, () => SipDialog(m.callId));
    d.messages.add(m);
  }
  return map.values.toList();
}

/// One arrow of a ladder diagram.
class LadderArrow {
  const LadderArrow({
    required this.message,
    required this.fromLane,
    required this.toLane,
    required this.delta,
    required this.offset,
  });
  final SipMessage message;
  final int fromLane;
  final int toLane;

  /// Time since the previous message in the dialog.
  final Duration delta;

  /// Time since the first message in the dialog.
  final Duration offset;
}

class Ladder {
  const Ladder(this.lanes, this.arrows);

  /// Lane 0 is always the local endpoint; remote endpoints follow.
  final List<String> lanes;
  final List<LadderArrow> arrows;
}

/// Builds a ladder diagram: lane 0 = local, one lane per distinct remote.
Ladder buildLadder(SipDialog dialog) {
  final lanes = <String>['local'];
  final localAddrs = dialog.messages.map((m) => m.local).where((s) => s.isNotEmpty).toSet();
  if (localAddrs.length == 1) lanes[0] = localAddrs.first;
  final remoteIdx = <String, int>{};
  final arrows = <LadderArrow>[];
  DateTime? prev;
  for (final m in dialog.messages) {
    final r = m.remote.isEmpty ? 'remote' : m.remote;
    final idx = remoteIdx.putIfAbsent(r, () {
      lanes.add(r);
      return lanes.length - 1;
    });
    arrows.add(
      LadderArrow(
        message: m,
        fromLane: m.outgoing ? 0 : idx,
        toLane: m.outgoing ? idx : 0,
        delta: prev == null ? Duration.zero : m.time.difference(prev),
        offset: m.time.difference(dialog.start),
      ),
    );
    prev = m.time;
  }
  if (lanes.length == 1) lanes.add('remote');
  return Ladder(lanes, arrows);
}
