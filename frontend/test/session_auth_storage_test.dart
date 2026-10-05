import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
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
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'Keychain tokens use independent ordinary and protected window keys',
    () async {
      const channel = MethodChannel(
        'plugins.it_nomads.com/flutter_secure_storage',
      );
      final messenger =
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
      final values = <String, String>{};
      messenger.setMockMethodCallHandler(channel, (call) async {
        final key = call.arguments['key'] as String;
        if (call.method == 'write') {
          values[key] = call.arguments['value'] as String;
        }
        if (call.method == 'delete') values.remove(key);
        if (call.method == 'read') return values[key];
        return null;
      });
      addTearDown(() => messenger.setMockMethodCallHandler(channel, null));
      final session = AuthSuccess(
        authStrategy: 'jwt',
        token: 'test',
        refreshToken: 'refresh',
        authUserId: UuidValue.fromString(
          '00000000-0000-0000-0000-000000000001',
        ),
        scopeNames: {},
      );
      final first = SessionAuthStorage('https://example.test/')
        ..remember = true;
      final second = SessionAuthStorage(
        'https://example.test/',
        windowId: 'two',
      )..remember = true;
      await first.set(session);
      await second.set(session);
      expect(
        values.keys,
        containsAll([
          'garden.session.https://example.test/',
          'garden.session.https://example.test/.two',
        ]),
      );
      await second.setTouchId(true);
      expect(
        values.containsKey('garden.session.https://example.test/'),
        isTrue,
      );
      expect(
        values.containsKey('garden.touchId.https://example.test/.two'),
        isTrue,
      );
      await second.forget();
      expect(values.keys, ['garden.session.https://example.test/']);
    },
  );
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
  test(
    'protected restore reads once and never reads the ordinary store',
    () async {
      final plain = StoredSession();
      final protected = StoredSession();
      final session = AuthSuccess(
        authStrategy: 'jwt',
        token: 'test',
        refreshToken: 'refresh',
        authUserId: UuidValue.fromString(
          '00000000-0000-0000-0000-000000000001',
        ),
        scopeNames: {},
      );
      final active = SessionAuthStorage(
        'https://example.test/',
        persistent: plain,
        protected: protected,
      );
      await active.set(session);
      await active.setTouchId(true);
      expect(protected.value, session);
      expect(plain.value, isNull);
      final restored =
          SessionAuthStorage(
              'https://example.test/',
              persistent: plain,
              protected: protected,
            )
            ..remember = true
            ..touchId = true;
      expect(await restored.get(), session);
      expect(await restored.get(), session);
      expect(protected.reads, 1);
      expect(plain.reads, 0);
      await restored.setTouchId(false);
      expect(plain.value, session);
      expect(protected.value, isNull);
      await restored.forget();
      expect(plain.value, isNull);
    },
  );
}
