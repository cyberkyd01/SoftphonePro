// Engine API models (see docs/ENGINE_API.md). Tolerant fromJson: missing or
// extra fields never throw.

// ignore_for_file: unused_import

import 'json_util.dart';
import 'models.dart';

class AudioDevice {
  const AudioDevice({
    this.devId = '',
    this.name = '',
    this.driver = '',
    this.inputs = 0,
    this.outputs = 0,
    this.isDefault = false,
  });

  final String devId;
  final String name;
  final String driver;
  final int inputs;
  final int outputs;
  final bool isDefault;

  factory AudioDevice.fromJson(Map<String, dynamic> j) => AudioDevice(
    devId: asString(j['devId'], ''),
    name: asString(j['name'], ''),
    driver: asString(j['driver'], ''),
    inputs: asInt(j['inputs'], 0),
    outputs: asInt(j['outputs'], 0),
    isDefault: asBool(j['isDefault'], false),
  );

  Map<String, dynamic> toJson() => {
    'devId': devId,
    'name': name,
    'driver': driver,
    'inputs': inputs,
    'outputs': outputs,
    'isDefault': isDefault,
  };

  @override
  bool operator ==(Object other) =>
      other is AudioDevice && jsonEqual(toJson(), other.toJson());

  @override
  int get hashCode => jsonHash(toJson());

  @override
  String toString() => 'AudioDevice(${toJson()})';
}

class CurrentDevices {
  const CurrentDevices({
    this.capture = 'default',
    this.playback = 'default',
    this.ringer = 'default',
  });

  final String capture;
  final String playback;
  final String ringer;

  factory CurrentDevices.fromJson(Map<String, dynamic> j) => CurrentDevices(
    capture: asString(j['capture'], 'default'),
    playback: asString(j['playback'], 'default'),
    ringer: asString(j['ringer'], 'default'),
  );

  Map<String, dynamic> toJson() => {
    'capture': capture,
    'playback': playback,
    'ringer': ringer,
  };

  @override
  bool operator ==(Object other) =>
      other is CurrentDevices && jsonEqual(toJson(), other.toJson());

  @override
  int get hashCode => jsonHash(toJson());

  @override
  String toString() => 'CurrentDevices(${toJson()})';
}

class AudioDevices {
  const AudioDevices({
    this.capture = const <AudioDevice>[],
    this.playback = const <AudioDevice>[],
    this.current = const CurrentDevices(),
  });

  final List<AudioDevice> capture;
  final List<AudioDevice> playback;
  final CurrentDevices current;

  factory AudioDevices.fromJson(Map<String, dynamic> j) => AudioDevices(
    capture: asList(
      j['capture'],
    ).map((e) => AudioDevice.fromJson(asMap(e))).toList(),
    playback: asList(
      j['playback'],
    ).map((e) => AudioDevice.fromJson(asMap(e))).toList(),
    current: j['current'] is Map
        ? CurrentDevices.fromJson(asMap(j['current']))
        : const CurrentDevices(),
  );

  Map<String, dynamic> toJson() => {
    'capture': capture.map((e) => e.toJson()).toList(),
    'playback': playback.map((e) => e.toJson()).toList(),
    'current': current.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      other is AudioDevices && jsonEqual(toJson(), other.toJson());

  @override
  int get hashCode => jsonHash(toJson());

  @override
  String toString() => 'AudioDevices(${toJson()})';
}

class CodecInfo {
  const CodecInfo({
    this.id = '',
    this.name = '',
    this.clockRate = 0,
    this.channels = 1,
    this.priority = 0,
    this.enabled = false,
  });

  final String id;
  final String name;
  final int clockRate;
  final int channels;
  final int priority;
  final bool enabled;

  factory CodecInfo.fromJson(Map<String, dynamic> j) => CodecInfo(
    id: asString(j['id'], ''),
    name: asString(j['name'], ''),
    clockRate: asInt(j['clockRate'], 0),
    channels: asInt(j['channels'], 1),
    priority: asInt(j['priority'], 0),
    enabled: asBool(j['enabled'], false),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'clockRate': clockRate,
    'channels': channels,
    'priority': priority,
    'enabled': enabled,
  };

  CodecInfo copyWith({
    String? id,
    String? name,
    int? clockRate,
    int? channels,
    int? priority,
    bool? enabled,
  }) => CodecInfo(
    id: id ?? this.id,
    name: name ?? this.name,
    clockRate: clockRate ?? this.clockRate,
    channels: channels ?? this.channels,
    priority: priority ?? this.priority,
    enabled: enabled ?? this.enabled,
  );

  @override
  bool operator ==(Object other) =>
      other is CodecInfo && jsonEqual(toJson(), other.toJson());

  @override
  int get hashCode => jsonHash(toJson());

  @override
  String toString() => 'CodecInfo(${toJson()})';
}

class OpusParams {
  const OpusParams({
    this.bitrate,
    this.fec,
    this.dtx,
    this.cbr,
    this.complexity,
    this.maxPlaybackRate,
  });

