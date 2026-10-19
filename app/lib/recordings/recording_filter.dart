import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/format.dart';
import '../l10n/l10n.dart';
import '../models/call_record.dart';
import '../models/chat.dart';
import '../models/contact.dart';
import '../services/contacts_controller.dart';
import 'recordings_controller.dart';

/// Search and filters of the recordings page.
class RecordingFilter {
  const RecordingFilter({this.query = '', this.accountId, this.direction, this.range});
  final String query;
  final String? accountId;
  final CallDirection? direction;
  final DateTimeRange? range;

  bool get isEmpty => query.isEmpty && accountId == null && direction == null && range == null;

  RecordingFilter copyWith({
    String? query,
    Object? accountId = _keep,
    Object? direction = _keep,
    Object? range = _keep,
  }) => RecordingFilter(
    query: query ?? this.query,
    accountId: identical(accountId, _keep) ? this.accountId : accountId as String?,
    direction: identical(direction, _keep) ? this.direction : direction as CallDirection?,
    range: identical(range, _keep) ? this.range : range as DateTimeRange?,
  );
  static const Object _keep = Object();
}

class RecordingFilterController extends Notifier<RecordingFilter> {
  @override
  RecordingFilter build() => const RecordingFilter();
  void set(RecordingFilter f) => state = f;
}

final recordingFilterProvider = NotifierProvider<RecordingFilterController, RecordingFilter>(RecordingFilterController.new);

/// Name to show for a recording: user title, contact, name at recording
/// time, number.
String recordingTitle(RecordingMeta m, List<Contact> contacts, AppLocalizations l) {
  if (m.title.isNotEmpty) return m.title;
  final c = findContact(contacts, m.remote);
  if (c != null && c.displayName.isNotEmpty) return c.displayName;
  if (m.remoteName.isNotEmpty) return m.remoteName;
  return m.remote.isEmpty ? l.recTitleFallback : m.remote;
}

List<RecordingMeta> applyRecordingFilter(List<RecordingMeta> all, RecordingFilter f, List<Contact> contacts, AppLocalizations l) {
  final q = f.query.trim().toLowerCase();
  final qd = digitsOf(q);
  final range = f.range;
  return all.where((m) {
    if (f.accountId != null && m.accountId != f.accountId) return false;
    if (f.direction != null && (m.outgoing ? CallDirection.outgoing : CallDirection.incoming) != f.direction) return false;
    if (range != null) {
      final day = DateTime(m.time.year, m.time.month, m.time.day);
      final from = DateTime(range.start.year, range.start.month, range.start.day);
      final to = DateTime(range.end.year, range.end.month, range.end.day);
      if (day.isBefore(from) || day.isAfter(to)) return false;
    }
    if (q.isNotEmpty) {
      return recordingTitle(m, contacts, l).toLowerCase().contains(q) ||
          m.remote.toLowerCase().contains(q) ||
          (qd.isNotEmpty && digitsOf(m.remote).contains(qd));
    }
    return true;
  }).toList();
}

final filteredRecordingsProvider = Provider<List<RecordingMeta>>((ref) {
  return applyRecordingFilter(
    ref.watch(recordingsProvider),
    ref.watch(recordingFilterProvider),
    ref.watch(contactsProvider),
    ref.watch(l10nProvider),
  );
});
