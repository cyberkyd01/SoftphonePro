import '../l10n/l10n.dart';
import '../lan/lan_models.dart';
import '../platform/desktop/launch_args.dart';

/// What an incoming link or command-line intent asks the app to do.
sealed class LinkAction {
  const LinkAction();
}

/// `softphonepro://provision?url=<https>`: needs user confirmation.
class ProvisionLinkAction extends LinkAction {
  const ProvisionLinkAction(this.url);
  final Uri url;
}

/// `--provision <path|url>`: local intent, imported without a prompt.
class ProvisionCliAction extends LinkAction {
  const ProvisionCliAction(this.source);
  final String source;
}

/// `softphonepro://lan?...`: LAN Link manual connect.
class LanLinkAction extends LinkAction {
  const LanLinkAction(this.target, this.raw);
  final LanTarget target;
  final String raw;
}

/// sip:/sips:/tel:/callto:/softphonepro://call: fill the dialer (or call).
class DialLinkAction extends LinkAction {
  const DialLinkAction(this.target);
  final String target;
}

/// `--dial <target>`: always places the call.
class DialCliAction extends LinkAction {
  const DialCliAction(this.target);
  final String target;
}

/// A link that must not be acted on.
class RejectedLinkAction extends LinkAction {
  const RejectedLinkAction(this.reason);
  final LinkRejection reason;
}

/// Why a link was rejected; see [linkRejectionText].
enum LinkRejection { missingArgument, httpsRequired, invalidLan }

String linkRejectionText(AppLocalizations l, LinkRejection r) => switch (r) {
  LinkRejection.missingArgument => l.callLinkMissingArgument,
  LinkRejection.httpsRequired => l.callLinkHttpsRequired,
  LinkRejection.invalidLan => l.callLinkInvalidLan,
};

/// https only; plain http is accepted for localhost testing.
bool isAllowedProvisionUrl(Uri u) {
  if (u.host.isEmpty) return false;
  if (u.scheme == 'https') return true;
  if (u.scheme == 'http') {
    final h = u.host.toLowerCase();
    return h == 'localhost' || h == '127.0.0.1' || h == '::1';
  }
  return false;
}

LinkAction classifyLink(Uri uri) {
  if (uri.scheme == kCliScheme) {
    final v = uri.queryParameters['v'] ?? '';
    if (v.isEmpty) return const RejectedLinkAction(LinkRejection.missingArgument);
    return uri.host == 'provision' ? ProvisionCliAction(v) : DialCliAction(v);
  }
  if (uri.scheme == 'softphonepro') {
    switch (uri.host.toLowerCase()) {
      case 'provision':
        final raw = uri.queryParameters['url'] ?? '';
        final u = Uri.tryParse(raw);
        if (u == null || !isAllowedProvisionUrl(u)) {
          return const RejectedLinkAction(LinkRejection.httpsRequired);
        }
        return ProvisionLinkAction(u);
      case 'lan':
        final t = LanTarget.parse(uri.toString());
        if (t == null) return const RejectedLinkAction(LinkRejection.invalidLan);
        return LanLinkAction(t, uri.toString());
    }
  }
  return DialLinkAction(dialTargetFromLink(uri));
}
