import 'package:garden_client/garden_client.dart';

abstract interface class ChatGateway {
  Client get client;
}

abstract interface class ChatService {
  Future<ChatSnapshot> snapshot(int drive, {int? conversation});
  Future<List<DriveMessage>> history(
    int drive,
    int before, {
    int? conversation,
  });
  Future<List<DriveMessage>> thread(
    int drive,
    int message,
    int before, {
    int? conversation,
  });
  Future<List<ConversationSummary>> conversations(int drive, int before);
  Future<List<PublicIdentity>> members(int drive);
  Future<ConversationSummary> createConversation(
    int drive,
    List<String> recipients,
    String title,
  );
  Stream<DriveMessage> watch(int drive, int after, {int? conversation});
  Future<DriveMessage> send(
    int drive,
    String text,
    int? reply,
    int? node, {
    int? conversation,
  });
  Future<int> readCursor(int drive);
  Future<void> markRead(int drive, int message, {int? conversation});
}

class ServerpodChatService implements ChatService {
  ServerpodChatService(this.client);
  final Client client;
  @override
  Future<ChatSnapshot> snapshot(int drive, {int? conversation}) =>
      conversation == null
      ? client.chat.snapshot(drive)
      : client.conversationMessages.snapshot(conversation);
  @override
  Future<List<DriveMessage>> history(
    int drive,
    int before, {
    int? conversation,
  }) => conversation == null
      ? client.chat.history(drive, before)
      : client.conversationMessages.history(conversation, before);
  @override
  Future<List<DriveMessage>> thread(
    int drive,
    int message,
    int before, {
    int? conversation,
  }) => conversation == null
      ? client.chat.thread(drive, message, before)
      : client.conversationMessages.thread(conversation, message, before);
  @override
  Future<List<ConversationSummary>> conversations(int drive, int before) =>
      client.conversations.list(drive, before);
  @override
  Future<List<PublicIdentity>> members(int drive) =>
      client.identities.members(drive);
  @override
  Future<ConversationSummary> createConversation(
    int drive,
    List<String> recipients,
    String title,
  ) => client.conversations.create(drive, recipients, title);
  @override
  Stream<DriveMessage> watch(int drive, int after, {int? conversation}) =>
      conversation == null
      ? client.chat.watch(drive, after)
      : client.conversationMessages.watch(conversation, after);
  @override
  Future<DriveMessage> send(
    int drive,
    String text,
    int? reply,
    int? node, {
    int? conversation,
  }) => conversation == null
      ? client.chat.send(drive, text, reply, node)
      : client.conversationMessages.send(conversation, text, reply, node);
  @override
  Future<int> readCursor(int drive) => client.chat.readCursor(drive);
  @override
  Future<void> markRead(int drive, int message, {int? conversation}) =>
      conversation == null
      ? client.chat.markRead(drive, message)
      : client.conversationMessages.markRead(conversation, message);
}
