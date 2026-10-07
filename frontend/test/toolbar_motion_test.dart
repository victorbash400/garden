import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:garden_flutter/components/files/toolbar_button.dart';
import 'package:garden_flutter/components/files/toolbar_entrance.dart';
import 'package:garden_flutter/components/files/toolbar_group.dart';
import 'package:garden_flutter/components/system_icon.dart';
import 'package:garden_flutter/ui/garden_theme.dart';

void main() {
  testWidgets('page toolbar entrance settles once and respects Reduce Motion', (
    tester,
  ) async {
    Widget page({bool reduceMotion = false}) => MaterialApp(
      home: Scaffold(
        body: MediaQuery(
          data: MediaQueryData(disableAnimations: reduceMotion),
          child: const ToolbarEntrance(child: Text('Toolbar')),
        ),
      ),
    );
    await tester.pumpWidget(page());
    final opacity = find.descendant(
      of: find.byType(ToolbarEntrance),
      matching: find.byType(Opacity),
    );
    expect(tester.widget<Opacity>(opacity).opacity, 0);
    await tester.pump(const Duration(milliseconds: 60));
    expect(tester.widget<Opacity>(opacity).opacity, greaterThan(0));
    expect(tester.widget<Opacity>(opacity).opacity, lessThan(1));
    await tester.pumpAndSettle();
    await tester.pumpWidget(page());
    expect(tester.widget<Opacity>(opacity).opacity, 1);
    await tester.pumpWidget(page(reduceMotion: true));
    expect(opacity, findsNothing);
    expect(find.text('Toolbar'), findsOneWidget);
  });

  testWidgets(
    'toolbar controls enter and leave without moving existing actions abruptly',
    (tester) async {
      var removedCalls = 0, retainedCalls = 0;
      Widget bar(bool extra, {bool reduceMotion = false}) => MaterialApp(
        theme: GardenTheme.light,
        home: Scaffold(
          body: MediaQuery(
            data: MediaQueryData(disableAnimations: reduceMotion),
            child: Align(
              alignment: Alignment.topLeft,
              child: ToolbarGroup(
                children: [
                  extra
                      ? ToolbarButton(
                          tooltip: 'Invite',
                          icon: SystemIcons.userPlus,
                          onPressed: () => removedCalls++,
                        )
                      : null,
                  ToolbarButton(
                    tooltip: 'Import',
                    icon: SystemIcons.importFiles,
                    onPressed: () => retainedCalls++,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpWidget(bar(false));
      await tester.pumpAndSettle();
      final narrow = tester.getSize(find.byType(ToolbarGroup)).width;
      await tester.pumpWidget(bar(true));
      await tester.pump(const Duration(milliseconds: 60));
      final middle = tester.getSize(find.byType(ToolbarGroup)).width;
      expect(middle, greaterThan(narrow));
      await tester.pumpAndSettle();
      final wide = tester.getSize(find.byType(ToolbarGroup)).width;
      expect(middle, lessThan(wide));
      await tester.tap(find.byTooltip('Invite'));
      expect(removedCalls, 1);
      await tester.pumpWidget(bar(false));
      await tester.pump(const Duration(milliseconds: 40));
      final leaving = tester.getSize(find.byType(ToolbarGroup)).width;
      expect(leaving, greaterThan(narrow));
      expect(leaving, lessThan(wide));
      final ignored = find.ancestor(
        of: find.byTooltip('Invite'),
        matching: find.byType(IgnorePointer),
      );
      expect(
        tester.widgetList<IgnorePointer>(ignored).any((item) => item.ignoring),
        isTrue,
      );
      await tester.pumpAndSettle();
      expect(find.byTooltip('Invite'), findsNothing);
      await tester.tap(find.byTooltip('Import'));
      expect(retainedCalls, 1);
      await tester.pumpWidget(bar(true, reduceMotion: true));
      expect(tester.getSize(find.byType(ToolbarGroup)).width, wide);
      await tester.pumpWidget(bar(false, reduceMotion: true));
      expect(tester.getSize(find.byType(ToolbarGroup)).width, narrow);
      expect(find.byTooltip('Invite'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
}
