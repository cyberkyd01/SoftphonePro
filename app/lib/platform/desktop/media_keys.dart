import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hotkey_manager/hotkey_manager.dart';

import '../../services/calls_controller.dart';
import '../../services/settings_controller.dart';
import 'desktop_channel.dart';

/// What a headset / media play-pause press does.
enum MediaKeyAction { none, answer, hangup, mute }

/// The policy: a ringing call is answered; otherwise during a call the key
/// hangs up or mutes, per [activeAction] (`hangup` | `mute`).
MediaKeyAction decideMediaKey({required bool ringing, required bool ongoing, required String activeAction}) {
  if (ringing) return MediaKeyAction.answer;
  if (ongoing) return activeAction == 'mute' ? MediaKeyAction.mute : MediaKeyAction.hangup;
  return MediaKeyAction.none;
}

/// Platform side of the media keys. [setActive] claims / releases the keys;
/// presses arrive through [onPress].
abstract class MediaKeyBackend {
  void Function()? onPress;
  Future<void> setActive(bool active);
  Future<void> dispose() async {}
}

/// macOS: MPRemoteCommandCenter in the runner, over `softphonepro/desktop`.
class ChannelMediaKeyBackend extends MediaKeyBackend {
  ChannelMediaKeyBackend(this._channel) {
    _sub = _channel.mediaKeyPresses.listen((_) => onPress?.call());
  }
  final DesktopChannel _channel;
  StreamSubscription<void>? _sub;

  @override
  Future<void> setActive(bool active) => _channel.setMediaKeysActive(active);

  @override
  Future<void> dispose() async => _sub?.cancel();
}

/// Windows: a system hotkey on VK_MEDIA_PLAY_PAUSE (hotkey_manager).
class HotkeyMediaKeyBackend extends MediaKeyBackend {
  final HotKey _hotKey = HotKey(
    identifier: 'softphonepro.mediaPlayPause',
    key: PhysicalKeyboardKey.mediaPlayPause,
    scope: HotKeyScope.system,
  );
  bool _registered = false;

  @override
  Future<void> setActive(bool active) async {
    if (active == _registered) return;
    try {
      if (active) {
        await hotKeyManager.register(_hotKey, keyDownHandler: (_) => onPress?.call());
      } else {
        await hotKeyManager.unregister(_hotKey);
      }
      _registered = active;
    } catch (_) {
      _registered = false;
    }
  }

  /// Another part of the app unregistered every hotkey.
  void forgetRegistration() => _registered = false;

  @override
  Future<void> dispose() => setActive(false);
}

/// Claims the media keys only while a call rings or is active (so music apps
/// keep them otherwise) and turns presses into call actions.
class MediaKeyController {
  MediaKeyController(this._ref, this._backend, {DateTime Function()? clock}) : _now = clock ?? DateTime.now;

  final Ref _ref;
  final MediaKeyBackend _backend;
  final DateTime Function() _now;
  final List<ProviderSubscription<dynamic>> _subs = [];
  bool _claimed = false;
  DateTime _lastPress = DateTime.fromMillisecondsSinceEpoch(0);

  bool get claimed => _claimed;

  void start() {
    _backend.onPress = handlePress;
    _subs.add(_ref.listen<CallsState>(callsProvider, (_, _) => sync()));
    _subs.add(_ref.listen(settingsProvider.select((s) => s.mediaKeys), (_, _) => sync()));
    sync();
  }

  /// Registers / releases the keys to match the current call and settings.
  Future<void> sync() async {
    final calls = _ref.read(callsProvider);
    final want = _ref.read(settingsProvider).mediaKeys && (calls.ringing.isNotEmpty || calls.ongoing.isNotEmpty);
    if (want == _claimed) return;
    _claimed = want;
    await _backend.setActive(want);
  }

  /// The platform dropped its registration (e.g. hotkeys were re-applied).
  Future<void> reclaim() async {
    if (_claimed) {
      _claimed = false;
      await sync();
    }
  }

  Future<void> handlePress() async {
    final t = _now();
    // Some devices send both "play" and "toggle", or repeat the press.
    if (t.difference(_lastPress) < const Duration(milliseconds: 500)) return;
    final settings = _ref.read(settingsProvider);
    if (!settings.mediaKeys) return;
    final calls = _ref.read(callsProvider);
    final action = decideMediaKey(
      ringing: calls.ringing.isNotEmpty,
      ongoing: calls.ongoing.isNotEmpty,
      activeAction: settings.mediaKeyActive,
    );
    if (action == MediaKeyAction.none) return;
    _lastPress = t;
    final ctl = _ref.read(callsProvider.notifier);
    switch (action) {
      case MediaKeyAction.answer:
        await ctl.answer(calls.ringing.first.cid);
      case MediaKeyAction.hangup:
        final c = calls.focused ?? calls.ongoing.first;
        await ctl.hangup(c.cid);
      case MediaKeyAction.mute:
        final c = calls.focused ?? calls.ongoing.first;
        await ctl.toggleMute(c.cid);
      case MediaKeyAction.none:
        break;
    }
  }

  Future<void> dispose() async {
    for (final s in _subs) {
      s.close();
    }
    _subs.clear();
    _backend.onPress = null;
    _claimed = false;
    await _backend.dispose();
  }
}
