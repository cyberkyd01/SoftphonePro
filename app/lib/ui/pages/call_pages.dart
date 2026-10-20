import '../../core/bidi.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/format.dart';
import '../../core/theme.dart';
import '../../l10n/l10n.dart';
import '../../platform/platform_services.dart';
import '../../services/accounts_controller.dart';
import '../../services/calls_controller.dart';
import '../../services/contacts_controller.dart';
import '../../services/messages_controller.dart';
import '../../services/providers.dart';
import '../helpers.dart';
import 'lan/lan_call_widgets.dart';
import 'audio/audio_call_widgets.dart';
import '../widgets/basic_widgets.dart';
import '../widgets/audio_mixer.dart';
import '../widgets/call_widgets.dart';
import '../widgets/caller_identity_block.dart';
import '../widgets/transfer_stalled_banner.dart';
import '../widgets/dial_pad.dart';

/// Full-screen in-call page (compact layouts).
class InCallPage extends ConsumerStatefulWidget {
  const InCallPage({super.key});
  @override
  ConsumerState<InCallPage> createState() => _InCallPageState();
}

class _InCallPageState extends ConsumerState<InCallPage> {
  bool _keypad = false;

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(callsProvider);
    final calls = ref.read(callsProvider.notifier);
    final contacts = ref.watch(contactsProvider);
    final acc = ref.watch(accountsProvider);
    final c = s.focused;
    final t = Theme.of(context);
    final colors = context.colors;
    final l = context.l10n;

