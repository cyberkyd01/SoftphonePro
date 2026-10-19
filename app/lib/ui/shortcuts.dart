import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../services/app_services.dart';
import '../services/calls_controller.dart';
import 'pages/misc_pages.dart';
import 'widgets/call_widgets.dart';

class SearchIntent extends Intent {
  const SearchIntent();
}

class FocusDialerIntent extends Intent {
  const FocusDialerIntent();
}

class MuteIntent extends Intent {
  const MuteIntent();
}

class HoldIntent extends Intent {
  const HoldIntent();
}

class TransferIntent extends Intent {
  const TransferIntent();
}

class EndCallIntent extends Intent {
  const EndCallIntent();
}

class AnswerIntent extends Intent {
  const AnswerIntent();
}

class SettingsIntent extends Intent {
  const SettingsIntent();
}

Map<ShortcutActivator, Intent> _bindings() {
  Map<ShortcutActivator, Intent> both(LogicalKeyboardKey k, Intent i, {bool shift = false}) => {
    SingleActivator(k, meta: true, shift: shift): i,
    SingleActivator(k, control: true, shift: shift): i,
  };
  return {
    ...both(LogicalKeyboardKey.keyK, const SearchIntent()),
    ...both(LogicalKeyboardKey.keyD, const FocusDialerIntent()),
    ...both(LogicalKeyboardKey.keyM, const MuteIntent()),
    ...both(LogicalKeyboardKey.keyH, const HoldIntent(), shift: true),
    ...both(LogicalKeyboardKey.keyT, const TransferIntent(), shift: true),
    ...both(LogicalKeyboardKey.keyE, const EndCallIntent()),
    ...both(LogicalKeyboardKey.keyA, const AnswerIntent(), shift: true),
    ...both(LogicalKeyboardKey.comma, const SettingsIntent()),
  };
}

/// Desktop keyboard shortcuts from docs/UI_DESIGN.md.
class AppShortcuts extends ConsumerWidget {
  const AppShortcuts({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final calls = ref.read(callsProvider.notifier);
    UiCallOrNull focused() => ref.read(callsProvider).focused;
    return Shortcuts(
      shortcuts: _bindings(),
      child: Actions(
        actions: {
          SearchIntent: CallbackAction<SearchIntent>(onInvoke: (_) {
            showGlobalSearch(context);
            return null;
          }),
          FocusDialerIntent: CallbackAction<FocusDialerIntent>(onInvoke: (_) {
            GoRouter.of(context).go('/keypad');
            ref.read(dialFocusProvider.notifier).request();
            return null;
          }),
          MuteIntent: CallbackAction<MuteIntent>(onInvoke: (_) {
            final c = focused();
            if (c != null) calls.toggleMute(c.cid);
            return null;
          }),
          HoldIntent: CallbackAction<HoldIntent>(onInvoke: (_) {
            final c = focused();
            if (c != null) calls.toggleHold(c.cid);
            return null;
          }),
          TransferIntent: CallbackAction<TransferIntent>(onInvoke: (_) {
            final c = focused();
            if (c != null) showTransferSheet(context, c.cid);
            return null;
          }),
          EndCallIntent: CallbackAction<EndCallIntent>(onInvoke: (_) {
            final c = focused() ?? ref.read(callsProvider).ringing.firstOrNull;
            if (c != null) calls.hangup(c.cid);
            return null;
          }),
          AnswerIntent: CallbackAction<AnswerIntent>(onInvoke: (_) {
            final r = ref.read(callsProvider).ringing;
            if (r.isNotEmpty) calls.answer(r.first.cid);
            return null;
          }),
          SettingsIntent: CallbackAction<SettingsIntent>(onInvoke: (_) {
            GoRouter.of(context).go('/settings');
            return null;
          }),
        },
        child: Focus(autofocus: false, child: child),
      ),
    );
  }
}

typedef UiCallOrNull = UiCall?;
