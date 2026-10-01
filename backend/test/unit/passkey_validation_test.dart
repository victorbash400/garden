import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:test/test.dart';
import 'package:garden_server/src/auth/passkey_validation.dart';

void main() {
  ByteData client(String origin, String type, {bool crossOrigin = false}) =>
      ByteData.sublistView(
        Uint8List.fromList(
          utf8.encode(
            jsonEncode({
              'origin': origin,
              'type': type,
              'crossOrigin': crossOrigin,
            }),
          ),
        ),
      );
  test(
    'rejects foreign origins, incorrect ceremonies and embedded requests',
    () {
      validatePasskeyClient(
        client('https://garden.serverpod.space', 'webauthn.get'),
        'webauthn.get',
      );
      for (final value in [
        client('https://other.example', 'webauthn.get'),
        client('https://garden.serverpod.space', 'webauthn.create'),
        client(
          'https://garden.serverpod.space',
          'webauthn.get',
          crossOrigin: true,
        ),
      ]) {
        expect(
          () => validatePasskeyClient(value, 'webauthn.get'),
          throwsStateError,
        );
      }
    },
  );
  test('requires verified presence and the Garden relying party hash', () {
    final bytes = Uint8List.fromList([
      ...sha256.convert(utf8.encode(passkeyHostname)).bytes,
      5,
      0,
      0,
      0,
      0,
    ]);
    validatePasskeyAssertion(ByteData.sublistView(bytes));
    bytes[32] = 1;
    expect(
      () => validatePasskeyAssertion(ByteData.sublistView(bytes)),
      throwsStateError,
    );
    bytes[32] = 5;
    bytes[0] ^= 1;
    expect(
      () => validatePasskeyAssertion(ByteData.sublistView(bytes)),
      throwsStateError,
    );
  });
}
