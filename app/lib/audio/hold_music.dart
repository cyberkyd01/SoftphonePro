import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spcore_dart/spcore_dart.dart';

import '../services/accounts_controller.dart';
import '../services/engine_controller.dart';
import '../services/settings_controller.dart';
import 'audio_library.dart';

/// Resolves the music-on-hold setting (account override > global) to a
/// [HoldMusic] for `call.hold`, or null for plain hold (PBX default).
class HoldMusicService {
  HoldMusicService(this._ref);
  final Ref _ref;

  /// The effective audio ref for [accountId]: `pbx` or `builtin:` / `lib:`.
  String refFor(String? accountId) {
    final s = _ref.read(settingsProvider);
    final acc = accountId == null ? null : _ref.read(accountsProvider).byId(accountId);
    final o = acc?.holdMusic ?? 'inherit';
    return (o.isEmpty || o == 'inherit') ? s.holdMusic : o;
  }

  Future<HoldMusic?> musicFor(String? accountId) async {
    final ref = refFor(accountId);
    if (ref.isEmpty || ref == 'pbx') return null;
    final file = await _ref.read(audioLibraryProvider).resolve(ref);
    if (file == null) return null;
    return HoldMusic(
      file: file,
      loop: true,
      volume: _ref.read(settingsProvider).holdMusicVolume.clamp(0.0, 1.0).toDouble(),
    );
  }

  /// Holds [cid], with music when configured. A refusal of the music (an
  /// engine without client-side music on hold, or an unreadable file) falls
  /// back to a plain hold; other failures are rethrown.
  Future<void> hold(int cid, String? accountId) async {
    final engine = _ref.read(engineProvider.notifier).engine;
    HoldMusic? music;
    try {
      music = await musicFor(accountId);
    } catch (e) {
      _ref.read(engineLogProvider.notifier).add('hold music unavailable: $e');
    }
    if (music != null) {
      try {
        await engine.hold(cid, music: music);
        return;
      } on EngineException catch (e) {
        final soft = e.code == ErrorCode.unsupported || e.code == ErrorCode.invalidParam;
        if (!soft) rethrow;
        _ref.read(engineLogProvider.notifier).add('hold music not applied (${e.code.wire}); holding normally');
      }
    }
    await engine.hold(cid);
  }
}

final holdMusicServiceProvider = Provider<HoldMusicService>((ref) => HoldMusicService(ref));
