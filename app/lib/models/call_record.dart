enum CallDirection { incoming, outgoing }

enum CallResult {
  answered,
  missed,
  rejected,
  failed,
  busy,
  forwarded,
  transferred,
  handedOff,
  interrupted;

  String get label => switch (this) {
    answered => 'Answered',
    missed => 'Missed',
    rejected => 'Declined',
    failed => 'Failed',
    busy => 'Busy',
    forwarded => 'Forwarded',
    transferred => 'Transferred',
    handedOff => 'Handed off',
    interrupted => 'Interrupted',
  };
}

/// One point of a call's quality time series.
class QualitySample {
  const QualitySample({
    required this.t,
    this.mos = 0,
    this.jitter = 0,
    this.loss = 0,
    this.rtt = 0,
  });

  /// Seconds since the call connected.
  final double t;
  final double mos;
  final double jitter;
  final double loss;
  final double rtt;

  List<num> toJson() => [
    double.parse(t.toStringAsFixed(1)),
    double.parse(mos.toStringAsFixed(2)),
    double.parse(jitter.toStringAsFixed(1)),
    double.parse(loss.toStringAsFixed(2)),
    double.parse(rtt.toStringAsFixed(0)),
  ];

  static QualitySample? fromJson(Object? j) {
    if (j is! List || j.length < 5) return null;
    double d(int i) => j[i] is num ? (j[i] as num).toDouble() : 0;
    return QualitySample(t: d(0), mos: d(1), jitter: d(2), loss: d(3), rtt: d(4));
  }
}

class QualitySummary {
  const QualitySummary({
    this.mosAvg = 0,
    this.mosMin = 0,
    this.jitterMax = 0,
    this.lossPct = 0,
    this.samples = const [],
  });

  /// Down-sampled series (at most ~120 points), empty for old records.
  final List<QualitySample> samples;

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
    samples: j['samples'] is List
        ? [
            for (final e in j['samples'] as List)
              if (QualitySample.fromJson(e) case final q?) q,
          ]
        : const [],
  );

  Map<String, dynamic> toJson() => {
    'mosAvg': mosAvg,
    'mosMin': mosMin,
    'jitterMax': jitterMax,
    'lossPct': lossPct,
    if (samples.isNotEmpty) 'samples': [for (final q in samples) q.toJson()],
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
    this.callId = '',
    this.recordingId,
    this.relatedRecordingIds = const [],
    this.assertedName = '',
    this.assertedNumber = '',
    this.divertedFrom = '',
    this.divertReason = '',
    this.referredBy = '',
  });

  /// SIP Call-ID (to find the call in the SIP trace); empty for old records.
  final String callId;
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

  /// Id of the primary [RecordingMeta] of this call.
  final String? recordingId;

  /// Recording ids of related calls (transfer consult legs, relays).
  final List<String> relatedRecordingIds;

  /// Caller identity from P-Asserted-Identity / Remote-Party-ID.
  final String assertedName;
  final String assertedNumber;

  /// First diversion hop (user) and its reason, when the call was forwarded.
  final String divertedFrom;
  final String divertReason;

  /// `Referred-By` user/URI for calls that result from a transfer.
  final String referredBy;

  bool get isMissed =>
      direction == CallDirection.incoming && result == CallResult.missed;

  CallRecord copyWith({
    String? recordingPath,
    QualitySummary? quality,
    String? recordingId,
    List<String>? relatedRecordingIds,
    bool clearRecording = false,
  }) =>
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
        recordingPath: clearRecording ? null : (recordingPath ?? this.recordingPath),
        quality: quality ?? this.quality,
        callId: callId,
        recordingId: clearRecording ? null : (recordingId ?? this.recordingId),
        relatedRecordingIds: relatedRecordingIds ?? this.relatedRecordingIds,
        assertedName: assertedName,
        assertedNumber: assertedNumber,
        divertedFrom: divertedFrom,
        divertReason: divertReason,
        referredBy: referredBy,
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
    callId: j['callId'] as String? ?? '',
    recordingId: j['recordingId'] as String?,
    relatedRecordingIds: [for (final e in (j['relatedRecordingIds'] as List? ?? const [])) '$e'],
    assertedName: j['assertedName'] as String? ?? '',
    assertedNumber: j['assertedNumber'] as String? ?? '',
    divertedFrom: j['divertedFrom'] as String? ?? '',
    divertReason: j['divertReason'] as String? ?? '',
    referredBy: j['referredBy'] as String? ?? '',
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
    if (callId.isNotEmpty) 'callId': callId,
    if (recordingId != null) 'recordingId': recordingId,
    if (relatedRecordingIds.isNotEmpty) 'relatedRecordingIds': relatedRecordingIds,
    if (assertedName.isNotEmpty) 'assertedName': assertedName,
    if (assertedNumber.isNotEmpty) 'assertedNumber': assertedNumber,
    if (divertedFrom.isNotEmpty) 'divertedFrom': divertedFrom,
    if (divertReason.isNotEmpty) 'divertReason': divertReason,
    if (referredBy.isNotEmpty) 'referredBy': referredBy,
  };
}
