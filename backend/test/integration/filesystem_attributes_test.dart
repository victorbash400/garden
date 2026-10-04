import 'dart:convert';
import 'dart:io';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';
import 'package:garden_server/src/generated/protocol.dart';
import 'test_tools/serverpod_test_tools.dart';

FilesystemRequest request(
  FilesystemOperation operation,
  String path, {
  DateTime? modifiedAt,
  FileAttributes? attributes,
  String? name,
  String? value,
  int flags = 0,
}) => FilesystemRequest(
  operationId: Uuid().v4obj(),
  operation: operation,
  path: path,
  modifiedAt: modifiedAt,
  attributes: attributes,
  attributeName: name,
  attributeValue: value,
  attributeFlags: flags,
);

Matcher error(FilesystemError code) =>
    isA<FilesystemException>().having((e) => e.code, 'code', code);

void main() {
  withServerpod(
    'File attributes',
    (builder, endpoints) {
      final owner = builder.copyWith(
        authentication: AuthenticationOverride.authenticationInfo('owner', {}),
      );
      final guest = builder.copyWith(
        authentication: AuthenticationOverride.authenticationInfo('guest', {}),
      );

      test('creation permissions commit atomically and bind replay', () async {
        final drive = await endpoints.garden.create(owner, 'Creation modes');
        for (final operation in [
          FilesystemOperation.createFile,
          FilesystemOperation.createFolder,
        ]) {
          final path = '/${operation.name}';
          final create = request(
            operation,
            path,
            attributes: FileAttributes(permissions: 0x180),
          );
          final event = (await endpoints.filesystem.mutate(
            owner,
            drive.id,
            create,
          )).single;
          expect(event.node!.attributes!.permissions, 0x180);
          expect(
            (await endpoints.files.get(
              owner,
              event.node!.id!,
            )).attributes!.permissions,
            0x180,
          );
          expect(
            (await endpoints.filesystem.mutate(
              owner,
              drive.id,
              create,
            )).single.id,
            event.id,
          );
          await expectLater(
            endpoints.filesystem.mutate(
              owner,
              drive.id,
              create.copyWith(attributes: FileAttributes(permissions: 0x1ff)),
            ),
            throwsA(error(FilesystemError.invalid)),
          );
        }
        final invalid = request(
          FilesystemOperation.createFile,
          '/Invalid',
          attributes: FileAttributes(permissions: 0x800),
        );
        await expectLater(
          endpoints.filesystem.mutate(owner, drive.id, invalid),
          throwsA(error(FilesystemError.invalid)),
        );
        final corrected = (await endpoints.filesystem.mutate(
          owner,
          drive.id,
          invalid.copyWith(attributes: FileAttributes(permissions: 0)),
        )).single.node!;
        expect(corrected.attributes!.permissions, 0);
        for (final attributes in [
          FileAttributes(flags: 0),
          FileAttributes(accessedAt: DateTime.utc(2025)),
          FileAttributes(extended: {'test': 'AQ=='}),
        ]) {
          await expectLater(
            endpoints.filesystem.mutate(
              owner,
              drive.id,
              request(
                FilesystemOperation.createFolder,
                '/Rejected',
                attributes: attributes,
              ),
            ),
            throwsA(error(FilesystemError.invalid)),
          );
        }
        await expectLater(
          endpoints.filesystem.mutate(
            guest,
            drive.id,
            request(
              FilesystemOperation.createFile,
              '/Guest',
              attributes: FileAttributes(permissions: 0x1ff),
            ),
          ),
          throwsA(error(FilesystemError.accessDenied)),
        );
      });

      test(
        'dates and permissions persist without changing content identity; replay binds every argument',
        () async {
          final drive = await endpoints.garden.create(owner, 'Metadata');
          final file = (await endpoints.filesystem.mutate(
            owner,
            drive.id,
            request(FilesystemOperation.createFile, '/File'),
          )).single.node!;
          final modified = DateTime.utc(2025, 5, 1);
          final access = DateTime.utc(2025, 5, 2);
          final change = request(
            FilesystemOperation.setAttributes,
            '/File',
            modifiedAt: modified,
            attributes: FileAttributes(
              permissions: 0x180,
              accessedAt: access,
              flags: 0x8000,
            ),
          );
          final event = (await endpoints.filesystem.mutate(
            owner,
            drive.id,
            change,
          )).single;
          final current = await endpoints.files.get(owner, file.id!);
          expect(current.updatedAt, modified);
          expect(current.attributes!.accessedAt, access);
          expect(current.attributes!.permissions, 0x180);
          expect(current.attributes!.flags, 0x8000);
          expect(current.version, file.version);
          expect(
            (await endpoints.filesystem.mutate(
              owner,
              drive.id,
              change,
            )).single.id,
            event.id,
          );
          await expectLater(
            endpoints.filesystem.mutate(
              owner,
              drive.id,
              change.copyWith(attributes: FileAttributes(permissions: 0x1a4)),
            ),
            throwsA(error(FilesystemError.invalid)),
          );
          await expectLater(
            endpoints.filesystem.mutate(
              guest,
              drive.id,
              request(
                FilesystemOperation.setAttributes,
                '/File',
                modifiedAt: modified,
              ),
            ),
            throwsA(error(FilesystemError.accessDenied)),
          );
        },
      );

      test(
        'binary attributes follow rename, enforce create and replace, and replay removal',
        () async {
          final drive = await endpoints.garden.create(owner, 'Extended');
          final file = (await endpoints.filesystem.mutate(
            owner,
            drive.id,
            request(FilesystemOperation.createFile, '/File'),
          )).single.node!;
          const name = 'com.apple.FinderInfo';
          final value = base64Encode(List<int>.generate(32, (i) => i));
          final create = request(
            FilesystemOperation.setExtendedAttribute,
            '/File',
            name: name,
            value: value,
            flags: 2,
          );
          final event = (await endpoints.filesystem.mutate(
            owner,
            drive.id,
            create,
          )).single;
          expect(
            (await endpoints.filesystem.mutate(
              owner,
              drive.id,
              create,
            )).single.id,
            event.id,
          );
          await expectLater(
            endpoints.filesystem.mutate(
              owner,
              drive.id,
              request(
                FilesystemOperation.setExtendedAttribute,
                '/File',
                name: name,
                value: value,
                flags: 2,
              ),
            ),
            throwsA(error(FilesystemError.alreadyExists)),
          );
          await expectLater(
            endpoints.filesystem.mutate(
              owner,
              drive.id,
              request(
                FilesystemOperation.setExtendedAttribute,
                '/File',
                name: 'missing',
                value: value,
                flags: 4,
              ),
            ),
            throwsA(error(FilesystemError.noAttribute)),
          );
          await endpoints.filesystem.mutate(
            owner,
            drive.id,
            request(
              FilesystemOperation.rename,
              '/File',
            ).copyWith(destination: '/Renamed'),
          );
          var current = await endpoints.files.get(owner, file.id!);
          expect(current.name, 'Renamed');
          expect(current.attributes!.extended, {name: value});
          expect(current.version, file.version);
          expect(
            current.updatedAt.isBefore(
              DateTime.now().toUtc().add(const Duration(seconds: 1)),
            ),
            isTrue,
          );
          final remove = request(
            FilesystemOperation.removeExtendedAttribute,
            '/Renamed',
            name: name,
          );
          final removed = (await endpoints.filesystem.mutate(
            owner,
            drive.id,
            remove,
          )).single;
          expect(
            (await endpoints.filesystem.mutate(
              owner,
              drive.id,
              remove,
            )).single.id,
            removed.id,
          );
          current = await endpoints.files.get(owner, file.id!);
          expect(current.attributes!.extended, isEmpty);
          await expectLater(
            endpoints.filesystem.mutate(
              owner,
              drive.id,
              request(
                FilesystemOperation.removeExtendedAttribute,
                '/Renamed',
                name: name,
              ),
            ),
            throwsA(error(FilesystemError.noAttribute)),
          );
        },
      );

      test(
        'invalid and oversized changes roll back without consuming an operation ID',
        () async {
          final drive = await endpoints.garden.create(owner, 'Limits');
          final file = (await endpoints.filesystem.mutate(
            owner,
            drive.id,
            request(FilesystemOperation.createFile, '/File'),
          )).single.node!;
          final tooLarge = request(
            FilesystemOperation.setExtendedAttribute,
            '/File',
            name: 'test',
            value: base64Encode(List<int>.filled(256 * 1024 + 1, 1)),
          );
          await expectLater(
            endpoints.filesystem.mutate(owner, drive.id, tooLarge),
            throwsA(error(FilesystemError.tooLarge)),
          );
          await endpoints.filesystem.mutate(
            owner,
            drive.id,
            tooLarge.copyWith(attributeValue: 'AQ=='),
          );
          for (final invalid in [
            request(
              FilesystemOperation.setExtendedAttribute,
              '/File',
              name: 'test',
              value: 'not-base64',
            ),
            request(
              FilesystemOperation.setAttributes,
              '/File',
              attributes: FileAttributes(permissions: 0x800),
            ),
            request(
              FilesystemOperation.setAttributes,
              '/File',
              attributes: FileAttributes(flags: 2),
            ),
            request(
              FilesystemOperation.setAttributes,
              '/File',
              attributes: FileAttributes(extended: {'test': 'AQ=='}),
            ),
            request(FilesystemOperation.unlink, '/File', name: 'test'),
          ]) {
            await expectLater(
              endpoints.filesystem.mutate(owner, drive.id, invalid),
              throwsA(error(FilesystemError.invalid)),
            );
          }
          expect(
            (await endpoints.files.get(owner, file.id!)).attributes!.extended,
            {'test': 'AQ=='},
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
