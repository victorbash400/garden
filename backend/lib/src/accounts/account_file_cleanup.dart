import 'package:aws_client/s3.dart' as aws;
import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';
import '../files/multipart_object_store.dart';

class AccountFileCleanup {
  static Future<void> remove(Session session, String user) async {
    var cursor = 0;
    while (true) {
      final rows = await session.db.unsafeQuery('''
        SELECT v.id FROM file_version v
        JOIN file_node n ON n.id = v."nodeId"
        JOIN garden_record g ON g.id = n."gardenId"
        WHERE g."ownerId" = @user AND v.id > @cursor ORDER BY v.id LIMIT 128
      ''', parameters: QueryParameters.named({'user': user, 'cursor': cursor}));
      if (rows.isEmpty) return;
      for (final row in rows) {
        final id = row.single as int;
        final version = await FileVersion.db.findById(session, id);
        if (version == null) {
          throw StateError(
            'A file version disappeared during account cleanup.',
          );
        }
        if (!version.committed &&
            version.uploadId != null &&
            version.objectPath != null) {
          final store = MultipartObjectStore(session);
          try {
            try {
              await store.abort(version);
            } on aws.NoSuchUpload {
              /* Already completed or aborted. */
            }
          } finally {
            store.close();
          }
        }
        if (version.objectPath != null) {
          await _delete(session, version.objectPath!);
        }
        final chunks = await FileChunk.db.find(
          session,
          where: (row) => row.versionId.equals(id),
        );
        for (final chunk in chunks) {
          await _delete(session, 'versions/$id/${chunk.chunkIndex}');
        }
        cursor = id;
      }
    }
  }

  static Future<void> _delete(Session session, String path) async {
    if (await session.storage.fileExists(storageId: 'private', path: path)) {
      await session.storage.deleteFile(storageId: 'private', path: path);
    }
  }
}
