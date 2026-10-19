import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spcore_dart/spcore_dart.dart';

import '../core/format.dart';
import '../models/chat.dart';
import '../storage/repositories.dart';
import 'contacts_controller.dart';
import 'engine_controller.dart';
import 'providers.dart';
import 'settings_controller.dart';

class MessagesState {
  const MessagesState({this.messages = const [], this.typing = const {}});
  final List<ChatMessage> messages;

  /// Conversation keys whose remote party is typing.
  final Set<String> typing;

  List<Conversation> get conversations {
    final byKey = <String, List<ChatMessage>>{};
    for (final m in messages) {
      (byKey[m.conversationKey] ??= []).add(m);
    }
    final out = <Conversation>[];
    for (final e in byKey.entries) {
      final list = e.value..sort((a, b) => a.time.compareTo(b.time));
      final last = list.last;
      final named = list.reversed.firstWhere(
        (m) => m.peerDisplay.isNotEmpty,
        orElse: () => last,
      );
      out.add(
        Conversation(
          key: e.key,
          channel: last.channel,
          accountId: last.accountId,
          peer: last.peer,
          peerDisplay: named.peerDisplay,
          last: last,
          unread: list.where((m) => !m.outgoing && !m.read).length,
        ),
      );
    }
    out.sort((a, b) => b.last.time.compareTo(a.last.time));
    return out;
  }

  List<ChatMessage> thread(String key) =>
      messages.where((m) => m.conversationKey == key).toList()
        ..sort((a, b) => a.time.compareTo(b.time));

  int get unreadTotal =>
      messages.where((m) => !m.outgoing && !m.read).length;
}

class MessagesController extends Notifier<MessagesState> {
  final Map<String, Timer> _typingTimers = {};

  @override
  MessagesState build() {
    final sub = ref.read(engineProvider.notifier).events.listen(_onEvent);
    ref.onDispose(() {
      sub.cancel();
      for (final t in _typingTimers.values) {
        t.cancel();
      }
    });
    return MessagesState(messages: ref.read(bootDataProvider).messages);
  }

  void _put(ChatMessage m) {
    final exists = state.messages.any((e) => e.id == m.id);
    state = MessagesState(
      messages: exists
          ? [for (final e in state.messages) e.id == m.id ? m : e]
          : [...state.messages, m],
      typing: state.typing,
    );
    unawaited(ref.read(messagesRepoProvider).put(m));
  }

  /// Sends a SIP MESSAGE through [accountId] to [to].
  Future<ChatMessage?> send(String accountId, String to, String body) async {
    final text = body.trim();
    if (text.isEmpty) return null;
    final engine = ref.read(engineProvider.notifier);
    final id = newId();
    final contacts = ref.read(contactsProvider);
    var m = ChatMessage(
      id: id,
      channel: kChannelSip,
      accountId: accountId,
      peer: to,
      outgoing: true,
      body: text,
      time: DateTime.now(),
      status: MessageStatus.sending,
      peerDisplay: nameForNumber(contacts, to, ''),
    );
    _put(m);
    if (!engine.hasEngine) {
      _put(m.copyWith(status: MessageStatus.failed, error: 'Engine not running'));
      return m;
    }
    try {
      await engine.engine.sendIm(
        acc: AccountRef.uid(accountId),
        to: to,
        body: text,
        msgId: id,
      );
      // Delivery is reported through im.status; an early status may already
      // have updated the message.
      final cur = state.messages.firstWhere((e) => e.id == id, orElse: () => m);
      if (cur.status == MessageStatus.sending) {
        m = cur.copyWith(status: MessageStatus.sent);
        _put(m);
      }
    } on EngineException catch (e) {
      m = m.copyWith(status: MessageStatus.failed, error: e.error.message);
      _put(m);
    }
    return m;
  }

  Future<void> retry(ChatMessage m) async {
    state = MessagesState(
      messages: state.messages.where((e) => e.id != m.id).toList(),
      typing: state.typing,
    );
    await send(m.accountId, m.peer, m.body);
  }

  Future<void> sendTyping(String accountId, String to, bool typing) async {
    if (!ref.read(settingsProvider).sendTyping) return;
    final engine = ref.read(engineProvider.notifier);
    if (!engine.hasEngine) return;
    try {
      await engine.engine.sendTyping(
        acc: AccountRef.uid(accountId),
        to: to,
        typing: typing,
      );
    } catch (_) {}
  }

  void markRead(String key) {
    final changed = <ChatMessage>[];
    final msgs = [
      for (final m in state.messages)
        if (m.conversationKey == key && !m.outgoing && !m.read)
          () {
            final r = m.copyWith(read: true);
            changed.add(r);
            return r;
          }()
        else
          m,
    ];
    if (changed.isEmpty) return;
    state = MessagesState(messages: msgs, typing: state.typing);
    unawaited(ref.read(messagesRepoProvider).putAll(changed));
  }

  Future<void> deleteConversation(String key) async {
    state = MessagesState(
      messages: state.messages.where((m) => m.conversationKey != key).toList(),
      typing: state.typing,
    );
    await ref.read(messagesRepoProvider).deleteConversation(key);
  }

  /// Appends a message produced by another channel (LAN Link).
  void addExternal(ChatMessage m) => _put(m);

  void _onEvent(EngineEvent e) {
    switch (e) {
      case ImIncomingEvent():
        _onIncoming(e.message);
      case ImStatusEvent():
        final s = e.status;
        final idx = state.messages.indexWhere((m) => m.id == s.msgId);
        if (idx >= 0) {
          final m = state.messages[idx];
          _put(
            m.copyWith(
              status: s.ok ? MessageStatus.delivered : MessageStatus.failed,
              error: s.ok ? '' : '${s.reason} (${s.code})',
            ),
          );
        }
      case ImTypingEvent():
        final t = e.typing;
        final key = '$kChannelSip|${t.uid}|${ChatMessage.peerKey(t.from)}';
        _typingTimers.remove(key)?.cancel();
        final set = {...state.typing};
        if (t.typing) {
          set.add(key);
          _typingTimers[key] = Timer(const Duration(seconds: 10), () {
            state = MessagesState(
              messages: state.messages,
              typing: {...state.typing}..remove(key),
            );
          });
        } else {
          set.remove(key);
        }
        state = MessagesState(messages: state.messages, typing: set);
      default:
    }
  }

  void _onIncoming(ImMessage im) {
    if (im.isLan) return;
    final contacts = ref.read(contactsProvider);
    final display = im.fromDisplay.isNotEmpty
        ? im.fromDisplay
        : nameForNumber(contacts, im.from, '');
    final m = ChatMessage(
      id: newId(),
      channel: kChannelSip,
      accountId: im.uid,
      peer: im.from,
      outgoing: false,
      body: im.body,
      time: DateTime.now(),
      read: false,
      peerDisplay: display,
    );
    _put(m);
    final typingKey = m.conversationKey;
    if (state.typing.contains(typingKey)) {
      state = MessagesState(
        messages: state.messages,
        typing: {...state.typing}..remove(typingKey),
      );
    }
    unawaited(
      ref.read(platformServicesProvider).showMessageNotification(
        title: display.isNotEmpty ? display : userPart(im.from),
        body: im.body,
        payload: m.conversationKey,
      ),
    );
  }
}

final messagesProvider = NotifierProvider<MessagesController, MessagesState>(
  MessagesController.new,
);

final unreadMessagesProvider = Provider<int>(
  (ref) => ref.watch(messagesProvider).unreadTotal,
);

