// Engine API models (see docs/ENGINE_API.md). Tolerant fromJson: missing or
// extra fields never throw.

// ignore_for_file: unused_import

import 'json_util.dart';
import 'models.dart';

class TransportPort {
  const TransportPort({this.port = 5060, this.enabled = true});

  final int port;
  final bool enabled;

  factory TransportPort.fromJson(Map<String, dynamic> j) => TransportPort(
    port: asInt(j['port'], 5060),
    enabled: asBool(j['enabled'], true),
  );

  Map<String, dynamic> toJson() => {'port': port, 'enabled': enabled};

  @override
  bool operator ==(Object other) =>
      other is TransportPort && jsonEqual(toJson(), other.toJson());

  @override
  int get hashCode => jsonHash(toJson());

  @override
  String toString() => 'TransportPort(${toJson()})';
}

class TlsTransportConfig {
  const TlsTransportConfig({
    this.port = 5061,
    this.enabled = true,
    this.verifyServer = false,
    this.caFile,
    this.certFile,
    this.keyFile,
    this.minProto = 'tls1.2',
  });

  final int port;
  final bool enabled;
  final bool verifyServer;
  final String? caFile;
  final String? certFile;
  final String? keyFile;
  final String minProto;

  factory TlsTransportConfig.fromJson(Map<String, dynamic> j) =>
      TlsTransportConfig(
        port: asInt(j['port'], 5061),
        enabled: asBool(j['enabled'], true),
        verifyServer: asBool(j['verifyServer'], false),
        caFile: asStringN(j['caFile']),
        certFile: asStringN(j['certFile']),
        keyFile: asStringN(j['keyFile']),
        minProto: asString(j['minProto'], 'tls1.2'),
      );

  Map<String, dynamic> toJson() => {
    'port': port,
    'enabled': enabled,
    'verifyServer': verifyServer,
    'caFile': caFile,
    'certFile': certFile,
    'keyFile': keyFile,
    'minProto': minProto,
  };

  TlsTransportConfig copyWith({
    int? port,
    bool? enabled,
    bool? verifyServer,
    String? caFile,
    String? certFile,
    String? keyFile,
    String? minProto,
  }) => TlsTransportConfig(
    port: port ?? this.port,
    enabled: enabled ?? this.enabled,
    verifyServer: verifyServer ?? this.verifyServer,
    caFile: caFile ?? this.caFile,
    certFile: certFile ?? this.certFile,
    keyFile: keyFile ?? this.keyFile,
    minProto: minProto ?? this.minProto,
  );

  @override
  bool operator ==(Object other) =>
      other is TlsTransportConfig && jsonEqual(toJson(), other.toJson());

  @override
  int get hashCode => jsonHash(toJson());

  @override
  String toString() => 'TlsTransportConfig(${toJson()})';
}

class TransportConfig {
  const TransportConfig({
    this.udp = const TransportPort(),
    this.tcp = const TransportPort(),
    this.tls = const TlsTransportConfig(),
    this.ipv6 = false,
    this.qos = true,
  });

  final TransportPort udp;
  final TransportPort tcp;
  final TlsTransportConfig tls;
  final bool ipv6;
  final bool qos;

  factory TransportConfig.fromJson(Map<String, dynamic> j) => TransportConfig(
    udp: j['udp'] is Map
        ? TransportPort.fromJson(asMap(j['udp']))
        : const TransportPort(),
    tcp: j['tcp'] is Map
        ? TransportPort.fromJson(asMap(j['tcp']))
        : const TransportPort(),
    tls: j['tls'] is Map
        ? TlsTransportConfig.fromJson(asMap(j['tls']))
        : const TlsTransportConfig(),
    ipv6: asBool(j['ipv6'], false),
    qos: asBool(j['qos'], true),
  );

  Map<String, dynamic> toJson() => {
    'udp': udp.toJson(),
    'tcp': tcp.toJson(),
    'tls': tls.toJson(),
    'ipv6': ipv6,
    'qos': qos,
  };

