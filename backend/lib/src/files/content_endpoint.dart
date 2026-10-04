import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import 'drive_access.dart';
import 'drive_journal.dart';
import 'multipart_object_store.dart';
import 'upload_cleanup_tasks.dart';

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
    if (baseVersion != 0 && baseVersion != node.version) {
      final base = await FileVersion.db.findById(session, baseVersion);
      if (base == null || base.nodeId != nodeId || !base.committed) {
        throw GardenException(
          message: 'This base file version is unavailable.',
        );
      }
    }
    final upload = await FileVersion.db.insertRow(
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
    await UploadCleanupTasks.schedule(session, upload.id!);
    return upload;
  }

  Future<FileVersion> beginMultipart(
    Session session,
    int nodeId,
    int baseVersion,
    int size,
  ) async {
    if (size <= chunkSize) {
      throw GardenException(message: 'Use chunk upload for small files.');
    }
    final store = MultipartObjectStore(session);
    try {
      await DriveAccess.node(session, nodeId);
      final pending = await FileVersion.db.findFirstRow(
        session,
        where: (row) =>
            row.nodeId.equals(nodeId) &
            row.authorId.equals(DriveAccess.user(session)) &
            row.baseVersion.equals(baseVersion) &
            row.size.equals(size) &
            row.committed.equals(false) &
            row.aborted.equals(false) &
            row.objectPath.notEquals(null),
        orderBy: (row) => row.createdAt.desc(),
      );
      if (pending != null &&
          pending.createdAt.isAfter(
            DateTime.now().toUtc().subtract(const Duration(hours: 23)),
          )) {
        return pending;
      }
      final version = await begin(session, nodeId, baseVersion, size);
      version.objectPath = 'objects/${version.id}/content';
      version.partSize = MultipartObjectStore.partSizeFor(size);
      version.chunkCount = (size + version.partSize! - 1) ~/ version.partSize!;
      version.uploadId = await store.begin(version.objectPath!);
      return await FileVersion.db.updateRow(session, version);
    } finally {
      store.close();
    }
  }

  Future<List<String>> uploadParts(
    Session session,
    int versionId,
    int first,
    int count,
  ) => session.db.transaction((transaction) async {
    final version = await _upload(session, versionId, transaction);
    if (version.objectPath == null || version.uploadId == null) {
      throw GardenException(
        message: 'This upload does not use multipart storage.',
      );
    }
    final store = MultipartObjectStore(session);
    try {
      return store.partUrls(version, first, count);
    } finally {
      store.close();
    }
  });

  Future<List<UploadedPart>> uploadedParts(Session session, int versionId) =>
      session.db.transaction((transaction) async {
        final version = await _upload(session, versionId, transaction);
        if (version.objectPath == null || version.uploadId == null) {
          throw GardenException(
            message: 'This upload does not use multipart storage.',
          );
        }
        final store = MultipartObjectStore(session);
        try {
          return (await store.parts(version)).map((part) {
            final number = part.partNumber;
            final size = part.size;
            final tag = part.eTag;
            if (number == null || size == null || tag == null) {
              throw StateError('Invalid S3 part metadata.');
            }
            return UploadedPart(
              number: number,
              size: size,
              checksum: tag.replaceAll('"', ''),
            );
          }).toList();
        } finally {
          store.close();
        }
      });

  Future<ContentDownload> download(
    Session session,
    int nodeId,
    int versionId,
  ) async {
    await DriveAccess.contentNode(session, nodeId);
    final version = await FileVersion.db.findById(session, versionId);
    if (version == null || version.nodeId != nodeId || !version.committed) {
      throw GardenException(
        message: 'This file version is unavailable.',
      );
    }
    if (version.objectPath == null) {
      return ContentDownload(
        size: version.size,
        expiresAt: DateTime.now().toUtc().add(const Duration(minutes: 15)),
      );
    }
    final store = MultipartObjectStore(session);
    try {
      return store.download(version);
    } finally {
      store.close();
    }
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
        version.aborted ||
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
    if (version.objectPath != null) {
      throw GardenException(
        message: 'This upload requires direct multipart transfers.',
      );
    }
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
    if (initial.committed) return original;
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
        var attempt = 0;
        var name = DriveAccess.conflictName(node.name, versionId, attempt);
        while (await FileNode.db.count(
              session,
              where: (row) =>
                  row.gardenId.equals(node.gardenId) &
                  row.parentId.equals(node.parentId) &
                  row.activeName.equals(name.toLowerCase()),
              transaction: transaction,
            ) !=
            0) {
          name = DriveAccess.conflictName(node.name, versionId, ++attempt);
        }
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
      if (version.objectPath != null) {
        final exists = await session.storage.fileExists(
          storageId: 'private',
          path: version.objectPath!,
        );
        if (!exists) {
          final store = MultipartObjectStore(session);
          try {
            await store.complete(version);
          } finally {
            store.close();
          }
        }
        final stat = await session.storage.statFile(
          storageId: 'private',
          path: version.objectPath!,
        );
        if (stat.size != version.size) {
          throw GardenException(
            message: 'The uploaded file size does not match.',
          );
        }
      } else {
        final count = await FileChunk.db.count(
          session,
          where: (row) => row.versionId.equals(versionId),
          transaction: transaction,
        );
        if (count != version.chunkCount) {
          throw GardenException(message: 'The upload is incomplete.');
        }
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
    final node = await DriveAccess.contentNode(session, nodeId);
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
    if (version.objectPath != null) {
      final store = MultipartObjectStore(session);
      try {
        return ByteData.sublistView(
          await store.read(version.objectPath!, offset, end - offset),
        );
      } finally {
        store.close();
      }
    }
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
