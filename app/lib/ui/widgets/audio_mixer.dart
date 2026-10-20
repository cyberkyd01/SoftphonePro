import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../audio/audio_io.dart';
import '../../audio/audio_levels.dart';
import '../../audio/audio_platform.dart';
import '../../audio/audio_library.dart';
import '../../audio/device_labels.dart';
import '../../audio/musicbed.dart';
import '../../core/theme.dart';
import '../../l10n/l10n.dart';
import '../../models/app_settings.dart';
import '../../platform/platform_services.dart';
import '../../services/providers.dart';
import '../../services/settings_controller.dart';
import 'call_widgets.dart';
import 'level_meter.dart';

class _Flag extends Notifier<bool> {
  @override
  bool build() => false;
  void set(bool v) => state = v;
}

/// The mixer strip on the keypad / call screens is open (phone).
final mixerStripOpenProvider = NotifierProvider<_Flag, bool>(_Flag.new);

/// The compact mixer shows device pickers and musicbed controls.
final mixerDetailsOpenProvider = NotifierProvider<_Flag, bool>(_Flag.new);

/// Output routes the phone offers right now (earpiece, speaker, Bluetooth...).
final availableRoutesProvider = FutureProvider.autoDispose<Set<AudioRoute>>((ref) {
  ref.watch(audioRouteProvider);
  return ref.watch(platformServicesProvider).availableAudioRoutes();
});

bool _mobile(WidgetRef ref) => ref.watch(platformServicesProvider).ringsViaOs || isMobilePlatform;

String _pct(double v) => '${(v * 100).round()}%';

void _set(WidgetRef ref, Map<String, dynamic> m) => ref.read(settingsProvider.notifier).update(m);

/// Level bars and sliders for the microphone, the speaker / headphones and the
/// musicbed, with the input / output device pickers. [compact] is three slim
/// rows with an expand control for the pickers and the musicbed file; the full
/// variant shows everything. [showDevices] / [showMusicbed] let a screen that
/// already has those controls elsewhere (Settings) leave them out.
class AudioMixer extends ConsumerWidget {
  const AudioMixer({super.key, this.compact = false, this.showDevices = true, this.showMusicbed = true});
  final bool compact;
  final bool showDevices;
  final bool showMusicbed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(settingsProvider);
    final meters = ref.watch(audioLevelsProvider);
    final l = context.l10n;
    final mobile = _mobile(ref);
    final details = compact && ref.watch(mixerDetailsOpenProvider);
    final hasMore = showDevices || showMusicbed;
    final bed = _MusicbedBlock(settings: s, meters: meters, compact: compact, extras: !compact || details);

    final mic = _Channel(
      compact: compact,
      icon: Icons.mic_rounded,
      title: l.mixerMicrophone,
      sliderLabel: l.mixerMicVolume,
      sliderKey: const Key('mixer-mic-slider'),
      value: s.micLevel,
      max: 2,
      channel: meters.mic,
      onChanged: (v) => _set(ref, {'micLevel': v}),
    );
    final speaker = _Channel(
      compact: compact,
      icon: Icons.headphones_rounded,
      title: l.mixerSpeaker,
      sliderLabel: l.mixerSpeakerVolume,
      sliderKey: const Key('mixer-speaker-slider'),
      value: s.speakerLevel,
      max: 2,
      channel: meters.speaker,
      onChanged: (v) => _set(ref, {'speakerLevel': v}),
    );
    final micDevice = showDevices && (!compact || details)
        ? (mobile
              ? null
              : _DevicePicker(
                  key: const Key('mixer-input-device'),
                  icon: Icons.mic_none_rounded,
                  label: l.mixerInputDevice,
                  field: 'captureDev',
                  value: s.captureDev,
                  capture: true,
                ))
        : null;
    final speakerDevice = showDevices && (!compact || details)
        ? (mobile
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _RouteSelector(label: l.mixerOutputRoute),
                    const SizedBox(height: 6),
                    Text(
                      l.mixerInputFollowsOutput,
                      key: const Key('mixer-route-hint'),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 4),
                  ],
                )
              : _DevicePicker(
                  key: const Key('mixer-output-device'),
                  icon: Icons.speaker_rounded,
                  label: l.mixerOutputDevice,
                  field: 'playbackDev',
                  value: s.playbackDev,
                  capture: false,
                ))
        : null;

    final gap = SizedBox(height: compact ? 4 : 16);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        mic,
        if (micDevice != null) Padding(padding: const EdgeInsets.only(top: 6), child: micDevice),
        gap,
        speaker,
        if (speakerDevice != null) Padding(padding: const EdgeInsets.only(top: 6), child: speakerDevice),
        if (showMusicbed) ...[gap, bed],
        if (compact && hasMore)
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: TextButton.icon(
              key: const Key('mixer-expand'),
              style: TextButton.styleFrom(
                visualDensity: VisualDensity.compact,
                minimumSize: const Size(44, 36),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onPressed: () => ref.read(mixerDetailsOpenProvider.notifier).set(!details),
              icon: Icon(details ? Icons.expand_less_rounded : Icons.expand_more_rounded, size: 18),
              label: Text(details ? l.mixerShowLess : l.mixerShowMore, overflow: TextOverflow.ellipsis),
            ),
          ),
      ],
    );
  }
}

