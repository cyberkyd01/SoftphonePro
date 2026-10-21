import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spcore_dart/spcore_dart.dart';

import '../../../audio/audio_library.dart';
import '../../../audio/echo_test.dart';
import '../../../audio/musicbed.dart';
import '../../../models/app_settings.dart';
import '../../../services/calls_controller.dart';
import '../../../services/engine_controller.dart';
import '../../../services/settings_controller.dart';

/// Bundled test sound (a short three-note chime).
const kChimeAsset = 'assets/sounds/chime.wav';

/// The interactive steps of the Audio test page (the summary is derived).
enum AudioTestStep { devices, mic, speaker, record, echo, music }

enum StepStatus { notRun, running, pass, fail, skipped }

/// What the microphone check currently concludes from the raw levels.
enum MicVerdict { waiting, ok, quiet, clipping, silent }

enum RecPhase { idle, recording, playing, done }

/// Sampling period of `media.levels` (the verdict windows count samples, not
/// wall-clock time, so they behave the same under a fake clock).
const kAudioTestSample = Duration(milliseconds: 100);

/// Length of the "record and play back" step.
const kAudioTestRecordSeconds = 5;

class AudioTestState {
  const AudioTestState({
    this.status = const {},
    this.messages = const {},
    this.audio,
    this.mic = MicVerdict.waiting,
    this.micPassed = false,
    this.speakerPlaying = false,
    this.speakerPlayed = false,
    this.speakerNoLevel = false,
    this.rec = RecPhase.idle,
    this.recSecondsLeft = 0,
    this.recEmpty = false,
    this.echoSecondsLeft = 0,
    this.echoUsed = false,
    this.echoBusy = false,
    this.echoEndedReason,
    this.headphonesAck = false,
    this.previewOn = false,
    this.previewUsed = false,
    this.previewOk,
    this.bedMoved = false,
    this.peaks = const {},
  });

  final Map<AudioTestStep, StepStatus> status;

  /// Engine error text of a failed step.
  final Map<AudioTestStep, String> messages;

  /// Last `media.audioState`; null until read.
  final AudioState? audio;
  final MicVerdict mic;

  /// The microphone check passed once (stays passed).
  final bool micPassed;
  final bool speakerPlaying;
  final bool speakerPlayed;

  /// The speaker meter stayed flat during the test sound.
  final bool speakerNoLevel;
  final RecPhase rec;
  final int recSecondsLeft;
  final bool recEmpty;
  final int echoSecondsLeft;
  final bool echoUsed;

  /// The engine refused the echo test because a call is active.
  final bool echoBusy;
  final String? echoEndedReason;

  /// The headphones warning was confirmed this session.
  final bool headphonesAck;
  final bool previewOn;
  final bool previewUsed;
  final bool? previewOk;
  final bool bedMoved;

  /// Highest raw level seen per channel (`mic`, `speaker`, `record`, `echo`,
  /// `musicbed`, `send`) while its step was active.
  final Map<String, int> peaks;

  StepStatus statusOf(AudioTestStep s) => status[s] ?? StepStatus.notRun;

  AudioTestState copyWith({
    Map<AudioTestStep, StepStatus>? status,
    Map<AudioTestStep, String>? messages,
    AudioState? audio,
    MicVerdict? mic,
    bool? micPassed,
    bool? speakerPlaying,
    bool? speakerPlayed,
    bool? speakerNoLevel,
    RecPhase? rec,
    int? recSecondsLeft,
    bool? recEmpty,
    int? echoSecondsLeft,
    bool? echoUsed,
    bool? echoBusy,
    Object? echoEndedReason = _keep,
    bool? headphonesAck,
    bool? previewOn,
    bool? previewUsed,
    Object? previewOk = _keep,
    bool? bedMoved,
    Map<String, int>? peaks,
  }) => AudioTestState(
    status: status ?? this.status,
    messages: messages ?? this.messages,
    audio: audio ?? this.audio,
    mic: mic ?? this.mic,
    micPassed: micPassed ?? this.micPassed,
    speakerPlaying: speakerPlaying ?? this.speakerPlaying,
    speakerPlayed: speakerPlayed ?? this.speakerPlayed,
    speakerNoLevel: speakerNoLevel ?? this.speakerNoLevel,
    rec: rec ?? this.rec,
    recSecondsLeft: recSecondsLeft ?? this.recSecondsLeft,
    recEmpty: recEmpty ?? this.recEmpty,
    echoSecondsLeft: echoSecondsLeft ?? this.echoSecondsLeft,
    echoUsed: echoUsed ?? this.echoUsed,
    echoBusy: echoBusy ?? this.echoBusy,
    echoEndedReason: identical(echoEndedReason, _keep) ? this.echoEndedReason : echoEndedReason as String?,
    headphonesAck: headphonesAck ?? this.headphonesAck,
    previewOn: previewOn ?? this.previewOn,
    previewUsed: previewUsed ?? this.previewUsed,
    previewOk: identical(previewOk, _keep) ? this.previewOk : previewOk as bool?,
    bedMoved: bedMoved ?? this.bedMoved,
    peaks: peaks ?? this.peaks,
  );
}

