import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:lan_link/lan_link.dart';

class Node {
  Node(this.link, this.dir, this.keys, this.trust);
  final LanLink link;
  final Directory dir;
  final KeyStore keys;
  final TrustStore trust;
  final List<ChatMessage> inbox = [];
  String get id => link.deviceId;
  int get port => link.linkPort;
  String get downloads => '${dir.path}/downloads';
}

Future<Node> makeNode(
  String name, {
  KeyStore? keys,
  TrustStore? trust,
  Directory? dir,
  int port = 0,
  Duration pairingTimeout = const Duration(seconds: 120),
  Duration handoffTimeout = const Duration(seconds: 45),
  Set<Capability>? caps,
  int maxFileSize = 4 * 1024 * 1024 * 1024,
  bool start = true,
  bool keepConnected = true,
}) async {
  dir ??= await Directory.systemTemp.createTemp('lanlink_$name');
  keys ??= InMemoryKeyStore();
  trust ??= InMemoryTrustStore();
  final link = LanLink(LanLinkConfig(
    deviceName: name,
    platform: 'test',
    downloadsDir: '${dir.path}/downloads',
    linkPort: port,
    discoveryProviders: [],
    keyStore: keys,
    trustStore: trust,
    bindAddress: InternetAddress.loopbackIPv4,
    pairingTimeout: pairingTimeout,
    handoffTimeout: handoffTimeout,
    maxFileSize: maxFileSize,
    keepConnected: keepConnected,
    allowedCapabilities: caps ??
        const {
          Capability.chat,
          Capability.files,
          Capability.handoff,
          Capability.intercom
        },
  ));
  final n = Node(link, dir, keys, trust);
  link.chatMessages.where((m) => m.incoming).listen(n.inbox.add);
  if (start) await link.start();
  return n;
}

Future<void> stopNode(Node n) async {
  await n.link.stop();
  try {
    await n.dir.delete(recursive: true);
  } catch (_) {}
}

/// Makes each node know the other's address (what discovery does in real life).
Future<void> introduce(Node a, Node b) async {
  await a.link.connectManual('127.0.0.1', b.port);
  await b.link.connectManual('127.0.0.1', a.port);
}

Future<T> until<T>(T? Function() f,
    {Duration timeout = const Duration(seconds: 20), String? what}) async {
  final end = DateTime.now().add(timeout);
  while (true) {
    final v = f();
    if (v != null && v != false) return v;
    if (DateTime.now().isAfter(end)) {
      throw TimeoutException('until timed out ${what ?? ''}');
    }
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
}

/// Runs a full successful pairing between [a] and [b].
Future<void> pairNodes(Node a, Node b) async {
  await introduce(a, b);
  final incoming = b.link.pairingRequests.first;
  final sa = a.link.pair(a.link.peerById(b.id)!);
  final sb = await incoming;
  await until(() =>
      sa.state == PairingState.awaitingConfirm &&
      sb.state == PairingState.awaitingConfirm);
  if (sa.sas != sb.sas) throw StateError('SAS mismatch');
  await sa.confirm();
  await sb.confirm();
  await sa.done;
  await sb.done;
  if (!sa.success || !sb.success)
    throw StateError('pairing failed ${sa.failure} ${sb.failure}');
  await until(() =>
      a.link.peerById(b.id)?.trusted == true &&
      b.link.peerById(a.id)?.trusted == true);
}

final _rng = Random(42);

Future<File> randomFile(Directory dir, String name, int bytes) async {
  final f = File('${dir.path}/$name');
  final sink = f.openWrite();
  var left = bytes;
  while (left > 0) {
    final n = min(left, 1 << 16);
    sink.add(List<int>.generate(n, (_) => _rng.nextInt(256)));
    left -= n;
  }
  await sink.close();
  return f;
}
