import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';

ClientAuthSuccessStorage biometricSessionStorage(String serverUrl) =>
    SecureClientAuthSuccessStorage(
      authSuccessStorageKey: 'garden.touchId.$serverUrl',
      secureStorage: const FlutterSecureStorage(
        mOptions: MacOsOptions(
          accountName: 'Garden',
          usesDataProtectionKeychain: true,
          accessibility: KeychainAccessibility.unlocked_this_device,
          accessControlFlags: [AccessControlFlag.biometryCurrentSet],
          synchronizable: false,
        ),
      ),
    );
