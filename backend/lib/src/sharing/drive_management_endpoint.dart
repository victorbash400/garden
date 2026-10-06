import 'package:serverpod/serverpod.dart';
import '../files/drive_access.dart';
import '../gardens/drive_permissions.dart';
import '../generated/protocol.dart';

class DriveManagementEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  Future<DriveManagement> get(
    Session session,
    int gardenId,
  ) => session.db.transaction((transaction) async {
    final drive = await DriveAccess.lock(
      session,
      gardenId,
      transaction,
      mode: LockMode.forShare,
      capability: DriveCapability.read,
    );
    final members = await GardenMember.db.find(
      session,
      where: (row) => row.gardenId.equals(gardenId),
      transaction: transaction,
    );
    final actor = members.singleWhere(
      (member) => member.userId == DriveAccess.user(session),
    );
    final totals = await session.db.unsafeQuery(
      '''
      SELECT COALESCE(SUM("size") FILTER (WHERE "kind" = 'file'), 0)::bigint,
        COUNT(*) FILTER (WHERE "kind" = 'file'), COUNT(*) FILTER (WHERE "kind" = 'folder')
      FROM "file_node" WHERE "gardenId" = @drive AND "deleted" = false
    ''',
      parameters: QueryParameters.named({'drive': gardenId}),
      transaction: transaction,
    );
    final invitations =
        DriveRole.parse(actor.role).allows(DriveCapability.manageMembers)
        ? await DriveInvitation.db.find(
            session,
            where: (row) => row.gardenId.equals(gardenId),
            orderBy: (row) => row.createdAt.desc(),
            limit: 200,
            transaction: transaction,
          )
        : <DriveInvitation>[];
    final identities = await AccountUsername.db.find(
      session,
      where: (row) =>
          row.userId.inSet(members.map((member) => member.userId).toSet()),
      transaction: transaction,
    );
    final names = {
      for (final identity in identities) identity.userId: identity.username,
    };
    final details = members.map((member) {
      return DriveMemberDetails(
        userId: member.userId,
        role: member.role,
        displayName: names[member.userId] ?? 'Username unavailable',
      );
    }).toList();
    return DriveManagement(
      drive: GardenSummary(
        id: gardenId,
        name: drive.name,
        role: actor.role,
        members: members.length,
      ),
      logicalBytes: totals.single[0] as int,
      fileCount: totals.single[1] as int,
      folderCount: totals.single[2] as int,
      members: details,
      invitations: invitations,
    );
  });
}
