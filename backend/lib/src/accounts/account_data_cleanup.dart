import 'package:serverpod/serverpod.dart';

class AccountDataCleanup {
  static Future<void> remove(
    Session session,
    String user,
    String email,
    Transaction transaction,
  ) async {
    const drives = 'SELECT id FROM garden_record WHERE "ownerId" = @user';
    const nodes = 'SELECT id FROM file_node WHERE "gardenId" IN ($drives)';
    const versions = 'SELECT id FROM file_version WHERE "nodeId" IN ($nodes)';
    final statements = [
      'DELETE FROM file_chunk WHERE "versionId" IN ($versions)',
      'DELETE FROM file_comment WHERE "nodeId" IN ($nodes) OR "authorId" = @user',
      'DELETE FROM file_lease WHERE "nodeId" IN ($nodes) OR "holderId" = @user',
      'DELETE FROM file_version WHERE "nodeId" IN ($nodes)',
      'DELETE FROM file_node WHERE "gardenId" IN ($drives)',
      'DELETE FROM drive_event WHERE "gardenId" IN ($drives)',
      'DELETE FROM filesystem_receipt WHERE "gardenId" IN ($drives)',
      'DELETE FROM drive_message WHERE "gardenId" IN ($drives)',
      'DELETE FROM conversation WHERE "gardenId" IN ($drives)',
      'DELETE FROM conversation_member WHERE "userId" = @user',
      'DELETE FROM chat_read WHERE "gardenId" IN ($drives) OR "userId" = @user',
      'DELETE FROM inbox_event WHERE "gardenId" IN ($drives) OR "userId" = @user',
      'DELETE FROM account_notification WHERE "gardenId" IN ($drives) OR "recipientEmail" = @email OR "invitationId" IN (SELECT id FROM drive_invitation WHERE "inviterId" = @user OR "recipientEmail" = @email)',
      'DELETE FROM drive_invitation WHERE "gardenId" IN ($drives) OR "recipientEmail" = @email OR "inviterId" = @user',
      'DELETE FROM garden_member WHERE "gardenId" IN ($drives) OR "userId" = @user',
      'DELETE FROM garden_record WHERE "ownerId" = @user',
      'UPDATE drive_message SET "authorId" = \'deleted\', username = \'Deleted account\' WHERE "authorId" = @user',
      'UPDATE conversation SET "creatorId" = (SELECT "ownerId" FROM garden_record WHERE id = conversation."gardenId"), "directKey" = NULL WHERE "creatorId" = @user',
      'DELETE FROM account_username WHERE "userId" = @user',
      'DELETE FROM account_deletion WHERE "userId" = @user',
    ];
    for (final sql in statements) {
      final parameters = <String, Object>{};
      if (sql.contains('@user')) parameters['user'] = user;
      if (sql.contains('@email')) parameters['email'] = email;
      await session.db.unsafeExecute(
        sql,
        parameters: QueryParameters.named(parameters),
        transaction: transaction,
      );
    }
  }
}