const Object _keep = Object();

/// Runs the Audio test: samples `media.levels` while the page is open, judges
/// the microphone, plays the chime, records and plays back, runs the echo test
/// and the "what callers hear" preview, and builds the diagnostics text.
/// [stopAll] undoes everything that makes sound or holds the device.
class AudioTestController extends Notifier<AudioTestState> {
  late final EngineController _engCtl;
  late final EchoTestController _echo;
  AppSettings _settings = const AppSettings({});

  Timer? _sampler;
  Timer? _recTimer;
  Timer? _echoTimer;
  Timer? _toneTimer;
  bool _sampling = false;
  bool _foreground = true;
  bool _disposed = false;

  final _micWin = <int>[];
  int? _chimeId;
  int? _recPlayId;
  String? _recFile;
  bool _started = false;
  bool _audioStateBusy = false;
  bool _audioStateUnsupported = false;

  /// How many samples back each verdict looks (see [kAudioTestSample]).
  static const _win3s = 30;
  static const _win5s = 50;
  static const _win6s = 60;

  @override
  AudioTestState build() {
    _engCtl = ref.read(engineProvider.notifier);
    _echo = ref.read(echoTestProvider.notifier);
    _settings = ref.read(settingsProvider);
    ref.onDispose(() {
      _disposed = true;
      _sampler?.cancel();
      _recTimer?.cancel();
      _echoTimer?.cancel();
      _toneTimer?.cancel();
    });
    ref.listen<AppSettings>(settingsProvider, (old, s) {
      _settings = s;
      // The preview plays the bed at its call volume: follow the slider.
      if (state.previewOn && old?.musicbedVolume != s.musicbedVolume) {
        unawaited(_quiet(() => _engine!.musicbedSet(monitorVolume: s.musicbedVolume)));
      }
    });
    final sub = _engCtl.events.listen(_onEvent);
    ref.onDispose(sub.cancel);
    ref.listen<EchoTestState>(echoTestProvider, (old, next) {
      if (next.on) return;
      _echoTimer?.cancel();
      _echoTimer = null;
      final wasPreview = state.previewOn;
      state = state.copyWith(echoSecondsLeft: 0, previewOn: false, echoEndedReason: next.endedReason);
      if (wasPreview) unawaited(_restoreBed());
    });
    return const AudioTestState();
  }

  SipEngine? get _engine => _engCtl.hasEngine ? _engCtl.engine : null;

