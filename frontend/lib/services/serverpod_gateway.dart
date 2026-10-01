import 'package:garden_client/garden_client.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';

import '../model/account_info.dart';
import '../model/garden_info.dart';
import 'garden_gateway.dart';
import 'memory_auth_storage.dart';

class ServerpodGateway implements GardenGateway {
  ServerpodGateway(String serverUrl) : client = Client(serverUrl) {
    client.authSessionManager = FlutterAuthSessionManager(
      storage: MemoryAuthStorage(),
    );
  }
  final Client client;
  @override
  Future<AccountInfo?> restoreAccount() async {
    await client.auth.initialize();
    if (!client.auth.isAuthenticated) return null;
    return _account();
  }

  Future<AccountInfo> _account() async {
    final account = await client.garden.account();
    return AccountInfo(id: account.id, email: account.email);
  }

  @override
  Future<AccountInfo> signIn(String email, String password) async {
    final result = await client.emailIdp.login(
      email: email,
      password: password,
    );
    await client.auth.updateSignedInUser(result);
    return _account();
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
    await client.auth.updateSignedInUser(result);
    return _account();
  }

  @override
  Future<void> deleteDrive(int driveId) => client.garden.delete(driveId);
  @override
  Future<void> signOut() => client.auth.signOutDevice();
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
