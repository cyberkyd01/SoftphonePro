// Engine API models (see docs/ENGINE_API.md). Tolerant fromJson: missing or
// extra fields never throw.

// ignore_for_file: unused_import

import 'json_util.dart';
import 'models.dart';

class AutoAnswerHint {
  const AutoAnswerHint({
    this.afterSec = 0,
    this.source = AutoAnswerSource.unknown,
    this.require = false,
  });

  final int afterSec;
  final AutoAnswerSource source;
  final bool require;

  factory AutoAnswerHint.fromJson(Map<String, dynamic> j) => AutoAnswerHint(
    afterSec: asInt(j['afterSec'], 0),
    source: AutoAnswerSource.parse(j['source'], AutoAnswerSource.unknown),
    require: asBool(j['require'], false),
  );

  Map<String, dynamic> toJson() => {
    'afterSec': afterSec,
    'source': source.wire,
    'require': require,
  };

  @override
  bool operator ==(Object other) =>
      other is AutoAnswerHint && jsonEqual(toJson(), other.toJson());

  @override
  int get hashCode => jsonHash(toJson());

  @override
  String toString() => 'AutoAnswerHint(${toJson()})';
}

/// P-Asserted-Identity / Remote-Party-ID (contract v1.1).
class AssertedIdentity {
  const AssertedIdentity({this.display = '', this.user = '', this.uri = ''});

  final String display;
  final String user;
  final String uri;

  factory AssertedIdentity.fromJson(Map<String, dynamic> j) => AssertedIdentity(
    display: asString(j['display'], ''),
    user: asString(j['user'], ''),
    uri: asString(j['uri'], ''),
  );

  Map<String, dynamic> toJson() => {
    'display': display,
    'user': user,
    'uri': uri,
  };

  AssertedIdentity copyWith({String? display, String? user, String? uri}) =>
      AssertedIdentity(
        display: display ?? this.display,
        user: user ?? this.user,
        uri: uri ?? this.uri,
      );

  @override
  bool operator ==(Object other) =>
      other is AssertedIdentity && jsonEqual(toJson(), other.toJson());

  @override
  int get hashCode => jsonHash(toJson());

  @override
  String toString() => 'AssertedIdentity(${toJson()})';
}

/// One Diversion / History-Info hop (contract v1.1).
class DiversionEntry {
  const DiversionEntry({
    this.uri = '',
    this.user = '',
    this.reason = '',
    this.counter = 0,
  });

  final String uri;
  final String user;
  final String reason;
  final int counter;

  factory DiversionEntry.fromJson(Map<String, dynamic> j) => DiversionEntry(
    uri: asString(j['uri'], ''),
    user: asString(j['user'], ''),
    reason: asString(j['reason'], ''),
    counter: asInt(j['counter'], 0),
  );

  Map<String, dynamic> toJson() => {
    'uri': uri,
    'user': user,
    'reason': reason,
    'counter': counter,
  };

  DiversionEntry copyWith({
    String? uri,
    String? user,
    String? reason,
    int? counter,
  }) => DiversionEntry(
    uri: uri ?? this.uri,
    user: user ?? this.user,
    reason: reason ?? this.reason,
    counter: counter ?? this.counter,
  );

  @override
  bool operator ==(Object other) =>
      other is DiversionEntry && jsonEqual(toJson(), other.toJson());

  @override
  int get hashCode => jsonHash(toJson());

  @override
  String toString() => 'DiversionEntry(${toJson()})';
}

class CallInfo {
  const CallInfo({
    this.cid = 0,
    this.call = 0,
    this.acc = 0,
    this.uid = '',
    this.proto = SipProto.sip,
    this.role = CallRole.unknown,
    this.state = CallState.unknown,
    this.stateCode = 0,
    this.stateReason = '',
    this.lastCode = 0,
    this.remoteUri = '',
    this.remoteContact = '',
    this.remoteDisplay = '',
    this.remoteUser = '',
    this.localUri = '',
    this.callId = '',
    this.localTag = '',
    this.remoteTag = '',
    this.media = MediaStatus.none,
    this.codec = '',
    this.srtp = false,
    this.secureSignaling = false,
    this.muted = false,
    this.recording = false,
    this.detached = false,
    this.held = false,
    this.conferenceWith = const <int>[],
    this.bridgedWith = const <int>[],
    this.connectMs = 0,
    this.totalMs = 0,
    this.headers = const <String, String>{},
    this.transferFrom,
    this.assertedIdentity,
    this.diversion = const <DiversionEntry>[],
    this.referredBy,
  });

