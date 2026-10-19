import 'package:spcore_dart/spcore_dart.dart';

/// Feature codes (star codes) of the PBX, used for park/pickup/DND/forward.
class FeatureCodes {
  const FeatureCodes({
    this.park = '*85',
    this.pickupGroup = '*8',
    this.pickupDirectedPrefix = '**',
    this.dndOn = '*78',
    this.dndOff = '*79',
    this.forwardOn = '*72',
    this.forwardOff = '*73',
    this.parkRetrieve = '',
  });

  final String park;
  final String pickupGroup;
  final String pickupDirectedPrefix;
  final String dndOn;
  final String dndOff;
  final String forwardOn;
  final String forwardOff;

  /// Prefix dialled before the park slot to retrieve a parked call (empty =
  /// dial the slot number itself).
  final String parkRetrieve;

  factory FeatureCodes.fromJson(Map<String, dynamic> j) {
    const d = FeatureCodes();
    String s(String k, String def) => j[k] is String ? j[k] as String : def;
    return FeatureCodes(
      park: s('park', d.park),
      pickupGroup: s('pickupGroup', d.pickupGroup),
      pickupDirectedPrefix: s('pickupDirectedPrefix', d.pickupDirectedPrefix),
      dndOn: s('dndOn', d.dndOn),
      dndOff: s('dndOff', d.dndOff),
      forwardOn: s('forwardOn', d.forwardOn),
      forwardOff: s('forwardOff', d.forwardOff),
      parkRetrieve: s('parkRetrieve', d.parkRetrieve),
    );
  }

  Map<String, dynamic> toJson() => {
    'park': park,
    'pickupGroup': pickupGroup,
    'pickupDirectedPrefix': pickupDirectedPrefix,
    'dndOn': dndOn,
    'dndOff': dndOff,
    'forwardOn': forwardOn,
    'forwardOff': forwardOff,
    'parkRetrieve': parkRetrieve,
  };

  FeatureCodes copyWith({
    String? park,
    String? pickupGroup,
    String? pickupDirectedPrefix,
    String? dndOn,
    String? dndOff,
    String? forwardOn,
    String? forwardOff,
    String? parkRetrieve,
  }) => FeatureCodes(
    park: park ?? this.park,
    pickupGroup: pickupGroup ?? this.pickupGroup,
    pickupDirectedPrefix: pickupDirectedPrefix ?? this.pickupDirectedPrefix,
    dndOn: dndOn ?? this.dndOn,
    dndOff: dndOff ?? this.dndOff,
    forwardOn: forwardOn ?? this.forwardOn,
    forwardOff: forwardOff ?? this.forwardOff,
    parkRetrieve: parkRetrieve ?? this.parkRetrieve,
  );
}

class AutoAnswerConfig {
  const AutoAnswerConfig({
    this.enabled = false,
    this.delaySec = 0,
    this.onlyIntercomHeaders = false,
  });

  final bool enabled;
  final int delaySec;

  /// Auto-answer only when the INVITE carries an auto-answer header hint.
  final bool onlyIntercomHeaders;

  factory AutoAnswerConfig.fromJson(Map<String, dynamic> j) => AutoAnswerConfig(
    enabled: j['enabled'] == true,
    delaySec: (j['delaySec'] as num?)?.toInt() ?? 0,
    onlyIntercomHeaders: j['onlyIntercomHeaders'] == true,
  );

  Map<String, dynamic> toJson() => {
    'enabled': enabled,
    'delaySec': delaySec,
    'onlyIntercomHeaders': onlyIntercomHeaders,
  };

  AutoAnswerConfig copyWith({
    bool? enabled,
    int? delaySec,
    bool? onlyIntercomHeaders,
  }) => AutoAnswerConfig(
    enabled: enabled ?? this.enabled,
    delaySec: delaySec ?? this.delaySec,
    onlyIntercomHeaders: onlyIntercomHeaders ?? this.onlyIntercomHeaders,
  );
}

enum ForwardMode { off, always, busy, noAnswer }

class ForwardingConfig {
  const ForwardingConfig({
    this.mode = ForwardMode.off,
    this.target = '',
    this.noAnswerSec = 20,
  });

  final ForwardMode mode;
  final String target;
  final int noAnswerSec;

  bool get active => mode != ForwardMode.off && target.trim().isNotEmpty;

  factory ForwardingConfig.fromJson(Map<String, dynamic> j) => ForwardingConfig(
    mode: ForwardMode.values.firstWhere(
      (m) => m.name == j['mode'],
      orElse: () => ForwardMode.off,
    ),
    target: j['target'] as String? ?? '',
    noAnswerSec: (j['noAnswerSec'] as num?)?.toInt() ?? 20,
  );

  Map<String, dynamic> toJson() => {
    'mode': mode.name,
    'target': target,
    'noAnswerSec': noAnswerSec,
  };

  ForwardingConfig copyWith({
    ForwardMode? mode,
    String? target,
    int? noAnswerSec,
  }) => ForwardingConfig(
    mode: mode ?? this.mode,
    target: target ?? this.target,
    noAnswerSec: noAnswerSec ?? this.noAnswerSec,
  );
}

/// A persisted account: the engine's [AccountConfig] plus app-only fields.
/// `config.uid` always equals [id].
class AccountProfile {
  const AccountProfile({
    required this.id,
    required this.config,
    this.enabled = true,
    this.isDefault = false,
    this.label = '',
    this.color = 0xFF3F51E0,
    this.voicemailNumber = '',
    this.featureCodes = const FeatureCodes(),
    this.dnd = false,
    this.autoAnswer = const AutoAnswerConfig(),
    this.forwarding = const ForwardingConfig(),
    this.ringtone = 'default',
    this.dialRuleSetId = '',
    this.providerTemplateId = 'generic',
    this.backupRegistrar = '',
    this.autoRecord = 'inherit',
    this.holdMusic = 'inherit',
    this.openingAnnouncement = 'inherit',
  });

