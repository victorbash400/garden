import 'package:flutter/material.dart';

import '../../model/appearance/theme_profile.dart';
import '../settings/settings_picker.dart';

class ThemePresetControl extends StatelessWidget {
  const ThemePresetControl({
    super.key,
    required this.profile,
    required this.presets,
    required this.onChanged,
  });
  final ThemeProfile profile;
  final List<ThemeProfile> presets;
  final ValueChanged<ThemeProfile>? onChanged;
  @override
  Widget build(BuildContext context) => SettingsPicker<String>(
    value: profile.id,
    items: [
      for (final preset in presets)
        DropdownMenuItem(
          value: preset.id,
          child: Text(
            preset.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
    ],
    onChanged: onChanged == null
        ? null
        : (id) =>
              onChanged!(presets.singleWhere((profile) => profile.id == id)),
  );
}
