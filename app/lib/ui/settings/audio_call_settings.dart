import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    return SettingsGroup(
      title: 'Hold',
      footer: 'With "PBX default" the call is simply put on hold and your phone system may play its own music. Any other choice is played to the caller by this app.',
      children: [
        AudioRefTile(
          key: const Key('hold-music'),
          icon: Icons.music_note_rounded,
          title: 'Hold music',
          value: s.holdMusic,
          holdMusicOnly: true,
          leading: const {'pbx': 'PBX default'},
          onChanged: (v) => _set(ref, {'holdMusic': v}),
        ),
        SliderTile(
          key: const Key('hold-music-volume'),
          icon: Icons.volume_up_rounded,
          title: 'Hold music volume',
          value: s.holdMusicVolume,
          divisions: 10,
          format: (v) => '${(v * 100).round()}%',
          onChanged: custom ? (v) => _set(ref, {'holdMusicVolume': v}) : (_) {},
        ),
        NavTile(
          key: const Key('hold-music-library'),
          icon: Icons.library_music_rounded,
          title: 'Audio files',
          subtitle: 'Import or record hold music',
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
    const none = {'': 'None'};
    return SettingsGroup(
      title: 'Announcements',
      footer: 'Announcements are played to the other party. Everything is skipped silently if the file is missing.',
      children: [
        SwitchTile(
          key: const Key('announce-opening'),
          icon: Icons.campaign_rounded,
          title: 'Opening announcement',
          subtitle: 'Play a message when a call connects',
          value: s.announceOpening,
          onChanged: (v) => _set(ref, {'announceOpening': v}),
        ),
        if (s.announceOpening) ...[
          AudioRefTile(
            key: const Key('announce-opening-file'),
            title: 'Announcement file',
            value: s.announceOpeningFile,
            leading: const {'': 'Choose a file'},
            onChanged: (v) => _set(ref, {'announceOpeningFile': v}),
          ),
          SelectTile<String>(
            key: const Key('announce-direction'),
            title: 'Play for',
            value: s.announceDirection,
            options: const {'both': 'Incoming and outgoing', 'incoming': 'Incoming calls', 'outgoing': 'Outgoing calls'},
            onChanged: (v) => _set(ref, {'announceDirection': v}),
          ),
          SwitchTile(
            key: const Key('announce-mute-mic'),
            title: 'Mute my microphone while it plays',
            value: s.announceMuteMic,
            onChanged: (v) => _set(ref, {'announceMuteMic': v}),
          ),
          SwitchTile(
            key: const Key('announce-monitor'),
            title: 'Also let me hear it',
            value: s.announceMonitor,
            onChanged: (v) => _set(ref, {'announceMonitor': v}),
          ),
        ],
        AudioRefTile(
          key: const Key('announce-recording-notice'),
          icon: Icons.fiber_manual_record_rounded,
          title: 'Before recording starts, play',
          value: s.recordingNoticeFile,
          leading: none,
          onChanged: (v) => _set(ref, {'recordingNoticeFile': v}),
        ),
        AudioRefTile(
          key: const Key('announce-transfer'),
          icon: Icons.phone_forwarded_rounded,
          title: 'Before transferring a caller, play',
          value: s.transferNoticeFile,
          leading: none,
          onChanged: (v) => _set(ref, {'transferNoticeFile': v}),
        ),
      ],
    );
  }
}
