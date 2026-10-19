import 'package:flutter/material.dart';

/// Immutable, JSON-backed application settings. Every field has a typed
/// getter with a default; [update] returns a modified copy.
class AppSettings {
  const AppSettings([this._m = const {}]);
  final Map<String, dynamic> _m;

  factory AppSettings.fromJson(Map<String, dynamic> j) =>
      AppSettings(Map<String, dynamic>.from(j));
  Map<String, dynamic> toJson() => Map<String, dynamic>.from(_m);

  AppSettings update(Map<String, dynamic> changes) =>
      AppSettings({..._m, ...changes});

  bool _b(String k, bool d) => _m[k] is bool ? _m[k] as bool : d;
  int _i(String k, int d) => _m[k] is num ? (_m[k] as num).toInt() : d;
  double _d(String k, double d) => _m[k] is num ? (_m[k] as num).toDouble() : d;
  String _s(String k, String d) => _m[k] is String ? _m[k] as String : d;
  List<String> _l(String k, [List<String> d = const []]) =>
      _m[k] is List ? [for (final e in _m[k] as List) '$e'] : d;

  // ---- appearance
  ThemeMode get themeMode => ThemeMode.values.firstWhere(
    (m) => m.name == _s('themeMode', 'system'),
    orElse: () => ThemeMode.system,
  );
  int get accent => _i('accent', 0xFF3F51E0);
  bool get compactDensity => _b('compactDensity', false);

  /// UI language: `system` (follow the OS) or a code from `kAppLanguages`.
  String get language => _s('language', 'system');

  // ---- status / calls
  String get globalStatus => _s('globalStatus', 'available');
  bool get dnd => _b('dnd', false);
  int get dndRejectCode => _i('dndRejectCode', 486);
  bool get callWaiting => _b('callWaiting', true);
  int get busyRejectCode => _i('busyRejectCode', 486);
  bool get autoAnswer => _b('autoAnswer', false);
  int get autoAnswerDelay => _i('autoAnswerDelay', 0);
  bool get allowAutoAnswerHeaders => _b('allowAutoAnswerHeaders', true);
  bool get rejectAnonymous => _b('rejectAnonymous', false);
  List<String> get blocklist => _l('blocklist');
  String get ringtone => _s('ringtone', 'default');
  double get ringerVolume => _d('ringerVolume', 1.0);
  List<String> get emergencyNumbers =>
      _l('emergencyNumbers', const ['911', '112', '999', '000']);
  String get defaultCountryPrefix => _s('defaultCountryPrefix', '');

  // ---- audio
  String get captureDev => _s('captureDev', 'default');
  String get playbackDev => _s('playbackDev', 'default');
  String get ringerDev => _s('ringerDev', 'default');
  double get micLevel => _d('micLevel', 1.0);
  double get speakerLevel => _d('speakerLevel', 1.0);
  String get ecAlgo => _s('ecAlgo', 'auto');
  int get ecTailMs => _i('ecTailMs', 200);
  bool get noiseSuppression => _b('noiseSuppression', true);
  bool get agc => _b('agc', false);
  bool get vad => _b('vad', false);

  // ---- codecs
  List<String> get codecOrder => _l('codecOrder');
  List<String> get codecsDisabled => _l('codecsDisabled');
  int get opusBitrate => _i('opusBitrate', 32000);
  bool get opusFec => _b('opusFec', true);
  bool get opusDtx => _b('opusDtx', false);
  bool get opusCbr => _b('opusCbr', false);
  int get opusComplexity => _i('opusComplexity', 8);

  // ---- network
  bool get udpEnabled => _b('udpEnabled', true);
  int get udpPort => _i('udpPort', 0);
  bool get tcpEnabled => _b('tcpEnabled', true);
  int get tcpPort => _i('tcpPort', 0);
  bool get tlsEnabled => _b('tlsEnabled', true);
  int get tlsPort => _i('tlsPort', 0);
  bool get tlsVerify => _b('tlsVerify', true);
  List<String> get stunServers =>
      _l('stunServers', const ['stun.l.google.com:19302']);
  bool get ipv6 => _b('ipv6', false);
  bool get qos => _b('qos', true);
  List<String> get dnsServers => _l('dnsServers');
  List<String> get tlsPins => _l('tlsPins');
  int get rtpPort => _i('rtpPort', 4000);
  int get rtpPortRange => _i('rtpPortRange', 0);

