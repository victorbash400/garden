import 'dart:async';
import '../chat/chat_pages.dart';
import 'package:serverpod/serverpod.dart';
import '../accounts/usernames.dart';
import '../files/drive_access.dart';
import '../files/drive_journal.dart';
import '../gardens/drive_permissions.dart';
import '../generated/protocol.dart';
import 'conversation_access.dart';

class ConversationMessagesEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  Future<ChatSnapshot> snapshot(Session session, int id) async {
    final conversation = await ConversationAccess.require(session, id);
    return session.db.transaction((transaction) async {
      await DriveAccess.lock(
        session,
        conversation.gardenId,
        transaction,
        mode: LockMode.forShare,
        capability: DriveCapability.read,
      );
      await ConversationAccess.require(session, id, transaction: transaction);
      final member = await ConversationMember.db.findFirstRow(
        session,
        transaction: transaction,
        where: (row) =>
            row.conversationId.equals(id) &
            row.userId.equals(DriveAccess.user(session)),
      );
      final messages = await DriveMessage.db.find(
        session,
        transaction: transaction,
        where: (row) =>
            row.conversationId.equals(id) & row.replyToId.equals(null),
        orderBy: (row) => row.id.desc(),
        limit: 100,
      );
      await ChatPages.markThreads(
        session,
        messages,
        transaction: transaction,
      );
      final latest = await DriveMessage.db.findFirstRow(
        session,
        transaction: transaction,
        where: (row) => row.conversationId.equals(id),
        orderBy: (row) => row.id.desc(),
      );
      final summary = await ConversationAccess.summary(
        session,
        conversation,
        transaction: transaction,
      );
      final unread = await DriveMessage.db.count(
        session,
        transaction: transaction,
        where: (row) =>
            row.conversationId.equals(id) &
            (row.id > member!.readCursor) &
            row.authorId.notEquals(DriveAccess.user(session)),
      );
      return ChatSnapshot(
        latestMessageId: latest?.id ?? 0,
        messages: messages,
        identities: summary.members,
        readCursor: member!.readCursor,
        unreadCount: unread,
      );
    });
  }

  Future<List<DriveMessage>> history(
    Session session,
    int id,
    int beforeId,
  ) async {
    await ConversationAccess.require(session, id);
    if (beforeId < 0) throw GardenException(message: 'Invalid message cursor.');
    final messages = await DriveMessage.db.find(
      session,
      where: (row) =>
          row.conversationId.equals(id) &
          row.replyToId.equals(null) &
          (beforeId == 0 ? Constant.bool(true) : row.id < beforeId),
      orderBy: (row) => row.id.desc(),
      limit: 100,
    );
    await ChatPages.markThreads(session, messages);
    return messages;
  }

  Future<List<DriveMessage>> thread(
    Session session,
    int id,
    int messageId,
    int beforeId,
  ) async {
    await ConversationAccess.require(session, id);
    if (beforeId < 0) throw GardenException(message: 'Invalid message cursor.');
    final message = await DriveMessage.db.findById(session, messageId);
    if (message == null || message.conversationId != id) {
      throw GardenException(message: 'Message unavailable.');
    }
    final root = message.replyToId == null
        ? message
        : await DriveMessage.db.findById(session, message.replyToId!);
    if (root == null || root.conversationId != id) {
      throw GardenException(message: 'Thread unavailable.');
    }
    final replies = await DriveMessage.db.find(
      session,
      where: (row) =>
          row.conversationId.equals(id) &
          row.replyToId.equals(root.id) &
          (beforeId == 0 ? Constant.bool(true) : row.id < beforeId),
      orderBy: (row) => row.id.desc(),
      limit: 100,
    );
    return [root, ...replies];
  }

  Future<DriveMessage> send(
    Session session,
    int id,
    String text,
    int? replyToId,
    int? nodeId,
  ) async {
    final clean = text.trim();
    if (clean.length > 4000 || (clean.isEmpty && nodeId == null)) {
      throw GardenException(
        message: 'Use a message of 1–4000 characters or mention a file.',
      );
    }
    final conversation = await ConversationAccess.require(session, id);
    final identity = await Usernames.ensure(session, DriveAccess.user(session));
    late DriveEvent event;
    final result = await session.db.transaction((transaction) async {
      final drive = await DriveAccess.lock(
        session,
        conversation.gardenId,
        transaction,
        capability: DriveCapability.read,
      );
      await ConversationAccess.require(session, id, transaction: transaction);
      if (replyToId != null) {
        final parent = await DriveMessage.db.findById(
          session,
          replyToId,
          transaction: transaction,
        );
        if (parent == null ||
            parent.conversationId != id ||
            parent.replyToId != null) {
          throw GardenException(message: 'This thread is unavailable.');
        }
      }
      final node = nodeId == null
          ? null
          : await DriveAccess.node(session, nodeId, transaction: transaction);
      if (node != null && node.gardenId != drive.id) {
        throw GardenException(message: 'Choose a file in this drive.');
      }
      final message = await DriveMessage.db.insertRow(
        session,
        DriveMessage(
          gardenId: drive.id!,
          conversationId: id,
          authorId: identity.userId,
          username: identity.username,
          text: clean,
          replyToId: replyToId,
          nodeId: nodeId,
          nodeName: node?.name,
          createdAt: DateTime.now().toUtc(),
        ),
        transaction: transaction,
      );
      drive.revision++;
      await GardenRecord.db.updateRow(session, drive, transaction: transaction);
      event = await DriveEvent.db.insertRow(
        session,
        DriveEvent(
          gardenId: drive.id!,
          revision: drive.revision,
          operation: 'chat',
          authorId: identity.userId,
          createdAt: message.createdAt,
        ),
        transaction: transaction,
      );
      return message;
    });
    await DriveJournal.publish(session, event);
    return result;
  }

  Future<void> markRead(Session session, int id, int messageId) async {
    final conversation = await ConversationAccess.require(session, id);
    await session.db.transaction((transaction) async {
      await DriveAccess.lock(
        session,
        conversation.gardenId,
        transaction,
        capability: DriveCapability.read,
      );
      await ConversationAccess.require(session, id, transaction: transaction);
      final message = await DriveMessage.db.findById(
        session,
        messageId,
        transaction: transaction,
      );
      if (message == null || message.conversationId != id) {
        throw GardenException(message: 'Message unavailable.');
      }
      final member = await ConversationMember.db.findFirstRow(
        session,
        where: (row) =>
            row.conversationId.equals(id) &
            row.userId.equals(DriveAccess.user(session)),
        transaction: transaction,
      );
      if (messageId > member!.readCursor) {
        member.readCursor = messageId;
        await ConversationMember.db.updateRow(
          session,
          member,
          transaction: transaction,
        );
      }
    });
  }

  Stream<DriveMessage> watch(Session session, int id, int afterId) async* {
    if (afterId < 0) throw GardenException(message: 'Invalid message cursor.');
    final conversation = await ConversationAccess.require(session, id);
    final changes = StreamIterator(
      session.messages.createStream<DriveEvent>(
        DriveJournal.channel(conversation.gardenId),
      ),
    );
    var cursor = afterId;
    Future<List<DriveMessage>> pending() => DriveMessage.db.find(
      session,
      where: (row) => row.conversationId.equals(id) & (row.id > cursor),
      orderBy: (row) => row.id,
      limit: 100,
    );
    try {
      var batch = await pending();
      while (true) {
        await ConversationAccess.require(session, id);
        for (final message in batch) {
          cursor = message.id!;
          yield message;
        }
        if (batch.length == 100) {
          batch = await pending();
          continue;
        }
        if (!await changes.moveNext()) break;
        batch = await pending();
      }
    } finally {
      await changes.cancel();
    }
  }
}
