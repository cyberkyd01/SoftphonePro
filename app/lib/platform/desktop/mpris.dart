import 'dart:async';

import 'package:dbus/dbus.dart';
import 'package:flutter/foundation.dart';

import 'media_keys.dart';

const kMprisBusName = 'org.mpris.MediaPlayer2.softphonepro';
const kMprisPath = '/org/mpris/MediaPlayer2';
const _ifRoot = 'org.mpris.MediaPlayer2';
const _ifPlayer = 'org.mpris.MediaPlayer2.Player';

/// The exported MPRIS object. GNOME / KDE send headset and keyboard
/// play-pause to the MPRIS player that is "Playing"; every transport call
/// here is reported as one press through [onPress].
class MprisObject extends DBusObject {
  MprisObject({required this.onPress, this.onRaise, this.title = 'Call', this.desktopEntry = 'com.softphonepro.softphonepro'})
    : super(DBusObjectPath(kMprisPath));

  final void Function() onPress;
  final void Function()? onRaise;
  final String title;
  final String desktopEntry;

  /// "Playing" while a call rings / is active (the keys are claimed).
  bool playing = true;

  Map<String, DBusValue> get _root => {
    'CanQuit': const DBusBoolean(false),
    'CanRaise': DBusBoolean(onRaise != null),
    'HasTrackList': const DBusBoolean(false),
    'Identity': const DBusString('SoftphonePro'),
    'DesktopEntry': DBusString(desktopEntry),
    'SupportedUriSchemes': DBusArray.string(const []),
    'SupportedMimeTypes': DBusArray.string(const []),
  };

  Map<String, DBusValue> get _player => {
    'PlaybackStatus': DBusString(playing ? 'Playing' : 'Stopped'),
    'Rate': const DBusDouble(1.0),
    'MinimumRate': const DBusDouble(1.0),
    'MaximumRate': const DBusDouble(1.0),
    'Volume': const DBusDouble(1.0),
    'Position': const DBusInt64(0),
    'Metadata': DBusDict.stringVariant({
      'mpris:trackid': DBusObjectPath('/org/softphonepro/call'),
      'xesam:title': DBusString(title),
    }),
    'CanGoNext': const DBusBoolean(false),
    'CanGoPrevious': const DBusBoolean(false),
    'CanPlay': const DBusBoolean(true),
    'CanPause': const DBusBoolean(true),
    'CanSeek': const DBusBoolean(false),
    'CanControl': const DBusBoolean(true),
  };

  Map<String, DBusValue>? _props(String interface) => switch (interface) {
    _ifRoot => _root,
    _ifPlayer => _player,
    _ => null,
  };

  @override
  List<DBusIntrospectInterface> introspect() => [
    DBusIntrospectInterface(
      _ifRoot,
      methods: [DBusIntrospectMethod('Raise'), DBusIntrospectMethod('Quit')],
      properties: [
        for (final e in _root.entries) DBusIntrospectProperty(e.key, e.value.signature, access: DBusPropertyAccess.read),
      ],
    ),
    DBusIntrospectInterface(
      _ifPlayer,
      methods: [
        for (final m in const ['Next', 'Previous', 'Pause', 'PlayPause', 'Stop', 'Play']) DBusIntrospectMethod(m),
      ],
      properties: [
        for (final e in _player.entries) DBusIntrospectProperty(e.key, e.value.signature, access: DBusPropertyAccess.read),
      ],
    ),
  ];

  @override
  Future<DBusMethodResponse> handleMethodCall(DBusMethodCall methodCall) async {
    if (methodCall.interface == _ifRoot) {
      switch (methodCall.name) {
        case 'Raise':
          onRaise?.call();
          return DBusMethodSuccessResponse();
        case 'Quit':
          return DBusMethodSuccessResponse(); // CanQuit is false
      }
      return DBusMethodErrorResponse.unknownMethod();
    }
    if (methodCall.interface == _ifPlayer) {
      switch (methodCall.name) {
        case 'PlayPause':
        case 'Play':
        case 'Pause':
        case 'Stop':
          onPress();
          return DBusMethodSuccessResponse();
        case 'Next':
        case 'Previous':
          return DBusMethodSuccessResponse();
      }
      return DBusMethodErrorResponse.unknownMethod();
    }
    return DBusMethodErrorResponse.unknownInterface();
  }

  @override
  Future<DBusMethodResponse> getProperty(String interface, String name) async {
    final props = _props(interface);
    if (props == null) return DBusMethodErrorResponse.unknownInterface();
    final v = props[name];
    return v == null ? DBusMethodErrorResponse.unknownProperty() : DBusGetPropertyResponse(v);
  }

  @override
  Future<DBusMethodResponse> getAllProperties(String interface) async {
    final props = _props(interface);
    return props == null ? DBusMethodErrorResponse.unknownInterface() : DBusGetAllPropertiesResponse(props);
  }

  @override
  Future<DBusMethodResponse> setProperty(String interface, String name, DBusValue value) async =>
      _props(interface)?.containsKey(name) == true
          ? DBusMethodErrorResponse.propertyReadOnly()
          : DBusMethodErrorResponse.unknownProperty();
}

/// Linux: owns `org.mpris.MediaPlayer2.softphonepro` only while claimed, so
/// the desktop routes the headset play/pause button to the call and music
/// players keep it otherwise. Any D-Bus failure disables the backend quietly.
class MprisMediaKeyBackend extends MediaKeyBackend {
  MprisMediaKeyBackend({this.onRaise, DBusClient Function()? clientFactory, this.title = 'Call'})
    : _factory = clientFactory ?? DBusClient.session;

  final void Function()? onRaise;
  final String title;
  final DBusClient Function() _factory;
  DBusClient? _client;
  MprisObject? _object;
  bool _owned = false;
  bool _broken = false;

  bool get owned => _owned;

  @override
  Future<void> setActive(bool active) async {
    if (_broken || active == _owned) return;
    try {
      if (active) {
        final c = _client ??= _factory();
        final o = _object ??= MprisObject(onPress: () => onPress?.call(), onRaise: onRaise, title: title);
        o.playing = true;
        if (o.client == null) await c.registerObject(o);
        final r = await c.requestName(kMprisBusName, flags: {DBusRequestNameFlag.doNotQueue}).timeout(const Duration(seconds: 3));
        _owned = r == DBusRequestNameReply.primaryOwner || r == DBusRequestNameReply.alreadyOwner;
      } else {
        await _release();
      }
    } catch (e) {
      debugPrint('MPRIS media keys unavailable: $e');
      _broken = true;
      _owned = false;
      await _closeClient();
    }
  }

  Future<void> _release() async {
    _owned = false;
    _object?.playing = false;
    await _client?.releaseName(kMprisBusName).timeout(const Duration(seconds: 3));
  }

  Future<void> _closeClient() async {
    final c = _client;
    _client = null;
    _object = null;
    try {
      await c?.close().timeout(const Duration(seconds: 1));
    } catch (_) {}
  }

  @override
  Future<void> dispose() async {
    try {
      if (_owned) await _release();
    } catch (_) {}
    await _closeClient();
  }
}
