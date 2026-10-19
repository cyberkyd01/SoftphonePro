/// Pure-Dart dial plan: normalises what the user typed into what is dialled.
class DialRule {
  const DialRule({
    required this.id,
    this.name = '',
    this.enabled = true,
    required this.pattern,
    this.replacement = r'$0',
    this.accountId = '',
  });

  final String id;
  final String name;
  final bool enabled;

  /// Regular expression matched against the whole number (anchored).
  final String pattern;

  /// Replacement; `$1`..`$9` refer to groups, `$0` to the whole match.
  final String replacement;

  /// When set, a matching call is routed through this account profile id.
  final String accountId;

  DialRule copyWith({
    String? name,
    bool? enabled,
    String? pattern,
    String? replacement,
    String? accountId,
  }) => DialRule(
    id: id,
    name: name ?? this.name,
    enabled: enabled ?? this.enabled,
    pattern: pattern ?? this.pattern,
    replacement: replacement ?? this.replacement,
    accountId: accountId ?? this.accountId,
  );

  /// Tolerant: a value of the wrong type takes its default, never throws.
  factory DialRule.fromJson(Map<String, dynamic> j) {
    String str(String k, String d) => j[k] is String ? j[k] as String : d;
    return DialRule(
      id: str('id', ''),
      name: str('name', ''),
      enabled: j['enabled'] != false,
      pattern: str('pattern', ''),
      replacement: str('replacement', r'$0'),
      accountId: str('accountId', ''),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'enabled': enabled,
    'pattern': pattern,
    'replacement': replacement,
    'accountId': accountId,
  };
}

class DialResult {
  const DialResult(
    this.target, {
    this.accountId,
    this.emergency = false,
    this.ruleId,
    this.isUri = false,
  });

  /// What to hand to the engine (a number, `user@host` or a full URI).
  final String target;

  /// Account the matching rule routes through, if any.
  final String? accountId;
  final bool emergency;
  final String? ruleId;
  final bool isUri;

  @override
  String toString() => 'DialResult($target, acc: $accountId, rule: $ruleId)';
}

class DialRules {
  const DialRules({
    this.rules = const [],
    this.emergencyNumbers = const ['911', '112', '999', '000'],
    this.plusReplacement,
    this.stripPrefix = '',
    this.defaultCountryPrefix = '',
  });

  final List<DialRule> rules;
  final List<String> emergencyNumbers;

  /// If not null, a leading `+` is replaced by this (e.g. `00`).
  final String? plusReplacement;

  /// Prefix removed from the start of every number before rules (e.g. `9`).
  final String stripPrefix;

  /// Added in place of the trunk `0` of national numbers (e.g. `+44`).
  final String defaultCountryPrefix;

  static final RegExp _uriLike = RegExp(
    r'^(sips?:|tel:|callto:)|@',
    caseSensitive: false,
  );

  /// Removes visual separators; keeps digits, `+ * #` and letters.
  static String clean(String input) {
    var s = input.trim();
    if (_uriLike.hasMatch(s) || RegExp(r'[A-Za-z]{2,}').hasMatch(s)) return s;
    return s.replaceAll(RegExp(r'[\s\-\.\(\) /]'), '');
  }

  DialResult apply(String input) {
    var s = input.trim();
    if (s.isEmpty) return const DialResult('');
    final lower = s.toLowerCase();
    if (lower.startsWith('tel:') || lower.startsWith('callto:')) {
      s = s.substring(s.indexOf(':') + 1);
    } else if (_uriLike.hasMatch(s)) {
      return DialResult(s, isUri: true);
    }
    s = clean(s);
    if (s.isEmpty) return const DialResult('');
    if (emergencyNumbers.contains(s)) {
      return DialResult(s, emergency: true);
    }
    if (stripPrefix.isNotEmpty && s.startsWith(stripPrefix) && s.length > 4) {
      s = s.substring(stripPrefix.length);
    }
    if (defaultCountryPrefix.isNotEmpty &&
        s.length > 4 &&
        s.startsWith('0') &&
        !s.startsWith('00') &&
        RegExp(r'^\d+$').hasMatch(s)) {
      s = defaultCountryPrefix + s.substring(1);
    }
    if (plusReplacement != null && plusReplacement!.isNotEmpty && s.startsWith('+')) {
      s = plusReplacement! + s.substring(1);
    }
    for (final r in rules) {
      if (!r.enabled || r.pattern.isEmpty) continue;
      RegExp re;
      try {
        re = RegExp('^(?:${r.pattern})\$');
      } on FormatException {
        continue;
      }
      final m = re.firstMatch(s);
      if (m == null) continue;
      final out = r.replacement.replaceAllMapped(RegExp(r'\$(\d)'), (g) {
        final n = int.parse(g[1]!);
        if (n == 0) return m[0] ?? '';
        return n <= m.groupCount ? (m[n] ?? '') : '';
      });
      return DialResult(
        out,
        accountId: r.accountId.isEmpty ? null : r.accountId,
        ruleId: r.id,
      );
    }
    return DialResult(s);
  }

  /// Validates a pattern; returns an error text or null.
  static String? validatePattern(String pattern) {
    try {
      RegExp(pattern);
      return null;
    } on FormatException catch (e) {
      return e.message;
    }
  }
}
