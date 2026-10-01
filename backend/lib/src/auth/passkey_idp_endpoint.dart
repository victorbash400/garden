import 'dart:typed_data';
import 'passkey_validation.dart';
import 'package:serverpod_auth_idp_server/core.dart';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/providers/passkey.dart';

class PasskeyIdpEndpoint extends PasskeyIdpBaseEndpoint {
  @override
  Future<void> register(
    Session session, {
    required PasskeyRegistrationRequest registrationRequest,
  }) async {
    if (session.authenticated == null) {
      throw StateError('Sign in to add a passkey.');
    }
    validatePasskeyClient(
      registrationRequest.clientDataJSON,
      'webauthn.create',
    );
    validatePasskeyRegistration(registrationRequest.attestationObject);
    await super.register(session, registrationRequest: registrationRequest);
  }

  @override
  Future<AuthSuccess> login(
    Session session, {
    required PasskeyLoginRequest loginRequest,
  }) async {
    validatePasskeyClient(loginRequest.clientDataJSON, 'webauthn.get');
    validatePasskeyAssertion(loginRequest.authenticatorData);
    return super.login(session, loginRequest: loginRequest);
  }

  Future<List<({UuidValue id, DateTime createdAt, ByteData keyId})>> listKeys(
    Session session,
  ) async {
    final userId = session.authenticated?.authUserId;
    if (userId == null) throw StateError('Sign in to manage passkeys.');
    final keys = await PasskeyAccount.db.find(
      session,
      where: (t) => t.authUserId.equals(userId),
      orderBy: (t) => t.createdAt,
    );
    return keys
        .map(
          (key) => (
            id: key.id!,
            createdAt: key.createdAt,
            keyId: key.keyId,
          ),
        )
        .toList();
  }

  Future<void> removeKey(Session session, UuidValue id) async {
    final userId = session.authenticated?.authUserId;
    if (userId == null) throw StateError('Sign in to manage passkeys.');
    await PasskeyAccount.db.deleteWhere(
      session,
      where: (t) => t.id.equals(id) & t.authUserId.equals(userId),
    );
  }
}
