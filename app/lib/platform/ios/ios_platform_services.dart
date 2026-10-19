import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../android/android_platform_services.dart' show DeviceContact;
import '../desktop/launch_args.dart' show parseLink;
import '../platform_services.dart';

/// iOS host services over a MethodChannel + one EventChannel implemented in
/// `app/ios/Runner/PlatformBridge.swift`.
///
/// Limitation (v1): no PushKit / VoIP push, so incoming calls are only
/// reported to CallKit while the app process is running (foreground, or
/// background with the `audio`/`voip` background modes keeping the SIP
/// socket alive). See docs/ARCHITECTURE.md section 8.
class IosPlatformServices extends NoopPlatformServices {
  IosPlatformServices({MethodChannel? method, EventChannel? events})
    : _method = method ?? const MethodChannel('softphonepro/platform'),
      _events = events ?? const EventChannel('softphonepro/platform/events'),
      super(mobile: true);

  final MethodChannel _method;
  final EventChannel _events;

  StreamSubscription<dynamic>? _sub;
  final _route = StreamController<AudioRoute>.broadcast();
  final _session = StreamController<bool>.broadcast();
  final _actions = StreamController<SystemCallAction>.broadcast();
  final _links = StreamController<Uri>.broadcast();
  final _dtmf = StreamController<({String callKey, String digits})>.broadcast();

  /// DTMF digits typed on the system call UI.
  Stream<({String callKey, String digits})> get systemDtmf => _dtmf.stream;

  @override
  bool get ringsViaOs => true;

  @override
  Future<void> init() async {
    _sub = _events.receiveBroadcastStream().listen(
      handleEvent,
      onError: (Object e) => debugPrint('ios events error: $e'),
    );
    await _call('init');
  }

  @override
  Future<void> dispose() async {
    await _sub?.cancel();
    await _route.close();
    await _session.close();
    await _actions.close();
    await _links.close();
    await _dtmf.close();
  }

  Future<T?> _call<T>(String method, [Map<String, Object?>? args]) async {
    try {
      return await _method.invokeMethod<T>(method, args);
    } on MissingPluginException {
      return null;
    } on PlatformException catch (e) {
      debugPrint('ios $method failed: ${e.code} ${e.message}');
      return null;
    }
  }

  /// Decodes one event map from the native side.
  @visibleForTesting
  void handleEvent(dynamic raw) {
    if (raw is! Map) return;
    switch (raw['type']) {
      case 'audioSession':
        _session.add(raw['active'] == true);
      case 'route':
        final r = parseRoute(raw['route'] as String?);
        if (r != null) _route.add(r);
      case 'callAction':
        final k = parseActionKind(raw['kind'] as String?);
        final key = raw['callKey'] as String?;
        if (k != null && key != null) _actions.add(SystemCallAction(k, key));
      case 'dtmf':
        final key = raw['callKey'] as String?;
        final digits = raw['digits'] as String?;
        if (key != null && digits != null) {
          _dtmf.add((callKey: key, digits: digits));
        }
      case 'link':
        final u = parseLink(raw['url'] as String? ?? '');
        if (u != null) _links.add(u);
    }
  }

  static AudioRoute? parseRoute(String? s) => switch (s) {
    'earpiece' => AudioRoute.earpiece,
    'speaker' => AudioRoute.speaker,
    'bluetooth' => AudioRoute.bluetooth,
    'wired' => AudioRoute.wired,
    _ => null,
  };

  static SystemCallActionKind? parseActionKind(String? s) {
    for (final k in SystemCallActionKind.values) {
      if (k.name == s) return k;
    }
    return null;
  }

  static PermissionStatus parsePermission(Object? s) => switch (s) {
    'granted' => PermissionStatus.granted,
    'denied' => PermissionStatus.denied,
    'permanentlyDenied' => PermissionStatus.permanentlyDenied,
    _ => PermissionStatus.unsupported,
  };

  // ---- permissions
  @override
  Future<PermissionsResult> requestPermissions() async {
    final m = await _call<Map<Object?, Object?>>('requestPermissions');
    if (m == null) return const PermissionsResult();
    return PermissionsResult(
      microphone: parsePermission(m['microphone']),
      notifications: parsePermission(m['notifications']),
      contacts: parsePermission(m['contacts']),
    );
  }

