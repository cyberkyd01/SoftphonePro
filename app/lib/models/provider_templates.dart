import 'package:spcore_dart/spcore_dart.dart';

import 'account_profile.dart';

/// Prefilled settings for popular providers and PBXs.
class ProviderTemplate {
  const ProviderTemplate({
    required this.id,
    required this.name,
    required this.description,
    this.domainHint = '',
    this.transport = AccTransport.udp,
    this.useStun = true,
    this.ice = false,
    this.srtp = SrtpMode.off,
    this.codecs = const [],
    this.regExpires = 300,
    this.keepAliveSec = 15,
    this.outboundProxy = '',
    this.usernameHint = 'Extension / username',
    this.featureCodes = const FeatureCodes(),
    this.sessionTimers = SessionTimers.optional,
    this.rtcpMux = false,
    this.proto = SipProto.sip,
    this.defaultPort,
    this.wsPath = '/ws',
    this.rtcpFb = false,
    this.srtpKeying = const [SrtpKeying.sdes],
    this.notes = '',
    this.serverLabel = 'Server / domain',
  });

  final String id;
  final String name;
  final String description;
  final String domainHint;
  final AccTransport transport;
  final bool useStun;
  final bool ice;
  final SrtpMode srtp;
  final List<String> codecs;
  final int regExpires;
  final int keepAliveSec;
  final String outboundProxy;
  final String usernameHint;
  final FeatureCodes featureCodes;
  final SessionTimers sessionTimers;
  final bool rtcpMux;

  /// Protocol of accounts built from this template (SIP or IAX2).
  final SipProto proto;

  /// Port appended to the server when the user typed none (e.g. 8089 for
  /// a WebRTC gateway, 4569 for IAX2 is carried in [IaxConfig] instead).
  final int? defaultPort;
  final String wsPath;
  final bool rtcpFb;
  final List<SrtpKeying> srtpKeying;

  /// Provider-specific setup hints shown in the add-account form.
  final String notes;
  final String serverLabel;

  bool get isIax => proto == SipProto.iax2;

  /// Builds a new profile (not yet persisted) from this template.
  AccountProfile build({
    required String id,
    required String username,
    required String password,
    required String domain,
    String displayName = '',
    String label = '',
    String? authUser,
    int color = 0xFF3F51E0,
    int? port,
    String? iaxContext,
    String? callerId,
  }) {
    var host = domain.trim().isEmpty ? domainHint : domain.trim();
    if (isIax) {
      final p = port ?? defaultPort ?? 4569;
      final ctx = iaxContext?.trim() ?? '';
      return AccountProfile(
        id: id,
        label: label,
        color: color,
        providerTemplateId: this.id,
        featureCodes: featureCodes,
        config: AccountConfig(
          uid: id,
          proto: SipProto.iax2,
          displayName: displayName,
          username: username,
          password: password,
          domain: host,
          register: true,
          useStun: useStun,
          regExpires: regExpires,
          regRetrySec: 30,
          regFirstRetrySec: 5,
          codecs: codecs,
          callerId: (callerId == null || callerId.trim().isEmpty)
              ? null
              : callerId.trim(),
          iax: IaxConfig(host: host, port: p, context: ctx.isEmpty ? null : ctx),
        ),
      );
    }
    final p = port ?? defaultPort;
    if (p != null && !_hasPort(host)) host = '$host:$p';
    return AccountProfile(
      id: id,
      label: label,
      color: color,
      providerTemplateId: this.id,
      featureCodes: featureCodes,
      config: AccountConfig(
        uid: id,
        displayName: displayName,
        username: username,
        authUser: (authUser == null || authUser.isEmpty) ? null : authUser,
        password: password,
        domain: host,
        proxies: outboundProxy.isEmpty ? const [] : [outboundProxy],
        transport: transport,
        regExpires: regExpires,
        keepAliveSec: keepAliveSec,
        useStun: useStun,
        ice: ice,
        srtp: srtp,
        codecs: codecs,
        sessionTimers: sessionTimers,
        rtcpMux: rtcpMux,
        srtpKeying: srtpKeying,
        wsPath: wsPath,
        rtcpFb: rtcpFb,
        callerId: (callerId == null || callerId.trim().isEmpty)
            ? null
            : callerId.trim(),
      ),
    );
  }
}

/// True when [host] already carries an explicit `:port` (IPv6 literals in
/// brackets without a trailing port do not).
bool _hasPort(String host) {
  if (host.startsWith('[')) return host.contains(']:');
  return host.contains(':');
}

