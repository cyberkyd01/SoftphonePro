/// Helpers that keep technical left-to-right strings (SIP URIs, phone
/// numbers, IP addresses, host:port, codec names) in their written order when
/// they are shown inside right-to-left text such as Arabic.
library;

/// Left-to-right isolate: LRI ... PDI (U+2066 / U+2069).
final String _lri = String.fromCharCode(0x2066);
final String _pdi = String.fromCharCode(0x2069);

final RegExp _rtlChar = RegExp(r'[֐-ࣿיִ-﷿ﹰ-﻿]');
final RegExp _technical = RegExp(r'[@:./\d]');

/// [s] forced to render left-to-right, whatever the surrounding direction.
String ltr(String s) => s.isEmpty || s.startsWith(_lri) ? s : '$_lri$s$_pdi';

/// [s] without the isolate marks (for comparisons, copying and tests).
String stripBidi(String s) => s.replaceAll(_lri, '').replaceAll(_pdi, '');

/// Isolates [s] when it looks technical (contains digits or `@ : . /`) and has
/// no right-to-left letters; plain names and RTL text pass through unchanged.
String bidiSafe(String s) =>
    s.isEmpty || _rtlChar.hasMatch(s) || !_technical.hasMatch(s) ? s : ltr(s);
