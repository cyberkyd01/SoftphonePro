// Host-side LAN Link peer for testing the app against an emulator/device.
//
//   dart --packages=.dart_tool/package_config.json tool/lan_peer.dart \
//     --port 47900 --dir /tmp/peer --app 127.0.0.1:47800 [--send file] [--say text]
//
// With adb: `adb reverse tcp:47900 tcp:47900` lets the app reach this peer at
// 127.0.0.1:47900, and `adb forward tcp:47800 tcp:47800` lets this peer reach
// the app (set the app's LAN "Link port" to 47800).
//
// Behaviour: auto-confirms the pairing code, echoes every chat message, marks
// them read, accepts every file offer and logs everything to stdout.
import 'dart:async';
import 'dart:io';

import 'package:lan_link/lan_link.dart';

Future<void> main(List<String> args) async {
  String opt(String name, String def) {
    final i = args.indexOf('--$name');
    return i >= 0 && i + 1 < args.length ? args[i + 1] : def;
  }

  final dir = opt('dir', '${Directory.systemTemp.path}/lan_peer');
  final port = int.parse(opt('port', '47900'));
  final name = opt('name', 'Host peer');
  final app = opt('app', '');
  final say = opt('say', '');
  final send = opt('send', '');
  Directory(dir).createSync(recursive: true);
  void log(String s) => stdout.writeln('[peer ${DateTime.now().toIso8601String().substring(11, 19)}] $s');

  final link = LanLink(LanLinkConfig(
    deviceName: name,
    platform: 'linux',
    downloadsDir: '$dir/downloads',
    linkPort: port,
    discoveryProviders: const [],
    keyStore: FileKeyStore('$dir/keys.json'),
    trustStore: FileTrustStore('$dir/trust.json'),
    autoAcceptFile: (peer, offer) => true,
  ));
  await link.start();
  log('started: deviceId=${link.deviceId} link port=${link.linkPort} downloads=$dir/downloads');

  void watchPairing(PairingSession s) {
    s.updates.listen((x) {
      log('pairing ${x.incoming ? 'from' : 'with'} ${x.peerName}: ${x.state.name}${x.sas != null ? ' code=${x.sas}' : ''}');
      if (x.state == PairingState.awaitingConfirm) x.confirm();
    });
    s.done.then((x) async {
      log('pairing finished: ${x.state.name}');
      if (!x.success) return;
      // Give the app a moment to finish its side, then greet and drop a file.
      await Future<void>.delayed(const Duration(seconds: 2));
      try {
        if (say.isNotEmpty) await link.sendChat(x.peerId, say, queue: true);
        if (send.isNotEmpty) link.sendFile(x.peerId, send);
      } catch (e) {
        log('greeting failed: $e');
      }
    });
  }

  link.pairingRequests.listen(watchPairing);
  link.chatMessages.listen((m) async {
    if (!m.incoming) return;
    log('chat from ${link.peerById(m.peerId)?.name}: "${m.text}"');
    await link.markRead(m.peerId, m.id);
    await link.sendChat(m.peerId, 'echo: ${m.text}');
    if (send.isNotEmpty && m.text.toLowerCase().contains('file')) link.sendFile(m.peerId, send);
  });
  link.typingEvents.listen((t) => log('typing ${t.peerId}: ${t.typing}'));
  link.fileTransfers.listen((t) {
    log('${t.incoming ? 'incoming' : 'outgoing'} file ${t.name} (${t.size} bytes)');
    t.done.then((x) => log('file ${x.name}: ${x.state.name}${x.savedPath != null ? ' -> ${x.savedPath}' : ''}${x.error != null ? ' (${x.error})' : ''}'));
  });
  link.handoffOffers.listen((h) {
    log('handoff offer from ${h.peer.name}: ${h.offer.caller.name} ${h.offer.caller.number} mode=${h.offer.mode.name}');
    h.accept();
  });

  if (app.isNotEmpty) {
    final i = app.lastIndexOf(':');
    final host = app.substring(0, i);
    final p = int.parse(app.substring(i + 1));
    LanPeer? peer;
    for (var n = 0; n < 30 && peer == null; n++) {
      try {
        peer = await link.connectManual(host, p);
      } catch (e) {
        log('waiting for the app at $app ($e)');
        await Future<void>.delayed(const Duration(seconds: 2));
      }
    }
    if (peer == null) exit(2);
    log('found ${peer.name} (${peer.deviceId}) trusted=${peer.trusted}');
    if (!peer.trusted) watchPairing(link.pair(peer));
    if (say.isNotEmpty || send.isNotEmpty) {
      for (var n = 0; n < 120 && link.peerById(peer.deviceId)?.trusted != true; n++) {
        await Future<void>.delayed(const Duration(seconds: 1));
      }
      if (say.isNotEmpty) await link.sendChat(peer.deviceId, say, queue: true);
      if (send.isNotEmpty) link.sendFile(peer.deviceId, send);
    }
  }

  final done = Completer<void>();
  ProcessSignal.sigint.watch().listen((_) => done.complete());
  await done.future;
  await link.stop();
}
