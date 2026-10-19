import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/format.dart';
import '../../core/theme.dart';
import '../../models/call_record.dart';
import '../../models/contact.dart';
import '../../services/accounts_controller.dart';
import '../../services/app_services.dart';
import '../../services/calls_controller.dart';
import '../../services/contacts_controller.dart';
import '../../services/history_controller.dart';
import '../../services/providers.dart';
import '../widgets/account_widgets.dart';
import '../widgets/basic_widgets.dart';
import '../widgets/dial_pad.dart';
import '../settings/speed_dial_page.dart';
import '../../services/settings_controller.dart';

class Suggestion {
  const Suggestion(this.name, this.number, {this.contact});
  final String name;
  final String number;
  final Contact? contact;
}

/// T9 + substring suggestions from contacts and call history.
List<Suggestion> buildSuggestions(String input, List<Contact> contacts, List<CallRecord> history, {int limit = 6}) {
  final q = input.trim();
  if (q.isEmpty) return const [];
  final digits = digitsOf(q);
  final lower = q.toLowerCase();
  final isT9 = RegExp(r'^[0-9]+$').hasMatch(q);
  final out = <Suggestion>[];
  final seen = <String>{};
  for (final c in contacts) {
    for (final a in c.addresses) {
      final nameT9 = t9Of(c.displayName.replaceAll(RegExp(r'\s+'), ''));
      final words = c.displayName.split(RegExp(r'\s+'));
      final matchName = c.displayName.toLowerCase().contains(lower) ||
          (isT9 && (nameT9.startsWith(digits) || words.any((w) => t9Of(w).startsWith(digits) && digits.length >= 2)));
      final matchNum = digits.isNotEmpty && digitsOf(a).contains(digits);
      if ((matchName || matchNum) && seen.add('${c.id}|$a')) {
        out.add(Suggestion(c.displayName, a, contact: c));
      }
    }
  }
  for (final r in history) {
    if (r.remoteNumber.isEmpty) continue;
    final matchNum = digits.isNotEmpty && digitsOf(r.remoteNumber).contains(digits);
    final matchName = r.remoteDisplay.toLowerCase().contains(lower);
    if ((matchNum || matchName) && seen.add('h|${r.remoteNumber}') && !out.any((s) => sameNumber(s.number, r.remoteNumber))) {
      out.add(Suggestion(r.remoteDisplay, r.remoteNumber));
    }
  }
  return out.take(limit).toList();
}

class KeypadPage extends ConsumerStatefulWidget {
  const KeypadPage({super.key});
  @override
  ConsumerState<KeypadPage> createState() => _KeypadPageState();
}

