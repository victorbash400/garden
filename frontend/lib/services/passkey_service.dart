import 'dart:convert';
import 'dart:typed_data';

import 'package:garden_client/garden_client.dart';
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart';
import 'package:passkeys/authenticator.dart';
import 'package:passkeys/types.dart';

class PasskeyService {
  PasskeyService(this.client);
  final Client client;
  final authenticator = PasskeyAuthenticator();
  static const hostname = 'garden.serverpod.space';
  String _encode(ByteData value) => base64UrlEncode(
    value.buffer.asUint8List(value.offsetInBytes, value.lengthInBytes),
  ).replaceAll('=', '');
  ByteData _decode(String value) =>
      ByteData.sublistView(base64Url.decode(base64Url.normalize(value)));

  Future<void> register(String userId, String email) async {
    final keys = await client.passkeyIdp.listKeys();
    final challenge = await client.passkeyIdp.createChallenge();
    final credential = await authenticator.register(
      RegisterRequestType(
        challenge: _encode(challenge.challenge),
        relyingParty: RelyingPartyType(id: hostname, name: 'Garden'),
        user: UserType(
          id: base64UrlEncode(utf8.encode(userId)),
          name: email,
          displayName: email,
        ),
        excludeCredentials: keys
            .map(
              (key) => CredentialType(
                transports: [],
                type: 'public-key',
                id: _encode(key.keyId),
              ),
            )
            .toList(),
        authSelectionType: AuthenticatorSelectionType(
          requireResidentKey: true,
          residentKey: 'required',
          userVerification: 'required',
        ),
      ),
    );
    await client.passkeyIdp.register(
      registrationRequest: PasskeyRegistrationRequest(
        challengeId: challenge.id,
        keyId: _decode(credential.rawId),
        clientDataJSON: _decode(credential.clientDataJSON),
        attestationObject: _decode(credential.attestationObject),
      ),
    );
  }

  Future<AuthSuccess> signIn() async {
    final challenge = await client.passkeyIdp.createChallenge();
    final credential = await authenticator.authenticate(
      AuthenticateRequestType(
        relyingPartyId: hostname,
        challenge: _encode(challenge.challenge),
        mediation: MediationType.Required,
        preferImmediatelyAvailableCredentials: false,
        userVerification: 'required',
      ),
    );
    return client.passkeyIdp.login(
      loginRequest: PasskeyLoginRequest(
        challengeId: challenge.id,
        keyId: _decode(credential.rawId),
        authenticatorData: _decode(credential.authenticatorData),
        clientDataJSON: _decode(credential.clientDataJSON),
        signature: _decode(credential.signature),
      ),
    );
  }
}
