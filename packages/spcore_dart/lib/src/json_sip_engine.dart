import 'models/models.dart';
import 'models/json_util.dart';
import 'sip_engine.dart';

/// Implements every typed [SipEngine] method on top of [request], so engines
/// only have to provide the JSON request transport. Both the real FFI engine
/// and the fake share this layer, which keeps them contract-identical.
abstract class JsonSipEngine implements SipEngine {
  Future<Map<String, dynamic>> _r(String m, [Map<String, dynamic>? p]) =>
      request(m, p ?? const {});

  Future<void> _v(String m, [Map<String, dynamic>? p]) async {
    await request(m, p ?? const {});
  }

  @override
  Future<CoreStartResult> start(CoreConfig config) async =>
      CoreStartResult.fromJson(await _r('core.start', config.toJson()));

  @override
  Future<void> stop({bool graceful = true}) =>
      _v('core.stop', {'graceful': graceful});

  @override
  Future<EngineSnapshot> snapshot() async =>
      EngineSnapshot.fromJson(await _r('core.snapshot'));

  @override
  Future<CoreInfo> info() async => CoreInfo.fromJson(await _r('core.info'));

  @override
  Future<void> ping() => _v('core.ping');

  @override
  Future<void> setLogLevel(int level, {bool forward = false}) =>
      _v('core.setLogLevel', {'level': level, 'forward': forward});

  @override
  Future<void> setSipTrace(bool enabled) =>
      _v('core.setSipTrace', {'enabled': enabled});

  @override
  Future<void> handleIpChange() => _v('core.handleIpChange');

  @override
  Future<void> setNameservers(List<String> servers) =>
      _v('core.setNameservers', {'servers': servers});

  @override
  Future<void> setTlsPins(List<TlsPin> pins) =>
      _v('core.setTlsPins', {'pins': pins.map((p) => p.toJson()).toList()});

  @override
  Future<void> setUserAgent(String userAgent) =>
      _v('core.setUserAgent', {'userAgent': userAgent});

  // ---- accounts
  @override
  Future<int> addAccount(AccountConfig config) async =>
      asInt((await _r('account.add', config.toJson()))['acc']);

  @override
  Future<void> modifyAccount(AccountRef acc, AccountConfig config) =>
      _v('account.modify', {...config.toJson(), ...acc.toJson()});

  @override
  Future<void> removeAccount(AccountRef acc) =>
      _v('account.remove', acc.toJson());

  @override
  Future<void> setRegistration(AccountRef acc, bool register) =>
      _v('account.register', {...acc.toJson(), 'register': register});

  @override
  Future<void> setPresence(
    AccountRef acc,
    PresenceStatus status, {
    String? note,
  }) => _v('account.setPresence', {
    ...acc.toJson(),
    'status': status.wire,
    if (note != null) 'note': note,
  });

  @override
  Future<List<AccountInfo>> listAccounts() async => asList(
    (await _r('account.list'))['accounts'],
  ).map((e) => AccountInfo.fromJson(asMap(e))).toList();

  @override
  Future<AccountInfo> accountInfo(AccountRef acc) async =>
      AccountInfo.fromJson(await _r('account.info', acc.toJson()));

  // ---- calls
  @override
  Future<CallRef> makeCall({
    required AccountRef acc,
    required String uri,
    Map<String, String>? headers,
    String? displayName,
    bool anonymous = false,
  }) async => CallRef.fromJson(
    await _r('call.make', {
      ...acc.toJson(),
      'uri': uri,
      if (headers != null) 'headers': headers,
      if (displayName != null) 'displayName': displayName,
      if (anonymous) 'anonymous': true,
    }),
  );

  @override
  Future<void> answer(
    int cid, {
    int code = 200,
    Map<String, String>? headers,
  }) => _v('call.answer', {
    'cid': cid,
    'code': code,
    if (headers != null) 'headers': headers,
  });

  @override
  Future<void> ring(int cid) => _v('call.ring', {'cid': cid});

  @override
  Future<void> reject(
    int cid, {
    int code = 486,
    String? reason,
    Map<String, String>? headers,
  }) => _v('call.reject', {
    'cid': cid,
    'code': code,
    if (reason != null) 'reason': reason,
    if (headers != null) 'headers': headers,
  });

  @override
  Future<void> redirect(int cid, List<String> targets, {int code = 302}) =>
      _v('call.redirect', {'cid': cid, 'targets': targets, 'code': code});

