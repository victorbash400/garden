import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:garden_flutter/components/settings/finder_setup_row.dart';
import 'package:garden_flutter/state/garden_controller.dart';
import 'package:garden_flutter/ui/garden_theme.dart';

import 'widget_test.dart' show TestGateway, TestFinder, MemoryPreferences;

void main() {
  testWidgets(
    'Finder error reconnects inside Garden instead of opening Login Items',
    (tester) async {
      final finder = TestFinder();
      final controller = GardenController(
        TestGateway(),
        MemoryPreferences(),
        finder: finder,
      );
      addTearDown(controller.dispose);
      await controller.signIn('fixture@example.test', 'fixture');
      await tester.pump();
      controller.finderIssue =
          'Complete the pending drive removal before opening it.';
      await tester.pumpWidget(
        MaterialApp(
          theme: GardenTheme.light,
          home: Scaffold(
            body: ListenableBuilder(
              listenable: controller,
              builder: (context, _) => FinderSetupRow(controller: controller),
            ),
          ),
        ),
      );
      expect(find.text('Reconnect'), findsOneWidget);
      await tester.tap(find.text('Reconnect'));
      await tester.pumpAndSettle();
      expect(controller.finderIssue, isNull);
      expect(finder.openedSettings, isFalse);
      expect(find.text('Manage…'), findsOneWidget);
      await tester.tap(find.text('Manage…'));
      await tester.pumpAndSettle();
      expect(controller.settingsSection, SettingsSection.drives);
      expect(finder.openedSettings, isFalse);
    },
  );
}
