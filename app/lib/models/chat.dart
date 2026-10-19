enum MessageStatus { sending, sent, delivered, read, failed, received }

/// 'sip' for SIP MESSAGE, 'lan' for LAN Link chat.
const String kChannelSip = 'sip';
const String kChannelLan = 'lan';

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.channel,
    required this.accountId,
    required this.peer,
    required this.outgoing,
    required this.body,
    required this.time,
    this.status = MessageStatus.received,
    this.read = true,
    this.peerDisplay = '',
    this.error = '',
  });

  final String id;
  final String channel;

  /// Profile id (sip) or LAN device id (lan).
  final String accountId;

  /// Remote SIP URI (or LAN device id).
  final String peer;
  final bool outgoing;
  final String body;
  final DateTime time;
  final MessageStatus status;
  final bool read;
  final String peerDisplay;
  final String error;

  String get conversationKey => '$channel|$accountId|${peerKey(peer)}';

  /// Normalised peer key: `user@host` lower-case without scheme.
  static String peerKey(String uri) {
    var s = uri.trim();
    final lt = s.indexOf('<');
    final gt = s.indexOf('>');
    if (lt >= 0 && gt > lt) s = s.substring(lt + 1, gt);
    s = s.replaceFirst(RegExp(r'^(sips?|tel):', caseSensitive: false), '');
    final semi = s.indexOf(';');
    if (semi >= 0) s = s.substring(0, semi);
    return s.toLowerCase();
  }

  ChatMessage copyWith({MessageStatus? status, bool? read, String? error}) =>
      ChatMessage(
        id: id,
        channel: channel,
        accountId: accountId,
        peer: peer,
        outgoing: outgoing,
        body: body,
        time: time,
        status: status ?? this.status,
        read: read ?? this.read,
        peerDisplay: peerDisplay,
        error: error ?? this.error,
      );

  factory ChatMessage.fromJson(Map<String, dynamic> j) => ChatMessage(
    id: j['id'] as String,
    channel: j['channel'] as String? ?? kChannelSip,
    accountId: j['accountId'] as String? ?? '',
    peer: j['peer'] as String? ?? '',
    outgoing: j['outgoing'] == true,
    body: j['body'] as String? ?? '',
    time: DateTime.fromMillisecondsSinceEpoch((j['time'] as num?)?.toInt() ?? 0),
    status: MessageStatus.values.firstWhere(
      (s) => s.name == j['status'],
      orElse: () => MessageStatus.received,
    ),
    read: j['read'] != false,
    peerDisplay: j['peerDisplay'] as String? ?? '',
    error: j['error'] as String? ?? '',
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'channel': channel,
    'accountId': accountId,
    'peer': peer,
    'outgoing': outgoing,
    'body': body,
    'time': time.millisecondsSinceEpoch,
    'status': status.name,
    'read': read,
    'peerDisplay': peerDisplay,
    'error': error,
  };
}

class Conversation {
  const Conversation({
    required this.key,
    required this.channel,
    required this.accountId,
    required this.peer,
    required this.peerDisplay,
    required this.last,
    required this.unread,
  });

  final String key;
  final String channel;
  final String accountId;
  final String peer;
  final String peerDisplay;
  final ChatMessage last;
  final int unread;
}

class RecordingMeta {
  const RecordingMeta({
    required this.id,
    required this.path,
    required this.remote,
    required this.time,
    this.durationMs = 0,
    this.accountId = '',
  });

  final String id;
  final String path;
  final String remote;
  final DateTime time;
  final int durationMs;
  final String accountId;

  factory RecordingMeta.fromJson(Map<String, dynamic> j) => RecordingMeta(
    id: j['id'] as String,
    path: j['path'] as String? ?? '',
    remote: j['remote'] as String? ?? '',
    time: DateTime.fromMillisecondsSinceEpoch((j['time'] as num?)?.toInt() ?? 0),
    durationMs: (j['durationMs'] as num?)?.toInt() ?? 0,
    accountId: j['accountId'] as String? ?? '',
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'path': path,
    'remote': remote,
    'time': time.millisecondsSinceEpoch,
    'durationMs': durationMs,
    'accountId': accountId,
  };
}
