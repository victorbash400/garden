import 'biometric_session_storage.dart';

import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';

class SessionAuthStorage implements ClientAuthSuccessStorage {
  SessionAuthStorage(
    String serverUrl, {
    String windowId = 'main',
    ClientAuthSuccessStorage? persistent,
    ClientAuthSuccessStorage? protected,
  }) : biometric =
           protected ?? biometricSessionStorage(serverUrl, windowId: windowId),
       persistent =
           persistent ??
           SecureClientAuthSuccessStorage(
             authSuccessStorageKey: windowId == 'main'
                 ? 'garden.session.$serverUrl'
                 : 'garden.session.$serverUrl.$windowId',
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
  final ClientAuthSuccessStorage biometric;
  bool touchId = false;
  bool remember = false;
  AuthSuccess? value;
  @override
  Future<AuthSuccess?> get() async {
    if (value != null || !remember) return value;
    value = await (touchId ? biometric : persistent).get();
    return value;
  }

  @override
  Future<void> set(AuthSuccess? session) async {
    if (remember) await (touchId ? biometric : persistent).set(session);
    value = session;
  }

  Future<void> setTouchId(bool enabled) async {
    if (value == null) throw StateError('Sign in before enabling Touch ID.');
    if (enabled) {
      await biometric.set(value);
      await persistent.set(null);
    } else {
      await persistent.set(value);
      await biometric.set(null);
    }
    touchId = enabled;
    remember = true;
  }

  Future<void> forget() async {
    await persistent.set(null);
    if (touchId) await biometric.set(null);
    touchId = false;
    remember = false;
    value = null;
  }
}
