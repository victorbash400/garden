import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';

class UploadCleanup {
  static Future<void> expire(Session session, int versionId) async {
    final expired = await session.db.transaction((transaction) async {
      final version = await FileVersion.db.findById(
        session,
        versionId,
        transaction: transaction,
        lockMode: LockMode.forUpdate,
      );
      if (version == null || version.committed) return false;
      version.aborted = true;
      await FileVersion.db.updateRow(
        session,
        version,
        transaction: transaction,
      );
      return true;
    });
    if (!expired) return;
    final chunks = await FileChunk.db.find(
      session,
      where: (row) => row.versionId.equals(versionId),
    );
    for (final chunk in chunks) {
      final path = 'versions/$versionId/${chunk.chunkIndex}';
      if (await session.storage.fileExists(storageId: 'private', path: path)) {
        await session.storage.deleteFile(storageId: 'private', path: path);
      }
    }
    await session.db.transaction((transaction) async {
      await FileChunk.db.deleteWhere(
        session,
        where: (row) => row.versionId.equals(versionId),
        transaction: transaction,
      );
      await FileVersion.db.deleteWhere(
        session,
        where: (row) => row.id.equals(versionId) & row.aborted.equals(true),
        transaction: transaction,
      );
    });
  }
}
