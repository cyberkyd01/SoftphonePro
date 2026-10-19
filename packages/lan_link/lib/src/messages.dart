import 'dart:convert';
import 'dart:typed_data';

import 'models.dart';
import 'util.dart';

const int maxJsonFrame = 64 * 1024;
const int maxChunkData = 64 * 1024;
const int chunkHeader = 16 + 8;
const int fileWindow = 8;
const int maxChatText = 8000;

/// Base class of all application messages (encrypted JSON frames).
abstract class AppMessage {
  const AppMessage();
  String get type;
  Capability? get capability => null;
  Map<String, dynamic> body();

  Map<String, dynamic> toJson() => {'t': type, 'v': 1, ...body()};
  Uint8List encode() => Uint8List.fromList(utf8.encode(jsonEncode(toJson())));
}

String _id(Js j, String k) {
  final s = j.str(k, max: 64, allowEmpty: false);
  if (!RegExp(r'^[0-9A-Za-z_-]{1,64}$').hasMatch(s)) {
    throw FormatException('$k: bad id');
  }
  return s;
}

String _tid(Js j) {
  final s = j.str('transferId', max: 32);
  if (!RegExp(r'^[0-9a-f]{32}$').hasMatch(s)) {
    throw const FormatException('bad transferId');
  }
  return s;
}

class PeerInfoMsg extends AppMessage {
  const PeerInfoMsg(this.info);
  final DeviceInfo info;
  @override
  String get type => 'peer.info';
  @override
  Map<String, dynamic> body() => {'info': info.toJson()};
}

class PairConfirm extends AppMessage {
  const PairConfirm({required this.ok, this.reason});
  final bool ok;
  final String? reason;
  @override
  String get type => 'pair.confirm';
  @override
  Map<String, dynamic> body() =>
      {'ok': ok, if (reason != null) 'reason': reason};
}

class PairRevoke extends AppMessage {
  const PairRevoke();
  @override
  String get type => 'pair.revoke';
  @override
  Map<String, dynamic> body() => {};
}

class ChatText extends AppMessage {
  const ChatText(
      {required this.id, required this.text, required this.ts, this.replyTo});
  final String id;
  final String text;
  final int ts;
  final String? replyTo;
  @override
  String get type => 'chat.message';
  @override
  Capability get capability => Capability.chat;
  @override
  Map<String, dynamic> body() => {
        'id': id,
        'text': text,
        'ts': ts,
        if (replyTo != null) 'replyTo': replyTo
      };
}

enum AckStatus { delivered, read }

class ChatAck extends AppMessage {
  const ChatAck(this.id, this.status);
  final String id;
  final AckStatus status;
  @override
  String get type => 'chat.ack';
  @override
  Capability get capability => Capability.chat;
  @override
  Map<String, dynamic> body() => {'id': id, 'status': status.name};
}

class ChatTyping extends AppMessage {
  const ChatTyping(this.typing);
  final bool typing;
  @override
  String get type => 'chat.typing';
  @override
  Capability get capability => Capability.chat;
  @override
  Map<String, dynamic> body() => {'typing': typing};
}

class StatusUpdate extends AppMessage {
  const StatusUpdate(this.status);
  final PeerStatus status;
  @override
  String get type => 'status.update';
  @override
  Map<String, dynamic> body() => {'status': status.name};
}

class FileOffer extends AppMessage {
  const FileOffer({
    required this.transferId,
    required this.name,
    required this.size,
    required this.sha256,
    this.mime = 'application/octet-stream',
  });
  final String transferId;
  final String name;
  final int size;
  final String sha256;
  final String mime;
  @override
  String get type => 'file.offer';
  @override
  Capability get capability => Capability.files;
  @override
  Map<String, dynamic> body() => {
        'transferId': transferId,
        'name': name,
        'size': size,
        'sha256': sha256,
        'mime': mime
      };
}

class FileAccept extends AppMessage {
  const FileAccept(this.transferId, this.resumeOffset);
  final String transferId;
  final int resumeOffset;
  @override
  String get type => 'file.accept';
  @override
  Capability get capability => Capability.files;
  @override
  Map<String, dynamic> body() =>
      {'transferId': transferId, 'resumeOffset': resumeOffset};
}

class FileDecline extends AppMessage {
  const FileDecline(this.transferId, this.reason);
  final String transferId;
  final String reason;
  @override
  String get type => 'file.decline';
  @override
  Capability get capability => Capability.files;
  @override
  Map<String, dynamic> body() => {'transferId': transferId, 'reason': reason};
}

class FileChunkAck extends AppMessage {
  const FileChunkAck(this.transferId, this.offset);
  final String transferId;
  final int offset;
  @override
  String get type => 'file.chunkAck';
  @override
  Capability get capability => Capability.files;
  @override
  Map<String, dynamic> body() => {'transferId': transferId, 'offset': offset};
}

class FileComplete extends AppMessage {
  const FileComplete(this.transferId);
  final String transferId;
  @override
  String get type => 'file.complete';
  @override
  Capability get capability => Capability.files;
  @override
  Map<String, dynamic> body() => {'transferId': transferId};
}

