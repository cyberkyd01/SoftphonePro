import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/format.dart';
import '../../core/theme.dart';
import '../../models/chat.dart';
import '../../lan/lan_controller.dart';
import '../../services/accounts_controller.dart';
import '../../services/calls_controller.dart';
import '../../services/contacts_controller.dart';
import '../../services/messages_controller.dart';
import '../../services/providers.dart';
import '../widgets/basic_widgets.dart';
import 'lan/lan_widgets.dart';
import '../widgets/settings_tiles.dart';

String convTitle(Conversation c, List<dynamic> contacts) {
  if (c.channel == kChannelLan) return c.peerDisplay.isNotEmpty ? c.peerDisplay : c.peer;
  final named = findContact(List.castFrom(contacts), c.peer)?.displayName;
  if (named != null && named.isNotEmpty) return named;
  if (c.peerDisplay.isNotEmpty) return c.peerDisplay;
  return userPart(c.peer);
}

class MessagesPage extends ConsumerStatefulWidget {
  const MessagesPage({super.key});
  @override
  ConsumerState<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends ConsumerState<MessagesPage> {
  String? _selected;

  Future<void> _newMessage() async {
    final lan = ref.read(lanControllerProvider);
    if (lan.running && lan.paired.isNotEmpty) {
      final pick = await pickLanChatPeer(context, lan.paired);
      if (!mounted) return;
      if (pick != null && pick != 'sip') {
        _openThread(kChannelLan, pick, pick);
        return;
      }
      if (pick == null) return;
    }
    final acc = ref.read(accountsProvider);
    if (acc.profiles.isEmpty) {
      ref.read(noticeProvider.notifier).error('Add an account to send messages');
      return;
    }
    final to = await promptText(context, title: 'New message', hint: 'Number or SIP address', keyboardType: TextInputType.emailAddress);
    if (to == null || to.isEmpty || !mounted) return;
    final accId = acc.defaultProfile?.id ?? acc.profiles.first.id;
    _openThread(kChannelSip, accId, to);
  }

  void _openThread(String channel, String accId, String peer) {
    final key = '$channel|$accId|${ChatMessage.peerKey(peer)}';
    if (context.isExpanded) {
      setState(() => _selected = key);
      ref.read(_draftPeerProvider.notifier).set((accId, peer));
    } else {
      context.push('/thread?acc=$accId&peer=${Uri.encodeQueryComponent(peer)}&ch=$channel');
    }
  }

  @override
  Widget build(BuildContext context) {
    final ms = ref.watch(messagesProvider);
    final contacts = ref.watch(contactsProvider);
    final convs = ms.conversations;
    final expanded = context.isExpanded;
    final t = Theme.of(context);

    final listPane = Column(
      children: [
        PageHeader(
          title: 'Messages',
          actions: [IconButton(tooltip: 'New message', onPressed: _newMessage, icon: const Icon(Icons.edit_square))],
        ),
        Expanded(
          child: convs.isEmpty
              ? EmptyState(
                  icon: Icons.chat_bubble_outline_rounded,
                  title: 'No conversations',
                  subtitle: 'Send a SIP message to any extension or address on your accounts.',
                  actionLabel: 'New message',
                  onAction: _newMessage,
                )
              : ListView.separated(
                  padding: const EdgeInsets.only(bottom: 16),
                  itemCount: convs.length,
                  separatorBuilder: (_, __) => const Divider(indent: 72),
                  itemBuilder: (context, i) {
                    final c = convs[i];
                    final title = convTitle(c, contacts);
                    return ListTile(
                      key: ValueKey(c.key),
                      selected: expanded && _selected == c.key,
                      selectedTileColor: t.colorScheme.primary.withValues(alpha: 0.08),
                      leading: Avatar(name: title, icon: c.channel == kChannelLan ? Icons.devices_rounded : null),
                      title: Row(
                        children: [
                          Flexible(child: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontWeight: c.unread > 0 ? FontWeight.w700 : FontWeight.w600))),
                          if (c.channel == kChannelLan) ...[const SizedBox(width: 6), const LanBadge()],
                        ],
                      ),
                      subtitle: Text(
                        ms.typing.contains(c.key) ? 'typing...' : '${c.last.outgoing ? 'You: ' : ''}${c.last.body}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontWeight: c.unread > 0 ? FontWeight.w600 : null),
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(timeLabel(c.last.time), style: t.textTheme.bodySmall),
                          const SizedBox(height: 4),
                          if (c.unread > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(color: t.colorScheme.primary, borderRadius: BorderRadius.circular(999)),
                              child: Text('${c.unread}', style: TextStyle(color: t.colorScheme.onPrimary, fontSize: 12, fontWeight: FontWeight.w700)),
                            )
                          else
                            const SizedBox(height: 18),
                        ],
                      ),
                      onTap: () {
                        if (expanded) {
                          setState(() => _selected = c.key);
                          ref.read(_draftPeerProvider.notifier).set(null);
                        } else {
                          context.push('/thread?acc=${c.accountId}&peer=${Uri.encodeQueryComponent(c.peer)}&ch=${c.channel}');
                        }
                      },
                    );
                  },
                ),
        ),
      ],
    );
    if (!expanded) return listPane;
    final draft = ref.watch(_draftPeerProvider);
    Conversation? sel;
    for (final c in convs) {
      if (c.key == _selected) sel = c;
    }
    return Row(
      children: [
        SizedBox(width: 380, child: listPane),
        VerticalDivider(width: 1, color: t.colorScheme.outlineVariant),
        Expanded(
          child: _selected == null
              ? const EmptyState(icon: Icons.forum_outlined, title: 'Select a conversation')
              : ThreadView(
                  key: ValueKey(_selected),
                  channel: sel?.channel ?? _selected!.split('|').first,
                  accountId: sel?.accountId ?? draft?.$1 ?? '',
                  peer: sel?.peer ?? draft?.$2 ?? '',
                  embedded: true,
                ),
        ),
      ],
    );
  }
}

