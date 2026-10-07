import 'dart:typed_data';

import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import 'bounded_range_reads.dart';
import 'drive_access.dart';
import 'multipart_object_store.dart';

class ContentRanges {
  static Future<List<ByteData>> read(
    Session session,
    int nodeId,
    int versionId,
    List<int> offsets,
    List<int> lengths,
  ) async {
    final node = await DriveAccess.contentNode(session, nodeId);
    final version = await FileVersion.db.findById(session, versionId);
    if (node.kind != NodeKind.file ||
        version == null ||
        version.nodeId != nodeId ||
        !version.committed ||
        version.objectPath == null) {
      throw GardenException(
        message: 'This file version cannot read metadata ranges.',
      );
    }
    final store = MultipartObjectStore(session);
    try {
      return await BoundedRangeReads.read(
        version.size,
        offsets,
        lengths,
        (offset, length) =>
            store.read(version.objectPath!, offset, length, version.size),
      );
    } finally {
      store.close();
    }
  }
}