  final int cid;
  final int call;
  final int acc;
  final String uid;
  final SipProto proto;
  final CallRole role;
  final CallState state;
  final int stateCode;
  final String stateReason;
  final int lastCode;
  final String remoteUri;
  final String remoteContact;
  final String remoteDisplay;
  final String remoteUser;
  final String localUri;
  final String callId;
  final String localTag;
  final String remoteTag;
  final MediaStatus media;
  final String codec;
  final bool srtp;
  final bool secureSignaling;
  final bool muted;
  final bool recording;
  final bool detached;
  final bool held;
  final List<int> conferenceWith;
  final List<int> bridgedWith;
  final int connectMs;
  final int totalMs;
  final Map<String, String> headers;
  final int? transferFrom;

  /// P-Asserted-Identity / Remote-Party-ID, or null (contract v1.1).
  final AssertedIdentity? assertedIdentity;

  /// Diversion / History-Info hops, earliest first.
  final List<DiversionEntry> diversion;

  /// `Referred-By` URI for calls resulting from a transfer.
  final String? referredBy;

  factory CallInfo.fromJson(Map<String, dynamic> j) => CallInfo(
    cid: asInt(j['cid'], 0),
    call: asInt(j['call'], 0),
    acc: asInt(j['acc'], 0),
    uid: asString(j['uid'], ''),
    proto: SipProto.parse(j['proto'], SipProto.sip),
    role: CallRole.parse(j['role'], CallRole.unknown),
    state: CallState.parse(j['state'], CallState.unknown),
    stateCode: asInt(j['stateCode'], 0),
    stateReason: asString(j['stateReason'], ''),
    lastCode: asInt(j['lastCode'], 0),
    remoteUri: asString(j['remoteUri'], ''),
    remoteContact: asString(j['remoteContact'], ''),
    remoteDisplay: asString(j['remoteDisplay'], ''),
    remoteUser: asString(j['remoteUser'], ''),
    localUri: asString(j['localUri'], ''),
    callId: asString(j['callId'], ''),
    localTag: asString(j['localTag'], ''),
    remoteTag: asString(j['remoteTag'], ''),
    media: MediaStatus.parse(j['media'], MediaStatus.none),
    codec: asString(j['codec'], ''),
    srtp: asBool(j['srtp'], false),
    secureSignaling: asBool(j['secureSignaling'], false),
    muted: asBool(j['muted'], false),
    recording: asBool(j['recording'], false),
    detached: asBool(j['detached'], false),
    held: asBool(j['held'], false),
    conferenceWith: asIntList(j['conferenceWith'], const <int>[]),
    bridgedWith: asIntList(j['bridgedWith'], const <int>[]),
    connectMs: asInt(j['connectMs'], 0),
    totalMs: asInt(j['totalMs'], 0),
    headers: asStringMap(j['headers']),
    transferFrom: asIntN(j['transferFrom']),
    assertedIdentity: j['assertedIdentity'] is Map
        ? AssertedIdentity.fromJson(asMap(j['assertedIdentity']))
        : null,
    diversion: asList(
      j['diversion'],
    ).map((e) => DiversionEntry.fromJson(asMap(e))).toList(),
    referredBy: asStringN(j['referredBy']),
  );

