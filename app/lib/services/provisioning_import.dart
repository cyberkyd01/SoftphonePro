// ignore_for_file: curly_braces_in_flow_control_structures
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show ProviderListenable;
import 'package:http/http.dart' as http;

import '../l10n/l10n.dart';
import 'package:spcore_dart/spcore_dart.dart' show AccountConfig;

import '../models/account_profile.dart';
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

/// A provider reader: `ref.read` of a [Ref] or a [WidgetRef].
typedef Reader = T Function<T>(ProviderListenable<T> provider);

/// TRUSTED import: local command-line `--provision` only. Everything in [r]
/// applies, including the local automation API (enable flag, port, token,
/// origins). Nothing but `ProvisionCliAction` may call this.
Future<int> applyTrustedImport(Reader read, ProvisioningResult r) =>
    _applyImport(read, accounts: r.accounts, settings: r.settings);

/// UNTRUSTED import (web link, QR code, pasted URL / JSON, file, Settings URL
/// fetch): applies exactly what [plan] resolved for [decision]. The plan is
/// built by [prepareUntrustedImport], so nothing outside the allowlist, no
/// refused setting and no un-ticked risky feature reaches the stores.
Future<int> applyImportPlan(
  Reader read,
  ImportPlan plan, [
  ImportDecision decision = const ImportDecision(),
]) async {
  if (plan.refusedKey != null) {
    throw ProvisioningException(
      read(l10nProvider).linkImportRefused(plan.refusedKey!),
    );
  }
  final r = plan.resolve(decision);
  return await _applyImport(read, accounts: r.accounts, settings: r.settings);
}

/// Compatibility entry point. [allowAutomation] marks a TRUSTED (command-line)
/// import; the default is the UNTRUSTED path with no risky feature accepted.
Future<int> importProvisioningResult(
  Ref ref,
  ProvisioningResult r, {
  bool allowAutomation = false,
}) => allowAutomation
    ? applyTrustedImport(ref.read, r)
    : applyImportPlan(ref.read, prepareUntrustedImport(r));

Future<int> _applyImport(
  Reader read, {
  required List<AccountProfile> accounts,
  required Map<String, dynamic> settings,
}) async {
  for (final a in accounts) {
    await read(accountsProvider.notifier).add(a);
  }
  final changes = {...settings};
  if (accounts.isNotEmpty) changes['onboardingDone'] = true;
  if (changes.isNotEmpty) {
    await read(settingsProvider.notifier).update(changes);
  }
  read(noticeProvider.notifier).show(
    read(l10nProvider).provisioningImportedAccounts(accounts.length),
  );
  return accounts.length;
}

/// Loads a provisioning source: https/http URL or a local file path.
Future<ProvisioningResult> loadProvisioningSource(
  Ref ref,
  String source,
) async {
  final vars = await provisioningVars(
    settings: ref.read(settingsProvider).toJson(),
    save: ref.read(settingsProvider.notifier).update,
  );
  final u = Uri.tryParse(source);
  if (u != null && (u.scheme == 'http' || u.scheme == 'https')) {
    return Provisioning.fetch(
      u,
      vars: vars,
      client: ref.read(provisioningClientProvider),
      l10n: ref.read(l10nProvider),
    );
  }
  try {
    final path = u != null && u.scheme == 'file' ? u.toFilePath() : source;
    return Provisioning.parse(
      await File(path).readAsString(),
      vars: vars,
      l10n: ref.read(l10nProvider),
    );
  } on FileSystemException catch (e) {
    throw ProvisioningException(
      ref.read(l10nProvider).provisioningCouldNotRead(e.path ?? source),
    );
  }
}

// ---- trust model --------------------------------------------------------------
//
// Two levels. TRUSTED: the local command line (`--provision`), see
// [applyTrustedImport]. UNTRUSTED: everything else (web link, QR, pasted
// URL / JSON, file, Settings URL fetch). Untrusted configuration goes through
// [prepareUntrustedImport] and one confirmation dialog
// (`showImportConfirmDialog`), and only [kSettingImportPolicy]'s `allowed` and
// `flagged` keys can ever be applied. A new setting is `forbidden` unless
// someone classifies it (test/provisioning_trust_test.dart enforces that).