    if (c == null) {
      return Scaffold(
        body: Center(
          child: TextButton(
            onPressed: () => context.go('/keypad'),
            child: Text(context.l10n.actionBack),
          ),
        ),
      );
    }
    final title = callTitle(c, contacts, context.l10n);
    final profile = acc.byId(c.accountId);
    final others = s.ongoing.where((o) => o.cid != c.cid).toList();
    final waiting = s.ringing;
    final mergeable = s.ongoing.where((o) => o.isConfirmed).length >= 2;
    final route = ref.watch(audioRouteProvider).value ?? AudioRoute.earpiece;
    final speakerOn = route == AudioRoute.speaker;
    final consult = c.consultOf != null;

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, box) {
            final small = box.maxHeight < 640;
            final landscape =
                box.maxWidth > box.maxHeight && box.maxHeight < 560;
            Widget endButton(double bottom) => Padding(
              padding: EdgeInsetsDirectional.only(bottom: bottom, top: 4),
              child: RoundCallButton(
                key: const Key('end-call'),
                icon: Icons.call_end_rounded,
                color: colors.endRed,
                label: l.callEndCall,
                size: landscape ? 56 : 72,
                onPressed: () => calls.hangup(c.cid),
              ),
            );
            List<Widget> infoWidgets() => [
              SizedBox(height: small ? 0 : 8),
              Text(
                bidiSafe(title == c.number ? formatPhone(title) : title),
                maxLines: 2,
                textAlign: TextAlign.center,
                textDirection: title == c.number ? TextDirection.ltr : null,
                overflow: TextOverflow.ellipsis,
                style: t.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              CallerIdentityBlock(call: c, title: title),
              const SizedBox(height: 6),
              if (c.isConfirmed && !c.isHeld)
                CallTimer(
                  call: c,
                  style: t.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                )
              else
                Text(
                  callStateText(c, l),
                  style: t.textTheme.titleMedium?.copyWith(
                    color: c.isHeld
                        ? colors.holdAmber
                        : t.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              if (c.isConfirmed && c.isHeld)
                CallTimer(call: c, style: t.textTheme.bodyMedium),
              const SizedBox(height: 6),
              if (c.isConfirmed)
                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  children: [
                    QualityIndicator(
                      mos: c.stats?.mos ?? 0,
                      onTap: () => showStatsSheet(context, c.cid),
                    ),
                    SecureBadge(srtp: c.info.srtp, tls: c.info.secureSignaling),
                    const NoiseCancellationChip(),
                    MusicbedChip(held: c.isHeld),
                    if (c.recording)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.fiber_manual_record_rounded,
                            size: 14,
                            color: colors.endRed,
                          ),
                          Text(
                            ' ${l.callRecBadge}',
                            style: t.textTheme.labelSmall?.copyWith(
                              color: colors.endRed,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              LanCallLabel(call: c),
              RelayedBanner(call: c),
              AnnouncementChip(cid: c.cid, center: true),
              if (consult) _ConsultBanner(call: c),
              TransferStalledBanner(call: c),
              if (others.isNotEmpty) ...[
                const SizedBox(height: 12),
                for (final o in others)
                  Padding(
                    padding: const EdgeInsetsDirectional.only(bottom: 8),
                    child: _StackedCall(
                      call: o,
                      title: callTitle(o, contacts, context.l10n),
                    ),
                  ),
              ],
            ];
            List<Widget> controlWidgets({required bool landscape}) => [
              if (_keypad && c.isConfirmed) ...[
                const SizedBox(height: 8),
                InCallKeypad(cid: c.cid, compact: true),
              ] else if (others.isEmpty && !landscape) ...[
                SizedBox(height: small ? 12 : 24),
                Avatar(name: title, size: small ? 84 : 120),
              ],
              const SizedBox(height: 16),
              if (_keypad && c.isConfirmed)
                // The keypad takes the place of the action grid so its
                // bottom row is never pushed behind the End button.
                TextButton.icon(
                  key: const Key('keypad-hide'),
                  onPressed: () => setState(() => _keypad = false),
                  icon: const Icon(Icons.keyboard_hide_rounded),
                  label: Text(l.callHideKeypad),
                )
              else
                _ActionGrid(
                  children: [
                    CallActionButton(
                      icon: c.muted ? Icons.mic_off_rounded : Icons.mic_rounded,
                      label: l.callMute,
                      active: c.muted,
                      onPressed: c.isConfirmed
                          ? () => calls.toggleMute(c.cid)
                          : null,
                    ),
                    CallActionButton(
                      icon: Icons.dialpad_rounded,
                      label: l.callKeypad,
                      active: _keypad,
                      onPressed: c.isConfirmed
                          ? () => setState(() => _keypad = !_keypad)
                          : null,
                    ),
                    CallActionButton(
                      icon: audioRouteIcon(
                        speakerOn ? AudioRoute.speaker : route,
                      ),
                      label: speakerOn
                          ? l.callSpeaker
                          : (route == AudioRoute.earpiece
                                ? l.callSpeaker
                                : _routeName(l, route)),
                      active:
                          speakerOn ||
                          route == AudioRoute.bluetooth ||
                          route == AudioRoute.wired,
                      onPressed: () => _onSpeaker(context, ref, route),
                    ),
                    CallActionButton(
                      icon: Icons.pause_rounded,
                      label: c.isHeld ? l.callResume : l.callHold,
                      active: c.isHeld,
                      activeColor: colors.holdAmber,
                      onPressed: c.isConfirmed
                          ? () => calls.toggleHold(c.cid)
                          : null,
                    ),
                    CallActionButton(
                      icon: Icons.person_add_alt_1_rounded,
                      label: l.callAddCall,
                      onPressed: () => context.canPop()
                          ? context.pop()
                          : context.go('/keypad'),
                    ),
                    CallActionButton(
                      icon: Icons.phone_forwarded_rounded,
                      label: l.callTransfer,
                      onPressed: c.isConfirmed
                          ? () => showTransferSheet(context, c.cid)
                          : null,
                    ),
                    CallActionButton(
                      icon: Icons.fiber_manual_record_rounded,
                      label: c.recording ? l.callStop : l.callRecord,
                      active: c.recording,
                      activeColor: colors.endRed,
                      onPressed: c.isConfirmed
                          ? () => calls.toggleRecording(c.cid)
                          : null,
                    ),
                    CallActionButton(
                      icon: c.isConference
                          ? Icons.call_split_rounded
                          : Icons.call_merge_rounded,
                      label: c.isConference ? l.callSplit : l.callMerge,
                      active: c.isConference,
                      onPressed: c.isConference
                          ? () => calls.split()
                          : (mergeable ? () => calls.merge() : null),
                    ),
                    CallActionButton(
                      icon: Icons.more_horiz_rounded,
                      label: l.actionMore,
                      onPressed: () => showMoreSheet(context, c.cid),
                    ),
                  ],
                ),
              if (c.isConference) const ConferenceLevels(),
              const SizedBox(height: 16),
            ];
            // Meters and sliders sit right under the caller header, above the
            // actions, so they are on screen without scrolling; End stays
            // pinned below the scrolling column.
            const strip = Padding(
              padding: EdgeInsets.only(top: 12),
              child: MixerStrip(),
            );
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 4, 4, 0),
                  child: Row(
                    children: [
                      IconButton(
                        tooltip: l.callBackToApp,
                        onPressed: () => context.canPop()
                            ? context.pop()
                            : context.go('/keypad'),
                        icon: const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 30,
                        ),
                      ),
                      const Spacer(),
                      if (profile != null)
                        Padding(
                          padding: const EdgeInsetsDirectional.only(end: 12),
                          child: AccountChip(
                            name: profile.name,
                            status: acc.statusOf(profile.id),
                          ),
                        ),
                    ],
                  ),
                ),
                for (final w in waiting)
                  _WaitingBanner(
                    call: w,
                    title: callTitle(w, contacts, context.l10n),
                  ),
                Expanded(
                  child: landscape
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                children: [
                                  Expanded(
                                    child: SingleChildScrollView(
                                      key: const Key('call-info-scroll'),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                      ),
                                      child: Center(
                                        child: Column(children: infoWidgets()),
                                      ),
                                    ),
                                  ),
                                  endButton(4),
                                ],
                              ),
                            ),
                            Expanded(
                              child: SingleChildScrollView(
                                key: const Key('call-controls-scroll'),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: Center(
                                  child: Column(
                                    children: [
                                      const Padding(
                                        padding: EdgeInsets.only(top: 8),
                                        child: MixerStrip(),
                                      ),
                                      ...controlWidgets(landscape: true),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      : SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Center(
                            child: Column(
                              children: [
                                ...infoWidgets(),
                                strip,
                                ...controlWidgets(landscape: false),
                              ],
                            ),
                          ),
                        ),
                ),
                if (!landscape) endButton(20),
              ],
            );
          },
        ),
      ),
    );
  }

  String _routeName(AppLocalizations l, AudioRoute r) => switch (r) {
    AudioRoute.bluetooth => l.callRouteBluetooth,
    AudioRoute.wired => l.callRouteHeadset,
    _ => l.callSpeaker,
  };

  Future<void> _onSpeaker(
    BuildContext context,
    WidgetRef ref,
    AudioRoute cur,
  ) async {
    final p = ref.read(platformServicesProvider);
    final routes = await p.availableAudioRoutes();
    if (!context.mounted) return;
    if (routes.length > 2 ||
        cur == AudioRoute.bluetooth ||
        cur == AudioRoute.wired) {
      await showAudioSheet(context);
    } else {
      await p.setAudioRoute(
        cur == AudioRoute.speaker ? AudioRoute.earpiece : AudioRoute.speaker,
      );
    }
  }
}

