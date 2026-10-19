import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/format.dart';
import '../../models/provider_templates.dart';
import '../../services/accounts_controller.dart';
import '../../services/providers.dart';
import '../../services/settings_controller.dart';
import '../../storage/repositories.dart';
import '../widgets/basic_widgets.dart';
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
  bool _showPass = false;
  String? _err;

  @override
  void dispose() {
    for (final c in [_user, _pass, _domain, _name, _label, _auth]) {
      c.dispose();
    }
    super.dispose();
  }

  void _pick(ProviderTemplate t) {
    setState(() {
      _tpl = t;
      _domain.text = t.domainHint;
      _label.text = t.id == 'generic' ? '' : t.name;
    });
  }

  Future<void> _save() async {
    if (_user.text.trim().isEmpty || _domain.text.trim().isEmpty) {
      setState(() => _err = 'Username and server are required');
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
          Text('Choose your provider', style: t.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text('We prefill transport, ports and NAT settings for you.', style: t.textTheme.bodyMedium?.copyWith(color: t.colorScheme.onSurfaceVariant)),
          const SizedBox(height: 12),
          for (final tpl in kProviderTemplates)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Card(
                child: ListTile(
                  key: Key('tpl-${tpl.id}'),
                  leading: Avatar(name: tpl.name, size: 40),
                  title: Text(tpl.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(tpl.description),
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
                  onPressed: () async {
                    final n = await importProvisioningDialog(context, ref);
                    if (n > 0) widget.onDone();
                  },
                  icon: const Icon(Icons.link_rounded),
                  label: const Text('Import from URL or QR'),
                ),
              ),
            ],
          ),
          if (widget.onSkip != null) ...[
            const SizedBox(height: 8),
            TextButton(key: const Key('onb-skip'), onPressed: widget.onSkip, child: const Text('Skip for now (demo mode)')),
          ],
        ],
      );
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            IconButton(tooltip: 'Back', onPressed: () => setState(() => _tpl = null), icon: const Icon(Icons.arrow_back_rounded)),
            Expanded(child: Text(_tpl!.name, style: t.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700))),
          ],
        ),
        const SizedBox(height: 8),
        TextField(key: const Key('acc-username'), controller: _user, autocorrect: false, decoration: InputDecoration(labelText: _tpl!.usernameHint, prefixIcon: const Icon(Icons.person_rounded))),
        const SizedBox(height: 12),
        TextField(
          key: const Key('acc-password'),
          controller: _pass,
          obscureText: !_showPass,
          autocorrect: false,
          decoration: InputDecoration(
            labelText: 'Password',
            prefixIcon: const Icon(Icons.key_rounded),
            suffixIcon: IconButton(tooltip: _showPass ? 'Hide password' : 'Show password', onPressed: () => setState(() => _showPass = !_showPass), icon: Icon(_showPass ? Icons.visibility_off_rounded : Icons.visibility_rounded)),
          ),
        ),
        const SizedBox(height: 12),
        TextField(key: const Key('acc-domain'), controller: _domain, autocorrect: false, keyboardType: TextInputType.url, decoration: const InputDecoration(labelText: 'Server / domain', prefixIcon: Icon(Icons.dns_rounded))),
        const SizedBox(height: 12),
        TextField(key: const Key('acc-name'), controller: _name, decoration: const InputDecoration(labelText: 'Display name (optional)', prefixIcon: Icon(Icons.badge_rounded))),
        const SizedBox(height: 12),
        TextField(controller: _label, decoration: const InputDecoration(labelText: 'Account label (optional)', prefixIcon: Icon(Icons.label_rounded))),
        const SizedBox(height: 12),
        TextField(controller: _auth, autocorrect: false, decoration: const InputDecoration(labelText: 'Authorization user (if different)', prefixIcon: Icon(Icons.verified_user_rounded))),
        if (_err != null) Padding(padding: const EdgeInsets.only(top: 12), child: Text(_err!, style: TextStyle(color: t.colorScheme.error))),
        const SizedBox(height: 20),
        FilledButton(key: const Key('acc-save'), onPressed: _save, child: const Text('Add account')),
        const SizedBox(height: 8),
        Text('You can fine-tune transport, NAT, security and codecs later in Settings.', style: t.textTheme.bodySmall?.copyWith(color: t.colorScheme.onSurfaceVariant), textAlign: TextAlign.center),
      ],
    );
  }
}

class AccountWizardPage extends StatelessWidget {
  const AccountWizardPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add account')),
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
      final p = templateById('generic').build(id: newId(), username: '1001', password: 'demo', domain: 'demo.softphonepro.local', displayName: 'Demo user', label: 'Demo account');
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
          title: 'Welcome to SoftphonePro',
          text: 'A free, open-source SIP softphone with the features of premium apps. No ads, no tracking.',
          button: 'Get started',
          buttonKey: 'onb-get-started',
          onNext: () => setState(() => _step = 1),
        );
      case 1:
        page = _Intro(
          icon: Icons.mic_rounded,
          title: 'Permissions',
          text: 'SoftphonePro needs the microphone to carry your voice, and notifications to tell you about incoming calls and messages. Nothing leaves your device except your calls.',
          button: 'Continue',
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

