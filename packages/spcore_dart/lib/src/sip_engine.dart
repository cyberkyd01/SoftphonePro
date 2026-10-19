import 'events.dart';
import 'models/models.dart';

/// Thrown by every [SipEngine] request that fails.
class EngineException implements Exception {
  const EngineException(this.error);
  final EngineError error;

  ErrorCode get code => error.code;

  @override
  String toString() =>
      'EngineException(${error.code.wire}, status: ${error.status}, ${error.message})';
}

/// Identifies an account in requests: pjsua id or stable uid.
class AccountRef {
  const AccountRef.id(int this.acc) : uid = null;
  const AccountRef.uid(String this.uid) : acc = null;

  /// The userless direct account (`acc: -1`) for direct IP calls.
  const AccountRef.direct() : acc = -1, uid = null;

  final int? acc;
  final String? uid;

  Map<String, dynamic> toJson() => {
    if (acc != null) 'acc': acc,
    if (uid != null) 'uid': uid,
  };

  @override
  bool operator ==(Object other) =>
      other is AccountRef && other.acc == acc && other.uid == uid;

  @override
  int get hashCode => Object.hash(acc, uid);

  @override
  String toString() => 'AccountRef(${acc ?? uid})';
}

/// The Engine API (docs/ENGINE_API.md) as typed async methods.
///
/// Failures surface as [EngineException]. Implementations: `FfiSipEngine`
/// (real, via dart:ffi) and `FakeSipEngine` (in-memory simulator).
abstract class SipEngine {
  /// Broadcast stream of engine events, in order. Events caused by a request
  /// are delivered before that request's future completes.
  Stream<EngineEvent> get events;

  /// Prepares the engine (loads the library, attaches the event port).
  Future<void> init();

  /// `core.start`.
  Future<CoreStartResult> start(CoreConfig config);

  /// `core.stop`.
  Future<void> stop({bool graceful = true});

  /// `core.snapshot`: full state, used to resync.
  Future<EngineSnapshot> snapshot();

  /// Releases resources; pending requests fail.
  Future<void> dispose();

  /// Generic request escape hatch. Throws [EngineException].
  Future<Map<String, dynamic>> request(
    String method,
    Map<String, dynamic> params, {
    Duration? timeout,
  });

  // ---- core.*
  Future<CoreInfo> info();
  Future<void> ping();
  Future<void> setLogLevel(int level, {bool forward = false});
  Future<void> setSipTrace(bool enabled);
  Future<void> handleIpChange();
  Future<void> setNameservers(List<String> servers);
  Future<void> setTlsPins(List<TlsPin> pins);
  Future<void> setUserAgent(String userAgent);

  // ---- account.*
  Future<int> addAccount(AccountConfig config);
  Future<void> modifyAccount(AccountRef acc, AccountConfig config);
  Future<void> removeAccount(AccountRef acc);
  Future<void> setRegistration(AccountRef acc, bool register);
  Future<void> setPresence(
    AccountRef acc,
    PresenceStatus status, {
    String? note,
  });
  Future<List<AccountInfo>> listAccounts();
  Future<AccountInfo> accountInfo(AccountRef acc);

  // ---- call.*
  Future<CallRef> makeCall({
    required AccountRef acc,
    required String uri,
    Map<String, String>? headers,
    String? displayName,
    bool anonymous = false,
  });
  Future<void> answer(int cid, {int code = 200, Map<String, String>? headers});
  Future<void> ring(int cid);
  Future<void> reject(
    int cid, {
    int code = 486,
    String? reason,
    Map<String, String>? headers,
  });
  Future<void> redirect(int cid, List<String> targets, {int code = 302});
  Future<void> processRedirect(int cid, RedirectAction action);
  Future<void> hangup(int cid, {int? code});
  Future<void> hangupAll();

