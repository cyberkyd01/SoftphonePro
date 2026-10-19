import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:path/path.dart' as p;

import 'identity.dart';
import 'messages.dart';
import 'util.dart';

enum TransferState {
  preparing,
  offered, // incoming: waiting for local user; outgoing: waiting for peer
  transferring,
  verifying,
  completed,
  declined,
  cancelled,
  failed,
}

bool _terminal(TransferState s) =>
    s == TransferState.completed ||
    s == TransferState.declined ||
    s == TransferState.cancelled ||
    s == TransferState.failed;

/// One file transfer (incoming or outgoing). Listen to [updates] for progress.
class FileTransfer {
  FileTransfer._(this._engine, this.id, this.peerId, this.incoming, this.name,
      this.size, this.sha256, this.mime);

  final FileEngine _engine;
  final String id;
  final String peerId;
  final bool incoming;
  final String name;
  int size;
  String sha256;
  final String mime;

  TransferState state = TransferState.preparing;
  int bytesDone = 0;

  /// Offset the transfer (re)started from (> 0 when resumed).
  int resumedFrom = 0;
  String? error;

  /// Final path of a completed incoming file.
  String? savedPath;

  /// Local source path of an outgoing file.
  String? sourcePath;

  final _updates = StreamController<FileTransfer>.broadcast();
  final _done = Completer<FileTransfer>();
  DateTime _lastEmit = DateTime.fromMillisecondsSinceEpoch(0);

  Stream<FileTransfer> get updates => _updates.stream;

  /// Completes (never with error) when the transfer reaches a final state.
  Future<FileTransfer> get done => _done.future;
  bool get isFinished => _terminal(state);
  double get progress => size == 0 ? 1 : bytesDone / size;

  Future<void> accept() => _engine.accept(this);
  Future<void> decline([String reason = 'declined']) =>
      _engine.decline(this, reason);
  Future<void> cancel() => _engine.cancel(this);

  void _set(TransferState s, {String? err, bool force = false}) {
    if (isFinished) return;
    final changed = s != state;
    state = s;
    if (err != null) error = err;
    final now = DateTime.now();
    if (changed || force || now.difference(_lastEmit).inMilliseconds > 50) {
      _lastEmit = now;
      if (!_updates.isClosed) _updates.add(this);
    }
    if (_terminal(s)) {
      if (!_done.isCompleted) _done.complete(this);
      _updates.close();
    }
  }

  @override
  String toString() => 'FileTransfer($id $name $state $bytesDone/$size)';
}

/// Returns a safe file name or null if the name is a path-traversal attempt /
/// otherwise invalid.
String? sanitizeFileName(String raw) {
  if (raw.isEmpty || raw.length > 512) return null;
  if (raw.contains('/') || raw.contains('\\') || raw.contains('\u0000')) {
    return null;
  }
  if (raw == '.' || raw == '..') return null;
  var s = raw.replaceAll(RegExp(r'[\u0000-\u001f\u007f<>:"|?*]'), '_');
  s = s.replaceFirst(RegExp(r'^[.\s]+'), '_');
  s = s.replaceFirst(RegExp(r'[.\s]+$'), '');
  if (s.isEmpty) return null;
  final base = s.split('.').first.toUpperCase();
  if (RegExp(r'^(CON|PRN|AUX|NUL|COM[0-9]|LPT[0-9])$').hasMatch(base)) {
    s = '_$s';
  }
  if (s.length > 200) {
    final ext = p.extension(s);
    final e = ext.length > 20 ? '' : ext;
    s = s.substring(0, 200 - e.length) + e;
  }
  return s;
}

Future<String> sha256OfFile(String path) async {
  final sink = sha256Algo.newHashSink();
  await for (final c in File(path).openRead()) {
    sink.add(c);
  }
  sink.close();
  return hexEncode((await sink.hash()).bytes);
}

class _Aborted implements Exception {
  _Aborted(this.reason);
  final String reason;
}

class _Out {
  _Out(this.t) {
    accepted.future.ignore();
  }
  final FileTransfer t;
  final accepted = Completer<int>();
  final verified = Completer<bool>();
  Completer<void> wake = Completer<void>();
  final Map<int, int> inflight = {}; // offset -> length
  RandomAccessFile? raf;

