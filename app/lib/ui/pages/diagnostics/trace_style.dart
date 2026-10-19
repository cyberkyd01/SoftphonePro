import 'package:flutter/material.dart';

import '../../../diagnostics/sip_message.dart';

const String kMono = 'monospace';

/// Colour for a SIP message: by method for requests, by class for responses.
Color sipColor(SipMessage m, BuildContext context) {
  final dark = Theme.of(context).brightness == Brightness.dark;
  if (!m.valid) return Theme.of(context).colorScheme.onSurfaceVariant;
  if (m.isResponse) {
    final s = m.status;
    if (s < 200) return dark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280);
    if (s < 300) return dark ? const Color(0xFF4ADE80) : const Color(0xFF15803D);
    if (s < 400) return dark ? const Color(0xFF60A5FA) : const Color(0xFF1D4ED8);
    if (s < 500) return dark ? const Color(0xFFFBBF24) : const Color(0xFFB45309);
    return dark ? const Color(0xFFF87171) : const Color(0xFFB91C1C);
  }
  switch (m.method) {
    case 'INVITE':
    case 'UPDATE':
      return dark ? const Color(0xFF38BDF8) : const Color(0xFF0369A1);
    case 'ACK':
    case 'PRACK':
      return dark ? const Color(0xFF2DD4BF) : const Color(0xFF0F766E);
    case 'BYE':
    case 'CANCEL':
      return dark ? const Color(0xFFFB923C) : const Color(0xFFC2410C);
    case 'REGISTER':
      return dark ? const Color(0xFFC084FC) : const Color(0xFF7E22CE);
    case 'OPTIONS':
      return dark ? const Color(0xFF9CA3AF) : const Color(0xFF4B5563);
    case 'SUBSCRIBE':
    case 'NOTIFY':
    case 'PUBLISH':
      return dark ? const Color(0xFFFACC15) : const Color(0xFFA16207);
    case 'MESSAGE':
    case 'INFO':
      return dark ? const Color(0xFFA5B4FC) : const Color(0xFF4338CA);
    case 'REFER':
      return dark ? const Color(0xFFF472B6) : const Color(0xFFBE185D);
    default:
      return Theme.of(context).colorScheme.primary;
  }
}

String clockLabel(DateTime t) {
  String p(int n, [int w = 2]) => n.toString().padLeft(w, '0');
  return '${p(t.hour)}:${p(t.minute)}:${p(t.second)}.${p(t.millisecond, 3)}';
}

String deltaLabel(Duration d) {
  final ms = d.inMilliseconds;
  if (ms < 1000) return '+$ms ms';
  if (ms < 60000) return '+${(ms / 1000).toStringAsFixed(2)} s';
  return '+${(ms / 60000).toStringAsFixed(1)} min';
}

String shortId(String s, [int n = 10]) => s.length <= n ? s : '${s.substring(0, n)}...';

String bytesLabel(int b) {
  if (b < 1024) return '$b B';
  if (b < 1024 * 1024) return '${(b / 1024).toStringAsFixed(1)} KB';
  return '${(b / 1024 / 1024).toStringAsFixed(1)} MB';
}
