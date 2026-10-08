import 'dart:async';

import 'package:garden_client/garden_client.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';
import 'package:serverpod_flutter/serverpod_flutter.dart';

import '../model/account_info.dart';
import 'username_gateway.dart';
import 'session_gateway.dart';
import 'authenticated_client.dart';
import 'account_deletion_gateway.dart';
import 'chat_gateway.dart';
import '../model/garden_info.dart';
import 'garden_gateway.dart';
import 'sharing/drive_sharing_service.dart';
import 'session_auth_storage.dart';
import 'relaunch_session_gateway.dart';
import 'passkey_service.dart';

import 'package:shared_preferences/shared_preferences.dart';

class ServerpodGateway
    implements
        GardenGateway,
        SessionGateway,
        AccountDeletionGateway,
        RelaunchSessionGateway,
        SharingGateway,
        UsernameGateway,
        ChatGateway {
  ServerpodGateway(
    this.serverUrl, {
    String windowId = 'main',
    this.relaunchSession,
  }) : storage = SessionAuthStorage(serverUrl, windowId: windowId),
       savedEmailKey = windowId == 'main'
           ? 'garden.savedEmail.$serverUrl'
           : 'garden.savedEmail.$serverUrl.$windowId' {
    client = AuthenticatedClient(serverUrl, checkSession: _checkSession);
    client.authSessionManager = FlutterAuthSessionManager(storage: storage);
    client.connectivityMonitor = FlutterConnectivityMonitor();
  }
  @override
  late final DriveSharingService sharing = DriveSharingService(client);
  final String serverUrl;
  Map<String, Object?>? relaunchSession;

  @override
  Map<String, Object?> exportSession(AccountInfo? account) {
    final session = storage.value;
    if (account == null) return {};
    if (session == null) {
      throw StateError('The account session is unavailable.');
    }
    return {
      'serverUrl': serverUrl,
      'email': account.email,
      'auth': session.toJson(),
      'remember': storage.remember,
      'touchId': storage.touchId,
    };
  }

  @override
  Future<AccountInfo?> restoreRelaunch() async {
    final session = relaunchSession;
    relaunchSession = null;
    if (session == null || session.isEmpty) return null;
    if (session['serverUrl'] != serverUrl) {
      throw StateError('The relaunched account belongs to a different server.');
    }
    storage.value = AuthSuccess.fromJson(
      Map<String, dynamic>.from(session['auth'] as Map),
    );
    storage.remember = session['remember'] as bool;
    storage.touchId = session['touchId'] as bool;
    await client.auth.initialize();
    return await _account();
  }

  @override
  late final Client client;
  final _expired = StreamController<void>.broadcast(sync: true);
  bool _checkingSession = false;
  @override
  Stream<void> get sessionExpired => _expired.stream;

  Future<void> _checkSession() async {
    if (_checkingSession || !client.auth.isAuthenticated) return;
    _checkingSession = true;
    try {
      final result = await client.auth.refreshAuthKey(force: true);
      if (result == RefreshAuthKeyResult.failedOther) {
        throw StateError(
          'Could not verify your session. Check your connection and try again.',
        );
      }
      var valid = false;
      if (result != RefreshAuthKeyResult.failedUnauthorized) {
        try {
          valid = await client.modules.serverpod_auth_core.status.isSignedIn();
        } on ServerpodClientUnauthorized {
          valid = false;
        }
      }
      if (valid) return;
      await forgetSavedLogin();
      await client.auth.updateSignedInUser(null);
      _expired.add(null);
    } finally {
      _checkingSession = false;
    }
  }

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
    if (remember) await preferences.setString(savedEmailKey, account.username);
    return account;
  }

  Future<void> _storeSignIn(AuthSuccess result, bool remember) async {
    if (await savedLogin() != null) await forgetSavedLogin();
    storage.touchId = false;
    storage.remember = remember;
    await client.auth.updateSignedInUser(result);
  }

  Future<void> setTouchId(bool enabled, String username) async {
    await storage.setTouchId(enabled);
    await preferences.setString(savedEmailKey, username);
    await preferences.setBool(touchIdKey, enabled);
  }

  Future<AccountInfo> _account() async {
    final AccountDetails account;
    try {
      account = await client.garden.account();
    } on TypeError {
      throw StateError(
        'Garden’s account service needs an update. Retry after the service update finishes.',
      );
    }
    return AccountInfo(
      id: account.id,
      email: account.email,
      username: account.username,
    );
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
      throw StateError('Incorrect username, email or password.');
    }
    await _storeSignIn(result, remember);
    final account = await _account();
    if (remember) await preferences.setString(savedEmailKey, account.username);
    return account;
  }

  @override
  Future<AccountInfo> setUsername(String username) async {
    final value = await client.garden.setUsername(username);
    final account = AccountInfo(
      id: value.id,
      email: value.email,
      username: value.username,
    );
    if (storage.remember) {
      await preferences.setString(savedEmailKey, account.username);
    }
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
    await preferences.setString(savedEmailKey, account.username);
    return account;
  }

  @override
  Future<void> renameDrive(int driveId, String name) =>
      client.garden.rename(driveId, name);
  @override
  Future<void> deleteDrive(int driveId) => client.garden.delete(driveId);
  @override
  Future<void> deleteAccount(String email) async {
    await client.account.deleteAccount(email);
    await forgetSavedLogin();
    await client.auth.updateSignedInUser(null);
  }

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
  void dispose() {
    client.connectivityMonitor?.dispose();
    client.close();
    _expired.close();
  }
}
