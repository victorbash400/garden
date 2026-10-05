import 'package:garden_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';
import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Drive member administration', (builder, endpoints) {
    test('Manager cannot promote, remove or change administrators', () async {
      final owner = builder.copyWith(
        authentication: AuthenticationOverride.authenticationInfo(
          'admin-owner',
          {},
        ),
      );
      final manager = builder.copyWith(
        authentication: AuthenticationOverride.authenticationInfo(
          'admin-manager',
          {},
        ),
      );
      final drive = await endpoints.garden.create(owner, 'Membership');
      for (final entry in {
        'admin-manager': 'Manager',
        'admin-other-manager': 'Manager',
        'admin-editor': 'Editor',
      }.entries) {
        await GardenMember.db.insertRow(
          owner.build(),
          GardenMember(
            gardenId: drive.id,
            userId: entry.key,
            role: entry.value,
          ),
        );
      }
      await endpoints.driveMembers.changeRole(
        manager,
        drive.id,
        'admin-editor',
        'Viewer',
      );
      for (final target in [
        'admin-owner',
        'admin-manager',
        'admin-other-manager',
      ]) {
        await expectLater(
          endpoints.driveMembers.changeRole(
            manager,
            drive.id,
            target,
            'Viewer',
          ),
          throwsA(isA<GardenException>()),
        );
        await expectLater(
          endpoints.driveMembers.remove(manager, drive.id, target),
          throwsA(isA<GardenException>()),
        );
      }
      await expectLater(
        endpoints.driveMembers.changeRole(
          manager,
          drive.id,
          'admin-editor',
          'Manager',
        ),
        throwsA(isA<GardenException>()),
      );
      await expectLater(
        endpoints.driveMembers.leave(owner, drive.id),
        throwsA(isA<GardenException>()),
      );
      expect(
        await endpoints.driveMembers.accessRole(manager, drive.id),
        'Manager',
      );
      await endpoints.driveMembers.remove(manager, drive.id, 'admin-editor');
      final revoked = builder.copyWith(
        authentication: AuthenticationOverride.authenticationInfo(
          'admin-editor',
          {},
        ),
      );
      expect(
        await endpoints.driveMembers.accessRole(revoked, drive.id),
        isNull,
      );
      await expectLater(
        endpoints.files.list(revoked, drive.id, 0),
        throwsA(isA<GardenException>()),
      );
      expect(
        (await endpoints.files.changes(
          owner,
          drive.id,
          0,
        )).map((event) => event.operation),
        ['permissions', 'permissions'],
      );
    });
    test(
      'ownership transfer is atomic and the previous owner can leave',
      () async {
        final owner = builder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(
            'transfer-owner',
            {},
          ),
        );
        final member = builder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(
            'transfer-member',
            {},
          ),
        );
        final drive = await endpoints.garden.create(owner, 'Transfer');
        await GardenMember.db.insertRow(
          owner.build(),
          GardenMember(
            gardenId: drive.id,
            userId: 'transfer-member',
            role: 'Viewer',
          ),
        );
        await expectLater(
          endpoints.driveMembers.transferOwnership(
            member,
            drive.id,
            'transfer-owner',
          ),
          throwsA(isA<GardenException>()),
        );
        await expectLater(
          endpoints.driveMembers.transferOwnership(owner, drive.id, 'missing'),
          throwsA(isA<GardenException>()),
        );
        expect((await endpoints.garden.connect(owner, drive.id)).role, 'Owner');
        await endpoints.driveMembers.transferOwnership(
          owner,
          drive.id,
          'transfer-member',
        );
        expect(
          (await endpoints.garden.connect(owner, drive.id)).role,
          'Manager',
        );
        expect(
          (await endpoints.garden.connect(member, drive.id)).role,
          'Owner',
        );
        await expectLater(
          endpoints.garden.rename(owner, drive.id, 'Denied'),
          throwsA(isA<GardenException>()),
        );
        await endpoints.garden.rename(member, drive.id, 'Transferred');
        await endpoints.driveMembers.leave(owner, drive.id);
        await expectLater(
          endpoints.files.list(owner, drive.id, 0),
          throwsA(isA<GardenException>()),
        );
      },
    );
  });
}
