// Wire enums of the Engine API. Status enums map unknown strings to
// `unknown`; request/config enums fall back to their default value.

import 'json_util.dart';

enum RegState implements WireEnum {
  none('none'),
  registering('registering'),
  registered('registered'),
  unregistering('unregistering'),
  unregistered('unregistered'),
  failed('failed'),
  unknown('unknown');

  const RegState(this.wire);
  @override
  final String wire;

  /// Parses a wire string; unknown values yield [unknown].
  static RegState parse(Object? v, [RegState? fallback]) =>
      parseEnum(values, v, fallback ?? RegState.unknown);
}

enum CallState implements WireEnum {
  calling('calling'),
  incoming('incoming'),
  early('early'),
  connecting('connecting'),
  confirmed('confirmed'),
  disconnected('disconnected'),
  unknown('unknown');

  const CallState(this.wire);
  @override
  final String wire;

  /// Parses a wire string; unknown values yield [unknown].
  static CallState parse(Object? v, [CallState? fallback]) =>
      parseEnum(values, v, fallback ?? CallState.unknown);
}

enum CallRole implements WireEnum {
  caller('caller'),
  callee('callee'),
  unknown('unknown');

  const CallRole(this.wire);
  @override
  final String wire;

  /// Parses a wire string; unknown values yield [unknown].
  static CallRole parse(Object? v, [CallRole? fallback]) =>
      parseEnum(values, v, fallback ?? CallRole.unknown);
}

enum MediaStatus implements WireEnum {
  none('none'),
  active('active'),
  localHold('localHold'),
  remoteHold('remoteHold'),
  bothHold('bothHold'),
  error('error'),
  unknown('unknown');

  const MediaStatus(this.wire);
  @override
  final String wire;

  /// Parses a wire string; unknown values yield [unknown].
  static MediaStatus parse(Object? v, [MediaStatus? fallback]) =>
      parseEnum(values, v, fallback ?? MediaStatus.unknown);
}

enum PresenceStatus implements WireEnum {
  unknown('unknown'),
  online('online'),
  offline('offline'),
  away('away'),
  busy('busy'),
  onthephone('onthephone'),
  dnd('dnd');

  const PresenceStatus(this.wire);
  @override
  final String wire;

  /// Parses a wire string; unknown values yield [unknown].
  static PresenceStatus parse(Object? v, [PresenceStatus? fallback]) =>
      parseEnum(values, v, fallback ?? PresenceStatus.unknown);
}

enum BlfState implements WireEnum {
  unknown('unknown'),
  idle('idle'),
  early('early'),
  confirmed('confirmed'),
  terminated('terminated');

  const BlfState(this.wire);
  @override
  final String wire;

  /// Parses a wire string; unknown values yield [unknown].
  static BlfState parse(Object? v, [BlfState? fallback]) =>
      parseEnum(values, v, fallback ?? BlfState.unknown);
}

enum BlfDirection implements WireEnum {
  initiator('initiator'),
  recipient('recipient'),
  unknown('unknown');

  const BlfDirection(this.wire);
  @override
  final String wire;

  /// Parses a wire string; unknown values yield [unknown].
  static BlfDirection parse(Object? v, [BlfDirection? fallback]) =>
      parseEnum(values, v, fallback ?? BlfDirection.unknown);
}

enum NatType implements WireEnum {
  unknown('unknown'),
  open('open'),
  blocked('blocked'),
  symmetricUdp('symmetricUdp'),
  fullCone('fullCone'),
  symmetric('symmetric'),
  restricted('restricted'),
  portRestricted('portRestricted');

  const NatType(this.wire);
  @override
  final String wire;

  /// Parses a wire string; unknown values yield [unknown].
  static NatType parse(Object? v, [NatType? fallback]) =>
      parseEnum(values, v, fallback ?? NatType.unknown);
}

enum ErrorCode implements WireEnum {
  invalidParam('INVALID_PARAM'),
  notFound('NOT_FOUND'),
  notStarted('NOT_STARTED'),
  already('ALREADY'),
  pjError('PJ_ERROR'),
  timeout('TIMEOUT'),
  unsupported('UNSUPPORTED'),
  busy('BUSY'),
  internal('INTERNAL'),
  disposed('DISPOSED'),
  unknown('UNKNOWN');

  const ErrorCode(this.wire);
  @override
  final String wire;

  /// Parses a wire string; unknown values yield [unknown].
  static ErrorCode parse(Object? v, [ErrorCode? fallback]) =>
      parseEnum(values, v, fallback ?? ErrorCode.unknown);
}

enum IpChangeOp implements WireEnum {
  restartListener('restartListener'),
  shutdownTransport('shutdownTransport'),
  reregister('reregister'),
  reinvite('reinvite'),
  done('done'),
  unknown('unknown');

