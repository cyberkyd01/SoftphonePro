import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Extracts the ICU argument names (including those nested inside plural /
/// select branches) used by a message.
Set<String> icuArgs(String msg) {
  final out = <String>{};
  var i = 0;

  // Parses literal text + arguments until an unmatched '}' (or end).
  void text() {
    while (i < msg.length) {
      final c = msg[i];
      if (c == "'") {
        if (i + 1 < msg.length && msg[i + 1] == "'") {
          i += 2;
        } else if (i + 1 < msg.length &&
            (msg[i + 1] == '{' || msg[i + 1] == '}')) {
          final end = msg.indexOf("'", i + 1);
          i = end < 0 ? msg.length : end + 1;
        } else {
          i++;
        }
      } else if (c == '}') {
        return;
      } else if (c == '{') {
        i++;
        final start = i;
        while (i < msg.length && msg[i] != '}' && msg[i] != ',') {
          i++;
        }
        out.add(msg.substring(start, i).trim());
        if (i < msg.length && msg[i] == ',') {
          // type, then (for plural/select) branches.
          i++;
          final tstart = i;
          while (i < msg.length && msg[i] != '}' && msg[i] != ',') {
            i++;
          }
          final type = msg.substring(tstart, i).trim();
          if (i < msg.length &&
              msg[i] == ',' &&
              (type == 'plural' || type == 'select')) {
            i++;
            while (i < msg.length && msg[i] != '}') {
              while (i < msg.length && msg[i].trim().isEmpty) {
                i++;
              }
              while (i < msg.length && msg[i] != '{' && msg[i] != '}') {
                i++;
              }
              if (i < msg.length && msg[i] == '{') {
                i++;
                text();
                if (i < msg.length && msg[i] == '}') i++;
              }
            }
          } else {
            while (i < msg.length && msg[i] != '}') {
              i++;
            }
          }
        }
        if (i < msg.length && msg[i] == '}') i++;
      } else {
        i++;
      }
    }
  }

  text();
  return out;
}

Map<String, dynamic> loadArb(File f) =>
    jsonDecode(f.readAsStringSync()) as Map<String, dynamic>;

void main() {
  final dir = Directory('lib/l10n');
  final files =
      dir
          .listSync()
          .whereType<File>()
          .where((f) => RegExp(r'app_[A-Za-z_]+\.arb$').hasMatch(f.path))
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path));
  final template = loadArb(File('lib/l10n/app_en.arb'));
  final keys = template.keys.where((k) => !k.startsWith('@')).toSet();

  const expectedLocales = {
    'ar',
    'de',
    'en',
    'es',
    'fr',
    'hi',
    'it',
    'ja',
    'nl',
    'pt',
    'pt_BR',
    'ru',
    'tr',
    'zh',
  };

  test('all supported languages have an ARB file', () {
    final found = {
      for (final f in files)
        RegExp(r'app_(.+)\.arb$').firstMatch(f.path)!.group(1)!,
    };
    expect(found, expectedLocales);
  });

  test('template documents every key', () {
    final undocumented = [
      for (final k in keys)
        if (template['@$k'] is! Map ||
            (template['@$k']['description'] as String? ?? '').trim().isEmpty)
          k,
    ];
    expect(undocumented, isEmpty, reason: 'keys without @description');
  });

  test('template placeholders are declared', () {
    final bad = <String>[];
    for (final k in keys) {
      final used = icuArgs(template[k] as String);
      final declared =
          ((template['@$k'] as Map)['placeholders'] as Map?)?.keys.toSet() ??
          <String>{};
      if (used.difference(declared).isNotEmpty ||
          declared.difference(used).isNotEmpty) {
        bad.add('$k used=$used declared=$declared');
      }
    }
    expect(bad, isEmpty);
  });

  for (final f in files) {
    final locale = RegExp(r'app_(.+)\.arb$').firstMatch(f.path)!.group(1)!;
    if (locale == 'en') continue;
    test('app_$locale.arb has exactly the template keys and placeholders', () {
      final arb = loadArb(f);
      expect(arb['@@locale'], locale);
      final own = arb.keys.where((k) => !k.startsWith('@')).toSet();
      expect(keys.difference(own), isEmpty, reason: 'missing keys');
      expect(own.difference(keys), isEmpty, reason: 'extra keys');
      final bad = <String>[];
      for (final k in keys) {
        final v = arb[k];
        if (v is! String || v.trim().isEmpty) {
          bad.add('$k: empty / not a string');
          continue;
        }
        final want = icuArgs(template[k] as String);
        final got = icuArgs(v);
        if (want.length != got.length || !want.containsAll(got)) {
          bad.add('$k: placeholders $got != $want');
        }
      }
      expect(bad, isEmpty);
    });
  }
}
