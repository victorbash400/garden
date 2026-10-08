import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:garden_flutter/components/setup/setup_modal.dart';
import 'package:garden_flutter/state/garden_controller.dart';
import 'package:garden_flutter/ui/garden_app.dart';

import 'widget_test.dart' show TestGateway, MemoryPreferences;

void main() {
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
