import 'dart:async';
import 'dart:convert';
import 'dart:ffi' show Abi;
import 'dart:io';
import 'dart:ui' show Locale;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../l10n/l10n.dart';
import '../platform/desktop_platform_services.dart';
import 'engine_controller.dart';
import 'providers.dart';
import 'settings_controller.dart';

const kReleasesApi = 'https://api.github.com/repos/cyberkyd01/SoftphonePro/releases/latest';
const kUpdateInterval = Duration(days: 7);

/// A semantic version (`1.2.3`, `v1.2.3-rc.1+build`).
class SemVer implements Comparable<SemVer> {
  const SemVer(this.major, this.minor, this.patch, [this.pre = const []]);
  final int major, minor, patch;

  /// Pre-release identifiers (`rc.1` -> `[rc, 1]`); empty for a release.
  final List<String> pre;

  static SemVer? parse(String input) {
    var s = input.trim();
    if (s.startsWith('v') || s.startsWith('V')) s = s.substring(1);
    final plus = s.indexOf('+');
    if (plus >= 0) s = s.substring(0, plus);
    String? preStr;
    final dash = s.indexOf('-');
    if (dash >= 0) {
      preStr = s.substring(dash + 1);
      s = s.substring(0, dash);
    }
    final parts = s.split('.');
    if (parts.isEmpty || parts.length > 3) return null;
    final n = [for (final p in parts) int.tryParse(p)];
    if (n.any((e) => e == null || e < 0)) return null;
    while (n.length < 3) {
      n.add(0);
    }
    final pre = preStr == null || preStr.isEmpty ? <String>[] : preStr.split('.');
    return SemVer(n[0]!, n[1]!, n[2]!, pre);
  }

  bool get isPrerelease => pre.isNotEmpty;

  @override
  int compareTo(SemVer o) {
    for (final d in [major - o.major, minor - o.minor, patch - o.patch]) {
      if (d != 0) return d < 0 ? -1 : 1;
    }
    if (pre.isEmpty && o.pre.isEmpty) return 0;
    if (pre.isEmpty) return 1; // 1.0.0 > 1.0.0-rc.1
    if (o.pre.isEmpty) return -1;
    for (var i = 0; i < pre.length && i < o.pre.length; i++) {
      final a = pre[i], b = o.pre[i];
      final an = int.tryParse(a), bn = int.tryParse(b);
      int c;
      if (an != null && bn != null) {
        c = an.compareTo(bn);
      } else if (an != null) {
        c = -1; // numeric < alphanumeric
      } else if (bn != null) {
        c = 1;
      } else {
        c = a.compareTo(b);
      }
      if (c != 0) return c < 0 ? -1 : 1;
    }
    return pre.length.compareTo(o.pre.length).sign;
  }

  bool operator >(SemVer o) => compareTo(o) > 0;
  bool operator <(SemVer o) => compareTo(o) < 0;

  @override
  bool operator ==(Object other) => other is SemVer && compareTo(other) == 0;
  @override
  int get hashCode => Object.hash(major, minor, patch, pre.join('.'));
  @override
  String toString() => '$major.$minor.$patch${pre.isEmpty ? '' : '-${pre.join('.')}'}';
}

class ReleaseInfo {
  const ReleaseInfo({required this.version, required this.url, this.notes = '', this.assetUrl});
  final SemVer version;

  /// The release page.
  final String url;
  final String notes;

  /// Direct download of the matching package (Linux .deb / .tar.gz), if the
  /// release has one for this machine.
  final String? assetUrl;

  /// What the "Download" button opens.
  String get downloadUrl => assetUrl ?? url;
}

/// What the update checker needs to know about the machine to choose a
/// download. Only Linux has per-machine assets today.
class UpdatePlatform {
  const UpdatePlatform({this.isLinux = false, this.arch, this.installedFromDeb = false});

  /// `amd64` or `arm64` (the Debian names); null when unknown.
  final String? arch;
  final bool isLinux;

  /// The running executable lives under [kDebInstallDir].
  final bool installedFromDeb;

  static const none = UpdatePlatform();

  factory UpdatePlatform.current() {
    if (kIsWeb || !Platform.isLinux) return none;
    final abi = Abi.current();
    return UpdatePlatform(
      isLinux: true,
      arch: abi == Abi.linuxX64 ? 'amd64' : (abi == Abi.linuxArm64 ? 'arm64' : null),
      installedFromDeb: Platform.resolvedExecutable.startsWith(kDebInstallDir),
    );
  }
}

