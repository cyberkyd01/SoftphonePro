import 'dart:async';
import 'dart:io';
import 'dart:ui' show Locale;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spcore_dart/spcore_dart.dart';

import '../l10n/l10n.dart';
import '../models/account_profile.dart';
import '../services/accounts_controller.dart';
import '../services/engine_controller.dart';
import '../services/settings_controller.dart';
import 'diagnostics_hub.dart';
import 'sip_codes.dart';
import 'sip_trace_controller.dart';

enum StepStatus { pending, running, pass, warn, fail, skipped }

class WizardAction {
  const WizardAction(this.label, this.run);
  final String label;
  final Future<void> Function() run;
}

class WizardStep {
  const WizardStep({
    required this.id,
    required this.title,
    this.status = StepStatus.pending,
    this.summary = '',
    this.details = const [],
    this.suggestion = '',
    this.action,
  });
  final String id;
  final String title;
  final StepStatus status;
  final String summary;
  final List<String> details;
  final String suggestion;
  final WizardAction? action;

  WizardStep copyWith({
    StepStatus? status,
    String? summary,
    List<String>? details,
    String? suggestion,
    WizardAction? action,
    bool clearAction = false,
  }) => WizardStep(
    id: id,
    title: title,
    status: status ?? this.status,
    summary: summary ?? this.summary,
    details: details ?? this.details,
    suggestion: suggestion ?? this.suggestion,
    action: clearAction ? null : (action ?? this.action),
  );
}

class WizardState {
  const WizardState({this.steps = const [], this.running = false, this.finished = false});
  final List<WizardStep> steps;
  final bool running;
  final bool finished;

  int count(StepStatus s) => steps.where((e) => e.status == s).length;
}

class NetIface {
  const NetIface(this.name, this.addresses);
  final String name;
  final List<String> addresses;
}

/// Lists non-loopback network interfaces; override in tests.
final interfaceListerProvider = Provider<Future<List<NetIface>> Function()>(
  (ref) => () async {
    final l = await NetworkInterface.list(includeLoopback: false, includeLinkLocal: false);
    return [for (final i in l) NetIface(i.name, [for (final a in i.addresses) a.address])];
  },
);

class _R {
  const _R(this.status, this.summary, {this.details = const [], this.suggestion = '', this.action});
  final StepStatus status;
  final String summary;
  final List<String> details;
  final String suggestion;
  final WizardAction? action;
}

/// Extracts the bare host from a domain/registrar string.
String hostOf(String s) {
  var v = s.trim();
  v = v.replaceFirst(RegExp(r'^sips?:', caseSensitive: false), '');
  v = v.split(';').first.split('/').first;
  final at = v.lastIndexOf('@');
  if (at >= 0) v = v.substring(at + 1);
  if (v.startsWith('[')) {
    final e = v.indexOf(']');
    return e > 0 ? v.substring(1, e) : v;
  }
  final c = v.indexOf(':');
  if (c >= 0 && v.indexOf(':', c + 1) < 0) v = v.substring(0, c);
  return v;
}

bool isIpLiteral(String h) => InternetAddress.tryParse(h) != null;

bool _isPrivate(String ip) {
  final a = InternetAddress.tryParse(ip);
  if (a == null) return false;
  if (a.type == InternetAddressType.IPv6) return ip.toLowerCase().startsWith('fc') || ip.toLowerCase().startsWith('fd');
  final p = ip.split('.').map(int.tryParse).toList();
  if (p.length != 4 || p.contains(null)) return false;
  return p[0] == 10 || (p[0] == 172 && p[1]! >= 16 && p[1]! <= 31) || (p[0] == 192 && p[1] == 168) || (p[0] == 100 && p[1]! >= 64 && p[1]! <= 127);
}

class NetworkWizard extends Notifier<WizardState> {
  bool _cancel = false;
  final Map<String, OptionsResult?> _udpPing = {};
  Duration eventTimeout = const Duration(seconds: 8);

  EngineController get _ctl => ref.read(engineProvider.notifier);

  /// Strings in the language currently in effect.
  AppLocalizations get _l => ref.read(l10nProvider);

  @override
  WizardState build() => const WizardState();

  List<AccountProfile> get _accounts {
    final a = ref.read(accountsProvider);
    return a.enabled.where((p) => p.config.proto == SipProto.sip).toList();
  }

  void cancel() => _cancel = true;

