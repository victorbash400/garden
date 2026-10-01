import 'package:flutter_test/flutter_test.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';
import 'package:garden_flutter/services/session_auth_storage.dart';

class StoredSession implements ClientAuthSuccessStorage {
  AuthSuccess? value;
  int reads = 0;
  int writes = 0;
  @override
  Future<AuthSuccess?> get() async {
    reads++;
    return value;
  }

  @override
  Future<void> set(AuthSuccess? session) async {
    writes++;
    value = session;
  }
}

void main() {
  test(
    'session persistence is opt-in and forgetting removes the token',
    () async {
      final store = StoredSession();
      final session = AuthSuccess(
        authStrategy: 'jwt',
        token: 'test-token',
        refreshToken: 'test-refresh',
        authUserId: UuidValue.fromString(
          '00000000-0000-0000-0000-000000000001',
        ),
        scopeNames: {},
      );
      final storage = SessionAuthStorage(
        'https://example.test/',
        persistent: store,
      );
      await storage.set(session);
      expect(await storage.get(), session);
      expect(store.writes, 0);
      expect(store.reads, 0);
      storage.remember = true;
      await storage.set(session);
      final restarted = SessionAuthStorage(
        'https://example.test/',
        persistent: store,
      )..remember = true;
      expect(await restarted.get(), session);
      await restarted.forget();
      expect(await restarted.get(), isNull);
      expect(store.value, isNull);
    },
  );
}
