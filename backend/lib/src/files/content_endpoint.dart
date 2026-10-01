import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';
import 'drive_access.dart';
import 'drive_journal.dart';

class ContentEndpoint extends Endpoint {
  static const chunkSize = 256 * 1024;
  @override
  bool get requireLogin => true;
  String _path(int version, int index) => 'versions/$version/$index';

  Future<FileVersion> begin(
    Session session,
    int nodeId,
    int baseVersion,
    int size,
  ) async {
    final node = await DriveAccess.node(session, nodeId);
    if (node.kind != NodeKind.file || size < 0 || size > 1 << 40) {
      throw GardenException(message: 'Invalid file size or type.');
    }
    if (baseVersion != node.version) {
      throw GardenException(
        message: 'This file changed. Reopen it before saving.',
      );
    }
    return FileVersion.db.insertRow(
      session,
      FileVersion(
        nodeId: nodeId,
        authorId: DriveAccess.user(session),
        baseVersion: baseVersion,
        size: size,
        chunkCount: (size + chunkSize - 1) ~/ chunkSize,
        createdAt: DateTime.now().toUtc(),
      ),
    );
  }

  Future<FileVersion> _upload(
    Session session,
    int id,
    Transaction transaction,
  ) async {
    final version = await FileVersion.db.findById(
      session,
      id,
      transaction: transaction,
      lockMode: LockMode.forUpdate,
    );
    if (version == null ||
        version.committed ||
        version.authorId != DriveAccess.user(session)) {
      throw GardenException(message: 'This upload is unavailable.');
    }
    await DriveAccess.node(session, version.nodeId, transaction: transaction);
    return version;
  }

  Future<void> writeChunk(
    Session session,
    int versionId,
    int index,
    ByteData data,
  ) => session.db.transaction((transaction) async {
    final version = await _upload(session, versionId, transaction);
    final expected = min(chunkSize, version.size - index * chunkSize);
    if (index < 0 ||
        index >= version.chunkCount ||
        data.lengthInBytes != expected) {
      throw GardenException(message: 'Invalid file chunk.');
    }
    final checksum = sha256
        .convert(
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
        )
        .toString();
    final existing = await FileChunk.db.findFirstRow(
      session,
      where: (row) =>
          row.versionId.equals(versionId) & row.chunkIndex.equals(index),
      transaction: transaction,
    );
    if (existing != null) {
      if (existing.checksum != checksum) {
        throw GardenException(message: 'An uploaded chunk cannot be replaced.');
      }
      return;
    }
    await session.storage.storeFile(
      storageId: 'private',
      path: _path(versionId, index),
      byteData: data,
    );
    await FileChunk.db.insertRow(
      session,
      FileChunk(
        versionId: versionId,
        chunkIndex: index,
        size: data.lengthInBytes,
        checksum: checksum,
      ),
      transaction: transaction,
    );
  });

  Future<FileNode> finish(Session session, int versionId) async {
    final initial = await FileVersion.db.findById(session, versionId);
    if (initial == null) {
      throw GardenException(message: 'This upload is unavailable.');
    }
    final original = await DriveAccess.node(session, initial.nodeId);
    final event = await session.db.transaction((transaction) async {
      final drive = await DriveAccess.lock(
        session,
        original.gardenId,
        transaction,
      );
      final version = await _upload(session, versionId, transaction);
      var node = await DriveAccess.node(
        session,
        version.nodeId,
        transaction: transaction,
      );
      final lease = await FileLease.db.findFirstRow(
        session,
        where: (row) => row.nodeId.equals(node.id!),
        transaction: transaction,
      );
      if (lease != null &&
          lease.expiresAt.isAfter(DateTime.now().toUtc()) &&
          lease.holderId != DriveAccess.user(session)) {
        throw GardenException(
          message:
              'Someone else is editing this file. Your upload is retained.',
        );
      }
      var operation = 'write';
      if (node.version != version.baseVersion) {
        final name = '${node.name} (conflict $versionId)';
        node = await FileNode.db.insertRow(
          session,
          FileNode(
            gardenId: node.gardenId,
            parentId: node.parentId,
            name: name,
            activeName: name.toLowerCase(),
            kind: NodeKind.file,
            updatedAt: DateTime.now().toUtc(),
          ),
          transaction: transaction,
        );
        version.nodeId = node.id!;
        operation = 'conflict';
      }
      final count = await FileChunk.db.count(
        session,
        where: (row) => row.versionId.equals(versionId),
        transaction: transaction,
      );
      if (count != version.chunkCount) {
        throw GardenException(message: 'The upload is incomplete.');
      }
      version.committed = true;
      await FileVersion.db.updateRow(
        session,
        version,
        transaction: transaction,
      );
      node.version = versionId;
      node.size = version.size;
      node.updatedAt = DateTime.now().toUtc();
      await FileNode.db.updateRow(session, node, transaction: transaction);
      return DriveJournal.append(session, drive, transaction, operation, node);
    });
    await DriveJournal.publish(session, event);
    return event.node!;
  }

  Future<ByteData> read(
    Session session,
    int nodeId,
    int versionId,
    int offset,
    int length,
  ) async {
    final node = await DriveAccess.node(session, nodeId);
    if (node.kind != NodeKind.file ||
        offset < 0 ||
        length < 0 ||
        length > chunkSize) {
      throw GardenException(message: 'Invalid read range.');
    }
    if (versionId == 0 && node.version == 0) return ByteData(0);
    final version = await FileVersion.db.findById(session, versionId);
    if (version == null || version.nodeId != nodeId || !version.committed) {
      throw GardenException(message: 'This file version is unavailable.');
    }
    final end = min(offset + length, version.size);
    if (offset >= end) return ByteData(0);
    final result = Uint8List(end - offset);
    var position = offset;
    while (position < end) {
      final index = position ~/ chunkSize;
      final data = await session.storage.retrieveFile(
        storageId: 'private',
        path: _path(versionId, index),
      );
      final bytes = data.buffer.asUint8List(
        data.offsetInBytes,
        data.lengthInBytes,
      );
      final start = position % chunkSize;
      final count = min(end - position, bytes.length - start);
      if (count <= 0) {
        throw GardenException(message: 'File content is incomplete.');
      }
      result.setRange(
        position - offset,
        position - offset + count,
        bytes,
        start,
      );
      position += count;
    }
    return ByteData.sublistView(result);
  }

  Future<List<FileVersion>> versions(Session session, int nodeId) async {
    await DriveAccess.node(session, nodeId);
    return FileVersion.db.find(
      session,
      where: (row) => row.nodeId.equals(nodeId) & row.committed.equals(true),
      orderBy: (row) => row.createdAt.desc(),
      limit: 100,
    );
  }
}
