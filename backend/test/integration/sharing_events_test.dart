import 'dart:async';

import 'package:garden_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart'
    as auth;
import 'package:serverpod_auth_idp_server/providers/email.dart' as email;
import 'package:test/test.dart';

import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Sharing events and usage', (builder, endpoints) {
    test(
      'notifications replay and read changes stay recipient scoped',
      () async {
        final owner = builder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(
            'events-owner',
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
            email: 'events@example.com',
            passwordHash: 'unused',
          ),
        );
        final recipient = builder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(
            user.id!.toString(),
            {},
          ),
        );
        final drive = await endpoints.garden.create(owner, 'Events');
        final invitation = await endpoints.driveInvitations.invite(
          owner,
          drive.id,
          'events@example.com',
          'Viewer',
        );
        final stream = StreamIterator(
          endpoints.notifications.watch(recipient, 0),
        );
        int cursor = 0;
        try {
          expect(
            await stream.moveNext().timeout(const Duration(seconds: 5)),
            isTrue,
          );
          final notification = stream.current;
          cursor = notification.id!;
          expect(notification.invitationId, invitation.id);
          expect(notification.readAt, isNull);
          final outsiderUser = await auth.AuthUser.db.insertRow(
            owner.build(),
            auth.AuthUser(scopeNames: {}, blocked: false),
          );
          await email.EmailAccount.db.insertRow(
            owner.build(),
            email.EmailAccount(
              authUserId: outsiderUser.id!,
              email: 'unrelated-events@example.com',
              passwordHash: 'unused',
            ),
          );
          final outsider = builder.copyWith(
            authentication: AuthenticationOverride.authenticationInfo(
              outsiderUser.id!.toString(),
              {},
            ),
          );
          expect(await endpoints.notifications.list(outsider, 0), isEmpty);
          await expectLater(
            endpoints.notifications.markRead(outsider, notification.id!),
            throwsA(isA<GardenException>()),
          );
          expect(
            (await endpoints.notifications.list(recipient, 0)).single.readAt,
            isNull,
          );
          final next = stream.moveNext();
          await endpoints.notifications.markRead(recipient, notification.id!);
          expect(await next.timeout(const Duration(seconds: 5)), isTrue);
          expect(stream.current.id, notification.id);
          expect(stream.current.readAt, isNotNull);
        } finally {
          await stream.cancel();
        }
        final otherDrive = await endpoints.garden.create(owner, 'Missed event');
        final missed = await endpoints.driveInvitations.invite(
          owner,
          otherDrive.id,
          'events@example.com',
          'Viewer',
        );
        final replay = StreamIterator(
          endpoints.notifications.watch(recipient, cursor),
        );
        try {
          expect(
            await replay.moveNext().timeout(const Duration(seconds: 5)),
            isTrue,
          );
          expect(replay.current.id, greaterThan(cursor));
          expect(replay.current.invitationId, missed.id);
        } finally {
          await replay.cancel();
        }
      },
    );

    test(
      'drive usage excludes deleted nodes and hides invitations from Viewers',
      () async {
        final session = builder.build();
        final ownerUser = await auth.AuthUser.db.insertRow(
          session,
          auth.AuthUser(scopeNames: {}, blocked: false),
        );
        final viewerUser = await auth.AuthUser.db.insertRow(
          session,
          auth.AuthUser(scopeNames: {}, blocked: false),
        );
        final owner = builder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(
            ownerUser.id!.toString(),
            {},
          ),
        );
        final viewer = builder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(
            viewerUser.id!.toString(),
            {},
          ),
        );
        final drive = await endpoints.garden.create(owner, 'Usage');
        await GardenMember.db.insertRow(
          session,
          GardenMember(
            gardenId: drive.id,
            userId: viewerUser.id!.toString(),
            role: 'Viewer',
          ),
        );
        await endpoints.files.create(
          owner,
          drive.id,
          0,
          'Folder',
          NodeKind.folder,
        );
        final file = await endpoints.files.create(
          owner,
          drive.id,
          0,
          'Visible',
          NodeKind.file,
        );
        file.size = 12345;
        await FileNode.db.updateRow(session, file);
        final removed = await endpoints.files.create(
          owner,
          drive.id,
          0,
          'Deleted',
          NodeKind.file,
        );
        removed.size = 99999;
        removed.deleted = true;
        await FileNode.db.updateRow(session, removed);
        await endpoints.driveInvitations.invite(
          owner,
          drive.id,
          'pending@example.com',
          'Editor',
        );
        final own = await endpoints.driveManagement.get(owner, drive.id);
        expect(own.logicalBytes, 12345);
        expect(own.fileCount, 1);
        expect(own.folderCount, 1);
        expect(own.invitations, hasLength(1));
        final shared = await endpoints.driveManagement.get(viewer, drive.id);
        expect(shared.logicalBytes, 12345);
        expect(shared.invitations, isEmpty);
      },
    );
  }, rollbackDatabase: RollbackDatabase.disabled);
}
