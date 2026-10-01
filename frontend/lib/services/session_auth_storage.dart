import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';

class SessionAuthStorage implements ClientAuthSuccessStorage {
  SessionAuthStorage(String serverUrl, {ClientAuthSuccessStorage? persistent})
    : persistent =
          persistent ??
          SecureClientAuthSuccessStorage(
            authSuccessStorageKey: 'garden.session.$serverUrl',
            secureStorage: const FlutterSecureStorage(
              mOptions: MacOsOptions(
                accountName: 'Garden',
                usesDataProtectionKeychain: false,
                accessibility: KeychainAccessibility.first_unlock_this_device,
                synchronizable: false,
              ),
            ),
          );
  final ClientAuthSuccessStorage persistent;
  bool remember = false;
  AuthSuccess? value;
  @override
  Future<AuthSuccess?> get() async => remember ? persistent.get() : value;
  @override
  Future<void> set(AuthSuccess? session) async {
    if (remember) await persistent.set(session);
    value = session;
  }

  Future<void> forget() async {
    await persistent.set(null);
    remember = false;
    value = null;
  }
}
