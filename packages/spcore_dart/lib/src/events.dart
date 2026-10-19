import 'models/json_util.dart';
import 'models/models.dart';

/// A typed engine event (docs/ENGINE_API.md §3).
///
/// Every event keeps its original JSON in [raw]; typed accessors are derived
/// from it. Parsing never throws: unknown event names yield [UnknownEvent] and
/// missing fields take defaults.
sealed class EngineEvent {
  EngineEvent(Map<String, dynamic> raw)
    : raw = Map.unmodifiable(raw),
      seq = asInt(raw['seq']),
      ts = asInt(raw['ts']);

  /// Original JSON message.
  final Map<String, dynamic> raw;

  /// Monotonic event counter (0 for synthetic, Dart-side events).
  final int seq;

  /// Unix time in milliseconds.
  final int ts;

  /// Wire event name, e.g. `call.state`.
  String get name => asString(raw['event']);

  Map<String, dynamic> toJson() => raw;

  /// Parses an event message. Never throws.
  factory EngineEvent.fromJson(Map<String, dynamic> j) {
    try {
      return _parse(j);
    } catch (_) {
      return UnknownEvent(j);
    }
  }

  static EngineEvent _parse(Map<String, dynamic> j) {
    switch (asString(j['event'])) {
      case 'core.started':
        return CoreStartedEvent(j);
      case 'core.stopped':
        return CoreStoppedEvent(j);
      case 'core.ipChangeProgress':
        return CoreIpChangeProgressEvent(j);
      case 'log':
        return LogEvent(j);
      case 'sip.trace':
        return SipTraceEvent(j);
      case 'transport.state':
        return TransportStateEvent(j);
      case 'transport.tlsVerify':
        return TransportTlsVerifyEvent(j);
      case 'account.reg':
        return AccountRegEvent(j);
      case 'account.mwi':
        return AccountMwiEvent(j);
      case 'account.incomingSubscribe':
        return AccountIncomingSubscribeEvent(j);
      case 'call.incoming':
        return CallIncomingEvent(j);
      case 'call.state':
        return CallStateEvent(j);
      case 'call.media':
        return CallMediaEvent(j);
      case 'call.dtmf':
        return CallDtmfEvent(j);
      case 'call.transferRequest':
        return CallTransferRequestEvent(j);
      case 'call.transferStatus':
        return CallTransferStatusEvent(j);
      case 'call.replaced':
        return CallReplacedEvent(j);
      case 'call.redirected':
        return CallRedirectedEvent(j);
      case 'call.recording':
        return CallRecordingEvent(j);
      case 'call.playDone':
        return CallPlayDoneEvent(j);
      case 'call.stats':
        return CallStatsEvent(j);
      case 'buddy.state':
        return BuddyStateEvent(j);
      case 'im.incoming':
        return ImIncomingEvent(j);
      case 'im.status':
        return ImStatusEvent(j);
      case 'im.typing':
        return ImTypingEvent(j);
      case 'media.devicesChanged':
        return MediaDevicesChangedEvent(j);
      case 'media.error':
        return MediaErrorEvent(j);
      case 'diag.natType':
        return DiagNatTypeEvent(j);
      case 'diag.options':
        return DiagOptionsEvent(j);
      default:
        return UnknownEvent(j);
    }
  }

  @override
  String toString() => '$runtimeType(seq: $seq, $raw)';
}

/// An event whose name is not known to this version of the package.
final class UnknownEvent extends EngineEvent {
  UnknownEvent(super.raw);
}

final class CoreStartedEvent extends EngineEvent {
  CoreStartedEvent(super.raw) : version = asString(raw['version']);
  final String version;
}

final class CoreStoppedEvent extends EngineEvent {
  CoreStoppedEvent(super.raw);
}

final class CoreIpChangeProgressEvent extends EngineEvent {
  CoreIpChangeProgressEvent(super.raw)
    : op = IpChangeOp.parse(raw['op']),
      status = asInt(raw['status']),
      acc = asIntN(raw['acc']),
      cid = asIntN(raw['cid']);
  final IpChangeOp op;
  final int status;
  final int? acc;
  final int? cid;
}

