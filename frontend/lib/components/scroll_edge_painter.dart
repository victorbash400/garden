import 'package:flutter/material.dart';

class ScrollEdgePainter extends CustomPainter {
  ScrollEdgePainter({required this.color, required this.edges})
    : super(repaint: edges);
  final Color color;
  final ValueNotifier<(bool, bool)> edges;

  @override
  void paint(Canvas canvas, Size size) {
    final height = size.height.clamp(0.0, 12.0);
    if (height == 0 || size.width == 0) return;
    for (final top in [true, false]) {
      if (!(top ? edges.value.$1 : edges.value.$2)) continue;
      // Leave the trailing scrollbar unobscured.
      final rect = Rect.fromLTWH(
        0,
        top ? 0 : size.height - height,
        (size.width - 8).clamp(0.0, size.width),
        height,
      );
      canvas.drawRect(
        rect,
        Paint()
          ..shader = LinearGradient(
            begin: top ? Alignment.topCenter : Alignment.bottomCenter,
            end: top ? Alignment.bottomCenter : Alignment.topCenter,
            colors: [color, color.withValues(alpha: 0)],
          ).createShader(rect),
      );
    }
  }

  @override
  bool shouldRepaint(ScrollEdgePainter oldDelegate) =>
      color != oldDelegate.color || edges != oldDelegate.edges;
}
