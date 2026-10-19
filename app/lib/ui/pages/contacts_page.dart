import '../../core/bidi.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/format.dart';
import '../../core/theme.dart';
import '../../l10n/l10n.dart';
import '../../models/contact.dart';
import '../../services/accounts_controller.dart';
import '../../services/calls_controller.dart';
import '../../services/contact_io.dart';
import '../../services/contacts_controller.dart';
import '../../services/device_contacts.dart';
import '../../services/presence_controller.dart';
import '../../services/providers.dart';
import '../../services/ringtones.dart';
import '../../storage/repositories.dart';
import '../widgets/basic_widgets.dart';
import '../widgets/settings_tiles.dart';

class ContactsPage extends ConsumerStatefulWidget {
  const ContactsPage({super.key});
  @override
  ConsumerState<ContactsPage> createState() => _ContactsPageState();
}

class _ContactsPageState extends ConsumerState<ContactsPage> {
  String _q = '';
  String? _selected;
  bool _favOnly = false;

  @override
  Widget build(BuildContext context) {
    final all = ref.watch(contactsProvider);
    final presence = ref.watch(presenceProvider);
    final expanded = context.isExpanded;
    var list = all.where((c) {
      if (_favOnly && !c.favorite) return false;
      if (_q.isEmpty) return true;
      final q = _q.toLowerCase();
      return c.displayName.toLowerCase().contains(q) ||
          c.company.toLowerCase().contains(q) ||
          c.addresses.any((a) => a.toLowerCase().contains(q) || (digitsOf(q).isNotEmpty && digitsOf(a).contains(digitsOf(q))));
    }).toList();
    final favs = list.where((c) => c.favorite).toList();

    final items = <Object>[];
    if (!_favOnly && favs.isNotEmpty && _q.isEmpty) {
      items.add(context.l10n.contactsFavoritesHeader);
      items.addAll(favs);
    }
    String? lastLetter;
    for (final c in list) {
      final l = initialsOf(c.displayName).substring(0, 1);
      if (l != lastLetter) {
        items.add(l);
        lastLetter = l;
      }
      items.add(c);
    }

    final listPane = Column(
      children: [
        PageHeader(
          title: context.l10n.shellTabContacts,
          actions: [
            IconButton(
              tooltip: _favOnly ? context.l10n.contactsShowAll : context.l10n.contactsFavoritesOnly,
              onPressed: () => setState(() => _favOnly = !_favOnly),
              icon: Icon(_favOnly ? Icons.star_rounded : Icons.star_outline_rounded),
            ),
            PopupMenuButton<String>(
              tooltip: context.l10n.contactsImportExportTooltip,
              onSelected: (v) => _menu(v),
              itemBuilder: (_) => [
                if (ref.read(deviceContactsSourceProvider) != null)
                  PopupMenuItem(value: 'device', child: Text(context.l10n.contactsMenuDevice)),
                PopupMenuItem(value: 'import', child: Text(context.l10n.contactsMenuFile)),
                PopupMenuItem(value: 'paste', child: Text(context.l10n.contactsMenuClipboard)),
                PopupMenuItem(value: 'vcf', child: Text(context.l10n.contactsMenuCopyVcard)),
                PopupMenuItem(value: 'csv', child: Text(context.l10n.contactsMenuCopyCsv)),
              ],
            ),
            IconButton(
              tooltip: context.l10n.contactsNewTooltip,
              onPressed: () => context.push('/contacts/new'),
              icon: const Icon(Icons.person_add_alt_1_rounded),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 4, 16, 8),
          child: TextField(
            onChanged: (v) => setState(() => _q = v),
            decoration: InputDecoration(hintText: context.l10n.contactsSearchHint, prefixIcon: const Icon(Icons.search_rounded)),
          ),
        ),
        Expanded(
          child: all.isEmpty
              ? EmptyState(
                  icon: Icons.people_alt_rounded,
                  title: context.l10n.contactsEmptyTitle,
                  subtitle: context.l10n.contactsEmptySubtitle,
                  actionLabel: context.l10n.contactsEmptyAction,
                  onAction: () => context.push('/contacts/new'),
                )
              : list.isEmpty
              ? EmptyState(icon: Icons.search_off_rounded, title: context.l10n.contactsNoMatches)
              : ListView.builder(
                  padding: const EdgeInsets.only(bottom: 24),
                  itemCount: items.length,
                  itemBuilder: (context, i) {
                    final it = items[i];
                    if (it is String) return SectionHeader(it, padding: const EdgeInsetsDirectional.fromSTEB(16, 14, 16, 2));
                    final c = it as Contact;
                    return ListTile(
                      key: ValueKey('${c.id}-$i'),
                      selected: expanded && _selected == c.id,
                      selectedTileColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
                      leading: Avatar(name: c.displayName, color: Color(c.avatarColor), lamp: c.blf ? presence.lampOf(c.id) : LampState.unknown),
                      title: Text(c.displayName, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text(
                        [if (c.company.isNotEmpty) c.company, bidiSafe(c.primary)].where((e) => e.isNotEmpty).join('  ·  '),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: c.addresses.isEmpty
                          ? null
                          : IconButton(
                              tooltip: context.l10n.contactsCallName(c.displayName),
                              icon: Icon(Icons.call_rounded, color: context.colors.callGreen),
                              onPressed: () => _callContact(context, ref, c),
                            ),
                      onTap: () {
                        if (expanded) {
                          setState(() => _selected = c.id);
                        } else {
                          context.push('/contacts/${c.id}');
                        }
                      },
                    );
                  },
                ),
        ),
      ],
    );
    if (!expanded) return listPane;
    return Row(
      children: [
        SizedBox(width: 400, child: listPane),
        VerticalDivider(width: 1, color: Theme.of(context).colorScheme.outlineVariant),
        Expanded(
          child: _selected == null || !all.any((c) => c.id == _selected)
              ? EmptyState(icon: Icons.touch_app_rounded, title: context.l10n.contactsSelect)
              : ContactDetailView(contactId: _selected!, embedded: true),
        ),
      ],
    );
  }

  Future<void> _menu(String v) async {
    final l = ref.read(l10nProvider);
    final ctl = ref.read(contactsProvider.notifier);
    final notice = ref.read(noticeProvider.notifier);
    switch (v) {
      case 'vcf':
        await Clipboard.setData(ClipboardData(text: ctl.exportVCard()));
        notice.show(l.contactsCopiedVcard);
      case 'csv':
        await Clipboard.setData(ClipboardData(text: ctl.exportCsv()));
        notice.show(l.contactsCopiedCsv);
      case 'device':
        await _importDevice();
      case 'paste':
        final d = await Clipboard.getData(Clipboard.kTextPlain);
        await _import(d?.text ?? '');
      case 'import':
        final r = await FilePicker.platform.pickFiles(type: FileType.any, withData: true);
        final f = r?.files.single;
        if (f?.bytes != null) await _import(String.fromCharCodes(f!.bytes!), name: f.name);
    }
  }

  Future<void> _importDevice() async {
    final l = ref.read(l10nProvider);
    final src = ref.read(deviceContactsSourceProvider);
    final notice = ref.read(noticeProvider.notifier);
    if (src == null) return;
    if (!await src.requestPermission()) {
      notice.show(l.contactsDeviceDenied, isError: true);
      return;
    }
    final device = await src.read();
    final plan = planDeviceImport(ref.read(contactsProvider), device);
    if (!mounted) return;
    if (plan.isEmpty) {
      notice.show(device.isEmpty ? l.contactsDeviceNone : l.contactsNothingNew(plan.skipped));
      return;
    }
    final ok = await confirm(
      context,
      title: l.contactsImportDeviceTitle,
      message: [
        l.contactsImportNew(plan.added.length),
        if (plan.updated.isNotEmpty) l.contactsImportUpdated(plan.updated.length),
        if (plan.skipped != 0) l.contactsImportSkipped(plan.skipped),
      ].join('\n'),
      confirmLabel: l.actionImport,
      destructive: false,
    );
    if (!ok) return;
    final n = await ref.read(contactsProvider.notifier).applyImport(plan);
    notice.show(l.contactsImportedCount(n));
  }

  Future<void> _import(String text, {String name = ''}) async {
    final isCsv = name.toLowerCase().endsWith('.csv') || (!text.contains('BEGIN:VCARD'));
    final parsed = isCsv ? ContactIo.fromCsv(text) : ContactIo.fromVCard(text);
    final n = await ref.read(contactsProvider.notifier).importAll(parsed);
    ref.read(noticeProvider.notifier).show(parsed.isEmpty ? ref.read(l10nProvider).contactsImportNone : ref.read(l10nProvider).contactsImportedCount(n));
  }
}

String contactLabelText(AppLocalizations l, String raw) => switch (raw) {
  'mobile' => l.contactsLabelMobile,
  'work' => l.contactsLabelWork,
  'home' => l.contactsLabelHome,
  'other' => l.contactsLabelOther,
  _ => raw,
};

Future<void> _callContact(BuildContext context, WidgetRef ref, Contact c) async {
  if (c.addresses.length <= 1) {
    await ref.read(callsProvider.notifier).dial(c.primary);
    return;
  }
  final pick = await showModalBottomSheet<String>(
    context: context,
    builder: (ctx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final n in c.numbers)
            ListTile(leading: const Icon(Icons.phone_rounded), title: Text(n.value, textDirection: TextDirection.ltr), subtitle: Text(contactLabelText(ctx.l10n, n.label)), onTap: () => Navigator.pop(ctx, n.value)),
          for (final u in c.sipUris) ListTile(leading: const Icon(Icons.alternate_email_rounded), title: Text(u, textDirection: TextDirection.ltr), subtitle: Text(ctx.l10n.contactsSip), onTap: () => Navigator.pop(ctx, u)),
        ],
      ),
    ),
  );
  if (pick != null) await ref.read(callsProvider.notifier).dial(pick);
}

