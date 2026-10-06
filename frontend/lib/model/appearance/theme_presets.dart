import 'package:flutter/material.dart';

import 'theme_profile.dart';

// Codex, Catppuccin light, and Dracula dark values are documented at
// https://learn.chatgpt.com/docs/reference/settings. Absolutely light is the
// supplied Codex export. The other named palettes below use supplied exports.
const lightPresets = [
  ThemeProfile(
    id: 'absolutely',
    name: 'Clay',
    surface: Color(0xFFF9F9F7),
    ink: Color(0xFF2D2D2B),
    accent: Color(0xFFCC7D5E),
    contrast: 40,
  ),
  ThemeProfile(
    id: 'codex',
    name: 'Clear',
    surface: Color(0xFFFFFFFF),
    ink: Color(0xFF0D0D0D),
    accent: Color(0xFF0285FF),
    contrast: 45,
  ),
  ThemeProfile(
    id: 'catppuccin',
    name: 'Lilac',
    surface: Color(0xFFEFF1F5),
    ink: Color(0xFF4C4F69),
    accent: Color(0xFF8839EF),
    contrast: 40,
  ),
  ThemeProfile(
    id: 'gruvbox',
    name: 'Sand',
    surface: Color(0xFFFBF1C7),
    ink: Color(0xFF3C3836),
    accent: Color(0xFF458588),
    contrast: 40,
    uiFont: 'Geist',
    codeFont: 'GeistMono',
  ),
  ThemeProfile(
    id: 'everforest',
    name: 'Fern',
    surface: Color(0xFFFDF6E3),
    ink: Color(0xFF5C6A72),
    accent: Color(0xFF93B259),
    contrast: 40,
    uiFont: 'Geist',
    codeFont: 'GeistMono',
  ),
  ThemeProfile(
    id: 'notion',
    name: 'Paper',
    surface: Color(0xFFFFFFFF),
    ink: Color(0xFF37352F),
    accent: Color(0xFF3183D8),
    contrast: 40,
    uiFont: null,
    codeFont: null,
  ),
  ThemeProfile(
    id: 'raycast',
    name: 'Coral',
    surface: Color(0xFFFFFFFF),
    ink: Color(0xFF030303),
    accent: Color(0xFFFF6363),
    contrast: 40,
    uiFont: 'Inter',
    codeFont: 'JetBrainsMono',
  ),
];
const darkPresets = [
  ThemeProfile(
    id: 'absolutely',
    name: 'Clay',
    surface: Color(0xFF2D2D2B),
    ink: Color(0xFFF9F9F7),
    accent: Color(0xFFCC7D5E),
    contrast: 50,
  ),
  ThemeProfile(
    id: 'codex',
    name: 'Clear',
    surface: Color(0xFF181818),
    ink: Color(0xFFFFFFFF),
    accent: Color(0xFF339CFF),
    contrast: 60,
  ),
  ThemeProfile(
    id: 'dracula',
    name: 'Orchid',
    surface: Color(0xFF282A36),
    ink: Color(0xFFF8F8F2),
    accent: Color(0xFFFF79C6),
    contrast: 60,
  ),
];