  void signal() {
    if (!wake.isCompleted) wake.complete();
  }
}

class _In {
  _In(this.t, this.partialPath);
  final FileTransfer t;
  final String partialPath;
  RandomAccessFile? raf;
  int written = 0;
  Timer? offerTimer;
}

/// Implements the file protocol for all peers. Pure logic over callbacks.
class FileEngine {
  FileEngine({
    required this.downloadsDir,
    required this.sendMessage,
    required this.sendChunk,
    this.maxFileSize = 4 * 1024 * 1024 * 1024,
    this.maxPendingOffersPerPeer = 16,
    this.offerTimeout = const Duration(minutes: 5),
    this.acceptTimeout = const Duration(minutes: 5),
  });

  final String downloadsDir;
  final int maxFileSize;
  final int maxPendingOffersPerPeer;
  final Duration offerTimeout;
  final Duration acceptTimeout;
  final Future<void> Function(String peerId, AppMessage m) sendMessage;
  final Future<void> Function(String peerId, FileChunk c) sendChunk;

  final _newTransfers = StreamController<FileTransfer>.broadcast();
  final Map<String, _Out> _out = {};
  final Map<String, _In> _in = {};

  /// Emits every new transfer (incoming offers and outgoing sends).
  Stream<FileTransfer> get transfers => _newTransfers.stream;

  String get _partialDir => p.join(downloadsDir, '.spp-partial');

  /// Called by the owner of this engine on a fatal send failure etc.
  void _safeSend(String peer, AppMessage m) {
    sendMessage(peer, m).catchError((_) {});
  }

  // ---- outgoing ----------------------------------------------------------

  FileTransfer sendFile(String peerId, String path) {
    final id = hexEncode(randomBytes(16));
    final t = FileTransfer._(this, id, peerId, false, p.basename(path), 0, '',
        'application/octet-stream')
      ..sourcePath = path;
    final o = _Out(t);
    _out[id] = o;
    _newTransfers.add(t);
    unawaited(_runOut(o, path));
    return t;
  }

  Future<void> _runOut(_Out o, String path) async {
    final t = o.t;
    try {
      final f = File(path);
      if (!await f.exists()) throw _Aborted('file_not_found');
      t.size = await f.length();
      if (t.size > maxFileSize) throw _Aborted('too_large');
      t.sha256 = await sha256OfFile(path);
      _checkOut(o);
      t._set(TransferState.offered, force: true);
      await sendMessage(
          t.peerId,
          FileOffer(
              transferId: t.id,
              name: t.name,
              size: t.size,
              sha256: t.sha256,
              mime: _mimeFor(t.name)));
      final resume = await o.accepted.future
          .timeout(acceptTimeout, onTimeout: () => throw _Aborted('timeout'));
      _checkOut(o);
      t.resumedFrom = resume;
      t.bytesDone = resume;
      t._set(TransferState.transferring, force: true);
      final raf = o.raf = await f.open();
      var pos = resume;
      while (pos < t.size) {
        while (o.inflight.length >= fileWindow) {
          await o.wake.future.timeout(const Duration(seconds: 60),
              onTimeout: () => throw _Aborted('stalled'));
          o.wake = Completer<void>();
          _checkOut(o);
        }
        _checkOut(o);
        final n = min(maxChunkData, t.size - pos);
        await raf.setPosition(pos);
        final data = await raf.read(n);
        if (data.length != n) throw _Aborted('file_changed');
        o.inflight[pos] = n;
        await sendChunk(t.peerId, FileChunk(t.id, pos, data));
        pos += n;
      }
      while (o.inflight.isNotEmpty) {
        await o.wake.future.timeout(const Duration(seconds: 60),
            onTimeout: () => throw _Aborted('stalled'));
        o.wake = Completer<void>();
        _checkOut(o);
      }
      _checkOut(o);
      t._set(TransferState.verifying, force: true);
      await sendMessage(t.peerId, FileComplete(t.id));
      final ok = await o.verified.future.timeout(const Duration(seconds: 120),
          onTimeout: () => throw _Aborted('verify_timeout'));
      if (ok) {
        t.bytesDone = t.size;
        t._set(TransferState.completed, force: true);
      } else {
        t._set(TransferState.failed, err: 'verification_failed', force: true);
      }
    } on _Aborted catch (e) {
      if (!t.isFinished) {
        final st = e.reason == 'declined' || e.reason.startsWith('declined:')
            ? TransferState.declined
            : e.reason == 'cancelled'
                ? TransferState.cancelled
                : TransferState.failed;
        t._set(st, err: e.reason, force: true);
      }
    } catch (e) {
      t._set(TransferState.failed, err: '$e', force: true);
    } finally {
      await o.raf?.close();
      _out.remove(t.id);
    }
  }

