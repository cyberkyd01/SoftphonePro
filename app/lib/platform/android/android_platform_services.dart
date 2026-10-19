import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../platform_services.dart';

/// A device contact (name + phone numbers) read from the Android address book.
class DeviceContact {
  const DeviceContact({required this.id, required this.name, required this.numbers});
  final String id;
  final String name;

  /// `(label, number)` pairs.
  final List<(String, String)> numbers;
}

/// Extra permission/feature state exposed by Android.
class AndroidStatus {
  const AndroidStatus({
    this.microphone = PermissionStatus.unsupported,
    this.notifications = PermissionStatus.unsupported,
    this.contacts = PermissionStatus.unsupported,
    this.bluetooth = PermissionStatus.unsupported,
    this.fullScreenIntent = true,
    this.batteryOptimizationsIgnored = false,
    this.sdk = 0,
    this.manufacturer = '',
  });
  final PermissionStatus microphone;
  final PermissionStatus notifications;
  final PermissionStatus contacts;
  final PermissionStatus bluetooth;

  /// Android 14+: whether full-screen incoming-call UI is allowed.
  final bool fullScreenIntent;
  final bool batteryOptimizationsIgnored;
  final int sdk;
  final String manufacturer;

  static PermissionStatus _p(Object? v) => switch (v) {
    'granted' => PermissionStatus.granted,
    'denied' => PermissionStatus.denied,
    'permanentlyDenied' => PermissionStatus.permanentlyDenied,
    _ => PermissionStatus.unsupported,
  };

  factory AndroidStatus.fromMap(Map<Object?, Object?> m) => AndroidStatus(
    microphone: _p(m['microphone']),
    notifications: _p(m['notifications']),
    contacts: _p(m['contacts']),
    bluetooth: _p(m['bluetooth']),
    fullScreenIntent: m['fullScreenIntent'] != false,
    batteryOptimizationsIgnored: m['batteryOptimizationsIgnored'] == true,
    sdk: (m['sdk'] as num?)?.toInt() ?? 0,
    manufacturer: '${m['manufacturer'] ?? ''}',
  );

  PermissionsResult toResult() => PermissionsResult(
    microphone: microphone,
    notifications: notifications,
    contacts: contacts,
  );
}

/// Android implementation: foreground service, notifications (full-screen
/// incoming call), ringtone, Telecom self-managed calls, audio routing,
/// proximity and URL intents, all in Kotlin behind one MethodChannel.
class AndroidPlatformServices extends NoopPlatformServices {
  AndroidPlatformServices() : super(mobile: true);

  static const _m = MethodChannel('softphonepro/platform');
  static const _e = EventChannel('softphonepro/platform/events');

  final _actions = StreamController<SystemCallAction>.broadcast();
  final _links = StreamController<Uri>.broadcast();
  final _routes = StreamController<AudioRoute>.broadcast();
  final _dns = StreamController<List<String>>.broadcast();
  final _nav = StreamController<String>.broadcast();
  StreamSubscription<dynamic>? _sub;

  @override
  bool get ringsViaOs => true;

  Future<T?> _call<T>(String method, [Object? args]) async {
    try {
      return await _m.invokeMethod<T>(method, args);
    } on MissingPluginException {
      debugPrint('android $method: no native handler');
      return null;
    } on PlatformException catch (e) {
      debugPrint('android $method failed: ${e.message}');
      return null;
    }
  }

  @override
  Future<void> init() async {
    _sub ??= _e.receiveBroadcastStream().listen(_onEvent, onError: (_) {});
    await _call<Object>('init');
  }

  @override
  Future<void> dispose() async {
    await _sub?.cancel();
    _sub = null;
  }

  void _onEvent(dynamic ev) {
    if (ev is! Map) return;
    switch (ev['type']) {
      case 'callAction':
        final kind = SystemCallActionKind.values.asNameMap()['${ev['kind']}'];
        final key = '${ev['callKey']}';
        if (kind != null) _actions.add(SystemCallAction(kind, key));
      case 'audioRoute':
        final r = _route('${ev['route']}');
        if (r != null) _routes.add(r);
      case 'link':
        final u = Uri.tryParse('${ev['uri']}');
        if (u != null) _links.add(u);
      case 'dns':
        _dns.add([for (final s in (ev['servers'] as List? ?? const [])) '$s']);
      case 'route':
        _nav.add('${ev['route']}');
    }
  }

