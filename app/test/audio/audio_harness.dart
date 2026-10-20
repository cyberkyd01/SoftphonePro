import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:softphonepro/audio/audio_io.dart';
import 'package:softphonepro/audio/audio_library.dart';
import 'package:softphonepro/models/account_profile.dart';
import 'package:softphonepro/models/app_settings.dart';
import 'package:softphonepro/services/accounts_controller.dart';
import 'package:softphonepro/services/app_services.dart';
import 'package:softphonepro/services/calls_controller.dart';
import 'package:softphonepro/services/engine_controller.dart';
import 'package:softphonepro/platform/platform_services.dart' show PlatformServices;
import 'package:softphonepro/services/providers.dart' show EngineFactory, platformServicesProvider;
import 'package:softphonepro/services/settings_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:spcore_dart/spcore_dart.dart';

import '../harness.dart';

/// Records the media-related requests in order.
class LogEngine extends FakeSipEngine {
  LogEngine({this.unsupportedHoldMusic = false, this.unsupportedVoiceIsolation = false, this.unsupportedFiles = false})
    : super(timings: FakeTimings.instant);

  final log = <String>[];
  final plays = <({int cid, String file, bool muteMic, bool monitor})>[];
  final holds = <HoldMusic?>[];
  int statusPolls = 0;
  bool unsupportedHoldMusic;
  bool unsupportedVoiceIsolation;
  bool unsupportedFiles;
  CoreConfig? startConfig;

  EngineException get _unsupported => const EngineException(EngineError(code: ErrorCode.unsupported, message: 'unsupported'));

  @override
  Future<CoreStartResult> start(CoreConfig config) {
    startConfig = config;
    return super.start(config);
  }

  @override
  Future<void> hold(int cid, {HoldMusic? music}) {
    holds.add(music);
    log.add('hold${music == null ? '' : '+music'}');
    if (music != null && unsupportedHoldMusic) return Future.error(_unsupported);
    return super.hold(cid, music: music);
  }

  @override
  Future<int> playFile(int cid, String file, {bool loop = false, double volume = 1.0, bool localMonitor = false, bool muteMic = false}) {
    if (unsupportedFiles) return Future.error(_unsupported);
    log.add('playFile');
    plays.add((cid: cid, file: file, muteMic: muteMic, monitor: localMonitor));
    return super.playFile(cid, file, loop: loop, volume: volume, localMonitor: localMonitor, muteMic: muteMic);
  }

  @override
  Future<void> stopFile(int cid, {int? playId}) {
    log.add('stopFile');
    return super.stopFile(cid, playId: playId);
  }

  @override
  Future<void> transfer(int cid, String target) {
    log.add('transfer');
    return super.transfer(cid, target);
  }

  @override
  Future<void> transferAttended(int cid, int destCid, {bool requireReplaces = true}) {
    log.add('transferAttended');
    return super.transferAttended(cid, destCid, requireReplaces: requireReplaces);
  }

  @override
  Future<VoiceIsolationResult> setVoiceIsolation({VoiceIsolationSide? mic, VoiceIsolationSide? incoming}) {
    log.add('setVoiceIsolation');
    if (unsupportedVoiceIsolation) return Future.error(_unsupported);
    return super.setVoiceIsolation(mic: mic, incoming: incoming);
  }

  @override
  Future<VoiceIsolationStatus> voiceIsolationStatus() {
    statusPolls++;
    if (unsupportedVoiceIsolation) return Future.error(_unsupported);
    return super.voiceIsolationStatus();
  }
}

class FakePreview implements AudioPreview {
  final ValueNotifier<String?> _p = ValueNotifier(null);
  final played = <String>[];
  @override
  ValueListenable<String?> get playing => _p;
  @override
  Future<void> play(String path) async {
    played.add(path);
    _p.value = path;
  }

  @override
  Future<void> stop() async => _p.value = null;
  @override
  void dispose() {}
}

/// A ProviderContainer wired like the app, for service-level tests.
class AudioEnv {
  AudioEnv._(this.env, this.engine, this.container, this.audioDir, this.picked, this.preview);
  final TestEnv env;
  final LogEngine engine;
  final ProviderContainer container;
  final Directory audioDir;
  final FakePreview preview;

  /// What the (fake) file picker returns next.
  final List<String?> picked;

  static Future<AudioEnv> create({
    Map<String, dynamic> settings = const {},
    List<AccountProfile>? profiles,
    LogEngine? engine,
    bool start = true,
    EngineFactory? factory,
    PlatformServices? platform,
  }) async {
    final e = engine ?? LogEngine();
    final env = await TestEnv.create(
      engine: e,
      profiles: profiles ?? [testProfile()],
      settings: AppSettings({'onboardingDone': true, ...settings}),
      factory: factory,
    );
    final dir = Directory('${env.tempDir.path}/audio')..createSync(recursive: true);
    final picked = <String?>[];
    final preview = FakePreview();
    final overrides = <Override>[
      ...env.overrides,
      audioDirProvider.overrideWithValue(() async => dir.path),
      audioAssetFileProvider.overrideWithValue((asset) async {
        final f = File('${env.tempDir.path}/assets/${asset.split('/').last}');
        if (!f.existsSync()) {
          f.createSync(recursive: true);
          f.writeAsBytesSync(List.filled(64, 0));
        }
        return f.path;
      }),
      audioFilePickerProvider.overrideWithValue(() async => picked.isEmpty ? null : picked.removeAt(0)),
      audioPreviewProvider.overrideWithValue(preview),
      if (platform != null) platformServicesProvider.overrideWithValue(platform),
    ];
    final c = ProviderContainer(overrides: overrides);
    final a = AudioEnv._(env, e, c, dir, picked, preview);
    if (start) {
      c.read(appServicesProvider);
      await a.until(() => c.read(engineProvider).running && c.read(accountsProvider).statusOf('acc1') == AccountStatus.registered);
    }
    return a;
  }

  /// Waits (real time) until [cond] holds. Zero-delay engine steps (answers,
  /// registration) run by themselves; long ones such as the end of a playback
  /// only run on [flush].
  Future<void> until(bool Function() cond, {int tries = 60}) async {
    for (var i = 0; i < tries; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 5));
      if (cond()) return;
    }
  }

  /// Runs every pending engine step now (playbacks end, ...).
  Future<void> flush() async {
    await engine.settle();
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }

  CallsController get calls => container.read(callsProvider.notifier);
  SettingsController get settings => container.read(settingsProvider.notifier);

  /// A confirmed outgoing call; returns its cid.
  Future<int> dialConfirmed([String number = '2002']) async {
    await calls.dial(number);
    await until(() => container.read(callsProvider).focused?.isConfirmed ?? false);
    return container.read(callsProvider).focused!.cid;
  }

  /// A confirmed incoming call; returns its cid.
  Future<int> incomingConfirmed() async {
    final ref = engine.simulateIncomingCall(from: 'sip:3003@pbx.test');
    await until(() => container.read(callsProvider).byCid(ref.cid) != null);
    await calls.answer(ref.cid);
    await until(() => container.read(callsProvider).byCid(ref.cid)?.isConfirmed ?? false);
    return ref.cid;
  }

  Future<File> makeAudio(String name, {int bytes = 64}) async {
    final f = File('${env.tempDir.path}/src/$name');
    f.parent.createSync(recursive: true);
    f.writeAsBytesSync(List.filled(bytes, 1));
    return f;
  }

  void dispose() => container.dispose();
}
