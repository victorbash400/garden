import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:garden_flutter/components/settings/settings_row.dart';
import 'package:garden_flutter/components/settings/settings_inline_button.dart';
import 'package:garden_flutter/components/settings/settings_icon_button.dart';
import 'package:garden_flutter/components/system_icon.dart';
import 'package:garden_flutter/ui/garden_theme.dart';

void main() {
  for (final width in [760.0, 320.0]) {
    testWidgets('settings values and actions share a trailing edge at $width', (
      tester,
    ) async {
      const statusKey = ValueKey('status');
      const actionKey = ValueKey('action');
      const pickerKey = ValueKey('picker');
      await tester.pumpWidget(
        MaterialApp(
          theme: GardenTheme.light,
          home: Scaffold(
            body: Align(
              alignment: Alignment.topLeft,
              child: SizedBox(
                width: width,
                child: Column(
                  children: [
                    const SettingsRow(
                      label: 'Garden service',
                      value: Text('Available', key: statusKey),
                    ),
                    SettingsRow(
                      label: 'Connection status',
                      value: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Flexible(child: Text('Needs attention')),
                          const SizedBox(width: 12),
                          SettingsInlineButton(
                            key: actionKey,
                            label: 'Details',
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ),
                    const SettingsRow(
                      label: 'Drive',
                      value: SizedBox(key: pickerKey, width: 180, height: 32),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      for (final key in [statusKey, actionKey, pickerKey]) {
        expect(tester.getRect(find.byKey(key)).right, closeTo(width - 16, .1));
      }
      if (width == 760) {
        expect(tester.getRect(find.text('Garden service')).left, 16);
        expect(tester.getRect(find.text('Connection status')).left, 16);
      }
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets('settings refresh has compact bounds and keeps its action', (
    tester,
  ) async {
    var calls = 0;
    await tester.pumpWidget(
      MaterialApp(
        theme: GardenTheme.light,
        home: Scaffold(
          body: SettingsIconButton(
            tooltip: 'Refresh storage usage',
            icon: SystemIcons.refreshCw,
            onPressed: () => calls++,
          ),
        ),
      ),
    );
    expect(tester.getSize(find.byType(IconButton)), const Size(32, 32));
    expect(tester.widget<SystemIcon>(find.byType(SystemIcon)).size, 14);
    await tester.tap(find.byTooltip('Refresh storage usage'));
    expect(calls, 1);
  });
}
