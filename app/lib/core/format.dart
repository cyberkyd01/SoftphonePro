import 'package:intl/intl.dart';

String formatDuration(Duration d) {
  final h = d.inHours;
  final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
  final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
  return h > 0 ? '$h:$m:$s' : '$m:$s';
}

String formatMs(int ms) => formatDuration(Duration(milliseconds: ms));

String initialsOf(String name) {
  final parts = name
      .trim()
      .split(RegExp(r'\s+'))
      .where((e) => e.isNotEmpty)
      .toList();
  if (parts.isEmpty) return '#';
  if (parts.length == 1) {
    final p = parts.first;
    final c = p.runes.first;
    final ch = String.fromCharCode(c);
    return RegExp(r'[A-Za-z]').hasMatch(ch) ? ch.toUpperCase() : '#';
  }
  return (parts.first[0] + parts.last[0]).toUpperCase();
}

const List<int> kAvatarPalette = [
  0xFF3F51E0,
  0xFF0EA5E9,
  0xFF14B8A6,
  0xFF16A34A,
  0xFFD97706,
  0xFFDB2777,
  0xFF9333EA,
  0xFF64748B,
  0xFFDC2626,
];

int hashColor(String seed) {
  var h = 0;
  for (final c in seed.codeUnits) {
    h = (h * 31 + c) & 0x7fffffff;
  }
  return kAvatarPalette[h % kAvatarPalette.length];
}

String dayLabel(DateTime t, [DateTime? now]) {
  now ??= DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final d = DateTime(t.year, t.month, t.day);
  final diff = today.difference(d).inDays;
  if (diff == 0) return 'Today';
  if (diff == 1) return 'Yesterday';
  if (diff < 7) return DateFormat('EEEE').format(t);
  return DateFormat.yMMMd().format(t);
}

String timeLabel(DateTime t) => DateFormat.jm().format(t);

/// `sip:1002@pbx` -> `1002`; `"Bob" <sip:bob@x>` -> `bob`.
String userPart(String uri) {
  var s = uri.trim();
  final lt = s.indexOf('<');
  final gt = s.indexOf('>');
  if (lt >= 0 && gt > lt) s = s.substring(lt + 1, gt);
  s = s.replaceFirst(RegExp(r'^(sips?|tel):', caseSensitive: false), '');
  final semi = s.indexOf(';');
  if (semi >= 0) s = s.substring(0, semi);
  final at = s.indexOf('@');
  return at >= 0 ? s.substring(0, at) : s;
}

String hostPart(String uri) {
  var s = uri.trim();
  final lt = s.indexOf('<');
  final gt = s.indexOf('>');
  if (lt >= 0 && gt > lt) s = s.substring(lt + 1, gt);
  s = s.replaceFirst(RegExp(r'^(sips?|tel):', caseSensitive: false), '');
  final semi = s.indexOf(';');
  if (semi >= 0) s = s.substring(0, semi);
  final at = s.indexOf('@');
  return at >= 0 ? s.substring(at + 1) : '';
}

/// Digits only (keeps a leading `+`), for number comparison.
String digitsOf(String s) => s.replaceAll(RegExp(r'[^0-9]'), '');

bool sameNumber(String a, String b) {
  final da = digitsOf(userPart(a));
  final db = digitsOf(userPart(b));
  if (da.isEmpty || db.isEmpty) return userPart(a) == userPart(b);
  if (da == db) return true;
  final n = da.length < db.length ? da.length : db.length;
  return n >= 7 && da.substring(da.length - n) == db.substring(db.length - n);
}

/// T9 key for a letter.
String t9Digit(String ch) {
  const map = {
    'abc': '2',
    'def': '3',
    'ghi': '4',
    'jkl': '5',
    'mno': '6',
    'pqrs': '7',
    'tuv': '8',
    'wxyz': '9',
  };
  final c = ch.toLowerCase();
  for (final e in map.entries) {
    if (e.key.contains(c)) return e.value;
  }
  return RegExp(r'[0-9]').hasMatch(c) ? c : '';
}

String t9Of(String name) => name.split('').map(t9Digit).join();
