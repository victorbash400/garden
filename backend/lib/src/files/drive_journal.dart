import 'dart:async';
import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';
import 'drive_access.dart';

class DriveJournal {
  static String channel(int id) => 'drive_$id';

  static Future<DriveEvent> append(
    Session session,
    GardenRecord drive,
    Transaction transaction,
    String operation,
    FileNode node, {
    int? previousParentId,
  }) async {
    drive.revision++;
    await GardenRecord.db.updateRow(session, drive, transaction: transaction);
    return DriveEvent.db.insertRow(
      session,
      DriveEvent(
        gardenId: drive.id!,
        revision: drive.revision,
        operation: operation,
        authorId: DriveAccess.user(session),
        node: node,
        previousParentId: previousParentId,
        createdAt: DateTime.now().toUtc(),
      ),
      transaction: transaction,
    );
  }

  static Future<void> publish(Session session, DriveEvent event) async {
    await session.messages.postMessage(channel(event.gardenId), event);
  }

  static Stream<DriveEvent> watch(
    Session session,
    int gardenId,
    int afterRevision,
  ) async* {
    await DriveAccess.require(session, gardenId);
    if (afterRevision < 0) throw GardenException(message: 'Invalid revision.');
    final changes = StreamIterator(
      session.messages.createStream<DriveEvent>(channel(gardenId)),
    );
    var revision = afterRevision;
    Future<List<DriveEvent>> pending() => DriveEvent.db.find(
      session,
      where: (row) => row.gardenId.equals(gardenId) & (row.revision > revision),
      orderBy: (row) => row.revision,
      limit: 256,
    );
    // Register before replay so writes during catch-up stay buffered.
    try {
      var batch = await pending();
      while (batch.isNotEmpty) {
        for (final event in batch) {
          revision = event.revision;
          yield event;
        }
        batch = await pending();
      }
      yield DriveEvent(
        gardenId: gardenId,
        revision: revision,
        operation: 'ready',
        authorId: DriveAccess.user(session),
        createdAt: DateTime.now().toUtc(),
      );
      while (await changes.moveNext()) {
        final notification = changes.current;
        if (notification.revision <= revision) continue;
        await DriveAccess.require(session, gardenId);
        batch = await pending();
        while (batch.isNotEmpty) {
          for (final event in batch) {
            revision = event.revision;
            yield event;
          }
          batch = await pending();
        }
      }
    } finally {
      // Cancel an unconsumed stream when replay fails or its caller cancels.
      await changes.cancel();
    }
  }
}
