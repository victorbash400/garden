import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:garden_flutter/components/error_notice.dart';
import 'package:garden_flutter/components/error_popup.dart';
import 'package:garden_flutter/ui/garden_theme.dart';
import 'package:garden_flutter/utils/error_message.dart';
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart';

void main() {
  test('authentication failures use clear typed messages', () {
    expect(
      errorMessage(
        EmailAccountLoginException(
          reason: EmailAccountLoginExceptionReason.invalidCredentials,
        ),
      ),
      'Incorrect username, email or password.',
    );
    expect(
      errorMessage(
        EmailAccountLoginException(
          reason: EmailAccountLoginExceptionReason.tooManyAttempts,
        ),
      ),
      'Too many sign-in attempts. Please try again later.',
    );
    expect(
      errorMessage(Exception('internal data')),
      isNot(contains('internal data')),
    );
  });
  testWidgets('errors queue, dismiss, and do not reopen on rebuild', (
    tester,
  ) async {
    final rebuild = ValueNotifier(0);
    addTearDown(rebuild.dispose);
    var dismissed = 0;
    await tester.pumpWidget(
      MaterialApp(
        theme: GardenTheme.light,
        home: Scaffold(
          body: ValueListenableBuilder<int>(
            valueListenable: rebuild,
            builder: (_, value, _) => Column(
              children: [
                ErrorNotice(
                  message: 'First error',
                  onDismiss: () => dismissed++,
                ),
                const ErrorNotice(message: 'Second error'),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(ErrorPopup), findsOneWidget);
    expect(find.text('First error'), findsOneWidget);
    expect(find.text('Second error'), findsNothing);
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(dismissed, 1);
    expect(find.text('Second error'), findsOneWidget);
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    rebuild.value++;
    await tester.pumpAndSettle();
    expect(find.byType(ErrorPopup), findsNothing);
  });
}
