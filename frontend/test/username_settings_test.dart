import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:garden_flutter/components/profile_button.dart';
import 'package:garden_flutter/components/settings/username_dialog.dart';
import 'package:garden_flutter/model/account_info.dart';
import 'package:garden_flutter/services/username_gateway.dart';
import 'package:garden_flutter/state/garden_controller.dart';
import 'package:garden_flutter/ui/garden_theme.dart';

import 'widget_test.dart' show TestGateway, MemoryPreferences;

class UsernameFixture extends TestGateway implements UsernameGateway {
  bool reject = false;
  @override
  Future<AccountInfo> setUsername(String name) async {
    if (reject) throw StateError('That username is already taken.');
    return AccountInfo(
      id: 'account',
      email: 'private@example.com',
      username: name,
    );
  }
}

void main() {
  testWidgets(
    'editing a username updates the profile without exposing its email; failure preserves input',
    (tester) async {
      final gateway = UsernameFixture();
      final controller = GardenController(gateway, MemoryPreferences());
      await controller.signIn('private@example.com', 'test-only');
      await tester.pumpWidget(
        MaterialApp(
          theme: GardenTheme.light,
          home: Scaffold(
            body: Builder(
              builder: (context) => Column(
                children: [
                  ListenableBuilder(
                    listenable: controller,
                    builder: (_, _) => ProfileButton(controller: controller),
                  ),
                  TextButton(
                    onPressed: () => showDialog<void>(
                      context: context,
                      builder: (_) => UsernameDialog(controller: controller),
                    ),
                    child: const Text('Edit username'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Edit username'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'my_username');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(controller.account!.username, 'my_username');
      expect(find.text('M'), findsOneWidget);
      expect(find.text('my_username'), findsNothing);
      await tester.tap(find.byType(ProfileButton));
      await tester.pumpAndSettle();
      expect(find.text('my_username'), findsOneWidget);
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();
      expect(controller.page, GardenPage.settings);
      expect(find.text('private@example.com'), findsNothing);
      gateway.reject = true;
      await tester.tap(find.text('Edit username'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'taken_name');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(controller.account!.username, 'my_username');
      expect(find.byType(UsernameDialog), findsOneWidget);
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        'taken_name',
      );
      expect(find.textContaining('already taken'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      controller.dispose();
    },
  );
}