class ContactDetailView extends ConsumerWidget {
  const ContactDetailView({super.key, required this.contactId, this.embedded = false});
  final String contactId;
  final bool embedded;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contacts = ref.watch(contactsProvider);
    final c = contacts.where((e) => e.id == contactId).firstOrNull;
    if (c == null) return EmptyState(icon: Icons.person_off_rounded, title: context.l10n.contactsNotFound);
    final t = Theme.of(context);
    final colors = context.colors;
    final acc = ref.watch(accountsProvider);
    final body = ListView(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 32),
      children: [
        Column(
          children: [
            Avatar(name: c.displayName, size: 96, color: Color(c.avatarColor)),
            const SizedBox(height: 12),
            Text(c.displayName, style: t.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700), textAlign: TextAlign.center),
            if (c.company.isNotEmpty && c.company != c.displayName) Text(c.company, style: t.textTheme.bodyMedium?.copyWith(color: t.colorScheme.onSurfaceVariant)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              alignment: WrapAlignment.center,
              children: [
                _CircleAction(icon: Icons.call_rounded, label: context.l10n.uiCall, color: colors.callGreen, onTap: c.addresses.isEmpty ? null : () => _callContact(context, ref, c)),
                _CircleAction(
                  icon: Icons.message_rounded,
                  label: context.l10n.uiMessage,
                  onTap: c.addresses.isEmpty || acc.defaultProfile == null
                      ? null
                      : () => context.push('/thread?acc=${acc.defaultProfile!.id}&peer=${Uri.encodeQueryComponent(c.primary)}'),
                ),
                _CircleAction(
                  icon: c.favorite ? Icons.star_rounded : Icons.star_outline_rounded,
                  label: context.l10n.contactsActionFavorite,
                  color: c.favorite ? colors.holdAmber : null,
                  onTap: () => ref.read(contactsProvider.notifier).toggleFavorite(c.id),
                ),
                _CircleAction(icon: Icons.edit_rounded, label: context.l10n.actionEdit, onTap: () => context.push('/contacts/${c.id}/edit')),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (c.numbers.isNotEmpty || c.sipUris.isNotEmpty)
          SettingsGroup(
            title: context.l10n.contactsNumbersHeader,
            children: [
              for (final n in c.numbers)
                ListTile(
                  leading: const Icon(Icons.phone_rounded),
                  title: Text(ltr(n.value), style: tabular(null)),
                  subtitle: Text(contactLabelText(context.l10n, n.label)),
                  trailing: IconButton(tooltip: context.l10n.contactsCallName(n.value), icon: Icon(Icons.call_rounded, color: colors.callGreen), onPressed: () => ref.read(callsProvider.notifier).dial(n.value)),
                ),
              for (final u in c.sipUris)
                ListTile(
                  leading: const Icon(Icons.alternate_email_rounded),
                  title: Text(ltr(u)),
                  subtitle: Text(context.l10n.contactsSipAddress),
                  trailing: IconButton(tooltip: context.l10n.contactsCallName(u), icon: Icon(Icons.call_rounded, color: colors.callGreen), onPressed: () => ref.read(callsProvider.notifier).dial(u)),
                ),
            ],
          ),
        if (c.email.isNotEmpty || c.notes.isNotEmpty || c.blf || c.autoRecord)
          SettingsGroup(
            title: context.l10n.contactsDetailsHeader,
            children: [
              if (c.email.isNotEmpty) ListTile(leading: const Icon(Icons.email_outlined), title: Text(c.email)),
              if (c.blf) ListTile(leading: const Icon(Icons.grid_view_rounded), title: Text(context.l10n.contactsOnBlf)),
              if (c.autoRecord) ListTile(leading: const Icon(Icons.fiber_manual_record_rounded), title: Text(context.l10n.contactsAlwaysRecorded)),
              if (c.notes.isNotEmpty) ListTile(leading: const Icon(Icons.notes_rounded), title: Text(c.notes)),
            ],
          ),
        const SizedBox(height: 16),
        Align(
          child: TextButton.icon(
            onPressed: () async {
              if (await confirm(context, title: context.l10n.contactsDeleteTitle(c.displayName), message: context.l10n.contactsDeleteMessage)) {
                await ref.read(contactsProvider.notifier).delete(c.id);
                if (!embedded && context.mounted) context.pop();
              }
            },
            style: TextButton.styleFrom(foregroundColor: t.colorScheme.error),
            icon: const Icon(Icons.delete_outline_rounded),
            label: Text(context.l10n.contactsDeleteButton),
          ),
        ),
      ],
    );
    if (embedded) return body;
    return Scaffold(appBar: AppBar(title: Text(context.l10n.contactsDetailTitle)), body: body);
  }
}

class _CircleAction extends StatelessWidget {
  const _CircleAction({required this.icon, required this.label, required this.onTap, this.color});
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Color? color;
  @override
  Widget build(BuildContext context) {
    final c = color ?? Theme.of(context).colorScheme.primary;
    return Opacity(
      opacity: onTap == null ? 0.4 : 1,
      child: Semantics(
        button: true,
        label: label,
        excludeSemantics: true,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: SizedBox(
            width: 72,
            child: Column(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: c.withValues(alpha: 0.12)),
                  child: Icon(icon, color: c),
                ),
                const SizedBox(height: 6),
                Text(label, style: Theme.of(context).textTheme.labelMedium),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ContactDetailPage extends StatelessWidget {
  const ContactDetailPage({super.key, required this.contactId});
  final String contactId;
  @override
  Widget build(BuildContext context) => ContactDetailView(contactId: contactId);
}

// ---------------------------------------------------------------------------

class ContactEditorPage extends ConsumerStatefulWidget {
  const ContactEditorPage({super.key, this.contactId, this.prefillNumber});
  final String? contactId;
  final String? prefillNumber;
  @override
  ConsumerState<ContactEditorPage> createState() => _ContactEditorPageState();
}

class _ContactEditorPageState extends ConsumerState<ContactEditorPage> {
  late final TextEditingController _name;
  late final TextEditingController _company;
  late final TextEditingController _email;
  late final TextEditingController _notes;
  late List<_NumRow> _nums;
  late List<TextEditingController> _sips;
  bool _fav = false;
  bool _blf = false;
  bool _autoRecord = false;
  String _ring = 'default';
  String? _presenceUri;
  String _presenceAcc = '';
  late String _id;

  @override
  void initState() {
    super.initState();
    final existing = widget.contactId == null || widget.contactId == 'new'
        ? null
        : ref.read(contactsProvider).where((c) => c.id == widget.contactId).firstOrNull;
    _id = existing?.id ?? newId();
    _name = TextEditingController(text: existing?.name ?? '');
    _company = TextEditingController(text: existing?.company ?? '');
    _email = TextEditingController(text: existing?.email ?? '');
    _notes = TextEditingController(text: existing?.notes ?? '');
    _nums = [
      for (final n in existing?.numbers ?? <ContactNumber>[]) _NumRow(n.label, TextEditingController(text: n.value)),
      if (existing == null) _NumRow('mobile', TextEditingController(text: widget.prefillNumber ?? '')),
    ];
    _sips = [for (final s in existing?.sipUris ?? <String>[]) TextEditingController(text: s)];
    _fav = existing?.favorite ?? false;
    _blf = existing?.blf ?? false;
    _autoRecord = existing?.autoRecord ?? false;
    _ring = existing?.ringtone ?? 'default';
    _presenceUri = existing?.presenceUri;
    _presenceAcc = existing?.presenceAccountId ?? '';
    if (!ref.read(accountsProvider).profiles.any((p) => p.id == _presenceAcc)) _presenceAcc = '';
  }

  @override
  void dispose() {
    for (final c in [_name, _company, _email, _notes, ..._sips, ..._nums.map((e) => e.ctl)]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    final nums = [
      for (final n in _nums)
        if (n.ctl.text.trim().isNotEmpty) ContactNumber(label: n.label, value: n.ctl.text.trim()),
    ];
    final sips = [for (final s in _sips) if (s.text.trim().isNotEmpty) s.text.trim()];
    if (_name.text.trim().isEmpty && _company.text.trim().isEmpty && nums.isEmpty && sips.isEmpty) {
      ref.read(noticeProvider.notifier).error(ref.read(l10nProvider).contactsErrorNameOrNumber);
      return;
    }
    final name = _name.text.trim().isEmpty ? (nums.isNotEmpty ? nums.first.value : (sips.isNotEmpty ? sips.first : _company.text.trim())) : _name.text.trim();
    await ref.read(contactsProvider.notifier).save(
      Contact(
        id: _id,
        name: name,
        company: _company.text.trim(),
        numbers: nums,
        sipUris: sips,
        email: _email.text.trim(),
        notes: _notes.text.trim(),
        favorite: _fav,
        blf: _blf,
        ringtone: _ring,
        avatarColor: hashColor(name),
        presenceUri: _presenceUri,
        presenceAccountId: _presenceAcc.isEmpty ? null : _presenceAcc,
        autoRecord: _autoRecord,
      ),
    );
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final isNew = widget.contactId == null || widget.contactId == 'new';
    final t = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(isNew ? context.l10n.contactsNewTooltip : context.l10n.contactsEditTitle),
        actions: [TextButton(onPressed: _save, child: Text(context.l10n.actionSave)), const SizedBox(width: 8)],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextField(controller: _name, textCapitalization: TextCapitalization.words, decoration: InputDecoration(labelText: context.l10n.contactsFieldName, prefixIcon: const Icon(Icons.person_rounded))),
              const SizedBox(height: 12),
              TextField(controller: _company, textCapitalization: TextCapitalization.words, decoration: InputDecoration(labelText: context.l10n.contactsFieldCompany, prefixIcon: const Icon(Icons.business_rounded))),
              SectionHeader(context.l10n.contactsNumbersHeader, padding: const EdgeInsetsDirectional.fromSTEB(4, 20, 4, 8)),
              for (var i = 0; i < _nums.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 112,
                        child: DropdownButtonFormField<String>(
                          value: _nums[i].label,
                          isExpanded: true,
                          decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14)),
                          items: [for (final l in const ['mobile', 'work', 'home', 'other']) DropdownMenuItem(value: l, child: Text(contactLabelText(context.l10n, l)))],
                          onChanged: (v) => setState(() => _nums[i].label = v ?? 'other'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: TextField(controller: _nums[i].ctl, keyboardType: TextInputType.phone, textDirection: TextDirection.ltr, decoration: InputDecoration(labelText: context.l10n.contactsFieldNumber))),
                      IconButton(tooltip: context.l10n.contactsRemoveNumber, onPressed: () => setState(() => _nums.removeAt(i)), icon: const Icon(Icons.remove_circle_outline_rounded)),
                    ],
                  ),
                ),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: TextButton.icon(onPressed: () => setState(() => _nums.add(_NumRow('mobile', TextEditingController()))), icon: const Icon(Icons.add_rounded), label: Text(context.l10n.contactsAddNumber)),
              ),
              SectionHeader(context.l10n.contactsSipHeader, padding: const EdgeInsetsDirectional.fromSTEB(4, 12, 4, 8)),
              for (var i = 0; i < _sips.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Expanded(child: TextField(controller: _sips[i], keyboardType: TextInputType.emailAddress, textDirection: TextDirection.ltr, decoration: const InputDecoration(labelText: 'sip:user@domain'))),
                      IconButton(tooltip: context.l10n.contactsRemoveAddress, onPressed: () => setState(() => _sips.removeAt(i)), icon: const Icon(Icons.remove_circle_outline_rounded)),
                    ],
                  ),
                ),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: TextButton.icon(onPressed: () => setState(() => _sips.add(TextEditingController())), icon: const Icon(Icons.add_rounded), label: Text(context.l10n.contactsAddSip)),
              ),
              const SizedBox(height: 12),
              TextField(controller: _email, keyboardType: TextInputType.emailAddress, textDirection: TextDirection.ltr, decoration: InputDecoration(labelText: context.l10n.contactsFieldEmail, prefixIcon: const Icon(Icons.email_outlined))),
              const SizedBox(height: 12),
              TextField(controller: _notes, maxLines: 3, decoration: InputDecoration(labelText: context.l10n.contactsFieldNotes, prefixIcon: const Icon(Icons.notes_rounded))),
              const SizedBox(height: 12),
              Card(
                child: Column(
                  children: [
                    SwitchListTile(secondary: const Icon(Icons.star_outline_rounded), title: Text(context.l10n.contactsFieldFavorite), value: _fav, onChanged: (v) => setState(() => _fav = v)),
                    const Divider(height: 1),
                    SwitchListTile(
                      secondary: const Icon(Icons.grid_view_rounded),
                      title: Text(context.l10n.contactsShowOnBlf),
                      subtitle: Text(context.l10n.contactsShowOnBlfSub),
                      value: _blf,
                      onChanged: (v) => setState(() => _blf = v),
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      key: const Key('contact-auto-record'),
                      secondary: const Icon(Icons.fiber_manual_record_rounded),
                      title: Text(context.l10n.contactsAlwaysRecordTitle),
                      subtitle: Text(context.l10n.contactsAlwaysRecordSub),
                      value: _autoRecord,
                      onChanged: (v) => setState(() => _autoRecord = v),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.music_note_rounded),
                      title: Text(context.l10n.contactsRingtone),
                      trailing: DropdownButton<String>(
                        value: _ring,
                        underline: const SizedBox.shrink(),
                        items: [
                          for (final e in ringtoneOptions(context.l10n).entries)
                            DropdownMenuItem(value: e.key, child: Text(e.key == 'default' ? context.l10n.commonDefault : e.value)),
                        ],
                        onChanged: (v) => setState(() => _ring = v ?? 'default'),
                      ),
                    ),
                    if (_blf && ref.watch(accountsProvider).profiles.length > 1) ...[
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.dns_rounded),
                        title: Text(context.l10n.contactsPresenceVia),
                        trailing: DropdownButton<String>(
                          key: const Key('presence-account'),
                          value: _presenceAcc,
                          underline: const SizedBox.shrink(),
                          items: [
                            DropdownMenuItem(value: '', child: Text(context.l10n.contactsDefaultAccount)),
                            for (final p in ref.watch(accountsProvider).profiles) DropdownMenuItem(value: p.id, child: Text(p.name)),
                          ],
                          onChanged: (v) => setState(() => _presenceAcc = v ?? ''),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (!isNew) ...[
                const SizedBox(height: 16),
                TextButton.icon(
                  style: TextButton.styleFrom(foregroundColor: t.colorScheme.error),
                  onPressed: () async {
                    if (await confirm(context, title: context.l10n.contactsDeleteContactTitle, message: context.l10n.contactsCannotUndo)) {
                      await ref.read(contactsProvider.notifier).delete(_id);
                      if (context.mounted) context.go('/contacts');
                    }
                  },
                  icon: const Icon(Icons.delete_outline_rounded),
                  label: Text(context.l10n.contactsDeleteButton),
                ),
              ],
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _NumRow {
  _NumRow(this.label, this.ctl);
  String label;
  final TextEditingController ctl;
}
