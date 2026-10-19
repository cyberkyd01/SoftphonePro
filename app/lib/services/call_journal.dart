import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/l10n.dart';
import '../models/call_record.dart';
import '../storage/repositories.dart';
import 'history_controller.dart';
import 'providers.dart';

/// Identifies this run of the app; entries of other sessions are leftovers.
final String kJournalSession = newId();

/// A call that was in progress, persisted so that a crash or force-stop does
/// not lose it from the history.
class JournalEntry {
  const JournalEntry({
    required this.key,
    required this.session,
    required this.cid,
    required this.accountId,
    required this.direction,
    required this.remoteUri,
    required this.remoteNumber,
    required this.remoteDisplay,
    required this.start,
    this.answeredAt,
    this.lastSeen,
    this.callId = '',
    this.recordingPath,
    this.recordingId,
  });

  final String key;
  final String session;
  final int cid;
  final String accountId;
  final CallDirection direction;
  final String remoteUri;
  final String remoteNumber;
  final String remoteDisplay;
  final DateTime start;
  final DateTime? answeredAt;
  final DateTime? lastSeen;
  final String callId;
  final String? recordingPath;
  final String? recordingId;

  JournalEntry copyWith({
    String? remoteUri,
    String? remoteNumber,
    String? remoteDisplay,
    DateTime? answeredAt,
    DateTime? lastSeen,
    String? callId,
    String? recordingPath,
    String? recordingId,
  }) => JournalEntry(
    key: key,
    session: session,
    cid: cid,
    accountId: accountId,
    direction: direction,
    remoteUri: remoteUri ?? this.remoteUri,
    remoteNumber: remoteNumber ?? this.remoteNumber,
    remoteDisplay: remoteDisplay ?? this.remoteDisplay,
    start: start,
    answeredAt: answeredAt ?? this.answeredAt,
    lastSeen: lastSeen ?? this.lastSeen,
    callId: callId ?? this.callId,
    recordingPath: recordingPath ?? this.recordingPath,
    recordingId: recordingId ?? this.recordingId,
  );

  factory JournalEntry.fromJson(Map<String, dynamic> j) => JournalEntry(
    key: j['key'] as String,
    session: j['session'] as String? ?? '',
    cid: (j['cid'] as num?)?.toInt() ?? 0,
    accountId: j['accountId'] as String? ?? '',
    direction: j['direction'] == 'incoming' ? CallDirection.incoming : CallDirection.outgoing,
    remoteUri: j['remoteUri'] as String? ?? '',
    remoteNumber: j['remoteNumber'] as String? ?? '',
    remoteDisplay: j['remoteDisplay'] as String? ?? '',
    start: DateTime.fromMillisecondsSinceEpoch((j['start'] as num?)?.toInt() ?? 0),
    answeredAt: j['answeredAt'] is num ? DateTime.fromMillisecondsSinceEpoch((j['answeredAt'] as num).toInt()) : null,
    lastSeen: j['lastSeen'] is num ? DateTime.fromMillisecondsSinceEpoch((j['lastSeen'] as num).toInt()) : null,
    callId: j['callId'] as String? ?? '',
    recordingPath: j['recordingPath'] as String?,
    recordingId: j['recordingId'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'key': key,
    'session': session,
    'cid': cid,
    'accountId': accountId,
    'direction': direction.name,
    'remoteUri': remoteUri,
    'remoteNumber': remoteNumber,
    'remoteDisplay': remoteDisplay,
    'start': start.millisecondsSinceEpoch,
    if (answeredAt != null) 'answeredAt': answeredAt!.millisecondsSinceEpoch,
    if (lastSeen != null) 'lastSeen': lastSeen!.millisecondsSinceEpoch,
    if (callId.isNotEmpty) 'callId': callId,
    if (recordingPath != null) 'recordingPath': recordingPath,
    if (recordingId != null) 'recordingId': recordingId,
  };

  /// The history record for a call that was cut off.
  CallRecord toInterruptedRecord([String reason = 'The app was closed during the call']) {
    final answered = answeredAt;
    final end = lastSeen ?? answered ?? start;
    return CallRecord(
      id: newId(),
      accountId: accountId,
      direction: direction,
      remoteUri: remoteUri,
      remoteNumber: remoteNumber,
      remoteDisplay: remoteDisplay,
      start: start,
      connectMs: answered == null ? 0 : answered.difference(start).inMilliseconds,
      durationMs: answered == null ? 0 : end.difference(answered).inMilliseconds.clamp(0, 1 << 40),
      result: CallResult.interrupted,
      reason: reason,
      recordingPath: recordingPath,
      recordingId: recordingId,
      callId: callId,
    );
  }
}

/// Persistent journal of calls in progress.
class CallJournal {
  CallJournal(this._store);
  final JsonStore _store;

  final Map<String, JournalEntry> _cache = {};

  Future<void> put(JournalEntry e) async {
    _cache[e.key] = e;
    // Root zone: the periodic heartbeat must not leave fake-async timers
    // (sembast's cooperator) pending in widget tests; no effect in the app.
    await Zone.root.run(() => _store.put(e.key, e.toJson()));
  }

  JournalEntry? cached(String key) => _cache[key];

  Future<void> remove(String key) async {
    _cache.remove(key);
    await Zone.root.run(() => _store.delete(key));
  }

  Future<List<JournalEntry>> all() async => [for (final j in await _store.all()) JournalEntry.fromJson(j)];

  /// Converts entries left by earlier sessions into "interrupted" history
  /// records and clears them. Returns how many were recovered.
  Future<int> recoverInto(HistoryController history, {String? session, String? reason}) async {
    final mine = session ?? kJournalSession;
    var n = 0;
    final entries = await all();
    entries.sort((a, b) => a.start.compareTo(b.start));
    for (final e in entries) {
      if (e.session == mine) continue;
      await history.add(reason == null ? e.toInterruptedRecord() : e.toInterruptedRecord(reason));
      await _store.delete(e.key);
      n++;
    }
    return n;
  }
}

final callJournalProvider = Provider<CallJournal>(
  (ref) => CallJournal(JsonStore(ref.watch(appDatabaseProvider).db, 'call_journal')),
);

/// Recovers leftovers of a previous run; call once at startup.
Future<int> recoverInterruptedCalls(Ref ref) async {
  try {
    return await ref.read(callJournalProvider).recoverInto(
      ref.read(historyProvider.notifier),
      reason: ref.read(l10nProvider).callJournalInterrupted,
    );
  } catch (e) {
    debugPrint('call journal recovery failed: $e');
    return 0;
  }
}
