import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:garden_flutter/components/setup/setup_modal.dart';
import 'package:garden_flutter/state/garden_controller.dart';
import 'package:garden_flutter/ui/garden_app.dart';
import 'package:garden_flutter/ui/garden_theme.dart';
import 'package:garden_flutter/services/setup_store.dart';

import 'widget_test.dart' show TestGateway, MemoryPreferences;

void main() {
  testWidgets('setup fits short content and keeps compact navigation visible', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1024, 900);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final controller = GardenController(TestGateway(), MemoryPreferences());
    await controller.signIn('test@example.com', 'password');
    controller.openSetup();
    await tester.pumpWidget(
      MaterialApp(
        theme: GardenTheme.light,
        home: Scaffold(body: SetupModal(controller: controller)),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      tester.getSize(find.byKey(const ValueKey('setup-surface'))).height,
      lessThan(500),
    );
    tester.view.physicalSize = const Size(560, 420);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull, reason: 'compact installation step');
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull, reason: 'compact Finder step');
    expect(tester.getRect(find.text('Continue')).bottom, lessThan(420));
    await tester.tap(find.text('Back'));
    await tester.pumpAndSettle();
    expect(find.text('Install Garden'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    await controller.checkFinder();
    controller.dispose();
  });
  test(
    'a clean demo account receives setup once per account on this Mac',
    () async {
      final store = TestSetupStore();
      final controller = GardenController(
        TestGateway(),
        MemoryPreferences(),
        setupStore: store,
      );
      await controller.signIn('judge-demo@garden.invalid', 'private-password');
      expect(controller.setupVisible, isTrue);
      await controller.closeSetup();
      expect(store.seen, contains('account'));
      await controller.signIn('judge-demo@garden.invalid', 'private-password');
      expect(controller.setupVisible, isFalse);
      controller.openSetup();
      expect(controller.setupVisible, isTrue);
      await controller.checkFinder();
      controller.dispose();
    },
  );
  testWidgets('registration opens setup; ordinary login does not', (
    tester,
  ) async {
    final controller = GardenController(TestGateway(), MemoryPreferences());
    await controller.signIn('test@example.com', 'password');
    expect(controller.setupVisible, isFalse);
    await controller.register('fresh@example.com', 'password');
    expect(controller.setupVisible, isFalse);
    await controller.verify('123456');
    expect(controller.setupVisible, isTrue);
    await tester.pumpWidget(GardenApp(controller: controller));
    await tester.pumpAndSettle();
    expect(find.byType(SetupModal), findsOneWidget);
    expect(find.text('Install Garden'), findsOneWidget);
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.text('Enable Finder drives'), findsOneWidget);
    expect(find.text('Get macFUSE'), findsOneWidget);
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.text('Set up your drive'), findsOneWidget);
    await tester.tap(
      find.descendant(
        of: find.byType(SetupModal),
        matching: find.text('Create drive'),
      ),
    );
    await tester.pumpAndSettle();
    expect(controller.page, GardenPage.create);
    expect(find.byType(SetupModal), findsNothing);
    controller.openSetup();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Set up later'));
    await tester.pumpAndSettle();
    expect(controller.setupVisible, isFalse);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    controller.dispose();
  });
}

class TestSetupStore implements SetupStore {
  final seen = <String>{};

  @override
  Future<bool> hasSeenSetup(String accountId) async => seen.contains(accountId);

  @override
  Future<void> markSetupSeen(String accountId) async {
    seen.add(accountId);
  }
}
