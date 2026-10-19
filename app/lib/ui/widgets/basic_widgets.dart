import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/format.dart';
import '../../core/theme.dart';
import '../../l10n/l10n.dart';
import '../../services/accounts_controller.dart';
import '../../services/presence_controller.dart';

Color statusColor(BuildContext context, AccountStatus s) {
  final c = context.colors;
  switch (s) {
    case AccountStatus.registered:
      return c.regOk;
    case AccountStatus.registering:
      return c.regWarn;
    case AccountStatus.failed:
      return c.regFail;
    case AccountStatus.offline:
    case AccountStatus.disabled:
      return c.disabled;
  }
}

String statusLabel(AccountStatus s, AppLocalizations l) => switch (s) {
  AccountStatus.registered => l.uiStatusRegistered,
  AccountStatus.registering => l.uiStatusRegistering,
  AccountStatus.failed => l.uiStatusRegFailed,
  AccountStatus.offline => l.statusOffline,
  AccountStatus.disabled => l.uiStatusDisabled,
};

class StatusDot extends StatelessWidget {
  const StatusDot({super.key, required this.color, this.size = 10, this.pulse = false});
  final Color color;
  final double size;
  final bool pulse;

  @override
  Widget build(BuildContext context) {
    final dot = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
    if (!pulse) return ExcludeSemantics(child: dot);
    return ExcludeSemantics(child: _Pulse(color: color, size: size, child: dot));
  }
}

class _Pulse extends StatefulWidget {
  const _Pulse({required this.color, required this.size, required this.child});
  final Color color;
  final double size;
  final Widget child;
  @override
  State<_Pulse> createState() => _PulseState();
}

class _PulseState extends State<_Pulse> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, child) {
        final t = Curves.easeOutCubic.transform(_c.value);
        return Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: widget.size * (1 + 1.2 * t),
              height: widget.size * (1 + 1.2 * t),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.color.withValues(alpha: 0.35 * (1 - t)),
              ),
            ),
            child!,
          ],
        );
      },
      child: widget.child,
    );
  }
}

