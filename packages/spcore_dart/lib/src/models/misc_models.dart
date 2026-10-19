// Engine API models (see docs/ENGINE_API.md). Tolerant fromJson: missing or
// extra fields never throw.

// ignore_for_file: unused_import

import 'json_util.dart';
import 'models.dart';

class CertInfo {
  const CertInfo({
    this.subject = '',
    this.issuer = '',
    this.notAfter = '',
    this.sha256 = '',
  });

  final String subject;
  final String issuer;
  final String notAfter;
  final String sha256;

  factory CertInfo.fromJson(Map<String, dynamic> j) => CertInfo(
    subject: asString(j['subject'], ''),
    issuer: asString(j['issuer'], ''),
    notAfter: asString(j['notAfter'], ''),
    sha256: asString(j['sha256'], ''),
  );

  Map<String, dynamic> toJson() => {
    'subject': subject,
    'issuer': issuer,
    'notAfter': notAfter,
    'sha256': sha256,
  };

  @override
  bool operator ==(Object other) =>
      other is CertInfo && jsonEqual(toJson(), other.toJson());

  @override
  int get hashCode => jsonHash(toJson());

  @override
  String toString() => 'CertInfo(${toJson()})';
}

class TlsInfo {
  const TlsInfo({
    this.verifyStatus = const <String>[],
    this.cipher = '',
    this.remoteCert,
  });

  final List<String> verifyStatus;
  final String cipher;
  final CertInfo? remoteCert;

  factory TlsInfo.fromJson(Map<String, dynamic> j) => TlsInfo(
    verifyStatus: asStringList(j['verifyStatus'], const <String>[]),
    cipher: asString(j['cipher'], ''),
    remoteCert: j['remoteCert'] is Map
        ? CertInfo.fromJson(asMap(j['remoteCert']))
        : null,
  );

  Map<String, dynamic> toJson() => {
    'verifyStatus': verifyStatus,
    'cipher': cipher,
    'remoteCert': remoteCert?.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      other is TlsInfo && jsonEqual(toJson(), other.toJson());

  @override
  int get hashCode => jsonHash(toJson());

  @override
  String toString() => 'TlsInfo(${toJson()})';
}

class TransportStateInfo {
  const TransportStateInfo({
    this.transport = '',
    this.local = '',
    this.remote = '',
    this.state = TransportStateKind.unknown,
    this.status = 0,
    this.tls,
  });

  final String transport;
  final String local;
  final String remote;
  final TransportStateKind state;
  final int status;
  final TlsInfo? tls;

  factory TransportStateInfo.fromJson(Map<String, dynamic> j) =>
      TransportStateInfo(
        transport: asString(j['transport'], ''),
        local: asString(j['local'], ''),
        remote: asString(j['remote'], ''),
        state: TransportStateKind.parse(j['state'], TransportStateKind.unknown),
        status: asInt(j['status'], 0),
        tls: j['tls'] is Map ? TlsInfo.fromJson(asMap(j['tls'])) : null,
      );

  Map<String, dynamic> toJson() => {
    'transport': transport,
    'local': local,
    'remote': remote,
    'state': state.wire,
    'status': status,
    'tls': tls?.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      other is TransportStateInfo && jsonEqual(toJson(), other.toJson());

  @override
  int get hashCode => jsonHash(toJson());

  @override
  String toString() => 'TransportStateInfo(${toJson()})';
}

class TlsVerifyInfo {
  const TlsVerifyInfo({
    this.host = '',
    this.sha256 = '',
    this.verifyStatus = const <String>[],
    this.subject = '',
    this.issuer = '',
  });

  final String host;
  final String sha256;
  final List<String> verifyStatus;
  final String subject;
  final String issuer;

  factory TlsVerifyInfo.fromJson(Map<String, dynamic> j) => TlsVerifyInfo(
    host: asString(j['host'], ''),
    sha256: asString(j['sha256'], ''),
    verifyStatus: asStringList(j['verifyStatus'], const <String>[]),
    subject: asString(j['subject'], ''),
    issuer: asString(j['issuer'], ''),
  );

  Map<String, dynamic> toJson() => {
    'host': host,
    'sha256': sha256,
    'verifyStatus': verifyStatus,
    'subject': subject,
    'issuer': issuer,
  };

  @override
  bool operator ==(Object other) =>
      other is TlsVerifyInfo && jsonEqual(toJson(), other.toJson());

