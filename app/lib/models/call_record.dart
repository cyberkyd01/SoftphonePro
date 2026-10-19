enum CallDirection { incoming, outgoing }

enum CallResult {
  answered,
  missed,
  rejected,
  failed,
  busy,
  forwarded,
  transferred,
  handedOff;

  String get label => switch (this) {
    answered => 'Answered',
    missed => 'Missed',
    rejected => 'Declined',
    failed => 'Failed',
    busy => 'Busy',
    forwarded => 'Forwarded',
    transferred => 'Transferred',
    handedOff => 'Handed off',
  };
}

class QualitySummary {
  const QualitySummary({
    this.mosAvg = 0,
    this.mosMin = 0,
    this.jitterMax = 0,
    this.lossPct = 0,
  });

  final double mosAvg;
  final double mosMin;
  final double jitterMax;
  final double lossPct;

  bool get isEmpty => mosAvg == 0 && mosMin == 0;

  factory QualitySummary.fromJson(Map<String, dynamic> j) => QualitySummary(
    mosAvg: (j['mosAvg'] as num?)?.toDouble() ?? 0,
    mosMin: (j['mosMin'] as num?)?.toDouble() ?? 0,
    jitterMax: (j['jitterMax'] as num?)?.toDouble() ?? 0,
    lossPct: (j['lossPct'] as num?)?.toDouble() ?? 0,
  );

  Map<String, dynamic> toJson() => {
    'mosAvg': mosAvg,
    'mosMin': mosMin,
    'jitterMax': jitterMax,
    'lossPct': lossPct,
  };
}

class CallRecord {
  const CallRecord({
    required this.id,
    required this.accountId,
    required this.direction,
    required this.remoteUri,
    required this.remoteNumber,
    required this.remoteDisplay,
    required this.start,
    this.connectMs = 0,
    this.durationMs = 0,
    this.result = CallResult.answered,
    this.sipCode = 0,
    this.reason = '',
    this.recordingPath,
    this.quality = const QualitySummary(),
  });

  final String id;
  final String accountId;
  final CallDirection direction;
  final String remoteUri;
  final String remoteNumber;
  final String remoteDisplay;
  final DateTime start;
  final int connectMs;
  final int durationMs;
  final CallResult result;
  final int sipCode;
  final String reason;
  final String? recordingPath;
  final QualitySummary quality;

  bool get isMissed =>
      direction == CallDirection.incoming && result == CallResult.missed;

  CallRecord copyWith({String? recordingPath, QualitySummary? quality}) =>
      CallRecord(
        id: id,
        accountId: accountId,
        direction: direction,
        remoteUri: remoteUri,
        remoteNumber: remoteNumber,
        remoteDisplay: remoteDisplay,
        start: start,
        connectMs: connectMs,
        durationMs: durationMs,
        result: result,
        sipCode: sipCode,
        reason: reason,
        recordingPath: recordingPath ?? this.recordingPath,
        quality: quality ?? this.quality,
      );

  factory CallRecord.fromJson(Map<String, dynamic> j) => CallRecord(
    id: j['id'] as String,
    accountId: j['accountId'] as String? ?? '',
    direction: CallDirection.values.firstWhere(
      (d) => d.name == j['direction'],
      orElse: () => CallDirection.outgoing,
    ),
    remoteUri: j['remoteUri'] as String? ?? '',
    remoteNumber: j['remoteNumber'] as String? ?? '',
    remoteDisplay: j['remoteDisplay'] as String? ?? '',
    start: DateTime.fromMillisecondsSinceEpoch(
      (j['start'] as num?)?.toInt() ?? 0,
    ),
    connectMs: (j['connectMs'] as num?)?.toInt() ?? 0,
    durationMs: (j['durationMs'] as num?)?.toInt() ?? 0,
    result: CallResult.values.firstWhere(
      (r) => r.name == j['result'],
      orElse: () => CallResult.answered,
    ),
    sipCode: (j['sipCode'] as num?)?.toInt() ?? 0,
    reason: j['reason'] as String? ?? '',
    recordingPath: j['recordingPath'] as String?,
    quality: QualitySummary.fromJson(
      Map<String, dynamic>.from((j['quality'] as Map?) ?? const {}),
    ),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'accountId': accountId,
    'direction': direction.name,
    'remoteUri': remoteUri,
    'remoteNumber': remoteNumber,
    'remoteDisplay': remoteDisplay,
    'start': start.millisecondsSinceEpoch,
    'connectMs': connectMs,
    'durationMs': durationMs,
    'result': result.name,
    'sipCode': sipCode,
    'reason': reason,
    'recordingPath': recordingPath,
    'quality': quality.toJson(),
  };
}
