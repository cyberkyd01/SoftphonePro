import 'package:uuid/uuid.dart';

import '../models/contact.dart';

/// vCard 3.0 and CSV import/export for contacts (pure Dart).
class ContactIo {
  static const _uuid = Uuid();

  static String _esc(String s) => s
      .replaceAll(r'\', r'\\')
      .replaceAll('\n', r'\n')
      .replaceAll(',', r'\,')
      .replaceAll(';', r'\;');
  static String _unesc(String s) => s
      .replaceAll(r'\n', '\n')
      .replaceAll(r'\,', ',')
      .replaceAll(r'\;', ';')
      .replaceAll(r'\\', r'\');

  static String toVCard(Iterable<Contact> contacts) {
    final b = StringBuffer();
    for (final c in contacts) {
      b.writeln('BEGIN:VCARD');
      b.writeln('VERSION:3.0');
      b.writeln('FN:${_esc(c.name)}');
      b.writeln('N:${_esc(c.name)};;;;');
      if (c.company.isNotEmpty) b.writeln('ORG:${_esc(c.company)}');
      for (final n in c.numbers) {
        b.writeln('TEL;TYPE=${n.label.toUpperCase()}:${n.value}');
      }
      for (final u in c.sipUris) {
        b.writeln('IMPP;X-SERVICE-TYPE=SIP:$u');
      }
      if (c.email.isNotEmpty) b.writeln('EMAIL:${c.email}');
      if (c.notes.isNotEmpty) b.writeln('NOTE:${_esc(c.notes)}');
      b.writeln('END:VCARD');
    }
    return b.toString();
  }

  static List<Contact> fromVCard(String text) {
    // Unfold continuation lines.
    final lines = text
        .replaceAll('\r\n', '\n')
        .replaceAll(RegExp(r'\n[ \t]'), '')
        .split('\n');
    final out = <Contact>[];
    Map<String, dynamic>? cur;
    for (final raw in lines) {
      final line = raw.trim();
      if (line.isEmpty) continue;
      final up = line.toUpperCase();
      if (up == 'BEGIN:VCARD') {
        cur = {
          'name': '',
          'company': '',
          'email': '',
          'notes': '',
          'numbers': <ContactNumber>[],
          'sip': <String>[],
        };
        continue;
      }
      if (up == 'END:VCARD') {
        if (cur != null) {
          final nums = cur['numbers'] as List<ContactNumber>;
          final sip = cur['sip'] as List<String>;
          var name = cur['name'] as String;
          if (name.isEmpty) name = (cur['company'] as String);
          if (name.isNotEmpty || nums.isNotEmpty || sip.isNotEmpty) {
            out.add(
              Contact(
                id: _uuid.v4(),
                name: name,
                company: cur['company'] as String,
                email: cur['email'] as String,
                notes: cur['notes'] as String,
                numbers: nums,
                sipUris: sip,
              ),
            );
          }
        }
        cur = null;
        continue;
      }
      if (cur == null) continue;
      final colon = line.indexOf(':');
      if (colon < 0) continue;
      final head = line.substring(0, colon).toUpperCase();
      final val = line.substring(colon + 1);
      final key = head.split(';').first;
      switch (key) {
        case 'FN':
          cur['name'] = _unesc(val);
        case 'N':
          if ((cur['name'] as String).isEmpty) {
            final p = val.split(';');
            cur['name'] = _unesc(
              [if (p.length > 1) p[1], p[0]].where((e) => e.isNotEmpty).join(' '),
            );
          }
        case 'ORG':
          cur['company'] = _unesc(val.split(';').first);
        case 'TEL':
          var label = 'other';
          final m = RegExp(r'TYPE=([A-Z]+)').firstMatch(head);
          if (m != null) label = m[1]!.toLowerCase();
          (cur['numbers'] as List<ContactNumber>).add(
            ContactNumber(label: label, value: val.trim()),
          );
        case 'IMPP':
        case 'X-SIP':
          (cur['sip'] as List<String>).add(
            val.trim().replaceFirst(RegExp(r'^sip:', caseSensitive: false), 'sip:'),
          );
        case 'EMAIL':
          cur['email'] = val.trim();
        case 'NOTE':
          cur['notes'] = _unesc(val);
      }
    }
    return out;
  }

  static const _csvHeader = [
    'name',
    'company',
    'mobile',
    'work',
    'home',
    'sip',
    'email',
    'notes',
    'favorite',
  ];

  static String _csvCell(String s) =>
      s.contains(RegExp(r'[",\n]')) ? '"${s.replaceAll('"', '""')}"' : s;

  static String toCsv(Iterable<Contact> contacts) {
    final b = StringBuffer()..writeln(_csvHeader.join(','));
    for (final c in contacts) {
      String num(String label) => c.numbers
          .where((n) => n.label == label)
          .map((n) => n.value)
          .join(' ');
      final others = c.numbers
          .where((n) => !['mobile', 'work', 'home'].contains(n.label))
          .map((n) => n.value);
      final row = [
        c.name,
        c.company,
        [num('mobile'), ...others].where((e) => e.isNotEmpty).join(' '),
        num('work'),
        num('home'),
        c.sipUris.join(' '),
        c.email,
        c.notes,
        c.favorite ? '1' : '0',
      ];
      b.writeln(row.map(_csvCell).join(','));
    }
    return b.toString();
  }

  static List<List<String>> _parseCsv(String text) {
    final rows = <List<String>>[];
    var row = <String>[];
    final cell = StringBuffer();
    var inQ = false;
    final s = text.replaceAll('\r\n', '\n');
    for (var i = 0; i < s.length; i++) {
      final ch = s[i];
      if (inQ) {
        if (ch == '"') {
          if (i + 1 < s.length && s[i + 1] == '"') {
            cell.write('"');
            i++;
          } else {
            inQ = false;
          }
        } else {
          cell.write(ch);
        }
      } else if (ch == '"') {
        inQ = true;
      } else if (ch == ',') {
        row.add(cell.toString());
        cell.clear();
      } else if (ch == '\n') {
        row.add(cell.toString());
        cell.clear();
        rows.add(row);
        row = <String>[];
      } else {
        cell.write(ch);
      }
    }
    if (cell.isNotEmpty || row.isNotEmpty) {
      row.add(cell.toString());
      rows.add(row);
    }
    return rows.where((r) => r.any((c) => c.trim().isNotEmpty)).toList();
  }

  static List<Contact> fromCsv(String text) {
    final rows = _parseCsv(text);
    if (rows.length < 2) return const [];
    final head = [for (final h in rows.first) h.trim().toLowerCase()];
    int idx(List<String> names) {
      for (final n in names) {
        final i = head.indexOf(n);
        if (i >= 0) return i;
      }
      return -1;
    }

    String at(List<String> r, int i) => i >= 0 && i < r.length ? r[i].trim() : '';
    final iName = idx(['name', 'full name', 'display name']);
    final iFirst = idx(['first name', 'firstname', 'given name']);
    final iLast = idx(['last name', 'lastname', 'family name']);
    final iCompany = idx(['company', 'organization']);
    final iMobile = idx(['mobile', 'phone', 'cell', 'phone 1 - value', 'number']);
    final iWork = idx(['work', 'business phone']);
    final iHome = idx(['home', 'home phone']);
    final iSip = idx(['sip', 'sip uri', 'impp']);
    final iEmail = idx(['email', 'e-mail', 'e-mail address']);
    final iNotes = idx(['notes', 'note']);
    final iFav = idx(['favorite', 'favourite', 'starred']);
    final out = <Contact>[];
    for (final r in rows.skip(1)) {
      var name = at(r, iName);
      if (name.isEmpty) {
        name = [at(r, iFirst), at(r, iLast)].where((e) => e.isNotEmpty).join(' ');
      }
      final nums = <ContactNumber>[];
      void addNums(String label, String v) {
        for (final p in v.split(RegExp(r'\s+|;'))) {
          if (p.isNotEmpty) nums.add(ContactNumber(label: label, value: p));
        }
      }

      addNums('mobile', at(r, iMobile));
      addNums('work', at(r, iWork));
      addNums('home', at(r, iHome));
      final sip = at(r, iSip).split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
      if (name.isEmpty && nums.isEmpty && sip.isEmpty) continue;
      out.add(
        Contact(
          id: _uuid.v4(),
          name: name,
          company: at(r, iCompany),
          numbers: nums,
          sipUris: sip,
          email: at(r, iEmail),
          notes: at(r, iNotes),
          favorite: ['1', 'true', 'yes'].contains(at(r, iFav).toLowerCase()),
        ),
      );
    }
    return out;
  }
}
