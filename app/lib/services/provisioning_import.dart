import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../l10n/l10n.dart';
import 'accounts_controller.dart';
import 'providers.dart';
import 'provisioning.dart';
import 'settings_controller.dart';

/// HTTP client for provisioning downloads (tests override it).
final provisioningClientProvider = Provider<http.Client?>((ref) => null);

/// Variables for `${MAC}`, `${USER}` and `${HOSTNAME}` placeholders.
///
/// The real MAC address is not available to Dart apps, so `MAC` is a stable
/// per-install id in MAC notation (locally administered), created once.
Future<Map<String, String>> provisioningVars({
  required Map<String, dynamic> settings,
  required Future<void> Function(Map<String, dynamic>) save,
}) async {
  var id = settings['instanceMac'] as String?;
  if (id == null || id.isEmpty) {
    final r = Random.secure();
    final b = [0x02, for (var i = 0; i < 5; i++) r.nextInt(256)];
    id = b.map((e) => e.toRadixString(16).padLeft(2, '0')).join(':');
    await save({'instanceMac': id});
  }
  var user = '';
  var host = '';
  if (!kIsWeb) {
    final env = Platform.environment;
    user = env['USER'] ?? env['USERNAME'] ?? '';
    try {
      host = Platform.localHostname;
    } catch (_) {}
  }
  return {'MAC': id, 'USER': user, 'HOSTNAME': host};
}

/// Adds the accounts / settings of [r], marks onboarding complete when an
/// account was provisioned. Returns the number of accounts added.
///
/// Settings under the `automation` prefix (local automation API: enable flag,
/// port, token, origins) are only applied when [allowAutomation] is set, i.e.
/// for local command-line provisioning. Configuration downloaded through a
/// web link or the Settings screen cannot switch the API on or choose its token.
Future<int> importProvisioningResult(
  Ref ref,
  ProvisioningResult r, {
  bool allowAutomation = false,
}) async {
  for (final a in r.accounts) {
    await ref.read(accountsProvider.notifier).add(a);
  }
  final changes = {...r.settings};
  if (!allowAutomation) {
    changes.removeWhere((k, _) => k.startsWith('automation'));
  }
  if (r.accounts.isNotEmpty) changes['onboardingDone'] = true;
  if (changes.isNotEmpty) {
    await ref.read(settingsProvider.notifier).update(changes);
  }
  ref.read(noticeProvider.notifier).show(ref.read(l10nProvider).provisioningImportedAccounts(r.accounts.length));
  return r.accounts.length;
}

/// Loads a provisioning source: https/http URL or a local file path.
Future<ProvisioningResult> loadProvisioningSource(Ref ref, String source) async {
  final vars = await provisioningVars(
    settings: ref.read(settingsProvider).toJson(),
    save: ref.read(settingsProvider.notifier).update,
  );
  final u = Uri.tryParse(source);
  if (u != null && (u.scheme == 'http' || u.scheme == 'https')) {
    return Provisioning.fetch(u, vars: vars, client: ref.read(provisioningClientProvider), l10n: ref.read(l10nProvider));
  }
  try {
    final path = u != null && u.scheme == 'file' ? u.toFilePath() : source;
    return Provisioning.parse(await File(path).readAsString(), vars: vars, l10n: ref.read(l10nProvider));
  } on FileSystemException catch (e) {
    throw ProvisioningException(ref.read(l10nProvider).provisioningCouldNotRead(e.path ?? source));
  }
}

// ---- web-link provisioning safety ---------------------------------------------

/// Settings a web link can never change (local-only state and secrets).
bool _webForbiddenSetting(String k) =>
    k.startsWith('automation') ||
    k.startsWith('appLock') ||
    k.startsWith('update') ||
    k == 'instanceMac' ||
    k == 'onboardingDone';

/// The first setting in [r] that a web link must refuse outright (so that nothing
/// is imported): turning TLS verification off or pointing at a custom CA file
/// (a man-in-the-middle recipe). Such settings are for file / command-line
/// import only. Null when the link is acceptable.
String? refusedWebSetting(ProvisioningResult r) {
  if (r.settings['tlsVerify'] == false) return 'tlsVerify';
  final ca = r.settings['customCaFile'];
  if (ca != null && '$ca'.isNotEmpty) return 'customCaFile';
  return null;
}

enum ImportFlagKind { autoAnswer, forwarding, intercom, dialRewrite, linksImmediately, diagnostics }

class ImportFlag {
  const ImportFlag(this.kind, [this.arg]);
  final ImportFlagKind kind;
  final String? arg;
}

/// What in [r] deserves a warning in the confirmation dialog.
List<ImportFlag> sensitiveImportFlags(ProvisioningResult r) {
  final out = <ImportFlag>[];
  bool has(ImportFlagKind k) => out.any((f) => f.kind == k);
  void add(ImportFlag f) {
    if (f.kind == ImportFlagKind.forwarding || !has(f.kind)) out.add(f);
  }

  final st = r.settings;
  if (st['autoAnswer'] == true) add(const ImportFlag(ImportFlagKind.autoAnswer));
  for (final a in r.accounts) {
    if (a.autoAnswer.enabled) add(const ImportFlag(ImportFlagKind.autoAnswer));
    if (a.forwarding.active) add(ImportFlag(ImportFlagKind.forwarding, a.forwarding.target));
  }
  if (st['lanAllowIntercom'] == true || st['lanIntercomPrompt'] == false || st['lanAllowPull'] == true) {
    add(const ImportFlag(ImportFlagKind.intercom));
  }
  if ('${st['stripPrefix'] ?? ''}'.isNotEmpty ||
      '${st['plusReplacement'] ?? ''}'.isNotEmpty ||
      (st['dialRules'] is List && (st['dialRules'] as List).isNotEmpty)) {
    add(const ImportFlag(ImportFlagKind.dialRewrite));
  }
  if (st['callLinksImmediately'] == true) add(const ImportFlag(ImportFlagKind.linksImmediately));
  if (st['sipTrace'] == true || st.containsKey('logLevel')) add(const ImportFlag(ImportFlagKind.diagnostics));
  return out;
}

/// Number of settings in [r] that are not shown as a flagged item.
int unflaggedSettingCount(ProvisioningResult r) => r.settings.keys.where((k) => !_webForbiddenSetting(k)).length;

/// [r] as a web link may apply it: local-only settings dropped and, unless
/// [allowAutoAnswer], every auto-answer switch (global and per account) off.
ProvisioningResult sanitizeForWebLink(ProvisioningResult r, {required bool allowAutoAnswer}) {
  final st = {...r.settings}..removeWhere((k, _) => _webForbiddenSetting(k));
  if (!allowAutoAnswer) st.remove('autoAnswer');
  return ProvisioningResult(
    accounts: [
      for (final a in r.accounts)
        allowAutoAnswer || !a.autoAnswer.enabled ? a : a.copyWith(autoAnswer: a.autoAnswer.copyWith(enabled: false)),
    ],
    settings: st,
    warnings: r.warnings,
  );
}
