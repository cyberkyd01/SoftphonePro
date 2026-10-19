import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart' show AppLifecycleState, WidgetsBinding;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:spcore_dart/spcore_dart.dart';

import '../audio/announcement_service.dart';
import '../audio/hold_music.dart';
import '../core/format.dart';
import '../l10n/l10n.dart';
import '../models/account_profile.dart';
import '../models/app_settings.dart';
import '../models/call_record.dart';
import '../models/chat.dart';
import '../storage/repositories.dart';
import '../lan/lan_handoff_impl.dart';
import '../lan/lan_models.dart';
import '../platform/lan_handoff.dart';
import '../platform/ios/ios_platform_services.dart';
import '../recordings/recording_formats.dart';
import '../recordings/recording_rules.dart';
import '../recordings/recordings_controller.dart';
import 'call_journal.dart';
import '../platform/platform_services.dart';
import 'accounts_controller.dart';
import 'caller_identity.dart';
import 'contacts_controller.dart';
import 'dial_rules.dart';
import 'engine_controller.dart';
import 'history_controller.dart';
import 'providers.dart';
import 'ringtones.dart';
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

  /// Quality time series (decimated to <= 240 points) for charts and history.
  final List<QualitySample> samples = [];
  int _sampleStride = 1;
  int _sampleTick = 0;
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

  /// Internal LAN relay leg: hidden, never recorded in history.
  bool silent = false;

  /// Set for calls over the LAN transport / transferred by a LAN device.
  LanCallMeta? lan;

  /// For a consultation call: the call being transferred.
  int? consultOf;
  String? recordingFile;
  String dialed = '';
  bool transferPending = false;

  /// Target of the blind transfer in progress and whether the server has not
  /// confirmed it after [kTransferConfirmTimeout].
  String transferTarget = '';
  bool transferStalled = false;
  Timer? transferTimer;

  /// Id the history record of this call will get (known early so that
  /// recordings can point at it).
  final String historyId = newId();

  /// Recording state: ids of this call's recordings (in order), the current
  /// segment, and recordings of related calls (transfer legs).
  final List<String> recordingIds = [];
  String? recordingId;
  RecordFormat recordingFormat = RecordFormat.wav;
  DateTime? recordingStartedAt;
  bool recordingPersisted = true;
  final Set<String> linkedRecordingIds = {};

  /// `Referred-By` of the REFER that spawned this call (from the parent).
  String referredByEvent = '';
  String journalKey = '';
  DateTime? journalBeatAt;

  /// Per-party levels in a conference (1.0 = unity): what we hear from this
  /// party (rx) and what this party hears of our microphone (tx).
  double rxLevel = 1.0;
  double txLevel = 1.0;
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

  void addSample(CallStats s) {
    if (_sampleTick++ % _sampleStride != 0) return;
    final t = connectedAt == null ? 0.0 : DateTime.now().difference(connectedAt!).inMilliseconds / 1000;
    samples.add(QualitySample(t: t, mos: s.mos, jitter: s.rx.jitterMs, loss: s.rx.lossPct, rtt: s.rtt.lastMs));
    if (samples.length > 240) {
      final keep = <QualitySample>[for (var i = 0; i < samples.length; i += 2) samples[i]];
      samples
        ..clear()
        ..addAll(keep);
      _sampleStride *= 2;
    }
  }

  QualitySummary get quality => QualitySummary(
    mosAvg: _mosN == 0 ? 0 : _mosSum / _mosN,
    mosMin: mosMin,
    jitterMax: jitterMax,
    lossPct: lossMax,
    samples: samples.length <= 120 ? List.of(samples) : [for (var i = 0; i < samples.length; i += 2) samples[i]],
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

/// Selector value meaning "no account": place the call over the direct
/// (account-less) transport.
const String kDirectAccountId = '__direct__';

/// DTMF digits typed on the system call UI (iOS CallKit); null elsewhere.
/// Overridable in tests.
final systemDtmfProvider = Provider<Stream<({String callKey, String digits})>?>((ref) {
  final p = ref.watch(platformServicesProvider);
  return p is IosPlatformServices ? p.systemDtmf : null;
});

/// A redirect (3xx) that needs the user's decision.
class RedirectPrompt {
  const RedirectPrompt({required this.cid, required this.target, required this.code});
  final int cid;
  final String target;
  final int code;
}

class RedirectPromptController extends Notifier<RedirectPrompt?> {
  @override
  RedirectPrompt? build() => null;
  void set(RedirectPrompt? p) => state = p;
}

final redirectPromptProvider = NotifierProvider<RedirectPromptController, RedirectPrompt?>(
  RedirectPromptController.new,
);

/// True when [target] points at an IPv4/IPv6 literal host (`sip:u@1.2.3.4`,
/// `u@[::1]:5060`, bare `1.2.3.4`); returns the literal or null.
String? ipLiteralHost(String target) {
  var t = target.trim();
  final m = RegExp(r'^sips?:', caseSensitive: false).firstMatch(t);
  if (m != null) t = t.substring(m.end);
  final at = t.lastIndexOf('@');
  if (at >= 0) t = t.substring(at + 1);
  t = t.split(RegExp(r'[;?>]')).first;
  if (t.startsWith('[')) {
    final end = t.indexOf(']');
    if (end > 1) {
      final h = t.substring(1, end);
      return InternetAddress.tryParse(h)?.type == InternetAddressType.IPv6 ? h : null;
    }
    return null;
  }
  final host = t.contains(':') && t.split(':').length == 2 ? t.split(':').first : t;
  return InternetAddress.tryParse(host)?.type == InternetAddressType.IPv4 ? host : null;
}

/// How long a blind transfer may stay unanswered by the server before the
/// UI offers to keep the call or retry.
const Duration kTransferConfirmTimeout = Duration(seconds: 10);

/// Interval of the recording beep while a call is being recorded.
const Duration kRecordBeepInterval = Duration(seconds: 15);

String describeCallFailure(AppLocalizations l, int code, String reason) {
  switch (code) {
    case 400:
      return l.callFailInvalidNumber;
    case 401:
    case 403:
      return l.callFailNotAuthorised('$code');
    case 404:
      return l.callFailNumberNotFound;
    case 408:
      return l.callFailNoAnswerFromServer;
    case 480:
      return l.callFailTemporarilyUnavailable;
    case 484:
      return l.callFailIncompleteNumber;
    case 486:
    case 600:
      return l.callFailBusy('$code');
    case 487:
      return l.callFailCancelled;
    case 488:
    case 606:
      return l.callFailNoCompatibleCodec('$code');
    case 503:
      return l.callFailServiceUnavailable;
    case 603:
      return l.callFailDeclined;
  }
  if (code == 0) return reason.isEmpty ? l.callFailGeneric : reason;
  return reason.isEmpty ? l.callFailGenericWithCode('$code') : l.callFailReasonWithCode(reason, '$code');
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
  // Per-cid LAN call attributes: the engine's call events can be processed
  // before or after makeCall returns, so both paths consult these maps.
  final Map<int, LanCallMeta?> _lanOutMeta = {};
  final Set<int> _silentCids = {};
  // Side effects are only pushed to the platform when their value changes.
  bool? _lastProximity;
  bool? _lastKeepOn;
  ({bool inCall, bool ringing})? _lastTray;
  // Call-progress tone currently owned by us (ringback / busy / congestion).
  ToneKind? _tone;
  Timer? _toneTimer;
  // Recording-beep timers per cid.
  final Map<int, Timer> _beepTimers = {};

  EngineController get _ctl => ref.read(engineProvider.notifier);
  SipEngine get _engine => _ctl.engine;
  AppSettings get _settings => ref.read(settingsProvider);
  PlatformServices get _platform => ref.read(platformServicesProvider);

  @override
  CallsState build() {
    final sub = _ctl.events.listen(_onEvent);
    final actions = _platform.systemCallActions.listen(_onSystemAction);
    final dtmfSub = ref.read(systemDtmfProvider)?.listen((e) {
      final cid = int.tryParse(e.callKey);
      if (cid != null && _calls.containsKey(cid)) unawaited(sendDtmf(cid, e.digits));
    });
    _statsTimer = Timer.periodic(const Duration(seconds: 1), (_) => _pollStats());
    ref.onDispose(() {
      sub.cancel();
      actions.cancel();
      dtmfSub?.cancel();
      _statsTimer?.cancel();
      _waitingTimer?.cancel();
      _toneTimer?.cancel();
      for (final t in _beepTimers.values) {
        t.cancel();
      }
      _beepTimers.clear();
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
        _stopTone();
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
      unawaited(_guard(() => _platform.startForegroundService(text: ref.read(l10nProvider).callForegroundServiceText)));
    } else if (!any && _fgService) {
      _fgService = false;
      unawaited(_guard(() => _platform.stopForegroundService()));
    }
    final connected = live.any((c) => c.isConfirmed);
    if (_lastProximity != connected) {
      _lastProximity = connected;
      unawaited(_guard(() => _platform.setProximityEnabled(connected)));
    }
    if (_lastKeepOn != any) {
      _lastKeepOn = any;
      unawaited(_guard(() => _platform.setKeepScreenOn(any)));
    }
    final tray = (inCall: connected, ringing: ringingNow.isNotEmpty);
    if (_lastTray != tray) {
      _lastTray = tray;
      unawaited(
        _guard(
          () => _platform.updateTray(
            missedCalls: 0,
            inCall: connected,
            ringing: ringingNow.isNotEmpty,
            tooltip: connected ? ref.read(l10nProvider).callTrayInCall : null,
          ),
        ),
      );
    }
  }

  Future<void> _guard(Future<void> Function() f) async {
    try {
      await f();
    } catch (e) {
      debugPrint('platform call failed: $e');
    }
  }

  Future<void> _playWaiting() => _guard(() => _engine.playTone(ToneKind.waiting));

  // ---- call-progress tones ---------------------------------------------------

  /// Ringback is played locally while an outgoing call is calling/early and
  /// the remote sends no early media.
  bool _wantsRingback() => _calls.values.any(
    (c) =>
        !c.hidden &&
        !c.silent &&
        c.direction == CallDirection.outgoing &&
        (c.state == CallState.calling || c.state == CallState.early) &&
        c.info.media == MediaStatus.none,
  );

  void _startTone(ToneKind kind, {Duration? duration}) {
    if (!_settings.progressTones || !_ctl.hasEngine) return;
    _toneTimer?.cancel();
    _toneTimer = null;
    _tone = kind;
    unawaited(_guard(() => _engine.playTone(kind, loop: true)));
    if (duration != null) {
      _toneTimer = Timer(duration, () {
        if (_tone == kind) _stopTone();
      });
    }
  }

  void _stopTone() {
    _toneTimer?.cancel();
    _toneTimer = null;
    if (_tone == null) return;
    _tone = null;
    if (_ctl.hasEngine) unawaited(_guard(() => _engine.stopTone()));
  }

  /// Starts/stops ringback to match the current calls. Timed tones (busy,
  /// congestion) are left to their own timer unless a new call is dialling.
  void _syncTones() {
    final want = _wantsRingback();
    if (want) {
      if (_tone != ToneKind.ringback) _startTone(ToneKind.ringback);
    } else if (_tone == ToneKind.ringback) {
      _stopTone();
    }
  }

  /// Tone for a failed outgoing call, or null.
  ToneKind? _terminalToneFor(UiCall c) {
    if (c.direction != CallDirection.outgoing || c.hidden || c.silent) return null;
    if (c.answered || c.userHangup || c.forcedResult != null) return null;
    final code = c.info.lastCode;
    if (code == 486 || code == 600 || code == 603) return ToneKind.busy;
    if (code == 408 || code == 404 || code == 484 || code >= 500) return ToneKind.congestion;
    return null;
  }

  void _endTone(UiCall c) {
    final t = _terminalToneFor(c);
    if (t != null && !_wantsRingback()) {
      _startTone(t, duration: const Duration(seconds: 3));
    } else {
      _syncTones();
    }
  }

  Future<void> _startRinger(UiCall call) async {
    final contacts = ref.read(contactsProvider);
    final contact = findContact(contacts, call.number);
    final profile = ref.read(accountsProvider).byId(call.accountId);
    final tone = resolveRingtoneName(_settings, profile, contact);
    final file = await ref.read(ringtoneFileProvider)(tone);
    if (!_ringing) return; // the call ended while the file was prepared
    if (_platform.ringsViaOs) {
      await _guard(
        () => _platform.startRingtone(ringtone: file ?? 'default', volume: _settings.ringerVolume),
      );
    } else {
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
        _syncTones();
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
          c.referredByEvent = e.referredBy;
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
        _onRedirected(e);
      case ResyncSnapshotEvent():
        _reconcile(e.snapshot.calls);
      default:
    }
  }

  void _onRedirected(CallRedirectedEvent e) {
    final c = _calls[e.cid];
    final profile = ref.read(accountsProvider).byId(c?.accountId ?? c?.info.uid ?? '');
    final policy = profile?.config.redirect ?? RedirectPolicy.auto;
    switch (policy) {
      case RedirectPolicy.ask:
        ref.read(redirectPromptProvider.notifier).set(
          RedirectPrompt(cid: e.cid, target: e.target, code: e.code),
        );
      case RedirectPolicy.reject:
        unawaited(_guard(() => _engine.processRedirect(e.cid, RedirectAction.reject)));
      case RedirectPolicy.auto:
        unawaited(_guard(() => _engine.processRedirect(e.cid, RedirectAction.accept)));
    }
  }

  /// The user's answer to a [RedirectPrompt].
  Future<void> resolveRedirect(bool follow) async {
    final p = ref.read(redirectPromptProvider);
    if (p == null) return;
    ref.read(redirectPromptProvider.notifier).set(null);
    await _guard(
      () => _engine.processRedirect(p.cid, follow ? RedirectAction.accept : RedirectAction.reject),
    );
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
    _syncTones();
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
        // Referred-By inherited from the REFER that spawned this call.
        referredBy: (info.referredBy ?? '').isEmpty ? cur.info.referredBy : null,
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
        _endTone(c);
        _emit();
        return;
      }
      _calls[e.cid] = c;
      if (c.direction == CallDirection.outgoing && _silentCids.contains(e.cid)) {
        c.hidden = true;
        c.silent = true;
        c.lan = _lanOutMeta[e.cid];
      } else if (c.direction == CallDirection.outgoing) {
        _focused = e.cid;
        c.dialed = s.remoteUser;
        c.lan = _lanOutMeta[e.cid];
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
      assertedIdentity: s.assertedIdentity,
      diversion: s.diversion.isEmpty ? null : s.diversion,
      referredBy: (s.referredBy ?? '').isNotEmpty ? s.referredBy : null,
    );
    _inheritReferredBy(c, s);
    if (c.direction == CallDirection.outgoing && !c.silent && !c.hidden && c.journalKey.isEmpty) {
      unawaited(_journalStart(c));
    }
    if (s.state == CallState.confirmed && prevState != CallState.confirmed) {
      c.answered = true;
      c.connectedAt ??= DateTime.now();
      c.noAnswerTimer?.cancel();
      if (!c.silent) unawaited(_journalStart(c, answered: true));
      _focused = c.cid;
      unawaited(_guard(() => _platform.reportCallConnected('${c!.cid}')));
      unawaited(_refresh(c.cid));
      if (!c.silent && !c.recording && _shouldAutoRecord(c)) {
        unawaited(startRecording(c.cid, continued: _recordingParentOf(c) != null && !_ruleWantsRecording(c)));
      }
      if (!c.silent) {
        unawaited(
          ref.read(announcementServiceProvider).onCallConfirmed(
            cid: c.cid,
            incoming: c.direction == CallDirection.incoming,
            accountId: c.accountId,
          ),
        );
      }
    }
    if (s.state == CallState.disconnected) {
      _finalize(c);
      _calls.remove(c.cid);
      if (_focused == c.cid) _focused = null;
      final prompt = ref.read(redirectPromptProvider);
      if (prompt?.cid == c.cid) ref.read(redirectPromptProvider.notifier).set(null);
      _endTone(c);
    } else {
      _syncTones();
    }
    _emit();
  }

  void _onTransferStatus(CallTransferStatusEvent e) {
    final c = _calls[e.cid];
    if (c == null || !e.isFinal) return;
    c.transferPending = false;
    c.transferStalled = false;
    c.transferTimer?.cancel();
    if (e.code >= 200 && e.code < 300) {
      c.transferredAway = true;
      c.forcedResult = CallResult.transferred;
      unawaited(_guard(() => _engine.hangup(e.cid)));
    } else if (ref.exists(lanHandoffImplProvider) && ref.read(lanHandoffImplProvider).sessionFor(e.cid) != null) {
      // A LAN hand-off owns this call: it decides (relay fallback / keep call).
    } else {
      ref.read(noticeProvider.notifier).error(
        ref.read(l10nProvider).callErrTransferFailedWithReason(e.reason, e.code),
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
    c.addSample(s);
    _emit();
  }

  Future<void> _pollStats() async {
    for (final c in _calls.values) {
      if (c.isConfirmed && !c.silent && !c.hidden) _journalBeat(c);
    }
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
      if (sameNumber(i.remoteUri, b)) return true;
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
    final isLan = info.uid == kLanAccountUid;
    final lan = ref.read(lanCallPolicyProvider).classifyIncoming(info);
    c.lan = lan;
    // A transferred call we agreed to take is answered without further ado.
    final lanForce = lan?.handoffAccepted ?? false;

    // [reason] goes on the wire (SIP reason phrase, English); [shown] is the
    // localised text kept in the call history.
    Future<void> reject(int code, String reason, CallResult result, String shown) async {
      c.hidden = true;
      c.forcedResult = result;
      c.forcedReason = shown;
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
    if (!lanForce && _isBlocked(info)) {
      unawaited(reject(603, 'Blocked', CallResult.rejected, ref.read(l10nProvider).callHistoryBlocked));
      _emit();
      return;
    }
    if (!lanForce && s.rejectAnonymous && _isAnonymous(info)) {
      unawaited(reject(433, 'Anonymity disallowed', CallResult.rejected, ref.read(l10nProvider).callHistoryAnonymityDisallowed));
      _emit();
      return;
    }
    // 2. DND (global, status, account)
    if (!lanForce && (s.dnd || s.globalStatus == 'dnd' || (profile?.dnd ?? false))) {
      unawaited(reject(s.dndRejectCode, 'Do not disturb', CallResult.rejected, ref.read(l10nProvider).callHistoryDoNotDisturb));
      _emit();
      return;
    }
    // 3. forward always
    if (!lanForce && fwd != null && fwd.mode == ForwardMode.always && fwd.active) {
      unawaited(redirect(fwd.target, ref.read(l10nProvider).callHistoryForwardedAlways));
      _emit();
      return;
    }
    // 4. busy handling
    if (others.isNotEmpty && !lanForce) {
      if (fwd != null && fwd.mode == ForwardMode.busy && fwd.active) {
        unawaited(redirect(fwd.target, ref.read(l10nProvider).callHistoryForwardedBusy));
        _emit();
        return;
      }
      if (!s.callWaiting) {
        unawaited(reject(s.busyRejectCode, 'Busy', CallResult.busy, ref.read(l10nProvider).callHistoryBusy));
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
    // Auto-answer headers on LAN calls are honoured only for paired devices
    // that are allowed to intercom us.
    final hintOk = !isLan || (lan?.intercom ?? false);
    if (answerAfter == null && hint != null && s.allowAutoAnswerHeaders && hintOk) {
      answerAfter = hint.afterSec;
    }
    if (answerAfter != null && others.isNotEmpty && !(hint?.require ?? false)) {
      answerAfter = null; // never steal an ongoing call
    }
    if (lanForce) answerAfter = 0;
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
          unawaited(redirect(fwd.target, ref.read(l10nProvider).callHistoryForwardedNoAnswer));
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
    // Android in the foreground: the in-app incoming page is the UI; the
    // heads-up notification would only duplicate it. Backgrounded or locked
    // the notification (with its full-screen intent) is what rings.
    if (!ref.read(incomingUiVisibleProvider)()) {
      unawaited(
        _guard(
          () => _platform.showIncomingCallNotification(
            callKey: '${ev.cid}',
            title: name,
            body: profile != null
                ? ref.read(l10nProvider).callIncomingNotificationBodyOnAccount(profile.name)
                : ref.read(l10nProvider).callIncomingNotificationBody,
            accountName: profile?.name,
          ),
        ),
      );
    }
    unawaited(_guard(() => _platform.bringToFront()));
    _notified.add('${ev.cid}');
    _emit();
  }

  // ---- finalising ------------------------------------------------------------

  void _finalize(UiCall c, {bool forceEnded = false}) {
    c.noAnswerTimer?.cancel();
    c.autoAnswerTimer?.cancel();
    c.transferTimer?.cancel();
    _beepTimers.remove(c.cid)?.cancel();
    if (c.journalKey.isNotEmpty) {
      final key = c.journalKey;
      unawaited(ref.read(callJournalProvider).remove(key));
    }
    if (_notified.remove('${c.cid}')) {
      unawaited(_guard(() => _platform.cancelIncomingCallNotification('${c.cid}')));
    }
    unawaited(_guard(() => _platform.reportCallEnded('${c.cid}')));
    if (c.silent) return; // internal relay leg: not part of the history

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
    final display = (c.info.assertedIdentity?.display ?? '').isNotEmpty
        ? c.info.assertedIdentity!.display
        : c.info.remoteDisplay.isNotEmpty
        ? c.info.remoteDisplay
        : nameForNumber(contacts, number, '');
    final end = DateTime.now();
    // A call that ended while recording: keep the file in the library.
    unawaited(_persistRecording(c));
    final who = CallerIdentity.of(c.info, contacts, fromNumber: number);
    final pai = c.info.assertedIdentity;
    final rec = CallRecord(
      id: c.historyId,
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
      callId: c.info.callId,
      recordingId: c.recordingIds.isEmpty ? null : c.recordingIds.first,
      relatedRecordingIds: [...c.recordingIds.skip(1), ...c.linkedRecordingIds],
      assertedName: pai?.display ?? '',
      assertedNumber: pai?.user ?? '',
      divertedFrom: who.forwardedFrom,
      divertReason: who.forwardReason,
      referredBy: who.transferredBy,
    );
    unawaited(ref.read(historyProvider.notifier).add(rec));

    if (result == CallResult.missed) {
      unawaited(
        _guard(
          () => _platform.showMissedCallNotification(
            title: ref.read(l10nProvider).callMissedNotificationTitle,
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
        describeCallFailure(ref.read(l10nProvider), c.info.lastCode, c.info.stateReason),
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
      stripPrefix: s.stripPrefix,
      plusReplacement: s.plusReplacement.isEmpty ? null : s.plusReplacement,
      defaultCountryPrefix: s.defaultCountryPrefix,
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
      notices.error(ref.read(l10nProvider).callErrEngineNotRunning);
      return null;
    }
    final res = applyRules ? dialRules().apply(input) : DialResult(input.trim());
    if (res.target.isEmpty) return null;
    final accState = ref.read(accountsProvider);
    final selected = ref.read(dialAccountProvider);
    final explicitDirect =
        accountId == kDirectAccountId || (accountId == null && selected == kDirectAccountId);
    var profile = explicitDirect ? null : _pickAccount(accountId, res);
    // sip:user@<IP literal> with an account whose domain differs goes out
    // directly, unless the user picked an account on purpose.
    final ip = ipLiteralHost(res.target);
    final pickedOnPurpose =
        accountId != null || res.accountId != null || (selected != null && selected != kDirectAccountId);
    if (!explicitDirect && ip != null && profile != null && !pickedOnPurpose) {
      final dom = profile.config.domain.replaceAll(RegExp(r'^\[|\]$'), '').split(RegExp(r':(?=\d+$)')).first;
      if (dom != ip) profile = null;
    }
    if (res.emergency && !explicitDirect && (ip == null || profile != null)) {
      // Emergency numbers go out through any registered account; with no
      // account at all they use the direct path.
      final registered = accState.profiles.where(
        (p) => accState.statusOf(p.id) == AccountStatus.registered,
      );
      profile = registered.isNotEmpty
          ? registered.first
          : (profile ?? (accState.profiles.isEmpty ? null : accState.profiles.first));
    }
    AccountRef ref0;
    if (profile == null) {
      final looksDirect =
          explicitDirect ||
          res.emergency ||
          ip != null ||
          res.isUri ||
          RegExp(r'^\d{1,3}(\.\d{1,3}){3}').hasMatch(res.target);
      if (!looksDirect) {
        notices.error(ref.read(l10nProvider).callErrAddAccount);
        return null;
      }
      ref0 = const AccountRef.direct();
    } else {
      final st = accState.statusOf(profile.id);
      if (!res.emergency && (st == AccountStatus.failed || st == AccountStatus.disabled)) {
        notices.error(
          ref.read(l10nProvider).callErrAccountNotRegistered(profile.name),
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
      notices.error(ref.read(l10nProvider).callErrCouldNotPlace, details: e.toString());
      return null;
    }
  }

  Future<void> _holdActive({int? except}) async {
    for (final c in _calls.values.toList()) {
      if (c.cid == except) continue;
      if (c.isConfirmed && !c.isHeld && !c.isConference) {
        await _holdCall(c.cid);
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
      ref.read(noticeProvider.notifier).error(ref.read(l10nProvider).callErrCouldNotAnswer, details: '$e');
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
      ref.read(noticeProvider.notifier).error(ref.read(l10nProvider).callErrNoVoicemailNumber);
      return;
    }
    c.forcedResult = CallResult.forwarded;
    c.forcedReason = ref.read(l10nProvider).callHistorySentToVoicemail;
    c.forcedCode = 302;
    await _guard(() => _engine.redirect(cid, [_uriFor(vm, profile)]));
  }

  Future<void> redirectTo(int cid, String target) async {
    final c = _calls[cid];
    if (c == null) return;
    final profile = ref.read(accountsProvider).byId(c.accountId);
    c.forcedResult = CallResult.forwarded;
    c.forcedReason = ref.read(l10nProvider).callHistoryRedirected;
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

  /// Holds a call, with the configured music on hold (plain hold when the
  /// engine cannot play it).
  Future<void> _holdCall(int cid) =>
      _guard(() => ref.read(holdMusicServiceProvider).hold(cid, _calls[cid]?.accountId));

  Future<void> hold(int cid) async {
    await _holdCall(cid);
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
    await _holdCall(active.cid);
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

  /// Sets the conference levels for one party (see [UiCall.rxLevel]).
  Future<void> setPartyLevels(int cid, {double? rx, double? tx}) async {
    final c = _calls[cid];
    if (c == null) return;
    c.rxLevel = rx ?? c.rxLevel;
    c.txLevel = tx ?? c.txLevel;
    await _guard(() => _engine.setCallLevels(cid, rx: c.rxLevel, tx: c.txLevel));
    _emit();
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
      await ref.read(announcementServiceProvider).playTransferNotice(cid);
      if (_calls[cid] == null) return false;
      await _engine.transfer(cid, res.target);
      c.transferTarget = res.target;
      c.transferStalled = false;
      c.transferTimer?.cancel();
      // No NOTIFY / final status from the server: offer keep / retry.
      c.transferTimer = Timer(kTransferConfirmTimeout, () {
        final cur = _calls[cid];
        if (cur == null || cur.isEnded || !cur.transferPending) return;
        cur.transferStalled = true;
        _emit();
      });
      _emit();
      return true;
    } on EngineException catch (e) {
      c.transferPending = false;
      ref.read(noticeProvider.notifier).error(ref.read(l10nProvider).callErrTransferFailed, details: '$e');
      return false;
    }
  }

  /// After "Transfer not confirmed": stay on the call.
  Future<void> keepCallAfterStalledTransfer(int cid) async {
    final c = _calls[cid];
    if (c == null) return;
    c.transferTimer?.cancel();
    c.transferPending = false;
    c.transferStalled = false;
    _emit();
    await _guard(() => _engine.unhold(cid));
    await _refresh(cid);
  }

  /// After "Transfer not confirmed": send the REFER again.
  Future<bool> retryStalledTransfer(int cid) async {
    final c = _calls[cid];
    if (c == null || c.transferTarget.isEmpty) return false;
    final target = c.transferTarget;
    c.transferTimer?.cancel();
    c.transferStalled = false;
    c.transferPending = false;
    return transferBlind(cid, target);
  }

  /// Starts an attended transfer: holds [origCid] and calls [target].
  Future<int?> startConsult(int origCid, String target) async {
    final orig = _calls[origCid];
    if (orig == null) return null;
    await _holdCall(origCid);
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
    final relay = ref.read(lanCallPolicyProvider);
    if (relay.isRelayConsult(consultCid)) return relay.completeAttendedRelay(consultCid);
    final consult = _calls[consultCid];
    final orig = consult?.consultOf == null ? null : _calls[consult!.consultOf!];
    if (consult == null || orig == null) return false;
    try {
      orig.transferPending = true;
      await ref.read(announcementServiceProvider).playTransferNotice(orig.cid);
      if (_calls[orig.cid] == null || _calls[consultCid] == null) return false;
      await _engine.transferAttended(orig.cid, consultCid);
      consult.transferredAway = true;
      consult.forcedResult = CallResult.transferred;
      _emit();
      return true;
    } on EngineException catch (e) {
      orig.transferPending = false;
      ref.read(noticeProvider.notifier).error(ref.read(l10nProvider).callErrTransferFailed, details: '$e');
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
      ref.read(noticeProvider.notifier).error(ref.read(l10nProvider).callErrCouldNotMerge, details: '$e');
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
        await _holdCall(id);
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

  /// Auto-record rules (contact, account, global) for [c].
  bool _ruleWantsRecording(UiCall c) {
    final profile = ref.read(accountsProvider).byId(c.accountId);
    return shouldAutoRecord(
      settings: _settings,
      profile: profile,
      contact: findContact(ref.read(contactsProvider), c.number),
      direction: c.direction,
    );
  }

  /// The recorded call that [c] continues: the call being transferred (for a
  /// consultation call) or the one that referred us (a REFER-spawned call).
  UiCall? _recordingParentOf(UiCall c) {
    if (!_settings.recordContinueTransfers) return null;
    final id = c.consultOf ?? c.info.transferFrom;
    final parent = id == null ? null : _calls[id];
    if (parent == null || parent.recordingIds.isEmpty) return null;
    return parent;
  }

  bool _shouldAutoRecord(UiCall c) => _ruleWantsRecording(c) || _recordingParentOf(c) != null;

  /// Keeps "Referred-By" of the REFER that spawned [c] for display.
  void _inheritReferredBy(UiCall c, CallInfo s) {
    final from = s.transferFrom ?? c.info.transferFrom;
    if (from == null || (c.info.referredBy ?? '').isNotEmpty) return;
    final by = _calls[from]?.referredByEvent ?? '';
    if (by.isNotEmpty) c.info = c.info.copyWith(referredBy: by);
  }

  Future<void> _journalStart(UiCall c, {bool answered = false}) async {
    try {
      final j = ref.read(callJournalProvider);
      if (c.journalKey.isEmpty) c.journalKey = '$kJournalSession-${c.cid}-${c.startedAt.millisecondsSinceEpoch}';
      final key = c.journalKey;
      final now = DateTime.now();
      final cur = j.cached(key);
      final number = c.number.isNotEmpty ? c.number : c.dialed;
      final e = (cur ??
              JournalEntry(
                key: key,
                session: kJournalSession,
                cid: c.cid,
                accountId: c.accountId,
                direction: c.direction,
                remoteUri: c.info.remoteUri,
                remoteNumber: number,
                remoteDisplay: c.info.remoteDisplay,
                start: c.startedAt,
              ))
          .copyWith(
            remoteUri: c.info.remoteUri,
            remoteNumber: number,
            remoteDisplay: c.info.remoteDisplay,
            callId: c.info.callId,
            answeredAt: answered ? (c.connectedAt ?? now) : null,
            lastSeen: now,
            recordingPath: c.recordingFile,
            recordingId: c.recordingIds.isEmpty ? null : c.recordingIds.first,
          );
      await j.put(e);
    } catch (e) {
      debugPrint('call journal write failed: $e');
    }
  }

  void _journalBeat(UiCall c) {
    final now = DateTime.now();
    final last = c.journalBeatAt;
    if (c.journalKey.isEmpty || (last != null && now.difference(last) < const Duration(seconds: 15))) return;
    c.journalBeatAt = now;
    unawaited(_journalStart(c, answered: c.answered));
  }

  /// While recording with "recording beep" on, plays a short beep into the
  /// call every [kRecordBeepInterval] (and once when recording starts).
  void _startBeeps(int cid) {
    _beepTimers.remove(cid)?.cancel();
    if (!_settings.recordBeep) return;
    Future<void> beep() async {
      final c = _calls[cid];
      if (c == null || c.isEnded || !c.recording || !_ctl.hasEngine) return;
      final file = await ref.read(recordBeepFileProvider)();
      if (file == null) return;
      await _guard(() => _engine.playFile(cid, file));
    }

    unawaited(beep());
    _beepTimers[cid] = Timer.periodic(kRecordBeepInterval, (_) => unawaited(beep()));
  }

  final Set<int> _recStarting = {};

  /// Starts recording [cid] in the format chosen in the settings. With
  /// [continued] the recording follows a transfer: it is linked to the
  /// recording of the call it continues.
  Future<void> startRecording(int cid, {bool continued = false}) async {
    final c = _calls[cid];
    if (c == null || c.recording || !_recStarting.add(cid)) return;
    try {
      if (_settings.recordNotice && !continued) {
        try {
          await ref.read(announcementServiceProvider).playRecordingNotice(cid);
        } catch (e) {
          debugPrint('recording notice failed: $e');
        }
        if (_calls[cid] == null || c.isEnded) return;
      }
      final format = recordFormatOf(_settings.recordFormat);
      final dir = await _recordingsDir();
      final t = DateTime.now();
      String two(int n) => n.toString().padLeft(2, '0');
      final safe = c.number.replaceAll(RegExp(r'[^A-Za-z0-9+_-]'), '');
      final name =
          'rec_${t.year}${two(t.month)}${two(t.day)}_${two(t.hour)}${two(t.minute)}${two(t.second)}_$safe.${recordFormatExtension(format)}';
      final file = await _engine.recordStart(cid, p.join(dir, name), format: format);
      c.recordingFile = file;
      c.recordingId = newId();
      c.recordingIds.add(c.recordingId!);
      c.recordingFormat = format;
      c.recordingStartedAt = DateTime.now();
      c.recordingPersisted = false;
      final parent = _recordingParentOf(c);
      if (parent != null && parent.recordingId != null) {
        c.linkedRecordingIds.add(parent.recordingId!);
        parent.linkedRecordingIds.add(c.recordingId!);
      }
      c.info = c.info.copyWith(recording: true);
      _startBeeps(cid);
      unawaited(_journalStart(c, answered: c.answered));
      _emit();
    } on EngineException catch (e) {
      ref.read(noticeProvider.notifier).error(ref.read(l10nProvider).callErrCouldNotStartRecording, details: '$e');
    } finally {
      _recStarting.remove(cid);
    }
  }

  Future<void> stopRecording(int cid) async {
    final c = _calls[cid];
    if (c == null) return;
    _beepTimers.remove(cid)?.cancel();
    try {
      final r = await _engine.recordStop(cid);
      c.recordingFile = r.file.isNotEmpty ? r.file : c.recordingFile;
      c.info = c.info.copyWith(recording: false);
      unawaited(_persistRecording(c, result: r));
      _emit();
    } on EngineException catch (e) {
      ref.read(noticeProvider.notifier).error(ref.read(l10nProvider).callErrCouldNotStopRecording, details: '$e');
    }
  }

  /// Saves the recording of [c] in the recordings library (once).
  Future<void> _persistRecording(UiCall c, {RecordingResult? result}) async {
    final file = c.recordingFile;
    final id = c.recordingId;
    if (file == null || id == null || c.recordingPersisted) return;
    c.recordingPersisted = true;
    var bytes = result?.bytes ?? 0;
    if (bytes <= 0) {
      try {
        bytes = File(file).lengthSync();
      } catch (_) {}
    }
    final started = c.recordingStartedAt;
    final duration = result != null && result.durationMs > 0
        ? result.durationMs
        : (started == null ? 0 : DateTime.now().difference(started).inMilliseconds);
    final contacts = ref.read(contactsProvider);
    final number = c.number.isNotEmpty ? c.number : c.dialed;
    final name = findContact(contacts, number)?.displayName ?? c.info.remoteDisplay;
    final ctl = ref.read(recordingsProvider.notifier);
    await ctl.add(
      RecordingMeta(
        id: id,
        path: file,
        remote: number,
        time: DateTime.now(),
        durationMs: duration,
        accountId: c.accountId,
        format: (result?.format ?? c.recordingFormat).wire,
        bytes: bytes,
        callRecordId: c.historyId,
        outgoing: c.direction == CallDirection.outgoing,
        remoteName: name,
        relatedIds: c.linkedRecordingIds.toList(),
        callStart: c.startedAt,
      ),
    );
    // The partner recordings may be saved already: link both ways.
    for (final other in c.linkedRecordingIds) {
      await ctl.link(id, other);
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
      ref.read(noticeProvider.notifier).show(ref.read(l10nProvider).callParkingNotice(code));
    } on EngineException catch (e) {
      c.transferPending = false;
      ref.read(noticeProvider.notifier).error(ref.read(l10nProvider).callErrParkFailed, details: '$e');
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

  /// Retrieves a parked call: dials `<parkRetrieve prefix><slot>`.
  Future<int?> retrieveParked(String slot, {String? accountId}) async {
    final s = slot.trim();
    if (s.isEmpty) return null;
    final profile =
        ref.read(accountsProvider).byId(accountId ?? '') ??
        ref.read(accountsProvider).defaultProfile;
    final prefix = profile?.featureCodes.parkRetrieve ?? '';
    return dial('$prefix$s', accountId: profile?.id, applyRules: false);
  }

  /// Directed pickup of a ringing BLF buddy. Uses an INVITE with Replaces
  /// when the early dialog is known, else falls back to the feature code.
  Future<int?> pickupBuddy(BuddyInfo b, {String? accountId}) async {
    final accState = ref.read(accountsProvider);
    final profile =
        accState.byId(accountId ?? '') ??
        accState.byId(b.uid) ??
        accState.defaultProfile;
    BlfDialog? d;
    for (final x in b.blf.dialogs) {
      if (x.state == BlfState.early &&
          x.callId.isNotEmpty &&
          x.localTag.isNotEmpty &&
          x.remoteTag.isNotEmpty) {
        d = x;
        break;
      }
    }
    if (d != null && profile != null && _ctl.hasEngine && b.uri.isNotEmpty) {
      try {
        await _holdActive();
        final r = await _engine.pickup(
          acc: AccountRef.uid(profile.id),
          uri: b.uri,
          callId: d.callId,
          toTag: d.localTag,
          fromTag: d.remoteTag,
        );
        _focused = r.cid;
        _emit();
        return r.cid;
      } on EngineException catch (e) {
        debugPrint('Replaces pickup failed, using feature code: $e');
      }
    }
    return pickup(extension: userPart(b.uri), accountId: profile?.id);
  }

  // ---- LAN Link hooks ---------------------------------------------------------

  /// Places a hidden call (no UI, no history) through [accountId]; used for
  /// PBX feature codes. Returns the call id or null.
  Future<int?> dialSilent(String uri, {required String accountId}) async {
    if (!_ctl.hasEngine) return null;
    try {
      final r = await _engine.makeCall(acc: AccountRef.uid(accountId), uri: uri);
      _silentCids.add(r.cid);
      final c = _calls[r.cid];
      if (c != null) {
        c.hidden = true;
        c.silent = true;
        _emit();
      }
      return r.cid;
    } on EngineException {
      return null;
    }
  }

  /// Places a call through the engine's LAN account (`__lan__`). [silent]
  /// calls are internal relay legs: hidden from the UI and the history.
  Future<int?> placeLanCall(
    String uri, {
    Map<String, String>? headers,
    LanCallMeta? meta,
    bool silent = false,
    bool holdOthers = false,
  }) async {
    final notices = ref.read(noticeProvider.notifier);
    if (!_ctl.hasEngine) {
      notices.error(ref.read(l10nProvider).callErrEngineNotRunning);
      return null;
    }
    if (holdOthers) await _holdActive();
    try {
      final r = await _engine.makeCall(
        acc: const AccountRef.uid(kLanAccountUid),
        uri: uri,
        headers: headers,
      );
      _lanOutMeta[r.cid] = meta;
      if (silent) _silentCids.add(r.cid);
      final c = _calls[r.cid];
      if (c != null) {
        // The call event was already processed: apply the attributes now.
        c.lan = meta;
        if (silent) {
          c.hidden = true;
          c.silent = true;
        } else {
          c.dialed = uri;
          _focused = r.cid;
        }
      }
      _emit();
      return r.cid;
    } on EngineException catch (e) {
      notices.error(ref.read(l10nProvider).callErrCouldNotPlace, details: e.toString());
      return null;
    }
  }

  /// A visible, direct LAN call (or intercom) to a nearby device.
  Future<int?> dialLan(String uri, {Map<String, String>? headers, LanCallMeta? meta}) =>
      placeLanCall(uri, headers: headers, meta: meta, holdOthers: true);

  /// The call object including hidden (policy-handled / relay) calls.
  UiCall? rawCall(int cid) => _calls[cid];

  /// Hides a call from the UI and history (a relay leg that is now bridged).
  void setSilent(int cid, bool silent) {
    final c = _calls[cid];
    if (c == null) return;
    c.silent = silent;
    c.hidden = silent;
    c.consultOf = silent ? null : c.consultOf;
    _emit();
  }

  /// Records that [cid] now lives on another device ("Handed off" in history).
  void markHandedOff(int cid, String reason) {
    final c = _calls[cid];
    if (c == null) return;
    c.forcedResult = CallResult.handedOff;
    c.forcedReason = reason;
    _emit();
  }

  void clearHandedOff(int cid) {
    final c = _calls[cid];
    if (c == null) return;
    if (c.forcedResult == CallResult.handedOff) {
      c.forcedResult = null;
      c.forcedReason = '';
    }
    _emit();
  }

  void markConsult(int lanCid, int origCid) {
    final c = _calls[lanCid];
    if (c == null) return;
    c.consultOf = origCid;
    _emit();
  }

  Future<void> handoffToLan(
    int cid,
    LanDevice device, {
    HandoffMode mode = HandoffMode.blind,
  }) async {
    try {
      await ref.read(lanHandoffImplProvider).handoff(cid: cid, peerId: device.id, attended: mode == HandoffMode.attended);
    } on LanHandoffException catch (e) {
      ref.read(noticeProvider.notifier).show(e.message);
    } catch (e) {
      ref.read(noticeProvider.notifier).error(ref.read(l10nProvider).callErrHandoffFailed, details: '$e');
    }
  }

  Future<void> forwardIncomingToLan(int cid, LanDevice device) async {
    try {
      await ref.read(lanHandoffImplProvider).forwardIncoming(cid: cid, peerId: device.id);
    } on LanHandoffException catch (e) {
      ref.read(noticeProvider.notifier).show(e.message);
    } catch (e) {
      ref.read(noticeProvider.notifier).error(ref.read(l10nProvider).callErrCouldNotSendToDevice, details: '$e');
    }
  }
}

/// Whether the in-app incoming-call UI is on screen right now (Android with
/// the app resumed). Overridable in tests.
final incomingUiVisibleProvider = Provider<bool Function()>(
  (ref) => () {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return false;
    try {
      return WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed;
    } catch (_) {
      return false; // no binding (pure Dart tests)
    }
  },
);

final callsProvider = NotifierProvider<CallsController, CallsState>(
  CallsController.new,
);
