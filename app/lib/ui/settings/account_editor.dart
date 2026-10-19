import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:spcore_dart/spcore_dart.dart';

import '../../core/format.dart';
import '../../models/account_profile.dart';
import '../../services/accounts_controller.dart';
import '../widgets/settings_tiles.dart';
import 'sections.dart';

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

  Widget _tx(String title, String value, ValueChanged<String> on, {bool obscure = false, String? hint, String? sub, TextInputType? kb, IconData? icon}) =>
      TextTile(title: title, value: value, onChanged: on, obscure: obscure, hint: hint, subtitle: sub, keyboardType: kb, icon: icon);
  Widget _sw(String title, bool v, ValueChanged<bool> on, {String? sub}) => SwitchTile(title: title, subtitle: sub, value: v, onChanged: on);
  Widget _num(String title, int v, ValueChanged<int> on, {String? sub}) => TextTile(title: title, subtitle: sub, value: '$v', keyboardType: TextInputType.number, onChanged: (s) => on(int.tryParse(s) ?? v));

  @override
  Widget build(BuildContext context) {
    final c = _p.config;
    final acc = ref.watch(accountsProvider);
    final known = ref.watch(codecListProvider).value ?? kFallbackCodecs;
    final codecs = c.codecs.isEmpty ? <String>[] : orderCodecs(known, c.codecs);
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
                  _tx('Authorization user', c.authUser ?? '', (v) => _cfg((x) => AccountConfigX.withAuth(x, v)), hint: 'Same as username'),
                  _tx('Password', c.password, (v) => _cfg((x) => x.copyWith(password: v)), obscure: true),
                  _tx('Server / domain', c.domain, (v) => _cfg((x) => x.copyWith(domain: v))),
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
                SettingsGroup(title: 'Server and transport', children: [
                  _tx('Registrar override', c.registrar ?? '', (v) => _cfg((x) => AccountConfigX.withRegistrar(x, v)), hint: 'sip:server:5060'),
                  _tx('Outbound proxies', c.proxies.join(', '), (v) => _cfg((x) => x.copyWith(proxies: v.split(RegExp(r'[,\s]+')).where((e) => e.isNotEmpty).toList())), hint: 'None'),
                  SelectTile<AccTransport>(title: 'Transport', value: c.transport, options: {for (final t in AccTransport.values) t: t.wire.toUpperCase()}, onChanged: (v) => _cfg((x) => x.copyWith(transport: v))),
                  _num('Registration expiry (s)', c.regExpires, (v) => _cfg((x) => x.copyWith(regExpires: v))),
                  _num('Keep-alive (s)', c.keepAliveSec, (v) => _cfg((x) => x.copyWith(keepAliveSec: v))),
                  _num('Local SIP port', c.localPort, (v) => _cfg((x) => x.copyWith(localPort: v)), sub: '0 uses the shared transport'),
                  _sw('Register', c.register, (v) => _cfg((x) => x.copyWith(register: v)), sub: 'Turn off for trunks without registration'),
                  _sw('SIP Outbound (RFC 5626)', c.sipOutbound, (v) => _cfg((x) => x.copyWith(sipOutbound: v))),
                ]),
                SettingsGroup(title: 'NAT', children: [
                  _sw('Use STUN', c.useStun, (v) => _cfg((x) => x.copyWith(useStun: v))),
                  _sw('ICE', c.ice, (v) => _cfg((x) => x.copyWith(ice: v))),
                  _sw('TURN relay', c.turn.enabled, (v) => _cfg((x) => x.copyWith(turn: x.turn.copyWith(enabled: v)))),
                  if (c.turn.enabled) ...[
                    _tx('TURN server', c.turn.server, (v) => _cfg((x) => x.copyWith(turn: x.turn.copyWith(server: v)))),
                    _tx('TURN username', c.turn.username, (v) => _cfg((x) => x.copyWith(turn: x.turn.copyWith(username: v)))),
                    _tx('TURN password', c.turn.password, (v) => _cfg((x) => x.copyWith(turn: x.turn.copyWith(password: v))), obscure: true),
                  ],
                  _sw('Rewrite Contact header', c.contactRewrite, (v) => _cfg((x) => x.copyWith(contactRewrite: v))),
                  _sw('Rewrite Via header', c.viaRewrite, (v) => _cfg((x) => x.copyWith(viaRewrite: v))),
                  _sw('Rewrite SDP address', c.sdpNatRewrite, (v) => _cfg((x) => x.copyWith(sdpNatRewrite: v))),
                  _sw('RTCP multiplexing', c.rtcpMux, (v) => _cfg((x) => x.copyWith(rtcpMux: v))),
                  SelectTile<Ipv6Mode>(title: 'IPv6 signalling', value: c.ipv6Sip, options: {for (final m in Ipv6Mode.values) m: m.wire}, onChanged: (v) => _cfg((x) => x.copyWith(ipv6Sip: v))),
                  SelectTile<Ipv6Mode>(title: 'IPv6 media', value: c.ipv6Media, options: {for (final m in Ipv6Mode.values) m: m.wire}, onChanged: (v) => _cfg((x) => x.copyWith(ipv6Media: v))),
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
                SettingsGroup(title: 'Features', children: [
                  _tx('Voicemail number', _p.voicemailNumber, (v) => _upd((p) => p.copyWith(voicemailNumber: v)), hint: '*97'),
                  _sw('Voicemail indicator (MWI)', c.mwi, (v) => _cfg((x) => x.copyWith(mwi: v))),
                  _sw('Publish my presence', c.publishPresence, (v) => _cfg((x) => x.copyWith(publishPresence: v))),
                  _sw('Do not disturb', _p.dnd, (v) => _upd((p) => p.copyWith(dnd: v))),
                  SelectTile<ForwardMode>(title: 'Call forwarding', value: _p.forwarding.mode, options: const {ForwardMode.off: 'Off', ForwardMode.always: 'Always', ForwardMode.busy: 'When busy', ForwardMode.noAnswer: 'No answer'}, onChanged: (v) => _upd((p) => p.copyWith(forwarding: p.forwarding.copyWith(mode: v)))),
                  if (_p.forwarding.mode != ForwardMode.off) _tx('Forward to', _p.forwarding.target, (v) => _upd((p) => p.copyWith(forwarding: p.forwarding.copyWith(target: v))), hint: 'Number or SIP address'),
                  if (_p.forwarding.mode == ForwardMode.noAnswer) _num('Ring for (s)', _p.forwarding.noAnswerSec, (v) => _upd((p) => p.copyWith(forwarding: p.forwarding.copyWith(noAnswerSec: v)))),
                  _sw('Auto-answer', _p.autoAnswer.enabled, (v) => _upd((p) => p.copyWith(autoAnswer: p.autoAnswer.copyWith(enabled: v)))),
                  if (_p.autoAnswer.enabled) ...[
                    _num('Answer after (s)', _p.autoAnswer.delaySec, (v) => _upd((p) => p.copyWith(autoAnswer: p.autoAnswer.copyWith(delaySec: v)))),
                    _sw('Only for intercom calls', _p.autoAnswer.onlyIntercomHeaders, (v) => _upd((p) => p.copyWith(autoAnswer: p.autoAnswer.copyWith(onlyIntercomHeaders: v))), sub: 'Needs an auto-answer header from the PBX'),
                  ],
                  SelectTile<String>(title: 'Ringtone', value: _p.ringtone, options: const {'default': 'Default', 'classic': 'Classic', 'soft': 'Soft'}, onChanged: (v) => _upd((p) => p.copyWith(ringtone: v))),
                ]),
                SettingsGroup(title: 'Feature codes', footer: 'Dialled for park, pickup, DND and forwarding on your PBX.', children: [
                  _tx('Park', _p.featureCodes.park, (v) => _upd((p) => p.copyWith(featureCodes: p.featureCodes.copyWith(park: v)))),
                  _tx('Group pickup', _p.featureCodes.pickupGroup, (v) => _upd((p) => p.copyWith(featureCodes: p.featureCodes.copyWith(pickupGroup: v)))),
                  _tx('Directed pickup prefix', _p.featureCodes.pickupDirectedPrefix, (v) => _upd((p) => p.copyWith(featureCodes: p.featureCodes.copyWith(pickupDirectedPrefix: v)))),
                  _tx('DND on', _p.featureCodes.dndOn, (v) => _upd((p) => p.copyWith(featureCodes: p.featureCodes.copyWith(dndOn: v)))),
                  _tx('DND off', _p.featureCodes.dndOff, (v) => _upd((p) => p.copyWith(featureCodes: p.featureCodes.copyWith(dndOff: v)))),
                  _tx('Forward on', _p.featureCodes.forwardOn, (v) => _upd((p) => p.copyWith(featureCodes: p.featureCodes.copyWith(forwardOn: v)))),
                  _tx('Forward off', _p.featureCodes.forwardOff, (v) => _upd((p) => p.copyWith(featureCodes: p.featureCodes.copyWith(forwardOff: v)))),
                ]),
                SettingsGroup(title: 'Advanced', children: [
                  SelectTile<SessionTimers>(title: 'Session timers', value: c.sessionTimers, options: {for (final s in SessionTimers.values) s: s.wire}, onChanged: (v) => _cfg((x) => x.copyWith(sessionTimers: v))),
                  _num('Session expires (s)', c.timerSe, (v) => _cfg((x) => x.copyWith(timerSe: v))),
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
                  _num('Retry interval (s)', c.regRetrySec, (v) => _cfg((x) => x.copyWith(regRetrySec: v))),
                  _num('Unregister timeout (ms)', c.unregTimeoutMs, (v) => _cfg((x) => x.copyWith(unregTimeoutMs: v))),
                  _num('MWI subscription expiry (s)', c.mwiExpires, (v) => _cfg((x) => x.copyWith(mwiExpires: v))),
                  _num('DSCP for SIP', c.dscp.sip, (v) => _cfg((x) => x.copyWith(dscp: DscpConfig(sip: v, rtp: x.dscp.rtp)))),
                  _num('DSCP for RTP', c.dscp.rtp, (v) => _cfg((x) => x.copyWith(dscp: DscpConfig(sip: x.dscp.sip, rtp: v)))),
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
