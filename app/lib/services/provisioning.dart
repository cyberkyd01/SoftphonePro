import 'dart:convert';
import 'dart:ui' show Locale;

import 'package:http/http.dart' as http;
import 'package:spcore_dart/spcore_dart.dart';
import 'package:uuid/uuid.dart';

import '../l10n/l10n.dart';
import '../models/account_profile.dart';
import '../models/provider_templates.dart';

class ProvisioningException implements Exception {
  ProvisioningException(this.message);
  final String message;
  @override
  String toString() => message;
}

class ProvisioningResult {
  const ProvisioningResult({
    this.accounts = const [],
    this.settings = const {},
    this.warnings = const [],
  });
  final List<AccountProfile> accounts;
  final Map<String, dynamic> settings;
  final List<String> warnings;
}

/// Import/export of provisioning JSON:
/// `{version, accounts: [...], settings: {...}}`.
///
/// Account entries are either full exports (with a `sip` object) or flat
/// objects (`username`, `password`, `domain`, `transport`, ...). `${VAR}`
/// placeholders in any string are substituted from the supplied variables.
class Provisioning {
  static const int version = 1;
  static final RegExp _var = RegExp(r'\$\{([A-Za-z_][A-Za-z0-9_]*)(?::-([^}]*))?\}');

  static dynamic substitute(dynamic v, Map<String, String> vars) {
    if (v is String) {
      return v.replaceAllMapped(_var, (m) => vars[m[1]!] ?? m[2] ?? '');
    }
    if (v is List) return [for (final e in v) substitute(e, vars)];
    if (v is Map) {
      return {for (final e in v.entries) e.key: substitute(e.value, vars)};
    }
    return v;
  }

  static ProvisioningResult parse(
    String text, {
    Map<String, String> vars = const {},
    Uuid? uuid,
    AppLocalizations? l10n,
  }) {
    final l = l10n ?? lookupAppLocalizations(const Locale('en'));
    final dynamic raw;
    try {
      raw = jsonDecode(text);
    } on FormatException catch (e) {
      throw ProvisioningException(l.provisioningNotValidJson(e.message));
    }
    if (raw is! Map) {
      throw ProvisioningException(l.provisioningExpectedObject);
    }
    final root = Map<String, dynamic>.from(substitute(raw, vars) as Map);
    final v = root['version'];
    if (v is num && v > version) {
      throw ProvisioningException(l.provisioningUnsupportedVersion('$v'));
    }
    final warnings = <String>[];
    final accounts = <AccountProfile>[];
    const gen = Uuid();
    for (final a in (root['accounts'] as List? ?? const [])) {
      if (a is! Map) {
        warnings.add(l.provisioningSkippedAccountEntry);
        continue;
      }
      try {
        accounts.add(_account(Map<String, dynamic>.from(a), uuid ?? gen, l));
      } on ProvisioningException catch (e) {
        warnings.add(e.message);
      }
    }
    final settings = root['settings'] is Map
        ? Map<String, dynamic>.from(root['settings'] as Map)
        : <String, dynamic>{};
    if (accounts.isEmpty && settings.isEmpty) {
      warnings.add(l.provisioningNothingToImport);
    }
    return ProvisioningResult(
      accounts: accounts,
      settings: settings,
      warnings: warnings,
    );
  }

  static AccountProfile _account(Map<String, dynamic> a, Uuid uuid, AppLocalizations l) {
    final id = uuid.v4();
    if (a['sip'] is Map) {
      return AccountProfile.fromJson(a, newId: id).copyWith(isDefault: false);
    }
    final username = '${a['username'] ?? ''}';
    final domain = '${a['domain'] ?? a['server'] ?? ''}';
    if (username.isEmpty || domain.isEmpty) {
      throw ProvisioningException(
        l.provisioningAccountNeedsUserDomain('${a['label'] ?? a['username'] ?? '?'}'),
      );
    }
    final t = templateById('${a['template'] ?? 'generic'}');
    var p = t.build(
      id: id,
      username: username,
      password: '${a['password'] ?? ''}',
      domain: domain,
      displayName: '${a['displayName'] ?? ''}',
      label: '${a['label'] ?? ''}',
      authUser: a['authUser'] as String?,
    );
    var c = p.config;
    if (a['transport'] != null) {
      c = c.copyWith(transport: AccTransport.parse(a['transport']));
    }
    final proxies = a['proxies'] ?? a['proxy'];
    if (proxies is List) {
      c = c.copyWith(proxies: [for (final e in proxies) '$e']);
    } else if (proxies is String && proxies.isNotEmpty) {
      c = c.copyWith(proxies: [proxies]);
    }
    if (a['registrar'] is String) c = c.copyWith(registrar: a['registrar'] as String);
    if (a['srtp'] != null) c = c.copyWith(srtp: SrtpMode.parse(a['srtp']));
    if (a['codecs'] is List) {
      c = c.copyWith(codecs: [for (final e in a['codecs'] as List) '$e']);
    }
    if (a['voicemail'] != null || a['voicemailNumber'] != null) {
      p = p.copyWith(
        voicemailNumber: '${a['voicemail'] ?? a['voicemailNumber']}',
      );
    }
    return p.copyWith(config: c);
  }

  static Future<ProvisioningResult> fetch(
    Uri url, {
    Map<String, String> vars = const {},
    http.Client? client,
    AppLocalizations? l10n,
  }) async {
    final l = l10n ?? lookupAppLocalizations(const Locale('en'));
    final c = client ?? http.Client();
    try {
      final r = await c.get(url).timeout(const Duration(seconds: 15));
      if (r.statusCode != 200) {
        throw ProvisioningException(l.provisioningServerAnswered(r.statusCode));
      }
      return parse(utf8.decode(r.bodyBytes), vars: vars, l10n: l);
    } on ProvisioningException {
      rethrow;
    } catch (e) {
      throw ProvisioningException(l.provisioningDownloadFailed('$e'));
    } finally {
      if (client == null) c.close();
    }
  }

  static String export(
    List<AccountProfile> accounts,
    Map<String, dynamic> settings, {
    bool includePasswords = false,
  }) {
    return const JsonEncoder.withIndent('  ').convert({
      'version': version,
      'accounts': [
        for (final a in accounts) a.toJson(includePassword: includePasswords),
      ],
      'settings': settings,
    });
  }
}
