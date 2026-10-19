import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:spcore_dart/spcore_dart.dart';

import '../services/engine_controller.dart';
import '../services/ringtones.dart' show supportAssetFile;

/// A track the app ships (synthesised by tool/gen_hold_music.py).
class BuiltInTrack {
  const BuiltInTrack(this.id, this.name, this.asset, {this.holdMusic = true});
  final String id;
  final String name;
  final String asset;

  /// False for short notices (the chime), which make poor hold music.
  final bool holdMusic;
}

const List<BuiltInTrack> kBuiltInTracks = [
  BuiltInTrack('hold_calm', 'Calm (built-in)', 'assets/sounds/hold_calm.wav'),
  BuiltInTrack('hold_breeze', 'Breeze (built-in)', 'assets/sounds/hold_breeze.wav'),
  BuiltInTrack('chime', 'Notice chime (built-in)', 'assets/sounds/chime.wav', holdMusic: false),
];

const String kRefPrefixBuiltIn = 'builtin:';
const String kRefPrefixLib = 'lib:';

/// An entry in the audio library. [ref] is what settings store:
/// `builtin:<id>` or `lib:<file name>`.
class AudioItem {
  const AudioItem({
    required this.ref,
    required this.name,
    this.builtin = false,
    this.path,
    this.durationMs = 0,
    this.format = '',
    this.holdMusic = true,
  });
  final String ref;
  final String name;
  final bool builtin;

  /// Local file (null for built-ins until they are materialised).
  final String? path;
  final int durationMs;
  final String format;
  final bool holdMusic;
}

class AudioLibraryException implements Exception {
  const AudioLibraryException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// Where imported / recorded audio lives (`<app support>/audio`). Override in
/// tests.
final audioDirProvider = Provider<Future<String> Function()>(
  (ref) => () async {
    final d = await getApplicationSupportDirectory();
    final dir = Directory(p.join(d.path, 'audio'));
    await dir.create(recursive: true);
    return dir.path;
  },
);

/// Materialises a bundled asset as a file the engine can read.
final audioAssetFileProvider = Provider<Future<String?> Function(String asset)>(
  (ref) => (asset) async {
    try {
      return await supportAssetFile(asset);
    } catch (_) {
      return null;
    }
  },
);

/// Bumped whenever the library changes so listings refresh.
class AudioLibraryRevision extends Notifier<int> {
  @override
  int build() => 0;
  void bump() => state++;
}

final audioLibraryRevisionProvider =
    NotifierProvider<AudioLibraryRevision, int>(AudioLibraryRevision.new);

final audioLibraryProvider = Provider<AudioLibrary>((ref) => AudioLibrary(ref));

final audioItemsProvider = FutureProvider.autoDispose<List<AudioItem>>((ref) {
  ref.watch(audioLibraryRevisionProvider);
  return ref.read(audioLibraryProvider).list();
});

/// Hold music and announcement files: built-ins plus user files with a small
/// JSON index (`index.json`) for names and durations.
class AudioLibrary {
  AudioLibrary(this._ref);
  final Ref _ref;

  static const extensions = {'.wav', '.mp3'};
  static const _indexName = 'index.json';

  Future<String> _dir() => _ref.read(audioDirProvider)();

  Future<Map<String, Map<String, dynamic>>> _readIndex() async {
    try {
      final f = File(p.join(await _dir(), _indexName));
      if (!await f.exists()) return {};
      final j = jsonDecode(await f.readAsString());
      if (j is! Map) return {};
      return {
        for (final e in j.entries)
          if (e.value is Map) '${e.key}': Map<String, dynamic>.from(e.value as Map),
      };
    } catch (_) {
      return {};
    }
  }

  Future<void> _writeIndex(Map<String, Map<String, dynamic>> idx) async {
    final f = File(p.join(await _dir(), _indexName));
    await f.writeAsString(jsonEncode(idx), flush: true);
  }

  void _changed() => _ref.read(audioLibraryRevisionProvider.notifier).bump();

  /// Built-in tracks first, then the user's files (oldest first).
  Future<List<AudioItem>> list() async {
    final out = <AudioItem>[];
    for (final t in kBuiltInTracks) {
      out.add(
        AudioItem(
          ref: '$kRefPrefixBuiltIn${t.id}',
          name: t.name,
          builtin: true,
          holdMusic: t.holdMusic,
          format: 'wav',
          path: await _ref.read(audioAssetFileProvider)(t.asset),
        ),
      );
    }
    final dir = Directory(await _dir());
    if (!await dir.exists()) return out;
    final idx = await _readIndex();
    final files = [
      for (final e in await dir.list().toList())
        if (e is File && extensions.contains(p.extension(e.path).toLowerCase())) e,
    ];
    final user = <(int, AudioItem)>[];
    for (final f in files) {
      final base = p.basename(f.path);
      final m = idx[base] ?? const {};
      user.add((
        (m['added'] as num?)?.toInt() ?? f.statSync().modified.millisecondsSinceEpoch,
        AudioItem(
          ref: '$kRefPrefixLib$base',
          name: (m['name'] as String?) ?? p.basenameWithoutExtension(base),
          path: f.path,
          durationMs: (m['durationMs'] as num?)?.toInt() ?? 0,
          format: (m['format'] as String?) ?? p.extension(base).substring(1).toLowerCase(),
        ),
      ));
    }
    user.sort((a, b) => a.$1.compareTo(b.$1));
    return [...out, for (final u in user) u.$2];
  }

