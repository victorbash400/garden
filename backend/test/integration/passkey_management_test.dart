import 'dart:typed_data';
import 'dart:convert';
import 'package:serverpod_auth_idp_server/core.dart';
import 'package:test/test.dart';
import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Passkey ownership', (builder, endpoints) {
    test('only the owner can list or remove a registered key', () async {
      final session = builder.build();
      final owner = await AuthUser.db.insertRow(
        session,
        AuthUser(scopeNames: {}),
      );
      final other = await AuthUser.db.insertRow(
        session,
        AuthUser(scopeNames: {}),
      );
      final authenticated = builder.copyWith(
        authentication: AuthenticationOverride.authenticationInfo(
          owner.id!.toString(),
          {},
        ),
      );
      final stranger = builder.copyWith(
        authentication: AuthenticationOverride.authenticationInfo(
          other.id!.toString(),
          {},
        ),
      );
      final data = ByteData.sublistView(Uint8List.fromList([1, 2, 3]));
      final key = await PasskeyAccount.db.insertRow(
        session,
        PasskeyAccount(
          authUserId: owner.id!,
          keyId: data,
          keyIdBase64: base64Encode([1, 2, 3]),
          clientDataJSON: data,
          attestationObject: data,
          originalChallenge: data,
        ),
      );
      expect(
        (await endpoints.passkeyIdp.listKeys(authenticated)).single.id,
        key.id,
      );
      expect(await endpoints.passkeyIdp.listKeys(stranger), isEmpty);
      await expectLater(
        endpoints.passkeyIdp.listKeys(builder),
        throwsStateError,
      );
      await expectLater(
        endpoints.passkeyIdp.removeKey(builder, key.id!),
        throwsStateError,
      );
      await endpoints.passkeyIdp.removeKey(stranger, key.id!);
      expect(await PasskeyAccount.db.findById(session, key.id!), isNotNull);
      await endpoints.passkeyIdp.removeKey(authenticated, key.id!);
      expect(await PasskeyAccount.db.findById(session, key.id!), isNull);
    });
  });
}