enum ImportClass {
  /// User preference that cannot weaken security or exfiltrate data.
  allowed,

  /// Applied, but shown in the dialog (some only when a checkbox is ticked).
  flagged,

  /// Dropped and listed as "ignored".
  forbidden,

  /// Refuses the whole import when present with a dangerous value.
  refused,
}

const _a = ImportClass.allowed;
const _f = ImportClass.flagged;
const _x = ImportClass.forbidden;
const _r = ImportClass.refused;

/// Classification of EVERY key of `AppSettings`.
const Map<String, ImportClass> kSettingImportPolicy = {
  // appearance
  'themeMode': _a, 'accent': _a, 'compactDensity': _a, 'language': _a,
  // status / calls
  'globalStatus': _x,
  'dnd': _a,
  'dndRejectCode': _a,
  'callWaiting': _a,
  'busyRejectCode': _a,
  'autoAnswer': _f,
  'autoAnswerDelay': _f,
  'allowAutoAnswerHeaders': _x,
  'rejectAnonymous': _a,
  'blocklist': _f,
  'ringtone': _a,
  'ringerVolume': _a,
  'emergencyNumbers': _f,
  'defaultCountryPrefix': _f,
  // audio (device names are machine specific: not importable)
  'captureDev': _x, 'playbackDev': _x, 'ringerDev': _x,
  'micLevel': _a,
  'speakerLevel': _a,
  'ecAlgo': _a,
  'ecTailMs': _a,
  'noiseSuppression': _a,
  'agc': _a,
  'vad': _a,
  // codecs
  'codecOrder': _a,
  'codecsDisabled': _a,
  'opusBitrate': _a,
  'opusFec': _a,
  'opusDtx': _a,
  'opusCbr': _a,
  'opusComplexity': _a,
  // network: transports / ports / STUN could downgrade or redirect; TLS and DNS are refused
  'udpEnabled': _x,
  'udpPort': _x,
  'tcpEnabled': _x,
  'tcpPort': _x,
  'tlsEnabled': _x,
  'tlsPort': _x,
  'tlsVerify': _r,
  'stunServers': _x,
  'ipv6': _x,
  'qos': _x,
  'dnsServers': _r,
  'tlsPins': _r,
  'rtpPort': _x, 'rtpPortRange': _x,
  // recording
  'autoRecord': _f,
  'recordingFolder': _x,
  'recordBeep': _a,
  'recordFormat': _a,
  'recordRule': _f,
  'recordNotice': _a, 'recordAutoDeleteDays': _f, 'recordContinueTransfers': _a,
  // privacy / system
  'appLock': _r, 'appLockMinutes': _r, 'appLockBiometrics': _r,
  'startAtLogin': _x, 'minimizeToTray': _a, 'hotkeys': _x, 'sendTyping': _a,
  // dial plan
  'dialRules': _f, 'stripPrefix': _f, 'plusReplacement': _f,
  // LAN
  'lanEnabled': _x,
  'lanDeviceName': _a,
  'lanShareAors': _x,
  'lanAllowIntercom': _f,
  'lanAllowPull': _f,
  'lanAutoAcceptFiles': _x,
  'lanDownloadsDir': _x,
  'lanLinkPort': _x,
  'lanIntercomPrompt': _f,
  // developer / flow
  'logLevel': _f, 'sipTrace': _f, 'useSimulator': _x, 'onboardingDone': _x,
  // polish
  'customCaFile': _r, 'callLinksImmediately': _f, 'syncFeatureCodes': _f,
  'jbInitMs': _a,
  'jbMinPreMs': _a,
  'jbMaxPreMs': _a,
  'jbMaxMs': _a,
  'ptime': _a,
  'progressTones': _a,
  // automation API (desktop, local only)
  'automationEnabled': _r,
  'automationPort': _r,
  'automationToken': _r,
  'automationOrigins': _r,
  // voice isolation, hold music, announcements (audio files are paths: not importable)
  'viMicOn': _a, 'viMicStrength': _a, 'viInOn': _a, 'viInStrength': _a,
  'holdMusic': _a, 'holdMusicVolume': _a,
  'announceOpening': _a,
  'announceOpeningFile': _x,
  'announceDirection': _a,
  'announceMuteMic': _a,
  'announceMonitor': _a,
  'recordingNoticeFile': _x, 'transferNoticeFile': _x,
  'speedDial': _f,
  // updates / media keys
  'updateCheck': _x,
  'updateLastCheck': _x,
  'updateSkipVersion': _x,
  'instanceMac': _x,
  'mediaKeys': _a, 'mediaKeyActive': _a,
};