class _ActionGrid extends StatelessWidget {
  const _ActionGrid({required this.children});
  final List<Widget> children;
  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.textScalerOf(context).scale(1);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 340),
      child: GridView(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        // Larger text needs taller cells than the fixed aspect ratio gives.
        gridDelegate: scale > 1.05
            ? SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, mainAxisSpacing: 14, crossAxisSpacing: 8, mainAxisExtent: 98 + 22 * (scale - 1))
            : const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, mainAxisSpacing: 14, crossAxisSpacing: 8, childAspectRatio: 1.08),
        children: children,
      ),
    );
  }
}

class _StackedCall extends ConsumerWidget {
  const _StackedCall({required this.call, required this.title});
  final UiCall call;
  final String title;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final calls = ref.read(callsProvider.notifier);
    final t = Theme.of(context);
    final colors = context.colors;
    final l = context.l10n;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(kRadius),
        border: Border.all(color: t.colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          Avatar(name: title, size: 40),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bidiSafe(title),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: t.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  callStateText(call, l),
                  style: t.textTheme.bodySmall?.copyWith(
                    color: call.isHeld
                        ? colors.holdAmber
                        : t.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          if (call.isConfirmed) ...[
            TextButton(onPressed: () => calls.swap(), child: Text(l.callSwap)),
            TextButton(
              onPressed: () => calls.merge(),
              child: Text(l.callMerge),
            ),
          ],
          IconButton(
            tooltip: l.callEndCallWith(title),
            onPressed: () => calls.hangup(call.cid),
            icon: Icon(Icons.call_end_rounded, color: colors.endRed),
          ),
        ],
      ),
    );
  }
}