  void _checkOut(_Out o) {
    if (o.t.isFinished) throw _Aborted('cancelled');
  }

  String _mimeFor(String name) {
    final e = p.extension(name).toLowerCase();
    return const {
          '.txt': 'text/plain',
          '.pdf': 'application/pdf',
          '.png': 'image/png',
          '.jpg': 'image/jpeg',
          '.jpeg': 'image/jpeg',
          '.gif': 'image/gif',
          '.mp3': 'audio/mpeg',
          '.wav': 'audio/wav',
          '.mp4': 'video/mp4',
          '.zip': 'application/zip',
        }[e] ??
        'application/octet-stream';
  }

  // ---- incoming protocol -------------------------------------------------

  Future<void> onMessage(String peerId, AppMessage m) async {
    switch (m) {
      case FileOffer():
        await _onOffer(peerId, m);
      case FileAccept():
        final o = _out[m.transferId];
        if (o == null || o.t.peerId != peerId || o.accepted.isCompleted) return;
        if (m.resumeOffset > o.t.size) {
          o.accepted.completeError(_Aborted('bad_resume'));
        } else {
          o.accepted.complete(m.resumeOffset);
        }
      case FileDecline():
        final o = _out[m.transferId];
        if (o == null || o.t.peerId != peerId) return;
        if (!o.accepted.isCompleted) {
          o.accepted.completeError(_Aborted('declined:${m.reason}'));
        }
        o.t.error = m.reason;
        o.signal();
      case FileChunkAck():
        final o = _out[m.transferId];
        if (o == null || o.t.peerId != peerId) return;
        final len = o.inflight.remove(m.offset);
        if (len != null) {
          o.t.bytesDone = max(o.t.bytesDone, m.offset + len);
          o.t._set(TransferState.transferring);
          o.signal();
        }
      case FileComplete():
        await _onComplete(peerId, m.transferId);
      case FileVerified():
        final o = _out[m.transferId];
        if (o == null || o.t.peerId != peerId || o.verified.isCompleted) return;
        o.verified.complete(m.ok);
      case FileCancel():
        _remoteCancel(peerId, m.transferId);
      default:
        break;
    }
  }

  Future<void> _onOffer(String peerId, FileOffer m) async {
    void decl(String r) => _safeSend(peerId, FileDecline(m.transferId, r));
    final known = _in[m.transferId];
    if (known != null && known.t.peerId == peerId && known.t.state == TransferState.offered) {
      // The sender repeated an offer we still wait on: surface the pending
      // transfer again (the UI re-shows its dialog) instead of declining it.
      _newTransfers.add(known.t);
      return;
    }
    if (known != null || _out.containsKey(m.transferId)) {
      return decl('duplicate');
    }
    final name = sanitizeFileName(m.name);
    if (name == null) return decl('invalid_name');
    if (m.size > maxFileSize) return decl('too_large');
    final pending =
        _in.values.where((e) => e.t.peerId == peerId && !e.t.isFinished).length;
    if (pending >= maxPendingOffersPerPeer) return decl('too_many_offers');
    final t = FileTransfer._(
        this, m.transferId, peerId, true, name, m.size, m.sha256, m.mime);
    final partial = p.join(
        _partialDir, '${peerId}_${m.sha256.substring(0, 32)}_${m.size}.part');
    final same = _in.values
        .where((e) => e.partialPath == partial && !e.t.isFinished)
        .firstOrNull;
    if (same != null) {
      if (same.t.state == TransferState.offered) _newTransfers.add(same.t);
      return decl('duplicate');
    }
    final i = _in[m.transferId] = _In(t, partial);
    i.offerTimer = Timer(offerTimeout, () {
      if (t.state == TransferState.offered) {
        unawaited(decline(t, 'timeout'));
      }
    });
    t._set(TransferState.offered, force: true);
    _newTransfers.add(t);
  }