class _DraftPeer extends Notifier<(String, String)?> {
  @override
  (String, String)? build() => null;
  void set((String, String)? v) => state = v;
}

final _draftPeerProvider = NotifierProvider<_DraftPeer, (String, String)?>(_DraftPeer.new);

class ThreadPage extends StatelessWidget {
  const ThreadPage({super.key, required this.accountId, required this.peer, this.channel = kChannelSip});
  final String accountId;
  final String peer;
  final String channel;
  @override
  Widget build(BuildContext context) => ThreadView(accountId: accountId, peer: peer, channel: channel);
}

class ThreadView extends ConsumerStatefulWidget {
  const ThreadView({super.key, required this.accountId, required this.peer, this.embedded = false, this.channel = kChannelSip});
  final String accountId;
  final String peer;
  final bool embedded;

  /// [kChannelSip] or [kChannelLan] (then both ids are the LAN device id).
  final String channel;
  @override
  ConsumerState<ThreadView> createState() => _ThreadViewState();
}

class _ThreadViewState extends ConsumerState<ThreadView> {
  final _ctl = TextEditingController();
  final _scroll = ScrollController();
  bool _typingSent = false;

  bool get _lan => widget.channel == kChannelLan;
  String get _key => '${widget.channel}|${widget.accountId}|${ChatMessage.peerKey(widget.peer)}';
  late final LanOpenThread _openThread = ref.read(lanOpenThreadProvider.notifier);

  void _markRead() {
    if (_lan) {
      unawaited(ref.read(lanControllerProvider.notifier).readThread(widget.peer));
    } else {
      ref.read(messagesProvider.notifier).markRead(_key);
    }
  }

