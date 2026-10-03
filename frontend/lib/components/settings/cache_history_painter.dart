import 'package:flutter/material.dart';

import '../../model/cache_sample.dart';

class CacheHistoryPainter extends CustomPainter {
  const CacheHistoryPainter({required this.samples, required this.maximum});
  final List<CacheSample> samples;
  final int maximum;

  @override
  void paint(Canvas canvas, Size size) {
    final grid = Paint()
      ..color = const Color(0xFFE6ECE8)
      ..strokeWidth = 1;
    for (var row = 0; row <= 4; row++) {
      final y = size.height * row / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }
    for (var column = 0; column <= 10; column++) {
      final x = size.width * column / 10;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);
    }
    if (samples.isEmpty) return;
    final end = samples.last.time.millisecondsSinceEpoch;
    const window = 5 * 60 * 1000;
    Offset point(CacheSample sample) => Offset(
      size.width *
          (1 - (end - sample.time.millisecondsSinceEpoch) / window).clamp(0, 1),
      size.height * (1 - sample.bytes / maximum).clamp(0, 1),
    );
    final first = point(samples.first);
    final last = point(samples.last);
    if (samples.length > 1) {
      final line = Path()..moveTo(first.dx, first.dy);
      for (final sample in samples.skip(1)) {
        final position = point(sample);
        line.lineTo(position.dx, position.dy);
      }
      final fill = Path.from(line)
        ..lineTo(last.dx, size.height)
        ..lineTo(first.dx, size.height)
        ..close();
      canvas.drawPath(fill, Paint()..color = const Color(0x18506F5C));
      canvas.drawPath(
        line,
        Paint()
          ..color = const Color(0xFF506F5C)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..strokeJoin = StrokeJoin.round,
      );
    }
    canvas.drawCircle(last, 3, Paint()..color = const Color(0xFF506F5C));
  }

  @override
  bool shouldRepaint(CacheHistoryPainter oldDelegate) =>
      oldDelegate.samples != samples || oldDelegate.maximum != maximum;
}
