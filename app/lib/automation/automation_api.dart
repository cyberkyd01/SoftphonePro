import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/account_profile.dart';
import '../models/chat.dart';
import '../services/accounts_controller.dart';
import '../services/calls_controller.dart';
import '../services/dial_ready.dart';
import '../services/engine_controller.dart';
import '../services/history_controller.dart';
import '../services/messages_controller.dart';
import '../services/settings_controller.dart';
import 'automation_events.dart';
import 'automation_json.dart';
import 'automation_server.dart';

final _dtmfRe = RegExp(r'^[0-9A-Da-d*#]{1,64}$');

/// Routes `/v1/...` requests to the app's controllers. The same controllers
/// the UI uses do the work, so the app and the API cannot disagree.
class AutomationApi {
  AutomationApi(this.ref, this.hub);
  final Ref ref;
  final AutomationEventHub hub;

  CallsController get _calls => ref.read(callsProvider.notifier);

  Future<ApiResponse> handle(ApiRequest r) async {
    final seg = r.segments;
    if (seg.isEmpty || seg.first != 'v1') throw ApiException(404, 'not_found', 'Unknown path');
    final route = seg.skip(1).toList();
    final m = r.method;

    ApiException notAllowed(String allow) =>
        ApiException(405, 'method_not_allowed', 'Use $allow for ${r.path}');

    if (route.length == 1) {
      switch (route[0]) {
        case 'status':
          if (m != 'GET') throw notAllowed('GET');
          return ApiResponse(200, _status());
        case 'accounts':
          if (m != 'GET') throw notAllowed('GET');
          return ApiResponse(200, {'accounts': _accounts()});
        case 'calls':
          if (m == 'GET') {
            return ApiResponse(200, {
              'calls': [for (final c in ref.read(callsProvider).live) callToJson(c)],
            });
          }
          if (m == 'POST') return _dial(r);
          throw notAllowed('GET or POST');
        case 'dnd':
          if (m == 'GET') return ApiResponse(200, {'enabled': ref.read(settingsProvider).dnd});
          if (m == 'POST') return _dnd(r);
          throw notAllowed('GET or POST');
        case 'history':
          if (m != 'GET') throw notAllowed('GET');
          return _history(r);
        case 'events':
          if (m != 'GET') throw notAllowed('GET');
          return _events();
        case 'messages':
          if (m != 'POST') throw notAllowed('POST');
          return _message(r);
      }
    }
    if (route.isNotEmpty && route[0] == 'calls' && route.length >= 2) {
      final cid = int.tryParse(route[1]);
      if (cid == null) throw ApiException(404, 'call_not_found', 'No such call');
      if (route.length == 2) {
        if (m != 'GET') throw notAllowed('GET');
        return ApiResponse(200, {'call': callToJson(_call(cid, allowEnded: true))});
      }
      if (route.length == 3) {
        if (m != 'POST') throw notAllowed('POST');
        return _callAction(cid, route[2], r);
      }
    }
    throw ApiException(404, 'not_found', 'Unknown path');
  }

  // ---- reads ------------------------------------------------------------------

  Map<String, Object?> _status() {
    final e = ref.read(engineProvider);
    final calls = ref.read(callsProvider);
    return {
      'app': 'SoftphonePro',
      'version': kAppVersion,
      'engine': {
        'state': e.phase.name,
        'version': e.version,
        'demo': e.demo,
        if (e.error != null) 'error': e.error,
      },
      'dnd': ref.read(settingsProvider).dnd,
      'accounts': _accounts(),
      'calls': calls.live.length,
    };
  }

  List<Map<String, Object?>> _accounts() {
    final s = ref.read(accountsProvider);
    return [for (final p in s.profiles) accountToJson(p, s)];
  }

  UiCall _call(int cid, {bool allowEnded = false}) {
    final c = ref.read(callsProvider).byCid(cid);
    if (c == null) throw ApiException(404, 'call_not_found', 'No call with id $cid');
    if (c.isEnded && !allowEnded) throw ApiException(409, 'call_ended', 'Call $cid has already ended');
    return c;
  }

  ApiResponse _history(ApiRequest r) {
    var limit = 50;
    final l = r.query['limit'];
    if (l != null) {
      final n = int.tryParse(l);
      if (n == null || n < 1 || n > 500) {
        throw ApiException(400, 'invalid_limit', 'limit must be between 1 and 500');
      }
      limit = n;
    }
    final all = ref.read(historyProvider);
    return ApiResponse(200, {
      'total': all.length,
      'history': [for (final h in all.take(limit)) historyToJson(h)],
    });
  }

  ApiResponse _events() {
    final c = StreamController<String>();
    final sub = hub.stream.listen((e) => c.add(e.frame));
    c.onCancel = sub.cancel;
    final hello = hub.direct('hello', 'snapshot', {'status': _status()});
    c.add(hello.frame);
    return ApiResponse.sse(c.stream);
  }

  // ---- writes -----------------------------------------------------------------

  AccountProfile? _resolveAccount(Object? v) {
    if (v == null) return null;
    if (v is! String || v.trim().isEmpty) {
      throw ApiException(400, 'invalid_account', 'accountId must be a string');
    }
    final id = v.trim();
    final s = ref.read(accountsProvider);
    final byId = s.byId(id);
    if (byId != null) return byId;
    final matches = s.profiles.where((p) => p.address == id || p.config.username == id || p.name == id).toList();
    if (matches.length == 1) return matches.single;
    if (matches.length > 1) {
      throw ApiException(409, 'ambiguous_account', 'More than one account matches "$id"; use the account id');
    }
    throw ApiException(404, 'account_not_found', 'No account "$id"');
  }

