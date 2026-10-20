import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

import '../../l10n/l10n.dart';

/// The schemes SoftphonePro can handle as the system dialler.
const kHandlerSchemes = ['sip', 'tel', 'callto'];

/// Linux desktop-file ID (also the app ID and icon name) the runner and the
/// packages use.
const kLinuxDesktopId = 'com.softphonepro.softphonepro';

/// Every scheme the Linux desktop file declares; all are set on "make default".
const kLinuxSchemes = ['sip', 'sips', 'tel', 'callto', 'softphonepro'];

/// Runs an external program (injected in tests).
typedef ProcessRunner = Future<ProcessResult> Function(String executable, List<String> arguments);

Future<ProcessResult> _runProcess(String exe, List<String> args) =>
    Process.run(exe, args).timeout(const Duration(seconds: 15));

/// One argument of a Desktop Entry `Exec=` line, quoted per the spec
/// (reserved characters need double quotes; `"`, `` ` ``, `$` and `\` get a
/// backslash, then every backslash is doubled for the string layer; `%` is
/// `%%`).
String desktopExecArg(String arg) {
  final pct = arg.replaceAll('%', '%%');
  const reserved = ' \t\n"\'\\><~|&;\$*?#()`';
  if (pct.isNotEmpty && !pct.split('').any(reserved.contains)) return pct;
  final inner = pct.replaceAllMapped(RegExp(r'["`$\\]'), (m) => '\\${m[0]}');
  return '"${inner.replaceAll('\\', '\\\\')}"';
}

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

  /// English name (tests / logs).
  String get label => labelOr('none');

  /// Name shown to the user; [noneLabel] when nothing handles the scheme.
  String labelOr(String noneLabel) => name.isNotEmpty ? name : (bundleId.isNotEmpty ? bundleId : noneLabel);
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
///  * Linux: `xdg-mime query|default x-scheme-handler/<scheme>` against the
///    desktop file [kLinuxDesktopId]. Packages install that file; for a
///    tarball [makeDefault] first writes a user-local one that points at the
///    running executable. Without `xdg-mime` the feature reports unsupported.
class DefaultHandlerService {
  DefaultHandlerService({
    MethodChannel? channel,
    bool? isMacOS,
    bool? isWindows,
    Future<void> Function(String uri)? openUri,
    bool? isLinux,
    ProcessRunner? runProcess,
    Map<String, String>? environment,
    String? executable,
  }) : _linux = isLinux ?? (!kIsWeb && Platform.isLinux),
       _run = runProcess ?? _runProcess,
       _env = environment ?? (kIsWeb ? const {} : Platform.environment),
       _exe = executable ?? (kIsWeb ? '' : Platform.resolvedExecutable),
       _channel = channel ?? const MethodChannel('softphonepro/desktop'),
       _mac = isMacOS ?? (!kIsWeb && Platform.isMacOS),
       _win = isWindows ?? (!kIsWeb && Platform.isWindows),
       _openUri = openUri ?? _defaultOpenUri;

  final MethodChannel _channel;
  final bool _mac;
  final bool _win;
  final bool _linux;
  final ProcessRunner _run;
  final Map<String, String> _env;
  final String _exe;
  final Future<void> Function(String uri) _openUri;

  bool get supported => _mac || _win || _linux;

  /// Linux: whether `xdg-mime` can be run. True elsewhere.
  Future<bool> isAvailable() async {
    if (!_linux) return supported;
    try {
      await _run('xdg-mime', const ['--version']);
      return true;
    } catch (_) {
      return false;
    }
  }

  // ---- Linux ----------------------------------------------------------------

  Future<String?> _xdgQuery(String scheme) async {
    try {
      final r = await _run('xdg-mime', ['query', 'default', 'x-scheme-handler/$scheme']);
      return r.exitCode == 0 ? '${r.stdout}'.trim() : null;
    } catch (_) {
      return null;
    }
  }

  Future<List<SchemeHandler>> _currentLinux() async {
    final out = <SchemeHandler>[];
    for (final s in kHandlerSchemes) {
      final id = await _xdgQuery(s);
      if (id == null) return const []; // xdg-mime missing / failing
      out.add(SchemeHandler(
        scheme: s,
        name: id.endsWith('.desktop') ? id.substring(0, id.length - 8) : id,
        bundleId: id,
        isSelf: id == '$kLinuxDesktopId.desktop',
      ));
    }
    return out;
  }

  String get _userApplicationsDir {
    final data = _env['XDG_DATA_HOME'];
    final base = data != null && data.isNotEmpty ? data : p.join(_env['HOME'] ?? '', '.local', 'share');
    return p.join(base, 'applications');
  }

