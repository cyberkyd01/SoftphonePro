import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../diagnostics/redaction.dart';
import '../../../diagnostics/sip_message.dart';
import 'trace_style.dart';

const int _kMaxShown = 200 * 1024;

/// Syntax-highlighted spans for a raw SIP message (start line, header names,
/// body). Pure and safe on garbage.
List<TextSpan> highlightSip(String text, ColorScheme cs, {Color? startColor}) {
  final spans = <TextSpan>[];
  final shown = text.length > _kMaxShown ? text.substring(0, _kMaxShown) : text;
  final lines = shown.split(RegExp(r'\r?\n'));
  var inBody = false;
  for (var i = 0; i < lines.length; i++) {
    final l = lines[i];
    final nl = i == lines.length - 1 ? '' : '\n';
    if (i == 0) {
      spans.add(TextSpan(text: '$l$nl', style: TextStyle(fontWeight: FontWeight.w700, color: startColor ?? cs.primary)));
    } else if (inBody) {
      final isSdp = RegExp(r'^[a-z]=').hasMatch(l);
      spans.add(TextSpan(text: '$l$nl', style: TextStyle(color: isSdp ? cs.tertiary : cs.onSurfaceVariant)));
    } else if (l.isEmpty) {
      inBody = true;
      spans.add(TextSpan(text: nl));
    } else if ((l.startsWith(' ') || l.startsWith('\t'))) {
      spans.add(TextSpan(text: '$l$nl'));
    } else {
      final c = l.indexOf(':');
      if (c > 0) {
        spans.add(TextSpan(text: l.substring(0, c + 1), style: TextStyle(color: cs.secondary, fontWeight: FontWeight.w600)));
        spans.add(TextSpan(text: '${l.substring(c + 1)}$nl'));
      } else {
        spans.add(TextSpan(text: '$l$nl', style: TextStyle(color: cs.error)));
      }
    }
  }
  if (text.length > _kMaxShown) {
    spans.add(TextSpan(text: '\n... truncated (${text.length} chars)', style: TextStyle(color: cs.onSurfaceVariant)));
  }
  return spans;
}

/// Opens the raw viewer for one message.
Future<void> showRawMessage(BuildContext context, SipMessage m, {bool redact = true, VoidCallback? onLadder}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    constraints: const BoxConstraints(maxWidth: 900),
    builder: (_) => RawMessageSheet(message: m, redact: redact, onLadder: onLadder),
  );
}

class RawMessageSheet extends StatefulWidget {
  const RawMessageSheet({super.key, required this.message, this.redact = true, this.onLadder});
  final SipMessage message;
  final bool redact;
  final VoidCallback? onLadder;

  @override
  State<RawMessageSheet> createState() => _RawMessageSheetState();
}

class _RawMessageSheetState extends State<RawMessageSheet> {
  late bool _redact = widget.redact;

  @override
  Widget build(BuildContext context) {
    final m = widget.message;
    final t = Theme.of(context);
    final text = _redact ? redactSecrets(m.raw) : m.raw;
    final color = sipColor(m, context);
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.8,
      maxChildSize: 0.95,
      minChildSize: 0.4,
      builder: (context, scroll) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Row(
              children: [
                Icon(m.outgoing ? Icons.north_east_rounded : Icons.south_west_rounded, size: 18, color: color),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(m.longLabel, style: t.textTheme.titleMedium?.copyWith(color: color, fontWeight: FontWeight.w700)),
                      Text(
                        '${clockLabel(m.time)}  ·  ${m.outgoing ? 'sent to' : 'received from'} ${m.remote}  ·  ${m.transport}  ·  ${bytesLabel(m.size)}',
                        style: t.textTheme.bodySmall?.copyWith(color: t.colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Wrap(
              spacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                TextButton.icon(
                  key: const Key('raw-copy'),
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: text));
                    if (context.mounted) {
                      ScaffoldMessenger.maybeOf(context)?.showSnackBar(const SnackBar(content: Text('Message copied')));
                    }
                  },
                  icon: const Icon(Icons.copy_rounded, size: 18),
                  label: const Text('Copy'),
                ),
                if (widget.onLadder != null)
                  TextButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      widget.onLadder!();
                    },
                    icon: const Icon(Icons.account_tree_outlined, size: 18),
                    label: const Text('Ladder'),
                  ),
                FilterChip(
                  key: const Key('raw-redact'),
                  label: const Text('Redact credentials'),
                  selected: _redact,
                  onSelected: (v) => setState(() => _redact = v),
                ),
              ],
            ),
          ),
          const Divider(height: 16),
          Expanded(
            child: SingleChildScrollView(
              controller: scroll,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SelectableText.rich(
                  TextSpan(
                    style: TextStyle(fontFamily: kMono, fontSize: 12.5, height: 1.4, color: t.colorScheme.onSurface),
                    children: highlightSip(text, t.colorScheme, startColor: color),
                  ),
                  key: const Key('raw-text'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
