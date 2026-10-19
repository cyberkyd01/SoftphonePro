import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:spcore_dart/spcore_dart.dart';

import '../../core/format.dart';
import '../../models/account_profile.dart';
import '../../recordings/recording_rules.dart';
import '../../services/accounts_controller.dart';
import '../pages/audio/audio_ref_tile.dart';
import '../widgets/settings_tiles.dart';
import 'sections.dart';
import 'tls_client_cert_group.dart';

class AccountEditorPage extends ConsumerStatefulWidget {
  const AccountEditorPage({super.key, required this.accountId});
  final String accountId;
  @override
  ConsumerState<AccountEditorPage> createState() => _AccountEditorPageState();
}

class _AccountEditorPageState extends ConsumerState<AccountEditorPage> {
  late AccountProfile _p;
  bool _dirty = false;

  @override
  void initState() {
    super.initState();
    _p = ref.read(accountsProvider).byId(widget.accountId)!;
  }

  void _upd(AccountProfile Function(AccountProfile) f) => setState(() {
    _p = f(_p);
    _dirty = true;
  });
  void _cfg(AccountConfig Function(AccountConfig) f) => _upd((p) => p.copyWith(config: f(p.config)));

  Future<void> _save() async {
    await ref.read(accountsProvider.notifier).update(_p);
    if (mounted) {
      setState(() => _dirty = false);
      context.pop();
    }
  }

  Widget _tx(String title, String value, ValueChanged<String> on, {bool obscure = false, String? hint, String? sub, TextInputType? kb, IconData? icon, String? Function(String)? validator}) =>
      TextTile(title: title, value: value, onChanged: on, obscure: obscure, hint: hint, subtitle: sub, keyboardType: kb, icon: icon, validator: validator);
  Widget _sw(String title, bool v, ValueChanged<bool> on, {String? sub}) => SwitchTile(title: title, subtitle: sub, value: v, onChanged: on);
  Widget _num(String title, int v, ValueChanged<int> on, {String? sub, int? min, int? max}) => TextTile(
    title: title,
    subtitle: sub == null && min != null && max != null ? 'Allowed range $min to $max' : sub,
    value: '$v',
    keyboardType: TextInputType.number,
    validator: (s) => validateInt(s, min: min, max: max),
    onChanged: (s) => on(int.tryParse(s) ?? v),
  );

