import 'dart:async';
import 'package:garden_server/src/accounts/usernames.dart';
import 'package:garden_server/src/generated/protocol.dart';
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart'
    as auth;
import 'package:test/test.dart';
import 'package:serverpod_auth_idp_server/core.dart';
import 'package:serverpod_auth_idp_server/providers/email.dart';
import 'test_tools/serverpod_test_tools.dart';

void main() {
  test(
    'username validation accepts canonical names and rejects unsafe input',
    () {
      expect(Usernames.normalize('  Victor_400  '), 'victor_400');
      for (final value in [
        '',
        'aa',
        '9name',
        'a b',
        'a@b.com',
        'abc/',
        'ab\ncd',
        'éclair',
      ]) {
        expect(
          () => Usernames.normalize(value),
          throwsA(isA<GardenException>()),
        );
      }
    },
  );
  withServerpod(
    'Username and drive chat boundaries',
    (builder, endpoints) {
      Future<TestSessionBuilder> account(String address) async {
        final session = builder.build();
        final user = await auth.AuthUser.db.insertRow(
          session,
          auth.AuthUser(scopeNames: {}),
        );
        await auth.UserProfile.db.insertRow(
          session,
          auth.UserProfile(
            authUserId: user.id!,
            email: address,
            createdAt: DateTime.now().toUtc(),
          ),
        );
        await EmailAccount.db.insertRow(
          session,
          EmailAccount(
            authUserId: user.id!,
            email: address,
            passwordHash: 'unused',
          ),
        );
        return builder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(
            user.id!.toString(),
            {},
          ),
        );
      }

      test(
        'Inbox discovers new conversations, delivers unread messages and isolates recipients',
        () async {
          final owner = await account('inbox-owner@example.com');
          final receiver = await account('inbox-receiver@example.com');
          final outsider = await account('inbox-outsider@example.com');
          final drive = await endpoints.garden.create(owner, 'Inbox drive');
          for (final member in [receiver, outsider]) {
            await GardenMember.db.insertRow(
              owner.build(),
              GardenMember(
                gardenId: drive.id,
                userId: member.build().authenticated!.userIdentifier,
                role: 'Viewer',
              ),
            );
          }
          final before = await endpoints.inbox.snapshot(receiver);
          final changes = StreamIterator(
            endpoints.inbox.watch(receiver, before.cursor),
          );
          final arriving = changes.moveNext();
          final conversation = await endpoints.conversations.create(
            owner,
            drive.id,
            [receiver.build().authenticated!.userIdentifier],
            'Design review',
          );
          final id = conversation.conversation.id!;
          expect(await arriving.timeout(const Duration(seconds: 5)), isTrue);
          expect(changes.current.kind, 'chatAdded');
          expect(changes.current.conversationId, id);
          var entry = (await endpoints.inbox.snapshot(
            receiver,
          )).entries.firstWhere((entry) => entry.conversationId == id);
          expect(entry.title, 'Design review');
          expect(entry.isNew, isTrue);
          expect(
            (await endpoints.inbox.snapshot(
              outsider,
            )).entries.where((entry) => entry.conversationId == id),
            isEmpty,
          );
          await endpoints.inbox.seen(receiver, id);
          entry = (await endpoints.inbox.snapshot(
            receiver,
          )).entries.firstWhere((entry) => entry.conversationId == id);
          expect(entry.isNew, isFalse);
          final folder = await endpoints.files.create(
            owner,
            drive.id,
            0,
            'Assets',
            NodeKind.folder,
          );
          final message = await endpoints.conversationMessages.send(
            owner,
            id,
            'Please review',
            null,
            folder.id,
          );
          entry = (await endpoints.inbox.snapshot(
            receiver,
          )).entries.firstWhere((entry) => entry.conversationId == id);
          expect(entry.unreadCount, 1);
          expect(entry.latestText, 'Please review');
          final notices = await AccountNotification.db.find(
            owner.build(),
            where: (row) =>
                row.recipientEmail.equals('inbox-receiver@example.com') &
                row.conversationId.equals(id),
          );
          expect(
            notices.map((notice) => notice.kind),
            containsAll(['chatAdded', 'chatMessage']),
          );
          await endpoints.conversationMessages.markRead(
            receiver,
            id,
            message.id!,
          );
          expect(
            (await endpoints.inbox.snapshot(receiver)).entries
                .firstWhere((entry) => entry.conversationId == id)
                .unreadCount,
            0,
          );
          await expectLater(
            endpoints.conversations.rename(receiver, id, 'Forbidden'),
            throwsA(isA<GardenException>()),
          );
          await endpoints.conversations.rename(owner, id, 'Renamed review');
          expect(
            (await endpoints.inbox.snapshot(
              receiver,
            )).entries.firstWhere((entry) => entry.conversationId == id).title,
            'Renamed review',
          );
          await endpoints.conversations.delete(owner, id);
          expect(
            (await endpoints.inbox.snapshot(
              receiver,
            )).entries.where((entry) => entry.conversationId == id),
            isEmpty,
          );
          await expectLater(
            endpoints.conversationMessages.snapshot(receiver, id),
            throwsA(isA<GardenException>()),
          );
          await changes.cancel();
        },
      );
      test(
        'existing users receive private unique names; rename uniqueness is case insensitive',
        () async {
          final first = await account('private-one@example.com');
          final second = await account('private-two@example.com');
          final one = await Usernames.ensure(
            first.build(),
            first.build().authenticated!.userIdentifier,
          );
          final two = await Usernames.ensure(
            second.build(),
            second.build().authenticated!.userIdentifier,
          );
          expect(one.username, startsWith('garden_'));
          expect(one.username.length, 19);
          expect(one.username, isNot(two.username));
          expect(one.username, isNot(contains('private')));
          expect(
            (await Usernames.ensure(first.build(), one.userId)).username,
            one.username,
          );
          await Usernames.rename(first.build(), one.userId, '  Victor_400 ');
          await expectLater(
            Usernames.rename(second.build(), two.userId, 'VICTOR_400'),
            throwsA(isA<GardenException>()),
          );
          expect(
            (await Usernames.ensure(second.build(), two.userId)).username,
            two.username,
          );
          await expectLater(
            Usernames.rename(second.build(), two.userId, 'garden_reserved'),
            throwsA(isA<GardenException>()),
          );
        },
      );
      test(
        'simultaneous first access assigns one username and competing renames have one winner',
        () async {
          final first = await account('concurrent-one@example.com');
          final second = await account('concurrent-two@example.com');
          final id = first.build().authenticated!.userIdentifier;
          final assigned = await Future.wait([
            Usernames.ensure(first.build(), id),
            Usernames.ensure(first.build(), id),
          ]);
          expect(assigned[0].id, assigned[1].id);
          Future<bool> claim(TestSessionBuilder actor) async {
            try {
              await Usernames.rename(
                actor.build(),
                actor.build().authenticated!.userIdentifier,
                'contended_name',
              );
              return true;
            } on GardenException {
              return false;
            }
          }

          final results = await Future.wait([claim(first), claim(second)]);
          expect(results.where((value) => value).length, 1);
        },
      );
      test(
        'username and email login authenticate the same account without exposing email',
        () async {
          final session = builder.build();
          session.serverpod.initializeAuthServices(
            tokenManagerBuilders: [JwtConfigFromPasswords()],
            identityProviderBuilders: [
              const EmailIdpConfig(
                secretHashPepper: 'test-only-username-login-pepper',
              ),
            ],
          );
          final services = AuthServices.instance;
          final user = await services.authUsers.create(session);
          await services.userProfiles.createUserProfile(
            session,
            user.id,
            UserProfileData(email: 'username-login@example.com'),
          );
          await services.emailIdp.admin.createEmailAuthentication(
            session,
            authUserId: user.id,
            email: 'username-login@example.com',
            password: 'Test-login-only-2066',
          );
          final identity = await Usernames.rename(
            session,
            user.id.toString(),
            'login_user',
          );
          final byName = await endpoints.emailIdp.login(
            builder,
            email: ' LOGIN_USER ',
            password: 'Test-login-only-2066',
          );
          final byEmail = await endpoints.emailIdp.login(
            builder,
            email: 'username-login@example.com',
            password: 'Test-login-only-2066',
          );
          expect(byName.authUserId, byEmail.authUserId);
          expect(byName.authUserId.toString(), identity.userId);
          await expectLater(
            endpoints.emailIdp.login(
              builder,
              email: 'login_user',
              password: 'wrong',
            ),
            throwsA(isA<EmailAccountLoginException>()),
          );
          await expectLater(
            endpoints.emailIdp.login(
              builder,
              email: 'unknown_user',
              password: 'wrong',
            ),
            throwsA(isA<EmailAccountLoginException>()),
          );
        },
      );
      test(
        'chat validates membership, threads and file references; Viewer can chat without file edits',
        () async {
          final owner = await account('chat-owner@example.com');
          final viewer = await account('chat-viewer@example.com');
          final stranger = await account('chat-other@example.com');
          final drive = await endpoints.garden.create(owner, 'Shared chat');
          await GardenMember.db.insertRow(
            owner.build(),
            GardenMember(
              gardenId: drive.id,
              userId: viewer.build().authenticated!.userIdentifier,
              role: 'Viewer',
            ),
          );
          final node = await endpoints.files.create(
            owner,
            drive.id,
            0,
            'Reference.txt',
            NodeKind.file,
          );
          final message = await endpoints.chat.send(
            owner,
            drive.id,
            'Review this',
            null,
            node.id,
          );
          expect(message.username, startsWith('garden_'));
          expect(message.nodeName, 'Reference.txt');
          final reply = await endpoints.chat.send(
            owner,
            drive.id,
            'Reply',
            message.id,
            null,
          );
          expect(reply.replyToId, message.id);
          expect(
            (await endpoints.chat.conversations(
              viewer,
              drive.id,
              0,
            )).map((item) => item.id),
            [message.id],
          );
          expect(
            await endpoints.chat.conversations(viewer, drive.id, message.id!),
            isEmpty,
          );
          await expectLater(
            endpoints.chat.conversations(stranger, drive.id, 0),
            throwsA(isA<GardenException>()),
          );
          final conversation = await endpoints.chat.thread(
            viewer,
            drive.id,
            reply.id!,
            0,
          );
          expect(conversation.first.id, message.id);
          expect(conversation.last.id, reply.id);
          await expectLater(
            endpoints.chat.thread(stranger, drive.id, message.id!, 0),
            throwsA(isA<GardenException>()),
          );
          await expectLater(
            endpoints.chat.send(owner, drive.id, 'Nested', reply.id, null),
            throwsA(isA<GardenException>()),
          );
          expect(
            (await endpoints.chat.snapshot(viewer, drive.id)).unreadCount,
            2,
          );
          await endpoints.chat.markRead(viewer, drive.id, reply.id!);
          expect(
            (await endpoints.chat.snapshot(viewer, drive.id)).unreadCount,
            0,
          );
          expect(
            (await endpoints.chat.send(
              viewer,
              drive.id,
              'Viewer message',
              null,
              null,
            )).text,
            'Viewer message',
          );
          await expectLater(
            endpoints.chat.history(stranger, drive.id, 0),
            throwsA(isA<GardenException>()),
          );
          final privateDrive = await endpoints.garden.create(
            stranger,
            'Private',
          );
          final privateNode = await endpoints.files.create(
            stranger,
            privateDrive.id,
            0,
            'Hidden.txt',
            NodeKind.file,
          );
          await expectLater(
            endpoints.chat.send(
              owner,
              drive.id,
              'Wrong drive',
              null,
              privateNode.id,
            ),
            throwsA(isA<GardenException>()),
          );
          final other = await endpoints.chat.send(
            stranger,
            privateDrive.id,
            'Private message',
            null,
            null,
          );
          await expectLater(
            endpoints.chat.send(owner, drive.id, 'Wrong reply', other.id, null),
            throwsA(isA<GardenException>()),
          );
          await expectLater(
            endpoints.chat.markRead(viewer, drive.id, other.id!),
            throwsA(isA<GardenException>()),
          );
          expect(
            (await endpoints.chat.history(
              owner,
              drive.id,
              reply.id!,
            )).single.id,
            message.id,
          );
        },
      );
      test(
        'direct and group chats enforce recipients, hide private messages from drive feeds, and revoke streaming access',
        () async {
          final owner = await account('conversation-owner@example.com');
          final viewer = await account('conversation-viewer@example.com');
          final unselected = await account(
            'conversation-unselected@example.com',
          );
          final outsider = await account('conversation-outsider@example.com');
          final drive = await endpoints.garden.create(
            owner,
            'Conversation drive',
          );
          for (final peer in [viewer, unselected]) {
            await GardenMember.db.insertRow(
              owner.build(),
              GardenMember(
                gardenId: drive.id,
                userId: peer.build().authenticated!.userIdentifier,
                role: 'Viewer',
              ),
            );
            await endpoints.garden.account(peer);
          }
          final viewerId = viewer.build().authenticated!.userIdentifier;
          final ownerId = owner.build().authenticated!.userIdentifier;
          final direct = await endpoints.conversations.create(owner, drive.id, [
            viewerId,
          ], '');
          expect(direct.members.map((member) => member.userId).toSet(), {
            ownerId,
            viewerId,
          });
          final reused = await endpoints.conversations.create(
            viewer,
            drive.id,
            [ownerId],
            '',
          );
          expect(reused.conversation.id, direct.conversation.id);
          final id = direct.conversation.id!;
          expect(
            await endpoints.conversations.list(unselected, drive.id, 0),
            isEmpty,
          );
          await expectLater(
            endpoints.conversations.get(unselected, id),
            throwsA(isA<GardenException>()),
          );
          await expectLater(
            endpoints.conversations.create(owner, drive.id, [
              outsider.build().authenticated!.userIdentifier,
            ], ''),
            throwsA(isA<GardenException>()),
          );
          final node = await endpoints.files.create(
            owner,
            drive.id,
            0,
            'Reference.txt',
            NodeKind.file,
          );
          final private = await endpoints.conversationMessages.send(
            viewer,
            id,
            'Private discussion',
            null,
            node.id,
          );
          expect(private.conversationId, id);
          expect(
            (await endpoints.conversationMessages.snapshot(
              owner,
              id,
            )).messages.single.id,
            private.id,
          );
          expect(
            (await endpoints.chat.snapshot(unselected, drive.id)).messages,
            isEmpty,
          );
          expect(
            await endpoints.chat.history(unselected, drive.id, 0),
            isEmpty,
          );
          await expectLater(
            endpoints.chat.thread(unselected, drive.id, private.id!, 0),
            throwsA(isA<GardenException>()),
          );
          await expectLater(
            endpoints.chat.send(
              owner,
              drive.id,
              'Wrong feed',
              private.id,
              null,
            ),
            throwsA(isA<GardenException>()),
          );
          await expectLater(
            endpoints.conversationMessages.snapshot(unselected, id),
            throwsA(isA<GardenException>()),
          );
          await expectLater(
            endpoints.conversationMessages.history(unselected, id, 0),
            throwsA(isA<GardenException>()),
          );
          await expectLater(
            endpoints.conversationMessages.send(
              unselected,
              id,
              'Denied',
              null,
              null,
            ),
            throwsA(isA<GardenException>()),
          );
          await expectLater(
            endpoints.conversationMessages.markRead(
              unselected,
              id,
              private.id!,
            ),
            throwsA(isA<GardenException>()),
          );
          await expectLater(
            endpoints.conversationMessages.thread(
              unselected,
              id,
              private.id!,
              0,
            ),
            throwsA(isA<GardenException>()),
          );
          final group = await endpoints.conversations.create(owner, drive.id, [
            viewerId,
            unselected.build().authenticated!.userIdentifier,
          ], 'Review team');
          expect(group.members.length, 3);
          await expectLater(
            endpoints.conversationMessages.send(
              owner,
              group.conversation.id!,
              'Wrong thread',
              private.id,
              null,
            ),
            throwsA(isA<GardenException>()),
          );
          await expectLater(
            endpoints.files.create(
              viewer,
              drive.id,
              0,
              'Denied.txt',
              NodeKind.file,
            ),
            throwsA(isA<GardenException>()),
          );
          final stream = StreamIterator(
            endpoints.conversationMessages.watch(viewer, id, 0),
          );
          expect(
            await stream.moveNext().timeout(const Duration(seconds: 5)),
            isTrue,
          );
          expect(stream.current.id, private.id);
          final waiting = stream.moveNext();
          await endpoints.driveMembers.remove(owner, drive.id, viewerId);
          await expectLater(
            waiting.timeout(const Duration(seconds: 5)),
            throwsA(isA<GardenException>()),
          );
          await stream.cancel();
          await expectLater(
            endpoints.conversationMessages.snapshot(viewer, id),
            throwsA(isA<GardenException>()),
          );
          final replies = await DriveMessage.db.insert(
            owner.build(),
            List.generate(
              120,
              (index) => DriveMessage(
                gardenId: drive.id,
                conversationId: id,
                authorId: owner.build().authenticated!.userIdentifier,
                username: private.username,
                text: 'Reply $index',
                replyToId: private.id,
                createdAt: DateTime.now().toUtc(),
              ),
            ),
          );
          final page = await endpoints.conversationMessages.snapshot(owner, id);
          expect(page.messages.single.id, private.id);
          expect(page.messages.single.hasReplies, isTrue);
          expect(page.latestMessageId, replies.last.id);
          expect(
            (await endpoints.conversationMessages.history(
              owner,
              id,
              0,
            )).single.id,
            private.id,
          );
        },
      );
      test(
        'live chat replays a missed message and closes on member removal',
        () async {
          final owner = await account('stream-owner@example.com');
          final member = await account('stream-member@example.com');
          final drive = await endpoints.garden.create(owner, 'Stream');
          await GardenMember.db.insertRow(
            owner.build(),
            GardenMember(
              gardenId: drive.id,
              userId: member.build().authenticated!.userIdentifier,
              role: 'Editor',
            ),
          );
          final initial = await endpoints.chat.send(
            owner,
            drive.id,
            'Earlier',
            null,
            null,
          );
          final changes = StreamIterator(
            endpoints.chat.watch(member, drive.id, 0),
          );
          expect(
            await changes.moveNext().timeout(const Duration(seconds: 5)),
            isTrue,
          );
          expect(changes.current.id, initial.id);
          final next = changes.moveNext();
          final message = await endpoints.chat.send(
            owner,
            drive.id,
            'Live',
            null,
            null,
          );
          expect(await next.timeout(const Duration(seconds: 5)), isTrue);
          expect(changes.current.id, message.id);
          final removed = changes.moveNext();
          await endpoints.driveMembers.remove(
            owner,
            drive.id,
            member.build().authenticated!.userIdentifier,
          );
          await expectLater(
            removed.timeout(const Duration(seconds: 5)),
            throwsA(isA<GardenException>()),
          );
          await changes.cancel();
          await expectLater(
            endpoints.chat.snapshot(member, drive.id),
            throwsA(isA<GardenException>()),
          );
        },
      );
    },
    rollbackDatabase: RollbackDatabase.disabled,
    ephemeralDatabase: true,
  );
}
