// Engine API models (see docs/ENGINE_API.md). Tolerant fromJson: missing or
// extra fields never throw.

// ignore_for_file: unused_import

import 'json_util.dart';
import 'models.dart';

class TurnConfig {
  const TurnConfig({
    this.enabled = false,
    this.server = '',
    this.username = '',
    this.password = '',
    this.transport = 'udp',
  });

  final bool enabled;
  final String server;
  final String username;
  final String password;
  final String transport;

  factory TurnConfig.fromJson(Map<String, dynamic> j) => TurnConfig(
    enabled: asBool(j['enabled'], false),
    server: asString(j['server'], ''),
    username: asString(j['username'], ''),
    password: asString(j['password'], ''),
    transport: asString(j['transport'], 'udp'),
  );

  Map<String, dynamic> toJson() => {
    'enabled': enabled,
    'server': server,
    'username': username,
    'password': password,
    'transport': transport,
  };

  TurnConfig copyWith({
    bool? enabled,
    String? server,
    String? username,
    String? password,
    String? transport,
  }) => TurnConfig(
    enabled: enabled ?? this.enabled,
    server: server ?? this.server,
    username: username ?? this.username,
    password: password ?? this.password,
    transport: transport ?? this.transport,
  );

  @override
  bool operator ==(Object other) =>
      other is TurnConfig && jsonEqual(toJson(), other.toJson());

  @override
  int get hashCode => jsonHash(toJson());

  @override
  String toString() => 'TurnConfig(${toJson()})';
}

class IpChangeConfig {
  const IpChangeConfig({
    this.shutdownTransport = true,
    this.hangupCalls = false,
    this.reinvite = true,
    this.useUpdate = false,
  });

  final bool shutdownTransport;
  final bool hangupCalls;
  final bool reinvite;
  final bool useUpdate;

  factory IpChangeConfig.fromJson(Map<String, dynamic> j) => IpChangeConfig(
    shutdownTransport: asBool(j['shutdownTransport'], true),
    hangupCalls: asBool(j['hangupCalls'], false),
    reinvite: asBool(j['reinvite'], true),
    useUpdate: asBool(j['useUpdate'], false),
  );

  Map<String, dynamic> toJson() => {
    'shutdownTransport': shutdownTransport,
    'hangupCalls': hangupCalls,
    'reinvite': reinvite,
    'useUpdate': useUpdate,
  };

  IpChangeConfig copyWith({
    bool? shutdownTransport,
    bool? hangupCalls,
    bool? reinvite,
    bool? useUpdate,
  }) => IpChangeConfig(
    shutdownTransport: shutdownTransport ?? this.shutdownTransport,
    hangupCalls: hangupCalls ?? this.hangupCalls,
    reinvite: reinvite ?? this.reinvite,
    useUpdate: useUpdate ?? this.useUpdate,
  );

  @override
  bool operator ==(Object other) =>
      other is IpChangeConfig && jsonEqual(toJson(), other.toJson());

  @override
  int get hashCode => jsonHash(toJson());

  @override
  String toString() => 'IpChangeConfig(${toJson()})';
}

class DscpConfig {
  const DscpConfig({this.sip = 24, this.rtp = 46});

  final int sip;
  final int rtp;

  factory DscpConfig.fromJson(Map<String, dynamic> j) =>
      DscpConfig(sip: asInt(j['sip'], 24), rtp: asInt(j['rtp'], 46));

  Map<String, dynamic> toJson() => {'sip': sip, 'rtp': rtp};

  @override
  bool operator ==(Object other) =>
      other is DscpConfig && jsonEqual(toJson(), other.toJson());

  @override
  int get hashCode => jsonHash(toJson());

  @override
  String toString() => 'DscpConfig(${toJson()})';
}

class IaxConfig {
  const IaxConfig({this.host = '', this.port = 4569, this.context});

  final String host;
  final int port;
  final String? context;

  factory IaxConfig.fromJson(Map<String, dynamic> j) => IaxConfig(
    host: asString(j['host'], ''),
    port: asInt(j['port'], 4569),
    context: asStringN(j['context']),
  );

  Map<String, dynamic> toJson() => {
    'host': host,
    'port': port,
    'context': context,
  };

  IaxConfig copyWith({String? host, int? port, String? context}) => IaxConfig(
    host: host ?? this.host,
    port: port ?? this.port,
    context: context ?? this.context,
  );

  @override
  bool operator ==(Object other) =>
      other is IaxConfig && jsonEqual(toJson(), other.toJson());