  static AudioRoute? _route(String s) => AudioRoute.values.asNameMap()[s];

  // ---- permissions ---------------------------------------------------------

  @override
  Future<PermissionsResult> requestPermissions() async =>
      (await requestAll()).toResult();

  /// Requests microphone, notification and Bluetooth permissions (and contacts
  /// when [contacts] is set); returns the resulting state.
  Future<AndroidStatus> requestAll({bool contacts = false}) async {
    final m = await _call<Map<Object?, Object?>>('requestPermissions', {'contacts': contacts});
    return m == null ? const AndroidStatus() : AndroidStatus.fromMap(m);
  }

  Future<AndroidStatus> status() async {
    final m = await _call<Map<Object?, Object?>>('permissions');
    return m == null ? const AndroidStatus() : AndroidStatus.fromMap(m);
  }

  Future<AndroidStatus> requestContactsPermission() async {
    final m = await _call<Map<Object?, Object?>>('requestContactsPermission');
    return m == null ? const AndroidStatus() : AndroidStatus.fromMap(m);
  }

  Future<List<DeviceContact>> readDeviceContacts() async {
    final l = await _call<List<Object?>>('readContacts') ?? const [];
    return [
      for (final c in l.whereType<Map>())
        DeviceContact(
          id: '${c['id']}',
          name: '${c['name']}',
          numbers: [
            for (final n in (c['numbers'] as List? ?? const []).whereType<Map>())
              ('${n['label']}', '${n['number']}'),
          ],
        ),
    ];
  }

  Future<bool> openFullScreenIntentSettings() async => await _call<bool>('openFullScreenIntentSettings') ?? false;
  Future<bool> openNotificationSettings() async => await _call<bool>('openNotificationSettings') ?? false;
  Future<bool> openAppSettings() async => await _call<bool>('openAppSettings') ?? false;

  // ---- battery / background reliability -----------------------------------------

  Future<bool> isIgnoringBatteryOptimizations() async =>
      await _call<bool>('isIgnoringBatteryOptimizations') ?? false;
  Future<bool> requestIgnoreBatteryOptimizations() async =>
      await _call<bool>('requestIgnoreBatteryOptimizations') ?? false;

  /// Opens the vendor autostart / protected apps screen (Xiaomi, Huawei, Oppo,
  /// Vivo, Samsung, Asus). Returns false when unavailable.
  Future<bool> openAutostartSettings() async => await _call<bool>('openAutostartSettings') ?? false;
  Future<bool> hasAutostartSettings() async => await _call<bool>('hasAutostartSettings') ?? false;

  Future<bool> idleWakeLock() async => await _call<bool>('idleWakeLock') ?? false;

  /// Hold a partial CPU wake lock while registered and idle (more reliable on
  /// aggressive devices, costs battery).
  Future<void> setIdleWakeLock(bool enabled) => _call<void>('setIdleWakeLock', {'enabled': enabled});

  /// Keeps the registration foreground service running (idle notification
  /// "SoftphonePro - N accounts online").
  Future<void> setBackgroundService({required bool enabled, int online = 0, int total = 0}) =>
      _call<void>('setBackgroundService', {'enabled': enabled, 'online': online, 'total': total});

  /// Holds the Wi-Fi multicast lock (needed for LAN discovery).
  Future<void> setMulticastLock(bool enabled) => _call<void>('setMulticast', {'enabled': enabled});

  // ---- DNS ----------------------------------------------------------------------

  /// DNS servers of the active network (Android has no res_ninit for the engine).
  Future<List<String>> getDnsServers() async {
    final l = await _call<List<Object?>>('getDnsServers');
    return [for (final s in l ?? const []) '$s'];
  }

  /// Emits the new list whenever the active network's DNS servers change.
  Stream<List<String>> get dnsChanges => _dns.stream;

