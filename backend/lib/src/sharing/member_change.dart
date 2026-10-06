import 'package:serverpod/serverpod.dart';

import '../files/drive_access.dart';
import '../files/drive_journal.dart';
import '../generated/protocol.dart';
import 'account_notices.dart';
import '../inbox/inbox_journal.dart';

class MemberChange {
  MemberChange(this.event, this.notices, this.inbox);
  final List<InboxEvent> inbox;
  final DriveEvent event;
  final List<AccountNotification> notices;

  static Future<MemberChange> record(
    Session session,
    GardenRecord drive,
    Transaction transaction,
    Map<String, String> affected,
  ) async {
    drive.revision++;
    await GardenRecord.db.updateRow(session, drive, transaction: transaction);
    final event = await DriveEvent.db.insertRow(
      session,
      DriveEvent(
        gardenId: drive.id!,
        revision: drive.revision,
        operation: 'permissions',
        authorId: DriveAccess.user(session),
        createdAt: DateTime.now().toUtc(),
      ),
      transaction: transaction,
    );
    final notices = <AccountNotification>[];
    for (final entry in affected.entries) {
      final identities = await session.db.unsafeQuery(
        '''SELECT "email" FROM "serverpod_auth_idp_email_account"
           WHERE "authUserId"::text = @user''',
        parameters: QueryParameters.named({'user': entry.key}),
        transaction: transaction,
      );
      for (final identity in identities) {
        notices.add(
          await AccountNotification.db.insertRow(
            session,
            AccountNotification(
              recipientEmail: identity.single as String,
              gardenId: drive.id,
              kind: 'accessChanged',
              title: '${drive.name} · ${entry.value}',
              createdAt: event.createdAt,
            ),
            transaction: transaction,
          ),
        );
      }
    }
    return MemberChange(
      event,
      notices,
      await InboxJournal.record(
        session,
        transaction,
        affected.keys,
        drive.id!,
        null,
        'access',
      ),
    );
  }

  Future<void> publish(Session session) async {
    await DriveJournal.publish(session, event);
    await InboxJournal.publish(session, inbox);
    for (final notice in notices) {
      await AccountNotices.publish(session, notice);
    }
  }
}
