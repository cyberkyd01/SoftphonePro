import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:lan_link/lan_link.dart' as ll;
import 'package:softphonepro/lan/lan_controller.dart';
import 'package:softphonepro/lan/lan_handoff_impl.dart';
import 'package:softphonepro/models/account_profile.dart';
import 'package:softphonepro/models/app_settings.dart';
import 'package:softphonepro/services/accounts_controller.dart';
import 'package:softphonepro/services/calls_controller.dart';
import 'package:softphonepro/services/engine_controller.dart';
import 'package:softphonepro/services/messages_controller.dart';
import 'package:softphonepro/ui/pages/lan/lan_widgets.dart';
import 'package:spcore_dart/spcore_dart.dart';

import '../harness.dart';

class Req {
  Req(this.method, this.params);
  final String method;
  final Map<String, dynamic> params;
  @override
  String toString() => '$method${params.isEmpty ? '' : params}';
}

/// FakeSipEngine that records every request in order.
class RecordingEngine extends FakeSipEngine {
  RecordingEngine() : super(timings: FakeTimings.instant);
  final List<Req> log = [];
  void Function(String method, Map<String, dynamic> params)? onRequest;

  @override
  Future<Map<String, dynamic>> request(String method, Map<String, dynamic> params, {Duration? timeout}) {
    log.add(Req(method, Map.of(params)));
    onRequest?.call(method, params);
    return super.request(method, params, timeout: timeout);
  }

  List<String> get methods => log.map((e) => e.method).toList();
  Iterable<Req> of(String m) => log.where((e) => e.method == m);
}

class FakeFileOps extends LanFileOps {
  FakeFileOps([this.picks = const []]);
  List<String> picks;
  @override
  Future<List<String>> pick() async => picks;
}

/// One simulated device: its own database, secrets, engine and link.
class LanNode {
  LanNode._(this.name, this.env, this.engine, this.downloads, this.overrides);
  final String name;
  final TestEnv env;
  final RecordingEngine engine;
  final Directory downloads;
  final List<Override> overrides;
  ProviderContainer? _c;

  static Future<LanNode> create(
    String name, {
    List<AccountProfile> profiles = const [],
    Map<String, dynamic> settings = const {},
    FakeFileOps? fileOps,
  }) async {
    final engine = RecordingEngine();
    final env = await TestEnv.create(
      profiles: profiles,
      engine: engine,
      settings: AppSettings({'onboardingDone': true, 'lanEnabled': true, 'lanDeviceName': name, ...settings}),
    );
    final dl = Directory.systemTemp.createTempSync('lan_dl_$name');
    final overrides = <Override>[
      ...env.overrides,
      lanDiscoveryFactoryProvider.overrideWithValue(() => const <ll.DiscoveryProvider>[]),
      lanLocalAddressesProvider.overrideWithValue(() async => ['127.0.0.1']),
      lanDownloadsDirProvider.overrideWithValue(() async => dl.path),
      lanFileOpsProvider.overrideWithValue(fileOps ?? FakeFileOps()),
    ];
    return LanNode._(name, env, engine, dl, overrides);
  }

  /// A container-only node (no widgets). Starts engine + LAN.
  Future<ProviderContainer> boot() async {
    final c = _c = ProviderContainer(overrides: overrides);
    await bootIn(c);
    return c;
  }

  ProviderContainer get c => _c!;
  void attach(ProviderContainer c) => _c = c;

  Future<void> bootIn(ProviderContainer c) async {
    _c ??= c;
    c.read(accountsProvider);
    c.read(callsProvider);
    c.read(messagesProvider);
    c.read(lanControllerProvider);
    c.read(lanHandoffImplProvider);
    await c.read(engineProvider.notifier).start();
    await until(() => c.read(lanControllerProvider).running && c.read(lanControllerProvider).self!.sipPort > 0, what: '$name LAN running');
  }

  LanController lan([ProviderContainer? x]) => (x ?? c).read(lanControllerProvider.notifier);
  String id([ProviderContainer? x]) => lan(x).link!.deviceId;
  int port([ProviderContainer? x]) => lan(x).link!.linkPort;

  Future<void> dispose() async {
    _c?.dispose();
    try {
      downloads.deleteSync(recursive: true);
    } catch (_) {}
  }
}

Future<void> until(bool Function() cond, {Duration timeout = const Duration(seconds: 10), String what = 'condition'}) async {
  final end = DateTime.now().add(timeout);
  while (!cond()) {
    if (DateTime.now().isAfter(end)) throw StateError('timed out waiting for $what');
    await Future<void>.delayed(const Duration(milliseconds: 20));
  }
}

/// A connects to B by address and both confirm the pairing code.
Future<void> pairNodes(LanNode a, ProviderContainer ca, LanNode b, ProviderContainer cb) async {
  final incoming = Completer<ll.PairingSession>();
  final sub = b.lan(cb).pairingRequests.listen((s) {
    if (!incoming.isCompleted) incoming.complete(s);
  });
  await a.lan(ca).connectManual('127.0.0.1:${b.port(cb)}');
  final sa = a.lan(ca).pair(b.id(cb));
  final sb = await incoming.future.timeout(const Duration(seconds: 10));
  await until(() => sa.state == ll.PairingState.awaitingConfirm && sb.state == ll.PairingState.awaitingConfirm, what: 'SAS');
  if (sa.sas != sb.sas) throw StateError('SAS mismatch');
  await sa.confirm();
  await sb.confirm();
  await sa.done;
  await sub.cancel();
  if (!sa.success) throw StateError('pairing failed: ${sa.failure}');
  await until(() => a.lan(ca).link!.peerById(b.id(cb))?.trusted == true && b.lan(cb).link!.peerById(a.id(ca))?.trusted == true, what: 'trust');
  await until(() => a.lan(ca).link!.peerById(b.id(cb))?.info != null, what: 'peer info');
  await until(() => b.lan(cb).link!.peerById(a.id(ca))?.connected == true || a.lan(ca).link!.peerById(b.id(cb))?.connected == true, what: 'connection');
}

AccountProfile accountFor(String id, String user, {String domain = 'pbx.test'}) => testProfile(id: id, user: user, domain: domain);
