import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/format.dart';
import '../../core/theme.dart';
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
      items.add('★ Favorites');
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
          title: 'Contacts',
          actions: [
            IconButton(
              tooltip: _favOnly ? 'Show all' : 'Favorites only',
              onPressed: () => setState(() => _favOnly = !_favOnly),
              icon: Icon(_favOnly ? Icons.star_rounded : Icons.star_outline_rounded),
            ),
            PopupMenuButton<String>(
              tooltip: 'Import and export',
              onSelected: (v) => _menu(v),
              itemBuilder: (_) => [
                if (ref.read(deviceContactsSourceProvider) != null)
                  const PopupMenuItem(value: 'device', child: Text('Import from device')),
                const PopupMenuItem(value: 'import', child: Text('Import vCard / CSV file')),
                const PopupMenuItem(value: 'paste', child: Text('Import from clipboard')),
                const PopupMenuItem(value: 'vcf', child: Text('Copy as vCard')),
                const PopupMenuItem(value: 'csv', child: Text('Copy as CSV')),
              ],
            ),
            IconButton(
              tooltip: 'New contact',
              onPressed: () => context.push('/contacts/new'),
              icon: const Icon(Icons.person_add_alt_1_rounded),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
          child: TextField(
            onChanged: (v) => setState(() => _q = v),
            decoration: const InputDecoration(hintText: 'Search contacts', prefixIcon: Icon(Icons.search_rounded)),
          ),
        ),
        Expanded(
          child: all.isEmpty
              ? EmptyState(
                  icon: Icons.people_alt_rounded,
                  title: 'No contacts yet',
                  subtitle: 'Add people you call often, or import a vCard or CSV file.',
                  actionLabel: 'Add a contact',
                  onAction: () => context.push('/contacts/new'),
                )
              : list.isEmpty
              ? const EmptyState(icon: Icons.search_off_rounded, title: 'No matches')
              : ListView.builder(
                  padding: const EdgeInsets.only(bottom: 24),
                  itemCount: items.length,
                  itemBuilder: (context, i) {
                    final it = items[i];
                    if (it is String) return SectionHeader(it, padding: const EdgeInsets.fromLTRB(16, 14, 16, 2));
                    final c = it as Contact;
                    return ListTile(
                      key: ValueKey('${c.id}-$i'),
                      selected: expanded && _selected == c.id,
                      selectedTileColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
                      leading: Avatar(name: c.displayName, color: Color(c.avatarColor), lamp: c.blf ? presence.lampOf(c.id) : LampState.unknown),
                      title: Text(c.displayName, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text(
                        [if (c.company.isNotEmpty) c.company, c.primary].where((e) => e.isNotEmpty).join('  ·  '),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: c.addresses.isEmpty
                          ? null
                          : IconButton(
                              tooltip: 'Call ${c.displayName}',
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
              ? const EmptyState(icon: Icons.touch_app_rounded, title: 'Select a contact')
              : ContactDetailView(contactId: _selected!, embedded: true),
        ),
      ],
    );
  }

  Future<void> _menu(String v) async {
    final ctl = ref.read(contactsProvider.notifier);
    final notice = ref.read(noticeProvider.notifier);
    switch (v) {
      case 'vcf':
        await Clipboard.setData(ClipboardData(text: ctl.exportVCard()));
        notice.show('Contacts copied as vCard');
      case 'csv':
        await Clipboard.setData(ClipboardData(text: ctl.exportCsv()));
        notice.show('Contacts copied as CSV');
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
    final src = ref.read(deviceContactsSourceProvider);
    final notice = ref.read(noticeProvider.notifier);
    if (src == null) return;
    if (!await src.requestPermission()) {
      notice.show('Contacts access was denied. Allow it in system settings to import.', isError: true);
      return;
    }
    final device = await src.read();
    final plan = planDeviceImport(ref.read(contactsProvider), device);
    if (!mounted) return;
    if (plan.isEmpty) {
      notice.show(device.isEmpty ? 'No contacts found on this device' : 'Nothing new to import (${plan.skipped} already present)');
      return;
    }
    final ok = await confirm(
      context,
      title: 'Import from device?',
      message:
          '${plan.added.length} new contact${plan.added.length == 1 ? '' : 's'}'
          '${plan.updated.isEmpty ? '' : ', ${plan.updated.length} updated with extra numbers'}'
          '${plan.skipped == 0 ? '' : ', ${plan.skipped} skipped (duplicates or no phone number)'}.',
      confirmLabel: 'Import',
      destructive: false,
    );
    if (!ok) return;
    final n = await ref.read(contactsProvider.notifier).applyImport(plan);
    notice.show('Imported $n contact${n == 1 ? '' : 's'}');
  }

  Future<void> _import(String text, {String name = ''}) async {
    final isCsv = name.toLowerCase().endsWith('.csv') || (!text.contains('BEGIN:VCARD'));
    final parsed = isCsv ? ContactIo.fromCsv(text) : ContactIo.fromVCard(text);
    final n = await ref.read(contactsProvider.notifier).importAll(parsed);
    ref.read(noticeProvider.notifier).show(parsed.isEmpty ? 'No contacts found in that data' : 'Imported $n contacts');
  }
}

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
            ListTile(leading: const Icon(Icons.phone_rounded), title: Text(n.value), subtitle: Text(n.label), onTap: () => Navigator.pop(ctx, n.value)),
          for (final u in c.sipUris) ListTile(leading: const Icon(Icons.alternate_email_rounded), title: Text(u), subtitle: const Text('SIP'), onTap: () => Navigator.pop(ctx, u)),
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
    if (c == null) return const EmptyState(icon: Icons.person_off_rounded, title: 'Contact not found');
    final t = Theme.of(context);
    final colors = context.colors;
    final acc = ref.watch(accountsProvider);
    final body = ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
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
                _CircleAction(icon: Icons.call_rounded, label: 'Call', color: colors.callGreen, onTap: c.addresses.isEmpty ? null : () => _callContact(context, ref, c)),
                _CircleAction(
                  icon: Icons.message_rounded,
                  label: 'Message',
                  onTap: c.addresses.isEmpty || acc.defaultProfile == null
                      ? null
                      : () => context.push('/thread?acc=${acc.defaultProfile!.id}&peer=${Uri.encodeQueryComponent(c.primary)}'),
                ),
                _CircleAction(
                  icon: c.favorite ? Icons.star_rounded : Icons.star_outline_rounded,
                  label: 'Favorite',
                  color: c.favorite ? colors.holdAmber : null,
                  onTap: () => ref.read(contactsProvider.notifier).toggleFavorite(c.id),
                ),
                _CircleAction(icon: Icons.edit_rounded, label: 'Edit', onTap: () => context.push('/contacts/${c.id}/edit')),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (c.numbers.isNotEmpty || c.sipUris.isNotEmpty)
          SettingsGroup(
            title: 'Numbers',
            children: [
              for (final n in c.numbers)
                ListTile(
                  leading: const Icon(Icons.phone_rounded),
                  title: Text(n.value, style: tabular(null)),
                  subtitle: Text(n.label),
                  trailing: IconButton(tooltip: 'Call ${n.value}', icon: Icon(Icons.call_rounded, color: colors.callGreen), onPressed: () => ref.read(callsProvider.notifier).dial(n.value)),
                ),
              for (final u in c.sipUris)
                ListTile(
                  leading: const Icon(Icons.alternate_email_rounded),
                  title: Text(u),
                  subtitle: const Text('SIP address'),
                  trailing: IconButton(tooltip: 'Call $u', icon: Icon(Icons.call_rounded, color: colors.callGreen), onPressed: () => ref.read(callsProvider.notifier).dial(u)),
                ),
            ],
          ),
        if (c.email.isNotEmpty || c.notes.isNotEmpty || c.blf)
          SettingsGroup(
            title: 'Details',
            children: [
              if (c.email.isNotEmpty) ListTile(leading: const Icon(Icons.email_outlined), title: Text(c.email)),
              if (c.blf) const ListTile(leading: Icon(Icons.grid_view_rounded), title: Text('Shown on the BLF board')),
              if (c.notes.isNotEmpty) ListTile(leading: const Icon(Icons.notes_rounded), title: Text(c.notes)),
            ],
          ),
        const SizedBox(height: 16),
        Align(
          child: TextButton.icon(
            onPressed: () async {
              if (await confirm(context, title: 'Delete ${c.displayName}?', message: 'This contact will be removed from this device.')) {
                await ref.read(contactsProvider.notifier).delete(c.id);
                if (!embedded && context.mounted) context.pop();
              }
            },
            style: TextButton.styleFrom(foregroundColor: t.colorScheme.error),
            icon: const Icon(Icons.delete_outline_rounded),
            label: const Text('Delete contact'),
          ),
        ),
      ],
    );
    if (embedded) return body;
    return Scaffold(appBar: AppBar(title: const Text('Contact')), body: body);
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
      ref.read(noticeProvider.notifier).error('Enter a name or a number');
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
        title: Text(isNew ? 'New contact' : 'Edit contact'),
        actions: [TextButton(onPressed: _save, child: const Text('Save')), const SizedBox(width: 8)],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextField(controller: _name, textCapitalization: TextCapitalization.words, decoration: const InputDecoration(labelText: 'Name', prefixIcon: Icon(Icons.person_rounded))),
              const SizedBox(height: 12),
              TextField(controller: _company, textCapitalization: TextCapitalization.words, decoration: const InputDecoration(labelText: 'Company', prefixIcon: Icon(Icons.business_rounded))),
              const SectionHeader('Numbers', padding: EdgeInsets.fromLTRB(4, 20, 4, 8)),
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
                          items: [for (final l in const ['mobile', 'work', 'home', 'other']) DropdownMenuItem(value: l, child: Text(l))],
                          onChanged: (v) => setState(() => _nums[i].label = v ?? 'other'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: TextField(controller: _nums[i].ctl, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Number'))),
                      IconButton(tooltip: 'Remove number', onPressed: () => setState(() => _nums.removeAt(i)), icon: const Icon(Icons.remove_circle_outline_rounded)),
                    ],
                  ),
                ),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(onPressed: () => setState(() => _nums.add(_NumRow('mobile', TextEditingController()))), icon: const Icon(Icons.add_rounded), label: const Text('Add number')),
              ),
              const SectionHeader('SIP addresses', padding: EdgeInsets.fromLTRB(4, 12, 4, 8)),
              for (var i = 0; i < _sips.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Expanded(child: TextField(controller: _sips[i], keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'sip:user@domain'))),
                      IconButton(tooltip: 'Remove address', onPressed: () => setState(() => _sips.removeAt(i)), icon: const Icon(Icons.remove_circle_outline_rounded)),
                    ],
                  ),
                ),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(onPressed: () => setState(() => _sips.add(TextEditingController())), icon: const Icon(Icons.add_rounded), label: const Text('Add SIP address')),
              ),
              const SizedBox(height: 12),
              TextField(controller: _email, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined))),
              const SizedBox(height: 12),
              TextField(controller: _notes, maxLines: 3, decoration: const InputDecoration(labelText: 'Notes', prefixIcon: Icon(Icons.notes_rounded))),
              const SizedBox(height: 12),
              Card(
                child: Column(
                  children: [
                    SwitchListTile(secondary: const Icon(Icons.star_outline_rounded), title: const Text('Favorite'), value: _fav, onChanged: (v) => setState(() => _fav = v)),
                    const Divider(height: 1),
                    SwitchListTile(
                      secondary: const Icon(Icons.grid_view_rounded),
                      title: const Text('Show on BLF board'),
                      subtitle: const Text('Watch this extension\'s presence and busy lamp'),
                      value: _blf,
                      onChanged: (v) => setState(() => _blf = v),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.music_note_rounded),
                      title: const Text('Ringtone'),
                      trailing: DropdownButton<String>(
                        value: _ring,
                        underline: const SizedBox.shrink(),
                        items: [
                          for (final e in kRingtoneOptions.entries)
                            DropdownMenuItem(value: e.key, child: Text(e.key == 'default' ? 'Default' : e.value)),
                        ],
                        onChanged: (v) => setState(() => _ring = v ?? 'default'),
                      ),
                    ),
                    if (_blf && ref.watch(accountsProvider).profiles.length > 1) ...[
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.dns_rounded),
                        title: const Text('Presence via account'),
                        trailing: DropdownButton<String>(
                          key: const Key('presence-account'),
                          value: _presenceAcc,
                          underline: const SizedBox.shrink(),
                          items: [
                            const DropdownMenuItem(value: '', child: Text('Default account')),
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
                    if (await confirm(context, title: 'Delete contact?', message: 'This cannot be undone.')) {
                      await ref.read(contactsProvider.notifier).delete(_id);
                      if (context.mounted) context.go('/contacts');
                    }
                  },
                  icon: const Icon(Icons.delete_outline_rounded),
                  label: const Text('Delete contact'),
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
