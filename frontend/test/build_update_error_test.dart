import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:garden_flutter/components/build_update_banner.dart';
import 'package:garden_flutter/components/error_popup.dart';
import 'package:garden_flutter/native/account_window.dart';
import 'package:garden_flutter/ui/garden_theme.dart';

void main() {
  for (final dismissed in [false, true]) {
    testWidgets('update failure uses modal when dismissed=$dismissed', (
      tester,
    ) async {
      final window = AccountWindow()
        ..updateReady = true
        ..updateDismissed = dismissed
        ..updateError = 'Close files on “Tangerine”, then try Update again.';
      addTearDown(window.dispose);
      await tester.pumpWidget(
        MaterialApp(
          theme: GardenTheme.light,
          home: Scaffold(body: BuildUpdateBanner(window: window)),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(ErrorPopup), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(BuildUpdateBanner),
          matching: find.text(window.updateError!),
        ),
        findsNothing,
      );
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(window.updateError, isNull);
      expect(find.byType(ErrorPopup), findsNothing);
      expect(
        find.text('Software Update Available'),
        dismissed ? findsNothing : findsOneWidget,
      );
      window.notifyListeners();
      await tester.pumpAndSettle();
      expect(find.byType(ErrorPopup), findsNothing);
    });
  }
}