  /// Directories searched for the desktop file (user dir first).
  List<String> get _applicationDirs {
    final dirs = _env['XDG_DATA_DIRS'];
    final list = (dirs == null || dirs.isEmpty ? '/usr/local/share:/usr/share' : dirs).split(':').where((d) => d.isNotEmpty);
    return [_userApplicationsDir, for (final d in list) p.join(d, 'applications')];
  }

  bool _desktopFileInstalled() => _applicationDirs.any((d) => File(p.join(d, '$kLinuxDesktopId.desktop')).existsSync());

  /// Desktop file text for a bundle that was not installed from a package.
  String linuxDesktopEntry() {
    final icon = p.join(p.dirname(_exe), 'data', 'flutter_assets', 'assets', 'branding', 'icon_1024.png');
    return '[Desktop Entry]\n'
        'Type=Application\n'
        'Name=SoftphonePro\n'
        'Comment=SIP softphone\n'
        'Exec=${desktopExecArg(_exe)} %u\n'
        'Icon=${File(icon).existsSync() ? icon : kLinuxDesktopId}\n'
        'Terminal=false\n'
        'Categories=Network;Telephony;\n'
        'StartupWMClass=softphonepro\n'
        'MimeType=${[for (final s in kLinuxSchemes) 'x-scheme-handler/$s'].join(';')};\n';
  }

  Future<MakeDefaultResult> _makeDefaultLinux() async {
    if (!await isAvailable()) return const MakeDefaultResult(ok: false, failed: kHandlerSchemes);
    try {
      if (!_desktopFileInstalled()) {
        final dir = _userApplicationsDir;
        await Directory(dir).create(recursive: true);
        await File(p.join(dir, '$kLinuxDesktopId.desktop')).writeAsString(linuxDesktopEntry());
        try {
          await _run('update-desktop-database', [dir]);
        } catch (_) {} // optional
      }
    } catch (e) {
      debugPrint('desktop file not written: $e');
      return const MakeDefaultResult(ok: false, failed: kHandlerSchemes);
    }
    final failed = <String>[];
    for (final s in kLinuxSchemes) {
      try {
        final r = await _run('xdg-mime', ['default', '$kLinuxDesktopId.desktop', 'x-scheme-handler/$s']);
        if (r.exitCode != 0) failed.add(s);
      } catch (_) {
        failed.add(s);
      }
    }
    return MakeDefaultResult(ok: failed.isEmpty, failed: failed);
  }

  /// Current handler per scheme (macOS). Empty elsewhere or on error.
  Future<List<SchemeHandler>> current() async {
    if (_linux) return _currentLinux();
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
    if (_linux) return _makeDefaultLinux();
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
  bool _available = true;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    final svc = ref.read(defaultHandlerServiceProvider);
    final ok = await svc.isAvailable(); // Linux without xdg-mime: hidden
    final h = ok ? await svc.current() : const <SchemeHandler>[];
    if (mounted) {
      setState(() {
        _available = ok;
        _handlers = h;
      });
    }
  }

  Future<void> _make() async {
    setState(() => _busy = true);
    final svc = ref.read(defaultHandlerServiceProvider);
    final r = await svc.makeDefault();
    if (!mounted) return;
    setState(() => _busy = false);
    final l = context.l10n;
    final msg = r.openedSettings
        ? l.defaultHandlerChooseInSettings
        : r.ok
            ? l.defaultHandlerNowOpens
            : l.defaultHandlerCouldNotChange(r.failed.join(', '));
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(SnackBar(content: Text(msg)));
    await _refresh();
  }

  @override
  Widget build(BuildContext context) {
    final svc = ref.watch(defaultHandlerServiceProvider);
    if (!svc.supported || !_available) return const SizedBox.shrink();
    final l = context.l10n;
    final allSelf = _handlers.isNotEmpty && _handlers.every((h) => h.isSelf);
    final status = _handlers.isEmpty
        ? l.defaultHandlerIntro
        : (allSelf
              ? l.defaultHandlerIsSelf
              : l.defaultHandlerNow([for (final h in _handlers) '${h.scheme}: ${h.labelOr(l.commonNone)}'].join('  |  ')));
    return ListTile(
      key: const Key('make-default-handler'),
      leading: const Icon(Icons.link_rounded),
      title: Text(l.defaultHandlerTitle),
      subtitle: Text(status),
      trailing: _busy
          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
          : (allSelf ? const Icon(Icons.check_circle_rounded) : const Icon(Icons.chevron_right_rounded)),
      onTap: _busy || allSelf ? null : _make,
    );
  }
}