  final int? bitrate;
  final bool? fec;
  final bool? dtx;
  final bool? cbr;
  final int? complexity;
  final int? maxPlaybackRate;

  factory OpusParams.fromJson(Map<String, dynamic> j) => OpusParams(
    bitrate: asIntN(j['bitrate']),
    fec: asBoolN(j['fec']),
    dtx: asBoolN(j['dtx']),
    cbr: asBoolN(j['cbr']),
    complexity: asIntN(j['complexity']),
    maxPlaybackRate: asIntN(j['maxPlaybackRate']),
  );

  Map<String, dynamic> toJson() => {
    if (bitrate != null) 'bitrate': bitrate,
    if (fec != null) 'fec': fec,
    if (dtx != null) 'dtx': dtx,
    if (cbr != null) 'cbr': cbr,
    if (complexity != null) 'complexity': complexity,
    if (maxPlaybackRate != null) 'maxPlaybackRate': maxPlaybackRate,
  };

  @override
  bool operator ==(Object other) =>
      other is OpusParams && jsonEqual(toJson(), other.toJson());

  @override
  int get hashCode => jsonHash(toJson());

  @override
  String toString() => 'OpusParams(${toJson()})';
}

/// One direction of AI noise suppression (docs/ENGINE_API.md 9.1).
class VoiceIsolationSide {
  const VoiceIsolationSide({this.enabled = false, this.strength = 1.0});

  final bool enabled;
  final double strength;

  factory VoiceIsolationSide.fromJson(Map<String, dynamic> j) =>
      VoiceIsolationSide(
        enabled: asBool(j['enabled'], false),
        strength: asDouble(j['strength'], 1.0).clamp(0.0, 1.0).toDouble(),
      );

  Map<String, dynamic> toJson() => {'enabled': enabled, 'strength': strength};

  VoiceIsolationSide copyWith({bool? enabled, double? strength}) =>
      VoiceIsolationSide(
        enabled: enabled ?? this.enabled,
        strength: strength ?? this.strength,
      );

  @override
  bool operator ==(Object other) =>
      other is VoiceIsolationSide && jsonEqual(toJson(), other.toJson());

  @override
  int get hashCode => jsonHash(toJson());

  @override
  String toString() => 'VoiceIsolationSide(${toJson()})';
}

/// `core.start` media.voiceIsolation (default: both off).
class VoiceIsolationConfig {
  const VoiceIsolationConfig({
    this.mic = const VoiceIsolationSide(),
    this.incoming = const VoiceIsolationSide(),
  });

  final VoiceIsolationSide mic;
  final VoiceIsolationSide incoming;

  factory VoiceIsolationConfig.fromJson(Map<String, dynamic> j) =>
      VoiceIsolationConfig(
        mic: j['mic'] is Map
            ? VoiceIsolationSide.fromJson(asMap(j['mic']))
            : const VoiceIsolationSide(),
        incoming: j['incoming'] is Map
            ? VoiceIsolationSide.fromJson(asMap(j['incoming']))
            : const VoiceIsolationSide(),
      );

  Map<String, dynamic> toJson() => {
    'mic': mic.toJson(),
    'incoming': incoming.toJson(),
  };

  VoiceIsolationConfig copyWith({
    VoiceIsolationSide? mic,
    VoiceIsolationSide? incoming,
  }) => VoiceIsolationConfig(
    mic: mic ?? this.mic,
    incoming: incoming ?? this.incoming,
  );

  @override
  bool operator ==(Object other) =>
      other is VoiceIsolationConfig && jsonEqual(toJson(), other.toJson());

  @override
  int get hashCode => jsonHash(toJson());

  @override
  String toString() => 'VoiceIsolationConfig(${toJson()})';
}

/// Result of `media.setVoiceIsolation`.
class VoiceIsolationResult {
  const VoiceIsolationResult({this.available = false, this.engine = ''});

  final bool available;
  final String engine;

  factory VoiceIsolationResult.fromJson(Map<String, dynamic> j) =>
      VoiceIsolationResult(
        available: asBool(j['available'], false),
        engine: asString(j['engine'], ''),
      );

  Map<String, dynamic> toJson() => {'available': available, 'engine': engine};

  VoiceIsolationResult copyWith({bool? available, String? engine}) =>
      VoiceIsolationResult(
        available: available ?? this.available,
        engine: engine ?? this.engine,
      );

  @override
  bool operator ==(Object other) =>
      other is VoiceIsolationResult && jsonEqual(toJson(), other.toJson());

  @override
  int get hashCode => jsonHash(toJson());

  @override
  String toString() => 'VoiceIsolationResult(${toJson()})';
}

/// Mic side of `media.voiceIsolationStatus`; [vad] is speech probability 0-1.
class VoiceIsolationMicStatus {
  const VoiceIsolationMicStatus({
    this.enabled = false,
    this.strength = 1.0,
    this.vad = 0.0,
  });

