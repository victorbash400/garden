import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';

class ChatPages {
  static Future<void> markThreads(
    Session session,
    List<DriveMessage> messages, {
    Transaction? transaction,
  }) async {
    if (messages.isEmpty) return;
    final rows = await session.db.unsafeQuery(
      'SELECT DISTINCT "replyToId" FROM "drive_message" '
      'WHERE "replyToId" = ANY(@ids::bigint[])',
      parameters: QueryParameters.named({
        'ids': messages.map((message) => message.id!).toList(),
      }),
      transaction: transaction,
    );
    final parents = rows.map((row) => row.first as int).toSet();
    for (final message in messages) {
      message.hasReplies = parents.contains(message.id);
    }
  }
}
