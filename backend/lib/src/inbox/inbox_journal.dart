import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';

class InboxJournal {
  static String channel(String user) => 'inbox_$user';
  static Future<List<InboxEvent>> record(
    Session session,
    Transaction transaction,
    Iterable<String> users,
    int drive,
    int? conversation,
    String kind,
  ) async {
    final ids = users.toSet();
    if (ids.isEmpty) return [];
    return InboxEvent.db.insert(session, [
      for (final user in ids)
        InboxEvent(
          userId: user,
          gardenId: drive,
          conversationId: conversation,
          kind: kind,
          createdAt: DateTime.now().toUtc(),
        ),
    ], transaction: transaction);
  }

  static Future<void> publish(Session session, List<InboxEvent> events) async {
    for (final event in events) {
      await session.messages.postMessage(channel(event.userId), event);
    }
  }
}
