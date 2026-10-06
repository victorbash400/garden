import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';
import '../files/drive_access.dart';
import '../sharing/account_notices.dart';
import 'inbox_journal.dart';

class InboxDelivery {
  InboxDelivery(this.events, this.notices);
  final List<InboxEvent> events;
  final List<AccountNotification> notices;

  static Future<InboxDelivery> record(
    Session session,
    Transaction transaction,
    int drive,
    int? conversation,
    String kind,
    String title,
  ) async {
    final driveMembers = await GardenMember.db.find(
      session,
      where: (row) => row.gardenId.equals(drive),
      transaction: transaction,
    );
    var users = driveMembers.map((member) => member.userId).toSet();
    if (conversation != null) {
      final members = await ConversationMember.db.find(
        session,
        where: (row) => row.conversationId.equals(conversation),
        transaction: transaction,
      );
      users = users.intersection(
        members.map((member) => member.userId).toSet(),
      );
    }
    final events = await InboxJournal.record(
      session,
      transaction,
      users,
      drive,
      conversation,
      kind,
    );
    final recipients = users.difference({DriveAccess.user(session)});
    if (recipients.isEmpty) return InboxDelivery(events, []);
    final emails = await session.db.unsafeQuery(
      'SELECT "email" FROM "serverpod_auth_idp_email_account" '
      'WHERE "authUserId"::text = ANY(@users::text[])',
      parameters: QueryParameters.named({'users': recipients.toList()}),
      transaction: transaction,
    );
    final notices = await AccountNotification.db.insert(session, [
      for (final row in emails)
        AccountNotification(
          recipientEmail: row.first as String,
          gardenId: drive,
          conversationId: conversation,
          kind: kind,
          title: title,
          createdAt: DateTime.now().toUtc(),
        ),
    ], transaction: transaction);
    return InboxDelivery(events, notices);
  }

  Future<void> publish(Session session) async {
    await InboxJournal.publish(session, events);
    for (final notice in notices) {
      await AccountNotices.publish(session, notice);
    }
  }
}
