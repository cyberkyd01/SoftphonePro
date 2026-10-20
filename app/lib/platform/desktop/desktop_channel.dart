import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'launch_args.dart';

/// The native side of desktop integration (`softphonepro/desktop`):
///  * macOS: URL (Apple) events and the login-item API (MainFlutterWindow.swift)
///  * Windows: command lines forwarded by a second launch (WM_COPYDATA)
///  * Linux: the same protocol as Windows; the GTK runner forwards a second
///    launch's argv (joined with newlines, `--show` when empty) as `onArgs`
class DesktopChannel {
  DesktopChannel([MethodChannel? channel, bool? isMacOS])
    : _channel = channel ?? const MethodChannel('softphonepro/desktop'),
      _isMacOS = isMacOS ?? (!kIsWeb && defaultTargetPlatform == TargetPlatform.macOS);

  final bool _isMacOS;

  final MethodChannel _channel;
  final _links = StreamController<Uri>.broadcast();
  final _showRequests = StreamController<void>.broadcast();
  final _mediaKeys = StreamController<void>.broadcast();
  final List<Uri> _initial = [];
  Uri? _lastLink;
  DateTime _lastLinkAt = DateTime.fromMillisecondsSinceEpoch(0);

  /// True when macOS started the app as a login item.
  bool launchedAtLogin = false;

  /// True when the process was started with `--minimized`.
  bool startMinimized = false;

  /// Links arriving while the app runs.
  Stream<Uri> get links => _links.stream;

  /// A second launch asked for the window without carrying a link.
  Stream<void> get showRequests => _showRequests.stream;

  /// macOS: a headset / media play-pause press while media keys are claimed.
  Stream<void> get mediaKeyPresses => _mediaKeys.stream;

  /// The link the process was launched with, if any.
  Uri? get initialLink => _initial.isEmpty ? null : _initial.first;

  Future<void> init(List<String> startupArgs) async {
    final parsed = parseLaunchArgs(startupArgs);
    startMinimized = parsed.minimized;
    if (parsed.link != null) _initial.add(parsed.link!);
    _channel.setMethodCallHandler(_onCall);
    try {
      final r = await _channel.invokeMethod<Map<Object?, Object?>>('ready');
      launchedAtLogin = r?['launchedAtLogin'] == true;
      final pending = r?['pending'];
      if (pending is List) {
        for (final p in pending) {
          _handlePayload('$p', startup: true);
        }
      }
    } on MissingPluginException {
      // Not running with the native runner (tests, other platforms).
    } on PlatformException catch (e) {
      debugPrint('desktop channel: $e');
    }
  }

  Future<dynamic> _onCall(MethodCall call) async {
    switch (call.method) {
      case 'onLink':
        _emit(parseLink('${call.arguments}'));
      case 'onArgs':
        _handlePayload('${call.arguments}');
      case 'onMediaKey':
        _mediaKeys.add(null);
    }
    return null;
  }

  /// Handles a payload from the native runner.
  ///
  /// macOS: Apple-event URLs are plain strings from other apps / web pages, so
  /// they go through [parseLink] ONLY (sip/sips/tel/callto/softphonepro) and are
  /// never split into command-line flags: a URL can not become `--provision`.
  ///
  /// Windows / Linux: the payload is the argv of a second launch (WM_COPYDATA /
  /// the GTK runner's single-instance forwarding) and is
  /// parsed as a command line, so `--provision` / `--dial` are honoured. That
  /// is the same-user privilege level as launching the program yourself, which
  /// is acceptable (any process of this user can already run it with flags).
  void _handlePayload(String payload, {bool startup = false}) {
    if (_isMacOS) {
      final link = parseLink(payload);
      if (link != null) {
        if (startup) {
          _initial.add(link);
        } else {
          _emit(link);
        }
      } else if (!startup) {
        _showRequests.add(null);
      }
      return;
    }
    final p = parseForwardedArgs(payload);
    if (p.link != null) {
      if (startup) {
        _initial.add(p.link!);
      } else {
        _emit(p.link);
      }
    } else if (!p.minimized && !startup) {
      _showRequests.add(null);
    }
  }

  void _emit(Uri? uri) {
    if (uri == null) return;
    // Some launch paths deliver the same URL twice.
    final now = DateTime.now();
    if (uri == _lastLink && now.difference(_lastLinkAt) < const Duration(seconds: 1)) return;
    _lastLink = uri;
    _lastLinkAt = now;
    _links.add(uri);
  }

  /// macOS: registers / unregisters the app as a login item. Returns whether
  /// the request succeeded.
  Future<bool> setLoginItem(bool enabled) async {
    try {
      return await _channel.invokeMethod<bool>('setLoginItem', enabled) ?? false;
    } on MissingPluginException {
      return false;
    } on PlatformException {
      return false;
    }
  }

  /// macOS: claim (or release) the system media keys / headset buttons.
  Future<bool> setMediaKeysActive(bool active) async {
    try {
      return await _channel.invokeMethod<bool>('setMediaKeys', active) ?? false;
    } on MissingPluginException {
      return false;
    } on PlatformException {
      return false;
    }
  }

  Future<void> dispose() async {
    _channel.setMethodCallHandler(null);
    await _links.close();
    await _showRequests.close();
    await _mediaKeys.close();
  }
}
