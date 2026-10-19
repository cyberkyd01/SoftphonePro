import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/format.dart';
import '../models/call_record.dart';
import 'providers.dart';

class HistoryController extends Notifier<List<CallRecord>> {
  @override
  List<CallRecord> build() => ref.read(bootDataProvider).history;

  Future<void> add(CallRecord r) async {
    state = [r, ...state.where((e) => e.id != r.id)];
    await ref.read(historyRepoProvider).put(r);
  }

  Future<void> update(CallRecord r) async {
    state = [for (final e in state) e.id == r.id ? r : e];
    await ref.read(historyRepoProvider).put(r);
  }

  Future<void> delete(String id) async {
    state = state.where((e) => e.id != id).toList();
    await ref.read(historyRepoProvider).delete(id);
  }

  Future<void> clear() async {
    state = [];
    await ref.read(historyRepoProvider).clear();
  }

  /// Last number dialled (for redial).
  CallRecord? get lastOutgoing {
    for (final r in state) {
      if (r.direction == CallDirection.outgoing) return r;
    }
    return null;
  }

  String exportCsv() {
    final b = StringBuffer(
      'time,direction,result,number,name,account,duration_s,sip_code,reason\n',
    );
    String q(String s) => '"${s.replaceAll('"', '""')}"';
    for (final r in state) {
      b.writeln(
        [
          r.start.toIso8601String(),
          r.direction.name,
          r.result.name,
          q(r.remoteNumber),
          q(r.remoteDisplay),
          q(r.accountId),
          r.durationMs ~/ 1000,
          r.sipCode,
          q(r.reason),
        ].join(','),
      );
    }
    return b.toString();
  }
}

final historyProvider = NotifierProvider<HistoryController, List<CallRecord>>(
  HistoryController.new,
);

enum HistoryKind { all, missed, incoming, outgoing }

class HistoryFilter {
  const HistoryFilter({
    this.kind = HistoryKind.all,
    this.query = '',
    this.accountId,
  });
  final HistoryKind kind;
  final String query;
  final String? accountId;

  HistoryFilter copyWith({
    HistoryKind? kind,
    String? query,
    Object? accountId = _keep,
  }) => HistoryFilter(
    kind: kind ?? this.kind,
    query: query ?? this.query,
    accountId: identical(accountId, _keep) ? this.accountId : accountId as String?,
  );
  static const Object _keep = Object();
}

class HistoryFilterController extends Notifier<HistoryFilter> {
  @override
  HistoryFilter build() => const HistoryFilter();
  void set(HistoryFilter f) => state = f;
}

final historyFilterProvider =
    NotifierProvider<HistoryFilterController, HistoryFilter>(
      HistoryFilterController.new,
    );

List<CallRecord> applyHistoryFilter(List<CallRecord> all, HistoryFilter f) {
  final q = f.query.trim().toLowerCase();
  return all.where((r) {
    switch (f.kind) {
      case HistoryKind.all:
        break;
      case HistoryKind.missed:
        if (!r.isMissed) return false;
      case HistoryKind.incoming:
        if (r.direction != CallDirection.incoming) return false;
      case HistoryKind.outgoing:
        if (r.direction != CallDirection.outgoing) return false;
    }
    if (f.accountId != null && r.accountId != f.accountId) return false;
    if (q.isNotEmpty) {
      return r.remoteNumber.toLowerCase().contains(q) ||
          r.remoteDisplay.toLowerCase().contains(q) ||
          digitsOf(r.remoteNumber).contains(digitsOf(q)) && digitsOf(q).isNotEmpty;
    }
    return true;
  }).toList();
}

final filteredHistoryProvider = Provider<List<CallRecord>>((ref) {
  return applyHistoryFilter(
    ref.watch(historyProvider),
    ref.watch(historyFilterProvider),
  );
});

/// When the user last looked at Recents; missed calls after it are "new".
class RecentsSeenController extends Notifier<DateTime> {
  @override
  DateTime build() => DateTime.fromMillisecondsSinceEpoch(0);
  void markSeen() => state = DateTime.now();
}

final recentsSeenProvider = NotifierProvider<RecentsSeenController, DateTime>(
  RecentsSeenController.new,
);

final missedCountProvider = Provider<int>((ref) {
  final seen = ref.watch(recentsSeenProvider);
  return ref
      .watch(historyProvider)
      .where((r) => r.isMissed && r.start.isAfter(seen))
      .length;
});
