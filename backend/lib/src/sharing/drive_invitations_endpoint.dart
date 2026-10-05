import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/providers/email.dart';
import '../files/drive_access.dart';
import '../gardens/drive_permissions.dart';
import '../generated/protocol.dart';
import 'recipient_identity.dart';
import 'invitation_mailer.dart';
import 'invitation_acceptance.dart';
import 'account_notices.dart';

class DriveInvitationsEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  Future<DriveInvitation> invite(
    Session session,
    int gardenId,
    String email,
    String role,
  ) async {
    final recipient = RecipientIdentity.normalize(email);
    final proposed = DriveRole.parse(role);
    late AccountNotification notice;
    final invitation = await session.db.transaction((transaction) async {
      final drive = await DriveAccess.lock(
        session,
        gardenId,
        transaction,
        capability: DriveCapability.manageMembers,
      );
      final actor = await GardenMember.db.findFirstRow(
        session,
        where: (row) =>
            row.gardenId.equals(gardenId) &
            row.userId.equals(DriveAccess.user(session)),
        transaction: transaction,
      );
      if (!DriveRole.parse(actor!.role).canManage(proposed)) {
        throw GardenException(message: 'You cannot invite this role.');
      }
      final account = await EmailAccount.db.findFirstRow(
        session,
        where: (row) => row.email.equals(recipient),
        transaction: transaction,
      );
      if (account != null &&
          await GardenMember.db.findFirstRow(
                session,
                where: (row) =>
                    row.gardenId.equals(gardenId) &
                    row.userId.equals(account.authUserId.toString()),
                transaction: transaction,
              ) !=
              null) {
        throw GardenException(
          message: 'This account is already a drive member.',
        );
      }
      final now = DateTime.now().toUtc();
      final pending = await DriveInvitation.db.find(
        session,
        where: (row) =>
            row.gardenId.equals(gardenId) &
            row.recipientEmail.equals(recipient) &
            row.acceptedAt.equals(null) &
            row.declinedAt.equals(null) &
            row.revokedAt.equals(null),
        transaction: transaction,
      );
      if (pending.any((invite) => invite.expiresAt.isAfter(now))) {
        throw GardenException(
          message: 'An invitation is already pending for this email.',
        );
      }
      final invite = await DriveInvitation.db.insertRow(
        session,
        DriveInvitation(
          gardenId: gardenId,
          inviterId: DriveAccess.user(session),
          recipientEmail: recipient,
          role: proposed.label,
          deliveryStatus: 'notConfigured',
          createdAt: now,
          expiresAt: now.add(const Duration(days: 7)),
        ),
        transaction: transaction,
      );
      notice = await AccountNotification.db.insertRow(
        session,
        AccountNotification(
          recipientEmail: recipient,
          gardenId: gardenId,
          invitationId: invite.id!,
          kind: 'invitation',
          title: drive.name,
          createdAt: now,
        ),
        transaction: transaction,
      );
      return invite;
    });
    await AccountNotices.publish(session, notice);
    final drive = await GardenRecord.db.findById(session, gardenId);
    final sent = await InvitationMailer.send(session, invitation, drive!.name);
    await AccountNotices.invitationChanged(session, invitation.id!);
    return sent;
  }

  Future<List<DriveInvitation>> received(Session session) async {
    final email = await RecipientIdentity.email(session);
    return DriveInvitation.db.find(
      session,
      where: (row) => row.recipientEmail.equals(email),
      orderBy: (row) => row.createdAt.desc(),
      limit: 200,
    );
  }

  Future<void> accept(Session session, int invitationId) =>
      InvitationAcceptance.accept(session, invitationId);

  Future<void> decline(Session session, int invitationId) =>
      InvitationAcceptance.decline(session, invitationId);

  Future<DriveInvitation> resend(Session session, int invitationId) async {
    final original = await DriveInvitation.db.findById(session, invitationId);
    if (original == null) {
      throw GardenException(message: 'This invitation is unavailable.');
    }
    final invitation = await session.db.transaction((transaction) async {
      await DriveAccess.lock(
        session,
        original.gardenId,
        transaction,
        capability: DriveCapability.manageMembers,
      );
      final actor = await GardenMember.db.findFirstRow(
        session,
        where: (row) =>
            row.gardenId.equals(original.gardenId) &
            row.userId.equals(DriveAccess.user(session)),
        transaction: transaction,
      );
      final invite = await DriveInvitation.db.findById(
        session,
        invitationId,
        transaction: transaction,
        lockMode: LockMode.forUpdate,
      );
      if (invite == null ||
          !DriveRole.parse(
            actor!.role,
          ).canManage(DriveRole.parse(invite.role))) {
        throw GardenException(message: 'You cannot resend this invitation.');
      }
      InvitationAcceptance.pending(invite);
      if (invite.createdAt.isAfter(
        DateTime.now().toUtc().subtract(const Duration(minutes: 1)),
      )) {
        throw GardenException(
          message: 'Wait a minute before resending this invitation.',
        );
      }
      invite.createdAt = DateTime.now().toUtc();
      invite.expiresAt = invite.createdAt.add(const Duration(days: 7));
      invite.deliveryStatus = 'queued';
      return DriveInvitation.db.updateRow(
        session,
        invite,
        transaction: transaction,
      );
    });
    final drive = await GardenRecord.db.findById(session, original.gardenId);
    final sent = await InvitationMailer.send(session, invitation, drive!.name);
    await AccountNotices.invitationChanged(session, invitation.id!);
    return sent;
  }

  Future<void> revoke(Session session, int invitationId) async {
    final original = await DriveInvitation.db.findById(session, invitationId);
    if (original == null) {
      throw GardenException(message: 'This invitation is unavailable.');
    }
    List<AccountNotification> updates = [];
    await session.db.transaction((transaction) async {
      await DriveAccess.lock(
        session,
        original.gardenId,
        transaction,
        capability: DriveCapability.manageMembers,
      );
      final actor = await GardenMember.db.findFirstRow(
        session,
        where: (row) =>
            row.gardenId.equals(original.gardenId) &
            row.userId.equals(DriveAccess.user(session)),
        transaction: transaction,
      );
      final invite = await DriveInvitation.db.findById(
        session,
        invitationId,
        transaction: transaction,
        lockMode: LockMode.forUpdate,
      );
      if (invite == null ||
          !DriveRole.parse(
            actor!.role,
          ).canManage(DriveRole.parse(invite.role))) {
        throw GardenException(message: 'You cannot revoke this invitation.');
      }
      InvitationAcceptance.pending(invite);
      invite.revokedAt = DateTime.now().toUtc();
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
}