/// The class of setting [k]; keys nobody classified are [ImportClass.forbidden]
/// (`automation*` / `appLock*` stay refused whatever they are called).
ImportClass classifyImportSetting(String k) {
  final c = kSettingImportPolicy[k];
  if (c != null) return c;
  if (k.startsWith('automation') || k.startsWith('appLock'))
    return ImportClass.refused;
  return ImportClass.forbidden;
}

bool _nonEmpty(Object? v) => v is String
    ? v.trim().isNotEmpty
    : v is List
    ? v.isNotEmpty
    : v != null;

/// The first setting in [settings] that makes an untrusted import unacceptable
/// as a whole: TLS verification off, a custom CA, certificate pins, custom DNS
/// resolvers, the automation API or the app lock. Null when none.
String? refusedImportSetting(Map<String, dynamic> settings) {
  for (final e in settings.entries) {
    if (classifyImportSetting(e.key) != ImportClass.refused) continue;
    switch (e.key) {
      case 'tlsVerify':
        if (e.value != true)
          return e.key; // true is a no-op (dropped); anything else weakens TLS
      case 'customCaFile' || 'tlsPins' || 'dnsServers':
        if (_nonEmpty(e.value)) return e.key;
      default:
        return e.key;
    }
  }
  return null;
}

final RegExp _audioRef = RegExp(
  r'^(builtin:[A-Za-z0-9_.\-]{1,64}|lib:[^/\\:\x00-\x1f]{1,128})$',
);
bool _safeAudioRef(Object? v, Set<String> words) =>
    v is String &&
    (words.contains(v) || (_audioRef.hasMatch(v) && !v.contains('..')));

/// Type / shape check for an importable value (false: dropped as ignored).
bool _validImportValue(String k, Object? v) {
  bool isList(int max) =>
      v is List &&
      v.length <= max &&
      v.every((e) => e is String && e.length <= 128);
  switch (k) {
    case 'themeMode' ||
        'ecAlgo' ||
        'recordFormat' ||
        'recordRule' ||
        'announceDirection' ||
        'mediaKeyActive' ||
        'language' ||
        'globalStatus':
      return v is String && v.length <= 32;
    case 'ringtone' || 'holdMusic':
      return _safeAudioRef(v, const {'default', 'pbx'});
    case 'lanDeviceName' ||
        'stripPrefix' ||
        'plusReplacement' ||
        'defaultCountryPrefix':
      return v is String && v.length <= 64;
    case 'blocklist' || 'emergencyNumbers' || 'codecOrder' || 'codecsDisabled':
      return isList(256);
    case 'dialRules':
      return v is List && v.length <= 64 && v.every((e) => e is Map);
    case 'speedDial':
      return v is Map && v.length <= 9;
    case 'ringerVolume' ||
        'micLevel' ||
        'speakerLevel' ||
        'holdMusicVolume' ||
        'viMicStrength' ||
        'viInStrength':
      return v is num && v >= 0 && v <= 4;
    case 'accent':
      return v is int;
  }
  // Remaining keys: booleans or integers (the getter ignores a wrong type anyway).
  return v is bool || (v is num && v.isFinite && v.abs() < 1e9);
}

enum ImportFlagKind {
  autoAnswer,
  autoRecord,
  forwarding,
  intercom,
  dialRewrite,
  linksImmediately,
  diagnostics,
  blocklist,
  emergencyNumbers,
  speedDial,
  recordingDeletion,
  featureCodes,
}

