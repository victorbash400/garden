import 'package:flutter/material.dart';

import '../../model/appearance/theme_profile.dart';
import '../settings/settings_group.dart';
import '../settings/settings_row.dart';
import 'theme_preset_control.dart';
import 'theme_color_control.dart';
import 'theme_font_control.dart';

class ThemeProfileControls extends StatelessWidget {
  const ThemeProfileControls({
    super.key,
    required this.profile,
    required this.presets,
    required this.onChanged,
  });
  final ThemeProfile profile;
  final List<ThemeProfile> presets;
  final ValueChanged<ThemeProfile>? onChanged;
  @override
  Widget build(BuildContext context) => SettingsGroup(
    children: [
      SettingsRow(
        label: 'Theme',
        value: ThemePresetControl(
          profile: profile,
          presets: presets,
          onChanged: onChanged,
        ),
      ),
      for (final entry in {
        'Accent': profile.accent,
        'Background': profile.surface,
        'Foreground': profile.ink,
      }.entries)
        SettingsRow(
          label: entry.key,
          value: ThemeColorControl(
            key: ValueKey('${profile.id}-${entry.key}'),
            label: entry.key,
            color: entry.value,
            onChanged: onChanged == null
                ? null
                : (color) => onChanged!(switch (entry.key) {
                    'Accent' => profile.copyWith(accent: color),
                    'Background' => profile.copyWith(surface: color),
                    _ => profile.copyWith(ink: color),
                  }),
          ),
        ),
      SettingsRow(
        label: 'Font',
        value: ThemeFontControl(
          font: profile.uiFont,
          onChanged: onChanged == null
              ? null
              : (font) => onChanged!(profile.copyWith(uiFont: font)),
        ),
      ),
    ],
  );
}
