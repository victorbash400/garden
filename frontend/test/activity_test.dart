import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:garden_flutter/components/files/hover_rename.dart';
import 'package:garden_flutter/components/settings/activity_row.dart';
import 'package:garden_flutter/model/activity_entry.dart';
import 'package:garden_flutter/services/activity_log.dart';

void main() {
  test('App log remains bounded and isolated by account', () {
    final log = ActivityLog();
    log.account = 'one';
    for (var i = 0; i < 310; i++) {
      log.record(2, 'File $i', 'Upload');
    }
    expect(log.entries('one').length, 300);
    log.account = 'two';
    log.record(3, 'Private', 'Open');
    expect(log.entries('one').any((entry) => entry.name == 'Private'), false);
    log.clear('one');
    expect(log.entries('one'), isEmpty);
    expect(log.entries('two').length, 1);
  });
  testWidgets('Activity expands measured read details', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ActivityRow(
            drive: 'Pepsi',
            entry: ActivityEntry(
              id: 'read',
              account: 'one',
              drive: 2,
              name: 'Video.mp4',
              action: 'Read',
              source: 'Cloud',
              time: DateTime(2026, 10, 5),
              bytes: 3072,
              count: 2,
              milliseconds: 40,
            ),
          ),
        ),
      ),
    );
    expect(find.text('3072 bytes · 2 reads'), findsNothing);
    await tester.tap(find.text('Video.mp4'));
    await tester.pump();
    expect(find.textContaining('3072 bytes · 2 reads'), findsOneWidget);
    expect(find.textContaining('40.0 ms total'), findsOneWidget);
  });
  testWidgets('Rename hover does not change row size and invokes action', (
    tester,
  ) async {
    var renamed = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: HoverRename(
            onRename: () => renamed = true,
            child: const SizedBox(width: 200, height: 34),
          ),
        ),
      ),
    );
    final before = tester.getSize(find.byType(HoverRename));
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: const Offset(500, 500));
    await mouse.moveTo(const Offset(30, 15));
    await tester.pump();
    expect(tester.getSize(find.byType(HoverRename)), before);
    await tester.tap(find.byTooltip('Rename'));
    expect(renamed, true);
    await mouse.removePointer();
  });
}