  @override
  Future<void> processRedirect(int cid, RedirectAction action) =>
      _v('call.processRedirect', {'cid': cid, 'action': action.wire});

  @override
  Future<void> hangup(int cid, {int? code}) =>
      _v('call.hangup', {'cid': cid, if (code != null) 'code': code});

  @override
  Future<void> hangupAll() => _v('call.hangupAll');

  @override
  Future<void> hold(int cid) => _v('call.hold', {'cid': cid});

  @override
  Future<void> unhold(int cid) => _v('call.unhold', {'cid': cid});

  @override
  Future<void> mute(int cid, bool mute) =>
      _v('call.mute', {'cid': cid, 'mute': mute});

  @override
  Future<void> setCallLevels(int cid, {double rx = 1.0, double tx = 1.0}) =>
      _v('call.setLevels', {'cid': cid, 'rx': rx, 'tx': tx});

  @override
  Future<void> sendDtmf(
    int cid,
    String digits, {
    DtmfMethod? method,
    int durationMs = 160,
  }) => _v('call.dtmf', {
    'cid': cid,
    'digits': digits,
    if (method != null) 'method': method.wire,
    'durationMs': durationMs,
  });

  @override
  Future<void> transfer(int cid, String target) =>
      _v('call.transfer', {'cid': cid, 'target': target});

  @override
  Future<void> transferAttended(
    int cid,
    int destCid, {
    bool requireReplaces = true,
  }) => _v('call.transferAttended', {
    'cid': cid,
    'destCid': destCid,
    'requireReplaces': requireReplaces,
  });

  @override
  Future<CallRef> pickup({
    required AccountRef acc,
    required String uri,
    required String callId,
    required String toTag,
    required String fromTag,
    Map<String, String>? headers,
  }) async => CallRef.fromJson(
    await _r('call.pickup', {
      ...acc.toJson(),
      'uri': uri,
      'replaces': {'callId': callId, 'toTag': toTag, 'fromTag': fromTag},
      if (headers != null) 'headers': headers,
    }),
  );

  @override
  Future<void> bridge(int a, int b, bool bridge) =>
      _v('call.bridge', {'a': a, 'b': b, 'bridge': bridge});

  @override
  Future<void> detachLocal(int cid, bool detached) =>
      _v('call.detachLocal', {'cid': cid, 'detached': detached});

  @override
  Future<void> conference(List<int> cids) =>
      _v('call.conference', {'cids': cids});

  @override
  Future<void> unconference(List<int> cids) =>
      _v('call.unconference', {'cids': cids});

  @override
  Future<String> recordStart(
    int cid,
    String file, {
    RecordMix mix = RecordMix.both,
  }) async => asString(
    (await _r('call.recordStart', {
      'cid': cid,
      'file': file,
      'mix': mix.wire,
    }))['file'],
  );

  @override
  Future<RecordingResult> recordStop(int cid) async =>
      RecordingResult.fromJson(await _r('call.recordStop', {'cid': cid}));

  @override
  Future<void> updateCall(int cid, {bool useUpdate = false}) =>
      _v('call.update', {'cid': cid, 'useUpdate': useUpdate});

  @override
  Future<void> sendRequest(
    int cid,
    String method, {
    Map<String, String>? headers,
    String? body,
    String? contentType,
  }) => _v('call.sendRequest', {
    'cid': cid,
    'method': method,
    if (headers != null) 'headers': headers,
    if (body != null) 'body': body,
    if (contentType != null) 'contentType': contentType,
  });

  @override
  Future<CallInfo> callInfo(int cid) async =>
      CallInfo.fromJson(await _r('call.info', {'cid': cid}));

  @override
  Future<CallStats> callStats(int cid) async =>
      CallStats.fromJson(await _r('call.stats', {'cid': cid}));

  @override
  Future<List<CallInfo>> listCalls() async => asList(
    (await _r('call.list'))['calls'],
  ).map((e) => CallInfo.fromJson(asMap(e))).toList();

  @override
  Future<void> playFile(int cid, String file, {bool loop = false}) =>
      _v('call.playFile', {'cid': cid, 'file': file, 'loop': loop});

  @override
  Future<void> stopFile(int cid) => _v('call.stopFile', {'cid': cid});

  // ---- media
  @override
  Future<AudioDevices> audioDevices() async =>
      AudioDevices.fromJson(await _r('media.devices'));

  @override
  Future<void> setAudioDevices({String? capture, String? playback}) =>
      _v('media.setDevices', {
        if (capture != null) 'capture': capture,
        if (playback != null) 'playback': playback,
      });

