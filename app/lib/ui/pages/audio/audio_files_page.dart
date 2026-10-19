import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../audio/audio_io.dart';
import '../../../audio/audio_library.dart';
import '../../../audio/mic_recorder.dart';
import '../../../core/format.dart';
import '../../../core/theme.dart';
import '../../../l10n/l10n.dart';
import '../../../services/providers.dart';
import '../../widgets/settings_tiles.dart';

/// Settings > Audio > Audio files: hold music and announcements.
class AudioFilesPage extends StatelessWidget {
  const AudioFilesPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(context.l10n.audioFilesTitle)),
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
    final l = context.l10n;
    setState(() => _importing = true);
    try {
      final path = await ref.read(audioFilePickerProvider)();
      if (path == null) return;
      final item = await ref.read(audioLibraryProvider).import(path);
      _notice(l.audioAdded(item.name));
    } on AudioLibraryException catch (e) {
      _notice(e.message, error: true);
    } finally {
      if (mounted) setState(() => _importing = false);
    }
  }

  Future<void> _toggle(AudioItem i) async {
    final l = context.l10n;
    if (_preview.playing.value != null && _preview.playing.value == (i.path ?? i.ref)) {
      await _preview.stop();
      return;
    }
    final path = i.path ?? await ref.read(audioLibraryProvider).resolve(i.ref);
    if (path == null) {
      _notice(l.audioFileUnavailable, error: true);
      return;
    }
    await _preview.play(path);
  }

  Future<void> _rename(AudioItem i) async {
    final n = await promptText(context, title: context.l10n.actionRename, initial: i.name, validator: (v) => v.isEmpty ? context.l10n.audioNameRequired : null);
    if (n != null) await ref.read(audioLibraryProvider).rename(i.ref, n);
  }

  Future<void> _delete(AudioItem i) async {
    if (!await confirm(context, title: context.l10n.audioDeleteTitle(i.name), message: context.l10n.audioDeleteMessage)) return;
    if (_preview.playing.value == i.path) await _preview.stop();
    await ref.read(audioLibraryProvider).delete(i.ref);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final items = ref.watch(audioItemsProvider).value ?? const <AudioItem>[];
    final builtin = items.where((i) => i.builtin).toList();
    final mine = items.where((i) => !i.builtin).toList();
    return ListView(
      padding: const EdgeInsets.only(bottom: 32),
      children: [
        SettingsGroup(
          title: l.audioGroupAdd,
          footer: l.audioAddFooter,
          children: [
            ListTile(
              key: const Key('audio-import'),
              leading: const Icon(Icons.upload_file_rounded),
              title: Text(l.audioImport),
              trailing: _importing ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : null,
              onTap: _importing ? null : _import,
            ),
            const _RecorderTile(),
          ],
        ),
        SettingsGroup(
          title: l.audioGroupMine,
          children: [
            if (mine.isEmpty)
              ListTile(
                key: const Key('audio-empty'),
                leading: const Icon(Icons.library_music_outlined),
                title: Text(l.audioEmptyTitle),
                subtitle: Text(l.audioEmptyHint),
              ),
            for (final i in mine) _ItemTile(item: i, preview: _preview, onToggle: () => _toggle(i), onRename: () => _rename(i), onDelete: () => _delete(i)),
          ],
        ),
        SettingsGroup(
          title: l.audioGroupBuiltIn,
          footer: l.audioBuiltInFooter,
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
    final l = context.l10n;
    final sub = [if (item.format.isNotEmpty) item.format.toUpperCase(), _duration(item.durationMs)].where((e) => e.isNotEmpty).join('  ·  ');
    return ValueListenableBuilder<String?>(
      valueListenable: preview.playing,
      builder: (context, playing, _) {
        final on = playing != null && playing == item.path;
        return ListTile(
          key: Key('audio-${item.ref}'),
          leading: IconButton.filledTonal(
            key: Key('audio-play-${item.ref}'),
            tooltip: on ? l.audioPreviewStop : l.audioPreviewPlay(item.name),
            icon: Icon(on ? Icons.stop_rounded : Icons.play_arrow_rounded),
            onPressed: onToggle,
          ),
          title: Text(item.name, maxLines: 1, overflow: TextOverflow.ellipsis),
          subtitle: sub.isEmpty ? null : Text(sub),
          trailing: item.builtin
              ? null
              : PopupMenuButton<String>(
                  key: Key('audio-menu-${item.ref}'),
                  tooltip: l.actionMore,
                  onSelected: (v) => v == 'rename' ? onRename?.call() : onDelete?.call(),
                  itemBuilder: (_) => [
                    PopupMenuItem(value: 'rename', child: Text(l.actionRename)),
                    PopupMenuItem(value: 'delete', child: Text(l.actionDelete)),
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
    final n = await promptText(context, title: context.l10n.audioRecordedName, initial: context.l10n.audioRecordedDefaultName, validator: (v) => v.isEmpty ? context.l10n.audioNameRequired : null);
    if (n == null) return;
    final item = await _rec.save(n);
    if (item != null && mounted) ref.read(noticeProvider.notifier).show(context.l10n.audioSaved(item.name));
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final r = ref.watch(micRecorderProvider);
    final t = Theme.of(context);
    final c = context.colors;
    if (r.recording || r.phase == RecorderPhase.saving) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                  label: Text(l.audioRecorderStop),
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
            padding: const EdgeInsetsDirectional.only(start: 16, top: 8, end: 8, bottom: 8),
            child: Row(
              key: const Key('recorder-review'),
              children: [
                IconButton.filledTonal(
                  key: const Key('recorder-preview'),
                  tooltip: on ? l.audioPreviewStop : l.audioRecorderPlay,
                  icon: Icon(on ? Icons.stop_rounded : Icons.play_arrow_rounded),
                  onPressed: () => on ? _preview.stop() : _preview.play(r.file!),
                ),
                const SizedBox(width: 12),
                Expanded(child: Text(l.audioRecorderNew(formatMs(r.durationMs)))),
                TextButton(key: const Key('recorder-discard'), onPressed: () { _preview.stop(); _rec.discard(); }, child: Text(l.audioRecorderDiscard)),
                FilledButton(key: const Key('recorder-save'), onPressed: _save, child: Text(l.actionSave)),
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
          title: Text(l.audioRecordOwn),
          subtitle: Text(r.error ?? l.audioRecordOwnHint),
          subtitleTextStyle: r.error == null ? null : TextStyle(color: t.colorScheme.error),
          onTap: _rec.start,
        ),
      ],
    );
  }
}