  /// Runs all checks sequentially.
  Future<void> run() async {
    if (state.running) return;
    _cancel = false;
    _udpPing.clear();
    final accounts = _accounts;
    final l = _l;
    final defs = <(String, String, Future<_R> Function())>[
      ('net', l.diagWizStepNet, _stepNet),
      for (final a in accounts) ('dns:${a.id}', l.diagWizStepDns(a.name), () => _stepDns(a)),
      ('nat', l.diagWizStepNat, _stepNat),
      for (final a in accounts) ('options:${a.id}', l.diagWizStepOptions(a.name), () => _stepOptions(a)),
      for (final a in accounts.where(_isTls)) ('tls:${a.id}', l.diagWizStepTls(a.name), () => _stepTls(a)),
      for (final a in accounts) ('reg:${a.id}', l.diagWizStepReg(a.name), () => _stepReg(a)),
      if (accounts.isNotEmpty) ('alg', l.diagWizStepAlg, _stepAlg),
    ];
    state = WizardState(
      steps: [for (final d in defs) WizardStep(id: d.$1, title: d.$2)],
      running: true,
    );
    for (final d in defs) {
      if (_cancel) break;
      await _exec(d.$1, d.$3);
    }
    state = WizardState(steps: state.steps, finished: !_cancel);
  }

  /// Re-runs one step (used after "Trust this certificate").
  Future<void> rerun(String id) async {
    final accId = id.contains(':') ? id.split(':')[1] : '';
    final acc = ref.read(accountsProvider).byId(accId);
    Future<_R> Function()? f = switch (id.split(':').first) {
      'net' => _stepNet,
      'nat' => _stepNat,
      'alg' => _stepAlg,
      'dns' when acc != null => () => _stepDns(acc),
      'options' when acc != null => () => _stepOptions(acc),
      'tls' when acc != null => () => _stepTls(acc),
      'reg' when acc != null => () => _stepReg(acc),
      _ => null,
    };
    if (f != null) await _exec(id, f);
  }

  Future<void> _exec(String id, Future<_R> Function() f) async {
    _set(id, (s) => s.copyWith(status: StepStatus.running, summary: _l.diagWizChecking, details: const [], suggestion: '', clearAction: true));
    _R r;
    try {
      r = await f();
    } on EngineException catch (e) {
      r = _R(StepStatus.fail, _l.diagWizEngineError(e.error.message));
    } catch (e) {
      r = _R(StepStatus.fail, _l.diagWizCheckFailed('$e'));
    }
    _set(id, (s) => s.copyWith(status: r.status, summary: r.summary, details: r.details, suggestion: r.suggestion, action: r.action, clearAction: r.action == null));
  }

  void _set(String id, WizardStep Function(WizardStep) f) {
    state = WizardState(
      steps: [for (final s in state.steps) s.id == id ? f(s) : s],
      running: state.running,
      finished: state.finished,
    );
  }

  bool _isTls(AccountProfile p) => p.config.transport == AccTransport.tls || p.config.transport == AccTransport.wss;

  String _hostFor(AccountProfile p) {
    final r = p.config.registrar;
    return hostOf(r != null && r.trim().isNotEmpty ? r : p.config.domain);
  }

  bool get _engineUp => _ctl.hasEngine;

  _R _noEngine() => _R(
    StepStatus.skipped,
    _l.diagWizNoEngine,
    suggestion: _l.diagWizNoEngineFix,
  );

  /// Waits for an engine event matching [test] after calling [trigger].
  Future<T?> _await<T extends EngineEvent>(Future<void> Function() trigger, bool Function(T) test) async {
    final c = Completer<T?>();
    final sub = _ctl.events.listen((e) {
      if (e is T && test(e) && !c.isCompleted) c.complete(e);
    });
    final timer = Timer(eventTimeout, () {
      if (!c.isCompleted) c.complete(null);
    });
    try {
      await trigger();
      return await c.future;
    } catch (_) {
      if (!c.isCompleted) c.complete(null);
      rethrow;
    } finally {
      timer.cancel();
      await sub.cancel();
    }
  }

  // ---------------------------------------------------------------- steps

