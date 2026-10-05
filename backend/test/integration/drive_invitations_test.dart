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
