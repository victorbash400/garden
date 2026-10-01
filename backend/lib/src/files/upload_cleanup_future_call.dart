import 'package:serverpod/serverpod.dart';
import 'upload_cleanup.dart';

class UploadCleanupFutureCall extends FutureCall {
  Future<void> expire(Session session, int versionId) =>
      UploadCleanup.expire(session, versionId);
}
