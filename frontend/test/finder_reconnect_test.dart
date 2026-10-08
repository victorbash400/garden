import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:garden_flutter/native/system_setup.dart';
import 'package:garden_flutter/state/native_setup_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:garden_flutter/components/settings/finder_setup_row.dart';
import 'package:garden_flutter/views/connections_settings.dart';
import 'package:garden_flutter/state/garden_controller.dart';
import 'package:garden_flutter/ui/garden_theme.dart';

import 'widget_test.dart' show TestGateway, TestFinder, MemoryPreferences;

class MissingFuse extends Fake implements SystemSetup {
  @override
  Future<SystemSetupStatus> status() async => const SystemSetupStatus(
    finderAvailable: false,
    macFuseInstalled: false,
    launchAtLogin: LoginItemState.disabled,
  );
}

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
  testWidgets('missing macFUSE offers its installer from Connections', (
    tester,
  ) async {
    final setup = NativeSetupController(MissingFuse());
    await setup.refresh();
    final controller = GardenController(
      TestGateway(),
      MemoryPreferences(),
      nativeSetup: setup,
    );
    addTearDown(controller.dispose);
    Object? requested;
    const channel = MethodChannel('garden/setup');
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, (
      call,
    ) async {
      expect(call.method, 'openHelp');
      requested = call.arguments;
      return null;
    });
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        channel,
        null,
      ),
    );
    await tester.pumpWidget(
      MaterialApp(
        theme: GardenTheme.light,
        home: Scaffold(body: ConnectionsSettings(controller: controller)),
      ),
    );
    expect(find.text('macFUSE not installed'), findsOneWidget);
    expect(find.text('Not installed'), findsOneWidget);
    expect(find.text('Get macFUSE'), findsOneWidget);
    await tester.tap(find.text('Get macFUSE'));
    await tester.pumpAndSettle();
    expect(requested, 'macFuse');
  });
}