class ImportFlag {
  const ImportFlag(this.kind, [this.arg]);
  final ImportFlagKind kind;
  final String? arg;
}

/// What the user ticked in the confirmation dialog.
class ImportDecision {
  const ImportDecision({
    this.allowAutoAnswer = false,
    this.allowAutoRecord = false,
  });
  final bool allowAutoAnswer;
  final bool allowAutoRecord;
}

/// What an untrusted import would do, computed before anything is applied.
class ImportPlan {
  ImportPlan._({
    required this.refusedKey,
    required this.accounts,
    required this.safeSettings,
    required this.autoAnswerSettings,
    required this.autoRecordSettings,
    required this.flags,
    required this.ignored,
    required this.warnings,
  });

  /// Non-null: the whole import must be refused (see [refusedImportSetting]).
  final String? refusedKey;

  /// Sanitised accounts: client certificates dropped, audio refs validated;
  /// auto-answer / auto-record still set (see [resolve]).
  final List<AccountProfile> accounts;

  /// Settings that apply once the user confirms.
  final Map<String, dynamic> safeSettings;

  /// Settings that apply only when auto-answer is ticked.
  final Map<String, dynamic> autoAnswerSettings;

  /// Settings that apply only when automatic recording is ticked.
  final Map<String, dynamic> autoRecordSettings;
  final List<ImportFlag> flags;

  /// Everything dropped: `key` or `accounts[i].field`.
  final List<String> ignored;
  final List<String> warnings;

  bool get hasAutoAnswer =>
      flags.any((f) => f.kind == ImportFlagKind.autoAnswer);
  bool get hasAutoRecord =>
      flags.any((f) => f.kind == ImportFlagKind.autoRecord);

  /// Number of settings that would be applied with everything ticked.
  int get settingCount =>
      safeSettings.length +
      autoAnswerSettings.length +
      autoRecordSettings.length;
  bool get isEmpty => accounts.isEmpty && settingCount == 0;

  /// The accounts / settings to apply for [d]; risky features stay off unless ticked.
  ProvisioningResult resolve(ImportDecision d) {
    return ProvisioningResult(
      accounts: [
        for (final a in accounts)
          a.copyWith(
            autoAnswer: d.allowAutoAnswer || !a.autoAnswer.enabled
                ? a.autoAnswer
                : a.autoAnswer.copyWith(enabled: false),
            autoRecord: d.allowAutoRecord || a.autoRecord != 'always'
                ? a.autoRecord
                : 'inherit',
          ),
      ],
      settings: {
        ...safeSettings,
        if (d.allowAutoAnswer) ...autoAnswerSettings,
        if (d.allowAutoRecord) ...autoRecordSettings,
      },
      warnings: warnings,
    );
  }
}

