import 'dart:typed_data';
import 'package:garden_server/src/gardens/drive_permissions.dart';
import 'package:garden_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';
import 'test_tools/serverpod_test_tools.dart';

void main() {
  test('role matrix rejects unknown roles and protects administrators', () {
    expect(DriveRole.viewer.allows(DriveCapability.read), isTrue);
    expect(DriveRole.viewer.allows(DriveCapability.write), isFalse);
    expect(DriveRole.editor.allows(DriveCapability.manageMembers), isFalse);
    expect(DriveRole.manager.canManage(DriveRole.viewer), isTrue);
    expect(DriveRole.manager.canManage(DriveRole.manager), isFalse);
    expect(DriveRole.owner.canManage(DriveRole.owner), isFalse);
    expect(() => DriveRole.parse('Unknown'), throwsA(isA<GardenException>()));
  });

  withServerpod('Drive role enforcement', (builder, endpoints) {
    var sequence = 0;
    test(
      'Viewer can browse empty folders but cannot mutate or upload',
      () async {
        final owner = builder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(
            'role-owner-${sequence++}',
            {},
          ),
        );
        final viewer = builder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(
            'role-viewer-${sequence++}',
            {},
          ),
        );
        final drive = await endpoints.garden.create(owner, 'Read only');
        await GardenMember.db.insertRow(
          owner.build(),
          GardenMember(
            gardenId: drive.id,
            userId: viewer.build().authenticated!.userIdentifier,
            role: 'Viewer',
          ),
        );
        final folder = await endpoints.files.create(
          owner,
          drive.id,
          0,
          'Empty',
          NodeKind.folder,
        );
        final file = await endpoints.files.create(
          owner,
          drive.id,
          0,
          'Read.txt',
          NodeKind.file,
        );
        expect(
          (await endpoints.files.list(viewer, drive.id, folder.id!)).nodes,
          isEmpty,
        );
        expect(
          await endpoints.files.revision(viewer, drive.id),
          greaterThan(0),
        );
        await expectLater(
          endpoints.files.create(
            viewer,
            drive.id,
            0,
            'Denied',
            NodeKind.folder,
          ),
          throwsA(isA<GardenException>()),
        );
        await expectLater(
          endpoints.files.move(viewer, file.id!, 0, 'Changed.txt'),
          throwsA(isA<GardenException>()),
        );
        await expectLater(
          endpoints.files.delete(viewer, file.id!),
          throwsA(isA<GardenException>()),
        );
        await expectLater(
          endpoints.content.begin(viewer, file.id!, 0, 1),
          throwsA(isA<GardenException>()),
        );
        await expectLater(
          endpoints.collaboration.acquire(viewer, file.id!),
          throwsA(isA<GardenException>()),
        );
        await expectLater(
          endpoints.collaboration.comment(viewer, file.id!, 'Denied'),
          throwsA(isA<GardenException>()),
        );
        await expectLater(
          endpoints.filesystem.mutate(
            viewer,
            drive.id,
            FilesystemRequest(
              operationId: Uuid().v4obj(),
              operation: FilesystemOperation.createFile,
              path: '/Denied.txt',
            ),
          ),
          throwsA(isA<FilesystemException>()),
        );
      },
    );

    test(
      'downgrade blocks an upload that began with Editor permission',
      () async {
        final owner = builder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(
            'role-owner-${sequence++}',
            {},
          ),
        );
        final editor = builder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(
            'role-editor-${sequence++}',
            {},
          ),
        );
        final drive = await endpoints.garden.create(owner, 'Downgrade');
        final member = await GardenMember.db.insertRow(
          owner.build(),
          GardenMember(
            gardenId: drive.id,
            userId: editor.build().authenticated!.userIdentifier,
            role: 'Editor',
          ),
        );
        final file = await endpoints.files.create(
          editor,
          drive.id,
          0,
          'Pending.txt',
          NodeKind.file,
        );
        final upload = await endpoints.content.begin(editor, file.id!, 0, 1);
        member.role = 'Viewer';
        await GardenMember.db.updateRow(owner.build(), member);
        await expectLater(
          endpoints.content.writeChunk(editor, upload.id!, 0, ByteData(1)),
          throwsA(isA<GardenException>()),
        );
        await expectLater(
          endpoints.content.finish(editor, upload.id!),
          throwsA(isA<GardenException>()),
        );
        expect((await endpoints.files.get(owner, file.id!)).version, 0);
      },
    );
  });
}
