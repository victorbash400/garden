import 'dart:async';
import 'dart:typed_data';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';
import 'package:garden_server/src/generated/protocol.dart';
import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Drive filesystem', (builder, endpoints) {
    final owner = builder.copyWith(
      authentication: AuthenticationOverride.authenticationInfo('owner', {}),
    );
    final guest = builder.copyWith(
      authentication: AuthenticationOverride.authenticationInfo('guest', {}),
    );
    setUp(() {
      final session = owner.build();
      session.server.serverpod.addCloudStorage(DatabaseCloudStorage('private'));
    });

    test('permissions, hierarchy, and duplicate names are enforced', () async {
      final drive = await endpoints.garden.create(owner, 'Files');
      final folder = await endpoints.files.create(
        owner,
        drive.id,
        0,
        'Work',
        NodeKind.folder,
      );
      await endpoints.files.create(
        owner,
        drive.id,
        folder.id!,
        'notes.txt',
        NodeKind.file,
      );
      expect(
        (await endpoints.files.list(
          owner,
          drive.id,
          folder.id!,
        )).nodes.single.name,
        'notes.txt',
      );
      await expectLater(
        endpoints.files.list(guest, drive.id, 0),
        throwsA(isA<GardenException>()),
      );
      await expectLater(
        endpoints.files.create(owner, drive.id, 0, 'WORK', NodeKind.folder),
        throwsA(isA<GardenException>()),
      );
      await expectLater(
        endpoints.files.move(owner, folder.id!, folder.id!, 'Work'),
        throwsA(isA<GardenException>()),
      );
      await expectLater(
        endpoints.files.delete(owner, folder.id!),
        throwsA(isA<GardenException>()),
      );
      await expectLater(
        endpoints.files.create(owner, drive.id, 0, '../bad', NodeKind.file),
        throwsA(isA<GardenException>()),
      );
    });

    test(
      'chunks support cross-boundary reads and immutable authored versions',
      () async {
        final drive = await endpoints.garden.create(owner, 'Content');
        final node = await endpoints.files.create(
          owner,
          drive.id,
          0,
          'video.bin',
          NodeKind.file,
        );
        final bytes = Uint8List.fromList(
          List.generate(262144 + 31, (index) => index % 251),
        );
        final upload = await endpoints.content.begin(
          owner,
          node.id!,
          0,
          bytes.length,
        );
        await endpoints.content.writeChunk(
          owner,
          upload.id!,
          0,
          ByteData.sublistView(bytes, 0, 262144),
        );
        await expectLater(
          endpoints.content.finish(owner, upload.id!),
          throwsA(isA<GardenException>()),
        );
        await endpoints.content.writeChunk(
          owner,
          upload.id!,
          1,
          ByteData.sublistView(bytes, 262144),
        );
        final saved = await endpoints.content.finish(owner, upload.id!);
        final range = await endpoints.content.read(
          owner,
          node.id!,
          saved.version,
          262130,
          30,
        );
        expect(range.buffer.asUint8List(), bytes.sublist(262130, 262160));
        expect(
          (await endpoints.content.versions(owner, node.id!)).single.authorId,
          'owner',
        );
        await expectLater(
          endpoints.content.writeChunk(owner, upload.id!, 1, ByteData(31)),
          throwsA(isA<GardenException>()),
        );
        await expectLater(
          endpoints.content.read(guest, node.id!, saved.version, 0, 10),
          throwsA(isA<GardenException>()),
        );
      },
    );

    test(
      'concurrent saves preserve a conflict copy and deleted names can be reused',
      () async {
        final drive = await endpoints.garden.create(owner, 'Versions');
        final node = await endpoints.files.create(
          owner,
          drive.id,
          0,
          'notes.txt',
          NodeKind.file,
        );
        final a = await endpoints.content.begin(owner, node.id!, 0, 0);
        final b = await endpoints.content.begin(owner, node.id!, 0, 0);
        final first = await endpoints.content.finish(owner, a.id!);
        final conflict = await endpoints.content.finish(owner, b.id!);
        expect(conflict.id, isNot(first.id));
        expect(conflict.name, contains('conflict'));
        await endpoints.files.delete(owner, node.id!);
        final replacement = await endpoints.files.create(
          owner,
          drive.id,
          0,
          'notes.txt',
          NodeKind.file,
        );
        expect(replacement.id, isNot(node.id));
      },
    );

    test(
      'lease prevents another member saving and comments are persisted',
      () async {
        final drive = await endpoints.garden.create(owner, 'Shared');
        await endpoints.garden.join(guest, drive.invitationCode!);
        final node = await endpoints.files.create(
          owner,
          drive.id,
          0,
          'notes.txt',
          NodeKind.file,
        );
        final lease = await endpoints.collaboration.acquire(owner, node.id!);
        await expectLater(
          endpoints.collaboration.acquire(guest, node.id!),
          throwsA(isA<GardenException>()),
        );
        final upload = await endpoints.content.begin(guest, node.id!, 0, 0);
        await expectLater(
          endpoints.content.finish(guest, upload.id!),
          throwsA(isA<GardenException>()),
        );
        await endpoints.collaboration.release(owner, node.id!, lease.token);
        await endpoints.content.finish(guest, upload.id!);
        await endpoints.collaboration.comment(guest, node.id!, 'Ready');
        expect(
          (await endpoints.collaboration.comments(owner, node.id!)).single.text,
          'Ready',
        );
      },
    );

    test(
      'invitations are owner-only and rotation invalidates the old code',
      () async {
        final drive = await endpoints.garden.create(owner, 'Invitations');
        await endpoints.garden.join(guest, drive.invitationCode!);
        await expectLater(
          endpoints.garden.invite(guest, drive.id),
          throwsA(isA<GardenException>()),
        );
        final code = await endpoints.garden.invite(owner, drive.id);
        await expectLater(
          endpoints.garden.join(guest, drive.invitationCode!),
          throwsA(isA<GardenException>()),
        );
        expect((await endpoints.garden.join(guest, code)).id, drive.id);
      },
    );
    test(
      'upload cleanup is idempotent and preserves committed versions',
      () async {
        final drive = await endpoints.garden.create(owner, 'Cleanup');
        final node = await endpoints.files.create(
          owner,
          drive.id,
          0,
          'notes.txt',
          NodeKind.file,
        );
        final pending = await endpoints.content.begin(owner, node.id!, 0, 1);
        await endpoints.content.writeChunk(owner, pending.id!, 0, ByteData(1));
        await endpoints.futureCalls.uploadCleanup.expire(owner, pending.id!);
        await endpoints.futureCalls.uploadCleanup.expire(owner, pending.id!);
        await expectLater(
          endpoints.content.finish(owner, pending.id!),
          throwsA(isA<GardenException>()),
        );
        final complete = await endpoints.content.begin(owner, node.id!, 0, 0);
        await endpoints.content.finish(owner, complete.id!);
        await endpoints.futureCalls.uploadCleanup.expire(owner, complete.id!);
        expect(
          (await endpoints.content.versions(owner, node.id!)).single.id,
          complete.id,
        );
      },
    );
    test(
      'live stream and replay are ordered and contain committed node state',
      () async {
        final drive = await endpoints.garden.create(owner, 'Events');
        final stream = StreamIterator(
          endpoints.files.watch(owner, drive.id, 0),
        );
        expect(
          await stream.moveNext().timeout(const Duration(seconds: 5)),
          isTrue,
        );
        expect(stream.current.operation, 'ready');
        final node = await endpoints.files.create(
          owner,
          drive.id,
          0,
          'notes.txt',
          NodeKind.file,
        );
        expect(
          await stream.moveNext().timeout(const Duration(seconds: 5)),
          isTrue,
        );
        expect(stream.current.node!.id, node.id);
        expect(stream.current.revision, 1);
        await stream.cancel();
        final replay = StreamIterator(
          endpoints.files.watch(owner, drive.id, 0),
        );
        expect(
          await replay.moveNext().timeout(const Duration(seconds: 5)),
          isTrue,
        );
        expect(replay.current.revision, 1);
        await replay.cancel();
      },
    );
  }, rollbackDatabase: RollbackDatabase.disabled);
}
