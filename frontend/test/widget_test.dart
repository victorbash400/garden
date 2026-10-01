import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:garden_flutter/model/account_info.dart';
import 'package:garden_flutter/model/garden_info.dart';
import 'package:garden_flutter/services/garden_gateway.dart';
import 'package:garden_flutter/services/preferences_store.dart';
import 'package:garden_flutter/state/garden_controller.dart';
import 'package:garden_flutter/ui/garden_app.dart';
import 'package:garden_flutter/components/garden_sidebar.dart';
import 'package:garden_flutter/state/files_controller.dart';

import 'files_gateway_fixture.dart';

import 'package:garden_flutter/components/settings/settings_sidebar.dart';

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
  bool failList = false;
  int calls = 0;
  int restoreCalls = 0;
  String? savedEmail;
  bool remembered = false;
  @override
  Future<String?> savedLogin() async => savedEmail;
  @override
  Future<void> forgetSavedLogin() async {
    savedEmail = null;
  }

  @override
  Future<AccountInfo?> restoreAccount() async {
    restoreCalls++;
    return savedEmail == null
        ? null
        : AccountInfo(id: 'account', email: savedEmail!);
  }

  @override
  Future<AccountInfo> signIn(
    String email,
    String password, {
    bool remember = false,
  }) async {
    calls++;
    remembered = remember;
    if (remember) savedEmail = email;
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
  Future<void> deleteDrive(int driveId) async {}
  @override
  Future<List<GardenInfo>> listGardens() async {
    if (failList) throw StateError('Cannot refresh Gardens.');
    return [];
  }

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

class PendingGateway extends TestGateway {
  final result = Completer<AccountInfo>();
  @override
  Future<AccountInfo> signIn(
    String email,
    String password, {
    bool remember = false,
  }) {
    calls++;
    return result.future;
  }
}

void main() {
  testWidgets('saved login waits for Continue and remember is optional', (
    tester,
  ) async {
    final gateway = TestGateway()..savedEmail = 'saved@example.com';
    final controller = GardenController(gateway, MemoryPreferences());
    await controller.initialize();
    expect(gateway.restoreCalls, 0);
    await tester.pumpWidget(GardenApp(controller: controller));
    expect(find.text('Continue as saved@example.com'), findsOneWidget);
    await tester.tap(find.text('Continue as saved@example.com'));
    await tester.pumpAndSettle();
    expect(gateway.restoreCalls, 1);
    expect(controller.account!.email, 'saved@example.com');
    await controller.signOut();
    controller.setRememberLogin(true);
    await controller.signIn('new@example.com', 'password');
    expect(gateway.remembered, isTrue);
    expect(gateway.savedEmail, 'new@example.com');
  });

  testWidgets(
    'Settings replaces the sidebar and Back restores the previous drive view',
    (tester) async {
      final controller = GardenController(
        TestGateway(),
        MemoryPreferences(),
        files: FilesController(FilesFixture()),
      );
      await controller.signIn('demo@garden.local', 'garden-demo');
      await controller.openDrive(
        const GardenInfo(id: 1, name: 'Shared', role: 'Member', members: 2),
      );
      controller.navigate(GardenPage.settings);
      await tester.pumpWidget(GardenApp(controller: controller));
      expect(find.byType(SettingsSidebar), findsOneWidget);
      expect(find.byType(GardenSidebar), findsNothing);
      expect(find.text('Sign out'), findsOneWidget);
      await tester.tap(find.text('Storage'));
      await tester.pumpAndSettle();
      expect(find.text('Cache limit'), findsOneWidget);
      expect(find.text('Finder connection'), findsOneWidget);
      await tester.tap(find.text('Back to drives'));
      await tester.pumpAndSettle();
      expect(find.byType(GardenSidebar), findsOneWidget);
      expect(find.byType(SettingsSidebar), findsNothing);
      expect(find.text('Shared'), findsWidgets);
    },
  );

  testWidgets('Signed-out launch shows sign-in without a sidebar', (
    tester,
  ) async {
    final controller = GardenController(
      TestGateway(),
      MemoryPreferences(),
      files: FilesController(FilesFixture()),
    );
    await tester.pumpWidget(GardenApp(controller: controller));
    expect(find.byType(TextField), findsNWidgets(2));
    expect(find.byType(GardenSidebar), findsNothing);
    expect(find.text('Use demo account'), findsOneWidget);
    expect(find.text('Create account'), findsOneWidget);
  });

  testWidgets('Demo button fills credentials without signing in', (
    tester,
  ) async {
    final gateway = TestGateway();
    final controller = GardenController(gateway, MemoryPreferences());
    controller.navigate(GardenPage.signIn);
    await tester.pumpWidget(GardenApp(controller: controller));
    await tester.tap(find.text('Use demo account'));
    await tester.pump();
    final fields = tester
        .widgetList<TextField>(find.byType(TextField))
        .toList();
    expect(fields[0].controller!.text, 'demo@garden.local');
    expect(fields[1].controller!.text, 'garden-demo');
    expect(gateway.calls, 0);
    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();
    expect(gateway.calls, 1);
    expect(controller.account!.email, 'demo@garden.local');
  });

  test('Pending requests reject duplicate actions', () async {
    final gateway = PendingGateway();
    final controller = GardenController(gateway, MemoryPreferences());
    final first = controller.signIn('garden@example.com', 'password');
    await controller.signIn('garden@example.com', 'password');
    expect(gateway.calls, 1);
    expect(controller.busy, isTrue);
    gateway.result.complete(
      const AccountInfo(id: 'account', email: 'garden@example.com'),
    );
    await first;
    expect(controller.busy, isFalse);
  });
  testWidgets(
    'Account creation accepts an email code and opens Garden selection',
    (tester) async {
      final controller = GardenController(
        TestGateway(),
        MemoryPreferences(),
        files: FilesController(FilesFixture()),
      );
      await tester.pumpWidget(GardenApp(controller: controller));
      await tester.tap(find.text('Create account'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byType(TextField).at(0),
        'garden@example.com',
      );
      await tester.enterText(find.byType(TextField).at(1), 'password');
      await tester.pump();
      await tester.tap(find.text('Create account'));
      await tester.pumpAndSettle();
      expect(find.text('Email verification code'), findsOneWidget);
      await tester.enterText(find.byType(TextField).first, '12345678');
      await tester.pump();
      await tester.tap(find.text('Verify'));
      await tester.pumpAndSettle();
      expect(find.text('Join drive'), findsOneWidget);
      expect(controller.registrationPassword, isEmpty);
    },
  );

  testWidgets(
    'Create Garden opens API readiness and identifies unavailable Finder mounting',
    (tester) async {
      final controller = GardenController(
        TestGateway(),
        MemoryPreferences(),
        files: FilesController(FilesFixture()),
      );
      await controller.signIn('garden@example.com', 'password');
      await tester.pumpWidget(GardenApp(controller: controller));
      await tester.tap(find.widgetWithText(TextButton, 'Create drive').last);
      await tester.pumpAndSettle();
      expect(find.byType(Dialog), findsOneWidget);
      expect(tester.getCenter(find.byType(Dialog)).dy, closeTo(300, 1));
      await tester.enterText(find.byType(TextField), 'Projects');
      await tester.pump();
      await tester.tap(find.widgetWithText(TextButton, 'Create drive').last);
      await tester.pumpAndSettle();
      expect(find.text('Projects'), findsWidgets);
      expect(find.text('Connected to drive'), findsNothing);
      expect(find.text('Finder mounting is not available yet.'), findsNothing);
      expect(find.byTooltip('Create invitation'), findsOneWidget);
    },
  );
  testWidgets('Join Garden submits the invitation and shows its membership', (
    tester,
  ) async {
    final controller = GardenController(
      TestGateway(),
      MemoryPreferences(),
      files: FilesController(FilesFixture()),
    );
    await controller.signIn('garden@example.com', 'password');
    await tester.pumpWidget(GardenApp(controller: controller));
    await tester.tap(find.text('Join drive').last);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'invite');
    await tester.pump();
    await tester.tap(find.text('Join drive').last);
    await tester.pumpAndSettle();
    expect(controller.selected!.role, 'Member');
    expect(find.text('Shared'), findsWidgets);
    expect(find.text('Connected to drive'), findsNothing);
  });

  test('Drive creation opens files without a redundant list request', () async {
    final gateway = TestGateway()..failList = true;
    final controller = GardenController(
      gateway,
      MemoryPreferences(),
      files: FilesController(FilesFixture()),
    );
    await controller.create('Projects');
    expect(controller.page, GardenPage.files);
    expect(controller.selected!.name, 'Projects');
    expect(controller.selected!.invitationCode, 'invite');
    expect(controller.error, isNull);
  });
  test('A failed list refresh retains the authenticated state', () async {
    final gateway = TestGateway()..failList = true;
    final controller = GardenController(gateway, MemoryPreferences());
    await controller.signIn('garden@example.com', 'password');
    expect(controller.account!.email, 'garden@example.com');
    expect(controller.page, GardenPage.gardens);
    expect(controller.error, contains('Cannot refresh Gardens.'));
  });

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
    expect(find.text('Create drive'), findsOneWidget);
    expect(find.text('Join drive'), findsOneWidget);
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
      final controller = GardenController(
        TestGateway(),
        MemoryPreferences(),
        files: FilesController(FilesFixture()),
      );
      await controller.register('garden@example.com', 'password');
      expect(controller.page, GardenPage.verify);
      await controller.verify('123456');
      expect(controller.registrationPassword, isEmpty);
      await controller.create('Projects');
      expect(controller.selected!.invitationCode, 'invite');
      expect(controller.page, GardenPage.files);
      await controller.signOut();
      expect(controller.account, isNull);
      expect(controller.selected, isNull);
      expect(controller.page, GardenPage.signIn);
    },
  );
}
