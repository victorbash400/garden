import 'dart:async' as async;

import 'package:passkeys/exceptions.dart';
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart';
import 'package:flutter/services.dart';
import 'package:garden_client/garden_client.dart';

String errorMessage(Object error) => switch (error) {
  EmailAccountLoginException() => switch (error.reason) {
    EmailAccountLoginExceptionReason.invalidCredentials =>
      'Incorrect username, email or password.',
    EmailAccountLoginExceptionReason.tooManyAttempts =>
      'Too many sign-in attempts. Please try again later.',
    EmailAccountLoginExceptionReason.unknown =>
      'Could not sign in. Please try again.',
  },
  EmailAccountRequestException() => switch (error.reason) {
    EmailAccountRequestExceptionReason.expired =>
      'The verification code has expired. Request a new code.',
    EmailAccountRequestExceptionReason.invalid =>
      'Incorrect verification code.',
    EmailAccountRequestExceptionReason.policyViolation =>
      'The password does not meet the account requirements.',
    EmailAccountRequestExceptionReason.tooManyAttempts =>
      'Too many attempts. Please try again later.',
    EmailAccountRequestExceptionReason.unknown =>
      'Could not verify the account. Please try again.',
  },
  async.TimeoutException() =>
    'Garden took too long to respond. Check your connection and try again.',
  ServerpodClientNetworkException() =>
    'Could not connect to Garden. Check your connection and try again.',
  ServerpodClientUnauthorized() => 'Please sign in again to continue.',
  ServerpodClientForbidden() => 'You do not have permission to do this.',
  ServerpodClientInternalServerError() =>
    'Garden could not complete the request. Please try again.',
  PasskeyAuthCancelledException() => 'Passkey request canceled.',
  DomainNotAssociatedException() =>
    'Garden’s passkey domain is not associated with this signed app.',
  NoCredentialsAvailableException() =>
    'No Garden passkey found. Sign in with your password to add one.',
  ExcludeCredentialsCanNotBeRegisteredException() =>
    'This passkey is already registered.',
  PlatformException(code: '-128') => 'Authentication canceled.',
  MissingPluginException() => 'Restart Garden to load the native controls.',
  PlatformException() =>
    error.message?.trim().isNotEmpty == true
        ? error.message!
        : 'The macOS request could not be completed. Try again.',
  StateError() => error.message,
  GardenException() => error.message,
  _ => 'The request could not be completed. Please try again.',
};