class _ConsultBanner extends ConsumerWidget {
  const _ConsultBanner({required this.call});
  final UiCall call;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final calls = ref.read(callsProvider.notifier);
    final t = Theme.of(context);
    final l = context.l10n;
    return Container(
      margin: const EdgeInsetsDirectional.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: t.colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(kRadius),
      ),
      child: Column(
        children: [
          Text(
            l.callAttendedTransferHint,
            style: t.textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  key: const Key('complete-transfer'),
                  onPressed: call.isConfirmed
                      ? () => calls.completeAttended(call.cid)
                      : null,
                  child: Text(l.callCompleteTransfer),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                key: const Key('cancel-transfer'),
                onPressed: () => calls.cancelConsult(call.cid),
                child: Text(l.actionCancel),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WaitingBanner extends ConsumerWidget {
  const _WaitingBanner({required this.call, required this.title});
  final UiCall call;
  final String title;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final calls = ref.read(callsProvider.notifier);
    final colors = context.colors;
    final l = context.l10n;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      padding: const EdgeInsetsDirectional.fromSTEB(14, 10, 8, 10),
      decoration: BoxDecoration(
        color: colors.raised,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.callWaiting,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  bidiSafe(title),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          IconButton.filled(
            key: Key('waiting-answer-${call.cid}'),
            tooltip: l.callHoldAndAnswer,
            style: IconButton.styleFrom(backgroundColor: colors.callGreen),
            onPressed: () => calls.answer(call.cid),
            icon: const Icon(Icons.call_rounded),
          ),
          const SizedBox(width: 4),
          IconButton.filled(
            tooltip: l.callDecline,
            style: IconButton.styleFrom(backgroundColor: colors.endRed),
            onPressed: () => calls.decline(call.cid),
            icon: const Icon(Icons.call_end_rounded),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------

/// Full-screen incoming call page (compact layouts).
class IncomingCallPage extends ConsumerWidget {
  const IncomingCallPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(callsProvider);
    final calls = ref.read(callsProvider.notifier);
    final contacts = ref.watch(contactsProvider);
    final acc = ref.watch(accountsProvider);
    final lan = ref.watch(lanHandoffProvider);
    final c = s.ringing.isEmpty ? null : s.ringing.first;
    final t = Theme.of(context);
    final colors = context.colors;
    final l = context.l10n;
    if (c == null) {
      return Scaffold(
        body: Center(
          child: TextButton(
            onPressed: () => context.go('/keypad'),
            child: Text(l.actionBack),
          ),
        ),
      );
    }
    final title = callTitle(c, contacts, context.l10n);
    final profile = acc.byId(c.accountId);
    final hasVoicemail = (profile?.effectiveVoicemail ?? '').isNotEmpty;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              children: [
                const SizedBox(height: 24),
                Text(
                  l.callIncomingCall,
                  style: t.textTheme.titleMedium?.copyWith(
                    color: t.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (profile != null)
                  Padding(
                    padding: const EdgeInsetsDirectional.only(top: 8),
                    child: AccountChip(
                      name: profile.name,
                      status: acc.statusOf(profile.id),
                    ),
                  ),
                const Spacer(),
                PulseRing(size: 120, child: Avatar(name: title, size: 120)),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    bidiSafe(title == c.number ? formatPhone(title) : title),
                    textAlign: TextAlign.center,
                    textDirection: title == c.number ? TextDirection.ltr : null,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: t.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                CallerIdentityBlock(
                  call: c,
                  title: title,
                  numberStyle: tabular(
                    t.textTheme.titleMedium?.copyWith(
                      color: t.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: LanCallLabel(call: c),
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    CallActionButton(
                      icon: Icons.message_rounded,
                      label: l.callReply,
                      size: 54,
                      onPressed: () => _reply(context, ref, c),
                    ),
                    CallActionButton(
                      icon: Icons.voicemail_rounded,
                      label: l.callVoicemail,
                      size: 54,
                      onPressed: hasVoicemail
                          ? () => calls.redirectToVoicemail(c.cid)
                          : null,
                    ),
                    CallActionButton(
                      icon: Icons.devices_rounded,
                      label: l.callToDevice,
                      size: 54,
                      onPressed:
                          lan.available && lan.devices.any((d) => d.online)
                          ? () => forwardRingingToLan(context, ref, c.cid)
                          : null,
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    RoundCallButton(
                      key: const Key('decline-call'),
                      icon: Icons.call_end_rounded,
                      color: colors.endRed,
                      label: l.callDecline,
                      showLabel: true,
                      size: 76,
                      onPressed: () => calls.decline(c.cid),
                    ),
                    RoundCallButton(
                      key: const Key('answer-call'),
                      icon: Icons.call_rounded,
                      color: colors.callGreen,
                      label: l.callAnswer,
                      showLabel: true,
                      size: 76,
                      onPressed: () => calls.answer(c.cid),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _reply(BuildContext context, WidgetRef ref, UiCall c) async {
    final calls = ref.read(callsProvider.notifier);
    final msgs = ref.read(messagesProvider.notifier);
    final l = ref.read(l10nProvider);
    final quick = [
      l.callQuickReplyBusy,
      l.callQuickReplyMeeting,
      l.callQuickReplyOnMyWay,
    ];
    final text = await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final q in quick)
              ListTile(title: Text(q), onTap: () => Navigator.pop(ctx, q)),
          ],
        ),
      ),
    );
    if (text == null) return;
    final to = c.info.remoteUri;
    final acc = c.accountId;
    await calls.decline(c.cid, code: 486);
    if (acc.isNotEmpty) await msgs.send(acc, to, text);
  }
}

/// Green call bar shown on compact layouts while a call is active.
class CallBar extends ConsumerWidget {
  const CallBar({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(callsProvider);
    final c = s.focused;
    final ringing = s.ringing.where((r) => !r.waiting).toList();
    if (c == null && ringing.isEmpty) return const SizedBox.shrink();
    final contacts = ref.watch(contactsProvider);
    final colors = context.colors;
    final shown = c ?? ringing.first;
    final title = callTitle(shown, contacts, context.l10n);
    return Semantics(
      button: true,
      label: context.l10n.callReturnToCallWith(title),
      child: Material(
        color: colors.callGreen,
        child: InkWell(
          onTap: () => context.push(c == null ? '/incoming' : '/call'),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                const Icon(Icons.call_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    c == null
                        ? context.l10n.callBarIncoming(title)
                        : context.l10n.callBarInCallWith(title),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (c != null && c.isConfirmed)
                  CallTimer(
                    call: c,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                const SizedBox(width: 6),
                const Icon(Icons.chevron_right_rounded, color: Colors.white),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