/// One meter + slider channel: [compact] is `icon  meter/slider  42%`; the
/// full layout puts a title and the percentage above the meter.
class _Channel extends StatelessWidget {
  const _Channel({
    required this.compact,
    required this.icon,
    required this.title,
    required this.sliderLabel,
    required this.sliderKey,
    required this.value,
    required this.max,
    required this.channel,
    required this.onChanged,
    this.leading,
    this.trailing,
  });
  final bool compact;
  final IconData icon;
  final String title;
  final String sliderLabel;
  final Key sliderKey;
  final double value;
  final double max;
  final MeterChannel channel;
  final ValueChanged<double> onChanged;

  /// Replaces the icon (the compact musicbed row uses a toggle button).
  final Widget? leading;

  /// Right side of the full header (the musicbed switch).
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final l = context.l10n;
    final meter = LevelMeter(channel: channel, label: l.mixerMeterLabel(title), height: compact ? 6 : 8);
    final slider = _MixSlider(key: sliderKey, label: sliderLabel, value: value, max: max, dense: compact, onChanged: onChanged);
    final pct = Text(_pct(value), style: tabular(t.textTheme.labelMedium));
    if (compact) {
      return Row(
        children: [
          leading ?? SizedBox(width: 44, child: Icon(icon, size: 20, color: t.colorScheme.onSurfaceVariant)),
          Expanded(
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [meter, slider]),
          ),
          SizedBox(
            width: 48,
            child: Align(alignment: AlignmentDirectional.centerEnd, child: FittedBox(fit: BoxFit.scaleDown, child: pct)),
          ),
        ],
      );
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: t.colorScheme.onSurfaceVariant),
            const SizedBox(width: 8),
            Expanded(
              child: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: t.textTheme.titleSmall),
            ),
            if (trailing != null) trailing!,
            const SizedBox(width: 8),
            pct,
          ],
        ),
        const SizedBox(height: 8),
        meter,
        slider,
      ],
    );
  }
}

class _MixSlider extends StatelessWidget {
  const _MixSlider({super.key, required this.label, required this.value, required this.max, required this.onChanged, this.dense = false});
  final String label;
  final double value;
  final double max;
  final bool dense;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final slider = MergeSemantics(
      child: Semantics(
        label: label,
        child: Slider(
          // No horizontal inset: the track ends line up with the meter above.
          padding: const EdgeInsets.symmetric(vertical: 4),
          value: value.clamp(0.0, max).toDouble(),
          max: max,
          onChanged: onChanged,
          semanticFormatterCallback: _pct,
        ),
      ),
    );
    if (!dense) return slider;
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        trackHeight: 3,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
      ),
      child: SizedBox(height: 28, child: slider),
    );
  }
}

