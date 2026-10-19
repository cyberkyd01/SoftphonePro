import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:spcore_dart/spcore_dart.dart';

import '../widgets/settings_tiles.dart';

/// Chooses a certificate / key file. Replaceable in tests.
typedef TlsFilePicker = Future<String?> Function(String title);

/// On iOS and Android the picker hands out a cache copy; keep our own copy
/// so the path stays valid. Desktop uses the chosen path directly.
Future<String?> defaultTlsFilePicker(String title) async {
  final r = await FilePicker.platform.pickFiles(dialogTitle: title, type: FileType.any);
  final src = r?.files.single.path;
  if (src == null) return null;
  if (kIsWeb || !(Platform.isIOS || Platform.isAndroid)) return src;
  final dir = await getApplicationSupportDirectory();
  final dest = Directory(p.join(dir.path, 'tls'));
  await dest.create(recursive: true);
  final out = p.join(dest.path, '${DateTime.now().millisecondsSinceEpoch}_${p.basename(src)}');
  await File(src).copy(out);
  return out;
}

final tlsFilePickerProvider = Provider<TlsFilePicker>((ref) => defaultTlsFilePicker);

/// Returns [c] with the client certificate replaced (null removes it).
AccountConfig withTlsClientCert(AccountConfig c, TlsClientCert? cert) {
  final j = c.toJson();
  if (cert == null || (cert.certFile.isEmpty && cert.keyFile.isEmpty && (cert.password ?? '').isEmpty)) {
    j.remove('tlsClientCert');
  } else {
    j['tlsClientCert'] = cert.toJson();
  }
  return AccountConfig.fromJson(j);
}

/// Whether a client certificate is complete enough to send to the engine.
bool tlsClientCertComplete(TlsClientCert? c) => c != null && c.certFile.isNotEmpty && c.keyFile.isNotEmpty;

/// Account editor group: mutual TLS client certificate (ENGINE_API 9.6).
class TlsClientCertGroup extends ConsumerWidget {
  const TlsClientCertGroup({super.key, required this.config, required this.onChanged});
  final AccountConfig config;
  final ValueChanged<AccountConfig> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cert = config.tlsClientCert ?? const TlsClientCert();
    final pick = ref.read(tlsFilePickerProvider);
    final incomplete = !tlsClientCertComplete(config.tlsClientCert) && config.tlsClientCert != null;
    Widget fileTile(Key key, String title, String value, ValueChanged<String> set) => ListTile(
      key: key,
      leading: const Icon(Icons.description_outlined),
      title: Text(title),
      subtitle: Text(value.isEmpty ? 'Not set' : p.basename(value), maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (value.isNotEmpty)
            IconButton(tooltip: 'Clear $title', icon: const Icon(Icons.close_rounded), onPressed: () => set('')),
          TextButton(
            onPressed: () async {
              final path = await pick(title);
              if (path != null) set(path);
            },
            child: Text(value.isEmpty ? 'Choose...' : 'Change...'),
          ),
        ],
      ),
    );
    return SettingsGroup(
      title: 'Client certificate (mutual TLS)',
      footer: incomplete
          ? 'Choose both a certificate and its private key. The certificate is only presented once both are set.'
          : 'For servers that ask the app to identify itself with a certificate. PEM files. Used for TLS and secure WebSocket.',
      children: [
        fileTile(const Key('acc-tls-cert'), 'Certificate file', cert.certFile, (v) => onChanged(withTlsClientCert(config, cert.copyWith(certFile: v)))),
        fileTile(const Key('acc-tls-key'), 'Private key file', cert.keyFile, (v) => onChanged(withTlsClientCert(config, cert.copyWith(keyFile: v)))),
        TextTile(
          key: const Key('acc-tls-key-password'),
          icon: Icons.key_rounded,
          title: 'Key password',
          subtitle: 'Only if the key is encrypted',
          value: cert.password ?? '',
          obscure: true,
          hint: 'None',
          onChanged: (v) => onChanged(withTlsClientCert(config, v.isEmpty ? TlsClientCert(certFile: cert.certFile, keyFile: cert.keyFile) : cert.copyWith(password: v))),
        ),
      ],
    );
  }
}
