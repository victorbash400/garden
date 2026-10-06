import 'package:serverpod/serverpod.dart';
import '../files/drive_access.dart';
import '../generated/protocol.dart';

class ConversationAccess {
  static Future<Conversation> require(
    Session session,
    int id, {
    Transaction? transaction,
  }) async {
    final conversation = await Conversation.db.findById(
      session,
      id,
      transaction: transaction,
    );
    if (conversation == null) {
      throw GardenException(message: 'Chat unavailable.');
    }
    await DriveAccess.require(
      session,
      conversation.gardenId,
      transaction: transaction,
    );
    final member = await ConversationMember.db.findFirstRow(
      session,
      where: (row) =>
          row.conversationId.equals(id) &
          row.userId.equals(DriveAccess.user(session)),
      transaction: transaction,
    );
    if (member == null) {
      throw GardenException(message: 'You do not have access to this chat.');
    }
    return conversation;
  }

  static Future<ConversationSummary> summary(
    Session session,
    Conversation conversation, {
    Transaction? transaction,
  }) async {
    final members = await ConversationMember.db.find(
      session,
      where: (row) => row.conversationId.equals(conversation.id),
      transaction: transaction,
    );
    final identities = await AccountUsername.db.find(
      session,
      where: (row) =>
          row.userId.inSet(members.map((member) => member.userId).toSet()),
      transaction: transaction,
    );
    return ConversationSummary(
      conversation: conversation,
      members: identities
          .map(
            (identity) => PublicIdentity(
              userId: identity.userId,
              username: identity.username,
            ),
          )
          .toList(),
    );
  }
}
