import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lan_link/lan_link.dart' as ll;
import 'package:path/path.dart' as p;

import '../../../core/theme.dart';
import '../../../lan/lan_controller.dart';
import '../../../services/providers.dart';
import '../../widgets/basic_widgets.dart';

/// Small "LAN" pill used on chat threads and conversation rows.
class LanBadge extends StatelessWidget {
  const LanBadge({super.key});
  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: t.colorScheme.tertiary.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text('LAN', style: t.textTheme.labelSmall?.copyWith(color: t.colorScheme.tertiary, fontWeight: FontWeight.w800, letterSpacing: 0.4)),
    );
  }
}

IconData platformIcon(String platform) => switch (platform) {
      'android' => Icons.phone_android_rounded,
      'ios' => Icons.phone_iphone_rounded,
      'macos' => Icons.laptop_mac_rounded,
      'windows' => Icons.desktop_windows_rounded,
      'linux' => Icons.computer_rounded,
      _ => Icons.devices_rounded,
    };

String statusLabelOf(ll.LanPeer p) {
  if (!p.online) return 'Offline';
  return switch (p.status) {
    ll.PeerStatus.available => 'Available',
    ll.PeerStatus.busy => 'Busy',
    ll.PeerStatus.onCall => 'On a call',
    ll.PeerStatus.dnd => 'Do not disturb',
  };
}

Color statusColorOf(BuildContext context, ll.LanPeer p) {
  final c = context.colors;
  if (!p.online) return c.disabled;
  return switch (p.status) {
    ll.PeerStatus.available => c.regOk,
    ll.PeerStatus.busy || ll.PeerStatus.onCall => c.regWarn,
    ll.PeerStatus.dnd => c.regFail,
  };
}

String formatBytes(int n) {
  if (n < 1024) return '$n B';
  const u = ['KB', 'MB', 'GB', 'TB'];
  var v = n / 1024.0;
  var i = 0;
  while (v >= 1024 && i < u.length - 1) {
    v /= 1024;
    i++;
  }
  return '${v.toStringAsFixed(v >= 10 ? 0 : 1)} ${u[i]}';
}

/// Overridable (tests) file picking and opening.
class LanFileOps {
  const LanFileOps();

  Future<List<String>> pick() async {
    try {
      final r = await FilePicker.platform.pickFiles(allowMultiple: true);
      return [for (final f in r?.files ?? const <PlatformFile>[]) if (f.path != null) f.path!];
    } catch (_) {
      return const [];
    }
  }

  Future<bool> open(String path) async {
    try {
      if (Platform.isMacOS) return (await Process.run('open', [path])).exitCode == 0;
      if (Platform.isWindows) return (await Process.run('explorer', [path])).exitCode <= 1;
      if (Platform.isLinux) return (await Process.run('xdg-open', [path])).exitCode == 0;
    } catch (_) {}
    return false;
  }

  Future<bool> reveal(String path) async {
    try {
      if (Platform.isMacOS) return (await Process.run('open', ['-R', path])).exitCode == 0;
      if (Platform.isWindows) return (await Process.run('explorer', ['/select,', path])).exitCode <= 1;
      if (Platform.isLinux) return (await Process.run('xdg-open', [p.dirname(path)])).exitCode == 0;
    } catch (_) {}
    return false;
  }

  bool get isDesktop => !kIsWeb && (Platform.isMacOS || Platform.isWindows || Platform.isLinux);
}

final lanFileOpsProvider = Provider<LanFileOps>((ref) => const LanFileOps());

Future<void> pickAndSendLanFile(BuildContext context, WidgetRef ref, String peerId) async {
  final paths = await ref.read(lanFileOpsProvider).pick();
  final lan = ref.read(lanControllerProvider.notifier);
  for (final path in paths) {
    lan.sendFile(peerId, path);
  }
  if (paths.isNotEmpty) {
    ref.read(noticeProvider.notifier).show(paths.length == 1 ? 'Sending ${p.basename(paths.first)}...' : 'Sending ${paths.length} files...');
  }
}

/// Choose where a new message goes: a paired device (returns its id) or SIP.
Future<String?> pickLanChatPeer(BuildContext context, List<ll.LanPeer> paired) {
  return showModalBottomSheet<String>(
    context: context,
    showDragHandle: true,
    builder: (ctx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: Align(alignment: Alignment.centerLeft, child: Text('New message', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600))),
          ),
          ListTile(
            key: const Key('new-sip-message'),
            leading: const Icon(Icons.alternate_email_rounded),
            title: const Text('SIP message'),
            subtitle: const Text('To a number or address through your account'),
            onTap: () => Navigator.pop(ctx, 'sip'),
          ),
          for (final d in paired)
            ListTile(
              key: Key('new-lan-${d.deviceId}'),
              leading: Avatar(name: d.name, size: 36, icon: platformIcon(d.info?.platform ?? '')),
              title: Text(d.name),
              subtitle: Text(d.online ? 'LAN chat, online' : 'LAN chat, offline'),
              trailing: const LanBadge(),
              onTap: () => Navigator.pop(ctx, d.deviceId),
            ),
        ],
      ),
    ),
  );
}

/// Opens/reveals a received file, falling back to showing its path.
Future<void> openLanFile(BuildContext context, WidgetRef ref, String path, {bool reveal = false}) async {
  final ops = ref.read(lanFileOpsProvider);
  final ok = reveal ? await ops.reveal(path) : await ops.open(path);
  if (ok) return;
  await Clipboard.setData(ClipboardData(text: path));
  ref.read(noticeProvider.notifier).show('Saved at $path (path copied)');
}
