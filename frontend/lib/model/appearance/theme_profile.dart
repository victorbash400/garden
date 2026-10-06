import 'package:flutter/material.dart';

class ThemeProfile {
  const ThemeProfile({
    required this.id,
    required this.name,
    required this.surface,
    required this.ink,
    required this.accent,
    required this.contrast,
    this.uiFont = 'Geist',
    this.codeFont = 'GeistMono',
  });
  final String? uiFont;
  final String? codeFont;
  final String id;
  final String name;
  final Color surface;
  final Color ink;
  final Color accent;
  final int contrast;

  ThemeProfile copyWith({
    Color? surface,
    Color? ink,
    Color? accent,
    int? contrast,
    String? uiFont,
  }) => ThemeProfile(
    id: id,
    name: name,
    uiFont: uiFont ?? this.uiFont,
    codeFont: codeFont,
    surface: surface ?? this.surface,
    ink: ink ?? this.ink,
    accent: accent ?? this.accent,
    contrast: contrast ?? this.contrast,
  );

  Map<String, Object?> toJson() => {
    'id': id,
    'surface': hexColor(surface),
    'ink': hexColor(ink),
    'accent': hexColor(accent),
    'contrast': contrast,
    'uiFont': uiFont,
  };

  static ThemeProfile fromJson(
    Map<String, dynamic> value,
    List<ThemeProfile> presets,
  ) {
    final preset = presets.where((preset) => preset.id == value['id']).single;
    final contrast = value['contrast'];
    if (contrast is! int || contrast < 0 || contrast > 100) {
      throw const FormatException('Contrast must be between 0 and 100.');
    }
    final font = value.containsKey('uiFont') ? value['uiFont'] : preset.uiFont;
    if (![null, '.AppleSystemUIFont', 'Geist', 'Inter'].contains(font)) {
      throw const FormatException('Unsupported UI font.');
    }
    return preset.copyWith(
      uiFont: font as String?,
      surface: parseColor(value['surface'] as String),
      ink: parseColor(value['ink'] as String),
      accent: parseColor(value['accent'] as String),
      contrast: contrast,
    );
  }
}

Color parseColor(String value) {
  final text = value.trim();
  if (text.length != 7 || !text.startsWith('#')) {
    throw const FormatException('Use a color in #RRGGBB format.');
  }
  const digits = '0123456789abcdefABCDEF';
  if (!text.substring(1).split('').every(digits.contains)) {
    throw const FormatException('Use a color in #RRGGBB format.');
  }
  return Color(0xFF000000 | int.parse(text.substring(1), radix: 16));
}

String hexColor(Color color) =>
    '#${color.toARGB32().toRadixString(16).substring(2).toUpperCase()}';
