import 'package:flutter/material.dart';

import 'scroll_edge_painter.dart';

class ScrollEdge extends StatefulWidget {
  const ScrollEdge({super.key, required this.color, required this.child});
  final Color color;
  final Widget child;

  @override
  State<ScrollEdge> createState() => _ScrollEdgeState();
}

class _ScrollEdgeState extends State<ScrollEdge> {
  final edges = ValueNotifier<(bool, bool)>((false, false));

  void update(ScrollMetrics metrics, int depth) {
    if (depth != 0 || metrics.axis != Axis.vertical) return;
    final before = metrics.extentBefore > 1;
    final after = metrics.extentAfter > 1;
    edges.value = metrics.axisDirection == AxisDirection.up
        ? (after, before)
        : (before, after);
  }

  @override
  void dispose() {
    edges.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      NotificationListener<ScrollMetricsNotification>(
        onNotification: (event) {
          update(event.metrics, event.depth);
          return false;
        },
        child: NotificationListener<ScrollNotification>(
          onNotification: (event) {
            update(event.metrics, event.depth);
            return false;
          },
          child: CustomPaint(
            foregroundPainter: ScrollEdgePainter(
              color: widget.color,
              edges: edges,
            ),
            child: widget.child,
          ),
        ),
      );
}