/// Where the .deb installs the bundle.
const kDebInstallDir = '/opt/softphonepro/';

/// The release asset to download on Linux: `SoftphonePro-<ver>-linux-<arch>.deb`
/// for a .deb install, otherwise the matching `.tar.gz` (a .deb install falls
/// back to the tarball when the release has no .deb, and the reverse). Null
/// when nothing fits; the release page is used then.
String? pickReleaseAsset(Object? assets, SemVer version, UpdatePlatform platform) {
  if (!platform.isLinux || platform.arch == null || assets is! List) return null;
  final byName = <String, String>{};
  for (final a in assets) {
    if (a is! Map) continue;
    final name = a['name'], url = a['browser_download_url'];
    if (name is String && url is String && url.startsWith('https://')) byName[name] = url;
  }
  final base = 'SoftphonePro-$version-linux-${platform.arch}';
  final order = platform.installedFromDeb ? ['deb', 'tar.gz'] : ['tar.gz', 'deb'];
  for (final ext in order) {
    final u = byName['$base.$ext'];
    if (u != null) return u;
  }
  return null;
}

enum UpdateOutcome { available, upToDate, rateLimited, failed }

class UpdateCheckResult {
  const UpdateCheckResult(this.outcome, {this.release, this.error, this.answered = false});
  final UpdateOutcome outcome;
  final ReleaseInfo? release;
  final String? error;

  /// GitHub answered (so the check counts for the weekly schedule).
  final bool answered;
}

/// One request to the GitHub releases API: nothing but the GET is sent.
Future<UpdateCheckResult> checkForUpdate({
  required http.Client client,
  required SemVer current,
  Duration timeout = const Duration(seconds: 10),
  Uri? endpoint,
  AppLocalizations? l10n,
  UpdatePlatform? platform,
}) async {
  final l = l10n ?? lookupAppLocalizations(const Locale('en'));
  try {
    final r = await client
        .get(endpoint ?? Uri.parse(kReleasesApi), headers: const {'Accept': 'application/vnd.github+json'})
        .timeout(timeout);
    if (r.statusCode == 403 || r.statusCode == 429) {
      return UpdateCheckResult(UpdateOutcome.rateLimited, error: l.updatesRateLimited, answered: true);
    }
    if (r.statusCode == 404) {
      // No release published yet.
      return const UpdateCheckResult(UpdateOutcome.upToDate, answered: true);
    }
    if (r.statusCode != 200) {
      return UpdateCheckResult(UpdateOutcome.failed, error: l.updatesServerAnswered(r.statusCode), answered: true);
    }
    final j = jsonDecode(utf8.decode(r.bodyBytes));
    if (j is! Map) return UpdateCheckResult(UpdateOutcome.failed, error: l.updatesUnexpectedReply, answered: true);
    if (j['draft'] == true || j['prerelease'] == true) {
      return const UpdateCheckResult(UpdateOutcome.upToDate, answered: true);
    }
    final v = SemVer.parse('${j['tag_name'] ?? ''}');
    final url = '${j['html_url'] ?? ''}';
    if (v == null || !url.startsWith('https://')) {
      return UpdateCheckResult(UpdateOutcome.failed, error: l.updatesUnexpectedReply, answered: true);
    }
    if (v.compareTo(current) > 0) {
      return UpdateCheckResult(
        UpdateOutcome.available,
        release: ReleaseInfo(
          version: v,
          url: url,
          notes: '${j['body'] ?? ''}',
          assetUrl: pickReleaseAsset(j['assets'], v, platform ?? UpdatePlatform.current()),
        ),
        answered: true,
      );
    }
    return const UpdateCheckResult(UpdateOutcome.upToDate, answered: true);
  } on TimeoutException {
    return UpdateCheckResult(UpdateOutcome.failed, error: l.updatesTimedOut);
  } catch (e) {
    return UpdateCheckResult(UpdateOutcome.failed, error: '$e');
  }
}

// ---- providers ---------------------------------------------------------------

final updateHttpClientProvider = Provider<http.Client>((ref) {
  final c = http.Client();
  ref.onDispose(c.close);
  return c;
});

/// The running app version (package_info_plus, falling back to the constant).
final currentVersionProvider = Provider<Future<SemVer>>((ref) async {
  try {
    final p = await PackageInfo.fromPlatform();
    final v = SemVer.parse(p.version);
    if (v != null) return v;
  } catch (_) {}
  return SemVer.parse(kAppVersion) ?? const SemVer(0, 0, 0);
});

