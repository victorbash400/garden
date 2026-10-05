import 'package:garden_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart'
    as auth;
import 'package:serverpod_auth_idp_server/providers/email.dart' as email;
import 'package:test/test.dart';
import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Recipient-bound invitations', (builder, endpoints) {
    test(
      'duplicate, declined and downgraded-sender invitations stay closed',
      () async {
        final owner = builder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(
            'invitation-controls-owner',
            {},
          ),
        );
        final manager = builder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(
            'invitation-controls-manager',
            {},
          ),
        );
        final user = await auth.AuthUser.db.insertRow(
          owner.build(),
          auth.AuthUser(scopeNames: {}, blocked: false),
        );
        await email.EmailAccount.db.insertRow(
          owner.build(),
          email.EmailAccount(
            authUserId: user.id!,
            email: 'controls-recipient@example.com',
            passwordHash: 'test-only-unused',
          ),
        );
        final recipient = builder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(
            user.id!.toString(),
            {},
          ),
        );
        final drive = await endpoints.garden.create(
          owner,
          'Invitation controls',
        );
        await GardenMember.db.insertRow(
          owner.build(),
          GardenMember(
            gardenId: drive.id,
            userId: 'invitation-controls-manager',
            role: 'Manager',
          ),
        );
        final invitation = await endpoints.driveInvitations.invite(
          manager,
          drive.id,
          'controls-recipient@example.com',
          'Editor',
        );
        expect(invitation.deliveryStatus, 'notConfigured');
        await expectLater(
          endpoints.driveInvitations.invite(
            owner,
            drive.id,
            ' CONTROLS-RECIPIENT@EXAMPLE.COM ',
            'Viewer',
          ),
          throwsA(isA<GardenException>()),
        );
        await expectLater(
          endpoints.driveInvitations.resend(manager, invitation.id!),
          throwsA(isA<GardenException>()),
        );
        await endpoints.driveInvitations.decline(recipient, invitation.id!);
        await expectLater(
          endpoints.driveInvitations.accept(recipient, invitation.id!),
          throwsA(isA<GardenException>()),
        );
        await expectLater(
          endpoints.driveInvitations.resend(manager, invitation.id!),
          throwsA(isA<GardenException>()),
        );
        final replacement = await endpoints.driveInvitations.invite(
          manager,
          drive.id,
          'controls-recipient@example.com',
          'Viewer',
        );
        await endpoints.driveMembers.changeRole(
          owner,
          drive.id,
          'invitation-controls-manager',
          'Viewer',
        );
        await expectLater(
          endpoints.driveInvitations.accept(recipient, replacement.id!),
          throwsA(isA<GardenException>()),
        );
        await expectLater(
          endpoints.driveInvitations.resend(manager, replacement.id!),
          throwsA(isA<GardenException>()),
        );
        expect(await endpoints.garden.list(recipient), isEmpty);
        await endpoints.driveInvitations.revoke(owner, replacement.id!);
        final values = await endpoints.driveInvitations.received(recipient);
        expect(
          values.firstWhere((item) => item.id == invitation.id).declinedAt,
          isNotNull,
        );
        expect(
          values.firstWhere((item) => item.id == replacement.id).revokedAt,
          isNotNull,
        );
      },
    );
    test(
      'acceptance is email-bound, idempotent and cannot resurrect revoked access',
      () async {
        final owner = builder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(
            'invite-owner',
            {},
          ),
        );
        final user = await auth.AuthUser.db.insertRow(
          owner.build(),
          auth.AuthUser(scopeNames: {}, blocked: false),
        );
        final stranger = await auth.AuthUser.db.insertRow(
          owner.build(),
          auth.AuthUser(scopeNames: {}, blocked: false),
        );
        await email.EmailAccount.db.insertRow(
          owner.build(),
          email.EmailAccount(
            authUserId: user.id!,
            email: 'recipient@example.com',
            passwordHash: 'test-only-unused',
          ),
        );
        await email.EmailAccount.db.insertRow(
          owner.build(),
          email.EmailAccount(
            authUserId: stranger.id!,
            email: 'stranger@example.com',
            passwordHash: 'test-only-unused',
          ),
        );
        final recipient = builder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(
            user.id!.toString(),
            {},
          ),
        );
        final other = builder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(
            stranger.id!.toString(),
            {},
          ),
        );
        final drive = await endpoints.garden.create(owner, 'Shared');
        final invite = await endpoints.driveInvitations.invite(
          owner,
          drive.id,
          ' Recipient@Example.com ',
          'Viewer',
        );
        await expectLater(
          endpoints.driveInvitations.accept(other, invite.id!),
          throwsA(isA<GardenException>()),
        );
        expect(await endpoints.notifications.list(other, 0), isEmpty);
        expect(
          (await endpoints.notifications.list(
            recipient,
            0,
          )).single.invitationId,
          invite.id,
        );
        await endpoints.driveInvitations.accept(recipient, invite.id!);
        await endpoints.driveInvitations.accept(recipient, invite.id!);
        expect((await endpoints.garden.list(recipient)).single.role, 'Viewer');
        expect(
          await GardenMember.db.count(
            owner.build(),
            where: (row) => row.gardenId.equals(drive.id),
          ),
          2,
        );
        await endpoints.driveMembers.remove(
          owner,
          drive.id,
          user.id!.toString(),
        );
        await endpoints.driveInvitations.accept(recipient, invite.id!);
        expect(await endpoints.garden.list(recipient), isEmpty);
        final revoked = await endpoints.driveInvitations.invite(
          owner,
          drive.id,
          'recipient@example.com',
          'Editor',
        );
        await endpoints.driveInvitations.revoke(owner, revoked.id!);
        await expectLater(
          endpoints.driveInvitations.accept(recipient, revoked.id!),
          throwsA(isA<GardenException>()),
        );
        final expired = await endpoints.driveInvitations.invite(
          owner,
          drive.id,
          'recipient@example.com',
          'Viewer',
        );
        expired.expiresAt = DateTime.now().toUtc().subtract(
          const Duration(seconds: 1),
        );
        await DriveInvitation.db.updateRow(owner.build(), expired);
        await expectLater(
          endpoints.driveInvitations.accept(recipient, expired.id!),
          throwsA(isA<GardenException>()),
        );
      },
    );
  });
}