  @override
  Widget build(BuildContext context) {
    final c = _p.config;
    final acc = ref.watch(accountsProvider);
    final known = ref.watch(codecListProvider).value ?? kFallbackCodecs;
    final codecs = c.codecs.isEmpty ? <String>[] : orderCodecs(known, c.codecs);
    final iax = c.proto == SipProto.iax2;
    final ws = c.transport == AccTransport.ws || c.transport == AccTransport.wss;
    final iaxKnown = const ['PCMU/8000/1', 'PCMA/8000/1', 'GSM/8000/1'];
    final iaxCodecs = orderCodecs(iaxKnown, c.codecs);
    final headersText = c.headers.entries.map((e) => '${e.key}: ${e.value}').join('\n');
    return PopScope(
      canPop: !_dirty,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final discard = await confirm(context, title: 'Discard changes?', message: 'Your edits to this account are not saved.', confirmLabel: 'Discard');
        if (discard && context.mounted) context.pop();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_p.name),
          actions: [
            TextButton(key: const Key('save-account'), onPressed: _dirty ? _save : null, child: const Text('Save')),
            PopupMenuButton<String>(
              onSelected: (v) async {
                if (v == 'delete' && await confirm(context, title: 'Delete ${_p.name}?', message: 'The account and its saved password will be removed from this device.')) {
                  await ref.read(accountsProvider.notifier).remove(_p.id);
                  if (context.mounted) context.go('/settings/accounts');
                }
              },
              itemBuilder: (_) => const [PopupMenuItem(value: 'delete', child: Text('Delete account'))],
            ),
          ],
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: ListView(
              padding: const EdgeInsets.only(bottom: 48),
              children: [
                SettingsGroup(title: 'Basic', children: [
                  _tx('Label', _p.label, (v) => _upd((p) => p.copyWith(label: v)), hint: 'e.g. Office'),
                  _tx('Display name', c.displayName, (v) => _cfg((x) => x.copyWith(displayName: v))),
                  _tx('Username', c.username, (v) => _cfg((x) => x.copyWith(username: v))),
                  ListTile(
                    key: const Key('acc-protocol'),
                    title: const Text('Protocol'),
                    subtitle: const Text('Fixed when the account is created'),
                    trailing: Text(iax ? 'IAX2' : 'SIP', style: Theme.of(context).textTheme.bodyMedium),
                  ),
                  if (!iax) _tx('Authorization user', c.authUser ?? '', (v) => _cfg((x) => AccountConfigX.withAuth(x, v)), hint: 'Same as username', sub: 'Only if the provider uses a different login name than the username'),
                  _tx('Password', c.password, (v) => _cfg((x) => x.copyWith(password: v)), obscure: true),
                  if (iax) ...[
                    _tx('Server host', c.iax.host.isEmpty ? c.domain : c.iax.host, (v) => _cfg((x) => x.copyWith(domain: v, iax: x.iax.copyWith(host: v))), validator: validateHost),
                    _num('Port', c.iax.port, (v) => _cfg((x) => x.copyWith(iax: x.iax.copyWith(port: v))), min: 1, max: 65535, sub: 'IAX2 default is 4569'),
                    _tx('Context', c.iax.context ?? '', (v) => _cfg((x) => x.copyWith(iax: IaxConfig(host: x.iax.host, port: x.iax.port, context: v.isEmpty ? null : v))), hint: 'Not set', sub: 'Optional. Sent to the PBX as the called context'),
                  ] else
                    _tx('Server / domain', c.domain, (v) => _cfg((x) => x.copyWith(domain: v)), validator: validateHost, sub: 'host or host:port'),
                  _sw('Enabled', _p.enabled, (v) => _upd((p) => p.copyWith(enabled: v))),
                  _sw('Default account for outgoing calls', _p.isDefault, (v) => _upd((p) => p.copyWith(isDefault: v))),
                  ListTile(
                    title: const Text('Colour'),
                    trailing: Wrap(spacing: 8, children: [
                      for (final col in kAvatarPalette.take(7))
                        InkResponse(onTap: () => _upd((p) => p.copyWith(color: col)), child: Container(width: 26, height: 26, decoration: BoxDecoration(color: Color(col), shape: BoxShape.circle, border: _p.color == col ? Border.all(width: 3, color: Theme.of(context).colorScheme.onSurface) : null))),
                    ]),
                  ),
                ]),
                if (iax) ...[
                  SettingsGroup(title: 'Registration', children: [
                    _sw('Register', c.register, (v) => _cfg((x) => x.copyWith(register: v)), sub: 'Turn off for peers that need no registration'),
                    _num('Registration expiry (s)', c.regExpires, (v) => _cfg((x) => x.copyWith(regExpires: v)), min: 10, max: 86400, sub: 'Asterisk usually forces 60 s. Range 10 to 86400'),
                    _num('Retry interval (s)', c.regRetrySec, (v) => _cfg((x) => x.copyWith(regRetrySec: v)), min: 0, max: 86400),
                    _num('First retry (s)', c.regFirstRetrySec, (v) => _cfg((x) => x.copyWith(regFirstRetrySec: v)), min: 0, max: 86400),
                  ]),
                  SettingsGroup(
                    title: 'Codecs',
                    footer: 'IAX2 supports G.711 and GSM. Drag to set the preference order.',
                    children: [
                      ReorderableListView(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        buildDefaultDragHandles: false,
                        onReorder: (a, b) {
                          if (b > a) b -= 1;
                          final l = [...iaxCodecs];
                          l.insert(b, l.removeAt(a));
                          _cfg((x) => x.copyWith(codecs: l));
                        },
                        children: [
                          for (var i = 0; i < iaxCodecs.length; i++)
                            ListTile(
                              key: ValueKey('iax-${iaxCodecs[i]}'),
                              leading: ReorderableDragStartListener(index: i, child: const Icon(Icons.drag_indicator_rounded)),
                              title: Text(iaxCodecs[i].split('/').first),
                              trailing: c.codecs.contains(iaxCodecs[i]) || c.codecs.isEmpty
                                  ? IconButton(tooltip: 'Remove ${iaxCodecs[i].split('/').first}', icon: const Icon(Icons.close_rounded), onPressed: iaxCodecs.length <= 1 ? null : () => _cfg((x) => x.copyWith(codecs: iaxCodecs.where((e) => e != iaxCodecs[i]).toList())))
                                  : null,
                            ),
                        ],
                      ),
                      if (iaxCodecs.length < iaxKnown.length)
                        ListTile(
                          leading: const Icon(Icons.add_rounded),
                          title: const Text('Add codec'),
                          onTap: () async {
                            final pick = await showModalBottomSheet<String>(
                              context: context,
                              builder: (ctx) => SafeArea(child: ListView(shrinkWrap: true, children: [for (final k in iaxKnown.where((k) => !iaxCodecs.contains(k))) ListTile(title: Text(k.split('/').first), onTap: () => Navigator.pop(ctx, k))])),
                            );
                            if (pick != null) _cfg((x) => x.copyWith(codecs: [...iaxCodecs, pick]));
                          },
                        ),
                    ],
                  ),
                ] else ...[
                SettingsGroup(title: 'Server and transport', children: [
                  _tx('Registrar override', c.registrar ?? '', (v) => _cfg((x) => AccountConfigX.withRegistrar(x, v)), hint: 'sip:server:5060'),
                  _tx('Backup registrar', _p.backupRegistrar, (v) => _upd((p) => p.copyWith(backupRegistrar: v.trim())), hint: 'None', sub: 'Used after 3 failed attempts; the primary is retried every 5 minutes'),
                  _tx('Outbound proxies', c.proxies.join(', '), (v) => _cfg((x) => x.copyWith(proxies: v.split(RegExp(r'[,\s]+')).where((e) => e.isNotEmpty).toList())), hint: 'None'),
                  SelectTile<AccTransport>(
                    key: const Key('acc-transport'),
                    title: 'Transport',
                    subtitle: c.transport == AccTransport.auto ? 'Looks up the server\'s DNS SRV records and picks TLS, TCP or UDP' : null,
                    value: c.transport,
                    options: {for (final t in AccTransport.values) t: t == AccTransport.auto ? 'Automatic (DNS SRV)' : t.wire.toUpperCase()},
                    onChanged: (v) => _cfg((x) => x.copyWith(transport: v)),
                  ),
                  if (ws) _tx('WebSocket path', c.wsPath, (v) => _cfg((x) => x.copyWith(wsPath: v)), hint: '/ws', sub: 'HTTP path of the WebSocket upgrade, e.g. /ws. Must start with "/"', validator: validateWsPath),
                  _num('Registration expiry (s)', c.regExpires, (v) => _cfg((x) => x.copyWith(regExpires: v)), min: 10, max: 86400, sub: '300 to 3600 is typical. Range 10 to 86400'),
                  if (!ws) _num('Keep-alive (s)', c.keepAliveSec, (v) => _cfg((x) => x.copyWith(keepAliveSec: v)), min: 0, max: 3600, sub: 'UDP keep-alive interval. 0 turns it off. Range 0 to 3600'),
                  _num('Local SIP port', c.localPort, (v) => _cfg((x) => x.copyWith(localPort: v)), min: 0, max: 65535, sub: '0 uses the shared transport. Range 0 to 65535'),
                  _sw('Register', c.register, (v) => _cfg((x) => x.copyWith(register: v)), sub: 'Turn off for trunks without registration'),
                  if (!ws) _sw('SIP Outbound (RFC 5626)', c.sipOutbound, (v) => _cfg((x) => x.copyWith(sipOutbound: v)), sub: 'Keeps a persistent flow through NAT. Needs server support'),
                ]),
                if (c.transport == AccTransport.tls || c.transport == AccTransport.wss || c.transport == AccTransport.auto)
                  TlsClientCertGroup(config: c, onChanged: (cfg) => _upd((p) => p.copyWith(config: cfg))),
                SettingsGroup(title: 'NAT', children: [
                  _sw('Use STUN', c.useStun, (v) => _cfg((x) => x.copyWith(useStun: v))),
                  _sw('ICE', c.ice, (v) => _cfg((x) => x.copyWith(ice: v))),
                  _sw('TURN relay', c.turn.enabled, (v) => _cfg((x) => x.copyWith(turn: x.turn.copyWith(enabled: v)))),
                  if (c.turn.enabled) ...[
                    _tx('TURN server', c.turn.server, (v) => _cfg((x) => x.copyWith(turn: x.turn.copyWith(server: v)))),
                    _tx('TURN username', c.turn.username, (v) => _cfg((x) => x.copyWith(turn: x.turn.copyWith(username: v)))),
                    _tx('TURN password', c.turn.password, (v) => _cfg((x) => x.copyWith(turn: x.turn.copyWith(password: v))), obscure: true),
                  ],
                  if (!ws) ...[
                    _sw('Rewrite Contact header', c.contactRewrite, (v) => _cfg((x) => x.copyWith(contactRewrite: v)), sub: 'Use the address the server sees. Keep on behind NAT'),
                    _sw('Rewrite Via header', c.viaRewrite, (v) => _cfg((x) => x.copyWith(viaRewrite: v)), sub: 'Use the address the server sees. Keep on behind NAT'),
                  ],
                  _sw('Rewrite SDP address', c.sdpNatRewrite, (v) => _cfg((x) => x.copyWith(sdpNatRewrite: v)), sub: 'Replace the media address in SDP with the public one'),
                  SelectTile<Ipv6Mode>(title: 'IPv6 signalling', value: c.ipv6Sip, options: {for (final m in Ipv6Mode.values) m: m.wire}, onChanged: (v) => _cfg((x) => x.copyWith(ipv6Sip: v))),
                  SelectTile<Ipv6Mode>(title: 'IPv6 media', value: c.ipv6Media, options: {for (final m in Ipv6Mode.values) m: m.wire}, onChanged: (v) => _cfg((x) => x.copyWith(ipv6Media: v))),
                ]),
                SettingsGroup(title: 'Advanced media', footer: 'WebRTC gateways need RTCP multiplexing and RTCP feedback.', children: [
                  _sw('RTCP multiplexing', c.rtcpMux, (v) => _cfg((x) => x.copyWith(rtcpMux: v)), sub: 'Send RTP and RTCP on one port (rtcp-mux)'),
                  _sw('RTCP feedback (AVPF)', c.rtcpFb, (v) => _cfg((x) => x.copyWith(rtcpFb: v)), sub: 'Offer RTP/AVPF with NACK. Needed for WebRTC servers'),
                ]),
                SettingsGroup(title: 'Security', children: [
                  SelectTile<SrtpMode>(title: 'Media encryption (SRTP)', value: c.srtp, options: const {SrtpMode.off: 'Off', SrtpMode.optional: 'Optional', SrtpMode.mandatory: 'Required'}, onChanged: (v) => _cfg((x) => x.copyWith(srtp: v))),
                  SelectTile<SrtpKeying>(title: 'Key exchange', value: c.srtpKeying.isEmpty ? SrtpKeying.sdes : c.srtpKeying.first, options: const {SrtpKeying.sdes: 'SDES', SrtpKeying.dtls: 'DTLS'}, onChanged: (v) => _cfg((x) => x.copyWith(srtpKeying: [v]))),
                  SelectTile<int>(title: 'Secure signalling', value: c.srtpSecureSignaling, options: const {0: 'Not required', 1: 'TLS hop-by-hop', 2: 'TLS end-to-end (sips)'}, onChanged: (v) => _cfg((x) => x.copyWith(srtpSecureSignaling: v))),
                  SelectTile<String>(title: 'Auth algorithm', value: c.authAlgorithm, options: const {'auto': 'Automatic', 'md5': 'MD5', 'sha256': 'SHA-256'}, onChanged: (v) => _cfg((x) => x.copyWith(authAlgorithm: v))),
                  _sw('Hide caller ID (privacy)', c.privacy, (v) => _cfg((x) => x.copyWith(privacy: v))),
                  SelectTile<AcceptPolicy>(title: 'Incoming transfers (REFER)', value: c.referPolicy, options: const {AcceptPolicy.accept: 'Accept', AcceptPolicy.reject: 'Reject'}, onChanged: (v) => _cfg((x) => x.copyWith(referPolicy: v))),
                  SelectTile<AcceptPolicy>(title: 'Presence watchers', value: c.watcherPolicy, options: const {AcceptPolicy.accept: 'Accept', AcceptPolicy.reject: 'Reject'}, onChanged: (v) => _cfg((x) => x.copyWith(watcherPolicy: v))),
                ]),
                SettingsGroup(
                  title: 'Codecs',
                  footer: 'Overrides the global codec list for this account.',
                  children: [
                    _sw('Use global codec order', c.codecs.isEmpty, (v) => _cfg((x) => x.copyWith(codecs: v ? <String>[] : orderCodecs(known, <String>[])))),
                    if (c.codecs.isNotEmpty)
                      ReorderableListView(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        buildDefaultDragHandles: false,
                        onReorder: (a, b) {
                          if (b > a) b -= 1;
                          final l = [...codecs];
                          l.insert(b, l.removeAt(a));
                          _cfg((x) => x.copyWith(codecs: l));
                        },
                        children: [
                          for (var i = 0; i < codecs.length; i++)
                            ListTile(
                              key: ValueKey(codecs[i]),
                              leading: ReorderableDragStartListener(index: i, child: const Icon(Icons.drag_indicator_rounded)),
                              title: Text(codecs[i].split('/').first),
                              trailing: IconButton(tooltip: 'Remove ${codecs[i].split('/').first}', icon: const Icon(Icons.close_rounded), onPressed: () => _cfg((x) => x.copyWith(codecs: codecs.where((e) => e != codecs[i]).toList()))),
                            ),
                        ],
                      ),
                    if (c.codecs.isNotEmpty && known.any((k) => !codecs.contains(k)))
                      ListTile(
                        leading: const Icon(Icons.add_rounded),
                        title: const Text('Add codec'),
                        onTap: () async {
                          final pick = await showModalBottomSheet<String>(
                            context: context,
                            builder: (ctx) => SafeArea(child: ListView(shrinkWrap: true, children: [for (final k in known.where((k) => !codecs.contains(k))) ListTile(title: Text(k), onTap: () => Navigator.pop(ctx, k))])),
                          );
                          if (pick != null) _cfg((x) => x.copyWith(codecs: [...codecs, pick]));
                        },
                      ),
                  ],
                ),
                ],
                SettingsGroup(title: 'Features', children: [
                  _tx('Voicemail number', _p.voicemailNumber, (v) => _upd((p) => p.copyWith(voicemailNumber: v)), hint: '*97'),
                  if (!iax) _sw('Voicemail indicator (MWI)', c.mwi, (v) => _cfg((x) => x.copyWith(mwi: v)), sub: 'Subscribe to message-waiting notifications'),
                  if (!iax) _sw('Publish my presence', c.publishPresence, (v) => _cfg((x) => x.copyWith(publishPresence: v)), sub: 'Let the server share your online status'),
                  _sw('Do not disturb', _p.dnd, (v) => _upd((p) => p.copyWith(dnd: v))),
                  SelectTile<ForwardMode>(title: 'Call forwarding', value: _p.forwarding.mode, options: const {ForwardMode.off: 'Off', ForwardMode.always: 'Always', ForwardMode.busy: 'When busy', ForwardMode.noAnswer: 'No answer'}, onChanged: (v) => _upd((p) => p.copyWith(forwarding: p.forwarding.copyWith(mode: v)))),
                  if (_p.forwarding.mode != ForwardMode.off) _tx('Forward to', _p.forwarding.target, (v) => _upd((p) => p.copyWith(forwarding: p.forwarding.copyWith(target: v))), hint: 'Number or SIP address'),
                  if (_p.forwarding.mode == ForwardMode.noAnswer) _num('Ring for (s)', _p.forwarding.noAnswerSec, (v) => _upd((p) => p.copyWith(forwarding: p.forwarding.copyWith(noAnswerSec: v)))),
                  _sw('Auto-answer', _p.autoAnswer.enabled, (v) => _upd((p) => p.copyWith(autoAnswer: p.autoAnswer.copyWith(enabled: v)))),
                  if (_p.autoAnswer.enabled) ...[
                    _num('Answer after (s)', _p.autoAnswer.delaySec, (v) => _upd((p) => p.copyWith(autoAnswer: p.autoAnswer.copyWith(delaySec: v)))),
                    _sw('Only for intercom calls', _p.autoAnswer.onlyIntercomHeaders, (v) => _upd((p) => p.copyWith(autoAnswer: p.autoAnswer.copyWith(onlyIntercomHeaders: v))), sub: 'Needs an auto-answer header from the PBX'),
                  ],
                  SelectTile<String>(title: 'Ringtone', value: _p.ringtone, options: const {'default': 'Default', 'classic': 'Classic', 'soft': 'Soft', 'digital': 'Digital'}, onChanged: (v) => _upd((p) => p.copyWith(ringtone: v))),
                  SelectTile<String>(key: const Key('acc-auto-record'), title: 'Record calls', value: _p.autoRecord, options: kAccountRecordOptions, onChanged: (v) => _upd((p) => p.copyWith(autoRecord: v))),
                  AudioRefTile(key: const Key('acc-hold-music'), title: 'Hold music', value: _p.holdMusic, holdMusicOnly: true, leading: const {'inherit': 'Use global setting', 'pbx': 'PBX default'}, onChanged: (v) => _upd((p) => p.copyWith(holdMusic: v))),
                  AudioRefTile(key: const Key('acc-opening-announcement'), title: 'Opening announcement', value: _p.openingAnnouncement, leading: const {'inherit': 'Use global setting', 'off': 'Off'}, onChanged: (v) => _upd((p) => p.copyWith(openingAnnouncement: v))),
                ]),
                SettingsGroup(title: 'Feature codes', footer: 'Dialled for park, pickup, DND and forwarding on your PBX.', children: [
                  _tx('Park', _p.featureCodes.park, (v) => _upd((p) => p.copyWith(featureCodes: p.featureCodes.copyWith(park: v)))),
                  _tx('Group pickup', _p.featureCodes.pickupGroup, (v) => _upd((p) => p.copyWith(featureCodes: p.featureCodes.copyWith(pickupGroup: v)))),
                  _tx('Directed pickup prefix', _p.featureCodes.pickupDirectedPrefix, (v) => _upd((p) => p.copyWith(featureCodes: p.featureCodes.copyWith(pickupDirectedPrefix: v)))),
                  _tx('Park retrieve prefix', _p.featureCodes.parkRetrieve, (v) => _upd((p) => p.copyWith(featureCodes: p.featureCodes.copyWith(parkRetrieve: v))), hint: 'Dial the slot number', sub: 'Prefix dialled before the park slot to pick a parked call back up'),
                  _tx('DND on', _p.featureCodes.dndOn, (v) => _upd((p) => p.copyWith(featureCodes: p.featureCodes.copyWith(dndOn: v)))),
                  _tx('DND off', _p.featureCodes.dndOff, (v) => _upd((p) => p.copyWith(featureCodes: p.featureCodes.copyWith(dndOff: v)))),
                  _tx('Forward on', _p.featureCodes.forwardOn, (v) => _upd((p) => p.copyWith(featureCodes: p.featureCodes.copyWith(forwardOn: v)))),
                  _tx('Forward off', _p.featureCodes.forwardOff, (v) => _upd((p) => p.copyWith(featureCodes: p.featureCodes.copyWith(forwardOff: v)))),
                ]),
                if (iax)
                  SettingsGroup(title: 'Advanced', footer: 'DTMF is sent as native IAX2 frames.', children: [
                    _tx('Caller ID override', c.callerId ?? '', (v) => _cfg((x) => AccountConfigX.withCallerId(x, v)), hint: 'Use account default', sub: 'Caller ID name or number sent to the PBX'),
                  ])
                else
                SettingsGroup(title: 'Advanced', children: [
                  SelectTile<SessionTimers>(title: 'Session timers', value: c.sessionTimers, options: {for (final s in SessionTimers.values) s: s.wire}, onChanged: (v) => _cfg((x) => x.copyWith(sessionTimers: v))),
                  _num('Session expires (s)', c.timerSe, (v) => _cfg((x) => x.copyWith(timerSe: v)), min: 90, max: 86400, sub: 'Range 90 to 86400'),
                  _sw('100rel (reliable provisional)', c.use100rel, (v) => _cfg((x) => x.copyWith(use100rel: v))),
                  SelectTile<HoldType>(title: 'Hold method', value: c.holdType, options: const {HoldType.rfc3264: 'RFC 3264 (sendonly)', HoldType.rfc2543: 'RFC 2543 (0.0.0.0)'}, onChanged: (v) => _cfg((x) => x.copyWith(holdType: v))),
                  SelectTile<DtmfMethod>(title: 'DTMF method', value: c.dtmfMethod, options: const {DtmfMethod.rfc2833: 'RFC 2833', DtmfMethod.info: 'SIP INFO', DtmfMethod.inband: 'In-band', DtmfMethod.auto: 'Automatic'}, onChanged: (v) => _cfg((x) => x.copyWith(dtmfMethod: v))),
                  SelectTile<RedirectPolicy>(title: 'Redirects (3xx)', value: c.redirect, options: const {RedirectPolicy.auto: 'Follow', RedirectPolicy.ask: 'Ask', RedirectPolicy.reject: 'Reject'}, onChanged: (v) => _cfg((x) => x.copyWith(redirect: v))),
                  _sw('Lock codec after answer', c.lockCodec, (v) => _cfg((x) => x.copyWith(lockCodec: v))),
                  _sw('Media keep-alive', c.streamKeepAlive, (v) => _cfg((x) => x.copyWith(streamKeepAlive: v))),
                  _sw('Drop calls when registration fails', c.dropCallsOnRegFail, (v) => _cfg((x) => x.copyWith(dropCallsOnRegFail: v))),
                  _tx('Caller ID override', c.callerId ?? '', (v) => _cfg((x) => AccountConfigX.withCallerId(x, v)), hint: 'Use account default'),
                  _tx('User-Agent', c.userAgent ?? '', (v) => _cfg((x) => AccountConfigX.withUserAgent(x, v)), hint: 'Default'),
                  _tx('Extra SIP headers', headersText, (v) => _cfg((x) => x.copyWith(headers: parseHeaders(v))), hint: 'X-Header: value (one per line)'),
                  _num('Retry interval (s)', c.regRetrySec, (v) => _cfg((x) => x.copyWith(regRetrySec: v)), min: 0, max: 86400, sub: 'Wait before retrying a failed registration. Range 0 to 86400'),
                  _num('Unregister timeout (ms)', c.unregTimeoutMs, (v) => _cfg((x) => x.copyWith(unregTimeoutMs: v)), min: 0, max: 60000, sub: 'How long to wait for the unregister reply. Range 0 to 60000'),
                  _num('MWI subscription expiry (s)', c.mwiExpires, (v) => _cfg((x) => x.copyWith(mwiExpires: v)), min: 0, max: 86400),
                  _num('DSCP for SIP', c.dscp.sip, (v) => _cfg((x) => x.copyWith(dscp: DscpConfig(sip: v, rtp: x.dscp.rtp))), min: 0, max: 63, sub: 'QoS marking of signalling. 24 (CS3) is typical'),
                  _num('DSCP for RTP', c.dscp.rtp, (v) => _cfg((x) => x.copyWith(dscp: DscpConfig(sip: x.dscp.sip, rtp: v))), min: 0, max: 63, sub: 'QoS marking of media. 46 (EF) is typical'),
                  _sw('Re-INVITE after network change', c.ipChange.reinvite, (v) => _cfg((x) => x.copyWith(ipChange: x.ipChange.copyWith(reinvite: v)))),
                  _sw('Hang up calls on network change', c.ipChange.hangupCalls, (v) => _cfg((x) => x.copyWith(ipChange: x.ipChange.copyWith(hangupCalls: v)))),
                ]),
                const SizedBox(height: 16),
                if (acc.errorOf(_p.id) != null)
                  Padding(padding: const EdgeInsets.all(16), child: Text('Last error: ${acc.errorOf(_p.id)}')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Integer validation with the engine's accepted range.
String? validateInt(String s, {int? min, int? max}) {
  final v = int.tryParse(s.trim());
  if (v == null) return 'Enter a whole number';
  if (min != null && v < min) return 'Must be at least $min';
  if (max != null && v > max) return 'Must be at most $max';
  return null;
}

/// Server host (optionally host:port) must be non-empty and have no spaces.
String? validateHost(String s) {
  final v = s.trim();
  if (v.isEmpty) return 'Enter a server host name or address';
  if (RegExp(r'\s').hasMatch(v)) return 'The server cannot contain spaces';
  if (v.contains('/') || v.contains('@')) return 'Enter only host or host:port';
  final m = RegExp(r'^(?:\[[^\]]+\]|[^:]+):(\d+)$').firstMatch(v);
  if (m != null) {
    final port = int.parse(m.group(1)!);
    if (port < 1 || port > 65535) return 'Port must be between 1 and 65535';
  }
  return null;
}

/// WebSocket upgrade path: starts with "/", at most 120 characters.
String? validateWsPath(String s) {
  final v = s.trim();
  if (!v.startsWith('/')) return 'The path must start with "/"';
  if (v.length > 120) return 'Use at most 120 characters';
  if (RegExp(r'\s').hasMatch(v)) return 'The path cannot contain spaces';
  return null;
}

Map<String, String> parseHeaders(String text) {
  final m = <String, String>{};
  for (final line in text.split(RegExp(r'[\n;]'))) {
    final i = line.indexOf(':');
    if (i > 0) m[line.substring(0, i).trim()] = line.substring(i + 1).trim();
  }
  return m;
}

/// copyWith cannot set nullable fields back to null; rebuild via JSON.
class AccountConfigX {
  static AccountConfig _with(AccountConfig c, String key, String v) {
    final j = c.toJson();
    j[key] = v.isEmpty ? null : v;
    return AccountConfig.fromJson(j);
  }

  static AccountConfig withAuth(AccountConfig c, String v) => _with(c, 'authUser', v);
  static AccountConfig withRegistrar(AccountConfig c, String v) => _with(c, 'registrar', v);
  static AccountConfig withCallerId(AccountConfig c, String v) => _with(c, 'callerId', v);
  static AccountConfig withUserAgent(AccountConfig c, String v) => _with(c, 'userAgent', v);
}
