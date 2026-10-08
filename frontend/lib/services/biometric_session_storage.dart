import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';

ClientAuthSuccessStorage biometricSessionStorage(
  String serverUrl, {
  String windowId = 'main',
}) => _UnavailableBiometricStorage();

class _UnavailableBiometricStorage implements ClientAuthSuccessStorage {
  @override
  Future<AuthSuccess?> get() async => throw StateError(
    'Saved Touch ID sessions are unavailable. Sign in with your password.',
  );

  @override
  Future<void> set(AuthSuccess? value) async {
    if (value != null) {
      throw StateError('Touch ID session storage is unavailable.');
    }
  }
}
