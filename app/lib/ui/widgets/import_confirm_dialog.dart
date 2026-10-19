import 'package:flutter/material.dart';

import '../../l10n/l10n.dart';
import '../../models/account_profile.dart';
import '../../services/provisioning_import.dart';

String importFlagText(AppLocalizations l, ImportFlag f) => switch (f.kind) {
  ImportFlagKind.autoAnswer => l.linkImportFlagAutoAnswer,
  ImportFlagKind.autoRecord => l.linkImportFlagAutoRecord,
  ImportFlagKind.forwarding => l.linkImportFlagForwarding(f.arg ?? ''),
  ImportFlagKind.intercom => l.linkImportFlagIntercom,
  ImportFlagKind.dialRewrite => l.linkImportFlagDialRewrite,
  ImportFlagKind.linksImmediately => l.linkImportFlagLinksImmediately,
  ImportFlagKind.diagnostics => l.linkImportFlagDiagnostics,
  ImportFlagKind.blocklist => l.linkImportFlagBlocklist,
  ImportFlagKind.emergencyNumbers => l.linkImportFlagEmergency,
  ImportFlagKind.speedDial => l.linkImportFlagSpeedDial,
  ImportFlagKind.recordingDeletion => l.linkImportFlagRecordingDelete,
  ImportFlagKind.featureCodes => l.linkImportFlagFeatureCodes,
};

/// Lines describing where an imported account connects (server, proxies,
/// transport, relay, custom headers, caller id).
List<String> importAccountLines(AppLocalizations l, AccountProfile a) {
  final c = a.config;
  final server = (c.registrar != null && c.registrar!.isNotEmpty) ? c.registrar! : c.domain;
  final out = <String>[l.importAccountLine(a.name, a.address, server, c.transport.wire)];
  if (c.proxies.isNotEmpty) out.add(l.importAccountProxies(c.proxies.join(', ')));
  if (a.backupRegistrar.isNotEmpty) out.add(l.importAccountProxies(a.backupRegistrar));
  if (c.turn.enabled && c.turn.server.isNotEmpty) out.add(l.importAccountTurn(c.turn.server));
  if (c.headers.isNotEmpty) out.add(l.importAccountHeaders(c.headers.entries.map((e) => '${e.key}: ${e.value}').join('; ')));
  if ((c.callerId ?? '').isNotEmpty) out.add(l.importAccountCallerId(c.callerId!));
  if (c.transport.wire == 'tls' && c.srtp.wire == 'off') out.add(l.importAccountSrtpOff);
  return out;
}

/// The ONE confirmation dialog for every untrusted import (web link, QR,
/// pasted URL / JSON, file, Settings URL fetch). Shows each account's server,
/// every flagged item, the keys that are ignored, and the checkboxes that
/// switch on auto-answer / automatic recording (both off by default).
/// Returns what the user accepted, or null when cancelled.
Future<ImportDecision?> showImportConfirmDialog(BuildContext context, ImportPlan plan, {String? host}) {
  final l = context.l10n;
  var allowAutoAnswer = false;
  var allowAutoRecord = false;
  return showDialog<ImportDecision>(
    context: context,
    builder: (c) => StatefulBuilder(
      builder: (c, setState) => AlertDialog(
        key: const Key('link-import-confirm'),
        title: Text(l.callLinkImportTitle),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                host == null
                    ? l.provisioningSummary(plan.accounts.length, plan.settingCount)
                    : plan.settingCount == 0
                    ? l.callLinkImportBody(host, plan.accounts.length)
                    : l.callLinkImportBodyWithSettings(host, plan.accounts.length, plan.settingCount),
              ),
              for (final a in plan.accounts)
                for (final (i, line) in importAccountLines(l, a).indexed)
                  Padding(
                    padding: EdgeInsets.only(top: i == 0 ? 8 : 2, left: i == 0 ? 0 : 12),
                    child: Text(i == 0 ? '• $line' : line, key: i == 0 ? const Key('link-import-account') : null),
                  ),
              if (plan.flags.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(l.linkImportSensitiveHeader, style: const TextStyle(fontWeight: FontWeight.w700)),
                for (final f in plan.flags)
                  Padding(
                    key: Key('link-import-flag-${f.kind.name}'),
                    padding: const EdgeInsets.only(top: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.warning_amber_rounded, size: 18, color: Theme.of(c).colorScheme.error),
                        const SizedBox(width: 6),
                        Expanded(child: Text(importFlagText(l, f))),
                      ],
                    ),
                  ),
              ],
              if (plan.hasAutoAnswer)
                CheckboxListTile(
                  key: const Key('link-import-allow-autoanswer'),
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  value: allowAutoAnswer,
                  title: Text(l.linkImportAllowAutoAnswer),
                  onChanged: (v) => setState(() => allowAutoAnswer = v ?? false),
                ),
              if (plan.hasAutoRecord)
                CheckboxListTile(
                  key: const Key('link-import-allow-autorecord'),
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  value: allowAutoRecord,
                  title: Text(l.linkImportAllowAutoRecord),
                  onChanged: (v) => setState(() => allowAutoRecord = v ?? false),
                ),
              if (plan.ignored.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(l.importIgnoredHeader, style: const TextStyle(fontWeight: FontWeight.w700)),
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(plan.ignored.join(', '), key: const Key('link-import-ignored')),
                ),
              ],
              if (plan.warnings.isNotEmpty) ...[
                const SizedBox(height: 8),
                for (final w in plan.warnings) Text(w, style: TextStyle(color: Theme.of(c).colorScheme.error)),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: Text(l.actionCancel)),
          FilledButton(
            key: const Key('link-import-yes'),
            onPressed: plan.isEmpty
                ? null
                : () => Navigator.pop(c, ImportDecision(allowAutoAnswer: allowAutoAnswer, allowAutoRecord: allowAutoRecord)),
            child: Text(l.actionImport),
          ),
        ],
      ),
    ),
  );
}