  Future<_R> _stepNet() async {
    final ifaces = await ref.read(interfaceListerProvider)();
    final addrs = [
      for (final i in ifaces)
        for (final a in i.addresses) (i.name, a),
    ];
    final l = _l;
    final details = [for (final a in addrs) _isPrivate(a.$2) ? l.diagWizNetAddrPrivate(a.$1, a.$2) : '${a.$1}: ${a.$2}'];
    if (addrs.isEmpty) {
      return _R(
        StepStatus.fail,
        l.diagWizNetNone,
        suggestion: l.diagWizNetNoneFix,
      );
    }
    final v4 = addrs.where((a) => InternetAddress.tryParse(a.$2)?.type == InternetAddressType.IPv4).toList();
    if (v4.isEmpty) {
      return _R(StepStatus.warn, l.diagWizNetIpv6Only, details: details, suggestion: l.diagWizNetIpv6OnlyFix);
    }
    final vpn = ifaces.any((i) => RegExp(r'^(tun|tap|utun|wg|ppp|ipsec)', caseSensitive: false).hasMatch(i.name));
    return _R(
      vpn ? StepStatus.warn : StepStatus.pass,
      l.diagWizNetSummary(v4.length, ifaces.length),
      details: details,
      suggestion: vpn ? l.diagWizNetVpnFix : '',
    );
  }

  Future<_R> _stepDns(AccountProfile a) async {
    final l = _l;
    final host = _hostFor(a);
    if (host.isEmpty) return _R(StepStatus.fail, l.diagWizDnsNoServer, suggestion: l.diagWizDnsNoServerFix);
    if (isIpLiteral(host)) return _R(StepStatus.pass, l.diagWizDnsIpLiteral(host));
    if (!_engineUp) return _noEngine();
    final e = _ctl.engine;
    final details = <String>[];
    var addrs = <String>[];
    String? addrErr;
    try {
      addrs = (await e.resolve(host)).addresses;
    } on EngineException catch (x) {
      addrErr = x.error.message;
    }
    details.add(addrs.isEmpty ? (addrErr == null ? l.diagWizDnsANone : l.diagWizDnsANoneError(addrErr)) : 'A/AAAA: ${addrs.join(', ')}');
    var srvCount = 0;
    for (final t in const ['udp', 'tcp', 'tls']) {
      try {
        final r = await e.resolve(host, srv: true, transport: t);
        final proto = t == 'tls' ? '_sips._tcp' : '_sip._$t';
        if (r.srv.isEmpty) {
          details.add(l.diagWizDnsSrvNone('$proto.$host'));
        } else {
          srvCount += r.srv.length;
          for (final s in r.srv) {
            details.add(l.diagWizDnsSrvRecord('$proto.$host', s.target, s.port, s.priority, s.weight));
          }
        }
      } on EngineException catch (x) {
        details.add(l.diagWizDnsSrvFailed(t, x.error.message));
      }
    }
    if (addrs.isEmpty && srvCount == 0) {
      return _R(
        StepStatus.fail,
        l.diagWizDnsNotResolved(host),
        details: details,
        suggestion: l.diagWizDnsNotResolvedFix,
      );
    }
    if (addrs.isEmpty) {
      return _R(StepStatus.warn, l.diagWizDnsSrvOnly(host), details: details, suggestion: l.diagWizDnsSrvOnlyFix);
    }
    return _R(StepStatus.pass, l.diagWizDnsResolves(host, addrs.first, addrs.length - 1, srvCount), details: details);
  }

  Future<_R> _stepNat() async {
    if (!_engineUp) return _noEngine();
    final l = _l;
    final ev = await _await<DiagNatTypeEvent>(() => _ctl.engine.natType(), (_) => true);
    if (ev == null) {
      return _R(
        StepStatus.warn,
        l.diagWizNatTimeout,
        suggestion: l.diagWizNatTimeoutFix,
      );
    }
    final i = ev.info;
    final desc = friendlyNatDescription(i.description, l);
    final d = <String>[if (desc.isNotEmpty) desc, if (i.stun.isNotEmpty) l.diagWizNatStun(i.stun)];
    switch (i.natType) {
      case NatType.open:
        return _R(StepStatus.pass, l.diagWizNatOpen, details: d);
      case NatType.fullCone:
        return _R(StepStatus.pass, l.diagWizNatFullCone, details: d);
      case NatType.restricted:
        return _R(StepStatus.pass, l.diagWizNatRestricted, details: d);
      case NatType.portRestricted:
        return _R(StepStatus.pass, l.diagWizNatPortRestricted, details: d);
      case NatType.symmetric:
      case NatType.symmetricUdp:
        return _R(
          StepStatus.warn,
          l.diagWizNatSymmetric,
          details: d,
          suggestion: l.diagWizNatSymmetricFix,
        );
      case NatType.blocked:
        return _R(
          StepStatus.fail,
          l.diagWizNatBlocked,
          details: d,
          suggestion: l.diagWizNatBlockedFix,
        );
      case NatType.unknown:
        return _R(StepStatus.warn, l.diagWizNatUnknown, details: d, suggestion: l.diagWizNatUnknownFix);
    }
  }

