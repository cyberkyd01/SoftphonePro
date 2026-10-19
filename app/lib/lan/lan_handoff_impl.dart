import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lan_link/lan_link.dart' as ll;
import 'package:spcore_dart/spcore_dart.dart';

import '../audio/announcement_service.dart';
import '../l10n/l10n.dart';
import '../platform/lan_handoff.dart';
import '../services/accounts_controller.dart';
import '../services/calls_controller.dart';
import '../services/engine_controller.dart';
import '../services/providers.dart';
import '../services/settings_controller.dart';
import 'lan_controller.dart';
import 'lan_models.dart';

/// A hand-off that could not start or was refused. [message] is user-facing;
/// the original call is untouched.
class LanHandoffException implements Exception {
  const LanHandoffException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// What the call policy needs from LAN Link (kept small so CallsController
/// does not depend on the whole implementation).
abstract class LanCallPolicy {
  /// Identifies calls over the LAN transport / transferred by a LAN device.
  LanCallMeta? classifyIncoming(CallInfo info);

  /// True for the visible consultation leg of an attended relay hand-off.
  bool isRelayConsult(int cid);
  Future<bool> completeAttendedRelay(int consultCid);
}

class _Accepted {
  _Accepted(this.peerId, this.offer, this.expires);
  final String peerId;
  final ll.HandoffOffer offer;
  final DateTime expires;
}

/// State for the UI: calls on this device that are relayed to a LAN peer.
class LanRelayController extends Notifier<Map<int, RelaySession>> {
  @override
  Map<int, RelaySession> build() => {};
  void put(RelaySession s) => state = {...state, s.cid: s};
  void touch() => state = {...state};
  void remove(int cid) {
    if (state.containsKey(cid)) state = {...state}..remove(cid);
  }
}

final lanRelayProvider = NotifierProvider<LanRelayController, Map<int, RelaySession>>(LanRelayController.new);

String _hex(int bytes) {
  final r = Random.secure();
  return List.generate(bytes, (_) => r.nextInt(256).toRadixString(16).padLeft(2, '0')).join();
}

String? _hostOf(String uri) {
  final m = RegExp(r'@?(\d{1,3}(?:\.\d{1,3}){3})').firstMatch(uri);
  return m?.group(1);
}

String _digits(String s) => s.replaceAll(RegExp(r'[^0-9]'), '');

/// Hand-off, forward, pull and LAN call policy on top of [LanController].
class LanHandoffImpl implements LanCallPolicy {
  LanHandoffImpl(this._ref);
  final Ref _ref;

  final Map<String, _Accepted> _accepted = {};
  final Map<int, RelaySession> _sessions = {};
  final List<StreamSubscription<dynamic>> _subs = [];
  final _prompts = StreamController<ll.IncomingHandoff>.broadcast();
  final _cancelledPrompts = StreamController<String>.broadcast();
  bool _disposed = false;

  AppLocalizations get _l => _ref.read(l10nProvider);
  LanController get _lan => _ref.read(lanControllerProvider.notifier);
  CallsController get _calls => _ref.read(callsProvider.notifier);
  EngineController get _engCtl => _ref.read(engineProvider.notifier);
  SipEngine get _engine => _engCtl.engine;
  LanRelayController get _relay => _ref.read(lanRelayProvider.notifier);

  /// Offers waiting for the user (shown as a dialog by the UI).
  Stream<ll.IncomingHandoff> get pendingOffers => _prompts.stream;

  /// handoffIds withdrawn by the sender while the prompt was open.
  Stream<String> get cancelledOffers => _cancelledPrompts.stream;

  RelaySession? sessionFor(int cid) => _sessions[cid];

  void init() {
    _subs
      ..add(_lan.handoffOffers.listen(_onOffer))
      ..add(_lan.handoffEvents.listen(_onHandoffEvent))
      ..add(_lan.pullRequests.listen(_onPull))
      ..add(_engCtl.events.listen((e) {
        if (e is CallStateEvent && e.isTerminal) _onCallEnded(e.cid);
      }));
  }

  void dispose() {
    _disposed = true;
    for (final s in _subs) {
      s.cancel();
    }
    _prompts.close();
    _cancelledPrompts.close();
  }

  // ---- devices ----------------------------------------------------------------

  bool get available => _ref.read(lanControllerProvider).running;

