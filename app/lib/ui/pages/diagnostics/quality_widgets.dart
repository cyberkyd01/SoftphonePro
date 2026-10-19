import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:spcore_dart/spcore_dart.dart';

import '../../../core/theme.dart';
import '../../../l10n/l10n.dart';
import '../../../models/call_record.dart';
import '../../widgets/basic_widgets.dart';

Color mosColor(BuildContext context, double mos) {
  final c = context.colors;
  if (mos <= 0) return c.disabled;
  if (mos >= 4.0) return c.regOk;
  if (mos >= 3.5) return c.regWarn;
  return c.regFail;
}

/// Semi-circular MOS gauge (1.0 - 5.0).
class MosGauge extends StatelessWidget {
  const MosGauge({super.key, required this.mos, this.size = 150});
  final double mos;
  final double size;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final color = mosColor(context, mos);
    return Semantics(
      label: context.l10n.diagQualityMosSemantics(mos > 0 ? mos.toStringAsFixed(1) : context.l10n.diagQualityMeasuring, QualityIndicator.labelFor(mos, context.l10n)),
      child: SizedBox(
        width: size,
        height: size * 0.62,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _GaugePainter(
                  value: mos <= 0 ? 0 : ((mos - 1) / 4).clamp(0, 1).toDouble(),
                  color: color,
                  track: t.colorScheme.outlineVariant,
                ),
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(mos > 0 ? mos.toStringAsFixed(1) : '--', style: tabular(t.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700, color: color))),
                Text(QualityIndicator.labelFor(mos, context.l10n), style: t.textTheme.labelMedium?.copyWith(color: t.colorScheme.onSurfaceVariant)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  _GaugePainter({required this.value, required this.color, required this.track});
  final double value;
  final Color color;
  final Color track;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = size.width * 0.075;
    final rect = Rect.fromCenter(center: Offset(size.width / 2, size.height - stroke / 2), width: size.width - stroke, height: (size.width - stroke));
    final base = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = track;
    canvas.drawArc(rect, math.pi, math.pi, false, base);
    if (value > 0) canvas.drawArc(rect, math.pi, math.pi * value, false, base..color = color);
  }

  @override
  bool shouldRepaint(_GaugePainter o) => o.value != value || o.color != color || o.track != track;
}

/// Lightweight line chart of one metric over the call.
class QualityChart extends StatelessWidget {
  const QualityChart({
    super.key,
    required this.title,
    required this.values,
    required this.color,
    this.unit = '',
    this.minY,
    this.maxY,
    this.height = 84,
    this.decimals = 1,
  });
  final String title;
  final List<double> values;
  final Color color;
  final String unit;
  final double? minY;
  final double? maxY;
  final double height;
  final int decimals;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final l = context.l10n;
    final last = values.isEmpty ? null : values.last;
    final mx = values.isEmpty ? 0.0 : values.reduce(math.max);
    return Semantics(
      label: last == null ? l.diagQualityChartSemantics(title) : l.diagQualityChartSemanticsLatest(title, '${last.toStringAsFixed(decimals)} $unit'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(title, style: t.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600)),
              const Spacer(),
              Text(
                last == null ? '--' : l.diagQualityLatestMax('${last.toStringAsFixed(decimals)} $unit', mx.toStringAsFixed(decimals)),
                style: tabular(t.textTheme.labelMedium?.copyWith(color: t.colorScheme.onSurfaceVariant)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          SizedBox(
            height: height,
            width: double.infinity,
            child: CustomPaint(
              painter: _LinePainter(values: values, color: color, grid: t.colorScheme.outlineVariant, minY: minY, maxY: maxY),
            ),
          ),
        ],
      ),
    );
  }
}

class _LinePainter extends CustomPainter {
  _LinePainter({required this.values, required this.color, required this.grid, this.minY, this.maxY});
  final List<double> values;
  final Color color;
  final Color grid;
  final double? minY;
  final double? maxY;