/// Desktop: dropdown of the engine's capture or playback devices; the choice
/// is saved in [field] and applied by the engine controller.
class _DevicePicker extends ConsumerWidget {
  const _DevicePicker({super.key, required this.icon, required this.label, required this.field, required this.value, required this.capture});
  final IconData icon;
  final String label;
  final String field;
  final String value;
  final bool capture;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dev = ref.watch(audioDevicesProvider).value;
    final opts = audioDeviceOptions(context.l10n, capture ? dev?.capture : dev?.playback);
    final current = opts[value] ?? opts['default']!;
    final t = Theme.of(context);
    return Semantics(
      label: label,
      value: current,
      button: true,
      excludeSemantics: true,
      child: PopupMenuButton<String>(
        tooltip: label,
        onSelected: (v) => _set(ref, {field: v}),
        itemBuilder: (_) => [
          for (final e in opts.entries)
            PopupMenuItem<String>(
              key: Key('$field-${e.key}'),
              value: e.key,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 280),
                child: Text(e.value, maxLines: 2, overflow: TextOverflow.ellipsis, style: e.key == (opts.containsKey(value) ? value : 'default') ? const TextStyle(fontWeight: FontWeight.w700) : null),
              ),
            ),
        ],
        child: Container(
          constraints: const BoxConstraints(minHeight: 40),
          padding: const EdgeInsetsDirectional.only(start: 10, end: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: t.colorScheme.outlineVariant),
          ),
          child: Row(
            children: [
              Icon(icon, size: 18, color: t.colorScheme.onSurfaceVariant),
              const SizedBox(width: 8),
              Expanded(child: Text(current, maxLines: 1, overflow: TextOverflow.ellipsis, style: t.textTheme.bodyMedium)),
              Icon(Icons.arrow_drop_down_rounded, color: t.colorScheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

/// Mobile: earpiece / speaker / Bluetooth / wired as chips.
class _RouteSelector extends ConsumerWidget {
  const _RouteSelector({required this.label});
  final String label;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final platform = ref.watch(platformServicesProvider);
    final cur = ref.watch(audioRouteProvider).value ?? AudioRoute.earpiece;
    final routes = ref.watch(availableRoutesProvider).value ?? const {AudioRoute.earpiece, AudioRoute.speaker};
    final l = context.l10n;
    return Semantics(
      container: true,
      label: label,
      child: Wrap(
        spacing: 8,
        runSpacing: 4,
        children: [
          for (final r in AudioRoute.values.where(routes.contains))
            ChoiceChip(
              key: Key('mixer-route-${r.name}'),
              avatar: Icon(audioRouteIcon(r), size: 18),
              label: Text(audioRouteLabel(l, r)),
              selected: r == cur,
              showCheckmark: false,
              visualDensity: VisualDensity.compact,
              onSelected: (_) => platform.setAudioRoute(r),
            ),
        ],
      ),
    );
  }
}

/// Musicbed channel: switch, meter, volume, file chip and "hear it myself".
class _MusicbedBlock extends ConsumerWidget {
  const _MusicbedBlock({required this.settings, required this.meters, required this.compact, required this.extras});
  final AppSettings settings;
  final AudioMeters meters;
  final bool compact;

  /// Show the file chip and the monitor controls.
  final bool extras;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = settings;
    final l = context.l10n;
    final t = Theme.of(context);
    Future<void> toggle(bool on) => toggleMusicbed(context, ref, on);

    final leading = compact
        ? SizedBox(
            width: 44,
            child: IconButton(
              key: const Key('mixer-musicbed-switch'),
              isSelected: s.musicbedEnabled,
              tooltip: l.musicbedPlay,
              visualDensity: VisualDensity.compact,
              icon: const Icon(Icons.music_note_outlined, size: 20),
              selectedIcon: Icon(Icons.music_note_rounded, size: 20, color: t.colorScheme.primary),
              onPressed: () => toggle(!s.musicbedEnabled),
            ),
          )
        : null;
    final switchW = compact
        ? null
        : Semantics(
            label: l.musicbedPlay,
            child: Switch(key: const Key('mixer-musicbed-switch'), value: s.musicbedEnabled, onChanged: toggle),
          );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Channel(
          compact: compact,
          icon: Icons.music_note_rounded,
          title: l.musicbedTitle,
          sliderLabel: l.musicbedVolume,
          sliderKey: const Key('mixer-musicbed-slider'),
          value: s.musicbedVolume,
          max: 2,
          channel: meters.musicbed,
          leading: leading,
          trailing: switchW,
          onChanged: (v) => _set(ref, {'musicbedVolume': v}),
        ),
        if (extras) ...[
          const SizedBox(height: 4),
          Align(alignment: AlignmentDirectional.centerStart, child: MusicbedFileChip(file: s.musicbedFile)),
          Row(
            children: [
              Expanded(
                child: Text(l.musicbedHearIt, maxLines: 2, overflow: TextOverflow.ellipsis, style: t.textTheme.bodyMedium),
              ),
              Switch(
                key: const Key('mixer-monitor-switch'),
                value: s.musicbedMonitor,
                onChanged: (v) => _set(ref, {'musicbedMonitor': v}),
              ),
            ],
          ),
          if (ref.watch(isIosProvider))
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(l.musicbedMonitorIosHint, key: const Key('mixer-monitor-ios-hint'), style: t.textTheme.bodySmall?.copyWith(color: t.colorScheme.onSurfaceVariant)),
            ),
          if (s.musicbedMonitor)
            Row(
              children: [
                Icon(Icons.hearing_rounded, size: 18, color: t.colorScheme.onSurfaceVariant),
                const SizedBox(width: 8),
                Expanded(
                  child: _MixSlider(
                    key: const Key('mixer-monitor-slider'),
                    label: l.musicbedMonitorVolume,
                    value: s.musicbedMonitorVolume,
                    max: 1,
                    dense: true,
                    onChanged: (v) => _set(ref, {'musicbedMonitorVolume': v}),
                  ),
                ),
                SizedBox(
                  width: 48,
                  child: Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: FittedBox(fit: BoxFit.scaleDown, child: Text(_pct(s.musicbedMonitorVolume), style: tabular(t.textTheme.labelMedium))),
                  ),
                ),
              ],
            ),
        ],
      ],
    );
  }
}

