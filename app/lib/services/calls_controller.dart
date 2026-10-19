import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:spcore_dart/spcore_dart.dart';

import '../core/format.dart';
import '../models/account_profile.dart';
import '../models/app_settings.dart';
import '../models/call_record.dart';
import '../models/chat.dart';
import '../storage/repositories.dart';
import '../platform/lan_handoff.dart';
import '../platform/platform_services.dart';
import 'accounts_controller.dart';
import 'contacts_controller.dart';
import 'dial_rules.dart';
import 'engine_controller.dart';
import 'history_controller.dart';
import 'providers.dart';
import 'settings_controller.dart';

/// A live call: engine [CallInfo] merged with UI/app state.
class UiCall {
  UiCall({
    required this.cid,
    required this.info,
    required this.direction,
    required this.startedAt,
    this.accountId = '',
  });

  final int cid;
  CallInfo info;
  String accountId;
  final CallDirection direction;
  final DateTime startedAt;
  DateTime? connectedAt;
  bool answered = false;

  /// Incoming call that arrived while another call was active.
  bool waiting = false;
  CallStats? stats;
  final List<double> mosHistory = [];
  double _mosSum = 0;
  int _mosN = 0;
  double mosMin = 0;
  double jitterMax = 0;
  double lossMax = 0;

  CallResult? forcedResult;
  String forcedReason = '';
  int forcedCode = 0;
  bool userDeclined = false;
  bool userHangup = false;
  bool transferredAway = false;

  /// Handled by policy (rejected/forwarded) before ever ringing; not shown.
  bool hidden = false;

  /// For a consultation call: the call being transferred.
  int? consultOf;
  String? recordingFile;
  String dialed = '';
  bool transferPending = false;
  Timer? noAnswerTimer;
  Timer? autoAnswerTimer;

  CallState get state => info.state;
  bool get isRingingIn =>
      info.role == CallRole.callee &&
      !answered &&
      (info.state == CallState.incoming || info.state == CallState.early);
  bool get isOutgoingProgress =>
      info.role != CallRole.callee &&
      (info.state == CallState.calling ||
          info.state == CallState.early ||
          info.state == CallState.connecting);
  bool get isConfirmed => info.state == CallState.confirmed;
  bool get isEnded => info.state == CallState.disconnected;
  bool get isHeld =>
      info.held ||
      info.media == MediaStatus.localHold ||
      info.media == MediaStatus.bothHold;
  bool get remoteHeld =>
      info.media == MediaStatus.remoteHold ||
      info.media == MediaStatus.bothHold;
  bool get isConference => info.conferenceWith.isNotEmpty;
  bool get muted => info.muted;
  bool get recording => info.recording;

  String get number => info.remoteUser.isNotEmpty
      ? info.remoteUser
      : userPart(info.remoteUri);

  Duration get duration => connectedAt == null
      ? Duration.zero
      : DateTime.now().difference(connectedAt!);

  void addMos(double mos, double jitter, double loss) {
    mosHistory.add(mos);
    if (mosHistory.length > 90) mosHistory.removeAt(0);
    if (mos > 0) {
      _mosSum += mos;
      _mosN++;
      mosMin = mosMin == 0 ? mos : min(mosMin, mos);
    }
    jitterMax = max(jitterMax, jitter);
    lossMax = max(lossMax, loss);
  }

  QualitySummary get quality => QualitySummary(
    mosAvg: _mosN == 0 ? 0 : _mosSum / _mosN,
    mosMin: mosMin,
    jitterMax: jitterMax,
    lossPct: lossMax,
  );
}

class CallsState {
  const CallsState({this.calls = const [], this.focusedCid});
  final List<UiCall> calls;
  final int? focusedCid;

  List<UiCall> get live => calls.where((c) => !c.isEnded).toList();
  bool get hasCalls => live.isNotEmpty;
  List<UiCall> get ringing =>
      live.where((c) => c.isRingingIn).toList();

  /// Calls that are not ringing in (answered, dialling or held).
  List<UiCall> get ongoing => live.where((c) => !c.isRingingIn).toList();

  UiCall? byCid(int cid) {
    for (final c in calls) {
      if (c.cid == cid) return c;
    }
    return null;
  }

  UiCall? get focused {
    final f = focusedCid == null ? null : byCid(focusedCid!);
    if (f != null && !f.isEnded && !f.isRingingIn) return f;
    final og = ongoing;
    if (og.isEmpty) return null;
    return og.firstWhere((c) => !c.isHeld, orElse: () => og.last);
  }
}

/// Which account the dialer will use (null = default).
class DialAccountController extends Notifier<String?> {
  @override
  String? build() => null;
  void select(String? id) => state = id;
}

final dialAccountProvider = NotifierProvider<DialAccountController, String?>(
  DialAccountController.new,
);