/// Update checking exists on desktop only (mobile uses stores / sideloading).
final updatesSupportedProvider = Provider<bool>(
  (ref) => !kIsWeb && (Platform.isMacOS || Platform.isWindows || Platform.isLinux),
);

final updatePlatformProvider = Provider<UpdatePlatform>((ref) => UpdatePlatform.current());

final urlOpenerProvider = Provider<Future<bool> Function(Uri)>(
  (ref) => (u) => launchUrl(u, mode: LaunchMode.externalApplication),
);

class UpdateState {
  const UpdateState({this.checking = false, this.release, this.dismissed = false, this.lastResult});
  final bool checking;

  /// The newer release, if one was found and not skipped.
  final ReleaseInfo? release;

  /// The banner was closed for this session.
  final bool dismissed;
  final UpdateCheckResult? lastResult;

  bool get showBanner => release != null && !dismissed;

  UpdateState copyWith({bool? checking, ReleaseInfo? release, bool clearRelease = false, bool? dismissed, UpdateCheckResult? lastResult}) =>
      UpdateState(
        checking: checking ?? this.checking,
        release: clearRelease ? null : (release ?? this.release),
        dismissed: dismissed ?? this.dismissed,
        lastResult: lastResult ?? this.lastResult,
      );
}

class UpdateController extends Notifier<UpdateState> {
  Timer? _first, _timer;

  @override
  UpdateState build() {
    ref.onDispose(() {
      _first?.cancel();
      _timer?.cancel();
    });
    return const UpdateState();
  }

  /// Starts the background schedule (desktop only; never blocks startup).
  void startAuto({Duration initialDelay = const Duration(seconds: 20), Duration poll = const Duration(hours: 6)}) {
    if (!ref.read(updatesSupportedProvider)) return;
    if (ref.read(platformServicesProvider) is! DesktopPlatformServices) return;
    _first?.cancel();
    _timer?.cancel();
    _first = Timer(initialDelay, () => unawaited(maybeAutoCheck()));
    _timer = Timer.periodic(poll, (_) => unawaited(maybeAutoCheck()));
  }

  /// Checks when enabled and the last answered check is over a week old.
  Future<void> maybeAutoCheck({DateTime? now}) async {
    final s = ref.read(settingsProvider);
    if (!ref.read(updatesSupportedProvider) || !s.updateCheck) return;
    final last = DateTime.fromMillisecondsSinceEpoch(s.updateLastCheck);
    if ((now ?? DateTime.now()).difference(last) < kUpdateInterval) return;
    await checkNow();
  }

  /// Runs a check immediately ("Check now"). A skipped version stays hidden.
  Future<UpdateCheckResult> checkNow() async {
    if (state.checking) return state.lastResult ?? UpdateCheckResult(UpdateOutcome.failed, error: ref.read(l10nProvider).updatesAlreadyChecking);
    state = state.copyWith(checking: true);
    final res = await checkForUpdate(
      client: ref.read(updateHttpClientProvider),
      current: await ref.read(currentVersionProvider),
      l10n: ref.read(l10nProvider),
      platform: ref.read(updatePlatformProvider),
    );
    final settings = ref.read(settingsProvider.notifier);
    if (res.answered) {
      await settings.update({'updateLastCheck': DateTime.now().millisecondsSinceEpoch});
    }
    final skipped = res.release != null && ref.read(settingsProvider).updateSkipVersion == res.release!.version.toString();
    state = state.copyWith(
      checking: false,
      lastResult: res,
      release: res.outcome == UpdateOutcome.available && !skipped ? res.release : null,
      clearRelease: res.outcome == UpdateOutcome.upToDate || skipped,
      dismissed: false,
    );
    return res;
  }

  void dismiss() => state = state.copyWith(dismissed: true);

  Future<void> skipVersion() async {
    final r = state.release;
    if (r == null) return;
    await ref.read(settingsProvider.notifier).update({'updateSkipVersion': r.version.toString()});
    state = state.copyWith(clearRelease: true);
  }

  Future<void> open(String url) async {
    try {
      await ref.read(urlOpenerProvider)(Uri.parse(url));
    } catch (_) {}
  }
}

final updateProvider = NotifierProvider<UpdateController, UpdateState>(UpdateController.new);
