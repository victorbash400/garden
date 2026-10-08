import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:garden_flutter/components/account_background.dart';
import 'package:garden_flutter/components/garden_button.dart';
import 'package:garden_flutter/ui/garden_theme.dart';
import 'package:garden_flutter/views/account_form.dart';

import 'account_security_controls_test.dart' show SecurityFixture;

void main() {
  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });
  testWidgets('sign-in stays usable after resizing to a narrow short window', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1100, 740);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final security = SecurityFixture();
    addTearDown(() {
      security.gateway.dispose();
      security.dispose();
    });
    String? submittedEmail;
    String? submittedPassword;
    var passkeyCalls = 0;
    await tester.pumpWidget(
      MaterialApp(
        theme: GardenTheme.light,
        home: Scaffold(
          body: AccountBackground(
            child: AccountForm(
              busy: false,
              submitLabel: 'Sign in',
              security: security,
              onPasskey: () => passkeyCalls++,
              onCreateAccount: () {},
              onSubmit: (email, password) {
                submittedEmail = email;
                submittedPassword = password;
              },
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).at(0), 'garden@example.com');
    await tester.enterText(find.byType(TextField).at(1), 'test-password');
    await tester.pump();
    tester.view.physicalSize = const Size(320, 420);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('garden@example.com'), findsOneWidget);
    expect(find.text('test-password'), findsOneWidget);
    final signIn = find.widgetWithText(GardenButton, 'Sign in');
    await tester.ensureVisible(signIn);
    await tester.pumpAndSettle();
    await tester.tap(signIn);
    expect(submittedEmail, 'garden@example.com');
    expect(submittedPassword, 'test-password');
    final passkey = find.widgetWithText(GardenButton, 'Sign in with passkey');
    await tester.ensureVisible(passkey);
    await tester.pumpAndSettle();
    await tester.tap(passkey);
    expect(passkeyCalls, 1);
    expect(tester.takeException(), isNull);
  });
}