const List<ProviderTemplate> kProviderTemplates = [
  ProviderTemplate(
    id: 'asterisk',
    name: 'Asterisk / FreePBX',
    description: 'Extension on your own PBX. UDP 5060, STUN on.',
    notes: 'Use the PJSIP/SIP extension number and its secret. For TLS or '
        'WebRTC change the transport later in the account settings.',
    domainHint: 'pbx.example.com',
    usernameHint: 'Extension (e.g. 1001)',
    featureCodes: FeatureCodes(
      park: '700',
      pickupGroup: '*8',
      pickupDirectedPrefix: '**',
    ),
  ),
  ProviderTemplate(
    id: '3cx',
    name: '3CX',
    description: 'Use the extension, auth ID and password from the 3CX portal.',
    notes: 'In 3CX open the extension, then "Phones > Provisioning" for the '
        'Authentication ID (set it as Authorization user) and password. The '
        'FQDN is the one in your 3CX URL.',
    domainHint: 'company.3cx.eu',
    transport: AccTransport.tcp,
    usernameHint: 'Extension',
    featureCodes: FeatureCodes(park: '*85', pickupGroup: '*8'),
    sessionTimers: SessionTimers.optional,
  ),
  ProviderTemplate(
    id: 'freeswitch',
    name: 'FreeSWITCH',
    description: 'Directory user on a FreeSWITCH server.',
    notes: 'Use the user id and password from the directory. The default '
        'internal profile listens on UDP/TCP 5060.',
    domainHint: 'fs.example.com',
    usernameHint: 'User ID',
    featureCodes: FeatureCodes(park: '*5900', pickupGroup: '*8'),
  ),
  ProviderTemplate(
    id: 'kamailio',
    name: 'Kamailio / OpenSIPS',
    description: 'SIP proxy registrar. TCP recommended behind NAT.',
    notes: 'Use the SIP domain served by your registrar. Add an outbound '
        'proxy in the account settings if the registrar is reached through '
        'a different host.',
    domainHint: 'sip.example.com',
    transport: AccTransport.tcp,
  ),
  ProviderTemplate(
    id: 'twilio',
    name: 'Twilio SIP Registration',
    description: 'Programmable Voice SIP Domain credentials. TLS and SRTP.',
    domainHint: 'yourdomain.sip.twilio.com',
    transport: AccTransport.tls,
    srtp: SrtpMode.optional,
    codecs: ['PCMU/8000/1', 'PCMA/8000/1'],
    usernameHint: 'Credential list username',
    useStun: false,
    notes: 'Create a SIP Domain in the Twilio console, add a Credential List '
        'and enable SIP Registration. Enter the full domain '
        '(name.sip.twilio.com) as the server and the credential list user '
        'and password. TLS uses port 5061. Twilio supports G.711 only.',
  ),
  ProviderTemplate(
    id: 'telnyx',
    name: 'Telnyx',
    description: 'Credential connection. UDP, G.711 / Opus.',
    domainHint: 'sip.telnyx.com',
    codecs: ['PCMU/8000/1', 'PCMA/8000/1', 'opus/48000/2'],
    usernameHint: 'SIP username (credential connection)',
    notes: 'Create a Credential Connection in the Telnyx portal and copy its '
        'SIP username and password (not your portal login). Assign a number '
        'or outbound voice profile to the connection to place and receive '
        'calls.',
  ),
  ProviderTemplate(
    id: 'voipms',
    name: 'VoIP.ms',
    description: 'Sub-account username and password. Pick the POP closest to you.',
    domainHint: 'atlanta.voip.ms',
    codecs: ['PCMU/8000/1', 'GSM/8000/1'],
    usernameHint: 'Sub-account (e.g. 123456_phone)',
    notes: 'Use a sub-account created under Sub Accounts, not your main '
        'account. Choose the server (POP) closest to you from the VoIP.ms '
        'server list and allow it for your IP if required.',
  ),
  ProviderTemplate(
    id: 'vonage',
    name: 'Vonage Business',
    description: 'SIP registration with TLS.',
    domainHint: '',
    notes: 'Vonage Business only offers SIP registration on some plans. '
        'Enter the SIP server, user and password shown in the Vonage admin '
        'portal for the device.',
    transport: AccTransport.tls,
    srtp: SrtpMode.optional,
  ),
  ProviderTemplate(
    id: 'iax2',
    name: 'IAX2 (Asterisk)',
    description: 'Inter-Asterisk eXchange over UDP 4569. No NAT or SRTP settings.',
    domainHint: 'pbx.example.com',
    proto: SipProto.iax2,
    useStun: false,
    codecs: ['PCMU/8000/1', 'PCMA/8000/1', 'GSM/8000/1'],
    regExpires: 60,
    usernameHint: 'IAX2 username',
    serverLabel: 'Server host',
    notes: 'Needs a peer/user in iax.conf (type=friend or user+peer) with '
        'the same secret. Asterisk renews IAX2 registrations every 60 s by '
        'default. The context is optional and is sent as the called '
        'context.',
  ),
  ProviderTemplate(
    id: 'webrtc',
    name: 'WebRTC gateway (WSS)',
    description: 'SIP over secure WebSocket with DTLS-SRTP, ICE and RTCP-mux.',
    domainHint: 'pbx.example.com',
    transport: AccTransport.wss,
    defaultPort: 8089,
    wsPath: '/ws',
    srtp: SrtpMode.mandatory,
    srtpKeying: [SrtpKeying.dtls],
    ice: true,
    rtcpMux: true,
    rtcpFb: true,
    notes: 'For Asterisk (webrtc=yes, http.conf TLS on 8089), FreeSWITCH or '
        'Kamailio WebSocket endpoints. The server needs a valid TLS '
        'certificate. Change the WebSocket path in the account settings if '
        'your gateway does not use /ws.',
  ),
  ProviderTemplate(
    id: 'generic',
    name: 'Generic SIP',
    description: 'Any SIP registrar. Fill in the details yourself.',
  ),
];

ProviderTemplate templateById(String id) => kProviderTemplates.firstWhere(
  (t) => t.id == id,
  orElse: () => kProviderTemplates.last,
);