  @override
  int get hashCode => jsonHash(toJson());

  @override
  String toString() => 'IaxConfig(${toJson()})';
}

class AccountConfig {
  const AccountConfig({
    this.uid = '',
    this.proto = SipProto.sip,
    this.displayName = '',
    this.username = '',
    this.authUser,
    this.password = '',
    this.domain = '',
    this.registrar,
    this.proxies = const <String>[],
    this.regUseProxy = 3,
    this.transport = AccTransport.udp,
    this.register = true,
    this.regExpires = 300,
    this.regRetrySec = 30,
    this.regFirstRetrySec = 5,
    this.regRetryRandomSec = 10,
    this.regDelayBeforeRefreshSec = 5,
    this.unregTimeoutMs = 4000,
    this.dropCallsOnRegFail = false,
    this.keepAliveSec = 15,
    this.localPort = 0,
    this.contactUseSrcPort = true,
    this.publishPresence = false,
    this.mwi = true,
    this.mwiExpires = 3600,
    this.watcherPolicy = AcceptPolicy.accept,
    this.referPolicy = AcceptPolicy.accept,
    this.redirect = RedirectPolicy.auto,
    this.srtp = SrtpMode.off,
    this.srtpSecureSignaling = 0,
    this.srtpKeying = const [SrtpKeying.sdes],
    this.srtpCryptos = const <String>[],
    this.ice = false,
    this.rtcpMux = false,
    this.turn = const TurnConfig(),
    this.useStun = true,
    this.contactRewrite = true,
    this.viaRewrite = true,
    this.sdpNatRewrite = false,
    this.sipOutbound = false,
    this.sessionTimers = SessionTimers.optional,
    this.timerSe = 1800,
    this.use100rel = false,
    this.holdType = HoldType.rfc3264,
    this.lockCodec = true,
    this.streamKeepAlive = true,
    this.dtmfMethod = DtmfMethod.rfc2833,
    this.codecs = const <String>[],
    this.callerId,
    this.privacy = false,
    this.headers = const <String, String>{},
    this.userAgent,
    this.authAlgorithm = 'auto',
    this.ipv6Sip = Ipv6Mode.disabled,
    this.ipv6Media = Ipv6Mode.disabled,
    this.ipChange = const IpChangeConfig(),
    this.dscp = const DscpConfig(),
    this.voicemailNumber,
    this.iax = const IaxConfig(),
  });

  final String uid;
  final SipProto proto;
  final String displayName;
  final String username;
  final String? authUser;
  final String password;
  final String domain;
  final String? registrar;
  final List<String> proxies;
  final int regUseProxy;
  final AccTransport transport;
  final bool register;
  final int regExpires;
  final int regRetrySec;
  final int regFirstRetrySec;
  final int regRetryRandomSec;
  final int regDelayBeforeRefreshSec;
  final int unregTimeoutMs;
  final bool dropCallsOnRegFail;
  final int keepAliveSec;
  final int localPort;
  final bool contactUseSrcPort;
  final bool publishPresence;
  final bool mwi;
  final int mwiExpires;
  final AcceptPolicy watcherPolicy;
  final AcceptPolicy referPolicy;
  final RedirectPolicy redirect;
  final SrtpMode srtp;
  final int srtpSecureSignaling;
  final List<SrtpKeying> srtpKeying;
  final List<String> srtpCryptos;
  final bool ice;
  final bool rtcpMux;
  final TurnConfig turn;
  final bool useStun;
  final bool contactRewrite;
  final bool viaRewrite;
  final bool sdpNatRewrite;
  final bool sipOutbound;
  final SessionTimers sessionTimers;
  final int timerSe;
  final bool use100rel;
  final HoldType holdType;
  final bool lockCodec;
  final bool streamKeepAlive;
  final DtmfMethod dtmfMethod;
  final List<String> codecs;
  final String? callerId;
  final bool privacy;
  final Map<String, String> headers;
  final String? userAgent;
  final String authAlgorithm;
  final Ipv6Mode ipv6Sip;
  final Ipv6Mode ipv6Media;
  final IpChangeConfig ipChange;
  final DscpConfig dscp;
  final String? voicemailNumber;
  final IaxConfig iax;