  /// Puts the call on hold. With [music], a looping file is played to the
  /// held party (client-side music on hold, contract v1.1).
  Future<void> hold(int cid, {HoldMusic? music});
  Future<void> unhold(int cid);
  Future<void> mute(int cid, bool mute);
  Future<void> setCallLevels(int cid, {double rx = 1.0, double tx = 1.0});
  Future<void> sendDtmf(
    int cid,
    String digits, {
    DtmfMethod? method,
    int durationMs = 160,
  });
  Future<void> transfer(int cid, String target);
  Future<void> transferAttended(
    int cid,
    int destCid, {
    bool requireReplaces = true,
  });
  Future<CallRef> pickup({
    required AccountRef acc,
    required String uri,
    required String callId,
    required String toTag,
    required String fromTag,
    Map<String, String>? headers,
  });
  Future<void> bridge(int a, int b, bool bridge);
  Future<void> detachLocal(int cid, bool detached);
  Future<void> conference(List<int> cids);
  Future<void> unconference(List<int> cids);
  Future<String> recordStart(
    int cid,
    String file, {
    RecordMix mix = RecordMix.both,
    RecordFormat format = RecordFormat.wav,
  });
  Future<RecordingResult> recordStop(int cid);
  Future<void> updateCall(int cid, {bool useUpdate = false});
  Future<void> sendRequest(
    int cid,
    String method, {
    Map<String, String>? headers,
    String? body,
    String? contentType,
  });
  Future<CallInfo> callInfo(int cid);
  Future<CallStats> callStats(int cid);
  Future<List<CallInfo>> listCalls();

  /// Plays a WAV/MP3 file into the call; returns the playId reported by
  /// `call.playDone`.
  Future<int> playFile(
    int cid,
    String file, {
    bool loop = false,
    double volume = 1.0,
    bool localMonitor = false,
    bool muteMic = false,
  });

  /// Stops one playback ([playId]) or, when null, all playback on the call.
  Future<void> stopFile(int cid, {int? playId});

  // ---- media.*
  Future<AudioDevices> audioDevices();
  Future<void> setAudioDevices({String? capture, String? playback});
  Future<void> refreshDevices();
  Future<List<CodecInfo>> codecs();
  Future<void> setCodecPriority(String id, int priority);
  Future<void> setCodecPriorities(
    List<String> order, {
    bool disableOthers = false,
  });
  Future<void> setCodecParam(
    String id, {
    int? ptime,
    bool? vad,
    Map<String, String>? fmtp,
    OpusParams? opus,
  });
  Future<void> setEc(EcConfig ec);
  Future<MediaLevels> levels();
  Future<void> setMicLevel(double level);
  Future<void> setSpeakerLevel(double level);
  Future<void> playTone(ToneKind kind, {String? digits, bool loop = false});
  Future<void> stopTone();
  Future<void> ringStart({
    String? file,
    String devId = 'default',
    bool loop = true,
    double volume = 1,
  });
  Future<void> ringStop();
  Future<void> loopback(bool enabled);
  Future<VoiceIsolationResult> setVoiceIsolation({
    VoiceIsolationSide? mic,
    VoiceIsolationSide? incoming,
  });
  Future<VoiceIsolationStatus> voiceIsolationStatus();
  Future<MediaFileInfo> fileInfo(String file);

  /// Records only the microphone to WAV (works without a call).
  Future<String> recordMicStart(String file);
  Future<RecordingResult> recordMicStop();

  // ---- buddy.*
  Future<int> addBuddy({
    required AccountRef acc,
    required String uri,
    bool presence = true,
    bool blf = false,
  });
  Future<void> subscribeBuddy(int buddy, {bool? presence, bool? blf});
  Future<void> removeBuddy(int buddy);
  Future<List<BuddyInfo>> listBuddies();
  Future<void> refreshBuddy(int buddy);

  // ---- im.*
  Future<void> sendIm({
    required AccountRef acc,
    required String to,
    required String body,
    String contentType = 'text/plain',
    String? msgId,
  });
  Future<void> sendTyping({
    required AccountRef acc,
    required String to,
    required bool typing,
  });

  // ---- diag.*
  /// Starts NAT detection; the result arrives as a [DiagNatTypeEvent].
  Future<void> natType();
  Future<ResolveResult> resolve(
    String host, {
    bool srv = false,
    String? transport,
  });

  /// Sends OPTIONS; the result arrives as a [DiagOptionsEvent].
  Future<void> optionsPing(AccountRef acc, {String? target});
}