  void _requireEngine() {
    if (!ref.read(engineProvider.notifier).hasEngine) {
      throw ApiException(409, 'engine_not_running', 'The call engine is not running');
    }
  }

  Future<ApiResponse> _dial(ApiRequest r) async {
    final b = r.json;
    final to = b['to'];
    if (to is! String || to.trim().isEmpty || to.length > 256) {
      throw ApiException(400, 'invalid_to', '"to" must be a non-empty string');
    }
    final acc = _resolveAccount(b['accountId']);
    var wait = 5;
    if (b['waitSeconds'] != null) {
      final w = b['waitSeconds'];
      if (w is! int || w < 0 || w > 30) {
        throw ApiException(400, 'invalid_wait', 'waitSeconds must be an integer from 0 to 30');
      }
      wait = w;
    }
    _requireEngine();
    final ready = await waitForDialReady(ref, to, accountId: acc?.id, timeout: Duration(seconds: wait));
    if (!ready.ok) throw ApiException(409, 'account_not_ready', ready.message ?? 'The account is not ready');
    final cid = await _calls.dial(to, accountId: acc?.id);
    if (cid == null) {
      throw ApiException(409, 'dial_failed', 'The call could not be placed');
    }
    final c = ref.read(callsProvider).byCid(cid);
    return ApiResponse(201, {'cid': cid, if (c != null) 'call': callToJson(c)});
  }

  Future<ApiResponse> _callAction(int cid, String action, ApiRequest r) async {
    final c = _call(cid);
    void need(bool ok, String why) {
      if (!ok) throw ApiException(409, 'invalid_state', 'Cannot $action: $why (state: ${callStateName(c)})');
    }

    Object? result;
    switch (action) {
      case 'answer':
        need(c.isRingingIn, 'the call is not ringing');
        await _calls.answer(cid);
      case 'hangup':
        await _calls.hangup(cid);
      case 'hold':
        need(c.isConfirmed && !c.isHeld, 'the call is not active');
        await _calls.hold(cid);
      case 'unhold':
        need(c.isConfirmed && c.isHeld, 'the call is not on hold');
        await _calls.unhold(cid);
      case 'mute':
        need(c.isConfirmed, 'the call is not connected');
        await _calls.setMute(cid, true);
      case 'unmute':
        need(c.isConfirmed, 'the call is not connected');
        await _calls.setMute(cid, false);
      case 'dtmf':
        need(c.isConfirmed, 'the call is not connected');
        final d = r.json['digits'];
        if (d is! String || !_dtmfRe.hasMatch(d)) {
          throw ApiException(400, 'invalid_digits', '"digits" must be 1-64 characters of 0-9 A-D * #');
        }
        await _calls.sendDtmf(cid, d.toUpperCase());
      case 'transfer':
        need(c.isConfirmed, 'the call is not connected');
        final b = r.json;
        final t = b['target'];
        if (t is! String || t.trim().isEmpty || t.length > 256) {
          throw ApiException(400, 'invalid_target', '"target" must be a non-empty string');
        }
        if (b['attended'] != null && b['attended'] is! bool) {
          throw ApiException(400, 'invalid_attended', '"attended" must be a boolean');
        }
        if (b['attended'] == true) {
          final consult = await _calls.startConsult(cid, t);
          if (consult == null) throw ApiException(409, 'transfer_failed', 'The consultation call could not be placed');
          result = {'consultCid': consult};
        } else {
          final ok = await _calls.transferBlind(cid, t);
          if (!ok) throw ApiException(409, 'transfer_failed', 'The transfer was refused');
        }
      case 'complete-transfer':
        final ok = await _calls.completeAttended(cid);
        if (!ok) throw ApiException(409, 'transfer_failed', 'Not a consultation call, or the transfer was refused');
      case 'cancel-transfer':
        await _calls.cancelConsult(cid);
      default:
        throw ApiException(404, 'not_found', 'Unknown call action "$action"');
    }
    final now = ref.read(callsProvider).byCid(cid) ?? c;
    return ApiResponse(200, {
      'ok': true,
      if (result is Map) ...result.cast<String, Object?>(),
      'call': callToJson(now),
    });
  }

  Future<ApiResponse> _dnd(ApiRequest r) async {
    final e = r.json['enabled'];
    if (e is! bool) throw ApiException(400, 'invalid_enabled', '"enabled" must be true or false');
    await ref.read(settingsProvider.notifier).update({'dnd': e});
    return ApiResponse(200, {'enabled': e});
  }

  Future<ApiResponse> _message(ApiRequest r) async {
    final b = r.json;
    final to = b['to'];
    final body = b['body'];
    if (to is! String || to.trim().isEmpty || to.length > 256) {
      throw ApiException(400, 'invalid_to', '"to" must be a non-empty string');
    }
    if (body is! String || body.trim().isEmpty || body.length > 4096) {
      throw ApiException(400, 'invalid_body', '"body" must be a non-empty string of at most 4096 characters');
    }
    final acc = _resolveAccount(b['accountId']) ?? ref.read(accountsProvider).defaultProfile;
    if (acc == null) throw ApiException(409, 'no_account', 'Add an account to send messages');
    _requireEngine();
    final msg = await ref.read(messagesProvider.notifier).send(acc.id, to.trim(), body);
    if (msg == null) throw ApiException(400, 'invalid_body', 'The message is empty');
    final cur = ref.read(messagesProvider).messages.where((m) => m.id == msg.id).firstOrNull ?? msg;
    if (cur.status == MessageStatus.failed) {
      throw ApiException(502, 'send_failed', cur.error.isEmpty ? 'The message could not be sent' : cur.error);
    }
    return ApiResponse(201, {'message': messageToJson(cur)});
  }
}