  bool _engineHas(AccountProfile p) => ref.read(accountsProvider).applied.contains(p.id);

  Future<OptionsResult?> _ping(AccountProfile a, {String? target}) async {
    final ev = await _await<DiagOptionsEvent>(
      () => _ctl.engine.optionsPing(AccountRef.uid(a.id), target: target),
      (e) => e.result.uid == a.id,
    );
    return ev?.result;
  }

  Future<_R> _stepOptions(AccountProfile a) async {
    if (!_engineUp) return _noEngine();
    final l = _l;
    if (!_engineHas(a)) return _R(StepStatus.skipped, l.diagWizOptionsNotLoaded);
    final r = await _ping(a);
    _udpPing[a.id] = r;
    final t = a.config.transport.wire;
    if (r == null) {
      return _R(
        StepStatus.fail,
        l.diagWizOptionsNoAnswer(eventTimeout.inSeconds, t),
        suggestion: l.diagWizOptionsNoAnswerFix,
      );
    }
    final rtt = r.rttMs.round();
    final help = r.code >= 400 ? explainSipCode(r.code, l) : null;
    // Any SIP answer proves reachability. 408/5xx indicate trouble.
    if (r.code == 408 || r.code == 0) {
      return _R(StepStatus.fail, l.diagWizOptionsTimedOut(r.code, r.reason), suggestion: explainSipCode(408, l).suggestion);
    }
    if (r.code >= 500) {
      return _R(StepStatus.warn, l.diagWizOptionsAnsweredAfter(r.code, r.reason, rtt), details: ['${help!.title}: ${help.explanation}'], suggestion: help.suggestion);
    }
    final slow = rtt > 300;
    return _R(
      slow ? StepStatus.warn : StepStatus.pass,
      l.diagWizOptionsAnsweredIn(r.code, r.reason, rtt),
      details: [if (r.code >= 400) l.diagWizOptionsNormalError(r.code)],
      suggestion: slow ? l.diagWizOptionsSlowFix : '',
    );
  }

  Future<_R> _stepTls(AccountProfile a) async {
    final l = _l;
    final host = _hostFor(a);
    final hub = ref.read(diagnosticsHubProvider);
    final rejects = hub.rejectsFor(host);
    if (rejects.isNotEmpty) {
      final r = rejects.last;
      return _R(
        StepStatus.fail,
        l.diagWizTlsRejected,
        details: [
          l.diagWizTlsSubject(r.subject),
          l.diagWizTlsIssuer(r.issuer),
          'SHA-256: ${r.sha256}',
          l.diagWizTlsProblems(r.verifyStatus.join(', ')),
        ],
        suggestion: l.diagWizTlsRejectedFix,
        action: WizardAction(l.diagWizTlsTrust, () => trustCertificate(a, r)),
      );
    }
    final t = hub.tlsFor(host);
    if (t?.tls?.remoteCert != null) {
      final c = t!.tls!.remoteCert!;
      final d = [l.diagWizTlsSubject(c.subject), l.diagWizTlsIssuer(c.issuer), l.diagWizTlsExpires(c.notAfter), 'SHA-256: ${c.sha256}', if (t.tls!.cipher.isNotEmpty) l.diagWizTlsCipher(t.tls!.cipher)];
      final exp = _parseDate(c.notAfter);
      if (exp != null) {
        final left = exp.difference(DateTime.now());
        if (left.isNegative) {
          return _R(StepStatus.fail, l.diagWizTlsExpired(c.notAfter), details: d, suggestion: l.diagWizTlsExpiredFix);
        }
        if (left.inDays < 30) {
          return _R(StepStatus.warn, l.diagWizTlsExpiresSoon(left.inDays), details: d, suggestion: l.diagWizTlsExpiresSoonFix);
        }
      }
      final bad = t.tls!.verifyStatus.where((s) => s.toLowerCase() != 'ok' && s.toLowerCase() != 'verified').toList();
      if (bad.isNotEmpty) {
        return _R(StepStatus.warn, l.diagWizTlsVerifyReported(bad.join(', ')), details: d);
      }
      return _R(StepStatus.pass, l.diagWizTlsOk, details: d);
    }
    final status = ref.read(accountsProvider).statusOf(a.id);
    if (status == AccountStatus.registered) {
      return _R(StepStatus.pass, l.diagWizTlsRegistered);
    }
    return _R(StepStatus.warn, l.diagWizTlsNone, suggestion: l.diagWizTlsNoneFix);
  }