  factory AccountConfig.fromJson(Map<String, dynamic> j) => AccountConfig(
    uid: asString(j['uid'], ''),
    proto: SipProto.parse(j['proto'], SipProto.sip),
    displayName: asString(j['displayName'], ''),
    username: asString(j['username'], ''),
    authUser: asStringN(j['authUser']),
    password: asString(j['password'], ''),
    domain: asString(j['domain'], ''),
    registrar: asStringN(j['registrar']),
    proxies: asStringList(j['proxies'], const <String>[]),
    regUseProxy: asInt(j['regUseProxy'], 3),
    transport: AccTransport.parse(j['transport'], AccTransport.udp),
    register: asBool(j['register'], true),
    regExpires: asInt(j['regExpires'], 300),
    regRetrySec: asInt(j['regRetrySec'], 30),
    regFirstRetrySec: asInt(j['regFirstRetrySec'], 5),
    regRetryRandomSec: asInt(j['regRetryRandomSec'], 10),
    regDelayBeforeRefreshSec: asInt(j['regDelayBeforeRefreshSec'], 5),
    unregTimeoutMs: asInt(j['unregTimeoutMs'], 4000),
    dropCallsOnRegFail: asBool(j['dropCallsOnRegFail'], false),
    keepAliveSec: asInt(j['keepAliveSec'], 15),
    localPort: asInt(j['localPort'], 0),
    contactUseSrcPort: asBool(j['contactUseSrcPort'], true),
    publishPresence: asBool(j['publishPresence'], false),
    mwi: asBool(j['mwi'], true),
    mwiExpires: asInt(j['mwiExpires'], 3600),
    watcherPolicy: AcceptPolicy.parse(j['watcherPolicy'], AcceptPolicy.accept),
    referPolicy: AcceptPolicy.parse(j['referPolicy'], AcceptPolicy.accept),
    redirect: RedirectPolicy.parse(j['redirect'], RedirectPolicy.auto),
    srtp: SrtpMode.parse(j['srtp'], SrtpMode.off),
    srtpSecureSignaling: asInt(j['srtpSecureSignaling'], 0),
    srtpKeying: j['srtpKeying'] is List
        ? asList(j['srtpKeying']).map((e) => SrtpKeying.parse(e)).toList()
        : const [SrtpKeying.sdes],
    srtpCryptos: asStringList(j['srtpCryptos'], const <String>[]),
    ice: asBool(j['ice'], false),
    rtcpMux: asBool(j['rtcpMux'], false),
    turn: j['turn'] is Map
        ? TurnConfig.fromJson(asMap(j['turn']))
        : const TurnConfig(),
    useStun: asBool(j['useStun'], true),
    contactRewrite: asBool(j['contactRewrite'], true),
    viaRewrite: asBool(j['viaRewrite'], true),
    sdpNatRewrite: asBool(j['sdpNatRewrite'], false),
    sipOutbound: asBool(j['sipOutbound'], false),
    sessionTimers: SessionTimers.parse(
      j['sessionTimers'],
      SessionTimers.optional,
    ),
    timerSe: asInt(j['timerSe'], 1800),
    use100rel: asBool(j['use100rel'], false),
    holdType: HoldType.parse(j['holdType'], HoldType.rfc3264),
    lockCodec: asBool(j['lockCodec'], true),
    streamKeepAlive: asBool(j['streamKeepAlive'], true),
    dtmfMethod: DtmfMethod.parse(j['dtmfMethod'], DtmfMethod.rfc2833),
    codecs: asStringList(j['codecs'], const <String>[]),
    callerId: asStringN(j['callerId']),
    privacy: asBool(j['privacy'], false),
    headers: asStringMap(j['headers']),
    userAgent: asStringN(j['userAgent']),
    authAlgorithm: asString(j['authAlgorithm'], 'auto'),
    ipv6Sip: Ipv6Mode.parse(j['ipv6Sip'], Ipv6Mode.disabled),
    ipv6Media: Ipv6Mode.parse(j['ipv6Media'], Ipv6Mode.disabled),
    ipChange: j['ipChange'] is Map
        ? IpChangeConfig.fromJson(asMap(j['ipChange']))
        : const IpChangeConfig(),
    dscp: j['dscp'] is Map
        ? DscpConfig.fromJson(asMap(j['dscp']))
        : const DscpConfig(),
    voicemailNumber: asStringN(j['voicemailNumber']),
    iax: j['iax'] is Map
        ? IaxConfig.fromJson(asMap(j['iax']))
        : const IaxConfig(),
  );

