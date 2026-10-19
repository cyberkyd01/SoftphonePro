import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../audio/audio_library.dart';
import '../../widgets/settings_tiles.dart';

/// Dropdown of the audio library for settings. [leading] adds fixed
/// choices first (for example `pbx` or `inherit`); [value] is an audio ref.
class AudioRefTile extends ConsumerWidget {
  const AudioRefTile({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
    this.leading = const {},
    this.subtitle,
    this.icon,
    this.holdMusicOnly = false,
  });
  final String title;
  final String? subtitle;
  final String value;
  final ValueChanged<String> onChanged;
  final Map<String, String> leading;
  final IconData? icon;
  final bool holdMusicOnly;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(audioItemsProvider).value ?? const <AudioItem>[];
    final opts = <String, String>{
      ...leading,
      for (final i in items)
        if (!holdMusicOnly || i.holdMusic) i.ref: i.name,
    };
    if (value.isNotEmpty && !opts.containsKey(value) && items.isNotEmpty) {
      opts[value] = 'Missing file';
    }
    return SelectTile<String>(
      icon: icon,
      title: title,
      subtitle: subtitle,
      value: value,
      options: opts,
      onChanged: onChanged,
    );
  }
}
