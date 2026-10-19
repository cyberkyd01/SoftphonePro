import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/theme.dart';
import 'l10n/l10n.dart';
import 'security/app_lock_gate.dart';
import 'services/app_services.dart';
import 'services/calls_controller.dart';
import 'services/engine_controller.dart';
import 'services/providers.dart';
import 'services/settings_controller.dart';
import 'services/update_checker.dart';
import 'ui/router.dart';
import 'ui/widgets/account_widgets.dart';
import 'ui/widgets/engine_failure_gate.dart';

final rootMessengerKey = GlobalKey<ScaffoldMessengerState>();

class SoftphoneApp extends ConsumerStatefulWidget {
  const SoftphoneApp({super.key});
  @override
  ConsumerState<SoftphoneApp> createState() => _SoftphoneAppState();
}

class _SoftphoneAppState extends ConsumerState<SoftphoneApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Desktop only (no-op elsewhere); never delays startup.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.read(updateProvider.notifier).startAuto();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeLocales(List<Locale>? locales) {
    ref.read(systemLocalesProvider.notifier).refresh();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached) {
      ref.read(engineProvider.notifier).onAppDetached();
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(appServicesProvider);
    final router = ref.watch(routerProvider);
    final settings = ref.watch(settingsProvider);
    final accent = Color(settings.accent);
    ref.listen(noticeProvider, (_, n) {
      if (n == null) return;
      final m = rootMessengerKey.currentState;
      if (m == null) return;
      m.hideCurrentSnackBar();
      m.showSnackBar(
        SnackBar(
          content: Text(n.message),
          duration: Duration(seconds: n.isError ? 6 : 3),
          action: n.details == null
              ? null
              : SnackBarAction(
                  label: ref.read(l10nProvider).actionDetails,
                  onPressed: () {
                    final ctx = rootNavigatorKey.currentContext;
                    if (ctx != null) showErrorDetails(ctx, n.isError ? ref.read(l10nProvider).commonError : ref.read(l10nProvider).actionDetails, n.message, n.details);
                  },
                ),
        ),
      );
    });
    ref.listen(redirectPromptProvider, (_, p) {
      if (p == null) return;
      final ctx = rootNavigatorKey.currentContext;
      if (ctx == null) return;
      showDialog<bool>(
        context: ctx,
        barrierDismissible: false,
        builder: (dctx) => AlertDialog(
          key: const Key('redirect-prompt'),
          title: Text(dctx.l10n.appRedirectTitle),
          content: Text(dctx.l10n.appRedirectMessage(p.target)),
          actions: [
            TextButton(key: const Key('redirect-reject'), onPressed: () => Navigator.pop(dctx, false), child: Text(dctx.l10n.appRedirectCancelCall)),
            FilledButton(key: const Key('redirect-follow'), onPressed: () => Navigator.pop(dctx, true), child: Text(dctx.l10n.acctOptRedirectFollow)),
          ],
        ),
      ).then((v) => ref.read(callsProvider.notifier).resolveRedirect(v ?? false));
    });
    return MaterialApp.router(
      onGenerateTitle: (ctx) => ctx.l10n.appName,
      debugShowCheckedModeBanner: false,
      locale: ref.watch(appLocaleProvider),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      scaffoldMessengerKey: rootMessengerKey,
      routerConfig: router,
      themeMode: settings.themeMode,
      theme: buildTheme(Brightness.light, accent: accent, compact: settings.compactDensity),
      darkTheme: buildTheme(Brightness.dark, accent: accent, compact: settings.compactDensity),
      builder: (context, child) {
        final b = Theme.of(context).brightness;
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: overlayFor(b),
          child: AppLockGate(child: EngineFailureGate(child: CallRouteCoordinator(child: child ?? const SizedBox.shrink()))),
        );
      },
    );
  }
}

/// Opens the full-screen incoming / in-call routes on compact layouts and
/// closes them when calls end.
class CallRouteCoordinator extends ConsumerStatefulWidget {
  const CallRouteCoordinator({super.key, required this.child});
  final Widget child;
  @override
  ConsumerState<CallRouteCoordinator> createState() => _CallRouteCoordinatorState();
}

class _CallRouteCoordinatorState extends ConsumerState<CallRouteCoordinator> {
  Set<int> _seenOngoing = {};
  Set<int> _seenRinging = {};

  Set<String> get _open => ref.read(callRouteObserverProvider).open.value;

  void _handle(CallsState s) {
    final router = ref.read(routerProvider);
    final compact = MediaQuery.sizeOf(context).width < 840;
    final ongoing = s.ongoing.where((c) => !c.isEnded).toList();
    final ringing = s.ringing;
    final newOngoing = ongoing.where((c) => !_seenOngoing.contains(c.cid)).toList();
    final newRinging = ringing.where((c) => !_seenRinging.contains(c.cid)).toList();
    _seenOngoing = ongoing.map((c) => c.cid).toSet();
    _seenRinging = ringing.map((c) => c.cid).toSet();
    if (!compact) return;
    if (ringing.isNotEmpty && ongoing.isEmpty) {
      if (!_open.contains('incoming')) router.push('/incoming');
      return;
    }
    if (newOngoing.isNotEmpty || (newRinging.isNotEmpty && ongoing.isNotEmpty)) {
      if (_open.contains('incoming')) {
        rootNavigatorKey.currentState?.popUntil((r) => r.settings.name != 'incoming');
        router.push('/call');
      } else if (!_open.contains('call')) {
        router.push('/call');
      }
      return;
    }
    if (!s.hasCalls && (_open.contains('call') || _open.contains('incoming'))) {
      rootNavigatorKey.currentState?.popUntil((r) => r.settings.name != 'call' && r.settings.name != 'incoming');
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<CallsState>(callsProvider, (_, next) => _handle(next));
    return widget.child;
  }
}
