import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';
import '../files/drive_access.dart';
import '../files/drive_journal.dart';
import '../gardens/drive_permissions.dart';
import '../inbox/inbox_journal.dart';
import '../sharing/account_notices.dart';
import 'conversation_access.dart';

class ConversationMutations {
  static Future<void> rename(Session session, int id, String title) async {
    final clean = title.trim();
    if (clean.isEmpty || clean.length > 80) {
      throw GardenException(message: 'Use a name of 1–80 characters.');
    }
    await _change(session, id, 'renamed', clean);
  }

  static Future<void> delete(Session session, int id) =>
      _change(session, id, 'deleted', null);
  static Future<void> leave(Session session, int id) =>
      _change(session, id, 'left', null);
  static Future<void> _change(
    Session session,
    int id,
    String kind,
    String? title,
  ) async {
    final original = await ConversationAccess.require(session, id);
    late List<InboxEvent> events;
    late DriveEvent event;
    List<AccountNotification> notices = [];
    await session.db.transaction((transaction) async {
      final drive = await DriveAccess.lock(
        session,
        original.gardenId,
        transaction,
        capability: DriveCapability.read,
      );
      final conversation = await ConversationAccess.require(
        session,
        id,
        transaction: transaction,
      );
      final user = DriveAccess.user(session);
      if (kind != 'left' && conversation.creatorId != user) {
        throw GardenException(
          message: 'Only the creator can rename or delete this conversation.',
        );
      }
      final members = await ConversationMember.db.find(
        session,
        where: (row) => row.conversationId.equals(id),
        transaction: transaction,
      );
      events = await InboxJournal.record(
        session,
        transaction,
        members.map((member) => member.userId),
        drive.id!,
        id,
        kind,
      );
      if (kind == 'renamed') {
        conversation.title = title!;
        await Conversation.db.updateRow(
          session,
          conversation,
          transaction: transaction,
        );
      } else if (kind == 'left' && members.length > 1) {
        conversation.directKey = null;
        if (conversation.title.isEmpty) {
          conversation.title = 'Conversation';
        }
        await Conversation.db.updateRow(
          session,
          conversation,
          transaction: transaction,
        );
        await ConversationMember.db.deleteWhere(
          session,
          where: (row) =>
              row.conversationId.equals(id) & row.userId.equals(user),
          transaction: transaction,
        );
      } else {
        await Conversation.db.deleteRow(
          session,
          conversation,
          transaction: transaction,
        );
      }
      if (kind != 'renamed') {
        notices = await AccountNotification.db.find(
          session,
          where: (row) => row.conversationId.equals(id),
          transaction: transaction,
        );
        if (kind == 'left' && members.length > 1) {
          final emails = await session.db.unsafeQuery(
            'SELECT email FROM serverpod_auth_idp_email_account WHERE "authUserId"::text = @user',
            parameters: QueryParameters.named({'user': user}),
            transaction: transaction,
          );
          final own = emails.map((row) => row.first as String).toSet();
          notices = notices
              .where((notice) => own.contains(notice.recipientEmail))
              .toList();
        }
        for (final notice in notices) {
          notice.trashedAt = DateTime.now().toUtc();
        }
        if (notices.isNotEmpty) {
          await AccountNotification.db.update(
            session,
            notices,
            transaction: transaction,
          );
        }
      }
      drive.revision++;
      await GardenRecord.db.updateRow(session, drive, transaction: transaction);
      event = await DriveEvent.db.insertRow(
        session,
        DriveEvent(
          gardenId: drive.id!,
          revision: drive.revision,
          operation: 'chat',
          authorId: user,
          createdAt: DateTime.now().toUtc(),
        ),
        transaction: transaction,
      );
    });
    await DriveJournal.publish(session, event);
    await InboxJournal.publish(session, events);
    for (final notice in notices) {
      await AccountNotices.publish(session, notice);
    }
  }
}
