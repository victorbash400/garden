import 'dart:async';
import 'package:serverpod/serverpod.dart';
import '../files/drive_access.dart';
import '../generated/protocol.dart';
import 'inbox_entries.dart';
import 'inbox_journal.dart';
import 'inbox_reads.dart';
import '../conversations/conversation_access.dart';
import '../gardens/drive_permissions.dart';

class InboxEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;
  Future<InboxSnapshot> snapshot(Session session) async {
    final user = DriveAccess.user(session);
    final latest = await InboxEvent.db.findFirstRow(
      session,
      where: (row) => row.userId.equals(user),
      orderBy: (row) => row.id.desc(),
    );
    return InboxSnapshot(
      entries: await InboxEntries.list(session, user),
      cursor: latest?.id ?? 0,
    );
  }

  Future<void> seen(Session session, int id) async {
    final conversation = await ConversationAccess.require(session, id);
    final delivery = await session.db.transaction((transaction) async {
      await DriveAccess.lock(
        session,
        conversation.gardenId,
        transaction,
        capability: DriveCapability.read,
      );
      await ConversationAccess.require(session, id, transaction: transaction);
      return InboxReads.record(
        session,
        transaction,
        conversation.gardenId,
        id,
        onlyAdded: true,
      );
    });
    await delivery.publish(session);
  }

  Stream<InboxEvent> watch(Session session, int afterId) async* {
    if (afterId < 0) throw GardenException(message: 'Invalid inbox cursor.');
    final user = DriveAccess.user(session);
    final changes = StreamIterator(
      session.messages.createStream<InboxEvent>(InboxJournal.channel(user)),
    );
    var cursor = afterId;
    Future<List<InboxEvent>> pending() => InboxEvent.db.find(
      session,
      where: (row) => row.userId.equals(user) & (row.id > cursor),
      orderBy: (row) => row.id,
      limit: 200,
    );
    try {
      while (true) {
        var batch = await pending();
        while (batch.isNotEmpty) {
          for (final event in batch) {
            cursor = event.id!;
            yield event;
          }
          batch = await pending();
        }
        if (!await changes.moveNext()) break;
      }
    } finally {
      await changes.cancel();
    }
  }
}
