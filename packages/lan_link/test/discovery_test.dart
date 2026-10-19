import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:lan_link/lan_link.dart';
import 'package:test/test.dart';

class FakeSocket implements BeaconSocket {
  final ctrl = StreamController<Datagram>.broadcast();
  final sent = <({List<int> data, InternetAddress to, int port})>[];
  bool closed = false;
  @override
  Stream<Datagram> get datagrams => ctrl.stream;
  @override
  void send(List<int> data, InternetAddress address, int port) =>
      sent.add((data: data, to: address, port: port));
  @override
  Future<void> close() async => closed = true;
}

Future<DeviceInfo> makeInfo(String name,
    {int port = 1234, PeerStatus status = PeerStatus.available}) async {
  final id = await LocalIdentity.generate();
  return DeviceInfo(
      deviceId: id.deviceId,
      name: name,
      platform: 'test',
      linkPort: port,
      ed25519Pub: id.edPub,
      x25519Pub: id.xPub,
      status: status);
}

void main() {
  group('beacon codec', () {
    test('round trip', () async {
      final info = await makeInfo('Desk');
      final b = await BeaconCodec.decode(BeaconCodec.encodeBeacon(info));
      expect(b!.info!.deviceId, info.deviceId);
      expect(b.info!.name, 'Desk');
      expect(b.info!.sameAs(info), isTrue);
    });

    test('malformed input never throws', () async {
      final info = await makeInfo('x');
      final good = jsonDecode(utf8.decode(BeaconCodec.encodeBeacon(info)))
          as Map<String, dynamic>;
      Future<ParsedBeacon?> d(Object o) =>
          BeaconCodec.decode(o is List<int> ? o : utf8.encode(jsonEncode(o)));
      expect(await d([]), isNull);
      expect(await d([0xff, 0xfe, 0x00]), isNull);
      expect(await d(utf8.encode('{not json')), isNull);
      expect(await d([1, 2, 3]), isNull);
      expect(await d(<String, dynamic>{'spp': 2, 't': 'beacon'}), isNull);
      expect(await d(<String, dynamic>{'spp': 1, 't': 'beacon', 'info': 5}),
          isNull);
      expect(
          await d(<String, dynamic>{
            'spp': 1,
            't': 'beacon',
            'info': {'name': 1}
          }),
          isNull);
      expect(await d(List<int>.filled(maxBeaconSize + 1, 65)), isNull);
      // id not matching key
      final forged = jsonDecode(jsonEncode(good)) as Map<String, dynamic>;
      (forged['info'] as Map<String, dynamic>)['deviceId'] = '0123456789abcdef';
      expect(await d(forged), isNull);
      // bad port, wrong types
      final badPort = jsonDecode(jsonEncode(good)) as Map<String, dynamic>;
      (badPort['info'] as Map<String, dynamic>)['linkPort'] = 99999;
      expect(await d(badPort), isNull);
      final badType = jsonDecode(jsonEncode(good)) as Map<String, dynamic>;
      (badType['info'] as Map<String, dynamic>)['aors'] = 'x';
      expect(await d(badType), isNull);
    });

    test('control chars and unknown capabilities are sanitised', () async {
      final info = await makeInfo('x');
      final m = jsonDecode(utf8.decode(BeaconCodec.encodeBeacon(info)))
          as Map<String, dynamic>;
      final i = m['info'] as Map<String, dynamic>;
      i['name'] = 'a\u0000b\nc';
      i['capabilities'] = ['chat', 'nuke', 5];
      final b = await BeaconCodec.decode(utf8.encode(jsonEncode(m)));
      expect(b!.info!.name, 'a b c');
      expect(b.info!.capabilities, {Capability.chat});
    });
  });

  group('MulticastDiscovery with fake socket', () {
    late FakeSocket sock;
    late DateTime clock;
    late MulticastDiscovery d;
    late List<DiscoveryEvent> events;
    final from = InternetAddress('192.168.1.50');

    setUp(() async {
      sock = FakeSocket();
      clock = DateTime(2025, 1, 1);
      d = MulticastDiscovery(
          socketFactory: (g, p) async => sock, now: () => clock);
      events = [];
      d.events.listen(events.add);
    });
    tearDown(() => d.stop());

    Future<void> deliver(List<int> data) async {
      await d.handlePacket(data, from);
      await Future<void>.delayed(Duration.zero);
    }

    test('announce sends beacon + probe on start, and on change', () async {
      final own = await makeInfo('me');
      d.announce(own);
      await d.start();
      final kinds = sock.sent
          .map((s) => (jsonDecode(utf8.decode(s.data)) as Map)['t'])
          .toList();
      expect(kinds, containsAll(['probe', 'beacon']));
      expect(sock.sent.first.to.address, '239.255.77.77');
      expect(sock.sent.first.port, 47777);
      final before = sock.sent.length;
      d.announce(own.copyWith(status: PeerStatus.busy));
      expect(sock.sent.length, before + 1);
      d.announce(own.copyWith(status: PeerStatus.busy)); // unchanged
      expect(sock.sent.length, before + 1);
    });

    test('found, updated, ignore own, expire', () async {
      final own = await makeInfo('me');
      d.announce(own);
      await d.start();
      final peer = await makeInfo('peer');
      await deliver(BeaconCodec.encodeBeacon(own)); // own beacon ignored
      expect(events, isEmpty);
      await deliver(BeaconCodec.encodeBeacon(peer));
      expect(events.single.type, DiscoveryEventType.found);
      expect(events.single.address, from);
      // same beacon again: refresh only
      clock = clock.add(const Duration(seconds: 3));
      await deliver(BeaconCodec.encodeBeacon(peer));
      expect(events.length, 1);
      // change -> updated
      await deliver(
          BeaconCodec.encodeBeacon(peer.copyWith(status: PeerStatus.dnd)));
      expect(events.last.type, DiscoveryEventType.updated);
      expect(events.last.info!.status, PeerStatus.dnd);
      // within 12s: still there
      clock = clock.add(const Duration(seconds: 11));
      d.sweep();
      expect(events.length, 2);
      // past 12s of silence: lost
      clock = clock.add(const Duration(seconds: 2));
      d.sweep();
      await Future<void>.delayed(Duration.zero);
      expect(events.last.type, DiscoveryEventType.lost);
      expect(events.last.deviceId, peer.deviceId);
      // garbage is ignored
      await deliver([1, 2, 3]);
      expect(events.length, 3);
    });

    test('probe triggers unicast beacon reply', () async {
      final own = await makeInfo('me');
      d.announce(own);
      await d.start();
      sock.sent.clear();
      await deliver(BeaconCodec.encodeProbe('someoneelse'));
      await Future<void>.delayed(const Duration(milliseconds: 400));
      expect(sock.sent.length, 1);
      expect(sock.sent.single.to, from);
    });

    test('stop emits lost for known peers', () async {
      d.announce(await makeInfo('me'));
      await d.start();
      final peer = await makeInfo('peer');
      await deliver(BeaconCodec.encodeBeacon(peer));
      await d.stop();
      await Future<void>.delayed(Duration.zero);
      expect(events.last.type, DiscoveryEventType.lost);
      expect(sock.closed, isTrue);
    });
  });

  group('CompositeDiscovery', () {
    test('merges by deviceId; lost only when all providers lost', () async {
      final peer = await makeInfo('p');
      final ctrlA = StreamController<DiscoveryEvent>.broadcast();
      final ctrlB = StreamController<DiscoveryEvent>.broadcast();
      final c2 = CompositeDiscovery([_Fake(ctrlA.stream), _Fake(ctrlB.stream)]);
      final ev = <DiscoveryEvent>[];
      c2.events.listen(ev.add);
      await c2.start();
      final addr = InternetAddress('10.0.0.1');
      ctrlA.add(DiscoveryEvent(DiscoveryEventType.found, peer.deviceId,
          info: peer, address: addr));
      ctrlB.add(DiscoveryEvent(DiscoveryEventType.found, peer.deviceId,
          info: peer, address: addr));
      await Future<void>.delayed(Duration.zero);
      expect(ev.map((e) => e.type), [DiscoveryEventType.found]);
      ctrlA.add(DiscoveryEvent(DiscoveryEventType.lost, peer.deviceId));
      await Future<void>.delayed(Duration.zero);
      expect(ev.length, 1);
      ctrlB.add(DiscoveryEvent(DiscoveryEventType.lost, peer.deviceId));
      await Future<void>.delayed(Duration.zero);
      expect(ev.last.type, DiscoveryEventType.lost);
      await c2.stop();
    });
  });

  group('network', () {
    test('two MulticastDiscovery instances find each other', () async {
      final port = 47000 + DateTime.now().millisecond % 500;
      final a = MulticastDiscovery(
          port: port, beaconInterval: const Duration(milliseconds: 300));
      final b = MulticastDiscovery(
          port: port, beaconInterval: const Duration(milliseconds: 300));
      final ia = await makeInfo('A');
      final ib = await makeInfo('B');
      a.announce(ia);
      b.announce(ib);
      final gotA = a.events.firstWhere((e) => e.deviceId == ib.deviceId);
      final gotB = b.events.firstWhere((e) => e.deviceId == ia.deviceId);
      await a.start();
      await b.start();
      final ea = await gotA.timeout(const Duration(seconds: 8));
      final eb = await gotB.timeout(const Duration(seconds: 8));
      expect(ea.info!.name, 'B');
      expect(eb.info!.name, 'A');
      await a.stop();
      await b.stop();
    }, tags: ['network']);
  });
}

class _Fake implements DiscoveryProvider {
  _Fake(this.events);
  @override
  final Stream<DiscoveryEvent> events;
  @override
  void announce(DeviceInfo info) {}
  @override
  Future<void> start() async {}
  @override
  Future<void> stop() async {}
}
