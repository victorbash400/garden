import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';
import '../generated/protocol.dart';
import '../sharing/member_change.dart';
import 'account_data_cleanup.dart';
import 'account_file_cleanup.dart';
import 'account_lifecycle.dart';

class AccountEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  Future<void> deleteAccount(Session session, String email) async {
    final user = session.authenticated!.userIdentifier;
    final id = UuidValue.fromString(user);
    final profile = await AuthServices.instance.userProfiles
        .findUserProfileByUserId(session, id);
    if (email.trim().toLowerCase() != profile.email?.toLowerCase()) {
      throw GardenException(
        message: 'Enter your account email to confirm deletion.',
      );
    }
    final changes = await session.db.transaction((transaction) async {
      await AccountLifecycle.lock(session, user, transaction);
      final pending = await AccountDeletion.db.findFirstRow(
        session,
        where: (row) => row.userId.equals(user),
        transaction: transaction,
      );
      if (pending == null) {
        await AccountDeletion.db.insertRow(
          session,
          AccountDeletion(userId: user, createdAt: DateTime.now().toUtc()),
          transaction: transaction,
        );
      }
      final drives = await GardenRecord.db.find(
        session,
        where: (row) => row.ownerId.equals(user) & row.deleted.equals(false),
        lockMode: LockMode.forUpdate,
        transaction: transaction,
      );
      final events = <MemberChange>[];
      for (final drive in drives) {
        drive.deleted = true;
        final members = await GardenMember.db.find(
          session,
          where: (row) => row.gardenId.equals(drive.id!),
          transaction: transaction,
        );
        events.add(
          await MemberChange.record(session, drive, transaction, {
            for (final member in members) member.userId: 'Drive deleted',
          }),
        );
      }
      return events;
    });
    for (final change in changes) {
      await change.publish(session);
    }
    // Keep the deletion marker and identities until cloud cleanup succeeds.
    // A failed request can resume safely; its email is not released prematurely.
    await session.db.transaction((transaction) async {
      await AccountLifecycle.lock(session, user, transaction);
      await AccountFileCleanup.remove(session, user);
      await AccountDataCleanup.remove(
        session,
        user,
        profile.email!,
        transaction,
      );
      await AuthServices.instance.authUsers.delete(
        session,
        authUserId: id,
        transaction: transaction,
      );
    });
    await session.messages.authenticationRevoked(
      user,
      RevokedAuthenticationUser(),
    );
  }
}
