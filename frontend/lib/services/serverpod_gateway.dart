import 'package:garden_client/garden_client.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';

import '../model/account_info.dart';
import '../model/garden_info.dart';
import 'garden_gateway.dart';
import 'session_auth_storage.dart';
import 'passkey_service.dart';

import 'package:shared_preferences/shared_preferences.dart';

class ServerpodGateway implements GardenGateway {
  ServerpodGateway(String serverUrl, {String windowId = 'main'})
    : client = Client(serverUrl),
      storage = SessionAuthStorage(serverUrl, windowId: windowId),
      savedEmailKey = windowId == 'main'
          ? 'garden.savedEmail.$serverUrl'
          : 'garden.savedEmail.$serverUrl.$windowId' {
    client.authSessionManager = FlutterAuthSessionManager(storage: storage);
  }
  final Client client;
  final SessionAuthStorage storage;
  final String savedEmailKey;
  String get touchIdKey => '$savedEmailKey.touchId';
  final preferences = SharedPreferencesAsync();
  @override
  Future<String?> savedLogin() => preferences.getString(savedEmailKey);
  @override
  Future<void> forgetSavedLogin() async {
    storage.touchId = await preferences.getBool(touchIdKey) ?? false;
    await storage.forget();
    await preferences.remove(savedEmailKey);
    await preferences.remove(touchIdKey);
  }

  @override
  Future<AccountInfo?> restoreAccount() async {
    storage.touchId = await preferences.getBool(touchIdKey) ?? false;
    storage.remember = true;
    await client.auth.initialize();
    if (!client.auth.isAuthenticated) return null;
    try {
      return await _account();
    } on ServerpodClientUnauthorized {
      return null;
    }
  }

  Future<AccountInfo> signInWithPasskey({required bool remember}) async {
    final result = await PasskeyService(client).signIn();
    await _storeSignIn(result, remember);
    final account = await _account();
    if (remember) await preferences.setString(savedEmailKey, account.email);
    return account;
  }

  Future<void> _storeSignIn(AuthSuccess result, bool remember) async {
    if (await savedLogin() != null) await forgetSavedLogin();
    storage.touchId = false;
    storage.remember = remember;
    await client.auth.updateSignedInUser(result);
  }

  Future<void> setTouchId(bool enabled, String email) async {
    await storage.setTouchId(enabled);
    await preferences.setString(savedEmailKey, email);
    await preferences.setBool(touchIdKey, enabled);
  }

  Future<AccountInfo> _account() async {
    final account = await client.garden.account();
    return AccountInfo(id: account.id, email: account.email);
  }

  @override
  Future<AccountInfo> signIn(
    String email,
    String password, {
    bool remember = false,
  }) async {
    final AuthSuccess result;
    try {
      result = await client.emailIdp.login(email: email, password: password);
    } on ServerpodClientUnauthorized {
      throw StateError('Invalid email or password.');
    }
    await _storeSignIn(result, remember);
    final account = AccountInfo(
      id: result.authUserId.toString(),
      email: email.trim(),
    );
    if (remember) await preferences.setString(savedEmailKey, email);
    return account;
  }

  @override
  Future<String> beginRegistration(String email) async =>
      (await client.emailIdp.startRegistration(email: email)).toString();
  @override
  Future<AccountInfo> finishRegistration(
    String requestId,
    String code,
    String password,
  ) async {
    final token = await client.emailIdp.verifyRegistrationCode(
      accountRequestId: UuidValue.fromString(requestId),
      verificationCode: code,
    );
    final result = await client.emailIdp.finishRegistration(
      registrationToken: token,
      password: password,
    );
    await _storeSignIn(result, true);
    final account = await _account();
    await preferences.setString(savedEmailKey, account.email);
    return account;
  }

  @override
  Future<void> renameDrive(int driveId, String name) =>
      client.garden.rename(driveId, name);
  @override
  Future<void> deleteDrive(int driveId) => client.garden.delete(driveId);
  @override
  Future<void> signOut() async {
    await client.auth.signOutDevice();
    await forgetSavedLogin();
  }

  GardenInfo _garden(GardenSummary summary) => GardenInfo(
    id: summary.id,
    name: summary.name,
    role: summary.role,
    members: summary.members,
    invitationCode: summary.invitationCode,
  );
  @override
  Future<List<GardenInfo>> listGardens() async =>
      (await client.garden.list()).map(_garden).toList();
  @override
  Future<GardenInfo> createGarden(String name) async =>
      _garden(await client.garden.create(name));
  @override
  Future<GardenInfo> joinGarden(String code) async =>
      _garden(await client.garden.join(code));
  @override
  Future<GardenInfo> connect(int gardenId) async =>
      _garden(await client.garden.connect(gardenId));
  @override
  void dispose() => client.close();
}