  TransportConfig copyWith({
    TransportPort? udp,
    TransportPort? tcp,
    TlsTransportConfig? tls,
    bool? ipv6,
    bool? qos,
  }) => TransportConfig(
    udp: udp ?? this.udp,
    tcp: tcp ?? this.tcp,
    tls: tls ?? this.tls,
    ipv6: ipv6 ?? this.ipv6,
    qos: qos ?? this.qos,
  );

  @override
  bool operator ==(Object other) =>
      other is TransportConfig && jsonEqual(toJson(), other.toJson());

  @override
  int get hashCode => jsonHash(toJson());

  @override
  String toString() => 'TransportConfig(${toJson()})';
}

class LanConfig {
  const LanConfig({this.enabled = false, this.port = 0});

  final bool enabled;
  final int port;

  factory LanConfig.fromJson(Map<String, dynamic> j) => LanConfig(
    enabled: asBool(j['enabled'], false),
    port: asInt(j['port'], 0),
  );

  Map<String, dynamic> toJson() => {'enabled': enabled, 'port': port};

  @override
  bool operator ==(Object other) =>
      other is LanConfig && jsonEqual(toJson(), other.toJson());

  @override
  int get hashCode => jsonHash(toJson());

  @override
  String toString() => 'LanConfig(${toJson()})';
}

class EcConfig {
  const EcConfig({
    this.algo = EcAlgo.auto,
    this.tailMs = 200,
    this.ns = true,
    this.agc = false,
  });

  final EcAlgo algo;
  final int tailMs;
  final bool ns;
  final bool agc;

  factory EcConfig.fromJson(Map<String, dynamic> j) => EcConfig(
    algo: EcAlgo.parse(j['algo'], EcAlgo.auto),
    tailMs: asInt(j['tailMs'], 200),
    ns: asBool(j['ns'], true),
    agc: asBool(j['agc'], false),
  );

  Map<String, dynamic> toJson() => {
    'algo': algo.wire,
    'tailMs': tailMs,
    'ns': ns,
    'agc': agc,
  };

  EcConfig copyWith({EcAlgo? algo, int? tailMs, bool? ns, bool? agc}) =>
      EcConfig(
        algo: algo ?? this.algo,
        tailMs: tailMs ?? this.tailMs,
        ns: ns ?? this.ns,
        agc: agc ?? this.agc,
      );

  @override
  bool operator ==(Object other) =>
      other is EcConfig && jsonEqual(toJson(), other.toJson());

  @override
  int get hashCode => jsonHash(toJson());

  @override
  String toString() => 'EcConfig(${toJson()})';
}

class JbConfig {
  const JbConfig({
    this.initMs = -1,
    this.minPreMs = -1,
    this.maxPreMs = -1,
    this.maxMs = -1,
  });

  final int initMs;
  final int minPreMs;
  final int maxPreMs;
  final int maxMs;

  factory JbConfig.fromJson(Map<String, dynamic> j) => JbConfig(
    initMs: asInt(j['initMs'], -1),
    minPreMs: asInt(j['minPreMs'], -1),
    maxPreMs: asInt(j['maxPreMs'], -1),
    maxMs: asInt(j['maxMs'], -1),
  );

  Map<String, dynamic> toJson() => {
    'initMs': initMs,
    'minPreMs': minPreMs,
    'maxPreMs': maxPreMs,
    'maxMs': maxMs,
  };

  @override
  bool operator ==(Object other) =>
      other is JbConfig && jsonEqual(toJson(), other.toJson());

  @override
  int get hashCode => jsonHash(toJson());

  @override
  String toString() => 'JbConfig(${toJson()})';
}

class MediaConfig {
  const MediaConfig({
    this.clockRate = 0,
    this.sndClockRate = 0,
    this.channelCount = 1,
    this.ec = const EcConfig(),
    this.vad = false,
    this.quality = 8,
    this.ptime = 20,
    this.jb = const JbConfig(),
    this.rtpPort = 4000,
    this.rtpPortRange = 0,
    this.sndMode = SndMode.auto,
    this.noAudioDevice = false,
    this.voiceIsolation = const VoiceIsolationConfig(),
  });

