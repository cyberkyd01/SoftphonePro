import 'dart:async';

import 'events.dart';
import 'json_sip_engine.dart';
import 'models/json_util.dart';
import 'models/models.dart';
import 'sip_engine.dart';

/// Delays used by [FakeSipEngine]. Use [FakeTimings.instant] in tests and
/// then call [FakeSipEngine.settle] to run all scheduled steps.
class FakeTimings {
  const FakeTimings({
    this.register = const Duration(milliseconds: 50),
    this.ring = const Duration(milliseconds: 100),
    this.answer = const Duration(milliseconds: 200),
    this.transfer = const Duration(milliseconds: 50),
    this.im = const Duration(milliseconds: 20),
    this.diag = const Duration(milliseconds: 50),
    this.requestLatency = Duration.zero,
  });

  static const FakeTimings instant = FakeTimings(
    register: Duration.zero,
    ring: Duration.zero,
    answer: Duration.zero,
    transfer: Duration.zero,
    im: Duration.zero,
    diag: Duration.zero,
  );

  final Duration register;
  final Duration ring;
  final Duration answer;
  final Duration transfer;
  final Duration im;
  final Duration diag;

  /// Delay before a request is processed (events still precede the response).
  final Duration requestLatency;
}

/// How a simulated remote party reacts to an outgoing call.
enum CalleeBehavior {
  /// 180 then 200.
  answer,

  /// 180, then stays ringing until [FakeSipEngine.simulateRemoteAnswer].
  noAnswer,

  /// Stays in `calling` until driven with the simulate* methods.
  manual,

  /// 486 Busy Here.
  busy,

  /// 603 Decline.
  decline,

  /// 404 Not Found.
  notFound,
}

class _Acc {
  _Acc(this.id, this.cfg);
  final int id;
  Map<String, dynamic> cfg;
  RegState regState = RegState.none;
  int regCode = 0;
  String regReason = '';
  String? lastError;
  bool online = false;
  PresenceStatus presence = PresenceStatus.online;
  bool isLan = false;
  bool isDirect = false;

  String get uid => asString(cfg['uid']);
  String get username => asString(cfg['username']);
  String get domain => asString(cfg['domain']);
  String get password => asString(cfg['password']);

  Map<String, dynamic> toJson() => {
    'acc': id,
    'uid': uid,
    'proto': asString(cfg['proto'], 'sip'),
    'uri': isDirect ? 'sip:localhost' : 'sip:$username@$domain',
    'regState': regState.wire,
    'regCode': regCode,
    'regReason': regReason,
    'status': regCode >= 200 && regCode < 300
        ? 0
        : (regCode == 0 ? 0 : 70000 + regCode),
    'statusText': regCode >= 200 && regCode < 300 ? 'Success' : regReason,
    'lastError': lastError,
    'expires': regState == RegState.registered
        ? asInt(cfg['regExpires'], 300)
        : 0,
    'online': online,
    'isUnreg': regState == RegState.unregistered,
    'contact': regState == RegState.registered
        ? '<sip:$username@127.0.0.1:5060;ob>'
        : '',
    'transport': asString(cfg['transport'], 'udp'),
    'presence': presence.wire,
    'isLan': isLan,
    'isDirect': isDirect,
  };
}

class _Call {
  _Call(this.cid, this.slot, this.acc, this.role, DateTime now)
    : createdAt = now;
  final int cid;
  final int slot;
  final _Acc acc;
  final CallRole role;
  final DateTime createdAt;
  CallState state = CallState.calling;
  int stateCode = 0;
  String stateReason = 'Calling';
  int lastCode = 0;
  String remoteUri = '';
  String remoteDisplay = '';
  String remoteUser = '';
  bool localHold = false;
  bool remoteHold = false;
  bool earlyMedia = false;
  bool muted = false;
  bool recording = false;
  String recordFile = '';
  DateTime? recordStarted;
  bool detached = false;
  final Set<int> conferenceWith = {};
  final Set<int> bridgedWith = {};
  Map<String, String> headers = {};
  DateTime? connectedAt;
  DateTime? activeSince;
  int activeMsAcc = 0;
  String? playingFile;
  bool pendingRedirect = false;
  bool ended = false;
  final String callId = 'call-id';
  final String localTag = 'ltag';
  final String remoteTag = 'rtag';
  int rxLevel = 120;
  int txLevel = 90;
}

class _Task {
  _Task(this.due, this.fn);
  final int due;
  final void Function() fn;
  Timer? timer;
}

/// Deterministic in-memory implementation of the Engine API.
///
/// It runs the same JSON contract as the native core (via [JsonSipEngine]),
/// including the event invariants: `call.incoming` precedes any other event
/// of an incoming cid, exactly one terminal `call.state` per cid, `cid`s are
/// monotonic and never reused, and events precede the response of the request
/// that caused them (events are delivered synchronously).
///
/// Drive it from tests/demos with the `simulate*` methods; use
/// [FakeTimings.instant] plus [settle] for fully deterministic tests.
class FakeSipEngine extends JsonSipEngine {
  FakeSipEngine({
    this.timings = const FakeTimings(),
    DateTime Function()? clock,
    this.defaultCallee = CalleeBehavior.answer,
    Map<String, CalleeBehavior>? calleeRules,
  }) : _clock = clock ?? DateTime.now,
       calleeRules = calleeRules ?? {};

  final FakeTimings timings;
  final DateTime Function() _clock;

  /// Behaviour of callees by user part of the dialled URI.
  final Map<String, CalleeBehavior> calleeRules;
  CalleeBehavior defaultCallee;

  /// `call.transferStatus` final code for transfers.
  int transferResultCode = 200;

  /// Result of `diag.natType`.
  NatType natTypeResult = NatType.fullCone;

  /// Users for which `im.send` fails with 404.
  final Set<String> unreachableUsers = {};

  /// DTMF digits sent per cid (for assertions).
  final Map<int, String> sentDtmf = {};

  /// Every event emitted so far.
  final List<EngineEvent> history = [];

  final StreamController<EngineEvent> _ctrl =
      StreamController<EngineEvent>.broadcast(sync: true);

  bool _inited = false;
  bool _disposed = false;
  bool _started = false;
  int _seq = 0;
  int _nextCid = 1;
  int _nextAcc = 0;
  int _nextBuddy = 1;
  int _taskSeq = 0;
  final Map<int, _Acc> _accs = {};
  final Map<int, _Call> _calls = {};
  final Set<int> _endedCids = {};
  final Map<int, Map<String, dynamic>> _buddies = {};
  final Map<int, _Task> _tasks = {};
  Timer? _statsTimer;
  Map<String, dynamic> _coreCfg = {};
  late AudioDevices _devices = _defaultDevices();
  late List<CodecInfo> _codecs = _defaultCodecs();
  double micLevel = 1.0;
  double speakerLevel = 1.0;
  EcConfig ec = const EcConfig();
  bool loopbackEnabled = false;
  bool ringerActive = false;
  String? activeTone;
  String userAgent = 'SoftphonePro/1.0';
  List<TlsPin> tlsPins = const [];
  List<String> nameservers = const [];

