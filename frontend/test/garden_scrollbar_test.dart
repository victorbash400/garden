import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:garden_flutter/ui/garden_scroll_behavior.dart';
import 'package:garden_flutter/ui/garden_theme.dart';

void main() {
  testWidgets(
    'pane scrollbars drag independently, including horizontal lists',
    (tester) async {
      final left = ScrollController();
      final right = ScrollController();
      final horizontal = ScrollController();
      addTearDown(left.dispose);
      addTearDown(right.dispose);
      addTearDown(horizontal.dispose);
      await tester.pumpWidget(
        MaterialApp(
          theme: GardenTheme.light.copyWith(platform: TargetPlatform.macOS),
          scrollBehavior: const GardenScrollBehavior(),
          home: Scaffold(
            body: Column(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      for (final controller in [left, right])
                        Expanded(
                          child: ListView.builder(
                            key: ValueKey(controller),
                            controller: controller,
                            itemCount: 40,
                            itemExtent: 40,
                            itemBuilder: (_, index) => Text('Item $index'),
                          ),
                        ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 80,
                  child: ListView.builder(
                    controller: horizontal,
                    scrollDirection: Axis.horizontal,
                    itemCount: 40,
                    itemExtent: 100,
                    itemBuilder: (_, index) => Text('File $index'),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(Scrollbar), findsNWidgets(3));
      final pane = find.byKey(ValueKey(left));
      await tester.drag(pane, const Offset(0, -80));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      final before = left.offset;
      final bounds = tester.getRect(pane);
      final point = Offset(bounds.right - 5, bounds.top + 60);
      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await gesture.addPointer(location: point);
      await gesture.moveTo(point);
      await tester.pump(const Duration(milliseconds: 200));
      await gesture.down(point);
      await tester.pump();
      await gesture.moveBy(const Offset(0, 10));
      await tester.pump();
      await gesture.moveBy(const Offset(0, 60));
      await tester.pump();
      await gesture.up();
      expect(left.offset, greaterThan(before));
      expect(right.offset, 0);
      await tester.drag(find.text('File 2'), const Offset(-150, 0));
      await tester.pump();
      expect(horizontal.offset, greaterThan(0));
      expect(right.offset, 0);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    },
  );
}
