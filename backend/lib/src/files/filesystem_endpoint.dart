import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';
import 'drive_access.dart';
import 'drive_journal.dart';
import 'filesystem_mutations.dart';
import 'filesystem_paths.dart';

class FilesystemEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  Future<List<DriveEvent>> mutate(
    Session session,
    int gardenId,
    FilesystemRequest request,
  ) async {
    if ((request.operation != FilesystemOperation.rename &&
            (request.destination != null || request.noReplace)) ||
        (request.operation != FilesystemOperation.setAttributes &&
            request.createdAt != null)) {
      FilesystemPaths.fail(
        FilesystemError.invalid,
        'Unexpected filesystem arguments.',
      );
    }
    final events = await session.db.transaction((transaction) async {
      GardenRecord drive;
      try {
        drive = await DriveAccess.lock(session, gardenId, transaction);
      } on GardenException {
        FilesystemPaths.fail(
          FilesystemError.accessDenied,
          'Drive access denied.',
        );
      }
      final author = DriveAccess.user(session);
      final receipt = await FilesystemReceipt.db.findFirstRow(
        session,
        where: (row) =>
            row.gardenId.equals(gardenId) &
            row.authorId.equals(author) &
            row.operationId.equals(request.operationId),
        transaction: transaction,
      );
      if (receipt != null) {
        final original = receipt.request;
        if (original.operation != request.operation ||
            original.path != request.path ||
            original.destination != request.destination ||
            original.noReplace != request.noReplace ||
            original.createdAt != request.createdAt) {
          FilesystemPaths.fail(
            FilesystemError.invalid,
            'Operation ID was reused with different arguments.',
          );
        }
        return receipt.events;
      }
      final events = await FilesystemMutations(
        session,
        drive,
        transaction,
      ).apply(request);
      await FilesystemReceipt.db.insertRow(
        session,
        FilesystemReceipt(
          gardenId: gardenId,
          authorId: author,
          request: request,
          operationId: request.operationId,
          events: events,
        ),
        transaction: transaction,
      );
      return events;
    });
    for (final event in events) {
      await DriveJournal.publish(session, event);
    }
    return events;
  }
}
