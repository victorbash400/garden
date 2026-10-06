import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:garden_client/garden_client.dart';
import 'package:garden_flutter/services/inbox_service.dart';
import 'package:garden_flutter/state/inbox_controller.dart';

import 'chat_controller_test.dart' show FakeChat;

class FakeInbox implements InboxService {
  final events = StreamController<InboxEvent>.broadcast();
  List<InboxEntry> entries = [];
  int seenId = 0;
  @override
  Future<InboxSnapshot> snapshot() async =>
      InboxSnapshot(entries: List.of(entries), cursor: 0);
  @override
  Stream<InboxEvent> watch(int cursor) => events.stream;
  @override
  Future<void> seen(int conversation) async {
    seenId = conversation;
  }
}

InboxEntry entry(int id, {int unread = 0, bool added = false}) => InboxEntry(
  gardenId: 1,
  driveName: 'Shared',
  conversationId: id,
  title: 'Review',
  createdAt: DateTime.utc(2026),
  creatorId: 'other',
  members: [PublicIdentity(userId: 'other', username: 'recipient')],
  unreadCount: unread,
  latestText: 'Hello',
  isNew: added,
);
void main() {
  test(
    'Incoming conversation appears without opening a conversation',
    () async {
      final service = FakeInbox(), messages = FakeChat();
      final inbox = InboxController(service, messages, 'me');
      await inbox.start();
      service.entries = [entry(2, added: true)];
      service.events.add(
        InboxEvent(
          userId: 'me',
          gardenId: 1,
          conversationId: 2,
          kind: 'chatAdded',
          createdAt: DateTime.utc(2026),
        ),
      );
      await Future<void>.delayed(Duration.zero);
      expect(inbox.entries.single.title, 'Review');
      expect(inbox.unread, 1);
      expect(inbox.chat, isNull);
      await inbox.select(inbox.entries.single);
      expect(service.seenId, 2);
      service.entries = [entry(2, unread: 3)];
      await inbox.refresh();
      expect(inbox.unread, 3);
      service.entries = [];
      await inbox.refresh();
      expect(inbox.chat, isNull);
      inbox.dispose();
      await service.events.close();
      await messages.events.close();
    },
  );
  test('Signing out discards account entries and later events', () async {
    final service = FakeInbox()..entries = [entry(3, unread: 2)];
    final messages = FakeChat();
    final inbox = InboxController(service, messages, 'me');
    await inbox.start();
    await inbox.close();
    service.events.add(
      InboxEvent(
        userId: 'me',
        gardenId: 1,
        kind: 'chatMessage',
        createdAt: DateTime.utc(2026),
      ),
    );
    await Future<void>.delayed(Duration.zero);
    expect(inbox.entries, isEmpty);
    expect(inbox.unread, 0);
    inbox.dispose();
    await service.events.close();
    await messages.events.close();
  });
}
