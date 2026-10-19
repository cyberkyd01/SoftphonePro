import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spcore_dart/spcore_dart.dart';

import '../services/accounts_controller.dart';
import '../services/engine_controller.dart';
import '../services/settings_controller.dart';
import 'audio_library.dart';

enum AnnouncementKind { opening, transfer, recordingNotice }

/// An announcement being played into a call (drives the in-call chip).
class AnnouncementPlay {
  const AnnouncementPlay(this.cid, this.playId, this.kind, this.file);
  final int cid;
  final int playId;
  final AnnouncementKind kind;
  final String file;
}

class AnnouncementsState extends Notifier<Map<int, AnnouncementPlay>> {
  @override
  Map<int, AnnouncementPlay> build() => const {};
  void put(AnnouncementPlay p) => state = {...state, p.cid: p};
  void remove(int cid, [int? playId]) {
    final cur = state[cid];
    if (cur == null || (playId != null && cur.playId != playId)) return;
    state = {...state}..remove(cid);
  }
}

/// Active announcement per call id.
final activeAnnouncementsProvider =
    NotifierProvider<AnnouncementsState, Map<int, AnnouncementPlay>>(AnnouncementsState.new);

final announcementServiceProvider = Provider<AnnouncementService>((ref) {
  final s = AnnouncementService(ref);
  ref.onDispose(s.dispose);
  return s;
});

/// Plays configured audio into calls: the opening announcement, the notice
/// before a transfer and the notice before recording.
class AnnouncementService {
  AnnouncementService(this._ref) {
    _sub = _ref.read(engineProvider.notifier).events.listen(_onEvent);
  }
  final Ref _ref;
  StreamSubscription<EngineEvent>? _sub;

  /// Longest we wait for a playback to finish.
  Duration maxWait = const Duration(seconds: 15);

  final Map<(int, int), Completer<void>> _waiters = {};
  final Set<(int, int)> _doneEarly = {};
  final Set<int> _openingDone = {};

  void dispose() => _sub?.cancel();

  void _log(String m) => _ref.read(engineLogProvider.notifier).add(m);

  void _onEvent(EngineEvent e) {
    if (e is CallPlayDoneEvent) {
      final key = (e.cid, e.playId);
      final w = _waiters.remove(key);
      if (w != null) {
        w.complete();
      } else {
        _doneEarly.add(key);
      }
      _ref.read(activeAnnouncementsProvider.notifier).remove(e.cid, e.playId);
    } else if (e is CallStateEvent && e.isTerminal) {
      _openingDone.remove(e.cid);
      _ref.read(activeAnnouncementsProvider.notifier).remove(e.cid);
      for (final k in _waiters.keys.where((k) => k.$1 == e.cid).toList()) {
        _waiters.remove(k)?.complete();
      }
      _doneEarly.removeWhere((k) => k.$1 == e.cid);
    }
  }

  /// Plays [ref] into [cid] and returns when it has finished (or after
  /// [maxWait]). Returns false when nothing could be played; failures never
  /// throw so a call flow is not blocked by a bad announcement.
  Future<bool> play(
    int cid,
    String ref, {
    required AnnouncementKind kind,
    bool muteMic = true,
    bool monitor = false,
    bool wait = true,
  }) async {
    final ctl = _ref.read(engineProvider.notifier);
    if (!ctl.hasEngine || ref.isEmpty) return false;
    final file = await _ref.read(audioLibraryProvider).resolve(ref);
    if (file == null) {
      _log('announcement file missing: $ref');
      return false;
    }
    final int playId;
    try {
      playId = await ctl.engine.playFile(cid, file, muteMic: muteMic, localMonitor: monitor);
    } on EngineException catch (e) {
      _log('announcement not played (${e.code.wire}): ${e.error.message}');
      return false;
    }
    final key = (cid, playId);
    if (_doneEarly.remove(key)) return true;
    final done = Completer<void>();
    _waiters[key] = done;
    _ref.read(activeAnnouncementsProvider.notifier).put(AnnouncementPlay(cid, playId, kind, file));
    final waiting = done.future;
    if (!wait) return true;
    try {
      await waiting.timeout(maxWait);
    } on TimeoutException {
      _waiters.remove(key);
      _ref.read(activeAnnouncementsProvider.notifier).remove(cid, playId);
      try {
        await ctl.engine.stopFile(cid, playId: playId);
      } catch (_) {}
    }
    return true;
  }

  /// Stops whatever announcement is playing into [cid] (the Skip button).
  Future<void> skip(int cid) async {
    final ctl = _ref.read(engineProvider.notifier);
    if (!ctl.hasEngine) return;
    try {
      await ctl.engine.stopFile(cid);
    } on EngineException catch (e) {
      _log('skip announcement failed: ${e.error.message}');
    }
  }

  // ---- opening announcement ----------------------------------------------

  /// The audio ref to play when a call on [accountId] connects, or empty.
  String openingRefFor(String accountId, {required bool incoming}) {
    final s = _ref.read(settingsProvider);
    final acc = _ref.read(accountsProvider).byId(accountId);
    final o = acc?.openingAnnouncement ?? 'inherit';
    if (o == 'off') return '';
    final dir = s.announceDirection;
    final dirOk = dir == 'both' || (dir == 'incoming' && incoming) || (dir == 'outgoing' && !incoming);
    if (!dirOk) return '';
    if (o != 'inherit' && o.isNotEmpty) return o;
    return s.announceOpening ? s.announceOpeningFile : '';
  }

  /// Call connected: plays the opening announcement once per call.
  Future<void> onCallConfirmed({
    required int cid,
    required bool incoming,
    required String accountId,
  }) async {
    if (_openingDone.contains(cid)) return;
    final ref = openingRefFor(accountId, incoming: incoming);
    if (ref.isEmpty) return;
    _openingDone.add(cid);
    final s = _ref.read(settingsProvider);
    await play(
      cid,
      ref,
      kind: AnnouncementKind.opening,
      muteMic: s.announceMuteMic,
      monitor: s.announceMonitor,
      wait: false,
    );
  }

  // ---- other notices --------------------------------------------------------

  /// Plays the recording notice, returning when finished (max 15 s). Does
  /// nothing when none is configured. For use before recording starts.
  Future<void> playRecordingNotice(int cid) async {
    final ref = _ref.read(settingsProvider).recordingNoticeFile;
    if (ref.isEmpty) return;
    await play(cid, ref, kind: AnnouncementKind.recordingNotice, muteMic: true);
  }

  /// Plays the "you are being transferred" notice to the party on [cid] and
  /// waits for it (max 15 s) before the caller performs the transfer.
  Future<void> playTransferNotice(int cid) async {
    final ref = _ref.read(settingsProvider).transferNoticeFile;
    if (ref.isEmpty) return;
    await play(cid, ref, kind: AnnouncementKind.transfer, muteMic: true);
  }
}