  @override
  void paint(Canvas canvas, Size size) {
    final gp = Paint()
      ..color = grid.withValues(alpha: 0.6)
      ..strokeWidth = 1;
    for (var i = 0; i <= 2; i++) {
      final y = size.height * i / 2;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gp);
    }
    if (values.length < 2) return;
    var lo = minY ?? values.reduce(math.min);
    var hi = maxY ?? values.reduce(math.max);
    if (maxY == null && hi < lo + 1e-6) hi = lo + 1;
    if (hi - lo < 1e-6) hi = lo + 1;
    if (maxY == null) hi = hi + (hi - lo) * 0.1;
    if (minY == null) lo = math.min(lo, 0);
    final path = Path();
    final fill = Path();
    for (var i = 0; i < values.length; i++) {
      final x = size.width * i / (values.length - 1);
      final y = size.height - size.height * ((values[i] - lo) / (hi - lo)).clamp(0.0, 1.0);
      if (i == 0) {
        path.moveTo(x, y);
        fill.moveTo(x, size.height);
        fill.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fill.lineTo(x, y);
      }
    }
    fill
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(fill, Paint()..color = color.withValues(alpha: 0.12));
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_LinePainter o) => o.values != values || o.color != color;
}

/// Reusable quality panel: gauge, three charts and stat chips. Works for a
/// live call ([stats] set) and for a finished one ([samples] only).
class QualityPanel extends StatelessWidget {
  const QualityPanel({super.key, required this.samples, this.stats, this.summary});
  final List<QualitySample> samples;
  final CallStats? stats;
  final QualitySummary? summary;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final l = context.l10n;
    final c = context.colors;
    final mos = stats?.mos ?? (samples.isNotEmpty ? samples.last.mos : (summary?.mosAvg ?? 0));
    final s = stats;
    Widget stat(String k, String v) => Chip(
      visualDensity: VisualDensity.compact,
      label: Text.rich(TextSpan(children: [TextSpan(text: '$k  ', style: TextStyle(color: t.colorScheme.onSurfaceVariant)), TextSpan(text: v, style: const TextStyle(fontWeight: FontWeight.w600))])),
    );
    return Column(
      key: const Key('quality-panel'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(child: MosGauge(mos: mos)),
        if (summary != null && !summary!.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4, bottom: 4),
            child: Center(
              child: Text(
                l.diagQualityAvgWorst(summary!.mosAvg.toStringAsFixed(1), summary!.mosMin.toStringAsFixed(1)),
                style: t.textTheme.bodySmall?.copyWith(color: t.colorScheme.onSurfaceVariant),
              ),
            ),
          ),
        const SizedBox(height: 8),
        if (s != null)
          Wrap(
            spacing: 6,
            children: [
              stat(l.diagQualityCodec, s.codec.isEmpty ? '--' : s.codec),
              stat(l.diagQualityLoss, '${s.rx.lossPct.toStringAsFixed(1)} %'),
              stat(l.diagQualityJitter, '${s.rx.jitterMs.toStringAsFixed(1)} ms'),
              stat('RTT', '${s.rtt.lastMs.toStringAsFixed(0)} ms'),
              stat('Rx', l.diagQualityPackets(s.rx.packets)),
              stat('Tx', l.diagQualityPackets(s.tx.packets)),
              stat(l.diagQualityMedia, s.srtp ? 'SRTP' : 'RTP'),
              if (s.ice.state != 'none') stat('ICE', s.ice.state),
            ],
          ),
        const SizedBox(height: 12),
        if (samples.length < 2 && s == null)
          Text(l.diagQualityNoSeries, style: t.textTheme.bodySmall?.copyWith(color: t.colorScheme.onSurfaceVariant))
        else ...[
          QualityChart(title: 'MOS', values: [for (final q in samples) q.mos], color: mosColor(context, mos), minY: 1, maxY: 5),
          const SizedBox(height: 12),
          QualityChart(title: l.diagQualityJitter, unit: 'ms', values: [for (final q in samples) q.jitter], color: c.holdAmber),
          const SizedBox(height: 12),
          QualityChart(title: l.diagQualityPacketLoss, unit: '%', values: [for (final q in samples) q.loss], color: c.regFail, decimals: 2),
          const SizedBox(height: 12),
          QualityChart(title: l.diagQualityRtt, unit: 'ms', values: [for (final q in samples) q.rtt], color: t.colorScheme.primary, decimals: 0),
        ],
      ],
    );
  }
}
