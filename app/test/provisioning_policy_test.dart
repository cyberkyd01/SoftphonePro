import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:softphonepro/models/account_profile.dart';
import 'package:softphonepro/models/app_settings.dart';
import 'package:softphonepro/services/dial_rules.dart';
import 'package:softphonepro/services/provisioning.dart';
import 'package:softphonepro/services/provisioning_import.dart';
import 'package:spcore_dart/spcore_dart.dart';

Set<String> _keysOf(Map<String, dynamic> m, String prefix) => {for (final k in m.keys) '$prefix$k'};

/// Every field path of an AccountProfile, read from the real classes.
Set<String> _accountProfileFields() {
  final p = AccountProfile(
    id: 'a',
    config: const AccountConfig(
      username: 'u',
      domain: 'd',
      tlsClientCert: TlsClientCert(certFile: 'c', keyFile: 'k'),
    ),
  );
  final j = p.toJson();
  final out = <String>{};
  for (final k in j.keys) {
    out.add(k);
    if (k == 'sip') continue;
    if (j[k] is Map) out.addAll(_keysOf(Map<String, dynamic>.from(j[k] as Map), '$k.'));
  }
  // AccountConfig keys (runtime) + every key literal of its toJson source.
  out.addAll(_keysOf(Map<String, dynamic>.from(j['sip'] as Map), 'sip.'));
  final src = File('../packages/spcore_dart/lib/src/models/account_models.dart').readAsStringSync();
  final start = src.indexOf('class AccountConfig');
  final from = src.indexOf('Map<String, dynamic> toJson() => {', start);
  final to = src.indexOf('};', from);
  for (final m in RegExp(r"^\s*(?:if \([^)]*\) )?'(\w+)':", multiLine: true).allMatches(src.substring(from, to))) {
    out.add('sip.${m.group(1)}');
  }
  return out;
}