  Future<void> accept(FileTransfer t) async {
    final i = _in[t.id];
    if (i == null || t.state != TransferState.offered || !t.incoming) return;
    i.offerTimer?.cancel();
    try {
      await Directory(_partialDir).create(recursive: true);
      var resume = 0;
      final pf = File(i.partialPath);
      if (await pf.exists()) {
        final len = await pf.length();
        if (len <= t.size) resume = len;
      }
      i.raf =
          await pf.open(mode: resume == 0 ? FileMode.write : FileMode.append);
      i.written = resume;
      t.resumedFrom = resume;
      t.bytesDone = resume;
      t._set(TransferState.transferring, force: true);
      await sendMessage(t.peerId, FileAccept(t.id, resume));
      if (resume == t.size) {
        // everything already present; sender will send complete
      }
    } catch (e) {
      await _failIn(i, 'io_error: $e', notify: 'io_error');
    }
  }

  Future<void> decline(FileTransfer t, String reason) async {
    final i = _in[t.id];
    if (i == null || t.isFinished) return;
    i.offerTimer?.cancel();
    t._set(TransferState.declined, err: reason, force: true);
    _in.remove(t.id);
    _safeSend(t.peerId, FileDecline(t.id, reason));
  }

  Future<void> cancel(FileTransfer t) async {
    if (t.isFinished) return;
    if (t.incoming) {
      final i = _in[t.id];
      if (i == null) return;
      i.offerTimer?.cancel();
      t._set(TransferState.cancelled, force: true);
      _safeSend(t.peerId, FileCancel(t.id));
      await _dropIn(i, deletePartial: true);
    } else {
      final o = _out[t.id];
      _safeSend(t.peerId, FileCancel(t.id));
      t._set(TransferState.cancelled, err: 'cancelled', force: true);
      if (o != null) {
        if (!o.accepted.isCompleted)
          o.accepted.completeError(_Aborted('cancelled'));
        o.signal();
      }
    }
  }

  void _remoteCancel(String peerId, String id) {
    final o = _out[id];
    if (o != null && o.t.peerId == peerId) {
      o.t._set(TransferState.cancelled, err: 'cancelled_by_peer', force: true);
      if (!o.accepted.isCompleted)
        o.accepted.completeError(_Aborted('cancelled'));
      if (!o.verified.isCompleted) o.verified.complete(false);
      o.signal();
    }
    final i = _in[id];
    if (i != null && i.t.peerId == peerId) {
      i.offerTimer?.cancel();
      i.t._set(TransferState.cancelled, err: 'cancelled_by_peer', force: true);
      unawaited(_dropIn(i, deletePartial: true));
    }
  }

  Future<void> _dropIn(_In i, {required bool deletePartial}) async {
    _in.remove(i.t.id);
    try {
      await i.raf?.close();
    } catch (_) {}
    i.raf = null;
    if (deletePartial) {
      try {
        await File(i.partialPath).delete();
      } catch (_) {}
    }
  }

  Future<void> _failIn(_In i, String err,
      {String? notify, bool deletePartial = false}) async {
    if (notify != null) _safeSend(i.t.peerId, FileCancel(i.t.id));
    await _dropIn(i, deletePartial: deletePartial);
    i.t._set(TransferState.failed, err: err, force: true);
  }

  Future<void> onChunk(String peerId, FileChunk c) async {
    final i = _in[c.transferId];
    if (i == null || i.t.peerId != peerId) return;
    final t = i.t;
    if (t.state != TransferState.transferring || i.raf == null) return;
    if (c.offset != i.written || i.written + c.data.length > t.size) {
      await _failIn(i, 'bad_offset', notify: 'x');
      return;
    }
    try {
      await i.raf!.writeFrom(c.data);
    } catch (e) {
      await _failIn(i, 'io_error: $e', notify: 'x');
      return;
    }
    i.written += c.data.length;
    t.bytesDone = i.written;
    t._set(TransferState.transferring);
    _safeSend(peerId, FileChunkAck(t.id, c.offset));
  }

