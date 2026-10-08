import 'package:flutter_test/flutter_test.dart';

import 'dart:io';

import 'package:garden_flutter/services/local_session_storage.dart';
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
    'local sessions isolate windows, survive restart and remove on sign out',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'garden-session-test-',
      );
      addTearDown(() => directory.delete(recursive: true));
      final session = AuthSuccess(
        authStrategy: 'jwt',
        token: 'fixture',
        refreshToken: 'fixture-refresh',
        authUserId: UuidValue.fromString(
          '00000000-0000-4000-8000-000000000001',
        ),
        scopeNames: {},
      );
      final first = localSessionStorage(
        'https://example.test/',
        directory: directory,
      );
      final second = localSessionStorage(
        'https://example.test/',
        windowId: 'two',
        directory: directory,
      );
      await first.set(session);
      await second.set(session);
      expect(
        (await localSessionStorage(
          'https://example.test/',
          directory: directory,
        ).get())?.token,
        'fixture',
      );
      final files = await directory.list().toList();
      expect(files, hasLength(2));
      expect((await directory.stat()).mode & 511, 448);
      for (final file in files) {
        expect((await file.stat()).mode & 511, 384);
      }
      await second.set(null);
      expect(await second.get(), isNull);
      expect((await first.get())?.token, 'fixture');
      await first.set(null);
      expect(await directory.list().toList(), isEmpty);
    },
  );
  test('corrupt local session fails visibly', () async {
    final directory = await Directory.systemTemp.createTemp(
      'garden-session-corrupt-',
    );
    addTearDown(() => directory.delete(recursive: true));
    final files = LocalSessionFiles(directory: directory);
    await files.set('https://example.test/\u0000main', 'invalid');
    await expectLater(
      localSessionStorage('https://example.test/', directory: directory).get(),
      throwsA(isA<FormatException>()),
    );
  });
  test(
    'session persistence is opt-in and forgetting removes the token',
    () async {
      final store = StoredSession();
      final session = AuthSuccess(
        authStrategy: 'jwt',
        token: 'test-token',
        refreshToken: 'test-refresh',
        authUserId: UuidValue.fromString(
          '00000000-0000-4000-8000-000000000001',
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
          '00000000-0000-4000-8000-000000000001',
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