class _KeypadPageState extends ConsumerState<KeypadPage> {
  final _ctl = TextEditingController();
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _ctl.text = ref.read(dialInputProvider);
    _ctl.addListener(() {
      if (ref.read(dialInputProvider) != _ctl.text) {
        ref.read(dialInputProvider.notifier).set(_ctl.text);
      }
    });
  }

  @override
  void dispose() {
    _ctl.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _syncFrom(String v) {
    if (_ctl.text != v) {
      _ctl.value = TextEditingValue(text: v, selection: TextSelection.collapsed(offset: v.length));
    }
  }

  void _digit(String d) {
    final sel = _ctl.selection;
    final text = _ctl.text;
    final start = sel.isValid ? sel.start : text.length;
    final end = sel.isValid ? sel.end : text.length;
    final next = text.replaceRange(start, end, d);
    _ctl.value = TextEditingValue(text: next, selection: TextSelection.collapsed(offset: start + d.length));
    if (d != '+') ref.read(callsProvider.notifier).playLocalDtmf(d);
  }

  void _backspace() {
    final sel = _ctl.selection;
    final text = _ctl.text;
    if (text.isEmpty) return;
    if (sel.isValid && sel.start != sel.end) {
      _ctl.value = TextEditingValue(text: text.replaceRange(sel.start, sel.end, ''), selection: TextSelection.collapsed(offset: sel.start));
    } else {
      final pos = sel.isValid && sel.start > 0 ? sel.start : text.length;
      if (pos == 0) return;
      _ctl.value = TextEditingValue(text: text.replaceRange(pos - 1, pos, ''), selection: TextSelection.collapsed(offset: pos - 1));
    }
  }

  Future<void> _call() async {
    var number = _ctl.text.trim();
    if (number.isEmpty) {
      final last = ref.read(historyProvider.notifier).lastOutgoing;
      if (last != null) {
        _ctl.text = last.remoteNumber;
        _ctl.selection = TextSelection.collapsed(offset: _ctl.text.length);
      }
      return;
    }
    final cid = await ref.read(callsProvider.notifier).dial(number);
    if (cid != null) _ctl.clear();
  }

  Future<void> _paste() async {
    final d = await Clipboard.getData(Clipboard.kTextPlain);
    final t = d?.text?.trim();
    if (t != null && t.isNotEmpty) {
      _ctl.text = DialRulesCleaner.clipboard(t);
      _ctl.selection = TextSelection.collapsed(offset: _ctl.text.length);
    }
  }

  Future<void> _voicemail() async {
    final acc = ref.read(accountsProvider);
    final sel = ref.read(dialAccountProvider);
    final p = (sel != null ? acc.byId(sel) : null) ?? acc.defaultProfile;
    if (p == null || p.effectiveVoicemail.isEmpty) {
      ref.read(noticeProvider.notifier).show('No voicemail number configured for this account');
      return;
    }
    await ref.read(callsProvider.notifier).dial(p.effectiveVoicemail, accountId: p.id, applyRules: false);
  }

  /// Long-press on a digit with an empty number field: dial the speed dial
  /// slot, or open the assignment dialog when it is empty.
  Future<void> _speedDial(String d) async {
    if (_ctl.text.trim().isNotEmpty) return d == '1' ? _voicemail() : null;
    final slot = int.tryParse(d);
    if (slot == null) return;
    final e = ref.read(settingsProvider).speedDial[slot];
    if (e == null) {
      if (d == '1') return _voicemail(); // slot 1 defaults to voicemail
      await showSpeedDialEditor(context, ref, slot);
      return;
    }
    await ref.read(callsProvider.notifier).dial(e.number, accountId: e.accountId);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<String>(dialInputProvider, (_, v) => _syncFrom(v));
    ref.listen<int>(dialFocusProvider, (_, __) => _focus.requestFocus());
    final contacts = ref.watch(contactsProvider);
    final history = ref.watch(historyProvider);
    final text = ref.watch(dialInputProvider);
    final suggestions = buildSuggestions(text, contacts, history, limit: context.isExpanded ? 8 : 4);
    final expanded = context.isExpanded;
    final acc = ref.watch(accountsProvider);
    final selId = ref.watch(dialAccountProvider);
    final isDirect = selId == kDirectAccountId;
    final selected = isDirect ? null : (selId != null ? acc.byId(selId) : null) ?? acc.defaultProfile;

    final field = _NumberField(
      controller: _ctl,
      focus: _focus,
      onSubmit: _call,
      onBackspace: _backspace,
      onClear: () => _ctl.clear(),
      onPaste: _paste,
    );
    final callBtn = RoundCallButton(
      icon: Icons.call_rounded,
      color: context.colors.callGreen,
      label: 'Call',
      size: 72,
      onPressed: _call,
    );

    void pick(Suggestion s) {
      _ctl.text = s.number;
      _ctl.selection = TextSelection.collapsed(offset: s.number.length);
    }

    if (expanded) {
      return LayoutBuilder(
        builder: (context, box) {
          final wide = box.maxWidth >= 900;
          final card = Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        field,
                        const SizedBox(height: 12),
                        const AccountSelector(),
                        if (!wide && suggestions.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            children: [
                              for (final s in suggestions.take(3))
                                ActionChip(
                                  avatar: Avatar(name: s.name.isEmpty ? s.number : s.name, size: 22),
                                  label: Text(s.name.isEmpty ? s.number : s.name),
                                  onPressed: () => pick(s),
                                ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 16),
                        DialPad(onDigit: _digit, onVoicemail: _voicemail, onLongPressDigit: _speedDial),
                        const SizedBox(height: 16),
                        callBtn,
                        const SizedBox(height: 8),
                        Text(
                          isDirect ? 'Call directly (no account)' : (selected == null ? 'Add an account to place calls' : 'Call from ${selected.name}'),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
          if (!wide) return card;
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: card),
              SizedBox(
                width: 340,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 24, 24, 24),
                  child: _SuggestionsPanel(suggestions: suggestions, query: text, onPick: pick, onCall: (s) => ref.read(callsProvider.notifier).dial(s.number)),
                ),
              ),
            ],
          );
        },
      );
    }

    return LayoutBuilder(
      builder: (context, c) {
        final tight = c.maxHeight < 560;
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
              child: field,
            ),
            const SizedBox(height: 4),
            AccountSelector(dense: tight),
            if (!tight)
              // Tall phones: use the gap above the keypad for the top T9
              // suggestions (or recent calls while nothing is typed).
              Expanded(
                child: _QuickList(
                  title: text.trim().isEmpty ? 'Recent' : 'Suggestions',
                  entries: text.trim().isEmpty ? _recent(history) : suggestions.take(3).toList(),
                  onPick: pick,
                ),
              )
            else
            AnimatedSize(
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeOutCubic,
              child: suggestions.isEmpty
                  ? const SizedBox(width: double.infinity)
                  : SizedBox(
                      height: 52,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        children: [
                          for (final s in suggestions)
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ActionChip(
                                avatar: Avatar(name: s.name.isEmpty ? s.number : s.name, size: 24),
                                label: Text(s.name.isEmpty ? s.number : '${s.name}  ${s.number}'),
                                onPressed: () => pick(s),
                              ),
                            ),
                        ],
                      ),
                    ),
            ),
            if (tight) const Spacer(),
            DialPad(onDigit: _digit, onVoicemail: _voicemail, onLongPressDigit: _speedDial, compact: tight),
            const SizedBox(height: 8),
            callBtn,
            const SizedBox(height: 12),
          ],
        );
      },
    );
  }
}

