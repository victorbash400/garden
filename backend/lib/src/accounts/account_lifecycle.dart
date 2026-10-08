import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';

class AccountLifecycle {
  static Future<void> lock(
    Session session,
    String user,
    Transaction transaction,
  ) => session.db
      .unsafeQuery(
        'SELECT pg_advisory_xact_lock(hashtextextended(@user, 712493))',
        parameters: QueryParameters.named({'user': user}),
        transaction: transaction,
      )
      .then((_) {});

  static Future<void> requireActive(
    Session session,
    String user, {
    Transaction? transaction,
  }) async {
    final deleting = await AccountDeletion.db.findFirstRow(
      session,
      where: (row) => row.userId.equals(user),
      transaction: transaction,
    );
    if (deleting != null) {
      throw GardenException(
        message:
            'Account deletion is in progress. Retry Delete account to finish.',
      );
    }
  }
}
