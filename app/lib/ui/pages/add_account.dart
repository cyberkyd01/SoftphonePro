import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:spcore_dart/spcore_dart.dart';

import '../../core/format.dart';
import '../../l10n/l10n.dart';
import '../../models/provider_templates.dart';
import '../../services/accounts_controller.dart';
import '../../services/providers.dart';
import '../../services/settings_controller.dart';
import '../../storage/repositories.dart';
import '../widgets/basic_widgets.dart';
import '../settings/account_editor.dart' show validateHost, validateInt;
import '../settings/provisioning_section.dart';

/// Template picker -> credentials form. Used by onboarding and the wizard.
class AddAccountFlow extends ConsumerStatefulWidget {
  const AddAccountFlow({super.key, required this.onDone, this.onSkip});
  final VoidCallback onDone;
  final VoidCallback? onSkip;
  @override
  ConsumerState<AddAccountFlow> createState() => _AddAccountFlowState();
}

class _AddAccountFlowState extends ConsumerState<AddAccountFlow> {
  ProviderTemplate? _tpl;
  final _user = TextEditingController();
  final _pass = TextEditingController();
  final _domain = TextEditingController();
  final _name = TextEditingController();
  final _label = TextEditingController();
  final _auth = TextEditingController();
  final _port = TextEditingController(text: '4569');
  final _context = TextEditingController();
  final _callerId = TextEditingController();
  bool _showPass = false;
  String? _err;

  @override
  void dispose() {
    for (final c in [_user, _pass, _domain, _name, _label, _auth, _port, _context, _callerId]) {
      c.dispose();
    }
    super.dispose();
  }

  void _pick(ProviderTemplate t) {
    setState(() {
      _tpl = t;
      _domain.text = t.domainHint;
      _label.text = t.id == 'generic' ? '' : t.name;
      _err = null;
      _portErr = null;
      if (t.isIax) _port.text = '${t.defaultPort ?? 4569}';
    });
  }

  String? _portErr;
  String? _domainErr;

  /// Protocol picker: SIP shows the provider list, IAX2 goes straight to the
  /// IAX2 form.
  Widget _protoPicker() => SegmentedButton<SipProto>(
    key: const Key('acc-proto'),
    segments: const [
      ButtonSegment(value: SipProto.sip, label: Text('SIP'), icon: Icon(Icons.phone_in_talk_rounded)),
      ButtonSegment(value: SipProto.iax2, label: Text('IAX2'), icon: Icon(Icons.swap_calls_rounded)),
    ],
    selected: {_tpl?.proto ?? SipProto.sip},
    onSelectionChanged: (v) {
      if (v.first == SipProto.iax2) {
        _pick(templateById('iax2'));
      } else {
        setState(() => _tpl = null);
      }
    },
  );

