import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    return SettingsGroup(
      title: 'Encryption',
      footer:
          'Encrypts the local database with AES-256-GCM. The key is kept in the system keychain / keystore; if it is lost the data cannot be recovered. Call recordings and exported files are not encrypted. The change takes effect the next time SoftphonePro starts (quit it completely first); the previous file is kept as a backup until the start after that.',
      children: [
        SwitchTile(
          key: const Key('encrypt-data'),
          icon: Icons.enhanced_encryption_rounded,
          title: 'Encrypt call history, contacts and messages on this device',
          subtitle: !_loaded
              ? null
              : _pending != null
              ? 'Will ${_pending! ? 'be encrypted' : 'be decrypted'} at the next start'
              : (db.encrypted ? 'On' : 'Off'),
          value: target,
          onChanged: dir == null || !_loaded
              ? null
              : (v) async {
                  if (v == db.encrypted) {
                    await AppDatabase.cancelRequest(dir);
                  } else {
                    await AppDatabase.requestMode(dir, encrypt: v);
                    ref.read(noticeProvider.notifier).show('Quit and restart SoftphonePro to ${v ? 'encrypt' : 'decrypt'} your data.');
                  }
                  await _refresh();
                },
        ),
      ],
    );
  }
}
