import 'package:flutter/material.dart';

import '../../../diagnostics/sip_dialogs.dart';
import '../../../diagnostics/sip_message.dart';
import 'trace_style.dart';

const double _kRowH = 52;
const double _kTimeW = 66;

/// Ladder (sequence) diagram of one SIP dialog.
class LadderDiagram extends StatelessWidget {
  const LadderDiagram({super.key, required this.ladder, required this.onTap});
  final Ladder ladder;
  final void Function(SipMessage) onTap;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return LayoutBuilder(
      builder: (context, c) {
        final lanes = ladder.lanes.length;
        final minLane = 150.0;
        final width = (c.maxWidth).clamp(_kTimeW + minLane * lanes, double.infinity).toDouble();
        final laneW = (width - _kTimeW) / lanes;
        double laneX(int i) => _kTimeW + laneW * (i + 0.5);
        final body = SizedBox(
          width: width,
          child: Column(
            children: [
              // Lane headers
              SizedBox(
                height: 44,
                child: Stack(
                  children: [
                    for (var i = 0; i < lanes; i++)
                      Positioned(
                        left: laneX(i) - laneW / 2 + 4,
                        width: laneW - 8,
                        top: 4,
                        child: Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
                          decoration: BoxDecoration(
                            color: i == 0 ? t.colorScheme.primaryContainer : t.colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            i == 0 ? 'Local\n${ladder.lanes[0]}' : ladder.lanes[i],
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: t.textTheme.labelSmall?.copyWith(fontFamily: kMono, fontSize: 10.5, height: 1.15),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: ladder.arrows.length,
                  itemExtent: _kRowH,
                  itemBuilder: (context, i) => _LadderRow(
                    key: Key('ladder-row-$i'),
                    arrow: ladder.arrows[i],
                    first: i == 0,
                    lanes: lanes,
                    width: width,
                    laneX: laneX,
                    onTap: onTap,
                  ),
                ),
              ),
            ],
          ),
        );
        if (width <= c.maxWidth + 0.5) return body;
        return SingleChildScrollView(scrollDirection: Axis.horizontal, child: SizedBox(width: width, height: c.maxHeight, child: body));
      },
    );
  }
}

class _LadderRow extends StatelessWidget {
  const _LadderRow({super.key, required this.arrow, required this.first, required this.lanes, required this.width, required this.laneX, required this.onTap});
  final LadderArrow arrow;
  final bool first;
  final int lanes;
  final double width;
  final double Function(int) laneX;
  final void Function(SipMessage) onTap;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final m = arrow.message;
    final color = sipColor(m, context);
    final xa = laneX(arrow.fromLane);
    final xb = laneX(arrow.toLane);
    final left = xa < xb ? xa : xb;
    final right = xa < xb ? xb : xa;
    return Semantics(
      button: true,
      label: '${m.outgoing ? 'Sent' : 'Received'} ${m.longLabel}',
      child: InkWell(
        onTap: () => onTap(m),
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _RowPainter(
                  lanes: [for (var i = 0; i < lanes; i++) laneX(i)],
                  from: xa,
                  to: xb,
                  color: color,
                  line: t.colorScheme.outlineVariant,
                  errorMark: m.isError,
                ),
              ),
            ),
            Positioned(
              left: 4,
              width: _kTimeW - 8,
              top: 8,
              child: Text(
                first ? clockLabel(m.time).substring(0, 8) : deltaLabel(arrow.delta),
                style: t.textTheme.labelSmall?.copyWith(fontFamily: kMono, fontSize: 10, color: t.colorScheme.onSurfaceVariant),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Positioned(
              left: left + 6,
              width: (right - left - 12).clamp(40, double.infinity),
              top: 6,
              child: Text(
                m.longLabel,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: t.textTheme.labelMedium?.copyWith(color: color, fontWeight: FontWeight.w700, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RowPainter extends CustomPainter {
  _RowPainter({required this.lanes, required this.from, required this.to, required this.color, required this.line, required this.errorMark});
  final List<double> lanes;
  final double from;
  final double to;
  final Color color;
  final Color line;
  final bool errorMark;

  @override
  void paint(Canvas canvas, Size size) {
    final life = Paint()
      ..color = line
      ..strokeWidth = 1.2;
    for (final x in lanes) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), life);
    }
    final y = size.height * 0.68;
    final p = Paint()
      ..color = color
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(from, y), Offset(to, y), p);
    final dir = to >= from ? 1.0 : -1.0;
    final head = Path()
      ..moveTo(to, y)
      ..lineTo(to - 8 * dir, y - 5)
      ..lineTo(to - 8 * dir, y + 5)
      ..close();
    canvas.drawPath(head, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_RowPainter o) => o.from != from || o.to != to || o.color != color || o.lanes.length != lanes.length || o.line != line;
}
