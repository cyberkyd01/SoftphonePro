import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/app_settings.dart';
import '../models/call_record.dart';
import '../services/accounts_controller.dart';
import '../services/calls_controller.dart';
import '../services/history_controller.dart';
import '../services/messages_controller.dart';
import '../services/settings_controller.dart';
import 'automation_json.dart';

/// One Server-Sent Event: `event: <category>` + JSON `data` with a `type`.
class AutomationEvent {
  AutomationEvent(this.id, this.category, this.data);
  final int id;
  final String category;
  final Map<String, Object?> data;

  String get frame => '${id == 0 ? '' : 'id: $id\n'}event: $category\ndata: ${jsonEncode(data)}\n\n';
}

/// Fan-out of automation events to all open `/v1/events` streams.
class AutomationEventHub {
  final _c = StreamController<AutomationEvent>.broadcast(sync: true);
  int _seq = 0;

  Stream<AutomationEvent> get stream => _c.stream;

  AutomationEvent emit(String category, String type, Map<String, Object?> data) {
    final e = AutomationEvent(++_seq, category, {
      'type': type,
      'time': DateTime.now().toUtc().toIso8601String(),
      ...data,
    });
    if (!_c.isClosed) _c.add(e);
    return e;
  }

  /// An event for one stream only (the `hello` snapshot); not broadcast.
  AutomationEvent direct(String category, String type, Map<String, Object?> data) =>
      AutomationEvent(0, category, {
        'type': type,
        'time': DateTime.now().toUtc().toIso8601String(),
        ...data,
      });

  Future<void> close() => _c.close();
}

/// Turns provider state changes into automation events:
///  * `call`     incoming | outgoing | state | ended
///  * `account`  registration state changes
///  * `mwi`      voicemail indicator changes
///  * `message`  new / updated SIP messages
///  * `history`  a call record was written (also for calls the app rejected)
///  * `dnd`      do-not-disturb toggled
///
/// Must be created with the service's [Ref]; call [dispose] to stop.
class AutomationEventBridge {
  AutomationEventBridge(this.ref, this.hub) {
    final calls = ref.read(callsProvider);
    _prime(calls);
    _subs.add(ref.listen<CallsState>(callsProvider, (_, n) => _onCalls(n)));
    _subs.add(ref.listen<AccountsState>(accountsProvider, (p, n) => _onAccounts(p, n)));
    _subs.add(ref.listen<MessagesState>(messagesProvider, (p, n) => _onMessages(n)));
    _subs.add(ref.listen<List<CallRecord>>(historyProvider, (p, n) => _onHistory(p, n)));
    _subs.add(ref.listen<AppSettings>(settingsProvider, (p, n) {
      if (p != null && p.dnd != n.dnd) hub.emit('dnd', 'changed', {'enabled': n.dnd});
    }));
    for (final m in ref.read(messagesProvider).messages) {
      _msgStatus[m.id] = m.status.name;
    }
  }

  final Ref ref;
  final AutomationEventHub hub;
  final List<ProviderSubscription<Object?>> _subs = [];
  final Map<int, String> _callSnap = {};
  final Map<int, UiCall> _last = {};
  final Set<int> _ended = {};
  final Map<String, String> _msgStatus = {};

  void dispose() {
    for (final s in _subs) {
      s.close();
    }
    _subs.clear();
  }

  void _prime(CallsState s) {
    for (final c in s.calls) {
      _callSnap[c.cid] = _snap(c);
      if (c.isEnded) _ended.add(c.cid);
    }
  }

  String _snap(UiCall c) => '${callStateName(c)}|${c.muted}|${c.isHeld}';

  void _onCalls(CallsState s) {
    for (final c in s.calls) {
      _last[c.cid] = c;
      final snap = _snap(c);
      final prev = _callSnap[c.cid];
      if (prev == null) {
        _callSnap[c.cid] = snap;
        if (c.isEnded) {
          // Seen for the first time already over (rejected very quickly).
          _ended.add(c.cid);
          hub.emit('call', c.direction.name, {'call': callToJson(c)});
          hub.emit('call', 'ended', {'call': callToJson(c)});
          continue;
        }
        hub.emit('call', c.direction.name, {'call': callToJson(c)});
      } else if (prev != snap) {
        _callSnap[c.cid] = snap;
        if (!c.isEnded) hub.emit('call', 'state', {'call': callToJson(c)});
      }
      if (c.isEnded && _ended.add(c.cid)) {
        hub.emit('call', 'ended', {'call': callToJson(c)});
      }
    }
    // Forget calls that left the list (bounded memory).
    final live = {for (final c in s.calls) c.cid};
    // The controller drops a call from the list as soon as it ends.
    for (final cid in _callSnap.keys.toList()) {
      if (live.contains(cid) || _ended.contains(cid)) continue;
      final last = _last[cid];
      if (last != null) {
        hub.emit('call', 'ended', {'call': {...callToJson(last), 'state': 'ended'}});
      }
    }
    _last.removeWhere((cid, _) => !live.contains(cid));
    _callSnap.removeWhere((cid, _) => !live.contains(cid));
    _ended.removeWhere((cid) => !live.contains(cid));
  }

  void _onAccounts(AccountsState? p, AccountsState n) {
    for (final prof in n.profiles) {
      final now = n.statusOf(prof.id);
      final before = p?.byId(prof.id) == null ? null : p!.statusOf(prof.id);
      if (before != now) {
        hub.emit('account', 'registration', {'account': accountToJson(prof, n)});
      }
      final m = n.mwi[prof.id];
      final pm = p?.mwi[prof.id];
      if (m != null && (pm == null || pm.waiting != m.waiting || pm.newMsgs != m.newMsgs || pm.oldMsgs != m.oldMsgs)) {
        hub.emit('mwi', 'changed', {
          'accountId': prof.id,
          'waiting': m.waiting,
          'new': m.newMsgs,
          'old': m.oldMsgs,
        });
      }
    }
  }

  void _onMessages(MessagesState n) {
    for (final m in n.messages) {
      final seen = _msgStatus[m.id];
      if (seen == null) {
        _msgStatus[m.id] = m.status.name;
        hub.emit('message', m.outgoing ? 'sent' : 'received', {'message': messageToJson(m)});
      } else if (seen != m.status.name) {
        _msgStatus[m.id] = m.status.name;
        hub.emit('message', 'status', {'message': messageToJson(m)});
      }
    }
  }

  void _onHistory(List<CallRecord>? p, List<CallRecord> n) {
    final known = {for (final r in p ?? const <CallRecord>[]) r.id};
    for (final r in n) {
      if (!known.contains(r.id)) hub.emit('history', 'added', {'record': historyToJson(r)});
    }
  }
}
