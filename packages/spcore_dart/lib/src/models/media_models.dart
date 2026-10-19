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
