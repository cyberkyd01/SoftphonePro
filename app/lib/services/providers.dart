import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:spcore_dart/spcore_dart.dart';

import '../models/account_profile.dart';
import '../models/app_settings.dart';
import '../models/call_record.dart';
import '../models/chat.dart';
import '../lan/lan_handoff_impl.dart';
import '../models/contact.dart';
import '../platform/lan_handoff.dart';
import '../platform/platform_services.dart';
import '../storage/app_database.dart';
import '../storage/repositories.dart';
import '../storage/secrets_store.dart';
import 'safe_connectivity.dart';
import 'ringtones.dart';

/// An engine plus whether it is the in-memory simulator.
class EngineHandle {
  const EngineHandle(this.engine, {required this.demo, this.note, this.loadError});
  final SipEngine engine;
  final bool demo;
  final String? note;

  /// Why the native library could not be loaded (the engine controller turns
  /// it into the localised demo-mode note).
  final String? loadError;
}

typedef EngineFactory = Future<EngineHandle> Function({required bool simulator});

/// Default: real FFI engine; on load failure the simulator ("Demo mode").
Future<EngineHandle> defaultEngineFactory({required bool simulator}) async {
  if (!simulator) {
    try {
      final e = FfiSipEngine();
      await e.init();
      return EngineHandle(e, demo: false);
    } catch (err) {
      return EngineHandle(
        FakeSipEngine(),
        demo: true,
        loadError: '$err',
      );
    }
  }
  return EngineHandle(FakeSipEngine(), demo: true);
}

/// Everything read from disk before the first frame.
class BootData {
  const BootData({
    this.settings = const AppSettings(),
    this.profiles = const [],
    this.contacts = const [],
    this.history = const [],
    this.messages = const [],
  });
  final AppSettings settings;
  final List<AccountProfile> profiles;
  final List<Contact> contacts;
  final List<CallRecord> history;
  final List<ChatMessage> messages;
}

// ---- overridable infrastructure -------------------------------------------

final appDatabaseProvider = Provider<AppDatabase>(
  (ref) => throw UnimplementedError('appDatabaseProvider must be overridden'),
);
final secretsStoreProvider = Provider<SecretsStore>(
  (ref) => throw UnimplementedError('secretsStoreProvider must be overridden'),
);
final bootDataProvider = Provider<BootData>((ref) => const BootData());
final engineFactoryProvider = Provider<EngineFactory>(
  (ref) => defaultEngineFactory,
);
final platformServicesProvider = Provider<PlatformServices>(
  (ref) => NoopPlatformServices(),
);
final lanHandoffProvider = Provider<LanHandoff>((ref) => ref.watch(lanHandoffFacadeProvider));

/// Connectivity changes; override with an empty stream in tests.
final connectivityStreamProvider = Provider<Stream<List<ConnectivityResult>>>(
  (ref) => guardedConnectivityStream(),
);

/// Where recordings are written when no folder is configured.
final recordingsDirProvider = Provider<Future<String> Function()>(
  (ref) => () async {
    final d = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(d.path, 'Recordings'));
    await dir.create(recursive: true);
    return dir.path;
  },
);

// ---- repositories ---------------------------------------------------------

final accountsRepoProvider = Provider(
  (ref) => AccountsRepository(
    ref.watch(appDatabaseProvider),
    ref.watch(secretsStoreProvider),
  ),
);
final historyRepoProvider = Provider(
  (ref) => HistoryRepository(ref.watch(appDatabaseProvider)),
);
final contactsRepoProvider = Provider(
  (ref) => ContactsRepository(ref.watch(appDatabaseProvider)),
);
final messagesRepoProvider = Provider(
  (ref) => MessagesRepository(ref.watch(appDatabaseProvider)),
);
final settingsRepoProvider = Provider(
  (ref) => SettingsRepository(ref.watch(appDatabaseProvider)),
);
final recordingsRepoProvider = Provider(
  (ref) => RecordingsRepository(ref.watch(appDatabaseProvider)),
);

Future<BootData> loadBootData(
  AppDatabase db,
  SecretsStore secrets,
) async => BootData(
  settings: await SettingsRepository(db).load(),
  profiles: await AccountsRepository(db, secrets).loadAll(),
  contacts: await ContactsRepository(db).loadAll(),
  history: await HistoryRepository(db).loadAll(),
  messages: await MessagesRepository(db).loadAll(),
);

/// A transient user-visible message (snackbar) with optional details.
class AppNotice {
  AppNotice(this.message, {this.details, this.isError = false})
    : id = DateTime.now().microsecondsSinceEpoch;
  final int id;
  final String message;
  final String? details;
  final bool isError;
}

class NoticeController extends Notifier<AppNotice?> {
  @override
  AppNotice? build() => null;
  void show(String message, {String? details, bool isError = false}) =>
      state = AppNotice(message, details: details, isError: isError);
  void error(String message, {String? details}) =>
      show(message, details: details, isError: true);
}

final noticeProvider = NotifierProvider<NoticeController, AppNotice?>(
  NoticeController.new,
);

/// Turns a ringtone name into a playable local file (overridable in tests).
final ringtoneFileProvider = Provider<Future<String?> Function(String name)>(
  (ref) => (name) async {
    try {
      return await defaultRingtoneFile(name);
    } catch (_) {
      return null;
    }
  },
);

/// Local path of the recording-beep WAV (null if unavailable).
final recordBeepFileProvider = Provider<Future<String?> Function()>(
  (ref) => () async {
    try {
      return await supportAssetFile(kRecordBeepAsset);
    } catch (_) {
      return null;
    }
  },
);