  Future<void> _save() async {
    if (_user.text.trim().isEmpty || _domain.text.trim().isEmpty) {
      setState(() => _err = context.l10n.onboardingRequired);
      return;
    }
    final domErr = validateHost(_domain.text, context.l10n);
    final portErr = _tpl!.isIax ? validateInt(_port.text, min: 1, max: 65535, l: context.l10n) : null;
    if (domErr != null || portErr != null) {
      setState(() {
        _err = null;
        _domainErr = domErr;
        _portErr = portErr;
      });
      return;
    }
    final accounts = ref.read(accountsProvider);
    final p = _tpl!.build(
      id: newId(),
      username: _user.text.trim(),
      password: _pass.text,
      domain: _domain.text.trim(),
      displayName: _name.text.trim(),
      label: _label.text.trim(),
      authUser: _auth.text.trim(),
      color: kAvatarPalette[accounts.profiles.length % kAvatarPalette.length],
      port: _tpl!.isIax ? int.parse(_port.text.trim()) : null,
      iaxContext: _context.text,
      callerId: _callerId.text,
    );
    await ref.read(accountsProvider.notifier).add(p);
    widget.onDone();
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    if (_tpl == null) {
      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(context.l10n.onboardingChooseProvider, style: t.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(context.l10n.onboardingChooseProviderSub, style: t.textTheme.bodyMedium?.copyWith(color: t.colorScheme.onSurfaceVariant)),
          const SizedBox(height: 12),
          _protoPicker(),
          const SizedBox(height: 12),
          for (final tpl in kProviderTemplates)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Card(
                child: ListTile(
                  key: Key('tpl-${tpl.id}'),
                  leading: Avatar(name: tpl.name, size: 40),
                  title: Text(tpl.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(tpl.descriptionOf(context.l10n)),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => _pick(tpl),
                ),
              ),
            ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  key: const Key('scan-provisioning-qr'),
                  onPressed: () async {
                    final n = await scanProvisioningQr(context, ref);
                    if (n > 0) widget.onDone();
                  },
                  icon: const Icon(Icons.qr_code_scanner_rounded),
                  label: Text(context.l10n.onboardingScanQr),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final n = await importProvisioningDialog(context, ref);
                    if (n > 0) widget.onDone();
                  },
                  icon: const Icon(Icons.link_rounded),
                  label: Text(context.l10n.onboardingImportUrl),
                ),
              ),
            ],
          ),
          if (widget.onSkip != null) ...[
            const SizedBox(height: 8),
            TextButton(key: const Key('onb-skip'), onPressed: widget.onSkip, child: Text(context.l10n.onboardingSkip)),
          ],
        ],
      );
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            IconButton(tooltip: context.l10n.actionBack, onPressed: () => setState(() => _tpl = null), icon: const Icon(Icons.arrow_back_rounded)),
            Expanded(child: Text(_tpl!.name, style: t.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700))),
          ],
        ),
        const SizedBox(height: 4),
        _protoPicker(),
        if (_tpl!.notesOf(context.l10n).isNotEmpty) ...[
          const SizedBox(height: 12),
          Container(
            key: const Key('acc-notes'),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: t.colorScheme.secondaryContainer.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(12)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline_rounded, size: 20, color: t.colorScheme.onSecondaryContainer),
                const SizedBox(width: 10),
                Expanded(child: Text(_tpl!.notesOf(context.l10n), style: t.textTheme.bodySmall?.copyWith(color: t.colorScheme.onSecondaryContainer))),
              ],
            ),
          ),
        ],
        const SizedBox(height: 12),
        TextField(key: const Key('acc-username'), controller: _user, autocorrect: false, textDirection: TextDirection.ltr, decoration: InputDecoration(labelText: _tpl!.usernameHintOf(context.l10n), prefixIcon: const Icon(Icons.person_rounded))),
        const SizedBox(height: 12),
        TextField(
          key: const Key('acc-password'),
          controller: _pass,
          obscureText: !_showPass,
          autocorrect: false,
          decoration: InputDecoration(
            labelText: context.l10n.acctFieldPassword,
            prefixIcon: const Icon(Icons.key_rounded),
            suffixIcon: IconButton(tooltip: _showPass ? context.l10n.onboardingHidePassword : context.l10n.onboardingShowPassword, onPressed: () => setState(() => _showPass = !_showPass), icon: Icon(_showPass ? Icons.visibility_off_rounded : Icons.visibility_rounded)),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          key: const Key('acc-domain'),
          controller: _domain,
          autocorrect: false,
          textDirection: TextDirection.ltr,
          keyboardType: TextInputType.url,
          onChanged: (_) {
            if (_domainErr != null) setState(() => _domainErr = null);
          },
          decoration: InputDecoration(
            labelText: _tpl!.serverLabelOf(context.l10n),
            prefixIcon: const Icon(Icons.dns_rounded),
            errorText: _domainErr,
            helperText: _tpl!.defaultPort != null && !_tpl!.isIax ? context.l10n.onboardingDefaultPortHelper(_tpl!.defaultPort!) : null,
          ),
        ),
        const SizedBox(height: 12),
        if (_tpl!.isIax) ...[
          TextField(
            key: const Key('acc-port'),
            controller: _port,
            textDirection: TextDirection.ltr,
            keyboardType: TextInputType.number,
            onChanged: (_) {
              if (_portErr != null) setState(() => _portErr = null);
            },
            decoration: InputDecoration(labelText: context.l10n.acctFieldPort, prefixIcon: const Icon(Icons.numbers_rounded), errorText: _portErr, helperText: context.l10n.acctFieldIaxPortSub),
          ),
          const SizedBox(height: 12),
          TextField(key: const Key('acc-context'), controller: _context, autocorrect: false, decoration: InputDecoration(labelText: context.l10n.onboardingContextOptional, prefixIcon: Icon(Icons.account_tree_rounded))),
          const SizedBox(height: 12),
        ],
        TextField(key: const Key('acc-name'), controller: _name, decoration: InputDecoration(labelText: context.l10n.onboardingDisplayNameOptional, prefixIcon: Icon(Icons.badge_rounded))),
        const SizedBox(height: 12),
        TextField(controller: _label, decoration: InputDecoration(labelText: context.l10n.onboardingLabelOptional, prefixIcon: Icon(Icons.label_rounded))),
        const SizedBox(height: 12),
        if (_tpl!.isIax)
          TextField(key: const Key('acc-callerid'), controller: _callerId, decoration: InputDecoration(labelText: context.l10n.onboardingCallerIdOptional, prefixIcon: Icon(Icons.contact_phone_rounded)))
        else
          TextField(controller: _auth, autocorrect: false, decoration: InputDecoration(labelText: context.l10n.onboardingAuthUserOptional, prefixIcon: Icon(Icons.verified_user_rounded))),
        if (_err != null) Padding(padding: const EdgeInsets.only(top: 12), child: Text(_err!, style: TextStyle(color: t.colorScheme.error))),
        const SizedBox(height: 20),
        FilledButton(key: const Key('acc-save'), onPressed: _save, child: Text(context.l10n.acctAddAccount)),
        const SizedBox(height: 8),
        Text(_tpl!.isIax ? context.l10n.onboardingFineTuneIax : context.l10n.onboardingFineTuneSip, style: t.textTheme.bodySmall?.copyWith(color: t.colorScheme.onSurfaceVariant), textAlign: TextAlign.center),
      ],
    );
  }
}