  @override
  int get hashCode => jsonHash(toJson());

  @override
  String toString() => 'TlsVerifyInfo(${toJson()})';
}

class NatTypeInfo {
  const NatTypeInfo({
    this.natType = NatType.unknown,
    this.description = '',
    this.stun = '',
  });

  final NatType natType;
  final String description;
  final String stun;

  factory NatTypeInfo.fromJson(Map<String, dynamic> j) => NatTypeInfo(
    natType: NatType.parse(j['natType'], NatType.unknown),
    description: asString(j['description'], ''),
    stun: asString(j['stun'], ''),
  );

  Map<String, dynamic> toJson() => {
    'natType': natType.wire,
    'description': description,
    'stun': stun,
  };

  @override
  bool operator ==(Object other) =>
      other is NatTypeInfo && jsonEqual(toJson(), other.toJson());

  @override
  int get hashCode => jsonHash(toJson());

  @override
  String toString() => 'NatTypeInfo(${toJson()})';
}

class OptionsResult {
  const OptionsResult({
    this.acc = 0,
    this.uid = '',
    this.code = 0,
    this.reason = '',
    this.rttMs = 0,
  });

  final int acc;
  final String uid;
  final int code;
  final String reason;
  final double rttMs;

  factory OptionsResult.fromJson(Map<String, dynamic> j) => OptionsResult(
    acc: asInt(j['acc'], 0),
    uid: asString(j['uid'], ''),
    code: asInt(j['code'], 0),
    reason: asString(j['reason'], ''),
    rttMs: asDouble(j['rttMs'], 0),
  );

  Map<String, dynamic> toJson() => {
    'acc': acc,
    'uid': uid,
    'code': code,
    'reason': reason,
    'rttMs': rttMs,
  };

  @override
  bool operator ==(Object other) =>
      other is OptionsResult && jsonEqual(toJson(), other.toJson());

  @override
  int get hashCode => jsonHash(toJson());

  @override
  String toString() => 'OptionsResult(${toJson()})';
}

class EngineError {
  const EngineError({
    this.code = ErrorCode.unknown,
    this.status = 0,
    this.message = '',
  });

  final ErrorCode code;
  final int status;
  final String message;

  factory EngineError.fromJson(Map<String, dynamic> j) => EngineError(
    code: ErrorCode.parse(j['code'], ErrorCode.unknown),
    status: asInt(j['status'], 0),
    message: asString(j['message'], ''),
  );

  Map<String, dynamic> toJson() => {
    'code': code.wire,
    'status': status,
    'message': message,
  };

  @override
  bool operator ==(Object other) =>
      other is EngineError && jsonEqual(toJson(), other.toJson());

  @override
  int get hashCode => jsonHash(toJson());

  @override
  String toString() => 'EngineError(${toJson()})';
}

class EngineSnapshot {
  const EngineSnapshot({
    this.accounts = const <AccountInfo>[],
    this.calls = const <CallInfo>[],
    this.buddies = const <BuddyInfo>[],
    this.devices = const AudioDevices(),
    this.seq = 0,
  });

  final List<AccountInfo> accounts;
  final List<CallInfo> calls;
  final List<BuddyInfo> buddies;
  final AudioDevices devices;
  final int seq;

  factory EngineSnapshot.fromJson(Map<String, dynamic> j) => EngineSnapshot(
    accounts: asList(
      j['accounts'],
    ).map((e) => AccountInfo.fromJson(asMap(e))).toList(),
    calls: asList(j['calls']).map((e) => CallInfo.fromJson(asMap(e))).toList(),
    buddies: asList(
      j['buddies'],
    ).map((e) => BuddyInfo.fromJson(asMap(e))).toList(),
    devices: j['devices'] is Map
        ? AudioDevices.fromJson(asMap(j['devices']))
        : const AudioDevices(),
    seq: asInt(j['seq'], 0),
  );

  Map<String, dynamic> toJson() => {
    'accounts': accounts.map((e) => e.toJson()).toList(),
    'calls': calls.map((e) => e.toJson()).toList(),
    'buddies': buddies.map((e) => e.toJson()).toList(),
    'devices': devices.toJson(),
    'seq': seq,
  };

  @override
  bool operator ==(Object other) =>
      other is EngineSnapshot && jsonEqual(toJson(), other.toJson());

  @override
  int get hashCode => jsonHash(toJson());

  @override
  String toString() => 'EngineSnapshot(${toJson()})';
}
