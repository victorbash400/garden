import 'package:passkeys/exceptions.dart';
import 'package:flutter/services.dart';
import 'package:garden_client/garden_client.dart';

String errorMessage(Object error) => switch (error) {
  PasskeyAuthCancelledException() => 'Passkey request canceled.',
  DomainNotAssociatedException() =>
    'Garden’s passkey domain is not associated with this signed app.',
  NoCredentialsAvailableException() =>
    'No Garden passkey found. Sign in with your password to add one.',
  ExcludeCredentialsCanNotBeRegisteredException() =>
    'This passkey is already registered.',
  PlatformException(code: '-128') => 'Authentication canceled.',
  StateError() => error.message,
  GardenException() => error.message,
  _ => error.toString(),
};