final class LogEvent extends EngineEvent {
  LogEvent(super.raw) : level = asInt(raw['level']), msg = asString(raw['msg']);
  final int level;
  final String msg;
}

final class SipTraceEvent extends EngineEvent {
  SipTraceEvent(super.raw)
    : dir = SipDir.parse(raw['dir']),
      transport = asString(raw['transport']),
      local = asString(raw['local']),
      remote = asString(raw['remote']),
      len = asInt(raw['len']),
      msg = asString(raw['msg']);
  final SipDir dir;
  final String transport;
  final String local;
  final String remote;
  final int len;
  final String msg;
}

final class TransportStateEvent extends EngineEvent {
  TransportStateEvent(super.raw) : info = TransportStateInfo.fromJson(raw);
  final TransportStateInfo info;
}

final class TransportTlsVerifyEvent extends EngineEvent {
  TransportTlsVerifyEvent(super.raw) : info = TlsVerifyInfo.fromJson(raw);
  final TlsVerifyInfo info;
}

final class AccountRegEvent extends EngineEvent {
  AccountRegEvent(super.raw) : account = AccountInfo.fromJson(raw);
  final AccountInfo account;
}

final class AccountMwiEvent extends EngineEvent {
  AccountMwiEvent(super.raw) : mwi = MwiInfo.fromJson(raw);
  final MwiInfo mwi;
}

final class AccountIncomingSubscribeEvent extends EngineEvent {
  AccountIncomingSubscribeEvent(super.raw)
    : acc = asInt(raw['acc']),
      uid = asString(raw['uid']),
      from = asString(raw['from']),
      accepted = asBool(raw['accepted']);
  final int acc;
  final String uid;
  final String from;
  final bool accepted;
}

/// Base for events that concern one call.
sealed class CallEvent extends EngineEvent {
  CallEvent(super.raw) : cid = asInt(raw['cid']);
  final int cid;
}

final class CallIncomingEvent extends CallEvent {
  CallIncomingEvent(super.raw)
    : call = CallInfo.fromJson(raw),
      replacesCid = asIntN(raw['replacesCid']),
      autoAnswerHint = raw['autoAnswerHint'] is Map
          ? AutoAnswerHint.fromJson(asMap(raw['autoAnswerHint']))
          : null;
  final CallInfo call;
  final int? replacesCid;
  final AutoAnswerHint? autoAnswerHint;
  Map<String, String> get headers => call.headers;
}

final class CallStateEvent extends CallEvent {
  CallStateEvent(super.raw) : call = CallInfo.fromJson(raw);

  /// The state-relevant subset of CallInfo carried by the event.
  final CallInfo call;
  CallState get state => call.state;
  bool get isTerminal => call.state == CallState.disconnected;
}

final class CallMediaEvent extends CallEvent {
  CallMediaEvent(super.raw)
    : media = MediaStatus.parse(raw['media']),
      codec = asString(raw['codec']),
      srtp = asBool(raw['srtp']),
      crypto = asStringN(raw['crypto']),
      secureSignaling = asBool(raw['secureSignaling']),
      ice = raw['ice'];
  final MediaStatus media;
  final String codec;
  final bool srtp;
  final String? crypto;
  final bool secureSignaling;

  /// ICE info; shape not fixed by the contract (string or object).
  final Object? ice;
}

final class CallDtmfEvent extends CallEvent {
  CallDtmfEvent(super.raw)
    : digit = asString(raw['digit']),
      method = DtmfWireMethod.parse(raw['method']),
      durationMs = asInt(raw['durationMs']);
  final String digit;
  final DtmfWireMethod method;
  final int durationMs;
}

final class CallTransferRequestEvent extends CallEvent {
  CallTransferRequestEvent(super.raw)
    : target = asString(raw['target']),
      referredBy = asString(raw['referredBy']),
      accepted = asBool(raw['accepted']);
  final String target;
  final String referredBy;

  /// REFER accepted (referPolicy accept). The spawned call's call.state
  /// events carry `transferFrom`.
  final bool accepted;
}

final class CallTransferStatusEvent extends CallEvent {
  CallTransferStatusEvent(super.raw)
    : code = asInt(raw['code']),
      reason = asString(raw['reason']),
      isFinal = asBool(raw['final']);
  final int code;
  final String reason;
  final bool isFinal;
}

