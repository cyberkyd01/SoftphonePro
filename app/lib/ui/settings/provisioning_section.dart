import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../l10n/l10n.dart';
import '../../services/accounts_controller.dart';
import '../../services/provisioning.dart';
import '../../services/provisioning_import.dart';
import '../../services/providers.dart';
import '../../services/settings_controller.dart';
import '../../models/app_settings.dart';
import '../widgets/qr_payload.dart';
import '../widgets/qr_scanner_sheet.dart';
import '../widgets/settings_tiles.dart';

/// Applies a parsed provisioning result after user confirmation.
Future<int> applyProvisioning(BuildContext context, WidgetRef ref, ProvisioningResult r) async {
  final l = context.l10n;
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(l.provisioningImportTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.provisioningSummary(r.accounts.length, r.settings.length)),
          for (final a in r.accounts) Text('• ${a.name}  (${a.address})'),
          if (r.warnings.isNotEmpty) ...[
            const SizedBox(height: 8),
            for (final w in r.warnings) Text(w, style: TextStyle(color: Theme.of(ctx).colorScheme.error)),
          ],
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l.actionCancel)),
        FilledButton(key: const Key('apply-import'), onPressed: r.accounts.isEmpty && r.settings.isEmpty ? null : () => Navigator.pop(ctx, true), child: Text(l.actionImport)),
      ],
    ),
  );
  if (ok != true) return 0;
  for (final a in r.accounts) {
    await ref.read(accountsProvider.notifier).add(a);
  }
  if (r.settings.isNotEmpty || r.accounts.isNotEmpty) {
    await ref.read(settingsProvider.notifier).update({...r.settings, if (r.accounts.isNotEmpty) 'onboardingDone': true});
  }
  ref.read(noticeProvider.notifier).show(l.provisioningImportedAccounts(r.accounts.length));
  return r.accounts.length;
}

/// Asks for a URL or pasted JSON and imports it. Returns accounts added.
Future<int> importProvisioningDialog(BuildContext context, WidgetRef ref) async {
  final text = await promptText(context, title: context.l10n.provisioningImportFromUrlTitle, hint: context.l10n.provisioningImportFromUrlHint, maxLines: 4);
  if (text == null || text.isEmpty || !context.mounted) return 0;
  return importProvisioningText(context, ref, text);
}

/// Imports provisioning JSON, an http(s) URL or a `softphonepro://provision`
/// link (what the QR code carries). Returns accounts added.
Future<int> importProvisioningText(BuildContext context, WidgetRef ref, String text) async {
  final l = context.l10n;
  try {
    final p = parseQrPayload(text);
    final r = switch (p) {
      QrProvisionJson(:final json) => Provisioning.parse(json, l10n: l),
      QrProvisionUrl(:final url) => await Provisioning.fetch(
        url,
        l10n: l,
        vars: await provisioningVars(
          settings: ref.read(settingsProvider).toJson(),
          save: ref.read(settingsProvider.notifier).update,
        ),
      ),
      _ => throw const FormatException('unsupported'),
    };
    if (!context.mounted) return 0;
    return applyProvisioning(context, ref, r);
  } on ProvisioningException catch (e) {
    ref.read(noticeProvider.notifier).error(e.message);
    return 0;
  } on FormatException {
    ref.read(noticeProvider.notifier).error(l.provisioningInvalidSource);
    return 0;
  }
}

/// Opens the QR scanner (camera, with paste fallback) and imports the result.
Future<int> scanProvisioningQr(BuildContext context, WidgetRef ref) async {
  final code = await showQrScannerSheet(context, title: context.l10n.provisioningScanTitle, pasteHint: context.l10n.provisioningPasteHint);
  if (code == null || !context.mounted) return 0;
  return importProvisioningText(context, ref, code);
}

class ProvisioningSection extends ConsumerStatefulWidget {
  const ProvisioningSection({super.key});
  @override
  ConsumerState<ProvisioningSection> createState() => _ProvisioningSectionState();
}

class _ProvisioningSectionState extends ConsumerState<ProvisioningSection> {
  bool _passwords = false;
  String? _qrFor;

  String _export() {
    final acc = ref.read(accountsProvider).profiles;
    return Provisioning.export(acc, ref.read(settingsProvider).toJson(), includePasswords: _passwords);
  }

  @override
  Widget build(BuildContext context) {
    final acc = ref.watch(accountsProvider).profiles;
    final notice = ref.read(noticeProvider.notifier);
    final qrAcc = acc.where((a) => a.id == _qrFor).firstOrNull;
    final l = context.l10n;
    return ListView(
      padding: const EdgeInsets.only(bottom: 32),
      children: [
        SettingsGroup(
          title: l.provisioningImportGroup,
          footer: l.provisioningImportFooter,
          children: [
            NavTile(
              icon: Icons.qr_code_scanner_rounded,
              title: l.provisioningScanQr,
              onTap: () => scanProvisioningQr(context, ref),
            ),
            NavTile(
              icon: Icons.link_rounded,
              title: l.provisioningFromUrl,
              onTap: () => importProvisioningDialog(context, ref),
            ),
            NavTile(
              icon: Icons.folder_open_rounded,
              title: l.provisioningFromFile,
              onTap: () async {
                final r = await FilePicker.platform.pickFiles(type: FileType.any, withData: true);
                final bytes = r?.files.single.bytes;
                if (bytes == null || !context.mounted) return;
                try {
                  await applyProvisioning(context, ref, Provisioning.parse(String.fromCharCodes(bytes), l10n: l));
                } on ProvisioningException catch (e) {
                  notice.error(e.message);
                }
              },
            ),
            NavTile(
              icon: Icons.content_paste_rounded,
              title: l.provisioningFromClipboard,
              onTap: () async {
                final d = await Clipboard.getData(Clipboard.kTextPlain);
                if (!context.mounted) return;
                try {
                  await applyProvisioning(context, ref, Provisioning.parse(d?.text ?? '', l10n: l));
                } on ProvisioningException catch (e) {
                  notice.error(e.message);
                }
              },
            ),
          ],
        ),
        SettingsGroup(
          title: l.provisioningExportGroup,
          children: [
            SwitchTile(title: l.provisioningIncludePasswords, subtitle: l.provisioningIncludePasswordsHint, value: _passwords, onChanged: (v) => setState(() => _passwords = v)),
            NavTile(
              icon: Icons.copy_rounded,
              title: l.provisioningCopyConfig,
              onTap: () async {
                await Clipboard.setData(ClipboardData(text: _export()));
                notice.show(l.provisioningConfigCopied);
              },
            ),
          ],
        ),
        SettingsGroup(
          title: l.provisioningQrGroup,
          footer: l.provisioningQrFooter,
          children: [
            SelectTile<String>(
              title: l.provisioningQrAccount,
              value: _qrFor ?? '',
              options: {'': l.provisioningChoose, for (final a in acc) a.id: a.name},
              onChanged: (v) => setState(() => _qrFor = v.isEmpty ? null : v),
            ),
            if (qrAcc != null)
              Padding(
                padding: const EdgeInsets.all(20),
                child: Center(
                  child: Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(12),
                    child: QrImageView(
                      data: Provisioning.export([qrAcc], const AppSettings().toJson(), includePasswords: _passwords),
                      size: 240,
                      version: QrVersions.auto,
                      errorStateBuilder: (c, e) => Text(l.provisioningQrTooMuchData),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