  // ---- recording
  bool get autoRecord => _b('autoRecord', false);
  String get recordingFolder => _s('recordingFolder', '');
  bool get recordBeep => _b('recordBeep', false);

  // ---- privacy / system
  bool get appLock => _b('appLock', false);
  bool get startAtLogin => _b('startAtLogin', false);
  bool get minimizeToTray => _b('minimizeToTray', true);
  Map<String, String> get hotkeys => _m['hotkeys'] is Map
      ? {
          for (final e in (_m['hotkeys'] as Map).entries)
            '${e.key}': '${e.value}',
        }
      : const {};
  bool get sendTyping => _b('sendTyping', true);

  // ---- dial rules (list of rule JSON)
  List<Map<String, dynamic>> get dialRules => _m['dialRules'] is List
      ? [
          for (final r in _m['dialRules'] as List)
            Map<String, dynamic>.from(r as Map),
        ]
      : const [];

  // ---- LAN
  bool get lanEnabled => _b('lanEnabled', false);
  String get lanDeviceName => _s('lanDeviceName', '');
  List<String> get lanShareAors => _l('lanShareAors');
  bool get lanAllowIntercom => _b('lanAllowIntercom', true);
  bool get lanAllowPull => _b('lanAllowPull', false);
  bool get lanAutoAcceptFiles => _b('lanAutoAcceptFiles', false);
  String get lanDownloadsDir => _s('lanDownloadsDir', '');

  /// Fixed LAN Link TCP port (0 = random).
  int get lanLinkPort => _i('lanLinkPort', 0);

  /// Ask before allowing an intercom from a paired device (else auto-allow).
  bool get lanIntercomPrompt => _b('lanIntercomPrompt', true);

  // ---- developer / flow
  int get logLevel => _i('logLevel', 3);
  bool get sipTrace => _b('sipTrace', false);
  bool get useSimulator => _b('useSimulator', false);
  bool get onboardingDone => _b('onboardingDone', false);

  // ---- app lock (PIN itself lives in the secrets store)
  /// Minutes in the background before the app locks again (0 = immediately).
  int get appLockMinutes => _i('appLockMinutes', 1);
  bool get appLockBiometrics => _b('appLockBiometrics', true);

  // ---- polish A1 (new fields are appended)
  /// User-provided CA bundle (PEM); empty = bundled Mozilla CA list.
  String get customCaFile => _s('customCaFile', '');

  /// Place sip:/tel: links as calls immediately instead of filling the dialer.
  bool get callLinksImmediately => _b('callLinksImmediately', false);

  /// Dial the PBX feature codes when per-account DND / forwarding change.
  bool get syncFeatureCodes => _b('syncFeatureCodes', false);

  /// Dial plan helpers (passed to DialRules).
  String get stripPrefix => _s('stripPrefix', '');
  String get plusReplacement => _s('plusReplacement', '');

  /// Jitter buffer (-1 = engine default) and packet time.
  int get jbInitMs => _i('jbInitMs', -1);
  int get jbMinPreMs => _i('jbMinPreMs', -1);
  int get jbMaxPreMs => _i('jbMaxPreMs', -1);
  int get jbMaxMs => _i('jbMaxMs', -1);
  int get ptime => _i('ptime', 20);

  // ---- polish A2 (appended)
  /// Play ringback, busy and congestion tones locally.
  bool get progressTones => _b('progressTones', true);

  // ---- recording (UX2)
  /// `wav` | `wavStereo` | `opus` (engine RecordFormat wire names).
  String get recordFormat => _s('recordFormat', 'wav');

  /// Auto-record rule: `off` | `all` | `incoming` | `outgoing`. Falls back
  /// to the legacy [autoRecord] switch when unset.
  String get recordRule => _s('recordRule', autoRecord ? 'all' : 'off');

