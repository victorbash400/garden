import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/providers/email.dart';
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart'
    as auth;
import '../generated/protocol.dart';

class EmailIdpEndpoint extends EmailIdpBaseEndpoint {
  @override
  Future<AuthSuccess> login(
    Session session, {
    required String email,
    required String password,
  }) async {
    var address = email.trim().toLowerCase();
    if (!address.contains('@')) {
      final identity = await AccountUsername.db.findFirstRow(
        session,
        where: (row) => row.username.equals(address),
      );
      final profile = identity == null
          ? null
          : await auth.UserProfile.db.findFirstRow(
              session,
              where: (row) =>
                  row.authUserId.equals(UuidValue.fromString(identity.userId)),
            );
      // The identity provider handles credential failures and throttling uniformly.
      address = profile?.email ?? 'unknown@garden.invalid';
    }
    return super.login(session, email: address, password: password);
  }
}
