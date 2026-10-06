import 'package:flutter/material.dart';

import '../../model/appearance/theme_profile.dart';

class ThemeModePreview extends CustomPainter {
  const ThemeModePreview({
    required this.mode,
    required this.light,
    required this.dark,
  });
  final ThemeMode mode;
  final ThemeProfile light;
  final ThemeProfile dark;

  void draw(Canvas canvas, Size size, ThemeProfile profile) {
    final paint = Paint()..color = profile.surface;
    canvas.drawRect(Offset.zero & size, paint);
    paint.color = Color.lerp(profile.surface, profile.ink, .07)!;
    canvas.drawRect(Rect.fromLTWH(0, 0, 16, size.height), paint);
    paint.color = Color.lerp(profile.surface, profile.ink, .2)!;
    for (var i = 0; i < 3; i++) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(22, 13 + i * 6, i == 1 ? 24 : 30, 2),
          const Radius.circular(1),
        ),
        paint,
      );
    }
    paint.color = profile.accent;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(22, 7, 32, 2),
        const Radius.circular(1),
      ),
      paint,
    );
    canvas.drawCircle(Offset(size.width - 8, size.height - 7), 2, paint);
  }

  @override
  void paint(Canvas canvas, Size size) {
    draw(canvas, size, mode == ThemeMode.dark ? dark : light);
    if (mode == ThemeMode.system) {
      canvas.save();
      canvas.clipRect(
        Rect.fromLTWH(size.width / 2, 0, size.width / 2, size.height),
      );
      draw(canvas, size, dark);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(ThemeModePreview oldDelegate) =>
      mode != oldDelegate.mode ||
      light != oldDelegate.light ||
      dark != oldDelegate.dark;
}