  Future<AudioItem?> find(String ref) async {
    for (final i in await list()) {
      if (i.ref == ref) return i;
    }
    return null;
  }

  /// Local file for an audio ref (null when the ref is empty or the file is
  /// gone).
  Future<String?> resolve(String ref) async {
    if (ref.isEmpty) return null;
    if (ref.startsWith(kRefPrefixBuiltIn)) {
      final id = ref.substring(kRefPrefixBuiltIn.length);
      for (final t in kBuiltInTracks) {
        if (t.id == id) return _ref.read(audioAssetFileProvider)(t.asset);
      }
      return null;
    }
    if (ref.startsWith(kRefPrefixLib)) {
      final f = File(p.join(await _dir(), p.basename(ref.substring(kRefPrefixLib.length))));
      return await f.exists() ? f.path : null;
    }
    // A bare path (hand-edited settings).
    return await File(ref).exists() ? ref : null;
  }

  /// Display name for a ref (falls back to the ref itself).
  Future<String> nameOf(String ref) async => (await find(ref))?.name ?? ref;

  /// Imports a WAV/MP3: validated through the engine when it is running,
  /// then copied into the library.
  Future<AudioItem> import(String source, {String? name}) async {
    final ext = p.extension(source).toLowerCase();
    if (!extensions.contains(ext)) {
      throw const AudioLibraryException('Only WAV and MP3 files can be used.');
    }
    final src = File(source);
    if (!await src.exists()) {
      throw const AudioLibraryException('That file could not be found.');
    }
    final info = await _validate(source);
    final dest = await _uniqueName(p.basenameWithoutExtension(source), ext);
    await src.copy(dest);
    return _register(dest, name ?? p.basenameWithoutExtension(source), info);
  }

  /// Adds a file the app recorded itself (already inside the library dir or
  /// anywhere on disk; it is moved into the library).
  Future<AudioItem> addRecorded(String file, {required String name, int durationMs = 0}) async {
    final f = File(file);
    if (!await f.exists()) {
      throw const AudioLibraryException('The recording was not saved.');
    }
    final dir = await _dir();
    var dest = f.path;
    if (p.dirname(f.path) != dir) {
      dest = await _uniqueName(p.basenameWithoutExtension(file), '.wav');
      await f.copy(dest);
    }
    MediaFileInfo? info;
    try {
      info = await _validate(dest);
    } on AudioLibraryException {
      rethrow;
    } catch (_) {}
    return _register(dest, name, info ?? MediaFileInfo(format: 'wav', durationMs: durationMs));
  }

  Future<MediaFileInfo> _validate(String file) async {
    final ctl = _ref.read(engineProvider.notifier);
    if (!ctl.hasEngine) {
      return MediaFileInfo(format: p.extension(file).substring(1).toLowerCase());
    }
    try {
      final info = await ctl.engine.fileInfo(file);
      if (info.durationMs <= 0 && info.format.isEmpty) {
        throw const AudioLibraryException('This audio file is empty or unreadable.');
      }
      return info;
    } on EngineException catch (e) {
      if (e.error.code == ErrorCode.unsupported) {
        // Old engine without media.fileInfo: trust the extension.
        return MediaFileInfo(format: p.extension(file).substring(1).toLowerCase());
      }
      throw AudioLibraryException(
        'This audio file cannot be used (${e.error.message}). Use PCM, mu-law or A-law WAV, or MP3.',
      );
    }
  }

  Future<String> _uniqueName(String base, String ext) async {
    final dir = await _dir();
    final clean = base.replaceAll(RegExp(r'[^A-Za-z0-9._ -]'), '_');
    var candidate = p.join(dir, '$clean$ext');
    var n = 2;
    while (await File(candidate).exists()) {
      candidate = p.join(dir, '$clean-$n$ext');
      n++;
    }
    return candidate;
  }

  Future<AudioItem> _register(String path, String name, MediaFileInfo info) async {
    final idx = await _readIndex();
    final base = p.basename(path);
    idx[base] = {
      'name': name.trim().isEmpty ? p.basenameWithoutExtension(base) : name.trim(),
      'durationMs': info.durationMs,
      'format': info.format,
      'added': DateTime.now().millisecondsSinceEpoch,
    };
    await _writeIndex(idx);
    _changed();
    return AudioItem(
      ref: '$kRefPrefixLib$base',
      name: idx[base]!['name'] as String,
      path: path,
      durationMs: info.durationMs,
      format: info.format,
    );
  }

  Future<void> rename(String ref, String name) async {
    if (!ref.startsWith(kRefPrefixLib) || name.trim().isEmpty) return;
    final base = p.basename(ref.substring(kRefPrefixLib.length));
    final idx = await _readIndex();
    idx[base] = {...?idx[base], 'name': name.trim()};
    await _writeIndex(idx);
    _changed();
  }

  Future<void> delete(String ref) async {
    if (!ref.startsWith(kRefPrefixLib)) return;
    final base = p.basename(ref.substring(kRefPrefixLib.length));
    final f = File(p.join(await _dir(), base));
    if (await f.exists()) await f.delete();
    final idx = await _readIndex();
    if (idx.remove(base) != null) await _writeIndex(idx);
    _changed();
  }

  /// Where a new recording should be written (not yet in the index).
  Future<String> newRecordingPath() async {
    final t = DateTime.now();
    String two(int n) => n.toString().padLeft(2, '0');
    return _uniqueName(
      'Recording ${t.year}-${two(t.month)}-${two(t.day)} ${two(t.hour)}.${two(t.minute)}.${two(t.second)}',
      '.wav',
    );
  }
}
