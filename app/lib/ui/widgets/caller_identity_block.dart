import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format.dart';
import '../../l10n/l10n.dart';
import '../../models/call_record.dart';
import '../../services/caller_identity.dart';
import '../../services/calls_controller.dart';
import '../../services/contacts_controller.dart';
import '../../core/theme.dart';

/// The lines under a caller's name: the number (asserted number when the
/// network provided one), the SIP From number when it differs, "Forwarded
/// from ..." (Diversion) and "Transferred by ..." (Referred-By).
class CallerIdentityBlock extends ConsumerWidget {
  const CallerIdentityBlock({
    super.key,
    required this.call,
    required this.title,
    this.center = true,
    this.numberStyle,
    this.dense = false,
    this.showNumber = true,
  });
  final UiCall call;
  final String title;
  final bool center;
  final TextStyle? numberStyle;

  /// Smaller text for cards and banners.
  final bool dense;

  /// Hide the number and "From" lines (cards show their own).
  final bool showNumber;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contacts = ref.watch(contactsProvider);
    final who = CallerIdentity.of(call.info, contacts, fromNumber: call.number);
    final t = Theme.of(context);
    final muted = t.colorScheme.onSurfaceVariant;
    final small = t.textTheme.bodySmall?.copyWith(color: muted);
    final align = center ? CrossAxisAlignment.center : CrossAxisAlignment.start;
    final ta = center ? TextAlign.center : TextAlign.start;
    final showNum = showNumber && who.number.isNotEmpty && title != who.number;
    return Column(
      crossAxisAlignment: align,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showNum)
          Text(
            who.number,
            key: const Key('identity-number'),
            textAlign: ta,
            textDirection: TextDirection.ltr,
            style: numberStyle ?? tabular(dense ? small : t.textTheme.bodyLarge?.copyWith(color: muted)),
          ),
        if (showNumber && who.secondaryNumber.isNotEmpty)
          Text(context.l10n.callIdentityFrom(who.secondaryNumber), key: const Key('identity-from'), textAlign: ta, style: small),
        if (who.forwardedFrom.isNotEmpty)
          _Tag(key: const Key('identity-forwarded'), icon: Icons.phone_forwarded_rounded, text: who.forwardedLabel(context.l10n), center: center),
        if (who.transferredBy.isNotEmpty)
          _Tag(key: const Key('identity-transferred'), icon: Icons.swap_calls_rounded, text: who.transferredLabel(context.l10n), center: center),
      ],
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({super.key, required this.icon, required this.text, required this.center});
  final IconData icon;
  final String text;
  final bool center;
  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Padding(
      padding: const EdgeInsetsDirectional.only(top: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: t.colorScheme.primary),
          const SizedBox(width: 4),
          Flexible(
            child: Text(text, maxLines: 2, overflow: TextOverflow.ellipsis, style: t.textTheme.labelMedium?.copyWith(color: t.colorScheme.primary)),
          ),
        ],
      ),
    );
  }
}

/// Identity lines of a history record (detail view).
class RecordIdentityLines extends StatelessWidget {
  const RecordIdentityLines({super.key, required this.record});
  final CallRecord record;
  @override
  Widget build(BuildContext context) {
    final r = record;
    final l = context.l10n;
    final t = Theme.of(context);
    final lines = <(Key, IconData, String)>[
      if (r.assertedNumber.isNotEmpty && !sameNumber(r.assertedNumber, r.remoteNumber))
        (const Key('hist-asserted'), Icons.verified_user_outlined, r.assertedName.isEmpty ? l.callIdentityCallerId(r.assertedNumber) : l.callIdentityCallerIdWithName(r.assertedName, r.assertedNumber)),
      if (r.divertedFrom.isNotEmpty)
        (const Key('hist-forwarded'), Icons.phone_forwarded_rounded, r.divertReason.isEmpty ? l.callIdentityForwardedFrom(r.divertedFrom) : l.callIdentityForwardedFromReason(r.divertedFrom, r.divertReason)),
      if (r.referredBy.isNotEmpty) (const Key('hist-transferred'), Icons.swap_calls_rounded, l.callIdentityTransferredBy(r.referredBy)),
    ];
    if (lines.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final ln in lines)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Row(children: [
              Icon(ln.$2, size: 14, color: t.colorScheme.primary),
              const SizedBox(width: 6),
              Expanded(child: Text(ln.$3, key: ln.$1, style: t.textTheme.bodySmall)),
            ]),
          ),
      ],
    );
  }
}