/// Chip with the musicbed file's name; tap to choose another one.
class MusicbedFileChip extends ConsumerWidget {
  const MusicbedFileChip({super.key, required this.file});
  final String file;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final items = ref.watch(audioItemsProvider).value ?? const <AudioItem>[];
    final item = items.where((i) => i.ref == file).firstOrNull;
    final name = file.isEmpty ? l.musicbedChooseFile : (item?.name ?? (items.isEmpty ? file : l.audioMissingFile));
    return Semantics(
      button: true,
      excludeSemantics: true,
      label: l.musicbedChangeFile(name),
      child: ActionChip(
        key: const Key('mixer-musicbed-file'),
        avatar: const Icon(Icons.library_music_rounded, size: 18),
        label: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis),
        visualDensity: VisualDensity.compact,
        onPressed: () async {
          final ref0 = await chooseMusicbedFile(context, ref);
          if (ref0 != null) _set(ref, {'musicbedFile': ref0});
        },
      ),
    );
  }
}

/// Bottom sheet listing the audio library plus "Add a file…". Returns the
/// chosen audio ref (null: dismissed).
Future<String?> chooseMusicbedFile(BuildContext context, WidgetRef ref) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    constraints: const BoxConstraints(maxWidth: 560),
    builder: (_) => const _FileSheet(),
  );
}