  Map<String, dynamic> toJson() => {
    'cid': cid,
    'call': call,
    'acc': acc,
    'uid': uid,
    'proto': proto.wire,
    'role': role.wire,
    'state': state.wire,
    'stateCode': stateCode,
    'stateReason': stateReason,
    'lastCode': lastCode,
    'remoteUri': remoteUri,
    'remoteContact': remoteContact,
    'remoteDisplay': remoteDisplay,
    'remoteUser': remoteUser,
    'localUri': localUri,
    'callId': callId,
    'localTag': localTag,
    'remoteTag': remoteTag,
    'media': media.wire,
    'codec': codec,
    'srtp': srtp,
    'secureSignaling': secureSignaling,
    'muted': muted,
    'recording': recording,
    'detached': detached,
    'held': held,
    'conferenceWith': conferenceWith,
    'bridgedWith': bridgedWith,
    'connectMs': connectMs,
    'totalMs': totalMs,
    'headers': headers,
    'transferFrom': transferFrom,
    'assertedIdentity': assertedIdentity?.toJson(),
    'diversion': diversion.map((e) => e.toJson()).toList(),
    'referredBy': referredBy,
  };

  CallInfo copyWith({
    int? cid,
    int? call,
    int? acc,
    String? uid,
    SipProto? proto,
    CallRole? role,
    CallState? state,
    int? stateCode,
    String? stateReason,
    int? lastCode,
    String? remoteUri,
    String? remoteContact,
    String? remoteDisplay,
    String? remoteUser,
    String? localUri,
    String? callId,
    String? localTag,
    String? remoteTag,
    MediaStatus? media,
    String? codec,
    bool? srtp,
    bool? secureSignaling,
    bool? muted,
    bool? recording,
    bool? detached,
    bool? held,
    List<int>? conferenceWith,
    List<int>? bridgedWith,
    int? connectMs,
    int? totalMs,
    Map<String, String>? headers,
    int? transferFrom,
    AssertedIdentity? assertedIdentity,
    List<DiversionEntry>? diversion,
    String? referredBy,
  }) => CallInfo(
    cid: cid ?? this.cid,
    call: call ?? this.call,
    acc: acc ?? this.acc,
    uid: uid ?? this.uid,
    proto: proto ?? this.proto,
    role: role ?? this.role,
    state: state ?? this.state,
    stateCode: stateCode ?? this.stateCode,
    stateReason: stateReason ?? this.stateReason,
    lastCode: lastCode ?? this.lastCode,
    remoteUri: remoteUri ?? this.remoteUri,
    remoteContact: remoteContact ?? this.remoteContact,
    remoteDisplay: remoteDisplay ?? this.remoteDisplay,
    remoteUser: remoteUser ?? this.remoteUser,
    localUri: localUri ?? this.localUri,
    callId: callId ?? this.callId,
    localTag: localTag ?? this.localTag,
    remoteTag: remoteTag ?? this.remoteTag,
    media: media ?? this.media,
    codec: codec ?? this.codec,
    srtp: srtp ?? this.srtp,
    secureSignaling: secureSignaling ?? this.secureSignaling,
    muted: muted ?? this.muted,
    recording: recording ?? this.recording,
    detached: detached ?? this.detached,
    held: held ?? this.held,
    conferenceWith: conferenceWith ?? this.conferenceWith,
    bridgedWith: bridgedWith ?? this.bridgedWith,
    connectMs: connectMs ?? this.connectMs,
    totalMs: totalMs ?? this.totalMs,
    headers: headers ?? this.headers,
    transferFrom: transferFrom ?? this.transferFrom,
    assertedIdentity: assertedIdentity ?? this.assertedIdentity,
    diversion: diversion ?? this.diversion,
    referredBy: referredBy ?? this.referredBy,
  );

  @override
  bool operator ==(Object other) =>
      other is CallInfo && jsonEqual(toJson(), other.toJson());

  @override
  int get hashCode => jsonHash(toJson());

  @override
  String toString() => 'CallInfo(${toJson()})';
}

class RxStats {
  const RxStats({
    this.packets = 0,
    this.bytes = 0,
    this.lost = 0,
    this.lossPct = 0,
    this.discard = 0,
    this.reorder = 0,
    this.dup = 0,
    this.jitterMs = 0,
    this.jitterMaxMs = 0,
    this.lossPeriodMs = 0,
  });

  final int packets;
  final int bytes;
  final int lost;
  final double lossPct;
  final int discard;
  final int reorder;
  final int dup;
  final double jitterMs;
  final double jitterMaxMs;
  final double lossPeriodMs;

