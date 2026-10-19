import 'dart:async';
import 'dart:io';

/// Audio output routes on mobile.
enum AudioRoute { earpiece, speaker, bluetooth, wired }

/// Requests from the system call UI (CallKit / ConnectionService / headset
/// buttons / notification actions) that the app must apply.
enum SystemCallActionKind { answer, decline, end, hold, unhold, mute, unmute }

class SystemCallAction {
  const SystemCallAction(this.kind, this.callKey);
  final SystemCallActionKind kind;

  /// The key given to [PlatformServices.reportIncomingCall] (the engine cid
  /// as a string).
  final String callKey;
}

enum PermissionStatus { granted, denied, permanentlyDenied, unsupported }

class PermissionsResult {
  const PermissionsResult({
    this.microphone = PermissionStatus.unsupported,
    this.notifications = PermissionStatus.unsupported,
    this.contacts = PermissionStatus.unsupported,
  });
  final PermissionStatus microphone;
  final PermissionStatus notifications;
  final PermissionStatus contacts;
}

/// Everything the app needs from the host OS that is not pure Dart.
///
/// The default [NoopPlatformServices] makes every call a harmless no-op so
/// the app runs anywhere; platform agents provide real implementations
/// (Android ConnectionService/foreground service, iOS CallKit, desktop tray
/// and URL handlers) and override `platformServicesProvider`.
abstract class PlatformServices {
  /// Whether the OS rings (mobile) instead of the engine's ringer device.
  bool get ringsViaOs;

  Future<void> init();
  Future<void> dispose();

  // ---- permissions
  Future<PermissionsResult> requestPermissions();

  // ---- notifications
  Future<void> showIncomingCallNotification({
    required String callKey,
    required String title,
    required String body,
    String? accountName,
  });
  Future<void> cancelIncomingCallNotification(String callKey);
  Future<void> showMissedCallNotification({
    required String title,
    required String body,
    String? payload,
  });
  Future<void> showMessageNotification({
    required String title,
    required String body,
    String? payload,
  });

  // ---- ringtone (mobile)
  Future<void> startRingtone({String ringtone = 'default', double volume = 1});
  Future<void> stopRingtone();

  // ---- audio route
  Future<Set<AudioRoute>> availableAudioRoutes();
  Future<AudioRoute> getAudioRoute();
  Future<void> setAudioRoute(AudioRoute route);
  Stream<AudioRoute> get audioRouteChanges;

  // ---- sensors / screen
  Future<void> setProximityEnabled(bool enabled);
  Future<void> setKeepScreenOn(bool keepOn);

  // ---- background service
  Future<void> startForegroundService({required String text});
  Future<void> stopForegroundService();

  // ---- CallKit / ConnectionService hooks
  Future<void> reportIncomingCall({
    required String callKey,
    required String handle,
    required String displayName,
  });
  Future<void> reportOutgoingCall({
    required String callKey,
    required String handle,
    required String displayName,
  });
  Future<void> reportCallConnected(String callKey);
  Future<void> reportCallEnded(String callKey, {String reason = 'remoteEnded'});

  /// iOS: CallKit activated/deactivated the audio session. The app then sends
  /// `media.setDevices` (see ENGINE_API §5).
  Stream<bool> get audioSessionActive;

  /// Actions triggered from the system UI.
  Stream<SystemCallAction> get systemCallActions;

  // ---- links
  /// Launch arguments / URL scheme events: sip:, sips:, tel:, callto:,
  /// softphonepro:.
  Stream<Uri> get incomingLinks;
  Future<Uri?> initialLink();

  // ---- desktop shell
  Future<void> bringToFront();
  Future<void> updateBadge(int count);
  Future<void> updateTray({
    String? tooltip,
    int missedCalls = 0,
    bool inCall = false,
    bool ringing = false,
  });
  Future<void> setStartAtLogin(bool enabled);
}

/// Safe default: does nothing, never throws.
class NoopPlatformServices implements PlatformServices {
  NoopPlatformServices({this.mobile = false});

  /// Pretend to be a mobile device (tests, emulators without native code).
  final bool mobile;

  final StreamController<AudioRoute> _route = StreamController.broadcast();
  AudioRoute _current = AudioRoute.earpiece;

  @override
  bool get ringsViaOs => false;

  @override
  Future<void> init() async {}
  @override
  Future<void> dispose() async {}
  @override
  Future<PermissionsResult> requestPermissions() async =>
      const PermissionsResult();
  @override
  Future<void> showIncomingCallNotification({
    required String callKey,
    required String title,
    required String body,
    String? accountName,
  }) async {}
  @override
  Future<void> cancelIncomingCallNotification(String callKey) async {}
  @override
  Future<void> showMissedCallNotification({
    required String title,
    required String body,
    String? payload,
  }) async {}
  @override
  Future<void> showMessageNotification({
    required String title,
    required String body,
    String? payload,
  }) async {}
  @override
  Future<void> startRingtone({
    String ringtone = 'default',
    double volume = 1,
  }) async {}
  @override
  Future<void> stopRingtone() async {}
  @override
  Future<Set<AudioRoute>> availableAudioRoutes() async => {
    AudioRoute.earpiece,
    AudioRoute.speaker,
  };
  @override
  Future<AudioRoute> getAudioRoute() async => _current;
  @override
  Future<void> setAudioRoute(AudioRoute route) async {
    _current = route;
    _route.add(route);
  }

  @override
  Stream<AudioRoute> get audioRouteChanges => _route.stream;
  @override
  Future<void> setProximityEnabled(bool enabled) async {}
  @override
  Future<void> setKeepScreenOn(bool keepOn) async {}
  @override
  Future<void> startForegroundService({required String text}) async {}
  @override
  Future<void> stopForegroundService() async {}
  @override
  Future<void> reportIncomingCall({
    required String callKey,
    required String handle,
    required String displayName,
  }) async {}
  @override
  Future<void> reportOutgoingCall({
    required String callKey,
    required String handle,
    required String displayName,
  }) async {}
  @override
  Future<void> reportCallConnected(String callKey) async {}
  @override
  Future<void> reportCallEnded(
    String callKey, {
    String reason = 'remoteEnded',
  }) async {}
  @override
  Stream<bool> get audioSessionActive => const Stream.empty();
  @override
  Stream<SystemCallAction> get systemCallActions => const Stream.empty();
  @override
  Stream<Uri> get incomingLinks => const Stream.empty();
  @override
  Future<Uri?> initialLink() async => null;
  @override
  Future<void> bringToFront() async {}
  @override
  Future<void> updateBadge(int count) async {}
  @override
  Future<void> updateTray({
    String? tooltip,
    int missedCalls = 0,
    bool inCall = false,
    bool ringing = false,
  }) async {}
  @override
  Future<void> setStartAtLogin(bool enabled) async {}
}

bool get isDesktopPlatform =>
    Platform.isMacOS || Platform.isWindows || Platform.isLinux;
bool get isMobilePlatform => Platform.isAndroid || Platform.isIOS;
