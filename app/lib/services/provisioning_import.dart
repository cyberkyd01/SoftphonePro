// ignore_for_file: curly_braces_in_flow_control_structures
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show ProviderListenable;
import 'package:http/http.dart' as http;

import '../l10n/l10n.dart';
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

/// True when [a] and [b] are the same account: same protocol, username,
/// domain and registrar (hosts compared case-insensitively).
bool sameAccountIdentity(AccountProfile a, AccountProfile b) {
  String host(String? v) => (v ?? '').trim().toLowerCase();
  final x = a.config, y = b.config;
  return x.proto == y.proto &&
      x.username == y.username &&
      host(x.domain) == host(y.domain) &&
      host(x.registrar) == host(y.registrar);
}

/// The existing account that [incoming] would update, or null when it is new.
AccountProfile? matchingAccount(
  Iterable<AccountProfile> existing,
  AccountProfile incoming,
) {
  for (final e in existing) {
    if (sameAccountIdentity(e, incoming)) return e;
  }
  return null;
}

/// How many of [incoming] update an existing account and how many are added.
({int updated, int added}) countImportMatches(
  Iterable<AccountProfile> existing,
  Iterable<AccountProfile> incoming,
) {
  final pool = [...existing];
  var updated = 0, added = 0;
  for (final a in incoming) {
    if (matchingAccount(pool, a) != null) {
      updated++;
    } else {
      added++;
      pool.add(a);
    }
  }
  return (updated: updated, added: added);
}

/// [incoming] merged onto [existing]: keeps its id (history links), default
/// flag and, unless the import carries one, its password.
AccountProfile mergeIntoExisting(AccountProfile existing, AccountProfile incoming) {
  final pw = incoming.config.password.isEmpty
      ? existing.config.password
      : incoming.config.password;
  return AccountProfile(
    id: existing.id,
    config: incoming.config.copyWith(uid: existing.id, password: pw),
    enabled: incoming.enabled,
    isDefault: existing.isDefault,
    label: incoming.label,
    color: incoming.color,
    voicemailNumber: incoming.voicemailNumber,
    featureCodes: incoming.featureCodes,
    dnd: incoming.dnd,
    autoAnswer: incoming.autoAnswer,
    forwarding: incoming.forwarding,
    ringtone: incoming.ringtone,
    dialRuleSetId: incoming.dialRuleSetId,
    providerTemplateId: incoming.providerTemplateId,
    backupRegistrar: incoming.backupRegistrar,
    autoRecord: incoming.autoRecord,
    holdMusic: incoming.holdMusic,
    openingAnnouncement: incoming.openingAnnouncement,
  );
}

