import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:garden_flutter/components/scroll_edge.dart';
import 'package:garden_flutter/components/scroll_edge_painter.dart';

void main() {
  for (final reverse in [false, true]) {
    testWidgets('scroll edges follow content and resize, reverse: $reverse', (
      tester,
    ) async {
      final controller = ScrollController();
      addTearDown(controller.dispose);
      Widget pane(int count) => MaterialApp(
        home: Scaffold(
          body: SizedBox(
            height: 160,
            child: ScrollEdge(
              color: Colors.white,
              child: ListView.builder(
                controller: controller,
                reverse: reverse,
                itemExtent: 40,
                itemCount: count,
                itemBuilder: (_, i) => Text('Item $i'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpWidget(pane(20));
      await tester.pumpAndSettle();
      ScrollEdgePainter painter() =>
          tester
                  .widget<CustomPaint>(
                    find.byWidgetPredicate(
                      (widget) =>
                          widget is CustomPaint &&
                          widget.foregroundPainter is ScrollEdgePainter,
                    ),
                  )
                  .foregroundPainter!
              as ScrollEdgePainter;
      expect(painter().edges.value, reverse ? (true, false) : (false, true));
      await tester.drag(find.byType(ListView), Offset(0, reverse ? 100 : -100));
      await tester.pumpAndSettle();
      expect(painter().edges.value, (true, true));
      controller.jumpTo(controller.position.maxScrollExtent);
      await tester.pumpAndSettle();
      expect(painter().edges.value, reverse ? (false, true) : (true, false));
      controller.jumpTo(0);
      await tester.pumpWidget(pane(1));
      await tester.pumpAndSettle();
      expect(painter().edges.value, (false, false));
      expect(tester.takeException(), isNull);
    });
  }
}
