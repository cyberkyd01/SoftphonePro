import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../audio/audio_io.dart';
import '../../../audio/audio_library.dart';
import '../../../audio/mic_recorder.dart';
import '../../../core/format.dart';
import '../../../core/theme.dart';
import '../../../services/providers.dart';
import '../../widgets/settings_tiles.dart';

/// Settings > Audio > Audio files: hold music and announcements.
class AudioFilesPage extends StatelessWidget {
  const AudioFilesPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Audio files')),
    body: const AudioFilesBody(),
  );
}

String _duration(int ms) => ms <= 0 ? '' : formatMs(ms);

class AudioFilesBody extends ConsumerStatefulWidget {
  const AudioFilesBody({super.key});
  @override
  ConsumerState<AudioFilesBody> createState() => _AudioFilesBodyState();
}

class _AudioFilesBodyState extends ConsumerState<AudioFilesBody> {
  late final AudioPreview _preview;
  bool _importing = false;

  @override
  void initState() {
    super.initState();
    _preview = ref.read(audioPreviewProvider);
  }

  @override
  void dispose() {
    _preview.stop();
    super.dispose();
  }

  void _notice(String m, {bool error = false}) {
    final n = ref.read(noticeProvider.notifier);
    error ? n.error(m) : n.show(m);
  }

  Future<void> _import() async {
    setState(() => _importing = true);
    try {
      final path = await ref.read(audioFilePickerProvider)();
      if (path == null) return;
      final item = await ref.read(audioLibraryProvider).import(path);
      _notice('Added "${item.name}"');
    } on AudioLibraryException catch (e) {
      _notice(e.message, error: true);
    } finally {
      if (mounted) setState(() => _importing = false);
    }
  }

  Future<void> _toggle(AudioItem i) async {
    if (_preview.playing.value != null && _preview.playing.value == (i.path ?? i.ref)) {
      await _preview.stop();
      return;
    }
    final path = i.path ?? await ref.read(audioLibraryProvider).resolve(i.ref);
    if (path == null) {
      _notice('That file is not available.', error: true);
      return;
    }
    await _preview.play(path);
  }

  Future<void> _rename(AudioItem i) async {
    final n = await promptText(context, title: 'Rename', initial: i.name, validator: (v) => v.isEmpty ? 'Enter a name' : null);
    if (n != null) await ref.read(audioLibraryProvider).rename(i.ref, n);
  }

  Future<void> _delete(AudioItem i) async {
    if (!await confirm(context, title: 'Delete "${i.name}"?', message: 'Settings that use this file go back to the default.')) return;
    if (_preview.playing.value == i.path) await _preview.stop();
    await ref.read(audioLibraryProvider).delete(i.ref);
  }

  @override
  Widget build(BuildContext context) {
    final items = ref.watch(audioItemsProvider).value ?? const <AudioItem>[];
    final builtin = items.where((i) => i.builtin).toList();
    final mine = items.where((i) => !i.builtin).toList();
    return ListView(
      padding: const EdgeInsets.only(bottom: 32),
      children: [
        SettingsGroup(
          title: 'Add',
          footer: 'WAV (PCM, mu-law, A-law) and MP3 files work. Files are copied into the app, so the original can move.',
          children: [
            ListTile(
              key: const Key('audio-import'),
              leading: const Icon(Icons.upload_file_rounded),
              title: const Text('Import a WAV or MP3…'),
              trailing: _importing ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : null,
              onTap: _importing ? null : _import,
            ),
            const _RecorderTile(),
          ],
        ),
        SettingsGroup(
          title: 'My files',
          children: [
            if (mine.isEmpty)
              const ListTile(
                key: Key('audio-empty'),
                leading: Icon(Icons.library_music_outlined),
                title: Text('No files yet'),
                subtitle: Text('Import a file or record your own announcement.'),
              ),
            for (final i in mine) _ItemTile(item: i, preview: _preview, onToggle: () => _toggle(i), onRename: () => _rename(i), onDelete: () => _delete(i)),
          ],
        ),
        SettingsGroup(
          title: 'Built in',
          footer: 'Generated for SoftphonePro, free to use.',
          children: [
            for (final i in builtin) _ItemTile(item: i, preview: _preview, onToggle: () => _toggle(i)),
          ],
        ),
      ],
    );
  }
}

