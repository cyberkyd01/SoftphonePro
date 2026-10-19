import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

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
Future<int> importProvisioningResult(Ref ref, ProvisioningResult r) async {
  for (final a in r.accounts) {
    await ref.read(accountsProvider.notifier).add(a);
  }
  final changes = {...r.settings};
  if (r.accounts.isNotEmpty) changes['onboardingDone'] = true;
  if (changes.isNotEmpty) {
    await ref.read(settingsProvider.notifier).update(changes);
  }
  ref.read(noticeProvider.notifier).show('Imported ${r.accounts.length} account(s)');
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
    return Provisioning.fetch(u, vars: vars, client: ref.read(provisioningClientProvider));
  }
  try {
    final path = u != null && u.scheme == 'file' ? u.toFilePath() : source;
    return Provisioning.parse(await File(path).readAsString(), vars: vars);
  } on FileSystemException catch (e) {
    throw ProvisioningException('Could not read ${e.path ?? source}');
  }
}
