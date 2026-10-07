import 'package:flutter/material.dart';
import 'package:garden_flutter/ui/garden_theme.dart';
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

  var relaunchCalls = 0;
  setUp(() {
    relaunchCalls = 0;
    messenger.setMockMethodCallHandler(AccountWindow.channel, (call) async {
      if (call.method == 'relaunch') relaunchCalls++;
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
          theme: GardenTheme.light,
          home: Scaffold(
            body: SizedBox(
              width: 240,
              child: BuildUpdateBanner(window: window),
            ),
          ),
        ),
      );
      expect(find.text('Software Update Available'), findsNothing);
      await native('build', {
        'ready': true,
        'restarting': false,
        'error': null,
      });
      await tester.pump();
      expect(find.text('Software Update Available'), findsOneWidget);
      expect(
        tester.getSize(find.byType(BuildUpdateBanner)).height,
        lessThanOrEqualTo(56),
      );
      expect(find.byType(Badge), findsOneWidget);
      final button = tester.widget<TextButton>(find.byType(TextButton));
      expect(button.style!.backgroundColor!.resolve({}), Colors.transparent);
      await tester.tap(find.text('Software Update Available'));
      expect(relaunchCalls, 1);
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
      expect(find.text('Software Update Available'), findsNothing);
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
      lessThanOrEqualTo(56),
    );
    expect(controller.busy, false);
    await tester.enterText(fields.at(0), 'edited@garden.test');
    await tester.tap(find.byTooltip('Dismiss update'));
    await tester.pump();
    expect(find.text('Software Update Available'), findsNothing);
    expect(find.text('edited@garden.test'), findsOneWidget);
    expect(find.text('password-for-test'), findsOneWidget);
    expect(tester.getTopLeft(fields.first), formPosition);
    expect(controller.page, GardenPage.register);
    await tester.pumpWidget(const SizedBox.shrink());
    controller.dispose();
    window.dispose();
  });

  testWidgets('a failed relaunch shows the error and allows retry', (
    tester,
  ) async {
    messenger.setMockMethodCallHandler(AccountWindow.channel, (call) async {
      if (call.method == 'relaunch') {
        throw PlatformException(code: 'relaunch_failed');
      }
      return null;
    });
    final window = AccountWindow()..updateReady = true;
    await tester.pumpWidget(
      MaterialApp(
        theme: GardenTheme.light,
        home: Scaffold(
          body: SizedBox(width: 240, child: BuildUpdateBanner(window: window)),
        ),
      ),
    );
    await tester.tap(find.text('Software Update Available'));
    await tester.pumpAndSettle();
    expect(find.text('Could not relaunch Garden. Try again.'), findsOneWidget);
    expect(
      tester.widget<TextButton>(find.byType(TextButton)).onPressed,
      isNotNull,
    );
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
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
