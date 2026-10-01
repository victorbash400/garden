import 'package:garden_client/garden_client.dart';
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart';

class MemoryAuthStorage implements ClientAuthSuccessStorage {
  AuthSuccess? value;
  @override
  Future<AuthSuccess?> get() async => value;
  @override
  Future<void> set(AuthSuccess? data) async {
    value = data;
  }
}

Future<void> main() async {
  final client = Client('http://localhost:8080/');
  final auth = ClientAuthSessionManager(
    storage: MemoryAuthStorage(),
    caller: client.modules.serverpod_auth_core,
  );
  client.authKeyProvider = auth;
  try {
    final result = await client.emailIdp.login(
      email: 'demo@garden.local',
      password: 'garden-demo',
    );
    await auth.updateSignedInUser(result);
    final account = await client.garden.account();
    if (account.email != 'demo@garden.local') {
      throw StateError('Unexpected demo account.');
    }
    final gardens = await client.garden.list();
    for (final drive in gardens) {
      final connected = await client.garden.connect(drive.id);
      if (connected.id != drive.id) {
        throw StateError('Drive connection mismatch.');
      }
    }
    print(
      'Demo login verified; authenticated membership list returned ${gardens.length} drives.',
    );
    await auth.signOutDevice();
  } finally {
    client.close();
  }
}
