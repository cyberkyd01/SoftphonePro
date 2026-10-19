import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:softphonepro/models/contact.dart';
import 'package:softphonepro/platform/android/android_platform_services.dart';
import 'package:softphonepro/platform/ios/ios_platform_services.dart';
import 'package:softphonepro/services/device_contacts.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('planDeviceImport', () {
    var n = 0;
    String id() => 'new${n++}';
    const existing = [
      Contact(id: 'a', name: 'Alice', numbers: [ContactNumber(value: '+1 (555) 123-4567')]),
    ];

    test('adds new, skips duplicates by normalised number', () {
      final plan = planDeviceImport(existing, const [
        DeviceContact(id: '1', name: 'Alice Dup', numbers: [('mobile', '555-123-4567')]),
        DeviceContact(id: '2', name: 'Bob', numbers: [('home', '555 000 1111')], emails: ['b@x.org']),
        DeviceContact(id: '3', name: 'NoPhone', numbers: [], emails: ['n@x.org']),
      ], newId: id);
      expect(plan.added.map((c) => c.name), ['Bob']);
      expect(plan.added.single.email, 'b@x.org');
      expect(plan.updated, isEmpty);
      expect(plan.skipped, 2);
    });

    test('merges extra numbers and email into the matching contact', () {
      final plan = planDeviceImport(existing, const [
        DeviceContact(
          id: '1',
          name: 'Alice',
          numbers: [('mobile', '5551234567'), ('work', '555 777 8888')],
          emails: ['a@x.org'],
        ),
      ], newId: id);
      expect(plan.added, isEmpty);
      final u = plan.updated.single;
      expect(u.id, 'a');
      expect(u.numbers.map((e) => e.value), ['+1 (555) 123-4567', '555 777 8888']);
      expect(u.email, 'a@x.org');
    });

    test('dedupes within the incoming list', () {
      final plan = planDeviceImport(const [], const [
        DeviceContact(id: '1', name: 'Carl', numbers: [('mobile', '5559990000')]),
        DeviceContact(id: '2', name: 'Carl 2', numbers: [('mobile', '555-999-0000'), ('work', '5551112222')]),
      ], newId: id);
      expect(plan.added, hasLength(1));
      expect(plan.added.single.numbers, hasLength(2));
      expect(plan.updated, isEmpty);
    });
  });

  test('iOS channel: permission + read', () async {
    const ch = MethodChannel('softphonepro/platform');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(ch, (call) async {
      if (call.method == 'requestContactsPermission') return 'granted';
      if (call.method == 'readContacts') {
        return [
          {
            'id': 'x',
            'name': 'Zed',
            'numbers': [
              {'label': 'mobile', 'number': '123'},
            ],
            'emails': ['z@x.org'],
          },
        ];
      }
      return null;
    });
    final p = IosPlatformServices();
    expect(await p.requestContactsPermission(), isTrue);
    final l = await p.readDeviceContacts();
    expect(l.single.name, 'Zed');
    expect(l.single.numbers.single, ('mobile', '123'));
    expect(l.single.emails, ['z@x.org']);
  });

  test('macOS channel: denied and read', () async {
    const ch = MethodChannel('softphonepro/desktop');
    var perm = 'permanentlyDenied';
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(ch, (call) async {
      if (call.method == 'requestContactsPermission') return perm;
      if (call.method == 'readContacts') {
        return [
          {'id': '1', 'name': 'M', 'numbers': [], 'emails': ['m@x.org']},
        ];
      }
      return null;
    });
    final s = MacosContactsSource(ch);
    expect(await s.requestPermission(), isFalse);
    perm = 'granted';
    expect(await s.requestPermission(), isTrue);
    expect((await s.read()).single.emails, ['m@x.org']);
  });
}