final class CallReplacedEvent extends CallEvent {
  CallReplacedEvent(super.raw)
    : oldCid = asInt(raw['oldCid']),
      newCid = asInt(raw['newCid']);
  final int oldCid;
  final int newCid;
}

final class CallRedirectedEvent extends CallEvent {
  CallRedirectedEvent(super.raw)
    : target = asString(raw['target']),
      code = asInt(raw['code']);
  final String target;
  final int code;
}

final class CallRecordingEvent extends CallEvent {
  CallRecordingEvent(super.raw)
    : recording = asBool(raw['recording']),
      file = asString(raw['file']);
  final bool recording;
  final String file;
}

/// A `call.playFile` playback ended (contract v1.1).
final class CallPlayDoneEvent extends CallEvent {
  CallPlayDoneEvent(super.raw)
    : playId = asInt(raw['playId']),
      file = asString(raw['file']),
      reason = PlayDoneReason.parse(raw['reason']);
  final int playId;
  final String file;
  final PlayDoneReason reason;
}

final class CallStatsEvent extends CallEvent {
  CallStatsEvent(super.raw) : stats = CallStats.fromJson(raw);
  final CallStats stats;
}

final class BuddyStateEvent extends EngineEvent {
  BuddyStateEvent(super.raw) : buddy = BuddyInfo.fromJson(raw);
  final BuddyInfo buddy;
}

final class ImIncomingEvent extends EngineEvent {
  ImIncomingEvent(super.raw) : message = ImMessage.fromJson(raw);
  final ImMessage message;
}

final class ImStatusEvent extends EngineEvent {
  ImStatusEvent(super.raw) : status = ImStatus.fromJson(raw);
  final ImStatus status;
}

final class ImTypingEvent extends EngineEvent {
  ImTypingEvent(super.raw) : typing = ImTyping.fromJson(raw);
  final ImTyping typing;
}

final class MediaDevicesChangedEvent extends EngineEvent {
  MediaDevicesChangedEvent(super.raw);
}

final class MediaErrorEvent extends EngineEvent {
  MediaErrorEvent(super.raw)
    : op = asString(raw['op']),
      status = asInt(raw['status']),
      message = asString(raw['message']),
      fallback = asStringN(raw['fallback']);
  final String op;
  final int status;
  final String message;
  final String? fallback;
}

final class DiagNatTypeEvent extends EngineEvent {
  DiagNatTypeEvent(super.raw) : info = NatTypeInfo.fromJson(raw);
  final NatTypeInfo info;
}

final class DiagOptionsEvent extends EngineEvent {
  DiagOptionsEvent(super.raw) : result = OptionsResult.fromJson(raw);
  final OptionsResult result;
}

// ---- Synthetic, Dart-side events (seq == 0) ----

/// A gap in `seq` was detected (ring overflow) or the engine was re-attached;
/// state is stale until the following [ResyncSnapshotEvent].
final class ResyncNeededEvent extends EngineEvent {
  ResyncNeededEvent({this.expectedSeq = 0, this.receivedSeq = 0})
    : super({
        'type': 'event',
        'event': 'dart.resyncNeeded',
        'expectedSeq': expectedSeq,
        'receivedSeq': receivedSeq,
      });
  final int expectedSeq;
  final int receivedSeq;
}

/// Result of the automatic `core.snapshot` after a [ResyncNeededEvent].
final class ResyncSnapshotEvent extends EngineEvent {
  ResyncSnapshotEvent(this.snapshot)
    : super({'type': 'event', 'event': 'dart.resyncSnapshot'});
  final EngineSnapshot snapshot;
}

/// The watchdog (`core.ping`) got no answer.
final class EngineUnresponsiveEvent extends EngineEvent {
  EngineUnresponsiveEvent(this.consecutiveFailures)
    : super({
        'type': 'event',
        'event': 'dart.unresponsive',
        'failures': consecutiveFailures,
      });
  final int consecutiveFailures;
}

/// The watchdog got an answer again after [EngineUnresponsiveEvent].
final class EngineResponsiveEvent extends EngineEvent {
  EngineResponsiveEvent()
    : super({'type': 'event', 'event': 'dart.responsive'});
}