  const IpChangeOp(this.wire);
  @override
  final String wire;

  /// Parses a wire string; unknown values yield [unknown].
  static IpChangeOp parse(Object? v, [IpChangeOp? fallback]) =>
      parseEnum(values, v, fallback ?? IpChangeOp.unknown);
}

enum TransportStateKind implements WireEnum {
  connected('connected'),
  disconnected('disconnected'),
  shutdown('shutdown'),
  unknown('unknown');

  const TransportStateKind(this.wire);
  @override
  final String wire;

  /// Parses a wire string; unknown values yield [unknown].
  static TransportStateKind parse(Object? v, [TransportStateKind? fallback]) =>
      parseEnum(values, v, fallback ?? TransportStateKind.unknown);
}

enum AutoAnswerSource implements WireEnum {
  callInfo('callInfo'),
  alertInfo('alertInfo'),
  answerMode('answerMode'),
  unknown('unknown');

  const AutoAnswerSource(this.wire);
  @override
  final String wire;

  /// Parses a wire string; unknown values yield [unknown].
  static AutoAnswerSource parse(Object? v, [AutoAnswerSource? fallback]) =>
      parseEnum(values, v, fallback ?? AutoAnswerSource.unknown);
}

enum DtmfWireMethod implements WireEnum {
  rfc2833('rfc2833'),
  info('info'),
  unknown('unknown');

  const DtmfWireMethod(this.wire);
  @override
  final String wire;

  /// Parses a wire string; unknown values yield [unknown].
  static DtmfWireMethod parse(Object? v, [DtmfWireMethod? fallback]) =>
      parseEnum(values, v, fallback ?? DtmfWireMethod.unknown);
}

enum SipDir implements WireEnum {
  rx('rx'),
  tx('tx'),
  unknown('unknown');

  const SipDir(this.wire);
  @override
  final String wire;

  /// Parses a wire string; unknown values yield [unknown].
  static SipDir parse(Object? v, [SipDir? fallback]) =>
      parseEnum(values, v, fallback ?? SipDir.unknown);
}

enum SipProto implements WireEnum {
  sip('sip'),
  iax2('iax2');

  const SipProto(this.wire);
  @override
  final String wire;

  /// Parses a wire string; unknown values yield [sip].
  static SipProto parse(Object? v, [SipProto? fallback]) =>
      parseEnum(values, v, fallback ?? SipProto.sip);
}

enum AccTransport implements WireEnum {
  udp('udp'),
  tcp('tcp'),
  tls('tls'),
  ws('ws'),
  wss('wss'),
  auto('auto');

  const AccTransport(this.wire);
  @override
  final String wire;

  /// Parses a wire string; unknown values yield [udp].
  static AccTransport parse(Object? v, [AccTransport? fallback]) =>
      parseEnum(values, v, fallback ?? AccTransport.udp);
}

enum SrtpMode implements WireEnum {
  off('off'),
  optional('optional'),
  mandatory('mandatory');

  const SrtpMode(this.wire);
  @override
  final String wire;

  /// Parses a wire string; unknown values yield [off].
  static SrtpMode parse(Object? v, [SrtpMode? fallback]) =>
      parseEnum(values, v, fallback ?? SrtpMode.off);
}

enum SrtpKeying implements WireEnum {
  sdes('sdes'),
  dtls('dtls');

  const SrtpKeying(this.wire);
  @override
  final String wire;

  /// Parses a wire string; unknown values yield [sdes].
  static SrtpKeying parse(Object? v, [SrtpKeying? fallback]) =>
      parseEnum(values, v, fallback ?? SrtpKeying.sdes);
}

enum SessionTimers implements WireEnum {
  off('off'),
  optional('optional'),
  required('required'),
  always('always');

  const SessionTimers(this.wire);
  @override
  final String wire;

  /// Parses a wire string; unknown values yield [optional].
  static SessionTimers parse(Object? v, [SessionTimers? fallback]) =>
      parseEnum(values, v, fallback ?? SessionTimers.optional);
}

enum HoldType implements WireEnum {
  rfc3264('rfc3264'),
  rfc2543('rfc2543');

  const HoldType(this.wire);
  @override
  final String wire;

  /// Parses a wire string; unknown values yield [rfc3264].
  static HoldType parse(Object? v, [HoldType? fallback]) =>
      parseEnum(values, v, fallback ?? HoldType.rfc3264);
}

enum DtmfMethod implements WireEnum {
  rfc2833('rfc2833'),
  info('info'),
  inband('inband'),
  auto('auto');

  const DtmfMethod(this.wire);
  @override
  final String wire;

  /// Parses a wire string; unknown values yield [rfc2833].
  static DtmfMethod parse(Object? v, [DtmfMethod? fallback]) =>
      parseEnum(values, v, fallback ?? DtmfMethod.rfc2833);
}