  @override
  void initState() {
    super.initState();
    _openThread; // resolve while the element is alive
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_lan) _openThread.set(widget.peer);
      _markRead();
    });
  }

  @override
  void dispose() {
    if (_lan) {
      final peer = widget.peer;
      Future.microtask(() => _openThread.clearIf(peer));
    }
    _ctl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _ctl.text;
    if (text.trim().isEmpty) return;
    _ctl.clear();
    _typingSent = false;
    if (_lan) {
      await ref.read(lanControllerProvider.notifier).sendChat(widget.peer, text);
      return;
    }
    await ref.read(messagesProvider.notifier).send(widget.accountId, widget.peer, text);
  }

  @override
  Widget build(BuildContext context) {
    final ms = ref.watch(messagesProvider);
    final contacts = ref.watch(contactsProvider);
    final thread = ms.thread(_key);
    final typing = ms.typing.contains(_key);
    final t = Theme.of(context);
    final acc = ref.watch(accountsProvider);
    final lanPeer = _lan ? ref.watch(lanControllerProvider).peer(widget.peer) : null;
    final title = _lan
        ? (lanPeer?.name ?? thread.where((m) => m.peerDisplay.isNotEmpty).lastOrNull?.peerDisplay ?? widget.peer)
        : (findContact(contacts, widget.peer)?.displayName ??
            (thread.where((m) => m.peerDisplay.isNotEmpty).lastOrNull?.peerDisplay) ??
            userPart(widget.peer));
    ref.listen(messagesProvider, (prev, next) {
      if (next.unreadTotal > 0) _markRead();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scroll.hasClients) _scroll.animateTo(0, duration: const Duration(milliseconds: 180), curve: Curves.easeOutCubic);
      });
    });
    final reversed = thread.reversed.toList();

    final header = Row(
      children: [
        Avatar(name: title, size: 36),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(child: Text(title, style: t.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis)),
                  if (_lan) ...[const SizedBox(width: 6), const LanBadge()],
                ],
              ),
              Text(
                typing
                    ? 'typing...'
                    : _lan
                        ? ((lanPeer?.online ?? false) ? 'Online on your network' : 'Offline. Messages are sent when it is back.')
                        : '${userPart(widget.peer)} · ${acc.byId(widget.accountId)?.name ?? ''}',
                style: t.textTheme.bodySmall?.copyWith(color: typing ? t.colorScheme.primary : t.colorScheme.onSurfaceVariant),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        if (_lan)
          IconButton(
            key: const Key('lan-thread-file'),
            tooltip: 'Send a file to $title',
            onPressed: () => pickAndSendLanFile(context, ref, widget.peer),
            icon: const Icon(Icons.attach_file_rounded),
          ),
        IconButton(
          tooltip: 'Call $title',
          onPressed: () => _lan
              ? ref.read(lanControllerProvider.notifier).callPeer(widget.peer)
              : ref.read(callsProvider.notifier).dial(widget.peer, accountId: widget.accountId.isEmpty ? null : widget.accountId),
          icon: Icon(Icons.call_rounded, color: context.colors.callGreen),
        ),
        PopupMenuButton<String>(
          tooltip: 'More',
          onSelected: (v) async {
            if (v == 'delete' && await confirm(context, title: 'Delete conversation?', message: 'All messages with $title will be removed.')) {
              await ref.read(messagesProvider.notifier).deleteConversation(_key);
              if (!widget.embedded && context.mounted) context.pop();
            }
          },
          itemBuilder: (_) => const [PopupMenuItem(value: 'delete', child: Text('Delete conversation'))],
        ),
      ],
    );

    final body = Column(
      children: [
        Expanded(
          child: thread.isEmpty
              ? EmptyState(
                  icon: Icons.waving_hand_outlined,
                  title: 'Say hello',
                  subtitle: _lan ? 'Messages go straight to this device over your network, end-to-end encrypted.' : 'Messages are sent with SIP MESSAGE through your account.',
                )
              : ListView.builder(
                  controller: _scroll,
                  reverse: true,
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                  itemCount: reversed.length,
                  itemBuilder: (context, i) {
                    final m = reversed[i];
                    final older = i + 1 < reversed.length ? reversed[i + 1] : null;
                    final showDay = older == null || dayLabel(older.time) != dayLabel(m.time);
                    return Column(
                      children: [
                        if (showDay)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Text(dayLabel(m.time), style: t.textTheme.labelSmall?.copyWith(color: t.colorScheme.onSurfaceVariant)),
                          ),
                        _Bubble(
                          message: m,
                          onRetry: () => _lan ? ref.read(lanControllerProvider.notifier).retryChat(m) : ref.read(messagesProvider.notifier).retry(m),
                        ),
                      ],
                    );
                  },
                ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: TextField(
                    key: const Key('message-input'),
                    controller: _ctl,
                    minLines: 1,
                    maxLines: 5,
                    textCapitalization: TextCapitalization.sentences,
                    onChanged: (v) {
                      final typingNow = v.isNotEmpty;
                      if (typingNow != _typingSent) {
                        _typingSent = typingNow;
                        if (_lan) {
                          ref.read(lanControllerProvider.notifier).sendTyping(widget.peer, typingNow);
                        } else {
                          ref.read(messagesProvider.notifier).sendTyping(widget.accountId, widget.peer, typingNow);
                        }
                      }
                    },
                    onSubmitted: (_) => _send(),
                    decoration: const InputDecoration(hintText: 'Message', contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  key: const Key('send-message'),
                  tooltip: 'Send',
                  onPressed: _send,
                  icon: const Icon(Icons.send_rounded),
                ),
              ],
            ),
          ),
        ),
      ],
    );

    if (widget.embedded) {
      return Column(children: [Padding(padding: const EdgeInsets.fromLTRB(16, 10, 8, 6), child: header), const Divider(height: 1), Expanded(child: body)]);
    }
    return Scaffold(
      appBar: AppBar(titleSpacing: 0, title: header),
      body: body,
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.message, required this.onRetry});
  final ChatMessage message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final out = message.outgoing;
    final bg = out ? t.colorScheme.primary : context.colors.card;
    final fg = out ? t.colorScheme.onPrimary : t.colorScheme.onSurface;
    final failed = message.status == MessageStatus.failed;
    return Align(
      alignment: out ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 3),
        constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.78 > 520 ? 520 : MediaQuery.sizeOf(context).width * 0.78),
        padding: const EdgeInsets.fromLTRB(14, 9, 12, 7),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(out ? 18 : 4),
            bottomRight: Radius.circular(out ? 4 : 18),
          ),
          border: out ? null : Border.all(color: t.colorScheme.outlineVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(alignment: Alignment.centerLeft, child: SelectableText(message.body, style: TextStyle(color: fg, fontSize: 15, height: 1.3))),
            const SizedBox(height: 3),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(timeLabel(message.time), style: TextStyle(color: fg.withValues(alpha: 0.7), fontSize: 11)),
                if (out) ...[
                  const SizedBox(width: 4),
                  Semantics(
                    label: switch (message.status) {
                      MessageStatus.sending => 'Sending',
                      MessageStatus.sent => 'Sent',
                      MessageStatus.delivered => 'Delivered',
                      MessageStatus.read => 'Read',
                      MessageStatus.failed => 'Failed',
                      _ => '',
                    },
                    child: Icon(
                      switch (message.status) {
                        MessageStatus.sending => Icons.schedule_rounded,
                        MessageStatus.sent => Icons.check_rounded,
                        MessageStatus.delivered => Icons.done_all_rounded,
                        MessageStatus.read => Icons.done_all_rounded,
                        MessageStatus.failed => Icons.error_outline_rounded,
                        MessageStatus.received => Icons.check_rounded,
                      },
                      size: 14,
                      color: failed
                          ? const Color(0xFFFFB4AB)
                          : message.status == MessageStatus.read
                              ? const Color(0xFF7DD3FC)
                              : fg.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ],
            ),
            if (failed)
              InkWell(
                onTap: onRetry,
                child: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text('Not delivered. Tap to retry', style: TextStyle(color: const Color(0xFFFFB4AB), fontSize: 11, fontWeight: FontWeight.w600)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
