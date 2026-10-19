import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../services/settings_controller.dart';
import 'pages/add_account.dart';
import 'pages/call_pages.dart';
import 'pages/contacts_page.dart';
import 'pages/keypad_page.dart';
import 'pages/messages_page.dart';
import 'pages/misc_pages.dart';
import 'pages/presence_page.dart';
import 'pages/recents_page.dart';
import 'settings/account_editor.dart';
import 'settings/settings_page.dart';
import 'shell/app_shell.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
/// Tracks which full-screen call routes are open.
class CallRouteObserver extends NavigatorObserver {
  final ValueNotifier<Set<String>> open = ValueNotifier({});
  void _set(Route<dynamic>? r, bool add) {
    final n = r?.settings.name;
    if (n != 'call' && n != 'incoming') return;
    final next = {...open.value};
    add ? next.add(n!) : next.remove(n);
    WidgetsBinding.instance.addPostFrameCallback((_) => open.value = next);
    open.value = next;
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) => _set(route, true);
  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) => _set(route, false);
  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) => _set(route, false);
  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    _set(oldRoute, false);
    _set(newRoute, true);
  }
}

final _shellKey = GlobalKey<NavigatorState>(debugLabel: 'shell');

Page<void> _tab(Widget w, GoRouterState s) => CustomTransitionPage<void>(
  key: ValueKey(s.uri.path.split('/').take(2).join('/')),
  child: w,
  transitionDuration: const Duration(milliseconds: 150),
  transitionsBuilder: (context, anim, _, child) => FadeTransition(opacity: CurvedAnimation(parent: anim, curve: Curves.easeOutCubic), child: child),
);

GoRouter buildRouter({required bool onboarded, CallRouteObserver? observer}) {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    observers: [if (observer != null) observer],
    initialLocation: onboarded ? '/keypad' : '/onboarding',
    routes: [
      GoRoute(path: '/onboarding', parentNavigatorKey: rootNavigatorKey, builder: (_, __) => const OnboardingPage()),
      GoRoute(path: '/account-wizard', parentNavigatorKey: rootNavigatorKey, builder: (_, __) => const AccountWizardPage()),
      GoRoute(name: 'call', path: '/call', parentNavigatorKey: rootNavigatorKey, builder: (_, __) => const InCallPage()),
      GoRoute(name: 'incoming', path: '/incoming', parentNavigatorKey: rootNavigatorKey, builder: (_, __) => const IncomingCallPage()),
      GoRoute(path: '/recents/detail', parentNavigatorKey: rootNavigatorKey, builder: (_, s) => RecentDetailPage(number: s.uri.queryParameters['n'] ?? '')),
      GoRoute(path: '/contacts/new', parentNavigatorKey: rootNavigatorKey, builder: (_, s) => ContactEditorPage(prefillNumber: s.uri.queryParameters['number'])),
      GoRoute(path: '/contacts/:id', parentNavigatorKey: rootNavigatorKey, builder: (_, s) => ContactDetailPage(contactId: s.pathParameters['id']!)),
      GoRoute(path: '/contacts/:id/edit', parentNavigatorKey: rootNavigatorKey, builder: (_, s) => ContactEditorPage(contactId: s.pathParameters['id'])),
      GoRoute(
        path: '/thread',
        parentNavigatorKey: rootNavigatorKey,
        builder: (_, s) => ThreadPage(accountId: s.uri.queryParameters['acc'] ?? '', peer: s.uri.queryParameters['peer'] ?? ''),
      ),
      GoRoute(path: '/settings/accounts/:id', parentNavigatorKey: rootNavigatorKey, builder: (_, s) => AccountEditorPage(accountId: s.pathParameters['id']!)),
      ShellRoute(
        navigatorKey: _shellKey,
        builder: (context, state, child) => AppShell(location: state.uri.path, child: child),
        routes: [
          GoRoute(path: '/keypad', pageBuilder: (c, s) => _tab(const KeypadPage(), s)),
          GoRoute(path: '/recents', pageBuilder: (c, s) => _tab(const RecentsPage(), s)),
          GoRoute(path: '/contacts', pageBuilder: (c, s) => _tab(const ContactsPage(), s)),
          GoRoute(path: '/messages', pageBuilder: (c, s) => _tab(const MessagesPage(), s)),
          GoRoute(path: '/presence', pageBuilder: (c, s) => _tab(const PresencePage(), s)),
          GoRoute(path: '/lan', pageBuilder: (c, s) => _tab(const LanPage(), s)),
          GoRoute(path: '/more', pageBuilder: (c, s) => _tab(const MorePage(), s)),
          GoRoute(path: '/settings', pageBuilder: (c, s) => _tab(const SettingsPage(), s)),
          GoRoute(path: '/settings/:section', pageBuilder: (c, s) => _tab(SettingsPage(section: s.pathParameters['section']), s)),
        ],
      ),
    ],
  );
}

final routerProvider = Provider<GoRouter>((ref) {
  final onboarded = ref.read(settingsProvider).onboardingDone;
  final r = buildRouter(onboarded: onboarded, observer: ref.read(callRouteObserverProvider));
  ref.onDispose(r.dispose);
  return r;
});

final callRouteObserverProvider = Provider<CallRouteObserver>((ref) => CallRouteObserver());

