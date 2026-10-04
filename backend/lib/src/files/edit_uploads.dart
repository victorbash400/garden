import 'dart:convert';

import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import 'drive_access.dart';
import 'multipart_object_store.dart';
import 'upload_cleanup_tasks.dart';

class EditUploads {
  static const chunkSize = 256 * 1024;

  static Future<FileVersion> begin(
    Session session,
    int nodeId,
    int baseVersion,
    int size,
    UuidValue operationId, {
    DateTime? modifiedAt,
  }) async {
    if (size < 0 || size > 1 << 40) {
      throw GardenException(message: 'Invalid file size.');
    }
    if (modifiedAt != null &&
        (modifiedAt.year < 1970 || modifiedAt.year > 9999)) {
      throw GardenException(message: 'Invalid modification date.');
    }
    final request = jsonEncode([
      nodeId,
      baseVersion,
      size,
      if (modifiedAt != null) modifiedAt.toUtc().toIso8601String(),
    ]);
    final author = DriveAccess.user(session);
    final receipt = await FileVersion.db.findFirstRow(
      session,
      where: (row) =>
          row.authorId.equals(author) & row.operationId.equals(operationId),
    );
    if (receipt != null) {
      _sameRequest(receipt, request);
      if (receipt.committed) {
        await DriveAccess.contentNode(session, receipt.nodeId);
        return receipt;
      }
    }
    final original = await DriveAccess.node(session, nodeId);
    return session.db.transaction((transaction) async {
      await DriveAccess.lock(session, original.gardenId, transaction);
      final node = await DriveAccess.node(
        session,
        nodeId,
        transaction: transaction,
      );
      if (node.kind != NodeKind.file) {
        throw GardenException(message: 'Choose a file to edit.');
      }
      final existing = await FileVersion.db.findFirstRow(
        session,
        where: (row) =>
            row.authorId.equals(author) & row.operationId.equals(operationId),
        transaction: transaction,
        lockMode: LockMode.forUpdate,
      );
      if (existing != null) {
        _sameRequest(existing, request);
        if (existing.committed ||
            (!existing.aborted &&
                existing.createdAt.isAfter(
                  DateTime.now().toUtc().subtract(const Duration(hours: 23)),
                ))) {
          return existing;
        }
        existing.operationId = null;
        existing.editRequest = null;
        existing.aborted = true;
        await FileVersion.db.updateRow(
          session,
          existing,
          transaction: transaction,
        );
      }
      if (baseVersion != 0) {
        final base = await FileVersion.db.findById(
          session,
          baseVersion,
          transaction: transaction,
        );
        if (base == null || base.nodeId != nodeId || !base.committed) {
          throw GardenException(
            message: 'This base file version is unavailable.',
          );
        }
      }
      var upload = await FileVersion.db.insertRow(
        session,
        FileVersion(
          nodeId: nodeId,
          authorId: author,
          baseVersion: baseVersion,
          size: size,
          chunkCount: (size + chunkSize - 1) ~/ chunkSize,
          operationId: operationId,
          editRequest: request,
          modifiedAt: modifiedAt?.toUtc(),
          createdAt: DateTime.now().toUtc(),
        ),
        transaction: transaction,
      );
      if (size > chunkSize) {
        final store = MultipartObjectStore(session);
        try {
          upload.objectPath = 'objects/${upload.id}/content';
          upload.partSize = MultipartObjectStore.partSizeFor(size);
          upload.chunkCount = (size + upload.partSize! - 1) ~/ upload.partSize!;
          upload.uploadId = await store.begin(upload.objectPath!);
          upload = await FileVersion.db.updateRow(
            session,
            upload,
            transaction: transaction,
          );
        } finally {
          store.close();
        }
      }
      await UploadCleanupTasks.schedule(session, upload.id!);
      return upload;
    });
  }

  static void _sameRequest(FileVersion version, String request) {
    if (version.editRequest != request) {
      throw GardenException(
        message: 'This edit identifier was already used for different data.',
      );
    }
  }
}
