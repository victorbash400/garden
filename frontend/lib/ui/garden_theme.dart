import 'package:flutter/material.dart';

import '../model/appearance/theme_profile.dart';
import 'garden_colors.dart';
import 'garden_scrollbar_theme.dart';

abstract final class GardenTheme {
  static const ink = Color(0xFF222226);
  static const secondary = Color(0xFF737373);
  static const canvas = Color(0xFFFAFAFB);
  static const sidebar = Color(0xFFF1F1F3);
  static const selection = Color(0xFFE3E3E6);
  static const blue = Color(0xFF087CFF);
  static final _lightProfiles = Expando<ThemeData>();
  static final _darkProfiles = Expando<ThemeData>();
  static ThemeData profile(ThemeProfile profile, Brightness brightness) {
    final cache = brightness == Brightness.light
        ? _lightProfiles
        : _darkProfiles;
    final cached = cache[profile];
    if (cached != null) return cached;
    final colors = GardenColors.profile(profile);
    final scheme =
        ColorScheme.fromSeed(
          seedColor: colors.accent,
          brightness: brightness,
        ).copyWith(
          primary: colors.accent,
          onPrimary: colors.onAccent,
          surface: colors.surface,
          onSurface: colors.ink,
          onSurfaceVariant: colors.secondary,
          outline: colors.border,
          outlineVariant: colors.border,
          error: colors.danger,
          surfaceContainerHighest: colors.hover,
          surfaceContainer: colors.panel,
          surfaceContainerLow: colors.panel,
        );
    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      fontFamily: profile.uiFont ?? '.AppleSystemUIFont',
      colorScheme: scheme,
    );
    final theme = base.copyWith(
      extensions: [colors],
      scrollbarTheme: gardenScrollbarTheme(colors.ink),
      scaffoldBackgroundColor: colors.surface,
      textTheme: base.textTheme.apply(
        bodyColor: colors.ink,
        displayColor: colors.ink,
      ),
      iconTheme: IconThemeData(color: colors.ink),
      dividerColor: colors.border,
      disabledColor: colors.disabled,
      splashColor: colors.accentSurface,
      hoverColor: colors.hover,
      dialogTheme: DialogThemeData(
        elevation: 2,
        shadowColor: colors.ink.withValues(alpha: .12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: colors.border),
        ),
        backgroundColor: colors.panel,
        surfaceTintColor: Colors.transparent,
      ),
      popupMenuTheme: PopupMenuThemeData(
        elevation: 1,
        shadowColor: colors.ink.withValues(alpha: .14),
        menuPadding: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: colors.border),
        ),
        textStyle: base.textTheme.bodyMedium!.copyWith(fontSize: 13),
        color: colors.panel,
        surfaceTintColor: Colors.transparent,
      ),
      tooltipTheme: const TooltipThemeData(
        waitDuration: Duration(milliseconds: 450),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: colors.accent,
        thumbColor: colors.accent,
        inactiveTrackColor: colors.border,
        trackHeight: 3,
      ),
    );
    cache[profile] = theme;
    return theme;
  }

  static ThemeData get light => ThemeData(
    useMaterial3: true,
    extensions: const [
      GardenColors(
        surface: canvas,
        ink: ink,
        accent: blue,
        contrast: 40,
        legacy: true,
      ),
    ],
    brightness: Brightness.light,
    scrollbarTheme: gardenScrollbarTheme(ink),
    scaffoldBackgroundColor: canvas,
    fontFamily: 'GoogleSans',
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
      activeTickMarkColor: Colors.transparent,
      inactiveTickMarkColor: Colors.transparent,
    ),
  );
}
