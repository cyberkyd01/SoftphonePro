// Engine API models (see docs/ENGINE_API.md). Tolerant fromJson: missing or
// extra fields never throw.

// ignore_for_file: unused_import

import 'json_util.dart';
import 'models.dart';

class BuddyPresence {
  const BuddyPresence({
    this.status = PresenceStatus.unknown,
    this.note = '',
    this.subState = '',
  });

  final PresenceStatus status;
  final String note;
  final String subState;

  factory BuddyPresence.fromJson(Map<String, dynamic> j) => BuddyPresence(
    status: PresenceStatus.parse(j['status'], PresenceStatus.unknown),
    note: asString(j['note'], ''),
    subState: asString(j['subState'], ''),
  );

  Map<String, dynamic> toJson() => {
    'status': status.wire,
    'note': note,
    'subState': subState,
  };

  @override
  bool operator ==(Object other) =>
      other is BuddyPresence && jsonEqual(toJson(), other.toJson());

  @override
  int get hashCode => jsonHash(toJson());

  @override
  String toString() => 'BuddyPresence(${toJson()})';
}

class BlfDialog {
  const BlfDialog({
    this.id = '',
    this.state = BlfState.unknown,
    this.direction = BlfDirection.unknown,
    this.callId = '',
    this.localTag = '',
    this.remoteTag = '',
    this.remote = '',
    this.local = '',
    this.durationSec = 0,
  });

  final String id;
  final BlfState state;
  final BlfDirection direction;
  final String callId;
  final String localTag;
  final String remoteTag;
  final String remote;
  final String local;
  final int durationSec;

  factory BlfDialog.fromJson(Map<String, dynamic> j) => BlfDialog(
    id: asString(j['id'], ''),
    state: BlfState.parse(j['state'], BlfState.unknown),
    direction: BlfDirection.parse(j['direction'], BlfDirection.unknown),
    callId: asString(j['callId'], ''),
    localTag: asString(j['localTag'], ''),
    remoteTag: asString(j['remoteTag'], ''),
    remote: asString(j['remote'], ''),
    local: asString(j['local'], ''),
    durationSec: asInt(j['durationSec'], 0),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'state': state.wire,
    'direction': direction.wire,
    'callId': callId,
    'localTag': localTag,
    'remoteTag': remoteTag,
    'remote': remote,
    'local': local,
    'durationSec': durationSec,
  };

  @override
  bool operator ==(Object other) =>
      other is BlfDialog && jsonEqual(toJson(), other.toJson());

  @override
  int get hashCode => jsonHash(toJson());

  @override
  String toString() => 'BlfDialog(${toJson()})';
}

class BlfInfo {
  const BlfInfo({
    this.state = BlfState.unknown,
    this.subState = '',
    this.dialogs = const <BlfDialog>[],
  });

  final BlfState state;
  final String subState;
  final List<BlfDialog> dialogs;

  factory BlfInfo.fromJson(Map<String, dynamic> j) => BlfInfo(
    state: BlfState.parse(j['state'], BlfState.unknown),
    subState: asString(j['subState'], ''),
    dialogs: asList(
      j['dialogs'],
    ).map((e) => BlfDialog.fromJson(asMap(e))).toList(),
  );

  Map<String, dynamic> toJson() => {
    'state': state.wire,
    'subState': subState,
    'dialogs': dialogs.map((e) => e.toJson()).toList(),
  };

  @override
  bool operator ==(Object other) =>
      other is BlfInfo && jsonEqual(toJson(), other.toJson());

  @override
  int get hashCode => jsonHash(toJson());

  @override
  String toString() => 'BlfInfo(${toJson()})';
}

class BuddyInfo {
  const BuddyInfo({
    this.buddy = 0,
    this.acc = 0,
    this.uid = '',
    this.uri = '',
    this.presence = const BuddyPresence(),
    this.blf = const BlfInfo(),
  });

  final int buddy;
  final int acc;
  final String uid;
  final String uri;
  final BuddyPresence presence;
  final BlfInfo blf;

  factory BuddyInfo.fromJson(Map<String, dynamic> j) => BuddyInfo(
    buddy: asInt(j['buddy'], 0),
    acc: asInt(j['acc'], 0),
    uid: asString(j['uid'], ''),
    uri: asString(j['uri'], ''),
    presence: j['presence'] is Map
        ? BuddyPresence.fromJson(asMap(j['presence']))
        : const BuddyPresence(),
    blf: j['blf'] is Map ? BlfInfo.fromJson(asMap(j['blf'])) : const BlfInfo(),
  );

