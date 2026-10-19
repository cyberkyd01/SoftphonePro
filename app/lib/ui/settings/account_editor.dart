import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:spcore_dart/spcore_dart.dart';

import '../../core/format.dart';
import '../../l10n/l10n.dart';
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
    subtitle: sub == null && min != null && max != null ? context.l10n.acctRangeAllowed(min, max) : sub,
    value: '$v',
    keyboardType: TextInputType.number,
    validator: (s) => validateInt(s, min: min, max: max, l: context.l10n),
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
        final discard = await confirm(context, title: context.l10n.acctEditorDiscardTitle, message: context.l10n.acctEditorDiscardMessage, confirmLabel: context.l10n.acctEditorDiscardConfirm);
        if (discard && context.mounted) context.pop();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_p.name),
          actions: [
            TextButton(key: const Key('save-account'), onPressed: _dirty ? _save : null, child: Text(context.l10n.actionSave)),
            PopupMenuButton<String>(
              onSelected: (v) async {
                if (v == 'delete' && await confirm(context, title: context.l10n.acctEditorDeleteTitle(_p.name), message: context.l10n.acctEditorDeleteMessage)) {
                  await ref.read(accountsProvider.notifier).remove(_p.id);
                  if (context.mounted) context.go('/settings/accounts');
                }
              },
              itemBuilder: (_) => [PopupMenuItem(value: 'delete', child: Text(context.l10n.acctEditorMenuDelete))],
            ),
          ],
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: ListView(
              padding: const EdgeInsets.only(bottom: 48),
              children: [
                SettingsGroup(title: context.l10n.acctGroupBasic, children: [
                  _tx(context.l10n.acctFieldLabel, _p.label, (v) => _upd((p) => p.copyWith(label: v)), hint: context.l10n.acctFieldLabelHint),
                  _tx(context.l10n.acctFieldDisplayName, c.displayName, (v) => _cfg((x) => x.copyWith(displayName: v))),
                  _tx(context.l10n.acctFieldUsername, c.username, (v) => _cfg((x) => x.copyWith(username: v))),
                  ListTile(
                    key: const Key('acc-protocol'),
                    title: Text(context.l10n.acctFieldProtocol),
                    subtitle: Text(context.l10n.acctFieldProtocolSub),
                    trailing: Text(iax ? 'IAX2' : 'SIP', style: Theme.of(context).textTheme.bodyMedium),
                  ),
                  if (!iax) _tx(context.l10n.acctFieldAuthUser, c.authUser ?? '', (v) => _cfg((x) => AccountConfigX.withAuth(x, v)), hint: context.l10n.acctFieldAuthUserHint, sub: context.l10n.acctFieldAuthUserSub),
                  _tx(context.l10n.acctFieldPassword, c.password, (v) => _cfg((x) => x.copyWith(password: v)), obscure: true),
                  if (iax) ...[
                    _tx(context.l10n.acctFieldServerHost, c.iax.host.isEmpty ? c.domain : c.iax.host, (v) => _cfg((x) => x.copyWith(domain: v, iax: x.iax.copyWith(host: v))), validator: (s) => validateHost(s, context.l10n)),
                    _num(context.l10n.acctFieldPort, c.iax.port, (v) => _cfg((x) => x.copyWith(iax: x.iax.copyWith(port: v))), min: 1, max: 65535, sub: context.l10n.acctFieldIaxPortSub),
                    _tx(context.l10n.acctFieldIaxContext, c.iax.context ?? '', (v) => _cfg((x) => x.copyWith(iax: IaxConfig(host: x.iax.host, port: x.iax.port, context: v.isEmpty ? null : v))), hint: context.l10n.commonNotSet, sub: context.l10n.acctFieldIaxContextSub),
                  ] else
                    _tx(context.l10n.acctFieldServerDomain, c.domain, (v) => _cfg((x) => x.copyWith(domain: v)), validator: (s) => validateHost(s, context.l10n), sub: context.l10n.acctFieldServerDomainSub),
                  _sw(context.l10n.acctFieldEnabled, _p.enabled, (v) => _upd((p) => p.copyWith(enabled: v))),
                  _sw(context.l10n.acctFieldDefault, _p.isDefault, (v) => _upd((p) => p.copyWith(isDefault: v))),
                  ListTile(
                    title: Text(context.l10n.acctFieldColour),
                    trailing: Wrap(spacing: 8, children: [
                      for (final col in kAvatarPalette.take(7))
                        InkResponse(onTap: () => _upd((p) => p.copyWith(color: col)), child: Container(width: 26, height: 26, decoration: BoxDecoration(color: Color(col), shape: BoxShape.circle, border: _p.color == col ? Border.all(width: 3, color: Theme.of(context).colorScheme.onSurface) : null))),
                    ]),
                  ),
                ]),
                if (iax) ...[
                  SettingsGroup(title: context.l10n.acctGroupRegistration, children: [
                    _sw(context.l10n.acctFieldRegister, c.register, (v) => _cfg((x) => x.copyWith(register: v)), sub: context.l10n.acctFieldRegisterSubIax),
                    _num(context.l10n.acctFieldRegExpiry, c.regExpires, (v) => _cfg((x) => x.copyWith(regExpires: v)), min: 10, max: 86400, sub: context.l10n.acctFieldRegExpirySubIax),
                    _num(context.l10n.acctFieldRetryInterval, c.regRetrySec, (v) => _cfg((x) => x.copyWith(regRetrySec: v)), min: 0, max: 86400),
                    _num(context.l10n.acctFieldFirstRetry, c.regFirstRetrySec, (v) => _cfg((x) => x.copyWith(regFirstRetrySec: v)), min: 0, max: 86400),
                  ]),
                  SettingsGroup(
                    title: context.l10n.acctGroupCodecs,
                    footer: context.l10n.acctGroupCodecsFooterIax,
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
                                  ? IconButton(tooltip: context.l10n.acctCodecRemove(iaxCodecs[i].split('/').first), icon: const Icon(Icons.close_rounded), onPressed: iaxCodecs.length <= 1 ? null : () => _cfg((x) => x.copyWith(codecs: iaxCodecs.where((e) => e != iaxCodecs[i]).toList())))
                                  : null,
                            ),
                        ],
                      ),
                      if (iaxCodecs.length < iaxKnown.length)
                        ListTile(
                          leading: const Icon(Icons.add_rounded),
                          title: Text(context.l10n.acctCodecAdd),
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
                SettingsGroup(title: context.l10n.acctGroupServerTransport, children: [
                  _tx(context.l10n.acctFieldRegistrar, c.registrar ?? '', (v) => _cfg((x) => AccountConfigX.withRegistrar(x, v)), hint: 'sip:server:5060'),
                  _tx(context.l10n.acctFieldBackupRegistrar, _p.backupRegistrar, (v) => _upd((p) => p.copyWith(backupRegistrar: v.trim())), hint: context.l10n.commonNone, sub: context.l10n.acctFieldBackupRegistrarSub),
                  _tx(context.l10n.acctFieldProxies, c.proxies.join(', '), (v) => _cfg((x) => x.copyWith(proxies: v.split(RegExp(r'[,\s]+')).where((e) => e.isNotEmpty).toList())), hint: context.l10n.commonNone),
                  SelectTile<AccTransport>(
                    key: const Key('acc-transport'),
                    title: context.l10n.acctFieldTransport,
                    subtitle: c.transport == AccTransport.auto ? context.l10n.acctFieldTransportAutoSub : null,
                    value: c.transport,
                    options: {for (final t in AccTransport.values) t: t == AccTransport.auto ? context.l10n.acctTransportAuto : t.wire.toUpperCase()},
                    onChanged: (v) => _cfg((x) => x.copyWith(transport: v)),
                  ),
                  if (ws) _tx(context.l10n.acctFieldWsPath, c.wsPath, (v) => _cfg((x) => x.copyWith(wsPath: v)), hint: '/ws', sub: context.l10n.acctFieldWsPathSub, validator: (s) => validateWsPath(s, context.l10n)),
                  _num(context.l10n.acctFieldRegExpiry, c.regExpires, (v) => _cfg((x) => x.copyWith(regExpires: v)), min: 10, max: 86400, sub: context.l10n.acctFieldRegExpirySubSip),
                  if (!ws) _num(context.l10n.acctFieldKeepAlive, c.keepAliveSec, (v) => _cfg((x) => x.copyWith(keepAliveSec: v)), min: 0, max: 3600, sub: context.l10n.acctFieldKeepAliveSub),
                  _num(context.l10n.acctFieldLocalPort, c.localPort, (v) => _cfg((x) => x.copyWith(localPort: v)), min: 0, max: 65535, sub: context.l10n.acctFieldLocalPortSub),
                  _sw(context.l10n.acctFieldRegister, c.register, (v) => _cfg((x) => x.copyWith(register: v)), sub: context.l10n.acctFieldRegisterSubSip),
                  if (!ws) _sw(context.l10n.acctFieldSipOutbound, c.sipOutbound, (v) => _cfg((x) => x.copyWith(sipOutbound: v)), sub: context.l10n.acctFieldSipOutboundSub),
                ]),
                if (c.transport == AccTransport.tls || c.transport == AccTransport.wss || c.transport == AccTransport.auto)
                  TlsClientCertGroup(config: c, onChanged: (cfg) => _upd((p) => p.copyWith(config: cfg))),
                SettingsGroup(title: context.l10n.acctGroupNat, children: [
                  _sw(context.l10n.acctFieldUseStun, c.useStun, (v) => _cfg((x) => x.copyWith(useStun: v))),
                  _sw('ICE', c.ice, (v) => _cfg((x) => x.copyWith(ice: v))),
                  _sw(context.l10n.acctFieldTurn, c.turn.enabled, (v) => _cfg((x) => x.copyWith(turn: x.turn.copyWith(enabled: v)))),
                  if (c.turn.enabled) ...[
                    _tx(context.l10n.acctFieldTurnServer, c.turn.server, (v) => _cfg((x) => x.copyWith(turn: x.turn.copyWith(server: v)))),
                    _tx(context.l10n.acctFieldTurnUsername, c.turn.username, (v) => _cfg((x) => x.copyWith(turn: x.turn.copyWith(username: v)))),
                    _tx(context.l10n.acctFieldTurnPassword, c.turn.password, (v) => _cfg((x) => x.copyWith(turn: x.turn.copyWith(password: v))), obscure: true),
                  ],
                  if (!ws) ...[
                    _sw(context.l10n.acctFieldContactRewrite, c.contactRewrite, (v) => _cfg((x) => x.copyWith(contactRewrite: v)), sub: context.l10n.acctFieldRewriteSub),
                    _sw(context.l10n.acctFieldViaRewrite, c.viaRewrite, (v) => _cfg((x) => x.copyWith(viaRewrite: v)), sub: context.l10n.acctFieldRewriteSub),
                  ],
                  _sw(context.l10n.acctFieldSdpRewrite, c.sdpNatRewrite, (v) => _cfg((x) => x.copyWith(sdpNatRewrite: v)), sub: context.l10n.acctFieldSdpRewriteSub),
                  SelectTile<Ipv6Mode>(title: context.l10n.acctFieldIpv6Sip, value: c.ipv6Sip, options: {for (final m in Ipv6Mode.values) m: m.wire}, onChanged: (v) => _cfg((x) => x.copyWith(ipv6Sip: v))),
                  SelectTile<Ipv6Mode>(title: context.l10n.acctFieldIpv6Media, value: c.ipv6Media, options: {for (final m in Ipv6Mode.values) m: m.wire}, onChanged: (v) => _cfg((x) => x.copyWith(ipv6Media: v))),
                ]),
                SettingsGroup(title: context.l10n.acctGroupAdvancedMedia, footer: context.l10n.acctGroupAdvancedMediaFooter, children: [
                  _sw(context.l10n.acctFieldRtcpMux, c.rtcpMux, (v) => _cfg((x) => x.copyWith(rtcpMux: v)), sub: context.l10n.acctFieldRtcpMuxSub),
                  _sw(context.l10n.acctFieldRtcpFb, c.rtcpFb, (v) => _cfg((x) => x.copyWith(rtcpFb: v)), sub: context.l10n.acctFieldRtcpFbSub),
                ]),
                SettingsGroup(title: context.l10n.acctGroupSecurity, children: [
                  SelectTile<SrtpMode>(title: context.l10n.acctFieldSrtp, value: c.srtp, options: {SrtpMode.off: context.l10n.commonOff, SrtpMode.optional: context.l10n.acctOptOptional, SrtpMode.mandatory: context.l10n.acctOptRequired}, onChanged: (v) => _cfg((x) => x.copyWith(srtp: v))),
                  SelectTile<SrtpKeying>(title: context.l10n.acctFieldKeyExchange, value: c.srtpKeying.isEmpty ? SrtpKeying.sdes : c.srtpKeying.first, options: {SrtpKeying.sdes: 'SDES', SrtpKeying.dtls: 'DTLS'}, onChanged: (v) => _cfg((x) => x.copyWith(srtpKeying: [v]))),
                  SelectTile<int>(title: context.l10n.acctFieldSecureSignaling, value: c.srtpSecureSignaling, options: {0: context.l10n.acctOptNotRequired, 1: context.l10n.acctOptTlsHop, 2: context.l10n.acctOptTlsE2e}, onChanged: (v) => _cfg((x) => x.copyWith(srtpSecureSignaling: v))),
                  SelectTile<String>(title: context.l10n.acctFieldAuthAlgorithm, value: c.authAlgorithm, options: {'auto': context.l10n.commonAutomatic, 'md5': 'MD5', 'sha256': 'SHA-256'}, onChanged: (v) => _cfg((x) => x.copyWith(authAlgorithm: v))),
                  _sw(context.l10n.acctFieldPrivacy, c.privacy, (v) => _cfg((x) => x.copyWith(privacy: v))),
                  SelectTile<AcceptPolicy>(title: context.l10n.acctFieldReferPolicy, value: c.referPolicy, options: {AcceptPolicy.accept: context.l10n.acctOptAccept, AcceptPolicy.reject: context.l10n.acctOptReject}, onChanged: (v) => _cfg((x) => x.copyWith(referPolicy: v))),
                  SelectTile<AcceptPolicy>(title: context.l10n.acctFieldWatcherPolicy, value: c.watcherPolicy, options: {AcceptPolicy.accept: context.l10n.acctOptAccept, AcceptPolicy.reject: context.l10n.acctOptReject}, onChanged: (v) => _cfg((x) => x.copyWith(watcherPolicy: v))),
                ]),
                SettingsGroup(
                  title: context.l10n.acctGroupCodecs,
                  footer: context.l10n.acctGroupCodecsFooter,
                  children: [
                    _sw(context.l10n.acctFieldUseGlobalCodecs, c.codecs.isEmpty, (v) => _cfg((x) => x.copyWith(codecs: v ? <String>[] : orderCodecs(known, <String>[])))),
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
                              trailing: IconButton(tooltip: context.l10n.acctCodecRemove(codecs[i].split('/').first), icon: const Icon(Icons.close_rounded), onPressed: () => _cfg((x) => x.copyWith(codecs: codecs.where((e) => e != codecs[i]).toList()))),
                            ),
                        ],
                      ),
                    if (c.codecs.isNotEmpty && known.any((k) => !codecs.contains(k)))
                      ListTile(
                        leading: const Icon(Icons.add_rounded),
                        title: Text(context.l10n.acctCodecAdd),
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
                SettingsGroup(title: context.l10n.acctGroupFeatures, children: [
                  _tx(context.l10n.acctFieldVoicemailNumber, _p.voicemailNumber, (v) => _upd((p) => p.copyWith(voicemailNumber: v)), hint: '*97'),
                  if (!iax) _sw(context.l10n.acctFieldMwi, c.mwi, (v) => _cfg((x) => x.copyWith(mwi: v)), sub: context.l10n.acctFieldMwiSub),
                  if (!iax) _sw(context.l10n.acctFieldPublishPresence, c.publishPresence, (v) => _cfg((x) => x.copyWith(publishPresence: v)), sub: context.l10n.acctFieldPublishPresenceSub),
                  _sw(context.l10n.acctFieldDnd, _p.dnd, (v) => _upd((p) => p.copyWith(dnd: v))),
                  SelectTile<ForwardMode>(title: context.l10n.acctFieldForwarding, value: _p.forwarding.mode, options: {ForwardMode.off: context.l10n.commonOff, ForwardMode.always: context.l10n.acctOptForwardAlways, ForwardMode.busy: context.l10n.acctOptForwardBusy, ForwardMode.noAnswer: context.l10n.acctOptForwardNoAnswer}, onChanged: (v) => _upd((p) => p.copyWith(forwarding: p.forwarding.copyWith(mode: v)))),
                  if (_p.forwarding.mode != ForwardMode.off) _tx(context.l10n.acctFieldForwardTo, _p.forwarding.target, (v) => _upd((p) => p.copyWith(forwarding: p.forwarding.copyWith(target: v))), hint: context.l10n.acctFieldForwardToHint),
                  if (_p.forwarding.mode == ForwardMode.noAnswer) _num(context.l10n.acctFieldRingFor, _p.forwarding.noAnswerSec, (v) => _upd((p) => p.copyWith(forwarding: p.forwarding.copyWith(noAnswerSec: v)))),
                  _sw(context.l10n.acctFieldAutoAnswer, _p.autoAnswer.enabled, (v) => _upd((p) => p.copyWith(autoAnswer: p.autoAnswer.copyWith(enabled: v)))),
                  if (_p.autoAnswer.enabled) ...[
                    _num(context.l10n.acctFieldAnswerAfter, _p.autoAnswer.delaySec, (v) => _upd((p) => p.copyWith(autoAnswer: p.autoAnswer.copyWith(delaySec: v)))),
                    _sw(context.l10n.acctFieldIntercomOnly, _p.autoAnswer.onlyIntercomHeaders, (v) => _upd((p) => p.copyWith(autoAnswer: p.autoAnswer.copyWith(onlyIntercomHeaders: v))), sub: context.l10n.acctFieldIntercomOnlySub),
                  ],
                  SelectTile<String>(title: context.l10n.acctFieldRingtone, value: _p.ringtone, options: {'default': context.l10n.commonDefault, 'classic': context.l10n.acctRingtoneClassic, 'soft': context.l10n.acctRingtoneSoft, 'digital': context.l10n.acctRingtoneDigital}, onChanged: (v) => _upd((p) => p.copyWith(ringtone: v))),
                  SelectTile<String>(key: const Key('acc-auto-record'), title: context.l10n.acctFieldRecordCalls, value: _p.autoRecord, options: accountRecordOptions(context.l10n), onChanged: (v) => _upd((p) => p.copyWith(autoRecord: v))),
                  AudioRefTile(key: const Key('acc-hold-music'), title: context.l10n.acctFieldHoldMusic, value: _p.holdMusic, holdMusicOnly: true, leading: {'inherit': context.l10n.acctOptUseGlobal, 'pbx': context.l10n.acctOptPbxDefault}, onChanged: (v) => _upd((p) => p.copyWith(holdMusic: v))),
                  AudioRefTile(key: const Key('acc-opening-announcement'), title: context.l10n.acctFieldOpeningAnnouncement, value: _p.openingAnnouncement, leading: {'inherit': context.l10n.acctOptUseGlobal, 'off': context.l10n.commonOff}, onChanged: (v) => _upd((p) => p.copyWith(openingAnnouncement: v))),
                ]),
                SettingsGroup(title: context.l10n.acctGroupFeatureCodes, footer: context.l10n.acctGroupFeatureCodesFooter, children: [
                  _tx(context.l10n.acctFieldPark, _p.featureCodes.park, (v) => _upd((p) => p.copyWith(featureCodes: p.featureCodes.copyWith(park: v)))),
                  _tx(context.l10n.acctFieldGroupPickup, _p.featureCodes.pickupGroup, (v) => _upd((p) => p.copyWith(featureCodes: p.featureCodes.copyWith(pickupGroup: v)))),
                  _tx(context.l10n.acctFieldDirectedPickup, _p.featureCodes.pickupDirectedPrefix, (v) => _upd((p) => p.copyWith(featureCodes: p.featureCodes.copyWith(pickupDirectedPrefix: v)))),
                  _tx(context.l10n.acctFieldParkRetrieve, _p.featureCodes.parkRetrieve, (v) => _upd((p) => p.copyWith(featureCodes: p.featureCodes.copyWith(parkRetrieve: v))), hint: context.l10n.acctFieldParkRetrieveHint, sub: context.l10n.acctFieldParkRetrieveSub),
                  _tx(context.l10n.acctFieldDndOn, _p.featureCodes.dndOn, (v) => _upd((p) => p.copyWith(featureCodes: p.featureCodes.copyWith(dndOn: v)))),
                  _tx(context.l10n.acctFieldDndOff, _p.featureCodes.dndOff, (v) => _upd((p) => p.copyWith(featureCodes: p.featureCodes.copyWith(dndOff: v)))),
                  _tx(context.l10n.acctFieldForwardOn, _p.featureCodes.forwardOn, (v) => _upd((p) => p.copyWith(featureCodes: p.featureCodes.copyWith(forwardOn: v)))),
                  _tx(context.l10n.acctFieldForwardOff, _p.featureCodes.forwardOff, (v) => _upd((p) => p.copyWith(featureCodes: p.featureCodes.copyWith(forwardOff: v)))),
                ]),
                if (iax)
                  SettingsGroup(title: context.l10n.acctGroupAdvanced, footer: context.l10n.acctGroupAdvancedFooterIax, children: [
                    _tx(context.l10n.acctFieldCallerIdOverride, c.callerId ?? '', (v) => _cfg((x) => AccountConfigX.withCallerId(x, v)), hint: context.l10n.acctFieldCallerIdHint, sub: context.l10n.acctFieldCallerIdSub),
                  ])
                else
                SettingsGroup(title: context.l10n.acctGroupAdvanced, children: [
                  SelectTile<SessionTimers>(title: context.l10n.acctFieldSessionTimers, value: c.sessionTimers, options: {for (final s in SessionTimers.values) s: s.wire}, onChanged: (v) => _cfg((x) => x.copyWith(sessionTimers: v))),
                  _num(context.l10n.acctFieldSessionExpires, c.timerSe, (v) => _cfg((x) => x.copyWith(timerSe: v)), min: 90, max: 86400, sub: context.l10n.acctFieldSessionExpiresSub),
                  _sw(context.l10n.acctField100rel, c.use100rel, (v) => _cfg((x) => x.copyWith(use100rel: v))),
                  SelectTile<HoldType>(title: context.l10n.acctFieldHoldMethod, value: c.holdType, options: {HoldType.rfc3264: 'RFC 3264 (sendonly)', HoldType.rfc2543: 'RFC 2543 (0.0.0.0)'}, onChanged: (v) => _cfg((x) => x.copyWith(holdType: v))),
                  SelectTile<DtmfMethod>(title: context.l10n.acctFieldDtmfMethod, value: c.dtmfMethod, options: {DtmfMethod.rfc2833: 'RFC 2833', DtmfMethod.info: 'SIP INFO', DtmfMethod.inband: context.l10n.acctOptDtmfInband, DtmfMethod.auto: context.l10n.commonAutomatic}, onChanged: (v) => _cfg((x) => x.copyWith(dtmfMethod: v))),
                  SelectTile<RedirectPolicy>(title: context.l10n.acctFieldRedirects, value: c.redirect, options: {RedirectPolicy.auto: context.l10n.acctOptRedirectFollow, RedirectPolicy.ask: context.l10n.acctOptRedirectAsk, RedirectPolicy.reject: context.l10n.acctOptReject}, onChanged: (v) => _cfg((x) => x.copyWith(redirect: v))),
                  _sw(context.l10n.acctFieldLockCodec, c.lockCodec, (v) => _cfg((x) => x.copyWith(lockCodec: v))),
                  _sw(context.l10n.acctFieldMediaKeepAlive, c.streamKeepAlive, (v) => _cfg((x) => x.copyWith(streamKeepAlive: v))),
                  _sw(context.l10n.acctFieldDropCalls, c.dropCallsOnRegFail, (v) => _cfg((x) => x.copyWith(dropCallsOnRegFail: v))),
                  _tx(context.l10n.acctFieldCallerIdOverride, c.callerId ?? '', (v) => _cfg((x) => AccountConfigX.withCallerId(x, v)), hint: context.l10n.acctFieldCallerIdHint),
                  _tx('User-Agent', c.userAgent ?? '', (v) => _cfg((x) => AccountConfigX.withUserAgent(x, v)), hint: context.l10n.commonDefault),
                  _tx(context.l10n.acctFieldExtraHeaders, headersText, (v) => _cfg((x) => x.copyWith(headers: parseHeaders(v))), hint: context.l10n.acctFieldExtraHeadersHint),
                  _num(context.l10n.acctFieldRetryInterval, c.regRetrySec, (v) => _cfg((x) => x.copyWith(regRetrySec: v)), min: 0, max: 86400, sub: context.l10n.acctFieldRetryIntervalSub),
                  _num(context.l10n.acctFieldUnregTimeout, c.unregTimeoutMs, (v) => _cfg((x) => x.copyWith(unregTimeoutMs: v)), min: 0, max: 60000, sub: context.l10n.acctFieldUnregTimeoutSub),
                  _num(context.l10n.acctFieldMwiExpiry, c.mwiExpires, (v) => _cfg((x) => x.copyWith(mwiExpires: v)), min: 0, max: 86400),
                  _num(context.l10n.acctFieldDscpSip, c.dscp.sip, (v) => _cfg((x) => x.copyWith(dscp: DscpConfig(sip: v, rtp: x.dscp.rtp))), min: 0, max: 63, sub: context.l10n.acctFieldDscpSipSub),
                  _num(context.l10n.acctFieldDscpRtp, c.dscp.rtp, (v) => _cfg((x) => x.copyWith(dscp: DscpConfig(sip: x.dscp.sip, rtp: v))), min: 0, max: 63, sub: context.l10n.acctFieldDscpRtpSub),
                  _sw(context.l10n.acctFieldReinvite, c.ipChange.reinvite, (v) => _cfg((x) => x.copyWith(ipChange: x.ipChange.copyWith(reinvite: v)))),
                  _sw(context.l10n.acctFieldHangupOnIpChange, c.ipChange.hangupCalls, (v) => _cfg((x) => x.copyWith(ipChange: x.ipChange.copyWith(hangupCalls: v)))),
                ]),
                const SizedBox(height: 16),
                if (acc.errorOf(_p.id) != null)
                  Padding(padding: const EdgeInsets.all(16), child: Text(context.l10n.acctEditorLastError(acc.errorOf(_p.id)!))),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Integer validation with the engine's accepted range. [l] defaults to English.
String? validateInt(String s, {int? min, int? max, AppLocalizations? l}) {
  final loc = l ?? _en;
  final v = int.tryParse(s.trim());
  if (v == null) return loc.acctValidateInt;
  if (min != null && v < min) return loc.acctValidateMin(min);
  if (max != null && v > max) return loc.acctValidateMax(max);
  return null;
}

final AppLocalizations _en = lookupAppLocalizations(const Locale('en'));

/// Server host (optionally host:port) must be non-empty and have no spaces.
String? validateHost(String s, [AppLocalizations? l]) {
  final loc = l ?? _en;
  final v = s.trim();
  if (v.isEmpty) return loc.acctValidateHostEmpty;
  if (RegExp(r'\s').hasMatch(v)) return loc.acctValidateHostSpaces;
  if (v.contains('/') || v.contains('@')) return loc.acctValidateHostFormat;
  final m = RegExp(r'^(?:\[[^\]]+\]|[^:]+):(\d+)$').firstMatch(v);
  if (m != null) {
    final port = int.parse(m.group(1)!);
    if (port < 1 || port > 65535) return loc.acctValidatePortRange;
  }
  return null;
}

/// WebSocket upgrade path: starts with "/", at most 120 characters.
String? validateWsPath(String s, [AppLocalizations? l]) {
  final loc = l ?? _en;
  final v = s.trim();
  if (!v.startsWith('/')) return loc.acctValidateWsStart;
  if (v.length > 120) return loc.acctValidateWsLength;
  if (RegExp(r'\s').hasMatch(v)) return loc.acctValidateWsSpaces;
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