  bool get _inCall {
    try {
      return ref.read(callsProvider).live.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<void> _quiet(Future<void> Function() f) async {
    try {
      await f();
    } catch (_) {}
  }

  void _set(AudioTestStep s, StepStatus v, {String? message}) {
    if (_disposed) return;
    final msgs = {...state.messages};
    if (message == null) {
      msgs.remove(s);
    } else {
      msgs[s] = message;
    }
    state = state.copyWith(status: {...state.status, s: v}, messages: msgs);
  }

  /// Starts sampling the levels; call once when the page opens.
  void start() {
    if (_started || _disposed) return;
    _started = true;
    _sampler = Timer.periodic(kAudioTestSample, (_) => unawaited(_sample()));
    unawaited(refreshAudioState());
  }

  /// The app went to the background (or came back): nothing is sampled while
  /// hidden.
  void setForeground(bool v) {
    _foreground = v;
    if (v) unawaited(refreshAudioState());
  }

  // ------------------------------------------------------------------ events

  void _onEvent(EngineEvent e) {
    if (_disposed) return;
    switch (e) {
      case MediaMonitorEvent():
        unawaited(refreshAudioState());
      case MediaPlayDoneEvent():
        _onPlayDone(e.playId);
      case MusicbedEvent() when e.active && state.previewOn:
        // The musicbed controller restarts the bed with the saved monitor
        // setting; the preview needs it heard.
        unawaited(_quiet(() => _engine!.musicbedSet(monitor: true, monitorVolume: _settings.musicbedVolume)));
      default:
    }
  }

  void _onPlayDone(int id) {
    if (id == _chimeId) {
      _chimeId = null;
      _toneTimer?.cancel();
      state = state.copyWith(speakerPlaying: false, speakerPlayed: true, speakerNoLevel: (state.peaks['speaker'] ?? 0) < 20);
    } else if (id == _recPlayId) {
      _recPlayId = null;
      state = state.copyWith(rec: RecPhase.done);
    }
  }

  /// Reads `media.audioState`; step 1 passes when a real device is open.
  Future<void> refreshAudioState() async {
    final e = _engine;
    if (e == null || _disposed || _audioStateBusy || _audioStateUnsupported) return;
    _audioStateBusy = true;
    try {
      final a = await e.audioState();
      if (_disposed) return;
      state = state.copyWith(audio: a);
      _set(
        AudioTestStep.devices,
        a.source == MonitorSource.device ? StepStatus.pass : StepStatus.fail,
      );
    } on EngineException catch (x) {
      // An engine without the call: step 1 stays untested.
      if (x.code == ErrorCode.unsupported) _audioStateUnsupported = true;
    } catch (_) {
    } finally {
      _audioStateBusy = false;
    }
  }

  // ---------------------------------------------------------------- sampling

  Future<void> _sample() async {
    if (_sampling || !_foreground || _disposed) return;
    final e = _engine;
    if (e == null) return;
    // The engine may have started after the page opened.
    if (state.audio == null) unawaited(refreshAudioState());
    _sampling = true;
    MediaLevels l;
    try {
      l = await e.levels();
    } catch (_) {
      _sampling = false;
      return;
    } finally {
      _sampling = false;
    }
    if (_disposed) return;

    final peaks = {...state.peaks};
    void peak(String k, int v) {
      if (v > (peaks[k] ?? 0)) peaks[k] = v;
    }

    peak('mic', l.mic);
    if (state.speakerPlaying) peak('speaker', l.speaker);
    if (state.rec == RecPhase.recording) peak('record', l.mic);
    if (_echo.state.on) peak('echo', l.mic);
    peak('musicbed', l.musicbed);
    peak('send', l.send);

    _micWin.add(l.mic);
    if (_micWin.length > _win6s) _micWin.removeAt(0);
    final verdict = _verdict();
    final passed = state.micPassed || verdict == MicVerdict.ok;
    // The bed meter only moves with a call or its monitor; otherwise the bed
    // is audible in the "sent to callers" level.
    final bedActive = ref.read(musicbedProvider).active;
    final bedMoved = state.bedMoved || l.musicbed >= 10 || (bedActive && l.send >= 10);

    state = state.copyWith(mic: verdict, micPassed: passed, bedMoved: bedMoved, peaks: peaks);

    if (passed) {
      if (state.statusOf(AudioTestStep.mic) != StepStatus.pass) _set(AudioTestStep.mic, StepStatus.pass);
    } else if (verdict == MicVerdict.silent) {
      _set(AudioTestStep.mic, StepStatus.fail);
    } else if (state.statusOf(AudioTestStep.mic) != StepStatus.running) {
      _set(AudioTestStep.mic, StepStatus.running);
    }
    _updateMusicStatus();
  }

  MicVerdict _verdict() {
    List<int> last(int n) => _micWin.length <= n ? _micWin : _micWin.sublist(_micWin.length - n);
    final w3 = last(_win3s);
    if (w3.where((v) => v >= 250).length >= 3) return MicVerdict.clipping;
    // At least 600 ms (6 samples) of real signal in the last 3 s.
    if (w3.where((v) => v >= 40).length >= 6) return MicVerdict.ok;
    if (_micWin.length >= _win5s) {
      final m = last(_win5s).fold<int>(0, (a, b) => a > b ? a : b);
      if (m > 0 && m < 15) return MicVerdict.quiet;
    }
    if (_micWin.length >= _win6s && _micWin.every((v) => v == 0) && state.audio?.source == MonitorSource.device) {
      return MicVerdict.silent;
    }
    return MicVerdict.waiting;
  }

  // ----------------------------------------------------------------- speaker

  /// Plays the bundled chime on the speaker (tone fallback when the file or
  /// `media.playLocal` is not available).
  Future<void> playChime() async {
    final e = _engine;
    if (e == null || _inCall) return;
    await _stopLocalPlayback();
    if (_disposed) return;
    _toneTimer?.cancel();
    final peaks = {...state.peaks}..remove('speaker');
    state = state.copyWith(speakerPlaying: true, speakerPlayed: false, speakerNoLevel: false, peaks: peaks);
    _set(AudioTestStep.speaker, StepStatus.running);
    try {
      String? path;
      try {
        path = await ref.read(audioAssetFileProvider)(kChimeAsset);
      } catch (_) {}
      if (_disposed) return;
      if (path != null) {
        try {
          final id = await e.playLocal(path);
          if (_disposed) return;
          _chimeId = id;
          return;
        } on EngineException catch (x) {
          if (x.code != ErrorCode.unsupported && x.code != ErrorCode.invalidParam) rethrow;
        }
      }
      await e.playTone(ToneKind.chime);
      if (_disposed) return;
      _toneTimer = Timer(const Duration(milliseconds: 1500), () {
        if (_disposed || !state.speakerPlaying) return;
        state = state.copyWith(speakerPlaying: false, speakerPlayed: true, speakerNoLevel: (state.peaks['speaker'] ?? 0) < 20);
      });
    } on EngineException catch (x) {
      if (_disposed) return;
      state = state.copyWith(speakerPlaying: false);
      _set(AudioTestStep.speaker, StepStatus.fail, message: x.error.message);
    }
  }

  void answerSpeaker(bool heard) => _set(AudioTestStep.speaker, heard ? StepStatus.pass : StepStatus.fail);

  Future<void> _stopLocalPlayback() async {
    final e = _engine;
    _chimeId = null;
    _recPlayId = null;
    if (e != null) await _quiet(() => e.playLocalStop());
  }

  // ------------------------------------------------------------------ record

  /// Records [kAudioTestRecordSeconds] seconds from the microphone, then plays
  /// the recording back.
  Future<void> startRecording() async {
    final e = _engine;
    if (e == null || _inCall || state.rec == RecPhase.recording) return;
    await _stopLocalPlayback();
    if (_disposed) return;
    _deleteRecording();
    final path = '${Directory.systemTemp.path}${Platform.pathSeparator}softphonepro_audiotest_${DateTime.now().microsecondsSinceEpoch}.wav';
    try {
      await e.recordMicStart(path);
    } on EngineException catch (x) {
      if (_disposed) return;
      _set(AudioTestStep.record, StepStatus.fail, message: x.error.message);
      return;
    }
    if (_disposed) {
      // Closed while starting: stop the recording we just began.
      unawaited(_quiet(() => e.recordMicStop()));
      return;
    }
    _recFile = path;
    final peaks = {...state.peaks}..remove('record');
    state = state.copyWith(rec: RecPhase.recording, recSecondsLeft: kAudioTestRecordSeconds, recEmpty: false, peaks: peaks);
    _set(AudioTestStep.record, StepStatus.running);
    _recTimer?.cancel();
    _recTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      final left = state.recSecondsLeft - 1;
      if (left > 0) {
        state = state.copyWith(recSecondsLeft: left);
      } else {
        t.cancel();
        _recTimer = null;
        unawaited(_finishRecording());
      }
    });
  }

