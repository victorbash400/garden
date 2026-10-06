import 'package:serverpod/serverpod.dart';
import '../accounts/usernames.dart';
import '../files/drive_access.dart';
import '../gardens/drive_permissions.dart';
import '../generated/protocol.dart';
import 'conversation_access.dart';

class ConversationsEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  Future<List<ConversationSummary>> list(
    Session session,
    int driveId,
    int beforeId,
  ) async {
    await DriveAccess.require(session, driveId);
    if (beforeId < 0) throw GardenException(message: 'Invalid chat cursor.');
    final membership = await ConversationMember.db.find(
      session,
      where: (row) => row.userId.equals(DriveAccess.user(session)),
    );
    if (membership.isEmpty) return [];
    final conversations = await Conversation.db.find(
      session,
      where: (row) =>
          row.gardenId.equals(driveId) &
          row.id.inSet(
            membership.map((member) => member.conversationId).toSet(),
          ) &
          (beforeId == 0 ? Constant.bool(true) : row.id < beforeId),
      orderBy: (row) => row.id.desc(),
      limit: 100,
    );
    final members = await ConversationMember.db.find(
      session,
      where: (row) => row.conversationId.inSet(
        conversations.map((conversation) => conversation.id!).toSet(),
      ),
    );
    final identities = await AccountUsername.db.find(
      session,
      where: (row) =>
          row.userId.inSet(members.map((member) => member.userId).toSet()),
    );
    return conversations.map((conversation) {
      final ids = members
          .where((member) => member.conversationId == conversation.id)
          .map((member) => member.userId)
          .toSet();
      return ConversationSummary(
        conversation: conversation,
        members: identities
            .where((identity) => ids.contains(identity.userId))
            .map(
              (identity) => PublicIdentity(
                userId: identity.userId,
                username: identity.username,
              ),
            )
            .toList(),
      );
    }).toList();
  }

  Future<ConversationSummary> get(Session session, int id) async =>
      ConversationAccess.summary(
        session,
        await ConversationAccess.require(session, id),
      );

  Future<ConversationSummary> create(
    Session session,
    int driveId,
    List<String> recipients,
    String title,
  ) async {
    await DriveAccess.require(session, driveId);
    await Usernames.ensure(session, DriveAccess.user(session));
    return session.db.transaction((transaction) async {
      await DriveAccess.lock(
        session,
        driveId,
        transaction,
        capability: DriveCapability.read,
      );
      final user = DriveAccess.user(session);
      final ids = {...recipients, user};
      if (ids.length < 2 || ids.length > 50) {
        throw GardenException(message: 'Choose 1–49 other drive members.');
      }
      final members = await GardenMember.db.find(
        session,
        where: (row) => row.gardenId.equals(driveId) & row.userId.inSet(ids),
        transaction: transaction,
      );
      if (members.length != ids.length) {
        throw GardenException(message: 'Choose current members of this drive.');
      }
      final name = title.trim();
      if (name.length > 80) {
        throw GardenException(
          message: 'Use a group name of at most 80 characters.',
        );
      }
      final sorted = ids.toList()..sort();
      final key = ids.length == 2 ? sorted.join(':') : null;
      if (key != null) {
        final existing = await Conversation.db.findFirstRow(
          session,
          where: (row) =>
              row.gardenId.equals(driveId) & row.directKey.equals(key),
          transaction: transaction,
        );
        if (existing != null) {
          return ConversationAccess.summary(
            session,
            existing,
            transaction: transaction,
          );
        }
      }
      final conversation = await Conversation.db.insertRow(
        session,
        Conversation(
          gardenId: driveId,
          creatorId: user,
          title: ids.length == 2 ? '' : name,
          directKey: key,
          createdAt: DateTime.now().toUtc(),
        ),
        transaction: transaction,
      );
      for (final id in ids) {
        await ConversationMember.db.insertRow(
          session,
          ConversationMember(
            conversationId: conversation.id!,
            userId: id,
            readCursor: 0,
          ),
          transaction: transaction,
        );
      }
      return ConversationAccess.summary(
        session,
        conversation,
        transaction: transaction,
      );
    });
  }
}
