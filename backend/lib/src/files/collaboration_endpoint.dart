import 'dart:convert';
import 'dart:math';
import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';
import 'drive_access.dart';
import 'drive_journal.dart';

class CollaborationEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  Future<List<FileComment>> comments(Session session, int nodeId) async {
    await DriveAccess.node(session, nodeId);
    return FileComment.db.find(
      session,
      where: (row) => row.nodeId.equals(nodeId),
      orderBy: (row) => row.createdAt,
      limit: 200,
    );
  }

  Future<FileComment> comment(Session session, int nodeId, String text) async {
    final clean = text.trim();
    if (clean.isEmpty || clean.length > 4000) {
      throw GardenException(
        message: 'Use a comment between 1 and 4000 characters.',
      );
    }
    final original = await DriveAccess.node(session, nodeId);
    late FileComment comment;
    final event = await session.db.transaction((transaction) async {
      final drive = await DriveAccess.lock(
        session,
        original.gardenId,
        transaction,
      );
      final node = await DriveAccess.node(
        session,
        nodeId,
        transaction: transaction,
      );
      comment = await FileComment.db.insertRow(
        session,
        FileComment(
          nodeId: nodeId,
          authorId: DriveAccess.user(session),
          text: clean,
          createdAt: DateTime.now().toUtc(),
        ),
        transaction: transaction,
      );
      return DriveJournal.append(session, drive, transaction, 'comment', node);
    });
    await DriveJournal.publish(session, event);
    return comment;
  }

  Future<FileLease> acquire(Session session, int nodeId) async {
    final original = await DriveAccess.node(session, nodeId);
    if (original.kind != NodeKind.file) {
      throw GardenException(message: 'Only files can be opened for editing.');
    }
    return session.db.transaction((transaction) async {
      await DriveAccess.lock(session, original.gardenId, transaction);
      final node = await DriveAccess.node(
        session,
        nodeId,
        transaction: transaction,
      );
      final now = DateTime.now().toUtc();
      final existing = await FileLease.db.findFirstRow(
        session,
        where: (row) => row.nodeId.equals(node.id!),
        transaction: transaction,
      );
      if (existing != null &&
          existing.expiresAt.isAfter(now) &&
          existing.holderId != DriveAccess.user(session)) {
        throw GardenException(message: 'Someone else is editing this file.');
      }
      if (existing != null) {
        existing.holderId = DriveAccess.user(session);
        existing.expiresAt = now.add(const Duration(minutes: 2));
        return FileLease.db.updateRow(
          session,
          existing,
          transaction: transaction,
        );
      }
      final random = Random.secure();
      return FileLease.db.insertRow(
        session,
        FileLease(
          nodeId: nodeId,
          holderId: DriveAccess.user(session),
          token: base64Url.encode(
            List.generate(24, (_) => random.nextInt(256)),
          ),
          expiresAt: now.add(const Duration(minutes: 2)),
        ),
        transaction: transaction,
      );
    });
  }

  Future<void> release(Session session, int nodeId, String token) async {
    final node = await DriveAccess.node(session, nodeId);
    await session.db.transaction((transaction) async {
      await DriveAccess.lock(session, node.gardenId, transaction);
      final lease = await FileLease.db.findFirstRow(
        session,
        where: (row) =>
            row.nodeId.equals(nodeId) &
            row.holderId.equals(DriveAccess.user(session)) &
            row.token.equals(token),
        transaction: transaction,
      );
      if (lease != null) {
        await FileLease.db.deleteRow(session, lease, transaction: transaction);
      }
    });
  }
}