  Future<void> _finishRecording() async {
    final e = _engine;
    if (e == null || _disposed) return;
    RecordingResult r;
    try {
      r = await e.recordMicStop();
    } on EngineException catch (x) {
      if (_disposed) return;
      state = state.copyWith(rec: RecPhase.idle);
      _set(AudioTestStep.record, StepStatus.fail, message: x.error.message);
      return;
    }
    if (_disposed) return;
    if (r.bytes == 0 || r.durationMs < 4000) {
      state = state.copyWith(rec: RecPhase.idle, recEmpty: true, recSecondsLeft: 0);
      _set(AudioTestStep.record, StepStatus.fail);
      return;
    }
    _recFile = r.file;
    state = state.copyWith(rec: RecPhase.idle);
    await playRecording();
  }

  Future<void> playRecording() async {
    final e = _engine;
    final f = _recFile;
    if (e == null || f == null || state.rec == RecPhase.recording) return;
    await _stopLocalPlayback();
    if (_disposed) return;
    try {
      final id = await e.playLocal(f);
      if (_disposed) return;
      _recPlayId = id;
      state = state.copyWith(rec: RecPhase.playing, recSecondsLeft: 0);
    } on EngineException catch (x) {
      if (_disposed) return;
      state = state.copyWith(rec: RecPhase.idle);
      _set(AudioTestStep.record, StepStatus.fail, message: x.error.message);
    }
  }

