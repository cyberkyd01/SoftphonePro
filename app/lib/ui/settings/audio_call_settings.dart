import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/l10n.dart';
import '../../services/settings_controller.dart';
import '../pages/audio/audio_files_page.dart';
import '../pages/audio/audio_ref_tile.dart';
import '../widgets/settings_tiles.dart';

void _set(WidgetRef ref, Map<String, dynamic> m) => ref.read(settingsProvider.notifier).update(m);

void openAudioFiles(BuildContext context) =>
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const AudioFilesPage()));

/// Settings > Calls > Hold music.
class HoldMusicGroup extends ConsumerWidget {
  const HoldMusicGroup({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(settingsProvider);
    final custom = s.holdMusic != 'pbx';
    final l = context.l10n;
    return SettingsGroup(
      title: l.callSettingsHoldGroupTitle,
      footer: l.callSettingsHoldFooter,
      children: [
        AudioRefTile(
          key: const Key('hold-music'),
          icon: Icons.music_note_rounded,
          title: l.callSettingsHoldMusic,
          value: s.holdMusic,
          holdMusicOnly: true,
          leading: {'pbx': l.callSettingsHoldPbxDefault},
          onChanged: (v) => _set(ref, {'holdMusic': v}),
        ),
        SliderTile(
          key: const Key('hold-music-volume'),
          icon: Icons.volume_up_rounded,
          title: l.callSettingsHoldMusicVolume,
          value: s.holdMusicVolume,
          divisions: 10,
          format: (v) => '${(v * 100).round()}%',
          onChanged: custom ? (v) => _set(ref, {'holdMusicVolume': v}) : (_) {},
        ),
        NavTile(
          key: const Key('hold-music-library'),
          icon: Icons.library_music_rounded,
          title: l.callSettingsHoldAudioFiles,
          subtitle: l.callSettingsHoldAudioFilesHint,
          onTap: () => openAudioFiles(context),
        ),
      ],
    );
  }
}

/// Settings > Calls > Announcements.
class AnnouncementsGroup extends ConsumerWidget {
  const AnnouncementsGroup({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(settingsProvider);
    final l = context.l10n;
    final none = {'': l.commonNone};
    return SettingsGroup(
      title: l.callSettingsAnnounceTitle,
      footer: l.callSettingsAnnounceFooter,
      children: [
        SwitchTile(
          key: const Key('announce-opening'),
          icon: Icons.campaign_rounded,
          title: l.callSettingsAnnounceOpening,
          subtitle: l.callSettingsAnnounceOpeningHint,
          value: s.announceOpening,
          onChanged: (v) => _set(ref, {'announceOpening': v}),
        ),
        if (s.announceOpening) ...[
          AudioRefTile(
            key: const Key('announce-opening-file'),
            title: l.callSettingsAnnounceFile,
            value: s.announceOpeningFile,
            leading: {'': l.callSettingsAnnounceChooseFile},
            onChanged: (v) => _set(ref, {'announceOpeningFile': v}),
          ),
          SelectTile<String>(
            key: const Key('announce-direction'),
            title: l.callSettingsAnnouncePlayFor,
            value: s.announceDirection,
            options: {'both': l.callSettingsAnnounceBoth, 'incoming': l.callSettingsAnnounceIncoming, 'outgoing': l.callSettingsAnnounceOutgoing},
            onChanged: (v) => _set(ref, {'announceDirection': v}),
          ),
          SwitchTile(
            key: const Key('announce-mute-mic'),
            title: l.callSettingsAnnounceMuteMic,
            value: s.announceMuteMic,
            onChanged: (v) => _set(ref, {'announceMuteMic': v}),
          ),
          SwitchTile(
            key: const Key('announce-monitor'),
            title: l.callSettingsAnnounceMonitor,
            value: s.announceMonitor,
            onChanged: (v) => _set(ref, {'announceMonitor': v}),
          ),
        ],
        AudioRefTile(
          key: const Key('announce-recording-notice'),
          icon: Icons.fiber_manual_record_rounded,
          title: l.callSettingsAnnounceBeforeRecording,
          value: s.recordingNoticeFile,
          leading: none,
          onChanged: (v) => _set(ref, {'recordingNoticeFile': v}),
        ),
        AudioRefTile(
          key: const Key('announce-transfer'),
          icon: Icons.phone_forwarded_rounded,
          title: l.callSettingsAnnounceBeforeTransfer,
          value: s.transferNoticeFile,
          leading: none,
          onChanged: (v) => _set(ref, {'transferNoticeFile': v}),
        ),
      ],
    );
  }
}