  static List<LanDevice> devicesOf(LanState st) => [
        for (final p in st.paired)
          LanDevice(
            id: p.deviceId,
            name: p.name,
            platform: p.info?.platform ?? '',
            online: p.online,
            busy: p.status == ll.PeerStatus.onCall || p.status == ll.PeerStatus.busy,
            paired: true,
          ),
      ];

  // ---- outgoing: hand a call to a peer ------------------------------------------

  Future<void> handoff({required int cid, required String peerId, bool attended = false}) =>
      _handoff(cid, peerId, attended: attended, ringing: false);

  Future<void> forwardIncoming({required int cid, required String peerId}) =>
      _handoff(cid, peerId, attended: false, ringing: true);

  /// `sip:user@domain` of the peer's registration on the call's own PBX, if any.
  String? _referTarget(ll.LanPeer peer, String? domain) {
    if (domain == null || domain.isEmpty) return null;
    final d = domain.toLowerCase();
    for (final a in peer.info?.aors ?? const <String>[]) {
      var s = a.trim();
      if (s.toLowerCase().startsWith('sip:')) s = s.substring(4);
      final at = s.lastIndexOf('@');
      if (at <= 0) continue;
      if (s.substring(at + 1).toLowerCase() == d) return 'sip:$s';
    }
    return null;
  }

  Future<void> _handoff(int cid, String peerId, {required bool attended, required bool ringing}) async {
    final lan = _lan;
    final link = lan.link;
    if (link == null) throw LanHandoffException(_l.lanHoOff);
    final peer = link.peerById(peerId);
    if (peer == null || !peer.trusted) throw LanHandoffException(_l.lanHoPairFirst);
    if (!peer.online) throw LanHandoffException(_l.lanHoOffline(peer.name));
    if (_sessions.containsKey(cid)) throw LanHandoffException(_l.lanHoAlready);
    final call = _calls.rawCall(cid);
    if (call == null || call.isEnded) throw LanHandoffException(_l.lanHoEnded);
    if (ringing ? !call.isRingingIn : !call.isConfirmed) {
      throw LanHandoffException(_l.lanHoWaitConnected);
    }
    if (call.info.uid == kLanAccountUid && call.lan != null) {
      throw LanHandoffException(_l.lanHoLanCall);
    }
    final profile = _ref.read(accountsProvider).byId(call.accountId);
    final target = _referTarget(peer, profile?.config.domain);
    final mode = target != null ? ll.HandoffMode.refer : ll.HandoffMode.relay;
    if (mode == ll.HandoffMode.relay && !peer.hasSip) {
      throw LanHandoffException(_l.lanHoPeerNoLan(peer.name));
    }
    if (mode == ll.HandoffMode.relay && lan.link!.info.sipPort == 0) {
      throw LanHandoffException(_l.lanHoNoLanHere);
    }
    final id = _hex(12);
    final callerName = call.info.remoteDisplay;
    final offer = ll.HandoffOffer(
      handoffId: id,
      mode: mode,
      caller: ll.CallerInfo(name: callerName, number: call.number, uri: call.info.remoteUri),
      accountName: profile?.name ?? '',
      referTarget: target,
      lanSipUri: 'sip:${link.deviceId}@${lan.localAddressFor(peer.address)}:${link.info.sipPort}',
      attended: attended,
    );
    final session = RelaySession(
      handoffId: id,
      cid: cid,
      peerId: peerId,
      peerName: peer.name,
      attended: attended,
    );
    _sessions[cid] = session;
    _relay.put(session);
    try {
      final res = await link.offerHandoff(peerId, offer);
      if (!res.accepted) {
        throw LanHandoffException(switch (res.outcome) {
          ll.HandoffOutcome.declined => _l.lanHoDeclined(peer.name),
          ll.HandoffOutcome.timeout => _l.lanHoTimeout(peer.name),
          ll.HandoffOutcome.cancelled => _l.lanHoCancelled,
          _ => res.reason == null ? _l.lanHoUnreachable(peer.name) : _l.lanHoUnreachableReason(peer.name, res.reason!),
        });
      }
      if (_calls.rawCall(cid)?.isEnded ?? true) {
        throw LanHandoffException(_l.lanHoEndedBefore);
      }
      if (!ringing && !attended) {
        await _ref.read(announcementServiceProvider).playTransferNotice(cid);
        if (_calls.rawCall(cid)?.isEnded ?? true) {
          throw LanHandoffException(_l.lanHoEndedBefore);
        }
      }
      if (mode == ll.HandoffMode.refer) {
        final done = await _doRefer(session, target!, attended: attended, ringing: ringing);
        if (done) return;
        if (!peer.hasSip) {
          // CallsController no longer reacts to this failure: keep the call.
          await _guard(() => _engine.unhold(cid));
          throw LanHandoffException(_l.lanHoPbxRefused(peer.name));
        }
        _ref.read(noticeProvider.notifier).show(_l.lanHoPbxFailedRelaying);
      }
      await _doRelay(session, ringing: ringing, attended: attended);
    } catch (e) {
      if (_sessions[cid] == session && session.phase != RelayPhase.relayed && session.phase != RelayPhase.consulting) {
        _drop(session);
      }
      rethrow;
    }
  }