List<Suggestion> _recent(List<CallRecord> history) {
  final out = <Suggestion>[];
  for (final r in history) {
    final n = r.remoteNumber.isNotEmpty ? r.remoteNumber : r.remoteUri;
    if (n.isEmpty || out.any((s) => sameNumber(s.number, n))) continue;
    out.add(Suggestion(r.remoteDisplay, n));
    if (out.length == 3) break;
  }
  return out;
}

/// Top suggestions / recent numbers shown between the number field and the
/// keypad on tall phones.
class _QuickList extends StatelessWidget {
  const _QuickList({required this.title, required this.entries, required this.onPick});
  final String title;
  final List<Suggestion> entries;
  final void Function(Suggestion) onPick;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    if (entries.isEmpty) return const SizedBox.shrink();
    return ClipRect(
      child: ListView(
        key: const Key('keypad-quick-list'),
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 2),
            child: Text(title, style: t.textTheme.labelMedium?.copyWith(color: t.colorScheme.onSurfaceVariant)),
          ),
          for (final s in entries)
            ListTile(
              dense: true,
              visualDensity: VisualDensity.compact,
              leading: Avatar(name: s.name.isEmpty ? s.number : s.name, size: 32),
              title: Text(s.name.isEmpty ? s.number : s.name, maxLines: 1, overflow: TextOverflow.ellipsis),
              subtitle: s.name.isEmpty ? null : Text(s.number, style: tabular(null), maxLines: 1),
              onTap: () => onPick(s),
            ),
        ],
      ),
    );
  }
}

/// Cleans text pasted into the dialler (spaces, dashes, "tel:" prefix).
class DialRulesCleaner {
  static String clipboard(String t) {
    var s = t.trim().replaceFirst(RegExp(r'^(tel:|callto:)', caseSensitive: false), '');
    if (RegExp(r'^[\d\s\-\(\)\.\+\*#]+$').hasMatch(s)) {
      s = s.replaceAll(RegExp(r'[\s\-\(\)\.]'), '');
    }
    return s;
  }
}

class _NumberField extends StatelessWidget {
  const _NumberField({
    required this.controller,
    required this.focus,
    required this.onSubmit,
    required this.onBackspace,
    required this.onClear,
    required this.onPaste,
  });
  final TextEditingController controller;
  final FocusNode focus;
  final VoidCallback onSubmit;
  final VoidCallback onBackspace;
  final VoidCallback onClear;
  final VoidCallback onPaste;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Semantics(
      label: 'Phone number',
      textField: true,
      child: Row(
        children: [
          IconButton(
            tooltip: 'Paste',
            onPressed: onPaste,
            icon: const Icon(Icons.content_paste_rounded),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focus,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.none,
              showCursor: true,
              enableInteractiveSelection: true,
              style: tabular(t.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w500, letterSpacing: 0.5)),
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9A-Za-z*#+@.:_\-\s]'))],
              onSubmitted: (_) => onSubmit(),
              decoration: const InputDecoration(
                hintText: 'Enter number',
                filled: false,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
            ),
          ),
          ListenableBuilder(
            listenable: controller,
            builder: (context, _) => GestureDetector(
              onLongPress: onClear,
              child: IconButton(
                tooltip: 'Backspace (long press to clear)',
                onPressed: controller.text.isEmpty ? null : onBackspace,
                icon: const Icon(Icons.backspace_outlined),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SuggestionsPanel extends StatelessWidget {
  const _SuggestionsPanel({required this.suggestions, required this.query, required this.onPick, required this.onCall});
  final List<Suggestion> suggestions;
  final String query;
  final void Function(Suggestion) onPick;
  final void Function(Suggestion) onCall;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Card(
      child: suggestions.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.search_rounded, size: 32, color: t.colorScheme.onSurfaceVariant),
                    const SizedBox(height: 8),
                    Text(
                      query.isEmpty ? 'Type a name or number' : 'No matches',
                      style: t.textTheme.bodyMedium?.copyWith(color: t.colorScheme.onSurfaceVariant),
                    ),
                    Text(
                      'Suggestions come from contacts and recent calls',
                      textAlign: TextAlign.center,
                      style: t.textTheme.bodySmall?.copyWith(color: t.colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: suggestions.length,
              separatorBuilder: (_, __) => const Divider(indent: 72),
              itemBuilder: (context, i) {
                final s = suggestions[i];
                return ListTile(
                  leading: Avatar(name: s.name.isEmpty ? s.number : s.name),
                  title: Text(s.name.isEmpty ? s.number : s.name),
                  subtitle: s.name.isEmpty ? null : Text(s.number, style: tabular(null)),
                  trailing: IconButton(
                    tooltip: 'Call ${s.name.isEmpty ? s.number : s.name}',
                    icon: Icon(Icons.call_rounded, color: context.colors.callGreen),
                    onPressed: () => onCall(s),
                  ),
                  onTap: () => onPick(s),
                );
              },
            ),
    );
  }
}

/// Opens the dialler with [number] pre-filled.
void openDialerWith(BuildContext context, WidgetRef ref, String number) {
  ref.read(dialInputProvider.notifier).set(number);
  context.go('/keypad');
}
