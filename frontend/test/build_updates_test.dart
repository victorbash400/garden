import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:garden_flutter/components/build_update_banner.dart';
import 'package:garden_flutter/native/account_window.dart';
import 'package:garden_flutter/state/garden_controller.dart';
import 'package:garden_flutter/ui/garden_app.dart';

import 'widget_test.dart' show TestGateway, MemoryPreferences;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  Future<void> native(String method, [Object? arguments]) async {
    await messenger.handlePlatformMessage(
      AccountWindow.channel.name,
      const StandardMethodCodec().encodeMethodCall(
        MethodCall(method, arguments),
      ),
      (response) {
        if (response != null) {
          const StandardMethodCodec().decodeEnvelope(response);
        }
      },
    );
  }

  setUp(() {
    messenger.setMockMethodCallHandler(AccountWindow.channel, (call) async {
      if (call.method == 'initialize') {
        return {
          'id': 'main',
          'active': true,
          'windows': <Object?>[],
          'build': {'ready': false, 'restarting': false, 'error': null},
        };
      }
      return null;
    });
  });
  tearDown(
    () => messenger.setMockMethodCallHandler(AccountWindow.channel, null),
  );

  testWidgets(
    'a pushed completed build shows relaunch and disables it while restarting',
    (tester) async {
      final window = AccountWindow();
      await window.initialize();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 240,
              child: BuildUpdateBanner(window: window),
            ),
          ),
        ),
      );
      expect(find.text('Relaunch'), findsNothing);
      await native('build', {
        'ready': true,
        'restarting': false,
        'error': null,
      });
      await tester.pump();
      expect(find.text('New build ready'), findsOneWidget);
      expect(find.text('Relaunch'), findsOneWidget);
      expect(
        tester.getSize(find.byType(BuildUpdateBanner)).height,
        lessThan(150),
      );
      await native('build', {'ready': true, 'restarting': true, 'error': null});
      await tester.pump();
      expect(
        tester.widget<TextButton>(find.byType(TextButton)).onPressed,
        isNull,
      );
      await native('build', {
        'ready': false,
        'restarting': false,
        'error': null,
      });
      await tester.pump();
      expect(find.text('New build ready'), findsNothing);
    },
  );

  testWidgets('update notice leaves signup usable and preserves input', (
    tester,
  ) async {
    final window = AccountWindow();
    await window.initialize();
    final controller = GardenController(
      TestGateway(),
      MemoryPreferences(),
      accountWindow: window,
    );
    controller.navigate(GardenPage.register);
    await tester.pumpWidget(GardenApp(controller: controller));
    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'new@garden.test');
    await tester.enterText(fields.at(1), 'password-for-test');
    final formPosition = tester.getTopLeft(fields.first);
    await native('build', {'ready': true, 'restarting': false, 'error': null});
    await tester.pump();
    expect(tester.getTopLeft(fields.first), formPosition);
    expect(
      tester.getSize(find.byType(BuildUpdateBanner)).height,
      lessThan(150),
    );
    expect(controller.busy, false);
    await tester.enterText(fields.at(0), 'edited@garden.test');
    await tester.tap(find.byTooltip('Dismiss update'));
    await tester.pump();
    expect(find.text('New build ready'), findsNothing);
    expect(find.text('edited@garden.test'), findsOneWidget);
    expect(find.text('password-for-test'), findsOneWidget);
    expect(tester.getTopLeft(fields.first), formPosition);
    expect(controller.page, GardenPage.register);
    await tester.pumpWidget(const SizedBox.shrink());
    controller.dispose();
    window.dispose();
  });

  test('registration blocks relaunch and a failed relaunch releases the window lock', () async {
    final window = AccountWindow();
    final controller = GardenController(
      TestGateway(),
      MemoryPreferences(),
      accountWindow: window,
    );
    controller.registrationPassword = 'pending';
    expect(window.prepareRelaunch!(), contains('creating your account'));
    expect(controller.busy, false);
    controller.registrationPassword = '';
    expect(window.prepareRelaunch!(), isNull);
    expect(controller.busy, true);
    window.cancelRelaunch!();
    expect(controller.busy, false);
  });
}