  final bool enabled;
  final double strength;
  final double vad;

  factory VoiceIsolationMicStatus.fromJson(Map<String, dynamic> j) =>
      VoiceIsolationMicStatus(
        enabled: asBool(j['enabled'], false),
        strength: asDouble(j['strength'], 1.0),
        vad: asDouble(j['vad'], 0.0).clamp(0.0, 1.0).toDouble(),
      );

  Map<String, dynamic> toJson() => {
    'enabled': enabled,
    'strength': strength,
    'vad': vad,
  };

  VoiceIsolationMicStatus copyWith({
    bool? enabled,
    double? strength,
    double? vad,
  }) => VoiceIsolationMicStatus(
    enabled: enabled ?? this.enabled,
    strength: strength ?? this.strength,
    vad: vad ?? this.vad,
  );

  @override
  bool operator ==(Object other) =>
      other is VoiceIsolationMicStatus && jsonEqual(toJson(), other.toJson());

  @override
  int get hashCode => jsonHash(toJson());

  @override
  String toString() => 'VoiceIsolationMicStatus(${toJson()})';
}

/// Result of `media.voiceIsolationStatus`.
class VoiceIsolationStatus {
  const VoiceIsolationStatus({
    this.mic = const VoiceIsolationMicStatus(),
    this.incoming = const VoiceIsolationSide(),
  });

  final VoiceIsolationMicStatus mic;
  final VoiceIsolationSide incoming;

  factory VoiceIsolationStatus.fromJson(Map<String, dynamic> j) =>
      VoiceIsolationStatus(
        mic: j['mic'] is Map
            ? VoiceIsolationMicStatus.fromJson(asMap(j['mic']))
            : const VoiceIsolationMicStatus(),
        incoming: j['incoming'] is Map
            ? VoiceIsolationSide.fromJson(asMap(j['incoming']))
            : const VoiceIsolationSide(),
      );

  Map<String, dynamic> toJson() => {
    'mic': mic.toJson(),
    'incoming': incoming.toJson(),
  };

  VoiceIsolationStatus copyWith({
    VoiceIsolationMicStatus? mic,
    VoiceIsolationSide? incoming,
  }) => VoiceIsolationStatus(
    mic: mic ?? this.mic,
    incoming: incoming ?? this.incoming,
  );

  @override
  bool operator ==(Object other) =>
      other is VoiceIsolationStatus && jsonEqual(toJson(), other.toJson());

  @override
  int get hashCode => jsonHash(toJson());

  @override
  String toString() => 'VoiceIsolationStatus(${toJson()})';
}

/// Result of `media.fileInfo` (`format` is "wav" or "mp3").
class MediaFileInfo {
  const MediaFileInfo({
    this.format = '',
    this.durationMs = 0,
    this.sampleRate = 0,
    this.channels = 0,
  });

  final String format;
  final int durationMs;
  final int sampleRate;
  final int channels;

  factory MediaFileInfo.fromJson(Map<String, dynamic> j) => MediaFileInfo(
    format: asString(j['format'], ''),
    durationMs: asInt(j['durationMs'], 0),
    sampleRate: asInt(j['sampleRate'], 0),
    channels: asInt(j['channels'], 0),
  );

  Map<String, dynamic> toJson() => {
    'format': format,
    'durationMs': durationMs,
    'sampleRate': sampleRate,
    'channels': channels,
  };

  MediaFileInfo copyWith({
    String? format,
    int? durationMs,
    int? sampleRate,
    int? channels,
  }) => MediaFileInfo(
    format: format ?? this.format,
    durationMs: durationMs ?? this.durationMs,
    sampleRate: sampleRate ?? this.sampleRate,
    channels: channels ?? this.channels,
  );

  @override
  bool operator ==(Object other) =>
      other is MediaFileInfo && jsonEqual(toJson(), other.toJson());

  @override
  int get hashCode => jsonHash(toJson());

  @override
  String toString() => 'MediaFileInfo(${toJson()})';
}

/// Client-side music on hold (`call.hold` music param).
class HoldMusic {
  const HoldMusic({this.file = '', this.loop = true, this.volume = 1.0});

  final String file;
  final bool loop;
  final double volume;

  factory HoldMusic.fromJson(Map<String, dynamic> j) => HoldMusic(
    file: asString(j['file'], ''),
    loop: asBool(j['loop'], true),
    volume: asDouble(j['volume'], 1.0),
  );

  Map<String, dynamic> toJson() => {
    'file': file,
    'loop': loop,
    'volume': volume,
  };

  HoldMusic copyWith({String? file, bool? loop, double? volume}) => HoldMusic(
    file: file ?? this.file,
    loop: loop ?? this.loop,
    volume: volume ?? this.volume,
  );

  @override
  bool operator ==(Object other) =>
      other is HoldMusic && jsonEqual(toJson(), other.toJson());

  @override
  int get hashCode => jsonHash(toJson());

  @override
  String toString() => 'HoldMusic(${toJson()})';
}
