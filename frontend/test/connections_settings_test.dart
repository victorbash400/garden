import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:garden_flutter/components/error_popup.dart';
import 'package:garden_flutter/components/warning_icon.dart';
import 'package:garden_flutter/state/garden_controller.dart';
import 'package:garden_flutter/ui/garden_theme.dart';
import 'package:garden_flutter/views/connections_settings.dart';

import 'widget_test.dart' show TestGateway, MemoryPreferences;

void main() {
  testWidgets(
    'opening Connections preserves failures without repeating a modal',
    (tester) async {
      final controller = GardenController(TestGateway(), MemoryPreferences());
      addTearDown(controller.dispose);
      controller.finderUpdateError(
        StateError('Garden returned an invalid response.'),
      );
      Widget page(int visit) => MaterialApp(
        theme: GardenTheme.light,
        home: Scaffold(
          body: ConnectionsSettings(
            key: ValueKey(visit),
            controller: controller,
          ),
        ),
      );
      await tester.pumpWidget(page(1));
      await tester.pumpAndSettle();
      expect(find.byType(ErrorPopup), findsNothing);
      expect(find.text('Needs attention'), findsOneWidget);
      await tester.tap(find.text('Details'));
      await tester.pumpAndSettle();
      expect(find.byType(WarningIcon), findsOneWidget);
      expect(
        find.text(
          'Connection check failed\n\nGarden returned an invalid response.',
        ),
        findsOneWidget,
      );
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      await tester.pumpWidget(page(2));
      await tester.pumpAndSettle();
      expect(find.byType(ErrorPopup), findsNothing);
      expect(find.text('Needs attention'), findsOneWidget);
      expect(controller.finderIssue, 'Garden returned an invalid response.');
      expect(tester.takeException(), isNull);
    },
  );
}
