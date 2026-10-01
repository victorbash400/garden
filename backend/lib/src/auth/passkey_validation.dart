import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:passkeys_server/passkeys_server.dart';

const passkeyHostname = 'garden.serverpod.space';

void validatePasskeyClient(ByteData value, String type) {
  final data =
      jsonDecode(
            utf8.decode(
              value.buffer.asUint8List(
                value.offsetInBytes,
                value.lengthInBytes,
              ),
            ),
          )
          as Map<String, dynamic>;
  if (data['type'] != type ||
      data['origin'] != 'https://$passkeyHostname' ||
      data['crossOrigin'] == true) {
    throw StateError('Invalid passkey origin or operation.');
  }
}

void validatePasskeyRegistration(ByteData attestation) {
  final (data,) = parseAttestationObject(
    attestation.buffer.asUint8List(
      attestation.offsetInBytes,
      attestation.lengthInBytes,
    ),
  );
  if (!data.userPresence || !data.userVerification) {
    throw StateError('Passkey verification is required.');
  }
}

void validatePasskeyAssertion(ByteData data) {
  final bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  if (bytes.length < 37 || (bytes[32] & 5) != 5) {
    throw StateError('Passkey verification is required.');
  }
  final hash = sha256.convert(utf8.encode(passkeyHostname)).bytes;
  for (var i = 0; i < hash.length; i++) {
    if (bytes[i] != hash[i]) throw StateError('Invalid passkey relying party.');
  }
}
