import 'dart:io';
import 'dart:typed_data';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';
import 'package:garden_server/src/generated/protocol.dart';
import 'test_tools/serverpod_test_tools.dart';

var sequence = 0;
FilesystemRequest operation(
  FilesystemOperation kind,
  String path, {
  String? destination,
  bool noReplace = false,
}) => FilesystemRequest(
  operationId: UuidValue.fromString(
    '00000000-0000-4000-8000-${(++sequence).toString().padLeft(12, '0')}',
  ),
  operation: kind,
  path: path,
  destination: destination,
  noReplace: noReplace,
);
Matcher failure(FilesystemError code) =>
    isA<FilesystemException>().having((error) => error.code, 'code', code);

void main() {
  withServerpod(
    'POSIX namespace',
    (builder, endpoints) {
      final owner = builder.copyWith(
        authentication: AuthenticationOverride.authenticationInfo('owner', {}),
      );
      final guest = builder.copyWith(
        authentication: AuthenticationOverride.authenticationInfo('guest', {}),
      );
      setUp(() {
        owner.build().server.serverpod.addCloudStorage(
          DatabaseCloudStorage('private'),
        );
      });

      test(
        'creation dates persist and replay without changing content identity',
        () async {
          final drive = await endpoints.garden.create(owner, 'Attributes');
          final folder = (await endpoints.filesystem.mutate(
            owner,
            drive.id,
            operation(FilesystemOperation.createFolder, '/Folder'),
          )).single.node!;
          final date = DateTime.utc(2026, 10, 4, 12, 30);
          final request = operation(
            FilesystemOperation.setAttributes,
            '/Folder',
          ).copyWith(createdAt: date);
          final event = (await endpoints.filesystem.mutate(
            owner,
            drive.id,
            request,
          )).single;
          expect(event.node!.createdAt, date);
          expect(event.node!.version, folder.version);
          expect(event.node!.updatedAt, folder.updatedAt);
          final replay = (await endpoints.filesystem.mutate(
            owner,
            drive.id,
            request,
          )).single;
          expect(replay.id, event.id);
          await expectLater(
            endpoints.filesystem.mutate(
              owner,
              drive.id,
              request.copyWith(createdAt: date.add(const Duration(seconds: 1))),
            ),
            throwsA(failure(FilesystemError.invalid)),
          );
        },
      );

      test(
        'empty directories can be removed; nonempty directories and wrong types cannot',
        () async {
          final drive = await endpoints.garden.create(owner, 'Types');
          final folder = (await endpoints.filesystem.mutate(
            owner,
            drive.id,
            operation(FilesystemOperation.createFolder, '/Empty'),
          )).single.node!;
          expect(
            (await endpoints.files.list(owner, drive.id, folder.id!)).nodes,
            isEmpty,
          );
          await endpoints.filesystem.mutate(
            owner,
            drive.id,
            operation(FilesystemOperation.createFile, '/Empty/note'),
          );
          final revision = await endpoints.files.revision(owner, drive.id);
          await expectLater(
            endpoints.filesystem.mutate(
              owner,
              drive.id,
              operation(FilesystemOperation.rmdir, '/Empty'),
            ),
            throwsA(failure(FilesystemError.notEmpty)),
          );
          await expectLater(
            endpoints.filesystem.mutate(
              owner,
              drive.id,
              operation(FilesystemOperation.unlink, '/Empty'),
            ),
            throwsA(failure(FilesystemError.isDirectory)),
          );
          await expectLater(
            endpoints.filesystem.mutate(
              owner,
              drive.id,
              operation(FilesystemOperation.rmdir, '/Empty/note'),
            ),
            throwsA(failure(FilesystemError.notDirectory)),
          );
          expect(await endpoints.files.revision(owner, drive.id), revision);
          await endpoints.filesystem.mutate(
            owner,
            drive.id,
            operation(FilesystemOperation.unlink, '/Empty/note'),
          );
          await endpoints.filesystem.mutate(
            owner,
            drive.id,
            operation(FilesystemOperation.rmdir, '/Empty'),
          );
          expect(
            (await endpoints.files.list(owner, drive.id, 0)).nodes,
            isEmpty,
          );
        },
      );

      test(
        'atomic replacement preserves source identity and replays exactly once',
        () async {
          final drive = await endpoints.garden.create(owner, 'Replace');
          final source = (await endpoints.filesystem.mutate(
            owner,
            drive.id,
            operation(FilesystemOperation.createFile, '/source'),
          )).single.node!;
          final target = (await endpoints.filesystem.mutate(
            owner,
            drive.id,
            operation(FilesystemOperation.createFile, '/target'),
          )).single.node!;
          final request = operation(
            FilesystemOperation.rename,
            '/source',
            destination: '/target',
          );
          final events = await endpoints.filesystem.mutate(
            owner,
            drive.id,
            request,
          );
          expect(events.map((event) => event.operation), ['delete', 'move']);
          expect(events.first.node!.id, target.id);
          expect(events.last.node!.id, source.id);
          expect(events.last.node!.name, 'target');
          final replay = await endpoints.filesystem.mutate(
            owner,
            drive.id,
            request,
          );
          expect(
            replay.map((event) => event.id),
            events.map((event) => event.id),
          );
          expect(await endpoints.files.revision(owner, drive.id), 4);
          expect(
            (await endpoints.files.list(owner, drive.id, 0)).nodes.single.id,
            source.id,
          );
          request.destination = '/different';
          await expectLater(
            endpoints.filesystem.mutate(owner, drive.id, request),
            throwsA(failure(FilesystemError.invalid)),
          );
          expect(await endpoints.files.revision(owner, drive.id), 4);
        },
      );

      test(
        'no-replace, folder replacement, cycle and case rename preserve invariants',
        () async {
          final drive = await endpoints.garden.create(owner, 'Folders');
          final a = (await endpoints.filesystem.mutate(
            owner,
            drive.id,
            operation(FilesystemOperation.createFolder, '/A'),
          )).single.node!;
          await endpoints.filesystem.mutate(
            owner,
            drive.id,
            operation(FilesystemOperation.createFolder, '/B'),
          );
          await endpoints.filesystem.mutate(
            owner,
            drive.id,
            operation(FilesystemOperation.createFolder, '/B/child'),
          );
          await expectLater(
            endpoints.filesystem.mutate(
              owner,
              drive.id,
              operation(
                FilesystemOperation.rename,
                '/A',
                destination: '/B',
                noReplace: true,
              ),
            ),
            throwsA(failure(FilesystemError.alreadyExists)),
          );
          await expectLater(
            endpoints.filesystem.mutate(
              owner,
              drive.id,
              operation(FilesystemOperation.rename, '/A', destination: '/B'),
            ),
            throwsA(failure(FilesystemError.notEmpty)),
          );
          await expectLater(
            endpoints.filesystem.mutate(
              owner,
              drive.id,
              operation(
                FilesystemOperation.rename,
                '/B',
                destination: '/B/child/nested',
              ),
            ),
            throwsA(failure(FilesystemError.invalid)),
          );
          await endpoints.filesystem.mutate(
            owner,
            drive.id,
            operation(FilesystemOperation.rename, '/A', destination: '/a'),
          );
          expect((await endpoints.files.get(owner, a.id!)).name, 'a');
          await endpoints.filesystem.mutate(
            owner,
            drive.id,
            operation(FilesystemOperation.rmdir, '/B/child'),
          );
          await endpoints.filesystem.mutate(
            owner,
            drive.id,
            operation(FilesystemOperation.rename, '/a', destination: '/B'),
          );
          expect(
            (await endpoints.files.list(owner, drive.id, 0)).nodes.single.id,
            a.id,
          );
        },
      );

      test(
        'replayed delete never removes a new file at the old name',
        () async {
          final drive = await endpoints.garden.create(owner, 'Replay');
          await endpoints.filesystem.mutate(
            owner,
            drive.id,
            operation(FilesystemOperation.createFile, '/name'),
          );
          final remove = operation(FilesystemOperation.unlink, '/name');
          await endpoints.filesystem.mutate(owner, drive.id, remove);
          final next = (await endpoints.filesystem.mutate(
            owner,
            drive.id,
            operation(FilesystemOperation.createFile, '/name'),
          )).single.node!;
          await endpoints.filesystem.mutate(owner, drive.id, remove);
          expect(
            (await endpoints.files.list(owner, drive.id, 0)).nodes.single.id,
            next.id,
          );
        },
      );

      test(
        'parallel requests serialize siblings and deduplicate the same operation',
        () async {
          final drive = await endpoints.garden.create(owner, 'Concurrent');
          final request = operation(FilesystemOperation.createFile, '/one');
          final results = await Future.wait([
            endpoints.filesystem.mutate(owner, drive.id, request),
            endpoints.filesystem.mutate(owner, drive.id, request),
          ]);
          expect(results.first.single.id, results.last.single.id);
          expect(await endpoints.files.revision(owner, drive.id), 1);
          final attempts = await Future.wait(
            ['Two', 'two'].map((name) async {
              try {
                await endpoints.filesystem.mutate(
                  owner,
                  drive.id,
                  operation(FilesystemOperation.createFile, '/$name'),
                );
                return true;
              } on FilesystemException catch (error) {
                expect(error.code, FilesystemError.alreadyExists);
                return false;
              }
            }),
          );
          expect(attempts.where((success) => success).length, 1);
          expect(await endpoints.files.revision(owner, drive.id), 2);
        },
      );

      test(
        'committed content remains readable after unlink while access stays enforced',
        () async {
          final drive = await endpoints.garden.create(owner, 'Handles');
          final file = (await endpoints.filesystem.mutate(
            owner,
            drive.id,
            operation(FilesystemOperation.createFile, '/data'),
          )).single.node!;
          final bytes = Uint8List.fromList([0, 1, 2, 3, 255]);
          final upload = await endpoints.content.begin(
            owner,
            file.id!,
            0,
            bytes.length,
          );
          await endpoints.content.writeChunk(
            owner,
            upload.id!,
            0,
            ByteData.sublistView(bytes),
          );
          final committed = await endpoints.content.finish(owner, upload.id!);
          await endpoints.filesystem.mutate(
            owner,
            drive.id,
            operation(FilesystemOperation.unlink, '/data'),
          );
          final read = await endpoints.content.read(
            owner,
            file.id!,
            committed.version,
            1,
            3,
          );
          expect(read.buffer.asUint8List(), [1, 2, 3]);
          await expectLater(
            endpoints.content.read(guest, file.id!, committed.version, 0, 3),
            throwsA(isA<GardenException>()),
          );
          await expectLater(
            endpoints.content.begin(owner, file.id!, committed.version, 1),
            throwsA(isA<GardenException>()),
          );
          await endpoints.garden.delete(owner, drive.id);
          await expectLater(
            endpoints.content.read(owner, file.id!, committed.version, 0, 3),
            throwsA(isA<GardenException>()),
          );
        },
      );

      test(
        'malformed paths and unauthorized operations make no changes',
        () async {
          final drive = await endpoints.garden.create(owner, 'Access');
          for (final path in [
            'relative',
            '/..',
            '/.',
            '/a//b',
            '/bad:',
            '/\u0000',
          ]) {
            await expectLater(
              endpoints.filesystem.mutate(
                owner,
                drive.id,
                operation(FilesystemOperation.createFolder, path),
              ),
              throwsA(failure(FilesystemError.invalid)),
            );
          }
          await expectLater(
            endpoints.filesystem.mutate(
              owner,
              drive.id,
              operation(FilesystemOperation.rmdir, '/'),
            ),
            throwsA(failure(FilesystemError.busy)),
          );
          await expectLater(
            endpoints.filesystem.mutate(
              guest,
              drive.id,
              operation(FilesystemOperation.createFile, '/foreign'),
            ),
            throwsA(failure(FilesystemError.accessDenied)),
          );
          await expectLater(
            endpoints.filesystem.mutate(
              owner,
              drive.id,
              operation(FilesystemOperation.createFile, '/missing/file'),
            ),
            throwsA(failure(FilesystemError.notFound)),
          );
          expect(await endpoints.files.revision(owner, drive.id), 0);
        },
      );
    },
    rollbackDatabase: RollbackDatabase.disabled,
    configOverride: (config) {
      final port = Platform.environment['GARDEN_TEST_POSTGRES_PORT'];
      if (port == null) return config;
      return config.copyWith(
        database: DatabaseConfig(
          host: 'localhost',
          port: int.parse(port),
          user: Platform.environment['GARDEN_TEST_POSTGRES_USER']!,
          password: '',
          name: config.database!.name,
        ),
      );
    },
  );
}