class FileVerified extends AppMessage {
  const FileVerified(this.transferId, this.ok);
  final String transferId;
  final bool ok;
  @override
  String get type => 'file.verified';
  @override
  Capability get capability => Capability.files;
  @override
  Map<String, dynamic> body() => {'transferId': transferId, 'ok': ok};
}

class FileCancel extends AppMessage {
  const FileCancel(this.transferId);
  final String transferId;
  @override
  String get type => 'file.cancel';
  @override
  Capability get capability => Capability.files;
  @override
  Map<String, dynamic> body() => {'transferId': transferId};
}

enum HandoffMode { relay, refer }

class CallerInfo {
  const CallerInfo({this.name = '', this.number = '', this.uri = ''});
  final String name;
  final String number;
  final String uri;
  Map<String, dynamic> toJson() => {'name': name, 'number': number, 'uri': uri};
  static CallerInfo fromJson(Js j) => CallerInfo(
      name: j.str('name', max: 128),
      number: j.str('number', max: 64),
      uri: j.str('uri', max: 256));
}

class HandoffOffer extends AppMessage {
  const HandoffOffer({
    required this.handoffId,
    required this.mode,
    required this.caller,
    this.accountName = '',
    this.referTarget,
    this.lanSipUri = '',
    this.attended = false,
  });
  final String handoffId;
  final HandoffMode mode;
  final CallerInfo caller;
  final String accountName;
  final String? referTarget;
  final String lanSipUri;
  final bool attended;
  @override
  String get type => 'handoff.offer';
  @override
  Capability get capability => Capability.handoff;
  @override
  Map<String, dynamic> body() => {
        'handoffId': handoffId,
        'mode': mode.name,
        'caller': caller.toJson(),
        'accountName': accountName,
        if (referTarget != null) 'referTarget': referTarget,
        'lanSipUri': lanSipUri,
        'attended': attended,
      };
}

class HandoffAccept extends AppMessage {
  const HandoffAccept(this.handoffId);
  final String handoffId;
  @override
  String get type => 'handoff.accept';
  @override
  Capability get capability => Capability.handoff;
  @override
  Map<String, dynamic> body() => {'handoffId': handoffId};
}

class HandoffDecline extends AppMessage {
  const HandoffDecline(this.handoffId, this.reason);
  final String handoffId;
  final String reason;
  @override
  String get type => 'handoff.decline';
  @override
  Capability get capability => Capability.handoff;
  @override
  Map<String, dynamic> body() => {'handoffId': handoffId, 'reason': reason};
}

class HandoffCancel extends AppMessage {
  const HandoffCancel(this.handoffId);
  final String handoffId;
  @override
  String get type => 'handoff.cancel';
  @override
  Capability get capability => Capability.handoff;
  @override
  Map<String, dynamic> body() => {'handoffId': handoffId};
}

class HandoffComplete extends AppMessage {
  const HandoffComplete(this.handoffId);
  final String handoffId;
  @override
  String get type => 'handoff.complete';
  @override
  Capability get capability => Capability.handoff;
  @override
  Map<String, dynamic> body() => {'handoffId': handoffId};
}

class CallsQuery extends AppMessage {
  const CallsQuery();
  @override
  String get type => 'calls.query';
  @override
  Capability get capability => Capability.handoff;
  @override
  Map<String, dynamic> body() => {};
}

class CallSummary {
  const CallSummary({
    required this.callId,
    this.remoteName = '',
    this.remoteNumber = '',
    this.durationSec = 0,
    this.accountName = '',
  });
  final String callId;
  final String remoteName;
  final String remoteNumber;
  final int durationSec;
  final String accountName;
  Map<String, dynamic> toJson() => {
        'callId': callId,
        'remoteName': remoteName,
        'remoteNumber': remoteNumber,
        'durationSec': durationSec,
        'accountName': accountName,
      };
  static CallSummary fromJson(Js j) => CallSummary(
        callId: j.str('callId', max: 64, allowEmpty: false),
        remoteName: j.str('remoteName', max: 128),
        remoteNumber: j.str('remoteNumber', max: 64),
        durationSec: j.integer('durationSec', max: 1 << 31),
        accountName: j.str('accountName', max: 128),
      );
}

class CallsList extends AppMessage {
  const CallsList(this.calls);
  final List<CallSummary> calls;
  @override
  String get type => 'calls.list';
  @override
  Capability get capability => Capability.handoff;
  @override
  Map<String, dynamic> body() =>
      {'calls': calls.map((e) => e.toJson()).toList()};
}

class CallPull extends AppMessage {
  const CallPull(this.callId);
  final String callId;
  @override
  String get type => 'call.pull';
  @override
  Capability get capability => Capability.handoff;
  @override
  Map<String, dynamic> body() => {'callId': callId};
}

class IntercomRequest extends AppMessage {
  const IntercomRequest({this.allowed});
  final bool? allowed;
  @override
  String get type => 'intercom.request';
  @override
  Capability get capability => Capability.intercom;
  @override
  Map<String, dynamic> body() => {if (allowed != null) 'allowed': allowed};
}

