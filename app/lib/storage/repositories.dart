import 'dart:async';
import 'dart:io';

import 'package:sembast/sembast.dart';
import 'package:uuid/uuid.dart';

import '../models/account_profile.dart';
import '../models/app_settings.dart';
import '../models/call_record.dart';
import '../models/chat.dart';
import '../models/contact.dart';
import 'app_database.dart';
import 'secrets_store.dart';

const _uuid = Uuid();
String newId() => _uuid.v4();

/// Generic JSON record store over sembast with change notifications.
class JsonStore {
  JsonStore(this._db, String name) : _store = stringMapStoreFactory.store(name);
  final Database _db;
  final StoreRef<String, Map<String, Object?>> _store;

  Future<List<Map<String, dynamic>>> all() async {
    final recs = await _store.find(_db);
    return [for (final r in recs) Map<String, dynamic>.from(r.value)];
  }

  Future<Map<String, dynamic>?> get(String id) async {
    final v = await _store.record(id).get(_db);
    return v == null ? null : Map<String, dynamic>.from(v);
  }

  Future<void> put(String id, Map<String, dynamic> json) async {
    await _store.record(id).put(_db, json);
  }

  Future<void> putAll(Map<String, Map<String, dynamic>> items) async {
    await _db.transaction((txn) async {
      for (final e in items.entries) {
        await _store.record(e.key).put(txn, e.value);
      }
    });
  }

  Future<void> delete(String id) async {
    await _store.record(id).delete(_db);
  }

  Future<void> deleteWhere(bool Function(Map<String, dynamic>) test) async {
    final recs = await _store.find(_db);
    await _db.transaction((txn) async {
      for (final r in recs) {
        if (test(Map<String, dynamic>.from(r.value))) {
          await _store.record(r.key).delete(txn);
        }
      }
    });
  }

  Future<void> clear() => _store.delete(_db);
}

class AccountsRepository {
  AccountsRepository(AppDatabase db, this._secrets)
    : _store = JsonStore(db.db, 'accounts');
  final JsonStore _store;
  final SecretsStore _secrets;

  static String _pwKey(String id) => 'account.$id.password';

  /// Persists the profile list in order (order = list index).
  Future<void> saveAll(List<AccountProfile> profiles) async {
    final existing = {for (final j in await _store.all()) j['id'] as String};
    final keep = <String>{};
    for (var i = 0; i < profiles.length; i++) {
      final p = profiles[i];
      keep.add(p.id);
      await _store.put(p.id, {...p.toJson(), 'order': i});
      await _secrets.write(_pwKey(p.id), p.config.password);
    }
    for (final id in existing.difference(keep)) {
      await _store.delete(id);
      await _secrets.delete(_pwKey(id));
    }
  }

  Future<List<AccountProfile>> loadAll() async {
    final recs = await _store.all();
    recs.sort(
      (a, b) => ((a['order'] ?? 0) as num).compareTo((b['order'] ?? 0) as num),
    );
    final out = <AccountProfile>[];
    for (final j in recs) {
      final base = AccountProfile.fromJson(j);
      final pw = await _secrets.read(_pwKey(base.id)) ?? '';
      out.add(base.copyWith(config: base.config.copyWith(password: pw)));
    }
    return out;
  }
}

class HistoryRepository {
  HistoryRepository(AppDatabase db) : _store = JsonStore(db.db, 'history');
  final JsonStore _store;

  Future<List<CallRecord>> loadAll() async {
    final out = [for (final j in await _store.all()) CallRecord.fromJson(j)];
    out.sort((a, b) => b.start.compareTo(a.start));
    return out;
  }

  Future<void> put(CallRecord r) => _store.put(r.id, r.toJson());
  Future<void> delete(String id) => _store.delete(id);
  Future<void> clear() => _store.clear();
}

class ContactsRepository {
  ContactsRepository(AppDatabase db) : _store = JsonStore(db.db, 'contacts');
  final JsonStore _store;

  Future<List<Contact>> loadAll() async => [
    for (final j in await _store.all()) Contact.fromJson(j),
  ];
  Future<void> put(Contact c) => _store.put(c.id, c.toJson());
  Future<void> putAll(Iterable<Contact> cs) =>
      _store.putAll({for (final c in cs) c.id: c.toJson()});
  Future<void> delete(String id) => _store.delete(id);
  Future<void> clear() => _store.clear();
}

class MessagesRepository {
  MessagesRepository(AppDatabase db) : _store = JsonStore(db.db, 'messages');
  final JsonStore _store;

  Future<List<ChatMessage>> loadAll() async {
    final out = [for (final j in await _store.all()) ChatMessage.fromJson(j)];
    out.sort((a, b) => a.time.compareTo(b.time));
    return out;
  }

  Future<void> put(ChatMessage m) => _store.put(m.id, m.toJson());
  Future<void> putAll(Iterable<ChatMessage> ms) =>
      _store.putAll({for (final m in ms) m.id: m.toJson()});
  Future<void> delete(String id) => _store.delete(id);
  Future<void> deleteConversation(String key) => _store.deleteWhere(
    (j) => ChatMessage.fromJson(j).conversationKey == key,
  );
}

class SettingsRepository {
  SettingsRepository(AppDatabase db)
    : _db = db.db,
      _store = StoreRef<String, Map<String, Object?>>('settings');
  final Database _db;
  final StoreRef<String, Map<String, Object?>> _store;

  Future<AppSettings> load() async {
    final v = await _store.record('app').get(_db);
    return v == null
        ? const AppSettings()
        : AppSettings.fromJson(Map<String, dynamic>.from(v));
  }

  Future<void> save(AppSettings s) async {
    await _store.record('app').put(_db, s.toJson());
  }
}

class RecordingsRepository {
  RecordingsRepository(AppDatabase db) : _store = JsonStore(db.db, 'recordings');
  final JsonStore _store;

  Future<List<RecordingMeta>> loadAll() async {
    final out = [for (final j in await _store.all()) RecordingMeta.fromJson(j)];
    out.sort((a, b) => b.time.compareTo(a.time));
    return out;
  }

  Future<void> put(RecordingMeta m) => _store.put(m.id, m.toJson());

  Future<void> delete(RecordingMeta m, {bool deleteFile = true}) async {
    await _store.delete(m.id);
    if (deleteFile) {
      try {
        final f = File(m.path);
        if (await f.exists()) await f.delete();
      } catch (_) {}
    }
  }
}
