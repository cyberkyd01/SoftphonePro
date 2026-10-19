import 'package:flutter/widgets.dart' show Locale;
import 'package:lan_link/lan_link.dart' as ll;

import '../l10n/l10n.dart';

/// The engine's local account uid for LAN SIP calls.
const String kLanAccountUid = '__lan__';

/// SIP headers used between SoftphonePro devices.
const String kHdrHandoff = 'X-SPP-Handoff';
const String kHdrCallerName = 'X-SPP-Caller-Name';
const String kHdrCallerNumber = 'X-SPP-Caller-Number';
const String kHdrDevice = 'X-SPP-Device';
const String kHdrIntercom = 'X-SPP-Intercom';

/// Case-insensitive header lookup.
String? headerValue(Map<String, String> headers, String name) {
  final n = name.toLowerCase();
  for (final e in headers.entries) {
    if (e.key.toLowerCase() == n) return e.value;
  }
  return null;
}

/// Extra facts about a call that came in over the LAN transport (or was
/// transferred to us by a LAN peer). Shown by the incoming/in-call UI.
class LanCallMeta {
  const LanCallMeta({
    this.peerId = '',
    this.peerName = '',
    this.paired = false,
    this.intercom = false,
    this.handoffId,
    this.handoffAccepted = false,
    this.callerName = '',
    this.callerNumber = '',
    this.outgoing = false,
  });

  /// deviceId of the LAN peer on the other end ('' when unknown).
  final String peerId;
  final String peerName;
  final bool paired;
  final bool intercom;
  final String? handoffId;

  /// We accepted the matching handoff offer, so the call is auto-answered.
  final bool handoffAccepted;

  /// Original caller of a transferred call.
  final String callerName;
  final String callerNumber;
  final bool outgoing;

  bool get isHandoff => handoffId != null;
  String get callerLabel => callerName.isNotEmpty ? callerName : callerNumber;

  /// "Transferred call from Kitchen iPad: Alice (1002)".
  String handoffTextFor(AppLocalizations l) {
    final who = peerName.isNotEmpty ? peerName : l.lanHandoffAnotherDevice;
    final c = callerLabel;
    return c.isEmpty ? l.lanHandoffTransferredFrom(who) : l.lanHandoffTransferredFromCaller(who, c);
  }

  /// English text (tests / non-UI callers); the UI uses [handoffTextFor].
  String get handoffText => handoffTextFor(lookupAppLocalizations(const Locale('en')));
}

/// A call that is being relayed through this device to a LAN peer.
enum RelayPhase { offering, dialing, consulting, relayed, takingBack }

class RelaySession {
  RelaySession({
    required this.handoffId,
    required this.cid,
    required this.peerId,
    required this.peerName,
    this.lanCid,
    this.phase = RelayPhase.offering,
    this.attended = false,
    DateTime? since,
  }) : since = since ?? DateTime.now();

  final String handoffId;
  final int cid;
  final String peerId;
  final String peerName;
  int? lanCid;
  RelayPhase phase;
  final bool attended;
  DateTime since;

  bool get isRelayed => phase == RelayPhase.relayed;
}

/// A device in the nearby list: a [ll.LanPeer] snapshot.
extension LanPeerX on ll.LanPeer {
  bool get canHandoff =>
      info == null || info!.capabilities.contains(ll.Capability.handoff);
  bool get canIntercom =>
      info == null || info!.capabilities.contains(ll.Capability.intercom);
  bool get hasSip => (info?.sipPort ?? 0) > 0 && address != null;

  /// SIP URI to call this device directly.
  String? get sipUri => hasSip ? 'sip:$deviceId@${address!.address}:${info!.sipPort}' : null;
}

/// Formats a deviceId as groups of four ("AB12 CD34 EF56 7890").
String fingerprintOf(String deviceId) {
  final up = deviceId.toUpperCase();
  final b = StringBuffer();
  for (var i = 0; i < up.length; i += 4) {
    if (i > 0) b.write(' ');
    b.write(up.substring(i, i + 4 > up.length ? up.length : i + 4));
  }
  return b.toString();
}

/// Parsed manual-connect target (host:port, optionally from a QR payload).
class LanTarget {
  const LanTarget(this.host, this.port, {this.deviceId, this.name});
  final String host;
  final int port;
  final String? deviceId;
  final String? name;

  /// Accepts `host:port`, `[v6]:port`, `softphonepro://lan?h=..&p=..&id=..&n=..`
  /// and `http://host:port/...`. Returns null when it cannot be parsed.
  static LanTarget? parse(String raw) {
    final s = raw.trim();
    if (s.isEmpty) return null;
    final looksUri = s.contains('://');
    if (looksUri) {
      final u = Uri.tryParse(s);
      if (u == null) return null;
      final q = u.queryParameters;
      final host = q['h'] ?? q['host'] ?? u.host;
      final port = int.tryParse(q['p'] ?? q['port'] ?? '') ?? (u.hasPort ? u.port : 0);
      if (host.isEmpty || port <= 0 || port > 65535) return null;
      return LanTarget(host, port, deviceId: q['id']?.toLowerCase(), name: q['n']);
    }
    final i = s.lastIndexOf(':');
    if (i <= 0 || i == s.length - 1) return null;
    var host = s.substring(0, i).trim();
    if (host.startsWith('[') && host.endsWith(']')) host = host.substring(1, host.length - 1);
    final port = int.tryParse(s.substring(i + 1).trim());
    if (host.isEmpty || port == null || port <= 0 || port > 65535) return null;
    return LanTarget(host, port);
  }

  /// The string encoded into this device's QR code.
  static String encode({required String host, required int port, required String deviceId, required String name}) =>
      Uri(scheme: 'softphonepro', host: 'lan', queryParameters: {'h': host, 'p': '$port', 'id': deviceId, 'n': name}).toString();
}

/// A finished (or failed) file transfer, persisted for the "files" list.
class LanFileEntry {
  const LanFileEntry({
    required this.id,
    required this.peerId,
    required this.peerName,
    required this.name,
    required this.size,
    required this.incoming,
    required this.time,
    this.path = '',
    this.ok = true,
    this.error = '',
  });
  final String id;
  final String peerId;
  final String peerName;
  final String name;
  final int size;
  final bool incoming;
  final DateTime time;
  final String path;
  final bool ok;
  final String error;

  factory LanFileEntry.fromJson(Map<String, dynamic> j) => LanFileEntry(
        id: j['id'] as String,
        peerId: j['peerId'] as String? ?? '',
        peerName: j['peerName'] as String? ?? '',
        name: j['name'] as String? ?? '',
        size: (j['size'] as num?)?.toInt() ?? 0,
        incoming: j['incoming'] == true,
        time: DateTime.fromMillisecondsSinceEpoch((j['time'] as num?)?.toInt() ?? 0),
        path: j['path'] as String? ?? '',
        ok: j['ok'] != false,
        error: j['error'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'peerId': peerId,
        'peerName': peerName,
        'name': name,
        'size': size,
        'incoming': incoming,
        'time': time.millisecondsSinceEpoch,
        'path': path,
        'ok': ok,
        'error': error,
      };
}
