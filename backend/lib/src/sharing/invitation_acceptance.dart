import 'package:serverpod/serverpod.dart';
import '../files/drive_access.dart';
import '../gardens/drive_permissions.dart';
import '../generated/protocol.dart';
import 'recipient_identity.dart';
import 'account_notices.dart';
import 'member_change.dart';

class InvitationAcceptance {
  static Future<void> accept(Session session, int invitationId) async {
    final email = await RecipientIdentity.email(session);
    final original = await DriveInvitation.db.findById(session, invitationId);
    if (original == null || original.recipientEmail != email) {
      throw GardenException(
        message: 'This invitation is unavailable for your account.',
      );
    }
    MemberChange? change;
    await session.db.transaction((transaction) async {
      final drive = await GardenRecord.db.findById(
        session,
        original.gardenId,
        transaction: transaction,
        lockMode: LockMode.forUpdate,
      );
      final invite = await DriveInvitation.db.findById(
        session,
        invitationId,
        transaction: transaction,
        lockMode: LockMode.forUpdate,
      );
      if (drive == null ||
          drive.deleted ||
          invite == null ||
          invite.recipientEmail != email) {
        throw GardenException(message: 'This invitation is unavailable.');
      }
      if (invite.acceptedBy == DriveAccess.user(session)) return;
      pending(invite);
      final inviter = await GardenMember.db.findFirstRow(
        session,
        where: (row) =>
            row.gardenId.equals(invite.gardenId) &
            row.userId.equals(invite.inviterId),
        transaction: transaction,
      );
      if (inviter == null ||
          !DriveRole.parse(
            inviter.role,
          ).canManage(DriveRole.parse(invite.role))) {
        throw GardenException(
          message: 'The sender no longer has permission to invite you.',
        );
      }
      final existing = await GardenMember.db.findFirstRow(
        session,
        where: (row) =>
            row.gardenId.equals(drive.id!) &
            row.userId.equals(DriveAccess.user(session)),
        transaction: transaction,
      );
      if (existing == null) {
        await GardenMember.db.insertRow(
          session,
          GardenMember(
            gardenId: drive.id!,
            userId: DriveAccess.user(session),
            role: DriveRole.parse(invite.role).label,
          ),
          transaction: transaction,
        );
      }
      if (existing == null) {
        change = await MemberChange.record(session, drive, transaction, {
          DriveAccess.user(session): '${invite.role} access granted',
          drive.ownerId: 'Member joined',
        });
      }
      invite.acceptedAt = DateTime.now().toUtc();
      invite.acceptedBy = DriveAccess.user(session);
      await DriveInvitation.db.updateRow(
        session,
        invite,
        transaction: transaction,
      );
    });
    await change?.publish(session);
    await AccountNotices.invitationChanged(session, invitationId);
  }

  static Future<void> decline(Session session, int invitationId) async {
    final email = await RecipientIdentity.email(session);
    List<AccountNotification> updates = [];
    await session.db.transaction((transaction) async {
      final invite = await DriveInvitation.db.findById(
        session,
        invitationId,
        transaction: transaction,
        lockMode: LockMode.forUpdate,
      );
      if (invite == null || invite.recipientEmail != email) {
        throw GardenException(message: 'This invitation is unavailable.');
      }
      pending(invite);
      invite.declinedAt = DateTime.now().toUtc();
      await DriveInvitation.db.updateRow(
        session,
        invite,
        transaction: transaction,
      );
      updates = await AccountNotices.recordInvitationStatus(
        session,
        invite,
        transaction,
      );
    });
    await AccountNotices.invitationChanged(session, invitationId);
    for (final notice in updates) {
      await AccountNotices.publish(session, notice);
    }
  }

  static void pending(DriveInvitation invite) {
    if (invite.acceptedAt != null ||
        invite.declinedAt != null ||
        invite.revokedAt != null ||
        !invite.expiresAt.isAfter(DateTime.now().toUtc())) {
      throw GardenException(
        message: 'This invitation has expired or is no longer pending.',
      );
    }
  }
}
