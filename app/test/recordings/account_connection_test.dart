import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sembast/sembast.dart';
import 'package:softphonepro/app.dart';
import 'package:softphonepro/services/accounts_controller.dart';
import 'package:softphonepro/ui/router.dart';
import 'package:softphonepro/ui/settings/tls_client_cert_group.dart';
import 'package:spcore_dart/spcore_dart.dart';

import '../harness.dart';

class CfgEng extends FakeSipEngine {
  CfgEng() : super(timings: FakeTimings.instant);
  final List<AccountConfig> configs = [];
  @override
  Future<int> addAccount(AccountConfig config) {
    configs.add(config);
    return super.addAccount(config);
  }

  @override
  Future<void> modifyAccount(AccountRef acc, AccountConfig config) {
    configs.add(config);
    return super.modifyAccount(acc, config);
  }
}

Future<TestEnv> boot(WidgetTester tester, {AccTransport transport = AccTransport.tls, AccTransport resolved = AccTransport.tls, List<String> picks = const []}) async {
  final eng = CfgEng()..autoTransportResult = resolved;
  final p = testProfile();
  final env = await TestEnv.create(profiles: [p.copyWith(config: p.config.copyWith(transport: transport))], engine: eng);
  tester.view.physicalSize = const Size(900, 6000) * 2;
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.reset);
  final queue = [...picks];
  await tester.pumpWidget(
    ProviderScope(
      overrides: [...env.overrides, tlsFilePickerProvider.overrideWithValue((title) async => queue.isEmpty ? null : queue.removeAt(0))],
      child: const SoftphoneApp(),
    ),
  );
  await settle(tester, env.engine);
  await waitRegistered(tester, env);
  containerOf(tester).read(routerProvider).push('/settings/accounts/acc1');
  await tester.pumpAndSettle();
  return env;
}

void main() {
  testWidgets('transport picker offers "Automatic (DNS SRV)" with a hint; saved as auto', (tester) async {
    final env = await boot(tester, transport: AccTransport.udp);
    expect(find.byKey(const Key('acc-transport')), findsOneWidget);
    await tester.tap(find.descendant(of: find.byKey(const Key('acc-transport')), matching: find.byType(DropdownButton<AccTransport>)));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Automatic (DNS SRV)').last);
    await tester.pumpAndSettle();
    expect(find.textContaining('DNS SRV records'), findsOneWidget);
    await tester.tap(find.byKey(const Key('save-account')));
    await tester.pumpAndSettle();
    await settle(tester, env.engine);
    final saved = containerOf(tester).read(accountsProvider).byId('acc1')!;
    expect(saved.config.transport, AccTransport.auto);
    expect((env.engine as CfgEng).configs.last.transport, AccTransport.auto);
  });

  testWidgets('account status sheet shows the server DNS resolved for transport auto', (tester) async {
    final env = await boot(tester, transport: AccTransport.auto, resolved: AccTransport.tls);
    containerOf(tester).read(routerProvider).go('/settings/accounts');
    await tester.pumpAndSettle();
    expect(env.engine, isNotNull);
    // Open the sheet from the account chip on the keypad.
    containerOf(tester).read(routerProvider).go('/keypad');
    await tester.pumpAndSettle();
    await settle(tester, env.engine);
    await tester.tap(find.text('1001@pbx.test').first);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('acc-resolved-server')), findsOneWidget);
    expect(find.text('pbx.test:5061'), findsOneWidget);
    expect(find.text('TLS'), findsOneWidget);
  });

  testWidgets('client certificate: files + key password reach the engine; password lives in the secrets store only', (tester) async {
    final env = await boot(tester, picks: ['/certs/client.pem', '/certs/client.key']);
    expect(find.text('CLIENT CERTIFICATE (MUTUAL TLS)'), findsOneWidget);
    await tester.tap(find.descendant(of: find.byKey(const Key('acc-tls-cert')), matching: find.text('Choose...')));
    await tester.pumpAndSettle();
    await tester.tap(find.descendant(of: find.byKey(const Key('acc-tls-key')), matching: find.text('Choose...')));
    await tester.pumpAndSettle();
    expect(find.text('client.pem'), findsOneWidget);
    expect(find.text('client.key'), findsOneWidget);
    await tester.tap(find.byKey(const Key('acc-tls-key-password')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 's3cret');
    await tester.tap(find.text('Save').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('save-account')));
    await tester.pumpAndSettle();
    await settle(tester, env.engine);
    await settle(tester, env.engine);

    final cert = containerOf(tester).read(accountsProvider).byId('acc1')!.config.tlsClientCert!;
    expect((cert.certFile, cert.keyFile, cert.password), ('/certs/client.pem', '/certs/client.key', 's3cret'));
    final sent = (env.engine as CfgEng).configs.last.tlsClientCert!;
    expect((sent.certFile, sent.keyFile, sent.password), ('/certs/client.pem', '/certs/client.key', 's3cret'));
    expect(env.secrets.data.values, contains('s3cret'));
    // Not in the database record.
    final stored = await tester.runAsync(() async => (await stringMapStoreFactory.store('accounts').find(env.db.db)).map((r) => '${r.value}').join('|'));
    expect(stored, isNot(contains('s3cret')));
    expect(stored, contains('/certs/client.pem'));
  });

  testWidgets('an incomplete certificate (no key) is not sent to the engine', (tester) async {
    final env = await boot(tester, picks: ['/certs/client.pem']);
    await tester.tap(find.descendant(of: find.byKey(const Key('acc-tls-cert')), matching: find.text('Choose...')));
    await tester.pumpAndSettle();
    expect(find.textContaining('Choose both a certificate and its private key'), findsOneWidget);
    await tester.tap(find.byKey(const Key('save-account')));
    await tester.pumpAndSettle();
    await settle(tester, env.engine);
    await settle(tester, env.engine);
    expect(containerOf(tester).read(accountsProvider).byId('acc1')!.config.tlsClientCert?.certFile, '/certs/client.pem');
    expect((env.engine as CfgEng).configs.last.tlsClientCert, isNull);
    expect(containerOf(tester).read(accountsProvider).statusOf('acc1'), AccountStatus.registered);
  });

  testWidgets('UDP accounts do not show the client certificate group', (tester) async {
    await boot(tester, transport: AccTransport.udp);
    expect(find.text('CLIENT CERTIFICATE (MUTUAL TLS)'), findsNothing);
  });

  test('withTlsClientCert sets and clears the certificate', () {
    const c = AccountConfig(uid: 'a', username: 'u', password: 'p', domain: 'd');
    final set = withTlsClientCert(c, const TlsClientCert(certFile: 'a', keyFile: 'b', password: 'x'));
    expect(set.tlsClientCert?.keyFile, 'b');
    expect(withTlsClientCert(set, null).tlsClientCert, isNull);
    expect(withTlsClientCert(set, const TlsClientCert()).tlsClientCert, isNull);
    expect(tlsClientCertComplete(set.tlsClientCert), isTrue);
    expect(tlsClientCertComplete(const TlsClientCert(certFile: 'a')), isFalse);
    expect(engineConfigOf(withTlsClientCert(c, const TlsClientCert(certFile: 'a'))).tlsClientCert, isNull);
  });
}