  /// Routes requested by notification taps (e.g. `/recents`, `/messages`).
  Stream<String> get routeRequests => _nav.stream;

  // ---- notifications -----------------------------------------------------------

  @override
  Future<void> showIncomingCallNotification({
    required String callKey,
    required String title,
    required String body,
    String? accountName,
  }) => _call<void>('showIncoming', {
    'callKey': callKey,
    'title': title,
    'body': body,
    'account': accountName,
  });

  @override
  Future<void> cancelIncomingCallNotification(String callKey) =>
      _call<void>('cancelIncoming', {'callKey': callKey});

  @override
  Future<void> showMissedCallNotification({
    required String title,
    required String body,
    String? payload,
  }) => _call<void>('showMissed', {'title': title, 'body': body, 'payload': payload});

  @override
  Future<void> showMessageNotification({
    required String title,
    required String body,
    String? payload,
  }) => _call<void>('showMessage', {'title': title, 'body': body, 'payload': payload});

  // ---- ringtone ------------------------------------------------------------------

  @override
  Future<void> startRingtone({String ringtone = 'default', double volume = 1}) =>
      _call<void>('startRingtone', {'ringtone': ringtone, 'volume': volume});

  @override
  Future<void> stopRingtone() => _call<void>('stopRingtone');

  // ---- audio routes ---------------------------------------------------------------

  @override
  Future<Set<AudioRoute>> availableAudioRoutes() async {
    final l = await _call<List<Object?>>('availableRoutes');
    final s = {for (final n in l ?? const []) ?_route('$n')};
    return s.isEmpty ? {AudioRoute.earpiece, AudioRoute.speaker} : s;
  }

  @override
  Future<AudioRoute> getAudioRoute() async =>
      _route(await _call<String>('getRoute') ?? '') ?? AudioRoute.earpiece;

  @override
  Future<void> setAudioRoute(AudioRoute route) => _call<void>('setRoute', {'route': route.name});

  @override
  Stream<AudioRoute> get audioRouteChanges => _routes.stream;

  // ---- sensors / screen --------------------------------------------------------------

  @override
  Future<void> setProximityEnabled(bool enabled) => _call<void>('setProximity', {'enabled': enabled});

  @override
  Future<void> setKeepScreenOn(bool keepOn) => _call<void>('setKeepScreenOn', {'enabled': keepOn});

  // ---- background service -------------------------------------------------------------

  @override
  Future<void> startForegroundService({required String text}) => _call<void>('startCallService', {'text': text});

  @override
  Future<void> stopForegroundService() => _call<void>('stopCallService');

  // ---- Telecom --------------------------------------------------------------------------

  @override
  Future<void> reportIncomingCall({
    required String callKey,
    required String handle,
    required String displayName,
  }) => _call<void>('telecomIncoming', {'callKey': callKey, 'handle': handle, 'name': displayName});

  @override
  Future<void> reportOutgoingCall({
    required String callKey,
    required String handle,
    required String displayName,
  }) => _call<void>('telecomOutgoing', {'callKey': callKey, 'handle': handle, 'name': displayName});

  @override
  Future<void> reportCallConnected(String callKey) => _call<void>('callConnected', {'callKey': callKey});

  @override
  Future<void> reportCallEnded(String callKey, {String reason = 'remoteEnded'}) =>
      _call<void>('callEnded', {'callKey': callKey, 'reason': reason});

  @override
  Stream<SystemCallAction> get systemCallActions => _actions.stream;

  // ---- links ------------------------------------------------------------------------------

  @override
  Stream<Uri> get incomingLinks => _links.stream;

  @override
  Future<Uri?> initialLink() async {
    final s = await _call<String>('initialLink');
    return s == null ? null : Uri.tryParse(s);
  }

  @override
  Future<void> bringToFront() => _call<void>('bringToFront');

  /// "Start at login" maps to starting the service/engine at device boot.
  @override
  Future<void> setStartAtLogin(bool enabled) => _call<void>('setStartAtBoot', {'enabled': enabled});

  Future<bool> startAtBoot() async => await _call<bool>('startAtBoot') ?? false;
}
