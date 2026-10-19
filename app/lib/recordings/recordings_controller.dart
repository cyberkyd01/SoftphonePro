import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/call_record.dart';
import '../models/chat.dart';
import '../services/history_controller.dart';
import '../services/providers.dart';
import '../services/settings_controller.dart';

/// All recordings known to the app (newest first), backed by the
/// `recordings` store. The files live in the recordings folder.
class RecordingsController extends Notifier<List<RecordingMeta>> {
  Timer? _daily;
  bool _loaded = false;

  /// Whether the store has been read.
  bool get loaded => _loaded;

  @override
  List<RecordingMeta> build() {
    ref.onDispose(() => _daily?.cancel());
    // Retention: at startup (after loading), daily, and when the setting changes.
    // Root-zone timer: a 24 h timer must not count as pending in widget tests.
    _daily = Zone.root.createPeriodicTimer(const Duration(hours: 24), (_) => unawaited(applyRetention()));
    ref.listen<int>(settingsProvider.select((s) => s.recordAutoDeleteDays), (prev, next) {
      if (_loaded && next > 0 && next != prev) unawaited(applyRetention());
    });
    unawaited(_load());
    return const [];
  }

  Future<void> _load() async {
    final stored = await ref.read(recordingsRepoProvider).loadAll();
    final byId = {for (final m in stored) m.id: m};
    for (final m in state) {
      byId[m.id] = m; // added while loading
    }
    state = _sorted(byId.values);
    _loaded = true;
    await applyRetention();
  }

  static List<RecordingMeta> _sorted(Iterable<RecordingMeta> l) =>
      [...l]..sort((a, b) => b.time.compareTo(a.time));

  /// Reloads from the store (e.g. after external changes).
  Future<void> reload() => _load();

  RecordingMeta? byId(String? id) {
    if (id == null) return null;
    for (final m in state) {
      if (m.id == id) return m;
    }
    return null;
  }

  RecordingMeta? byPath(String? path) {
    if (path == null || path.isEmpty) return null;
    for (final m in state) {
      if (m.path == path) return m;
    }
    return null;
  }

  Future<void> add(RecordingMeta m) async {
    state = _sorted([m, ...state.where((e) => e.id != m.id)]);
    await ref.read(recordingsRepoProvider).put(m);
  }

  Future<void> update(RecordingMeta m) async {
    state = _sorted([for (final e in state) e.id == m.id ? m : e]);
    await ref.read(recordingsRepoProvider).put(m);
  }

  /// Gives a recording a user-chosen name (empty restores the default).
  Future<void> rename(String id, String title) async {
    final m = byId(id);
    if (m == null) return;
    await update(m.copyWith(title: title.trim()));
  }

  /// Links two recordings (both directions) as belonging together, e.g. an
  /// attended-transfer consultation leg and the original call.
  Future<void> link(String a, String b) async {
    if (a == b) return;
    for (final (x, y) in [(a, b), (b, a)]) {
      final m = byId(x);
      if (m != null && !m.relatedIds.contains(y)) {
        await update(m.copyWith(relatedIds: [...m.relatedIds, y]));
      }
      final hist = ref.read(historyProvider);
      for (final r in hist) {
        if (r.recordingId == x && !r.relatedRecordingIds.contains(y)) {
          await ref.read(historyProvider.notifier).update(
            r.copyWith(relatedRecordingIds: [...r.relatedRecordingIds, y]),
          );
        }
      }
    }
  }

  /// Deletes the recordings and their files; history entries lose the link.
  Future<void> delete(Iterable<String> ids, {bool deleteFiles = true}) async {
    final set = ids.toSet();
    final doomed = state.where((m) => set.contains(m.id)).toList();
    state = state.where((m) => !set.contains(m.id)).toList();
    final repo = ref.read(recordingsRepoProvider);
    for (final m in doomed) {
      await repo.delete(m, deleteFile: deleteFiles);
    }
    final hist = ref.read(historyProvider);
    final paths = doomed.map((m) => m.path).toSet();
    for (final r in hist) {
      if (set.contains(r.recordingId) || (r.recordingPath != null && paths.contains(r.recordingPath))) {
        await ref.read(historyProvider.notifier).update(r.copyWith(clearRecording: true));
      }
    }
  }

  /// Deletes recordings older than the configured number of days. Returns
  /// how many were removed.
  Future<int> applyRetention({DateTime? now}) async {
    final days = ref.read(settingsProvider).recordAutoDeleteDays;
    if (days <= 0) return 0;
    final cutoff = (now ?? DateTime.now()).subtract(Duration(days: days));
    final old = state.where((m) => m.time.isBefore(cutoff)).map((m) => m.id).toList();
    if (old.isEmpty) return 0;
    await delete(old);
    return old.length;
  }

  /// Records that exist on disk but whose file is gone.
  List<RecordingMeta> get missingFiles => [for (final m in state) if (!File(m.path).existsSync()) m];
}

final recordingsProvider = NotifierProvider<RecordingsController, List<RecordingMeta>>(RecordingsController.new);

/// Disk usage of all recordings.
class RecordingsUsage {
  const RecordingsUsage(this.count, this.bytes);
  final int count;
  final int bytes;
}

/// Size of a recording: the stored value, else the file size.
int recordingBytes(RecordingMeta m) {
  if (m.bytes > 0) return m.bytes;
  try {
    return File(m.path).lengthSync();
  } catch (_) {
    return 0;
  }
}

final recordingsUsageProvider = Provider<RecordingsUsage>((ref) {
  final list = ref.watch(recordingsProvider);
  var bytes = 0;
  for (final m in list) {
    bytes += recordingBytes(m);
  }
  return RecordingsUsage(list.length, bytes);
});

/// The recording belonging to a history record (by id, then by path).
RecordingMeta? recordingForCall(List<RecordingMeta> all, CallRecord r) {
  for (final m in all) {
    if (m.id == r.recordingId || m.callRecordId == r.id) return m;
  }
  final path = r.recordingPath;
  if (path == null) return null;
  for (final m in all) {
    if (m.path == path) return m;
  }
  return null;
}

@visibleForTesting
String recordingsDebug(List<RecordingMeta> l) => l.map((e) => e.id).join(',');
