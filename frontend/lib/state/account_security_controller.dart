import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:garden_client/garden_client.dart';

import '../model/account_info.dart';
import '../services/serverpod_gateway.dart';
import '../services/passkey_service.dart';
import '../utils/error_message.dart';

class AccountSecurityController extends ChangeNotifier {
  AccountSecurityController(this.gateway);
  final ServerpodGateway gateway;
  final biometrics = LocalAuthentication();
  List<({UuidValue id, DateTime createdAt, ByteData keyId})> keys = [];
  bool configured = false;
  bool available = false;
  Future<void> checkConfiguration() async {
    configured =
        await const MethodChannel('garden/native_auth')
            .invokeMethod<bool>('configured') ??
        false;
    touchId = await gateway.preferences.getBool(gateway.touchIdKey) ?? false;
    notifyListeners();
  }

  bool touchId = false;
  bool busy = false;
  String? error;
  String? status;

  Future<void> load() => _run(() async {
    await checkConfiguration();
    available = false;
    touchId = await gateway.preferences.getBool(gateway.touchIdKey) ?? false;
    keys = await gateway.client.passkeyIdp.listKeys();
  });
  Future<void> addPasskey(AccountInfo account) => _run(() async {
    if (!configured) throw StateError('Apple signing setup is required.');
    await PasskeyService(gateway.client).register(account.id, account.email);
    keys = await gateway.client.passkeyIdp.listKeys();
    status = 'Passkey added';
  });
  Future<void> removePasskey(UuidValue id) => _run(() async {
    await gateway.client.passkeyIdp.removeKey(id);
    keys = keys.where((key) => key.id != id).toList();
    status = 'Passkey removed';
  });
  Future<void> setTouchId(bool enabled, AccountInfo account) => _run(() async {
    if (!configured) throw StateError('Apple signing setup is required.');
    if (!available) {
      throw StateError('Set up Touch ID in macOS System Settings.');
    }
    final confirmed = await biometrics.authenticate(
      localizedReason: enabled
          ? 'Enable Touch ID for Garden sign-in'
          : 'Disable Touch ID for Garden sign-in',
      biometricOnly: true,
    );
    if (!confirmed) throw StateError('Touch ID was canceled.');
    await gateway.setTouchId(enabled, account.username);
    touchId = enabled;
    status = enabled ? 'Touch ID enabled on this Mac' : 'Touch ID disabled';
  });
  Future<void> _run(Future<void> Function() action) async {
    if (busy) return;
    busy = true;
    error = null;
    status = null;
    notifyListeners();
    try {
      await action();
    } catch (failure) {
      error = errorMessage(failure);
    } finally {
      busy = false;
      notifyListeners();
    }
  }
}