  DateTime? _parseDate(String s) {
    final d = DateTime.tryParse(s.trim());
    if (d != null) return d;
    // "Mar  1 12:00:00 2030 GMT" (OpenSSL style).
    final m = RegExp(r'^([A-Za-z]{3})\s+(\d{1,2})\s+(\d\d):(\d\d):(\d\d)\s+(\d{4})').firstMatch(s.trim());
    if (m == null) return null;
    const mon = ['jan', 'feb', 'mar', 'apr', 'may', 'jun', 'jul', 'aug', 'sep', 'oct', 'nov', 'dec'];
    final mi = mon.indexOf(m.group(1)!.toLowerCase());
    if (mi < 0) return null;
    return DateTime.utc(int.parse(m.group(6)!), mi + 1, int.parse(m.group(2)!), int.parse(m.group(3)!), int.parse(m.group(4)!), int.parse(m.group(5)!));
  }

  /// Pins the certificate for the host (persisted) and re-registers.
  Future<void> trustCertificate(AccountProfile a, TlsVerifyInfo r) async {
    final host = r.host.isNotEmpty ? r.host : _hostFor(a);
    final s = ref.read(settingsProvider);
    final pin = '$host=${r.sha256}';
    if (!s.tlsPins.contains(pin)) {
      await ref.read(settingsProvider.notifier).update({'tlsPins': [...s.tlsPins, pin]});
    }
    ref.read(diagnosticsHubProvider.notifier).clearReject(r.sha256);
    if (_ctl.hasEngine) {
      try {
        await _ctl.engine.setTlsPins([
          for (final p in ref.read(settingsProvider).tlsPins)
            if (p.contains('=')) TlsPin(host: p.substring(0, p.indexOf('=')), sha256: p.substring(p.indexOf('=') + 1)),
        ]);
        await _ctl.engine.setRegistration(AccountRef.uid(a.id), true);
      } catch (_) {}
    }
    await rerun('tls:${a.id}');
  }

  Future<_R> _stepReg(AccountProfile a) async {
    final l = _l;
    final acc = ref.read(accountsProvider);
    final st = acc.statusOf(a.id);
    final i = acc.infos[a.id];
    switch (st) {
      case AccountStatus.registered:
        if (!a.config.register) return _R(StepStatus.pass, l.diagWizRegDisabledByConfig);
        return _R(StepStatus.pass, i != null && i.expires > 0 ? l.diagWizRegRegisteredExpires(i.expires) : l.diagWizRegRegistered, details: [if (i != null && i.transport.isNotEmpty) l.diagWizRegTransport(i.transport), if (i != null && i.contact.isNotEmpty) 'Contact: ${i.contact}']);
      case AccountStatus.registering:
        return _R(StepStatus.warn, l.diagWizRegInProgress, suggestion: l.diagWizRegInProgressFix);
      case AccountStatus.failed:
        final code = i?.regCode ?? 0;
        final help = explainSipCode(code, l);
        return _R(
          StepStatus.fail,
          i == null ? l.diagWizRegFailed : describeRegistrationFailure(i, l),
          details: ['${help.title}: ${help.explanation}'],
          suggestion: help.suggestion,
        );
      case AccountStatus.offline:
        return _R(StepStatus.warn, l.diagWizRegOffline, suggestion: l.diagWizRegOfflineFix);
      case AccountStatus.disabled:
        return _R(StepStatus.skipped, l.diagWizRegDisabled);
    }
  }