String describeCallFailure(int code, String reason) {
  switch (code) {
    case 400:
      return 'Invalid number (400)';
    case 401:
    case 403:
      return 'Call not authorised ($code)';
    case 404:
      return 'Number not found (404)';
    case 408:
      return 'No answer from server (408)';
    case 480:
      return 'Temporarily unavailable (480)';
    case 484:
      return 'Incomplete number (484)';
    case 486:
    case 600:
      return 'Busy ($code)';
    case 487:
      return 'Call cancelled (487)';
    case 488:
    case 606:
      return 'No compatible codec ($code)';
    case 503:
      return 'Service unavailable (503)';
    case 603:
      return 'Call declined (603)';
  }
  if (code == 0) return reason.isEmpty ? 'Call failed' : reason;
  return reason.isEmpty ? 'Call failed ($code)' : '$reason ($code)';
}

class CallsController extends Notifier<CallsState> {
  final Map<int, UiCall> _calls = {};
  int? _focused;
  Timer? _statsTimer;
  Timer? _waitingTimer;
  bool _ringing = false;
  final Set<String> _notified = {};
  int _generation = -1;
  bool _fgService = false;

  EngineController get _ctl => ref.read(engineProvider.notifier);
  SipEngine get _engine => _ctl.engine;
  AppSettings get _settings => ref.read(settingsProvider);
  PlatformServices get _platform => ref.read(platformServicesProvider);

  @override
  CallsState build() {
    final sub = _ctl.events.listen(_onEvent);
    final actions = _platform.systemCallActions.listen(_onSystemAction);
    _statsTimer = Timer.periodic(const Duration(seconds: 1), (_) => _pollStats());
    ref.onDispose(() {
      sub.cancel();
      actions.cancel();
      _statsTimer?.cancel();
      _waitingTimer?.cancel();
      for (final c in _calls.values) {
        c.noAnswerTimer?.cancel();
        c.autoAnswerTimer?.cancel();
      }
    });
    ref.listen<EngineState>(engineProvider, (prev, next) {
      if (next.running && next.generation != _generation) {
        _generation = next.generation;
        for (final c in _calls.values.toList()) {
          _finalize(c, forceEnded: true);
        }
        _calls.clear();
        _emit();
      }
    });
    return const CallsState();
  }

  void _emit() {
    final list = _calls.values.where((c) => !c.hidden).toList()
      ..sort((a, b) => a.startedAt.compareTo(b.startedAt));
    state = CallsState(calls: List.unmodifiable(list), focusedCid: _focused);
    _syncSideEffects();
  }

  void focus(int cid) {
    _focused = cid;
    _emit();
  }

  // ---- side effects (ringing, service, notifications) ----------------------

  void _syncSideEffects() {
    final live = _calls.values.where((c) => !c.isEnded).toList();
    final ringingNow = live.where((c) => c.isRingingIn && !c.waiting).toList();
    if (ringingNow.isNotEmpty && !_ringing) {
      _ringing = true;
      unawaited(_startRinger(ringingNow.first));
    } else if (ringingNow.isEmpty && _ringing) {
      _ringing = false;
      unawaited(_stopRinger());
    }
    final waitingNow = live.where((c) => c.isRingingIn && c.waiting).toList();
    if (waitingNow.isNotEmpty && _waitingTimer == null) {
      _waitingTimer = Timer.periodic(const Duration(seconds: 4), (_) {
        if (!_calls.values.any((c) => c.isRingingIn && c.waiting)) {
          _waitingTimer?.cancel();
          _waitingTimer = null;
        } else {
          _playWaiting();
        }
      });
    } else if (waitingNow.isEmpty) {
      _waitingTimer?.cancel();
      _waitingTimer = null;
    }
    final any = live.isNotEmpty;
    if (any && !_fgService) {
      _fgService = true;
      unawaited(_guard(() => _platform.startForegroundService(text: 'Call in progress')));
    } else if (!any && _fgService) {
      _fgService = false;
      unawaited(_guard(() => _platform.stopForegroundService()));
    }
    final connected = live.any((c) => c.isConfirmed);
    unawaited(_guard(() => _platform.setProximityEnabled(connected)));
    unawaited(_guard(() => _platform.setKeepScreenOn(any)));
    unawaited(
      _guard(
        () => _platform.updateTray(
          missedCalls: 0,
          inCall: connected,
          ringing: ringingNow.isNotEmpty,
          tooltip: connected ? 'In a call' : null,
        ),
      ),
    );
  }

  Future<void> _guard(Future<void> Function() f) async {
    try {
      await f();
    } catch (e) {
      debugPrint('platform call failed: $e');
    }
  }

  Future<void> _playWaiting() => _guard(() => _engine.playTone(ToneKind.waiting));