  final int clockRate;
  final int sndClockRate;
  final int channelCount;
  final EcConfig ec;
  final bool vad;
  final int quality;
  final int ptime;
  final JbConfig jb;
  final int rtpPort;
  final int rtpPortRange;
  final SndMode sndMode;
  final bool noAudioDevice;
  final VoiceIsolationConfig voiceIsolation;

  factory MediaConfig.fromJson(Map<String, dynamic> j) => MediaConfig(
    clockRate: asInt(j['clockRate'], 0),
    sndClockRate: asInt(j['sndClockRate'], 0),
    channelCount: asInt(j['channelCount'], 1),
    ec: j['ec'] is Map ? EcConfig.fromJson(asMap(j['ec'])) : const EcConfig(),
    vad: asBool(j['vad'], false),
    quality: asInt(j['quality'], 8),
    ptime: asInt(j['ptime'], 20),
    jb: j['jb'] is Map ? JbConfig.fromJson(asMap(j['jb'])) : const JbConfig(),
    rtpPort: asInt(j['rtpPort'], 4000),
    rtpPortRange: asInt(j['rtpPortRange'], 0),
    sndMode: SndMode.parse(j['sndMode'], SndMode.auto),
    noAudioDevice: asBool(j['noAudioDevice'], false),
    voiceIsolation: j['voiceIsolation'] is Map
        ? VoiceIsolationConfig.fromJson(asMap(j['voiceIsolation']))
        : const VoiceIsolationConfig(),
  );

  Map<String, dynamic> toJson() => {
    'clockRate': clockRate,
    'sndClockRate': sndClockRate,
    'channelCount': channelCount,
    'ec': ec.toJson(),
    'vad': vad,
    'quality': quality,
    'ptime': ptime,
    'jb': jb.toJson(),
    'rtpPort': rtpPort,
    'rtpPortRange': rtpPortRange,
    'sndMode': sndMode.wire,
    'noAudioDevice': noAudioDevice,
    'voiceIsolation': voiceIsolation.toJson(),
  };

  MediaConfig copyWith({
    int? clockRate,
    int? sndClockRate,
    int? channelCount,
    EcConfig? ec,
    bool? vad,
    int? quality,
    int? ptime,
    JbConfig? jb,
    int? rtpPort,
    int? rtpPortRange,
    SndMode? sndMode,
    bool? noAudioDevice,
    VoiceIsolationConfig? voiceIsolation,
  }) => MediaConfig(
    clockRate: clockRate ?? this.clockRate,
    sndClockRate: sndClockRate ?? this.sndClockRate,
    channelCount: channelCount ?? this.channelCount,
    ec: ec ?? this.ec,
    vad: vad ?? this.vad,
    quality: quality ?? this.quality,
    ptime: ptime ?? this.ptime,
    jb: jb ?? this.jb,
    rtpPort: rtpPort ?? this.rtpPort,
    rtpPortRange: rtpPortRange ?? this.rtpPortRange,
    sndMode: sndMode ?? this.sndMode,
    noAudioDevice: noAudioDevice ?? this.noAudioDevice,
    voiceIsolation: voiceIsolation ?? this.voiceIsolation,
  );

  @override
  bool operator ==(Object other) =>
      other is MediaConfig && jsonEqual(toJson(), other.toJson());

  @override
  int get hashCode => jsonHash(toJson());

  @override
  String toString() => 'MediaConfig(${toJson()})';
}

class CoreConfig {
  const CoreConfig({
    this.userAgent = 'SoftphonePro/1.0',
    this.logLevel = 3,
    this.logForward = false,
    this.sipTrace = false,
    this.logFile,
    this.publicAddr,
    this.nameservers,
    this.stunServers = const ['stun.l.google.com:19302'],
    this.stunIgnoreFailure = true,
    this.maxCalls = 16,
    this.incomingAutoRingMs = 1500,
    this.incomingUnattendedMs = 30000,
    this.statsIntervalMs = 0,
    this.transports = const TransportConfig(),
    this.lan = const LanConfig(),
    this.media = const MediaConfig(),
  });

