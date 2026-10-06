import 'dart:async';
import '../inbox/inbox_delivery.dart';
import '../inbox/inbox_reads.dart';
import '../chat/chat_pages.dart';
import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';
import '../accounts/usernames.dart';
import '../files/drive_access.dart';
import '../files/drive_journal.dart';
import '../gardens/drive_permissions.dart';

class ChatEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  Future<ChatSnapshot> snapshot(Session session, int driveId) =>
      session.db.transaction((transaction) async {
        await DriveAccess.lock(
          session,
          driveId,
          transaction,
          mode: LockMode.forShare,
          capability: DriveCapability.read,
        );
        final cursor =
            (await ChatRead.db.findFirstRow(
              session,
              where: (row) =>
                  row.gardenId.equals(driveId) &
                  row.userId.equals(DriveAccess.user(session)),
              transaction: transaction,
            ))?.messageId ??
            0;
        final messages = await DriveMessage.db.find(
          session,
          where: (row) =>
              row.gardenId.equals(driveId) &
              row.conversationId.equals(null) &
              row.replyToId.equals(null),
          orderBy: (row) => row.id.desc(),
          limit: 100,
          transaction: transaction,
        );
        await ChatPages.markThreads(
          session,
          messages,
          transaction: transaction,
        );
        final latest = await DriveMessage.db.findFirstRow(
          session,
          where: (row) =>
              row.gardenId.equals(driveId) & row.conversationId.equals(null),
          orderBy: (row) => row.id.desc(),
          transaction: transaction,
        );
        final unread = await DriveMessage.db.count(
          session,
          where: (row) =>
              row.gardenId.equals(driveId) &
              row.conversationId.equals(null) &
              (row.id > cursor) &
              row.authorId.notEquals(DriveAccess.user(session)),
          transaction: transaction,
        );
        final members = await GardenMember.db.find(
          session,
          where: (row) => row.gardenId.equals(driveId),
          transaction: transaction,
        );
        final identities = await AccountUsername.db.find(
          session,
          where: (row) => row.userId.inSet({
            ...members.map((member) => member.userId),
            ...messages.map((message) => message.authorId),
          }),
          transaction: transaction,
        );
        return ChatSnapshot(
          latestMessageId: latest?.id ?? 0,
          messages: messages,
          readCursor: cursor,
          unreadCount: unread,
          identities: identities
              .map(
                (identity) => PublicIdentity(
                  userId: identity.userId,
                  username: identity.username,
                ),
              )
              .toList(),
        );
      });

  Future<List<DriveMessage>> thread(
    Session session,
    int driveId,
    int messageId,
    int beforeId,
  ) async {
    await DriveAccess.require(session, driveId);
    if (beforeId < 0) throw GardenException(message: 'Invalid message cursor.');
    final message = await DriveMessage.db.findById(session, messageId);
    if (message == null ||
        message.gardenId != driveId ||
        message.conversationId != null) {
      throw GardenException(message: 'Message unavailable.');
    }
    final root = message.replyToId == null
        ? message
        : await DriveMessage.db.findById(session, message.replyToId!);
    if (root == null ||
        root.gardenId != driveId ||
        root.conversationId != null) {
      throw GardenException(message: 'Thread unavailable.');
    }
    final replies = await DriveMessage.db.find(
      session,
      where: (row) =>
          row.gardenId.equals(driveId) &
          row.conversationId.equals(null) &
          row.replyToId.equals(root.id) &
          (beforeId == 0 ? Constant.bool(true) : row.id < beforeId),
      orderBy: (row) => row.id.desc(),
      limit: 100,
    );
    return [root, ...replies];
  }

  Future<List<DriveMessage>> history(
    Session session,
    int driveId,
    int beforeId,
  ) async {
    await DriveAccess.require(session, driveId);
    if (beforeId < 0) throw GardenException(message: 'Invalid message cursor.');
    final messages = await DriveMessage.db.find(
      session,
      where: (row) =>
          row.gardenId.equals(driveId) &
          row.conversationId.equals(null) &
          row.replyToId.equals(null) &
          (beforeId == 0 ? Constant.bool(true) : row.id < beforeId),
      orderBy: (row) => row.id.desc(),
      limit: 100,
    );
    await ChatPages.markThreads(session, messages);
    return messages;
  }

  Future<List<DriveMessage>> conversations(
    Session session,
    int driveId,
    int beforeId,
  ) async {
    await DriveAccess.require(session, driveId);
    if (beforeId < 0) throw GardenException(message: 'Invalid message cursor.');
    return DriveMessage.db.find(
      session,
      where: (row) =>
          row.gardenId.equals(driveId) &
          row.conversationId.equals(null) &
          row.replyToId.equals(null) &
          (beforeId == 0 ? Constant.bool(true) : row.id < beforeId),
      orderBy: (row) => row.id.desc(),
      limit: 100,
    );
  }

  Future<DriveMessage> send(
    Session session,
    int driveId,
    String text,
    int? replyToId,
    int? nodeId,
  ) async {
    final clean = text.trim();
    if (clean.length > 4000 || (clean.isEmpty && nodeId == null)) {
      throw GardenException(
        message: 'Use a message of 1–4000 characters or share a file.',
      );
    }
    await DriveAccess.require(
      session,
      driveId,
      capability: DriveCapability.read,
    );
    final identity = await Usernames.ensure(session, DriveAccess.user(session));
    late DriveEvent event;
    late InboxDelivery delivery;
    final message = await session.db.transaction((transaction) async {
      final drive = await DriveAccess.lock(
        session,
        driveId,
        transaction,
        capability: DriveCapability.read,
      );
      if (replyToId != null) {
        final parent = await DriveMessage.db.findById(
          session,
          replyToId,
          transaction: transaction,
        );
        if (parent == null ||
            parent.gardenId != driveId ||
            parent.replyToId != null ||
            parent.conversationId != null) {
          throw GardenException(message: 'This conversation is unavailable.');
        }
      }
      final node = nodeId == null
          ? null
          : await DriveAccess.node(session, nodeId, transaction: transaction);
      if (node != null && node.gardenId != driveId) {
        throw GardenException(message: 'Choose a file in this drive.');
      }
      final value = await DriveMessage.db.insertRow(
        session,
        DriveMessage(
          gardenId: driveId,
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
          gardenId: driveId,
          revision: drive.revision,
          operation: 'chat',
          authorId: identity.userId,
          createdAt: value.createdAt,
        ),
        transaction: transaction,
      );
      delivery = await InboxDelivery.record(
        session,
        transaction,
        drive.id!,
        null,
        'chatMessage',
        '${identity.username} sent a message in ${drive.name}',
      );
      return value;
    });
    await DriveJournal.publish(session, event);
    await delivery.publish(session);
    return message;
  }

  Future<int> unread(Session session, int driveId) async {
    final cursor = await readCursor(session, driveId);
    return DriveMessage.db.count(
      session,
      where: (row) =>
          row.gardenId.equals(driveId) &
          row.conversationId.equals(null) &
          (row.id > cursor) &
          row.authorId.notEquals(DriveAccess.user(session)),
    );
  }

  Future<int> readCursor(Session session, int driveId) async {
    await DriveAccess.require(session, driveId);
    return (await ChatRead.db.findFirstRow(
          session,
          where: (row) =>
              row.gardenId.equals(driveId) &
              row.userId.equals(DriveAccess.user(session)),
        ))?.messageId ??
        0;
  }

  Future<void> markRead(Session session, int driveId, int messageId) async {
    InboxReads? delivery;
    await session.db.transaction((transaction) async {
      await DriveAccess.lock(
        session,
        driveId,
        transaction,
        capability: DriveCapability.read,
      );
      final message = await DriveMessage.db.findById(
        session,
        messageId,
        transaction: transaction,
      );
      if (message == null ||
          message.gardenId != driveId ||
          message.conversationId != null) {
        throw GardenException(message: 'This message is unavailable.');
      }
      final user = DriveAccess.user(session);
      final existing = await ChatRead.db.findFirstRow(
        session,
        where: (row) => row.gardenId.equals(driveId) & row.userId.equals(user),
        transaction: transaction,
      );
      if (existing == null) {
        await ChatRead.db.insertRow(
          session,
          ChatRead(gardenId: driveId, userId: user, messageId: messageId),
          transaction: transaction,
        );
      } else if (existing.messageId < messageId) {
        existing.messageId = messageId;
        await ChatRead.db.updateRow(
          session,
          existing,
          transaction: transaction,
        );
      }
      delivery = await InboxReads.record(session, transaction, driveId, null);
    });
    await delivery?.publish(session);
  }

  Stream<DriveMessage> watch(Session session, int driveId, int afterId) async* {
    if (afterId < 0) throw GardenException(message: 'Invalid message cursor.');
    await DriveAccess.require(session, driveId);
    final changes = StreamIterator(
      session.messages.createStream<DriveEvent>(DriveJournal.channel(driveId)),
    );
    var cursor = afterId;
    Future<List<DriveMessage>> pending() => DriveMessage.db.find(
      session,
      where: (row) =>
          row.gardenId.equals(driveId) &
          row.conversationId.equals(null) &
          (row.id > cursor),
      orderBy: (row) => row.id,
      limit: 100,
    );
    try {
      // Subscribe before replay; membership changes also wake this stream.
      var batch = await pending();
      while (true) {
        await DriveAccess.require(session, driveId);
        for (final message in batch) {
          cursor = message.id!;
          yield message;
        }
        if (batch.length == 100) {
          batch = await pending();
          continue;
        }
        if (!await changes.moveNext()) break;
        await DriveAccess.require(session, driveId);
        batch = await pending();
      }
    } finally {
      await changes.cancel();
    }
  }
}