  Future<void> _startRinger(UiCall call) async {
    final contacts = ref.read(contactsProvider);
    final contact = findContact(contacts, call.number);
    final profile = ref.read(accountsProvider).byId(call.accountId);
    var tone = _settings.ringtone;
    if (profile != null && profile.ringtone != 'default') tone = profile.ringtone;
    if (contact != null && contact.ringtone != 'default') tone = contact.ringtone;
    if (_platform.ringsViaOs) {
      await _guard(
        () => _platform.startRingtone(ringtone: tone, volume: _settings.ringerVolume),
      );
    } else {
      final file = (tone.contains('/') || tone.contains(r'\')) ? tone : null;
      await _guard(
        () => _engine.ringStart(
          file: file,
          devId: _settings.ringerDev,
          volume: _settings.ringerVolume,
        ),
      );
    }
  }

  Future<void> _stopRinger() async {
    await _guard(() => _platform.stopRingtone());
    if (_ctl.hasEngine) {
      await _guard(() => _engine.ringStop());
    }
  }

  void _onSystemAction(SystemCallAction a) {
    final cid = int.tryParse(a.callKey);
    if (cid == null) return;
    switch (a.kind) {
      case SystemCallActionKind.answer:
        unawaited(answer(cid));
      case SystemCallActionKind.decline:
        unawaited(decline(cid));
      case SystemCallActionKind.end:
        unawaited(hangup(cid));
      case SystemCallActionKind.hold:
        unawaited(hold(cid));
      case SystemCallActionKind.unhold:
        unawaited(unhold(cid));
      case SystemCallActionKind.mute:
        unawaited(setMute(cid, true));
      case SystemCallActionKind.unmute:
        unawaited(setMute(cid, false));
    }
  }

  // ---- engine events ---------------------------------------------------------

  void _onEvent(EngineEvent e) {
    switch (e) {
      case CallIncomingEvent():
        _onIncoming(e);
      case CallStateEvent():
        _onState(e);
      case CallMediaEvent():
        final c = _calls[e.cid];
        if (c == null) return;
        c.info = c.info.copyWith(
          media: e.media,
          codec: e.codec,
          srtp: e.srtp,
          secureSignaling: e.secureSignaling,
        );
        _emit();
        unawaited(_refresh(e.cid));
      case CallStatsEvent():
        _applyStats(e.stats);
      case CallRecordingEvent():
        final c = _calls[e.cid];
        if (c == null) return;
        c.info = c.info.copyWith(recording: e.recording);
        if (e.file.isNotEmpty) c.recordingFile = e.file;
        _emit();
      case CallTransferStatusEvent():
        _onTransferStatus(e);
      case CallTransferRequestEvent():
        final c = _calls[e.cid];
        if (c != null) {
          c.transferredAway = true;
          c.forcedResult = CallResult.transferred;
        }
      case CallReplacedEvent():
        final old = _calls[e.oldCid];
        final nw = _calls[e.newCid];
        if (old != null && nw != null) {
          nw.answered = old.answered;
          nw.connectedAt ??= old.connectedAt;
          old.forcedResult = CallResult.transferred;
        }
      case CallRedirectedEvent():
        unawaited(_guard(() => _engine.processRedirect(e.cid, RedirectAction.accept)));
      case ResyncSnapshotEvent():
        _reconcile(e.snapshot.calls);
      default:
    }
  }

  void _reconcile(List<CallInfo> snapshot) {
    final ids = snapshot.map((c) => c.cid).toSet();
    for (final c in snapshot) {
      final ex = _calls[c.cid];
      if (ex == null) {
        _calls[c.cid] = UiCall(
          cid: c.cid,
          info: c,
          direction: c.role == CallRole.callee
              ? CallDirection.incoming
              : CallDirection.outgoing,
          startedAt: DateTime.now().subtract(Duration(milliseconds: c.totalMs)),
          accountId: c.uid,
        )
          ..answered = c.state == CallState.confirmed
          ..connectedAt = c.state == CallState.confirmed
              ? DateTime.now().subtract(Duration(milliseconds: c.connectMs))
              : null;
      } else {
        ex.info = c;
      }
    }
    for (final c in _calls.values.toList()) {
      if (!ids.contains(c.cid) && !c.isEnded) {
        c.info = c.info.copyWith(state: CallState.disconnected);
        _finalize(c);
      }
    }
    _emit();
  }

  Future<void> _refresh(int cid) async {
    final c = _calls[cid];
    if (c == null || c.isEnded || !_ctl.hasEngine) return;
    try {
      final info = await _engine.callInfo(cid);
      final cur = _calls[cid];
      if (cur == null || cur.isEnded) return;
      cur.info = info.copyWith(
        remoteDisplay: info.remoteDisplay.isEmpty
            ? cur.info.remoteDisplay
            : info.remoteDisplay,
      );
      _emit();
    } catch (_) {}
  }

  void _onState(CallStateEvent e) {
    var c = _calls[e.cid];
    final s = e.call;
    if (c == null) {
      c = UiCall(
        cid: e.cid,
        info: s,
        direction: s.role == CallRole.callee
            ? CallDirection.incoming
            : CallDirection.outgoing,
        startedAt: DateTime.now(),
        accountId: s.uid,
      );
      if (s.state == CallState.disconnected) {
        // Unknown call that ended immediately: still record it.
        _calls[e.cid] = c;
        _finalize(c);
        _calls.remove(e.cid);
        _emit();
        return;
      }
      _calls[e.cid] = c;
      if (c.direction == CallDirection.outgoing) {
        _focused = e.cid;
        c.dialed = s.remoteUser;
        unawaited(
          _guard(
            () => _platform.reportOutgoingCall(
              callKey: '${e.cid}',
              handle: c!.number,
              displayName: s.remoteDisplay,
            ),
          ),
        );
      }
    }
    final prevState = c.info.state;
    c.info = c.info.copyWith(
      state: s.state,
      stateCode: s.stateCode,
      stateReason: s.stateReason,
      lastCode: s.lastCode,
      remoteUri: s.remoteUri.isNotEmpty ? s.remoteUri : null,
      remoteDisplay: s.remoteDisplay.isNotEmpty ? s.remoteDisplay : null,
      remoteUser: s.remoteUser.isNotEmpty ? s.remoteUser : null,
      connectMs: s.connectMs,
      totalMs: s.totalMs,
    );
    if (s.state == CallState.confirmed && prevState != CallState.confirmed) {
      c.answered = true;
      c.connectedAt ??= DateTime.now();
      c.noAnswerTimer?.cancel();
      _focused = c.cid;
      unawaited(_guard(() => _platform.reportCallConnected('${c!.cid}')));
      unawaited(_refresh(c.cid));
      if (_settings.autoRecord && !c.recording) {
        unawaited(startRecording(c.cid));
      }
    }
    if (s.state == CallState.disconnected) {
      _finalize(c);
      _calls.remove(c.cid);
      if (_focused == c.cid) _focused = null;
    }
    _emit();
  }

  void _onTransferStatus(CallTransferStatusEvent e) {
    final c = _calls[e.cid];
    if (c == null || !e.isFinal) return;
    c.transferPending = false;
    if (e.code >= 200 && e.code < 300) {
      c.transferredAway = true;
      c.forcedResult = CallResult.transferred;
      unawaited(_guard(() => _engine.hangup(e.cid)));
    } else {
      ref.read(noticeProvider.notifier).error(
        'Transfer failed: ${e.reason} (${e.code})',
      );
      unawaited(_guard(() => _engine.unhold(e.cid)));
    }
    _emit();
  }

  void _applyStats(CallStats s) {
    final c = _calls[s.cid];
    if (c == null) return;
    c.stats = s;
    c.addMos(s.mos, s.rx.jitterMaxMs, s.rx.lossPct);
    _emit();
  }

  Future<void> _pollStats() async {
    if (!_ctl.hasEngine) return;
    final f = state.focused;
    if (f == null || !f.isConfirmed) return;
    try {
      _applyStats(await _engine.callStats(f.cid));
    } catch (_) {}
  }

  // ---- incoming policy -------------------------------------------------------

  String _uriFor(String target, AccountProfile? profile) {
    final t = target.trim();
    if (t.contains('@') || t.toLowerCase().startsWith('sip')) {
      return t.toLowerCase().startsWith('sip') ? t : 'sip:$t';
    }
    return 'sip:$t@${profile?.config.domain ?? ''}';
  }

  bool _isBlocked(CallInfo i) {
    final list = _settings.blocklist;
    if (list.isEmpty) return false;
    for (final b in list) {
      if (b.trim().isEmpty) continue;
      if (sameNumber(i.remoteUri, b) || i.remoteUri.contains(b)) return true;
    }
    return false;
  }

  bool _isAnonymous(CallInfo i) {
    final u = i.remoteUser.toLowerCase();
    return u == 'anonymous' ||
        i.remoteUri.toLowerCase().contains('anonymous@anonymous') ||
        i.remoteDisplay.toLowerCase() == 'anonymous';
  }

  void _onIncoming(CallIncomingEvent ev) {
    final info = ev.call;
    final profile = ref.read(accountsProvider).byId(info.uid);
    final c = UiCall(
      cid: ev.cid,
      info: info,
      direction: CallDirection.incoming,
      startedAt: DateTime.now(),
      accountId: profile?.id ?? info.uid,
    );
    final others = _calls.values.where((o) => !o.isEnded && !o.isRingingIn).toList();
    c.waiting = others.isNotEmpty;
    _calls[ev.cid] = c;

    Future<void> reject(int code, String reason, CallResult result) async {
      c.hidden = true;
      c.forcedResult = result;
      c.forcedReason = reason;
      c.forcedCode = code;
      await _guard(() => _engine.reject(ev.cid, code: code, reason: reason));
    }

    Future<void> redirect(String target, String why) async {
      c.hidden = true;
      c.forcedResult = CallResult.forwarded;
      c.forcedReason = why;
      c.forcedCode = 302;
      await _guard(
        () => _engine.redirect(ev.cid, [_uriFor(target, profile)]),
      );
    }

    final s = _settings;
    final fwd = profile?.forwarding;

    // 1. blocklist / anonymous
    if (_isBlocked(info)) {
      unawaited(reject(603, 'Blocked', CallResult.rejected));
      _emit();
      return;
    }
    if (s.rejectAnonymous && _isAnonymous(info)) {
      unawaited(reject(433, 'Anonymity disallowed', CallResult.rejected));
      _emit();
      return;
    }
    // 2. DND (global, status, account)
    if (s.dnd || s.globalStatus == 'dnd' || (profile?.dnd ?? false)) {
      unawaited(reject(s.dndRejectCode, 'Do not disturb', CallResult.rejected));
      _emit();
      return;
    }
    // 3. forward always
    if (fwd != null && fwd.mode == ForwardMode.always && fwd.active) {
      unawaited(redirect(fwd.target, 'Forwarded (always)'));
      _emit();
      return;
    }
    // 4. busy handling
    if (others.isNotEmpty) {
      if (fwd != null && fwd.mode == ForwardMode.busy && fwd.active) {
        unawaited(redirect(fwd.target, 'Forwarded (busy)'));
        _emit();
        return;
      }
      if (!s.callWaiting) {
        unawaited(reject(s.busyRejectCode, 'Busy', CallResult.busy));
        _emit();
        return;
      }
    }
    // 5. auto answer
    final hint = ev.autoAnswerHint;
    int? answerAfter;
    final aa = profile?.autoAnswer;
    final cfgOn = (aa?.enabled ?? false) || s.autoAnswer;
    final cfgNeedsHeader = aa?.onlyIntercomHeaders ?? false;
    if (cfgOn && (!cfgNeedsHeader || hint != null)) {
      answerAfter = (aa?.enabled ?? false) ? aa!.delaySec : s.autoAnswerDelay;
    }
    if (answerAfter == null && hint != null && s.allowAutoAnswerHeaders) {
      answerAfter = hint.afterSec;
    }
    if (answerAfter != null && others.isNotEmpty && !(hint?.require ?? false)) {
      answerAfter = null; // never steal an ongoing call
    }
    // 6. ring
    unawaited(_guard(() => _engine.ring(ev.cid)));
    if (c.waiting) {
      unawaited(_playWaiting());
    }
    if (answerAfter != null) {
      final d = answerAfter;
      if (d <= 0) {
        unawaited(answer(ev.cid));
      } else {
        c.autoAnswerTimer = Timer(Duration(seconds: d), () {
          if (_calls[ev.cid]?.isRingingIn ?? false) unawaited(answer(ev.cid));
        });
      }
    }
    if (fwd != null && fwd.mode == ForwardMode.noAnswer && fwd.active) {
      c.noAnswerTimer = Timer(Duration(seconds: max(1, fwd.noAnswerSec)), () {
        if (_calls[ev.cid]?.isRingingIn ?? false) {
          unawaited(redirect(fwd.target, 'Forwarded (no answer)'));
        }
      });
    }
    // 7. notify
    final contacts = ref.read(contactsProvider);
    final name = nameForNumber(
      contacts,
      c.number,
      info.remoteDisplay.isNotEmpty ? info.remoteDisplay : c.number,
    );
    unawaited(
      _guard(
        () => _platform.reportIncomingCall(
          callKey: '${ev.cid}',
          handle: c.number,
          displayName: name,
        ),
      ),
    );
    unawaited(
      _guard(
        () => _platform.showIncomingCallNotification(
          callKey: '${ev.cid}',
          title: name,
          body: 'Incoming call${profile != null ? ' on ${profile.name}' : ''}',
          accountName: profile?.name,
        ),
      ),
    );
    unawaited(_guard(() => _platform.bringToFront()));
    _notified.add('${ev.cid}');
    _emit();
  }

  // ---- finalising ------------------------------------------------------------

  void _finalize(UiCall c, {bool forceEnded = false}) {
    c.noAnswerTimer?.cancel();
    c.autoAnswerTimer?.cancel();
    if (_notified.remove('${c.cid}')) {
      unawaited(_guard(() => _platform.cancelIncomingCallNotification('${c.cid}')));
    }
    unawaited(_guard(() => _platform.reportCallEnded('${c.cid}')));

    final incoming = c.direction == CallDirection.incoming;
    CallResult result;
    if (c.forcedResult != null) {
      result = c.forcedResult!;
    } else if (c.answered) {
      result = c.transferredAway ? CallResult.transferred : CallResult.answered;
    } else if (incoming) {
      result = c.userDeclined ? CallResult.rejected : CallResult.missed;
    } else {
      final code = c.info.lastCode;
      if (code == 486 || code == 600) {
        result = CallResult.busy;
      } else if (code == 603) {
        result = CallResult.rejected;
      } else {
        result = CallResult.failed;
      }
    }
    final contacts = ref.read(contactsProvider);
    final number = c.number.isNotEmpty ? c.number : c.dialed;
    final display = c.info.remoteDisplay.isNotEmpty
        ? c.info.remoteDisplay
        : nameForNumber(contacts, number, '');
    final end = DateTime.now();
    final rec = CallRecord(
      id: newId(),
      accountId: c.accountId,
      direction: c.direction,
      remoteUri: c.info.remoteUri,
      remoteNumber: number,
      remoteDisplay: display,
      start: c.startedAt,
      connectMs: c.connectedAt == null
          ? 0
          : c.connectedAt!.difference(c.startedAt).inMilliseconds,
      durationMs: c.connectedAt == null
          ? 0
          : end.difference(c.connectedAt!).inMilliseconds,
      result: result,
      sipCode: c.forcedCode != 0 ? c.forcedCode : c.info.lastCode,
      reason: c.forcedReason.isNotEmpty ? c.forcedReason : c.info.stateReason,
      recordingPath: c.recordingFile,
      quality: c.quality,
    );
    unawaited(ref.read(historyProvider.notifier).add(rec));

    if (result == CallResult.missed) {
      unawaited(
        _guard(
          () => _platform.showMissedCallNotification(
            title: 'Missed call',
            body: display.isNotEmpty ? display : number,
          ),
        ),
      );
    }
    if (!incoming &&
        !c.answered &&
        !c.userHangup &&
        c.forcedResult == null &&
        !forceEnded) {
      ref.read(noticeProvider.notifier).error(
        describeCallFailure(c.info.lastCode, c.info.stateReason),
        details: 'SIP ${c.info.lastCode} ${c.info.stateReason}',
      );
    }
  }

  // ---- dialling ---------------------------------------------------------------

  DialRules dialRules() {
    final s = _settings;
    return DialRules(
      rules: [for (final r in s.dialRules) DialRule.fromJson(r)],
      emergencyNumbers: s.emergencyNumbers,
    );
  }

  AccountProfile? _pickAccount(String? explicit, DialResult res) {
    final acc = ref.read(accountsProvider);
    for (final id in [explicit, res.accountId, ref.read(dialAccountProvider)]) {
      if (id == null) continue;
      final p = acc.byId(id);
      if (p != null && p.enabled) return p;
    }
    return acc.defaultProfile;
  }

  /// Dials [input] (after dial rules). Returns the call id or null.
  Future<int?> dial(
    String input, {
    String? accountId,
    Map<String, String>? headers,
    bool applyRules = true,
    bool holdOthers = true,
  }) async {
    final notices = ref.read(noticeProvider.notifier);
    if (!_ctl.hasEngine) {
      notices.error('The call engine is not running yet');
      return null;
    }
    final res = applyRules ? dialRules().apply(input) : DialResult(input.trim());
    if (res.target.isEmpty) return null;
    var profile = _pickAccount(accountId, res);
    final accState = ref.read(accountsProvider);
    if (res.emergency) {
      // Emergency numbers go out through any registered account.
      profile = accState.profiles.firstWhere(
        (p) => accState.statusOf(p.id) == AccountStatus.registered,
        orElse: () => profile ?? accState.profiles.first,
      );
    }
    AccountRef ref0;
    if (profile == null) {
      final looksDirect = res.isUri || RegExp(r'^\d{1,3}(\.\d{1,3}){3}').hasMatch(res.target);
      if (!looksDirect) {
        notices.error('Add an account to place calls');
        return null;
      }
      ref0 = const AccountRef.direct();
    } else {
      final st = accState.statusOf(profile.id);
      if (st == AccountStatus.failed || st == AccountStatus.disabled) {
        notices.error(
          '${profile.name} is not registered',
          details: accState.errorOf(profile.id),
        );
        return null;
      }
      ref0 = AccountRef.uid(profile.id);
    }
    if (holdOthers) await _holdActive();
    try {
      final r = await _engine.makeCall(
        acc: ref0,
        uri: res.target,
        headers: headers,
      );
      final c = _calls[r.cid];
      if (c != null) {
        c.dialed = res.target;
        c.accountId = profile?.id ?? c.accountId;
      }
      _focused = r.cid;
      _emit();
      return r.cid;
    } on EngineException catch (e) {
      notices.error('Could not place the call', details: e.toString());
      return null;
    }
  }

  Future<void> _holdActive({int? except}) async {
    for (final c in _calls.values.toList()) {
      if (c.cid == except) continue;
      if (c.isConfirmed && !c.isHeld && !c.isConference) {
        await _guard(() => _engine.hold(c.cid));
      }
    }
    // Refresh infos so UI shows "on hold".
    for (final c in _calls.values.toList()) {
      if (c.isConfirmed) await _refresh(c.cid);
    }
  }

  Future<void> redial() async {
    final last = ref.read(historyProvider.notifier).lastOutgoing;
    if (last != null) {
      await dial(last.remoteNumber.isNotEmpty ? last.remoteNumber : last.remoteUri,
          accountId: last.accountId.isEmpty ? null : last.accountId);
    }
  }

  // ---- call actions -----------------------------------------------------------

  Future<void> answer(int cid) async {
    final c = _calls[cid];
    if (c == null || !_ctl.hasEngine) return;
    c.autoAnswerTimer?.cancel();
    c.noAnswerTimer?.cancel();
    c.waiting = false;
    await _holdActive(except: cid);
    try {
      await _engine.answer(cid);
      _focused = cid;
    } on EngineException catch (e) {
      ref.read(noticeProvider.notifier).error('Could not answer', details: '$e');
    }
    _emit();
  }

  Future<void> decline(int cid, {int code = 603}) async {
    final c = _calls[cid];
    if (c == null) return;
    c.userDeclined = true;
    c.autoAnswerTimer?.cancel();
    await _guard(() => _engine.reject(cid, code: code));
  }

  /// Sends the ringing call to voicemail (redirect).
  Future<void> redirectToVoicemail(int cid) async {
    final c = _calls[cid];
    if (c == null) return;
    final profile = ref.read(accountsProvider).byId(c.accountId);
    final vm = profile?.effectiveVoicemail ?? '';
    if (vm.isEmpty) {
      ref.read(noticeProvider.notifier).error('No voicemail number set for this account');
      return;
    }
    c.forcedResult = CallResult.forwarded;
    c.forcedReason = 'Sent to voicemail';
    c.forcedCode = 302;
    await _guard(() => _engine.redirect(cid, [_uriFor(vm, profile)]));
  }

  Future<void> redirectTo(int cid, String target) async {
    final c = _calls[cid];
    if (c == null) return;
    final profile = ref.read(accountsProvider).byId(c.accountId);
    c.forcedResult = CallResult.forwarded;
    c.forcedReason = 'Redirected';
    c.forcedCode = 302;
    await _guard(() => _engine.redirect(cid, [_uriFor(target, profile)]));
  }

  Future<void> hangup(int cid) async {
    final c = _calls[cid];
    if (c == null) return;
    c.userHangup = true;
    if (c.isRingingIn) c.userDeclined = true;
    await _guard(() => _engine.hangup(cid));
  }

  Future<void> hangupAll() async {
    for (final c in _calls.values) {
      c.userHangup = true;
    }
    await _guard(() => _engine.hangupAll());
  }

  Future<void> hold(int cid) async {
    await _guard(() => _engine.hold(cid));
    await _refresh(cid);
  }

  Future<void> unhold(int cid) async {
    // Only one active (un-held) call unless merged.
    await _holdActive(except: cid);
    await _guard(() => _engine.unhold(cid));
    _focused = cid;
    await _refresh(cid);
  }

  Future<void> toggleHold(int cid) async {
    final c = _calls[cid];
    if (c == null) return;
    if (c.isHeld) {
      await unhold(cid);
    } else {
      await hold(cid);
    }
  }

  Future<void> swap() async {
    final list = _calls.values.where((c) => c.isConfirmed).toList();
    if (list.length < 2) return;
    final active = state.focused ?? list.first;
    final other = list.firstWhere((c) => c.cid != active.cid);
    await _guard(() => _engine.hold(active.cid));
    await _guard(() => _engine.unhold(other.cid));
    _focused = other.cid;
    await _refresh(active.cid);
    await _refresh(other.cid);
  }

  Future<void> setMute(int cid, bool mute) async {
    await _guard(() => _engine.mute(cid, mute));
    final c = _calls[cid];
    if (c != null) {
      c.info = c.info.copyWith(muted: mute);
      _emit();
    }
    await _refresh(cid);
  }

  Future<void> toggleMute(int cid) async {
    final c = _calls[cid];
    if (c != null) await setMute(cid, !c.muted);
  }

  Future<void> sendDtmf(int cid, String digits) async {
    if (digits.isEmpty) return;
    await _guard(() => _engine.sendDtmf(cid, digits));
    await _guard(() => _engine.playTone(ToneKind.dtmf, digits: digits));
  }

  /// Local DTMF feedback tone only (keypad press outside a call).
  Future<void> playLocalDtmf(String digit) async {
    if (!_ctl.hasEngine) return;
    await _guard(() => _engine.playTone(ToneKind.dtmf, digits: digit));
  }

  Future<bool> transferBlind(int cid, String target) async {
    final c = _calls[cid];
    if (c == null) return false;
    final res = dialRules().apply(target);
    if (res.target.isEmpty) return false;
    try {
      c.transferPending = true;
      await _engine.transfer(cid, res.target);
      _emit();
      return true;
    } on EngineException catch (e) {
      c.transferPending = false;
      ref.read(noticeProvider.notifier).error('Transfer failed', details: '$e');
      return false;
    }
  }

  /// Starts an attended transfer: holds [origCid] and calls [target].
  Future<int?> startConsult(int origCid, String target) async {
    final orig = _calls[origCid];
    if (orig == null) return null;
    await _guard(() => _engine.hold(origCid));
    final cid = await dial(
      target,
      accountId: orig.accountId.isEmpty ? null : orig.accountId,
      holdOthers: false,
    );
    if (cid == null) {
      await _guard(() => _engine.unhold(origCid));
      return null;
    }
    _calls[cid]?.consultOf = origCid;
    _emit();
    return cid;
  }

  Future<bool> completeAttended(int consultCid) async {
    final consult = _calls[consultCid];
    final orig = consult?.consultOf == null ? null : _calls[consult!.consultOf!];
    if (consult == null || orig == null) return false;
    try {
      orig.transferPending = true;
      await _engine.transferAttended(orig.cid, consultCid);
      consult.transferredAway = true;
      consult.forcedResult = CallResult.transferred;
      _emit();
      return true;
    } on EngineException catch (e) {
      orig.transferPending = false;
      ref.read(noticeProvider.notifier).error('Transfer failed', details: '$e');
      return false;
    }
  }

  Future<void> cancelConsult(int consultCid) async {
    final consult = _calls[consultCid];
    if (consult == null) return;
    final origCid = consult.consultOf;
    consult.userHangup = true;
    await _guard(() => _engine.hangup(consultCid));
    if (origCid != null) {
      await _guard(() => _engine.unhold(origCid));
      _focused = origCid;
      await _refresh(origCid);
    }
  }

  Future<void> merge() async {
    final cids = _calls.values
        .where((c) => c.isConfirmed)
        .map((c) => c.cid)
        .toList();
    if (cids.length < 2) return;
    try {
      await _engine.conference(cids);
    } on EngineException catch (e) {
      ref.read(noticeProvider.notifier).error('Could not merge calls', details: '$e');
    }
    for (final id in cids) {
      await _refresh(id);
    }
  }

  Future<void> split() async {
    final cids = _calls.values
        .where((c) => c.isConfirmed && c.isConference)
        .map((c) => c.cid)
        .toList();
    if (cids.isEmpty) return;
    await _guard(() => _engine.unconference(cids));
    for (final id in cids) {
      await _refresh(id);
    }
    // Keep only the focused call live.
    final f = state.focused ?? _calls[cids.first];
    if (f != null) {
      for (final id in cids.where((i) => i != f.cid)) {
        await _guard(() => _engine.hold(id));
        await _refresh(id);
      }
    }
  }

  Future<String> _recordingsDir() async {
    final s = _settings;
    if (s.recordingFolder.isNotEmpty) {
      await Directory(s.recordingFolder).create(recursive: true);
      return s.recordingFolder;
    }
    return ref.read(recordingsDirProvider)();
  }

  Future<void> startRecording(int cid) async {
    final c = _calls[cid];
    if (c == null) return;
    try {
      final dir = await _recordingsDir();
      final t = DateTime.now();
      String two(int n) => n.toString().padLeft(2, '0');
      final safe = c.number.replaceAll(RegExp(r'[^A-Za-z0-9+_-]'), '');
      final name =
          'rec_${t.year}${two(t.month)}${two(t.day)}_${two(t.hour)}${two(t.minute)}${two(t.second)}_$safe.wav';
      final file = await _engine.recordStart(cid, p.join(dir, name));
      c.recordingFile = file;
      c.info = c.info.copyWith(recording: true);
      _emit();
    } on EngineException catch (e) {
      ref.read(noticeProvider.notifier).error('Could not start recording', details: '$e');
    }
  }

  Future<void> stopRecording(int cid) async {
    final c = _calls[cid];
    if (c == null) return;
    try {
      final r = await _engine.recordStop(cid);
      c.recordingFile = r.file.isNotEmpty ? r.file : c.recordingFile;
      c.info = c.info.copyWith(recording: false);
      if (c.recordingFile != null) {
        await ref.read(recordingsRepoProvider).put(
          RecordingMeta(
            id: newId(),
            path: c.recordingFile!,
            remote: c.number,
            time: DateTime.now(),
            durationMs: r.durationMs,
            accountId: c.accountId,
          ),
        );
      }
      _emit();
    } on EngineException catch (e) {
      ref.read(noticeProvider.notifier).error('Could not stop recording', details: '$e');
    }
  }

  Future<void> toggleRecording(int cid) async {
    final c = _calls[cid];
    if (c == null) return;
    if (c.recording) {
      await stopRecording(cid);
    } else {
      await startRecording(cid);
    }
  }

  /// Parks the call by blind-transferring it to the park feature code.
  Future<void> park(int cid) async {
    final c = _calls[cid];
    if (c == null) return;
    final profile = ref.read(accountsProvider).byId(c.accountId);
    final code = profile?.featureCodes.park ?? const FeatureCodes().park;
    try {
      c.transferPending = true;
      await _engine.transfer(cid, code);
      ref.read(noticeProvider.notifier).show('Parking call (dial $code)');
    } on EngineException catch (e) {
      c.transferPending = false;
      ref.read(noticeProvider.notifier).error('Park failed', details: '$e');
    }
  }

  /// Picks up a ringing extension (directed) or the group via feature codes.
  Future<int?> pickup({String? extension, String? accountId}) async {
    final profile =
        ref.read(accountsProvider).byId(accountId ?? '') ??
        ref.read(accountsProvider).defaultProfile;
    if (profile == null) return null;
    final fc = profile.featureCodes;
    final code = (extension == null || extension.isEmpty)
        ? fc.pickupGroup
        : '${fc.pickupDirectedPrefix}$extension';
    return dial(code, accountId: profile.id, applyRules: false);
  }

  Future<void> handoffToLan(
    int cid,
    LanDevice device, {
    HandoffMode mode = HandoffMode.blind,
  }) async {
    final c = _calls[cid];
    try {
      await ref.read(lanHandoffProvider).handoff(cid: cid, device: device, mode: mode);
      if (c != null) {
        c.forcedResult = CallResult.handedOff;
        c.forcedReason = 'Handed off to ${device.name}';
      }
    } catch (e) {
      ref.read(noticeProvider.notifier).error('Hand-off failed', details: '$e');
    }
  }

  Future<void> forwardIncomingToLan(int cid, LanDevice device) async {
    final c = _calls[cid];
    try {
      await ref.read(lanHandoffProvider).forwardIncoming(cid: cid, device: device);
      if (c != null) {
        c.forcedResult = CallResult.handedOff;
        c.forcedReason = 'Sent to ${device.name}';
      }
    } catch (e) {
      ref.read(noticeProvider.notifier).error('Could not send to device', details: '$e');
    }
  }
}

final callsProvider = NotifierProvider<CallsController, CallsState>(
  CallsController.new,
);
