import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';
import 'package:garden_server/src/generated/protocol.dart';
import 'test_tools/serverpod_test_tools.dart';
import 'package:garden_server/src/files/upload_cleanup_route.dart';

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

    test('rename preserves files and is owner-only', () async {
      final drive = await endpoints.garden.create(owner, 'Original');
      await endpoints.garden.join(guest, drive.invitationCode!);
      final node = await endpoints.files.create(
        owner,
        drive.id,
        0,
        'Keep.txt',
        NodeKind.file,
      );
      await expectLater(
        endpoints.garden.rename(guest, drive.id, 'Denied'),
        throwsA(isA<GardenException>()),
      );
      await expectLater(
        endpoints.garden.rename(owner, drive.id, ' '),
        throwsA(isA<GardenException>()),
      );
      await endpoints.garden.rename(owner, drive.id, 'Renamed');
      expect((await endpoints.garden.list(owner)).single.name, 'Renamed');
      expect((await endpoints.garden.list(guest)).single.name, 'Renamed');
      expect(
        (await endpoints.files.list(owner, drive.id, 0)).nodes.single.id,
        node.id,
      );
    });

    test(
      'drive deletion is owner-only, hides membership and blocks files',
      () async {
        final drive = await endpoints.garden.create(owner, 'Disposable');
        await endpoints.garden.join(guest, drive.invitationCode!);
        final node = await endpoints.files.create(
          owner,
          drive.id,
          0,
          'Keep.txt',
          NodeKind.file,
        );
        await expectLater(
          endpoints.garden.delete(guest, drive.id),
          throwsA(isA<GardenException>()),
        );
        await endpoints.garden.delete(owner, drive.id);
        expect(await endpoints.garden.list(owner), isEmpty);
        expect(await endpoints.garden.list(guest), isEmpty);
        await expectLater(
          endpoints.files.list(owner, drive.id, 0),
          throwsA(isA<GardenException>()),
        );
        await expectLater(
          endpoints.garden.connect(guest, drive.id),
          throwsA(isA<GardenException>()),
        );
        expect(await FileNode.db.findById(owner.build(), node.id!), isNotNull);
      },
    );

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
      await endpoints.files.delete(owner, folder.id!);
      expect((await endpoints.files.list(owner, drive.id, 0)).nodes, isEmpty);
      await expectLater(
        endpoints.files.list(owner, drive.id, folder.id!),
        throwsA(isA<GardenException>()),
      );
      await expectLater(
        endpoints.files.create(owner, drive.id, 0, '../bad', NodeKind.file),
        throwsA(isA<GardenException>()),
      );
    });

    test('Finder pages directories and records both sides of a move', () async {
      final drive = await endpoints.garden.create(owner, 'Finder');
      final first = await endpoints.files.create(
        owner,
        drive.id,
        0,
        'First',
        NodeKind.folder,
      );
      final second = await endpoints.files.create(
        owner,
        drive.id,
        0,
        'Second',
        NodeKind.folder,
      );
      final file = await endpoints.files.create(
        owner,
        drive.id,
        first.id!,
        'note.txt',
        NodeKind.file,
      );
      expect(await endpoints.files.revision(owner, drive.id), 3);
      expect(
        (await endpoints.files.listPage(
          owner,
          drive.id,
          0,
          0,
        )).map((node) => node.name),
        ['First', 'Second'],
      );
      expect(
        (await endpoints.files.listPage(
          owner,
          drive.id,
          0,
          first.id!,
        )).single.id,
        second.id,
      );
      await endpoints.files.move(owner, file.id!, second.id!, 'renamed.txt');
      final events = await endpoints.files.changes(owner, drive.id, 3);
      expect(events.single.previousParentId, first.id);
      expect(events.single.node?.parentId, second.id);
      await endpoints.files.delete(owner, second.id!);
      expect(
        (await endpoints.files.snapshot(
          owner,
          drive.id,
          0,
        )).map((node) => node.id),
        [first.id],
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
      'cleanup callback rejects invalid credentials and premature expiry',
      () async {
        final drive = await endpoints.garden.create(owner, 'Task cleanup');
        final node = await endpoints.files.create(
          owner,
          drive.id,
          0,
          'task.txt',
          NodeKind.file,
        );
        final pending = await endpoints.content.begin(owner, node.id!, 0, 1);
        await endpoints.content.writeChunk(owner, pending.id!, 0, ByteData(1));
        final session = owner.build();
        final route = UploadCleanupRoute('test-cleanup-token');
        Future<int> call(String token) async =>
            (await route.handleCall(
                      session,
                      _CleanupRequest(token, '${pending.id}'),
                    )
                    as Response)
                .statusCode;
        expect(await call('wrong-token'), 401);
        expect(await call('test-cleanup-token'), 409);
        final version = await FileVersion.db.findById(session, pending.id!);
        version!.createdAt = DateTime.now().toUtc().subtract(
          const Duration(days: 2),
        );
        await FileVersion.db.updateRow(session, version);
        expect(await call('test-cleanup-token'), 200);
        expect(await call('test-cleanup-token'), 200);
        expect(await FileVersion.db.findById(session, pending.id!), isNull);
        await session.close();
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

class _CleanupRequest implements Request {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
  final String token;
  final String value;
  _CleanupRequest(this.token, this.value);
  @override
  Headers get headers => Headers.fromMap({
    'authorization': ['Bearer $token'],
  });
  @override
  Future<String> readAsString({Encoding? encoding, int? maxLength}) async =>
      value;
}