  // ------------------------------------------------------------ SipEngine

  @override
  Stream<EngineEvent> get events => _ctrl.stream;

  @override
  Future<void> init() async => _inited = true;

  @override
  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    _cancelAll();
    _statsTimer?.cancel();
    await _ctrl.close();
  }

  bool get started => _started;
  bool get initialized => _inited;

  @override
  Future<Map<String, dynamic>> request(
    String method,
    Map<String, dynamic> params, {
    Duration? timeout,
  }) async {
    if (_disposed) {
      throw const EngineException(
        EngineError(code: ErrorCode.disposed, message: 'engine disposed'),
      );
    }
    if (timings.requestLatency > Duration.zero) {
      await Future<void>.delayed(timings.requestLatency);
    }
    if (!_started && method != 'core.start' && method != 'core.info') {
      if (method == 'core.stop') return {};
      throw _err(ErrorCode.notStarted, 'core.start must be called first');
    }
    return _dispatch(method, params);
  }

  // ------------------------------------------------------------ helpers

  DateTime _now() => _clock();

  EngineException _err(ErrorCode code, String message, {int status = 0}) =>
      EngineException(
        EngineError(code: code, status: status, message: message),
      );

  EngineException _invalid(String m) =>
      _err(ErrorCode.invalidParam, m, status: 70004);

  void _emit(String name, Map<String, dynamic> fields) {
    if (_disposed) return;
    final j = <String, dynamic>{
      'type': 'event',
      'event': name,
      'ts': _now().millisecondsSinceEpoch,
      'seq': ++_seq,
      ...fields,
    };
    final e = EngineEvent.fromJson(j);
    history.add(e);
    _ctrl.add(e);
  }

  void _sched(Duration d, void Function() fn) {
    final id = ++_taskSeq;
    final t = _Task(id, () {
      _tasks.remove(id);
      fn();
    });
    t.timer = Timer(d, t.fn);
    _tasks[id] = t;
  }

  /// Runs all scheduled steps (registration, ringing, answers, ...) now, in
  /// order, including steps they schedule. Returns when nothing is pending.
  Future<void> settle() async {
    var guard = 0;
    while (_tasks.isNotEmpty && guard++ < 10000) {
      final id = (_tasks.keys.toList()..sort()).first;
      final t = _tasks.remove(id)!;
      t.timer?.cancel();
      t.fn();
    }
    await Future<void>.delayed(Duration.zero);
  }

  void _cancelAll() {
    for (final t in _tasks.values) {
      t.timer?.cancel();
    }
    _tasks.clear();
  }

  int _int(Map<String, dynamic> p, String k) {
    final v = p[k];
    if (v is int) return v;
    throw _invalid('missing or invalid "$k"');
  }

  String _str(Map<String, dynamic> p, String k, {bool allowEmpty = false}) {
    final v = p[k];
    if (v is String && (allowEmpty || v.isNotEmpty)) return v;
    throw _invalid('missing or invalid "$k"');
  }

  _Acc _acc(Map<String, dynamic> p) {
    final a = p['acc'];
    final u = p['uid'];
    if (a is int) {
      if (a == -1) {
        return _accs.values.firstWhere((x) => x.isDirect);
      }
      final r = _accs[a];
      if (r == null) throw _err(ErrorCode.notFound, 'no such account $a');
      return r;
    }
    if (u is String) {
      for (final x in _accs.values) {
        if (x.uid == u) return x;
      }
      throw _err(ErrorCode.notFound, 'no such account uid $u');
    }
    throw _invalid('"acc" or "uid" required');
  }

  _Call _call(Map<String, dynamic> p, [String key = 'cid']) {
    final cid = _int(p, key);
    final c = _calls[cid];
    if (c == null || c.ended) {
      throw _err(ErrorCode.notFound, 'unknown or ended call $cid');
    }
    return c;
  }

  // ------------------------------------------------------------ JSON builders

  Map<String, dynamic> _callJson(_Call c) {
    final now = _now();
    return {
      'cid': c.cid,
      'call': c.slot,
      'acc': c.acc.id,
      'uid': c.acc.uid,
      'proto': 'sip',
      'role': c.role.wire,
      'state': c.state.wire,
      'stateCode': c.stateCode,
      'stateReason': c.stateReason,
      'lastCode': c.lastCode,
      'remoteUri': c.remoteUri,
      'remoteContact': '<${c.remoteUri}>',
      'remoteDisplay': c.remoteDisplay,
      'remoteUser': c.remoteUser,
      'localUri': c.acc.isDirect
          ? 'sip:localhost'
          : 'sip:${c.acc.username}@${c.acc.domain}',
      'callId': c.callId,
      'localTag': c.localTag,
      'remoteTag': c.remoteTag,
      'media': _mediaStatus(c).wire,
      'codec': _hasMedia(c) ? 'PCMU/8000/1' : '',
      'srtp': false,
      'secureSignaling': false,
      'muted': c.muted,
      'recording': c.recording,
      'detached': c.detached,
      'held': c.localHold,
      'conferenceWith': c.conferenceWith.toList()..sort(),
      'bridgedWith': c.bridgedWith.toList()..sort(),
      'connectMs': c.connectedAt == null
          ? 0
          : now.difference(c.connectedAt!).inMilliseconds,
      'totalMs': now.difference(c.createdAt).inMilliseconds,
      'headers': c.headers,
    };
  }

  bool _hasMedia(_Call c) =>
      !c.ended &&
      (c.state == CallState.confirmed ||
          (c.state == CallState.early && c.earlyMedia));

  MediaStatus _mediaStatus(_Call c) {
    if (!_hasMedia(c)) return MediaStatus.none;
    if (c.localHold && c.remoteHold) return MediaStatus.bothHold;
    if (c.localHold) return MediaStatus.localHold;
    if (c.remoteHold) return MediaStatus.remoteHold;
    return MediaStatus.active;
  }

  void _trackActive(_Call c) {
    final active = _mediaStatus(c) == MediaStatus.active;
    if (active && c.activeSince == null) {
      c.activeSince = _now();
    } else if (!active && c.activeSince != null) {
      c.activeMsAcc += _now().difference(c.activeSince!).inMilliseconds;
      c.activeSince = null;
    }
  }

  int _activeMs(_Call c) =>
      c.activeMsAcc +
      (c.activeSince == null
          ? 0
          : _now().difference(c.activeSince!).inMilliseconds);

  void _emitMedia(_Call c) {
    _trackActive(c);
    _emit('call.media', {
      'cid': c.cid,
      'media': _mediaStatus(c).wire,
      'codec': _hasMedia(c) ? 'PCMU/8000/1' : '',
      'srtp': false,
      'crypto': null,
      'secureSignaling': false,
      'ice': 'none',
    });
  }

  void _setState(_Call c, CallState s, int code, String reason) {
    if (c.ended) return;
    c.state = s;
    c.stateCode = code;
    c.stateReason = reason;
    if (code > 0) c.lastCode = code;
    if (s == CallState.confirmed) c.connectedAt = _now();
    if (s == CallState.disconnected) {
      if (c.recording) {
        c.recording = false;
        _emit('call.recording', {
          'cid': c.cid,
          'recording': false,
          'file': c.recordFile,
        });
      }
      c.ended = true;
      c.localHold = false;
      c.remoteHold = false;
      _trackActive(c);
      _calls.remove(c.cid);
      _endedCids.add(c.cid);
      for (final o in _calls.values) {
        o.conferenceWith.remove(c.cid);
        o.bridgedWith.remove(c.cid);
      }
      // Emit with the pre-removal view of the call.
      _emit('call.state', _callJson(c));
      return;
    }
    _emit('call.state', _callJson(c));
  }

  int _freeSlot() {
    final used = _calls.values.map((c) => c.slot).toSet();
    for (var i = 0; i < 32; i++) {
      if (!used.contains(i)) return i;
    }
    throw _err(ErrorCode.busy, 'too many calls');
  }

  Map<String, dynamic> _buddyJson(int id) => _buddies[id]!;

  static String _userOf(String uri) {
    var s = uri;
    final c = s.indexOf(':');
    if (c >= 0 && (s.startsWith('sip') || s.startsWith('tel'))) {
      s = s.substring(c + 1);
    }
    final at = s.indexOf('@');
    return (at >= 0 ? s.substring(0, at) : s).split(';').first;
  }

  // ------------------------------------------------------------ dispatch

  Map<String, dynamic> _dispatch(String method, Map<String, dynamic> p) {
    switch (method) {
      case 'core.start':
        return _coreStart(p);
      case 'core.stop':
        return _coreStop(p);
      case 'core.info':
        return {
          'version': '1.0.0 (fake)',
          'pjsip': 'fake',
          'started': _started,
          'accounts': _accs.length,
          'calls': _calls.length,
          'natType': null,
          'sndMode': asString(asMap(_coreCfg['media'])['sndMode'], 'auto'),
          'soundDevice': {
            'capture': _devices.current.capture,
            'playback': _devices.current.playback,
            'open': _calls.isNotEmpty,
          },
        };
      case 'core.snapshot':
        return {
          'accounts': _accs.values.map((a) => a.toJson()).toList(),
          'calls': _calls.values.map(_callJson).toList(),
          'buddies': _buddies.keys.map(_buddyJson).toList(),
          'devices': _devices.toJson(),
          'seq': _seq,
        };
      case 'core.ping':
        return {};
      case 'core.setLogLevel':
        final l = _int(p, 'level');
        if (l < 0 || l > 6) throw _invalid('level 0-6');
        return {};
      case 'core.setSipTrace':
        return {};
      case 'core.handleIpChange':
        for (final op in [
          'restartListener',
          'shutdownTransport',
          'reregister',
          'done',
        ]) {
          _emit('core.ipChangeProgress', {'op': op, 'status': 0});
        }
        for (final a in _accs.values.where((a) => !a.isDirect && !a.isLan)) {
          if (asBool(a.cfg['register'], true)) _beginRegister(a);
        }
        return {};
      case 'core.setNameservers':
        nameservers = asStringList(p['servers']);
        return {};
      case 'core.setTlsPins':
        tlsPins = asList(
          p['pins'],
        ).map((e) => TlsPin.fromJson(asMap(e))).toList();
        return {};
      case 'core.setUserAgent':
        userAgent = _str(p, 'userAgent');
        return {};
      case 'account.add':
        return _accountAdd(p);
      case 'account.modify':
        return _accountModify(p);
      case 'account.remove':
        return _accountRemove(p);
      case 'account.register':
        final a = _acc(p);
        if (a.isDirect || a.isLan) {
          throw _err(ErrorCode.unsupported, 'no registration');
        }
        if (asBool(p['register'], true)) {
          _beginRegister(a);
        } else {
          _beginUnregister(a);
        }
        return {};
      case 'account.setPresence':
        final a = _acc(p);
        final s = _str(p, 'status');
        final ps = PresenceStatus.values.where((e) => e.wire == s).toList();
        if (ps.isEmpty || ps.first == PresenceStatus.unknown) {
          throw _invalid('bad presence status "$s"');
        }
        a.presence = ps.first;
        return {};
      case 'account.list':
        return {'accounts': _accs.values.map((a) => a.toJson()).toList()};
      case 'account.info':
        return _acc(p).toJson();
      case 'call.make':
        return _callMake(p);
      case 'call.pickup':
        _str(asMap(p['replaces']), 'callId');
        _str(asMap(p['replaces']), 'toTag');
        _str(asMap(p['replaces']), 'fromTag');
        return _callMake(p);
      case 'call.answer':
        return _callAnswer(p);
      case 'call.ring':
        final c = _call(p);
        if (c.role != CallRole.callee) throw _invalid('not an incoming call');
        if (c.state == CallState.incoming) {
          _setState(c, CallState.early, 180, 'Ringing');
        }
        return {};
      case 'call.reject':
        final c = _call(p);
        if (c.role != CallRole.callee || c.state == CallState.confirmed) {
          throw _invalid('call is not rejectable');
        }
        final code = asInt(p['code'], 486);
        if (code < 300 || code > 699) throw _invalid('reject code 300-699');
        _setState(
          c,
          CallState.disconnected,
          code,
          asString(p['reason'], _reasonFor(code)),
        );
        return {};
      case 'call.redirect':
        final c = _call(p);
        if (c.role != CallRole.callee || c.state == CallState.confirmed) {
          throw _invalid('call is not redirectable');
        }
        if (asStringList(p['targets']).isEmpty) {
          throw _invalid('targets required');
        }
        final code = asInt(p['code'], 302);
        _setState(c, CallState.disconnected, code, _reasonFor(code));
        return {};
      case 'call.processRedirect':
        final c = _call(p);
        final act = _str(p, 'action');
        if (!RedirectAction.values.any((e) => e.wire == act)) {
          throw _invalid('bad action');
        }
        if (!c.pendingRedirect) throw _invalid('no pending redirect');
        c.pendingRedirect = false;
        if (act == 'reject' || act == 'stop') {
          _setState(c, CallState.disconnected, 487, 'Request Terminated');
        }
        return {};
      case 'call.hangup':
        final c = _call(p);
        final code = p['code'] is int
            ? p['code'] as int
            : c.state == CallState.confirmed
            ? 200
            : c.role == CallRole.caller
            ? 487
            : 603;
        _setState(c, CallState.disconnected, code, _reasonFor(code));
        return {};
      case 'call.hangupAll':
        for (final c in _calls.values.toList()) {
          _setState(
            c,
            CallState.disconnected,
            c.state == CallState.confirmed ? 200 : 487,
            c.state == CallState.confirmed
                ? 'Normal call clearing'
                : 'Request Terminated',
          );
        }
        return {};
      case 'call.hold':
        final c = _confirmed(p);
        if (!c.localHold) {
          c.localHold = true;
          _emitMedia(c);
        }
        return {};
      case 'call.unhold':
        final c = _confirmed(p);
        if (c.localHold) {
          c.localHold = false;
          _emitMedia(c);
        }
        return {};
      case 'call.mute':
        final c = _call(p);
        if (p['mute'] is! bool) throw _invalid('"mute" must be bool');
        c.muted = p['mute'] as bool;
        return {};
      case 'call.setLevels':
        final c = _call(p);
        final rx = asDouble(p['rx'], 1);
        final tx = asDouble(p['tx'], 1);
        if (rx < 0 || tx < 0) throw _invalid('levels must be >= 0');
        c.rxLevel = (120 * rx).clamp(0, 255).round();
        c.txLevel = (90 * tx).clamp(0, 255).round();
        return {};
      case 'call.dtmf':
        final c = _confirmed(p);
        final d = _str(p, 'digits');
        if (!RegExp(r'^[0-9A-Da-d*#]+$').hasMatch(d)) {
          throw _invalid('bad DTMF digits');
        }
        sentDtmf[c.cid] = (sentDtmf[c.cid] ?? '') + d;
        return {};
      case 'call.transfer':
        final c = _confirmed(p);
        _str(p, 'target');
        _transferProgress(c);
        return {};
      case 'call.transferAttended':
        final c = _confirmed(p);
        final d = _call(p, 'destCid');
        if (d.cid == c.cid) throw _invalid('destCid must differ from cid');
        if (d.state != CallState.confirmed) {
          throw _invalid('destCid not confirmed');
        }
        _transferProgress(c);
        return {};
      case 'call.bridge':
        final a = _confirmed({'cid': p['a']});
        final b = _confirmed({'cid': p['b']});
        if (a.cid == b.cid) throw _invalid('a and b must differ');
        if (asBool(p['bridge'])) {
          a.bridgedWith.add(b.cid);
          b.bridgedWith.add(a.cid);
        } else {
          a.bridgedWith.remove(b.cid);
          b.bridgedWith.remove(a.cid);
        }
        return {};
      case 'call.detachLocal':
        final c = _confirmed(p);
        c.detached = asBool(p['detached']);
        return {};
      case 'call.conference':
        final cids = asIntList(p['cids']);
        if (cids.isEmpty) throw _invalid('cids required');
        final cs = cids.map((id) => _confirmed({'cid': id})).toList();
        for (final c in cs) {
          if (c.localHold) {
            c.localHold = false;
            _emitMedia(c);
          }
          c.detached = false;
          c.conferenceWith
            ..clear()
            ..addAll(cids.where((i) => i != c.cid));
        }
        return {};
      case 'call.unconference':
        final cids = asIntList(p['cids']);
        for (final id in cids) {
          _call({'cid': id}).conferenceWith.clear();
        }
        for (final o in _calls.values) {
          o.conferenceWith.removeAll(cids);
        }
        return {};
      case 'call.recordStart':
        final c = _confirmed(p);
        final f = _str(p, 'file');
        final mix = asString(p['mix'], 'both');
        if (!RecordMix.values.any((m) => m.wire == mix)) {
          throw _invalid('bad mix');
        }
        if (c.recording) throw _err(ErrorCode.already, 'already recording');
        c.recording = true;
        c.recordFile = f;
        c.recordStarted = _now();
        _emit('call.recording', {'cid': c.cid, 'recording': true, 'file': f});
        return {'file': f};
      case 'call.recordStop':
        final c = _call(p);
        if (!c.recording) throw _invalid('not recording');
        final dur = _now().difference(c.recordStarted!).inMilliseconds;
        c.recording = false;
        _emit('call.recording', {
          'cid': c.cid,
          'recording': false,
          'file': c.recordFile,
        });
        return {'file': c.recordFile, 'durationMs': dur};
      case 'call.update':
        final c = _confirmed(p);
        _emitMedia(c);
        return {};
      case 'call.sendRequest':
        final c = _call(p);
        _str(p, 'method');
        if (c.state != CallState.confirmed && c.state != CallState.early) {
          throw _err(ErrorCode.busy, 'call not in dialog');
        }
        return {};
      case 'call.info':
        return _callJson(_call(p));
      case 'call.stats':
        return _stats(_confirmed(p));
      case 'call.list':
        return {'calls': _calls.values.map(_callJson).toList()};
      case 'call.playFile':
        final c = _confirmed(p);
        c.playingFile = _str(p, 'file');
        return {};
      case 'call.stopFile':
        _call(p).playingFile = null;
        return {};
      default:
        return _dispatchMedia(method, p);
    }
  }

  Map<String, dynamic> _dispatchMedia(String method, Map<String, dynamic> p) {
    switch (method) {
      case 'media.devices':
        return _devices.toJson();
      case 'media.setDevices':
        final all = {
          'default',
          'null',
          'none',
          ..._devices.capture.map((d) => d.devId),
          ..._devices.playback.map((d) => d.devId),
        };
        for (final k in ['capture', 'playback']) {
          final v = p[k];
          if (v == null) continue;
          if (v is! String || !all.contains(v)) {
            throw _err(ErrorCode.notFound, 'unknown device $v');
          }
          if (v == 'none' &&
              asString(asMap(_coreCfg['media'])['sndMode'], 'auto') !=
                  'manual') {
            throw _err(ErrorCode.unsupported, '"none" needs sndMode manual');
          }
        }
        _devices = AudioDevices(
          capture: _devices.capture,
          playback: _devices.playback,
          current: CurrentDevices(
            capture: asStringN(p['capture']) ?? _devices.current.capture,
            playback: asStringN(p['playback']) ?? _devices.current.playback,
            ringer: _devices.current.ringer,
          ),
        );
        return {};
      case 'media.refreshDevices':
        _emit('media.devicesChanged', {});
        return {};
      case 'media.codecs':
        return {'codecs': _codecs.map((c) => c.toJson()).toList()};
      case 'media.setCodecPriority':
        final id = _str(p, 'id');
        final pr = _int(p, 'priority');
        if (pr < 0 || pr > 255) throw _invalid('priority 0-255');
        _codec(id);
        _codecs = [
          for (final c in _codecs)
            c.id == id ? c.copyWith(priority: pr, enabled: pr > 0) : c,
        ];
        return {};
      case 'media.setCodecPriorities':
        final order = asStringList(p['order']);
        for (final id in order) {
          _codec(id);
        }
        final disable = asBool(p['disableOthers']);
        _codecs = [
          for (final c in _codecs)
            order.contains(c.id)
                ? c.copyWith(priority: 255 - order.indexOf(c.id), enabled: true)
                : (disable ? c.copyWith(priority: 0, enabled: false) : c),
        ];
        return {};
      case 'media.setCodecParam':
        _codec(_str(p, 'id'));
        return {};
      case 'media.setEc':
        final algo = _str(p, 'algo');
        if (!EcAlgo.values.any((a) => a.wire == algo)) {
          throw _invalid('bad algo');
        }
        ec = EcConfig.fromJson(p);
        return {};
      case 'media.levels':
        final active = _calls.values.any((c) => c.state == CallState.confirmed);
        return {'mic': active ? 40 : 0, 'speaker': active ? 30 : 0};
      case 'media.setMicLevel':
        micLevel = _level(p);
        return {};
      case 'media.setSpeakerLevel':
        speakerLevel = _level(p);
        return {};
      case 'media.tone':
        final k = _str(p, 'kind');
        if (!ToneKind.values.any((t) => t.wire == k)) {
          throw _invalid('bad tone kind');
        }
        if (k == 'dtmf') _str(p, 'digits');
        activeTone = k;
        return {};
      case 'media.toneStop':
        activeTone = null;
        return {};
      case 'media.ringStart':
        ringerActive = true;
        return {};
      case 'media.ringStop':
        ringerActive = false;
        return {};
      case 'media.loopback':
        loopbackEnabled = asBool(p['enabled']);
        return {};
      default:
        return _dispatchSocial(method, p);
    }
  }

  Map<String, dynamic> _dispatchSocial(String method, Map<String, dynamic> p) {
    switch (method) {
      case 'buddy.add':
        final a = _acc(p);
        final uri = _str(p, 'uri');
        final id = _nextBuddy++;
        _buddies[id] = BuddyInfo(
          buddy: id,
          acc: a.id,
          uid: a.uid,
          uri: uri,
        ).toJson();
        _buddies[id]!['_pres'] = asBool(p['presence'], true);
        _buddies[id]!['_blf'] = asBool(p['blf']);
        _emit('buddy.state', _buddyJson(id));
        return {'buddy': id};
      case 'buddy.subscribe':
        final b = _buddyOrThrow(p);
        if (p['presence'] is bool) _buddies[b]!['_pres'] = p['presence'];
        if (p['blf'] is bool) _buddies[b]!['_blf'] = p['blf'];
        return {};
      case 'buddy.remove':
        _buddies.remove(_buddyOrThrow(p));
        return {};
      case 'buddy.list':
        return {'buddies': _buddies.keys.map(_buddyJson).toList()};
      case 'buddy.refresh':
        _emit('buddy.state', _buddyJson(_buddyOrThrow(p)));
        return {};
      case 'im.send':
        final a = _acc(p);
        final to = _str(p, 'to');
        _str(p, 'body');
        final msgId = asString(p['msgId']);
        final fail = unreachableUsers.contains(_userOf(to));
        _sched(
          timings.im,
          () => _emit('im.status', {
            'acc': a.id,
            'uid': a.uid,
            'to': to,
            'msgId': msgId,
            'code': fail ? 404 : 202,
            'reason': fail ? 'Not Found' : 'Accepted',
            'ok': !fail,
          }),
        );
        return {};
      case 'im.typing':
        _acc(p);
        _str(p, 'to');
        return {};
      case 'diag.natType':
        _sched(
          timings.diag,
          () => _emit('diag.natType', {
            'type': natTypeResult.wire,
            'description': 'Fake NAT detection',
            'stun': 'stun.example.org:3478',
          }),
        );
        return {};
      case 'diag.resolve':
        final h = _str(p, 'host');
        return {
          'addresses': ['127.0.0.1'],
          'srv': asBool(p['srv'])
              ? [
                  {'target': h, 'port': 5060, 'priority': 10, 'weight': 100},
                ]
              : <Map<String, dynamic>>[],
        };
      case 'diag.optionsPing':
        final a = _acc(p);
        _sched(
          timings.diag,
          () => _emit('diag.options', {
            'acc': a.id,
            'uid': a.uid,
            'code': 200,
            'reason': 'OK',
            'rttMs': 12.0,
          }),
        );
        return {};
      default:
        throw _err(ErrorCode.unsupported, 'unknown method $method');
    }
  }

  // ------------------------------------------------------------ handlers

  Map<String, dynamic> _coreStart(Map<String, dynamic> p) {
    if (_started) throw _err(ErrorCode.already, 'already started');
    _started = true;
    _coreCfg = p;
    final cfg = CoreConfig.fromJson(p);
    userAgent = cfg.userAgent;
    if (cfg.statsIntervalMs > 0) {
      _statsTimer = Timer.periodic(
        Duration(milliseconds: cfg.statsIntervalMs),
        (_) {
          for (final c in _calls.values.where(
            (c) => c.state == CallState.confirmed,
          )) {
            _emit('call.stats', _stats(c));
          }
        },
      );
    }
    final direct = _Acc(_nextAcc++, {'uid': '__direct__', 'proto': 'sip'})
      ..isDirect = true
      ..online = true;
    _accs[direct.id] = direct;
    Map<String, dynamic>? lan;
    if (cfg.lan.enabled) {
      final l = _Acc(_nextAcc++, {'uid': '__lan__', 'proto': 'sip'})
        ..isLan = true
        ..online = true;
      _accs[l.id] = l;
      lan = {
        'acc': l.id,
        'port': cfg.lan.port == 0 ? 5070 : cfg.lan.port,
        'transport': 'udp',
      };
    }
    final transports = <Map<String, dynamic>>[];
    void add(String t, bool en, int port) {
      if (en) {
        transports.add({
          'id': transports.length,
          'type': t,
          'local': '127.0.0.1:${port == 0 ? 50000 + transports.length : port}',
          'ipv6': false,
        });
      }
    }

    add('udp', cfg.transports.udp.enabled, cfg.transports.udp.port);
    add('tcp', cfg.transports.tcp.enabled, cfg.transports.tcp.port);
    add('tls', cfg.transports.tls.enabled, cfg.transports.tls.port);
    _emit('core.started', {'version': '1.0.0 (fake)'});
    return {
      'version': '1.0.0 (fake)',
      'pjsip': 'fake',
      'transports': transports,
      if (lan != null) 'lan': lan,
      'direct': {'acc': direct.id},
    };
  }

  Map<String, dynamic> _coreStop(Map<String, dynamic> p) {
    for (final c in _calls.values.toList()) {
      _setState(
        c,
        CallState.disconnected,
        c.state == CallState.confirmed ? 200 : 487,
        c.state == CallState.confirmed
            ? 'Normal call clearing'
            : 'Request Terminated',
      );
    }
    for (final a in _accs.values) {
      if (a.regState == RegState.registered ||
          a.regState == RegState.registering) {
        a.regState = RegState.unregistered;
        a.regCode = 200;
        a.regReason = 'OK';
        a.online = false;
        _emit('account.reg', a.toJson());
      }
    }
    _cancelAll();
    _statsTimer?.cancel();
    _statsTimer = null;
    _accs.clear();
    _buddies.clear();
    _started = false;
    _emit('core.stopped', {});
    return {};
  }

  Map<String, dynamic> _accountAdd(Map<String, dynamic> p) {
    final uid = _str(p, 'uid');
    if (_accs.values.any((a) => a.uid == uid)) {
      throw _err(ErrorCode.already, 'uid exists');
    }
    final proto = asString(p['proto'], 'sip');
    if (proto != 'sip' && proto != 'iax2') throw _invalid('bad proto');
    if (asString(p['username']).isEmpty) throw _invalid('username required');
    if (asString(p['domain']).isEmpty && proto == 'sip') {
      throw _invalid('domain required');
    }
    final a = _Acc(proto == 'iax2' ? 1000 + _nextAcc++ : _nextAcc++, {
      ...AccountConfig.fromJson(p).toJson(),
    });
    _accs[a.id] = a;
    if (asBool(a.cfg['register'], true)) {
      _beginRegister(a);
    } else {
      _emit('account.reg', a.toJson());
    }
    return {'acc': a.id};
  }

  Map<String, dynamic> _accountModify(Map<String, dynamic> p) {
    final a = _acc(p);
    if (a.isDirect || a.isLan) {
      throw _err(ErrorCode.unsupported, 'built-in account');
    }
    final merged = {...a.cfg};
    for (final e in p.entries) {
      if (e.key == 'acc') continue;
      if (e.key == 'uid' && e.value != a.uid) continue;
      merged[e.key] = e.value;
    }
    a.cfg = AccountConfig.fromJson(merged).toJson();
    if (asBool(a.cfg['register'], true)) {
      _beginRegister(a);
    } else {
      _beginUnregister(a);
    }
    return {};
  }

  Map<String, dynamic> _accountRemove(Map<String, dynamic> p) {
    final a = _acc(p);
    if (a.isDirect || a.isLan) {
      throw _err(ErrorCode.unsupported, 'built-in account');
    }
    for (final c in _calls.values.where((c) => c.acc == a).toList()) {
      _setState(c, CallState.disconnected, 487, 'Request Terminated');
    }
    if (a.regState == RegState.registered) {
      a.regState = RegState.unregistered;
      a.regCode = 200;
      a.regReason = 'OK';
      a.online = false;
      _emit('account.reg', a.toJson());
    }
    _accs.remove(a.id);
    _buddies.removeWhere((_, b) => b['acc'] == a.id);
    return {};
  }

  void _beginRegister(_Acc a) {
    a.regState = RegState.registering;
    a.regCode = 0;
    a.regReason = '';
    a.lastError = null;
    _emit('account.reg', a.toJson());
    _sched(timings.register, () {
      if (!_accs.containsKey(a.id) || a.regState != RegState.registering) {
        return;
      }
      if (a.password == 'wrong') {
        a.regState = RegState.failed;
        a.regCode = 403;
        a.regReason = 'Forbidden';
        a.lastError = 'Wrong username/password (403)';
        a.online = false;
      } else if (a.domain.endsWith('.invalid')) {
        a.regState = RegState.failed;
        a.regCode = 408;
        a.regReason = 'Request Timeout';
        a.lastError = 'Timeout (408)';
        a.online = false;
      } else {
        a.regState = RegState.registered;
        a.regCode = 200;
        a.regReason = 'OK';
        a.online = true;
      }
      _emit('account.reg', a.toJson());
    });
  }

  void _beginUnregister(_Acc a) {
    a.regState = RegState.unregistering;
    _emit('account.reg', a.toJson());
    _sched(timings.register, () {
      if (!_accs.containsKey(a.id) || a.regState != RegState.unregistering) {
        return;
      }
      a.regState = RegState.unregistered;
      a.regCode = 200;
      a.regReason = 'OK';
      a.online = false;
      _emit('account.reg', a.toJson());
    });
  }

  Map<String, dynamic> _callMake(Map<String, dynamic> p) {
    final a = _acc(p);
    final uri = _str(p, 'uri');
    final c = _newCall(a, CallRole.caller);
    final user = _userOf(uri);
    c.remoteUri =
        uri.contains(':') && (uri.startsWith('sip') || uri.startsWith('tel'))
        ? uri
        : (uri.contains('@')
              ? 'sip:$uri'
              : 'sip:$user@${a.domain.isEmpty ? uri : a.domain}');
    c.remoteUser = user;
    c.remoteDisplay = '';
    c.headers = asStringMap(p['headers']);
    _setState(c, CallState.calling, 0, 'Calling');
    final rule = calleeRules[user] ?? defaultCallee;
    void ringing() {
      if (c.ended) return;
      _setState(c, CallState.early, 180, 'Ringing');
    }

    switch (rule) {
      case CalleeBehavior.answer:
        _sched(timings.ring, () {
          ringing();
          _sched(timings.answer, () => _remoteAnswer(c));
        });
      case CalleeBehavior.noAnswer:
        _sched(timings.ring, ringing);
      case CalleeBehavior.manual:
        break;
      case CalleeBehavior.busy:
        _sched(
          timings.ring,
          () => _setState(c, CallState.disconnected, 486, 'Busy Here'),
        );
      case CalleeBehavior.decline:
        _sched(
          timings.ring,
          () => _setState(c, CallState.disconnected, 603, 'Decline'),
        );
      case CalleeBehavior.notFound:
        _sched(
          timings.ring,
          () => _setState(c, CallState.disconnected, 404, 'Not Found'),
        );
    }
    return {'cid': c.cid, 'call': c.slot};
  }

  _Call _newCall(_Acc a, CallRole role) {
    if (_calls.length >= asInt(_coreCfg['maxCalls'], 16)) {
      throw _err(ErrorCode.busy, 'maxCalls reached');
    }
    final c = _Call(_nextCid++, _freeSlot(), a, role, _now());
    _calls[c.cid] = c;
    return c;
  }

  void _remoteAnswer(_Call c) {
    if (c.ended || c.state == CallState.confirmed) return;
    _setState(c, CallState.confirmed, 200, 'OK');
    _emitMedia(c);
  }

  Map<String, dynamic> _callAnswer(Map<String, dynamic> p) {
    final c = _call(p);
    if (c.role != CallRole.callee) throw _invalid('not an incoming call');
    if (c.state == CallState.confirmed) {
      throw _err(ErrorCode.already, 'already answered');
    }
    final code = asInt(p['code'], 200);
    if (code >= 200 && code < 300) {
      _setState(c, CallState.connecting, 200, 'OK');
      _setState(c, CallState.confirmed, 200, 'OK');
      _emitMedia(c);
    } else if (code == 183) {
      c.earlyMedia = true;
      _setState(c, CallState.early, 183, 'Session Progress');
      _emitMedia(c);
    } else if (code == 180 || code == 181) {
      _setState(c, CallState.early, code, _reasonFor(code));
    } else {
      throw _invalid('answer code must be 1xx/2xx');
    }
    return {};
  }

  _Call _confirmed(Map<String, dynamic> p) {
    final c = _call(p);
    if (c.state != CallState.confirmed) {
      throw _err(ErrorCode.busy, 'call ${c.cid} not confirmed');
    }
    return c;
  }

  void _transferProgress(_Call c) {
    _emit('call.transferStatus', {
      'cid': c.cid,
      'code': 100,
      'reason': 'Trying',
      'final': false,
    });
    _sched(timings.transfer, () {
      if (c.ended) return;
      _emit('call.transferStatus', {
        'cid': c.cid,
        'code': transferResultCode,
        'reason': _reasonFor(transferResultCode),
        'final': true,
      });
    });
  }

  Map<String, dynamic> _stats(_Call c) {
    final ms = _activeMs(c);
    final pk = ms ~/ 20;
    final jitter = 2.0 + (c.cid % 5) * 0.8;
    final lost = pk ~/ 500;
    final mos = double.parse(
      (4.38 - jitter * 0.02 - lost * 0.001).toStringAsFixed(2),
    );
    return {
      'cid': c.cid,
      'codec': 'PCMU/8000/1',
      'clockRate': 8000,
      'ptime': 20,
      'rx': {
        'packets': pk,
        'bytes': pk * 160,
        'lost': lost,
        'lossPct': pk == 0 ? 0.0 : lost * 100 / pk,
        'discard': 0,
        'reorder': 0,
        'dup': 0,
        'jitterMs': jitter,
        'jitterMaxMs': jitter * 3,
        'lossPeriodMs': 20,
      },
      'tx': {
        'packets': pk,
        'bytes': pk * 160,
        'lost': 0,
        'lossPct': 0,
        'jitterMs': 2.0,
      },
      'rtt': {'lastMs': 38, 'minMs': 30, 'avgMs': 36, 'maxMs': 51},
      'jb': {
        'prefetch': 3,
        'size': 4,
        'avgDelayMs': 40,
        'maxDelayMs': 80,
        'burst': 2,
        'empty': 0,
        'discard': 0,
      },
      'mos': mos,
      'rxLevel': c.rxLevel,
      'txLevel': c.muted ? 0 : c.txLevel,
      'srtp': false,
      'crypto': null,
      'ice': {'state': 'none', 'localType': null, 'remoteType': null},
      'localRtp': '127.0.0.1:4000',
      'remoteRtp': '127.0.0.1:10000',
    };
  }

  CodecInfo _codec(String id) {
    for (final c in _codecs) {
      if (c.id == id) return c;
    }
    throw _err(ErrorCode.notFound, 'unknown codec $id');
  }

  double _level(Map<String, dynamic> p) {
    final v = p['level'];
    if (v is! num || v < 0 || v > 2) throw _invalid('level 0.0-2.0');
    return v.toDouble();
  }

  int _buddyOrThrow(Map<String, dynamic> p) {
    final b = _int(p, 'buddy');
    if (!_buddies.containsKey(b)) {
      throw _err(ErrorCode.notFound, 'unknown buddy $b');
    }
    return b;
  }

  static String _reasonFor(int code) => switch (code) {
    100 => 'Trying',
    180 => 'Ringing',
    181 => 'Call Is Being Forwarded',
    183 => 'Session Progress',
    200 => 'OK',
    202 => 'Accepted',
    302 => 'Moved Temporarily',
    404 => 'Not Found',
    480 => 'Temporarily Unavailable',
    486 => 'Busy Here',
    487 => 'Request Terminated',
    603 => 'Decline',
    _ => 'Status $code',
  };

  static AudioDevices _defaultDevices() => const AudioDevices(
    capture: [
      AudioDevice(
        devId: 'default',
        name: 'System Default',
        driver: 'fake',
        inputs: 1,
        isDefault: true,
      ),
      AudioDevice(
        devId: 'fake:Built-in Microphone',
        name: 'Built-in Microphone',
        driver: 'fake',
        inputs: 1,
      ),
      AudioDevice(
        devId: 'fake:USB Headset',
        name: 'USB Headset',
        driver: 'fake',
        inputs: 1,
      ),
    ],
    playback: [
      AudioDevice(
        devId: 'default',
        name: 'System Default',
        driver: 'fake',
        outputs: 2,
        isDefault: true,
      ),
      AudioDevice(
        devId: 'fake:Built-in Speakers',
        name: 'Built-in Speakers',
        driver: 'fake',
        outputs: 2,
      ),
      AudioDevice(
        devId: 'fake:USB Headset',
        name: 'USB Headset',
        driver: 'fake',
        outputs: 2,
      ),
    ],
    current: CurrentDevices(),
  );

  static List<CodecInfo> _defaultCodecs() => const [
    CodecInfo(
      id: 'opus/48000/2',
      name: 'opus',
      clockRate: 48000,
      channels: 2,
      priority: 255,
      enabled: true,
    ),
    CodecInfo(
      id: 'G722/16000/1',
      name: 'G722',
      clockRate: 16000,
      priority: 200,
      enabled: true,
    ),
    CodecInfo(
      id: 'PCMU/8000/1',
      name: 'PCMU',
      clockRate: 8000,
      priority: 130,
      enabled: true,
    ),
    CodecInfo(
      id: 'PCMA/8000/1',
      name: 'PCMA',
      clockRate: 8000,
      priority: 129,
      enabled: true,
    ),
    CodecInfo(
      id: 'speex/16000/1',
      name: 'speex',
      clockRate: 16000,
      priority: 0,
    ),
    CodecInfo(id: 'GSM/8000/1', name: 'GSM', clockRate: 8000, priority: 0),
    CodecInfo(id: 'iLBC/8000/1', name: 'iLBC', clockRate: 8000, priority: 0),
  ];

  // ------------------------------------------------------------ simulation API

  AccountRef _defaultAccRef() {
    final a = _accs.values.firstWhere(
      (a) => !a.isDirect && !a.isLan,
      orElse: () => _accs.values.firstWhere(
        (a) => a.isDirect,
        orElse: () => throw _err(ErrorCode.notStarted, 'engine not started'),
      ),
    );
    return AccountRef.id(a.id);
  }

  /// Simulates an incoming INVITE. Emits `call.incoming` first.
  CallRef simulateIncomingCall({
    AccountRef? acc,
    String from = 'sip:1002@pbx.example.com',
    String displayName = '',
    Map<String, String> headers = const {},
    AutoAnswerHint? autoAnswerHint,
    int? replacesCid,
  }) {
    if (!_started) throw _err(ErrorCode.notStarted, 'engine not started');
    final a = _acc((acc ?? _defaultAccRef()).toJson());
    final c = _newCall(a, CallRole.callee);
    c.state = CallState.incoming;
    c.stateCode = 0;
    c.stateReason = '';
    c.remoteUri = from;
    c.remoteUser = _userOf(from);
    c.remoteDisplay = displayName;
    c.headers = Map.of(headers);
    _emit('call.incoming', {
      ..._callJson(c),
      if (replacesCid != null) 'replacesCid': replacesCid,
      if (autoAnswerHint != null) 'autoAnswerHint': autoAnswerHint.toJson(),
    });
    return CallRef(cid: c.cid, call: c.slot);
  }

  /// Remote party hangs up (BYE / CANCEL).
  void simulateRemoteHangup(int cid) {
    final c = _call({'cid': cid});
    _setState(
      c,
      CallState.disconnected,
      c.state == CallState.confirmed ? 200 : 487,
      c.state == CallState.confirmed
          ? 'Normal call clearing'
          : 'Request Terminated',
    );
  }

  /// Remote answers an outgoing call driven manually ([CalleeBehavior.manual]/noAnswer).
  void simulateRemoteAnswer(int cid) => _remoteAnswer(_call({'cid': cid}));

  /// Remote sends 180 Ringing.
  void simulateRemoteRinging(int cid) {
    final c = _call({'cid': cid});
    _setState(c, CallState.early, 180, 'Ringing');
  }

  /// Remote rejects an outgoing call with [code].
  void simulateRemoteReject(int cid, {int code = 486}) => _setState(
    _call({'cid': cid}),
    CallState.disconnected,
    code,
    _reasonFor(code),
  );

  /// Remote puts the call on hold (or resumes).
  void simulateRemoteHold(int cid, bool hold) {
    final c = _confirmed({'cid': cid});
    if (c.remoteHold == hold) return;
    c.remoteHold = hold;
    _emitMedia(c);
  }

  void simulateDtmfReceived(
    int cid,
    String digit, {
    int durationMs = 160,
    String method = 'rfc2833',
  }) {
    final c = _call({'cid': cid});
    _emit('call.dtmf', {
      'cid': c.cid,
      'digit': digit,
      'method': method,
      'durationMs': durationMs,
    });
  }

  /// Incoming REFER on [cid]: creates the new outgoing call and emits
  /// `call.transferRequest` (with `newCid`).
  CallRef simulateTransferRequest(
    int cid,
    String target, {
    String referredBy = 'sip:1002@pbx.example.com',
  }) {
    final c = _confirmed({'cid': cid});
    final n = _newCall(c.acc, CallRole.caller);
    n.remoteUri = target;
    n.remoteUser = _userOf(target);
    _emit('call.transferRequest', {
      'cid': cid,
      'target': target,
      'referredBy': referredBy,
      'newCid': n.cid,
    });
    _setState(n, CallState.calling, 0, 'Calling');
    _sched(timings.ring, () {
      if (n.ended) return;
      _setState(n, CallState.early, 180, 'Ringing');
      _sched(timings.answer, () => _remoteAnswer(n));
    });
    return CallRef(cid: n.cid, call: n.slot);
  }

  /// Incoming INVITE with Replaces for [oldCid]: emits `call.incoming` for the
  /// new call (with `replacesCid`), then `call.replaced`, then ends the old call.
  CallRef simulateReplaced(
    int oldCid, {
    String from = 'sip:1003@pbx.example.com',
  }) {
    final o = _call({'cid': oldCid});
    final ref = simulateIncomingCall(
      acc: AccountRef.id(o.acc.id),
      from: from,
      replacesCid: oldCid,
    );
    _emit('call.replaced', {'oldCid': oldCid, 'newCid': ref.cid});
    _setState(o, CallState.disconnected, 200, 'Replaced');
    return ref;
  }

  /// Account has `redirect: ask` and the callee answered 3xx.
  void simulateRedirected(int cid, String target, {int code = 302}) {
    final c = _call({'cid': cid});
    c.pendingRedirect = true;
    _emit('call.redirected', {'cid': cid, 'target': target, 'code': code});
  }

  void simulateMwi(
    AccountRef acc, {
    bool waiting = true,
    int newMsgs = 1,
    int oldMsgs = 0,
    int urgentNew = 0,
    int urgentOld = 0,
    bool solicited = false,
  }) {
    final a = _acc(acc.toJson());
    _emit('account.mwi', {
      'acc': a.id,
      'uid': a.uid,
      'waiting': waiting,
      'newMsgs': newMsgs,
      'oldMsgs': oldMsgs,
      'urgentNew': urgentNew,
      'urgentOld': urgentOld,
      'account': 'sip:${a.username}@${a.domain}',
      'solicited': solicited,
    });
  }

  void simulateIm({
    AccountRef? acc,
    String from = 'sip:1002@pbx.example.com',
    String fromDisplay = '',
    String body = 'hello',
    String contentType = 'text/plain',
  }) {
    final a = _acc((acc ?? _defaultAccRef()).toJson());
    _emit('im.incoming', {
      'acc': a.id,
      'uid': a.uid,
      'from': from,
      'fromDisplay': fromDisplay,
      'to': 'sip:${a.username}@${a.domain}',
      'body': body,
      'contentType': contentType,
      'isLan': a.isLan,
    });
  }

  void simulateTyping({
    AccountRef? acc,
    String from = 'sip:1002@pbx.example.com',
    bool typing = true,
  }) {
    final a = _acc((acc ?? _defaultAccRef()).toJson());
    _emit('im.typing', {
      'acc': a.id,
      'uid': a.uid,
      'from': from,
      'typing': typing,
    });
  }

  /// Updates a buddy's presence/BLF and emits `buddy.state`. Identify it by
  /// [buddy] id or [uri].
  void simulateBuddyState({
    int? buddy,
    String? uri,
    PresenceStatus? presence,
    String note = '',
    BlfState? blf,
    List<BlfDialog> dialogs = const [],
  }) {
    final id =
        buddy ??
        _buddies.entries
            .firstWhere(
              (e) => e.value['uri'] == uri,
              orElse: () => throw _err(ErrorCode.notFound, 'no such buddy'),
            )
            .key;
    final b = _buddies[id];
    if (b == null) throw _err(ErrorCode.notFound, 'no such buddy');
    if (presence != null) {
      b['presence'] = BuddyPresence(
        status: presence,
        note: note,
        subState: 'active',
      ).toJson();
    }
    if (blf != null) {
      b['blf'] = BlfInfo(
        state: blf,
        subState: 'active',
        dialogs: dialogs,
      ).toJson();
    }
    _emit('buddy.state', b);
  }

  void simulateIncomingSubscribe(
    AccountRef acc,
    String from, {
    bool accepted = true,
  }) {
    final a = _acc(acc.toJson());
    _emit('account.incomingSubscribe', {
      'acc': a.id,
      'uid': a.uid,
      'from': from,
      'accepted': accepted,
    });
  }

  /// Registration lost (e.g. network down).
  void simulateRegistrationLost(
    AccountRef acc, {
    int code = 408,
    String error = 'Timeout (408)',
  }) {
    final a = _acc(acc.toJson());
    a.regState = RegState.failed;
    a.regCode = code;
    a.regReason = _reasonFor(code);
    a.lastError = error;
    a.online = false;
    _emit('account.reg', a.toJson());
  }

  void simulateTlsVerifyFailure(String host, {String sha256 = 'AA:BB'}) =>
      _emit('transport.tlsVerify', {
        'host': host,
        'sha256': sha256,
        'verifyStatus': ['self-signed'],
        'subject': 'CN=$host',
        'issuer': 'CN=$host',
      });

  void simulateTransportState(String type, String state, {int status = 0}) =>
      _emit('transport.state', {
        'type': type,
        'local': '127.0.0.1:5060',
        'remote': '127.0.0.1:5060',
        'state': state,
        'status': status,
      });

  void simulateMediaError(String op, {String message = 'device error'}) =>
      _emit('media.error', {
        'op': op,
        'status': 1,
        'message': message,
        'fallback': 'null',
      });

  void simulateLog(String msg, {int level = 3}) =>
      _emit('log', {'level': level, 'msg': msg});

  void simulateDevicesChanged(AudioDevices devices) {
    _devices = devices;
    _emit('media.devicesChanged', {});
  }

  /// Number of calls currently not disconnected.
  int get activeCallCount => _calls.length;
}
