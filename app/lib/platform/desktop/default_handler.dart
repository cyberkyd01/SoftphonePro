import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


/// The schemes SoftphonePro can handle as the system dialler.
const kHandlerSchemes = ['sip', 'tel', 'callto'];

/// Who currently opens one link scheme.
class SchemeHandler {
  const SchemeHandler({
    required this.scheme,
    this.name = '',
    this.bundleId = '',
    this.isSelf = false,
  });
  final String scheme;
  final String name;
  final String bundleId;
  final bool isSelf;

  String get label => name.isNotEmpty ? name : (bundleId.isNotEmpty ? bundleId : 'none');
}

/// Outcome of [DefaultHandlerService.makeDefault].
class MakeDefaultResult {
  const MakeDefaultResult({required this.ok, this.failed = const [], this.openedSettings = false});
  final bool ok;
  final List<String> failed;

  /// Windows: the system "Default apps" page was opened; the user finishes there.
  final bool openedSettings;
}

/// Reads and sets the system default app for sip:, tel: and callto: links.
///  * macOS: Launch Services through the `softphonepro/desktop` channel
///    (`defaultHandlers` reads, `setDefaultHandler` asks macOS to switch).
///  * Windows: the installer registers the protocols; the user picks the app
///    in Settings, which [makeDefault] opens (`ms-settings:defaultapps`).
class DefaultHandlerService {
  DefaultHandlerService({
    MethodChannel? channel,
    bool? isMacOS,
    bool? isWindows,
    Future<void> Function(String uri)? openUri,
  }) : _channel = channel ?? const MethodChannel('softphonepro/desktop'),
       _mac = isMacOS ?? (!kIsWeb && Platform.isMacOS),
       _win = isWindows ?? (!kIsWeb && Platform.isWindows),
       _openUri = openUri ?? _defaultOpenUri;

  final MethodChannel _channel;
  final bool _mac;
  final bool _win;
  final Future<void> Function(String uri) _openUri;

  bool get supported => _mac || _win;

  /// Current handler per scheme (macOS). Empty elsewhere or on error.
  Future<List<SchemeHandler>> current() async {
    if (!_mac) return const [];
    try {
      final raw = await _channel.invokeMethod<Map<Object?, Object?>>('defaultHandlers');
      if (raw == null) return const [];
      return [
        for (final s in kHandlerSchemes)
          if (raw[s] is Map)
            SchemeHandler(
              scheme: s,
              name: '${(raw[s] as Map)['name'] ?? ''}',
              bundleId: '${(raw[s] as Map)['bundleId'] ?? ''}',
              isSelf: (raw[s] as Map)['isSelf'] == true,
            ),
      ];
    } on MissingPluginException {
      return const [];
    } on PlatformException {
      return const [];
    }
  }

  /// Asks the OS to make this app the default for sip:, tel: and callto:.
  Future<MakeDefaultResult> makeDefault() async {
    if (_mac) {
      try {
        final r = await _channel.invokeMethod<Map<Object?, Object?>>('setDefaultHandler');
        final failed = [
          for (final f in (r?['failed'] as List? ?? const [])) '$f',
        ];
        return MakeDefaultResult(ok: r?['ok'] == true, failed: failed);
      } on MissingPluginException {
        return const MakeDefaultResult(ok: false, failed: kHandlerSchemes);
      } on PlatformException {
        return const MakeDefaultResult(ok: false, failed: kHandlerSchemes);
      }
    }
    if (_win) {
      try {
        await _openUri('ms-settings:defaultapps');
        return const MakeDefaultResult(ok: true, openedSettings: true);
      } catch (_) {
        return const MakeDefaultResult(ok: false, failed: kHandlerSchemes);
      }
    }
    return const MakeDefaultResult(ok: false, failed: kHandlerSchemes);
  }
}

Future<void> _defaultOpenUri(String uri) async {
  // `start` treats the first quoted argument as a window title.
  await Process.run('cmd', ['/c', 'start', '', uri]);
}

final defaultHandlerServiceProvider = Provider<DefaultHandlerService>(
  (ref) => DefaultHandlerService(),
);

/// Settings › Calls: shows who handles sip:/tel:/callto: and offers to take over.
class DefaultHandlerTile extends ConsumerStatefulWidget {
  const DefaultHandlerTile({super.key});
  @override
  ConsumerState<DefaultHandlerTile> createState() => _DefaultHandlerTileState();
}

class _DefaultHandlerTileState extends ConsumerState<DefaultHandlerTile> {
  List<SchemeHandler> _handlers = const [];
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    final h = await ref.read(defaultHandlerServiceProvider).current();
    if (mounted) setState(() => _handlers = h);
  }

  Future<void> _make() async {
    setState(() => _busy = true);
    final svc = ref.read(defaultHandlerServiceProvider);
    final r = await svc.makeDefault();
    if (!mounted) return;
    setState(() => _busy = false);
    final msg = r.openedSettings
        ? 'Choose SoftphonePro for SIP, TEL and CALLTO in Default apps'
        : r.ok
            ? 'SoftphonePro now opens sip:, tel: and callto: links'
            : 'Could not change the default for ${r.failed.join(', ')}';
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(SnackBar(content: Text(msg)));
    await _refresh();
  }

  @override
  Widget build(BuildContext context) {
    final svc = ref.watch(defaultHandlerServiceProvider);
    if (!svc.supported) return const SizedBox.shrink();
    final allSelf = _handlers.isNotEmpty && _handlers.every((h) => h.isSelf);
    final status = _handlers.isEmpty
        ? 'Opens sip:, tel: and callto: links from browsers and other apps'
        : (allSelf
              ? 'SoftphonePro handles sip:, tel: and callto: links'
              : 'Now: ${[for (final h in _handlers) '${h.scheme}: ${h.label}'].join('  |  ')}');
    return ListTile(
      key: const Key('make-default-handler'),
      leading: const Icon(Icons.link_rounded),
      title: const Text('Make SoftphonePro the default app for sip:, tel: and callto: links'),
      subtitle: Text(status),
      trailing: _busy
          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
          : (allSelf ? const Icon(Icons.check_circle_rounded) : const Icon(Icons.chevron_right_rounded)),
      onTap: _busy || allSelf ? null : _make,
    );
  }
}