  Map<String, dynamic> toJson() => {
    'uid': uid,
    'proto': proto.wire,
    'displayName': displayName,
    'username': username,
    'authUser': authUser,
    'password': password,
    'domain': domain,
    'registrar': registrar,
    'proxies': proxies,
    'regUseProxy': regUseProxy,
    'transport': transport.wire,
    'register': register,
    'regExpires': regExpires,
    'regRetrySec': regRetrySec,
    'regFirstRetrySec': regFirstRetrySec,
    'regRetryRandomSec': regRetryRandomSec,
    'regDelayBeforeRefreshSec': regDelayBeforeRefreshSec,
    'unregTimeoutMs': unregTimeoutMs,
    'dropCallsOnRegFail': dropCallsOnRegFail,
    'keepAliveSec': keepAliveSec,
    'localPort': localPort,
    'contactUseSrcPort': contactUseSrcPort,
    'publishPresence': publishPresence,
    'mwi': mwi,
    'mwiExpires': mwiExpires,
    'watcherPolicy': watcherPolicy.wire,
    'referPolicy': referPolicy.wire,
    'redirect': redirect.wire,
    'srtp': srtp.wire,
    'srtpSecureSignaling': srtpSecureSignaling,
    'srtpKeying': srtpKeying.map((e) => e.wire).toList(),
    'srtpCryptos': srtpCryptos,
    'ice': ice,
    'rtcpMux': rtcpMux,
    'turn': turn.toJson(),
    'useStun': useStun,
    'contactRewrite': contactRewrite,
    'viaRewrite': viaRewrite,
    'sdpNatRewrite': sdpNatRewrite,
    'sipOutbound': sipOutbound,
    'sessionTimers': sessionTimers.wire,
    'timerSe': timerSe,
    'use100rel': use100rel,
    'holdType': holdType.wire,
    'lockCodec': lockCodec,
    'streamKeepAlive': streamKeepAlive,
    'dtmfMethod': dtmfMethod.wire,
    'codecs': codecs,
    'callerId': callerId,
    'privacy': privacy,
    'headers': headers,
    'userAgent': userAgent,
    'authAlgorithm': authAlgorithm,
    'ipv6Sip': ipv6Sip.wire,
    'ipv6Media': ipv6Media.wire,
    'ipChange': ipChange.toJson(),
    'dscp': dscp.toJson(),
    'voicemailNumber': voicemailNumber,
    'iax': iax.toJson(),
  };

