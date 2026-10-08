import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:garden_flutter/components/error_notice.dart';
import 'package:garden_flutter/services/session_gateway.dart';
import 'package:garden_flutter/services/serverpod_gateway.dart';
import 'package:garden_flutter/state/garden_controller.dart';
import 'package:garden_flutter/ui/garden_theme.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import 'session_auth_storage_test.dart' show StoredSession;
import 'widget_test.dart' show TestGateway, MemoryPreferences, TestFinder;

class RefreshFixture implements RefresherClientAuthKeyProvider {
  RefreshFixture(this.result);
  RefreshAuthKeyResult result;
  @override
  Future<String?> get authHeaderValue async => 'Bearer fixture';
  @override
  Future<RefreshAuthKeyResult> refreshAuthKey({bool force = false}) async =>
      result;
}

class ExpiryFixture extends TestGateway implements SessionGateway {
  final events = StreamController<void>.broadcast(sync: true);
  @override
  Stream<void> get sessionExpired => events.stream;
}

class BusyFinder extends TestFinder {
  @override
  Future<void> signOut(account) async =>
      throw StateError('Close open files, then try again.');
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    HttpOverrides.global = null;
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });
  for (final result in [
    RefreshAuthKeyResult.failedUnauthorized,
    RefreshAuthKeyResult.failedOther,
  ]) {
    test('final RPC rejection with refresh $result', () async {
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      addTearDown(() => server.close(force: true));
      server.listen((request) async {
        await request.drain<void>();
        request.response.statusCode = 401;
        await request.response.close();
      });
      final gateway = ServerpodGateway('http://127.0.0.1:${server.port}/');
      addTearDown(gateway.dispose);
      final storage = StoredSession();
      gateway.client.authSessionManager = FlutterAuthSessionManager(
        storage: storage,
        authKeyProviderDelegates: {'jwt': RefreshFixture(result)},
      );
      await gateway.client.auth.updateSignedInUser(
        AuthSuccess(
          authStrategy: 'jwt',
          token: 'fixture',
          refreshToken: 'fixture',
          authUserId: UuidValue.fromString(
            '00000000-0000-4000-8000-000000000001',
          ),
          scopeNames: {},
        ),
      );
      var expired = 0;
      final subscription = gateway.sessionExpired.listen((_) => expired++);
      addTearDown(subscription.cancel);
      if (result == RefreshAuthKeyResult.failedUnauthorized) {
        await expectLater(
          gateway.listGardens(),
          throwsA(isA<ServerpodClientUnauthorized>()),
        );
        expect(expired, 1);
        expect(gateway.client.auth.isAuthenticated, isFalse);
        expect(storage.value, isNull);
      } else {
        await expectLater(gateway.listGardens(), throwsA(isA<StateError>()));
        expect(expired, 0);
        expect(gateway.client.auth.isAuthenticated, isTrue);
        expect(storage.value, isNotNull);
      }
    });
  }
  testWidgets('expired session has only Sign in and clears cached account', (
    tester,
  ) async {
    final gateway = ExpiryFixture();
    final finder = TestFinder();
    final controller = GardenController(
      gateway,
      MemoryPreferences(),
      finder: finder,
    );
    addTearDown(controller.dispose);
    addTearDown(gateway.events.close);
    await controller.signIn('fixture@example.test', 'fixture');
    finder.mountedDriveIDs.add(1);
    await tester.pumpWidget(
      MaterialApp(
        theme: GardenTheme.light,
        home: ListenableBuilder(
          listenable: controller,
          builder: (context, _) => Scaffold(
            body: controller.error == null
                ? Text(controller.page.name)
                : ErrorNotice(
                    message: controller.error!,
                    dismissLabel: 'Sign in',
                    canDismiss: false,
                    onDismiss: controller.acknowledgeSessionExpiry,
                  ),
          ),
        ),
      ),
    );
    gateway.events.add(null);
    await tester.pumpAndSettle();
    expect(controller.account, isNull);
    expect(controller.gardens, isEmpty);
    expect(controller.page, GardenPage.signIn);
    expect(finder.mountedDriveIDs, isEmpty);
    expect(find.text('OK'), findsNothing);
    expect(find.text('Sign in'), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Sign in'), findsOneWidget);
    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();
    expect(controller.sessionExpired, isFalse);
    expect(find.text('signIn'), findsOneWidget);
  });
  testWidgets('auth rejection replaces an already open error', (tester) async {
    var expired = false;
    var dismissed = false;
    late StateSetter update;
    await tester.pumpWidget(
      MaterialApp(
        theme: GardenTheme.light,
        home: StatefulBuilder(
          builder: (context, setState) {
            update = setState;
            return Scaffold(
              body: ErrorNotice(
                message: 'Please sign in again to continue.',
                dismissLabel: expired ? 'Sign in' : 'OK',
                canDismiss: !expired,
                onDismiss: () => dismissed = true,
              ),
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('OK'), findsOneWidget);
    update(() => expired = true);
    await tester.pumpAndSettle();
    expect(dismissed, isFalse);
    expect(find.text('OK'), findsNothing);
    expect(find.text('Sign in'), findsOneWidget);
    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();
    expect(dismissed, isTrue);
  });
  test('busy Finder cannot leave an expired account active', () async {
    final gateway = ExpiryFixture();
    final controller = GardenController(
      gateway,
      MemoryPreferences(),
      finder: BusyFinder(),
    );
    await controller.signIn('fixture@example.test', 'fixture');
    gateway.events.add(null);
    await Future<void>.delayed(Duration.zero);
    expect(controller.account, isNull);
    expect(controller.page, GardenPage.signIn);
    expect(controller.error, contains('Close open files'));
    controller.dispose();
    await gateway.events.close();
  });
}
