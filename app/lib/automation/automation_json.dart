import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spcore_dart/spcore_dart.dart';

import '../audio/audio_library.dart';
import '../audio/musicbed.dart';
import '../services/engine_controller.dart';
import '../services/settings_controller.dart';

import '../models/account_profile.dart';
import '../models/call_record.dart';
import '../models/chat.dart';
import '../services/accounts_controller.dart';
import '../services/calls_controller.dart';

/// JSON shapes of the automation API (documented in docs/AUTOMATION_API.md).

/// Simplified call state for integrations.
///  ringing_in  incoming, not answered yet
///  dialing     outgoing, no provisional response yet
///  ringing_out outgoing, the far end is ringing
///  connecting  answered, media being set up
///  active      talking
///  held        on hold (by us or by the far end)
///  ended
String callStateName(UiCall c) {
  if (c.isEnded) return 'ended';
  if (c.isRingingIn) return 'ringing_in';
  switch (c.state) {
    case CallState.calling:
      return 'dialing';
    case CallState.early:
      return 'ringing_out';
    case CallState.connecting:
    case CallState.incoming:
      return 'connecting';
    case CallState.confirmed:
      return c.isHeld || c.remoteHeld ? 'held' : 'active';
    case CallState.disconnected:
      return 'ended';
    case CallState.unknown:
      return 'dialing';
  }
}

Map<String, Object?> callToJson(UiCall c) => {
  'cid': c.cid,
  'state': callStateName(c),
  'engineState': c.state.wire,
  'direction': c.direction.name,
  'number': c.number,
  'display': c.info.remoteDisplay,
  'remoteUri': c.info.remoteUri,
  'dialed': c.dialed,
  'accountId': c.accountId,
  'held': c.isHeld,
  'remoteHeld': c.remoteHeld,
  'muted': c.muted,
  'recording': c.recording,
  'answered': c.answered,
  'startedAt': c.startedAt.toUtc().toIso8601String(),
  'connectedAt': c.connectedAt?.toUtc().toIso8601String(),
  'durationMs': c.duration.inMilliseconds,
  'sipCode': c.info.lastCode,
  'reason': c.info.stateReason,
};

Map<String, Object?> accountToJson(AccountProfile p, AccountsState s) {
  final status = s.statusOf(p.id);
  final i = s.infos[p.id];
  final mwi = s.mwi[p.id];
  return {
    'id': p.id,
    'name': p.name,
    'username': p.config.username,
    'domain': p.config.domain,
    'address': p.address,
    'enabled': p.enabled,
    'default': p.isDefault,
    'regState': status.name,
    'regCode': i?.regCode ?? 0,
    'error': s.errorOf(p.id),
    'transport': i?.transport ?? '',
    'dnd': p.dnd,
    'mwi': mwi == null
        ? null
        : {'waiting': mwi.waiting, 'new': mwi.newMsgs, 'old': mwi.oldMsgs},
  };
}

Map<String, Object?> historyToJson(CallRecord r) => {
  'id': r.id,
  'direction': r.direction.name,
  'result': r.result.name,
  'number': r.remoteNumber,
  'display': r.remoteDisplay,
  'remoteUri': r.remoteUri,
  'accountId': r.accountId,
  'start': r.start.toUtc().toIso8601String(),
  'durationMs': r.durationMs,
  'connectMs': r.connectMs,
  'sipCode': r.sipCode,
  'reason': r.reason,
  'callId': r.callId,
};

Map<String, Object?> messageToJson(ChatMessage m) => {
  'id': m.id,
  'direction': m.outgoing ? 'outgoing' : 'incoming',
  'peer': m.peer,
  'display': m.peerDisplay,
  'accountId': m.accountId,
  'body': m.body,
  'time': m.time.toUtc().toIso8601String(),
  'status': m.status.name,
  'error': m.error,
};

/// Display name of the musicbed file; never a path.
Future<String> _musicbedFileName(Ref ref, String file) async {
  if (file.isEmpty) return '';
  try {
    for (final i in await ref.read(audioLibraryProvider).list()) {
      if (i.ref == file) return i.name;
    }
  } catch (_) {}
  final i = file.indexOf(':');
  return i < 0 ? file : file.substring(i + 1).split(RegExp(r'[\\/]')).last;
}

/// The `musicbed` object of `GET /v1/audio` and the `audio` event.
Future<Map<String, Object?>> musicbedToJson(Ref ref) async {
  final s = ref.read(settingsProvider);
  final st = ref.read(musicbedProvider);
  return {
    'enabled': s.musicbedEnabled,
    'file': await _musicbedFileName(ref, s.musicbedFile),
    'active': st.active,
    'volume': s.musicbedVolume,
    'monitor': s.musicbedMonitor,
    'monitorVolume': s.musicbedMonitorVolume,
    'paused': st.paused,
  };
}

/// The body of `GET /v1/audio`. Levels come straight from the engine.
Future<Map<String, Object?>> audioToJson(Ref ref) async {
  final s = ref.read(settingsProvider);
  var l = const MediaLevels(mic: 0, speaker: 0, musicbed: 0);
  final ctl = ref.read(engineProvider.notifier);
  if (ctl.hasEngine) {
    try {
      l = await ctl.engine.levels();
    } catch (_) {}
  }
  return {
    'micLevel': s.micLevel,
    'speakerLevel': s.speakerLevel,
    'levels': {'mic': l.mic, 'speaker': l.speaker, 'musicbed': l.musicbed},
    'devices': {'capture': s.captureDev, 'playback': s.playbackDev},
    'musicbed': await musicbedToJson(ref),
  };
}
