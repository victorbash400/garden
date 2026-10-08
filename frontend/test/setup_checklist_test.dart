import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:garden_flutter/components/settings/setup_checklist.dart';
import 'package:garden_flutter/model/account_info.dart';
import 'package:garden_flutter/model/garden_info.dart';
import 'package:garden_flutter/native/finder_status.dart';
import 'package:garden_flutter/state/garden_controller.dart';
import 'package:garden_flutter/ui/garden_theme.dart';

import 'widget_test.dart' show TestGateway, MemoryPreferences;

void main() {
  testWidgets(
    'fresh account setup links to drive creation and connection settings',
    (tester) async {
      final controller = GardenController(TestGateway(), MemoryPreferences())
        ..account = const AccountInfo(id: 'fresh', email: 'fresh@example.com')
        ..gardens = [];
      await tester.pumpWidget(
        MaterialApp(
          theme: GardenTheme.light,
          home: Scaffold(body: SetupChecklist(controller: controller)),
        ),
      );
      expect(find.text('Done'), findsOneWidget);
      expect(find.text('Not complete'), findsNWidgets(3));
      await tester.tap(find.text('Create drive'));
      expect(controller.page, GardenPage.create);
      await tester.tap(find.text('Set up Finder'));
      expect(controller.page, GardenPage.settings);
      expect(controller.settingsSection, SettingsSection.connections);
      controller.dispose();
    },
  );

  testWidgets(
    'registered or disconnected drives do not falsely complete Finder setup',
    (tester) async {
      final controller = GardenController(TestGateway(), MemoryPreferences())
        ..account = const AccountInfo(id: 'fresh', email: 'fresh@example.com')
        ..serviceAvailable = true
        ..gardens = [
          const GardenInfo(id: 1, name: 'Drive', role: 'Owner', members: 1),
        ]
        ..finderStatus = const FinderStatus(
          registered: {1},
          enabled: {1},
          disconnected: {1},
        );
      Future<void> show() => tester.pumpWidget(
        MaterialApp(
          theme: GardenTheme.light,
          home: Scaffold(body: SetupChecklist(controller: controller)),
        ),
      );
      await show();
      expect(find.text('Set up Finder'), findsOneWidget);
      controller.finderStatus = const FinderStatus(
        registered: {1},
        enabled: {1},
      );
      await show();
      expect(find.text('Open in Finder'), findsOneWidget);
      expect(find.text('Not complete'), findsNothing);
      controller.finderIssue = 'Connection failed';
      await show();
      expect(find.text('Set up Finder'), findsOneWidget);
      controller.dispose();
    },
  );
}
