import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';

class AccountNotices {
  static String channel(String email) =>
      'notifications_${sha256.convert(utf8.encode(email))}';

  static Future<void> publish(Session session, AccountNotification notice) =>
      session.messages.postMessage(channel(notice.recipientEmail), notice);

  static Future<void> invitationChanged(
    Session session,
    int invitationId,
  ) async {
    final notice = await AccountNotification.db.findFirstRow(
      session,
      where: (row) => row.invitationId.equals(invitationId),
    );
    if (notice != null) await publish(session, notice);
  }

  static Future<List<AccountNotification>> recordInvitationStatus(
    Session session,
    DriveInvitation invitation,
    Transaction transaction,
  ) async {
    final drive = await GardenRecord.db.findById(
      session,
      invitation.gardenId,
      transaction: transaction,
    );
    if (drive == null) return [];
    final identities = await session.db.unsafeQuery(
      '''SELECT "email" FROM "serverpod_auth_idp_email_account"
         WHERE "authUserId"::text = @user''',
      parameters: QueryParameters.named({'user': invitation.inviterId}),
      transaction: transaction,
    );
    final status = invitation.declinedAt != null ? 'declined' : 'revoked';
    final updates = <AccountNotification>[];
    for (final identity in identities) {
      final update = await AccountNotification.db.insertRow(
        session,
        AccountNotification(
          recipientEmail: identity.single as String,
          gardenId: invitation.gardenId,
          kind: 'invitationUpdated',
          title: '${drive.name} · Invitation $status',
          createdAt: DateTime.now().toUtc(),
        ),
        transaction: transaction,
      );
      updates.add(update);
    }
    return updates;
  }
}
