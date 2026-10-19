import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme.dart';
import '../widgets/basic_widgets.dart';
import '../../platform/desktop/shortcuts_section.dart';
import 'provisioning_section.dart';
import 'sections.dart';

class SettingsEntry {
  const SettingsEntry(this.key, this.title, this.icon, this.builder, {this.subtitle = ''});
  final String key;
  final String title;
  final String subtitle;
  final IconData icon;
  final Widget Function() builder;
}

final List<SettingsEntry> kSettingsEntries = [
  SettingsEntry('accounts', 'Accounts', Icons.dns_rounded, () => const AccountsSection(), subtitle: 'SIP accounts and registration'),
  SettingsEntry('audio', 'Audio', Icons.mic_rounded, () => const AudioSection(), subtitle: 'Devices, levels, echo cancellation'),
  SettingsEntry('codecs', 'Codecs', Icons.graphic_eq_rounded, () => const CodecsSection(), subtitle: 'Order, availability, Opus'),
  SettingsEntry('calls', 'Calls', Icons.call_rounded, () => const CallsSection(), subtitle: 'DND, waiting, auto-answer, dial rules'),
  SettingsEntry('network', 'Network', Icons.lan_rounded, () => const NetworkSection(), subtitle: 'Transports, STUN, TLS, DNS'),
  SettingsEntry('recording', 'Recording', Icons.fiber_manual_record_rounded, () => const RecordingSection()),
  SettingsEntry('notifications', 'Notifications and ringtones', Icons.notifications_rounded, () => const NotificationsSection()),
  if (hotkeysSupported)
    SettingsEntry('shortcuts', 'Shortcuts', Icons.keyboard_rounded, () => const ShortcutsSection(), subtitle: 'Global hotkeys, in-app keys'),
  SettingsEntry('appearance', 'Appearance', Icons.palette_rounded, () => const AppearanceSection()),
  SettingsEntry('privacy', 'Privacy and security', Icons.shield_rounded, () => const PrivacySection()),
  SettingsEntry('lan', 'LAN Link', Icons.devices_rounded, () => const LanSection()),
  SettingsEntry('provisioning', 'Provisioning', Icons.qr_code_2_rounded, () => const ProvisioningSection(), subtitle: 'Import, export, QR'),
  SettingsEntry('diagnostics', 'Diagnostics', Icons.monitor_heart_rounded, () => const DiagnosticsSection(), subtitle: 'SIP trace, network checks'),
  SettingsEntry('advanced', 'Advanced', Icons.tune_rounded, () => const AdvancedSection()),
  SettingsEntry('about', 'About', Icons.info_outline_rounded, () => const AboutSection()),
];

SettingsEntry? settingsEntry(String? key) {
  for (final e in kSettingsEntries) {
    if (e.key == key) return e;
  }
  return null;
}

/// Settings hub: list on compact, master/detail on expanded.
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key, this.section});
  final String? section;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expanded = context.isExpanded;
    final t = Theme.of(context);
    final entry = settingsEntry(section) ?? (expanded ? kSettingsEntries.first : null);

    Widget list(String? selected) => ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        const PageHeader(title: 'Settings'),
        const SizedBox(height: 4),
        for (final e in kSettingsEntries)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
            child: ListTile(
              key: Key('settings-${e.key}'),
              selected: selected == e.key,
              selectedTileColor: t.colorScheme.primary.withValues(alpha: 0.1),
              leading: Icon(e.icon),
              title: Text(e.title),
              subtitle: expanded || e.subtitle.isEmpty ? null : Text(e.subtitle),
              trailing: expanded ? null : const Icon(Icons.chevron_right_rounded),
              onTap: () => context.go('/settings/${e.key}'),
            ),
          ),
      ],
    );

    if (!expanded) {
      if (entry == null) return list(null);
      return _Detail(entry: entry, showBack: true);
    }
    return Row(
      children: [
        SizedBox(width: 300, child: list(entry?.key)),
        VerticalDivider(width: 1, color: t.colorScheme.outlineVariant),
        Expanded(child: _Detail(entry: entry!, showBack: false)),
      ],
    );
  }
}

class _Detail extends StatelessWidget {
  const _Detail({required this.entry, required this.showBack});
  final SettingsEntry entry;
  final bool showBack;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        PageHeader(
          title: entry.title,
          leading: showBack ? IconButton(tooltip: 'Back', onPressed: () => context.go('/settings'), icon: const Icon(Icons.arrow_back_rounded)) : null,
        ),
        Expanded(
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 720), child: entry.builder()),
          ),
        ),
      ],
    );
  }
}
