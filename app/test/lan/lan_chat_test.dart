import 'package:flutter_test/flutter_test.dart';
import 'package:softphonepro/lan/lan_controller.dart';
import 'package:softphonepro/models/chat.dart';
import 'package:softphonepro/services/messages_controller.dart';
import 'package:softphonepro/services/providers.dart';

import 'lan_harness.dart';

void main() {
  test('pair, chat both ways: LAN messages land in Messages with channel lan, ticks and typing', () async {
    final a = await LanNode.create('Alpha');
    final b = await LanNode.create('Beta');
    final ca = await a.boot();
    final cb = await b.boot();
    addTearDown(() async {
      await a.dispose();
      await b.dispose();
    });
    await pairNodes(a, ca, b, cb);

    await a.lan().sendChat(b.id(), 'hello beta');
    await until(() => cb.read(messagesProvider).messages.any((m) => m.body == 'hello beta'), what: 'chat at B');
    final got = cb.read(messagesProvider).messages.firstWhere((m) => m.body == 'hello beta');
    expect(got.channel, kChannelLan);
    expect(got.outgoing, isFalse);
    expect(got.read, isFalse);
    expect(got.peerDisplay, 'Alpha');
    expect(cb.read(messagesProvider).conversations.single.channel, kChannelLan);
    expect(cb.read(messagesProvider).unreadTotal, 1);

    // Delivery tick on A, then read tick after B opens the thread.
    await until(() => ca.read(messagesProvider).messages.single.status == MessageStatus.delivered, what: 'delivered');
    await b.lan().readThread(a.id());
    await until(() => ca.read(messagesProvider).messages.single.status == MessageStatus.read, what: 'read');
    expect(cb.read(messagesProvider).unreadTotal, 0);

    // Reply and typing indicator.
    await b.lan().sendTyping(a.id(), true);
    await until(() => ca.read(lanControllerProvider).typing.contains(b.id()), what: 'typing');
    expect(ca.read(messagesProvider).typing, contains(lanConversationKey(b.id())));
    await b.lan().sendChat(a.id(), 'hi alpha');
    await until(() => ca.read(messagesProvider).messages.any((m) => m.body == 'hi alpha'), what: 'reply');
    // Persisted through the repository.
    final stored = await ca.read(messagesRepoProvider).loadAll();
    expect(stored.where((m) => m.channel == kChannelLan), hasLength(2));
  });

  test('sending to an unpaired device is stored as a failed message', () async {
    final a = await LanNode.create('Alpha');
    final ca = await a.boot();
    addTearDown(a.dispose);
    await a.lan().sendChat('deadbeefdeadbeef', 'anyone?');
    final m = ca.read(messagesProvider).messages.single;
    expect(m.status, MessageStatus.failed);
    expect(m.channel, kChannelLan);
  });
}
