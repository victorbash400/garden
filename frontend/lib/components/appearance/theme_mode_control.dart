import 'package:flutter/material.dart';

import '../../model/appearance/theme_profile.dart';
import '../../ui/garden_colors.dart';
import 'theme_mode_preview.dart';

class ThemeModeControl extends StatelessWidget {
  const ThemeModeControl({
    super.key,
    required this.mode,
    required this.light,
    required this.dark,
    required this.onChanged,
  });
  final ThemeMode mode;
  final ThemeProfile light;
  final ThemeProfile dark;
  final ValueChanged<ThemeMode>? onChanged;
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      for (final entry in const {
        ThemeMode.system: 'System',
        ThemeMode.light: 'Light',
        ThemeMode.dark: 'Dark',
      }.entries)
        Padding(
          padding: const EdgeInsets.only(left: 10),
          child: Tooltip(
            message: entry.value,
            child: Semantics(
              label: entry.value,
              button: true,
              selected: entry.key == mode,
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(9),
                child: InkWell(
                  onTap: onChanged == null ? null : () => onChanged!(entry.key),
                  borderRadius: BorderRadius.circular(9),
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(9),
                      border: Border.all(
                        color: entry.key == mode
                            ? GardenColors.of(context).accent
                            : GardenColors.of(context).border,
                        width: entry.key == mode ? 2 : 1,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: CustomPaint(
                        size: const Size(60, 36),
                        painter: ThemeModePreview(
                          mode: entry.key,
                          light: light,
                          dark: dark,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
    ],
  );
}