  final String userAgent;
  final int logLevel;
  final bool logForward;
  final bool sipTrace;
  final String? logFile;
  final String? publicAddr;

  /// null = "auto" (native detection); empty = OS resolver only.
  final List<String>? nameservers;
  final List<String> stunServers;
  final bool stunIgnoreFailure;
  final int maxCalls;
  final int incomingAutoRingMs;
  final int incomingUnattendedMs;
  final int statsIntervalMs;
  final TransportConfig transports;
  final LanConfig lan;
  final MediaConfig media;

  factory CoreConfig.fromJson(Map<String, dynamic> j) => CoreConfig(
    userAgent: asString(j['userAgent'], 'SoftphonePro/1.0'),
    logLevel: asInt(j['logLevel'], 3),
    logForward: asBool(j['logForward'], false),
    sipTrace: asBool(j['sipTrace'], false),
    logFile: asStringN(j['logFile']),
    publicAddr: asStringN(j['publicAddr']),
    nameservers: j['nameservers'] is List
        ? asStringList(j['nameservers'])
        : null,
    stunServers: asStringList(j['stunServers'], const [
      'stun.l.google.com:19302',
    ]),
    stunIgnoreFailure: asBool(j['stunIgnoreFailure'], true),
    maxCalls: asInt(j['maxCalls'], 16),
    incomingAutoRingMs: asInt(j['incomingAutoRingMs'], 1500),
    incomingUnattendedMs: asInt(j['incomingUnattendedMs'], 30000),
    statsIntervalMs: asInt(j['statsIntervalMs'], 0),
    transports: j['transports'] is Map
        ? TransportConfig.fromJson(asMap(j['transports']))
        : const TransportConfig(),
    lan: j['lan'] is Map
        ? LanConfig.fromJson(asMap(j['lan']))
        : const LanConfig(),
    media: j['media'] is Map
        ? MediaConfig.fromJson(asMap(j['media']))
        : const MediaConfig(),
  );

  Map<String, dynamic> toJson() => {
    'userAgent': userAgent,
    'logLevel': logLevel,
    'logForward': logForward,
    'sipTrace': sipTrace,
    'logFile': logFile,
    'publicAddr': publicAddr,
    'nameservers': nameservers ?? 'auto',
    'stunServers': stunServers,
    'stunIgnoreFailure': stunIgnoreFailure,
    'maxCalls': maxCalls,
    'incomingAutoRingMs': incomingAutoRingMs,
    'incomingUnattendedMs': incomingUnattendedMs,
    'statsIntervalMs': statsIntervalMs,
    'transports': transports.toJson(),
    'lan': lan.toJson(),
    'media': media.toJson(),
  };

  CoreConfig copyWith({
    String? userAgent,
    int? logLevel,
    bool? logForward,
    bool? sipTrace,
    String? logFile,
    String? publicAddr,
    List<String>? nameservers,
    List<String>? stunServers,
    bool? stunIgnoreFailure,
    int? maxCalls,
    int? incomingAutoRingMs,
    int? incomingUnattendedMs,
    int? statsIntervalMs,
    TransportConfig? transports,
    LanConfig? lan,
    MediaConfig? media,
  }) => CoreConfig(
    userAgent: userAgent ?? this.userAgent,
    logLevel: logLevel ?? this.logLevel,
    logForward: logForward ?? this.logForward,
    sipTrace: sipTrace ?? this.sipTrace,
    logFile: logFile ?? this.logFile,
    publicAddr: publicAddr ?? this.publicAddr,
    nameservers: nameservers ?? this.nameservers,
    stunServers: stunServers ?? this.stunServers,
    stunIgnoreFailure: stunIgnoreFailure ?? this.stunIgnoreFailure,
    maxCalls: maxCalls ?? this.maxCalls,
    incomingAutoRingMs: incomingAutoRingMs ?? this.incomingAutoRingMs,
    incomingUnattendedMs: incomingUnattendedMs ?? this.incomingUnattendedMs,
    statsIntervalMs: statsIntervalMs ?? this.statsIntervalMs,
    transports: transports ?? this.transports,
    lan: lan ?? this.lan,
    media: media ?? this.media,
  );