/// Parses a decrypted JSON frame. Returns null for unknown types / newer
/// versions (forward compatibility). Throws [FormatException] for malformed
/// known messages.
Future<AppMessage?> parseMessage(Uint8List data) async {
  if (data.length > maxJsonFrame)
    throw const FormatException('frame too large');
  final j = Js.parse(utf8.decode(data), maxLength: maxJsonFrame);
  final v = j.m['v'];
  if (v is! int || v > 1) return null;
  switch (j.str('t', max: 32)) {
    case 'peer.info':
      return PeerInfoMsg(await DeviceInfo.parse(j.obj('info')));
    case 'pair.confirm':
      return PairConfirm(
          ok: j.boolean('ok'), reason: j.optStr('reason', max: 128));
    case 'pair.revoke':
      return const PairRevoke();
    case 'chat.message':
      return ChatText(
          id: _id(j, 'id'),
          text: j.str('text', max: maxChatText),
          ts: j.integer('ts'),
          replyTo: j.has('replyTo') ? _id(j, 'replyTo') : null);
    case 'chat.ack':
      final s = j.str('status', max: 16);
      return ChatAck(
          _id(j, 'id'),
          AckStatus.values.firstWhere((e) => e.name == s,
              orElse: () => throw const FormatException('bad status')));
    case 'chat.typing':
      return ChatTyping(j.boolean('typing'));
    case 'status.update':
      final s = j.str('status', max: 16);
      return StatusUpdate(PeerStatus.values.firstWhere((e) => e.name == s,
          orElse: () => throw const FormatException('bad status')));
    case 'file.offer':
      final sha = j.str('sha256', max: 64);
      if (!RegExp(r'^[0-9a-f]{64}$').hasMatch(sha)) {
        throw const FormatException('bad sha256');
      }
      return FileOffer(
          transferId: _tid(j),
          name: j.str('name', max: 512, allowEmpty: false),
          size: j.integer('size'),
          sha256: sha,
          mime: j.str('mime', max: 100));
    case 'file.accept':
      return FileAccept(_tid(j), j.integer('resumeOffset'));
    case 'file.decline':
      return FileDecline(_tid(j), j.str('reason', max: 128));
    case 'file.chunkAck':
      return FileChunkAck(_tid(j), j.integer('offset'));
    case 'file.complete':
      return FileComplete(_tid(j));
    case 'file.verified':
      return FileVerified(_tid(j), j.boolean('ok'));
    case 'file.cancel':
      return FileCancel(_tid(j));
    case 'handoff.offer':
      final m = j.str('mode', max: 16);
      return HandoffOffer(
        handoffId: _id(j, 'handoffId'),
        mode: HandoffMode.values.firstWhere((e) => e.name == m,
            orElse: () => throw const FormatException('bad mode')),
        caller: CallerInfo.fromJson(j.obj('caller')),
        accountName: j.str('accountName', max: 128),
        referTarget: j.optStr('referTarget', max: 256),
        lanSipUri: j.str('lanSipUri', max: 256),
        attended: j.boolean('attended', def: false),
      );
    case 'handoff.accept':
      return HandoffAccept(_id(j, 'handoffId'));
    case 'handoff.decline':
      return HandoffDecline(_id(j, 'handoffId'), j.str('reason', max: 128));
    case 'handoff.cancel':
      return HandoffCancel(_id(j, 'handoffId'));
    case 'handoff.complete':
      return HandoffComplete(_id(j, 'handoffId'));
    case 'calls.query':
      return const CallsQuery();
    case 'calls.list':
      return CallsList([
        for (final c in j.list('calls', max: 64))
          CallSummary.fromJson(Js(c is Map<String, dynamic>
              ? c
              : throw const FormatException('bad call')))
      ]);
    case 'call.pull':
      return CallPull(j.str('callId', max: 64, allowEmpty: false));
    case 'intercom.request':
      return IntercomRequest(
          allowed: j.has('allowed') ? j.boolean('allowed') : null);
  }
  return null;
}

/// Binary file data frame: 16-byte transferId + 8-byte BE offset + data.
class FileChunk {
  FileChunk(this.transferId, this.offset, this.data);
  final String transferId; // 32 hex
  final int offset;
  final Uint8List data;

  Uint8List encode() {
    final out = Uint8List(chunkHeader + data.length);
    out.setRange(0, 16, hexDecode(transferId));
    ByteData.sublistView(out).setUint64(16, offset, Endian.big);
    out.setRange(chunkHeader, out.length, data);
    return out;
  }

  static FileChunk decode(Uint8List b) {
    if (b.length < chunkHeader || b.length > chunkHeader + maxChunkData) {
      throw const FormatException('bad chunk size');
    }
    final off = ByteData.sublistView(b).getUint64(16, Endian.big);
    if (off < 0) throw const FormatException('bad offset');
    return FileChunk(hexEncode(b.sublist(0, 16)), off,
        Uint8List.sublistView(b, chunkHeader));
  }
}