  /// Play a "this call is being recorded" notice when recording starts.
  bool get recordNotice => _b('recordNotice', false);

  /// Delete recordings older than this many days (0 = keep forever).
  int get recordAutoDeleteDays => _i('recordAutoDeleteDays', 0);

  /// Also record the consultation call of an attended transfer.
  bool get recordContinueTransfers => _b('recordContinueTransfers', true);

  // ---- local automation API (lib/automation; off by default)
  bool get automationEnabled => _b('automationEnabled', false);

  /// TCP port on 127.0.0.1.
  int get automationPort => _i('automationPort', 7771);

  /// Bearer token (generated when the API is first enabled).
  String get automationToken => _s('automationToken', '');

  /// Browser origins (`https://crm.example.com`) allowed to call the API.
  List<String> get automationOrigins => _l('automationOrigins');

  // ---- audio library, voice isolation, hold music, announcements (UX1)
  /// Voice isolation (AI noise cancellation): own microphone / other party.
  bool get viMicOn => _b('viMicOn', false);
  double get viMicStrength => _d('viMicStrength', 0.7);
  bool get viInOn => _b('viInOn', false);
  double get viInStrength => _d('viInStrength', 0.5);

  /// Hold music: `pbx` (plain hold) or an audio ref (`builtin:<id>`, `lib:<file>`).
  String get holdMusic => _s('holdMusic', 'pbx');
  double get holdMusicVolume => _d('holdMusicVolume', 0.6);

  /// Opening announcement played when a call connects.
  bool get announceOpening => _b('announceOpening', false);
  String get announceOpeningFile => _s('announceOpeningFile', '');

  /// `incoming`, `outgoing` or `both`.
  String get announceDirection => _s('announceDirection', 'both');
  bool get announceMuteMic => _b('announceMuteMic', true);
  bool get announceMonitor => _b('announceMonitor', false);

  /// Audio ref played before call recording starts (empty = none).
  String get recordingNoticeFile => _s('recordingNoticeFile', '');

  /// Audio ref played to a caller before transferring them (empty = none).
  String get transferNoticeFile => _s('transferNoticeFile', '');

  /// Speed dial slots 1-9: `{number, label, accountId?}`.
  Map<int, SpeedDialEntry> get speedDial {
    final raw = _m['speedDial'];
    if (raw is! Map) return const {};
    final out = <int, SpeedDialEntry>{};
    for (final e in raw.entries) {
      final k = int.tryParse('${e.key}');
      if (k == null || k < 1 || k > 9 || e.value is! Map) continue;
      final v = SpeedDialEntry.fromJson(Map<String, dynamic>.from(e.value as Map));
      if (v.number.isNotEmpty) out[k] = v;
    }
    return out;
  }

  // ---- encryption / updates / media keys (W3, appended)
  /// Desktop: check GitHub for a newer release about once a week.
  bool get updateCheck => _b('updateCheck', true);

  /// Epoch ms of the last answered update check (0 = never).
  int get updateLastCheck => _i('updateLastCheck', 0);

  /// A release version the user chose to skip (empty = none).
  String get updateSkipVersion => _s('updateSkipVersion', '');

  /// Desktop: the headset / media play-pause key answers and ends calls.
  bool get mediaKeys => _b('mediaKeys', true);

  /// What the media key does during a call: `hangup` or `mute`.
  String get mediaKeyActive => _s('mediaKeyActive', 'hangup');
}

class SpeedDialEntry {
  const SpeedDialEntry({required this.number, this.label = '', this.accountId});
  final String number;
  final String label;
  final String? accountId;

  factory SpeedDialEntry.fromJson(Map<String, dynamic> j) {
    final a = j['accountId'] as String?;
    return SpeedDialEntry(
      number: j['number'] as String? ?? '',
      label: j['label'] as String? ?? '',
      accountId: (a == null || a.isEmpty) ? null : a,
    );
  }
  Map<String, dynamic> toJson() => {
    'number': number,
    'label': label,
    if (accountId != null) 'accountId': accountId,
  };
}
