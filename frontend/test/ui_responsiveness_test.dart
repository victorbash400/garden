import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:garden_flutter/components/files/files_toolbar.dart';
import 'package:garden_flutter/model/garden_info.dart';
import 'package:garden_flutter/state/files_controller.dart';

import 'files_gateway_fixture.dart';

import 'package:garden_flutter/components/settings/settings_row.dart';
import 'package:garden_flutter/components/settings/settings_sidebar.dart';
import 'package:garden_flutter/components/settings/settings_transition.dart';
import 'package:garden_flutter/state/garden_controller.dart';
import 'package:garden_flutter/ui/garden_theme.dart';

import 'widget_test.dart' show TestGateway, MemoryPreferences;

void main() {
  testWidgets('file navigation and every existing action fit a narrow pane', (
    tester,
  ) async {
    final gateway = FilesFixture();
    final files = FilesController(gateway);
    await files.open(
      const GardenInfo(
        id: 1,
        name: 'A long drive name for narrow windows',
        role: 'Owner',
        members: 1,
      ),
    );
    var opened = 0;
    await tester.pumpWidget(
      MaterialApp(
        theme: GardenTheme.light,
        home: Scaffold(
          body: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: 360,
              child: FilesToolbar(
                controller: files,
                onImport: () {},
                onInvite: () {},
                onBackToDrives: () => opened++,
                onConnections: () {},
                onChat: () {},
                onShare: () {},
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    for (final tooltip in [
      'Import files',
      'Invite to drive',
      'Inbox',
      'Share',
      'Connection needs attention',
    ]) {
      expect(find.byTooltip(tooltip), findsOneWidget);
    }
    await tester.tap(find.byTooltip('Back to drives'));
    expect(opened, 1);
    await tester.pumpWidget(const SizedBox());
    files.dispose();
    await gateway.events.close();
  });

  testWidgets('settings categories remain reachable in short windows', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(640, 320);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final controller = GardenController(TestGateway(), MemoryPreferences());
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      MaterialApp(
        theme: GardenTheme.light,
        home: Scaffold(
          body: Row(children: [SettingsSidebar(controller: controller)]),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.drag(
      find.byType(SingleChildScrollView),
      const Offset(0, -160),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Activity'));
    await tester.pumpAndSettle();
    expect(controller.settingsSection, SettingsSection.activity);
  });

  testWidgets('narrow settings rows keep long labels and controls in bounds', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: GardenTheme.light,
        home: Scaffold(
          body: SizedBox(
            width: 260,
            child: SettingsRow(
              label: 'Background upload bandwidth',
              value: SizedBox(
                width: 180,
                child: OutlinedButton(
                  onPressed: () {},
                  child: const Text('Unlimited'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Unlimited'));
  });

  testWidgets('outgoing pages cannot keep keyboard focus or receive taps', (
    tester,
  ) async {
    var taps = 0;
    Widget page(int index, {bool reduceMotion = false}) => MaterialApp(
      home: Scaffold(
        body: MediaQuery(
          data: MediaQueryData(disableAnimations: reduceMotion),
          child: SettingsTransition(
            child: TextButton(
              key: ValueKey(index),
              onPressed: () => taps++,
              child: Text('Page $index'),
            ),
          ),
        ),
      ),
    );
    await tester.pumpWidget(page(1));
    await tester.pumpWidget(page(2));
    await tester.pump(const Duration(milliseconds: 20));
    expect(find.text('Page 1'), findsNothing);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Page 2'));
    expect(taps, 1);
    await tester.pumpWidget(page(3, reduceMotion: true));
    await tester.pump();
    expect(find.text('Page 2'), findsNothing);
    expect(find.text('Page 3'), findsOneWidget);
  });
}