class _FileSheet extends ConsumerWidget {
  const _FileSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final items = ref.watch(audioItemsProvider).value ?? const <AudioItem>[];
    final cur = ref.watch(settingsProvider).musicbedFile;
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.7),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(l.musicbedPickerTitle, style: Theme.of(context).textTheme.titleMedium),
              ),
            ),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (final i in items)
                    ListTile(
                      key: Key('musicbed-file-${i.ref}'),
                      leading: const Icon(Icons.music_note_rounded),
                      title: Text(i.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                      trailing: i.ref == cur ? const Icon(Icons.check_rounded) : null,
                      onTap: () => Navigator.pop(context, i.ref),
                    ),
                  ListTile(
                    key: const Key('musicbed-add-file'),
                    leading: const Icon(Icons.add_rounded),
                    title: Text(l.musicbedAddFile),
                    onTap: () async {
                      final nav = Navigator.of(context);
                      final item = await importAudioFile(ref);
                      if (item != null) nav.pop(item.ref);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Asks for a file, imports it into the audio library and returns the item
/// (null: cancelled or refused, with a notice).
Future<AudioItem?> importAudioFile(WidgetRef ref) async {
  final notice = ref.read(noticeProvider.notifier);
  try {
    final path = await ref.read(audioFilePickerProvider)();
    if (path == null) return null;
    final item = await ref.read(audioLibraryProvider).import(path);
    return item;
  } on AudioLibraryException catch (e) {
    notice.error(e.message);
    return null;
  }
}

/// Switch handler shared by the mixer and Settings: turning the musicbed on
/// without a file first asks for one.
Future<void> toggleMusicbed(BuildContext context, WidgetRef ref, bool on) async {
  final s = ref.read(settingsProvider);
  if (on && s.musicbedFile.isEmpty) {
    final picked = await chooseMusicbedFile(context, ref);
    if (picked == null) return;
    return _set(ref, {'musicbedFile': picked, 'musicbedEnabled': true});
  }
  await ref.read(musicbedProvider.notifier).setEnabled(on);
}

/// Phone: a slim strip that shows the three meters in one row and opens the
/// compact mixer when tapped.
class MixerStrip extends ConsumerWidget {
  const MixerStrip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final open = ref.watch(mixerStripOpenProvider);
    final meters = ref.watch(audioLevelsProvider);
    final l = context.l10n;
    final t = Theme.of(context);
    // Opening the strip or its details inside a scrolling page brings the
    // whole strip on screen (the End button is pinned outside the scroll
    // view, so the viewport already stops above it).
    void reveal() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        final scrollable = Scrollable.maybeOf(context);
        final box = context.findRenderObject();
        final viewport = scrollable?.context.findRenderObject();
        if (box is! RenderBox || !box.hasSize || viewport is! RenderBox || !viewport.hasSize) return;
        final top = box.localToGlobal(Offset.zero, ancestor: viewport).dy;
        if (top >= 0 && top + box.size.height <= viewport.size.height) return;
        // Partly out of view: put its top at the top of the viewport (the
        // controls come first; a strip taller than the viewport scrolls on).
        Scrollable.ensureVisible(context, alignment: 0, duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
      });
    }

    ref.listen<bool>(mixerStripOpenProvider, (prev, now) {
      if (now && prev != true) reveal();
    });
    ref.listen<bool>(mixerDetailsOpenProvider, (prev, now) {
      if (now && prev != true && ref.read(mixerStripOpenProvider)) reveal();
    });
    Widget meter(IconData icon, String name, MeterChannel c) => Expanded(
      child: Row(
        children: [
          Icon(icon, size: 16, color: t.colorScheme.onSurfaceVariant),
          const SizedBox(width: 6),
          Expanded(child: LevelMeter(channel: c, label: l.mixerMeterLabel(name))),
        ],
      ),
    );
    return Material(
      color: t.colorScheme.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(kRadius),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            key: const Key('mixer-strip'),
            onTap: () => ref.read(mixerStripOpenProvider.notifier).set(!open),
            child: Semantics(
              button: true,
              expanded: open,
              label: open ? l.mixerStripHide : l.mixerStripShow,
              excludeSemantics: true,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 44),
                child: Padding(
                  padding: const EdgeInsetsDirectional.only(start: 12, end: 8),
                  child: open
                      ? Row(
                          children: [
                            Icon(Icons.tune_rounded, size: 18, color: t.colorScheme.onSurfaceVariant),
                            const SizedBox(width: 8),
                            Expanded(child: Text(l.mixerTitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: t.textTheme.titleSmall)),
                            const Icon(Icons.expand_less_rounded),
                          ],
                        )
                      : Row(
                          children: [
                            meter(Icons.mic_rounded, l.mixerMicrophone, meters.mic),
                            const SizedBox(width: 12),
                            meter(Icons.headphones_rounded, l.mixerSpeaker, meters.speaker),
                            const SizedBox(width: 12),
                            meter(Icons.music_note_rounded, l.musicbedTitle, meters.musicbed),
                            const SizedBox(width: 4),
                            const Icon(Icons.expand_more_rounded),
                          ],
                        ),
                ),
              ),
            ),
          ),
          if (open)
            const Padding(
              padding: EdgeInsets.fromLTRB(8, 0, 8, 8),
              child: AudioMixer(compact: true),
            ),
        ],
      ),
    );
  }
}

/// Desktop / tablet: the full mixer in a card (side area of the keypad and
/// call panel).
class MixerCard extends StatelessWidget {
  const MixerCard({super.key, this.maxHeight});

  /// The card scrolls when it would be taller than this.
  final double? maxHeight;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    Widget body = Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.tune_rounded, size: 18, color: t.colorScheme.onSurfaceVariant),
              const SizedBox(width: 8),
              Expanded(child: Text(context.l10n.mixerTitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: t.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600))),
            ],
          ),
          const SizedBox(height: 12),
          const AudioMixer(),
        ],
      ),
    );
    if (maxHeight != null) body = ConstrainedBox(constraints: BoxConstraints(maxHeight: maxHeight!), child: SingleChildScrollView(child: body));
    return Card(key: const Key('mixer-card'), child: body);
  }
}
