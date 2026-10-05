import 'package:garden_client/garden_client.dart';

abstract interface class SharingGateway {
  DriveSharingService get sharing;
}

class DriveSharingService {
  DriveSharingService(this.client);
  final Client client;

  Future<DriveManagement> management(int drive) =>
      client.driveManagement.get(drive);
  Future<DriveInvitation> invite(int drive, String email, String role) =>
      client.driveInvitations.invite(drive, email, role);
  Future<DriveInvitation> resend(int invitation) =>
      client.driveInvitations.resend(invitation);
  Future<void> revoke(int invitation) =>
      client.driveInvitations.revoke(invitation);
  Future<void> changeRole(int drive, String user, String role) =>
      client.driveMembers.changeRole(drive, user, role);
  Future<void> remove(int drive, String user) =>
      client.driveMembers.remove(drive, user);
  Future<void> transferOwnership(int drive, String user) =>
      client.driveMembers.transferOwnership(drive, user);
  Future<void> leave(int drive) => client.driveMembers.leave(drive);
  Future<List<AccountNotification>> notifications() =>
      client.notifications.list(0);
  Stream<AccountNotification> watch(int cursor) =>
      client.notifications.watch(cursor);
  Future<void> markRead(int id) => client.notifications.markRead(id);
  Future<List<DriveInvitation>> received() =>
      client.driveInvitations.received();
  Future<void> accept(int id) => client.driveInvitations.accept(id);
  Future<void> decline(int id) => client.driveInvitations.decline(id);
}