  Future<void> _onComplete(String peerId, String id) async {
    final i = _in[id];
    if (i == null || i.t.peerId != peerId) return;
    final t = i.t;
    if (t.state != TransferState.transferring) return;
    if (i.written != t.size) {
      _safeSend(peerId, FileVerified(id, false));
      await _failIn(i, 'incomplete');
      return;
    }
    t._set(TransferState.verifying, force: true);
    try {
      await i.raf?.flush();
      await i.raf?.close();
      i.raf = null;
      final h = await sha256OfFile(i.partialPath);
      if (h != t.sha256) {
        _safeSend(peerId, FileVerified(id, false));
        await _failIn(i, 'hash_mismatch', deletePartial: true);
        return;
      }
      final dest = await _moveIntoPlace(i.partialPath, t.name);
      t.savedPath = dest;
      t.bytesDone = t.size;
      _in.remove(id);
      t._set(TransferState.completed, force: true);
      _safeSend(peerId, FileVerified(id, true));
    } catch (e) {
      _safeSend(peerId, FileVerified(id, false));
      await _failIn(i, 'io_error: $e');
    }
  }

  /// Moves [src] into the downloads directory with a collision-safe name.
  Future<String> _moveIntoPlace(String src, String name) async {
    final dir = Directory(downloadsDir);
    await dir.create(recursive: true);
    final stem = p.basenameWithoutExtension(name);
    final ext = p.extension(name);
    for (var n = 0; n < 10000; n++) {
      final candidate = p.join(downloadsDir, n == 0 ? name : '$stem ($n)$ext');
      // Exclusive create reserves the name atomically.
      try {
        await File(candidate).create(exclusive: true);
      } on PathExistsException {
        continue;
      } on FileSystemException {
        if (await File(candidate).exists()) continue;
        rethrow;
      }
      try {
        await File(src).rename(candidate);
      } on FileSystemException {
        await File(src).copy(candidate);
        await File(src).delete();
      }
      return candidate;
    }
    throw FileSystemException('no free file name', name);
  }

  /// Fails all active transfers with [peerId] (connection lost). Partial
  /// downloads are kept so a later offer can resume.
  void onPeerDisconnected(String peerId) {
    for (final o in _out.values.toList()) {
      if (o.t.peerId == peerId && !o.t.isFinished) {
        o.t._set(TransferState.failed, err: 'disconnected', force: true);
        if (!o.accepted.isCompleted)
          o.accepted.completeError(_Aborted('disconnected'));
        if (!o.verified.isCompleted) o.verified.complete(false);
        o.signal();
      }
    }
    for (final i in _in.values.toList()) {
      if (i.t.peerId == peerId && !i.t.isFinished) {
        i.offerTimer?.cancel();
        i.t._set(
            i.t.state == TransferState.offered
                ? TransferState.cancelled
                : TransferState.failed,
            err: 'disconnected',
            force: true);
        unawaited(_dropIn(i, deletePartial: false));
      }
    }
  }

  /// Deletes partial downloads older than [maxAge].
  Future<void> cleanPartials(
      {Duration maxAge = const Duration(days: 7)}) async {
    final d = Directory(_partialDir);
    if (!await d.exists()) return;
    await for (final e in d.list()) {
      try {
        if (e is File &&
            DateTime.now().difference(await e.lastModified()) > maxAge) {
          await e.delete();
        }
      } catch (_) {}
    }
  }

  Future<void> dispose() async {
    for (final o in _out.values.toList()) {
      o.t._set(TransferState.cancelled, err: 'shutdown', force: true);
      if (!o.accepted.isCompleted)
        o.accepted.completeError(_Aborted('cancelled'));
      o.signal();
    }
    for (final i in _in.values.toList()) {
      i.offerTimer?.cancel();
      i.t._set(TransferState.cancelled, err: 'shutdown', force: true);
      await _dropIn(i, deletePartial: false);
    }
    await _newTransfers.close();
  }
}