  AccountConfig copyWith({
    String? uid,
    SipProto? proto,
    String? displayName,
    String? username,
    String? authUser,
    String? password,
    String? domain,
    String? registrar,
    List<String>? proxies,
    int? regUseProxy,
    AccTransport? transport,
    bool? register,
    int? regExpires,
    int? regRetrySec,
    int? regFirstRetrySec,
    int? regRetryRandomSec,
    int? regDelayBeforeRefreshSec,
    int? unregTimeoutMs,
    bool? dropCallsOnRegFail,
    int? keepAliveSec,
    int? localPort,
    bool? contactUseSrcPort,
    bool? publishPresence,
    bool? mwi,
    int? mwiExpires,
    AcceptPolicy? watcherPolicy,
    AcceptPolicy? referPolicy,
    RedirectPolicy? redirect,
    SrtpMode? srtp,
    int? srtpSecureSignaling,
    List<SrtpKeying>? srtpKeying,
    List<String>? srtpCryptos,
    bool? ice,
    bool? rtcpMux,
    TurnConfig? turn,
    bool? useStun,
    bool? contactRewrite,
    bool? viaRewrite,
    bool? sdpNatRewrite,
    bool? sipOutbound,
    SessionTimers? sessionTimers,
    int? timerSe,
    bool? use100rel,
    HoldType? holdType,
    bool? lockCodec,
    bool? streamKeepAlive,
    DtmfMethod? dtmfMethod,
    List<String>? codecs,
    String? callerId,
    bool? privacy,
    Map<String, String>? headers,
    String? userAgent,
    String? authAlgorithm,
    Ipv6Mode? ipv6Sip,
    Ipv6Mode? ipv6Media,
    IpChangeConfig? ipChange,
    DscpConfig? dscp,
    String? voicemailNumber,
    IaxConfig? iax,
  }) => AccountConfig(
    uid: uid ?? this.uid,
    proto: proto ?? this.proto,
    displayName: displayName ?? this.displayName,
    username: username ?? this.username,
    authUser: authUser ?? this.authUser,
    password: password ?? this.password,
    domain: domain ?? this.domain,
    registrar: registrar ?? this.registrar,
    proxies: proxies ?? this.proxies,
    regUseProxy: regUseProxy ?? this.regUseProxy,
    transport: transport ?? this.transport,
    register: register ?? this.register,
    regExpires: regExpires ?? this.regExpires,
    regRetrySec: regRetrySec ?? this.regRetrySec,
    regFirstRetrySec: regFirstRetrySec ?? this.regFirstRetrySec,
    regRetryRandomSec: regRetryRandomSec ?? this.regRetryRandomSec,
    regDelayBeforeRefreshSec:
        regDelayBeforeRefreshSec ?? this.regDelayBeforeRefreshSec,
    unregTimeoutMs: unregTimeoutMs ?? this.unregTimeoutMs,
    dropCallsOnRegFail: dropCallsOnRegFail ?? this.dropCallsOnRegFail,
    keepAliveSec: keepAliveSec ?? this.keepAliveSec,
    localPort: localPort ?? this.localPort,
    contactUseSrcPort: contactUseSrcPort ?? this.contactUseSrcPort,
    publishPresence: publishPresence ?? this.publishPresence,
    mwi: mwi ?? this.mwi,
    mwiExpires: mwiExpires ?? this.mwiExpires,
    watcherPolicy: watcherPolicy ?? this.watcherPolicy,
    referPolicy: referPolicy ?? this.referPolicy,
    redirect: redirect ?? this.redirect,
    srtp: srtp ?? this.srtp,
    srtpSecureSignaling: srtpSecureSignaling ?? this.srtpSecureSignaling,
    srtpKeying: srtpKeying ?? this.srtpKeying,
    srtpCryptos: srtpCryptos ?? this.srtpCryptos,
    ice: ice ?? this.ice,
    rtcpMux: rtcpMux ?? this.rtcpMux,
    turn: turn ?? this.turn,
    useStun: useStun ?? this.useStun,
    contactRewrite: contactRewrite ?? this.contactRewrite,
    viaRewrite: viaRewrite ?? this.viaRewrite,
    sdpNatRewrite: sdpNatRewrite ?? this.sdpNatRewrite,
    sipOutbound: sipOutbound ?? this.sipOutbound,
    sessionTimers: sessionTimers ?? this.sessionTimers,
    timerSe: timerSe ?? this.timerSe,
    use100rel: use100rel ?? this.use100rel,
    holdType: holdType ?? this.holdType,
    lockCodec: lockCodec ?? this.lockCodec,
    streamKeepAlive: streamKeepAlive ?? this.streamKeepAlive,
    dtmfMethod: dtmfMethod ?? this.dtmfMethod,
    codecs: codecs ?? this.codecs,
    callerId: callerId ?? this.callerId,
    privacy: privacy ?? this.privacy,
    headers: headers ?? this.headers,
    userAgent: userAgent ?? this.userAgent,
    authAlgorithm: authAlgorithm ?? this.authAlgorithm,
    ipv6Sip: ipv6Sip ?? this.ipv6Sip,
    ipv6Media: ipv6Media ?? this.ipv6Media,
    ipChange: ipChange ?? this.ipChange,
    dscp: dscp ?? this.dscp,
    voicemailNumber: voicemailNumber ?? this.voicemailNumber,
    iax: iax ?? this.iax,
  );

  @override
  bool operator ==(Object other) =>
      other is AccountConfig && jsonEqual(toJson(), other.toJson());

  @override
  int get hashCode => jsonHash(toJson());

  @override
  String toString() => 'AccountConfig(${toJson()})';
}

class AccountInfo {
  const AccountInfo({
    this.acc = 0,
    this.uid = '',
    this.proto = SipProto.sip,
    this.uri = '',
    this.regState = RegState.unknown,
    this.regCode = 0,
    this.regReason = '',
    this.status = 0,
    this.statusText = '',
    this.lastError,
    this.expires = 0,
    this.online = false,
    this.isUnreg = false,
    this.contact = '',
    this.transport = '',
    this.presence = PresenceStatus.unknown,
    this.isLan = false,
    this.isDirect = false,
  });

  final int acc;
  final String uid;
  final SipProto proto;
  final String uri;
  final RegState regState;
  final int regCode;
  final String regReason;
  final int status;
  final String statusText;
  final String? lastError;
  final int expires;
  final bool online;
  final bool isUnreg;
  final String contact;
  final String transport;
  final PresenceStatus presence;
  final bool isLan;
  final bool isDirect;

