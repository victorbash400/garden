import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:garden_flutter/components/settings/delete_account_dialog.dart';
import 'package:garden_flutter/services/account_deletion_gateway.dart';
import 'package:garden_flutter/state/garden_controller.dart';
import 'package:garden_flutter/ui/garden_theme.dart';

import 'widget_test.dart' show TestGateway, MemoryPreferences, TestFinder;

class DeletionFixture extends TestGateway implements AccountDeletionGateway {
  DeletionFixture(this.finder);
  final TestFinder finder;
  bool reject = false;
  int deletions = 0;
  @override
  Future<void> deleteAccount(String email) async {
    if (finder.mountedDriveIDs.isNotEmpty) {
      throw StateError('Finder must disconnect before deletion.');
    }
    if (reject) throw StateError('Cloud cleanup failed. Retry deletion.');
    deletions++;
  }
}

void main() {
  testWidgets(
    'requires matching email, disconnects Finder, and clears the account',
    (tester) async {
      final finder = TestFinder();
      final gateway = DeletionFixture(finder);
      final controller = GardenController(
        gateway,
        MemoryPreferences(),
        finder: finder,
      );
      await controller.signIn('fixture@example.test', 'fixture');
      finder.mountedDriveIDs.add(1);
      await tester.pumpWidget(
        MaterialApp(
          theme: GardenTheme.light,
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => showDialog<void>(
                  context: context,
                  builder: (_) => DeleteAccountDialog(controller: controller),
                ),
                child: const Text('Open deletion'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open deletion'));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<TextButton>(
              find.widgetWithText(TextButton, 'Delete account'),
            )
            .onPressed,
        isNull,
      );
      await tester.enterText(find.byType(TextField), 'other@example.test');
      await tester.pump();
      expect(
        tester
            .widget<TextButton>(
              find.widgetWithText(TextButton, 'Delete account'),
            )
            .onPressed,
        isNull,
      );
      await tester.enterText(find.byType(TextField), 'fixture@example.test');
      await tester.pump();
      await tester.tap(find.text('Delete account'));
      await tester.pumpAndSettle();
      expect(gateway.deletions, 1);
      expect(controller.account, isNull);
      expect(controller.page, GardenPage.signIn);
      expect(find.byType(DeleteAccountDialog), findsNothing);
      controller.dispose();
    },
  );

  test('cleanup failure retains the account for retry', () async {
    final finder = TestFinder();
    final gateway = DeletionFixture(finder)..reject = true;
    final controller = GardenController(
      gateway,
      MemoryPreferences(),
      finder: finder,
    );
    await controller.signIn('fixture@example.test', 'fixture');
    await expectLater(
      controller.deleteAccount('fixture@example.test'),
      throwsStateError,
    );
    expect(controller.account, isNotNull);
    expect(controller.busy, isFalse);
    gateway.reject = false;
    await controller.deleteAccount('fixture@example.test');
    expect(controller.account, isNull);
    controller.dispose();
  });
}
