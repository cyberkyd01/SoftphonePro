import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme.dart';
import '../../l10n/l10n.dart';

const _letters = {
  '1': '',
  '2': 'ABC',
  '3': 'DEF',
  '4': 'GHI',
  '5': 'JKL',
  '6': 'MNO',
  '7': 'PQRS',
  '8': 'TUV',
  '9': 'WXYZ',
  '*': '',
  '0': '+',
  '#': '',
};

/// 3x4 dial pad. Long-press 0 gives `+`, long-press 1 calls voicemail.
class DialPad extends StatelessWidget {
  const DialPad({
    super.key,
    required this.onDigit,
    this.onVoicemail,
    this.onLongPressDigit,
    this.compact = false,
    this.maxWidth = 320,
  });

  final void Function(String digit) onDigit;
  final VoidCallback? onVoicemail;

  /// Long-press on digits 1-9 (speed dial). Takes precedence over
  /// [onVoicemail] for `1` when set.
  final void Function(String digit)? onLongPressDigit;
  final bool compact;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    const rows = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['*', '0', '#'],
    ];
    // The 1-2-3 layout never mirrors, even in right-to-left languages.
    return Directionality(
      textDirection: TextDirection.ltr,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: LayoutBuilder(
          builder: (context, box) {
            // Keys shrink in a narrow column instead of overflowing.
            final maxKey = box.maxWidth.isFinite ? box.maxWidth / 3 - 4 : null;
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final r in rows)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: compact ? 3 : 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        for (final d in r)
                          DialKey(
                            digit: d,
                            compact: compact,
                            maxSize: maxKey,
                            onTap: () => onDigit(d),
                            speedDial:
                                onLongPressDigit != null &&
                                RegExp(r'[1-9]').hasMatch(d),
                            onLongPress: d == '0'
                                ? () => onDigit('+')
                                : (onLongPressDigit != null &&
                                          RegExp(r'[1-9]').hasMatch(d)
                                      ? () => onLongPressDigit!(d)
                                      : (d == '1' && onVoicemail != null
                                            ? onVoicemail
                                            : null)),
                          ),
                      ],
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class DialKey extends StatelessWidget {
  const DialKey({
    super.key,
    required this.digit,
    required this.onTap,
    this.onLongPress,
    this.compact = false,
    this.speedDial = false,
    this.maxSize,
  });
  final String digit;
  final double? maxSize;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final bool compact;
  final bool speedDial;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final base = compact ? 64.0 : 76.0;
    final size = maxSize == null || maxSize! >= base
        ? base
        : maxSize!.clamp(40.0, base);
    final letters = _letters[digit] ?? '';
    final l = context.l10n;
    return Semantics(
      button: true,
      label: digit == '*'
          ? l.dialKeyStar
          : (digit == '#' ? l.dialKeyPound : digit),
      hint: digit == '0'
          ? l.dialKeyLongPressPlus
          : (speedDial
                ? l.dialKeyLongPressSpeedDial
                : (digit == '1' && onLongPress != null
                      ? l.dialKeyLongPressVoicemail
                      : null)),
      excludeSemantics: true,
      child: Material(
        color: context.colors.card,
        shape: CircleBorder(
          side: BorderSide(
            color: t.colorScheme.outlineVariant.withValues(alpha: 0.7),
          ),
        ),
        child: InkResponse(
          onTap: () {
            HapticFeedback.selectionClick();
            onTap();
          },
          onLongPress: onLongPress == null
              ? null
              : () {
                  HapticFeedback.mediumImpact();
                  onLongPress!();
                },
          customBorder: const CircleBorder(),
          radius: size / 2 + 6,
          child: SizedBox(
            width: size,
            height: size,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  digit,
                  style: tabular(
                    t.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w500,
                      height: 1.0,
                      fontSize: digit == '*' ? 30 : 26,
                    ),
                  ),
                ),
                SizedBox(
                  height: 12,
                  child: Text(
                    letters,
                    style: t.textTheme.labelSmall?.copyWith(
                      color: t.colorScheme.onSurfaceVariant,
                      letterSpacing: 1.2,
                      fontSize: 9.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Circular toggle with a label (Mute, Hold, ...).
class CallActionButton extends StatelessWidget {
  const CallActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.active = false,
    this.activeColor,
    this.enabled = true,
    this.size = 62,
  });
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final bool active;
  final Color? activeColor;
  final bool enabled;
  final double size;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final on = activeColor ?? t.colorScheme.primary;
    final bg = active ? on : t.colorScheme.surfaceContainerHigh;
    final fg = active ? Colors.white : t.colorScheme.onSurface;
    final isOn = enabled && onPressed != null;
    return Semantics(
      button: true,
      toggled: active,
      enabled: isOn,
      label: label,
      excludeSemantics: true,
      child: Opacity(
        opacity: isOn ? 1 : 0.4,
        child: InkWell(
          onTap: isOn ? onPressed : null,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
                  child: Icon(icon, color: fg, size: 26),
                ),
                const SizedBox(height: 6),
                Text(
                  label,
                  style: t.textTheme.labelMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class RoundCallButton extends StatelessWidget {
  const RoundCallButton({
    super.key,
    required this.icon,
    required this.color,
    required this.onPressed,
    required this.label,
    this.size = 68,
    this.showLabel = false,
  });
  final IconData icon;
  final Color color;
  final VoidCallback? onPressed;
  final String label;
  final double size;
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: Tooltip(
        message: label,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Material(
              color: color,
              shape: const CircleBorder(),
              elevation: 0,
              child: InkResponse(
                onTap: onPressed,
                customBorder: const CircleBorder(),
                radius: size / 2 + 8,
                child: SizedBox(
                  width: size,
                  height: size,
                  child: Icon(icon, color: Colors.white, size: size * 0.44),
                ),
              ),
            ),
            if (showLabel) ...[
              const SizedBox(height: 8),
              Text(label, style: Theme.of(context).textTheme.labelLarge),
            ],
          ],
        ),
      ),
    );
  }
}
