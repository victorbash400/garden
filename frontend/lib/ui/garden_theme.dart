import 'package:flutter/material.dart';

abstract final class GardenTheme {
  static const ink = Color(0xFF222226);
  static const secondary = Color(0xFF737373);
  static const canvas = Color(0xFFFAFAFB);
  static const sidebar = Color(0xFFF1F1F3);
  static const selection = Color(0xFFE3E3E6);
  static const blue = Color(0xFF087CFF);
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: canvas,
    fontFamily: '.AppleSystemUIFont',
    colorScheme: ColorScheme.fromSeed(
      seedColor: blue,
      brightness: Brightness.light,
      surface: canvas,
    ),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(fontSize: 14, color: ink),
      bodySmall: TextStyle(fontSize: 12, color: secondary),
    ),
    tooltipTheme: const TooltipThemeData(
      waitDuration: Duration(milliseconds: 450),
    ),
    sliderTheme: const SliderThemeData(
      activeTrackColor: ink,
      thumbColor: ink,
      trackHeight: 3,
    ),
  );
}