Future<int> _applyImport(
  Reader read, {
  required List<AccountProfile> accounts,
  required Map<String, dynamic> settings,
}) async {
  final notifier = read(accountsProvider.notifier);
  for (final a in accounts) {
    final existing = matchingAccount(read(accountsProvider).profiles, a);
    if (existing != null) {
      await notifier.update(mergeIntoExisting(existing, a));
    } else {
      await notifier.add(a);
    }
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
      return v is List && v.length <= 64 && v.every((e) => e is Map && e['pattern'] is String);
    case 'speedDial':
      return v is Map &&
          v.length <= 9 &&
          v.values.every((e) => e is Map && e['number'] is String);
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

/// Removes invalid ENTRIES of list / map settings (wrong types, oversize),
/// recording each as `key[i]` / `key.slot` in [ignored]. Returns [v] unchanged
/// for other keys. A non-empty list whose entries are all invalid becomes
/// null (the whole key is then dropped, so it cannot blank a safe default).
Object? _cleanNested(String k, Object? v, List<String> ignored) {
  bool str(Object? x, int max) => x is String && x.length <= max;
  bool optStr(Map m, String f, int max) => !m.containsKey(f) || m[f] == null || str(m[f], max);
  switch (k) {
    case 'blocklist' || 'emergencyNumbers' || 'codecOrder' || 'codecsDisabled':
      if (v is! List || v.length > 256) return v;
      final out = <Object?>[];
      for (var i = 0; i < v.length; i++) {
        if (str(v[i], 128)) {
          out.add(v[i]);
        } else {
          ignored.add('$k[$i]');
        }
      }
      return out.isEmpty && v.isNotEmpty ? null : out;
    case 'dialRules':
      if (v is! List || v.length > 64) return v;
      final out = <Object?>[];
      for (var i = 0; i < v.length; i++) {
        final r = v[i];
        final ok = r is Map &&
            r.keys.every((x) => x is String) &&
            str(r['pattern'], 256) &&
            optStr(r, 'id', 128) &&
            optStr(r, 'name', 128) &&
            optStr(r, 'replacement', 256) &&
            optStr(r, 'accountId', 128) &&
            (!r.containsKey('enabled') || r['enabled'] is bool);
        if (ok) {
          out.add(r);
        } else {
          ignored.add('$k[$i]');
        }
      }
      return out.isEmpty && v.isNotEmpty ? null : out;
    case 'speedDial':
      if (v is! Map || v.length > 9) return v;
      final out = <String, Object?>{};
      for (final e in v.entries) {
        final slot = int.tryParse('${e.key}');
        final x = e.value;
        final ok = slot != null &&
            slot >= 1 &&
            slot <= 9 &&
            x is Map &&
            str(x['number'], 64) &&
            optStr(x, 'label', 128) &&
            optStr(x, 'accountId', 128);
        if (ok) {
          out['${e.key}'] = x;
        } else {
          ignored.add('$k.${e.key}');
        }
      }
      return out.isEmpty && v.isNotEmpty ? null : out;
  }
  return v;
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

// ---- per-account field policy ----------------------------------------------

enum AccountFieldPolicy {
  /// Applied as imported.
  allowed,

  /// Applied, but the dialog shows it (some only once a checkbox is ticked).
  flagged,

  /// Applied only after its value passes a check (audio refs); else reset.
  validated,

  /// Reset to the field's default and listed as "ignored".
  dropped,
}

const _aa = AccountFieldPolicy.allowed;
const _af = AccountFieldPolicy.flagged;
const _av = AccountFieldPolicy.validated;
const _ad = AccountFieldPolicy.dropped;

/// Classification of EVERY `AccountProfile` field (`name`) and nested field
/// (`parent.name`), and of every `AccountConfig` JSON key (`sip.name`).
/// Anything not listed is [AccountFieldPolicy.dropped]
/// (test/provisioning_trust_test.dart enforces completeness).
const Map<String, AccountFieldPolicy> kAccountImportPolicy = {
  'id': _aa, 'enabled': _aa, 'isDefault': _aa, 'label': _aa, 'color': _aa,
  'voicemailNumber': _aa, 'dnd': _aa, 'dialRuleSetId': _aa,
  'providerTemplateId': _aa, 'backupRegistrar': _aa,
  'featureCodes': _af,
  'featureCodes.park': _af, 'featureCodes.pickupGroup': _af,
  'featureCodes.pickupDirectedPrefix': _af, 'featureCodes.dndOn': _af,
  'featureCodes.dndOff': _af, 'featureCodes.forwardOn': _af,
  'featureCodes.forwardOff': _af, 'featureCodes.parkRetrieve': _af,
  'autoAnswer': _af,
  'autoAnswer.enabled': _af, 'autoAnswer.delaySec': _af,
  'autoAnswer.onlyIntercomHeaders': _af,
  'forwarding': _af,
  'forwarding.mode': _af, 'forwarding.target': _af,
  'forwarding.noAnswerSec': _af,
  'autoRecord': _af,
  'ringtone': _av, 'holdMusic': _av, 'openingAnnouncement': _av,
  'sip': _aa,
  // AccountConfig: the account itself is what the user consents to (server,
  // transport, media, NAT); only a client certificate path is a local file.
  'sip.uid': _aa, 'sip.proto': _aa, 'sip.displayName': _aa,
  'sip.username': _aa, 'sip.authUser': _aa, 'sip.password': _aa,
  'sip.domain': _aa, 'sip.registrar': _aa, 'sip.proxies': _aa,
  'sip.regUseProxy': _aa, 'sip.transport': _aa, 'sip.register': _aa,
  'sip.regExpires': _aa, 'sip.regRetrySec': _aa, 'sip.regFirstRetrySec': _aa,
  'sip.regRetryRandomSec': _aa, 'sip.regDelayBeforeRefreshSec': _aa,
  'sip.unregTimeoutMs': _aa, 'sip.dropCallsOnRegFail': _aa,
  'sip.keepAliveSec': _aa, 'sip.localPort': _aa, 'sip.contactUseSrcPort': _aa,
  'sip.publishPresence': _aa, 'sip.mwi': _aa, 'sip.mwiExpires': _aa,
  'sip.watcherPolicy': _aa, 'sip.referPolicy': _aa, 'sip.redirect': _aa,
  'sip.srtp': _aa, 'sip.srtpSecureSignaling': _aa, 'sip.srtpKeying': _aa,
  'sip.srtpCryptos': _aa, 'sip.ice': _aa, 'sip.rtcpMux': _aa, 'sip.turn': _aa,
  'sip.useStun': _aa, 'sip.contactRewrite': _aa, 'sip.viaRewrite': _aa,
  'sip.sdpNatRewrite': _aa, 'sip.sipOutbound': _aa, 'sip.sessionTimers': _aa,
  'sip.timerSe': _aa, 'sip.use100rel': _aa, 'sip.holdType': _aa,
  'sip.lockCodec': _aa, 'sip.streamKeepAlive': _aa, 'sip.dtmfMethod': _aa,
  'sip.codecs': _aa, 'sip.callerId': _aa, 'sip.privacy': _aa,
  'sip.headers': _aa, 'sip.userAgent': _aa, 'sip.authAlgorithm': _aa,
  'sip.ipv6Sip': _aa, 'sip.ipv6Media': _aa, 'sip.ipChange': _aa,
  'sip.dscp': _aa, 'sip.voicemailNumber': _aa, 'sip.iax': _aa,
  'sip.wsPath': _aa, 'sip.rtcpFb': _aa,
  'sip.tlsClientCert': _ad,
};

/// The class of account field [path]; unlisted fields are dropped.
AccountFieldPolicy classifyAccountField(String path) =>
    kAccountImportPolicy[path] ?? AccountFieldPolicy.dropped;

/// Applies [kAccountImportPolicy] to an untrusted account: every `dropped`
/// (or unlisted) field is removed and takes its default. Dropped fields that
/// carried a non-default value are recorded in [ignored] as `prefix.field`.
AccountProfile _applyAccountPolicy(
  AccountProfile a,
  String prefix,
  List<String> ignored,
) {
  final j = a.toJson(includePassword: true);
  final removed = <String>[];
  void strip(Map<String, dynamic> m, String path) {
    for (final k in m.keys.toList()) {
      final p = path.isEmpty ? k : '$path.$k';
      if (classifyAccountField(p) == AccountFieldPolicy.dropped) {
        m.remove(k);
        removed.add(p);
      } else if (m[k] is Map &&
          kAccountImportPolicy.keys.any((x) => x.startsWith('$p.'))) {
        final child = Map<String, dynamic>.from(m[k] as Map);
        strip(child, p);
        m[k] = child;
      }
    }
  }

  strip(j, '');
  final out = AccountProfile.fromJson(j, newId: a.id);
  final before = a.toJson(includePassword: true);
  final after = out.toJson(includePassword: true);
  for (final p in removed) {
    final parts = p.split('.');
    Object? x = before, y = after;
    for (final s in parts) {
      x = x is Map ? x[s] : null;
      y = y is Map ? y[s] : null;
    }
    if ('$x' != '$y') ignored.add('$prefix.${parts.last}');
  }
  return out;
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
    final c = classifyImportSetting(k);
    if (c == ImportClass.forbidden || c == ImportClass.refused) {
      ignored.add(k);
      continue;
    }
    final v = _cleanNested(k, e.value, ignored);
    if (!_validImportValue(k, v)) {
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
    var a = _applyAccountPolicy(r.accounts[i], 'accounts[$i]', ignored);
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