  @override
  bool operator ==(Object other) =>
      other is CoreConfig && jsonEqual(toJson(), other.toJson());

  @override
  int get hashCode => jsonHash(toJson());

  @override
  String toString() => 'CoreConfig(${toJson()})';
}

class TransportInfo {
  const TransportInfo({
    this.id = 0,
    this.type = '',
    this.local = '',
    this.ipv6 = false,
  });

  final int id;
  final String type;
  final String local;
  final bool ipv6;

  factory TransportInfo.fromJson(Map<String, dynamic> j) => TransportInfo(
    id: asInt(j['id'], 0),
    type: asString(j['type'], ''),
    local: asString(j['local'], ''),
    ipv6: asBool(j['ipv6'], false),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type,
    'local': local,
    'ipv6': ipv6,
  };

  @override
  bool operator ==(Object other) =>
      other is TransportInfo && jsonEqual(toJson(), other.toJson());

  @override
  int get hashCode => jsonHash(toJson());

  @override
  String toString() => 'TransportInfo(${toJson()})';
}

class LanInfo {
  const LanInfo({this.acc = 0, this.port = 0, this.transport = ''});

  final int acc;
  final int port;
  final String transport;

  factory LanInfo.fromJson(Map<String, dynamic> j) => LanInfo(
    acc: asInt(j['acc'], 0),
    port: asInt(j['port'], 0),
    transport: asString(j['transport'], ''),
  );

  Map<String, dynamic> toJson() => {
    'acc': acc,
    'port': port,
    'transport': transport,
  };

  @override
  bool operator ==(Object other) =>
      other is LanInfo && jsonEqual(toJson(), other.toJson());

  @override
  int get hashCode => jsonHash(toJson());

  @override
  String toString() => 'LanInfo(${toJson()})';
}

class CoreStartResult {
  const CoreStartResult({
    this.version = '',
    this.pjsip = '',
    this.transports = const <TransportInfo>[],
    this.lan,
    this.directAcc,
  });

  final String version;
  final String pjsip;
  final List<TransportInfo> transports;
  final LanInfo? lan;
  final int? directAcc;

  factory CoreStartResult.fromJson(Map<String, dynamic> j) => CoreStartResult(
    version: asString(j['version'], ''),
    pjsip: asString(j['pjsip'], ''),
    transports: asList(
      j['transports'],
    ).map((e) => TransportInfo.fromJson(asMap(e))).toList(),
    lan: j['lan'] is Map ? LanInfo.fromJson(asMap(j['lan'])) : null,
    directAcc: asIntN(asMap(j['direct'])['acc']),
  );

  Map<String, dynamic> toJson() => {
    'version': version,
    'pjsip': pjsip,
    'transports': transports.map((e) => e.toJson()).toList(),
    'lan': lan?.toJson(),
    'directAcc': {'acc': directAcc},
  };

  @override
  bool operator ==(Object other) =>
      other is CoreStartResult && jsonEqual(toJson(), other.toJson());

  @override
  int get hashCode => jsonHash(toJson());

  @override
  String toString() => 'CoreStartResult(${toJson()})';
}

class SoundDeviceInfo {
  const SoundDeviceInfo({
    this.capture = '',
    this.playback = '',
    this.open = false,
  });

  final String capture;
  final String playback;
  final bool open;

  factory SoundDeviceInfo.fromJson(Map<String, dynamic> j) => SoundDeviceInfo(
    capture: asString(j['capture'], ''),
    playback: asString(j['playback'], ''),
    open: asBool(j['open'], false),
  );

  Map<String, dynamic> toJson() => {
    'capture': capture,
    'playback': playback,
    'open': open,
  };

  @override
  bool operator ==(Object other) =>
      other is SoundDeviceInfo && jsonEqual(toJson(), other.toJson());

  @override
  int get hashCode => jsonHash(toJson());

  @override
  String toString() => 'SoundDeviceInfo(${toJson()})';
}

