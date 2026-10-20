import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:spcore_dart/spcore_dart.dart' show RecordFormat;

import '../../../l10n/l10n.dart';
import '../../../recordings/recording_exporter.dart';
import '../../../recordings/recording_formats.dart';
import '../../../recordings/recording_rules.dart';
import '../../../recordings/recordings_controller.dart';
import '../../../services/accounts_controller.dart';
import '../../../services/providers.dart';
import '../../../services/settings_controller.dart';
import '../../widgets/settings_tiles.dart';

Map<int, String> autoDeleteOptions(AppLocalizations l) => {
  0: l.recAutoDeleteNever,
  7: l.recAutoDeleteAfterDays(7),
  30: l.recAutoDeleteAfterDays(30),
  90: l.recAutoDeleteAfterDays(90),
  365: l.recAutoDeleteAfterYear,
};

/// Settings > Recording.
class RecordingSettingsView extends ConsumerWidget {
  const RecordingSettingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final autoDelete = autoDeleteOptions(l);
    final globalOptions = globalRecordOptions(l);
    final accountOptions = accountRecordOptions(l);
    final s = ref.watch(settingsProvider);
    final acc = ref.watch(accountsProvider);
    final usage = ref.watch(recordingsUsageProvider);
    final ctl = ref.read(settingsProvider.notifier);
    final format = recordFormatOf(s.recordFormat);
    final desktop = !kIsWeb && (Platform.isMacOS || Platform.isWindows || Platform.isLinux);
    final canPickFolder = desktop || (!kIsWeb && Platform.isAndroid);
    final days = autoDelete.containsKey(s.recordAutoDeleteDays) ? s.recordAutoDeleteDays : 0;
    return ListView(
      padding: const EdgeInsetsDirectional.only(bottom: 32),
      children: [
        SettingsGroup(
          title: l.recSettingsFormat,
          footer: recordFormatHint(l, format),
          children: [
            for (final f in RecordFormat.values)
              RadioListTile<RecordFormat>(
                key: Key('rec-format-${f.wire}'),
                value: f,
                groupValue: format,
                onChanged: (v) {
                  if (v != null) ctl.update({'recordFormat': v.wire});
                },
                title: Text(recordFormatLabel(l, f)),
              ),
          ],
        ),
        SettingsGroup(
          title: l.recSettingsAutoGroup,
          footer: l.recSettingsAutoFooter,
          children: [
            SelectTile<String>(
              key: const Key('rec-rule'),
              icon: Icons.fiber_manual_record_rounded,
              title: l.recSettingsAutoRule,
              value: globalOptions.containsKey(s.recordRule) ? s.recordRule : 'off',
              options: globalOptions,
              onChanged: (v) => ctl.update({'recordRule': v, 'autoRecord': v == 'all'}),
            ),
            for (final p in acc.profiles)
              SelectTile<String>(
                key: Key('rec-acc-${p.id}'),
                icon: Icons.dns_rounded,
                title: p.name,
                subtitle: l.recSettingsAccountOverride,
                value: accountOptions.containsKey(p.autoRecord) ? p.autoRecord : 'inherit',
                options: accountOptions,
                onChanged: (v) => ref.read(accountsProvider.notifier).update(p.copyWith(autoRecord: v)),
              ),
          ],
        ),
        SettingsGroup(
          title: l.recSettingsNoticesGroup,
          children: [
            SwitchTile(
              key: const Key('rec-notice'),
              icon: Icons.record_voice_over_rounded,
              title: l.recSettingsNoticeSwitch,
              subtitle: l.recSettingsNoticeSwitchHint,
              value: s.recordNotice,
              onChanged: (v) => ctl.update({'recordNotice': v}),
            ),
            ListTile(
              key: const Key('rec-notice-open'),
              leading: const Icon(Icons.campaign_rounded),
              title: Text(l.recSettingsNoticeFile),
              subtitle: Text(l.recSettingsNoticeFileHint),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => context.go('/settings/calls'),
            ),
            SwitchTile(
              key: const Key('rec-beep'),
              icon: Icons.notifications_active_rounded,
              title: l.recSettingsBeep,
              subtitle: l.recSettingsBeepHint,
              value: s.recordBeep,
              onChanged: (v) => ctl.update({'recordBeep': v}),
            ),
          ],
        ),
        SettingsGroup(
          title: l.recSettingsTransfersGroup,
          children: [
            SwitchTile(
              key: const Key('rec-continue'),
              icon: Icons.swap_calls_rounded,
              title: l.recSettingsContinue,
              subtitle: l.recSettingsContinueHint,
              value: s.recordContinueTransfers,
              onChanged: (v) => ctl.update({'recordContinueTransfers': v}),
            ),
          ],
        ),
        SettingsGroup(
          title: l.recSettingsStorageGroup,
          children: [
            TextTile(
              key: const Key('rec-folder'),
              icon: Icons.folder_rounded,
              title: l.recSettingsFolder,
              subtitle: l.recSettingsFolderHint,
              hint: l.recSettingsFolderPlaceholder,
              value: s.recordingFolder,
              onChanged: (v) => ctl.update({'recordingFolder': v}),
            ),
            if (canPickFolder)
              ListTile(
                key: const Key('rec-choose-folder'),
                leading: const Icon(Icons.drive_folder_upload_rounded),
                title: Text(l.recSettingsChooseFolder),
                onTap: () async {
                  final dir = await FilePicker.platform.getDirectoryPath(dialogTitle: l.recSettingsFolderPickerTitle);
                  if (dir != null) await ctl.update({'recordingFolder': dir});
                },
              ),
            SelectTile<int>(
              key: const Key('rec-auto-delete'),
              icon: Icons.auto_delete_rounded,
              title: l.recSettingsAutoDelete,
              subtitle: l.recSettingsAutoDeleteHint,
              value: days,
              options: autoDelete,
              onChanged: (v) => ctl.update({'recordAutoDeleteDays': v}),
            ),
            ListTile(
              key: const Key('rec-open-manager'),
              leading: const Icon(Icons.graphic_eq_rounded),
              title: Text(l.recSettingsManage),
              subtitle: Text(l.recUsageSummary(usage.count, formatBytes(usage.bytes))),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => context.go('/recordings'),
            ),
            if (desktop)
              ListTile(
                key: const Key('rec-open-folder'),
                leading: const Icon(Icons.folder_open_rounded),
                title: Text(l.recSettingsOpenFolder),
                onTap: () async {
                  try {
                    final dir = s.recordingFolder.isNotEmpty ? s.recordingFolder : await ref.read(recordingsDirProvider)();
                    await ref.read(recordingExporterProvider).openFolder(dir);
                  } catch (e) {
                    ref.read(noticeProvider.notifier).error(ref.read(l10nProvider).callErrCouldNotStartRecording, details: '$e');
                  }
                },
              ),
          ],
        ),
      ],
    );
  }
}
