import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:garden_flutter/model/account_info.dart';
import 'package:garden_flutter/model/garden_info.dart';
import 'package:garden_flutter/services/garden_gateway.dart';
import 'package:garden_flutter/services/preferences_store.dart';
import 'package:garden_flutter/state/garden_controller.dart';
import 'package:garden_flutter/ui/garden_app.dart';

class MemoryPreferences implements PreferencesStore {
  int limit = 20;
  @override
  Future<int> readCacheLimit() async => limit;
  @override
  Future<void> saveCacheLimit(int gib) async {
    limit = gib;
  }
}

class TestGateway implements GardenGateway {
  bool fail = false;
  int calls = 0;
  @override
  Future<AccountInfo?> restoreAccount() async => null;
  @override
  Future<AccountInfo> signIn(String email, String password) async {
    calls++;
    if (fail) throw StateError('Cannot connect to the server.');
    return AccountInfo(id: 'account', email: email);
  }

  @override
  Future<String> beginRegistration(String email) async => 'request';
  @override
  Future<AccountInfo> finishRegistration(
    String requestId,
    String code,
    String password,
  ) async => const AccountInfo(id: 'account', email: 'garden@example.com');
  @override
  Future<void> signOut() async {}
  @override
  Future<List<GardenInfo>> listGardens() async => [];
  @override
  Future<GardenInfo> createGarden(String name) async => GardenInfo(
    id: 1,
    name: name,
    role: 'Owner',
    members: 1,
    invitationCode: 'invite',
  );
  @override
  Future<GardenInfo> joinGarden(String code) async =>
      const GardenInfo(id: 1, name: 'Shared', role: 'Member', members: 2);
  @override
  Future<GardenInfo> connect(int gardenId) async =>
      const GardenInfo(id: 1, name: 'Shared', role: 'Member', members: 2);
  @override
  void dispose() {}
}

void main() {
  testWidgets('Sign in submits credentials and opens Garden actions', (
    tester,
  ) async {
    final gateway = TestGateway();
    final controller = GardenController(gateway, MemoryPreferences());
    await tester.pumpWidget(GardenApp(controller: controller));
    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).at(0), 'garden@example.com');
    await tester.enterText(find.byType(TextField).at(1), 'password');
    await tester.pump();
    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();
    expect(gateway.calls, 1);
    expect(find.text('Create Garden'), findsOneWidget);
    expect(find.text('Join Garden'), findsOneWidget);
  });
  testWidgets('Connection failure remains visible without advancing', (
    tester,
  ) async {
    final gateway = TestGateway()..fail = true;
    final controller = GardenController(gateway, MemoryPreferences());
    controller.navigate(GardenPage.signIn);
    await tester.pumpWidget(GardenApp(controller: controller));
    await tester.enterText(find.byType(TextField).at(0), 'garden@example.com');
    await tester.enterText(find.byType(TextField).at(1), 'password');
    await tester.pump();
    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();
    expect(controller.page, GardenPage.signIn);
    expect(
      find.textContaining('Cannot connect to the server.'),
      findsOneWidget,
    );
  });
  test(
    'Registration, creation, connection, and sign-out preserve state',
    () async {
      final controller = GardenController(TestGateway(), MemoryPreferences());
      await controller.register('garden@example.com', 'password');
      expect(controller.page, GardenPage.verify);
      await controller.verify('123456');
      expect(controller.registrationPassword, isEmpty);
      await controller.create('Projects');
      expect(controller.selected!.invitationCode, 'invite');
      expect(controller.page, GardenPage.connected);
      await controller.signOut();
      expect(controller.account, isNull);
      expect(controller.selected, isNull);
      expect(controller.page, GardenPage.welcome);
    },
  );
}