void main() {
  group('account field policy (M3j)', () {
    final fields = _accountProfileFields();

    test('found a plausible number of fields', () {
      expect(fields.length, greaterThan(80));
      expect(fields, containsAll(['featureCodes.park', 'autoAnswer.enabled', 'forwarding.target', 'sip.tlsClientCert', 'sip.password']));
    });

    test('every AccountProfile / AccountConfig field is classified', () {
      final missing = fields.where((f) => !kAccountImportPolicy.containsKey(f)).toList()..sort();
      expect(missing, isEmpty, reason: 'classify in kAccountImportPolicy (allowed / flagged / validated / dropped): $missing');
    });

    test('the policy lists only real fields', () {
      final stale = kAccountImportPolicy.keys.where((k) => !fields.contains(k)).toList();
      expect(stale, isEmpty);
    });

    test('security-relevant fields', () {
      expect(classifyAccountField('sip.tlsClientCert'), AccountFieldPolicy.dropped);
      for (final k in ['autoAnswer', 'autoRecord', 'forwarding', 'featureCodes']) {
        expect(classifyAccountField(k), AccountFieldPolicy.flagged, reason: k);
      }
      for (final k in ['ringtone', 'holdMusic', 'openingAnnouncement']) {
        expect(classifyAccountField(k), AccountFieldPolicy.validated, reason: k);
      }
      expect(classifyAccountField('someFutureField'), AccountFieldPolicy.dropped);
      expect(classifyAccountField('sip.someFutureField'), AccountFieldPolicy.dropped);
    });

    test('the sanitiser drops what the policy drops (client cert), keeps the rest', () {
      final r = Provisioning.parse(jsonEncode({
        'version': 1,
        'accounts': [
          {
            'label': 'X',
            'sip': {
              'username': 'u',
              'password': 'pw',
              'domain': 'd',
              'registrar': 'sip:r.test',
              'tlsClientCert': {'certFile': '/c', 'keyFile': '/k'},
            },
          },
        ],
        'settings': {},
      }));
      final p = prepareUntrustedImport(r);
      final a = p.accounts.single;
      expect(a.config.tlsClientCert, isNull);
      expect(p.ignored, ['accounts[0].tlsClientCert']);
      expect(a.config.password, 'pw');
      expect(a.config.registrar, 'sip:r.test');
      expect(a.label, 'X');
    });
  });

  group('nested value validation (M3k)', () {
    List<String> ignoredOf(Map<String, dynamic> s) => prepareUntrustedImport(ProvisioningResult(settings: s)).ignored;
    Map<String, dynamic> safeOf(Map<String, dynamic> s) => prepareUntrustedImport(ProvisioningResult(settings: s)).safeSettings;

    test('speedDial: malformed slots dropped, valid kept', () {
      final s = {
        'speedDial': {
          '1': {'number': 5},
          '2': {'number': '100', 'label': 7},
          '3': 'x',
          '4': {'number': '200', 'label': 'ok', 'accountId': 'a'},
          'zz': {'number': '1'},
        },
      };
      expect(safeOf(s)['speedDial'], {
        '4': {'number': '200', 'label': 'ok', 'accountId': 'a'},
      });
      expect(ignoredOf(s), containsAll(['speedDial.1', 'speedDial.2', 'speedDial.3', 'speedDial.zz']));
      final only = {
        'speedDial': {
          '1': {'number': 5},
        },
      };
      expect(safeOf(only), isEmpty);
      expect(ignoredOf(only), containsAll(['speedDial.1', 'speedDial']));
    });

    test('dialRules: non-string fields dropped', () {
      final s = {
        'dialRules': [
          {'pattern': 5},
          {'pattern': r'0(\d+)', 'replacement': 3},
          {'pattern': r'0(\d+)', 'enabled': 'yes'},
          {'pattern': r'0(\d+)', 'replacement': r'+44$1', 'id': 'r1'},
          'junk',
        ],
      };
      expect(safeOf(s)['dialRules'], [
        {'pattern': r'0(\d+)', 'replacement': r'+44$1', 'id': 'r1'},
      ]);
      expect(ignoredOf(s), containsAll(['dialRules[0]', 'dialRules[1]', 'dialRules[2]', 'dialRules[4]']));
    });

    test('blocklist / emergencyNumbers: non-string entries dropped', () {
      final s = {
        'blocklist': ['100', 5, null, ['x']],
        'emergencyNumbers': [112, 999],
      };
      expect(safeOf(s)['blocklist'], ['100']);
      expect(safeOf(s).containsKey('emergencyNumbers'), isFalse); // all invalid: not blanked
      expect(ignoredOf(s), containsAll(['blocklist[1]', 'blocklist[2]', 'blocklist[3]', 'emergencyNumbers']));
    });

    test('hotkeys is not importable at all', () {
      expect(ignoredOf({'hotkeys': {'answer': 5}}), ['hotkeys']);
    });
  });

  group('tolerant stored settings (M3k)', () {
    final bad = AppSettings.fromJson({
      'speedDial': {
        '1': {'number': 5},
        '2': {'number': '100', 'label': 9, 'accountId': 3},
        '3': 'x',
        '4': null,
        '5': {'number': '555', 'label': 'five'},
        7: {'number': '7'},
      },
      'dialRules': [
        {'id': 1, 'pattern': 2, 'replacement': 3, 'name': [], 'accountId': {}, 'enabled': 'x'},
        'junk',
        null,
        {5: 'x'},
        {'id': 'ok', 'pattern': '1', 'replacement': '2'},
      ],
      'blocklist': [1, null, {}, 'x'],
      'emergencyNumbers': 'notalist',
      'hotkeys': {'a': 1, 2: 'b', 'c': 'd'},
    });

    test('no getter throws; invalid entries are skipped', () {
      expect(bad.speedDial.keys.toList()..sort(), [2, 5, 7]); // slot 2: bad label/accountId take defaults
      expect(bad.speedDial[5]!.label, 'five');
      expect(bad.dialRules.length, 2); // the junk-field map and the valid one
      expect([for (final r in bad.dialRules) DialRule.fromJson(r)].last.id, 'ok');
      final first = DialRule.fromJson(bad.dialRules.first);
      expect(first.pattern, '');
      expect(first.replacement, r'$0');
      expect(first.enabled, isTrue);
      expect(bad.blocklist, isA<List<String>>());
      expect(bad.emergencyNumbers, ['911', '112', '999', '000']);
      expect(bad.hotkeys, {'c': 'd'});
      expect(DialRules(rules: [for (final r in bad.dialRules) DialRule.fromJson(r)], emergencyNumbers: bad.emergencyNumbers).apply('12345').target, isNotEmpty);
    });

    test('whole settings of the wrong shapes load', () {
      final s = AppSettings.fromJson({'speedDial': 5, 'dialRules': 'x', 'hotkeys': [], 'blocklist': 3});
      expect(s.speedDial, isEmpty);
      expect(s.dialRules, isEmpty);
      expect(s.hotkeys, isEmpty);
      expect(s.blocklist, isEmpty);
    });

    test('SpeedDialEntry / DialRule fromJson never throw', () {
      expect(SpeedDialEntry.fromJson({'number': 5, 'label': 1, 'accountId': 2}).number, '');
      expect(DialRule.fromJson({'id': 1, 'pattern': 1, 'enabled': 1}).pattern, '');
    });

    test('malformed values survive an untrusted import round trip', () {
      final p = prepareUntrustedImport(const ProvisioningResult(settings: {
        'speedDial': {'1': {'number': 5}, '2': {'number': '9'}},
        'dialRules': [{'pattern': 1}],
      }));
      final s = AppSettings.fromJson(p.safeSettings);
      expect(s.speedDial.keys, [2]);
      expect(s.dialRules, isEmpty);
    });
  });
}
