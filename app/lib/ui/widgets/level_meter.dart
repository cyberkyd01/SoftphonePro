import 'package:flutter/material.dart';

import '../../audio/audio_levels.dart';
import '../../core/theme.dart';

/// Segmented level bar with a peak marker (green, amber near the top, red at
/// the top). Fills in the reading direction. Repaints only itself, and only when the value or peak moves: it listens
/// to its [channel] directly, so the surrounding widgets never rebuild at 15 Hz.
class LevelMeter extends StatelessWidget {
  const LevelMeter({
    super.key,
    required this.channel,
    required this.label,
    this.height = 8,
  });

  final MeterChannel channel;

  /// Accessibility label, for example "Microphone level".
  final String label;
  final double height;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      label: label,
      container: true,
      child: ExcludeSemantics(
        child: RepaintBoundary(
          child: CustomPaint(
            size: Size.fromHeight(height),
            painter: LevelMeterPainter(
              channel: channel,
              
              rtl: Directionality.of(context) == TextDirection.rtl,
              low: c.callGreen,
              mid: c.holdAmber,
              high: c.endRed,
              off: scheme.onSurface.withValues(alpha: 0.10),
            ),
          ),
        ),
      ),
    );
  }
}

class LevelMeterPainter extends CustomPainter {
  LevelMeterPainter({
    required this.channel,
    required this.rtl,
    required this.low,
    required this.mid,
    required this.high,
    required this.off,
  }) : super(repaint: channel);

  final MeterChannel channel;
  final bool rtl;
  final Color low, mid, high, off;

  /// Fractions of the scale where amber and red start.
  static const midFrom = 0.7;
  static const highFrom = 0.9;

  static const _segW = 5.0;
  static const _gap = 2.0;

  Color colorAt(double f) => f >= highFrom ? high : (f >= midFrom ? mid : low);

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;
    final n = ((size.width + _gap) / (_segW + _gap)).floor().clamp(8, 64);
    final segW = (size.width - _gap * (n - 1)) / n;
    final lit = (channel.level * n).ceil().clamp(0, n);
    final peakIdx = channel.peak > 0.02 ? (channel.peak * n).ceil().clamp(1, n) - 1 : -1;
    final paint = Paint();
    for (var i = 0; i < n; i++) {
      final x = i * (segW + _gap);
      final left = rtl ? size.width - x - segW : x;
      final f = (i + 1) / n;
      final on = i < lit;
      paint.color = on || i == peakIdx ? colorAt(f) : off;
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(left, 0, segW, size.height), const Radius.circular(1.5)),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(LevelMeterPainter old) =>
      old.channel != channel || old.rtl != rtl || old.low != low || old.mid != mid || old.high != high || old.off != off;
}