  void answerRecord(bool heard) => _set(AudioTestStep.record, heard ? StepStatus.pass : StepStatus.fail);

  void _deleteRecording() {
    final f = _recFile;
    _recFile = null;
    if (f == null) return;
    try {
      File(f).deleteSync();
    } catch (_) {}
  }

  // -------------------------------------------------------------------- echo

  void acknowledgeHeadphones() => state = state.copyWith(headphonesAck: true);

  /// Starts or stops "hear yourself". A call in progress is reported as
  /// [AudioTestState.echoBusy] instead of failing the step.
  Future<void> setEcho(bool on) async {
    if (!on) {
      await _echo.stop();
      return;
    }
    if (_inCall) {
      state = state.copyWith(echoBusy: true);
      return;
    }
    if (state.previewOn) await setPreview(false);
    if (_disposed) return;
    try {
      await _echo.start();
    } on EngineException catch (x) {
      if (_disposed) return;
      if (x.code == ErrorCode.busy) {
        state = state.copyWith(echoBusy: true);
      } else {
        _set(AudioTestStep.echo, StepStatus.fail, message: x.error.message);
      }
      return;
    }
    if (_disposed) return;
    _echoTimer?.cancel();
    final secs = EchoTestController.defaultTimeout.inSeconds;
    state = state.copyWith(echoUsed: true, echoBusy: false, echoSecondsLeft: secs, echoEndedReason: null);
    _set(AudioTestStep.echo, StepStatus.running);
    _echoTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      final left = state.echoSecondsLeft - 1;
      if (left <= 0) {
        t.cancel();
        _echoTimer = null;
        state = state.copyWith(echoSecondsLeft: 0);
      } else {
        state = state.copyWith(echoSecondsLeft: left);
      }
    });
  }

  void answerEcho(bool heard) => _set(AudioTestStep.echo, heard ? StepStatus.pass : StepStatus.fail);

  // ------------------------------------------------------------------- music

  /// "Preview what callers hear": the echo test plus the musicbed heard at its
  /// call volume. Undone (settings restored) when switched off.
  Future<void> setPreview(bool on) async {
    final e = _engine;
    if (e == null) return;
    if (!on) {
      if (!state.previewOn) return;
      state = state.copyWith(previewOn: false);
      await _echo.stop();
      if (_disposed) return;
      await _restoreBed();
      return;
    }
    if (_inCall) {
      state = state.copyWith(echoBusy: true);
      return;
    }
    if (_echo.state.on) await _echo.stop();
    if (_disposed) return;
    try {
      await _echo.start();
    } on EngineException catch (x) {
      if (_disposed) return;
      if (x.code == ErrorCode.busy) {
        state = state.copyWith(echoBusy: true);
      } else {
        _set(AudioTestStep.music, StepStatus.fail, message: x.error.message);
      }
      return;
    }
    if (_disposed) return;
    state = state.copyWith(previewOn: true, previewUsed: true, previewOk: null, echoBusy: false);
    // NOT_FOUND (no bed running) is fine: the voice alone is previewed.
    await _quiet(() => e.musicbedSet(monitor: true, monitorVolume: _settings.musicbedVolume));
  }

  Future<void> _restoreBed() async {
    final e = _engine;
    if (e == null) return;
    await _quiet(() => e.musicbedSet(monitor: _settings.musicbedMonitor, monitorVolume: _settings.musicbedMonitorVolume));
  }

  void answerPreview(bool heard) {
    state = state.copyWith(previewOk: heard);
    _updateMusicStatus();
  }

  void _updateMusicStatus() {
    if (state.previewOk == false) {
      _set(AudioTestStep.music, StepStatus.fail);
    } else if (state.bedMoved && (!state.previewUsed || state.previewOk == true)) {
      if (state.statusOf(AudioTestStep.music) != StepStatus.pass) _set(AudioTestStep.music, StepStatus.pass);
    } else if (state.statusOf(AudioTestStep.music) == StepStatus.notRun && state.bedMoved) {
      _set(AudioTestStep.music, StepStatus.running);
    }
  }

  // --------------------------------------------------------------------- end

  /// Stops everything the page started: echo, playbacks, a recording, the
  /// preview. [quiet]: called from `dispose`, so the state is left alone (the
  /// provider goes away with the page).
  void stopAll({bool quiet = false}) {
    _recTimer?.cancel();
    _recTimer = null;
    _echoTimer?.cancel();
    _echoTimer = null;
    _toneTimer?.cancel();
    _toneTimer = null;
    final e = _engine;
    final wasRecording = state.rec == RecPhase.recording;
    final wasPreview = state.previewOn;
    // The temp file is deleted only after the engine let go of it (Windows
    // refuses to delete an open file).
    final file = _recFile;
    _recFile = null;
    Future<void> engineSide() async {
      if (e != null) {
        await _quiet(() => e.playLocalStop());
        if (wasRecording) await _quiet(() => e.recordMicStop());
        if (wasPreview) await _restoreBed();
      }
      if (file != null) {
        try {
          File(file).deleteSync();
        } catch (_) {}
      }
    }

    if (quiet) {
      // From dispose: an engine may deliver events synchronously, which must
      // not change providers while the tree is being torn down.
      Future.microtask(() => unawaited(engineSide()));
      _echo.stopQuiet();
    } else {
      unawaited(engineSide());
      unawaited(_echo.stop());
    }
    _chimeId = null;
    _recPlayId = null;
    if (!quiet && !_disposed) {
      state = state.copyWith(
        speakerPlaying: false,
        rec: RecPhase.idle,
        recSecondsLeft: 0,
        echoSecondsLeft: 0,
        previewOn: false,
      );
    }
  }

  // ------------------------------------------------------------- diagnostics

  /// A plain-text report for support: versions, the step results, the engine's
  /// audio state, devices, the EC settings and the recent `media.*` events.
  Future<String> diagnosticsText() async {
    final b = StringBuffer();
    b.writeln('SoftphonePro $kAppVersion');
    b.writeln('OS: ${Platform.operatingSystem} ${Platform.operatingSystemVersion}');
    final eng = ref.read(engineProvider);
    b.writeln('Engine: ${eng.version}${eng.demo ? ' (simulator)' : ''}');
    b.writeln();
    b.writeln('Steps:');
    for (final s in AudioTestStep.values) {
      final m = state.messages[s];
      b.writeln('  ${s.name}: ${state.statusOf(s).name}${m == null ? '' : ' ($m)'}');
    }
    b.writeln('  mic verdict: ${state.mic.name}');
    b.writeln();
    b.writeln('Max levels (0-255): ${jsonEncode(state.peaks)}');
    final s = _settings;
    b.writeln('EC settings: algo=${s.ecAlgo} tail=${s.ecTailMs} ms ns=${s.noiseSuppression} agc=${s.agc}');
    b.writeln('Gain: mic=${s.micLevel} speaker=${s.speakerLevel}');
    final e = _engine;
    if (e != null) {
      try {
        b.writeln('Audio state: ${jsonEncode((await e.audioState()).toJson())}');
      } catch (x) {
        b.writeln('Audio state: unavailable ($x)');
      }
      try {
        final d = await e.audioDevices();
        b.writeln('Capture devices: ${d.capture.map((x) => x.name).join(' | ')}');
        b.writeln('Playback devices: ${d.playback.map((x) => x.name).join(' | ')}');
        b.writeln('Selected: capture=${d.current.capture} playback=${d.current.playback}');
      } catch (x) {
        b.writeln('Devices: unavailable ($x)');
      }
    } else {
      b.writeln('Engine not running');
    }
    final media = ref.read(engineLogProvider).where((l) => l.contains('media.')).toList();
    b.writeln();
    b.writeln('Recent media events:');
    for (final l in media.length > 20 ? media.sublist(media.length - 20) : media) {
      b.writeln('  $l');
    }
    return b.toString();
  }
}

final audioTestProvider = NotifierProvider.autoDispose<AudioTestController, AudioTestState>(AudioTestController.new);