  // ---- device contacts
  /// Asks for Contacts access (CNContactStore); true when granted.
  Future<bool> requestContactsPermission() async =>
      parsePermission(await _call<String>('requestContactsPermission')) ==
      PermissionStatus.granted;

  /// Reads name, phone numbers and emails of all device contacts.
  Future<List<DeviceContact>> readDeviceContacts() async =>
      parseDeviceContacts(await _call<List<Object?>>('readContacts'));

  /// Decodes the list produced by the native `readContacts`.
  static List<DeviceContact> parseDeviceContacts(List<Object?>? l) => [
    for (final c in (l ?? const []).whereType<Map>())
      DeviceContact(
        id: '${c['id']}',
        name: '${c['name'] ?? ''}',
        numbers: [
          for (final n in (c['numbers'] as List? ?? const []).whereType<Map>())
            ('${n['label'] ?? ''}', '${n['number']}'),
        ],
        emails: [for (final e in (c['emails'] as List? ?? const [])) '$e'],
      ),
  ];

  // ---- notifications (incoming calls are shown by CallKit)
  @override
  Future<void> showMissedCallNotification({
    required String title,
    required String body,
    String? payload,
  }) => _call('showNotification', {
    'id': 'missed-${DateTime.now().microsecondsSinceEpoch}',
    'title': title,
    'body': body,
    'payload': payload,
  });

  @override
  Future<void> showMessageNotification({
    required String title,
    required String body,
    String? payload,
  }) => _call('showNotification', {
    'id': 'msg-${DateTime.now().microsecondsSinceEpoch}',
    'title': title,
    'body': body,
    'payload': payload,
  });

  // ---- audio route
  @override
  Future<Set<AudioRoute>> availableAudioRoutes() async {
    final l = await _call<List<Object?>>('availableAudioRoutes');
    if (l == null) return super.availableAudioRoutes();
    return {
      for (final s in l)
        if (parseRoute(s as String?) case final r?) r,
    };
  }

  @override
  Future<AudioRoute> getAudioRoute() async =>
      parseRoute(await _call<String>('getAudioRoute')) ?? AudioRoute.earpiece;

  @override
  Future<void> setAudioRoute(AudioRoute route) =>
      _call('setAudioRoute', {'route': route.name});

  @override
  Stream<AudioRoute> get audioRouteChanges => _route.stream;

  // ---- sensors / screen
  @override
  Future<void> setProximityEnabled(bool enabled) =>
      _call('setProximityEnabled', {'enabled': enabled});

  @override
  Future<void> setKeepScreenOn(bool keepOn) =>
      _call('setKeepScreenOn', {'keepOn': keepOn});

  // ---- CallKit
  @override
  Future<void> reportIncomingCall({
    required String callKey,
    required String handle,
    required String displayName,
  }) => _call('reportIncomingCall', {
    'callKey': callKey,
    'handle': handle,
    'displayName': displayName,
  });

  @override
  Future<void> reportOutgoingCall({
    required String callKey,
    required String handle,
    required String displayName,
  }) => _call('reportOutgoingCall', {
    'callKey': callKey,
    'handle': handle,
    'displayName': displayName,
  });

  @override
  Future<void> reportCallConnected(String callKey) =>
      _call('reportCallConnected', {'callKey': callKey});

  @override
  Future<void> reportCallEnded(String callKey, {String reason = 'remoteEnded'}) =>
      _call('reportCallEnded', {'callKey': callKey, 'reason': reason});

  @override
  Stream<bool> get audioSessionActive => _session.stream;

  @override
  Stream<SystemCallAction> get systemCallActions => _actions.stream;

  // ---- links
  @override
  Stream<Uri> get incomingLinks => _links.stream;

  @override
  Future<Uri?> initialLink() async {
    final s = await _call<String>('initialLink');
    return s == null ? null : parseLink(s);
  }

  @override
  Future<void> updateBadge(int count) => _call('updateBadge', {'count': count});
}
