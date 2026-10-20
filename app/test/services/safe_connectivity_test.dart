import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:softphonepro/services/safe_connectivity.dart';

void main() {
  test('Linux without NetworkManager: stream ends, source never created', () async {
    var created = false;
    final events = await guardedConnectivityStream(
      isLinux: true,
      nmAvailable: () async => false,
      source: () {
        created = true;
        return const Stream.empty();
      },
    ).toList();
    expect(events, isEmpty);
    expect(created, isFalse);
  });

  test('is a broadcast stream (engine and LAN controller both listen)', () async {
    final s = guardedConnectivityStream(isLinux: false, source: () => const Stream.empty());
    expect(s.isBroadcast, isTrue);
    final a = s.listen((_) {});
    final b = s.listen((_) {});
    await a.cancel();
    await b.cancel();
  });

  test('forwards events when the source works', () async {
    final events = await guardedConnectivityStream(
      isLinux: true,
      nmAvailable: () async => true,
      source: () => Stream.fromIterable([
        [ConnectivityResult.wifi],
        [ConnectivityResult.none],
      ]),
    ).toList();
    expect(events, [
      [ConnectivityResult.wifi],
      [ConnectivityResult.none],
    ]);
  });

  test('source that throws on creation or emits errors never errors the stream', () async {
    expect(
      await guardedConnectivityStream(isLinux: false, source: () => throw StateError('no bus')).toList(),
      isEmpty,
    );
    final events = await guardedConnectivityStream(
      isLinux: false,
      source: () async* {
        yield [ConnectivityResult.ethernet];
        throw const FormatException('boom');
      },
    ).toList();
    expect(events, [
      [ConnectivityResult.ethernet],
    ]);
  });

  test('NetworkManager probe never throws', () async {
    expect(await networkManagerAvailable(timeout: const Duration(milliseconds: 50)), isA<bool>());
  });

  test('safeCheckConnectivity treats failures and missing NM as unknown (other)', () async {
    expect(await safeCheckConnectivity(isLinux: true, nmAvailable: () async => false), [ConnectivityResult.other]);
    expect(
      await safeCheckConnectivity(isLinux: false, check: () async => throw StateError('x')),
      [ConnectivityResult.other],
    );
    expect(
      await safeCheckConnectivity(isLinux: false, check: () async => [ConnectivityResult.wifi]),
      [ConnectivityResult.wifi],
    );
  });
}
