import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// True on iOS, where (CallKit's manual audio session) there is no audio
/// device outside a call. A provider so tests can override it.
final isIosProvider = Provider<bool>((_) => !kIsWeb && Platform.isIOS);

/// Platform extras for noise cancellation, over the existing channels:
/// `softphonepro/desktop` (macOS) and `softphonepro/platform` (iOS, Android).
abstract class AudioPlatform {
  /// macOS 12+ / iOS 15+: the system "Microphone Mode" (Voice Isolation) UI.
  bool get hasSystemMicrophoneModes;

  /// Opens it; false when the OS is too old.
  Future<bool> showSystemMicrophoneModes();

  /// Android only: availability of the platform effects (null elsewhere).
  Future<AndroidAudioEffects?> androidEffects();
}

class AndroidAudioEffects {
  const AndroidAudioEffects({required this.noiseSuppressor, required this.echoCanceler});
  final bool noiseSuppressor;
  final bool echoCanceler;
}

class ChannelAudioPlatform implements AudioPlatform {
  ChannelAudioPlatform({MethodChannel? desktop, MethodChannel? mobile})
    : _desktop = desktop ?? const MethodChannel('softphonepro/desktop'),
      _mobile = mobile ?? const MethodChannel('softphonepro/platform');
  final MethodChannel _desktop;
  final MethodChannel _mobile;

  @override
  bool get hasSystemMicrophoneModes => !kIsWeb && (Platform.isMacOS || Platform.isIOS);

  @override
  Future<bool> showSystemMicrophoneModes() async {
    if (!hasSystemMicrophoneModes) return false;
    try {
      final ch = Platform.isMacOS ? _desktop : _mobile;
      return (await ch.invokeMethod<bool>('showMicrophoneModes')) ?? false;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }

  @override
  Future<AndroidAudioEffects?> androidEffects() async {
    if (kIsWeb || !Platform.isAndroid) return null;
    try {
      final m = await _mobile.invokeMapMethod<String, dynamic>('audioEffectsAvailable');
      if (m == null) return null;
      return AndroidAudioEffects(
        noiseSuppressor: m['noiseSuppressor'] == true,
        echoCanceler: m['echoCanceler'] == true,
      );
    } on PlatformException {
      return null;
    } on MissingPluginException {
      return null;
    }
  }
}

final audioPlatformProvider = Provider<AudioPlatform>((ref) => ChannelAudioPlatform());