  factory RxStats.fromJson(Map<String, dynamic> j) => RxStats(
    packets: asInt(j['packets'], 0),
    bytes: asInt(j['bytes'], 0),
    lost: asInt(j['lost'], 0),
    lossPct: asDouble(j['lossPct'], 0),
    discard: asInt(j['discard'], 0),
    reorder: asInt(j['reorder'], 0),
    dup: asInt(j['dup'], 0),
    jitterMs: asDouble(j['jitterMs'], 0),
    jitterMaxMs: asDouble(j['jitterMaxMs'], 0),
    lossPeriodMs: asDouble(j['lossPeriodMs'], 0),
  );

  Map<String, dynamic> toJson() => {
    'packets': packets,
    'bytes': bytes,
    'lost': lost,
    'lossPct': lossPct,
    'discard': discard,
    'reorder': reorder,
    'dup': dup,
    'jitterMs': jitterMs,
    'jitterMaxMs': jitterMaxMs,
    'lossPeriodMs': lossPeriodMs,
  };

  @override
  bool operator ==(Object other) =>
      other is RxStats && jsonEqual(toJson(), other.toJson());

  @override
  int get hashCode => jsonHash(toJson());

  @override
  String toString() => 'RxStats(${toJson()})';
}

class TxStats {
  const TxStats({
    this.packets = 0,
    this.bytes = 0,
    this.lost = 0,
    this.lossPct = 0,
    this.jitterMs = 0,
  });

  final int packets;
  final int bytes;
  final int lost;
  final double lossPct;
  final double jitterMs;

  factory TxStats.fromJson(Map<String, dynamic> j) => TxStats(
    packets: asInt(j['packets'], 0),
    bytes: asInt(j['bytes'], 0),
    lost: asInt(j['lost'], 0),
    lossPct: asDouble(j['lossPct'], 0),
    jitterMs: asDouble(j['jitterMs'], 0),
  );

  Map<String, dynamic> toJson() => {
    'packets': packets,
    'bytes': bytes,
    'lost': lost,
    'lossPct': lossPct,
    'jitterMs': jitterMs,
  };

  @override
  bool operator ==(Object other) =>
      other is TxStats && jsonEqual(toJson(), other.toJson());

  @override
  int get hashCode => jsonHash(toJson());

  @override
  String toString() => 'TxStats(${toJson()})';
}

class RttStats {
  const RttStats({
    this.lastMs = 0,
    this.minMs = 0,
    this.avgMs = 0,
    this.maxMs = 0,
  });

  final double lastMs;
  final double minMs;
  final double avgMs;
  final double maxMs;

  factory RttStats.fromJson(Map<String, dynamic> j) => RttStats(
    lastMs: asDouble(j['lastMs'], 0),
    minMs: asDouble(j['minMs'], 0),
    avgMs: asDouble(j['avgMs'], 0),
    maxMs: asDouble(j['maxMs'], 0),
  );

  Map<String, dynamic> toJson() => {
    'lastMs': lastMs,
    'minMs': minMs,
    'avgMs': avgMs,
    'maxMs': maxMs,
  };

  @override
  bool operator ==(Object other) =>
      other is RttStats && jsonEqual(toJson(), other.toJson());

  @override
  int get hashCode => jsonHash(toJson());

  @override
  String toString() => 'RttStats(${toJson()})';
}

class JbStats {
  const JbStats({
    this.prefetch = 0,
    this.size = 0,
    this.avgDelayMs = 0,
    this.maxDelayMs = 0,
    this.burst = 0,
    this.empty = 0,
    this.discard = 0,
  });

  final int prefetch;
  final int size;
  final double avgDelayMs;
  final double maxDelayMs;
  final int burst;
  final int empty;
  final int discard;

  factory JbStats.fromJson(Map<String, dynamic> j) => JbStats(
    prefetch: asInt(j['prefetch'], 0),
    size: asInt(j['size'], 0),
    avgDelayMs: asDouble(j['avgDelayMs'], 0),
    maxDelayMs: asDouble(j['maxDelayMs'], 0),
    burst: asInt(j['burst'], 0),
    empty: asInt(j['empty'], 0),
    discard: asInt(j['discard'], 0),
  );

