import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:garden_client/garden_client.dart';
import 'package:garden_flutter/services/chat_gateway.dart';
import 'package:garden_flutter/state/chat_controller.dart';

DriveMessage message(int id, {String author = 'other', int? reply}) =>
    DriveMessage(
      id: id,
      gardenId: 1,
      authorId: author,
      username: 'member',
      text: 'Message $id',
      replyToId: reply,
      createdAt: DateTime.utc(2026, 10, 6),
    );

class FakeChat implements ChatService {
  final sent = <DriveMessage>[];
  bool failSend = false;
  final events = StreamController<DriveMessage>.broadcast();
  Completer<ChatSnapshot>? delayed;
  int watched = 0, read = 0;
  ChatSnapshot initial = ChatSnapshot(
    messages: [message(2), message(1)],
    identities: [PublicIdentity(userId: 'other', username: 'member')],
    readCursor: 1,
    unreadCount: 1,
  );
  @override
  Future<ChatSnapshot> snapshot(int drive, {int? conversation}) async =>
      delayed != null
      ? delayed!.future
      : ChatSnapshot(
          messages: [
            ...initial.messages,
            ...sent,
          ].where((item) => item.conversationId == conversation).toList(),
          identities: initial.identities,
          readCursor: initial.readCursor,
          unreadCount: initial.unreadCount,
        );
  @override
  Stream<DriveMessage> watch(int drive, int after, {int? conversation}) {
    watched = after;
    return events.stream.where((item) => item.conversationId == conversation);
  }

  @override
  Future<void> markRead(int drive, int id, {int? conversation}) async {
    read = id;
  }

  @override
  Future<int> readCursor(int drive) async => read;
  @override
  Future<List<DriveMessage>> thread(
    int drive,
    int id,
    int before, {
    int? conversation,
  }) async {
    final items = [...initial.messages, ...sent];
    return [
      items.firstWhere((item) => item.id == id),
      ...items.where((item) => item.replyToId == id),
    ];
  }

  @override
  Future<List<DriveMessage>> history(
    int drive,
    int before, {
    int? conversation,
  }) async => [];
  final groups = <ConversationSummary>[];
  @override
  Future<List<ConversationSummary>> conversations(
    int drive,
    int before,
  ) async => groups;
  @override
  Future<List<PublicIdentity>> members(int drive) async => [
    PublicIdentity(userId: 'me', username: 'my_user'),
    PublicIdentity(userId: 'other', username: 'member'),
  ];
  @override
  Future<ConversationSummary> createConversation(
    int drive,
    List<String> recipients,
    String title,
  ) async {
    final value = ConversationSummary(
      conversation: Conversation(
        id: groups.length + 1,
        gardenId: drive,
        creatorId: 'me',
        title: title,
        createdAt: DateTime.utc(2026),
      ),
      members: await members(drive),
    );
    groups.add(value);
    return value;
  }

  @override
  Future<DriveMessage> send(
    int drive,
    String text,
    int? reply,
    int? node, {
    int? conversation,
  }) async {
    if (failSend) throw StateError('Message could not be sent.');
    final value = message(4 + sent.length, author: 'me', reply: reply).copyWith(
      text: text,
      conversationId: conversation,
      nodeId: node,
      nodeName: node == null ? null : 'Shared.txt',
    );
    sent.add(value);
    return value;
  }
}

void main() {
  test('snapshot and stream merge without duplicate unread counts; opening marks read', () async {
    final service = FakeChat();
    final controller = ChatController(service, 1, 'me');
    await controller.start();
    expect(service.watched, 2);
    expect(controller.unread, 1);
    service.events.add(message(2));
    service.events.add(message(3));
    await Future<void>.delayed(Duration.zero);
    expect(controller.unread, 2);
    expect(controller.messages.length, 3);
    controller.toggle();
    await Future<void>.delayed(Duration.zero);
    expect(service.read, 3);
    expect(controller.unread, 0);
    await controller.openThread(message(2));
    expect(await controller.send('Reply'), isTrue);
    expect(controller.messages.first.replyToId, 2);
    expect(controller.messages.first.authorId, 'me');
    controller.dispose();
    await service.events.close();
  });
  test(
    'disposed controller rejects a late snapshot and cancels its subscription',
    () async {
      final service = FakeChat()..delayed = Completer<ChatSnapshot>();
      final controller = ChatController(service, 1, 'me');
      final loading = controller.start();
      await Future<void>.delayed(Duration.zero);
      controller.dispose();
      service.delayed!.complete(service.initial);
      await loading;
      expect(service.events.hasListener, isFalse);
      await service.events.close();
    },
  );
  test('closed stream is visible', () async {
    final service = FakeChat();
    final controller = ChatController(service, 1, 'me');
    await controller.start();
    await service.events.close();
    await Future<void>.delayed(Duration.zero);
    expect(controller.connected, isFalse);
    expect(controller.error, contains('disconnected'));
    controller.dispose();
  });
}
