import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:garden_flutter/components/settings/drive_settings_row.dart';
import 'package:garden_flutter/model/account_info.dart';
import 'package:garden_flutter/model/garden_info.dart';
import 'package:garden_flutter/native/finder_drive_control.dart';
import 'package:garden_flutter/native/finder_status.dart';
import 'package:garden_flutter/state/garden_controller.dart';
import 'package:garden_flutter/ui/garden_theme.dart';

import 'widget_test.dart' show TestFinder, TestGateway, MemoryPreferences;

class ControlledFinder extends TestFinder implements FinderDriveControl {
  final finished = Completer<void>();
  int calls = 0;
  bool mounted = true;
  @override
  Future<void> setMounted(AccountInfo account, int driveId, bool value) async {
    calls++;
    await finished.future;
    mounted = value;
  }

  @override
  Future<FinderStatus> status(
    AccountInfo account,
    List<GardenInfo> drives,
  ) async => FinderStatus(
    registered: {1},
    enabled: mounted ? {1} : {},
    disabled: mounted ? {} : {1},
  );
}

void main() {
  testWidgets(
    'drive row unmounts once and changes to Mount after confirmation',
    (tester) async {
      const drive = GardenInfo(
        id: 1,
        name: 'Potato',
        role: 'Owner',
        members: 1,
      );
      final finder = ControlledFinder();
      final controller =
          GardenController(TestGateway(), MemoryPreferences(), finder: finder)
            ..account = const AccountInfo(
              id: 'account',
              email: 'test@example.com',
            )
            ..gardens = [drive]
            ..finderStatus = const FinderStatus(registered: {1}, enabled: {1});
      await tester.pumpWidget(
        MaterialApp(
          theme: GardenTheme.light,
          home: Scaffold(
            body: ListenableBuilder(
              listenable: controller,
              builder: (_, _) => DriveSettingsRow(
                controller: controller,
                drive: drive,
                selected: true,
                onSelect: () {},
              ),
            ),
          ),
        ),
      );
      expect(find.text('Potato'), findsOneWidget);
      await tester.tap(find.text('Unmount'));
      await tester.pump();
      expect(find.text('Owner · Unmounting…'), findsOneWidget);
      await controller.setDriveMounted(drive, false);
      expect(finder.calls, 1);
      finder.finished.complete();
      await tester.pumpAndSettle();
      expect(find.text('Owner · Unmounted'), findsOneWidget);
      expect(find.text('Mount'), findsOneWidget);
      controller.dispose();
    },
  );
}