  void _drop(RelaySession s) {
    if (_sessions[s.cid] == s) _sessions.remove(s.cid);
    _relay.remove(s.cid);
  }

  /// REFER (or 302 for a ringing call). Returns false when the PBX refused.
  Future<bool> _doRefer(RelaySession s, String target, {required bool attended, required bool ringing}) async {
    final link = _lan.link;
    if (ringing) {
      await _calls.redirectTo(s.cid, target);
      _drop(s);
      _ref.read(noticeProvider.notifier).show(_l.lanHoSentTo(s.peerName));
      return true;
    }
    if (attended) {
      final consult = await _calls.startConsult(s.cid, target);
      _drop(s);
      if (consult == null) throw LanHandoffException(_l.lanHoConsultFailed);
      return true;
    }
    final completer = Completer<bool?>();
    final sub = _engCtl.events.listen((e) {
      if (e is CallTransferStatusEvent && e.cid == s.cid && e.isFinal && !completer.isCompleted) {
        completer.complete(e.code >= 200 && e.code < 300);
      }
    });
    try {
      _calls.rawCall(s.cid)?.transferPending = true;
      await _engine.transfer(s.cid, target);
      final ok = await completer.future.timeout(const Duration(seconds: 20), onTimeout: () => null);
      if (ok == false) {
        _calls.rawCall(s.cid)?.transferPending = false;
        return false;
      }
      if (ok == true) unawaited(link?.completeHandoff(s.peerId, s.handoffId).catchError((_) {}));
      _drop(s);
      return true;
    } on EngineException {
      _calls.rawCall(s.cid)?.transferPending = false;
      return false;
    } finally {
      await sub.cancel();
    }
  }

  Future<void> _guard(Future<void> Function() f) async {
    try {
      await f();
    } catch (e) {
      debugPrint('LAN hand-off engine call failed: $e');
    }
  }

  Future<bool> _waitConfirmed(int cid, Duration timeout) async {
    final started = DateTime.now();
    var seen = false;
    bool? check() {
      final c = _calls.rawCall(cid);
      if (c == null) {
        // Engine events reach CallsController asynchronously: a brand-new
        // call may not be known yet. Only once seen does absence mean ended.
        if (seen || DateTime.now().difference(started) > const Duration(seconds: 3)) return false;
        return null;
      }
      seen = true;
      if (c.isEnded) return false;
      if (c.isConfirmed) return true;
      return null;
    }

    // Poll: engine events reach CallsController asynchronously, so a state
    // change can be queued but not yet applied when we start looking.
    final end = DateTime.now().add(timeout);
    while (!_disposed) {
      final r = check();
      if (r != null) return r;
      if (DateTime.now().isAfter(end)) return false;
      await Future<void>.delayed(const Duration(milliseconds: 40));
    }
    return false;
  }