  Map<String, dynamic> toJson() => {
    'buddy': buddy,
    'acc': acc,
    'uid': uid,
    'uri': uri,
    'presence': presence.toJson(),
    'blf': blf.toJson(),
  };

  BuddyInfo copyWith({
    int? buddy,
    int? acc,
    String? uid,
    String? uri,
    BuddyPresence? presence,
    BlfInfo? blf,
  }) => BuddyInfo(
    buddy: buddy ?? this.buddy,
    acc: acc ?? this.acc,
    uid: uid ?? this.uid,
    uri: uri ?? this.uri,
    presence: presence ?? this.presence,
    blf: blf ?? this.blf,
  );

  @override
  bool operator ==(Object other) =>
      other is BuddyInfo && jsonEqual(toJson(), other.toJson());

  @override
  int get hashCode => jsonHash(toJson());

  @override
  String toString() => 'BuddyInfo(${toJson()})';
}

class ImMessage {
  const ImMessage({
    this.acc = 0,
    this.uid = '',
    this.from = '',
    this.fromDisplay = '',
    this.to = '',
    this.body = '',
    this.contentType = 'text/plain',
    this.isLan = false,
  });

  final int acc;
  final String uid;
  final String from;
  final String fromDisplay;
  final String to;
  final String body;
  final String contentType;
  final bool isLan;

  factory ImMessage.fromJson(Map<String, dynamic> j) => ImMessage(
    acc: asInt(j['acc'], 0),
    uid: asString(j['uid'], ''),
    from: asString(j['from'], ''),
    fromDisplay: asString(j['fromDisplay'], ''),
    to: asString(j['to'], ''),
    body: asString(j['body'], ''),
    contentType: asString(j['contentType'], 'text/plain'),
    isLan: asBool(j['isLan'], false),
  );

  Map<String, dynamic> toJson() => {
    'acc': acc,
    'uid': uid,
    'from': from,
    'fromDisplay': fromDisplay,
    'to': to,
    'body': body,
    'contentType': contentType,
    'isLan': isLan,
  };

  @override
  bool operator ==(Object other) =>
      other is ImMessage && jsonEqual(toJson(), other.toJson());

  @override
  int get hashCode => jsonHash(toJson());

  @override
  String toString() => 'ImMessage(${toJson()})';
}

class ImStatus {
  const ImStatus({
    this.acc = 0,
    this.uid = '',
    this.to = '',
    this.msgId = '',
    this.code = 0,
    this.reason = '',
    this.ok = false,
  });

  final int acc;
  final String uid;
  final String to;
  final String msgId;
  final int code;
  final String reason;
  final bool ok;

  factory ImStatus.fromJson(Map<String, dynamic> j) => ImStatus(
    acc: asInt(j['acc'], 0),
    uid: asString(j['uid'], ''),
    to: asString(j['to'], ''),
    msgId: asString(j['msgId'], ''),
    code: asInt(j['code'], 0),
    reason: asString(j['reason'], ''),
    ok: asBool(j['ok'], false),
  );

  Map<String, dynamic> toJson() => {
    'acc': acc,
    'uid': uid,
    'to': to,
    'msgId': msgId,
    'code': code,
    'reason': reason,
    'ok': ok,
  };

  @override
  bool operator ==(Object other) =>
      other is ImStatus && jsonEqual(toJson(), other.toJson());

  @override
  int get hashCode => jsonHash(toJson());

  @override
  String toString() => 'ImStatus(${toJson()})';
}

class ImTyping {
  const ImTyping({
    this.acc = 0,
    this.uid = '',
    this.from = '',
    this.typing = false,
  });

  final int acc;
  final String uid;
  final String from;
  final bool typing;

  factory ImTyping.fromJson(Map<String, dynamic> j) => ImTyping(
    acc: asInt(j['acc'], 0),
    uid: asString(j['uid'], ''),
    from: asString(j['from'], ''),
    typing: asBool(j['typing'], false),
  );

  Map<String, dynamic> toJson() => {
    'acc': acc,
    'uid': uid,
    'from': from,
    'typing': typing,
  };

  @override
  bool operator ==(Object other) =>
      other is ImTyping && jsonEqual(toJson(), other.toJson());

  @override
  int get hashCode => jsonHash(toJson());

  @override
  String toString() => 'ImTyping(${toJson()})';
}
