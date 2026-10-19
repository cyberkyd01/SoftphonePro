import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/settings_controller.dart';
import '../ui/widgets/settings_tiles.dart';
import 'automation_auth.dart';
import 'automation_service.dart';

/// Settings › Advanced › Local automation API.
class AutomationSettingsGroup extends ConsumerStatefulWidget {
  const AutomationSettingsGroup({super.key});
  @override
  ConsumerState<AutomationSettingsGroup> createState() => _AutomationSettingsGroupState();
}

class _AutomationSettingsGroupState extends ConsumerState<AutomationSettingsGroup> {
  bool _reveal = false;

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(settingsProvider);
    final st = ref.watch(automationServiceProvider);
    final svc = ref.read(automationServiceProvider.notifier);
    final t = Theme.of(context);
    final token = s.automationToken;
    final shownToken = token.isEmpty
        ? 'Created when you turn the API on'
        : (_reveal ? token : '${token.substring(0, 4)}${'•' * 20}');
    final status = !s.automationEnabled
        ? 'Off'
        : st.running
            ? 'Listening on http://127.0.0.1:${st.port}'
            : (st.error ?? 'Starting...');
    return SettingsGroup(
      title: 'Local automation API',
      footer:
          'For CRM and helpdesk integrations on this computer. It listens on 127.0.0.1 only and every request needs the access token. See docs/AUTOMATION_API.md.',
      children: [
        SwitchTile(
          key: const Key('automation-enabled'),
          icon: Icons.api_rounded,
          title: 'Enable local automation API',
          subtitle: status,
          value: s.automationEnabled,
          onChanged: (v) => svc.setEnabled(v),
        ),
        if (s.automationEnabled && !st.running && st.error != null)
          ListTile(
            key: const Key('automation-error'),
            leading: Icon(Icons.error_outline_rounded, color: t.colorScheme.error),
            title: Text(st.error!, style: TextStyle(color: t.colorScheme.error)),
          ),
        TextTile(
          key: const Key('automation-port'),
          icon: Icons.numbers_rounded,
          title: 'Port',
          subtitle: 'Default 7771. Choose a free port between 1024 and 65535.',
          value: '${s.automationPort}',
          keyboardType: TextInputType.number,
          validator: (v) {
            final n = int.tryParse(v.trim());
            return n == null || n < 1024 || n > 65535 ? 'Enter a port from 1024 to 65535' : null;
          },
          onChanged: (v) {
            final n = int.tryParse(v.trim());
            if (n != null && n >= 1024 && n <= 65535) {
              ref.read(settingsProvider.notifier).update({'automationPort': n});
            }
          },
        ),
        ListTile(
          key: const Key('automation-token'),
          leading: const Icon(Icons.key_rounded),
          title: const Text('Access token'),
          subtitle: SelectableText(
            shownToken,
            maxLines: 1,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
          ),
          trailing: Wrap(
            spacing: 0,
            children: [
              IconButton(
                key: const Key('automation-token-reveal'),
                tooltip: _reveal ? 'Hide token' : 'Show token',
                icon: Icon(_reveal ? Icons.visibility_off_rounded : Icons.visibility_rounded),
                onPressed: token.isEmpty ? null : () => setState(() => _reveal = !_reveal),
              ),
              IconButton(
                key: const Key('automation-token-copy'),
                tooltip: 'Copy token',
                icon: const Icon(Icons.copy_rounded),
                onPressed: token.isEmpty
                    ? null
                    : () async {
                        await Clipboard.setData(ClipboardData(text: token));
                        if (context.mounted) {
                          ScaffoldMessenger.maybeOf(context)?.showSnackBar(
                            const SnackBar(content: Text('Token copied')),
                          );
                        }
                      },
              ),
              IconButton(
                key: const Key('automation-token-regenerate'),
                tooltip: 'Generate a new token',
                icon: const Icon(Icons.refresh_rounded),
                onPressed: () async {
                  final ok = await showDialog<bool>(
                    context: context,
                    builder: (c) => AlertDialog(
                      title: const Text('Generate a new token?'),
                      content: const Text('Programs using the old token stop working until you give them the new one.'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
                        FilledButton(
                          key: const Key('automation-token-regenerate-yes'),
                          onPressed: () => Navigator.pop(c, true),
                          child: const Text('Generate'),
                        ),
                      ],
                    ),
                  );
                  if (ok == true) await svc.regenerateToken();
                },
              ),
            ],
          ),
        ),
        TextTile(
          key: const Key('automation-origins'),
          icon: Icons.public_rounded,
          title: 'Allowed browser origins',
          subtitle: 'Comma separated, for example https://crm.example.com. Programs without a browser (curl, scripts) do not need this.',
          hint: 'None',
          value: s.automationOrigins.join(', '),
          validator: (v) {
            for (final o in v.split(RegExp(r'[,\s]+')).where((e) => e.isNotEmpty)) {
              if (normalizeOrigin(o) == null) return 'Not an http(s) origin: $o';
            }
            return null;
          },
          onChanged: (v) => ref.read(settingsProvider.notifier).update({
            'automationOrigins': [
              for (final o in v.split(RegExp(r'[,\s]+')))
                if (normalizeOrigin(o) case final n?) n,
            ],
          }),
        ),
      ],
    );
  }
}
