import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:softphonepro/ui/widgets/qr_payload.dart';
import 'package:softphonepro/ui/widgets/qr_scanner_sheet.dart';

void main() {
  group('parseQrPayload', () {
    test('provisioning JSON', () {
      expect(parseQrPayload('  {"accounts":[]}'), isA<QrProvisionJson>());
    });
    test('provision link variants', () {
      final u = parseQrPayload('softphonepro://provision?url=${Uri.encodeComponent('https://pbx.test/p.json')}');
      expect((u as QrProvisionUrl).url.host, 'pbx.test');
      final d = parseQrPayload('softphonepro://provision?data=${Uri.encodeComponent('{"a":1}')}');
      expect((d as QrProvisionJson).json, '{"a":1}');
      final b = parseQrPayload('softphonepro://provision?b64=${base64Url.encode(utf8.encode('{"b":2}'))}');
      expect((b as QrProvisionJson).json, '{"b":2}');
      expect(parseQrPayload('softphonepro://provision?url=ftp://x'), isA<QrUnknown>());
    });
    test('url, lan and unknown', () {
      expect(parseQrPayload('https://x.org/cfg'), isA<QrProvisionUrl>());
      expect(parseQrPayload('softphonepro://lan?h=1.2.3.4&p=4711&id=a&n=b'), isA<QrLan>());
      expect(parseQrPayload('192.168.1.20:4711'), isA<QrLan>());
      expect(parseQrPayload('hello world'), isA<QrUnknown>());
      expect(parseQrPayload(''), isA<QrUnknown>());
    });
  });

  testWidgets('paste fallback returns trimmed text; no camera shown when unsupported', (tester) async {
    String? got;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (ctx) => TextButton(
            onPressed: () async => got = await showQrScannerSheet(ctx, cameraSupported: false),
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('qr-camera')), findsNothing);
    expect(find.byKey(const Key('qr-no-camera')), findsOneWidget);
    await tester.enterText(find.byKey(const Key('qr-paste-field')), '  softphonepro://lan?h=1.1.1.1&p=1&id=x&n=y \n');
    await tester.tap(find.byKey(const Key('qr-use-text')));
    await tester.pumpAndSettle();
    expect(got, 'softphonepro://lan?h=1.1.1.1&p=1&id=x&n=y');
    expect(parseQrPayload(got!), isA<QrLan>());
  });

  testWidgets('camera detection closes the sheet with the code (once)', (tester) async {
    String? got;
    ValueChanged<String>? emit;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (ctx) => TextButton(
            onPressed: () async => got = await showQrScannerSheet(
              ctx,
              cameraSupported: true,
              cameraBuilder: (c, onCode) {
                emit = onCode;
                return const SizedBox();
              },
            ),
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('qr-camera')), findsOneWidget);
    emit!('{"accounts":[]}');
    emit!('ignored');
    await tester.pumpAndSettle();
    expect(got, '{"accounts":[]}');
  });
}