class _ItemTile extends StatelessWidget {
  const _ItemTile({required this.item, required this.preview, required this.onToggle, this.onRename, this.onDelete});
  final AudioItem item;
  final AudioPreview preview;
  final VoidCallback onToggle;
  final VoidCallback? onRename;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final sub = [if (item.format.isNotEmpty) item.format.toUpperCase(), _duration(item.durationMs)].where((e) => e.isNotEmpty).join('  ·  ');
    return ValueListenableBuilder<String?>(
      valueListenable: preview.playing,
      builder: (context, playing, _) {
        final on = playing != null && playing == item.path;
        return ListTile(
          key: Key('audio-${item.ref}'),
          leading: IconButton.filledTonal(
            key: Key('audio-play-${item.ref}'),
            tooltip: on ? 'Stop preview' : 'Preview ${item.name}',
            icon: Icon(on ? Icons.stop_rounded : Icons.play_arrow_rounded),
            onPressed: onToggle,
          ),
          title: Text(item.name, maxLines: 1, overflow: TextOverflow.ellipsis),
          subtitle: sub.isEmpty ? null : Text(sub),
          trailing: item.builtin
              ? null
              : PopupMenuButton<String>(
                  key: Key('audio-menu-${item.ref}'),
                  tooltip: 'More',
                  onSelected: (v) => v == 'rename' ? onRename?.call() : onDelete?.call(),
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'rename', child: Text('Rename')),
                    PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ],
                ),
        );
      },
    );
  }
}

/// "Record your own" with timer, level meter, preview and save.
class _RecorderTile extends ConsumerStatefulWidget {
  const _RecorderTile();
  @override
  ConsumerState<_RecorderTile> createState() => _RecorderTileState();
}

class _RecorderTileState extends ConsumerState<_RecorderTile> {
  late final AudioPreview _preview;
  late final MicRecorderController _rec;

  @override
  void initState() {
    super.initState();
    _preview = ref.read(audioPreviewProvider);
    _rec = ref.read(micRecorderProvider.notifier);
  }

  @override
  void dispose() {
    _preview.stop();
    super.dispose();
  }

  Future<void> _save() async {
    final n = await promptText(context, title: 'Name this recording', initial: 'My announcement', validator: (v) => v.isEmpty ? 'Enter a name' : null);
    if (n == null) return;
    final item = await _rec.save(n);
    if (item != null && mounted) ref.read(noticeProvider.notifier).show('Saved "${item.name}"');
  }

  @override
  Widget build(BuildContext context) {
    final r = ref.watch(micRecorderProvider);
    final t = Theme.of(context);
    final c = context.colors;
    if (r.recording || r.phase == RecorderPhase.saving) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Column(
          key: const Key('recorder-active'),
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.fiber_manual_record_rounded, color: c.endRed, size: 16),
                const SizedBox(width: 8),
                Text(formatMs(r.elapsed.inMilliseconds), key: const Key('recorder-timer'), style: t.textTheme.titleMedium?.copyWith(fontFeatures: const [FontFeature.tabularFigures()])),
                const Spacer(),
                FilledButton.icon(
                  key: const Key('recorder-stop'),
                  style: FilledButton.styleFrom(backgroundColor: c.endRed),
                  onPressed: r.recording ? _rec.stop : null,
                  icon: const Icon(Icons.stop_rounded),
                  label: const Text('Stop'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                key: const Key('recorder-level'),
                value: r.level,
                minHeight: 8,
                backgroundColor: t.colorScheme.surfaceContainerHighest,
                color: r.level > 0.85 ? c.regFail : c.regOk,
              ),
            ),
          ],
        ),
      );
    }
    if (r.file != null) {
      return ValueListenableBuilder<String?>(
        valueListenable: _preview.playing,
        builder: (context, playing, _) {
          final on = playing == r.file;
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
            child: Row(
              key: const Key('recorder-review'),
              children: [
                IconButton.filledTonal(
                  key: const Key('recorder-preview'),
                  tooltip: on ? 'Stop preview' : 'Play recording',
                  icon: Icon(on ? Icons.stop_rounded : Icons.play_arrow_rounded),
                  onPressed: () => on ? _preview.stop() : _preview.play(r.file!),
                ),
                const SizedBox(width: 12),
                Expanded(child: Text('New recording  ·  ${formatMs(r.durationMs)}')),
                TextButton(key: const Key('recorder-discard'), onPressed: () { _preview.stop(); _rec.discard(); }, child: const Text('Discard')),
                FilledButton(key: const Key('recorder-save'), onPressed: _save, child: const Text('Save')),
              ],
            ),
          );
        },
      );
    }
    return Column(
      children: [
        ListTile(
          key: const Key('audio-record'),
          leading: const Icon(Icons.mic_rounded),
          title: const Text('Record your own…'),
          subtitle: Text(r.error ?? 'Uses the microphone selected in Audio settings'),
          subtitleTextStyle: r.error == null ? null : TextStyle(color: t.colorScheme.error),
          onTap: _rec.start,
        ),
      ],
    );
  }
}