  final String id;
  final AccountConfig config;
  final bool enabled;
  final bool isDefault;
  final String label;
  final int color;
  final String voicemailNumber;
  final FeatureCodes featureCodes;
  final bool dnd;
  final AutoAnswerConfig autoAnswer;
  final ForwardingConfig forwarding;
  final String ringtone;
  final String dialRuleSetId;
  final String providerTemplateId;

  /// Backup registrar (`host[:port]` or sip: URI) used after repeated failures.
  final String backupRegistrar;

  /// Per-account auto-record: `inherit` (global setting), `always`, `never`.
  final String autoRecord;

  /// Music on hold override: `inherit`, `pbx` (plain hold) or an audio ref
  /// (`builtin:<id>` / `lib:<file>`, see lib/audio/audio_library.dart).
  final String holdMusic;

  /// Opening announcement override: `inherit`, `off` or an audio ref.
  final String openingAnnouncement;

  /// Name shown in chips and selectors.
  String get name {
    if (label.trim().isNotEmpty) return label.trim();
    if (config.displayName.trim().isNotEmpty) return config.displayName.trim();
    if (config.username.isNotEmpty) {
      return '${config.username}@${config.domain}';
    }
    return 'Account';
  }

  String get address => '${config.username}@${config.domain}';

  String get effectiveVoicemail =>
      voicemailNumber.isNotEmpty
          ? voicemailNumber
          : (config.voicemailNumber ?? '');

  AccountProfile copyWith({
    AccountConfig? config,
    bool? enabled,
    bool? isDefault,
    String? label,
    int? color,
    String? voicemailNumber,
    FeatureCodes? featureCodes,
    bool? dnd,
    AutoAnswerConfig? autoAnswer,
    ForwardingConfig? forwarding,
    String? ringtone,
    String? dialRuleSetId,
    String? providerTemplateId,
    String? backupRegistrar,
    String? autoRecord,
    String? holdMusic,
    String? openingAnnouncement,
  }) => AccountProfile(
    id: id,
    config: (config ?? this.config).copyWith(uid: id),
    enabled: enabled ?? this.enabled,
    isDefault: isDefault ?? this.isDefault,
    label: label ?? this.label,
    color: color ?? this.color,
    voicemailNumber: voicemailNumber ?? this.voicemailNumber,
    featureCodes: featureCodes ?? this.featureCodes,
    dnd: dnd ?? this.dnd,
    autoAnswer: autoAnswer ?? this.autoAnswer,
    forwarding: forwarding ?? this.forwarding,
    ringtone: ringtone ?? this.ringtone,
    dialRuleSetId: dialRuleSetId ?? this.dialRuleSetId,
    providerTemplateId: providerTemplateId ?? this.providerTemplateId,
    backupRegistrar: backupRegistrar ?? this.backupRegistrar,
    autoRecord: autoRecord ?? this.autoRecord,
    holdMusic: holdMusic ?? this.holdMusic,
    openingAnnouncement: openingAnnouncement ?? this.openingAnnouncement,
  );

  /// JSON for persistence. The password is never included unless
  /// [includePassword] is set (exports).
  Map<String, dynamic> toJson({bool includePassword = false}) {
    final sip = config.toJson();
    if (!includePassword) sip['password'] = '';
    return {
      'id': id,
      'enabled': enabled,
      'isDefault': isDefault,
      'label': label,
      'color': color,
      'voicemailNumber': voicemailNumber,
      'featureCodes': featureCodes.toJson(),
      'dnd': dnd,
      'autoAnswer': autoAnswer.toJson(),
      'forwarding': forwarding.toJson(),
      'ringtone': ringtone,
      'dialRuleSetId': dialRuleSetId,
      'providerTemplateId': providerTemplateId,
      'backupRegistrar': backupRegistrar,
      'autoRecord': autoRecord,
      'holdMusic': holdMusic,
      'openingAnnouncement': openingAnnouncement,
      'sip': sip,
    };
  }

  factory AccountProfile.fromJson(Map<String, dynamic> j, {String? newId}) {
    final id = newId ?? (j['id'] as String? ?? '');
    final sip = Map<String, dynamic>.from(
      (j['sip'] as Map?) ?? const <String, dynamic>{},
    );
    sip['uid'] = id;
    Map<String, dynamic> m(String k) =>
        Map<String, dynamic>.from((j[k] as Map?) ?? const {});
    return AccountProfile(
      id: id,
      config: AccountConfig.fromJson(sip),
      enabled: j['enabled'] != false,
      isDefault: j['isDefault'] == true,
      label: j['label'] as String? ?? '',
      color: (j['color'] as num?)?.toInt() ?? 0xFF3F51E0,
      voicemailNumber: j['voicemailNumber'] as String? ?? '',
      featureCodes: FeatureCodes.fromJson(m('featureCodes')),
      dnd: j['dnd'] == true,
      autoAnswer: AutoAnswerConfig.fromJson(m('autoAnswer')),
      forwarding: ForwardingConfig.fromJson(m('forwarding')),
      ringtone: j['ringtone'] as String? ?? 'default',
      dialRuleSetId: j['dialRuleSetId'] as String? ?? '',
      providerTemplateId: j['providerTemplateId'] as String? ?? 'generic',
      backupRegistrar: j['backupRegistrar'] as String? ?? '',
      autoRecord: j['autoRecord'] as String? ?? 'inherit',
      holdMusic: j['holdMusic'] as String? ?? 'inherit',
      openingAnnouncement: j['openingAnnouncement'] as String? ?? 'inherit',
    );
  }
}
