import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:garden_flutter/state/garden_controller.dart';
import 'package:garden_flutter/ui/garden_app.dart';

import 'widget_test.dart' show TestGateway, MemoryPreferences;

void main() {
  testWidgets('dismissing a startup failure does not restart an idle spinner', (
    tester,
  ) async {
    final gateway = TestGateway()
      ..savedEmail = 'fixture@example.test'
      ..failList = true;
    final controller = GardenController(gateway, MemoryPreferences());
    addTearDown(controller.dispose);
    await tester.pumpWidget(GardenApp(controller: controller));
    await controller.initialize();
    await tester.pumpAndSettle();
    expect(controller.page, GardenPage.starting);
    expect(controller.busy, isFalse);
    expect(find.text('OK'), findsOneWidget);
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('Retry'), findsOneWidget);
    expect(find.text('Sign in'), findsOneWidget);
    gateway.failList = false;
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(controller.page, GardenPage.gardens);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });
}
