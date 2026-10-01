import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';
import 'upload_cleanup.dart';

class UploadCleanupRoute extends Route {
  final List<int> _tokenHash;

  UploadCleanupRoute(String token)
    : _tokenHash = sha256.convert(utf8.encode('Bearer $token')).bytes,
      super(methods: {Method.post});

  @override
  Future<Result> handleCall(Session session, Request request) async {
    final supplied = request.headers.authorization?.headerValue ?? '';
    final suppliedHash = sha256.convert(utf8.encode(supplied)).bytes;
    var difference = 0;
    for (var i = 0; i < _tokenHash.length; i++) {
      difference |= _tokenHash[i] ^ suppliedHash[i];
    }
    if (difference != 0) return Response.unauthorized();
    final id = int.tryParse(await request.readAsString(maxLength: 32));
    if (id == null || id <= 0) return Response.badRequest();
    final version = await FileVersion.db.findById(session, id);
    if (version != null &&
        !version.committed &&
        DateTime.now().toUtc().difference(version.createdAt) <
            const Duration(hours: 24)) {
      return Response(409);
    }
    await UploadCleanup.expire(session, id);
    return Response.ok();
  }
}