class CoreInfo {
  const CoreInfo({
    this.version = '',
    this.pjsip = '',
    this.started = false,
    this.accounts = 0,
    this.calls = 0,
    this.natType,
    this.sndMode = SndMode.auto,
    this.soundDevice = const SoundDeviceInfo(),
  });

  final String version;
  final String pjsip;
  final bool started;
  final int accounts;
  final int calls;
  final String? natType;
  final SndMode sndMode;
  final SoundDeviceInfo soundDevice;

  factory CoreInfo.fromJson(Map<String, dynamic> j) => CoreInfo(
    version: asString(j['version'], ''),
    pjsip: asString(j['pjsip'], ''),
    started: asBool(j['started'], false),
    accounts: asInt(j['accounts'], 0),
    calls: asInt(j['calls'], 0),
    natType: asStringN(j['natType']),
    sndMode: SndMode.parse(j['sndMode'], SndMode.auto),
    soundDevice: j['soundDevice'] is Map
        ? SoundDeviceInfo.fromJson(asMap(j['soundDevice']))
        : const SoundDeviceInfo(),
  );

  Map<String, dynamic> toJson() => {
    'version': version,
    'pjsip': pjsip,
    'started': started,
    'accounts': accounts,
    'calls': calls,
    'natType': natType,
    'sndMode': sndMode.wire,
    'soundDevice': soundDevice.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      other is CoreInfo && jsonEqual(toJson(), other.toJson());

  @override
  int get hashCode => jsonHash(toJson());

  @override
  String toString() => 'CoreInfo(${toJson()})';
}

class TlsPin {
  const TlsPin({this.host = '', this.sha256 = ''});

  final String host;
  final String sha256;

  factory TlsPin.fromJson(Map<String, dynamic> j) =>
      TlsPin(host: asString(j['host'], ''), sha256: asString(j['sha256'], ''));

  Map<String, dynamic> toJson() => {'host': host, 'sha256': sha256};

  @override
  bool operator ==(Object other) =>
      other is TlsPin && jsonEqual(toJson(), other.toJson());

  @override
  int get hashCode => jsonHash(toJson());

  @override
  String toString() => 'TlsPin(${toJson()})';
}

class SrvRecord {
  const SrvRecord({
    this.target = '',
    this.port = 0,
    this.priority = 0,
    this.weight = 0,
  });

  final String target;
  final int port;
  final int priority;
  final int weight;

  factory SrvRecord.fromJson(Map<String, dynamic> j) => SrvRecord(
    target: asString(j['target'], ''),
    port: asInt(j['port'], 0),
    priority: asInt(j['priority'], 0),
    weight: asInt(j['weight'], 0),
  );

  Map<String, dynamic> toJson() => {
    'target': target,
    'port': port,
    'priority': priority,
    'weight': weight,
  };

  @override
  bool operator ==(Object other) =>
      other is SrvRecord && jsonEqual(toJson(), other.toJson());

  @override
  int get hashCode => jsonHash(toJson());

  @override
  String toString() => 'SrvRecord(${toJson()})';
}

class ResolveResult {
  const ResolveResult({
    this.addresses = const <String>[],
    this.srv = const <SrvRecord>[],
  });

  final List<String> addresses;
  final List<SrvRecord> srv;

  factory ResolveResult.fromJson(Map<String, dynamic> j) => ResolveResult(
    addresses: asStringList(j['addresses'], const <String>[]),
    srv: asList(j['srv']).map((e) => SrvRecord.fromJson(asMap(e))).toList(),
  );

  Map<String, dynamic> toJson() => {
    'addresses': addresses,
    'srv': srv.map((e) => e.toJson()).toList(),
  };

  @override
  bool operator ==(Object other) =>
      other is ResolveResult && jsonEqual(toJson(), other.toJson());

  @override
  int get hashCode => jsonHash(toJson());

  @override
  String toString() => 'ResolveResult(${toJson()})';
}

class CallRef {
  const CallRef({this.cid = 0, this.call = 0});

  final int cid;
  final int call;

  factory CallRef.fromJson(Map<String, dynamic> j) =>
      CallRef(cid: asInt(j['cid'], 0), call: asInt(j['call'], 0));

