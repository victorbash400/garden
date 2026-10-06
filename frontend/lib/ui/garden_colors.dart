import 'package:flutter/material.dart';

import '../model/appearance/theme_profile.dart';

class GardenColors extends ThemeExtension<GardenColors> {
  const GardenColors({
    required this.surface,
    required this.ink,
    required this.accent,
    required this.contrast,
    this.legacy = false,
    this.codeFont = 'GeistMono',
  });
  factory GardenColors.profile(ThemeProfile profile) => GardenColors(
    surface: profile.surface,
    ink: profile.ink,
    accent: profile.accent,
    contrast: profile.contrast,
    codeFont: profile.codeFont ?? 'monospace',
  );
  static GardenColors of(BuildContext context) =>
      Theme.of(context).extension<GardenColors>()!;
  final Color surface;
  final Color ink;
  final Color accent;
  final int contrast;
  final bool legacy;
  final String? codeFont;
  Color mix(double amount) => Color.lerp(surface, ink, amount)!;
  Color get secondary =>
      legacy ? const Color(0xFF737373) : mix(.56 + contrast * .001);
  Color get icon => mix(.78);
  Color get panel => legacy ? Colors.white : mix(.018);
  Color get sidebar => legacy ? const Color(0xFFF9F9F9) : surface;
  Color get sidebarBorder => mix(.16);
  Color get divider => mix(.08);
  Color get border => mix(.10 + contrast * .001);
  Color get selection => legacy
      ? const Color(0xFFE3E3E6)
      : Color.lerp(surface, accent, .13 + contrast * .001)!;
  Color get hover => mix(.06);
  Color get stripe => mix(.025);
  Color get disabled => mix(.28);
  Color get onAccent =>
      accent.computeLuminance() > .179 ? const Color(0xFF151515) : Colors.white;
  Color get danger =>
      ThemeData.estimateBrightnessForColor(surface) == Brightness.dark
      ? const Color(0xFFFF8E77)
      : const Color(0xFFB73526);
  Color get dangerSurface => Color.lerp(surface, danger, .09)!;
  Color get accentSurface => accent.withValues(alpha: .12);

  @override
  GardenColors copyWith({
    Color? surface,
    Color? ink,
    Color? accent,
    int? contrast,
    bool? legacy,
  }) => GardenColors(
    surface: surface ?? this.surface,
    ink: ink ?? this.ink,
    accent: accent ?? this.accent,
    contrast: contrast ?? this.contrast,
    legacy: legacy ?? this.legacy,
    codeFont: codeFont,
  );
  @override
  GardenColors lerp(covariant GardenColors? other, double t) {
    if (other == null) return this;
    return GardenColors(
      surface: Color.lerp(surface, other.surface, t)!,
      ink: Color.lerp(ink, other.ink, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      contrast: (contrast + (other.contrast - contrast) * t).round(),
      legacy: t < .5 ? legacy : other.legacy,
      codeFont: t < .5 ? codeFont : other.codeFont,
    );
  }
}