  /// Relay: call the peer over the LAN and bridge the two legs.
  Future<void> _doRelay(RelaySession s, {required bool ringing, required bool attended}) async {
    final lan = _lan;
    final link = lan.link;
    final peer = link?.peerById(s.peerId);
    if (link == null || peer == null || peer.sipUri == null) {
      throw LanHandoffException(_l.lanHoNoLongerReachable(s.peerName));
    }
    final cid = s.cid;
    var call = _calls.rawCall(cid)!;
    if (ringing) {
      await _engine.answer(cid);
      if (!await _waitConfirmed(cid, const Duration(seconds: 15))) {
        throw LanHandoffException(_l.lanHoCouldNotAnswer);
      }
      call = _calls.rawCall(cid) ?? call;
    }
    final callerName = call.info.remoteDisplay;
    final headers = {
      kHdrHandoff: s.handoffId,
      kHdrDevice: link.deviceId,
      kHdrCallerName: callerName,
      kHdrCallerNumber: call.number,
    };
    final meta = LanCallMeta(
      peerId: s.peerId,
      peerName: s.peerName,
      paired: true,
      handoffId: s.handoffId,
      callerName: callerName.isNotEmpty ? callerName : call.number,
      callerNumber: call.number,
      outgoing: true,
    );
    final wasMuted = call.muted;
    if (attended) {
      // The owner talks to the peer first: park the external caller.
      await _guard(() => _engine.hold(cid));
    } else if (!wasMuted) {
      // Keep the external call up but stop our microphone while we dial.
      await _guard(() => _engine.mute(cid, true));
    }
    s.phase = attended ? RelayPhase.consulting : RelayPhase.dialing;
    _relay.touch();
    final lanCid = await _calls.placeLanCall(peer.sipUri!, headers: headers, meta: meta, silent: !attended);
    if (lanCid == null) {
      await _restoreAfterFailure(s, wasMuted: wasMuted);
      throw LanHandoffException(_l.lanHoCouldNotCall(s.peerName));
    }
    s.lanCid = lanCid;
    if (attended) {
      _calls.markConsult(lanCid, cid);
      _relay.touch();
      return; // completed from the consult banner (completeAttendedRelay)
    }
    final ok = await _waitConfirmed(lanCid, const Duration(seconds: 30));
    if (!ok || _sessions[cid] != s) {
      if (_calls.rawCall(lanCid)?.isEnded == false) await _guard(() => _engine.hangup(lanCid));
      await _restoreAfterFailure(s, wasMuted: wasMuted);
      throw LanHandoffException(_l.lanHoNoAnswer(s.peerName));
    }
    if (_calls.rawCall(cid)?.isEnded ?? true) {
      await _guard(() => _engine.hangup(lanCid));
      _drop(s);
      return;
    }
    await _bridge(s);
    if (!wasMuted) await _guard(() => _engine.mute(cid, false));
  }

  Future<void> _restoreAfterFailure(RelaySession s, {required bool wasMuted}) async {
    final c = _calls.rawCall(s.cid);
    if (c != null && !c.isEnded) {
      if (s.attended) {
        await _guard(() => _engine.unhold(s.cid));
      } else if (!wasMuted) {
        await _guard(() => _engine.mute(s.cid, false));
      }
    }
    unawaited(_lan.link?.cancelHandoff(s.peerId, s.handoffId).catchError((_) {}));
    _drop(s);
  }

  /// Joins the external call and the LAN leg and removes our own audio.
  Future<void> _bridge(RelaySession s) async {
    final lanCid = s.lanCid!;
    await _engine.bridge(s.cid, lanCid, true);
    await _engine.detachLocal(s.cid, true);
    await _engine.detachLocal(lanCid, true);
    s.phase = RelayPhase.relayed;
    s.since = DateTime.now();
    _calls.markHandedOff(s.cid, _l.lanHoHandedOffReason(s.peerName));
    _relay.put(s);
    unawaited(_lan.link?.completeHandoff(s.peerId, s.handoffId).catchError((_) {}));
    _ref.read(noticeProvider.notifier).show(_l.lanHoRelayed(s.peerName));
  }

  @override
  bool isRelayConsult(int cid) =>
      _sessions.values.any((s) => s.lanCid == cid && s.phase == RelayPhase.consulting);

  @override
  Future<bool> completeAttendedRelay(int consultCid) async {
    RelaySession? s;
    for (final x in _sessions.values) {
      if (x.lanCid == consultCid && x.phase == RelayPhase.consulting) s = x;
    }
    if (s == null) return false;
    final lanCall = _calls.rawCall(consultCid);
    if (lanCall == null || !lanCall.isConfirmed) {
      _ref.read(noticeProvider.notifier).show(_l.lanHoWaitAnswer(s.peerName));
      return false;
    }
    try {
      await _engine.unhold(s.cid);
      _calls.setSilent(consultCid, true);
      await _bridge(s);
      return true;
    } on EngineException catch (e) {
      _ref.read(noticeProvider.notifier).error(_l.lanHoFailed, details: '$e');
      return false;
    }
  }

  /// Reverse of the relay: reconnect our audio and drop the LAN leg.
  Future<void> takeBack(int cid) async {
    final s = _sessions[cid];
    if (s == null || s.phase != RelayPhase.relayed || s.lanCid == null) return;
    s.phase = RelayPhase.takingBack;
    _relay.touch();
    final lanCid = s.lanCid!;
    await _guard(() => _engine.bridge(cid, lanCid, false));
    await _guard(() => _engine.detachLocal(cid, false));
    await _guard(() => _engine.hangup(lanCid));
    _calls.clearHandedOff(cid);
    unawaited(_lan.link?.cancelHandoff(s.peerId, s.handoffId).catchError((_) {}));
    _drop(s);
    _ref.read(noticeProvider.notifier).show(_l.lanHoTakenBack(s.peerName));
  }

