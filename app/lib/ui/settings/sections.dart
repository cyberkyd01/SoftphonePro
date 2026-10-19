import '../../core/bidi.dart';
import '../pages/diagnostics/diagnostics_page.dart';
import 'encryption_settings.dart';
import 'update_settings.dart';
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:spcore_dart/spcore_dart.dart';

import '../../core/format.dart';
import '../../l10n/l10n.dart';
import '../../core/theme.dart';
import '../../security/app_lock_settings.dart';
import '../../platform/android/android_reliability_group.dart';
import '../../automation/automation_section.dart';
import '../../platform/desktop/default_handler.dart';
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
import '../pages/recordings/recording_settings.dart';
import '../../services/ringtones.dart';
import '../../audio/device_labels.dart';
import '../../audio/voice_isolation.dart' show strengthLabel;
import 'audio_call_settings.dart';
import '../pages/audio/voice_isolation_page.dart';
import 'native_licenses.dart';
import 'speed_dial_page.dart';
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
              title: context.l10n.settingsAccountsEmptyTitle,
              subtitle: context.l10n.settingsAccountsEmptySubtitle,
              actionLabel: context.l10n.settingsAccountsAdd,
              onAction: () => context.push('/account-wizard'),
            ),
          )
        else ...[
          SectionHeader(context.l10n.settingsAccountsYourAccounts),
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
              alignment: AlignmentDirectional.centerStart,
              child: FilledButton.icon(
                key: const Key('add-account'),
                onPressed: () => context.push('/account-wizard'),
                icon: const Icon(Icons.add_rounded),
                label: Text(context.l10n.settingsAccountsAdd),
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
          PositionedDirectional(
            end: -2,
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
          Flexible(child: Text(bidiSafe(p.name), overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600))),
          if (p.isDefault) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6)),
              child: Text(context.l10n.commonDefault, style: Theme.of(context).textTheme.labelSmall),
            ),
          ],
        ],
      ),
      subtitle: Text(acc.errorOf(id) ?? (acc.usingBackup.contains(id) ? context.l10n.settingsAccountSubtitleBackup(ltr(p.address), statusLabel(st, context.l10n)) : context.l10n.settingsAccountSubtitle(ltr(p.address), statusLabel(st, context.l10n))), maxLines: 2, overflow: TextOverflow.ellipsis),
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
  late final EngineController _engCtl;

  @override
  void initState() {
    super.initState();
    _engCtl = ref.read(engineProvider.notifier);
    Future.microtask(() {
      if (mounted) ref.read(engineProvider.notifier).startDevicePolling();
    });
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
    _engCtl.stopDevicePolling();
    if (_loop && _engCtl.hasEngine) _engCtl.engine.loopback(false);
    super.dispose();
  }

  Future<void> _toggleLoop(bool v) async {
    final ctl = ref.read(engineProvider.notifier);
    if (!ctl.hasEngine) return;
    try {
      await ctl.engine.loopback(v);
      setState(() => _loop = v);
    } on EngineException catch (e) {
      ref.read(noticeProvider.notifier).error(ref.read(l10nProvider).settingsAudioEchoTestFailed, details: '$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(settingsProvider);
    final dev = ref.watch(audioDevicesProvider).value;
    final desktop = !isMobilePlatform;
    Map<String, String> opts(List<AudioDevice>? l) {
      return {
        'default': systemDefaultLabel(context.l10n, l),
        for (final d in l ?? <AudioDevice>[])
          if (d.devId != 'default') d.devId: d.name,
      };
    }

    return ListView(
      padding: const EdgeInsets.only(bottom: 32),
      children: [
        SettingsGroup(
          title: context.l10n.settingsAudioDevices,
          children: [
            SelectTile<String>(icon: Icons.mic_rounded, title: context.l10n.settingsAudioMicrophone, value: s.captureDev, options: opts(dev?.capture), onChanged: (v) => _s(ref).update({'captureDev': v})),
            SelectTile<String>(icon: Icons.speaker_rounded, title: context.l10n.settingsAudioSpeaker, value: s.playbackDev, options: opts(dev?.playback), onChanged: (v) => _s(ref).update({'playbackDev': v})),
            if (desktop) SelectTile<String>(icon: Icons.notifications_active_rounded, title: context.l10n.settingsAudioRinger, subtitle: context.l10n.settingsAudioRingerSub, value: s.ringerDev, options: opts(dev?.playback), onChanged: (v) => _s(ref).update({'ringerDev': v})),
            ListTile(
              leading: const Icon(Icons.refresh_rounded),
              title: Text(context.l10n.settingsAudioRefreshDevices),
              onTap: () async {
                final ctl = ref.read(engineProvider.notifier);
                if (ctl.hasEngine) await ctl.engine.refreshDevices();
                ref.invalidate(audioDevicesProvider);
              },
            ),
          ],
        ),
        SettingsGroup(
          title: context.l10n.settingsAudioLevelsAndTest,
          children: [
            SliderTile(icon: Icons.mic_none_rounded, title: context.l10n.settingsAudioMicVolume, value: s.micLevel, max: 2, divisions: 20, format: (v) => '${(v * 100).round()}%', onChanged: (v) => _s(ref).update({'micLevel': v})),
            _Vu(label: context.l10n.settingsAudioMicLevel, value: _levels.mic / 255),
            SliderTile(icon: Icons.volume_up_rounded, title: context.l10n.settingsAudioSpeakerVolume, value: s.speakerLevel, max: 2, divisions: 20, format: (v) => '${(v * 100).round()}%', onChanged: (v) => _s(ref).update({'speakerLevel': v})),
            _Vu(label: context.l10n.settingsAudioSpeakerLevel, value: _levels.speaker / 255),
            ListTile(
              key: const Key('test-speaker'),
              leading: const Icon(Icons.volume_up_rounded),
              title: Text(context.l10n.settingsAudioTestSpeaker),
              subtitle: Text(context.l10n.settingsAudioTestSpeakerSub),
              onTap: () async {
                final ctl = ref.read(engineProvider.notifier);
                if (!ctl.hasEngine) return;
                try {
                  await ctl.engine.playTone(ToneKind.dtmf, digits: '1357');
                } on EngineException catch (e) {
                  ref.read(noticeProvider.notifier).error(ref.read(l10nProvider).settingsAudioTestToneFailed, details: '$e');
                }
              },
            ),
            SwitchTile(icon: Icons.hearing_rounded, title: context.l10n.settingsAudioEchoTest, subtitle: context.l10n.settingsAudioEchoTestSub, value: _loop, onChanged: _toggleLoop),
          ],
        ),
        SettingsGroup(
          title: context.l10n.settingsAudioVoiceAndFiles,
          children: [
            NavTile(
              key: const Key('voice-isolation-entry'),
              icon: Icons.noise_control_off_rounded,
              title: context.l10n.settingsAudioVoiceIsolation,
              subtitle: s.viMicOn || s.viInOn
                  ? [if (s.viMicOn) context.l10n.settingsAudioVoiceIsolationMic(strengthLabel(context.l10n, s.viMicStrength)), if (s.viInOn) context.l10n.settingsAudioVoiceIsolationOthers(strengthLabel(context.l10n, s.viInStrength))].join('  ·  ')
                  : context.l10n.commonOff,
              onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const VoiceIsolationPage())),
            ),
            NavTile(
              key: const Key('audio-files-entry'),
              icon: Icons.library_music_rounded,
              title: context.l10n.settingsAudioAudioFiles,
              subtitle: context.l10n.settingsAudioAudioFilesSub,
              onTap: () => openAudioFiles(context),
            ),
          ],
        ),
        SettingsGroup(
          title: context.l10n.settingsAudioProcessing,
          children: [
            SelectTile<String>(
              title: context.l10n.settingsAudioEchoCancellation,
              value: s.ecAlgo,
              options: {for (final a in EcAlgo.values) a.wire: switch (a) { EcAlgo.auto => context.l10n.commonAutomatic, EcAlgo.aec3 => 'WebRTC AEC3', EcAlgo.webrtc => 'WebRTC', EcAlgo.speex => 'Speex', EcAlgo.simple => context.l10n.settingsAudioEcSimple, EcAlgo.platform => context.l10n.settingsAudioEcPlatform, EcAlgo.none => context.l10n.commonOff }},
              onChanged: (v) => _s(ref).update({'ecAlgo': v}),
            ),
            SelectTile<int>(title: context.l10n.settingsAudioEchoTail, value: s.ecTailMs, options: {for (final v in const [64, 128, 200, 256, 400]) v: context.l10n.settingsUnitMs(v)}, onChanged: (v) => _s(ref).update({'ecTailMs': v})),
            SwitchTile(title: context.l10n.settingsAudioNoiseSuppression, value: s.noiseSuppression, onChanged: (v) => _s(ref).update({'noiseSuppression': v})),
            SwitchTile(title: context.l10n.settingsAudioAgc, value: s.agc, onChanged: (v) => _s(ref).update({'agc': v})),
            SwitchTile(title: context.l10n.settingsAudioVad, subtitle: context.l10n.settingsAudioVadSub, value: s.vad, onChanged: (v) => _s(ref).update({'vad': v})),
          ],
        ),
        SettingsGroup(
          title: context.l10n.settingsAudioAdvanced,
          footer: context.l10n.settingsAudioAdvancedFooter,
          children: [
            SelectTile<int>(title: context.l10n.settingsAudioPtime, value: const {10, 20, 30, 40, 60}.contains(s.ptime) ? s.ptime : 20, options: {for (final v in const [10, 20, 30, 40, 60]) v: context.l10n.settingsUnitMs(v)}, onChanged: (v) => _s(ref).update({'ptime': v})),
            TextTile(key: const Key('jb-init'), title: context.l10n.settingsAudioJbInitial, value: '${s.jbInitMs}', keyboardType: TextInputType.number, onChanged: (v) => _s(ref).update({'jbInitMs': int.tryParse(v.trim()) ?? -1})),
            TextTile(key: const Key('jb-min'), title: context.l10n.settingsAudioJbMinPrefetch, value: '${s.jbMinPreMs}', keyboardType: TextInputType.number, onChanged: (v) => _s(ref).update({'jbMinPreMs': int.tryParse(v.trim()) ?? -1})),
            TextTile(key: const Key('jb-max-pre'), title: context.l10n.settingsAudioJbMaxPrefetch, value: '${s.jbMaxPreMs}', keyboardType: TextInputType.number, onChanged: (v) => _s(ref).update({'jbMaxPreMs': int.tryParse(v.trim()) ?? -1})),
            TextTile(key: const Key('jb-max'), title: context.l10n.settingsAudioJbMaxSize, value: '${s.jbMaxMs}', keyboardType: TextInputType.number, onChanged: (v) => _s(ref).update({'jbMaxMs': int.tryParse(v.trim()) ?? -1})),
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
      value: context.l10n.settingsAudioPercentValue((v * 100).round()),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(72, 0, 16, 12),
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
      return (await ctl.engine.codecs()).map((c) => c.id).toSet().toList();
    } catch (_) {}
  }
  return kFallbackCodecs;
});

/// Merges known ids with a saved order.
/// The engine lists some codecs more than once (e.g. G7221 bitrate variants
/// share an id); duplicates are dropped so list keys stay unique.
List<String> orderCodecs(List<String> known, List<String> saved) => {
  ...saved.where(known.contains),
  ...known.where((k) => !saved.contains(k)),
}.toList();

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
        SectionHeader(context.l10n.settingsCodecsOrder),
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
        Padding(padding: const EdgeInsets.fromLTRB(20, 8, 20, 0), child: Text(context.l10n.settingsCodecsDragHint)),
        SettingsGroup(
          title: 'Opus',
          children: [
            SelectTile<int>(title: context.l10n.settingsCodecsBitrate, value: s.opusBitrate, options: {for (final v in const [16, 24, 32, 48, 64]) v * 1000: context.l10n.settingsUnitKbps(v)}, onChanged: (v) => _s(ref).update({'opusBitrate': v})),
            SwitchTile(title: context.l10n.settingsCodecsFec, subtitle: context.l10n.settingsCodecsFecSub, value: s.opusFec, onChanged: (v) => _s(ref).update({'opusFec': v})),
            SwitchTile(title: 'DTX', subtitle: context.l10n.settingsCodecsDtxSub, value: s.opusDtx, onChanged: (v) => _s(ref).update({'opusDtx': v})),
            SwitchTile(title: context.l10n.settingsCodecsCbr, value: s.opusCbr, onChanged: (v) => _s(ref).update({'opusCbr': v})),
            SliderTile(title: context.l10n.settingsCodecsComplexity, value: s.opusComplexity.toDouble(), min: 0, max: 10, divisions: 10, format: (v) => v.round().toString(), onChanged: (v) => _s(ref).update({'opusComplexity': v.round()})),
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
          title: context.l10n.settingsCallsIncoming,
          children: [
            SwitchTile(icon: Icons.do_not_disturb_on_rounded, title: context.l10n.statusDoNotDisturb, subtitle: context.l10n.settingsCallsDndSub, value: s.dnd, onChanged: (v) => _s(ref).update({'dnd': v})),
            SelectTile<int>(title: context.l10n.settingsCallsRejectWith, value: s.dndRejectCode, options: {486: context.l10n.settingsCallsReasonBusy, 480: context.l10n.settingsCallsReasonUnavailable, 603: context.l10n.settingsCallsReasonDecline}, onChanged: (v) => _s(ref).update({'dndRejectCode': v})),
            SwitchTile(icon: Icons.phone_callback_rounded, title: context.l10n.settingsCallsWaiting, subtitle: context.l10n.settingsCallsWaitingSub, value: s.callWaiting, onChanged: (v) => _s(ref).update({'callWaiting': v})),
            SelectTile<int>(title: context.l10n.settingsCallsWhenBusy, value: s.busyRejectCode, options: {486: context.l10n.settingsCallsReasonBusy, 603: context.l10n.settingsCallsReasonDecline}, onChanged: (v) => _s(ref).update({'busyRejectCode': v})),
            SwitchTile(icon: Icons.person_off_rounded, title: context.l10n.settingsCallsRejectAnonymous, value: s.rejectAnonymous, onChanged: (v) => _s(ref).update({'rejectAnonymous': v})),
            SwitchTile(key: const Key('call-links-immediately'), icon: Icons.link_rounded, title: context.l10n.settingsCallsLinksImmediately, subtitle: context.l10n.settingsCallsLinksImmediatelySub, value: s.callLinksImmediately, onChanged: (v) => _s(ref).update({'callLinksImmediately': v})),
            SwitchTile(key: const Key('sync-feature-codes'), icon: Icons.sync_alt_rounded, title: context.l10n.settingsCallsSyncFeatureCodes, subtitle: context.l10n.settingsCallsSyncFeatureCodesSub, value: s.syncFeatureCodes, onChanged: (v) => _s(ref).update({'syncFeatureCodes': v})),
          ],
        ),
        if (ref.watch(defaultHandlerServiceProvider).supported)
          SettingsGroup(
            title: context.l10n.commonSystem,
            children: const [DefaultHandlerTile()],
          ),
        const HoldMusicGroup(),
        const AnnouncementsGroup(),
        SettingsGroup(
          title: context.l10n.settingsCallsAutoAnswerGroup,
          footer: context.l10n.settingsCallsAutoAnswerFooter,
          children: [
            SwitchTile(icon: Icons.auto_mode_rounded, title: context.l10n.settingsCallsAutoAnswerAll, value: s.autoAnswer, onChanged: (v) => _s(ref).update({'autoAnswer': v})),
            SelectTile<int>(title: context.l10n.settingsCallsAnswerAfter, value: s.autoAnswerDelay, options: {0: context.l10n.settingsCallsAnswerImmediately, 3: context.l10n.settingsUnitSeconds(3), 5: context.l10n.settingsUnitSeconds(5), 10: context.l10n.settingsUnitSeconds(10)}, onChanged: (v) => _s(ref).update({'autoAnswerDelay': v})),
            SwitchTile(title: context.l10n.settingsCallsIntercomHeaders, subtitle: context.l10n.settingsCallsIntercomHeadersSub, value: s.allowAutoAnswerHeaders, onChanged: (v) => _s(ref).update({'allowAutoAnswerHeaders': v})),
          ],
        ),
        SettingsGroup(
          title: context.l10n.settingsCallsBlocked,
          children: [
            for (final b in s.blocklist)
              ListTile(
                leading: const Icon(Icons.block_rounded),
                title: Text(b),
                trailing: IconButton(tooltip: context.l10n.settingsCallsUnblock(b), icon: const Icon(Icons.close_rounded), onPressed: () => _s(ref).update({'blocklist': s.blocklist.where((e) => e != b).toList()})),
              ),
            ListTile(
              leading: const Icon(Icons.add_rounded),
              title: Text(context.l10n.settingsCallsBlockNumber),
              onTap: () async {
                final n = await promptText(context, title: context.l10n.settingsCallsBlockNumberTitle, hint: context.l10n.settingsCallsBlockNumberHint, keyboardType: TextInputType.phone);
                if (n != null && n.isNotEmpty) _s(ref).update({'blocklist': [...s.blocklist, n]});
              },
            ),
          ],
        ),
        SettingsGroup(
          title: context.l10n.settingsCallsSpeedDial,
          children: [
            NavTile(key: const Key('speed-dial-entry'), icon: Icons.speed_rounded, title: context.l10n.settingsCallsSpeedDial, subtitle: context.l10n.settingsCallsSpeedDialAssigned(s.speedDial.length), onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const SpeedDialPage()))),
          ],
        ),
        SettingsGroup(
          title: context.l10n.settingsCallsDialPlan,
          children: [
            NavTile(icon: Icons.rule_rounded, title: context.l10n.settingsCallsDialRules, subtitle: context.l10n.settingsCallsDialRulesCount(s.dialRules.length), onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const DialRulesEditor()))),
            TextTile(key: const Key('strip-prefix'), icon: Icons.content_cut_rounded, title: context.l10n.settingsCallsStripPrefix, subtitle: context.l10n.settingsCallsStripPrefixSub, hint: context.l10n.commonNone, value: s.stripPrefix, onChanged: (v) => _s(ref).update({'stripPrefix': v.trim()})),
            TextTile(key: const Key('plus-replacement'), icon: Icons.add_rounded, title: context.l10n.settingsCallsPlusReplacement, subtitle: context.l10n.settingsCallsPlusReplacementSub, hint: context.l10n.settingsCallsPlusReplacementHint, value: s.plusReplacement, onChanged: (v) => _s(ref).update({'plusReplacement': v.trim()})),
            TextTile(key: const Key('default-country-prefix'), icon: Icons.flag_rounded, title: context.l10n.settingsCallsCountryPrefix, subtitle: context.l10n.settingsCallsCountryPrefixSub, hint: context.l10n.commonNone, value: s.defaultCountryPrefix, onChanged: (v) => _s(ref).update({'defaultCountryPrefix': v.trim()})),
            TextTile(icon: Icons.emergency_rounded, title: context.l10n.settingsCallsEmergency, subtitle: context.l10n.settingsCallsEmergencySub, value: s.emergencyNumbers.join(', '), onChanged: (v) => _s(ref).update({'emergencyNumbers': v.split(RegExp(r'[,\s]+')).where((e) => e.isNotEmpty).toList()})),
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
            title: Text(r == null ? context.l10n.settingsDialRulesNew : context.l10n.settingsDialRulesEdit),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: name, decoration: InputDecoration(labelText: context.l10n.settingsDialRulesName)),
                  const SizedBox(height: 10),
                  TextField(key: const Key('rule-pattern'), controller: pat, textDirection: TextDirection.ltr, onChanged: (_) => set(() {}), decoration: InputDecoration(labelText: context.l10n.settingsDialRulesPattern, helperText: r'e.g. 0(\d{9})', errorText: err)),
                  const SizedBox(height: 10),
                  TextField(key: const Key('rule-replacement'), controller: rep, textDirection: TextDirection.ltr, decoration: InputDecoration(labelText: context.l10n.settingsDialRulesReplacement, helperText: context.l10n.settingsDialRulesReplacementHelp)),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: acc,
                    decoration: InputDecoration(labelText: context.l10n.settingsDialRulesRoute),
                    items: [DropdownMenuItem(value: '', child: Text(context.l10n.commonDefault)), for (final a in accounts) DropdownMenuItem(value: a.id, child: Text(a.name))],
                    onChanged: (v) => acc = v ?? '',
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: Text(context.l10n.actionCancel)),
              FilledButton(
                onPressed: err != null || pat.text.isEmpty ? null : () => Navigator.pop(ctx, DialRule(id: r?.id ?? newId(), name: name.text, pattern: pat.text, replacement: rep.text, accountId: acc, enabled: r?.enabled ?? true)),
                child: Text(context.l10n.actionSave),
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
      body: SafeArea(
        child: Column(
          children: [
            // Same header as the other settings pages.
            PageHeader(
              title: context.l10n.settingsCallsDialRules,
              leading: IconButton(tooltip: context.l10n.actionBack, onPressed: () => Navigator.of(context).maybePop(), icon: const Icon(Icons.arrow_back_rounded)),
              actions: [IconButton(tooltip: context.l10n.settingsDialRulesAdd, onPressed: () => _edit(null), icon: const Icon(Icons.add_rounded))],
            ),
            Expanded(
              child: Center(
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
                      Text(context.l10n.settingsDialRulesLiveTest, style: Theme.of(context).textTheme.titleSmall),
                      const SizedBox(height: 8),
                      TextField(key: const Key('rule-test'), controller: _test, textDirection: TextDirection.ltr, onChanged: (_) => setState(() {}), decoration: InputDecoration(labelText: context.l10n.settingsDialRulesTyped)),
                      const SizedBox(height: 10),
                      Row(children: [
                        const Icon(Icons.arrow_forward_rounded, size: 18),
                        const SizedBox(width: 8),
                        Expanded(child: SelectableText(result.target.isEmpty ? context.l10n.settingsDialRulesNothing : result.target, key: const Key('rule-result'), textDirection: TextDirection.ltr, style: tabular(Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)))),
                      ]),
                      if (result.emergency) Text(context.l10n.settingsDialRulesEmergency),
                      if (result.accountId != null) Text(context.l10n.settingsDialRulesVia(accounts.byId(result.accountId!)?.name ?? context.l10n.settingsDialRulesAccountFallback)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              if (rules.isEmpty)
                Padding(padding: const EdgeInsets.all(24), child: Text(context.l10n.settingsDialRulesEmpty, textAlign: TextAlign.center))
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
                          subtitle: Text('${r.pattern}  →  ${r.replacement}', textDirection: TextDirection.ltr),
                          leading: Switch(value: r.enabled, onChanged: (v) => _save([for (final e in rules) e.id == r.id ? e.copyWith(enabled: v) : e])),
                          trailing: IconButton(
                            tooltip: context.l10n.settingsDialRulesDelete,
                            icon: const Icon(Icons.delete_outline_rounded),
                            onPressed: () async {
                              if (await confirm(context, title: context.l10n.settingsDialRulesDeleteTitle, message: r.name.isEmpty ? r.pattern : r.name)) _save(rules.where((e) => e.id != r.id).toList());
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
            ),
          ],
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
          title: context.l10n.settingsNetworkTransports,
          footer: context.l10n.settingsNetworkTransportsFooter,
          children: [
            SwitchTile(title: 'UDP', value: s.udpEnabled, onChanged: (v) => _s(ref).update({'udpEnabled': v})),
            TextTile(title: context.l10n.settingsNetworkUdpPort, value: '${s.udpPort}', keyboardType: TextInputType.number, onChanged: (v) => _s(ref).update({'udpPort': port(v)})),
            SwitchTile(title: 'TCP', value: s.tcpEnabled, onChanged: (v) => _s(ref).update({'tcpEnabled': v})),
            TextTile(title: context.l10n.settingsNetworkTcpPort, value: '${s.tcpPort}', keyboardType: TextInputType.number, onChanged: (v) => _s(ref).update({'tcpPort': port(v)})),
            SwitchTile(title: 'TLS', value: s.tlsEnabled, onChanged: (v) => _s(ref).update({'tlsEnabled': v})),
            TextTile(title: context.l10n.settingsNetworkTlsPort, value: '${s.tlsPort}', keyboardType: TextInputType.number, onChanged: (v) => _s(ref).update({'tlsPort': port(v)})),
            SwitchTile(icon: Icons.verified_rounded, title: context.l10n.settingsNetworkVerifyCerts, subtitle: context.l10n.settingsNetworkVerifyCertsSub, value: s.tlsVerify, onChanged: (v) => _s(ref).update({'tlsVerify': v})),
            TextTile(key: const Key('custom-ca-file'), icon: Icons.security_rounded, title: context.l10n.settingsNetworkCustomCa, subtitle: context.l10n.settingsNetworkCustomCaSub, hint: context.l10n.settingsNetworkCustomCaHint, value: s.customCaFile, onChanged: (v) => _s(ref).update({'customCaFile': v.trim()})),
            TextTile(icon: Icons.push_pin_rounded, title: context.l10n.settingsNetworkPins, subtitle: context.l10n.settingsNetworkPinsSub, value: s.tlsPins.join(', '), onChanged: (v) => _s(ref).update({'tlsPins': list(v)})),
          ],
        ),
        SettingsGroup(
          title: context.l10n.settingsNetworkNat,
          children: [
            TextTile(icon: Icons.public_rounded, title: context.l10n.settingsNetworkStun, subtitle: context.l10n.settingsNetworkStunSub, value: s.stunServers.join(', '), onChanged: (v) => _s(ref).update({'stunServers': list(v)})),
            ListTile(leading: const Icon(Icons.info_outline_rounded), title: Text(context.l10n.settingsNetworkIceTurn), subtitle: Text(context.l10n.settingsNetworkIceTurnSub)),
          ],
        ),
        SettingsGroup(
          title: context.l10n.settingsNetworkAdvanced,
          children: [
            SwitchTile(title: 'IPv6', value: s.ipv6, onChanged: (v) => _s(ref).update({'ipv6': v})),
            SwitchTile(title: context.l10n.settingsNetworkQos, subtitle: context.l10n.settingsNetworkQosSub, value: s.qos, onChanged: (v) => _s(ref).update({'qos': v})),
            TextTile(icon: Icons.dns_rounded, title: context.l10n.settingsNetworkDns, subtitle: context.l10n.settingsNetworkDnsSub, hint: context.l10n.commonAutomatic, value: s.dnsServers.join(', '), onChanged: (v) => _s(ref).update({'dnsServers': list(v)})),
            TextTile(title: context.l10n.settingsNetworkRtpStart, value: '${s.rtpPort}', keyboardType: TextInputType.number, onChanged: (v) => _s(ref).update({'rtpPort': port(v)})),
            TextTile(title: context.l10n.settingsNetworkRtpRange, subtitle: context.l10n.settingsNetworkRtpRangeSub, value: '${s.rtpPortRange}', keyboardType: TextInputType.number, onChanged: (v) => _s(ref).update({'rtpPortRange': port(v)})),
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
  Widget build(BuildContext context, WidgetRef ref) => const RecordingSettingsView();
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
          title: context.l10n.settingsNotifRingtone,
          children: [
            SelectTile<String>(icon: Icons.music_note_rounded, title: context.l10n.settingsNotifDefaultRingtone, value: s.ringtone, options: ringtoneOptions(context.l10n), onChanged: (v) => _s(ref).update({'ringtone': v})),
            SwitchTile(key: const Key('progress-tones'), icon: Icons.volume_up_rounded, title: context.l10n.settingsNotifProgressTones, subtitle: context.l10n.settingsNotifProgressTonesSub, value: s.progressTones, onChanged: (v) => _s(ref).update({'progressTones': v})),
            SliderTile(icon: Icons.volume_up_rounded, title: context.l10n.settingsNotifRingerVolume, value: s.ringerVolume, divisions: 10, format: (v) => '${(v * 100).round()}%', onChanged: (v) => _s(ref).update({'ringerVolume': v})),
            TextTile(icon: Icons.audio_file_rounded, title: context.l10n.settingsNotifCustomRingtone, subtitle: context.l10n.settingsNotifCustomRingtoneSub, value: s.ringtone.contains('/') ? s.ringtone : '', hint: context.l10n.commonNone, onChanged: (v) => _s(ref).update({'ringtone': v.isEmpty ? 'default' : v})),
          ],
        ),
        SettingsGroup(
          title: context.l10n.settingsNotifGroup,
          children: [
            ListTile(
              leading: const Icon(Icons.notifications_rounded),
              title: Text(context.l10n.settingsNotifRequestPermissions),
              subtitle: Text(context.l10n.settingsNotifRequestPermissionsSub),
              onTap: () async {
                final r = await ref.read(platformServicesProvider).requestPermissions();
                ref.read(noticeProvider.notifier).show(ref.read(l10nProvider).settingsNotifPermissionResult(r.microphone.name, r.notifications.name));
              },
            ),
            SwitchTile(icon: Icons.keyboard_rounded, title: context.l10n.settingsNotifTyping, value: s.sendTyping, onChanged: (v) => _s(ref).update({'sendTyping': v})),
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
          title: context.l10n.settingsAppearanceTheme,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: SegmentedButton<ThemeMode>(
                segments: [
                  ButtonSegment(value: ThemeMode.system, label: Text(context.l10n.commonSystem), icon: const Icon(Icons.brightness_auto_rounded)),
                  ButtonSegment(value: ThemeMode.light, label: Text(context.l10n.settingsAppearanceLight), icon: const Icon(Icons.light_mode_rounded)),
                  ButtonSegment(value: ThemeMode.dark, label: Text(context.l10n.settingsAppearanceDark), icon: const Icon(Icons.dark_mode_rounded)),
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
                  Text(context.l10n.settingsAppearanceAccent, style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      for (final c in kAvatarPalette)
                        Semantics(
                          button: true,
                          selected: s.accent == c,
                          label: context.l10n.settingsAppearanceAccentOption,
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
            SwitchTile(icon: Icons.density_small_rounded, title: context.l10n.settingsAppearanceCompact, value: s.compactDensity, onChanged: (v) => _s(ref).update({'compactDensity': v})),
          ],
        ),
        SettingsGroup(
          title: context.l10n.settingsLanguage,
          footer: context.l10n.languagePickerHint,
          children: [LanguageTile(current: s.language, onChanged: (v) => _s(ref).update({'language': v}))],
        ),
      ],
    );
  }
}

/// Language row: shows the current language's native name; opens a picker
/// listing every supported language by its own name.
class LanguageTile extends StatelessWidget {
  const LanguageTile({super.key, required this.current, required this.onChanged});
  final String current;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    String nameOf(String code) {
      for (final x in kAppLanguages) {
        if (x.code == code) return x.nativeName;
      }
      return l.languageSystemDefault;
    }

    return ListTile(
      key: const Key('language-tile'),
      leading: const Icon(Icons.language_rounded),
      title: Text(l.settingsLanguage),
      subtitle: Text(nameOf(current)),
      trailing: const Icon(Icons.arrow_drop_down_rounded),
      onTap: () async {
        final picked = await showDialog<String>(
          context: context,
          builder: (dctx) => SimpleDialog(
            title: Text(l.settingsLanguage),
            children: [
              SizedBox(
                width: 320,
                height: 420,
                child: ListView(
                  children: [
                    for (final code in [kSystemLanguage, ...kAppLanguages.map((e) => e.code)])
                      ListTile(
                        key: Key('language-$code'),
                        title: Text(nameOf(code)),
                        trailing: code == current ? const Icon(Icons.check_rounded) : null,
                        onTap: () => Navigator.pop(dctx, code),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
        if (picked != null) onChanged(picked);
      },
    );
  }
}

class PrivacySection extends ConsumerWidget {
  const PrivacySection({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Future<void> wipe(String confirmTitle, String done, Future<void> Function() f) async {
      if (await confirm(context, title: confirmTitle, message: context.l10n.settingsPrivacyCannotUndo, confirmLabel: context.l10n.actionDelete)) {
        await f();
        ref.read(noticeProvider.notifier).show(done);
      }
    }

    return ListView(
      padding: const EdgeInsets.only(bottom: 32),
      children: [
        SettingsGroup(
          title: context.l10n.settingsPrivacySecurity,
          children: [
            ListTile(leading: const Icon(Icons.shield_rounded), title: Text(context.l10n.settingsPrivacyPasswords), subtitle: Text(context.l10n.settingsPrivacyPasswordsSub)),
          ],
        ),
        const AppLockSettingsGroup(),
        const EncryptionSettingsGroup(),
        SettingsGroup(
          title: context.l10n.settingsPrivacyGroup,
          children: [ListTile(leading: const Icon(Icons.visibility_off_rounded), title: Text(context.l10n.settingsPrivacyNoTelemetry), subtitle: Text(context.l10n.settingsPrivacyNoTelemetrySub))],
        ),
        SettingsGroup(
          title: context.l10n.settingsPrivacyYourData,
          children: [
            ListTile(leading: const Icon(Icons.history_rounded), title: Text(context.l10n.settingsPrivacyClearHistory), onTap: () => wipe(context.l10n.settingsPrivacyConfirmHistory, context.l10n.settingsPrivacyDeletedHistory, () => ref.read(historyProvider.notifier).clear())),
            ListTile(leading: const Icon(Icons.people_rounded), title: Text(context.l10n.settingsPrivacyDeleteContacts), onTap: () => wipe(context.l10n.settingsPrivacyConfirmContacts, context.l10n.settingsPrivacyDeletedContacts, () => ref.read(contactsProvider.notifier).clear())),
            ListTile(
              leading: const Icon(Icons.chat_rounded),
              title: Text(context.l10n.settingsPrivacyDeleteMessages),
              onTap: () => wipe(context.l10n.settingsPrivacyConfirmMessages, context.l10n.settingsPrivacyDeletedMessages, () async {
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
          title: context.l10n.settingsLanGroup,
          footer: context.l10n.settingsLanFooter,
          children: [
            SwitchTile(icon: Icons.lan_rounded, title: context.l10n.settingsLanEnable, value: s.lanEnabled, onChanged: (v) => _s(ref).update({'lanEnabled': v})),
            TextTile(icon: Icons.badge_rounded, title: context.l10n.settingsLanDeviceName, hint: context.l10n.settingsLanDeviceNameHint, value: s.lanDeviceName, onChanged: (v) => _s(ref).update({'lanDeviceName': v})),
            SwitchTile(icon: Icons.volume_up_rounded, title: context.l10n.settingsLanAllowIntercom, subtitle: context.l10n.settingsLanAllowIntercomSub, value: s.lanAllowIntercom, onChanged: (v) => _s(ref).update({'lanAllowIntercom': v})),
            if (s.lanAllowIntercom) SwitchTile(icon: Icons.help_outline_rounded, title: context.l10n.settingsLanAskIntercom, subtitle: context.l10n.settingsLanAskIntercomSub, value: s.lanIntercomPrompt, onChanged: (v) => _s(ref).update({'lanIntercomPrompt': v})),
            SwitchTile(icon: Icons.download_for_offline_rounded, title: context.l10n.settingsLanAutoAcceptFiles, subtitle: context.l10n.settingsLanAutoAcceptFilesSub, value: s.lanAutoAcceptFiles, onChanged: (v) => _s(ref).update({'lanAutoAcceptFiles': v})),
            SwitchTile(icon: Icons.call_received_rounded, title: context.l10n.settingsLanAllowPull, subtitle: context.l10n.settingsLanAllowPullSub, value: s.lanAllowPull, onChanged: (v) => _s(ref).update({'lanAllowPull': v})),
            TextTile(icon: Icons.folder_rounded, title: context.l10n.settingsLanDownloads, hint: context.l10n.settingsLanDownloadsHint, value: s.lanDownloadsDir, onChanged: (v) => _s(ref).update({'lanDownloadsDir': v})),
            TextTile(icon: Icons.settings_ethernet_rounded, title: context.l10n.settingsLanPort, hint: context.l10n.commonAutomatic, value: s.lanLinkPort == 0 ? '' : '${s.lanLinkPort}', keyboardType: TextInputType.number, onChanged: (v) => _s(ref).update({'lanLinkPort': int.tryParse(v.trim()) ?? 0})),
          ],
        ),
        if (acc.profiles.isNotEmpty)
          SettingsGroup(
            title: context.l10n.settingsLanSharedAccounts,
            footer: context.l10n.settingsLanSharedAccountsFooter,
            children: [
              for (final p in acc.profiles)
                CheckboxListTile(
                  title: Text(p.name),
                  subtitle: Text(ltr(p.address)),
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
          title: context.l10n.settingsAdvEngine,
          children: [
            SwitchTile(icon: Icons.science_rounded, title: context.l10n.settingsAdvSimulator, subtitle: context.l10n.settingsAdvSimulatorSub, value: s.useSimulator, onChanged: (v) => _s(ref).update({'useSimulator': v})),
            SelectTile<int>(title: context.l10n.settingsAdvLogLevel, value: s.logLevel, options: {1: context.l10n.settingsAdvLogErrors, 3: context.l10n.settingsAdvLogInfo, 4: context.l10n.settingsAdvLogDebug, 5: context.l10n.settingsAdvLogVerbose}, onChanged: (v) => _s(ref).update({'logLevel': v})),
            SwitchTile(title: context.l10n.settingsAdvSipTrace, value: s.sipTrace, onChanged: (v) => _s(ref).update({'sipTrace': v})),
            ListTile(
              leading: const Icon(Icons.restart_alt_rounded),
              title: Text(context.l10n.settingsAdvRestartEngine),
              subtitle: Text('${e.phase.name}${e.version.isNotEmpty ? ', ${e.version}' : ''}'),
              onTap: () => ref.read(engineProvider.notifier).restart(),
            ),
          ],
        ),
        if (desktop)
          SettingsGroup(
            title: context.l10n.settingsAdvDesktop,
            children: [
              SwitchTile(icon: Icons.login_rounded, title: context.l10n.settingsAdvStartAtLogin, value: s.startAtLogin, onChanged: (v) {
                _s(ref).update({'startAtLogin': v});
                ref.read(platformServicesProvider).setStartAtLogin(v);
              }),
              SwitchTile(icon: Icons.minimize_rounded, title: context.l10n.settingsAdvCloseToTray, subtitle: context.l10n.settingsAdvCloseToTraySub, value: s.minimizeToTray, onChanged: (v) => _s(ref).update({'minimizeToTray': v})),
            ],
          ),
        if (desktop) const AutomationSettingsGroup(),
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
              Text(context.l10n.settingsAboutVersion(kAppVersion), style: t.textTheme.bodyMedium?.copyWith(color: t.colorScheme.onSurfaceVariant)),
            ],
          ),
        ),
        const UpdatesSettingsGroup(),
        SettingsGroup(
          title: context.l10n.settingsAboutLicence,
          footer: context.l10n.settingsAboutLicenceFooter,
          children: [
            NavTile(icon: Icons.gavel_rounded, title: context.l10n.settingsAboutGpl, subtitle: context.l10n.settingsAboutGplSub, onTap: () => showLicensePage(context: context, applicationName: 'SoftphonePro', applicationVersion: kAppVersion)),
          ],
        ),
        SettingsGroup(
          title: context.l10n.settingsAboutThirdParty,
          children: [
            for (final n in kNativeNotices)
              ListTile(title: Text(n.name), subtitle: Text(n.version.isEmpty ? context.l10n.settingsAboutNotice(n.license, n.purpose) : context.l10n.settingsAboutNoticeVersion(n.license, n.purpose, n.version))),
            ListTile(title: Text(context.l10n.settingsAboutPackages), subtitle: Text(context.l10n.settingsAboutPackagesSub)),
          ],
        ),
      ],
    );
  }
}