enum Ipv6Mode implements WireEnum {
  disabled('disabled'),
  enabled('enabled'),
  preferIpv4('preferIpv4'),
  preferIpv6('preferIpv6');

  const Ipv6Mode(this.wire);
  @override
  final String wire;

  /// Parses a wire string; unknown values yield [disabled].
  static Ipv6Mode parse(Object? v, [Ipv6Mode? fallback]) =>
      parseEnum(values, v, fallback ?? Ipv6Mode.disabled);
}

enum RedirectPolicy implements WireEnum {
  auto('auto'),
  ask('ask'),
  reject('reject');

  const RedirectPolicy(this.wire);
  @override
  final String wire;

  /// Parses a wire string; unknown values yield [auto].
  static RedirectPolicy parse(Object? v, [RedirectPolicy? fallback]) =>
      parseEnum(values, v, fallback ?? RedirectPolicy.auto);
}

enum AcceptPolicy implements WireEnum {
  accept('accept'),
  reject('reject');

  const AcceptPolicy(this.wire);
  @override
  final String wire;

  /// Parses a wire string; unknown values yield [accept].
  static AcceptPolicy parse(Object? v, [AcceptPolicy? fallback]) =>
      parseEnum(values, v, fallback ?? AcceptPolicy.accept);
}

enum EcAlgo implements WireEnum {
  auto('auto'),
  aec3('aec3'),
  webrtc('webrtc'),
  speex('speex'),
  simple('simple'),
  platform('platform'),
  none('none');

  const EcAlgo(this.wire);
  @override
  final String wire;

  /// Parses a wire string; unknown values yield [auto].
  static EcAlgo parse(Object? v, [EcAlgo? fallback]) =>
      parseEnum(values, v, fallback ?? EcAlgo.auto);
}

enum SndMode implements WireEnum {
  auto('auto'),
  manual('manual');

  const SndMode(this.wire);
  @override
  final String wire;

  /// Parses a wire string; unknown values yield [auto].
  static SndMode parse(Object? v, [SndMode? fallback]) =>
      parseEnum(values, v, fallback ?? SndMode.auto);
}

enum RecordMix implements WireEnum {
  both('both'),
  remote('remote'),
  local('local');

  const RecordMix(this.wire);
  @override
  final String wire;

  /// Parses a wire string; unknown values yield [both].
  static RecordMix parse(Object? v, [RecordMix? fallback]) =>
      parseEnum(values, v, fallback ?? RecordMix.both);
}

enum ToneKind implements WireEnum {
  ringback('ringback'),
  busy('busy'),
  congestion('congestion'),
  dial('dial'),
  waiting('waiting'),
  dtmf('dtmf'),
  chime('chime');

  const ToneKind(this.wire);
  @override
  final String wire;

  /// Parses a wire string; unknown values yield [ringback].
  static ToneKind parse(Object? v, [ToneKind? fallback]) =>
      parseEnum(values, v, fallback ?? ToneKind.ringback);
}

enum RedirectAction implements WireEnum {
  accept('accept'),
  acceptReplace('acceptReplace'),
  reject('reject'),
  stop('stop');

  const RedirectAction(this.wire);
  @override
  final String wire;

  /// Parses a wire string; unknown values yield [accept].
  static RedirectAction parse(Object? v, [RedirectAction? fallback]) =>
      parseEnum(values, v, fallback ?? RedirectAction.accept);
}

enum RecordFormat implements WireEnum {
  wav('wav'),
  wavStereo('wavStereo'),
  opus('opus');

  const RecordFormat(this.wire);
  @override
  final String wire;

  /// Parses a wire string; unknown values yield [wav].
  static RecordFormat parse(Object? v, [RecordFormat? fallback]) =>
      parseEnum(values, v, fallback ?? RecordFormat.wav);
}

/// Why a `call.playFile` playback ended (`call.playDone`).
enum PlayDoneReason implements WireEnum {
  eof('eof'),
  stopped('stopped'),
  hangup('hangup'),
  error('error'),
  unknown('unknown');

  const PlayDoneReason(this.wire);
  @override
  final String wire;

  /// Parses a wire string; unknown values yield [unknown].
  static PlayDoneReason parse(Object? v, [PlayDoneReason? fallback]) =>
      parseEnum(values, v, fallback ?? PlayDoneReason.unknown);
}

/// Where the live monitor (`media.monitor`) gets its audio from.
enum MonitorSource implements WireEnum {
  device('device'),

  /// The engine fell back to the silent null device (wire `"null"`).
  nul('null'),
  none('none');

  const MonitorSource(this.wire);
  @override
  final String wire;

  /// Parses a wire string; unknown values yield [none].
  static MonitorSource parse(Object? v, [MonitorSource? fallback]) =>
      parseEnum(values, v, fallback ?? MonitorSource.none);
}