/// THE gate for untrusted configuration: classifies every setting against
/// [kSettingImportPolicy], sanitises accounts and collects the warnings the
/// dialog must show. Pure; applies nothing.
ImportPlan prepareUntrustedImport(ProvisioningResult r) {
  final refused = refusedImportSetting(r.settings);
  final ignored = <String>[];
  final safe = <String, dynamic>{};
  final aaSet = <String, dynamic>{};
  final arSet = <String, dynamic>{};
  final flags = <ImportFlag>[];
  void flag(ImportFlag f) {
    if (f.kind == ImportFlagKind.forwarding ||
        !flags.any((x) => x.kind == f.kind))
      flags.add(f);
  }

  for (final e in r.settings.entries) {
    final k = e.key;
    final v = e.value;
    final c = classifyImportSetting(k);
    if (c == ImportClass.forbidden ||
        c == ImportClass.refused ||
        !_validImportValue(k, v)) {
      ignored.add(k);
      continue;
    }
    switch (k) {
      case 'autoAnswer' || 'autoAnswerDelay':
        if (k == 'autoAnswer' && v != true) {
          safe[k] = v; // turning it off is always fine
        } else if (k == 'autoAnswer') {
          aaSet[k] = v;
          flag(const ImportFlag(ImportFlagKind.autoAnswer));
        } else {
          aaSet[k] = v;
        }
      case 'autoRecord' || 'recordRule':
        final on = k == 'autoRecord' ? v == true : (v != 'off' && v != null);
        if (on) {
          arSet[k] = v;
          flag(const ImportFlag(ImportFlagKind.autoRecord));
        } else {
          safe[k] = v;
        }
      case 'recordAutoDeleteDays':
        safe[k] = v;
        if (v is num && v > 0)
          flag(const ImportFlag(ImportFlagKind.recordingDeletion));
      case 'lanAllowIntercom' || 'lanAllowPull':
        safe[k] = v;
        if (v == true) flag(const ImportFlag(ImportFlagKind.intercom));
      case 'lanIntercomPrompt':
        safe[k] = v;
        if (v == false) flag(const ImportFlag(ImportFlagKind.intercom));
      case 'dialRules' ||
          'stripPrefix' ||
          'plusReplacement' ||
          'defaultCountryPrefix':
        safe[k] = v;
        if (_nonEmpty(v)) flag(const ImportFlag(ImportFlagKind.dialRewrite));
      case 'syncFeatureCodes':
        safe[k] = v;
        if (v == true) flag(const ImportFlag(ImportFlagKind.featureCodes));
      case 'callLinksImmediately':
        safe[k] = v;
        if (v == true) flag(const ImportFlag(ImportFlagKind.linksImmediately));
      case 'sipTrace':
        safe[k] = v;
        if (v == true) flag(const ImportFlag(ImportFlagKind.diagnostics));
      case 'logLevel':
        safe[k] = v;
        flag(const ImportFlag(ImportFlagKind.diagnostics));
      case 'blocklist':
        safe[k] = v;
        flag(const ImportFlag(ImportFlagKind.blocklist));
      case 'emergencyNumbers':
        safe[k] = v;
        flag(const ImportFlag(ImportFlagKind.emergencyNumbers));
      case 'speedDial':
        safe[k] = v;
        flag(const ImportFlag(ImportFlagKind.speedDial));
      default:
        safe[k] = v;
    }
  }

  const defaultCodes = FeatureCodes();
  final accounts = <AccountProfile>[];
  for (var i = 0; i < r.accounts.length; i++) {
    var a = r.accounts[i];
    if (a.config.tlsClientCert != null) {
      ignored.add('accounts[$i].tlsClientCert');
      a = a.copyWith(
        config: AccountConfig.fromJson(
          a.config.toJson()..remove('tlsClientCert'),
        ),
      );
    }
    if (!_safeAudioRef(a.ringtone, const {'default'})) {
      ignored.add('accounts[$i].ringtone');
      a = a.copyWith(ringtone: 'default');
    }
    if (!_safeAudioRef(a.holdMusic, const {'inherit', 'pbx'})) {
      ignored.add('accounts[$i].holdMusic');
      a = a.copyWith(holdMusic: 'inherit');
    }
    if (!_safeAudioRef(a.openingAnnouncement, const {'inherit', 'off'})) {
      ignored.add('accounts[$i].openingAnnouncement');
      a = a.copyWith(openingAnnouncement: 'inherit');
    }
    if (!const {'inherit', 'always', 'never'}.contains(a.autoRecord))
      a = a.copyWith(autoRecord: 'inherit');
    if (a.autoAnswer.enabled) flag(const ImportFlag(ImportFlagKind.autoAnswer));
    if (a.autoRecord == 'always')
      flag(const ImportFlag(ImportFlagKind.autoRecord));
    if (a.forwarding.active)
      flag(ImportFlag(ImportFlagKind.forwarding, a.forwarding.target));
    if (a.featureCodes.toJson().toString() !=
        defaultCodes.toJson().toString()) {
      flag(const ImportFlag(ImportFlagKind.featureCodes));
    }
    accounts.add(a);
  }

  return ImportPlan._(
    refusedKey: refused,
    accounts: accounts,
    safeSettings: safe,
    autoAnswerSettings: aaSet,
    autoRecordSettings: arSet,
    flags: flags,
    ignored: ignored,
    warnings: r.warnings,
  );
}
