import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../l10n/l10n.dart';
import '../../storage/app_database.dart';
import '../../storage/secrets_store.dart';

/// Opens the database; when it cannot be opened (encryption key missing from
/// the keystore, wrong key, corrupt file) shows [DbRecoveryApp] until the user
/// retries successfully or chooses to start fresh. Never throws for data
/// problems.
Future<AppDatabase> openDatabaseOrRecover(String dir, SecretsStore secrets) async {
  while (true) {
    try {
      return await AppDatabase.openIn(dir, secrets);
    } on DbRecoveryNeeded catch (e) {
      final choice = Completer<bool>(); // true = start fresh
      runApp(DbRecoveryApp(problem: e, onRetry: () => choice.complete(false), onStartFresh: () => choice.complete(true)));
      if (await choice.future) await AppDatabase.startFresh(dir, secrets);
    }
  }
}

/// Minimal stand-alone screen shown before the app starts.
class DbRecoveryApp extends StatelessWidget {
  const DbRecoveryApp({super.key, required this.problem, required this.onRetry, required this.onStartFresh});
  final DbRecoveryNeeded problem;
  final VoidCallback onRetry;
  final VoidCallback onStartFresh;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SoftphonePro',
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: const Color(0xFF3F51E0), useMaterial3: true),
      home: DbRecoveryScreen(problem: problem, onRetry: onRetry, onStartFresh: onStartFresh),
    );
  }
}

class DbRecoveryScreen extends StatelessWidget {
  const DbRecoveryScreen({super.key, required this.problem, required this.onRetry, required this.onStartFresh});
  final DbRecoveryNeeded problem;
  final VoidCallback onRetry;
  final VoidCallback onStartFresh;

  @override
  Widget build(BuildContext context) {
    final missing = problem.problem == DbProblem.missingKey;
    final t = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: ListView(
              padding: const EdgeInsets.all(24),
              shrinkWrap: true,
              children: [
                Icon(Icons.lock_reset_rounded, size: 48, color: t.colorScheme.primary),
                const SizedBox(height: 16),
                Text(
                  missing ? context.l10n.appDbLockedTitle : context.l10n.appDbUnreadableTitle,
                  style: t.textTheme.headlineSmall,
                ),
                const SizedBox(height: 12),
                Text(
                  missing
                      ? context.l10n.appDbLockedBody
                      : context.l10n.appDbUnreadableBody,
                ),
                const SizedBox(height: 12),
                Text(context.l10n.appDbRecoveryAdvice),
                if (problem.detail != null) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Text(problem.detail!, textDirection: TextDirection.ltr, maxLines: 3, overflow: TextOverflow.ellipsis, style: t.textTheme.bodySmall),
                      ),
                      IconButton(
                        tooltip: context.l10n.appDbCopyDetails,
                        icon: const Icon(Icons.copy_rounded, size: 18),
                        onPressed: () => Clipboard.setData(ClipboardData(text: '${problem.problem.name}: ${problem.detail}')),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 24),
                FilledButton.icon(key: const Key('db-retry'), onPressed: onRetry, icon: const Icon(Icons.refresh_rounded), label: Text(context.l10n.appDbTryAgain)),
                const SizedBox(height: 8),
                OutlinedButton.icon(key: const Key('db-fresh'), onPressed: onStartFresh, icon: const Icon(Icons.delete_sweep_rounded), label: Text(context.l10n.appDbStartFresh)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