class AccountWizardPage extends StatelessWidget {
  const AccountWizardPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.acctAddAccount)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: AddAccountFlow(onDone: () => context.canPop() ? context.pop() : context.go('/keypad')),
        ),
      ),
    );
  }
}

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});
  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  int _step = 0;

  Future<void> _finish({bool demo = false}) async {
    if (demo && ref.read(accountsProvider).profiles.isEmpty) {
      final p = templateById('generic').build(id: newId(), username: '1001', password: 'demo', domain: 'demo.softphonepro.local', displayName: ref.read(l10nProvider).onboardingDemoUser, label: ref.read(l10nProvider).onboardingDemoAccount);
      await ref.read(accountsProvider.notifier).add(p);
    }
    await ref.read(settingsProvider.notifier).update({'onboardingDone': true});
    if (mounted) context.go('/keypad');
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    Widget page;
    switch (_step) {
      case 0:
        page = _Intro(
          icon: Icons.phone_in_talk_rounded,
          title: context.l10n.onboardingWelcomeTitle,
          text: context.l10n.onboardingWelcomeText,
          button: context.l10n.onboardingGetStarted,
          buttonKey: 'onb-get-started',
          onNext: () => setState(() => _step = 1),
        );
      case 1:
        page = _Intro(
          icon: Icons.mic_rounded,
          title: context.l10n.onboardingPermissionsTitle,
          text: context.l10n.onboardingPermissionsText,
          button: context.l10n.actionContinue,
          buttonKey: 'onb-continue',
          onNext: () async {
            await ref.read(platformServicesProvider).requestPermissions();
            if (mounted) setState(() => _step = 2);
          },
        );
      default:
        page = AddAccountFlow(onDone: () => _finish(), onSkip: () => _finish(demo: true));
    }
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                  child: Row(
                    children: [
                      for (var i = 0; i < 3; i++)
                        Expanded(
                          child: Container(
                            height: 4,
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(2), color: i <= _step ? t.colorScheme.primary : t.colorScheme.outlineVariant),
                          ),
                        ),
                    ],
                  ),
                ),
                Expanded(child: AnimatedSwitcher(duration: const Duration(milliseconds: 200), child: KeyedSubtree(key: ValueKey(_step), child: page))),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Intro extends StatelessWidget {
  const _Intro({required this.icon, required this.title, required this.text, required this.button, required this.buttonKey, required this.onNext});
  final IconData icon;
  final String title;
  final String text;
  final String button;
  final String buttonKey;
  final VoidCallback onNext;
  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Image.asset('assets/branding/icon_1024.png', width: 96, height: 96, errorBuilder: (_, __, ___) => Icon(icon, size: 64)),
          ),
          const SizedBox(height: 28),
          Text(title, style: t.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700), textAlign: TextAlign.center),
          const SizedBox(height: 12),
          Text(text, style: t.textTheme.bodyLarge?.copyWith(color: t.colorScheme.onSurfaceVariant), textAlign: TextAlign.center),
          const SizedBox(height: 32),
          SizedBox(width: double.infinity, child: FilledButton(key: Key(buttonKey), onPressed: onNext, child: Text(button))),
        ],
      ),
    );
  }
}

