import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';
import '../files/drive_access.dart';
import '../sharing/recipient_identity.dart';
import '../sharing/account_notices.dart';
import 'inbox_journal.dart';

class InboxReads {
  InboxReads(this.events, this.notices);
  final List<InboxEvent> events;
  final List<AccountNotification> notices;
  static Future<InboxReads> record(
    Session session,
    Transaction transaction,
    int drive,
    int? conversation, {
    bool onlyAdded = false,
  }) async {
    final user = DriveAccess.user(session);
    final email = await RecipientIdentity.email(session);
    final notices = await AccountNotification.db.find(
      session,
      where: (row) =>
          row.recipientEmail.equals(email) &
          row.gardenId.equals(drive) &
          row.conversationId.equals(conversation) &
          row.kind.inSet(
            onlyAdded ? {'chatAdded'} : {'chatAdded', 'chatMessage'},
          ) &
          row.readAt.equals(null),
      transaction: transaction,
    );
    for (final notice in notices) {
      notice.readAt = DateTime.now().toUtc();
    }
    if (notices.isNotEmpty) {
      await AccountNotification.db.update(
        session,
        notices,
        transaction: transaction,
      );
    }
    return InboxReads(
      await InboxJournal.record(
        session,
        transaction,
        [user],
        drive,
        conversation,
        'read',
      ),
      notices,
    );
  }

  Future<void> publish(Session session) async {
    await InboxJournal.publish(session, events);
    for (final notice in notices) {
      await AccountNotices.publish(session, notice);
    }
  }
}