  /// Ends a relayed call completely (both legs).
  Future<void> endRelayed(int cid) async {
    final s = _sessions[cid];
    if (s == null) return;
    final lanCid = s.lanCid;
    _calls.rawCall(cid)?.userHangup = true;
    if (lanCid != null) await _guard(() => _engine.hangup(lanCid));
    await _guard(() => _engine.hangup(cid));
  }

  void _onCallEnded(int ended) {
    for (final s in _sessions.values.toList()) {
      final lanCid = s.lanCid;
      if (s.cid != ended && lanCid != ended) continue;
      if (s.phase == RelayPhase.takingBack) continue;
      final other = s.cid == ended ? lanCid : s.cid;
      switch (s.phase) {
        case RelayPhase.relayed:
          // Either leg hung up: the other must not be left dangling.
          if (other != null) unawaited(_guard(() => _engine.hangup(other)));
          _drop(s);
        case RelayPhase.consulting:
          if (s.cid == ended) {
            if (other != null) unawaited(_guard(() => _engine.hangup(other)));
          } else {
            unawaited(_guard(() => _engine.unhold(s.cid)));
            _ref.read(noticeProvider.notifier).show(_l.lanHoConsultEnded(s.peerName));
          }
          unawaited(_lan.link?.cancelHandoff(s.peerId, s.handoffId).catchError((_) {}));
          _drop(s);
        case RelayPhase.dialing:
          // _doRelay is waiting on this leg and reports the failure itself.
          if (s.cid == ended && other != null) unawaited(_guard(() => _engine.hangup(other)));
        case RelayPhase.offering || RelayPhase.takingBack:
          break;
      }
    }
  }

  // ---- incoming: offers from a peer --------------------------------------------

  void _onOffer(ll.IncomingHandoff h) {
    if (_disposed) return;
    final peerId = h.peer.deviceId;
    final settings = _ref.read(settingsProvider);
    final pulled = _ref.read(lanPullIntentProvider.notifier).consume(peerId);
    if (!h.peer.trusted) {
      unawaited(h.decline('not_paired').catchError((_) {}));
      return;
    }
    if (!pulled && (settings.dnd || settings.globalStatus == 'dnd')) {
      unawaited(h.decline('dnd').catchError((_) {}));
      return;
    }
    final lanPort = _ref.read(engineProvider).startResult?.lan?.port ?? 0;
    if (h.offer.mode == ll.HandoffMode.relay && lanPort == 0) {
      unawaited(h.decline('lan_sip_unavailable').catchError((_) {}));
      return;
    }
    if (pulled) {
      unawaited(respond(h, true));
    } else if (_prompts.hasListener) {
      _prompts.add(h);
    } else {
      unawaited(h.decline('busy').catchError((_) {}));
    }
  }

  /// Accept or decline an incoming offer (after the user decided).
  Future<void> respond(ll.IncomingHandoff h, bool accept) async {
    if (h.cancelled || h.answered) return;
    final offer = h.offer;
    try {
      if (accept) {
        _accepted[offer.handoffId] = _Accepted(h.peer.deviceId, offer, DateTime.now().add(const Duration(minutes: 2)));
        await h.accept();
      } else {
        await h.decline();
      }
    } catch (_) {
      _accepted.remove(offer.handoffId);
    }
  }

  void _onHandoffEvent(ll.HandoffEvent e) {
    if (e.kind == ll.HandoffEventKind.cancelled) {
      _accepted.remove(e.handoffId);
      if (!_cancelledPrompts.isClosed) _cancelledPrompts.add(e.handoffId);
    }
  }

  Future<void> _onPull(ll.PullRequest r) async {
    final settings = _ref.read(settingsProvider);
    if (!settings.lanAllowPull || !r.peer.trusted || _disposed) return;
    final cid = int.tryParse(r.callId);
    final c = cid == null ? null : _calls.rawCall(cid);
    if (cid == null || c == null || !c.isConfirmed || c.lan != null || c.info.uid == kLanAccountUid) return;
    try {
      await _handoff(cid, r.peer.deviceId, attended: false, ringing: false);
    } on LanHandoffException catch (e) {
      _ref.read(noticeProvider.notifier).show(e.message);
    } catch (e) {
      _ref.read(noticeProvider.notifier).error(_l.lanHoCouldNotHand(r.peer.name), details: '$e');
    }
  }

