import '../l10n/l10n.dart';
import '../models/account_profile.dart';
import '../models/app_settings.dart';
import '../models/call_record.dart';
import '../models/contact.dart';

/// Whether a call should be recorded automatically when it connects.
///
/// Order: contact "always record" > per-account override > global rule.
/// Account values: `inherit`, `always` (all calls), `incoming`, `outgoing`,
/// `never`. Global rule: `off`, `all`, `incoming`, `outgoing`.
bool shouldAutoRecord({
  required AppSettings settings,
  required AccountProfile? profile,
  required Contact? contact,
  required CallDirection direction,
}) {
  if (contact?.autoRecord ?? false) return true;
  bool byRule(String rule) => switch (rule) {
    'all' || 'always' => true,
    'incoming' => direction == CallDirection.incoming,
    'outgoing' => direction == CallDirection.outgoing,
    _ => false,
  };
  final acc = profile?.autoRecord ?? 'inherit';
  if (acc == 'never') return false;
  if (acc != 'inherit') return byRule(acc);
  return byRule(settings.recordRule);
}

/// Labels for the per-account override.
Map<String, String> accountRecordOptions(AppLocalizations l) => {
  'inherit': l.recOptionInherit,
  'always': l.recOptionAlways,
  'incoming': l.recOptionIncoming,
  'outgoing': l.recOptionOutgoing,
  'never': l.recOptionNever,
};

/// Labels for the global rule.
Map<String, String> globalRecordOptions(AppLocalizations l) => {
  'off': l.commonOff,
  'all': l.recRuleAll,
  'incoming': l.recRuleIncoming,
  'outgoing': l.recRuleOutgoing,
};