/// Status chip for an account: dot + name. Tooltip carries the reason.
class AccountChip extends StatelessWidget {
  const AccountChip({
    super.key,
    required this.name,
    required this.status,
    this.reason,
    this.onTap,
    this.selected = false,
    this.badge = 0,
  });
  final String name;
  final AccountStatus status;
  final String? reason;
  final VoidCallback? onTap;
  final bool selected;
  final int badge;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tip = reason ?? statusLabel(status, context.l10n);
    return Semantics(
      button: true,
      label: '$name, ${statusLabel(status, context.l10n)}${reason != null ? ', $reason' : ''}',
      child: Tooltip(
        message: tip,
        child: Material(
          color: selected ? cs.primary.withValues(alpha: 0.12) : context.colors.card,
          shape: StadiumBorder(side: BorderSide(color: selected ? cs.primary : cs.outlineVariant)),
          child: InkWell(
            customBorder: const StadiumBorder(),
            onTap: onTap,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 36),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    StatusDot(color: statusColor(context, status), pulse: status == AccountStatus.registering),
                    const SizedBox(width: 8),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 150),
                      child: Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                    ),
                    if (badge > 0) ...[
                      const SizedBox(width: 6),
                      Icon(Icons.voicemail_rounded, size: 16, color: cs.primary),
                      const SizedBox(width: 2),
                      Text('$badge', style: Theme.of(context).textTheme.labelSmall),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Initials avatar on a hashed colour with an optional BLF presence ring.
class Avatar extends StatelessWidget {
  const Avatar({
    super.key,
    required this.name,
    this.size = 44,
    this.color,
    this.lamp = LampState.unknown,
    this.icon,
  });
  final String name;
  final double size;
  final Color? color;
  final LampState lamp;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    // Unknown callers get a calm neutral tint instead of a hashed (possibly
    // alarming red) colour.
    final unknown = color == null && initialsOf(name) == '#';
    final base = color ?? (unknown ? Theme.of(context).colorScheme.onSurfaceVariant : Color(hashColor(name.isEmpty ? '#' : name)));
    final c = context.colors;
    Color? ring;
    switch (lamp) {
      case LampState.idle:
        ring = c.regOk;
      case LampState.ringing:
        ring = c.regWarn;
      case LampState.busy:
        ring = c.regFail;
      case LampState.offline:
        ring = c.disabled;
      case LampState.unknown:
        ring = null;
    }
    final avatar = Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: base.withValues(alpha: 0.16),
      ),
      child: (icon != null || initialsOf(name) == '#')
          ? Icon(icon ?? Icons.person_rounded, size: size * 0.55, color: base)
          : Text(
              initialsOf(name),
              style: TextStyle(
                color: Color.lerp(base, Theme.of(context).colorScheme.onSurface, 0.15),
                fontWeight: FontWeight.w600,
                fontSize: size * 0.38,
              ),
            ),
    );
    if (ring == null) return ExcludeSemantics(child: avatar);
    return ExcludeSemantics(
      child: Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: ring, width: 2.5),
        ),
        child: avatar,
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
  });
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: t.colorScheme.primary.withValues(alpha: 0.1),
                ),
                child: Icon(icon, size: 34, color: t.colorScheme.primary),
              ),
              const SizedBox(height: 16),
              Text(title, style: t.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600), textAlign: TextAlign.center),
              if (subtitle != null) ...[
                const SizedBox(height: 8),
                Text(
                  subtitle!,
                  style: t.textTheme.bodyMedium?.copyWith(color: t.colorScheme.onSurfaceVariant),
                  textAlign: TextAlign.center,
                ),
              ],
              if (actionLabel != null) ...[
                const SizedBox(height: 20),
                FilledButton(onPressed: onAction, child: Text(actionLabel!)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader(this.title, {super.key, this.trailing, this.padding});
  final String title;
  final Widget? trailing;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Padding(
      padding: padding ?? const EdgeInsetsDirectional.fromSTEB(16, 20, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: Semantics(
              header: true,
              child: Text(
                title.toUpperCase(),
                style: t.textTheme.labelMedium?.copyWith(
                  color: t.colorScheme.onSurfaceVariant,
                  letterSpacing: 0.8,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

/// Page title row used instead of an AppBar inside the shell.
class PageHeader extends StatelessWidget {
  const PageHeader({super.key, required this.title, this.actions = const [], this.leading, this.subtitle});
  final String title;
  final String? subtitle;
  final List<Widget> actions;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 8, 4),
      child: Row(
        children: [
          ?leading,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Semantics(
                  header: true,
                  child: Text(title, style: t.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
                ),
                if (subtitle != null)
                  Text(subtitle!, style: t.textTheme.bodySmall?.copyWith(color: t.colorScheme.onSurfaceVariant)),
              ],
            ),
          ),
          ...actions,
        ],
      ),
    );
  }
}

/// MOS quality indicator: 0-5 bars, tooltip with stats.
class QualityIndicator extends StatelessWidget {
  const QualityIndicator({super.key, required this.mos, this.tooltip, this.onTap});
  final double mos;
  final String? tooltip;
  final VoidCallback? onTap;

  static int barsFor(double mos) {
    if (mos <= 0) return 0;
    if (mos >= 4.2) return 5;
    if (mos >= 3.9) return 4;
    if (mos >= 3.5) return 3;
    if (mos >= 3.0) return 2;
    return 1;
  }

  static String labelFor(double mos, AppLocalizations l) {
    final b = barsFor(mos);
    return switch (b) { 0 => l.uiQualityMeasuring, 5 => l.uiQualityExcellent, 4 => l.uiQualityGood, 3 => l.uiQualityFair, 2 => l.uiQualityPoor, _ => l.uiQualityBad };
  }

  @override
  Widget build(BuildContext context) {
    final bars = barsFor(mos);
    final c = context.colors;
    final color = bars >= 4 ? c.regOk : (bars == 3 ? c.regWarn : (bars == 0 ? c.disabled : c.regFail));
    final off = Theme.of(context).colorScheme.outlineVariant;
    return Semantics(
      label: mos > 0 ? context.l10n.uiQualitySemanticsMos(labelFor(mos, context.l10n), mos.toStringAsFixed(1)) : context.l10n.uiQualitySemantics(labelFor(mos, context.l10n)),
      button: onTap != null,
      child: Tooltip(
        message: tooltip ?? context.l10n.uiQualityTooltip(labelFor(mos, context.l10n)),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (var i = 0; i < 5; i++)
                  Padding(
                    padding: const EdgeInsetsDirectional.only(end: 2.5),
                    child: Container(
                      width: 4.5,
                      height: 6.0 + i * 3.5,
                      decoration: BoxDecoration(
                        color: i < bars ? color : off,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                const SizedBox(width: 4),
                Text(
                  mos > 0 ? mos.toStringAsFixed(1) : '--',
                  style: tabular(Theme.of(context).textTheme.labelMedium),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class Sparkline extends StatelessWidget {
  const Sparkline({super.key, required this.values, this.height = 40, this.min = 1, this.max = 5});
  final List<double> values;
  final double height;
  final double min;
  final double max;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: _SparkPainter(values, Theme.of(context).colorScheme.primary, min, max),
      ),
    );
  }
}

class _SparkPainter extends CustomPainter {
  _SparkPainter(this.v, this.color, this.min, this.max);
  final List<double> v;
  final Color color;
  final double min;
  final double max;
  @override
  void paint(Canvas canvas, Size size) {
    if (v.length < 2) return;
    final path = Path();
    for (var i = 0; i < v.length; i++) {
      final x = size.width * i / (v.length - 1);
      final y = size.height * (1 - ((v[i] - min) / (max - min)).clamp(0.0, 1.0));
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }
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
  bool shouldRepaint(_SparkPainter old) => old.v.length != v.length || (v.isNotEmpty && old.v.isNotEmpty && old.v.last != v.last);
}

class SecureBadge extends StatelessWidget {
  const SecureBadge({super.key, required this.srtp, required this.tls});
  final bool srtp;
  final bool tls;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final full = srtp && tls;
    final l = context.l10n;
    final label = full ? l.uiSecureFull : (srtp ? l.uiSecureMedia : (tls ? l.uiSecureSignalling : l.uiSecureNone));
    final color = full ? c.regOk : (srtp || tls ? c.regWarn : c.disabled);
    return Semantics(
      label: label,
      child: Tooltip(
        message: '$label${srtp ? '\n${l.uiSecureSrtpLine}' : ''}${tls ? '\n${l.uiSecureTlsLine}' : ''}',
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            color: color.withValues(alpha: 0.14),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(full || srtp || tls ? Icons.lock_rounded : Icons.lock_open_rounded, size: 14, color: color),
              const SizedBox(width: 4),
              Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Pulsing ring behind the avatar of an incoming call.
class PulseRing extends StatefulWidget {
  const PulseRing({super.key, required this.child, required this.size, this.color});
  final Widget child;
  final double size;
  final Color? color;
  @override
  State<PulseRing> createState() => _PulseRingState();
}

class _PulseRingState extends State<PulseRing> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800))..repeat();
  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? Theme.of(context).colorScheme.primary;
    final reduce = MediaQuery.of(context).disableAnimations;
    return SizedBox(
      width: widget.size * 1.7,
      height: widget.size * 1.7,
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              if (!reduce)
                for (final offset in const [0.0, 0.5])
                  () {
                    final t = Curves.easeOutCubic.transform((_c.value + offset) % 1);
                    return Container(
                      width: widget.size * (1 + 0.7 * t),
                      height: widget.size * (1 + 0.7 * t),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: color.withValues(alpha: 0.5 * (1 - t)), width: 3 * math.max(0.3, 1 - t)),
                      ),
                    );
                  }(),
              child!,
            ],
          );
        },
        child: widget.child,
      ),
    );
  }
}
