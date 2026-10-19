/// Parsing of process arguments / forwarded command lines (pure Dart).
///
/// Windows: `softphonepro.exe "sip:alice@example.com"` (URL protocol handler),
/// `softphonepro.exe --minimized` (autostart). A second launch forwards its
/// arguments, joined with newlines, to the running instance.
library;

const kLinkSchemes = {'sip', 'sips', 'tel', 'callto', 'softphonepro'};

/// Internal scheme for `--provision` / `--dial` command-line intents. It is
/// not in [kLinkSchemes], so no OS-delivered URL can ever produce it: command
/// line arguments are local user intent, web links are not.
const kCliScheme = 'softphonepro-cli';

final Expando<bool> _localLaunchUris = Expando('localLaunchUri');

/// True only for links that [parseLaunchArgs] built from this process's own
/// command line (`--provision` / `--dial`). Identity based: a URL string
/// delivered by the OS, a web page or another app can never carry this mark.
bool isLocalLaunchLink(Uri uri) => _localLaunchUris[uri] == true;

/// Result of parsing a launch / forwarded command line.
class LaunchArgs {
  const LaunchArgs({this.link, this.minimized = false, this.show = false});

  /// The first sip:/sips:/tel:/callto:/softphonepro: link, if any.
  final Uri? link;

  /// `--minimized`: start hidden in the tray (autostart).
  final bool minimized;

  /// `--show`: a plain re-launch of the app; bring the window forward.
  final bool show;

  bool get isEmpty => link == null && !minimized && !show;
}

/// Parses [args]; unknown arguments are ignored.
LaunchArgs parseLaunchArgs(Iterable<String> args) {
  Uri? link;
  var minimized = false;
  var show = false;
  final list = args.toList();
  for (var i = 0; i < list.length; i++) {
    final a = list[i].trim();
    if (a.isEmpty) continue;
    final cli = _cliIntent(a, i + 1 < list.length ? list[i + 1].trim() : null);
    if (cli != null) {
      if (cli.consumed) i++;
      link ??= cli.uri;
    } else if (a == '--minimized') {
      minimized = true;
    } else if (a == '--show') {
      show = true;
    } else {
      link ??= parseLink(a);
    }
  }
  return LaunchArgs(link: link, minimized: minimized, show: show);
}

({Uri uri, bool consumed})? _cliIntent(String a, String? next) {
  for (final flag in const ['provision', 'dial']) {
    String? value;
    var consumed = false;
    if (a == '--$flag') {
      if (next == null || next.isEmpty) return null;
      value = next;
      consumed = true;
    } else if (a.startsWith('--$flag=')) {
      value = a.substring(flag.length + 3);
    }
    if (value == null || value.isEmpty) continue;
    final uri = Uri(scheme: kCliScheme, host: flag, queryParameters: {'v': value});
    _localLaunchUris[uri] = true;
    return (uri: uri, consumed: consumed);
  }
  return null;
}

/// Parses a forwarded command line (arguments joined with `\n`).
LaunchArgs parseForwardedArgs(String payload) =>
    parseLaunchArgs(payload.split('\n'));

/// Returns [s] as a [Uri] when it is one of the supported link schemes.
/// Tolerates spaces and other characters a dialler link may carry
/// (`tel:+1 555 0100`).
Uri? parseLink(String s) {
  final t = s.trim();
  final i = t.indexOf(':');
  if (i <= 0) return null;
  final scheme = t.substring(0, i).toLowerCase();
  if (!kLinkSchemes.contains(scheme)) return null;
  if (t.length == i + 1) return null;
  return Uri.tryParse(t) ?? Uri(scheme: scheme, path: t.substring(i + 1));
}

/// The dial string a link stands for: `sip:alice@host` -> `alice@host`,
/// `tel:+1555` -> `+1555`, `softphonepro://call?number=100` -> `100`.
String dialTargetFromLink(Uri uri) {
  if (uri.scheme == 'softphonepro') {
    final n = uri.queryParameters['number'] ?? uri.queryParameters['to'];
    if (n != null && n.isNotEmpty) return n;
    return (uri.host + uri.path).replaceAll(RegExp(r'^/+'), '');
  }
  var n = uri.toString().replaceFirst(
    RegExp(r'^(sips?|tel|callto):(//)?', caseSensitive: false),
    '',
  );
  n = n.split('?').first.split(';').first;
  try {
    n = Uri.decodeComponent(n);
  } catch (_) {}
  return n.trim();
}
