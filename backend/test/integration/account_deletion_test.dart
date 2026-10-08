import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';
import 'package:serverpod_auth_idp_server/providers/email.dart';
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart'
    as auth;
import 'package:garden_server/src/generated/protocol.dart';
import 'package:garden_server/src/auth/garden_authentication.dart';
import 'test_tools/serverpod_test_tools.dart';

class FailingStorage extends DatabaseCloudStorage {
  FailingStorage() : super('private');
  bool fail = false;
  @override
  Future<void> deleteFile({
    required Session session,
    required String path,
  }) async {
    if (fail) throw StateError('Fixture cloud cleanup failure.');
    await super.deleteFile(session: session, path: path);
  }
}

void main() {
  withServerpod(
    'Account deletion',
    (builder, endpoints) {
      final storage = FailingStorage();
      final codes = <String, String>{};
      setUp(() {
        final pod = builder.build().serverpod;
        pod.addCloudStorage(storage);
        pod.initializeAuthServices(
          tokenManagerBuilders: [JwtConfigFromPasswords()],
          identityProviderBuilders: [
            EmailIdpConfig(
              secretHashPepper: 'account-deletion-fixture-pepper',
              sendRegistrationVerificationCode:
                  (
                    session, {
                    required email,
                    required accountRequestId,
                    required verificationCode,
                    required transaction,
                  }) async {
                    codes[accountRequestId.toString()] = verificationCode;
                  },
            ),
          ],
        );
        storage.fail = false;
      });

      Future<TestSessionBuilder> account(String email) async {
        final session = builder.build();
        final service = AuthServices.instance;
        final user = await service.authUsers.create(session);
        await service.emailIdp.admin.createEmailAuthentication(
          session,
          authUserId: user.id,
          email: email,
          password: 'test-account-password',
        );
        await service.userProfiles.createUserProfile(
          session,
          user.id,
          UserProfileData(email: email),
        );
        return builder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(
            user.id.toString(),
            {},
          ),
        );
      }

      Future<String> file(TestSessionBuilder actor, int drive) async {
        final node = await endpoints.files.create(
          actor,
          drive,
          0,
          'fixture.mp4',
          NodeKind.file,
        );
        final version = await FileVersion.db.insertRow(
          actor.build(),
          FileVersion(
            nodeId: node.id!,
            authorId: actor.build().authenticated!.userIdentifier,
            baseVersion: 0,
            size: 4,
            chunkCount: 1,
            committed: true,
            createdAt: DateTime.now().toUtc(),
          ),
        );
        await FileChunk.db.insertRow(
          actor.build(),
          FileChunk(
            versionId: version.id!,
            chunkIndex: 0,
            size: 4,
            checksum: 'fixture',
          ),
        );
        final path = 'versions/${version.id}/0';
        await actor.build().storage.storeFile(
          storageId: 'private',
          path: path,
          byteData: ByteData(4),
        );
        return path;
      }

      test(
        'normal verified signup, deletion and signup again reuse the same email',
        () async {
          const email = 'signup-reuse@example.test';
          Future<TestSessionBuilder> signup() async {
            final request = await endpoints.emailIdp.startRegistration(
              builder,
              email: email,
            );
            await expectLater(
              endpoints.emailIdp.login(
                builder,
                email: email,
                password: 'signup-fixture-password',
              ),
              throwsA(isA<EmailAccountLoginException>()),
            );
            final token = await endpoints.emailIdp.verifyRegistrationCode(
              builder,
              accountRequestId: request,
              verificationCode: codes[request.toString()]!,
            );
            final result = await endpoints.emailIdp.finishRegistration(
              builder,
              registrationToken: token,
              password: 'signup-fixture-password',
            );
            return builder.copyWith(
              authentication: AuthenticationOverride.authenticationInfo(
                result.authUserId.toString(),
                {},
              ),
            );
          }

          final original = await signup();
          expect((await endpoints.garden.account(original)).email, email);
          expect(await endpoints.garden.list(original), isEmpty);
          await endpoints.account.deleteAccount(original, email);
          final replacement = await signup();
          expect(
            replacement.build().authenticated!.userIdentifier,
            isNot(original.build().authenticated!.userIdentifier),
          );
          expect((await endpoints.garden.account(replacement)).email, email);
          expect(await endpoints.garden.list(replacement), isEmpty);
        },
      );

      test(
        'deletes owned cloud files and identities, preserves other drives and releases email',
        () async {
          const email = 'delete-fixture@example.test';
          final owner = await account(email);
          final other = await account('keep-fixture@example.test');
          final mine = await endpoints.garden.create(owner, 'Delete');
          final theirs = await endpoints.garden.create(other, 'Keep');
          final ownPath = await file(owner, mine.id);
          final otherPath = await file(other, theirs.id);
          await GardenMember.db.insertRow(
            owner.build(),
            GardenMember(
              gardenId: theirs.id,
              userId: owner.build().authenticated!.userIdentifier,
              role: 'Editor',
            ),
          );
          final login = await endpoints.emailIdp.login(
            builder,
            email: email,
            password: 'test-account-password',
          );
          expect(
            await gardenAuthentication(owner.build(), login.token),
            isNotNull,
          );
          await endpoints.account.deleteAccount(owner, email);
          expect(
            await owner.build().storage.fileExists(
              storageId: 'private',
              path: ownPath,
            ),
            isFalse,
          );
          expect(
            await other.build().storage.fileExists(
              storageId: 'private',
              path: otherPath,
            ),
            isTrue,
          );
          expect(
            await GardenRecord.db.findById(other.build(), mine.id),
            isNull,
          );
          expect(
            await auth.AuthUser.db.findById(other.build(), login.authUserId),
            isNull,
          );
          expect(
            await gardenAuthentication(other.build(), login.token),
            isNull,
          );
          await expectLater(
            endpoints.emailIdp.login(
              builder,
              email: email,
              password: 'test-account-password',
            ),
            throwsA(isA<EmailAccountLoginException>()),
          );
          final replacement = await account(email);
          expect(
            replacement.build().authenticated!.userIdentifier,
            isNot(login.authUserId.toString()),
          );
          expect(await endpoints.garden.list(replacement), isEmpty);
          expect((await endpoints.garden.list(other)).single.id, theirs.id);
        },
      );

      test(
        'cloud failure retains email and deletion marker, rejects mutations, and retries',
        () async {
          const email = 'delete-retry@example.test';
          final owner = await account(email);
          final drive = await endpoints.garden.create(owner, 'Retry');
          final path = await file(owner, drive.id);
          storage.fail = true;
          await expectLater(
            endpoints.account.deleteAccount(owner, email),
            throwsStateError,
          );
          expect(
            await AccountDeletion.db.findFirstRow(
              owner.build(),
              where: (row) => row.userId.equals(
                owner.build().authenticated!.userIdentifier,
              ),
            ),
            isNotNull,
          );
          expect(
            await AuthServices.instance.emailIdp.admin.findAccount(
              owner.build(),
              email: email,
            ),
            isNotNull,
          );
          await expectLater(
            endpoints.garden.create(owner, 'Blocked'),
            throwsA(isA<GardenException>()),
          );
          await expectLater(
            endpoints.files.create(
              owner,
              drive.id,
              0,
              'Blocked',
              NodeKind.file,
            ),
            throwsA(isA<GardenException>()),
          );
          storage.fail = false;
          await endpoints.account.deleteAccount(owner, email);
          expect(
            await owner.build().storage.fileExists(
              storageId: 'private',
              path: path,
            ),
            isFalse,
          );
          expect(
            await AuthServices.instance.emailIdp.admin.findAccount(
              owner.build(),
              email: email,
            ),
            isNull,
          );
        },
      );

      test(
        'wrong confirmation and unauthenticated deletion preserve data',
        () async {
          final owner = await account('confirm-fixture@example.test');
          final drive = await endpoints.garden.create(owner, 'Keep');
          await expectLater(
            endpoints.account.deleteAccount(owner, 'other@example.test'),
            throwsA(isA<GardenException>()),
          );
          await expectLater(
            endpoints.account.deleteAccount(
              builder,
              'confirm-fixture@example.test',
            ),
            throwsA(isA<ServerpodUnauthenticatedException>()),
          );
          expect((await endpoints.garden.list(owner)).single.id, drive.id);
        },
      );
    },
    rollbackDatabase: RollbackDatabase.disabled,
    ephemeralDatabase: true,
  );
}
