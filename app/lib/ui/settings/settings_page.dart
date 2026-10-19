import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme.dart';
import '../../l10n/l10n.dart';
import '../widgets/basic_widgets.dart';
import '../../platform/desktop/shortcuts_section.dart';
import 'provisioning_section.dart';
import 'sections.dart';

class SettingsEntry {
  const SettingsEntry(this.key, this.title, this.icon, this.builder, {this.subtitle});
  final String key;
  final String Function(AppLocalizations l) title;
  final String Function(AppLocalizations l)? subtitle;
  final IconData icon;
  final Widget Function() builder;
}

final List<SettingsEntry> kSettingsEntries = [
  SettingsEntry('accounts', (l) => l.settingsEntryAccounts, Icons.dns_rounded, () => const AccountsSection(), subtitle: (l) => l.settingsEntryAccountsSub),
  SettingsEntry('audio', (l) => l.settingsEntryAudio, Icons.mic_rounded, () => const AudioSection(), subtitle: (l) => l.settingsEntryAudioSub),
  SettingsEntry('codecs', (l) => l.settingsEntryCodecs, Icons.graphic_eq_rounded, () => const CodecsSection(), subtitle: (l) => l.settingsEntryCodecsSub),
  SettingsEntry('calls', (l) => l.settingsEntryCalls, Icons.call_rounded, () => const CallsSection(), subtitle: (l) => l.settingsEntryCallsSub),
  SettingsEntry('network', (l) => l.settingsEntryNetwork, Icons.lan_rounded, () => const NetworkSection(), subtitle: (l) => l.settingsEntryNetworkSub),
  SettingsEntry('recording', (l) => l.settingsEntryRecording, Icons.fiber_manual_record_rounded, () => const RecordingSection()),
  SettingsEntry('notifications', (l) => l.settingsEntryNotifications, Icons.notifications_rounded, () => const NotificationsSection()),
  if (hotkeysSupported)
    SettingsEntry('shortcuts', (l) => l.settingsEntryShortcuts, Icons.keyboard_rounded, () => const ShortcutsSection(), subtitle: (l) => l.settingsEntryShortcutsSub),
  SettingsEntry('appearance', (l) => l.settingsEntryAppearance, Icons.palette_rounded, () => const AppearanceSection()),
  SettingsEntry('privacy', (l) => l.settingsEntryPrivacy, Icons.shield_rounded, () => const PrivacySection()),
  SettingsEntry('lan', (l) => l.settingsEntryLan, Icons.devices_rounded, () => const LanSection()),
  SettingsEntry('provisioning', (l) => l.settingsEntryProvisioning, Icons.qr_code_2_rounded, () => const ProvisioningSection(), subtitle: (l) => l.settingsEntryProvisioningSub),
  SettingsEntry('diagnostics', (l) => l.settingsEntryDiagnostics, Icons.monitor_heart_rounded, () => const DiagnosticsSection(), subtitle: (l) => l.settingsEntryDiagnosticsSub),
  SettingsEntry('advanced', (l) => l.settingsEntryAdvanced, Icons.tune_rounded, () => const AdvancedSection()),
  SettingsEntry('about', (l) => l.settingsEntryAbout, Icons.info_outline_rounded, () => const AboutSection()),
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
        PageHeader(title: context.l10n.actionSettings),
        const SizedBox(height: 4),
        for (final e in kSettingsEntries)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
            child: ListTile(
              key: Key('settings-${e.key}'),
              selected: selected == e.key,
              selectedTileColor: t.colorScheme.primary.withValues(alpha: 0.1),
              leading: Icon(e.icon),
              title: Text(e.title(context.l10n)),
              subtitle: expanded || e.subtitle == null ? null : Text(e.subtitle!(context.l10n)),
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
          title: entry.title(context.l10n),
          leading: showBack ? IconButton(tooltip: context.l10n.actionBack, onPressed: () => context.go('/settings'), icon: const Icon(Icons.arrow_back_rounded)) : null,
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
