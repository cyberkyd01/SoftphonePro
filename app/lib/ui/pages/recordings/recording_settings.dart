import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:spcore_dart/spcore_dart.dart' show RecordFormat;

import '../../../recordings/recording_exporter.dart';
import '../../../recordings/recording_formats.dart';
import '../../../recordings/recording_rules.dart';
import '../../../recordings/recordings_controller.dart';
import '../../../services/accounts_controller.dart';
import '../../../services/providers.dart';
import '../../../services/settings_controller.dart';
import '../../widgets/settings_tiles.dart';

const Map<int, String> kAutoDeleteOptions = {
  0: 'Never',
  7: 'After 7 days',
  30: 'After 30 days',
  90: 'After 90 days',
  365: 'After 1 year',
};

/// Settings > Recording.
class RecordingSettingsView extends ConsumerWidget {
  const RecordingSettingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(settingsProvider);
    final acc = ref.watch(accountsProvider);
    final usage = ref.watch(recordingsUsageProvider);
    final ctl = ref.read(settingsProvider.notifier);
    final format = recordFormatOf(s.recordFormat);
    final desktop = !kIsWeb && (Platform.isMacOS || Platform.isWindows || Platform.isLinux);
    final canPickFolder = desktop || (!kIsWeb && Platform.isAndroid);
    final days = kAutoDeleteOptions.containsKey(s.recordAutoDeleteDays) ? s.recordAutoDeleteDays : 0;
    return ListView(
      padding: const EdgeInsets.only(bottom: 32),
      children: [
        SettingsGroup(
          title: 'Format',
          footer: recordFormatHint(format),
          children: [
            for (final f in RecordFormat.values)
              RadioListTile<RecordFormat>(
                key: Key('rec-format-${f.wire}'),
                value: f,
                groupValue: format,
                onChanged: (v) {
                  if (v != null) ctl.update({'recordFormat': v.wire});
                },
                title: Text(recordFormatLabel(f)),
              ),
          ],
        ),
        SettingsGroup(
          title: 'Automatic recording',
          footer: 'Check your local laws before recording calls. Turn on "Always record calls with this contact" in a contact to record them whatever these rules say.',
          children: [
            SelectTile<String>(
              key: const Key('rec-rule'),
              icon: Icons.fiber_manual_record_rounded,
              title: 'Record calls automatically',
              value: kGlobalRecordOptions.containsKey(s.recordRule) ? s.recordRule : 'off',
              options: kGlobalRecordOptions,
              onChanged: (v) => ctl.update({'recordRule': v, 'autoRecord': v == 'all'}),
            ),
            for (final p in acc.profiles)
              SelectTile<String>(
                key: Key('rec-acc-${p.id}'),
                icon: Icons.dns_rounded,
                title: p.name,
                subtitle: 'Override for this account',
                value: kAccountRecordOptions.containsKey(p.autoRecord) ? p.autoRecord : 'inherit',
                options: kAccountRecordOptions,
                onChanged: (v) => ref.read(accountsProvider.notifier).update(p.copyWith(autoRecord: v)),
              ),
          ],
        ),
        SettingsGroup(
          title: 'Notices',
          children: [
            SwitchTile(
              key: const Key('rec-notice'),
              icon: Icons.record_voice_over_rounded,
              title: 'Play a notice before recording',
              subtitle: 'Plays the recording announcement (Settings, Audio) to the other party first',
              value: s.recordNotice,
              onChanged: (v) => ctl.update({'recordNotice': v}),
            ),
            SwitchTile(
              key: const Key('rec-beep'),
              icon: Icons.notifications_active_rounded,
              title: 'Recording beep',
              subtitle: 'Warn the other party periodically',
              value: s.recordBeep,
              onChanged: (v) => ctl.update({'recordBeep': v}),
            ),
          ],
        ),
        SettingsGroup(
          title: 'Transfers',
          children: [
            SwitchTile(
              key: const Key('rec-continue'),
              icon: Icons.swap_calls_rounded,
              title: 'Continue recording through transfers',
              subtitle: 'Record the consultation call of an attended transfer and the call handed to us by a transfer, and link the recordings',
              value: s.recordContinueTransfers,
              onChanged: (v) => ctl.update({'recordContinueTransfers': v}),
            ),
          ],
        ),
        SettingsGroup(
          title: 'Storage',
          children: [
            TextTile(
              key: const Key('rec-folder'),
              icon: Icons.folder_rounded,
              title: 'Folder',
              subtitle: 'Where recordings are saved',
              hint: 'App documents / Recordings',
              value: s.recordingFolder,
              onChanged: (v) => ctl.update({'recordingFolder': v}),
            ),
            if (canPickFolder)
              ListTile(
                key: const Key('rec-choose-folder'),
                leading: const Icon(Icons.drive_folder_upload_rounded),
                title: const Text('Choose folder...'),
                onTap: () async {
                  final dir = await FilePicker.platform.getDirectoryPath(dialogTitle: 'Recordings folder');
                  if (dir != null) await ctl.update({'recordingFolder': dir});
                },
              ),
            SelectTile<int>(
              key: const Key('rec-auto-delete'),
              icon: Icons.auto_delete_rounded,
              title: 'Delete old recordings',
              subtitle: 'Checked at startup and once a day',
              value: days,
              options: kAutoDeleteOptions,
              onChanged: (v) => ctl.update({'recordAutoDeleteDays': v}),
            ),
            ListTile(
              key: const Key('rec-open-manager'),
              leading: const Icon(Icons.graphic_eq_rounded),
              title: const Text('Manage recordings'),
              subtitle: Text('${usage.count} recording${usage.count == 1 ? '' : 's'}  ·  ${formatBytes(usage.bytes)}'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => context.go('/recordings'),
            ),
            if (desktop)
              ListTile(
                key: const Key('rec-open-folder'),
                leading: const Icon(Icons.folder_open_rounded),
                title: const Text('Open recordings folder'),
                onTap: () async {
                  final dir = s.recordingFolder.isNotEmpty ? s.recordingFolder : await ref.read(recordingsDirProvider)();
                  await ref.read(recordingExporterProvider).openFolder(dir);
                },
              ),
          ],
        ),
      ],
    );
  }
}