  @override
  Future<void> refreshDevices() => _v('media.refreshDevices');

  @override
  Future<List<CodecInfo>> codecs() async => asList(
    (await _r('media.codecs'))['codecs'],
  ).map((e) => CodecInfo.fromJson(asMap(e))).toList();

  @override
  Future<void> setCodecPriority(String id, int priority) =>
      _v('media.setCodecPriority', {'id': id, 'priority': priority});

  @override
  Future<void> setCodecPriorities(
    List<String> order, {
    bool disableOthers = false,
  }) => _v('media.setCodecPriorities', {
    'order': order,
    'disableOthers': disableOthers,
  });

  @override
  Future<void> setCodecParam(
    String id, {
    int? ptime,
    bool? vad,
    Map<String, String>? fmtp,
    OpusParams? opus,
  }) => _v('media.setCodecParam', {
    'id': id,
    if (ptime != null) 'ptime': ptime,
    if (vad != null) 'vad': vad,
    if (fmtp != null) 'fmtp': fmtp,
    if (opus != null) 'opus': opus.toJson(),
  });

  @override
  Future<void> setEc(EcConfig ec) => _v('media.setEc', ec.toJson());

  @override
  Future<MediaLevels> levels() async =>
      MediaLevels.fromJson(await _r('media.levels'));

  @override
  Future<void> setMicLevel(double level) =>
      _v('media.setMicLevel', {'level': level});

  @override
  Future<void> setSpeakerLevel(double level) =>
      _v('media.setSpeakerLevel', {'level': level});

  @override
  Future<void> playTone(ToneKind kind, {String? digits, bool loop = false}) =>
      _v('media.tone', {
        'kind': kind.wire,
        if (digits != null) 'digits': digits,
        'loop': loop,
      });

  @override
  Future<void> stopTone() => _v('media.toneStop');

  @override
  Future<void> ringStart({
    String? file,
    String devId = 'default',
    bool loop = true,
    double volume = 1,
  }) => _v('media.ringStart', {
    if (file != null) 'file': file,
    'devId': devId,
    'loop': loop,
    'volume': volume,
  });

  @override
  Future<void> ringStop() => _v('media.ringStop');

  @override
  Future<void> loopback(bool enabled) =>
      _v('media.loopback', {'enabled': enabled});

  // ---- buddies
  @override
  Future<int> addBuddy({
    required AccountRef acc,
    required String uri,
    bool presence = true,
    bool blf = false,
  }) async => asInt(
    (await _r('buddy.add', {
      ...acc.toJson(),
      'uri': uri,
      'presence': presence,
      'blf': blf,
    }))['buddy'],
  );

  @override
  Future<void> subscribeBuddy(int buddy, {bool? presence, bool? blf}) =>
      _v('buddy.subscribe', {
        'buddy': buddy,
        if (presence != null) 'presence': presence,
        if (blf != null) 'blf': blf,
      });

  @override
  Future<void> removeBuddy(int buddy) => _v('buddy.remove', {'buddy': buddy});

  @override
  Future<List<BuddyInfo>> listBuddies() async => asList(
    (await _r('buddy.list'))['buddies'],
  ).map((e) => BuddyInfo.fromJson(asMap(e))).toList();

  @override
  Future<void> refreshBuddy(int buddy) => _v('buddy.refresh', {'buddy': buddy});

  // ---- im
  @override
  Future<void> sendIm({
    required AccountRef acc,
    required String to,
    required String body,
    String contentType = 'text/plain',
    String? msgId,
  }) => _v('im.send', {
    ...acc.toJson(),
    'to': to,
    'body': body,
    'contentType': contentType,
    if (msgId != null) 'msgId': msgId,
  });

  @override
  Future<void> sendTyping({
    required AccountRef acc,
    required String to,
    required bool typing,
  }) => _v('im.typing', {...acc.toJson(), 'to': to, 'typing': typing});

  // ---- diag
  @override
  Future<void> natType() => _v('diag.natType');

  @override
  Future<ResolveResult> resolve(
    String host, {
    bool srv = false,
    String? transport,
  }) async => ResolveResult.fromJson(
    await _r('diag.resolve', {
      'host': host,
      'srv': srv,
      if (transport != null) 'transport': transport,
    }),
  );

  @override
  Future<void> optionsPing(AccountRef acc, {String? target}) => _v(
    'diag.optionsPing',
    {...acc.toJson(), if (target != null) 'target': target},
  );
}
