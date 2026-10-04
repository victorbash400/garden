import 'dart:io';
import 'dart:typed_data';

import 'package:garden_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';

import 'test_tools/serverpod_test_tools.dart';

UuidValue identifier() => UuidValue.fromString(const Uuid().v4());

void main() {
  withServerpod(
    'Durable edit uploads',
    (builder, endpoints) {
      final owner = builder.copyWith(
        authentication: AuthenticationOverride.authenticationInfo('owner', {}),
      );
      final other = builder.copyWith(
        authentication: AuthenticationOverride.authenticationInfo('other', {}),
      );
      setUp(
        () => owner.build().server.serverpod.addCloudStorage(
          DatabaseCloudStorage('private'),
        ),
      );

      Future<FileNode> file(String name) async {
        final drive = await endpoints.garden.create(owner, name);
        return (await endpoints.filesystem.mutate(
          owner,
          drive.id,
          FilesystemRequest(
            operationId: identifier(),
            operation: FilesystemOperation.createFile,
            path: '/Edit.bin',
          ),
        )).single.node!;
      }

      test(
        'edits preserve modification time and file attributes through publication',
        () async {
          final node = await file('Edit metadata');
          final stored = await endpoints.files.get(owner, node.id!);
          await endpoints.filesystem.mutate(
            owner,
            stored.gardenId,
            FilesystemRequest(
              operationId: identifier(),
              operation: FilesystemOperation.setExtendedAttribute,
              path: '/' + stored.name,
              attributeName: 'com.apple.FinderInfo',
              attributeValue: 'AQ==',
            ),
          );
          final date = DateTime.utc(2025, 1, 2, 3, 4, 5);
          final operation = identifier();
          final upload = await endpoints.content.beginEdit(
            owner,
            node.id!,
            node.version,
            0,
            operation,
            modifiedAt: date,
          );
          final committed = await endpoints.content.finish(owner, upload.id!);
          expect(committed.updatedAt, date);
          expect(committed.attributes!.extended, {
            'com.apple.FinderInfo': 'AQ==',
          });
          expect(
            (await endpoints.content.beginEdit(
              owner,
              node.id!,
              node.version,
              0,
              operation,
              modifiedAt: date,
            )).id,
            upload.id,
          );
          await expectLater(
            endpoints.content.beginEdit(
              owner,
              node.id!,
              node.version,
              0,
              operation,
              modifiedAt: date.add(const Duration(seconds: 1)),
            ),
            throwsA(isA<GardenException>()),
          );
        },
      );

      test(
        'parallel retries deduplicate one edit while different edits stay separate',
        () async {
          final node = await file('Identity');
          final id = identifier();
          final retries = await Future.wait([
            endpoints.content.beginEdit(owner, node.id!, 0, 1, id),
            endpoints.content.beginEdit(owner, node.id!, 0, 1, id),
          ]);
          expect(retries[0].id, retries[1].id);
          final separate = await endpoints.content.beginEdit(
            owner,
            node.id!,
            0,
            1,
            identifier(),
          );
          expect(separate.id, isNot(retries[0].id));
          await expectLater(
            endpoints.content.beginEdit(owner, node.id!, 0, 2, id),
            throwsA(isA<GardenException>()),
          );
          await expectLater(
            endpoints.content.beginEdit(other, node.id!, 0, 1, id),
            throwsA(isA<GardenException>()),
          );
        },
      );

      test(
        'committed edits and parallel finish replay without another revision',
        () async {
          final node = await file('Commit');
          final id = identifier();
          final upload = await endpoints.content.beginEdit(
            owner,
            node.id!,
            0,
            3,
            id,
          );
          await endpoints.content.writeChunk(
            owner,
            upload.id!,
            0,
            ByteData.sublistView(Uint8List.fromList([4, 5, 6])),
          );
          final completed = await Future.wait([
            endpoints.content.finish(owner, upload.id!),
            endpoints.content.finish(owner, upload.id!),
          ]);
          expect(completed[0].version, completed[1].version);
          expect(await endpoints.files.revision(owner, node.gardenId), 2);
          final replay = await endpoints.content.beginEdit(
            owner,
            node.id!,
            0,
            3,
            id,
          );
          expect(replay.committed, isTrue);
          expect(replay.id, upload.id);
          expect(
            (await endpoints.content.read(
              owner,
              node.id!,
              upload.id!,
              0,
              3,
            )).buffer.asUint8List(),
            [4, 5, 6],
          );
        },
      );

      test(
        'conflict publication preserves its original request identity',
        () async {
          final node = await file('Conflict');
          final first = await endpoints.content.beginEdit(
            owner,
            node.id!,
            0,
            1,
            identifier(),
          );
          final conflictId = identifier();
          final second = await endpoints.content.beginEdit(
            owner,
            node.id!,
            0,
            1,
            conflictId,
          );
          for (final upload in [first, second]) {
            await endpoints.content.writeChunk(
              owner,
              upload.id!,
              0,
              ByteData.sublistView(
                Uint8List.fromList([upload == first ? 1 : 2]),
              ),
            );
          }
          await endpoints.content.finish(owner, first.id!);
          final conflict = await endpoints.content.finish(owner, second.id!);
          expect(conflict.id, isNot(node.id));
          final replay = await endpoints.content.beginEdit(
            owner,
            node.id!,
            0,
            1,
            conflictId,
          );
          expect(replay.id, second.id);
          expect(replay.nodeId, conflict.id);
          expect(replay.committed, isTrue);
        },
      );

      test(
        'expired pending uploads get fresh storage without mixing identities',
        () async {
          final node = await file('Expired');
          final id = identifier();
          final stale = await endpoints.content.beginEdit(
            owner,
            node.id!,
            0,
            1,
            id,
          );
          await FileVersion.db.updateRow(
            owner.build(),
            stale.copyWith(
              createdAt: DateTime.now().toUtc().subtract(
                const Duration(hours: 24),
              ),
            ),
          );
          final resumed = await endpoints.content.beginEdit(
            owner,
            node.id!,
            0,
            1,
            id,
          );
          expect(resumed.id, isNot(stale.id));
          expect(resumed.operationId, id);
          final abandoned = await FileVersion.db.findById(
            owner.build(),
            stale.id!,
          );
          expect(abandoned!.aborted, isTrue);
          expect(abandoned.operationId, isNull);
          expect(
            (await endpoints.content.beginEdit(owner, node.id!, 0, 1, id)).id,
            resumed.id,
          );
          await expectLater(
            endpoints.content.finish(owner, stale.id!),
            throwsA(isA<GardenException>()),
          );
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