  Map<String, dynamic> toJson() => {'cid': cid, 'call': call};

  @override
  bool operator ==(Object other) =>
      other is CallRef && jsonEqual(toJson(), other.toJson());

  @override
  int get hashCode => jsonHash(toJson());

  @override
  String toString() => 'CallRef(${toJson()})';
}

class RecordingResult {
  const RecordingResult({
    this.file = '',
    this.durationMs = 0,
    this.format = RecordFormat.wav,
    this.bytes = 0,
  });

  final String file;
  final int durationMs;

  /// Recording format (contract v1.1); `wav` when the engine omits it.
  final RecordFormat format;

  /// File size in bytes (contract v1.1); 0 when unknown.
  final int bytes;

  factory RecordingResult.fromJson(Map<String, dynamic> j) => RecordingResult(
    file: asString(j['file'], ''),
    durationMs: asInt(j['durationMs'], 0),
    format: RecordFormat.parse(j['format']),
    bytes: asInt(j['bytes'], 0),
  );

  Map<String, dynamic> toJson() => {
    'file': file,
    'durationMs': durationMs,
    'format': format.wire,
    'bytes': bytes,
  };

  RecordingResult copyWith({
    String? file,
    int? durationMs,
    RecordFormat? format,
    int? bytes,
  }) => RecordingResult(
    file: file ?? this.file,
    durationMs: durationMs ?? this.durationMs,
    format: format ?? this.format,
    bytes: bytes ?? this.bytes,
  );

  @override
  bool operator ==(Object other) =>
      other is RecordingResult && jsonEqual(toJson(), other.toJson());

  @override
  int get hashCode => jsonHash(toJson());

  @override
  String toString() => 'RecordingResult(${toJson()})';
}

/// Per-call meter values (0-255) from `media.levels`.
class CallLevel {
  const CallLevel({required this.cid, this.rx = 0, this.tx = 0});

  final int cid;
  final int rx;
  final int tx;

  factory CallLevel.fromJson(Map<String, dynamic> j) => CallLevel(
    cid: asInt(j['cid']),
    rx: asInt(j['rx'], 0),
    tx: asInt(j['tx'], 0),
  );

  Map<String, dynamic> toJson() => {'cid': cid, 'rx': rx, 'tx': tx};

  @override
  bool operator ==(Object other) =>
      other is CallLevel && jsonEqual(toJson(), other.toJson());

  @override
  int get hashCode => jsonHash(toJson());

  @override
  String toString() => 'CallLevel(${toJson()})';
}

/// Meter values (0-255, perceptual) from `media.levels`. Engines that predate
/// the musicbed omit [musicbed] and [calls]; they default to 0 / empty.
class MediaLevels {
  const MediaLevels({
    this.mic = 0,
    this.speaker = 0,
    this.musicbed = 0,
    this.send = 0,
    this.calls = const [],
  });

  final int mic;
  final int speaker;
  final int musicbed;

  /// Level of the mix that would be sent to callers (mic + musicbed); 0 when
  /// the live monitor is off or the engine predates it (contract v1.3).
  final int send;
  final List<CallLevel> calls;

  factory MediaLevels.fromJson(Map<String, dynamic> j) => MediaLevels(
    mic: asInt(j['mic'], 0),
    speaker: asInt(j['speaker'], 0),
    musicbed: asInt(j['musicbed'], 0),
    send: asInt(j['send'], 0),
    calls: [
      for (final c in asList(j['calls']))
        if (c is Map) CallLevel.fromJson(asMap(c)),
    ],
  );

  Map<String, dynamic> toJson() => {
    'mic': mic,
    'speaker': speaker,
    'musicbed': musicbed,
    'send': send,
    'calls': [for (final c in calls) c.toJson()],
  };

  @override
  bool operator ==(Object other) =>
      other is MediaLevels && jsonEqual(toJson(), other.toJson());

  @override
  int get hashCode => jsonHash(toJson());

  @override
  String toString() => 'MediaLevels(${toJson()})';
}
