import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart'
    as auth;

Future<AuthenticationInfo?> gardenAuthentication(
  Session session,
  String token,
) async {
  final identity = await AuthServices.instance.authenticationHandler(
    session,
    token,
  );
  if (identity == null) return null;
  final user = await auth.AuthUser.db.findById(
    session,
    UuidValue.fromString(identity.userIdentifier),
  );
  if (user == null || user.blocked) return null;
  return identity;
}
