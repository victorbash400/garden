import 'package:serverpod/serverpod.dart';
import '../files/drive_access.dart';
import 'member_change.dart';
import '../gardens/drive_permissions.dart';
import '../generated/protocol.dart';

class DriveMembersEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  Future<String?> accessRole(Session session, int gardenId) async {
    final drive = await GardenRecord.db.findById(session, gardenId);
    if (drive == null || drive.deleted) return null;
    final member = await GardenMember.db.findFirstRow(
      session,
      where: (row) =>
          row.gardenId.equals(gardenId) &
          row.userId.equals(DriveAccess.user(session)),
    );
    return member == null ? null : DriveRole.parse(member.role).label;
  }

  Future<List<GardenMember>> list(Session session, int gardenId) async {
    await DriveAccess.require(session, gardenId);
    return GardenMember.db.find(
      session,
      where: (row) => row.gardenId.equals(gardenId),
    );
  }

  Future<void> changeRole(
    Session session,
    int gardenId,
    String userId,
    String role,
  ) async {
    final targetRole = DriveRole.parse(role);
    final event = await session.db.transaction((transaction) async {
      final drive = await DriveAccess.lock(
        session,
        gardenId,
        transaction,
        capability: DriveCapability.manageMembers,
      );
      final actor = await _member(
        session,
        gardenId,
        DriveAccess.user(session),
        transaction,
      );
      final target = await _member(session, gardenId, userId, transaction);
      final actorRole = DriveRole.parse(actor.role);
      if (userId == actor.userId ||
          !actorRole.canManage(DriveRole.parse(target.role)) ||
          !actorRole.canManage(targetRole)) {
        throw GardenException(
          message: 'You cannot change this member’s permission.',
        );
      }
      if (targetRole == DriveRole.viewer) {
        await _releaseLeases(session, gardenId, userId, transaction);
      }
      target.role = targetRole.label;
      await GardenMember.db.updateRow(
        session,
        target,
        transaction: transaction,
      );
      return MemberChange.record(session, drive, transaction, {
        userId: targetRole.label,
      });
    });
    await event.publish(session);
  }

  Future<void> remove(Session session, int gardenId, String userId) async {
    final event = await session.db.transaction((transaction) async {
      final drive = await DriveAccess.lock(
        session,
        gardenId,
        transaction,
        capability: DriveCapability.manageMembers,
      );
      final actor = await _member(
        session,
        gardenId,
        DriveAccess.user(session),
        transaction,
      );
      final target = await _member(session, gardenId, userId, transaction);
      if (userId == actor.userId ||
          !DriveRole.parse(
            actor.role,
          ).canManage(DriveRole.parse(target.role))) {
        throw GardenException(message: 'You cannot remove this member.');
      }
      await _releaseLeases(session, gardenId, userId, transaction);
      await GardenMember.db.deleteRow(
        session,
        target,
        transaction: transaction,
      );
      return MemberChange.record(session, drive, transaction, {
        userId: 'Access removed',
      });
    });
    await event.publish(session);
  }

  Future<void> transferOwnership(
    Session session,
    int gardenId,
    String userId,
  ) async {
    final event = await session.db.transaction((transaction) async {
      final drive = await DriveAccess.lock(
        session,
        gardenId,
        transaction,
        capability: DriveCapability.manageDrive,
      );
      if (userId == DriveAccess.user(session)) {
        throw GardenException(message: 'Choose another drive member.');
      }
      final previous = await _member(
        session,
        gardenId,
        DriveAccess.user(session),
        transaction,
      );
      final next = await _member(session, gardenId, userId, transaction);
      previous.role = DriveRole.manager.label;
      next.role = DriveRole.owner.label;
      drive.ownerId = userId;
      await GardenMember.db.updateRow(
        session,
        previous,
        transaction: transaction,
      );
      await GardenMember.db.updateRow(session, next, transaction: transaction);
      return MemberChange.record(session, drive, transaction, {
        previous.userId: 'Manager',
        next.userId: 'Owner',
      });
    });
    await event.publish(session);
  }

  Future<void> leave(Session session, int gardenId) async {
    final event = await session.db.transaction((transaction) async {
      final drive = await DriveAccess.lock(
        session,
        gardenId,
        transaction,
        capability: DriveCapability.read,
      );
      final member = await _member(
        session,
        gardenId,
        DriveAccess.user(session),
        transaction,
      );
      if (DriveRole.parse(member.role) == DriveRole.owner) {
        throw GardenException(
          message: 'Transfer ownership before leaving this drive.',
        );
      }
      await _releaseLeases(session, gardenId, member.userId, transaction);
      await GardenMember.db.deleteRow(
        session,
        member,
        transaction: transaction,
      );
      return MemberChange.record(session, drive, transaction, {
        member.userId: 'Left drive',
      });
    });
    await event.publish(session);
  }

  Future<void> _releaseLeases(
    Session session,
    int drive,
    String user,
    Transaction transaction,
  ) async {
    await session.db.unsafeExecute(
      '''
      DELETE FROM "file_lease" USING "file_node"
      WHERE "file_lease"."nodeId" = "file_node"."id"
        AND "file_node"."gardenId" = @drive AND "file_lease"."holderId" = @user
    ''',
      parameters: QueryParameters.named({'drive': drive, 'user': user}),
      transaction: transaction,
    );
  }

  Future<GardenMember> _member(
    Session session,
    int gardenId,
    String userId,
    Transaction transaction,
  ) async {
    final member = await GardenMember.db.findFirstRow(
      session,
      where: (row) => row.gardenId.equals(gardenId) & row.userId.equals(userId),
      transaction: transaction,
    );
    if (member == null) {
      throw GardenException(message: 'This account is not a drive member.');
    }
    return member;
  }
}