  Map<String, dynamic> toJson() => {
    'prefetch': prefetch,
    'size': size,
    'avgDelayMs': avgDelayMs,
    'maxDelayMs': maxDelayMs,
    'burst': burst,
    'empty': empty,
    'discard': discard,
  };

  @override
  bool operator ==(Object other) =>
      other is JbStats && jsonEqual(toJson(), other.toJson());

  @override
  int get hashCode => jsonHash(toJson());

  @override
  String toString() => 'JbStats(${toJson()})';
}

class IceStats {
  const IceStats({this.state = 'none', this.localType, this.remoteType});

  final String state;
  final String? localType;
  final String? remoteType;

  factory IceStats.fromJson(Map<String, dynamic> j) => IceStats(
    state: asString(j['state'], 'none'),
    localType: asStringN(j['localType']),
    remoteType: asStringN(j['remoteType']),
  );

  Map<String, dynamic> toJson() => {
    'state': state,
    'localType': localType,
    'remoteType': remoteType,
  };

  @override
  bool operator ==(Object other) =>
      other is IceStats && jsonEqual(toJson(), other.toJson());

  @override
  int get hashCode => jsonHash(toJson());

  @override
  String toString() => 'IceStats(${toJson()})';
}

class CallStats {
  const CallStats({
    this.cid = 0,
    this.codec = '',
    this.clockRate = 0,
    this.ptime = 0,
    this.rx = const RxStats(),
    this.tx = const TxStats(),
    this.rtt = const RttStats(),
    this.jb = const JbStats(),
    this.mos = 0,
    this.rxLevel = 0,
    this.txLevel = 0,
    this.srtp = false,
    this.crypto,
    this.ice = const IceStats(),
    this.localRtp = '',
    this.remoteRtp = '',
  });

  final int cid;
  final String codec;
  final int clockRate;
  final int ptime;
  final RxStats rx;
  final TxStats tx;
  final RttStats rtt;
  final JbStats jb;
  final double mos;
  final int rxLevel;
  final int txLevel;
  final bool srtp;
  final String? crypto;
  final IceStats ice;
  final String localRtp;
  final String remoteRtp;

  factory CallStats.fromJson(Map<String, dynamic> j) => CallStats(
    cid: asInt(j['cid'], 0),
    codec: asString(j['codec'], ''),
    clockRate: asInt(j['clockRate'], 0),
    ptime: asInt(j['ptime'], 0),
    rx: j['rx'] is Map ? RxStats.fromJson(asMap(j['rx'])) : const RxStats(),
    tx: j['tx'] is Map ? TxStats.fromJson(asMap(j['tx'])) : const TxStats(),
    rtt: j['rtt'] is Map
        ? RttStats.fromJson(asMap(j['rtt']))
        : const RttStats(),
    jb: j['jb'] is Map ? JbStats.fromJson(asMap(j['jb'])) : const JbStats(),
    mos: asDouble(j['mos'], 0),
    rxLevel: asInt(j['rxLevel'], 0),
    txLevel: asInt(j['txLevel'], 0),
    srtp: asBool(j['srtp'], false),
    crypto: asStringN(j['crypto']),
    ice: j['ice'] is Map
        ? IceStats.fromJson(asMap(j['ice']))
        : const IceStats(),
    localRtp: asString(j['localRtp'], ''),
    remoteRtp: asString(j['remoteRtp'], ''),
  );

  Map<String, dynamic> toJson() => {
    'cid': cid,
    'codec': codec,
    'clockRate': clockRate,
    'ptime': ptime,
    'rx': rx.toJson(),
    'tx': tx.toJson(),
    'rtt': rtt.toJson(),
    'jb': jb.toJson(),
    'mos': mos,
    'rxLevel': rxLevel,
    'txLevel': txLevel,
    'srtp': srtp,
    'crypto': crypto,
    'ice': ice.toJson(),
    'localRtp': localRtp,
    'remoteRtp': remoteRtp,
  };

  @override
  bool operator ==(Object other) =>
      other is CallStats && jsonEqual(toJson(), other.toJson());

  @override
  int get hashCode => jsonHash(toJson());

  @override
  String toString() => 'CallStats(${toJson()})';
}
