import 'package:flutter_test/flutter_test.dart';
import 'package:softphonepro/services/dial_rules.dart';

void main() {
  group('DialRules.clean', () {
    test('strips separators', () {
      expect(DialRules.clean('+1 (555) 010-2030'), '+15550102030');
      expect(DialRules.clean(' 555.010.2030 '), '5550102030');
    });
    test('keeps star codes and hashes', () {
      expect(DialRules.clean('*72 5551234#'), '*725551234#');
    });
    test('keeps URIs untouched', () {
      expect(DialRules.clean('sip:alice@example.com'), 'sip:alice@example.com');
    });
  });

  group('DialRules.apply', () {
    test('plain number passes through cleaned', () {
      expect(const DialRules().apply('(555) 123-4567').target, '5551234567');
    });

    test('URIs are not rewritten', () {
      final r = DialRules(rules: [const DialRule(id: '1', pattern: r'.*', replacement: 'X')]).apply('sip:bob@x.org');
      expect(r.target, 'sip:bob@x.org');
      expect(r.isUri, isTrue);
    });

    test('tel: prefix is stripped', () {
      expect(const DialRules().apply('tel:+49 30 1234').target, '+49301234');
    });

    test('plus replacement', () {
      expect(const DialRules(plusReplacement: '00').apply('+44 20 7946 0958').target, '00442079460958');
    });

    test('regex rule rewrites with groups', () {
      const rules = DialRules(rules: [DialRule(id: 'a', pattern: r'0(\d{9})', replacement: r'+49$1')]);
      final r = rules.apply('0301234567');
      expect(r.target, '+49301234567');
      expect(r.ruleId, 'a');
    });

    test('first matching rule wins and disabled rules are skipped', () {
      const rules = DialRules(rules: [
        DialRule(id: 'off', pattern: r'\d+', replacement: 'no', enabled: false),
        DialRule(id: 'one', pattern: r'(\d{3})', replacement: r'ext$1'),
        DialRule(id: 'two', pattern: r'\d{3}', replacement: 'never'),
      ]);
      expect(rules.apply('204').target, 'ext204');
    });

    test('per-account routing', () {
      const rules = DialRules(rules: [DialRule(id: 'r', pattern: r'00(\d+)', replacement: r'+$1', accountId: 'acc-intl')]);
      final r = rules.apply('0044123');
      expect(r.target, '+44123');
      expect(r.accountId, 'acc-intl');
    });

    test('emergency numbers bypass rules', () {
      const rules = DialRules(rules: [DialRule(id: 'r', pattern: r'\d+', replacement: r'9$0')]);
      final r = rules.apply('112');
      expect(r.target, '112');
      expect(r.emergency, isTrue);
    });

    test('invalid regex is ignored', () {
      const rules = DialRules(rules: [DialRule(id: 'bad', pattern: '(', replacement: 'x')]);
      expect(rules.apply('123').target, '123');
      expect(DialRules.validatePattern('('), isNotNull);
      expect(DialRules.validatePattern(r'\d+'), isNull);
    });

    test('strip prefix', () {
      expect(const DialRules(stripPrefix: '9').apply('95551234').target, '5551234');
      expect(const DialRules(stripPrefix: '9').apply('911').target, '911');
    });

    test('empty input', () {
      expect(const DialRules().apply('  ').target, '');
    });
  });
}