  factory AccountInfo.fromJson(Map<String, dynamic> j) => AccountInfo(
    acc: asInt(j['acc'], 0),
    uid: asString(j['uid'], ''),
    proto: SipProto.parse(j['proto'], SipProto.sip),
    uri: asString(j['uri'], ''),
    regState: RegState.parse(j['regState'], RegState.unknown),
    regCode: asInt(j['regCode'], 0),
    regReason: asString(j['regReason'], ''),
    status: asInt(j['status'], 0),
    statusText: asString(j['statusText'], ''),
    lastError: asStringN(j['lastError']),
    expires: asInt(j['expires'], 0),
    online: asBool(j['online'], false),
    isUnreg: asBool(j['isUnreg'], false),
    contact: asString(j['contact'], ''),
    transport: asString(j['transport'], ''),
    presence: PresenceStatus.parse(j['presence'], PresenceStatus.unknown),
    isLan: asBool(j['isLan'], false),
    isDirect: asBool(j['isDirect'], false),
  );

  Map<String, dynamic> toJson() => {
    'acc': acc,
    'uid': uid,
    'proto': proto.wire,
    'uri': uri,
    'regState': regState.wire,
    'regCode': regCode,
    'regReason': regReason,
    'status': status,
    'statusText': statusText,
    'lastError': lastError,
    'expires': expires,
    'online': online,
    'isUnreg': isUnreg,
    'contact': contact,
    'transport': transport,
    'presence': presence.wire,
    'isLan': isLan,
    'isDirect': isDirect,
  };

  AccountInfo copyWith({
    int? acc,
    String? uid,
    SipProto? proto,
    String? uri,
    RegState? regState,
    int? regCode,
    String? regReason,
    int? status,
    String? statusText,
    String? lastError,
    int? expires,
    bool? online,
    bool? isUnreg,
    String? contact,
    String? transport,
    PresenceStatus? presence,
    bool? isLan,
    bool? isDirect,
  }) => AccountInfo(
    acc: acc ?? this.acc,
    uid: uid ?? this.uid,
    proto: proto ?? this.proto,
    uri: uri ?? this.uri,
    regState: regState ?? this.regState,
    regCode: regCode ?? this.regCode,
    regReason: regReason ?? this.regReason,
    status: status ?? this.status,
    statusText: statusText ?? this.statusText,
    lastError: lastError ?? this.lastError,
    expires: expires ?? this.expires,
    online: online ?? this.online,
    isUnreg: isUnreg ?? this.isUnreg,
    contact: contact ?? this.contact,
    transport: transport ?? this.transport,
    presence: presence ?? this.presence,
    isLan: isLan ?? this.isLan,
    isDirect: isDirect ?? this.isDirect,
  );

  @override
  bool operator ==(Object other) =>
      other is AccountInfo && jsonEqual(toJson(), other.toJson());

  @override
  int get hashCode => jsonHash(toJson());

  @override
  String toString() => 'AccountInfo(${toJson()})';
}

class MwiInfo {
  const MwiInfo({
    this.acc = 0,
    this.uid = '',
    this.waiting = false,
    this.newMsgs = 0,
    this.oldMsgs = 0,
    this.urgentNew = 0,
    this.urgentOld = 0,
    this.account,
    this.solicited = false,
  });

  final int acc;
  final String uid;
  final bool waiting;
  final int newMsgs;
  final int oldMsgs;
  final int urgentNew;
  final int urgentOld;
  final String? account;
  final bool solicited;

  factory MwiInfo.fromJson(Map<String, dynamic> j) => MwiInfo(
    acc: asInt(j['acc'], 0),
    uid: asString(j['uid'], ''),
    waiting: asBool(j['waiting'], false),
    newMsgs: asInt(j['newMsgs'], 0),
    oldMsgs: asInt(j['oldMsgs'], 0),
    urgentNew: asInt(j['urgentNew'], 0),
    urgentOld: asInt(j['urgentOld'], 0),
    account: asStringN(j['account']),
    solicited: asBool(j['solicited'], false),
  );

  Map<String, dynamic> toJson() => {
    'acc': acc,
    'uid': uid,
    'waiting': waiting,
    'newMsgs': newMsgs,
    'oldMsgs': oldMsgs,
    'urgentNew': urgentNew,
    'urgentOld': urgentOld,
    'account': account,
    'solicited': solicited,
  };

  @override
  bool operator ==(Object other) =>
      other is MwiInfo && jsonEqual(toJson(), other.toJson());

  @override
  int get hashCode => jsonHash(toJson());

  @override
  String toString() => 'MwiInfo(${toJson()})';
}
