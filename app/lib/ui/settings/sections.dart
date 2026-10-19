import '../pages/diagnostics/diagnostics_page.dart';
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:spcore_dart/spcore_dart.dart';

import '../../core/format.dart';
import '../../core/theme.dart';
import '../../models/chat.dart';
import '../../platform/android/android_reliability_group.dart';
import '../../platform/platform_services.dart';
import '../../services/accounts_controller.dart';
import '../../services/contacts_controller.dart';
import '../../services/dial_rules.dart';
import '../../services/engine_controller.dart';
import '../../services/history_controller.dart';
import '../../services/messages_controller.dart';
import '../../services/providers.dart';
import '../../services/settings_controller.dart';
import '../../storage/repositories.dart';
import '../widgets/basic_widgets.dart';
import '../widgets/call_widgets.dart';
import '../widgets/recording_player.dart';
import '../widgets/settings_tiles.dart';

SettingsController _s(WidgetRef ref) => ref.read(settingsProvider.notifier);

// ---------------------------------------------------------------------------
// Accounts

class AccountsSection extends ConsumerWidget {
  const AccountsSection({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final acc = ref.watch(accountsProvider);
    return ListView(
      padding: const EdgeInsets.only(bottom: 32),
      children: [
        if (acc.profiles.isEmpty)
          SizedBox(
            height: 360,
            child: EmptyState(
              icon: Icons.dns_rounded,
              title: 'Add your first account',
              subtitle: 'Connect to your PBX or SIP provider to start calling.',
              actionLabel: 'Add account',
              onAction: () => context.push('/account-wizard'),
            ),
          )
        else ...[
          const SectionHeader('Your accounts'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  for (var i = 0; i < acc.profiles.length; i++) ...[
                    _AccountTile(id: acc.profiles[i].id),
                    if (i != acc.profiles.length - 1) const Divider(height: 1, indent: 72),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: FilledButton.icon(
                key: const Key('add-account'),
                onPressed: () => context.push('/account-wizard'),
                icon: const Icon(Icons.add_rounded),
                label: const Text('Add account'),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _AccountTile extends ConsumerWidget {
  const _AccountTile({required this.id});
  final String id;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final acc = ref.watch(accountsProvider);
    final p = acc.byId(id)!;
    final st = acc.statusOf(id);
    return ListTile(
      leading: Stack(
        clipBehavior: Clip.none,
        children: [
          Avatar(name: p.name, color: Color(p.color)),
          Positioned(
            right: -2,
            bottom: -2,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(color: context.colors.card, shape: BoxShape.circle),
              child: StatusDot(color: statusColor(context, st), size: 11),
            ),
          ),
        ],
      ),
      title: Row(
        children: [
          Flexible(child: Text(p.name, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600))),
          if (p.isDefault) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6)),
              child: Text('Default', style: Theme.of(context).textTheme.labelSmall),
            ),
          ],
        ],
      ),
      subtitle: Text(acc.errorOf(id) ?? '${p.address}  ·  ${statusLabel(st)}', maxLines: 2, overflow: TextOverflow.ellipsis),
      trailing: Switch(value: p.enabled, onChanged: (v) => ref.read(accountsProvider.notifier).setEnabled(id, v)),
      onTap: () => context.push('/settings/accounts/$id'),
    );
  }
}

// ---------------------------------------------------------------------------
// Audio

class AudioSection extends ConsumerStatefulWidget {
  const AudioSection({super.key});
  @override
  ConsumerState<AudioSection> createState() => _AudioSectionState();
}

class _AudioSectionState extends ConsumerState<AudioSection> {
  Timer? _t;
  MediaLevels _levels = const MediaLevels();
  bool _loop = false;

  @override
  void initState() {
    super.initState();
    _t = Timer.periodic(const Duration(milliseconds: 200), (_) async {
      final ctl = ref.read(engineProvider.notifier);
      if (!ctl.hasEngine || !mounted) return;
      try {
        final l = await ctl.engine.levels();
        if (mounted) setState(() => _levels = l);
      } catch (_) {}
    });
  }

  @override
  void dispose() {
    _t?.cancel();
    if (_loop) {
      final ctl = ref.read(engineProvider.notifier);
      if (ctl.hasEngine) ctl.engine.loopback(false);
    }
    super.dispose();
  }

  Future<void> _toggleLoop(bool v) async {
    final ctl = ref.read(engineProvider.notifier);
    if (!ctl.hasEngine) return;
    try {
      await ctl.engine.loopback(v);
      setState(() => _loop = v);
    } on EngineException catch (e) {
      ref.read(noticeProvider.notifier).error('Echo test failed', details: '$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(settingsProvider);
    final dev = ref.watch(audioDevicesProvider).value;
    final desktop = !isMobilePlatform;
    Map<String, String> opts(List<AudioDevice>? l) => {'default': 'System default', for (final d in l ?? <AudioDevice>[]) d.devId: d.name};
    return ListView(
      padding: const EdgeInsets.only(bottom: 32),
      children: [
        SettingsGroup(
          title: 'Devices',
          children: [
            SelectTile<String>(icon: Icons.mic_rounded, title: 'Microphone', value: s.captureDev, options: opts(dev?.capture), onChanged: (v) => _s(ref).update({'captureDev': v})),
            SelectTile<String>(icon: Icons.speaker_rounded, title: 'Speaker', value: s.playbackDev, options: opts(dev?.playback), onChanged: (v) => _s(ref).update({'playbackDev': v})),
            if (desktop) SelectTile<String>(icon: Icons.notifications_active_rounded, title: 'Ringer', subtitle: 'Play the ringtone on a separate device', value: s.ringerDev, options: opts(dev?.playback), onChanged: (v) => _s(ref).update({'ringerDev': v})),
            ListTile(
              leading: const Icon(Icons.refresh_rounded),
              title: const Text('Refresh devices'),
              onTap: () async {
                final ctl = ref.read(engineProvider.notifier);
                if (ctl.hasEngine) await ctl.engine.refreshDevices();
                ref.invalidate(audioDevicesProvider);
              },
            ),
          ],
        ),
        SettingsGroup(
          title: 'Levels and test',
          children: [
            SliderTile(icon: Icons.mic_none_rounded, title: 'Microphone volume', value: s.micLevel, max: 2, divisions: 20, format: (v) => '${(v * 100).round()}%', onChanged: (v) => _s(ref).update({'micLevel': v})),
            _Vu(label: 'Mic level', value: _levels.mic / 255),
            SliderTile(icon: Icons.volume_up_rounded, title: 'Speaker volume', value: s.speakerLevel, max: 2, divisions: 20, format: (v) => '${(v * 100).round()}%', onChanged: (v) => _s(ref).update({'speakerLevel': v})),
            _Vu(label: 'Speaker level', value: _levels.speaker / 255),
            SwitchTile(icon: Icons.hearing_rounded, title: 'Echo test', subtitle: 'Plays your microphone back through the speaker. Use headphones to avoid feedback.', value: _loop, onChanged: _toggleLoop),
          ],
        ),
        SettingsGroup(
          title: 'Processing',
          children: [
            SelectTile<String>(
              title: 'Echo cancellation',
              value: s.ecAlgo,
              options: {for (final a in EcAlgo.values) a.wire: switch (a) { EcAlgo.auto => 'Automatic', EcAlgo.aec3 => 'WebRTC AEC3', EcAlgo.webrtc => 'WebRTC', EcAlgo.speex => 'Speex', EcAlgo.simple => 'Simple', EcAlgo.platform => 'Platform', EcAlgo.none => 'Off' }},
              onChanged: (v) => _s(ref).update({'ecAlgo': v}),
            ),
            SelectTile<int>(title: 'Echo tail', value: s.ecTailMs, options: const {64: '64 ms', 128: '128 ms', 200: '200 ms', 256: '256 ms', 400: '400 ms'}, onChanged: (v) => _s(ref).update({'ecTailMs': v})),
            SwitchTile(title: 'Noise suppression', value: s.noiseSuppression, onChanged: (v) => _s(ref).update({'noiseSuppression': v})),
            SwitchTile(title: 'Automatic gain control', value: s.agc, onChanged: (v) => _s(ref).update({'agc': v})),
            SwitchTile(title: 'Voice activity detection', subtitle: 'Saves bandwidth during silence', value: s.vad, onChanged: (v) => _s(ref).update({'vad': v})),
          ],
        ),
      ],
    );
  }
}

class _Vu extends StatelessWidget {
  const _Vu({required this.label, required this.value});
  final String label;
  final double value;
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final v = value.clamp(0.0, 1.0);
    return Semantics(
      label: label,
      value: '${(v * 100).round()} percent',
      child: Padding(
        padding: const EdgeInsets.fromLTRB(72, 0, 16, 12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: v,
            minHeight: 6,
            backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            color: v > 0.85 ? c.regFail : (v > 0.6 ? c.regWarn : c.regOk),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Codecs

const List<String> kFallbackCodecs = ['opus/48000/2', 'G722/16000/1', 'PCMU/8000/1', 'PCMA/8000/1', 'GSM/8000/1', 'iLBC/8000/1', 'speex/16000/1', 'speex/8000/1'];

final codecListProvider = FutureProvider.autoDispose<List<String>>((ref) async {
  final ctl = ref.watch(engineProvider.notifier);
  if (ctl.hasEngine) {
    try {
      return (await ctl.engine.codecs()).map((c) => c.id).toList();
    } catch (_) {}
  }
  return kFallbackCodecs;
});

/// Merges known ids with a saved order.
List<String> orderCodecs(List<String> known, List<String> saved) => [
  ...saved.where(known.contains),
  ...known.where((k) => !saved.contains(k)),
];

class CodecsSection extends ConsumerWidget {
  const CodecsSection({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(settingsProvider);
    final known = ref.watch(codecListProvider).value ?? kFallbackCodecs;
    final ordered = orderCodecs(known, s.codecOrder);
    return ListView(
      padding: const EdgeInsets.only(bottom: 32),
      children: [
        const SectionHeader('Order and availability'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Card(
            child: ReorderableListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              buildDefaultDragHandles: false,
              onReorder: (a, b) {
                if (b > a) b -= 1;
                final l = [...ordered];
                l.insert(b, l.removeAt(a));
                _s(ref).update({'codecOrder': l});
              },
              children: [
                for (var i = 0; i < ordered.length; i++)
                  SwitchListTile(
                    key: ValueKey(ordered[i]),
                    secondary: ReorderableDragStartListener(index: i, child: const Icon(Icons.drag_indicator_rounded)),
                    title: Text(ordered[i].split('/').first),
                    subtitle: Text(ordered[i].split('/').skip(1).join(' / ')),
                    value: !s.codecsDisabled.contains(ordered[i]),
                    onChanged: (v) {
                      final d = [...s.codecsDisabled];
                      v ? d.remove(ordered[i]) : d.add(ordered[i]);
                      _s(ref).update({'codecsDisabled': d, 'codecOrder': ordered});
                    },
                  ),
              ],
            ),
          ),
        ),
        const Padding(padding: EdgeInsets.fromLTRB(20, 8, 20, 0), child: Text('Drag to reorder. Accounts can override this list in their own settings.')),
        SettingsGroup(
          title: 'Opus',
          children: [
            SelectTile<int>(title: 'Bitrate', value: s.opusBitrate, options: const {16000: '16 kbps', 24000: '24 kbps', 32000: '32 kbps', 48000: '48 kbps', 64000: '64 kbps'}, onChanged: (v) => _s(ref).update({'opusBitrate': v})),
            SwitchTile(title: 'In-band FEC', subtitle: 'Recovers from packet loss', value: s.opusFec, onChanged: (v) => _s(ref).update({'opusFec': v})),
            SwitchTile(title: 'DTX', subtitle: 'Stop sending during silence', value: s.opusDtx, onChanged: (v) => _s(ref).update({'opusDtx': v})),
            SwitchTile(title: 'Constant bitrate', value: s.opusCbr, onChanged: (v) => _s(ref).update({'opusCbr': v})),
            SliderTile(title: 'Complexity', value: s.opusComplexity.toDouble(), min: 0, max: 10, divisions: 10, format: (v) => v.round().toString(), onChanged: (v) => _s(ref).update({'opusComplexity': v.round()})),
          ],
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Calls

class CallsSection extends ConsumerWidget {
  const CallsSection({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(settingsProvider);
    return ListView(
      padding: const EdgeInsets.only(bottom: 32),
      children: [
        SettingsGroup(
          title: 'Incoming',
          children: [
            SwitchTile(icon: Icons.do_not_disturb_on_rounded, title: 'Do not disturb', subtitle: 'Reject all incoming calls', value: s.dnd, onChanged: (v) => _s(ref).update({'dnd': v})),
            SelectTile<int>(title: 'Reject with', value: s.dndRejectCode, options: const {486: 'Busy Here (486)', 480: 'Temporarily Unavailable (480)', 603: 'Decline (603)'}, onChanged: (v) => _s(ref).update({'dndRejectCode': v})),
            SwitchTile(icon: Icons.phone_callback_rounded, title: 'Call waiting', subtitle: 'Allow a second incoming call during a call', value: s.callWaiting, onChanged: (v) => _s(ref).update({'callWaiting': v})),
            SelectTile<int>(title: 'When busy and waiting is off', value: s.busyRejectCode, options: const {486: 'Busy Here (486)', 603: 'Decline (603)'}, onChanged: (v) => _s(ref).update({'busyRejectCode': v})),
            SwitchTile(icon: Icons.person_off_rounded, title: 'Reject anonymous calls', value: s.rejectAnonymous, onChanged: (v) => _s(ref).update({'rejectAnonymous': v})),
          ],
        ),
        SettingsGroup(
          title: 'Auto-answer',
          footer: 'Call forwarding and per-account auto-answer are set in each account.',
          children: [
            SwitchTile(icon: Icons.auto_mode_rounded, title: 'Auto-answer all calls', value: s.autoAnswer, onChanged: (v) => _s(ref).update({'autoAnswer': v})),
            SelectTile<int>(title: 'Answer after', value: s.autoAnswerDelay, options: const {0: 'Immediately', 3: '3 seconds', 5: '5 seconds', 10: '10 seconds'}, onChanged: (v) => _s(ref).update({'autoAnswerDelay': v})),
            SwitchTile(title: 'Honour intercom headers', subtitle: 'Call-Info, Alert-Info and Answer-Mode auto-answer hints', value: s.allowAutoAnswerHeaders, onChanged: (v) => _s(ref).update({'allowAutoAnswerHeaders': v})),
          ],
        ),
        SettingsGroup(
          title: 'Blocked numbers',
          children: [
            for (final b in s.blocklist)
              ListTile(
                leading: const Icon(Icons.block_rounded),
                title: Text(b),
                trailing: IconButton(tooltip: 'Unblock $b', icon: const Icon(Icons.close_rounded), onPressed: () => _s(ref).update({'blocklist': s.blocklist.where((e) => e != b).toList()})),
              ),
            ListTile(
              leading: const Icon(Icons.add_rounded),
              title: const Text('Block a number'),
              onTap: () async {
                final n = await promptText(context, title: 'Block number', hint: 'Number or SIP address', keyboardType: TextInputType.phone);
                if (n != null && n.isNotEmpty) _s(ref).update({'blocklist': [...s.blocklist, n]});
              },
            ),
          ],
        ),
        SettingsGroup(
          title: 'Dial plan',
          children: [
            NavTile(icon: Icons.rule_rounded, title: 'Dial rules', subtitle: '${s.dialRules.length} rule(s)', onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const DialRulesEditor()))),
            TextTile(icon: Icons.emergency_rounded, title: 'Emergency numbers', subtitle: 'Comma separated. These bypass dial rules.', value: s.emergencyNumbers.join(', '), onChanged: (v) => _s(ref).update({'emergencyNumbers': v.split(RegExp(r'[,\s]+')).where((e) => e.isNotEmpty).toList()})),
          ],
        ),
      ],
    );
  }
}

class DialRulesEditor extends ConsumerStatefulWidget {
  const DialRulesEditor({super.key});
  @override
  ConsumerState<DialRulesEditor> createState() => _DialRulesEditorState();
}

class _DialRulesEditorState extends ConsumerState<DialRulesEditor> {
  final _test = TextEditingController(text: '+1 (555) 010-2030');

  List<DialRule> get _rules => [for (final r in ref.read(settingsProvider).dialRules) DialRule.fromJson(r)];
  Future<void> _save(List<DialRule> l) => _s(ref).update({'dialRules': l.map((e) => e.toJson()).toList()});

  Future<void> _edit(DialRule? r) async {
    final name = TextEditingController(text: r?.name ?? '');
    final pat = TextEditingController(text: r?.pattern ?? '');
    final rep = TextEditingController(text: r?.replacement ?? r'$1');
    String acc = r?.accountId ?? '';
    final accounts = ref.read(accountsProvider).profiles;
    final res = await showDialog<DialRule>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, set) {
          final err = DialRules.validatePattern(pat.text);
          return AlertDialog(
            title: Text(r == null ? 'New dial rule' : 'Edit dial rule'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: name, decoration: const InputDecoration(labelText: 'Name')),
                  const SizedBox(height: 10),
                  TextField(key: const Key('rule-pattern'), controller: pat, onChanged: (_) => set(() {}), decoration: InputDecoration(labelText: 'Pattern (regex)', helperText: r'e.g. 0(\d{9})', errorText: err)),
                  const SizedBox(height: 10),
                  TextField(key: const Key('rule-replacement'), controller: rep, decoration: const InputDecoration(labelText: 'Replacement', helperText: r'Use $1, $2 for groups')),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: acc,
                    decoration: const InputDecoration(labelText: 'Route through account'),
                    items: [const DropdownMenuItem(value: '', child: Text('Default')), for (final a in accounts) DropdownMenuItem(value: a.id, child: Text(a.name))],
                    onChanged: (v) => acc = v ?? '',
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
              FilledButton(
                onPressed: err != null || pat.text.isEmpty ? null : () => Navigator.pop(ctx, DialRule(id: r?.id ?? newId(), name: name.text, pattern: pat.text, replacement: rep.text, accountId: acc, enabled: r?.enabled ?? true)),
                child: const Text('Save'),
              ),
            ],
          );
        },
      ),
    );
    if (res == null) return;
    final l = _rules;
    final i = l.indexWhere((e) => e.id == res.id);
    i >= 0 ? l[i] = res : l.add(res);
    await _save(l);
  }

  @override
  void dispose() {
    _test.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(settingsProvider);
    final rules = [for (final r in s.dialRules) DialRule.fromJson(r)];
    final result = DialRules(rules: rules, emergencyNumbers: s.emergencyNumbers).apply(_test.text);
    final accounts = ref.watch(accountsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Dial rules'), actions: [IconButton(tooltip: 'Add rule', onPressed: () => _edit(null), icon: const Icon(Icons.add_rounded))]),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Live test', style: Theme.of(context).textTheme.titleSmall),
                      const SizedBox(height: 8),
                      TextField(key: const Key('rule-test'), controller: _test, onChanged: (_) => setState(() {}), decoration: const InputDecoration(labelText: 'Typed number')),
                      const SizedBox(height: 10),
                      Row(children: [
                        const Icon(Icons.arrow_forward_rounded, size: 18),
                        const SizedBox(width: 8),
                        Expanded(child: SelectableText(result.target.isEmpty ? '(nothing)' : result.target, key: const Key('rule-result'), style: tabular(Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)))),
                      ]),
                      if (result.emergency) const Text('Emergency number: dialled as typed'),
                      if (result.accountId != null) Text('via ${accounts.byId(result.accountId!)?.name ?? 'account'}'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              if (rules.isEmpty)
                const Padding(padding: EdgeInsets.all(24), child: Text('No rules. Numbers are cleaned (spaces, dashes, brackets removed) and dialled as typed. Rules run top to bottom; the first match wins.', textAlign: TextAlign.center))
              else
                Card(
                  child: ReorderableListView(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    onReorder: (a, b) {
                      if (b > a) b -= 1;
                      final l = [...rules];
                      l.insert(b, l.removeAt(a));
                      _save(l);
                    },
                    children: [
                      for (final r in rules)
                        ListTile(
                          key: ValueKey(r.id),
                          title: Text(r.name.isEmpty ? r.pattern : r.name),
                          subtitle: Text('${r.pattern}  →  ${r.replacement}'),
                          leading: Switch(value: r.enabled, onChanged: (v) => _save([for (final e in rules) e.id == r.id ? e.copyWith(enabled: v) : e])),
                          trailing: IconButton(
                            tooltip: 'Delete rule',
                            icon: const Icon(Icons.delete_outline_rounded),
                            onPressed: () async {
                              if (await confirm(context, title: 'Delete rule?', message: r.name.isEmpty ? r.pattern : r.name)) _save(rules.where((e) => e.id != r.id).toList());
                            },
                          ),
                          onTap: () => _edit(r),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Network

class NetworkSection extends ConsumerWidget {
  const NetworkSection({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(settingsProvider);
    int port(String v) => int.tryParse(v) ?? 0;
    List<String> list(String v) => v.split(RegExp(r'[,\s]+')).where((e) => e.isNotEmpty).toList();
    return ListView(
      padding: const EdgeInsets.only(bottom: 32),
      children: [
        SettingsGroup(
          title: 'Transports',
          footer: 'Port 0 picks a random free port. Changing transports restarts the call engine.',
          children: [
            SwitchTile(title: 'UDP', value: s.udpEnabled, onChanged: (v) => _s(ref).update({'udpEnabled': v})),
            TextTile(title: 'UDP port', value: '${s.udpPort}', keyboardType: TextInputType.number, onChanged: (v) => _s(ref).update({'udpPort': port(v)})),
            SwitchTile(title: 'TCP', value: s.tcpEnabled, onChanged: (v) => _s(ref).update({'tcpEnabled': v})),
            TextTile(title: 'TCP port', value: '${s.tcpPort}', keyboardType: TextInputType.number, onChanged: (v) => _s(ref).update({'tcpPort': port(v)})),
            SwitchTile(title: 'TLS', value: s.tlsEnabled, onChanged: (v) => _s(ref).update({'tlsEnabled': v})),
            TextTile(title: 'TLS port', value: '${s.tlsPort}', keyboardType: TextInputType.number, onChanged: (v) => _s(ref).update({'tlsPort': port(v)})),
            SwitchTile(icon: Icons.verified_rounded, title: 'Verify server certificates', subtitle: 'Turn off only for self-signed PBXs, or pin the certificate below', value: s.tlsVerify, onChanged: (v) => _s(ref).update({'tlsVerify': v})),
            TextTile(icon: Icons.push_pin_rounded, title: 'Pinned certificates', subtitle: 'host=SHA256 fingerprint, comma separated', value: s.tlsPins.join(', '), onChanged: (v) => _s(ref).update({'tlsPins': list(v)})),
          ],
        ),
        SettingsGroup(
          title: 'NAT traversal',
          children: [
            TextTile(icon: Icons.public_rounded, title: 'STUN servers', subtitle: 'host:port, comma separated', value: s.stunServers.join(', '), onChanged: (v) => _s(ref).update({'stunServers': list(v)})),
            const ListTile(leading: Icon(Icons.info_outline_rounded), title: Text('ICE and TURN'), subtitle: Text('Configured per account under NAT')),
          ],
        ),
        SettingsGroup(
          title: 'Advanced',
          children: [
            SwitchTile(title: 'IPv6', value: s.ipv6, onChanged: (v) => _s(ref).update({'ipv6': v})),
            SwitchTile(title: 'QoS (DSCP marking)', subtitle: 'Mark SIP and voice packets for priority', value: s.qos, onChanged: (v) => _s(ref).update({'qos': v})),
            TextTile(icon: Icons.dns_rounded, title: 'DNS servers', subtitle: 'Leave empty for automatic', hint: 'Automatic', value: s.dnsServers.join(', '), onChanged: (v) => _s(ref).update({'dnsServers': list(v)})),
            TextTile(title: 'RTP port start', value: '${s.rtpPort}', keyboardType: TextInputType.number, onChanged: (v) => _s(ref).update({'rtpPort': port(v)})),
            TextTile(title: 'RTP port range', subtitle: '0 uses the default', value: '${s.rtpPortRange}', keyboardType: TextInputType.number, onChanged: (v) => _s(ref).update({'rtpPortRange': port(v)})),
          ],
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Recording

class RecordingSection extends ConsumerWidget {
  const RecordingSection({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(settingsProvider);
    return ListView(
      padding: const EdgeInsets.only(bottom: 32),
      children: [
        SettingsGroup(
          title: 'Recording',
          footer: 'Check your local laws before recording calls. Recordings are WAV files stored on this device.',
          children: [
            SwitchTile(icon: Icons.fiber_manual_record_rounded, title: 'Record all calls automatically', value: s.autoRecord, onChanged: (v) => _s(ref).update({'autoRecord': v})),
            TextTile(icon: Icons.folder_rounded, title: 'Folder', subtitle: 'Where recordings are saved', hint: 'App documents / Recordings', value: s.recordingFolder, onChanged: (v) => _s(ref).update({'recordingFolder': v})),
            SwitchTile(title: 'Recording beep', subtitle: 'Warn the other party periodically', value: s.recordBeep, onChanged: (v) => _s(ref).update({'recordBeep': v})),
          ],
        ),
        FutureBuilder(
          future: ref.read(recordingsRepoProvider).loadAll(),
          builder: (context, snap) {
            final list = snap.data ?? const <RecordingMeta>[];
            if (list.isEmpty) return const SizedBox.shrink();
            return SettingsGroup(
              title: 'Saved recordings',
              children: [
                for (final r in list)
                  ExpansionTile(
                    leading: const Icon(Icons.graphic_eq_rounded),
                    title: Text(r.remote.isEmpty ? 'Recording' : r.remote),
                    subtitle: Text('${dayLabel(r.time)}, ${timeLabel(r.time)}  ·  ${formatMs(r.durationMs)}'),
                    children: [Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: RecordingPlayer(path: r.path))],
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Notifications / appearance / privacy / LAN

class NotificationsSection extends ConsumerWidget {
  const NotificationsSection({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(settingsProvider);
    return ListView(
      padding: const EdgeInsets.only(bottom: 32),
      children: [
        if (defaultTargetPlatform == TargetPlatform.android && !kIsWeb) const AndroidReliabilityGroup(),
        SettingsGroup(
          title: 'Ringtone',
          children: [
            SelectTile<String>(icon: Icons.music_note_rounded, title: 'Default ringtone', value: s.ringtone, options: const {'default': 'Default', 'classic': 'Classic', 'soft': 'Soft'}, onChanged: (v) => _s(ref).update({'ringtone': v})),
            SliderTile(icon: Icons.volume_up_rounded, title: 'Ringer volume', value: s.ringerVolume, divisions: 10, format: (v) => '${(v * 100).round()}%', onChanged: (v) => _s(ref).update({'ringerVolume': v})),
            TextTile(icon: Icons.audio_file_rounded, title: 'Custom ringtone file', subtitle: 'Path to a WAV file (desktop)', value: s.ringtone.contains('/') ? s.ringtone : '', hint: 'None', onChanged: (v) => _s(ref).update({'ringtone': v.isEmpty ? 'default' : v})),
          ],
        ),
        SettingsGroup(
          title: 'Notifications',
          children: [
            ListTile(
              leading: const Icon(Icons.notifications_rounded),
              title: const Text('Request permissions'),
              subtitle: const Text('Microphone and notifications'),
              onTap: () async {
                final r = await ref.read(platformServicesProvider).requestPermissions();
                ref.read(noticeProvider.notifier).show('Microphone: ${r.microphone.name}, notifications: ${r.notifications.name}');
              },
            ),
            SwitchTile(icon: Icons.keyboard_rounded, title: 'Send typing indicators', value: s.sendTyping, onChanged: (v) => _s(ref).update({'sendTyping': v})),
          ],
        ),
      ],
    );
  }
}

class AppearanceSection extends ConsumerWidget {
  const AppearanceSection({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(settingsProvider);
    return ListView(
      padding: const EdgeInsets.only(bottom: 32),
      children: [
        SettingsGroup(
          title: 'Theme',
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: SegmentedButton<ThemeMode>(
                segments: const [
                  ButtonSegment(value: ThemeMode.system, label: Text('System'), icon: Icon(Icons.brightness_auto_rounded)),
                  ButtonSegment(value: ThemeMode.light, label: Text('Light'), icon: Icon(Icons.light_mode_rounded)),
                  ButtonSegment(value: ThemeMode.dark, label: Text('Dark'), icon: Icon(Icons.dark_mode_rounded)),
                ],
                selected: {s.themeMode},
                onSelectionChanged: (v) => _s(ref).update({'themeMode': v.first.name}),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(width: double.infinity),
                  Text('Accent colour', style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      for (final c in kAvatarPalette)
                        Semantics(
                          button: true,
                          selected: s.accent == c,
                          label: 'Accent colour option',
                          child: InkResponse(
                            onTap: () => _s(ref).update({'accent': c}),
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(color: Color(c), shape: BoxShape.circle, border: s.accent == c ? Border.all(color: Theme.of(context).colorScheme.onSurface, width: 3) : null),
                              child: s.accent == c ? const Icon(Icons.check_rounded, color: Colors.white) : null,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            SwitchTile(icon: Icons.density_small_rounded, title: 'Compact density', value: s.compactDensity, onChanged: (v) => _s(ref).update({'compactDensity': v})),
          ],
        ),
      ],
    );
  }
}

class PrivacySection extends ConsumerWidget {
  const PrivacySection({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(settingsProvider);
    Future<void> wipe(String what, Future<void> Function() f) async {
      if (await confirm(context, title: 'Delete $what?', message: 'This cannot be undone.', confirmLabel: 'Delete')) {
        await f();
        ref.read(noticeProvider.notifier).show('Deleted $what');
      }
    }

    return ListView(
      padding: const EdgeInsets.only(bottom: 32),
      children: [
        SettingsGroup(
          title: 'Security',
          children: [
            const ListTile(leading: Icon(Icons.shield_rounded), title: Text('Passwords'), subtitle: Text('Stored in the system keychain / keystore (encrypted file fallback)')),
            SwitchTile(icon: Icons.lock_rounded, title: 'App lock (PIN or biometrics)', subtitle: 'Coming soon', value: s.appLock, onChanged: null),
          ],
        ),
        const SettingsGroup(
          title: 'Privacy',
          children: [ListTile(leading: Icon(Icons.visibility_off_rounded), title: Text('No telemetry'), subtitle: Text('SoftphonePro sends no analytics. Network traffic goes only to your SIP servers.'))],
        ),
        SettingsGroup(
          title: 'Your data',
          children: [
            ListTile(leading: const Icon(Icons.history_rounded), title: const Text('Clear call history'), onTap: () => wipe('call history', () => ref.read(historyProvider.notifier).clear())),
            ListTile(leading: const Icon(Icons.people_rounded), title: const Text('Delete all contacts'), onTap: () => wipe('all contacts', () => ref.read(contactsProvider.notifier).clear())),
            ListTile(
              leading: const Icon(Icons.chat_rounded),
              title: const Text('Delete all messages'),
              onTap: () => wipe('all messages', () async {
                final m = ref.read(messagesProvider.notifier);
                for (final c in ref.read(messagesProvider).conversations) {
                  await m.deleteConversation(c.key);
                }
              }),
            ),
          ],
        ),
      ],
    );
  }
}

class LanSection extends ConsumerWidget {
  const LanSection({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(settingsProvider);
    final acc = ref.watch(accountsProvider);
    return ListView(
      padding: const EdgeInsets.only(bottom: 32),
      children: [
        SettingsGroup(
          title: 'LAN Link',
          footer: 'Devices on the same network find each other, pair with a 6-digit code and talk directly, without any server.',
          children: [
            SwitchTile(icon: Icons.lan_rounded, title: 'Enable LAN Link', value: s.lanEnabled, onChanged: (v) => _s(ref).update({'lanEnabled': v})),
            TextTile(icon: Icons.badge_rounded, title: 'Device name', hint: 'This device', value: s.lanDeviceName, onChanged: (v) => _s(ref).update({'lanDeviceName': v})),
            SwitchTile(icon: Icons.volume_up_rounded, title: 'Allow intercom', subtitle: 'Let paired devices call you and be auto-answered', value: s.lanAllowIntercom, onChanged: (v) => _s(ref).update({'lanAllowIntercom': v})),
            SwitchTile(icon: Icons.download_for_offline_rounded, title: 'Auto-accept files from paired devices', subtitle: 'Otherwise you are asked for every file', value: s.lanAutoAcceptFiles, onChanged: (v) => _s(ref).update({'lanAutoAcceptFiles': v})),
            SwitchTile(icon: Icons.call_received_rounded, title: 'Let paired devices pull my calls', subtitle: 'A paired device can take over a call that is active here', value: s.lanAllowPull, onChanged: (v) => _s(ref).update({'lanAllowPull': v})),
            TextTile(icon: Icons.folder_rounded, title: 'Downloads folder', hint: 'Default (Downloads/SoftphonePro)', value: s.lanDownloadsDir, onChanged: (v) => _s(ref).update({'lanDownloadsDir': v})),
            TextTile(icon: Icons.settings_ethernet_rounded, title: 'Link port', hint: 'Automatic', value: s.lanLinkPort == 0 ? '' : '${s.lanLinkPort}', keyboardType: TextInputType.number, onChanged: (v) => _s(ref).update({'lanLinkPort': int.tryParse(v.trim()) ?? 0})),
          ],
        ),
        if (acc.profiles.isNotEmpty)
          SettingsGroup(
            title: 'Accounts shared with paired devices',
            footer: 'Sharing a registered account lets a paired device on the same server receive your calls directly (call transfer) instead of relaying them.',
            children: [
              for (final p in acc.profiles)
                CheckboxListTile(
                  title: Text(p.name),
                  subtitle: Text(p.address),
                  value: s.lanShareAors.contains(p.id),
                  onChanged: (v) {
                    final l = [...s.lanShareAors]..remove(p.id);
                    if (v == true) l.add(p.id);
                    _s(ref).update({'lanShareAors': l});
                  },
                ),
            ],
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Diagnostics (replaceable through diagnosticsPageBuilderProvider)

final diagnosticsPageBuilderProvider = Provider<WidgetBuilder>((ref) => (context) => const DiagnosticsPage());

class DiagnosticsSection extends ConsumerWidget {
  const DiagnosticsSection({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) => Builder(builder: ref.watch(diagnosticsPageBuilderProvider));
}

// ---------------------------------------------------------------------------
// Advanced

class AdvancedSection extends ConsumerWidget {
  const AdvancedSection({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(settingsProvider);
    final e = ref.watch(engineProvider);
    final desktop = isDesktopPlatform;
    return ListView(
      padding: const EdgeInsets.only(bottom: 32),
      children: [
        SettingsGroup(
          title: 'Engine',
          children: [
            SwitchTile(icon: Icons.science_rounded, title: 'Use simulator', subtitle: 'Run without the native engine. Calls are simulated.', value: s.useSimulator, onChanged: (v) => _s(ref).update({'useSimulator': v})),
            SelectTile<int>(title: 'Log level', value: s.logLevel, options: const {1: 'Errors', 3: 'Info', 4: 'Debug', 5: 'Verbose'}, onChanged: (v) => _s(ref).update({'logLevel': v})),
            SwitchTile(title: 'SIP trace', value: s.sipTrace, onChanged: (v) => _s(ref).update({'sipTrace': v})),
            ListTile(
              leading: const Icon(Icons.restart_alt_rounded),
              title: const Text('Restart engine'),
              subtitle: Text('${e.phase.name}${e.version.isNotEmpty ? ', ${e.version}' : ''}'),
              onTap: () => ref.read(engineProvider.notifier).restart(),
            ),
          ],
        ),
        if (desktop)
          SettingsGroup(
            title: 'Desktop',
            children: [
              SwitchTile(icon: Icons.login_rounded, title: 'Start at login', value: s.startAtLogin, onChanged: (v) {
                _s(ref).update({'startAtLogin': v});
                ref.read(platformServicesProvider).setStartAtLogin(v);
              }),
              SwitchTile(icon: Icons.minimize_rounded, title: 'Close to tray', subtitle: 'Closing the window keeps SoftphonePro running so calls can still ring. Quit from the tray / menu bar icon.', value: s.minimizeToTray, onChanged: (v) => _s(ref).update({'minimizeToTray': v})),
            ],
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// About

class AboutSection extends StatelessWidget {
  const AboutSection({super.key});
  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    const notices = [
      ('PJSIP', 'GPLv2 or later. SIP/media stack.'),
      ('OpenSSL', 'Apache License 2.0. TLS and SRTP.'),
      ('Opus', 'BSD 3-clause. Audio codec.'),
      ('bcg729', 'GPLv3. G.729 codec.'),
      ('Inter', 'SIL Open Font License 1.1. App typeface.'),
      ('Flutter and packages', 'BSD 3-clause and MIT. See licence page.'),
    ];
    return ListView(
      padding: const EdgeInsets.only(bottom: 32),
      children: [
        const SizedBox(height: 24),
        Center(
          child: Column(
            children: [
              ClipRRect(borderRadius: BorderRadius.circular(20), child: Image.asset('assets/branding/icon_1024.png', width: 84, height: 84, errorBuilder: (_, __, ___) => const Icon(Icons.phone_rounded, size: 64))),
              const SizedBox(height: 12),
              Text('SoftphonePro', style: t.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
              Text('Version $kAppVersion', style: t.textTheme.bodyMedium?.copyWith(color: t.colorScheme.onSurfaceVariant)),
            ],
          ),
        ),
        SettingsGroup(
          title: 'Licence',
          footer: 'SoftphonePro is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, version 3 or later. It is distributed WITHOUT ANY WARRANTY.',
          children: [
            NavTile(icon: Icons.gavel_rounded, title: 'GNU GPL v3 or later', subtitle: 'Source code available in the project repository', onTap: () => showLicensePage(context: context, applicationName: 'SoftphonePro', applicationVersion: kAppVersion)),
          ],
        ),
        SettingsGroup(
          title: 'Third-party notices',
          children: [for (final n in notices) ListTile(title: Text(n.$1), subtitle: Text(n.$2))],
        ),
      ],
    );
  }
}

