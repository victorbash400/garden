import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';
import '../files/drive_access.dart';
import 'usernames.dart';

class IdentitiesEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  Future<List<PublicIdentity>> members(Session session, int driveId) async {
    await DriveAccess.require(session, driveId);
    final members = await GardenMember.db.find(
      session,
      where: (row) => row.gardenId.equals(driveId),
    );
    final identities = await AccountUsername.db.find(
      session,
      where: (row) =>
          row.userId.inSet(members.map((member) => member.userId).toSet()),
    );
    final known = identities.map((identity) => identity.userId).toSet();
    for (final member in members) {
      if (!known.contains(member.userId)) {
        identities.add(await Usernames.ensure(session, member.userId));
      }
    }
    return identities
        .map(
          (identity) => PublicIdentity(
            userId: identity.userId,
            username: identity.username,
          ),
        )
        .toList();
  }
}
