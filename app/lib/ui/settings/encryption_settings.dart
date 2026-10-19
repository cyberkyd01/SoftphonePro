import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/l10n.dart';
import '../../services/providers.dart';
import '../../storage/app_database.dart';
import '../widgets/settings_tiles.dart';

/// Settings > Privacy and security: opt-in AES-256-GCM encryption of the local
/// database (call history, contacts, messages, settings). The change is
/// applied at the next start, before anything else touches the database; the
/// old file is kept as a backup until the start after that.
class EncryptionSettingsGroup extends ConsumerStatefulWidget {
  const EncryptionSettingsGroup({super.key});
  @override
  ConsumerState<EncryptionSettingsGroup> createState() => _EncryptionSettingsGroupState();
}

class _EncryptionSettingsGroupState extends ConsumerState<EncryptionSettingsGroup> {
  bool? _pending;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    final dir = ref.read(appDatabaseProvider).directory;
    final v = dir == null ? null : await AppDatabase.pendingMode(dir);
    if (mounted) {
      setState(() {
        _pending = v;
        _loaded = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final db = ref.watch(appDatabaseProvider);
    final dir = db.directory;
    final target = _pending ?? db.encrypted;
    final l = context.l10n;
    return SettingsGroup(
      title: l.encryptionTitle,
      footer: l.encryptionFooter,
      children: [
        SwitchTile(
          key: const Key('encrypt-data'),
          icon: Icons.enhanced_encryption_rounded,
          title: l.encryptionSwitchTitle,
          subtitle: !_loaded
              ? null
              : _pending != null
              ? (_pending! ? l.encryptionWillEncrypt : l.encryptionWillDecrypt)
              : (db.encrypted ? l.commonOn : l.commonOff),
          value: target,
          onChanged: dir == null || !_loaded
              ? null
              : (v) async {
                  if (v == db.encrypted) {
                    await AppDatabase.cancelRequest(dir);
                  } else {
                    await AppDatabase.requestMode(dir, encrypt: v);
                    ref.read(noticeProvider.notifier).show(v ? l.encryptionRestartToEncrypt : l.encryptionRestartToDecrypt);
                  }
                  await _refresh();
                },
        ),
      ],
    );
  }
}
