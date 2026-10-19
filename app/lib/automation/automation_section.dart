import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/l10n.dart';
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
    final l = context.l10n;
    final token = s.automationToken;
    final shownToken = token.isEmpty
        ? l.automationTokenPlaceholder
        : (_reveal ? token : '${token.substring(0, 4)}${'•' * 20}');
    final status = !s.automationEnabled
        ? l.commonOff
        : st.running
            ? l.automationListening('http://127.0.0.1:${st.port}')
            : (st.error ?? l.automationStarting);
    return SettingsGroup(
      title: l.automationTitle,
      footer: l.automationFooter,
      children: [
        SwitchTile(
          key: const Key('automation-enabled'),
          icon: Icons.api_rounded,
          title: l.automationEnable,
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
          title: l.automationPort,
          subtitle: l.automationPortHint,
          value: '${s.automationPort}',
          keyboardType: TextInputType.number,
          validator: (v) {
            final n = int.tryParse(v.trim());
            return n == null || n < 1024 || n > 65535 ? l.automationPortInvalid : null;
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
          title: Text(l.automationAccessToken),
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
                tooltip: _reveal ? l.automationHideToken : l.automationShowToken,
                icon: Icon(_reveal ? Icons.visibility_off_rounded : Icons.visibility_rounded),
                onPressed: token.isEmpty ? null : () => setState(() => _reveal = !_reveal),
              ),
              IconButton(
                key: const Key('automation-token-copy'),
                tooltip: l.automationCopyToken,
                icon: const Icon(Icons.copy_rounded),
                onPressed: token.isEmpty
                    ? null
                    : () async {
                        await Clipboard.setData(ClipboardData(text: token));
                        if (context.mounted) {
                          ScaffoldMessenger.maybeOf(context)?.showSnackBar(
                            SnackBar(content: Text(l.automationTokenCopied)),
                          );
                        }
                      },
              ),
              IconButton(
                key: const Key('automation-token-regenerate'),
                tooltip: l.automationGenerateToken,
                icon: const Icon(Icons.refresh_rounded),
                onPressed: () async {
                  final ok = await showDialog<bool>(
                    context: context,
                    builder: (c) => AlertDialog(
                      title: Text(l.automationGenerateTitle),
                      content: Text(l.automationGenerateBody),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(c, false), child: Text(l.actionCancel)),
                        FilledButton(
                          key: const Key('automation-token-regenerate-yes'),
                          onPressed: () => Navigator.pop(c, true),
                          child: Text(l.automationGenerate),
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
          title: l.automationOrigins,
          subtitle: l.automationOriginsHint,
          hint: l.commonNone,
          value: s.automationOrigins.join(', '),
          validator: (v) {
            for (final o in v.split(RegExp(r'[,\s]+')).where((e) => e.isNotEmpty)) {
              if (normalizeOrigin(o) == null) return l.automationNotOrigin(o);
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