  // ---- call policy -----------------------------------------------------------------

  @override
  LanCallMeta? classifyIncoming(CallInfo info) {
    final isLan = info.uid == kLanAccountUid;
    final h = info.headers;
    final handoffId = headerValue(h, kHdrHandoff);
    final link = _lan.link;
    final st = _ref.read(lanControllerProvider);
    final now = DateTime.now();
    _accepted.removeWhere((_, a) => a.expires.isBefore(now));

    // Who is calling? Header claim, cross-checked with the source address.
    ll.LanPeer? peer;
    if (link != null && isLan) {
      final claimed = headerValue(h, kHdrDevice)?.toLowerCase();
      if (claimed != null) peer = st.peer(claimed);
      final ip = _hostOf(info.remoteContact) ?? _hostOf(info.remoteUri);
      if (peer != null && ip != null && peer.address != null && peer.address!.address != ip) peer = null;
      peer ??= ip == null ? null : st.peers.cast<ll.LanPeer?>().firstWhere((p) => p!.address?.address == ip && p.trusted, orElse: () => null);
    }

    _Accepted? acc;
    if (handoffId != null) {
      final a = _accepted[handoffId];
      if (a != null && (!isLan || peer == null || peer.deviceId == a.peerId || headerValue(h, kHdrDevice) == a.peerId)) acc = a;
    } else if (!isLan) {
      // REFER mode: the PBX delivers the transferred call to our AOR.
      final num = _digits(info.remoteUser);
      for (final a in _accepted.values) {
        if (a.offer.mode != ll.HandoffMode.refer) continue;
        final cn = _digits(a.offer.caller.number);
        final referred = headerValue(h, 'Referred-By') != null;
        if ((cn.isNotEmpty && cn == num) || (referred && cn.isEmpty)) {
          acc = a;
          break;
        }
      }
    }
    if (!isLan && acc == null) return null;
    if (acc != null) _accepted.remove(acc.offer.handoffId);

    final peerId = peer?.deviceId ?? acc?.peerId ?? '';
    final known = peerId.isEmpty ? null : st.peer(peerId);
    final name = headerValue(h, kHdrCallerName) ?? acc?.offer.caller.name ?? '';
    final number = headerValue(h, kHdrCallerNumber) ?? acc?.offer.caller.number ?? '';
    final intercom = isLan && peer != null && peer.trusted && _lan.intercomGranted(peer.deviceId);
    return LanCallMeta(
      peerId: peerId,
      peerName: known?.name ?? '',
      paired: known?.trusted ?? false,
      intercom: intercom,
      handoffId: acc?.offer.handoffId ?? handoffId,
      handoffAccepted: acc != null,
      callerName: name,
      callerNumber: number,
    );
  }
}

final lanHandoffImplProvider = Provider<LanHandoffImpl>((ref) {
  final impl = LanHandoffImpl(ref);
  ref.onDispose(impl.dispose);
  Future.microtask(() {
    try {
      impl.init();
    } catch (_) {}
  });
  return impl;
});

final lanCallPolicyProvider = Provider<LanCallPolicy>((ref) => ref.watch(lanHandoffImplProvider));

/// Snapshot facade: a new instance whenever LAN state changes, so widgets
/// watching [lanHandoffProvider] rebuild when devices come and go.
class _LanHandoffFacade implements LanHandoff {
  _LanHandoffFacade(this._impl, this._state);
  final LanHandoffImpl _impl;
  final LanState _state;

  @override
  bool get available => _state.running;
  @override
  List<LanDevice> get devices => LanHandoffImpl.devicesOf(_state);
  @override
  Stream<List<LanDevice>> get devicesStream => Stream.value(devices);

  @override
  Future<void> handoff({required int cid, required LanDevice device, HandoffMode mode = HandoffMode.blind}) =>
      _impl.handoff(cid: cid, peerId: device.id, attended: mode == HandoffMode.attended);

  @override
  Future<void> forwardIncoming({required int cid, required LanDevice device}) =>
      _impl.forwardIncoming(cid: cid, peerId: device.id);
}

final lanHandoffFacadeProvider = Provider<LanHandoff>((ref) {
  final st = ref.watch(lanControllerProvider);
  return _LanHandoffFacade(ref.watch(lanHandoffImplProvider), st);
});