  Future<_R> _stepAlg() async {
    if (!_engineUp) return _noEngine();
    final l = _l;
    final details = <String>[];
    final suspects = <String>[];
    final udp = _accounts.where((a) => a.config.transport == AccTransport.udp || a.config.transport == AccTransport.auto).toList();
    if (udp.isEmpty) {
      return _R(StepStatus.skipped, l.diagWizAlgNoUdp);
    }
    final acc = ref.read(accountsProvider);
    for (final a in udp) {
      if (!_engineHas(a)) continue;
      final u = _udpPing[a.id];
      final udpOk = u != null && u.code != 408 && u.code != 0;
      if (!udpOk) {
        final host = _hostFor(a);
        final tcp = await _ping(a, target: 'sip:$host;transport=tcp');
        if (tcp != null && tcp.code != 408 && tcp.code != 0) {
          suspects.add(a.name);
          details.add(l.diagWizAlgTcpOnly(a.name, tcp.code, tcp.rttMs.round()));
        } else {
          details.add(l.diagWizAlgNoAnswer(a.name));
        }
      } else {
        final i = acc.infos[a.id];
        if (i != null && i.regState == RegState.failed && (i.regCode == 408 || i.regCode == 0)) {
          suspects.add(a.name);
          details.add(l.diagWizAlgRegisterTimeout(a.name));
        }
      }
    }
    final rewrite = _contactRewritten();
    if (rewrite != null) details.add(rewrite);
    if (suspects.isNotEmpty) {
      return _R(
        StepStatus.fail,
        l.diagWizAlgSuspected,
        details: details,
        suggestion: l.diagWizAlgSuspectedFix,
      );
    }
    if (rewrite != null) {
      return _R(
        StepStatus.warn,
        l.diagWizAlgContactChanged,
        details: details,
        suggestion: l.diagWizAlgContactChangedFix,
      );
    }
    return _R(StepStatus.pass, l.diagWizAlgOk, details: details);
  }

  /// Compares Contact in our latest REGISTER with the one echoed in the 2xx.
  String? _contactRewritten() {
    final msgs = ref.read(sipTraceProvider.notifier).messages;
    for (var i = msgs.length - 1; i >= 0; i--) {
      final r = msgs[i];
      if (!(r.outgoing && r.isRequest && r.method == 'REGISTER')) continue;
      for (var j = i + 1; j < msgs.length; j++) {
        final p = msgs[j];
        if (p.isResponse && p.callId == r.callId && p.cseqNum == r.cseqNum && p.status >= 200 && p.status < 300) {
          final a = _hostPort(r.header('contact'));
          final b = _hostPort(p.header('contact'));
          if (a != null && b != null && a != b) return _l.diagWizAlgContactRewritten(a, b);
          return null;
        }
      }
    }
    return null;
  }

  String? _hostPort(String? contact) {
    if (contact == null) return null;
    final m = RegExp(r'@([^;>\s,]+)').firstMatch(contact);
    return m?.group(1);
  }

  // ---------------------------------------------------------------- report

  String buildReport({String? header}) {
    final b = StringBuffer();
    b.writeln('SoftphonePro network diagnostics');
    b.writeln('Generated: ${DateTime.now().toIso8601String()}');
    if (header != null) b.writeln(header);
    b.writeln();
    for (final s in state.steps) {
      b.writeln('[${_label(s.status)}] ${s.title}');
      if (s.summary.isNotEmpty) b.writeln('    ${s.summary}');
      for (final d in s.details) {
        b.writeln('    - $d');
      }
      if (s.suggestion.isNotEmpty) b.writeln('    Suggestion: ${s.suggestion}');
    }
    return b.toString();
  }

  static String _label(StepStatus s) => switch (s) {
    StepStatus.pass => 'PASS',
    StepStatus.warn => 'WARN',
    StepStatus.fail => 'FAIL',
    StepStatus.skipped => 'SKIP',
    StepStatus.running => 'RUN ',
    StepStatus.pending => '... ',
  };
}

final networkWizardProvider = NotifierProvider<NetworkWizard, WizardState>(NetworkWizard.new);

/// Plain-language version of the raw NAT detection text from the engine
/// (for example `ErrUnknown` when the STUN server did not answer).
String friendlyNatDescription(String raw, [AppLocalizations? l]) {
  l ??= lookupAppLocalizations(const Locale('en'));
  final t = raw.trim();
  if (t.isEmpty) return '';
  if (RegExp(r'^err', caseSensitive: false).hasMatch(t)) {
    return l.diagWizNatErr;
  }
  if (t.toLowerCase() == 'unknown') return l.diagWizNatUnknownRaw;
  return t;
}
