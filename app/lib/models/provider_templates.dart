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
  }) {
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
        domain: domain.isEmpty ? domainHint : domain,
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
      ),
    );
  }
}

const List<ProviderTemplate> kProviderTemplates = [
  ProviderTemplate(
    id: 'asterisk',
    name: 'Asterisk / FreePBX',
    description: 'Extension on your own PBX. UDP 5060, STUN on.',
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
    domainHint: 'fs.example.com',
    usernameHint: 'User ID',
    featureCodes: FeatureCodes(park: '*5900', pickupGroup: '*8'),
  ),
  ProviderTemplate(
    id: 'kamailio',
    name: 'Kamailio / OpenSIPS',
    description: 'SIP proxy registrar. TCP recommended behind NAT.',
    domainHint: 'sip.example.com',
    transport: AccTransport.tcp,
  ),
  ProviderTemplate(
    id: 'twilio',
    name: 'Twilio SIP Registration',
    description: 'Elastic SIP trunking / SIP domain credentials. TLS and SRTP.',
    domainHint: 'yourdomain.sip.twilio.com',
    transport: AccTransport.tls,
    srtp: SrtpMode.optional,
    codecs: ['PCMU', 'PCMA'],
  ),
  ProviderTemplate(
    id: 'telnyx',
    name: 'Telnyx',
    description: 'Credential connection. UDP, G.711 / Opus.',
    domainHint: 'sip.telnyx.com',
    codecs: ['PCMU', 'PCMA', 'opus'],
  ),
  ProviderTemplate(
    id: 'voipms',
    name: 'VoIP.ms',
    description: 'Sub-account username and password. Pick the POP closest to you.',
    domainHint: 'atlanta.voip.ms',
    codecs: ['PCMU', 'GSM'],
    usernameHint: 'Sub-account (e.g. 123456_phone)',
  ),
  ProviderTemplate(
    id: 'vonage',
    name: 'Vonage Business',
    description: 'SIP registration with TLS.',
    domainHint: 'sip.vonage.example',
    transport: AccTransport.tls,
    srtp: SrtpMode.optional,
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
